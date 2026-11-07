import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'auth/token_manager.dart';
import 'endpoints.dart';
import 'interceptors/access_token_interceptor.dart';

class DioClient {
  static Dio getInstance(Ref ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.base,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final tokenManager = ref.read(tokenManagerProvider);

    dio.interceptors.addAll([
      AccessTokenInterceptor(tokenManager: tokenManager),
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          if (err.response?.statusCode == 401) {
            await tokenManager.clearSession();
            toastification.show(
              type: ToastificationType.warning,
              style: ToastificationStyle.minimal,
              title: const Text('Session expired. Please log in again.'),
              autoCloseDuration: const Duration(seconds: 4),
            );
          }
          handler.next(err);
        },
      ),
      if (kDebugMode) // disable logging only in production (release mode)
        // Auth request and response bodies may contain passwords and tokens.
        LogInterceptor(requestBody: false, responseBody: false), // always last
    ]);

    return dio;
  }
}

final dioProvider = Provider<Dio>((ref) {
  return DioClient.getInstance(ref);
});
