import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../application_state/theme_mode_provider/theme_mode_provider.dart';
import '../theme/theme.dart';

/// Styled theme toggle button matching the Stitch header.
///
/// Toggles between Light and Dark mode using Riverpod [themeModeProvider].
class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Tooltip(
      message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).changeTheme(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
        },
        borderRadius: BorderRadius.circular(context.radius.sm),
        child: Container(
          padding: EdgeInsets.all(context.spacing.sm2),
          decoration: BoxDecoration(
            color: context.color.surfaceSubtle,
            borderRadius: BorderRadius.circular(context.radius.sm),
            border: Border.all(color: context.color.border),
          ),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: context.sizes.iconSm, // 18px
            color: context.color.icon,
          ),
        ),
      ),
    );
  }
}
