import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../application_state/localization_provider/localization_provider.dart';
import '../theme/theme.dart';

/// Styled language selector pill [ EN | বাং ] matching the Stitch header.
///
/// Fully functional toggle between English and Bangla locales.
class LanguageSelectorPill extends ConsumerWidget {
  const LanguageSelectorPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localizationProvider);
    final isEn = currentLocale.languageCode == 'en';

    return Container(
      decoration: BoxDecoration(
        color: context.color.surfaceSubtle,
        borderRadius: BorderRadius.circular(context.radius.sm),
        border: Border.all(color: context.color.border),
      ),
      padding: EdgeInsets.all(context.spacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // English button
          InkWell(
            onTap: () {
              if (!isEn) {
                ref
                    .read(localizationProvider.notifier)
                    .changeLocale(const Locale('en'));
              }
            },
            borderRadius: BorderRadius.circular(context.radius.xs2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.sm,
                vertical: context.spacing.xs,
              ),
              decoration: BoxDecoration(
                color: isEn
                    ? context.color.surface
                    : context.color.surfaceSubtle,
                borderRadius: BorderRadius.circular(context.radius.xs2),
                boxShadow: isEn
                    ? [
                        BoxShadow(
                          color: context.color.text.primary.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'EN',
                style: context.textStyle.labelSmall.copyWith(
                  fontWeight: isEn ? FontWeight.w700 : FontWeight.w500,
                  color: isEn
                      ? context.color.primary
                      : context.color.text.secondary,
                ),
              ),
            ),
          ),

          // Bangla button
          InkWell(
            onTap: () {
              if (isEn) {
                ref
                    .read(localizationProvider.notifier)
                    .changeLocale(const Locale('bn'));
              }
            },
            borderRadius: BorderRadius.circular(context.radius.xs2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.sm,
                vertical: context.spacing.xs,
              ),
              decoration: BoxDecoration(
                color: isEn
                    ? context.color.surfaceSubtle
                    : context.color.surface,
                borderRadius: BorderRadius.circular(context.radius.xs2),
                boxShadow: !isEn
                    ? [
                        BoxShadow(
                          color: context.color.text.primary.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'বাং',
                style: context.textStyle.labelSmall.copyWith(
                  fontWeight: !isEn ? FontWeight.w700 : FontWeight.w500,
                  color: !isEn
                      ? context.color.primary
                      : context.color.text.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
