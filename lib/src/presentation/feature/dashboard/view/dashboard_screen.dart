import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/summary_kpi_card.dart';
import '../../vehicles/view_model/vehicles_provider.dart';

/// Desktop-first, responsive Dashboard screen for Stark VMS matching the Stitch design.
///
/// Fully theme-aware (Light & Dark) and localized (English & Bangla)
/// without hardcoded colors or styles.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  /// Defers route changes to the next frame to avoid triggering a Navigator
  /// mutation during an active pointer-event dispatch cycle, which causes the
  /// mouse_tracker.dart:199 "!_debugDuringDeviceUpdate" Flutter assertion.
  void _navigateTo(String path) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardStatsProvider);
    final recentVehicles = ref.watch(recentlyAddedVehiclesProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: context.color.scaffoldBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          screenWidth < 600 ? context.spacing.md : context.spacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.sizes.contentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header: Title & Register Vehicle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.loc.dashboardTitle,
                      style: context.textStyle.headLineLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: context.color.text.primary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _navigateTo(Routes.vehicleRegister.path),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.primary,
                        foregroundColor: context.color.onPrimary,
                        elevation: 1,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.lg,
                          vertical: context.spacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.radius.sm,
                          ),
                        ),
                      ),
                      icon: Icon(Icons.add, size: context.sizes.iconSm),
                      label: Text(
                        context.loc.registerVehicle,
                        style: context.textStyle.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.color.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.spacing.xl),

                // 4 Summary KPI Cards
                _buildKpiGrid(stats, screenWidth),

                SizedBox(height: context.spacing.xl),

                // Recently Added Vehicles Section
                Container(
                  decoration: BoxDecoration(
                    color: context.color.surface,
                    borderRadius: BorderRadius.circular(context.radius.md),
                    border: Border.all(color: context.color.border),
                    boxShadow: [
                      BoxShadow(
                        color: context.color.text.primary.withValues(
                          alpha: 0.04,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(context.spacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.loc.recentlyAddedVehicles,
                              style: context.textStyle.headLineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.color.text.primary,
                              ),
                            ),
                            if (recentVehicles.isNotEmpty)
                              TextButton(
                                onPressed: () => _openVehicleList(
                                  VehicleFilterState.allStatuses,
                                ),
                                child: Text(
                                  context.loc.viewAll,
                                  style: context.textStyle.labelLarge.copyWith(
                                    color: context.color.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Divider(
                        height: context.sizes.hairlineWidth,
                        color: context.color.border,
                      ),

                      if (recentVehicles.isEmpty)
                        _buildEmptyState()
                      else if (screenWidth < 640)
                        _buildMobileRecentList(recentVehicles)
                      else
                        _buildDesktopRecentTable(recentVehicles),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(
    DashboardStats stats,
    double screenWidth,
  ) {
    if (screenWidth >= 1024) {
      // 4 in a single row on desktop
      return Row(
        children: [
          Expanded(
            child: SummaryKpiCard(
              label: context.loc.totalFleet,
              value: '${stats.total}',
              valueColor: context.color.text.primary,
              onTap: () => _openVehicleList(VehicleFilterState.allStatuses),
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: SummaryKpiCard(
              label: context.loc.activeVehicles,
              value: '${stats.active}',
              valueColor: context.color.success,
              onTap: () => _openVehicleList(Vehicle.statusActive),
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: SummaryKpiCard(
              label: context.loc.inServiceVehicles,
              value: '${stats.inService}',
              valueColor: context.color.warning,
              onTap: () => _openVehicleList(Vehicle.statusInService),
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: SummaryKpiCard(
              label: context.loc.inactiveVehicles,
              value: '${stats.inactive}',
              valueColor: context.color.text.secondary,
              onTap: () => _openVehicleList(Vehicle.statusInactive),
            ),
          ),
        ],
      );
    } else if (screenWidth >= 600) {
      // 2x2 grid on tablet
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryKpiCard(
                  label: context.loc.totalFleet,
                  value: '${stats.total}',
                  valueColor: context.color.text.primary,
                  onTap: () =>
                      _openVehicleList(VehicleFilterState.allStatuses),
                ),
              ),
              SizedBox(width: context.spacing.lg),
              Expanded(
                child: SummaryKpiCard(
                  label: context.loc.activeVehicles,
                  value: '${stats.active}',
                  valueColor: context.color.success,
                  onTap: () => _openVehicleList(Vehicle.statusActive),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.lg),
          Row(
            children: [
              Expanded(
                child: SummaryKpiCard(
                  label: context.loc.inServiceVehicles,
                  value: '${stats.inService}',
                  valueColor: context.color.warning,
                  onTap: () => _openVehicleList(Vehicle.statusInService),
                ),
              ),
              SizedBox(width: context.spacing.lg),
              Expanded(
                child: SummaryKpiCard(
                  label: context.loc.inactiveVehicles,
                  value: '${stats.inactive}',
                  valueColor: context.color.text.secondary,
                  onTap: () => _openVehicleList(Vehicle.statusInactive),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Stacked on small mobile
      return Column(
        children: [
          SummaryKpiCard(
            label: context.loc.totalFleet,
            value: '${stats.total}',
            valueColor: context.color.text.primary,
            onTap: () => _openVehicleList(VehicleFilterState.allStatuses),
          ),
          SizedBox(height: context.spacing.md),
          SummaryKpiCard(
            label: context.loc.activeVehicles,
            value: '${stats.active}',
            valueColor: context.color.success,
            onTap: () => _openVehicleList(Vehicle.statusActive),
          ),
          SizedBox(height: context.spacing.md),
          SummaryKpiCard(
            label: context.loc.inServiceVehicles,
            value: '${stats.inService}',
            valueColor: context.color.warning,
            onTap: () => _openVehicleList(Vehicle.statusInService),
          ),
          SizedBox(height: context.spacing.md),
          SummaryKpiCard(
            label: context.loc.inactiveVehicles,
            value: '${stats.inactive}',
            valueColor: context.color.text.secondary,
            onTap: () => _openVehicleList(Vehicle.statusInactive),
          ),
        ],
      );
    }
  }

  Widget _buildDesktopRecentTable(List<Vehicle> recentVehicles) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.4),
        1: FlexColumnWidth(1.4),
        2: FlexColumnWidth(0.8),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: context.color.surfaceSubtle,
            border: Border(bottom: BorderSide(color: context.color.border)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.lg2,
                vertical: context.spacing.md,
              ),
              child: Text(
                context.loc.colVehicleNumber.toUpperCase(),
                style: context.textStyle.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.color.text.secondary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.lg2,
                vertical: context.spacing.md,
              ),
              child: Text(
                '${context.loc.colBrand} & ${context.loc.colModel}'
                    .toUpperCase(),
                style: context.textStyle.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.color.text.secondary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.lg2,
                vertical: context.spacing.md,
              ),
              child: Text(
                context.loc.colStatus.toUpperCase(),
                style: context.textStyle.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.color.text.secondary,
                ),
              ),
            ),
          ],
        ),
        for (final v in recentVehicles)
          TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.color.border)),
            ),
            children: [
              _buildRecentVehicleCell(
                v,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg2,
                  vertical: context.spacing.md2,
                ),
                child: Text(
                  v.vehicleNumber,
                  style: context.textStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.color.text.primary,
                  ),
                ),
              ),
              _buildRecentVehicleCell(
                v,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg2,
                  vertical: context.spacing.md2,
                ),
                child: Text(
                  '${v.brand} ${v.model}',
                  style: context.textStyle.bodyMedium.copyWith(
                    color: context.color.text.secondary,
                  ),
                ),
              ),
              _buildRecentVehicleCell(
                v,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg2,
                  vertical: context.spacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(status: v.status),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRecentVehicleCell(
    Vehicle vehicle, {
    required EdgeInsets padding,
    required Widget child,
  }) {
    return InkWell(
      onTap: () => _openVehicleEditor(vehicle),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _buildMobileRecentList(List<Vehicle> recentVehicles) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentVehicles.length,
      separatorBuilder: (_, _) => Divider(
        height: context.sizes.hairlineWidth,
        color: context.color.border,
      ),
      itemBuilder: (_, index) {
        final v = recentVehicles[index];
        return InkWell(
          onTap: () => _openVehicleEditor(v),
          borderRadius: BorderRadius.circular(context.radius.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.lg,
              vertical: context.spacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.vehicleNumber,
                        style: context.textStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.color.text.primary,
                        ),
                      ),
                      SizedBox(height: context.spacing.xxs),
                      Text(
                        '${v.brand} ${v.model}',
                        style: context.textStyle.bodySmall.copyWith(
                          color: context.color.text.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: v.status),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openVehicleList(String status) {
    final filter = ref.read(vehicleFilterProvider.notifier);
    filter
      ..setSearch('')
      ..setStatus(status);
    _navigateTo(Routes.vehicles.path);
  }

  void _openVehicleEditor(Vehicle vehicle) {
    final path = Routes.vehicleEdit.path.replaceFirst(
      ':vehicleNumber',
      Uri.encodeComponent(vehicle.vehicleNumber),
    );
    _navigateTo(path);
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.xl,
        vertical: context.spacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.sizes.lg2,
            height: context.sizes.lg2,
            decoration: BoxDecoration(
              color: context.color.surfaceSubtle,
              borderRadius: BorderRadius.circular(context.radius.pill),
            ),
            child: Icon(
              Icons.no_crash_outlined,
              size: context.sizes.iconLg,
              color: context.color.icon,
            ),
          ),
          SizedBox(height: context.spacing.lg),
          Text(
            context.loc.noVehiclesInFleet,
            style: context.textStyle.headLineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: context.color.text.primary,
            ),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            context.loc.noVehiclesInFleetDesc,
            textAlign: TextAlign.center,
            style: context.textStyle.bodySmall.copyWith(
              color: context.color.text.secondary,
            ),
          ),
          SizedBox(height: context.spacing.lg2),
          ElevatedButton.icon(
            onPressed: () => _navigateTo(Routes.vehicleRegister.path),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.color.primary,
              foregroundColor: context.color.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.lg3,
                vertical: context.spacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radius.sm),
              ),
            ),
            icon: Icon(Icons.add, size: context.sizes.xs),
            label: Text(
              context.loc.registerVehicle,
              style: context.textStyle.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: context.color.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
