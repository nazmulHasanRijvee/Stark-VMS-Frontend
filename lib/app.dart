import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'src/core/constants/app_strings.dart';
import 'src/core/localization/app_localization_delegates.dart';
import 'src/core/localization/app_localizations.dart';
import 'src/presentation/core/application_state/localization_provider/localization_provider.dart';
import 'src/presentation/core/application_state/theme_mode_provider/theme_mode_provider.dart';
import 'src/presentation/core/router/router.dart';
import 'src/presentation/core/theme/theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localizationProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: context.lightTheme,
        darkTheme: context.darkTheme,
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: appLocalizationDelegates,
        routerConfig: router,
      ),
    );
  }
}
