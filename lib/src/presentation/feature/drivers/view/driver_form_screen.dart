import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/custom_loading_indicator.dart';
import '../../../core/widgets/custom_toast.dart';
import '../view_model/drivers_provider.dart';

class DriverFormScreen extends ConsumerWidget {
  final int? driverId;
  final bool invalidDriverId;

  const DriverFormScreen({
    super.key,
    this.driverId,
    this.invalidDriverId = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = driverId != null || invalidDriverId;
    final title = isEdit ? context.loc.editDriver : context.loc.addDriver;
    late final Widget formBody;

    if (invalidDriverId) {
      formBody = _DriverLoadMessage(
        message: context.loc.noDriversFound,
        onRetry: () => context.go(Routes.drivers.path),
      );
    } else if (driverId == null) {
      formBody = const _DriverEditor();
    } else {
      final driverAsync = ref.watch(driverDetailsProvider(driverId!));
      formBody = driverAsync.when(
        loading: () =>
            const SizedBox(height: 240, child: CustomLoadingIndicator()),
        error: (error, _) => _DriverLoadMessage(
          message: context.loc.localizedApiError(error.toString()),
          onRetry: () => ref.invalidate(driverDetailsProvider(driverId!)),
        ),
        data: (driver) => driver == null
            ? _DriverLoadMessage(
                message: context.loc.noDriversFound,
                onRetry: () => context.go(Routes.drivers.path),
              )
            : _DriverEditor(
                key: ValueKey('driver_form_${driver.id}'),
                driver: driver,
              ),
      );
    }

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
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go(Routes.drivers.path),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(context.loc.driversTitle),
                  ),
                ),
                SizedBox(height: context.spacing.sm),
                Text(
                  title,
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
                SizedBox(height: context.spacing.xl),
                Container(
                  padding: EdgeInsets.all(
                    screenWidth < 600
                        ? context.spacing.lg
                        : context.spacing.xxl,
                  ),
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
                  child: formBody,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverLoadMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DriverLoadMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.xxl),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyle.bodyMedium.copyWith(
              color: context.color.text.secondary,
            ),
          ),
          SizedBox(height: context.spacing.lg),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.arrow_back, size: context.sizes.iconSm),
            label: Text(context.loc.driversTitle),
          ),
        ],
      ),
    );
  }
}

class _DriverEditor extends ConsumerStatefulWidget {
  final Driver? driver;

  const _DriverEditor({super.key, this.driver});

  @override
  ConsumerState<_DriverEditor> createState() => _DriverEditorState();
}

class _DriverEditorState extends ConsumerState<_DriverEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseExpiryController;
  late String _status;
  bool _isSaving = false;

  bool get _isEdit => widget.driver != null;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    _nameController = TextEditingController(text: driver?.name ?? '');
    _phoneController = TextEditingController(text: driver?.phone ?? '');
    _licenseNumberController = TextEditingController(
      text: driver?.licenseNumber ?? '',
    );
    _licenseExpiryController = TextEditingController(
      text: driver?.licenseExpiry ?? '',
    );
    _status = driver?.status ?? Driver.statusActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: context.color.surface,
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
  );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_licenseExpiryController.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now.add(const Duration(days: 365)),
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365 * 20)),
    );
    if (picked == null || !mounted) return;

    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    _licenseExpiryController.text = '$y-$m-$d';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final existing = widget.driver;
    final draft = Driver(
      id: existing?.id ?? 0,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim().toUpperCase(),
      licenseExpiry: _licenseExpiryController.text.trim(),
      status: _status,
      assignedVehicle: existing?.assignedVehicle,
    );
    final successTitle = _isEdit
        ? context.loc.driverUpdatedSuccess
        : context.loc.driverCreatedSuccess;

    setState(() => _isSaving = true);
    final success = existing == null
        ? await ref.read(driversProvider.notifier).createDriver(draft)
        : await ref
              .read(driversProvider.notifier)
              .updateDriver(existing.id, draft);

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CustomToast.showSuccess(context, title: successTitle);
        context.go(Routes.drivers.path);
      });
      return;
    }

    final error = ref.read(driversProvider).errorMessage;
    CustomToast.showError(
      context,
      title: error == null
          ? context.loc.apiRequestFailed
          : context.loc.localizedApiError(error),
    );
  }

  Widget _buildFields(BuildContext context) {
    final nameField = TextFormField(
      controller: _nameController,
      decoration: _decoration(
        context,
        label: context.loc.driverName,
        hint: context.loc.fullNameHint,
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? context.loc.driverNameRequired
          : null,
    );
    final phoneField = TextFormField(
      controller: _phoneController,
      decoration: _decoration(
        context,
        label: context.loc.phone,
        hint: context.loc.phoneHint,
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? context.loc.phoneRequired
          : null,
    );
    final licenseNumberField = TextFormField(
      controller: _licenseNumberController,
      textCapitalization: TextCapitalization.characters,
      decoration: _decoration(
        context,
        label: context.loc.licenseNumber,
        hint: context.loc.licenseNumberHint,
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? context.loc.licenseNumberRequired
          : null,
    );
    final licenseExpiryField = TextFormField(
      controller: _licenseExpiryController,
      readOnly: true,
      onTap: _pickDate,
      decoration: _decoration(
        context,
        label: context.loc.licenseExpiry,
        hint: context.loc.isoDateFormat,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? context.loc.licenseExpiryRequired
          : null,
    );

    final isWide = MediaQuery.sizeOf(context).width >= 640;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isWide)
          Row(
            children: [
              Expanded(child: nameField),
              SizedBox(width: context.spacing.lg),
              Expanded(child: phoneField),
            ],
          )
        else ...[
          nameField,
          SizedBox(height: context.spacing.md),
          phoneField,
        ],
        SizedBox(height: context.spacing.md),
        if (isWide)
          Row(
            children: [
              Expanded(child: licenseNumberField),
              SizedBox(width: context.spacing.lg),
              Expanded(child: licenseExpiryField),
            ],
          )
        else ...[
          licenseNumberField,
          SizedBox(height: context.spacing.md),
          licenseExpiryField,
        ],
        SizedBox(height: context.spacing.md),
        DropdownButtonFormField<String>(
          initialValue: _status,
          decoration: _decoration(context, label: context.loc.colStatus),
          items: Driver.allowedStatuses
              .where(
                (status) =>
                    !(widget.driver?.isAssigned ?? false) ||
                    status == Driver.statusActive,
              )
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(context.loc.localizedStatus(status)),
                ),
              )
              .toList(),
          onChanged: widget.driver?.isAssigned ?? false
              ? null
              : (value) {
                  if (value != null) setState(() => _status = value);
                },
        ),
        if (widget.driver?.isAssigned ?? false) ...[
          SizedBox(height: context.spacing.sm),
          Text(
            '${context.loc.assignedVehicle}: ${widget.driver!.assignedVehicle!.vehicleNumber}',
            style: context.textStyle.bodySmall.copyWith(
              color: context.color.text.secondary,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFields(context),
          SizedBox(height: context.spacing.xxl),
          Divider(
            height: context.sizes.hairlineWidth,
            color: context.color.border,
          ),
          SizedBox(height: context.spacing.lg),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: context.spacing.sm,
            runSpacing: context.spacing.sm,
            children: [
              OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () => context.go(Routes.drivers.path),
                child: Text(context.loc.cancel),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.primary,
                  foregroundColor: context.color.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xl,
                    vertical: context.spacing.md,
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: context.sizes.iconSm,
                        height: context.sizes.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.color.onPrimary,
                        ),
                      )
                    : Text(_isEdit ? context.loc.update : context.loc.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
