import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:stark_vms/src/core/localization/app_localizations.dart';
import 'package:stark_vms/src/presentation/core/theme/src/theme_extensions/src/colors/colors.dart';

void main() {
  group('AppLocalizations', () {
    test('English translations are accurate', () {
      final locEn = AppLocalizations(const Locale('en'));
      expect(locEn.appName, 'Stark VMS');
      expect(locEn.navDashboard, 'Dashboard');
      expect(locEn.navVehicles, 'Vehicles');
      expect(locEn.totalFleet, 'Total Fleet');
      expect(locEn.statusActive, 'Active');
      expect(locEn.statusInService, 'In Service');
      expect(locEn.statusInactive, 'Inactive');
      expect(locEn.showingPagination(1, 4, 4), 'Showing 1 to 4 of 4 vehicles');
    });

    test('Bangla translations are accurate and glyph-safe', () {
      final locBn = AppLocalizations(const Locale('bn'));
      expect(locBn.appName, 'স্টার্ক ভিএমএস');
      expect(locBn.navDashboard, 'ড্যাশবোর্ড');
      expect(locBn.navVehicles, 'যানবাহন');
      expect(locBn.totalFleet, 'মোট যানবাহন');
      expect(locBn.statusActive, 'সক্রিয়');
      expect(locBn.statusInService, 'সার্ভিসাধীন');
      expect(locBn.statusInactive, 'নিষ্ক্রিয়');
      expect(locBn.showingPagination(1, 4, 4), '4 টির মধ্যে 1 থেকে 4 টি দেখানো হচ্ছে');
    });
  });

  group('Theme Colors', () {
    test('Light and Dark color extensions provide valid contrast and tokens', () {
      const light = LightColorExtension();
      const dark = DarkColorExtension();

      expect(light.primary, isNotNull);
      expect(dark.primary, isNotNull);
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(dark.surface, const Color(0xFF1E293B));
      expect(light.scaffoldBackground, const Color(0xFFF8FAFC));
      expect(dark.scaffoldBackground, const Color(0xFF0B1120));
      expect(light.statusActiveBg, isNotNull);
      expect(dark.statusActiveBg, isNotNull);
    });
  });
}

