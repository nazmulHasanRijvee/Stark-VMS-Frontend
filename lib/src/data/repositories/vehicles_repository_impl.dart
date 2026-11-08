import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicles_repository.dart';
import '../services/network/api_handler.dart';
import '../services/network/rest_client.dart';

class VehiclesRepositoryImpl implements VehiclesRepository {
  VehiclesRepositoryImpl({required this.remote});

  final RestClient remote;
  String? _lastError;

  @override
  String? get lastError => _lastError;

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    }
    return <String, dynamic>{};
  }

  @override
  Future<List<Vehicle>> getVehicles({
    String? search,
    String? status,
    int page = 0,
    int size = 100,
  }) async {
    List<Vehicle> list = [];
    _lastError = null;

    await Api.call(
      action: remote.getVehicles(
        search: search,
        status: status,
        page: page,
        size: size,
      ),
      onSuccess: (response) {
        List<dynamic> items = [];
        if (response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic> && data['content'] is List) {
            items = data['content'] as List<dynamic>;
          } else if (data is List) {
            items = data;
          } else if (response['content'] is List) {
            items = response['content'] as List<dynamic>;
          }
        } else if (response is List) {
          items = response;
        }

        list = items
            .whereType<Map<String, dynamic>>()
            .map(Vehicle.fromMap)
            .toList();
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return list;
  }

  @override
  Future<Vehicle?> getVehicle(String vehicleNumber) async {
    Vehicle? vehicle;
    _lastError = null;

    await Api.call(
      action: remote.getVehicleByNumber(vehicleNumber),
      onSuccess: (response) {
        final data = _extractData(response);
        vehicle = Vehicle.fromMap(data);
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return vehicle;
  }

  @override
  Future<Vehicle?> createVehicle(Vehicle vehicle) async {
    Vehicle? created;
    _lastError = null;

    await Api.call(
      action: remote.createVehicle(vehicle.toBackendJson()),
      onSuccess: (response) {
        final data = _extractData(response);
        created = Vehicle.fromMap(data.isNotEmpty ? data : vehicle.toMap());
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return created;
  }

  @override
  Future<Vehicle?> updateVehicle(
    String originalVehicleNumber,
    Vehicle vehicle,
  ) async {
    Vehicle? updated;
    _lastError = null;

    await Api.call(
      action: remote.updateVehicle(
        originalVehicleNumber,
        vehicle.toBackendJson(),
      ),
      onSuccess: (response) {
        final data = _extractData(response);
        updated = Vehicle.fromMap(data.isNotEmpty ? data : vehicle.toMap());
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return updated;
  }

  @override
  Future<bool> deleteVehicle(String vehicleNumber) async {
    bool deleted = false;
    _lastError = null;

    await Api.call(
      action: remote.deleteVehicle(vehicleNumber),
      onSuccess: (_) {
        deleted = true;
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return deleted;
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    DashboardStats stats = const DashboardStats.empty();
    _lastError = null;

    await Api.call(
      action: remote.getDashboardStats(),
      onSuccess: (response) {
        final data = _extractData(response);
        stats = DashboardStats.fromMap(data);
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return stats;
  }
}

final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  final remote = ref.watch(restClientProvider);
  return VehiclesRepositoryImpl(remote: remote);
});
