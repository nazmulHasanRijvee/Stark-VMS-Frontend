import '../entities/maintenance_record.dart';
import '../entities/paged_response.dart';

abstract interface class MaintenanceRepository {
  Future<PagedResponse<MaintenanceRecord>> getMaintenanceRecords(
    String vehicleNumber, {
    int page = 0,
    int size = 50,
  });

  Future<MaintenanceRecord?> createMaintenanceRecord({
    required String vehicleNumber,
    required MaintenanceRecord record,
  });

  String? get lastError;
}
