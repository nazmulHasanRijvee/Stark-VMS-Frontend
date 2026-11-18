import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/drivers_repository_impl.dart';
import '../../../../domain/entities/driver.dart';
import '../../../../domain/repositories/drivers_repository.dart';

export '../../../../domain/entities/driver.dart';

@immutable
class DriversFilterState {
  static const allStatuses = 'All';

  final String searchQuery;
  final String statusFilter;
  final int page;
  final int size;
  final String? sortBy;
  final String? sortDirection;

  const DriversFilterState({
    this.searchQuery = '',
    this.statusFilter = allStatuses,
    this.page = 0,
    this.size = 10,
    this.sortBy,
    this.sortDirection,
  });

  DriversFilterState copyWith({
    String? searchQuery,
    String? statusFilter,
    int? page,
    int? size,
    String? sortBy,
    String? sortDirection,
  }) {
    return DriversFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      page: page ?? this.page,
      size: size ?? this.size,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

class DriversFilterNotifier extends Notifier<DriversFilterState> {
  @override
  DriversFilterState build() => const DriversFilterState();

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query.trim(), page: 0);
  }

  void setStatus(String status) {
    state = state.copyWith(statusFilter: status, page: 0);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void reset() {
    state = const DriversFilterState();
  }
}

final driversFilterProvider =
    NotifierProvider<DriversFilterNotifier, DriversFilterState>(
      DriversFilterNotifier.new,
    );

@immutable
class DriversListState {
  final List<Driver> drivers;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const DriversListState({
    this.drivers = const [],
    this.totalElements = 0,
    this.totalPages = 0,
    this.currentPage = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  DriversListState copyWith({
    List<Driver>? drivers,
    int? totalElements,
    int? totalPages,
    int? currentPage,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return DriversListState(
      drivers: drivers ?? this.drivers,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class DriversNotifier extends Notifier<DriversListState> {
  late DriversRepository _repository;

  @override
  DriversListState build() {
    _repository = ref.watch(driversRepositoryProvider);
    final filter = ref.watch(driversFilterProvider);

    Future.microtask(() => fetchDrivers(filter));

    return const DriversListState(isLoading: true);
  }

  Future<void> fetchDrivers([DriversFilterState? filterState]) async {
    final filter = filterState ?? ref.read(driversFilterProvider)!;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final paged = await _repository.getDrivers(
      search: filter.searchQuery.isNotEmpty ? filter.searchQuery : null,
      status: filter.statusFilter != DriversFilterState.allStatuses
          ? filter.statusFilter
          : null,
      page: filter.page,
      size: filter.size,
      sortBy: filter.sortBy,
      sortDirection: filter.sortDirection,
    );

    state = state.copyWith(
      drivers: paged.content,
      totalElements: paged.totalElements,
      totalPages: paged.totalPages,
      currentPage: paged.page,
      isLoading: false,
      errorMessage: paged.isEmpty ? _repository.lastError : null,
    );
  }

  Future<bool> createDriver(Driver driver) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final created = await _repository.createDriver(driver);
    if (created != null) {
      await fetchDrivers();
      state = state.copyWith(isSubmitting: false);
      return true;
    } else {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _repository.lastError ?? 'Failed to create driver.',
      );
      return false;
    }
  }

  Future<bool> updateDriver(int driverId, Driver driver) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final updated = await _repository.updateDriver(driverId, driver);
    if (updated != null) {
      await fetchDrivers();
      state = state.copyWith(isSubmitting: false);
      return true;
    } else {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _repository.lastError ?? 'Failed to update driver.',
      );
      return false;
    }
  }

  Future<bool> deleteDriver(int driverId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final success = await _repository.deleteDriver(driverId);
    if (success) {
      await fetchDrivers();
      state = state.copyWith(isSubmitting: false);
      return true;
    } else {
      final err = _repository.lastError ?? 'Failed to delete driver.';
      state = state.copyWith(isSubmitting: false, errorMessage: err);
      return false;
    }
  }

  /// Helper to get all Active unassigned drivers for the driver assignment dialog.
  Future<List<Driver>> getAvailableActiveDrivers() async {
    const pageSize = 100;
    final available = <Driver>[];
    var page = 0;
    var totalPages = 1;

    while (page < totalPages) {
      final response = await _repository.getDrivers(
        status: Driver.statusActive,
        page: page,
        size: pageSize,
      );
      available.addAll(
        response.content.where((driver) => driver.assignedVehicle == null),
      );
      totalPages = response.totalPages;
      if (response.isEmpty || _repository.lastError != null) break;
      page++;
    }

    return available;
  }
}

final driversProvider = NotifierProvider<DriversNotifier, DriversListState>(
  DriversNotifier.new,
);
