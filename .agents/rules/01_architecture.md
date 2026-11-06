# Rule: Project Architecture & Structure

All code in Stark VMS must strictly comply with Clean Architecture and feature-driven directory modularity.

## Directory Boundaries

```text
lib/
├── app.dart
├── main.dart
└── src/
    ├── core/          # App-wide technical infrastructure
    ├── data/          # Concrete implementations of data access
    ├── domain/        # Pure business rules and abstract contracts
    └── presentation/  # UI components, state management, and routing
```

### 1. `core/` Layer Rules
- Contains no feature-specific business logic.
- Houses shared helpers: extensions, logging (`AppLogger`), crash reporting (`CrashReporter`), and generated assets (`assets.gen.dart`).
- Must not import from `presentation/feature/` or `data/services/network/auth/` directly (except for technical adapters in `bootstrap.dart`).

### 2. `domain/` Layer Rules
- Pure Dart: Contains abstract repository interfaces (`abstract interface class VehicleRepository`).
- Pure entities with no Flutter or UI framework dependencies.
- Must NEVER import `package:flutter`, `package:dio`, `package:retrofit`, or `package:flutter_riverpod`.

### 3. `data/` Layer Rules
- Implements domain contracts (`class VehicleRepositoryImpl implements VehicleRepository`).
- Houses:
  - Network API definitions via Retrofit (`RestClient`).
  - DTOs and JSON serializable models (`data/models/`).
  - Cache implementations (`CacheService`, `SharedPreferencesService`).
  - Secure token storage (`SecureTokenStore`, `TokenManager`).
  - Interceptors (`AccessTokenInterceptor`, `TokenRefreshInterceptor`).
- Exposes Riverpod providers for repositories (e.g. `final vehicleRepositoryProvider = Provider<VehicleRepository>(...)`).

### 4. `presentation/` Layer Rules
- Divided into:
  - `core/`: Global application state (`startupProvider`, `sessionStatusProvider`, `themeModeProvider`), global router (`routerProvider`), theme setup, and shared UI widgets (`presentation/core/widgets/`).
  - `feature/<feature_name>/`: Self-contained vertical slices.
- Each feature slice must adhere to this folder structure:
  ```text
  feature/<feature_name>/
  ├── view/           # Screen widgets (e.g., vehicles_screen.dart, vehicle_details_screen.dart)
  ├── view_model/     # Riverpod Notifier / AsyncNotifier providers
  └── widgets/        # Screen-specific private widgets (e.g., vehicle_card.dart, vehicle_filter_bar.dart)
  ```
- Views must not instantiate network clients or talk directly to cache; they must communicate solely through their feature `view_model` providers.

