import '../entities/dashboard_stats.dart';
import '../entities/paged_response.dart';
import '../entities/vehicle.dart';

abstract interface class VehiclesRepository {
  Future<PagedResponse<Vehicle>> getVehiclesPaged({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDirection,
  });

  Future<List<Vehicle>> getVehicles({
    String? search,
    String? status,
    int page = 0,
    int size = 100,
    String? sortBy,
    String? sortDirection,
  });

  Future<Vehicle?> getVehicle(String vehicleNumber);

  Future<Vehicle?> createVehicle(Vehicle vehicle);

  Future<Vehicle?> updateVehicle(String originalVehicleNumber, Vehicle vehicle);

  Future<bool> deleteVehicle(String vehicleNumber);

  Future<Vehicle?> assignDriver(String vehicleNumber, int driverId);

  Future<bool> unassignDriver(String vehicleNumber);

  Future<DashboardStats> getDashboardStats();

  String? get lastError;
}
