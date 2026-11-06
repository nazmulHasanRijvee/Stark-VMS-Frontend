# Rule: Riverpod State Management Standards

Stark VMS utilizes **Flutter Riverpod (3.x)** with modern `Notifier` and `AsyncNotifier` primitives.

## 1. Provider Selection

| Use Case | Recommended Provider | Example |
| :--- | :--- | :--- |
| Pure dependency injection | `Provider<T>` | `dioProvider`, `authRepositoryProvider` |
| Synchronous mutable state | `NotifierProvider<TNotifier, TState>` | `themeModeProvider`, `onboardingStatusProvider` |
| Asynchronous mutation / fetch | `AsyncNotifierProvider<TNotifier, TState>` | `loginProvider`, `vehiclesListProvider` |
| Continuous streams | `StreamProvider<T>` | `sessionStatusProvider` |
| One-time async initialization | `FutureProvider<T>` | `startupProvider` |

## 2. Asynchronous State Handling Guidelines

- In `AsyncNotifier` subclasses, use `AsyncValue.guard(() async { ... })` for mutations. This automatically captures loading, error, and data states:
```dart
class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() {
    return ref.read(vehicleRepositoryProvider).getVehicles();
  }

  Future<void> refreshVehicles() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(vehicleRepositoryProvider).getVehicles(),
    );
  }
}
```

- In UI screens (`ConsumerWidget` / `ConsumerStatefulWidget`):
  - Use `ref.watch(provider)` to render state:
    ```dart
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    return vehiclesAsync.when(
      data: (vehicles) => VehiclesDataTable(vehicles: vehicles),
      loading: () => const CustomLoadingIndicator(),
      error: (err, _) => EmptyStateWidget(title: 'Error loading vehicles', subtitle: err.toString()),
    );
    ```
  - Use `ref.listen(provider, (prev, next) { ... })` inside `build()` for side effects like snackbars, toasts, or dialogs:
    ```dart
    ref.listen(vehiclesNotifierProvider, (previous, next) {
      if (next.hasError) {
        CustomToast.showError(context, title: 'Operation Failed', description: next.error.toString());
      }
    });
    ```

## 3. Router Integration & ValueListenable Bridge

- Use `ref.asListenable(provider)` (`RefAsListenable` extension from `lib/src/core/extensions/riverpod_extensions.dart`) when bridging a synchronous Riverpod provider to `GoRouter.refreshListenable`.
- Call `ref.asListenable` **once** at the provider level, never inside callbacks or build methods.

## 4. Forbidden Practices
- ❌ Do NOT use deprecated `StateProvider` or `StateNotifierProvider`.
- ❌ Do NOT call `ref.read` inside widget build methods for reactive state; only use `ref.read` in event callbacks (e.g. `onPressed`).
- ❌ Do NOT trigger navigation imperatively from notifiers or repositories. Navigation is reactive and governed by state via `routerStateProvider`.

