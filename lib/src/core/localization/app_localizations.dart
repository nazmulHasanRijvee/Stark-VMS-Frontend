import 'package:material_ui/material_ui.dart';

/// Centralized, production-grade localization support for Stark VMS.
///
/// Implements full English (`en`) and Bangla (`bn`) string translations
/// adhering to Clean Architecture and standard Flutter localization delegates.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isBangla => locale.languageCode == 'bn';

  // ===========================================================================
  // BRAND & GENERAL
  // ===========================================================================
  String get appName => isBangla ? 'স্টার্ক ভিএমএস' : 'Stark VMS';
  String get brandTag => isBangla ? 'স্টার্ক ভিএমএস' : 'STARK VMS';
  String get brandSubtitle => isBangla ? 'যানবাহন ব্যবস্থাপনা সিস্টেম' : 'Vehicle Management System';
  String get fleetManager => isBangla ? 'ফ্লিট ম্যানেজার' : 'Fleet Manager';
  String get cancel => isBangla ? 'বাতিল' : 'Cancel';
  String get delete => isBangla ? 'মুছুন' : 'Delete';
  String get edit => isBangla ? 'সম্পাদনা' : 'Edit';
  String get save => isBangla ? 'সংরক্ষণ করুন' : 'Save';
  String get update => isBangla ? 'হালনাগাদ করুন' : 'Update';
  String get search => isBangla ? 'অনুসন্ধান' : 'Search';
  String get actions => isBangla ? 'পদক্ষেপ' : 'Actions';
  String get viewAll => isBangla ? 'সব দেখুন' : 'View All';
  String get loading => isBangla ? 'লোড হচ্ছে...' : 'Loading...';
  String get retry => isBangla ? 'পুনরায় চেষ্টা করুন' : 'Retry';

  // ===========================================================================
  // NAVIGATION & SHELL
  // ===========================================================================
  String get navDashboard => isBangla ? 'ড্যাশবোর্ড' : 'Dashboard';
  String get navVehicles => isBangla ? 'যানবাহন' : 'Vehicles';
  String get signOut => isBangla ? 'সাইন আউট' : 'Sign Out';
  String get signedOutTitle => isBangla ? 'সাইন আউট সম্পন্ন হয়েছে' : 'Signed Out';
  String get signedOutMessage => isBangla ? 'সফলভাবে লগআউট করা হয়েছে।' : 'You have been logged out.';

  // ===========================================================================
  // AUTHENTICATION: LOGIN
  // ===========================================================================
  String get logInTitle => isBangla ? 'স্বাগতম' : 'Welcome back';
  String get logInSubtitle =>
      isBangla ? 'আপনার অ্যাকাউন্টে প্রবেশ করতে তথ্য দিন' : 'Enter your credentials to access your fleet';
  String get email => isBangla ? 'ইমেইল' : 'Email Address';
  String get emailHint => isBangla ? 'admin@stark.com' : 'admin@stark.com';
  String get emailRequired => isBangla ? 'ইমেইল প্রবেশ করা বাধ্যতামূলক' : 'Email is required';
  String get emailInvalid => isBangla ? 'সঠিক ইমেইল ঠিকানা দিন' : 'Enter a valid email address';
  String get password => isBangla ? 'পাসওয়ার্ড' : 'Password';
  String get passwordHint => isBangla ? 'আপনার পাসওয়ার্ড' : 'Enter your password';
  String get passwordRequired => isBangla ? 'পাসওয়ার্ড প্রবেশ করা বাধ্যতামূলক' : 'Password is required';
  String get passwordTooShort =>
      isBangla ? 'পাসওয়ার্ড অন্তত ৬ অক্ষরের হতে হবে' : 'Password must be at least 6 characters';
  String get rememberMe => isBangla ? 'আমাকে মনে রাখুন' : 'Remember me';
  String get forgotPassword => isBangla ? 'পাসওয়ার্ড ভুলে গেছেন?' : 'Forgot password?';
  String get logInButton => isBangla ? 'লগইন করুন' : 'Log In';
  String get dontHaveAccount => isBangla ? 'অ্যাকাউন্ট নেই?' : "Don't have an account?";
  String get signUpLink => isBangla ? 'নিবন্ধন করুন' : 'Sign Up';
  String get invalidCredentials =>
      isBangla ? 'অবৈধ ইমেইল বা পাসওয়ার্ড' : 'Invalid email or password';
  String get demoHint => isBangla
      ? 'ডেমো ক্রেডেনশিয়াল: admin@stark.com / password123'
      : 'Demo credentials: admin@stark.com / password123';

  // ===========================================================================
  // AUTHENTICATION: SIGN UP
  // ===========================================================================
  String get createAccountTitle => isBangla ? 'অ্যাকাউন্ট তৈরি করুন' : 'Create an Account';
  String get createAccountSubtitle => isBangla
      ? 'স্টার্ক ভিএমএস ব্যবহারের জন্য তথ্য দিন'
      : 'Enter your details to create your Stark VMS account';
  String get fullName => isBangla ? 'পুরো নাম' : 'Full Name';
  String get fullNameHint => isBangla ? 'জন ডো' : 'John Doe';
  String get fullNameRequired => isBangla ? 'পুরো নাম প্রদান বাধ্যতামূলক' : 'Full name is required';
  String get confirmPassword => isBangla ? 'পাসওয়ার্ড নিশ্চিত করুন' : 'Confirm Password';
  String get confirmPasswordHint => isBangla ? 'পাসওয়ার্ড পুনরায় লিখুন' : 'Re-enter your password';
  String get confirmPasswordRequired =>
      isBangla ? 'পাসওয়ার্ড নিশ্চিত করা আবশ্যক' : 'Confirm password is required';
  String get passwordMismatch => isBangla ? 'পাসওয়ার্ড মিলছে না' : 'Passwords do not match';
  String get createAccountButton => isBangla ? 'অ্যাকাউন্ট তৈরি করুন' : 'Create Account';
  String get alreadyHaveAccount => isBangla ? 'ইতিমধ্যে অ্যাকাউন্ট আছে?' : 'Already have an account?';
  String get accountCreatedTitle => isBangla ? 'অ্যাকাউন্ট তৈরি হয়েছে' : 'Account Created';
  String get accountCreatedMessage =>
      isBangla ? 'স্টার্ক ভিএমএসে স্বাগতম।' : 'Welcome to Stark VMS.';

  // ===========================================================================
  // DASHBOARD
  // ===========================================================================
  String get dashboardTitle => isBangla ? 'ফ্লিট সার্বিক চিত্র' : 'Fleet Overview';
  String get dashboardSubtitle =>
      isBangla ? 'রিয়েল-টাইম ফ্লিট অবস্থা ও মূল মেট্রিক্স' : 'Real-time fleet status and key operational metrics';
  String get registerVehicle => isBangla ? 'যানবাহন নিবন্ধন' : 'Register Vehicle';
  String get totalFleet => isBangla ? 'মোট যানবাহন' : 'Total Fleet';
  String get activeVehicles => isBangla ? 'সক্রিয় যানবাহন' : 'Active Vehicles';
  String get inServiceVehicles => isBangla ? 'সার্ভিসাধীন যানবাহন' : 'In Service';
  String get inactiveVehicles => isBangla ? 'নিষ্ক্রিয় যানবাহন' : 'Inactive';
  String get recentlyAddedVehicles =>
      isBangla ? 'সম্প্রতি যুক্ত যানবাহন' : 'Recently Added Vehicles';
  String get noVehiclesInFleet =>
      isBangla ? 'ফ্লিটে কোন যানবাহন নেই' : 'No vehicles in fleet';
  String get noVehiclesInFleetDesc => isBangla
      ? 'শুরু করতে প্রথম যানবাহনটি নিবন্ধন করুন।'
      : 'Register your first vehicle to get started.';

  // ===========================================================================
  // VEHICLES LIST & TABLE
  // ===========================================================================
  String get vehiclesTitle => isBangla ? 'যানবাহন তালিকা' : 'Vehicles';
  String get vehiclesSubtitle => isBangla
      ? 'ফ্লিট যানবাহন পরিচালনা, অবস্থা ও বিবরণ পর্যবেক্ষণ করুন'
      : 'Manage fleet vehicles, track statuses, and specifications';
  String get searchVehiclesHint => isBangla
      ? 'যানবাহন নম্বর, কোম্পানি, বা ব্র্যান্ড দিয়ে খুঁজুন...'
      : 'Search by vehicle number, company, or brand...';
  String get allStatuses => isBangla ? 'সকল অবস্থা' : 'All Statuses';
  String get statusActive => isBangla ? 'সক্রিয়' : 'Active';
  String get statusInService => isBangla ? 'সার্ভিসাধীন' : 'In Service';
  String get statusInactive => isBangla ? 'নিষ্ক্রিয়' : 'Inactive';
  String get colVehicleNumber => isBangla ? 'যানবাহন নম্বর' : 'Vehicle Number';
  String get colCompany => isBangla ? 'কোম্পানি' : 'Company';
  String get colType => isBangla ? 'ধরণ' : 'Type';
  String get colBrand => isBangla ? 'ব্র্যান্ড' : 'Brand';
  String get colModel => isBangla ? 'মডেল' : 'Model';
  String get colStatus => isBangla ? 'অবস্থা' : 'Status';
  String get colActions => isBangla ? 'পদক্ষেপ' : 'Actions';
  String get noVehiclesMatch =>
      isBangla ? 'কোন যানবাহন পাওয়া যায়নি' : 'No vehicles match your search';
  String get tryAdjustingFilters => isBangla
      ? 'অনুসন্ধান শব্দ বা ফিল্টার পরিবর্তন করে দেখুন'
      : 'Try adjusting your search terms or status filter';
  String get clearFilters => isBangla ? 'ফিল্টার পরিষ্কার করুন' : 'Clear Filters';

  String showingPagination(int start, int end, int total) {
    if (isBangla) {
      return '$total টির মধ্যে $start থেকে $end টি দেখানো হচ্ছে';
    }
    return 'Showing $start to $end of $total vehicles';
  }

  String get previousPage => isBangla ? 'পূর্ববর্তী' : 'Previous';
  String get nextPage => isBangla ? 'পরবর্তী' : 'Next';

  // ===========================================================================
  // VEHICLE FORM (REGISTER & EDIT)
  // ===========================================================================
  String get registerVehicleTitle => isBangla ? 'যানবাহন নিবন্ধন' : 'Register Vehicle';
  String get registerVehicleSubtitle => isBangla
      ? 'স্টার্ক ভিএমএস ফ্লিটে একটি নতুন যানবাহন যুক্ত করুন'
      : 'Add a new vehicle to the Stark VMS fleet';
  String get editVehicleTitle => isBangla ? 'যানবাহন সম্পাদনা' : 'Edit Vehicle';
  String get editVehicleSubtitle =>
      isBangla ? 'যানবাহনের বিবরণ ও অবস্থা হালনাগাদ করুন' : 'Update vehicle details and operational status';
  String get vehicleNumberLabel => isBangla ? 'যানবাহন নম্বর' : 'Vehicle Number';
  String get vehicleNumberHint => isBangla ? 'যেমন: DHAKA METRO GA-12-3456' : 'e.g. DHAKA METRO GA-12-3456';
  String get vehicleNumberRequired =>
      isBangla ? 'যানবাহন নম্বর প্রদান বাধ্যতামূলক' : 'Vehicle number is required';
  String get duplicateVehicleNumber => isBangla
      ? 'এই যানবাহন নম্বরটি ইতিমধ্যে ফ্লিটে বিদ্যমান'
      : 'A vehicle with this number already exists';
  String get companyLabel => isBangla ? 'কোম্পানি' : 'Company';
  String get companyHint => isBangla ? 'যেমন: Stark Logistics' : 'e.g. Stark Logistics';
  String get companyRequired => isBangla ? 'কোম্পানি প্রদান বাধ্যতামূলক' : 'Company is required';
  String get typeLabel => isBangla ? 'ধরণ' : 'Type';
  String get typeHint => isBangla ? 'যেমন: Truck, SUV, Sedan' : 'e.g. Truck, SUV, Sedan';
  String get typeRequired => isBangla ? 'ধরণ নির্বাচন বা প্রদান বাধ্যতামূলক' : 'Type is required';
  String get brandLabel => isBangla ? 'ব্র্যান্ড' : 'Brand';
  String get brandHint => isBangla ? 'যেমন: Scania, Toyota' : 'e.g. Scania, Toyota';
  String get brandRequired => isBangla ? 'ব্র্যান্ড প্রদান বাধ্যতামূলক' : 'Brand is required';
  String get modelLabel => isBangla ? 'মডেল' : 'Model';
  String get modelHint => isBangla ? 'যেমন: R500, Land Cruiser' : 'e.g. R500, Land Cruiser';
  String get modelRequired => isBangla ? 'মডেল প্রদান বাধ্যতামূলক' : 'Model is required';
  String get statusLabel => isBangla ? 'অবস্থা' : 'Status';
  String get saveVehicleButton => isBangla ? 'সংরক্ষণ করুন' : 'Save Vehicle';
  String get updateVehicleButton => isBangla ? 'হালনাগাদ করুন' : 'Update Vehicle';
  String get vehicleRegisteredSuccess =>
      isBangla ? 'যানবাহন সফলভাবে নিবন্ধিত হয়েছে' : 'Vehicle registered successfully';
  String get vehicleUpdatedSuccess =>
      isBangla ? 'যানবাহন সফলভাবে হালনাগাদ হয়েছে' : 'Vehicle updated successfully';

  // ===========================================================================
  // DELETE CONFIRMATION DIALOG
  // ===========================================================================
  String get deleteConfirmTitle => isBangla ? 'যানবাহন মুছুন' : 'Delete Vehicle';
  String deleteConfirmMessage(String vehicleNumber) {
    if (isBangla) {
      return 'আপনি কি নিশ্চিত যে $vehicleNumber ফ্লিট থেকে মুছে ফেলতে চান?';
    }
    return 'Are you sure you want to delete vehicle $vehicleNumber from the fleet?';
  }
  String get deleteWarningNote => isBangla
      ? 'এই কাজটি ফিরিয়ে আনা যাবে না। এই যানবাহনের রেকর্ড স্থায়ীভাবে মুছে যাবে।'
      : 'This action cannot be undone. All records associated with this vehicle will be permanently removed.';
  String get vehicleDeletedSuccess =>
      isBangla ? 'যানবাহন সফলভাবে মুছে ফেলা হয়েছে' : 'Vehicle deleted successfully';

  // Helper method for status chip label
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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

