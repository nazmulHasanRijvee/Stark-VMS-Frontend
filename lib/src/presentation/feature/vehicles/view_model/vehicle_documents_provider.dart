import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/vehicle_documents_repository_impl.dart';
import '../../../../domain/entities/vehicle_document.dart';
import '../../../../domain/repositories/vehicle_documents_repository.dart';

@immutable
class VehicleDocumentsState {
  final List<VehicleDocument> documents;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isUploading;
  final String? errorMessage;
  final String? selectedTypeFilter;
  final int currentPage;
  final int totalPages;

  const VehicleDocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isUploading = false,
    this.errorMessage,
    this.selectedTypeFilter,
    this.currentPage = 0,
    this.totalPages = 0,
  });

  VehicleDocumentsState copyWith({
    List<VehicleDocument>? documents,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isUploading,
    String? errorMessage,
    String? selectedTypeFilter,
    int? currentPage,
    int? totalPages,
    bool clearTypeFilter = false,
  }) {
    return VehicleDocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage,
      selectedTypeFilter: clearTypeFilter
          ? null
          : (selectedTypeFilter ?? this.selectedTypeFilter),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class VehicleDocumentsNotifier extends Notifier<VehicleDocumentsState> {
  VehicleDocumentsNotifier(this.arg);

  final String arg;
  late VehicleDocumentsRepository _repository;

  @override
  VehicleDocumentsState build() {
    _repository = ref.watch(vehicleDocumentsRepositoryProvider);
    Future.microtask(() => loadDocuments());
    return const VehicleDocumentsState(isLoading: true);
  }

  Future<void> loadDocuments({bool loadMore = false}) async {
    final nextPage = loadMore ? state.currentPage + 1 : 0;
    state = state.copyWith(
      isLoading: !loadMore,
      isLoadingMore: loadMore,
      errorMessage: null,
    );
    final result = await _repository.getDocuments(
      arg,
      documentType: state.selectedTypeFilter,
      page: nextPage,
      size: 50,
    );
    state = state.copyWith(
      documents: loadMore
          ? [...state.documents, ...result.content]
          : result.content,
      isLoading: false,
      isLoadingMore: false,
      currentPage: result.page,
      totalPages: result.totalPages,
      errorMessage: result.isEmpty ? _repository.lastError : null,
    );
  }

  void setTypeFilter(String? type) {
    if (type == null || type == 'All') {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(selectedTypeFilter: type);
    }
    loadDocuments();
  }

  Future<bool> uploadDocument({
    required List<int> fileBytes,
    required String filename,
    required String documentType,
    String? expiryDate,
  }) async {
    state = state.copyWith(isUploading: true, errorMessage: null);

    final uploaded = await _repository.uploadDocument(
      vehicleNumber: arg,
      fileBytes: fileBytes,
      filename: filename,
      documentType: documentType,
      expiryDate: expiryDate,
    );

    if (uploaded != null) {
      await loadDocuments();
      state = state.copyWith(isUploading: false);
      return true;
    } else {
      state = state.copyWith(
        isUploading: false,
        errorMessage: _repository.lastError ?? 'Failed to upload document.',
      );
      return false;
    }
  }

  Future<String?> getDownloadUrl(int documentId) async {
    return _repository.getDownloadUrl(
      vehicleNumber: arg,
      documentId: documentId,
    );
  }
}

final vehicleDocumentsProvider =
    NotifierProvider.family<
      VehicleDocumentsNotifier,
      VehicleDocumentsState,
      String
    >(VehicleDocumentsNotifier.new);
