import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../theme/theme.dart';

/// Applies the app's theme-aware grey shimmer to loading placeholders.
class AppSkeletonizer extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const AppSkeletonizer({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final isDark = context.isDark;
    final baseColor = isDark
        ? Color.lerp(colors.surface, colors.text.tertiary, 0.42)!
        : colors.border;
    final highlightColor = isDark
        ? Color.lerp(colors.surface, colors.text.tertiary, 0.62)!
        : colors.surfaceSubtle;

    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
      child: child,
    );
  }
}
