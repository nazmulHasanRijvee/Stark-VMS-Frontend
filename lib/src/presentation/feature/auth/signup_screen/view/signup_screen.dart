import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/extensions/localization_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/language_selector_pill.dart';
import '../../../../core/widgets/theme_mode_button.dart';
import '../../view_model/mock_auth_provider.dart';

/// Desktop-first, responsive Sign Up screen matching the Stitch design.
///
/// Fully theme-aware (Light & Dark) and localized (English & Bangla)
/// without hardcoded colors or styles.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _signupQueued = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_signupQueued || !(_formKey.currentState?.validate() ?? false)) return;

    _signupQueued = true;
    final fullName = _fullNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Let the current pointer/frame update finish before auth state refreshes
    // GoRouter and replaces this route.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _signupQueued = false;
      ref.read(mockAuthProvider.notifier).signUp(
            fullName: fullName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
          );
    });
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: context.textStyle.bodyMedium.copyWith(
        color: context.color.text.tertiary,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: context.sizes.iconSm,
        color: context.color.icon,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: context.color.textFieldFillColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.spacing.md2,
        vertical: context.spacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(color: context.color.textFieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(color: context.color.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(
          color: context.color.primary,
          width: context.sizes.focusStrokeWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(color: context.color.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
        borderSide: BorderSide(
          color: context.color.error,
          width: context.sizes.focusStrokeWidth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(mockAuthProvider);

    return Scaffold(
      backgroundColor: context.color.scaffoldBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.lg,
            vertical: context.spacing.xl,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.sizes.authCardMaxWidth,
            ),
            child: Container(
              padding: EdgeInsets.all(context.spacing.xl2), // 28px
              decoration: BoxDecoration(
                color: context.color.surface,
                borderRadius: BorderRadius.circular(context.radius.lg),
                border: Border.all(color: context.color.border),
                boxShadow: [
                  BoxShadow(
                    color: context.color.text.primary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top row: Brand + Language & Theme controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: context.color.primary,
                              size: context.sizes.sm,
                            ),
                            SizedBox(width: context.spacing.sm),
                            Text(
                              context.loc.brandTag,
                              style: context.textStyle.headLineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: context.color.text.primary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const LanguageSelectorPill(),
                            SizedBox(width: context.spacing.sm2),
                            const ThemeModeButton(),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: context.spacing.xl2),

                    // Title
                    Text(
                      context.loc.createAccountTitle,
                      style: context.textStyle.headLineLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: context.color.text.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.xs),
                    Text(
                      context.loc.createAccountSubtitle,
                      style: context.textStyle.bodyMedium.copyWith(
                        color: context.color.text.secondary,
                      ),
                    ),

                    if (authState.errorMessage != null) ...[
                      SizedBox(height: context.spacing.lg),
                      Container(
                        padding: EdgeInsets.all(context.spacing.md),
                        decoration: BoxDecoration(
                          color: context.color.errorBg,
                          borderRadius: BorderRadius.circular(context.radius.sm),
                          border: Border.all(
                            color: context.color.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: context.textStyle.bodySmall.copyWith(
                            color: context.color.error,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: context.spacing.lg2),

                    // Full Name Field
                    Text(
                      context.loc.fullName,
                      style: context.textStyle.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.color.text.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm2),
                    TextFormField(
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      style: context.textStyle.bodyMedium.copyWith(
                        color: context.color.text.primary,
                      ),
                      decoration: _buildInputDecoration(
                        context: context,
                        hintText: context.loc.fullNameHint,
                        prefixIcon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.loc.fullNameRequired;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: context.spacing.lg),

                    // Email Field
                    Text(
                      context.loc.email,
                      style: context.textStyle.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.color.text.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm2),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: context.textStyle.bodyMedium.copyWith(
                        color: context.color.text.primary,
                      ),
                      decoration: _buildInputDecoration(
                        context: context,
                        hintText: context.loc.emailHint,
                        prefixIcon: Icons.mail_outline,
                      ),
                      validator: (value) {
                        final val = value?.trim() ?? '';
                        if (val.isEmpty) return context.loc.emailRequired;
                        if (!val.contains('@') || !val.contains('.')) {
                          return context.loc.emailInvalid;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: context.spacing.lg),

                    // Password Field
                    Text(
                      context.loc.password,
                      style: context.textStyle.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.color.text.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm2),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      style: context.textStyle.bodyMedium.copyWith(
                        color: context.color.text.primary,
                      ),
                      decoration: _buildInputDecoration(
                        context: context,
                        hintText: context.loc.passwordHint,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: context.sizes.iconSm,
                            color: context.color.icon,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.loc.passwordRequired;
                        }
                        if (value.length < 6) {
                          return context.loc.passwordTooShort;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: context.spacing.lg),

                    // Confirm Password Field
                    Text(
                      context.loc.confirmPassword,
                      style: context.textStyle.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.color.text.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm2),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: context.textStyle.bodyMedium.copyWith(
                        color: context.color.text.primary,
                      ),
                      decoration: _buildInputDecoration(
                        context: context,
                        hintText: context.loc.confirmPasswordHint,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: context.sizes.iconSm,
                            color: context.color.icon,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.loc.confirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return context.loc.passwordMismatch;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: context.spacing.xl),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.primary,
                        foregroundColor: context.color.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: context.spacing.md2,
                        ),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.radius.sm),
                        ),
                      ),
                      icon: Icon(
                        Icons.person_add_outlined,
                        size: context.sizes.iconSm,
                        color: context.color.onPrimary,
                      ),
                      label: Text(
                        context.loc.createAccountButton,
                        style: context.textStyle.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.color.onPrimary,
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.lg2),

                    // Back to login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.loc.alreadyHaveAccount,
                          style: context.textStyle.bodySmall.copyWith(
                            color: context.color.text.secondary,
                          ),
                        ),
                        SizedBox(width: context.spacing.xs),
                        InkWell(
                          onTap: () => context.go(Routes.login.path),
                          borderRadius: BorderRadius.circular(context.radius.xs),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.spacing.xs,
                              vertical: context.spacing.xxs,
                            ),
                            child: Text(
                              context.loc.logInButton,
                              style: context.textStyle.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.color.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
