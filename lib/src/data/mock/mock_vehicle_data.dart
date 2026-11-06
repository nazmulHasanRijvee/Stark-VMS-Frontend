import '../../domain/entities/vehicle.dart';

/// Seed mock data for Stark VMS Part 1.
///
/// Contains the four illustrative records specified in the product handoff.
/// The dashboard summary is derived from this dataset:
/// Total: 4, Active: 2, In Service: 1, Inactive: 1.
abstract final class MockVehicleData {
  static const List<Vehicle> initialFleet = [
    Vehicle(
      vehicleNumber: 'DHAKA METRO GA-12-3456',
      company: 'Stark Logistics',
      type: 'Sedan',
      brand: 'Toyota',
      model: 'Corolla',
      status: Vehicle.statusActive,
    ),
    Vehicle(
      vehicleNumber: 'DHAKA METRO CHA-55-9812',
      company: 'Stark Agro',
      type: 'Microbus / Van',
      brand: 'Nissan',
      model: 'Urvan',
      status: Vehicle.statusInService,
    ),
    Vehicle(
      vehicleNumber: 'DHAKA METRO BA-11-2233',
      company: 'Stark Retail',
      type: 'Sedan',
      brand: 'Honda',
      model: 'Civic',
      status: Vehicle.statusActive,
    ),
    Vehicle(
      vehicleNumber: 'CHATTOGRAM METRO KHA-22-1100',
      company: 'Stark Tech',
      type: 'SUV',
      brand: 'Mitsubishi',
      model: 'Pajero',
      status: Vehicle.statusInactive,
    ),
  ];
}

