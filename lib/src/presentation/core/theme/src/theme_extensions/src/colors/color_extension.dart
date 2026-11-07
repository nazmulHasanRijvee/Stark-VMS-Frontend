part of 'colors.dart';

abstract interface class ColorExtension {
  const ColorExtension({
    required this.primary,
    required this.secondary,
    required this.onPrimary,
    required this.accent,
    required this.scaffoldBackground,
    required this.surface,
    required this.surfaceSubtle,
    required this.sidebarBackground,
    required this.sidebarBorder,
    required this.border,
    required this.icon,
    required this.success,
    required this.successBg,
    required this.successFg,
    required this.error,
    required this.errorBg,
    required this.errorFg,
    required this.warning,
    required this.warningBg,
    required this.warningFg,
    required this.info,
    required this.infoBg,
    required this.infoFg,
    required this.disabled,
    required this.active,
    required this.inactive,
    required this.text,
    required this.textFieldFillColor,
    required this.textFieldBorderColor,
    required this.textFieldFocusBorderColor,
    required this.appBar,
    required this.bottomNavBar,
    required this.pageView,
  });

  final Color primary;
  final Color secondary;
  final Color onPrimary;
  final AccentColors accent;
  final Color scaffoldBackground;
  final Color surface;
  final Color surfaceSubtle;
  final Color sidebarBackground;
  final Color sidebarBorder;
  final Color border;
  final Color icon;

  final Color success;
  final Color successBg;
  final Color successFg;

  final Color error;
  final Color errorBg;
  final Color errorFg;

  final Color warning;
  final Color warningBg;
  final Color warningFg;

  final Color info;
  final Color infoBg;
  final Color infoFg;

  final Color disabled;
  final Color active;
  final Color inactive;

  final Color textFieldFillColor;
  final Color textFieldBorderColor;
  final Color textFieldFocusBorderColor;
  final TextColors text;

  final AppBarColors appBar;
  final BottomNavBarColors bottomNavBar;
  final PageViewColors pageView;

  // Convenient aliases for vehicle status badges
  Color get statusActiveBg => successBg;
  Color get statusActiveFg => successFg;
  Color get statusInServiceBg => warningBg;
  Color get statusInServiceFg => warningFg;
  Color get statusInactiveBg => errorBg;
  Color get statusInactiveFg => errorFg;
}

class LightColorExtension extends ThemeExtension<LightColorExtension>
    implements ColorExtension {
  const LightColorExtension({
    this.primary = _Primitive.brandPrimary,
    this.secondary = _Primitive.brandSecondary,
    this.onPrimary = _Primitive.textPrimaryDark,
    this.accent = const _LightAccentColors(),
    this.scaffoldBackground = _Primitive.scaffoldLight,
    this.surface = _Primitive.surfaceLight,
    this.surfaceSubtle = _Primitive.surfaceSubtleLight,
    this.sidebarBackground = _Primitive.brandSecondary,
    this.sidebarBorder = const Color(0xFF1E293B),
    this.border = _Primitive.borderLight,
    this.icon = _Primitive.iconLight,
    this.success = _Primitive.success,
    this.successBg = _Primitive.successBgLight,
    this.successFg = _Primitive.successFgLight,
    this.error = _Primitive.error,
    this.errorBg = _Primitive.errorBgLight,
    this.errorFg = _Primitive.errorFgLight,
    this.warning = _Primitive.warning,
    this.warningBg = _Primitive.warningBgLight,
    this.warningFg = _Primitive.warningFgLight,
    this.info = _Primitive.info,
    this.infoBg = _Primitive.infoBgLight,
    this.infoFg = _Primitive.infoFgLight,
    this.disabled = _Primitive.borderLight,
    this.active = _Primitive.brandPrimary,
    this.inactive = _Primitive.unselected,
    this.text = const _LightTextColors(),
    this.textFieldFillColor = _Primitive.inputFillLight,
    this.textFieldBorderColor = _Primitive.inputBorderLight,
    this.textFieldFocusBorderColor = _Primitive.inputFocusBorder,
    this.appBar = const _LightAppBarColors(),
    this.bottomNavBar = const _LightBottomNavBarColors(),
    this.pageView = const _LightPageViewColors(),
  });

  @override
  final Color primary;

  @override
  final Color secondary;

  @override
  final Color onPrimary;

  @override
  final AccentColors accent;

  @override
  final Color scaffoldBackground;

  @override
  final Color surface;

  @override
  final Color surfaceSubtle;

  @override
  final Color sidebarBackground;

  @override
  final Color sidebarBorder;

  @override
  final Color border;

  @override
  final Color icon;

  @override
  final Color success;

  @override
  final Color successBg;

  @override
  final Color successFg;

  @override
  final Color error;

  @override
  final Color errorBg;

  @override
  final Color errorFg;

  @override
  final Color warning;

  @override
  final Color warningBg;

  @override
  final Color warningFg;

  @override
  final Color info;

  @override
  final Color infoBg;

  @override
  final Color infoFg;

  @override
  final Color disabled;

  @override
  final Color active;

  @override
  final Color inactive;

  @override
  final Color textFieldFillColor;

  @override
  final Color textFieldBorderColor;

  @override
  final Color textFieldFocusBorderColor;

  @override
  final TextColors text;

  @override
  final AppBarColors appBar;

  @override
  final BottomNavBarColors bottomNavBar;

  @override
  final PageViewColors pageView;

  @override
  Color get statusActiveBg => successBg;
  @override
  Color get statusActiveFg => successFg;
  @override
  Color get statusInServiceBg => warningBg;
  @override
  Color get statusInServiceFg => warningFg;
  @override
  Color get statusInactiveBg => errorBg;
  @override
  Color get statusInactiveFg => errorFg;

  @override
  LightColorExtension copyWith({
    Color? primary,
    Color? secondary,
    Color? onPrimary,
    AccentColors? accent,
    Color? scaffoldBackground,
    Color? surface,
    Color? surfaceSubtle,
    Color? sidebarBackground,
    Color? sidebarBorder,
    Color? border,
    Color? icon,
    Color? success,
    Color? successBg,
    Color? successFg,
    Color? error,
    Color? errorBg,
    Color? errorFg,
    Color? warning,
    Color? warningBg,
    Color? warningFg,
    Color? info,
    Color? infoBg,
    Color? infoFg,
    Color? disabled,
    Color? active,
    Color? inactive,
    Color? textFieldFillColor,
    Color? textFieldBorderColor,
    Color? textFieldFocusBorderColor,
    TextColors? text,
    AppBarColors? appBar,
    BottomNavBarColors? bottomNavBar,
    PageViewColors? pageView,
  }) {
    return LightColorExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      border: border ?? this.border,
      icon: icon ?? this.icon,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      successFg: successFg ?? this.successFg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      errorFg: errorFg ?? this.errorFg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      warningFg: warningFg ?? this.warningFg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      infoFg: infoFg ?? this.infoFg,
      disabled: disabled ?? this.disabled,
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
      textFieldFillColor: textFieldFillColor ?? this.textFieldFillColor,
      textFieldBorderColor: textFieldBorderColor ?? this.textFieldBorderColor,
      textFieldFocusBorderColor:
          textFieldFocusBorderColor ?? this.textFieldFocusBorderColor,
      text: text ?? this.text,
      appBar: appBar ?? this.appBar,
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      pageView: pageView ?? this.pageView,
    );
  }

  @override
  ThemeExtension<LightColorExtension> lerp(
    covariant ThemeExtension<LightColorExtension>? other,
    double t,
  ) {
    if (other is! LightColorExtension) {
      return this;
    }

    return LightColorExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: t < 0.5 ? accent : other.accent,
      scaffoldBackground: Color.lerp(
        scaffoldBackground,
        other.scaffoldBackground,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      sidebarBackground: Color.lerp(
        sidebarBackground,
        other.sidebarBackground,
        t,
      )!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      border: Color.lerp(border, other.border, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successFg: Color.lerp(successFg, other.successFg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      errorFg: Color.lerp(errorFg, other.errorFg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningFg: Color.lerp(warningFg, other.warningFg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoFg: Color.lerp(infoFg, other.infoFg, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      active: Color.lerp(active, other.active, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      textFieldFillColor: Color.lerp(
        textFieldFillColor,
        other.textFieldFillColor,
        t,
      )!,
      textFieldBorderColor: Color.lerp(
        textFieldBorderColor,
        other.textFieldBorderColor,
        t,
      )!,
      textFieldFocusBorderColor: Color.lerp(
        textFieldFocusBorderColor,
        other.textFieldFocusBorderColor,
        t,
      )!,
      text: t < 0.5 ? text : other.text,
      appBar: t < 0.5 ? appBar : other.appBar,
      bottomNavBar: t < 0.5 ? bottomNavBar : other.bottomNavBar,
      pageView: t < 0.5 ? pageView : other.pageView,
    );
  }
}

class DarkColorExtension extends ThemeExtension<DarkColorExtension>
    implements ColorExtension {
  const DarkColorExtension({
    this.primary = _Primitive.brandPrimary,
    this.secondary = _Primitive.brandSecondary,
    this.onPrimary = _Primitive.textPrimaryDark,
    this.accent = const _DarkAccentColors(),
    this.scaffoldBackground = _Primitive.scaffoldDark,
    this.surface = _Primitive.surfaceDark,
    this.surfaceSubtle = _Primitive.surfaceSubtleDark,
    this.sidebarBackground = const Color(0xFF0F172A),
    this.sidebarBorder = _Primitive.borderDark,
    this.border = _Primitive.borderDark,
    this.icon = _Primitive.iconDark,
    this.success = _Primitive.success,
    this.successBg = _Primitive.successBgDark,
    this.successFg = _Primitive.successFgDark,
    this.error = _Primitive.error,
    this.errorBg = _Primitive.errorBgDark,
    this.errorFg = _Primitive.errorFgDark,
    this.warning = _Primitive.warning,
    this.warningBg = _Primitive.warningBgDark,
    this.warningFg = _Primitive.warningFgDark,
    this.info = _Primitive.info,
    this.infoBg = _Primitive.infoBgDark,
    this.infoFg = _Primitive.infoFgDark,
    this.disabled = _Primitive.borderDark,
    this.active = _Primitive.brandPrimary,
    this.inactive = _Primitive.unselected,
    this.text = const _DarkTextColors(),
    this.textFieldFillColor = _Primitive.inputFillDark,
    this.textFieldBorderColor = _Primitive.inputBorderDark,
    this.textFieldFocusBorderColor = _Primitive.inputFocusBorder,
    this.appBar = const _DarkAppBarColors(),
    this.bottomNavBar = const _DarkBottomNavBarColors(),
    this.pageView = const _DarkPageViewColors(),
  });

  @override
  final Color primary;

  @override
  final Color secondary;

  @override
  final Color onPrimary;

  @override
  final AccentColors accent;

  @override
  final Color scaffoldBackground;

  @override
  final Color surface;

  @override
  final Color surfaceSubtle;

  @override
  final Color sidebarBackground;

  @override
  final Color sidebarBorder;

  @override
  final Color border;

  @override
  final Color icon;

  @override
  final Color success;

  @override
  final Color successBg;

  @override
  final Color successFg;

  @override
  final Color error;

  @override
  final Color errorBg;

  @override
  final Color errorFg;

  @override
  final Color warning;

  @override
  final Color warningBg;

  @override
  final Color warningFg;

  @override
  final Color info;

  @override
  final Color infoBg;

  @override
  final Color infoFg;

  @override
  final Color disabled;

  @override
  final Color active;

  @override
  final Color inactive;

  @override
  final Color textFieldFillColor;

  @override
  final Color textFieldBorderColor;

  @override
  final Color textFieldFocusBorderColor;

  @override
  final TextColors text;

  @override
  final AppBarColors appBar;

  @override
  final BottomNavBarColors bottomNavBar;

  @override
  final PageViewColors pageView;

  @override
  Color get statusActiveBg => successBg;
  @override
  Color get statusActiveFg => successFg;
  @override
  Color get statusInServiceBg => warningBg;
  @override
  Color get statusInServiceFg => warningFg;
  @override
  Color get statusInactiveBg => errorBg;
  @override
  Color get statusInactiveFg => errorFg;

  @override
  DarkColorExtension copyWith({
    Color? primary,
    Color? secondary,
    Color? onPrimary,
    AccentColors? accent,
    Color? scaffoldBackground,
    Color? surface,
    Color? surfaceSubtle,
    Color? sidebarBackground,
    Color? sidebarBorder,
    Color? border,
    Color? icon,
    Color? success,
    Color? successBg,
    Color? successFg,
    Color? error,
    Color? errorBg,
    Color? errorFg,
    Color? warning,
    Color? warningBg,
    Color? warningFg,
    Color? info,
    Color? infoBg,
    Color? infoFg,
    Color? disabled,
    Color? active,
    Color? inactive,
    Color? textFieldFillColor,
    Color? textFieldBorderColor,
    Color? textFieldFocusBorderColor,
    TextColors? text,
    AppBarColors? appBar,
    BottomNavBarColors? bottomNavBar,
    PageViewColors? pageView,
  }) {
    return DarkColorExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      border: border ?? this.border,
      icon: icon ?? this.icon,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      successFg: successFg ?? this.successFg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      errorFg: errorFg ?? this.errorFg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      warningFg: warningFg ?? this.warningFg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      infoFg: infoFg ?? this.infoFg,
      disabled: disabled ?? this.disabled,
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
      textFieldFillColor: textFieldFillColor ?? this.textFieldFillColor,
      textFieldBorderColor: textFieldBorderColor ?? this.textFieldBorderColor,
      textFieldFocusBorderColor:
          textFieldFocusBorderColor ?? this.textFieldFocusBorderColor,
      text: text ?? this.text,
      appBar: appBar ?? this.appBar,
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      pageView: pageView ?? this.pageView,
    );
  }

  @override
  ThemeExtension<DarkColorExtension> lerp(
    covariant ThemeExtension<DarkColorExtension>? other,
    double t,
  ) {
    if (other is! DarkColorExtension) {
      return this;
    }

    return DarkColorExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: t < 0.5 ? accent : other.accent,
      scaffoldBackground: Color.lerp(
        scaffoldBackground,
        other.scaffoldBackground,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      sidebarBackground: Color.lerp(
        sidebarBackground,
        other.sidebarBackground,
        t,
      )!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      border: Color.lerp(border, other.border, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successFg: Color.lerp(successFg, other.successFg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      errorFg: Color.lerp(errorFg, other.errorFg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningFg: Color.lerp(warningFg, other.warningFg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoFg: Color.lerp(infoFg, other.infoFg, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      active: Color.lerp(active, other.active, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      textFieldFillColor: Color.lerp(
        textFieldFillColor,
        other.textFieldFillColor,
        t,
      )!,
      textFieldBorderColor: Color.lerp(
        textFieldBorderColor,
        other.textFieldBorderColor,
        t,
      )!,
      textFieldFocusBorderColor: Color.lerp(
        textFieldFocusBorderColor,
        other.textFieldFocusBorderColor,
        t,
      )!,
      text: t < 0.5 ? text : other.text,
      appBar: t < 0.5 ? appBar : other.appBar,
      bottomNavBar: t < 0.5 ? bottomNavBar : other.bottomNavBar,
      pageView: t < 0.5 ? pageView : other.pageView,
    );
  }
}
