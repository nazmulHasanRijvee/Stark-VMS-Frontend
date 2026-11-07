import 'package:material_ui/material_ui.dart';

class Dimensions extends ThemeExtension<Dimensions> {
  const Dimensions();

  /// Desing-Tokens for spacing, radius, sizes etc.
  final spacing = const AppSpacing();
  final radius = const AppRadius();
  final sizes = const AppSizes();

  @override
  ThemeExtension<Dimensions> lerp(
    covariant ThemeExtension<Dimensions>? other,
    double t,
  ) {
    if (other is! Dimensions) {
      return this;
    }
    // Constants don't really lerp, but we return 'this' (or other if t >= 0.5)
    // as per previous behavior. If we wanted to lerp, we'd need to lerp the
    // fields, but these are just buckets of constants.
    return t < 0.5 ? this : other;
  }

  @override
  ThemeExtension<Dimensions> copyWith() {
    return const Dimensions();
  }
}

/// Spacing design tokens used for gaps, padding, margin, etc.
class AppSpacing {
  const AppSpacing();

  // ex. ex. extra small, 1.5 px
  final double xxxs = 1.5;

  // extra extra small, 2 px
  final double xxs = 2;

  // extra small, 4 px
  final double xs = 4;

  /// small 2, 6 px
  final double sm2 = 6;

  /// compact component padding, 10 px
  final double sm3 = 10;

  // small, 8 px
  final double sm = 8;

  // medium, 12 px
  final double md = 12;

  /// medium plus, 14 px
  final double md2 = 14;

  // large, 16 px
  final double lg = 16;

  /// large 2, 20 px
  final double lg2 = 20;

  /// large plus, 18 px
  final double lg3 = 18;

  // extra large, 24 px
  final double xl = 24;

  /// extra large plus, 28 px
  final double xl2 = 28;

  // extra extra large, 32 px
  final double xxl = 32;

  /// extra extra large2, 40 px
  final double xxl2 = 40;

  // extra extra extra large, 48 px
  final double xxxl = 48;

  // offset, 64 px
  final double offset = 64;
}

/// Border Radius design tokens
class AppRadius {
  const AppRadius();

  /// extra extra small, 2 px
  final double xxs = 2;

  /// extra small, 4 px
  final double xs = 4;

  /// between extra small and small, 6 px
  final double xs2 = 6;

  /// small, 8 px
  final double sm = 8;

  /// medium, 12 px
  final double md = 12;

  /// large, 16 px
  final double lg = 16;

  /// extra large, 24 px
  final double xl = 24;

  /// Fully rounded / pill shape.
  final double pill = 999;
}

/// Component size design tokens.
// Example:
// Icon, IconButton, SizedBox for buttons, CircleAvatar, Container sizes etc.
class AppSizes {
  const AppSizes();

  /// Desktop navigation rail width and shared top bar height.
  final double sidebarWidth = 256;
  final double headerHeight = 64;
  final double dropdownMaxHeight = 250;
  final double contentMaxWidth = 1200;
  final double authCardMaxWidth = 440;
  final double dialogMaxWidth = 440;
  final double vehicleFormMaxWidth = 880;
  final double filterInputWidth = 190;
  final double compactControlHeight = 42;
  final double paginationButtonSize = 32;
  final double paginationIndicatorSize = 28;
  final double focusStrokeWidth = 1.5;
  final double hairlineWidth = 1;
  final double iconXs = 14;
  final double iconSm = 18;
  final double iconMd = 20;
  final double iconLg = 28;
  final double iconBadge = 44;

  /// extra small, 16 px
  final double xs = 16;

  /// small, 24 px
  final double sm = 24;

  /// medium, 32 px
  final double md = 32;

  /// medium 2, 40 px
  final double md2 = 40;

  /// large, 48 px
  final double lg = 48;

  /// large 2, 56 px
  final double lg2 = 56;

  /// extra large, 64 px
  final double xl = 64;

  /// extra extra large, 80 px
  final double xxl = 80;

  /// extra extra extra large, 100 px
  final double xxxl = 100;
}
