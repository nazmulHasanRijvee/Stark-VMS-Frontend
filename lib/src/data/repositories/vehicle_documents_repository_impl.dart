import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vehicle_document.dart';
import '../../domain/entities/paged_response.dart';
import '../../domain/repositories/vehicle_documents_repository.dart';
import '../services/network/api_handler.dart';
import '../services/network/rest_client.dart';

class VehicleDocumentsRepositoryImpl implements VehicleDocumentsRepository {
  VehicleDocumentsRepositoryImpl({required this.remote});

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
  Future<PagedResponse<VehicleDocument>> getDocuments(
    String vehicleNumber, {
    String? documentType,
    String? expiryState,
    int page = 0,
    int size = 50,
  }) async {
    PagedResponse<VehicleDocument> result = const PagedResponse.empty();
    _lastError = null;

    await Api.call(
      action: remote.getDocuments(
        vehicleNumber,
        documentType: documentType,
        expiryState: expiryState,
        page: page,
        size: size,
      ),
      onSuccess: (response) {
        dynamic data;
        if (response is Map<String, dynamic>) {
          data = response['data'] ?? response;
          if (data is Map<String, dynamic> && data['content'] is List) {
            final content = (data['content'] as List)
                .whereType<Map<String, dynamic>>()
                .map(VehicleDocument.fromMap)
                .toList();
            final responsePage = (data['page'] as num?)?.toInt() ?? page;
            final responseSize = (data['size'] as num?)?.toInt() ?? size;
            final totalElements =
                (data['totalElements'] as num?)?.toInt() ?? content.length;
            final totalPages =
                (data['totalPages'] as num?)?.toInt() ??
                (totalElements == 0
                    ? 0
                    : (totalElements / responseSize).ceil());
            result = PagedResponse<VehicleDocument>(
              content: content,
              page: responsePage,
              size: responseSize,
              totalElements: totalElements,
              totalPages: totalPages,
            );
          } else if (data is List) {
            final content = data
                .whereType<Map<String, dynamic>>()
                .map(VehicleDocument.fromMap)
                .toList();
            result = PagedResponse<VehicleDocument>(
              content: content,
              page: page,
              size: size,
              totalElements: content.length,
              totalPages: content.isEmpty ? 0 : 1,
            );
          }
        }
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return result;
  }

  @override
  Future<VehicleDocument?> uploadDocument({
    required String vehicleNumber,
    required List<int> fileBytes,
    required String filename,
    required String documentType,
    String? expiryDate,
  }) async {
    VehicleDocument? document;
    _lastError = null;

    final multipart = MultipartFile.fromBytes(fileBytes, filename: filename);

    await Api.call(
      action: remote.uploadDocument(
        vehicleNumber,
        multipart,
        documentType,
        expiryDate,
      ),
      onSuccess: (response) {
        final data = _extractData(response);
        document = VehicleDocument.fromMap(data);
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return document;
  }

  @override
  Future<String?> getDownloadUrl({
    required String vehicleNumber,
    required int documentId,
  }) async {
    String? url;
    _lastError = null;

    await Api.call(
      action: remote.getDocumentDownloadUrl(vehicleNumber, documentId),
      onSuccess: (response) {
        final data = _extractData(response);
        url = data['url'] as String? ?? response['url'] as String?;
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return url;
  }
}

final vehicleDocumentsRepositoryProvider = Provider<VehicleDocumentsRepository>(
  (ref) {
    final remote = ref.watch(restClientProvider);
    return VehicleDocumentsRepositoryImpl(remote: remote);
  },
);
