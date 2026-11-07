import 'package:material_ui/material_ui.dart';

import '../../../../../core/extensions/localization_extension.dart';
import '../../../../core/theme/theme.dart';

/// [SplashScreen] solely focuses on its splash UI, free from
/// any authentication or onboarding logic. All app-level initialization
/// logics are centralized in [startupProvider].
///
/// While routing decisions (based on authentication, onboadring status) are handled  by go_router's
/// [routerStateProvider]
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.sizes.xxl,
              height: context.sizes.xxl,
              decoration: BoxDecoration(
                color: context.color.primary,
                borderRadius: BorderRadius.circular(context.radius.md),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: context.color.onPrimary,
                size: context.sizes.iconLg,
              ),
            ),
            SizedBox(height: context.spacing.lg),
            Text(
              context.loc.appName,
              style: context.textStyle.headLineLarge.copyWith(
                color: context.color.text.primary,
              ),
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              context.loc.brandSubtitle,
              style: context.textStyle.bodyMedium.copyWith(
                color: context.color.text.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
