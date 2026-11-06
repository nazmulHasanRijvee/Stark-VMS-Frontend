# Rule: Theme System, Design Tokens & Extensions

Stark VMS utilizes a strict, centralized Design Token system implemented via Flutter `ThemeExtension` on `BuildContext`.

## 1. Accessing Theme Elements via `BuildContext`

Always use the convenient getters exported by `lib/src/presentation/core/theme/theme.dart`:

```dart
// Colors
final colors = context.color;
colors.primary;              // Brand primary color (Color(0xFF002335))
colors.secondary;            // Brand secondary color (Color(0xFF00131C))
colors.scaffoldBackground;   // Light or dark scaffold background
colors.border;               // Card/container border
colors.icon;                 // Standard icon color
colors.text.primary;         // Primary text color
colors.text.secondary;       // Secondary / subtitle text color
colors.text.tertiary;        // Disabled / hint text color
colors.accent.yellow;        // Rating, stars, warning accent
colors.accent.blue;          // Informational accent
colors.accent.purple;        // Special accent
colors.success;              // Positive status / active fleet
colors.error;                // Critical alerts, maintenance required
colors.warning;              // Due for inspection

// Spacing (Gaps, Padding, Margin)
context.spacing.xxxs;        // 1.5 px
context.spacing.xxs;         // 2 px
context.spacing.xs;          // 4 px
context.spacing.sm2;         // 6 px
context.spacing.sm;          // 8 px
context.spacing.md;          // 12 px
context.spacing.lg;          // 16 px
context.spacing.lg2;         // 20 px
context.spacing.xl;          // 24 px
context.spacing.xxl;         // 32 px
context.spacing.xxl2;        // 40 px
context.spacing.xxxl;        // 48 px
context.spacing.offset;      // 64 px

// Radius (BorderRadius)
context.radius.xxs;          // 2 px
context.radius.xs;           // 4 px
context.radius.sm;           // 8 px
context.radius.md;           // 12 px
context.radius.lg;           // 16 px
context.radius.xl;           // 24 px
context.radius.pill;         // 999 px (fully rounded badge/pill)

// Component Sizes (Icons, Avatars, Buttons)
context.sizes.xs;            // 16 px
context.sizes.sm;            // 24 px
context.sizes.md;            // 32 px
context.sizes.md2;           // 40 px
context.sizes.lg;            // 48 px
context.sizes.lg2;           // 56 px
context.sizes.xl;            // 64 px
context.sizes.xxl;           // 80 px
context.sizes.xxxl;          // 100 px

// Typography (GoogleFonts Manrope)
context.textStyle.headLineLarge;   // 24px, w600, h1.40
context.textStyle.headLineMedium;  // 20px, w600, h1.40
context.textStyle.headLineSmall;   // 18px, w500, h1.33
context.textStyle.bodyLarge;       // 16px, w400, h1.50
context.textStyle.bodyMedium;      // 14px, w400, h1.42
context.textStyle.bodySmall;       // 12px, w400, h1.42
context.textStyle.labelLarge;      // 16px, w500, h1.15
context.textStyle.labelMedium;     // 14px, w500, h1.15
context.textStyle.labelSmall;      // 12px, w500, h1.15
```

## 2. Primitive Color Palette

Figma tokens are defined in `lib/src/presentation/core/theme/src/theme_extensions/src/colors/primitive.dart` under `_Primitive`:
- Brand: `brandPrimary` (`#002335`), `brandSecondary` (`#00131C`)
- Surface: `scaffoldLight` (`#F5F1E8`), `scaffoldDark` (`#141414`), `surfaceDark` (`#2B2B2B`)
- Text: `textPrimaryLight` (`#1F1F1F`), `textPrimaryDark` (`#FFFFFF`), `textSecondaryLight` (`#757575`), `textSecondaryDark` (`#B0B0B0`)
- Inputs: `inputFill` (`#FDF8F8`), `inputBorder` (`#E5E5E5`), `inputFocusBorder` (`brandPrimary`)
- Status: `success` (`#008000`), `error` (`#FF0000`), `warning` (`#FFFF00`), `info` (`brandPrimary`)

When adding new Figma color tokens, register them in `_Primitive` and expose them through `ColorExtension`, `LightColorExtension`, and `DarkColorExtension`.

## 3. Strict Rules
- ❌ NEVER use raw numbers for padding or margins like `EdgeInsets.all(16.0)` or `SizedBox(height: 8.0)`. Instead:
  `EdgeInsets.all(context.spacing.lg)`
  `SizedBox(height: context.spacing.sm)`
- ❌ NEVER hardcode `TextStyle(fontFamily: ...)` or arbitrary font sizes. Always base text on `context.textStyle.*.copyWith(...)`.
- ❌ NEVER hardcode hex colors in widgets. All colors must resolve from `context.color.*`.

