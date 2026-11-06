import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stark_vms/src/domain/entities/vehicle.dart';
import 'package:stark_vms/src/presentation/feature/vehicles/view_model/vehicles_provider.dart';

void main() {
  group('VehiclesProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state contains exactly 4 seed vehicles', () {
      final vehicles = container.read(vehiclesProvider);
      expect(vehicles.length, 4);
      expect(vehicles.any((v) => v.vehicleNumber == 'DHAKA METRO GA-12-3456'), isTrue);
    });

    test('adds a new vehicle with uppercase vehicleNumber', () {
      final notifier = container.read(vehiclesProvider.notifier);
      const newVehicle = Vehicle(
        vehicleNumber: 'dhaka metro ha-99-0001',
        company: 'Stark Logistics',
        type: 'Pickup',
        brand: 'Ford',
        model: 'Ranger',
        status: Vehicle.statusActive,
      );

      final error = notifier.addVehicle(newVehicle);
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

    test('prevents adding duplicate vehicle', () {
      final notifier = container.read(vehiclesProvider.notifier);
      const duplicateVehicle = Vehicle(
        vehicleNumber: 'DHAKA METRO GA-12-3456',
        company: 'Other Company',
        type: 'Van',
        brand: 'Toyota',
        model: 'HiAce',
        status: Vehicle.statusActive,
      );

      final error = notifier.addVehicle(duplicateVehicle);
      expect(error, isNotNull);
      expect(container.read(vehiclesProvider).length, 4);
    });

    test('updates existing vehicle without duplicate error on its own plate', () {
      final notifier = container.read(vehiclesProvider.notifier);
      const updatedVehicle = Vehicle(
        vehicleNumber: 'DHAKA METRO GA-12-3456',
        company: 'Stark Corp Updated',
        type: 'Heavy Truck',
        brand: 'Scania',
        model: 'R500',
        status: Vehicle.statusInService,
      );

      final error = notifier.updateVehicle('DHAKA METRO GA-12-3456', updatedVehicle);
      expect(error, isNull);

      final vehicle = notifier.getVehicle('DHAKA METRO GA-12-3456');
      expect(vehicle?.company, 'Stark Corp Updated');
      expect(vehicle?.status, Vehicle.statusInService);
    });

    test('deletes a vehicle by vehicleNumber', () {
      final notifier = container.read(vehiclesProvider.notifier);
      notifier.deleteVehicle('DHAKA METRO GA-12-3456');

      final vehicles = container.read(vehiclesProvider);
      expect(vehicles.length, 3);
      expect(vehicles.any((v) => v.vehicleNumber == 'DHAKA METRO GA-12-3456'), isFalse);
    });

    test('calculates accurate dashboard stats', () {
      final stats = container.read(dashboardStatsProvider);
      expect(stats.total, 4);
      expect(stats.active, 2);
      expect(stats.inService, 1);
      expect(stats.inactive, 1);
    });

    test('filters vehicles by search query and status', () {
      container.read(vehicleFilterProvider.notifier).setSearch('Land Cruiser');
      var filtered = container.read(filteredVehiclesProvider);
      expect(filtered.length, 1);
      expect(filtered.first.vehicleNumber, 'DHAKA METRO CHA-55-9812');

      container.read(vehicleFilterProvider.notifier).reset();
      container.read(vehicleFilterProvider.notifier).setStatus(Vehicle.statusActive);
      filtered = container.read(filteredVehiclesProvider);
      expect(filtered.length, 2);
      for (final v in filtered) {
        expect(v.status, Vehicle.statusActive);
      }
    });
  });
}

