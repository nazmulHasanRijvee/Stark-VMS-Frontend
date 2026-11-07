import 'package:flutter/foundation.dart';

/// Pure domain entity representing a fleet vehicle in Stark VMS.
///
/// Contains exactly the 6 fields mandated by the product requirements:
/// - vehicleNumber
/// - company
/// - type
/// - brand
/// - model
/// - status ('Active', 'In Service', 'Inactive')
@immutable
class Vehicle {
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final String status;

  const Vehicle({
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
  });

  /// The only three allowed status labels according to the specification.
  static const String statusActive = 'Active';
  static const String statusInService = 'In Service';
  static const String statusInactive = 'Inactive';

  static const List<String> allowedStatuses = [
    statusActive,
    statusInService,
    statusInactive,
  ];

  Vehicle copyWith({
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    String? status,
  }) {
    return Vehicle(
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
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
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      company: map['company'] as String? ?? '',
      type: map['type'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      status: map['status'] as String? ?? statusActive,
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
      'Vehicle($vehicleNumber, $company, $type, $brand, $model, $status)';
}
