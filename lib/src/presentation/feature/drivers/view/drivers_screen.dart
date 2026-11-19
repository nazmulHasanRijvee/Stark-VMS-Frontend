import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_skeletonizer.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/custom_loading_indicator.dart';
import '../../../core/widgets/status_chip.dart';
import '../view_model/drivers_provider.dart';

class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key});

  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(driversFilterProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) ref.read(driversFilterProvider.notifier).setSearch(value);
    });
  }

  void _onStatusChanged(String? status) {
    if (status != null) {
      ref.read(driversFilterProvider.notifier).setStatus(status);
    }
  }

  void _resetFilter() {
    _searchController.clear();
    ref.read(driversFilterProvider.notifier).reset();
  }

  void _navigateTo(String path) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(path);
    });
  }

  void _openDriverForm() => _navigateTo(Routes.driverRegister.path);

  void _openDriverEdit(Driver driver) {
    final path = Routes.driverEdit.path.replaceFirst(
      ':driverId',
      driver.id.toString(),
    );
    _navigateTo(path);
  }

  String _formatDate(BuildContext context, String value) {
    final date = DateTime.tryParse(value);
    return date == null
        ? value
        : MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Future<void> _handleDelete(Driver driver) async {
    if (driver.isAssigned) {
      CustomToast.showError(
        context,
        title: context.loc.cannotDeleteAssignedDriver,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.loc.deleteDriver),
        content: Text(ctx.loc.deleteDriverConfirm(driver.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctx.color.error,
              foregroundColor: ctx.color.errorFg,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.loc.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final successLoc = context.loc.driverDeletedSuccess;
      final success = await ref
          .read(driversProvider.notifier)
          .deleteDriver(driver.id);
      if (mounted) {
        if (success) {
          CustomToast.showSuccess(context, title: successLoc);
        } else {
          final err = ref.read(driversProvider).errorMessage;
          CustomToast.showError(
            context,
            title: err == null
                ? context.loc.cannotDeleteAssignedDriver
                : context.loc.localizedApiError(err),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driversProvider);
    final filter = ref.watch(driversFilterProvider);
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
                // Top Header: Title & Add Driver Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.driversTitle,
                            style: context.textStyle.headLineLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: context.color.text.primary,
                            ),
                          ),
                          SizedBox(height: context.spacing.xs),
                          Text(
                            context.loc.driversSubtitle,
                            style: context.textStyle.bodyMedium.copyWith(
                              color: context.color.text.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.spacing.lg),
                    ElevatedButton.icon(
                      onPressed: _openDriverForm,
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
                        context.loc.addDriver,
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

                // Drivers Content Container
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
                  child: AppSkeletonizer(
                    enabled: state.isLoading && state.drivers.isNotEmpty,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.isLoading && state.drivers.isEmpty)
                          const SizedBox(
                            height: 120,
                            child: CustomLoadingIndicator(),
                          )
                        else if (state.errorMessage != null &&
                            state.drivers.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(context.spacing.xl),
                            child: Column(
                              children: [
                                Text(
                                  context.loc.localizedApiError(
                                    state.errorMessage!,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => ref
                                      .read(driversProvider.notifier)
                                      .fetchDrivers(),
                                  child: Text(context.loc.retry),
                                ),
                              ],
                            ),
                          )
                        else if (state.drivers.isEmpty)
                          _buildEmptyResults(context)
                        else if (isDesktop)
                          _buildDesktopTable(context, state.drivers)
                        else
                          _buildMobileCardList(context, state.drivers),

                        // Pagination Footer
                        if (state.drivers.isNotEmpty)
                          _buildPaginationFooter(context, state),
                      ],
                    ),
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
    return SizedBox(
      height: context.sizes.compactControlHeight,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: context.textStyle.dataMedium.copyWith(
          color: context.color.text.primary,
        ),
        decoration: InputDecoration(
          hintText: context.loc.searchDriversHint,
          hintStyle: context.textStyle.dataMedium.copyWith(
            color: context.color.text.tertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: context.sizes.iconSm,
            color: context.color.icon,
          ),
          filled: true,
          fillColor: context.color.textFieldFillColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.xs,
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
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, DriversFilterState filter) {
    final statuses = [
      DriversFilterState.allStatuses,
      Driver.statusActive,
      Driver.statusInactive,
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
          items: statuses.map((status) {
            final label = status == DriversFilterState.allStatuses
                ? context.loc.allStatuses
                : context.loc.localizedStatus(status);
            return DropdownMenuItem(value: status, child: Text(label));
          }).toList(),
          onChanged: _onStatusChanged,
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return SizedBox(
      height: context.sizes.compactControlHeight,
      child: OutlinedButton(
        onPressed: _resetFilter,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.color.text.secondary,
          side: BorderSide(color: context.color.border),
          padding: EdgeInsets.symmetric(horizontal: context.spacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.radius.sm),
          ),
        ),
        child: Text(
          context.loc.clearFilters,
          style: context.textStyle.labelSmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Driver> drivers) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.0), // Name
        1: FlexColumnWidth(1.5), // Phone
        2: FlexColumnWidth(1.8), // License Number
        3: FlexColumnWidth(1.4), // License Expiry
        4: FlexColumnWidth(1.2), // Status
        5: FlexColumnWidth(2.2), // Assigned Vehicle
        6: FlexColumnWidth(1.2), // Actions
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Table Header
        TableRow(
          decoration: BoxDecoration(
            color: context.color.surfaceSubtle,
            border: Border(bottom: BorderSide(color: context.color.border)),
          ),
          children: [
            _tableHeader(context, context.loc.driverName),
            _tableHeader(context, context.loc.phone),
            _tableHeader(context, context.loc.licenseNumber),
            _tableHeader(context, context.loc.licenseExpiry),
            _tableHeader(context, context.loc.colStatus),
            _tableHeader(context, context.loc.assignedVehicle),
            _tableHeader(context, context.loc.colActions),
          ],
        ),

        // Data Rows
        for (final driver in drivers)
          TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.color.border)),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: context.color.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        driver.name.isNotEmpty
                            ? driver.name[0].toUpperCase()
                            : 'D',
                        style: context.textStyle.labelSmall.copyWith(
                          color: context.color.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: context.spacing.sm2),
                    Expanded(
                      child: Text(
                        driver.name,
                        style: context.textStyle.dataMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.color.text.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Text(
                  driver.phone,
                  style: context.textStyle.dataMedium.copyWith(
                    color: context.color.text.secondary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Text(
                  driver.licenseNumber,
                  style: context.textStyle.dataMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Text(
                  _formatDate(context, driver.licenseExpiry),
                  style: context.textStyle.dataSmall.copyWith(
                    color: context.color.text.secondary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: StatusChip(status: driver.status),
              ),
              Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: driver.assignedVehicle != null
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.sm2,
                          vertical: context.spacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: context.color.infoBg,
                          borderRadius: BorderRadius.circular(
                            context.radius.xs,
                          ),
                          border: Border.all(
                            color: context.color.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 14,
                              color: context.color.infoFg,
                            ),
                            SizedBox(width: context.spacing.xs),
                            Flexible(
                              child: Text(
                                driver.assignedVehicle!.vehicleNumber,
                                style: context.textStyle.dataSmall.copyWith(
                                  color: context.color.infoFg,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        context.loc.unassigned,
                        style: context.textStyle.dataSmall.copyWith(
                          color: context.color.text.tertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(context.spacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: context.sizes.iconSm,
                        color: context.color.primary,
                      ),
                      tooltip: context.loc.edit,
                      onPressed: () => _openDriverEdit(driver),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: context.sizes.iconSm,
                        color: context.color.error,
                      ),
                      tooltip: context.loc.delete,
                      onPressed: () => _handleDelete(driver),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMobileCardList(BuildContext context, List<Driver> drivers) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: drivers.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: context.color.border),
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      driver.name,
                      style: context.textStyle.headLineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusChip(status: driver.status),
                ],
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                '${context.loc.phone}: ${driver.phone}',
                style: context.textStyle.bodySmall.copyWith(
                  color: context.color.text.secondary,
                ),
              ),
              Text(
                '${context.loc.licenseNumber}: ${driver.licenseNumber} (${context.loc.licenseExpiry}: ${_formatDate(context, driver.licenseExpiry)})',
                style: context.textStyle.bodySmall.copyWith(
                  color: context.color.text.secondary,
                ),
              ),
              SizedBox(height: context.spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  driver.assignedVehicle != null
                      ? Text(
                          '${context.loc.assignedVehicle}: ${driver.assignedVehicle!.vehicleNumber}',
                          style: context.textStyle.dataSmall.copyWith(
                            color: context.color.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          context.loc.unassigned,
                          style: context.textStyle.dataSmall.copyWith(
                            color: context.color.text.tertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: context.sizes.iconSm,
                          color: context.color.primary,
                        ),
                        onPressed: () => _openDriverEdit(driver),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: context.sizes.iconSm,
                          color: context.color.error,
                        ),
                        onPressed: () => _handleDelete(driver),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationFooter(BuildContext context, DriversListState state) {
    final start = state.currentPage * 10 + 1;
    final end = (start + state.drivers.length - 1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.lg2,
        vertical: context.spacing.md2,
      ),
      decoration: BoxDecoration(
        color: context.color.surfaceSubtle,
        border: Border(top: BorderSide(color: context.color.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.loc.showingPagination(
              state.drivers.isNotEmpty ? start : 0,
              end,
              state.totalElements,
            ),
            style: context.textStyle.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: context.color.text.secondary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: state.currentPage > 0
                    ? () {
                        ref
                            .read(driversFilterProvider.notifier)
                            .setPage(state.currentPage - 1);
                        ref.read(driversProvider.notifier).fetchDrivers();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: context.loc.previousPage,
              ),
              Text(
                '${state.currentPage + 1} / ${state.totalPages > 0 ? state.totalPages : 1}',
                style: context.textStyle.dataSmall,
              ),
              IconButton(
                onPressed: state.currentPage + 1 < state.totalPages
                    ? () {
                        ref
                            .read(driversFilterProvider.notifier)
                            .setPage(state.currentPage + 1);
                        ref.read(driversProvider.notifier).fetchDrivers();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: context.loc.nextPage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.spacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: context.color.text.tertiary,
          ),
          SizedBox(height: context.spacing.md),
          Text(
            context.loc.noDriversFound,
            style: context.textStyle.headLineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            context.loc.tryAdjustingFilters,
            style: context.textStyle.bodySmall.copyWith(
              color: context.color.text.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.md2,
      ),
      child: Text(
        text,
        style: context.textStyle.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: context.color.text.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
