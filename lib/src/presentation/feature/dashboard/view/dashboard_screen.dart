import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/summary_kpi_card.dart';
import '../../vehicles/view_model/vehicles_provider.dart';

/// Desktop-first, responsive Dashboard screen for Stark VMS matching the Stitch design.
///
/// Fully theme-aware (Light & Dark) and localized (English & Bangla)
/// without hardcoded colors or styles.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            constraints: const BoxConstraints(maxWidth: 1200),
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
                      onPressed: () => context.go(Routes.vehicleRegister.path),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.primary,
                        foregroundColor: context.color.onPrimary,
                        elevation: 1,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.lg,
                          vertical: context.spacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.radius.sm),
                        ),
                      ),
                      icon: Icon(Icons.add, size: context.sizes.xs + 2),
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
                _buildKpiGrid(context, stats, screenWidth),

                SizedBox(height: context.spacing.xl),

                // Recently Added Vehicles Section
                Container(
                  decoration: BoxDecoration(
                    color: context.color.surface,
                    borderRadius: BorderRadius.circular(context.radius.md),
                    border: Border.all(color: context.color.border),
                    boxShadow: [
                      BoxShadow(
                        color: context.color.text.primary.withOpacity(0.04),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: context.color.text.primary,
                              ),
                            ),
                            if (recentVehicles.isNotEmpty)
                              TextButton(
                                onPressed: () => context.go(Routes.vehicles.path),
                                child: Text(
                                  context.loc.viewAll,
                                  style: context.textStyle.labelSmall.copyWith(
                                    color: context.color.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: context.color.border),

                      if (recentVehicles.isEmpty)
                        _buildEmptyState(context)
                      else if (screenWidth < 640)
                        _buildMobileRecentList(context, recentVehicles)
                      else
                        _buildDesktopRecentTable(context, recentVehicles),
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
    BuildContext context,
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
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: SummaryKpiCard(
              label: context.loc.activeVehicles,
              value: '${stats.active}',
              valueColor: context.color.success,
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: SummaryKpiCard(
              label: context.loc.inServiceVehicles,
              value: '${stats.inService}',
              valueColor: context.color.warning,
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: SummaryKpiCard(
              label: context.loc.inactiveVehicles,
              value: '${stats.inactive}',
              valueColor: context.color.text.secondary,
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
                ),
              ),
              SizedBox(width: context.spacing.lg),
              Expanded(
                child: SummaryKpiCard(
                  label: context.loc.activeVehicles,
                  value: '${stats.active}',
                  valueColor: context.color.success,
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
                ),
              ),
              SizedBox(width: context.spacing.lg),
              Expanded(
                child: SummaryKpiCard(
                  label: context.loc.inactiveVehicles,
                  value: '${stats.inactive}',
                  valueColor: context.color.text.secondary,
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
          ),
          SizedBox(height: context.spacing.md),
          SummaryKpiCard(
            label: context.loc.activeVehicles,
            value: '${stats.active}',
            valueColor: context.color.success,
          ),
          SizedBox(height: context.spacing.md),
          SummaryKpiCard(
            label: context.loc.inServiceVehicles,
            value: '${stats.inService}',
            valueColor: context.color.warning,
          ),
          SizedBox(height: context.spacing.md),
          SummaryKpiCard(
            label: context.loc.inactiveVehicles,
            value: '${stats.inactive}',
            valueColor: context.color.text.secondary,
          ),
        ],
      );
    }
  }

  Widget _buildDesktopRecentTable(BuildContext context, List recentVehicles) {
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
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
                '${context.loc.colBrand} & ${context.loc.colModel}'.toUpperCase(),
                style: context.textStyle.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
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
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg2,
                  vertical: context.spacing.md + 2,
                ),
                child: Text(
                  v.vehicleNumber,
                  style: context.textStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.color.text.primary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg2,
                  vertical: context.spacing.md + 2,
                ),
                child: Text(
                  '${v.brand} ${v.model}',
                  style: context.textStyle.bodyMedium.copyWith(
                    color: context.color.text.secondary,
                  ),
                ),
              ),
              Padding(
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

  Widget _buildMobileRecentList(BuildContext context, List recentVehicles) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentVehicles.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: context.color.border),
      itemBuilder: (context, index) {
        final v = recentVehicles[index];
        return Padding(
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
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              size: context.sizes.sm + 4,
              color: context.color.icon,
            ),
          ),
          SizedBox(height: context.spacing.lg),
          Text(
            context.loc.noVehiclesInFleet,
            style: context.textStyle.headLineSmall.copyWith(
              fontSize: 17,
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
            onPressed: () => context.go(Routes.vehicleRegister.path),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.color.primary,
              foregroundColor: context.color.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.lg + 2,
                vertical: context.spacing.sm2 + 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radius.sm),
              ),
            ),
            icon: Icon(Icons.add, size: context.sizes.xs),
            label: Text(
              context.loc.registerVehicle,
              style: context.textStyle.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: context.color.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
