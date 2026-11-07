import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Summary KPI metric card matching the Stitch Dashboard design.
class SummaryKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const SummaryKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(context.radius.md);

    return Material(
      color: context.color.surface,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: borderRadius,
            border: Border.all(color: context.color.border),
            boxShadow: [
              BoxShadow(
                color: context.color.text.primary.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(context.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: context.textStyle.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: context.color.text.secondary,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Text(
                  value,
                  style: context.textStyle.metricLarge.copyWith(
                    color: valueColor ?? context.color.text.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
