import '../entities/driver.dart';
import '../entities/paged_response.dart';

abstract interface class DriversRepository {
  Future<PagedResponse<Driver>> getDrivers({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDirection,
  });

  Future<Driver?> getDriver(int driverId);

  Future<Driver?> createDriver(Driver driver);

  Future<Driver?> updateDriver(int driverId, Driver driver);

  Future<bool> deleteDriver(int driverId);

  String? get lastError;
}
