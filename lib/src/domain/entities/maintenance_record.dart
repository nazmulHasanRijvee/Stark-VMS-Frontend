import 'package:flutter/foundation.dart';

/// Pure domain entity representing a maintenance record in Stark VMS.
@immutable
class MaintenanceRecord {
  final int? id;
  final int? vehicleId;
  final String maintenanceDate;
  final String maintenanceType;
  final double cost;
  final String workshop;
  final String? notes;
  final String? createdAt;

  const MaintenanceRecord({
    this.id,
    this.vehicleId,
    required this.maintenanceDate,
    required this.maintenanceType,
    required this.cost,
    required this.workshop,
    this.notes,
    this.createdAt,
  });

  static const List<String> commonMaintenanceTypes = [
    'Scheduled Service',
    'Oil Change',
    'Tire Replacement',
    'Brake Inspection / Repair',
    'Engine Diagnostics',
    'Battery Replacement',
    'Suspension & Alignment',
    'Body & Paint',
    'Emergency Repair',
    'Other',
  ];

  Map<String, dynamic> toBackendJson() {
    return {
      'maintenanceDate': maintenanceDate.trim(),
      'maintenanceType': maintenanceType.trim(),
      'cost': cost,
      'workshop': workshop.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: (map['id'] as num?)?.toInt(),
      vehicleId: (map['vehicleId'] as num?)?.toInt(),
      maintenanceDate: map['maintenanceDate'] as String? ?? '',
      maintenanceType: map['maintenanceType'] as String? ?? 'General Service',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      workshop: map['workshop'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicleId': vehicleId,
      'maintenanceDate': maintenanceDate,
      'maintenanceType': maintenanceType,
      'cost': cost,
      'workshop': workshop,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MaintenanceRecord($id, $maintenanceDate, $maintenanceType, \$$cost, $workshop)';
}
