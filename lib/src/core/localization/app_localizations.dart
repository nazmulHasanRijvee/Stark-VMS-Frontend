import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('bn'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Stark VMS'**
  String get appName;

  /// No description provided for @brandTag.
  ///
  /// In en, this message translates to:
  /// **'STARK VMS'**
  String get brandTag;

  /// No description provided for @brandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Management System'**
  String get brandSubtitle;

  /// No description provided for @fleetManager.
  ///
  /// In en, this message translates to:
  /// **'Fleet Manager'**
  String get fleetManager;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get navVehicles;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Signed Out'**
  String get signedOutTitle;

  /// No description provided for @signedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been logged out.'**
  String get signedOutMessage;

  /// No description provided for @logInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get logInTitle;

  /// No description provided for @logInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your fleet'**
  String get logInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'admin@stark.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @demoHint.
  ///
  /// In en, this message translates to:
  /// **'Demo credentials: admin@stark.com / password123'**
  String get demoHint;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to create your Stark VMS account'**
  String get createAccountSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreatedTitle;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Stark VMS.'**
  String get accountCreatedMessage;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Fleet Overview'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time fleet status and key operational metrics'**
  String get dashboardSubtitle;

  /// No description provided for @registerVehicle.
  ///
  /// In en, this message translates to:
  /// **'Register Vehicle'**
  String get registerVehicle;

  /// No description provided for @totalFleet.
  ///
  /// In en, this message translates to:
  /// **'Total Fleet'**
  String get totalFleet;

  /// No description provided for @activeVehicles.
  ///
  /// In en, this message translates to:
  /// **'Active Vehicles'**
  String get activeVehicles;

  /// No description provided for @inServiceVehicles.
  ///
  /// In en, this message translates to:
  /// **'In Service'**
  String get inServiceVehicles;

  /// No description provided for @inactiveVehicles.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveVehicles;

  /// No description provided for @recentlyAddedVehicles.
  ///
  /// In en, this message translates to:
  /// **'Recently Added Vehicles'**
  String get recentlyAddedVehicles;

  /// No description provided for @noVehiclesInFleet.
  ///
  /// In en, this message translates to:
  /// **'No vehicles in fleet'**
  String get noVehiclesInFleet;

  /// No description provided for @noVehiclesInFleetDesc.
  ///
  /// In en, this message translates to:
  /// **'Register your first vehicle to get started.'**
  String get noVehiclesInFleetDesc;

  /// No description provided for @vehiclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehiclesTitle;

  /// No description provided for @vehiclesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage fleet vehicles, track statuses, and specifications'**
  String get vehiclesSubtitle;

  /// No description provided for @searchVehiclesHint.
  ///
  /// In en, this message translates to:
  /// **'Search by vehicle number, company, or brand...'**
  String get searchVehiclesHint;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInService.
  ///
  /// In en, this message translates to:
  /// **'In Service'**
  String get statusInService;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @colVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get colVehicleNumber;

  /// No description provided for @colCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get colCompany;

  /// No description provided for @colType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get colType;

  /// No description provided for @colBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get colBrand;

  /// No description provided for @colModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get colModel;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @colActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get colActions;

  /// No description provided for @noVehiclesMatch.
  ///
  /// In en, this message translates to:
  /// **'No vehicles match your search'**
  String get noVehiclesMatch;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms or status filter'**
  String get tryAdjustingFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPage;

  /// No description provided for @registerVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Vehicle'**
  String get registerVehicleTitle;

  /// No description provided for @registerVehicleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new vehicle to the Stark VMS fleet'**
  String get registerVehicleSubtitle;

  /// No description provided for @editVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicleTitle;

  /// No description provided for @editVehicleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update vehicle details and operational status'**
  String get editVehicleSubtitle;

  /// No description provided for @vehicleNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumberLabel;

  /// No description provided for @vehicleNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. DHAKA METRO GA-12-3456'**
  String get vehicleNumberHint;

  /// No description provided for @vehicleNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number is required'**
  String get vehicleNumberRequired;

  /// No description provided for @duplicateVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'A vehicle with this number already exists'**
  String get duplicateVehicleNumber;

  /// No description provided for @companyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyLabel;

  /// No description provided for @companyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stark Logistics'**
  String get companyHint;

  /// No description provided for @companyRequired.
  ///
  /// In en, this message translates to:
  /// **'Company is required'**
  String get companyRequired;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @typeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Truck, SUV, Sedan'**
  String get typeHint;

  /// No description provided for @typeRequired.
  ///
  /// In en, this message translates to:
  /// **'Type is required'**
  String get typeRequired;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @brandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Scania, Toyota'**
  String get brandHint;

  /// No description provided for @brandRequired.
  ///
  /// In en, this message translates to:
  /// **'Brand is required'**
  String get brandRequired;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @modelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. R500, Land Cruiser'**
  String get modelHint;

  /// No description provided for @modelRequired.
  ///
  /// In en, this message translates to:
  /// **'Model is required'**
  String get modelRequired;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @saveVehicleButton.
  ///
  /// In en, this message translates to:
  /// **'Save Vehicle'**
  String get saveVehicleButton;

  /// No description provided for @updateVehicleButton.
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get updateVehicleButton;

  /// No description provided for @vehicleRegisteredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registered successfully'**
  String get vehicleRegisteredSuccess;

  /// No description provided for @vehicleUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated successfully'**
  String get vehicleUpdatedSuccess;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteWarningNote.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All records associated with this vehicle will be permanently removed.'**
  String get deleteWarningNote;

  /// No description provided for @vehicleDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle deleted successfully'**
  String get vehicleDeletedSuccess;

  /// No description provided for @showingPagination.
  ///
  /// In en, this message translates to:
  /// **'Showing {start} to {end} of {total} vehicles'**
  String showingPagination(int start, int end, int total);

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete vehicle {vehicleNumber} from the fleet?'**
  String deleteConfirmMessage(Object vehicleNumber);

  /// No description provided for @openNavigation.
  ///
  /// In en, this message translates to:
  /// **'Open navigation'**
  String get openNavigation;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get defaultUserName;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @backToVehicles.
  ///
  /// In en, this message translates to:
  /// **'Back to Vehicles'**
  String get backToVehicles;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
