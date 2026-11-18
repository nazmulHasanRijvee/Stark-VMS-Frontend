import 'package:flutter/foundation.dart';

/// Generic paged response envelope matching the Spring Boot pagination contract.
@immutable
class PagedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  const PagedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  const PagedResponse.empty()
    : content = const [],
      page = 0,
      size = 10,
      totalElements = 0,
      totalPages = 0;

  bool get hasNext => page + 1 < totalPages;
  bool get hasPrevious => page > 0;
  bool get isEmpty => content.isEmpty;
  bool get isNotEmpty => content.isNotEmpty;
}
