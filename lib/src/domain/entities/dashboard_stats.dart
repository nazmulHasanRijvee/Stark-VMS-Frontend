import 'package:flutter/foundation.dart';

@immutable
class DashboardStats {
  final int total;
  final int active;
  final int inService;
  final int inactive;

  const DashboardStats({
    required this.total,
    required this.active,
    required this.inService,
    required this.inactive,
  });

  const DashboardStats.empty()
    : total = 0,
      active = 0,
      inService = 0,
      inactive = 0;

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      total:
          (map['totalVehicles'] as num?)?.toInt() ??
          (map['total'] as num?)?.toInt() ??
          0,
      active:
          (map['activeVehicles'] as num?)?.toInt() ??
          (map['active'] as num?)?.toInt() ??
          0,
      inService:
          (map['inServiceVehicles'] as num?)?.toInt() ??
          (map['inService'] as num?)?.toInt() ??
          0,
      inactive:
          (map['inactiveVehicles'] as num?)?.toInt() ??
          (map['inactive'] as num?)?.toInt() ??
          0,
    );
  }

  DashboardStats copyWith({
    int? total,
    int? active,
    int? inService,
    int? inactive,
  }) {
    return DashboardStats(
      total: total ?? this.total,
      active: active ?? this.active,
      inService: inService ?? this.inService,
      inactive: inactive ?? this.inactive,
    );
  }
}
