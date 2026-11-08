import '../entities/dashboard_stats.dart';
import '../entities/vehicle.dart';

abstract interface class VehiclesRepository {
  Future<List<Vehicle>> getVehicles({
    String? search,
    String? status,
    int page = 0,
    int size = 100,
  });

  Future<Vehicle?> getVehicle(String vehicleNumber);

  Future<Vehicle?> createVehicle(Vehicle vehicle);

  Future<Vehicle?> updateVehicle(String originalVehicleNumber, Vehicle vehicle);

  Future<bool> deleteVehicle(String vehicleNumber);

  Future<DashboardStats> getDashboardStats();

  String? get lastError;
}
