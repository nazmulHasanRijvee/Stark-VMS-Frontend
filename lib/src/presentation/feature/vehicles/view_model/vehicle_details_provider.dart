import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/vehicles_repository_impl.dart';
import '../../../../domain/repositories/vehicles_repository.dart';
import '../../drivers/view_model/drivers_provider.dart';
import 'vehicles_provider.dart';

@immutable
class VehicleDetailsState {
  final Vehicle? vehicle;
  final bool isLoading;
  final String? errorMessage;
  final bool isAssigningDriver;
  final String? assignmentError;

  const VehicleDetailsState({
    this.vehicle,
    this.isLoading = false,
    this.errorMessage,
    this.isAssigningDriver = false,
    this.assignmentError,
  });

  VehicleDetailsState copyWith({
    Vehicle? vehicle,
    bool? isLoading,
    String? errorMessage,
    bool? isAssigningDriver,
    String? assignmentError,
    bool clearAssignmentError = false,
  }) {
    return VehicleDetailsState(
      vehicle: vehicle ?? this.vehicle,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAssigningDriver: isAssigningDriver ?? this.isAssigningDriver,
      assignmentError: clearAssignmentError
          ? null
          : (assignmentError ?? this.assignmentError),
    );
  }
}

class VehicleDetailsNotifier extends Notifier<VehicleDetailsState> {
  VehicleDetailsNotifier(this.arg);

  final String arg;
  late VehiclesRepository _repository;

  @override
  VehicleDetailsState build() {
    _repository = ref.watch(vehiclesRepositoryProvider);
    // Find in existing vehicles list initially if available
    final existing = ref
        .watch(vehiclesProvider)
        .where(
          (v) =>
              v.vehicleNumber.trim().toUpperCase() == arg.trim().toUpperCase(),
        );
    final initialVehicle = existing.isNotEmpty ? existing.first : null;

    Future.microtask(() => loadVehicle(arg));

    return VehicleDetailsState(
      vehicle: initialVehicle,
      isLoading: initialVehicle == null,
    );
  }

  Future<void> loadVehicle(String vehicleNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final vehicle = await _repository.getVehicle(vehicleNumber);
    if (vehicle != null) {
      state = state.copyWith(vehicle: vehicle, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _repository.lastError ?? 'Vehicle not found.',
      );
    }
  }

  Future<bool> assignDriver(int driverId) async {
    if (state.vehicle == null) return false;
    final vehicleNumber = state.vehicle!.vehicleNumber;

    state = state.copyWith(isAssigningDriver: true, clearAssignmentError: true);

    final updated = await _repository.assignDriver(vehicleNumber, driverId);
    if (updated != null) {
      state = state.copyWith(vehicle: updated, isAssigningDriver: false);
      // Synchronize in fleet vehicles provider
      ref.read(vehiclesProvider.notifier).fetchVehicles();
      ref.invalidate(vehiclesPageProvider);
      ref.invalidate(driversProvider);
      return true;
    } else {
      state = state.copyWith(
        isAssigningDriver: false,
        assignmentError:
            _repository.lastError ?? 'Failed to assign driver to vehicle.',
      );
      return false;
    }
  }

  Future<bool> unassignDriver() async {
    if (state.vehicle == null) return false;
    final vehicleNumber = state.vehicle!.vehicleNumber;

    state = state.copyWith(isAssigningDriver: true, clearAssignmentError: true);

    final success = await _repository.unassignDriver(vehicleNumber);
    if (success) {
      state = state.copyWith(
        vehicle: state.vehicle!.copyWith(assignedDriver: () => null),
        isAssigningDriver: false,
      );
      // Synchronize in fleet vehicles provider
      ref.read(vehiclesProvider.notifier).fetchVehicles();
      ref.invalidate(vehiclesPageProvider);
      ref.invalidate(driversProvider);
      return true;
    } else {
      state = state.copyWith(
        isAssigningDriver: false,
        assignmentError:
            _repository.lastError ?? 'Failed to unassign driver from vehicle.',
      );
      return false;
    }
  }
}

final vehicleDetailsProvider =
    NotifierProvider.family<
      VehicleDetailsNotifier,
      VehicleDetailsState,
      String
    >(VehicleDetailsNotifier.new);
