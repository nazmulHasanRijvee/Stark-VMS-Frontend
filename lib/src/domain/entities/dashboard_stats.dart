import 'package:flutter/foundation.dart';

@immutable
class DocumentExpiryAttention {
  final int documentId;
  final String vehicleNumber;
  final String documentType;
  final String expiryDate;

  const DocumentExpiryAttention({
    required this.documentId,
    required this.vehicleNumber,
    required this.documentType,
    required this.expiryDate,
  });

  factory DocumentExpiryAttention.fromMap(Map<String, dynamic> map) =>
      DocumentExpiryAttention(
        documentId: (map['documentId'] as num?)?.toInt() ?? 0,
        vehicleNumber: map['vehicleNumber'] as String? ?? '',
        documentType: map['documentType']?.toString() ?? '',
        expiryDate: map['expiryDate']?.toString() ?? '',
      );
}

@immutable
class RecentMaintenanceSummary {
  final int recordId;
  final String maintenanceDate;
  final String vehicleNumber;
  final String maintenanceType;
  final String workshop;
  final double cost;

  const RecentMaintenanceSummary({
    required this.recordId,
    required this.maintenanceDate,
    required this.vehicleNumber,
    required this.maintenanceType,
    required this.workshop,
    required this.cost,
  });

  factory RecentMaintenanceSummary.fromMap(Map<String, dynamic> map) =>
      RecentMaintenanceSummary(
        recordId: (map['recordId'] as num?)?.toInt() ?? 0,
        maintenanceDate: map['maintenanceDate']?.toString() ?? '',
        vehicleNumber: map['vehicleNumber']?.toString() ?? '',
        maintenanceType: map['maintenanceType']?.toString() ?? '',
        workshop: map['workshop']?.toString() ?? '',
        cost: _toDouble(map['cost']),
      );
}

@immutable
class DashboardStats {
  final int total;
  final int active;
  final int maintenance;
  final int inactive;
  final int documentExpiringCount;
  final int documentExpiredCount;
  final double maintenanceThisMonthCost;
  final int maintenanceThisMonthCount;
  final List<DocumentExpiryAttention> expiringSoon;
  final List<RecentMaintenanceSummary> recentMaintenance;

  const DashboardStats({
    required this.total,
    required this.active,
    required this.maintenance,
    required this.inactive,
    this.documentExpiringCount = 0,
    this.documentExpiredCount = 0,
    this.maintenanceThisMonthCost = 0.0,
    this.maintenanceThisMonthCount = 0,
    this.expiringSoon = const [],
    this.recentMaintenance = const [],
  });

  const DashboardStats.empty()
    : total = 0,
      active = 0,
      maintenance = 0,
      inactive = 0,
      documentExpiringCount = 0,
      documentExpiredCount = 0,
      maintenanceThisMonthCost = 0,
      maintenanceThisMonthCount = 0,
      expiringSoon = const [],
      recentMaintenance = const [];

  factory DashboardStats.fromMap(Map<String, dynamic> map) => DashboardStats(
    total: (map['totalVehicles'] as num?)?.toInt() ?? 0,
    active: (map['activeVehicles'] as num?)?.toInt() ?? 0,
    maintenance: (map['maintenanceVehicles'] as num?)?.toInt() ?? 0,
    inactive: (map['inactiveVehicles'] as num?)?.toInt() ?? 0,
    documentExpiredCount: (map['expiredDocuments'] as num?)?.toInt() ?? 0,
    documentExpiringCount: (map['expiringSoonDocuments'] as num?)?.toInt() ?? 0,
    maintenanceThisMonthCount:
        (map['maintenanceRecordsThisMonth'] as num?)?.toInt() ?? 0,
    maintenanceThisMonthCost: _toDouble(map['maintenanceCostThisMonth']),
    expiringSoon: _mapList(map['expiringSoon'])
        .map(DocumentExpiryAttention.fromMap)
        .toList(growable: false),
    recentMaintenance: _mapList(map['recentMaintenance'])
        .map(RecentMaintenanceSummary.fromMap)
        .toList(growable: false),
  );
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
