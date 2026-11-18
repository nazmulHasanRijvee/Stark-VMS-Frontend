import 'package:flutter/foundation.dart';

/// Pure domain entity representing an uploaded vehicle document in Stark VMS.
@immutable
class VehicleDocument {
  final int id;
  final int? vehicleId;
  final String documentType;
  final String filename;
  final String contentType;
  final int sizeBytes;
  final String? expiryDate;
  final String expiryState;
  final String uploadedAt;
  final bool latest;

  const VehicleDocument({
    required this.id,
    this.vehicleId,
    required this.documentType,
    required this.filename,
    required this.contentType,
    required this.sizeBytes,
    this.expiryDate,
    required this.expiryState,
    required this.uploadedAt,
    required this.latest,
  });

  // Allowed Document Types
  static const String typeRegistration = 'Registration';
  static const String typeTaxToken = 'Tax Token';
  static const String typeInsurance = 'Insurance';
  static const String typeFitnessCertificate = 'Fitness Certificate';
  static const String typeOther = 'Other';

  static const List<String> allowedDocumentTypes = [
    typeRegistration,
    typeTaxToken,
    typeInsurance,
    typeFitnessCertificate,
    typeOther,
  ];

  // Document Expiry States returned by backend
  static const String expiryValid = 'VALID';
  static const String expiryExpiringSoon = 'EXPIRING_SOON';
  static const String expiryExpired = 'EXPIRED';
  static const String expiryNoExpiryDate = 'NO_EXPIRY_DATE';

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory VehicleDocument.fromMap(Map<String, dynamic> map) {
    return VehicleDocument(
      id: (map['id'] as num?)?.toInt() ?? 0,
      vehicleId: (map['vehicleId'] as num?)?.toInt(),
      documentType: map['documentType'] as String? ?? typeOther,
      filename: map['filename'] as String? ?? '',
      contentType: map['contentType'] as String? ?? '',
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      expiryDate: map['expiryDate'] as String?,
      expiryState: map['expiryState'] as String? ?? expiryNoExpiryDate,
      uploadedAt: map['uploadedAt'] as String? ?? '',
      latest: map['latest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'documentType': documentType,
      'filename': filename,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'expiryDate': expiryDate,
      'expiryState': expiryState,
      'uploadedAt': uploadedAt,
      'latest': latest,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleDocument &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VehicleDocument($id, $documentType, $filename, state: $expiryState, latest: $latest)';
}
