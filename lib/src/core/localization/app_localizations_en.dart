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
  String get loadMore => 'Load More';

  @override
  String get latest => 'Latest';

  @override
  String get optional => 'Optional';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navVehicles => 'Vehicles';

  @override
  String get navDrivers => 'Drivers';

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
  String get maintenanceVehicles => 'Maintenance';

  @override
  String get inactiveVehicles => 'Inactive';

  @override
  String get recentlyAddedVehicles => 'Recently Updated Vehicles';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortRecentlyUpdated => 'Recently updated';

  @override
  String get sortAscending => 'Sort ascending';

  @override
  String get sortDescending => 'Sort descending';

  @override
  String get loadVehiclesFailed => 'Could not load vehicles';

  @override
  String get loadDashboardFailed => 'Could not load dashboard metrics';

  @override
  String get apiRequestFailed =>
      'The request could not be completed. Please try again.';

  @override
  String get duplicateLicenseNumber =>
      'A driver with this license number already exists.';

  @override
  String get driverAssignmentConflict =>
      'Unassign this driver before changing its status or assignment.';

  @override
  String get documentStorageUnavailable =>
      'Document storage is temporarily unavailable. Keep the file selected and retry.';

  @override
  String get invalidDocumentFile =>
      'Choose a valid, non-empty PDF, JPEG, or PNG file up to 10 MB.';

  @override
  String get maintenanceDetailsInvalid =>
      'Check the maintenance date, cost, type, and workshop details.';

  @override
  String get resourceNotFound => 'The requested record could not be found.';

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
  String get allTypes => 'All Types';

  @override
  String get statusActive => 'Active';

  @override
  String get statusMaintenance => 'Maintenance';

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

  @override
  String get driversTitle => 'Drivers';

  @override
  String get driversSubtitle =>
      'Manage fleet driver profiles, licenses, and assignments';

  @override
  String get searchDriversHint =>
      'Search by driver name, phone, license, or vehicle...';

  @override
  String get addDriver => 'Add Driver';

  @override
  String get editDriver => 'Edit Driver';

  @override
  String get deleteDriver => 'Delete Driver';

  @override
  String get driverName => 'Driver Name';

  @override
  String get driverNameRequired => 'Driver name is required';

  @override
  String get phone => 'Phone Number';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneHint => '+880 1712-345678';

  @override
  String get licenseNumber => 'License Number';

  @override
  String get licenseNumberRequired => 'License number is required';

  @override
  String get licenseNumberHint => 'DHAKA-M-123456';

  @override
  String get licenseExpiry => 'License Expiry Date';

  @override
  String get licenseExpiryRequired => 'License expiry date is required';

  @override
  String get assignedVehicle => 'Assigned Vehicle';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get driverCreatedSuccess => 'Driver added successfully';

  @override
  String get driverUpdatedSuccess => 'Driver updated successfully';

  @override
  String get driverDeletedSuccess => 'Driver deleted successfully';

  @override
  String deleteDriverConfirm(Object name) {
    return 'Are you sure you want to delete driver $name?';
  }

  @override
  String get cannotDeleteAssignedDriver =>
      'Cannot delete an assigned driver. Please unassign the vehicle first.';

  @override
  String get assignDriver => 'Assign Driver';

  @override
  String get changeDriver => 'Change Driver';

  @override
  String get unassignDriver => 'Unassign Driver';

  @override
  String get unassignDriverFailed => 'Could not unassign the driver';

  @override
  String get unassignDriverConfirm =>
      'Are you sure you want to unassign the current driver from this vehicle?';

  @override
  String get assignDriverFailed => 'Could not assign the driver';

  @override
  String get driverAssignedSuccess => 'Driver assigned successfully';

  @override
  String get driverUnassignedSuccess => 'Driver unassigned successfully';

  @override
  String get noDriverAssigned => 'No driver currently assigned';

  @override
  String get selectDriver => 'Select an Active Driver';

  @override
  String get noAvailableDrivers => 'No active unassigned drivers available.';

  @override
  String get noDriversFound => 'No drivers found';

  @override
  String get vehicleDetailsTitle => 'Vehicle Details';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabDocuments => 'Documents';

  @override
  String get tabMaintenance => 'Maintenance';

  @override
  String get vehicleSpecifications => 'Vehicle Specifications';

  @override
  String get assignedDriverCard => 'Assigned Driver';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get documentHistory => 'Document History';

  @override
  String get documentType => 'Document Type';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get isoDateFormat => 'YYYY-MM-DD';

  @override
  String get expiryState => 'Expiry State';

  @override
  String get docRegistration => 'Registration';

  @override
  String get docTaxToken => 'Tax Token';

  @override
  String get docInsurance => 'Insurance';

  @override
  String get docFitness => 'Fitness Certificate';

  @override
  String get docOther => 'Other';

  @override
  String get statusValid => 'Valid';

  @override
  String get statusExpiringSoon => 'Expiring Soon';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusNoExpiry => 'No Expiry Date';

  @override
  String get download => 'Download';

  @override
  String get selectFile => 'Select File';

  @override
  String fileSelected(Object name) {
    return 'Selected: $name';
  }

  @override
  String get uploadSuccess => 'Document uploaded successfully';

  @override
  String get acceptedDocumentTypes => 'Choose a PDF, JPG, or PNG (up to 10 MB)';

  @override
  String get unsupportedDocumentType => 'Choose a PDF, JPG, or PNG file';

  @override
  String get cannotReadSelectedFile =>
      'Could not read the selected file. Please choose it again.';

  @override
  String get documentFileTooLarge => 'The file must be 10 MB or smaller';

  @override
  String get selectDocumentFirst => 'Select a document before uploading';

  @override
  String get downloadLinkFailed => 'Could not create a document download link';

  @override
  String get noDocumentsYet => 'No documents uploaded yet.';

  @override
  String get addMaintenanceRecord => 'Add Maintenance Record';

  @override
  String get maintenanceHistory => 'Maintenance History';

  @override
  String get maintenanceType => 'Maintenance Type';

  @override
  String get cost => 'Cost (BDT)';

  @override
  String get costHint => 'e.g. 4500.00';

  @override
  String get costRequired => 'Cost is required';

  @override
  String get costInvalid => 'Enter a valid non-negative amount';

  @override
  String get workshop => 'Workshop / Vendor';

  @override
  String get workshopHint => 'e.g. Navana Toyota Service Center';

  @override
  String get notes => 'Notes / Remarks';

  @override
  String get maintenanceNotesHint => 'Describe the work performed';

  @override
  String get maintenanceDate => 'Maintenance Date';

  @override
  String get maintenanceScheduledService => 'Scheduled Service';

  @override
  String get maintenanceOilChange => 'Oil Change';

  @override
  String get maintenanceTireReplacement => 'Tire Replacement';

  @override
  String get maintenanceBrakeRepair => 'Brake Inspection / Repair';

  @override
  String get maintenanceEngineDiagnostics => 'Engine Diagnostics';

  @override
  String get maintenanceBatteryReplacement => 'Battery Replacement';

  @override
  String get maintenanceSuspensionAlignment => 'Suspension & Alignment';

  @override
  String get maintenanceBodyPaint => 'Body & Paint';

  @override
  String get maintenanceEmergencyRepair => 'Emergency Repair';

  @override
  String get maintenanceOther => 'Other';

  @override
  String get maintenanceAddedSuccess => 'Maintenance record added successfully';

  @override
  String get addMaintenanceFailed => 'Could not add the maintenance record';

  @override
  String get workshopRequired => 'Workshop name is required';

  @override
  String get noMaintenanceYet => 'No maintenance records recorded yet.';

  @override
  String get maintenanceThisMonth => 'Maintenance This Month';

  @override
  String get maintenanceRecordsCount => 'records';

  @override
  String get allTimeMaintenanceSpend => 'All-Time Maintenance Spend';

  @override
  String get recentMaintenanceTitle => 'Recent Maintenance';

  @override
  String get noRecentMaintenance => 'No recent maintenance records';

  @override
  String get expiringSoonTitle => 'Documents Expiring Soon';

  @override
  String get noExpiringSoonDocuments => 'No documents expiring soon';

  @override
  String get documentExpiryAlertTitle => 'Document Attention Required';

  @override
  String documentExpiryAlertExpired(int count) {
    return '$count document(s) have expired';
  }

  @override
  String documentExpiryAlertExpiring(int count) {
    return '$count document(s) expiring soon';
  }

  @override
  String get expiringDocumentsAttention => 'Documents Expiring Soon';

  @override
  String get expiredDocumentsAlert => 'Expired Documents';

  @override
  String get attentionRequired => 'Attention Required';

  @override
  String get allDocumentsHealthy =>
      'All vehicle documents are currently up-to-date.';
}
