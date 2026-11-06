part of '../colors.dart';

abstract class AppBarColors {
  const AppBarColors();

  Color get background;
  Color get icon;
  Color get surfaceTint;
  Color get title;
}

class _LightAppBarColors extends AppBarColors {
  const _LightAppBarColors();

  @override
  Color get background => _Primitive.surfaceLight;

  @override
  Color get icon => _Primitive.iconLight;

  @override
  Color get surfaceTint => _Primitive.surfaceLight;

  @override
  Color get title => _Primitive.textPrimaryLight;
}

class _DarkAppBarColors extends AppBarColors {
  const _DarkAppBarColors();

  @override
  Color get background => _Primitive.surfaceDark;

  @override
  Color get icon => _Primitive.iconDark;

  @override
  Color get surfaceTint => _Primitive.surfaceDark;

  @override
  Color get title => _Primitive.textPrimaryDark;
}
