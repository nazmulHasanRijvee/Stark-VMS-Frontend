import 'package:material_ui/material_ui.dart';

import '../localization/app_localizations.dart';

extension LocalizationEx on BuildContext {
  /// Quick and clean accessor for localized strings throughout the UI.
  AppLocalizations get loc => AppLocalizations.of(this);
}
