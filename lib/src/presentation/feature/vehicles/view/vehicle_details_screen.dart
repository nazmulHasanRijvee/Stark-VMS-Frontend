import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/utils/platform_file_helper.dart';
import '../../../../domain/entities/maintenance_record.dart';
import '../../../../domain/entities/vehicle_document.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/custom_loading_indicator.dart';
import '../../../core/widgets/status_chip.dart';
import '../../drivers/view_model/drivers_provider.dart';
import '../view_model/vehicles_provider.dart';
import '../view_model/vehicle_details_provider.dart';
import '../view_model/vehicle_documents_provider.dart';
import '../view_model/vehicle_maintenance_provider.dart';

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  final String vehicleNumber;

  const VehicleDetailsScreen({super.key, required this.vehicleNumber});

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _documentTypeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAssignDriverDialog(Vehicle vehicle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AssignDriverDialog(
        vehicleNumber: vehicle.vehicleNumber,
        currentDriver: vehicle.assignedDriver,
      ),
    );
  }

  Future<void> _handleUnassignDriver() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.loc.unassignDriver),
        content: Text(ctx.loc.unassignDriverConfirm),
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
            child: Text(ctx.loc.unassignDriver),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(vehicleDetailsProvider(widget.vehicleNumber).notifier)
          .unassignDriver();

      if (mounted) {
        if (success) {
          CustomToast.showSuccess(
            context,
            title: context.loc.driverUnassignedSuccess,
          );
        } else {
          final err = ref
              .read(vehicleDetailsProvider(widget.vehicleNumber))
              .assignmentError;
          CustomToast.showError(
            context,
            title: err == null
                ? context.loc.unassignDriverFailed
                : context.loc.localizedApiError(err),
          );
        }
      }
    }
  }

  void _openUploadDocumentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          _UploadDocumentDialog(vehicleNumber: widget.vehicleNumber),
    );
  }

  void _openAddMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          _AddMaintenanceDialog(vehicleNumber: widget.vehicleNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsState = ref.watch(
      vehicleDetailsProvider(widget.vehicleNumber),
    );
    final docsState = ref.watch(vehicleDocumentsProvider(widget.vehicleNumber));
    final mtnState = ref.watch(
      vehicleMaintenanceProvider(widget.vehicleNumber),
    );
    final vehicle = detailsState.vehicle;
    final docsCount = docsState.documents.length;
    final mtnCount = mtnState.records.length;
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
                // Back Button & Navigation
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go(Routes.vehicles.path),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(context.loc.backToVehicles),
                  ),
                ),
                SizedBox(height: context.spacing.sm),

                // Vehicle Header Card
                Container(
                  padding: EdgeInsets.all(context.spacing.xl),
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
                  child: Skeletonizer(
                    enabled: detailsState.isLoading && vehicle == null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    vehicle?.vehicleNumber ??
                                        widget.vehicleNumber,
                                    style: context.textStyle.headLineLarge
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  SizedBox(width: context.spacing.md),
                                  StatusChip(
                                    status:
                                        vehicle?.status ?? Vehicle.statusActive,
                                  ),
                                ],
                              ),
                              SizedBox(height: context.spacing.xs),
                              Text(
                                '${vehicle?.brand ?? ''} ${vehicle?.model ?? ''} • ${vehicle?.company ?? ''} (${vehicle?.type ?? ''})',
                                style: context.textStyle.bodyMedium.copyWith(
                                  color: context.color.text.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            final editPath = Routes.vehicleEdit.path
                                .replaceFirst(
                                  ':vehicleNumber',
                                  Uri.encodeComponent(widget.vehicleNumber),
                                );
                            context.go(editPath);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(context.loc.edit),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.color.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.radius.sm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: context.spacing.lg),

                // Tabs Header
                Container(
                  decoration: BoxDecoration(
                    color: context.color.surface,
                    borderRadius: BorderRadius.circular(context.radius.md),
                    border: Border.all(color: context.color.border),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: context.color.primary,
                    unselectedLabelColor: context.color.text.secondary,
                    indicatorColor: context.color.primary,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.info_outline, size: 20),
                        text: context.loc.tabOverview,
                      ),
                      Tab(
                        icon: const Icon(Icons.description_outlined, size: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.loc.tabDocuments),
                            if (docsCount > 0) ...[
                              SizedBox(width: context.spacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.color.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(
                                    context.radius.pill,
                                  ),
                                ),
                                child: Text(
                                  '$docsCount',
                                  style: context.textStyle.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        icon: const Icon(Icons.build_outlined, size: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.loc.tabMaintenance),
                            if (mtnCount > 0) ...[
                              SizedBox(width: context.spacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.color.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(
                                    context.radius.pill,
                                  ),
                                ),
                                child: Text(
                                  '$mtnCount',
                                  style: context.textStyle.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing.lg),

                // Tab Content Body
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    switch (_tabController.index) {
                      case 0:
                        return _buildOverviewTab(context, vehicle);
                      case 1:
                        return _buildDocumentsTab(context);
                      case 2:
                        return _buildMaintenanceTab(context);
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Tab 1: Overview
  // ===========================================================================
  Widget _buildOverviewTab(BuildContext context, Vehicle? vehicle) {
    if (vehicle == null) return const SizedBox.shrink();

    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildSpecificationsCard(context, vehicle),
              ),
              SizedBox(width: context.spacing.lg),
              Expanded(
                flex: 2,
                child: _buildDriverAssignmentCard(context, vehicle),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildSpecificationsCard(context, vehicle),
              SizedBox(height: context.spacing.lg),
              _buildDriverAssignmentCard(context, vehicle),
            ],
          ),
      ],
    );
  }

  Widget _buildSpecificationsCard(BuildContext context, Vehicle vehicle) {
    return Container(
      padding: EdgeInsets.all(context.spacing.xl),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(context.radius.md),
        border: Border.all(color: context.color.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.vehicleSpecifications,
            style: context.textStyle.headLineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.spacing.lg),
          _specRow(
            context,
            context.loc.colVehicleNumber,
            vehicle.vehicleNumber,
          ),
          _specRow(context, context.loc.colCompany, vehicle.company),
          _specRow(context, context.loc.colType, vehicle.type),
          _specRow(context, context.loc.colBrand, vehicle.brand),
          _specRow(context, context.loc.colModel, vehicle.model),
          _specRow(
            context,
            context.loc.colStatus,
            context.loc.localizedStatus(vehicle.status),
          ),
        ],
      ),
    );
  }

  Widget _specRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyle.bodyMedium.copyWith(
              color: context.color.text.secondary,
            ),
          ),
          Text(
            value,
            style: context.textStyle.dataMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverAssignmentCard(BuildContext context, Vehicle vehicle) {
    final driver = vehicle.assignedDriver;

    return Container(
      padding: EdgeInsets.all(context.spacing.xl),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(context.radius.md),
        border: Border.all(color: context.color.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.loc.assignedDriverCard,
                style: context.textStyle.headLineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.person_pin_outlined,
                color: context.color.primary,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: context.spacing.lg),
          if (driver != null) ...[
            Container(
              padding: EdgeInsets.all(context.spacing.md),
              decoration: BoxDecoration(
                color: context.color.surfaceSubtle,
                borderRadius: BorderRadius.circular(context.radius.sm),
                border: Border.all(color: context.color.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.color.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      driver.name.isNotEmpty
                          ? driver.name[0].toUpperCase()
                          : 'D',
                      style: context.textStyle.labelMedium.copyWith(
                        color: context.color.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: context.textStyle.dataMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: context.spacing.xxs),
                        Text(
                          driver.phone,
                          style: context.textStyle.bodySmall.copyWith(
                            color: context.color.text.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openAssignDriverDialog(vehicle),
                    child: Text(context.loc.changeDriver),
                  ),
                ),
                SizedBox(width: context.spacing.md),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.color.errorBg,
                      foregroundColor: context.color.error,
                      elevation: 0,
                    ),
                    onPressed: _handleUnassignDriver,
                    child: Text(context.loc.unassignDriver),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              context.loc.noDriverAssigned,
              style: context.textStyle.bodyMedium.copyWith(
                color: context.color.text.tertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: context.spacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openAssignDriverDialog(vehicle),
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: Text(context.loc.assignDriver),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.primary,
                  foregroundColor: context.color.onPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // Tab 2: Documents
  // ===========================================================================
  Widget _buildDocumentsTab(BuildContext context) {
    final docsState = ref.watch(vehicleDocumentsProvider(widget.vehicleNumber));
    final docs = docsState.documents;

    return Container(
      padding: EdgeInsets.all(context.spacing.xl),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(context.radius.md),
        border: Border.all(color: context.color.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Upload Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.loc.documentHistory,
                style: context.textStyle.headLineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Container(
                    height: context.sizes.compactControlHeight,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: context.color.textFieldFillColor,
                      borderRadius: BorderRadius.circular(context.radius.sm),
                      border: Border.all(color: context.color.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _documentTypeFilter,
                        dropdownColor: context.color.surface,
                        style: context.textStyle.dataMedium.copyWith(
                          color: context.color.text.primary,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(context.loc.allTypes),
                          ),
                          DropdownMenuItem(
                            value: VehicleDocument.typeRegistration,
                            child: Text(context.loc.docRegistration),
                          ),
                          DropdownMenuItem(
                            value: VehicleDocument.typeTaxToken,
                            child: Text(context.loc.docTaxToken),
                          ),
                          DropdownMenuItem(
                            value: VehicleDocument.typeInsurance,
                            child: Text(context.loc.docInsurance),
                          ),
                          DropdownMenuItem(
                            value: VehicleDocument.typeFitnessCertificate,
                            child: Text(context.loc.docFitness),
                          ),
                          DropdownMenuItem(
                            value: VehicleDocument.typeOther,
                            child: Text(context.loc.docOther),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _documentTypeFilter = val);
                            ref
                                .read(
                                  vehicleDocumentsProvider(widget.vehicleNumber)
                                      .notifier,
                                )
                                .setTypeFilter(val == 'all' ? null : val);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  ElevatedButton.icon(
                    onPressed: _openUploadDocumentDialog,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(context.loc.uploadDocument),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.color.primary,
                      foregroundColor: context.color.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.spacing.lg),

          Skeletonizer(
            enabled: docsState.isLoading && docs.isNotEmpty,
            child: docs.isEmpty && docsState.isLoading
                ? const SizedBox(height: 72, child: CustomLoadingIndicator())
                : docs.isEmpty && docsState.errorMessage != null
                ? Padding(
                    padding: EdgeInsets.all(context.spacing.xl2),
                    child: Column(
                      children: [
                        Text(
                          context.loc.localizedApiError(
                            docsState.errorMessage!,
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(
                                vehicleDocumentsProvider(widget.vehicleNumber)
                                    .notifier,
                              )
                              .loadDocuments(),
                          child: Text(context.loc.retry),
                        ),
                      ],
                    ),
                  )
                : docs.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(context.spacing.xl2),
                    child: Center(
                      child: Text(
                        context.loc.noDocumentsYet,
                        style: context.textStyle.bodyMedium.copyWith(
                          color: context.color.text.tertiary,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: context.color.border),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return _buildDocumentRow(context, doc);
                    },
                  ),
          ),
          if (docsState.currentPage + 1 < docsState.totalPages)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: docsState.isLoadingMore
                    ? null
                    : () => ref
                          .read(
                            vehicleDocumentsProvider(widget.vehicleNumber)
                                .notifier,
                          )
                          .loadDocuments(loadMore: true),
                icon: docsState.isLoadingMore
                    ? SizedBox(
                        width: context.sizes.iconSm,
                        height: context.sizes.iconSm,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more),
                label: Text(context.loc.loadMore),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, VehicleDocument doc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.md),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacing.sm2),
            decoration: BoxDecoration(
              color: context.color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.radius.sm),
            ),
            child: Icon(
              Icons.description,
              color: context.color.primary,
              size: 24,
            ),
          ),
          SizedBox(width: context.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.loc.localizedDocumentType(doc.documentType),
                      style: context.textStyle.dataMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (doc.latest) ...[
                      SizedBox(width: context.spacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.color.successBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          context.loc.latest,
                          style: context.textStyle.labelSmall.copyWith(
                            color: context.color.successFg,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: context.spacing.xxs),
                Text(
                  '${doc.filename} • ${doc.formattedSize} • ${_formatDate(context, doc.uploadedAt)}',
                  style: context.textStyle.bodySmall.copyWith(
                    color: context.color.text.secondary,
                  ),
                ),
                if (doc.expiryDate != null)
                  Text(
                    '${context.loc.expiryDate}: ${_formatDate(context, doc.expiryDate!)}',
                    style: context.textStyle.bodySmall.copyWith(
                      color: context.color.text.tertiary,
                    ),
                  ),
              ],
            ),
          ),
          _buildExpiryStateChip(context, doc.expiryState),
          SizedBox(width: context.spacing.md),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: context.loc.download,
            onPressed: () async {
              final url = await ref
                  .read(vehicleDocumentsProvider(widget.vehicleNumber).notifier)
                  .getDownloadUrl(doc.id);
              if (url != null && url.isNotEmpty) {
                PlatformFileHelper.openUrl(url);
              } else {
                if (context.mounted) {
                  CustomToast.showError(
                    context,
                    title: context.loc.downloadLinkFailed,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryStateChip(BuildContext context, String expiryState) {
    Color bg;
    Color fg;
    String label;

    switch (expiryState) {
      case VehicleDocument.expiryValid:
        bg = context.color.successBg;
        fg = context.color.successFg;
        label = context.loc.statusValid;
        break;
      case VehicleDocument.expiryExpiringSoon:
        bg = context.color.warningBg;
        fg = context.color.warningFg;
        label = context.loc.statusExpiringSoon;
        break;
      case VehicleDocument.expiryExpired:
        bg = context.color.errorBg;
        fg = context.color.errorFg;
        label = context.loc.statusExpired;
        break;
      case VehicleDocument.expiryNoExpiryDate:
      default:
        bg = context.color.surfaceSubtle;
        fg = context.color.text.secondary;
        label = context.loc.statusNoExpiry;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm2,
        vertical: context.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.radius.pill),
      ),
      child: Text(
        label,
        style: context.textStyle.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, String value) {
    final date = DateTime.tryParse(value);
    return date == null
        ? value
        : MaterialLocalizations.of(context).formatMediumDate(date);
  }

  // ===========================================================================
  // Tab 3: Maintenance
  // ===========================================================================
  Widget _buildMaintenanceTab(BuildContext context) {
    final mtnState = ref.watch(
      vehicleMaintenanceProvider(widget.vehicleNumber),
    );
    final records = mtnState.records;

    final totalSpend = records.fold<double>(0.0, (sum, r) => sum + r.cost);
    final totalCount = records.length;

    final now = DateTime.now();
    final currentMonthRecords = records.where((r) {
      final date = DateTime.tryParse(r.maintenanceDate);
      if (date == null) return false;
      return date.year == now.year && date.month == now.month;
    }).toList();
    final currentMonthSpend = currentMonthRecords.fold<double>(
      0.0,
      (sum, r) => sum + r.cost,
    );
    final currentMonthCount = currentMonthRecords.length;

    return Column(
      children: [
        // 2 KPI Summary Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(context.spacing.lg),
                decoration: BoxDecoration(
                  color: context.color.surface,
                  borderRadius: BorderRadius.circular(context.radius.md),
                  border: Border.all(color: context.color.border),
                  boxShadow: [
                    BoxShadow(
                      color: context.color.text.primary.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.spacing.md),
                      decoration: BoxDecoration(
                        color: context.color.surfaceSubtle,
                        borderRadius: BorderRadius.circular(context.radius.sm),
                      ),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: context.color.primary,
                        size: context.sizes.iconMd,
                      ),
                    ),
                    SizedBox(width: context.spacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.maintenanceThisMonth,
                            style: context.textStyle.labelSmall.copyWith(
                              color: context.color.text.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: context.spacing.xxs),
                          Row(
                            children: [
                              Text(
                                '৳${currentMonthSpend.toStringAsFixed(0)}',
                                style: context.textStyle.headLineSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.color.text.primary,
                                ),
                              ),
                              Text(
                                ' • $currentMonthCount ${context.loc.maintenanceRecordsCount}',
                                style: context.textStyle.bodySmall.copyWith(
                                  color: context.color.text.secondary,
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
            ),
            SizedBox(width: context.spacing.lg),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(context.spacing.lg),
                decoration: BoxDecoration(
                  color: context.color.surface,
                  borderRadius: BorderRadius.circular(context.radius.md),
                  border: Border.all(color: context.color.border),
                  boxShadow: [
                    BoxShadow(
                      color: context.color.text.primary.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.spacing.md),
                      decoration: BoxDecoration(
                        color: context.color.surfaceSubtle,
                        borderRadius: BorderRadius.circular(context.radius.sm),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: context.color.primary,
                        size: context.sizes.iconMd,
                      ),
                    ),
                    SizedBox(width: context.spacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.allTimeMaintenanceSpend,
                            style: context.textStyle.labelSmall.copyWith(
                              color: context.color.text.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: context.spacing.xxs),
                          Row(
                            children: [
                              Text(
                                '৳${totalSpend.toStringAsFixed(0)}',
                                style: context.textStyle.headLineSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.color.text.primary,
                                ),
                              ),
                              Text(
                                ' • $totalCount ${context.loc.maintenanceRecordsCount}',
                                style: context.textStyle.bodySmall.copyWith(
                                  color: context.color.text.secondary,
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
            ),
          ],
        ),
        SizedBox(height: context.spacing.lg),

        Container(
          padding: EdgeInsets.all(context.spacing.xl),
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(context.radius.md),
            border: Border.all(color: context.color.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.loc.maintenanceHistory,
                    style: context.textStyle.headLineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddMaintenanceDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.loc.addMaintenanceRecord),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.color.primary,
                      foregroundColor: context.color.onPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.lg),

              Skeletonizer(
                enabled: mtnState.isLoading && records.isNotEmpty,
                child: records.isEmpty && mtnState.isLoading
                    ? const SizedBox(
                        height: 72,
                        child: CustomLoadingIndicator(),
                      )
                    : records.isEmpty && mtnState.errorMessage != null
                    ? Padding(
                        padding: EdgeInsets.all(context.spacing.xl2),
                        child: Column(
                          children: [
                            Text(
                              context.loc.localizedApiError(
                                mtnState.errorMessage!,
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref
                                  .read(
                                    vehicleMaintenanceProvider(
                                      widget.vehicleNumber,
                                    ).notifier,
                                  )
                                  .loadRecords(),
                              child: Text(context.loc.retry),
                            ),
                          ],
                        ),
                      )
                    : records.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(context.spacing.xl2),
                        child: Center(
                          child: Text(
                            context.loc.noMaintenanceYet,
                            style: context.textStyle.bodyMedium.copyWith(
                              color: context.color.text.tertiary,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length,
                        separatorBuilder: (_, _) =>
                            Divider(height: 1, color: context.color.border),
                        itemBuilder: (context, index) {
                          final rec = records[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: context.spacing.md,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(context.spacing.sm2),
                                  decoration: BoxDecoration(
                                    color: context.color.warningBg,
                                    borderRadius: BorderRadius.circular(
                                      context.radius.sm,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.build,
                                    color: context.color.warningFg,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: context.spacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            context.loc
                                                .localizedMaintenanceType(
                                                  rec.maintenanceType,
                                                ),
                                            style: context.textStyle.dataMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            '৳${rec.cost.toStringAsFixed(2)}',
                                            style: context.textStyle.dataMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: context.color.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: context.spacing.xxs),
                                      Text(
                                        '${_formatDate(context, rec.maintenanceDate)} • ${rec.workshop}',
                                        style: context.textStyle.bodySmall
                                            .copyWith(
                                              color:
                                                  context.color.text.secondary,
                                            ),
                                      ),
                                      if (rec.notes != null &&
                                          rec.notes!.isNotEmpty) ...[
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          rec.notes!,
                                          style: context.textStyle.bodySmall
                                              .copyWith(
                                                color: context
                                                    .color
                                                    .text
                                                    .secondary,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Dialog: Assign / Change Driver
// =============================================================================
class _AssignDriverDialog extends ConsumerStatefulWidget {
  final String vehicleNumber;
  final AssignedDriver? currentDriver;

  const _AssignDriverDialog({required this.vehicleNumber, this.currentDriver});

  @override
  ConsumerState<_AssignDriverDialog> createState() =>
      _AssignDriverDialogState();
}

class _AssignDriverDialogState extends ConsumerState<_AssignDriverDialog> {
  List<Driver> _availableDrivers = [];
  bool _isLoading = true;
  int? _selectedDriverId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableDrivers();
  }

  Future<void> _loadAvailableDrivers() async {
    final drivers = await ref
        .read(driversProvider.notifier)
        .getAvailableActiveDrivers();
    if (mounted) {
      setState(() {
        _availableDrivers = drivers;
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedDriverId == null) return;
    setState(() => _isSubmitting = true);

    final success = await ref
        .read(vehicleDetailsProvider(widget.vehicleNumber).notifier)
        .assignDriver(_selectedDriverId!);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        CustomToast.showSuccess(
          context,
          title: context.loc.driverAssignedSuccess,
        );
        Navigator.of(context).pop();
      } else {
        final err = ref
            .read(vehicleDetailsProvider(widget.vehicleNumber))
            .assignmentError;
        CustomToast.showError(
          context,
          title: err == null
              ? context.loc.assignDriverFailed
              : context.loc.localizedApiError(err),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.loc.selectDriver,
                    style: context.textStyle.headLineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.lg),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableDrivers.isEmpty)
                Padding(
                  padding: EdgeInsets.all(context.spacing.lg),
                  child: Text(
                    context.loc.noAvailableDrivers,
                    style: context.textStyle.bodyMedium.copyWith(
                      color: context.color.text.secondary,
                    ),
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _selectedDriverId,
                  decoration: InputDecoration(
                    labelText: context.loc.driverName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                  items: _availableDrivers.map((d) {
                    return DropdownMenuItem<int>(
                      value: d.id,
                      child: Text('${d.name} (${d.phone})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDriverId = val),
                ),

              SizedBox(height: context.spacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.loc.cancel),
                  ),
                  SizedBox(width: context.spacing.md),
                  ElevatedButton(
                    onPressed: _selectedDriverId == null || _isSubmitting
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.color.primary,
                      foregroundColor: context.color.onPrimary,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.loc.assignDriver),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Dialog: Upload Document
// =============================================================================
class _UploadDocumentDialog extends ConsumerStatefulWidget {
  final String vehicleNumber;

  const _UploadDocumentDialog({required this.vehicleNumber});

  @override
  ConsumerState<_UploadDocumentDialog> createState() =>
      _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends ConsumerState<_UploadDocumentDialog> {
  static const _maxFileBytes = 10 * 1024 * 1024;
  final _formKey = GlobalKey<FormState>();
  String _documentType = VehicleDocument.typeRegistration;
  final _expiryDateController = TextEditingController();
  String? _selectedFilename;
  List<int>? _selectedBytes;
  bool _isUploading = false;

  @override
  void dispose() {
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null || !mounted) return;

      final extension = file.extension?.toLowerCase();
      if (!const {'pdf', 'jpg', 'jpeg', 'png'}.contains(extension)) {
        CustomToast.showError(
          context,
          title: context.loc.unsupportedDocumentType,
        );
        return;
      }

      final size = await file.length();
      if (!mounted) return;
      if (size == null) {
        CustomToast.showError(
          context,
          title: context.loc.cannotReadSelectedFile,
        );
        return;
      }
      if (size > _maxFileBytes) {
        CustomToast.showError(context, title: context.loc.documentFileTooLarge);
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedFilename = file.name;
        _selectedBytes = bytes;
      });
    } catch (_) {
      if (mounted) {
        CustomToast.showError(
          context,
          title: context.loc.cannotReadSelectedFile,
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _expiryDateController.text = '$y-$m-$d';
    }
  }

  Future<void> _submit() async {
    if (_selectedBytes == null || _selectedFilename == null) {
      CustomToast.showError(context, title: context.loc.selectDocumentFirst);
      return;
    }

    setState(() => _isUploading = true);

    final success = await ref
        .read(vehicleDocumentsProvider(widget.vehicleNumber).notifier)
        .uploadDocument(
          fileBytes: _selectedBytes!,
          filename: _selectedFilename!,
          documentType: _documentType,
          expiryDate: _expiryDateController.text.trim().isNotEmpty
              ? _expiryDateController.text.trim()
              : null,
        );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        CustomToast.showSuccess(context, title: context.loc.uploadSuccess);
        ref.read(dashboardStatsProvider.notifier).refresh();
        Navigator.of(context).pop();
      } else {
        final err = ref
            .read(vehicleDocumentsProvider(widget.vehicleNumber))
            .errorMessage;
        CustomToast.showError(
          context,
          title: err == null
              ? context.loc.apiRequestFailed
              : context.loc.localizedApiError(err),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl2),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.loc.uploadDocument,
                      style: context.textStyle.headLineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.lg),

                // File Picker Row
                Container(
                  padding: EdgeInsets.all(context.spacing.md),
                  decoration: BoxDecoration(
                    color: context.color.surfaceSubtle,
                    borderRadius: BorderRadius.circular(context.radius.sm),
                    border: Border.all(color: context.color.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, color: context.color.primary),
                      SizedBox(width: context.spacing.sm),
                      Expanded(
                        child: Text(
                          _selectedFilename != null
                              ? context.loc.fileSelected(_selectedFilename!)
                              : context.loc.acceptedDocumentTypes,
                          style: context.textStyle.bodySmall.copyWith(
                            color: _selectedFilename != null
                                ? context.color.text.primary
                                : context.color.text.tertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickFile,
                        child: Text(context.loc.selectFile),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing.md),

                // Document Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _documentType,
                  decoration: InputDecoration(
                    labelText: context.loc.documentType,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                  items: VehicleDocument.allowedDocumentTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _documentType = val);
                  },
                ),
                SizedBox(height: context.spacing.md),

                // Expiry Date (Optional)
                TextFormField(
                  controller: _expiryDateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText:
                        '${context.loc.expiryDate} (${context.loc.optional})',
                    hintText: context.loc.isoDateFormat,
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.loc.cancel),
                    ),
                    SizedBox(width: context.spacing.md),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.primary,
                        foregroundColor: context.color.onPrimary,
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.loc.uploadDocument),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Dialog: Add Maintenance Record
// =============================================================================
class _AddMaintenanceDialog extends ConsumerStatefulWidget {
  final String vehicleNumber;

  const _AddMaintenanceDialog({required this.vehicleNumber});

  @override
  ConsumerState<_AddMaintenanceDialog> createState() =>
      _AddMaintenanceDialogState();
}

class _AddMaintenanceDialogState extends ConsumerState<_AddMaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _costController = TextEditingController();
  final _workshopController = TextEditingController();
  final _notesController = TextEditingController();
  String _maintenanceType = 'Scheduled Service';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _costController.dispose();
    _workshopController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 3)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _dateController.text = '$y-$m-$d';
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final costVal = double.tryParse(_costController.text.trim()) ?? 0.0;
    final record = MaintenanceRecord(
      maintenanceDate: _dateController.text.trim(),
      maintenanceType: _maintenanceType,
      cost: costVal,
      workshop: _workshopController.text.trim(),
      notes: _notesController.text.trim(),
    );

    final success = await ref
        .read(vehicleMaintenanceProvider(widget.vehicleNumber).notifier)
        .addRecord(record);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        CustomToast.showSuccess(
          context,
          title: context.loc.maintenanceAddedSuccess,
        );
        ref.read(dashboardStatsProvider.notifier).refresh();
        Navigator.of(context).pop();
      } else {
        final err = ref
            .read(vehicleMaintenanceProvider(widget.vehicleNumber))
            .errorMessage;
        CustomToast.showError(
          context,
          title: err == null
              ? context.loc.addMaintenanceFailed
              : context.loc.localizedApiError(err),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl2),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.loc.addMaintenanceRecord,
                      style: context.textStyle.headLineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.lg),

                // Date Picker
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: context.loc.maintenanceDate,
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.md),

                // Maintenance Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _maintenanceType,
                  decoration: InputDecoration(
                    labelText: context.loc.maintenanceType,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                  items: MaintenanceRecord.commonMaintenanceTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            context.loc.localizedMaintenanceType(type),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _maintenanceType = val);
                  },
                ),
                SizedBox(height: context.spacing.md),

                // Cost Field
                TextFormField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.loc.cost,
                    hintText: context.loc.costHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return context.loc.costRequired;
                    }
                    final amount = double.tryParse(val.trim());
                    if (amount == null || !amount.isFinite || amount < 0) {
                      return context.loc.costInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.spacing.md),

                // Workshop
                TextFormField(
                  controller: _workshopController,
                  decoration: InputDecoration(
                    labelText: context.loc.workshop,
                    hintText: context.loc.workshopHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? context.loc.workshopRequired
                      : null,
                ),
                SizedBox(height: context.spacing.md),

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.loc.notes,
                    hintText: context.loc.maintenanceNotesHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.sm),
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.loc.cancel),
                    ),
                    SizedBox(width: context.spacing.md),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.primary,
                        foregroundColor: context.color.onPrimary,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.loc.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
