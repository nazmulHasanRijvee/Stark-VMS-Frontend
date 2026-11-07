import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../feature/auth/view_model/mock_auth_provider.dart';
import '../theme/theme.dart';
import '../widgets/language_selector_pill.dart';
import '../widgets/theme_mode_button.dart';

/// The unified responsive shell for Stark VMS.
///
/// Features:
/// - Desktop (>= 1024px): Persistent deep-navy left sidebar, top header with controls, and main content.
/// - Tablet & Mobile (< 1024px): Collapsible drawer containing the navy sidebar and responsive top app bar.
class VmsAppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const VmsAppShell({super.key, required this.navigationShell});

  void _onNavigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;
    final authState = ref.watch(mockAuthProvider);

    return Scaffold(
      backgroundColor: context.color.scaffoldBackground,
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: context.color.sidebarBackground,
              child: SafeArea(
                child: _buildSidebarContent(context, ref, isDrawer: true),
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: context.sizes.sidebarWidth,
              child: ColoredBox(
                color: context.color.sidebarBackground,
                child: SafeArea(child: _buildSidebarContent(context, ref)),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isDesktop, authState),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    WidgetRef ref, {
    bool isDrawer = false,
  }) {
    final currentIndex = navigationShell.currentIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Brand Header
        Container(
          height: context.sizes.headerHeight,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.lg2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.color.sidebarBorder),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: context.sizes.md,
                height: context.sizes.md,
                decoration: BoxDecoration(
                  color: context.color.primary,
                  borderRadius: BorderRadius.circular(context.radius.sm),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: context.color.onPrimary,
                  size: context.sizes.iconSm,
                ),
              ),
              SizedBox(width: context.spacing.md),
              Text(
                context.loc.appName,
                style: context.textStyle.headLineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: context.color.onPrimary,
                ),
              ),
            ],
          ),
        ),

        // Navigation Links
        SizedBox(height: context.spacing.lg),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Column(
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.dashboard_outlined,
                label: context.loc.navDashboard,
                isSelected: currentIndex == 0,
                onTap: () {
                  if (isDrawer) Navigator.of(context).pop();
                  _onNavigate(0);
                },
              ),
              SizedBox(height: context.spacing.xs),
              _buildNavItem(
                context: context,
                icon: Icons.directions_car_outlined,
                label: context.loc.navVehicles,
                isSelected: currentIndex == 1,
                onTap: () {
                  if (isDrawer) Navigator.of(context).pop();
                  _onNavigate(1);
                },
              ),
            ],
          ),
        ),

        const Spacer(),

        // Bottom Logout Item
        Divider(
          color: context.color.sidebarBorder,
          height: context.spacing.xxxs,
        ),
        Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: InkWell(
            onTap: () => _handleLogout(context, ref),
            borderRadius: BorderRadius.circular(context.radius.sm),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm3,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: context.color.text.tertiary,
                    size: context.sizes.iconSm,
                  ),
                  SizedBox(width: context.spacing.md),
                  Text(
                    context.loc.signOut,
                    style: context.textStyle.bodyMedium.copyWith(
                      color: context.color.text.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radius.sm),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.md2,
          vertical: context.spacing.sm3,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.color.primary
              : context.color.sidebarBackground,
          borderRadius: BorderRadius.circular(context.radius.sm),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: context.sizes.iconMd,
              color: isSelected
                  ? context.color.onPrimary
                  : context.color.text.tertiary,
            ),
            SizedBox(width: context.spacing.md),
            Text(
              label,
              style: context.textStyle.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? context.color.onPrimary
                    : context.color.text.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDesktop,
    MockAuthState authState,
  ) {
    final displayName = authState.userName.trim().isNotEmpty
        ? authState.userName.trim()
        : context.loc.defaultUserName;
    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      height: context.sizes.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      decoration: BoxDecoration(
        color: context.color.surface,
        border: Border(bottom: BorderSide(color: context.color.border)),
        boxShadow: [
          BoxShadow(
            color: context.color.text.primary.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            Builder(
              builder: (innerContext) => IconButton(
                icon: Icon(Icons.menu, color: context.color.text.primary),
                onPressed: () => Scaffold.of(innerContext).openDrawer(),
                tooltip: context.loc.openNavigation,
              ),
            ),
            SizedBox(width: context.spacing.sm),
          ],
          Text(
            navigationShell.currentIndex == 0
                ? context.loc.navDashboard
                : context.loc.navVehicles,
            style: context.textStyle.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: context.color.text.primary,
            ),
          ),
          const Spacer(),

          // Right Controls
          const LanguageSelectorPill(),
          SizedBox(width: context.spacing.sm),
          const ThemeModeButton(),
          SizedBox(width: context.spacing.md),
          Container(
            height: context.sizes.iconMd,
            width: context.spacing.xxxs,
            color: context.color.border,
          ),
          SizedBox(width: context.spacing.md),

          // User Profile Area
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.sizes.md,
                height: context.sizes.md,
                decoration: BoxDecoration(
                  color: context.color.infoBg,
                  borderRadius: BorderRadius.circular(context.radius.pill),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: context.textStyle.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.color.primary,
                    ),
                  ),
                ),
              ),
              if (isDesktop) ...[
                SizedBox(width: context.spacing.sm),
                Text(
                  displayName,
                  style: context.textStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.color.text.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    // Defer state mutation to the next frame to avoid triggering a widget-tree
    // rebuild (and GoRouter redirect) during an active pointer-event dispatch,
    // which causes the mouse_tracker.dart:199 "!_debugDuringDeviceUpdate" assertion.
    // The router's refreshListenable watches mockAuthProvider, so calling
    // logout() is sufficient — no manual context.go() needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mockAuthProvider.notifier).logout();
    });
  }
}
