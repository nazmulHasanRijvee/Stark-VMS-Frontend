import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/maintenance_repository_impl.dart';
import '../../../../domain/entities/maintenance_record.dart';
import '../../../../domain/repositories/maintenance_repository.dart';

@immutable
class VehicleMaintenanceState {
  final List<MaintenanceRecord> records;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const VehicleMaintenanceState({
    this.records = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  VehicleMaintenanceState copyWith({
    List<MaintenanceRecord>? records,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return VehicleMaintenanceState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class VehicleMaintenanceNotifier extends Notifier<VehicleMaintenanceState> {
  VehicleMaintenanceNotifier(this.arg);

  final String arg;
  late MaintenanceRepository _repository;

  @override
  VehicleMaintenanceState build() {
    _repository = ref.watch(maintenanceRepositoryProvider);
    Future.microtask(() => loadRecords());
    return const VehicleMaintenanceState(isLoading: true);
  }

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    const pageSize = 100;
    final firstPage = await _repository.getMaintenanceRecords(
      arg,
      page: 0,
      size: pageSize,
    );
    final records = [...firstPage.content];
    for (var page = 1; page < firstPage.totalPages; page++) {
      final nextPage = await _repository.getMaintenanceRecords(
        arg,
        page: page,
        size: pageSize,
      );
      records.addAll(nextPage.content);
      if (_repository.lastError != null) break;
    }
    state = state.copyWith(
      records: records,
      isLoading: false,
      errorMessage: records.isEmpty ? _repository.lastError : null,
    );
  }

  Future<bool> addRecord(MaintenanceRecord record) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final created = await _repository.createMaintenanceRecord(
      vehicleNumber: arg,
      record: record,
    );

    if (created != null) {
      state = state.copyWith(
        records: [created, ...state.records],
        isSubmitting: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            _repository.lastError ?? 'Failed to add maintenance record.',
      );
      return false;
    }
  }
}

final vehicleMaintenanceProvider =
    NotifierProvider.family<
      VehicleMaintenanceNotifier,
      VehicleMaintenanceState,
      String
    >(VehicleMaintenanceNotifier.new);
