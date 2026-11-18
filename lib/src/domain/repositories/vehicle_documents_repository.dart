import '../entities/vehicle_document.dart';
import '../entities/paged_response.dart';

abstract interface class VehicleDocumentsRepository {
  Future<PagedResponse<VehicleDocument>> getDocuments(
    String vehicleNumber, {
    String? documentType,
    String? expiryState,
    int page = 0,
    int size = 50,
  });

  Future<VehicleDocument?> uploadDocument({
    required String vehicleNumber,
    required List<int> fileBytes,
    required String filename,
    required String documentType,
    String? expiryDate,
  });

  Future<String?> getDownloadUrl({
    required String vehicleNumber,
    required int documentId,
  });

  String? get lastError;
}
