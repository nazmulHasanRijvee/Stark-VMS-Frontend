import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Summary KPI metric card matching the Stitch Dashboard design.
class SummaryKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const SummaryKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(context.radius.md),
        border: Border.all(color: context.color.border),
        boxShadow: [
          BoxShadow(
            color: context.color.text.primary.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: context.textStyle.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: context.color.text.secondary,
            ),
          ),
          SizedBox(height: context.spacing.xs),
          Text(
            value,
            style: context.textStyle.headLineLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: valueColor ?? context.color.text.primary,
            ),
          ),
        ],
      ),
    );
  }
}
