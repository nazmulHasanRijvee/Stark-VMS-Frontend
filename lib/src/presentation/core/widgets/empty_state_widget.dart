import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Centered empty state for lists and data panels.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.sizes.xxl,
              height: context.sizes.xxl,
              decoration: BoxDecoration(
                color: context.color.infoBg,
                borderRadius: BorderRadius.circular(context.radius.pill),
              ),
              child: Icon(
                icon,
                size: context.sizes.md,
                color: context.color.primary,
              ),
            ),
            SizedBox(height: context.spacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textStyle.headLineMedium.copyWith(
                color: context.color.text.primary,
              ),
            ),
            SizedBox(height: context.spacing.xs),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.sizes.xxxl * 3),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: context.textStyle.bodyMedium.copyWith(
                  color: context.color.text.secondary,
                ),
              ),
            ),
            if (onAction != null && buttonLabel != null) ...[
              SizedBox(height: context.spacing.lg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}