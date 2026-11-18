import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/driver.dart';
import '../../domain/entities/paged_response.dart';
import '../../domain/repositories/drivers_repository.dart';
import '../services/network/api_handler.dart';
import '../services/network/rest_client.dart';

class DriversRepositoryImpl implements DriversRepository {
  DriversRepositoryImpl({required this.remote});

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
  Future<PagedResponse<Driver>> getDrivers({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDirection,
  }) async {
    PagedResponse<Driver> result = const PagedResponse.empty();
    _lastError = null;

    await Api.call(
      action: remote.getDrivers(
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

          final drivers = contentList
              .whereType<Map<String, dynamic>>()
              .map(Driver.fromMap)
              .toList();

          final resPage = (data['page'] as num?)?.toInt() ?? page;
          final resSize = (data['size'] as num?)?.toInt() ?? size;
          final totalElements =
              (data['totalElements'] as num?)?.toInt() ?? drivers.length;
          final totalPages =
              (data['totalPages'] as num?)?.toInt() ??
              (totalElements > 0 ? (totalElements / resSize).ceil() : 0);

          result = PagedResponse<Driver>(
            content: drivers,
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
  Future<Driver?> getDriver(int driverId) async {
    Driver? driver;
    _lastError = null;

    await Api.call(
      action: remote.getDriverById(driverId),
      onSuccess: (response) {
        final data = _extractData(response);
        driver = Driver.fromMap(data);
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return driver;
  }

  @override
  Future<Driver?> createDriver(Driver driver) async {
    Driver? created;
    _lastError = null;

    await Api.call(
      action: remote.createDriver(driver.toBackendJson()),
      onSuccess: (response) {
        final data = _extractData(response);
        created = Driver.fromMap(data.isNotEmpty ? data : driver.toMap());
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return created;
  }

  @override
  Future<Driver?> updateDriver(int driverId, Driver driver) async {
    Driver? updated;
    _lastError = null;

    await Api.call(
      action: remote.updateDriver(driverId, driver.toBackendJson()),
      onSuccess: (response) {
        final data = _extractData(response);
        updated = Driver.fromMap(data.isNotEmpty ? data : driver.toMap());
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return updated;
  }

  @override
  Future<bool> deleteDriver(int driverId) async {
    bool deleted = false;
    _lastError = null;

    await Api.call(
      action: remote.deleteDriver(driverId),
      onSuccess: (_) {
        deleted = true;
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return deleted;
  }
}

final driversRepositoryProvider = Provider<DriversRepository>((ref) {
  final remote = ref.watch(restClientProvider);
  return DriversRepositoryImpl(remote: remote);
});
