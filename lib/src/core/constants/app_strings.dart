/// Centralized string constants for Stark VMS.
///
/// In Part 1, all user-facing English strings are defined here so Part 2
/// can effortlessly bind them to Flutter Localizations (e.g. English & Bangla ARB files).
abstract final class AppStrings {
  // App & Brand
  static const String appName = 'Stark VMS';
  static const String appTitle = 'Stark VMS';
  static const String brandTag = 'STARK VMS';

  // Navigation
  static const String navDashboard = 'Dashboard';
  static const String navVehicles = 'Vehicles';
  static const String logOut = 'Log out';
  static const String demoUser = 'John Doe';
  static const String demoUserInitials = 'JD';

  // Header controls
  static const String langEn = 'EN';
  static const String langBn = 'বাং';
  static const String langFullEnBn = 'EN / বাংলা';
  static const String toggleTheme = 'Toggle Theme';

  // Auth - Login
  static const String signInTitle = 'Sign in';
  static const String signInSubtitle =
      'Enter your credentials to access your account';
  static const String email = 'Email';
  static const String emailHint = 'Enter your email';
  static const String password = 'Password';
  static const String passwordHint = '••••••••••••';
  static const String logInButton = 'Log in';
  static const String noAccountPrompt = "Don't have an account?";
  static const String createAccountLink = 'Create an account';
  static const String mockAuthNotice =
      'Mock Authentication — any valid email & password will sign in';
  static const String emailRequired = 'Please enter an email';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordRequired = 'Please enter your password';

  // Auth - Sign Up
  static const String createAccountTitle = 'Create Account';
  static const String fullName = 'Full Name';
  static const String fullNameHint = 'Enter your full name';
  static const String fullNameRequired = 'Please enter your full name';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordHint = 'Confirm password';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordMismatch = 'Passwords do not match';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String createAccountButton = 'Create account';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Dashboard
  static const String dashboardTitle = 'Dashboard';
  static const String totalVehicles = 'Total Vehicles';
  static const String active = 'Active';
  static const String inService = 'In Service';
  static const String inactive = 'Inactive';
  static const String recentlyAddedVehicles = 'Recently Added Vehicles';
  static const String noVehiclesRegisteredYet = 'No vehicles registered yet';
  static const String registerFirstVehicleSubtitle =
      'Register your first vehicle to get started with fleet tracking.';
  static const String registerFirstVehicleBtn = 'Register First Vehicle';

  // Vehicles List
  static const String vehiclesTitle = 'Vehicles';
  static const String vehiclesSubtitle =
      'Manage company vehicles across Stark Group fleet operations.';
  static const String registerVehicle = 'Register Vehicle';
  static const String searchPlaceholder =
      'Search vehicle number, brand, model...';
  static const String allStatuses = 'All Statuses';
  static const String reset = 'Reset';
  static const String noVehiclesFound = 'No vehicles found';
  static const String noVehiclesFoundSubtitle =
      'No registered vehicles match your current search or filter criteria.';
  static const String clearFilter = 'Clear filter';
  static const String colVehicleNumber = 'Vehicle Number';
  static const String colCompany = 'Company';
  static const String colType = 'Type';
  static const String colBrand = 'Brand';
  static const String colModel = 'Model';
  static const String colStatus = 'Status';
  static const String colActions = 'Actions';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String showingVehicles = 'Showing';
  static const String ofVehicles = 'of';
  static const String vehiclesUnit = 'vehicles';

  // Delete Dialog
  static const String deleteVehicleTitle = 'Delete Vehicle';
  static const String cancel = 'Cancel';
  static const String deleteConfirmMsgPrefix =
      'Are you sure you want to delete vehicle ';
  static const String deleteConfirmMsgSuffix =
      '? This action cannot be undone.';
  static const String vehicleDeletedSuccess = 'Vehicle deleted successfully';

  // Register & Edit Vehicle Form
  static const String editVehicleTitle = 'Edit Vehicle';
  static const String editVehicleSubtitle =
      'Update the vehicle specifications below.';
  static const String registerVehicleSubtitle =
      'Enter the vehicle specifications below to register a new unit to the fleet.';
  static const String fieldVehicleNumber = 'Vehicle Number *';
  static const String fieldCompany = 'Company *';
  static const String fieldType = 'Type *';
  static const String fieldBrand = 'Brand *';
  static const String fieldModel = 'Model *';
  static const String fieldStatus = 'Status *';
  static const String saveVehicle = 'Save Vehicle';
  static const String duplicateVehicleError =
      'This vehicle number is already registered.';
  static const String vehicleSavedSuccess = 'Vehicle registered successfully';
  static const String vehicleUpdatedSuccess = 'Vehicle updated successfully';
  static const String fieldRequired = 'This field is required';

  // Placeholders for Part 2 Notice
  static const String part2PlaceholderNotice =
      'Feature will be made functional in Part 2.';
}
