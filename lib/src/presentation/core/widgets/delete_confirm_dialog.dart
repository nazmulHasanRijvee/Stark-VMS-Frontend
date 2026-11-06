import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extension.dart';
import '../theme/theme.dart';

/// Reusable modal dialog for confirming vehicle deletion.
class DeleteConfirmDialog extends StatelessWidget {
  final String vehicleNumber;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.vehicleNumber,
    required this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, {required String vehicleNumber}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => DeleteConfirmDialog(
        vehicleNumber: vehicleNumber,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.lg),
      ),
      backgroundColor: context.color.surface,
      elevation: 16,
      insetPadding: EdgeInsets.all(context.spacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: context.sizes.lg - 4, // 44px
                    height: context.sizes.lg - 4,
                    decoration: BoxDecoration(
                      color: context.color.errorBg,
                      borderRadius: BorderRadius.circular(context.radius.md),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: context.color.error,
                      size: context.sizes.sm,
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.deleteConfirmTitle,
                          style: context.textStyle.headLineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.color.text.primary,
                          ),
                        ),
                        SizedBox(height: context.spacing.xs),
                        Text(
                          context.loc.deleteConfirmMessage(vehicleNumber),
                          style: context.textStyle.bodyMedium.copyWith(
                            color: context.color.text.secondary,
                          ),
                        ),
                        SizedBox(height: context.spacing.xs),
                        Text(
                          context.loc.deleteWarningNote,
                          style: context.textStyle.bodySmall.copyWith(
                            color: context.color.text.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.lg,
                        vertical: context.spacing.md,
                      ),
                      side: BorderSide(color: context.color.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.radius.sm),
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
                  SizedBox(width: context.spacing.sm),
                  ElevatedButton.icon(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.color.error,
                      foregroundColor: context.color.onPrimary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.lg,
                        vertical: context.spacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.radius.sm),
                      ),
                    ),
                    icon: Icon(Icons.delete_outline, size: context.sizes.xs + 2),
                    label: Text(
                      context.loc.delete,
                      style: context.textStyle.labelMedium.copyWith(
                        color: context.color.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
