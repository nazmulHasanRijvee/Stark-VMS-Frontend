import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/vehicles_repository_impl.dart';
import '../../../../domain/entities/dashboard_stats.dart';
import '../../../../domain/entities/paged_response.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../../../domain/repositories/vehicles_repository.dart';

export '../../../../domain/entities/dashboard_stats.dart';
export '../../../../domain/entities/vehicle.dart';

class VehiclesLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setLoading(bool loading) => state = loading;
}

final vehiclesLoadingProvider = NotifierProvider<VehiclesLoadingNotifier, bool>(
  VehiclesLoadingNotifier.new,
);

/// Single source of truth for fleet vehicle records backed by the REST API.
class VehiclesNotifier extends Notifier<List<Vehicle>> {
  late VehiclesRepository _repository;

  String? get lastError => _repository.lastError;

  @override
  List<Vehicle> build() {
    _repository = ref.watch(vehiclesRepositoryProvider);
    Future.microtask(() => fetchVehicles());
    return const [];
  }

  /// Fetch vehicles from the backend API.
  Future<void> fetchVehicles() async {
    ref.read(vehiclesLoadingProvider.notifier).setLoading(true);
    try {
      final vehicles = await _repository.getVehicles(
        sortBy: 'updatedAt',
        sortDirection: 'desc',
      );
      state = vehicles;
    } finally {
      ref.read(vehiclesLoadingProvider.notifier).setLoading(false);
    }
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

  /// Retrieve a vehicle by number for pre-filling the edit form or details.
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
    ref.invalidate(vehiclesPageProvider);
    ref.read(dashboardStatsProvider.notifier).refresh();
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
    ref.invalidate(vehiclesPageProvider);
    ref.read(dashboardStatsProvider.notifier).refresh();
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
      ref.invalidate(vehiclesPageProvider);
      ref.read(dashboardStatsProvider.notifier).refresh();
      return true;
    }
    return false;
  }

  /// Assign driver to vehicle and update state
  Future<bool> assignDriver(String vehicleNumber, int driverId) async {
    final updated = await _repository.assignDriver(vehicleNumber, driverId);
    if (updated != null) {
      final normalized = vehicleNumber.trim().toUpperCase();
      state = [
        for (final v in state)
          if (v.vehicleNumber.trim().toUpperCase() == normalized)
            updated
          else
            v,
      ];
      return true;
    }
    return false;
  }

  /// Unassign driver from vehicle and update state
  Future<bool> unassignDriver(String vehicleNumber) async {
    final success = await _repository.unassignDriver(vehicleNumber);
    if (success) {
      final normalized = vehicleNumber.trim().toUpperCase();
      state = [
        for (final v in state)
          if (v.vehicleNumber.trim().toUpperCase() == normalized)
            v.copyWith(assignedDriver: () => null)
          else
            v,
      ];
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
  final int page;
  final int size;
  final String sortBy;
  final String sortDirection;

  const VehicleFilterState({
    this.searchQuery = '',
    this.statusFilter = allStatuses,
    this.page = 0,
    this.size = 10,
    this.sortBy = 'updatedAt',
    this.sortDirection = 'desc',
  });

  VehicleFilterState copyWith({
    String? searchQuery,
    String? statusFilter,
    int? page,
    int? size,
    String? sortBy,
    String? sortDirection,
  }) {
    return VehicleFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      page: page ?? this.page,
      size: size ?? this.size,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

class VehicleFilterNotifier extends Notifier<VehicleFilterState> {
  @override
  VehicleFilterState build() => const VehicleFilterState();

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query.trim(), page: 0);
  }

  void setStatus(String status) {
    state = state.copyWith(statusFilter: status, page: 0);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void setSort(String sortBy, String sortDirection) {
    state = state.copyWith(
      sortBy: sortBy,
      sortDirection: sortDirection,
      page: 0,
    );
  }

  void reset() {
    state = const VehicleFilterState();
  }
}

final vehicleFilterProvider =
    NotifierProvider<VehicleFilterNotifier, VehicleFilterState>(
      VehicleFilterNotifier.new,
    );

@immutable
class VehiclesPageState {
  final PagedResponse<Vehicle> result;
  final bool isLoading;
  final String? errorMessage;

  const VehiclesPageState({
    this.result = const PagedResponse.empty(),
    this.isLoading = false,
    this.errorMessage,
  });

  VehiclesPageState copyWith({
    PagedResponse<Vehicle>? result,
    bool? isLoading,
    String? errorMessage,
  }) => VehiclesPageState(
    result: result ?? this.result,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
  );
}

class VehiclesPageNotifier extends Notifier<VehiclesPageState> {
  late VehiclesRepository _repository;
  int _requestId = 0;

  @override
  VehiclesPageState build() {
    _repository = ref.watch(vehiclesRepositoryProvider);
    final filter = ref.watch(vehicleFilterProvider);
    Future.microtask(() => fetchPage(filter));
    return const VehiclesPageState(isLoading: true);
  }

  Future<void> fetchPage([VehicleFilterState? requestedFilter]) async {
    final requestId = ++_requestId;
    final filter = requestedFilter ?? ref.read(vehicleFilterProvider)!;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getVehiclesPaged(
      search: filter.searchQuery.isNotEmpty ? filter.searchQuery : null,
      status: filter.statusFilter != VehicleFilterState.allStatuses
          ? filter.statusFilter
          : null,
      page: filter.page,
      size: filter.size,
      sortBy: filter.sortBy,
      sortDirection: filter.sortDirection,
    );
    if (requestId != _requestId) return;
    state = state.copyWith(
      result: result,
      isLoading: false,
      errorMessage: result.isEmpty ? _repository.lastError : null,
    );
  }
}

final vehiclesPageProvider =
    NotifierProvider<VehiclesPageNotifier, VehiclesPageState>(
      VehiclesPageNotifier.new,
    );

// =============================================================================
// Dashboard Derived Metrics & Sync
// =============================================================================

class DashboardLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setLoading(bool loading) => state = loading;
}

final dashboardLoadingProvider =
    NotifierProvider<DashboardLoadingNotifier, bool>(
      DashboardLoadingNotifier.new,
    );

class DashboardStatsErrorNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setError(bool hasError) => state = hasError;
}

final dashboardStatsErrorProvider =
    NotifierProvider<DashboardStatsErrorNotifier, bool>(
      DashboardStatsErrorNotifier.new,
    );

class DashboardStatsNotifier extends Notifier<DashboardStats> {
  @override
  DashboardStats build() {
    Future.microtask(() {
      if (ref.mounted) refresh();
    });
    return const DashboardStats.empty();
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    ref.read(dashboardLoadingProvider.notifier).setLoading(true);
    ref.read(dashboardStatsErrorProvider.notifier).setError(false);
    try {
      final repo = ref.read(vehiclesRepositoryProvider);
      final stats = await repo.getDashboardStats();
      if (!ref.mounted) return;
      if (repo.lastError == null) {
        state = stats;
        ref.read(dashboardStatsErrorProvider.notifier).setError(false);
      } else {
        ref.read(dashboardStatsErrorProvider.notifier).setError(true);
      }
    } catch (_) {
      if (ref.mounted) {
        ref.read(dashboardStatsErrorProvider.notifier).setError(true);
      }
    } finally {
      if (ref.mounted) {
        ref.read(dashboardLoadingProvider.notifier).setLoading(false);
      }
    }
  }
}

final dashboardStatsProvider =
    NotifierProvider<DashboardStatsNotifier, DashboardStats>(
      DashboardStatsNotifier.new,
    );

/// First four recently updated vehicles for the dashboard preview.
final recentlyAddedVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  return vehicles.take(4).toList();
});
