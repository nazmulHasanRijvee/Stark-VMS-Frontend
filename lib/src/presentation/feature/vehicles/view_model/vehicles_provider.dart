import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../data/mock/mock_vehicle_data.dart';
import '../../../../domain/entities/vehicle.dart';

/// Single source of truth for in-memory fleet vehicle records.
///
/// Modifying this state (create, edit, delete) automatically and reactively
/// updates both the Vehicles List screen and the Dashboard summary KPI cards.
class VehiclesNotifier extends Notifier<List<Vehicle>> {
  @override
  List<Vehicle> build() {
    return List<Vehicle>.from(MockVehicleData.initialFleet);
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
  /// Returns null on success, or an error message string on duplicate failure.
  String? addVehicle(Vehicle vehicle) {
    if (isDuplicate(vehicle.vehicleNumber)) {
      return AppStrings.duplicateVehicleError;
    }

    state = [vehicle, ...state];
    return null;
  }

  /// Update an existing vehicle with duplicate-number validation.
  /// Returns null on success, or an error message string on failure.
  String? updateVehicle(String originalVehicleNumber, Vehicle updated) {
    if (isDuplicate(
      updated.vehicleNumber,
      excludeVehicleNumber: originalVehicleNumber,
    )) {
      return AppStrings.duplicateVehicleError;
    }

    final normalizedOriginal = originalVehicleNumber.trim().toUpperCase();
    state = [
      for (final v in state)
        if (v.vehicleNumber.trim().toUpperCase() == normalizedOriginal)
          updated
        else
          v,
    ];
    return null;
  }

  /// Delete a vehicle by its vehicle number.
  void deleteVehicle(String vehicleNumber) {
    final normalized = vehicleNumber.trim().toUpperCase();
    state = state
        .where((v) => v.vehicleNumber.trim().toUpperCase() != normalized)
        .toList();
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
    state = state.copyWith(searchQuery: query);
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

/// Derived list of vehicles matching current search query and status filter.
final filteredVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  final filter = ref.watch(vehicleFilterProvider);

  final query = filter.searchQuery.trim().toLowerCase();
  final status = filter.statusFilter;

  return vehicles.where((v) {
    final matchesQuery =
        query.isEmpty ||
        v.vehicleNumber.toLowerCase().contains(query) ||
        v.brand.toLowerCase().contains(query) ||
        v.model.toLowerCase().contains(query) ||
        v.company.toLowerCase().contains(query) ||
        v.type.toLowerCase().contains(query);

    final matchesStatus =
        status == VehicleFilterState.allStatuses ||
        v.status.toLowerCase() == status.toLowerCase();

    return matchesQuery && matchesStatus;
  }).toList();
});

// =============================================================================
// Dashboard Derived Metrics
// =============================================================================

@immutable
class DashboardStats {
  final int total;
  final int active;
  final int inService;
  final int inactive;

  const DashboardStats({
    required this.total,
    required this.active,
    required this.inService,
    required this.inactive,
  });
}

/// Derived counts computed purely from the vehicle state.
/// Ensures that creating, editing, or deleting a vehicle updates the counts instantly.
final dashboardStatsProvider = Provider<DashboardStats>((ref) {
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
});

/// First 4 recent vehicles for the dashboard preview.
final recentlyAddedVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  return vehicles.take(4).toList();
});
