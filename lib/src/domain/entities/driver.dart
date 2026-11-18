import 'package:flutter/foundation.dart';

/// Assigned vehicle summary attached to a driver response.
@immutable
class AssignedVehicle {
  final String vehicleNumber;
  final String brand;
  final String model;

  const AssignedVehicle({
    required this.vehicleNumber,
    required this.brand,
    required this.model,
  });

  factory AssignedVehicle.fromMap(Map<String, dynamic> map) {
    return AssignedVehicle(
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'vehicleNumber': vehicleNumber,
    'brand': brand,
    'model': model,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedVehicle &&
          runtimeType == other.runtimeType &&
          vehicleNumber == other.vehicleNumber;

  @override
  int get hashCode => vehicleNumber.hashCode;

  @override
  String toString() => 'AssignedVehicle($vehicleNumber, $brand, $model)';
}

/// Pure domain entity representing a driver in Stark VMS.
@immutable
class Driver {
  final int id;
  final String name;
  final String phone;
  final String licenseNumber;
  final String licenseExpiry;
  final String status;
  final AssignedVehicle? assignedVehicle;

  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.status,
    this.assignedVehicle,
  });

  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';

  static const List<String> allowedStatuses = [statusActive, statusInactive];

  bool get isAssigned => assignedVehicle != null;
  bool get isActive => status == statusActive;

  Driver copyWith({
    int? id,
    String? name,
    String? phone,
    String? licenseNumber,
    String? licenseExpiry,
    String? status,
    AssignedVehicle? Function()? assignedVehicle,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      status: status ?? this.status,
      assignedVehicle: assignedVehicle != null
          ? assignedVehicle()
          : this.assignedVehicle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry,
      'status': status,
      if (assignedVehicle != null) 'assignedVehicle': assignedVehicle!.toMap(),
    };
  }

  /// Exact JSON payload matching backend API requirements.
  /// outer whitespace trimmed, license uppercase.
  Map<String, dynamic> toBackendJson() {
    return {
      'name': name.trim(),
      'phone': phone.trim(),
      'licenseNumber': licenseNumber.trim().toUpperCase(),
      'licenseExpiry': licenseExpiry.trim(),
      'status': status.trim(),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    AssignedVehicle? vehicle;
    if (map['assignedVehicle'] is Map<String, dynamic>) {
      vehicle = AssignedVehicle.fromMap(
        map['assignedVehicle'] as Map<String, dynamic>,
      );
    }

    return Driver(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      licenseNumber: map['licenseNumber'] as String? ?? '',
      licenseExpiry: map['licenseExpiry'] as String? ?? '',
      status: map['status'] as String? ?? statusActive,
      assignedVehicle: vehicle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Driver && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Driver($id, $name, $phone, $licenseNumber, $licenseExpiry, $status, vehicle: ${assignedVehicle?.vehicleNumber})';
}
