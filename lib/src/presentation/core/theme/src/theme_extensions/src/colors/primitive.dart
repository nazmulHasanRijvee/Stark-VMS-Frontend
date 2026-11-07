part of 'colors.dart';

/// Primitive color palette
///
/// Mapped directly to Stitch design tokens for Stark VMS.
class _Primitive {
  // ===========================================================================
  // 1. BRAND & ACCENTS (Buttons, Active States, Nav, Badges)
  // ===========================================================================

  /// Stitch: Primary Blue action / container
  static const Color brandPrimary = Color(0xFF1D4ED8);

  /// Stitch: Deep Navy Slate -> used for Desktop sidebar & headers
  static const Color brandSecondary = Color(0xFF0F172A);

  /// Stitch: Rating / Inspection warning
  static const Color accentYellow = Color(0xFFD97706);

  /// Stitch: Info Accent
  static const Color accentBlue = Color(0xFF2563EB);

  /// Stitch: Special Accent
  static const Color accentPurple = Color(0xFF7C3AED);

  // ===========================================================================
  // 2. BACKGROUNDS & SURFACES (Scaffolds, Cards, Modals)
  // ===========================================================================

  /// Stitch: Light mode crisp neutral scaffold background
  static const Color scaffoldLight = Color(0xFFF8FAFC);

  /// Stitch: Dark mode scaffold
  static const Color scaffoldDark = Color(0xFF0B1120);

  /// Stitch: Card & modal light surface
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Stitch: Dark mode card surface
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Stitch: Light subtle surface (for tables, input wrappers, etc.)
  static const Color surfaceSubtleLight = Color(0xFFF1F5F9);

  /// Stitch: Dark subtle surface
  static const Color surfaceSubtleDark = Color(0xFF141E33);

  // ===========================================================================
  // 3. TYPOGRAPHY / TEXT COLORS
  // ===========================================================================

  /// Stitch: Text Primary Light (Deep slate)
  static const Color textPrimaryLight = Color(0xFF0F172A);

  /// Stitch: Text Secondary Light (Muted slate)
  static const Color textSecondaryLight = Color(0xFF64748B);

  /// Stitch: Text Tertiary / Outline
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  /// Stitch: Text Primary Dark
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  /// Stitch: Text Secondary Dark
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ===========================================================================
  // 4. INPUTS & TEXT FIELDS
  // ===========================================================================

  /// Stitch: Text field fill light
  static const Color inputFillLight = Color(0xFFF8FAFC);

  /// Stitch: Text field fill dark
  static const Color inputFillDark = Color(0xFF0F172A);

  /// Stitch: Text field border light
  static const Color inputBorderLight = Color(0xFFCBD5E1);

  /// Stitch: Text field border dark
  static const Color inputBorderDark = Color(0xFF334155);

  /// Stitch: Text field focused border
  static const Color inputFocusBorder = brandPrimary;

  // ===========================================================================
  // 5. BORDERS, DIVIDERS & ICONS
  // ===========================================================================

  /// Stitch: Border Light
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Stitch: Border Dark
  static const Color borderDark = Color(0xFF334155);

  /// Stitch: Icon Light
  static const Color iconLight = Color(0xFF475569);

  /// Stitch: Icon Dark
  static const Color iconDark = Color(0xFF94A3B8);

  /// Stitch: Unselected / Inactive
  static const Color unselected = Color(0xFF94A3B8);

  // ===========================================================================
  // 6. STATUS / FEEDBACK & BADGES
  // ===========================================================================

  /// Stitch: Active Status Green
  static const Color success = Color(0xFF059669);
  static const Color successBgLight = Color(0xFFECFDF5);
  static const Color successFgLight = Color(0xFF065F46);
  static const Color successBgDark = Color(0xFF064E3B);
  static const Color successFgDark = Color(0xFF6EE7B7);

  /// Stitch: Error / Inactive Status Red
  static const Color error = Color(0xFFDC2626);
  static const Color errorBgLight = Color(0xFFFFF1F2);
  static const Color errorFgLight = Color(0xFF9F1239);
  static const Color errorBgDark = Color(0xFF881337);
  static const Color errorFgDark = Color(0xFFFECDD3);

  /// Stitch: In Service Status Amber
  static const Color warning = Color(0xFFD97706);
  static const Color warningBgLight = Color(0xFFFFFBEB);
  static const Color warningFgLight = Color(0xFF92400E);
  static const Color warningBgDark = Color(0xFF78350F);
  static const Color warningFgDark = Color(0xFFFDE68A);

  /// Stitch: Info Blue
  static const Color info = Color(0xFF2563EB);
  static const Color infoBgLight = Color(0xFFEFF6FF);
  static const Color infoFgLight = Color(0xFF1E40AF);
  static const Color infoBgDark = Color(0xFF1E3A8A);
  static const Color infoFgDark = Color(0xFF93C5FD);
}
