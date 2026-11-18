import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/maintenance_record.dart';
import '../../domain/entities/paged_response.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../services/network/api_handler.dart';
import '../services/network/rest_client.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl({required this.remote});

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
  Future<PagedResponse<MaintenanceRecord>> getMaintenanceRecords(
    String vehicleNumber, {
    int page = 0,
    int size = 50,
  }) async {
    PagedResponse<MaintenanceRecord> result = const PagedResponse.empty();
    _lastError = null;

    await Api.call(
      action: remote.getMaintenanceRecords(
        vehicleNumber,
        page: page,
        size: size,
      ),
      onSuccess: (response) {
        if (response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic> && data['content'] is List) {
            final content = (data['content'] as List)
                .whereType<Map<String, dynamic>>()
                .map(MaintenanceRecord.fromMap)
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
            result = PagedResponse<MaintenanceRecord>(
              content: content,
              page: responsePage,
              size: responseSize,
              totalElements: totalElements,
              totalPages: totalPages,
            );
          } else if (data is List) {
            final content = data
                .whereType<Map<String, dynamic>>()
                .map(MaintenanceRecord.fromMap)
                .toList();
            result = PagedResponse<MaintenanceRecord>(
              content: content,
              page: page,
              size: size,
              totalElements: content.length,
              totalPages: content.isEmpty ? 0 : 1,
            );
          } else if (response['content'] is List) {
            final content = (response['content'] as List)
                .whereType<Map<String, dynamic>>()
                .map(MaintenanceRecord.fromMap)
                .toList();
            result = PagedResponse<MaintenanceRecord>(
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
  Future<MaintenanceRecord?> createMaintenanceRecord({
    required String vehicleNumber,
    required MaintenanceRecord record,
  }) async {
    MaintenanceRecord? created;
    _lastError = null;

    await Api.call(
      action: remote.createMaintenanceRecord(
        vehicleNumber,
        record.toBackendJson(),
      ),
      onSuccess: (response) {
        final data = _extractData(response);
        created = MaintenanceRecord.fromMap(
          data.isNotEmpty ? data : record.toMap(),
        );
      },
      onError: (error) {
        _lastError = error;
      },
    );

    return created;
  }
}

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final remote = ref.watch(restClientProvider);
  return MaintenanceRepositoryImpl(remote: remote);
});
