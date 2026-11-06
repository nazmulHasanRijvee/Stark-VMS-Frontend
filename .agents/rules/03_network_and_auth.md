# Rule: Network Layer, Retrofit, & Authentication

Stark VMS implements a production-grade networking stack leveraging **Dio**, **Retrofit**, and an epoch-based token management system.

## 1. Defining Endpoints & Retrofit Contracts

1. **Declare Endpoint Constants**:
   Place all URLs and paths in `lib/src/data/services/network/endpoints.dart`:
   ```dart
   class Endpoints {
     static const base = String.fromEnvironment("BASE_URL");
     static const String vehicles = '/vms/vehicles';
     static const String vehicleDetail = '/vms/vehicles/{id}';
   }
   ```

2. **Add API Method in `RestClient`**:
   Declare typed endpoints in `lib/src/data/services/network/rest_client.dart`:
   ```dart
   @RestApi(baseUrl: Endpoints.base)
   abstract class RestClient {
     // ...
     @GET(Endpoints.vehicles)
     Future<HttpResponse<List<VehicleModel>>> getVehicles(@Queries() Map<String, dynamic> query);
   }
   ```
   Run build runner to regenerate:
   `dart run build_runner build --delete-conflicting-outputs`

## 2. Standardized API Invocation via `Api.call`

Always execute Retrofit actions through `Api.call<T>` in repository implementations. It handles `DioException`, extracts backend server error messages, logs to `AppLogger`, and prevents unhandled crashes:

```dart
@override
Future<List<Vehicle>> getVehicles() async {
  List<Vehicle> list = [];
  await Api.call<List<VehicleModel>>(
    action: remote.getVehicles({}),
    onSuccess: (data) {
      list = data.map((m) => m.toDomain()).toList();
    },
    onError: (errorMessage) {
      AppLogger.error('Failed to load vehicles: $errorMessage');
      throw Exception(errorMessage);
    },
  );
  return list;
}
```

## 3. Token Architecture & Refresh Lifecycle

- **`TokenStore`**: Abstract persistence contract. Backed by `SecureTokenStore` via `FlutterSecureStorage` (AES-GCM / iOS Keychain).
- **`TokenManager`**:
  - In-memory cache + persistent storage for `accessToken` and `refreshToken`.
  - Maintains `_sessionEpoch` (integer counter) incremented on logout/clear. Any in-flight refresh with mismatched epoch is immediately discarded to prevent resurrection bugs.
  - Exposes `sessionStream.distinct()` which drives `sessionStatusProvider`.
- **`AccessTokenInterceptor`**:
  - Automatically attaches `Authorization: Bearer <accessToken>` to every outbound HTTP call.
- **`TokenRefreshInterceptor`**:
  - Catches `401 Unauthorized` responses.
  - Prevents race conditions by locking (`_isRefreshing`) and queueing subsequent requests in `_queue`.
  - Performs token refresh using an isolated `_refreshDio` without interceptors (preventing infinite loops).
  - Retries the failed request and all queued requests upon successful refresh.
  - Automatically invalidates session via `tokenManager.clearSession()` upon refresh failure.

## 4. Forbidden Practices
- ❌ NEVER bypass `TokenManager` or write tokens directly to `SharedPreferences`.
- ❌ NEVER call `dio.get()` or `dio.post()` directly in views or view models; all HTTP logic stays in `RestClient` + Repository.
- ❌ NEVER hardcode `BASE_URL`; it must be supplied through `--dart-define-from-file=env/dev.json`.

