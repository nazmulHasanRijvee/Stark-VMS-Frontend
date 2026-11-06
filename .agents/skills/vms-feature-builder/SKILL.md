---
name: vms-feature-builder
description: >-
  Step-by-step workflow for building a new feature slice in Stark VMS (e.g. vehicles, drivers, dispatches, maintenance) according to Clean Architecture, Dio+Retrofit, Riverpod 3, and go_router conventions.
---

# VMS Feature Builder Skill

Use this skill whenever you need to add, extend, or scaffold a new feature for the Stark Vehicle Management System (VMS).

---

## 🚀 7-Step Implementation Workflow

```
1. Endpoints & Retrofit ➔ 2. Models & Entities ➔ 3. Repository Contract & Impl
                              ▼
7. Code Generation ➔ 6. Screen UI ➔ 5. Router Part & Routes ➔ 4. Riverpod View Model
```

---

### Step 1: Define Network Endpoints & Retrofit API

1. Add URL constants to `lib/src/data/services/network/endpoints.dart`:
   ```dart
   class Endpoints {
     // ...
     static const String vehicles = '/vms/vehicles';
     static const String vehicleDetail = '/vms/vehicles/{id}';
   }
   ```

2. Add methods in `lib/src/data/services/network/rest_client.dart`:
   ```dart
   @RestApi(baseUrl: Endpoints.base)
   abstract class RestClient {
     // ...
     @GET(Endpoints.vehicles)
     Future<HttpResponse<List<Map<String, dynamic>>>> getVehicles(
       @Queries() Map<String, dynamic> query,
     );

     @POST(Endpoints.vehicles)
     Future<HttpResponse<Map<String, dynamic>>> createVehicle(
       @Body() Map<String, dynamic> body,
     );
   }
   ```

---

### Step 2: Create Domain Entity & Data Model

1. **Domain Entity** (`lib/src/domain/entities/vehicle.dart`):
   ```dart
   class Vehicle {
     final String id;
     final String vin;
     final String make;
     final String model;
     final int year;
     final String licensePlate;
     final String status;

     const Vehicle({
       required this.id,
       required this.vin,
       required this.make,
       required this.model,
       required this.year,
       required this.licensePlate,
       required this.status,
     });
   }
   ```

2. **Data Model / DTO** (`lib/src/data/models/vehicle_model.dart`):
   ```dart
   import '../../domain/entities/vehicle.dart';

   class VehicleModel {
     final String id;
     final String vin;
     final String make;
     final String model;
     final int year;
     final String licensePlate;
     final String status;

     const VehicleModel({
       required this.id,
       required this.vin,
       required this.make,
       required this.model,
       required this.year,
       required this.licensePlate,
       required this.status,
     });

     factory VehicleModel.fromJson(Map<String, dynamic> json) {
       return VehicleModel(
         id: json['id'] as String? ?? '',
         vin: json['vin'] as String? ?? '',
         make: json['make'] as String? ?? '',
         model: json['model'] as String? ?? '',
         year: json['year'] as int? ?? DateTime.now().year,
         licensePlate: json['license_plate'] as String? ?? '',
         status: json['status'] as String? ?? 'ACTIVE',
       );
     }

     Map<String, dynamic> toJson() => {
       'id': id,
       'vin': vin,
       'make': make,
       'model': model,
       'year': year,
       'license_plate': licensePlate,
       'status': status,
     };

     Vehicle toDomain() => Vehicle(
       id: id,
       vin: vin,
       make: make,
       model: model,
       year: year,
       licensePlate: licensePlate,
       status: status,
     );
   }
   ```

---

### Step 3: Define Repository Interface & Implementation

1. **Domain Interface** (`lib/src/domain/repositories/vehicle_repository.dart`):
   ```dart
   import '../entities/vehicle.dart';

   abstract interface class VehicleRepository {
     Future<List<Vehicle>> getVehicles();
     Future<bool> createVehicle(Vehicle vehicle);
   }
   ```

2. **Data Implementation** (`lib/src/data/repositories/vehicle_repository_impl.dart`):
   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import '../../domain/entities/vehicle.dart';
   import '../../domain/repositories/vehicle_repository.dart';
   import '../models/vehicle_model.dart';
   import '../services/network/api_handler.dart';
   import '../services/network/rest_client.dart';

   class VehicleRepositoryImpl implements VehicleRepository {
     VehicleRepositoryImpl({required this.remote});
     final RestClient remote;

     @override
     Future<List<Vehicle>> getVehicles() async {
       List<Vehicle> result = [];
       await Api.call<List<Map<String, dynamic>>>(
         action: remote.getVehicles({}),
         onSuccess: (data) {
           result = data.map((json) => VehicleModel.fromJson(json).toDomain()).toList();
         },
         onError: (error) => throw Exception(error),
       );
       return result;
     }

     @override
     Future<bool> createVehicle(Vehicle vehicle) async {
       bool success = false;
       await Api.call<Map<String, dynamic>>(
         action: remote.createVehicle(
           VehicleModel(
             id: vehicle.id,
             vin: vehicle.vin,
             make: vehicle.make,
             model: vehicle.model,
             year: vehicle.year,
             licensePlate: vehicle.licensePlate,
             status: vehicle.status,
           ).toJson(),
         ),
         onSuccess: (_) => success = true,
         onError: (error) => throw Exception(error),
       );
       return success;
     }
   }

   final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
     return VehicleRepositoryImpl(remote: ref.watch(restClientProvider));
   });
   ```

---

### Step 4: Create Riverpod View Model

In `lib/src/presentation/feature/<feature>/view_model/vehicles_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/vehicle_repository_impl.dart';
import '../../../../domain/entities/vehicle.dart';

class VehiclesListNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() {
    return ref.read(vehicleRepositoryProvider).getVehicles();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(vehicleRepositoryProvider).getVehicles(),
    );
  }
}

final vehiclesListProvider = AsyncNotifierProvider<VehiclesListNotifier, List<Vehicle>>(
  VehiclesListNotifier.new,
);
```

---

### Step 5: Register Route in `Routes` Enum & Route Parts

1. Append to `lib/src/presentation/core/router/routes.dart`:
   ```dart
   enum Routes {
     // ...
     vehicles('/vehicles'),
     vehicleDetails('/vehicles/detail');
   }
   ```

2. Create route part in `lib/src/presentation/core/router/parts/vehicle_routes.dart`:
   ```dart
   part of '../router.dart';

   List<GoRoute> _vehicleRoutes(Ref ref) {
     return [
       GoRoute(
         path: Routes.vehicles.path,
         name: Routes.vehicles.name,
         pageBuilder: (context, state) => buildTransitionPage(
           child: const VehiclesScreen(),
           key: ValueKey(Routes.vehicles.name),
           type: AppTransitionType.fade,
         ),
       ),
     ];
   }
   ```

3. Add `part 'parts/vehicle_routes.dart';` and `..._vehicleRoutes(ref)` into `router.dart`.

---

### Step 6: Build Screen UI using Tokens and Core Widgets

In `lib/src/presentation/feature/vehicles/view/vehicles_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/custom_loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../view_model/vehicles_provider.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fleet Vehicles', style: context.textStyle.headLineSmall),
      ),
      body: Padding(
        padding: EdgeInsets.all(context.spacing.lg),
        child: vehiclesAsync.when(
          data: (vehicles) {
            if (vehicles.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.directions_car_outlined,
                title: 'No vehicles found',
                subtitle: 'Register vehicles to view fleet telemetry.',
                buttonLabel: 'Add Vehicle',
                onAction: () {},
              );
            }
            return ListView.separated(
              itemCount: vehicles.length,
              separatorBuilder: (_, __) => SizedBox(height: context.spacing.md),
              itemBuilder: (context, index) {
                final v = vehicles[index];
                return ListTile(
                  title: Text('${v.year} ${v.make} ${v.model}'),
                  subtitle: Text('VIN: ${v.vin} • Plate: ${v.licensePlate}'),
                );
              },
            );
          },
          loading: () => const CustomLoadingIndicator(),
          error: (err, _) => Center(child: Text(err.toString())),
        ),
      ),
    );
  }
}
```

---

### Step 7: Run Code Generation

Whenever modifying Retrofit interfaces or models:
```powershell
dart run build_runner build --delete-conflicting-outputs
```

