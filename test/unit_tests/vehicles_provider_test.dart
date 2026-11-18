import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stark_vms/src/data/repositories/vehicles_repository_impl.dart';
import 'package:stark_vms/src/data/services/cache/cache_service.dart';
import 'package:stark_vms/src/domain/entities/paged_response.dart';
import 'package:stark_vms/src/domain/repositories/vehicles_repository.dart';
import 'package:stark_vms/src/presentation/feature/vehicles/view_model/vehicles_provider.dart';

class InMemoryVehiclesRepository implements VehiclesRepository {
  List<Vehicle> _vehicles = [
    const Vehicle(
      vehicleNumber: 'DHAKA METRO GA-12-3456',
      company: 'Stark Logistics',
      type: 'Sedan',
      brand: 'Toyota',
      model: 'Corolla',
      status: Vehicle.statusActive,
    ),
    const Vehicle(
      vehicleNumber: 'DHAKA METRO CHA-55-9812',
      company: 'Stark Agro',
      type: 'Microbus / Van',
      brand: 'Nissan',
      model: 'Urvan',
      status: Vehicle.statusMaintenance,
    ),
    const Vehicle(
      vehicleNumber: 'DHAKA METRO BA-11-2233',
      company: 'Stark Retail',
      type: 'Sedan',
      brand: 'Honda',
      model: 'Civic',
      status: Vehicle.statusActive,
    ),
    const Vehicle(
      vehicleNumber: 'CHATTOGRAM METRO KHA-22-1100',
      company: 'Stark Tech',
      type: 'SUV',
      brand: 'Mitsubishi',
      model: 'Pajero',
      status: Vehicle.statusInactive,
    ),
  ];

  String? _lastError;
  String? lastSearch;
  String? lastStatus;

  @override
  String? get lastError => _lastError;

  @override
  Future<PagedResponse<Vehicle>> getVehiclesPaged({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDirection,
  }) async {
    lastSearch = search;
    lastStatus = status;
    var filtered = List<Vehicle>.from(_vehicles);
    final query = search?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      filtered = filtered
          .where(
            (vehicle) =>
                vehicle.vehicleNumber.toLowerCase().contains(query) ||
                vehicle.company.toLowerCase().contains(query) ||
                vehicle.type.toLowerCase().contains(query) ||
                vehicle.brand.toLowerCase().contains(query) ||
                vehicle.model.toLowerCase().contains(query),
          )
          .toList();
    }
    if (status != null) {
      filtered = filtered.where((vehicle) => vehicle.status == status).toList();
    }

    final totalElements = filtered.length;
    final safeSize = size > 0 ? size : 10;
    final start = page * safeSize;
    final content = start >= totalElements
        ? <Vehicle>[]
        : filtered.skip(start).take(safeSize).toList();
    return PagedResponse<Vehicle>(
      content: content,
      page: page,
      size: safeSize,
      totalElements: totalElements,
      totalPages: totalElements == 0 ? 0 : (totalElements / safeSize).ceil(),
    );
  }

  @override
  Future<List<Vehicle>> getVehicles({
    String? search,
    String? status,
    int page = 0,
    int size = 100,
    String? sortBy,
    String? sortDirection,
  }) async => (await getVehiclesPaged(
    search: search,
    status: status,
    page: page,
    size: size,
    sortBy: sortBy,
    sortDirection: sortDirection,
  )).content;

  @override
  Future<Vehicle?> getVehicle(String vehicleNumber) async {
    final norm = vehicleNumber.trim().toUpperCase();
    try {
      return _vehicles.firstWhere((v) => v.vehicleNumber.toUpperCase() == norm);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Vehicle?> createVehicle(Vehicle vehicle) async {
    _lastError = null;
    final norm = vehicle.vehicleNumber.trim().toUpperCase();
    if (_vehicles.any((v) => v.vehicleNumber.toUpperCase() == norm)) {
      _lastError = 'A vehicle with this registration number already exists.';
      return null;
    }
    _vehicles = [vehicle, ..._vehicles];
    return vehicle;
  }

  @override
  Future<Vehicle?> updateVehicle(
    String originalVehicleNumber,
    Vehicle vehicle,
  ) async {
    _lastError = null;
    final normOrig = originalVehicleNumber.trim().toUpperCase();
    final normNew = vehicle.vehicleNumber.trim().toUpperCase();

    if (_vehicles.any(
      (v) =>
          v.vehicleNumber.toUpperCase() == normNew &&
          v.vehicleNumber.toUpperCase() != normOrig,
    )) {
      _lastError = 'A vehicle with this registration number already exists.';
      return null;
    }

    _vehicles = [
      for (final v in _vehicles)
        if (v.vehicleNumber.toUpperCase() == normOrig) vehicle else v,
    ];
    return vehicle;
  }

  @override
  Future<bool> deleteVehicle(String vehicleNumber) async {
    final norm = vehicleNumber.trim().toUpperCase();
    _vehicles = _vehicles
        .where((v) => v.vehicleNumber.toUpperCase() != norm)
        .toList();
    return true;
  }

  @override
  Future<Vehicle?> assignDriver(String vehicleNumber, int driverId) async =>
      null;

  @override
  Future<bool> unassignDriver(String vehicleNumber) async => false;

  @override
  Future<DashboardStats> getDashboardStats() async {
    int active = 0;
    int inService = 0;
    int inactive = 0;

    for (final v in _vehicles) {
      if (v.status == Vehicle.statusActive) active++;
      if (v.status == Vehicle.statusMaintenance) inService++;
      if (v.status == Vehicle.statusInactive) inactive++;
    }

    return DashboardStats(
      total: _vehicles.length,
      active: active,
      maintenance: inService,
      inactive: inactive,
    );
  }
}

Future<void> _waitForVehiclesPage(ProviderContainer container) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    if (!container.read(vehiclesPageProvider).isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('VehiclesProvider (Repository-Backed)', () {
    late ProviderContainer container;
    late InMemoryVehiclesRepository fakeRepo;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      fakeRepo = InMemoryVehiclesRepository();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          vehiclesRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      // Let initial microtask fetch finish
      await container.read(vehiclesProvider.notifier).fetchVehicles();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state contains 4 seed vehicles', () {
      final vehicles = container.read(vehiclesProvider);
      expect(vehicles.length, 4);
      expect(
        vehicles.any((v) => v.vehicleNumber == 'DHAKA METRO GA-12-3456'),
        isTrue,
      );
    });

    test('adds a new vehicle with uppercase vehicleNumber', () async {
      final notifier = container.read(vehiclesProvider.notifier);
      const newVehicle = Vehicle(
        vehicleNumber: 'dhaka metro ha-99-0001',
        company: 'Stark Logistics',
        type: 'Pickup',
        brand: 'Ford',
        model: 'Ranger',
        status: Vehicle.statusActive,
      );

      final error = await notifier.addVehicle(newVehicle);
      expect(error, isNull);

      final vehicles = container.read(vehiclesProvider);
      expect(vehicles.length, 5);
      expect(vehicles.first.vehicleNumber, 'DHAKA METRO HA-99-0001');
    });

    test('detects duplicate vehicle numbers case-insensitively', () {
      final notifier = container.read(vehiclesProvider.notifier);
      expect(notifier.isDuplicate('dhaka metro ga-12-3456'), isTrue);
      expect(notifier.isDuplicate('DHAKA METRO GA-12-3456'), isTrue);
      expect(notifier.isDuplicate('NON-EXISTENT-PLATE'), isFalse);
    });

    test('prevents adding duplicate vehicle', () async {
      final notifier = container.read(vehiclesProvider.notifier);
      const duplicateVehicle = Vehicle(
        vehicleNumber: 'DHAKA METRO GA-12-3456',
        company: 'Other Company',
        type: 'Van',
        brand: 'Toyota',
        model: 'HiAce',
        status: Vehicle.statusActive,
      );

      final error = await notifier.addVehicle(duplicateVehicle);
      expect(error, isNotNull);
      expect(container.read(vehiclesProvider).length, 4);
    });

    test(
      'updates existing vehicle without duplicate error on its own plate',
      () async {
        final notifier = container.read(vehiclesProvider.notifier);
        const updatedVehicle = Vehicle(
          vehicleNumber: 'DHAKA METRO GA-12-3456',
          company: 'Stark Corp Updated',
          type: 'Heavy Truck',
          brand: 'Scania',
          model: 'R500',
          status: Vehicle.statusMaintenance,
        );

        final error = await notifier.updateVehicle(
          'DHAKA METRO GA-12-3456',
          updatedVehicle,
        );
        expect(error, isNull);

        final vehicle = notifier.getVehicle('DHAKA METRO GA-12-3456');
        expect(vehicle?.company, 'Stark Corp Updated');
        expect(vehicle?.status, Vehicle.statusMaintenance);
      },
    );

    test('deletes a vehicle by vehicleNumber', () async {
      final notifier = container.read(vehiclesProvider.notifier);
      final success = await notifier.deleteVehicle('DHAKA METRO GA-12-3456');
      expect(success, isTrue);

      final vehicles = container.read(vehiclesProvider);
      expect(vehicles.length, 3);
      expect(
        vehicles.any((v) => v.vehicleNumber == 'DHAKA METRO GA-12-3456'),
        isFalse,
      );
    });

    test('calculates accurate dashboard stats', () async {
      await container.read(dashboardStatsProvider.notifier).refresh();
      final stats = container.read(dashboardStatsProvider);
      expect(stats.total, 4);
      expect(stats.active, 2);
      expect(stats.maintenance, 1);
      expect(stats.inactive, 1);
    });

    test('filters vehicles by search query and status', () async {
      final filterNotifier = container.read(vehicleFilterProvider.notifier);
      filterNotifier.setSearch('Urvan');
      container.read(vehiclesPageProvider);
      await _waitForVehiclesPage(container);
      expect(fakeRepo.lastSearch, 'Urvan');
      var filtered = container.read(vehiclesPageProvider).result.content;
      expect(filtered.length, 1);
      expect(filtered.first.vehicleNumber, 'DHAKA METRO CHA-55-9812');

      filterNotifier.reset();
      filterNotifier.setStatus(Vehicle.statusActive);
      await _waitForVehiclesPage(container);
      expect(fakeRepo.lastStatus, Vehicle.statusActive);
      filtered = container.read(vehiclesPageProvider).result.content;
      expect(filtered.length, 2);
      for (final v in filtered) {
        expect(v.status, Vehicle.statusActive);
      }
    });
  });
}
