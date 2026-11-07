import 'package:material_ui/material_ui.dart';

import '../localization/app_localizations.dart';

extension LocalizationEx on BuildContext {
  /// Quick and clean accessor for localized strings throughout the UI.
  AppLocalizations get loc => AppLocalizations.of(this);
}

extension AppLocalizationsStatus on AppLocalizations {
  /// Returns the localized label for a vehicle status value from the model.
  String localizedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return statusActive;
      case 'in service':
        return statusInService;
      case 'inactive':
        return statusInactive;
      default:
        return status;
    }
  }
}
