import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/vehicles_repository_impl.dart';
import '../../../../domain/entities/dashboard_stats.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../../../domain/repositories/vehicles_repository.dart';

export '../../../../domain/entities/dashboard_stats.dart';

/// Single source of truth for fleet vehicle records backed by the REST API.
///
/// Modifying this state (create, edit, delete) automatically and reactively
/// updates both the Vehicles List screen and the Dashboard summary KPI cards.
class VehiclesNotifier extends Notifier<List<Vehicle>> {
  late final VehiclesRepository _repository;

  @override
  List<Vehicle> build() {
    _repository = ref.watch(vehiclesRepositoryProvider);
    Future.microtask(() => fetchVehicles());
    return const [];
  }

  /// Fetch vehicles from the backend API.
  Future<void> fetchVehicles() async {
    final vehicles = await _repository.getVehicles();
    state = vehicles;
  }

  /// Check whether a vehicle number already exists (case-insensitive).
  bool isDuplicate(String vehicleNumber, {String? excludeVehicleNumber}) {
    final normalized = vehicleNumber.trim().toUpperCase();
    final normalizedExclude = excludeVehicleNumber?.trim().toUpperCase();

    if (normalized.isEmpty) return false;

    return state.any((v) {
      final current = v.vehicleNumber.trim().toUpperCase();
      if (normalizedExclude != null && current == normalizedExclude) {
        return false;
      }
      return current == normalized;
    });
  }

  /// Retrieve a vehicle by number for pre-filling the edit form.
  Vehicle? getVehicle(String vehicleNumber) {
    final normalized = vehicleNumber.trim().toUpperCase();
    try {
      return state.firstWhere(
        (v) => v.vehicleNumber.trim().toUpperCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  /// Add a new vehicle with duplicate-number validation.
  /// Returns null on success, or an error message string on failure.
  Future<String?> addVehicle(Vehicle vehicle) async {
    if (isDuplicate(vehicle.vehicleNumber)) {
      return AppStrings.duplicateVehicleError;
    }

    final normalized = vehicle.copyWith(
      vehicleNumber: vehicle.vehicleNumber.trim().toUpperCase(),
    );

    final created = await _repository.createVehicle(normalized);
    if (created == null) {
      return _repository.lastError ?? AppStrings.duplicateVehicleError;
    }

    state = [created, ...state];
    return null;
  }

  /// Update an existing vehicle with duplicate-number validation.
  /// Returns null on success, or an error message string on failure.
  Future<String?> updateVehicle(
    String originalVehicleNumber,
    Vehicle updated,
  ) async {
    if (isDuplicate(
      updated.vehicleNumber,
      excludeVehicleNumber: originalVehicleNumber,
    )) {
      return AppStrings.duplicateVehicleError;
    }

    final normalizedOriginal = originalVehicleNumber.trim().toUpperCase();
    final result = await _repository.updateVehicle(normalizedOriginal, updated);

    if (result == null) {
      return _repository.lastError ?? 'Failed to update vehicle.';
    }

    state = [
      for (final v in state)
        if (v.vehicleNumber.trim().toUpperCase() == normalizedOriginal)
          result
        else
          v,
    ];
    return null;
  }

  /// Delete a vehicle by its vehicle number.
  Future<bool> deleteVehicle(String vehicleNumber) async {
    final normalized = vehicleNumber.trim().toUpperCase();
    final success = await _repository.deleteVehicle(normalized);

    if (success) {
      state = state
          .where((v) => v.vehicleNumber.trim().toUpperCase() != normalized)
          .toList();
      return true;
    }
    return false;
  }
}

final vehiclesProvider = NotifierProvider<VehiclesNotifier, List<Vehicle>>(
  VehiclesNotifier.new,
);

// =============================================================================
// Filters & Search State
// =============================================================================

@immutable
class VehicleFilterState {
  static const allStatuses = 'All';

  final String searchQuery;
  final String statusFilter;

  const VehicleFilterState({
    this.searchQuery = '',
    this.statusFilter = allStatuses,
  });

  VehicleFilterState copyWith({String? searchQuery, String? statusFilter}) {
    return VehicleFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class VehicleFilterNotifier extends Notifier<VehicleFilterState> {
  @override
  VehicleFilterState build() => const VehicleFilterState();

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void setStatus(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void reset() {
    state = const VehicleFilterState();
  }
}

final vehicleFilterProvider =
    NotifierProvider<VehicleFilterNotifier, VehicleFilterState>(
      VehicleFilterNotifier.new,
    );

/// Filtered list of fleet vehicles reacting to search text and status dropdown.
final filteredVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  final filter = ref.watch(vehicleFilterProvider);

  return vehicles.where((v) {
    final matchesStatus =
        filter.statusFilter == VehicleFilterState.allStatuses ||
        v.status == filter.statusFilter;

    if (!matchesStatus) return false;

    if (filter.searchQuery.isEmpty) return true;

    final query = filter.searchQuery.toLowerCase();
    final matchesQuery =
        v.vehicleNumber.toLowerCase().contains(query) ||
        v.company.toLowerCase().contains(query) ||
        v.brand.toLowerCase().contains(query) ||
        v.model.toLowerCase().contains(query) ||
        v.type.toLowerCase().contains(query);

    return matchesQuery;
  }).toList();
});

// =============================================================================
// Dashboard Derived Metrics
// =============================================================================

class DashboardStatsNotifier extends Notifier<DashboardStats> {
  @override
  DashboardStats build() {
    final vehicles = ref.watch(vehiclesProvider);
    int activeCount = 0;
    int inServiceCount = 0;
    int inactiveCount = 0;

    for (final v in vehicles) {
      switch (v.status) {
        case Vehicle.statusActive:
          activeCount++;
          break;
        case Vehicle.statusInService:
          inServiceCount++;
          break;
        case Vehicle.statusInactive:
          inactiveCount++;
          break;
      }
    }

    return DashboardStats(
      total: vehicles.length,
      active: activeCount,
      inService: inServiceCount,
      inactive: inactiveCount,
    );
  }

  Future<void> refresh() async {
    try {
      final repo = ref.read(vehiclesRepositoryProvider);
      final stats = await repo.getDashboardStats();
      if (stats.total > 0) {
        state = stats;
      }
    } catch (_) {}
  }
}

final dashboardStatsProvider =
    NotifierProvider<DashboardStatsNotifier, DashboardStats>(
      DashboardStatsNotifier.new,
    );

/// First 4 recent vehicles for the dashboard preview.
final recentlyAddedVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  return vehicles.take(4).toList();
});
