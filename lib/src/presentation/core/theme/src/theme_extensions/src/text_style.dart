import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class TextStyleExtension extends ThemeExtension<TextStyleExtension> {
  const TextStyleExtension();

  TextStyle get headLineLarge {
    return GoogleFonts.inter(
      height: 1.33,
      fontSize: 24,
      letterSpacing: -0.36,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle get headLineMedium {
    return GoogleFonts.inter(
      height: 1.40,
      fontSize: 20,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle get headLineSmall {
    return GoogleFonts.inter(
      height: 1.50,
      fontSize: 16,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle get bodyLarge {
    return GoogleFonts.inter(
      height: 1.47,
      fontSize: 15,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle get bodyMedium {
    return GoogleFonts.inter(
      height: 1.43,
      fontSize: 14,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle get bodySmall {
    return GoogleFonts.inter(
      height: 1.33,
      fontSize: 12,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle get labelLarge {
    return GoogleFonts.inter(
      height: 1.43,
      fontSize: 14,
      letterSpacing: 0.14,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle get labelMedium {
    return GoogleFonts.inter(
      height: 1.33,
      fontSize: 12,
      letterSpacing: 0.24,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle get labelSmall {
    return GoogleFonts.inter(
      height: 1.27,
      fontSize: 11,
      letterSpacing: 0.33,
      fontWeight: FontWeight.w600,
    );
  }

  /// Tabular numeric style for vehicle IDs and compact data cells.
  TextStyle get dataMedium {
    return GoogleFonts.inter(
      height: 1.38,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );
  }

  /// Large dashboard metric style.
  TextStyle get metricLarge {
    return GoogleFonts.inter(
      height: 1.25,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    );
  }

  @override
  ThemeExtension<TextStyleExtension> copyWith() => const TextStyleExtension();

  @override
  ThemeExtension<TextStyleExtension> lerp(
    covariant ThemeExtension<TextStyleExtension>? other,
    double t,
  ) {
    if (other is! TextStyleExtension) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
