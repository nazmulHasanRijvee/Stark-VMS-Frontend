import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/paged_response.dart';
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
  Future<PagedResponse<Vehicle>> getVehiclesPaged({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDirection,
  }) async {
    PagedResponse<Vehicle> result = const PagedResponse.empty();
    _lastError = null;

    await Api.call(
      action: remote.getVehicles(
        search: search,
        status: status,
        page: page,
        size: size,
        sortBy: sortBy,
        sortDirection: sortDirection,
      ),
      onSuccess: (response) {
        if (response is Map<String, dynamic>) {
          final data = response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response;

          final contentList = data['content'] is List
              ? data['content'] as List<dynamic>
              : (response['content'] is List
                    ? response['content'] as List<dynamic>
                    : []);

          final vehicles = contentList
              .whereType<Map<String, dynamic>>()
              .map(Vehicle.fromMap)
              .toList();

          final resPage = (data['page'] as num?)?.toInt() ?? page;
          final resSize = (data['size'] as num?)?.toInt() ?? size;
          final totalElements =
              (data['totalElements'] as num?)?.toInt() ?? vehicles.length;
          final totalPages =
              (data['totalPages'] as num?)?.toInt() ??
              (totalElements > 0 ? (totalElements / resSize).ceil() : 0);

          result = PagedResponse<Vehicle>(
            content: vehicles,
            page: resPage,
            size: resSize,
            totalElements: totalElements,
            totalPages: totalPages,
          );
        }
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return result;
  }

  @override
  Future<List<Vehicle>> getVehicles({
    String? search,
    String? status,
    int page = 0,
    int size = 100,
    String? sortBy,
    String? sortDirection,
  }) async {
    final paged = await getVehiclesPaged(
      search: search,
      status: status,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
    return paged.content;
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
  Future<Vehicle?> assignDriver(String vehicleNumber, int driverId) async {
    Vehicle? updated;
    _lastError = null;

    await Api.call(
      action: remote.assignDriver(vehicleNumber, {'driverId': driverId}),
      onSuccess: (response) {
        final data = _extractData(response);
        updated = Vehicle.fromMap(data);
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return updated;
  }

  @override
  Future<bool> unassignDriver(String vehicleNumber) async {
    bool unassigned = false;
    _lastError = null;

    await Api.call(
      action: remote.unassignDriver(vehicleNumber),
      onSuccess: (_) {
        unassigned = true;
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return unassigned;
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
