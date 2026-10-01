import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Highly polished, Uber-style Phone Number Login Screen.
/// Includes country code selector pre-filled with +880 (Bangladesh),
/// modern phone number input with instant validation, demo autofill chip,
/// alternative social login options, and simulated OTP verification state.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  bool _isLoading = false;
  String _selectedCountryCode = '+880';
  String _selectedCountryFlag = '🇧🇩';

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  bool get _isPhoneValid {
    final raw = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    return raw.length >= 8;
  }

  Future<void> _handleContinue() async {
    if (!_isPhoneValid || _isLoading) return;

    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // Brief simulated dispatch delay
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    setState(() => _isLoading = false);

    final rawPhone = _phoneController.text.trim();
    final phone = rawPhone.isEmpty ? '1712 345 678' : rawPhone;
    final formattedPhone = '$_selectedCountryCode $phone';

    context.push('/otp', extra: formattedPhone);
  }

  void _autofillDemoNumber() {
    HapticFeedback.lightImpact();
    _phoneController.text = '1712345678';
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );
  }

  void _showCountrySelector() {
    HapticFeedback.lightImpact();
    final colors = AppColorsResolved.of(context);

    final countries = [
      {'code': '+880', 'flag': '🇧🇩', 'name': 'Bangladesh'},
      {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
      {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
      {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
      {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
      {'code': '+966', 'flag': '🇸🇦', 'name': 'Saudi Arabia'},
      {'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore'},
      {'code': '+60', 'flag': '🇲🇾', 'name': 'Malaysia'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Select Country Code',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: colors.divider),
                  itemBuilder: (_, index) {
                    final item = countries[index];
                    final isSelected = item['code'] == _selectedCountryCode;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      leading: Text(
                        item['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        item['name']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      trailing: Text(
                        item['code']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : colors.textSecondary,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountryCode = item['code']!;
                          _selectedCountryFlag = item['flag']!;
                        });
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: colors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                // ─── Top App Bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back / Skip button
                      IconButton(
                        onPressed: () => context.go('/home'),
                        icon: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),

                      // Skip to Guest Browsing
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go('/home');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Scrollable Body ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Brand Emblem & Tag
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.hub_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'ServiceHub',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Uber-style bold Header
                        Text(
                          'Enter your mobile number',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: colors.textPrimary,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'We\'ll send an SMS with a 6-digit verification code to confirm your phone number.',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ─── Uber-style Phone Input Box ────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _phoneFocusNode.hasFocus
                                  ? AppColors.primary
                                  : colors.border,
                              width: _phoneFocusNode.hasFocus ? 1.8 : 1.2,
                            ),
                            boxShadow: [
                              if (_phoneFocusNode.hasFocus)
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Country Picker Pill
                              InkWell(
                                onTap: _showCountrySelector,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedCountryFlag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedCountryCode,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: colors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Vertical Divider
                              Container(
                                width: 1,
                                height: 28,
                                color: colors.border,
                              ),

                              // Phone Input Field
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocusNode,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '1712 345 678',
                                    hintStyle: TextStyle(
                                      color: colors.textHint,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 16,
                                    ),
                                    suffixIcon: _phoneController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.cancel_rounded,
                                              size: 18,
                                              color: colors.textHint,
                                            ),
                                            onPressed: () {
                                              _phoneController.clear();
                                            },
                                          )
                                        : null,
                                  ),
                                  onSubmitted: (_) => _handleContinue(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Quick Demo Autofill helper
                        GestureDetector(
                          onTap: _autofillDemoNumber,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.flash_on_rounded,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Tap for Demo Number: 1712-345678',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFB388FF) : AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ─── "Or Continue With" Divider ───────────────────
                        Row(
                          children: [
                            Expanded(child: Divider(color: colors.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textHint,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: colors.border)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ─── Social Login Buttons ─────────────────────────
                        Row(
                          children: [
                            // Google Login Button
                            Expanded(
                              child: _SocialButton(
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Google',
                                iconSize: 28,
                                iconColor: const Color(0xFFEA4335),
                                colors: colors,
                                onTap: () {
                                  _autofillDemoNumber();
                                  _handleContinue();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Apple Login Button
                            Expanded(
                              child: _SocialButton(
                                icon: Icons.apple_rounded,
                                label: 'Apple',
                                iconSize: 22,
                                iconColor: colors.textPrimary,
                                colors: colors,
                                onTap: () {
                                  _autofillDemoNumber();
                                  _handleContinue();
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Email login pill
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              _autofillDemoNumber();
                              _handleContinue();
                            },
                            icon: Icon(
                              Icons.mail_outline_rounded,
                              size: 16,
                              color: colors.textSecondary,
                            ),
                            label: Text(
                              'Sign in with Email instead',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ─── Bottom Action Container ───────────────────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    bottomInset > 0 ? 12 : 24,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    border: Border(
                      top: BorderSide(
                        color: colors.border.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Terms & Policy Microcopy
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          'By continuing, you agree to our Terms of Service & Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: colors.textHint,
                          ),
                        ),
                      ),

                      // Large Prominent Continue / Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isPhoneValid && !_isLoading
                              ? _handleContinue
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: isDark
                                ? const Color(0xFF2A2A3C)
                                : const Color(0xFFE5E7EB),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: colors.textHint,
                            elevation: _isPhoneValid ? 4 : 0,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper component for social login options
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final Color iconColor;
  final AppColorsResolved colors;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.iconColor,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
