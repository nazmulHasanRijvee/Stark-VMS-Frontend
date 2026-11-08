import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/delete_confirm_dialog.dart';
import '../../../core/widgets/status_chip.dart';
import '../view_model/vehicles_provider.dart';

/// Desktop-first, responsive Vehicles List screen for Stark VMS matching the Stitch design.
///
/// Fully theme-aware (Light & Dark) and localized (English & Bangla)
/// without hardcoded colors or styles.
class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  final _searchController = TextEditingController();

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
  void initState() {
    super.initState();
    _searchController.text = ref.read(vehicleFilterProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(vehicleFilterProvider.notifier).setSearch(value);
  }

  void _onStatusChanged(String? status) {
    if (status != null) {
      ref.read(vehicleFilterProvider.notifier).setStatus(status);
    }
  }

  void _resetFilter() {
    _searchController.clear();
    ref.read(vehicleFilterProvider.notifier).reset();
  }

  void _openVehicleEditor(Vehicle vehicle) {
    final path = Routes.vehicleEdit.path.replaceFirst(
      ':vehicleNumber',
      Uri.encodeComponent(vehicle.vehicleNumber),
    );
    // Defer navigation to next frame to avoid triggering a route change during
    // a pointer-event dispatch cycle (mouse_tracker.dart:199 assertion).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(path);
    });
  }

  Future<void> _handleDelete(Vehicle vehicle) async {
    final confirmed = await DeleteConfirmDialog.show(
      context,
      vehicleNumber: vehicle.vehicleNumber,
    );

    if (confirmed == true && mounted) {
      final successLoc = context.loc.vehicleDeletedSuccess;
      await ref
          .read(vehiclesProvider.notifier)
          .deleteVehicle(vehicle.vehicleNumber);
      if (mounted) {
        CustomToast.showSuccess(
          context,
          title: successLoc,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VehicleFilterState>(vehicleFilterProvider, (previous, next) {
      if (previous?.searchQuery == next.searchQuery ||
          _searchController.text == next.searchQuery) {
        return;
      }

      _searchController.value = TextEditingValue(
        text: next.searchQuery,
        selection: TextSelection.collapsed(offset: next.searchQuery.length),
      );
    });

    final totalVehicles = ref.watch(vehiclesProvider);
    final filteredVehicles = ref.watch(filteredVehiclesProvider);
    final filter = ref.watch(vehicleFilterProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

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
                // Top Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.vehiclesTitle,
                            style: context.textStyle.headLineLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: context.color.text.primary,
                            ),
                          ),
                          SizedBox(height: context.spacing.xs),
                          Text(
                            context.loc.vehiclesSubtitle,
                            style: context.textStyle.bodyMedium.copyWith(
                              color: context.color.text.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.spacing.lg),
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

                SizedBox(height: context.spacing.lg),

                // Search & Filter Toolbar
                Container(
                  padding: EdgeInsets.all(context.spacing.md),
                  decoration: BoxDecoration(
                    color: context.color.surface,
                    borderRadius: BorderRadius.circular(context.radius.md),
                    border: Border.all(color: context.color.border),
                    boxShadow: [
                      BoxShadow(
                        color: context.color.text.primary.withValues(
                          alpha: 0.04,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: screenWidth < 700
                      ? Column(
                          children: [
                            _buildSearchInput(context),
                            SizedBox(height: context.spacing.sm3),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatusDropdown(context, filter),
                                ),
                                SizedBox(width: context.spacing.sm),
                                _buildResetButton(context),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildSearchInput(context)),
                            SizedBox(width: context.spacing.md),
                            SizedBox(
                              width: context.sizes.filterInputWidth,
                              child: _buildStatusDropdown(context, filter),
                            ),
                            SizedBox(width: context.spacing.sm),
                            _buildResetButton(context),
                          ],
                        ),
                ),

                SizedBox(height: context.spacing.md),

                // Vehicle Records List or Table
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
                      if (filteredVehicles.isEmpty)
                        _buildEmptyResults(
                          context: context,
                          hasAnyVehicle: totalVehicles.isNotEmpty,
                        )
                      else if (isDesktop)
                        _buildDesktopTable(context, filteredVehicles)
                      else
                        _buildMobileCardList(context, filteredVehicles),

                      // Result Summary Footer
                      if (filteredVehicles.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.spacing.lg2,
                            vertical: context.spacing.md2,
                          ),
                          decoration: BoxDecoration(
                            color: context.color.surfaceSubtle,
                            border: Border(
                              top: BorderSide(color: context.color.border),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.loc.showingPagination(
                                  filteredVehicles.isNotEmpty ? 1 : 0,
                                  filteredVehicles.length,
                                  totalVehicles.length,
                                ),
                                style: context.textStyle.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: context.color.text.secondary,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.chevron_left,
                                      size: context.sizes.iconSm,
                                      color: context.color.text.tertiary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth:
                                          context.sizes.paginationButtonSize,
                                      minHeight:
                                          context.sizes.paginationButtonSize,
                                    ),
                                  ),
                                  Container(
                                    width:
                                        context.sizes.paginationIndicatorSize,
                                    height:
                                        context.sizes.paginationIndicatorSize,
                                    decoration: BoxDecoration(
                                      color: context.color.primary,
                                      borderRadius: BorderRadius.circular(
                                        context.radius.xs2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '1',
                                        style: context.textStyle.labelSmall
                                            .copyWith(
                                              color: context.color.onPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.chevron_right,
                                      size: context.sizes.iconSm,
                                      color: context.color.text.tertiary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth:
                                          context.sizes.paginationButtonSize,
                                      minHeight:
                                          context.sizes.paginationButtonSize,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildSearchInput(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      style: context.textStyle.bodyMedium.copyWith(
        color: context.color.text.primary,
      ),
      decoration: InputDecoration(
        hintText: context.loc.searchVehiclesHint,
        hintStyle: context.textStyle.bodyMedium.copyWith(
          color: context.color.text.tertiary,
        ),
        prefixIcon: Icon(
          Icons.search,
          size: context.sizes.iconMd,
          color: context.color.icon,
        ),
        filled: true,
        fillColor: context.color.textFieldFillColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.spacing.md2,
          vertical: context.spacing.sm3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius.sm),
          borderSide: BorderSide(color: context.color.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius.sm),
          borderSide: BorderSide(color: context.color.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius.sm),
          borderSide: BorderSide(
            color: context.color.primary,
            width: context.sizes.focusStrokeWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, VehicleFilterState filter) {
    final statuses = [
      VehicleFilterState.allStatuses,
      Vehicle.statusActive,
      Vehicle.statusInService,
      Vehicle.statusInactive,
    ];

    return Container(
      height: context.sizes.compactControlHeight,
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
      decoration: BoxDecoration(
        color: context.color.textFieldFillColor,
        borderRadius: BorderRadius.circular(context.radius.sm),
        border: Border.all(color: context.color.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filter.statusFilter,
          isExpanded: true,
          dropdownColor: context.color.surface,
          icon: Icon(
            Icons.expand_more,
            size: context.sizes.iconSm,
            color: context.color.icon,
          ),
          style: context.textStyle.dataMedium.copyWith(
            color: context.color.text.primary,
          ),
          items: statuses.map((s) {
            String label;
            if (s == VehicleFilterState.allStatuses) {
              label = context.loc.allStatuses;
            } else {
              label = context.loc.localizedStatus(s);
            }
            return DropdownMenuItem<String>(value: s, child: Text(label));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              _onStatusChanged(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return InkWell(
      onTap: _resetFilter,
      borderRadius: BorderRadius.circular(context.radius.sm),
      child: Container(
        height: context.sizes.compactControlHeight,
        padding: EdgeInsets.symmetric(horizontal: context.spacing.md2),
        decoration: BoxDecoration(
          color: context.color.surfaceSubtle,
          borderRadius: BorderRadius.circular(context.radius.sm),
          border: Border.all(color: context.color.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restart_alt,
              size: context.sizes.xs,
              color: context.color.icon,
            ),
            SizedBox(width: context.spacing.sm2),
            Text(
              context.loc.clearFilters,
              style: context.textStyle.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.color.text.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Vehicle> vehicles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minTableWidth = 920.0;
        final tableWidth = math.max(constraints.maxWidth, minTableWidth);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.8), // Vehicle Number
                1: FlexColumnWidth(1.4), // Company
                2: FlexColumnWidth(1.1), // Type
                3: FlexColumnWidth(1.0), // Brand
                4: FlexColumnWidth(1.0), // Model
                5: FlexColumnWidth(1.1), // Status
                6: FlexColumnWidth(1.6), // Actions
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: context.color.surfaceSubtle,
                    border: Border(
                      bottom: BorderSide(color: context.color.border),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
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
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                      child: Text(
                        context.loc.colCompany.toUpperCase(),
                        style: context.textStyle.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.color.text.secondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                      child: Text(
                        context.loc.colType.toUpperCase(),
                        style: context.textStyle.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.color.text.secondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                      child: Text(
                        context.loc.colBrand.toUpperCase(),
                        style: context.textStyle.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.color.text.secondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                      child: Text(
                        context.loc.colModel.toUpperCase(),
                        style: context.textStyle.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.color.text.secondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          context.loc.colActions.toUpperCase(),
                          style: context.textStyle.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.color.text.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                for (final v in vehicles)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: context.color.border),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md2,
                        ),
                        child: Text(
                          v.vehicleNumber,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textStyle.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.color.text.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md2,
                        ),
                        child: Text(
                          v.company,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textStyle.dataMedium.copyWith(
                            color: context.color.text.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md2,
                        ),
                        child: Text(
                          v.type,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textStyle.dataMedium.copyWith(
                            color: context.color.text.secondary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md2,
                        ),
                        child: Text(
                          v.brand,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textStyle.dataMedium.copyWith(
                            color: context.color.text.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md2,
                        ),
                        child: Text(
                          v.model,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textStyle.dataMedium.copyWith(
                            color: context.color.text.secondary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: StatusChip(status: v.status),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.sm3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _openVehicleEditor(v),
                              borderRadius: BorderRadius.circular(
                                context.radius.xs2,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spacing.sm2,
                                  vertical: context.spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: context.color.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(
                                    context.radius.xs2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: context.sizes.iconXs,
                                      color: context.color.primary,
                                    ),
                                    SizedBox(width: context.spacing.xs),
                                    Text(
                                      context.loc.edit,
                                      style: context.textStyle.labelSmall
                                          .copyWith(
                                            color: context.color.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: context.spacing.xs),
                            InkWell(
                              onTap: () => _handleDelete(v),
                              borderRadius: BorderRadius.circular(
                                context.radius.xs2,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spacing.sm2,
                                  vertical: context.spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: context.color.errorBg,
                                  borderRadius: BorderRadius.circular(
                                    context.radius.xs2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: context.sizes.iconXs,
                                      color: context.color.error,
                                    ),
                                    SizedBox(width: context.spacing.xs),
                                    Text(
                                      context.loc.delete,
                                      style: context.textStyle.labelSmall
                                          .copyWith(
                                            color: context.color.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileCardList(BuildContext context, List<Vehicle> vehicles) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      separatorBuilder: (_, _) => Divider(
        height: context.sizes.hairlineWidth,
        color: context.color.border,
      ),
      itemBuilder: (context, index) {
        final v = vehicles[index];
        return Padding(
          padding: EdgeInsets.all(context.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      v.vehicleNumber,
                      style: context.textStyle.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.color.text.primary,
                      ),
                    ),
                  ),
                  StatusChip(status: v.status),
                ],
              ),
              SizedBox(height: context.spacing.sm3),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.colCompany,
                          style: context.textStyle.labelSmall.copyWith(
                            color: context.color.text.tertiary,
                          ),
                        ),
                        Text(
                          v.company,
                          style: context.textStyle.dataMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.color.text.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.colType,
                          style: context.textStyle.labelSmall.copyWith(
                            color: context.color.text.tertiary,
                          ),
                        ),
                        Text(
                          v.type,
                          style: context.textStyle.dataMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.color.text.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.colBrand,
                          style: context.textStyle.labelSmall.copyWith(
                            color: context.color.text.tertiary,
                          ),
                        ),
                        Text(
                          v.brand,
                          style: context.textStyle.dataMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.color.text.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.colModel,
                          style: context.textStyle.labelSmall.copyWith(
                            color: context.color.text.tertiary,
                          ),
                        ),
                        Text(
                          v.model,
                          style: context.textStyle.dataMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.color.text.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.md2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openVehicleEditor(v),
                    icon: Icon(Icons.edit_outlined, size: context.sizes.iconXs),
                    label: Text(context.loc.edit),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.sm3,
                        vertical: context.spacing.xs,
                      ),
                      foregroundColor: context.color.primary,
                      backgroundColor: context.color.surfaceSubtle,
                      side: BorderSide(color: context.color.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.radius.sm),
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacing.sm),
                  ElevatedButton.icon(
                    onPressed: () => _handleDelete(v),
                    icon: Icon(
                      Icons.delete_outline,
                      size: context.sizes.iconXs,
                    ),
                    label: Text(context.loc.delete),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.sm3,
                        vertical: context.spacing.xs,
                      ),
                      backgroundColor: context.color.errorBg,
                      foregroundColor: context.color.error,
                      elevation: 0,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.radius.sm),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyResults({
    required BuildContext context,
    required bool hasAnyVehicle,
  }) {
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
              borderRadius: BorderRadius.circular(context.radius.lg),
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: context.sizes.iconLg,
              color: context.color.icon,
            ),
          ),
          SizedBox(height: context.spacing.lg),
          Text(
            hasAnyVehicle
                ? context.loc.noVehiclesMatch
                : context.loc.noVehiclesInFleet,
            style: context.textStyle.headLineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: context.color.text.primary,
            ),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            hasAnyVehicle
                ? context.loc.tryAdjustingFilters
                : context.loc.noVehiclesInFleetDesc,
            textAlign: TextAlign.center,
            style: context.textStyle.bodySmall.copyWith(
              color: context.color.text.secondary,
            ),
          ),
          SizedBox(height: context.spacing.lg2),
          if (hasAnyVehicle)
            OutlinedButton.icon(
              onPressed: _resetFilter,
              icon: Icon(Icons.restart_alt, size: context.sizes.xs),
              label: Text(context.loc.clearFilters),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg,
                  vertical: context.spacing.sm,
                ),
                side: BorderSide(color: context.color.border),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _navigateTo(Routes.vehicleRegister.path),
              icon: Icon(Icons.add, size: context.sizes.xs),
              label: Text(context.loc.registerVehicle),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.color.primary,
                foregroundColor: context.color.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg,
                  vertical: context.spacing.sm,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
