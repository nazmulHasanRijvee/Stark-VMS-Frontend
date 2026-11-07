import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../view_model/vehicles_provider.dart';

enum VehicleFormMode { register, edit }

/// Unified, responsive Register & Edit Vehicle form matching the Stitch design.
///
/// Fully theme-aware (Light & Dark) and localized (English & Bangla)
/// without hardcoded colors or styles.
class VehicleFormScreen extends ConsumerStatefulWidget {
  final VehicleFormMode mode;
  final String? initialVehicleNumber;

  const VehicleFormScreen({
    super.key,
    required this.mode,
    this.initialVehicleNumber,
  });

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _companyController;
  late final TextEditingController _typeController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;

  String _selectedStatus = Vehicle.statusActive;
  String? _duplicateError;

  @override
  void initState() {
    super.initState();

    Vehicle? existingVehicle;
    if (widget.mode == VehicleFormMode.edit && widget.initialVehicleNumber != null) {
      existingVehicle = ref
          .read(vehiclesProvider.notifier)
          .getVehicle(widget.initialVehicleNumber!);
    }

    _vehicleNumberController = TextEditingController(
      text: existingVehicle?.vehicleNumber ?? '',
    );
    _companyController = TextEditingController(
      text: existingVehicle?.company ?? '',
    );
    _typeController = TextEditingController(
      text: existingVehicle?.type ?? '',
    );
    _brandController = TextEditingController(
      text: existingVehicle?.brand ?? '',
    );
    _modelController = TextEditingController(
      text: existingVehicle?.model ?? '',
    );
    _selectedStatus = existingVehicle?.status ?? Vehicle.statusActive;

    _vehicleNumberController.addListener(_onVehicleNumberChanged);
  }

  @override
  void dispose() {
    _vehicleNumberController.removeListener(_onVehicleNumberChanged);
    _vehicleNumberController.dispose();
    _companyController.dispose();
    _typeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onVehicleNumberChanged() {
    final value = _vehicleNumberController.text.trim();
    if (value.isEmpty) {
      if (_duplicateError != null) setState(() => _duplicateError = null);
      return;
    }

    final isDuplicate = ref.read(vehiclesProvider.notifier).isDuplicate(
          value,
          excludeVehicleNumber: widget.mode == VehicleFormMode.edit
              ? widget.initialVehicleNumber
              : null,
        );

    final error = isDuplicate ? context.loc.duplicateVehicleNumber : null;
    if (error != _duplicateError) {
      setState(() => _duplicateError = error);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_duplicateError != null) return;

    final vehicle = Vehicle(
      vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
      company: _companyController.text.trim(),
      type: _typeController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      status: _selectedStatus,
    );

    String? error;
    if (widget.mode == VehicleFormMode.register) {
      error = ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    } else {
      error = ref.read(vehiclesProvider.notifier).updateVehicle(
            widget.initialVehicleNumber ?? vehicle.vehicleNumber,
            vehicle,
          );
    }

    if (error != null) {
      setState(() => _duplicateError = context.loc.duplicateVehicleNumber);
      return;
    }

    CustomToast.showSuccess(
      context,
      title: widget.mode == VehicleFormMode.register
          ? context.loc.vehicleRegisteredSuccess
          : context.loc.vehicleUpdatedSuccess,
      description: 'Vehicle ${vehicle.vehicleNumber} successfully saved.',
    );

    context.go(Routes.vehicles.path);
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String hintText,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: context.textStyle.bodyMedium.copyWith(
        color: context.color.text.tertiary,
      ),
      filled: true,
      fillColor: context.color.textFieldFillColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.spacing.md2,
        vertical: context.spacing.md,
      ),
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(color: context.color.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(
          color: errorText != null ? context.color.error : context.color.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(
          color: context.color.primary,
          width: context.sizes.focusStrokeWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(color: context.color.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(
          color: context.color.error,
          width: context.sizes.focusStrokeWidth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == VehicleFormMode.edit;
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
              maxWidth: context.sizes.vehicleFormMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Page Header with Back button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: context.color.text.primary,
                      ),
                      onPressed: () => context.go(Routes.vehicles.path),
                      tooltip: context.loc.backToVehicles,
                    ),
                    SizedBox(width: context.spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? context.loc.editVehicleTitle
                                : context.loc.registerVehicleTitle,
                            style: context.textStyle.headLineLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: context.color.text.primary,
                            ),
                          ),
                          SizedBox(height: context.spacing.xs),
                          Text(
                            isEdit
                                ? context.loc.editVehicleSubtitle
                                : context.loc.registerVehicleSubtitle,
                            style: context.textStyle.bodyMedium.copyWith(
                              color: context.color.text.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.spacing.xl),

                // Form Container
                Container(
                  padding: EdgeInsets.all(
                    screenWidth < 600 ? context.spacing.lg : context.spacing.xxl,
                  ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Responsive 2-column or 1-column layout
                        if (screenWidth >= 640)
                          _buildTwoColumnFields(context)
                        else
                          _buildOneColumnFields(context),

                        SizedBox(height: context.spacing.xxl),

                        Divider(
                          height: context.sizes.hairlineWidth,
                          color: context.color.border,
                        ),

                        SizedBox(height: context.spacing.lg),

                        // Form Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go(Routes.vehicles.path),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spacing.lg,
                                  vertical: context.spacing.md,
                                ),
                                side: BorderSide(color: context.color.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    context.radius.sm,
                                  ),
                                ),
                              ),
                              child: Text(
                                context.loc.cancel,
                                style: context.textStyle.labelMedium.copyWith(
                                  color: context.color.text.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: context.spacing.md),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.color.primary,
                                foregroundColor: context.color.onPrimary,
                                elevation: 1,
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spacing.xl,
                                  vertical: context.spacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    context.radius.sm,
                                  ),
                                ),
                              ),
                              child: Text(
                                isEdit
                                    ? context.loc.updateVehicleButton
                                    : context.loc.saveVehicleButton,
                                style: context.textStyle.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.color.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildTwoColumnFields(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildVehicleNumberField(context)),
            SizedBox(width: context.spacing.lg2),
            Expanded(child: _buildCompanyField(context)),
          ],
        ),
        SizedBox(height: context.spacing.lg2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTypeField(context)),
            SizedBox(width: context.spacing.lg2),
            Expanded(child: _buildBrandField(context)),
          ],
        ),
        SizedBox(height: context.spacing.lg2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildModelField(context)),
            SizedBox(width: context.spacing.lg2),
            Expanded(child: _buildStatusField(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildOneColumnFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildVehicleNumberField(context),
        SizedBox(height: context.spacing.lg),
        _buildCompanyField(context),
        SizedBox(height: context.spacing.lg),
        _buildTypeField(context),
        SizedBox(height: context.spacing.lg),
        _buildBrandField(context),
        SizedBox(height: context.spacing.lg),
        _buildModelField(context),
        SizedBox(height: context.spacing.lg),
        _buildStatusField(context),
      ],
    );
  }

  Widget _buildVehicleNumberField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.vehicleNumberLabel,
          style: context.textStyle.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.color.text.primary,
          ),
        ),
        SizedBox(height: context.spacing.sm2),
        TextFormField(
          controller: _vehicleNumberController,
          textCapitalization: TextCapitalization.characters,
          style: context.textStyle.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.color.text.primary,
          ),
          decoration: _buildInputDecoration(
            context: context,
            hintText: context.loc.vehicleNumberHint,
            errorText: _duplicateError,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.loc.vehicleNumberRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCompanyField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.companyLabel,
          style: context.textStyle.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.color.text.primary,
          ),
        ),
        SizedBox(height: context.spacing.sm2),
        TextFormField(
          controller: _companyController,
          style: context.textStyle.bodyMedium.copyWith(
            color: context.color.text.primary,
          ),
          decoration: _buildInputDecoration(
            context: context,
            hintText: context.loc.companyHint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.loc.companyRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.typeLabel,
          style: context.textStyle.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.color.text.primary,
          ),
        ),
        SizedBox(height: context.spacing.sm2),
        TextFormField(
          controller: _typeController,
          style: context.textStyle.bodyMedium.copyWith(
            color: context.color.text.primary,
          ),
          decoration: _buildInputDecoration(
            context: context,
            hintText: context.loc.typeHint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.loc.typeRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBrandField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.brandLabel,
          style: context.textStyle.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.color.text.primary,
          ),
        ),
        SizedBox(height: context.spacing.sm2),
        TextFormField(
          controller: _brandController,
          style: context.textStyle.bodyMedium.copyWith(
            color: context.color.text.primary,
          ),
          decoration: _buildInputDecoration(
            context: context,
            hintText: context.loc.brandHint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.loc.brandRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModelField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.modelLabel,
          style: context.textStyle.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.color.text.primary,
          ),
        ),
        SizedBox(height: context.spacing.sm2),
        TextFormField(
          controller: _modelController,
          style: context.textStyle.bodyMedium.copyWith(
            color: context.color.text.primary,
          ),
          decoration: _buildInputDecoration(
            context: context,
            hintText: context.loc.modelHint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.loc.modelRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.statusLabel,
          style: context.textStyle.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.color.text.primary,
          ),
        ),
        SizedBox(height: context.spacing.sm2),
        Container(
          height: context.sizes.lg,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md2),
          decoration: BoxDecoration(
            color: context.color.textFieldFillColor,
            borderRadius: BorderRadius.circular(context.radius.sm),
            border: Border.all(color: context.color.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              dropdownColor: context.color.surface,
              icon: Icon(
                Icons.expand_more,
                color: context.color.icon,
                size: context.sizes.iconSm,
              ),
              style: context.textStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: context.color.text.primary,
              ),
              items: Vehicle.allowedStatuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(context.loc.localizedStatus(status)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedStatus = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
