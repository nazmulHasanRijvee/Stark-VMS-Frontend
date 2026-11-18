import 'package:material_ui/material_ui.dart';

import '../localization/app_localizations.dart';

extension LocalizationEx on BuildContext {
  /// Quick and clean accessor for localized strings throughout the UI.
  AppLocalizations get loc => AppLocalizations.of(this);
}

extension AppLocalizationsStatus on AppLocalizations {
  /// Returns the localized label for a vehicle or driver status value from the model.
  String localizedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return statusActive;
      case 'maintenance':
        return statusMaintenance;
      case 'inactive':
        return statusInactive;
      default:
        return status;
    }
  }

  String localizedDocumentType(String documentType) {
    switch (documentType.toUpperCase().replaceAll(' ', '_')) {
      case 'REGISTRATION':
        return docRegistration;
      case 'TAX_TOKEN':
        return docTaxToken;
      case 'INSURANCE':
        return docInsurance;
      case 'FITNESS':
      case 'FITNESS_CERTIFICATE':
        return docFitness;
      case 'OTHER':
        return docOther;
      default:
        return documentType;
    }
  }

  String localizedMaintenanceType(String maintenanceType) {
    switch (maintenanceType) {
      case 'Scheduled Service':
        return maintenanceScheduledService;
      case 'Oil Change':
        return maintenanceOilChange;
      case 'Tire Replacement':
        return maintenanceTireReplacement;
      case 'Brake Inspection / Repair':
        return maintenanceBrakeRepair;
      case 'Engine Diagnostics':
        return maintenanceEngineDiagnostics;
      case 'Battery Replacement':
        return maintenanceBatteryReplacement;
      case 'Suspension & Alignment':
        return maintenanceSuspensionAlignment;
      case 'Body & Paint':
        return maintenanceBodyPaint;
      case 'Emergency Repair':
        return maintenanceEmergencyRepair;
      case 'Other':
        return maintenanceOther;
      default:
        return maintenanceType;
    }
  }

  String localizedApiError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('license') &&
        (normalized.contains('duplicate') || normalized.contains('already'))) {
      return duplicateLicenseNumber;
    }
    if (normalized.contains('vehicle') &&
        (normalized.contains('duplicate') ||
            normalized.contains('already exists'))) {
      return duplicateVehicleNumber;
    }
    if (normalized.contains('unassign') ||
        normalized.contains('already assigned') ||
        normalized.contains('only active drivers')) {
      return driverAssignmentConflict;
    }
    if (normalized.contains('storage') || normalized.contains('supabase')) {
      return documentStorageUnavailable;
    }
    if (normalized.contains('maintenance') && normalized.contains('invalid')) {
      return maintenanceDetailsInvalid;
    }
    if (normalized.contains('pdf') ||
        normalized.contains('jpeg') ||
        normalized.contains('png') ||
        normalized.contains('uploaded file') ||
        normalized.contains('file content')) {
      return invalidDocumentFile;
    }
    if (normalized.contains('not found')) return resourceNotFound;
    return apiRequestFailed;
  }
}
