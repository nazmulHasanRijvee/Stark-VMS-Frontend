# Stark VMS — Agent Guidelines & Project Overview

Welcome to **Stark VMS (Vehicle Management System)**. This is a production-structured Flutter Web application for managing enterprise vehicle fleets, drivers, dispatches, maintenance schedules, and analytics.

---

## 🏛️ Project Architecture at a Glance

The codebase follows **Clean Architecture** with feature-sliced presentation:

```
lib/
├── app.dart                   # Root MaterialApp.router setup
├── main.dart                  # Entry point with UncontrolledProviderScope & bootstrap
└── src/
    ├── core/                  # Shared utilities, extensions, logger, crash reporting
    │   ├── base/              # Crash reporting interfaces & Firebase/Console reporters
    │   ├── bootstrap.dart     # Pre-app initialization (SharedPreferences, orientations)
    │   ├── extensions/        # Context, String, DateTime, Riverpod extensions
    │   ├── gen/               # Asset code generated via flutter_gen
    │   ├── logger/            # AppLogger (PrettyPrinter) & RiverpodObserver
    │   └── utils/             # Validation, image picking helpers
    │
    ├── data/                  # Remote & local data implementation
    │   ├── models/            # DTOs and serializable models
    │   ├── repositories/      # Repository implementations (Auth, Router, Locale)
    │   └── services/
    │       ├── cache/         # CacheService (SharedPreferences) with CacheKey enum
    │       └── network/       # Dio + Retrofit client, TokenManager, Interceptors
    │
    ├── domain/                # Business logic contracts & pure entities
    │   ├── entities/          # Domain business models
    │   └── repositories/      # Abstract repository interfaces
    │
    └── presentation/          # User interface & state management
        ├── core/              # Global UI state, routing, theme system, reusable widgets
        │   ├── application_state/ # startup, session, theme mode, localization providers
        │   ├── router/        # GoRouter, Routes enum, RedirectGate, page transitions
        │   ├── theme/         # Design tokens, ThemeExtensions (Colors, Dimensions, TextStyles)
        │   └── widgets/       # Production core reusable widgets
        └── feature/           # Feature slices (auth, home, onboarding, splash, etc.)
            └── <feature_name>/
                ├── view/       # Screen UI widgets (ConsumerStatefulWidget / ConsumerWidget)
                ├── view_model/ # Riverpod Notifiers / StateNotifier / AsyncNotifier
                └── widgets/    # Screen-specific private widgets
```

---

## ⚡ Core Commandments for Agents

1. **Strict Design Token Usage**:
   - ❌ Never use raw `Colors.blue`, `Color(0xFF...)`, `SizedBox(height: 16)`, or `BorderRadius.circular(12)` in presentation features.
   - ✅ Always use theme extensions via BuildContext:
     - Colors: `context.color.primary`, `context.color.text.primary`, `context.color.scaffoldBackground`, etc.
     - Spacing: `context.spacing.sm`, `context.spacing.md`, `context.spacing.lg`
     - Sizes: `context.sizes.md`, `context.sizes.lg`
     - Radius: `context.radius.sm`, `context.radius.md`, `context.radius.pill`
     - TextStyles: `context.textStyle.headLineMedium`, `context.textStyle.bodyLarge`, etc.

2. **Network Calls via Retrofit + `Api.call`**:
   - Define all endpoints in `lib/src/data/services/network/endpoints.dart`.
   - Add HTTP methods to `RestClient` (`lib/src/data/services/network/rest_client.dart`).
   - Run `dart run build_runner build --delete-conflicting-outputs` after editing Retrofit interfaces.
   - Always execute requests via `Api.call<T>(action: ..., onSuccess: ..., onError: ...)` in repositories.

3. **Reactive State-Driven Routing (`go_router`)**:
   - Navigation is driven by **state, not imperative `context.go()` calls during redirects**.
   - `routerStateProvider` listens to `startupProvider`, `onboardingStatusProvider`, and `sessionStatusProvider`.
   - Gating rules live strictly in `RedirectGate.redirect(path, gate)`.
   - Add new route paths to `enum Routes` (`lib/src/presentation/core/router/routes.dart`).
   - Organize new route branches in `lib/src/presentation/core/router/parts/`.

4. **Riverpod State Management**:
   - Use `AsyncNotifierProvider` or `NotifierProvider` for view models.
   - Do not perform async work in `build()` of notifiers; use `AsyncValue.guard()`.
   - Register view models in `lib/src/presentation/feature/<feature>/view_model/`.

5. **Reuse Core Widgets**:
   - Before building custom inputs, dropdowns, loading spinners, or toasts, check `lib/src/presentation/core/widgets/`:
     - `AppTextField` (debounced validation, shake animation, obscure toggle)
     - `AppDropdown` (styled dropdown with validation)
     - `MultiSelectDropdown` (multi-item checkbox selector)
     - `CustomToast` (`showSuccess`, `showError`, `showInfo`, `showWarning`)
     - `CustomLoadingIndicator` (SpinKit bounce)
     - `CustomNetworkImage` (CachedNetworkImage with shimmer/placeholder)
     - `EmptyStateWidget` (animated empty illustration)
     - `NotFoundScreen` (404 route fallback)

---

## 📚 Deep Dive Documentation

Detailed documentation and skills are maintained in `.agents/`:
- **Rules**: [`.agents/rules/`](.agents/rules/)
- **Skills**: [`.agents/skills/vms-feature-builder/`](.agents/skills/vms-feature-builder/SKILL.md)
- **Detailed Docs**: [`.agents/docs/`](.agents/docs/)

