import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../../domain/entities/vehicle.dart';
import '../theme/theme.dart';

/// Reusable status badge chip matching the Stitch VMS design.
///
/// Features distinct, localized text labels alongside theme-aware background
/// and foreground colors for Active, In Service, and Inactive states in both
/// light and dark modes.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case Vehicle.statusActive:
        bg = context.color.statusActiveBg;
        fg = context.color.statusActiveFg;
        break;
      case Vehicle.statusInService:
        bg = context.color.statusInServiceBg;
        fg = context.color.statusInServiceFg;
        break;
      case Vehicle.statusInactive:
      default:
        bg = context.color.statusInactiveBg;
        fg = context.color.statusInactiveFg;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md - 2, // 10px
        vertical: context.spacing.xs - 0.5, // 3.5px
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.radius.pill),
      ),
      child: Text(
        context.loc.localizedStatus(status),
        style: context.textStyle.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
