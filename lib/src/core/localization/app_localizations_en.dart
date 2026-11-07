// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Stark VMS';

  @override
  String get brandTag => 'STARK VMS';

  @override
  String get brandSubtitle => 'Vehicle Management System';

  @override
  String get fleetManager => 'Fleet Manager';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get search => 'Search';

  @override
  String get actions => 'Actions';

  @override
  String get viewAll => 'View All';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navVehicles => 'Vehicles';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signedOutTitle => 'Signed Out';

  @override
  String get signedOutMessage => 'You have been logged out.';

  @override
  String get logInTitle => 'Welcome back';

  @override
  String get logInSubtitle => 'Enter your credentials to access your fleet';

  @override
  String get email => 'Email Address';

  @override
  String get emailHint => 'admin@stark.com';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logInButton => 'Log In';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get demoHint => 'Demo credentials: admin@stark.com / password123';

  @override
  String get createAccountTitle => 'Create an Account';

  @override
  String get createAccountSubtitle =>
      'Enter your details to create your Stark VMS account';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'John Doe';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get accountCreatedTitle => 'Account Created';

  @override
  String get accountCreatedMessage => 'Welcome to Stark VMS.';

  @override
  String get dashboardTitle => 'Fleet Overview';

  @override
  String get dashboardSubtitle =>
      'Real-time fleet status and key operational metrics';

  @override
  String get registerVehicle => 'Register Vehicle';

  @override
  String get totalFleet => 'Total Fleet';

  @override
  String get activeVehicles => 'Active Vehicles';

  @override
  String get inServiceVehicles => 'In Service';

  @override
  String get inactiveVehicles => 'Inactive';

  @override
  String get recentlyAddedVehicles => 'Recently Added Vehicles';

  @override
  String get noVehiclesInFleet => 'No vehicles in fleet';

  @override
  String get noVehiclesInFleetDesc =>
      'Register your first vehicle to get started.';

  @override
  String get vehiclesTitle => 'Vehicles';

  @override
  String get vehiclesSubtitle =>
      'Manage fleet vehicles, track statuses, and specifications';

  @override
  String get searchVehiclesHint =>
      'Search by vehicle number, company, or brand...';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInService => 'In Service';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get colVehicleNumber => 'Vehicle Number';

  @override
  String get colCompany => 'Company';

  @override
  String get colType => 'Type';

  @override
  String get colBrand => 'Brand';

  @override
  String get colModel => 'Model';

  @override
  String get colStatus => 'Status';

  @override
  String get colActions => 'Actions';

  @override
  String get noVehiclesMatch => 'No vehicles match your search';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your search terms or status filter';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get previousPage => 'Previous';

  @override
  String get nextPage => 'Next';

  @override
  String get registerVehicleTitle => 'Register Vehicle';

  @override
  String get registerVehicleSubtitle =>
      'Add a new vehicle to the Stark VMS fleet';

  @override
  String get editVehicleTitle => 'Edit Vehicle';

  @override
  String get editVehicleSubtitle =>
      'Update vehicle details and operational status';

  @override
  String get vehicleNumberLabel => 'Vehicle Number';

  @override
  String get vehicleNumberHint => 'e.g. DHAKA METRO GA-12-3456';

  @override
  String get vehicleNumberRequired => 'Vehicle number is required';

  @override
  String get duplicateVehicleNumber =>
      'A vehicle with this number already exists';

  @override
  String get companyLabel => 'Company';

  @override
  String get companyHint => 'e.g. Stark Logistics';

  @override
  String get companyRequired => 'Company is required';

  @override
  String get typeLabel => 'Type';

  @override
  String get typeHint => 'e.g. Truck, SUV, Sedan';

  @override
  String get typeRequired => 'Type is required';

  @override
  String get brandLabel => 'Brand';

  @override
  String get brandHint => 'e.g. Scania, Toyota';

  @override
  String get brandRequired => 'Brand is required';

  @override
  String get modelLabel => 'Model';

  @override
  String get modelHint => 'e.g. R500, Land Cruiser';

  @override
  String get modelRequired => 'Model is required';

  @override
  String get statusLabel => 'Status';

  @override
  String get saveVehicleButton => 'Save Vehicle';

  @override
  String get updateVehicleButton => 'Update Vehicle';

  @override
  String get vehicleRegisteredSuccess => 'Vehicle registered successfully';

  @override
  String get vehicleUpdatedSuccess => 'Vehicle updated successfully';

  @override
  String get deleteConfirmTitle => 'Delete Vehicle';

  @override
  String get deleteWarningNote =>
      'This action cannot be undone. All records associated with this vehicle will be permanently removed.';

  @override
  String get vehicleDeletedSuccess => 'Vehicle deleted successfully';

  @override
  String showingPagination(int start, int end, int total) {
    return 'Showing $start to $end of $total vehicles';
  }

  @override
  String deleteConfirmMessage(Object vehicleNumber) {
    return 'Are you sure you want to delete vehicle $vehicleNumber from the fleet?';
  }

  @override
  String get openNavigation => 'Open navigation';

  @override
  String get defaultUserName => 'John Doe';

  @override
  String get select => 'Select';

  @override
  String get backToVehicles => 'Back to Vehicles';
}
