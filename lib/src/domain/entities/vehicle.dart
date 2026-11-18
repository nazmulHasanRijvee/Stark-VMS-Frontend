import 'package:flutter/foundation.dart';

/// Assigned driver summary attached to a vehicle response.
@immutable
class AssignedDriver {
  final int id;
  final String name;
  final String phone;

  const AssignedDriver({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory AssignedDriver.fromMap(Map<String, dynamic> map) {
    return AssignedDriver(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'phone': phone};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedDriver &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AssignedDriver(id: $id, name: $name, phone: $phone)';
}

/// Pure domain entity representing a fleet vehicle in Stark VMS.
///
/// Contains the 6 vehicle fields plus optional assigned driver response:
/// - vehicleNumber
/// - company
/// - type
/// - brand
/// - model
/// - status ('Active', 'Inactive', 'Maintenance')
/// - assignedDriver (nullable, response-only)
@immutable
class Vehicle {
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final String status;
  final AssignedDriver? assignedDriver;

  const Vehicle({
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
    this.assignedDriver,
  });

  /// The only three allowed status labels in Assignment 2 are Active,
  /// Inactive, and Maintenance.
  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String statusMaintenance = 'Maintenance';

  static const List<String> allowedStatuses = [
    statusActive,
    statusInactive,
    statusMaintenance,
  ];

  Vehicle copyWith({
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    String? status,
    AssignedDriver? Function()? assignedDriver,
  }) {
    return Vehicle(
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
      assignedDriver: assignedDriver != null
          ? assignedDriver()
          : this.assignedDriver,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleNumber': vehicleNumber,
      'company': company,
      'type': type,
      'brand': brand,
      'model': model,
      'status': status,
      if (assignedDriver != null) 'assignedDriver': assignedDriver!.toMap(),
    };
  }

  /// Exact JSON payload matching backend API requirements.
  /// Note: assignedDriver is strictly response-only and MUST NOT be sent in CRUD bodies.
  Map<String, dynamic> toBackendJson() {
    return {
      'vehicleNumber': vehicleNumber.trim().toUpperCase(),
      'companyName': company.trim(),
      'vehicleType': type.trim(),
      'brand': brand.trim(),
      'model': model.trim(),
      'status': status.trim(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    AssignedDriver? driver;
    if (map['assignedDriver'] is Map<String, dynamic>) {
      driver = AssignedDriver.fromMap(
        map['assignedDriver'] as Map<String, dynamic>,
      );
    }

    return Vehicle(
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      company: map['companyName'] as String? ?? map['company'] as String? ?? '',
      type: map['vehicleType'] as String? ?? map['type'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      status: map['status'] as String? ?? statusActive,
      assignedDriver: driver,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          vehicleNumber == other.vehicleNumber;

  @override
  int get hashCode => vehicleNumber.hashCode;

  @override
  String toString() =>
      'Vehicle($vehicleNumber, $company, $type, $brand, $model, $status, driver: ${assignedDriver?.name})';
}
