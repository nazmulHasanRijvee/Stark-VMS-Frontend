import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extension.dart';
import '../router/routes.dart';
import '../theme/theme.dart';

/// Destination shown when a requested route does not exist.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.uri, super.key});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: context.sizes.md,
                color: context.color.error,
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                uri.toString(),
                style: context.textStyle.bodyMedium.copyWith(
                  color: context.color.text.secondary,
                ),
              ),
              SizedBox(height: context.spacing.md),
              FilledButton(
                onPressed: () => context.go(Routes.dashboard.path),
                child: Text(context.loc.navDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}