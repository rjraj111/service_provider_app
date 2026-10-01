import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

/// A premium, billion-dollar user profile & dashboard screen.
/// Includes user header, quick stats, active booking spotlight,
/// preferences (dark mode & language), payment methods, and account security.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = 'Jahedul Islam';
  String _userEmail = 'jahedul.islam@servicehub.com';
  String _userPhone = '+880 1812-345678';
  String _userAddress = 'Home - Chittagong (GEC Circle, Nasirabad)';
  final int _totalBookings = 12;
  final int _rewardPoints = 450;

  void _showEditProfileDialog() {
    final colors = AppColorsResolved.of(context);
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: colors.border),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textHint.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile Information',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEditTextField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                colors: colors,
              ),
              const SizedBox(height: 14),
              _buildEditTextField(
                controller: emailController,
                label: 'Email Address',
                icon: Icons.mail_outline_rounded,
                colors: colors,
              ),
              const SizedBox(height: 14),
              _buildEditTextField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                colors: colors,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _userName = nameController.text.trim();
                      _userEmail = emailController.text.trim();
                      _userPhone = phoneController.text.trim();
                    });
                    Navigator.of(ctx).pop();
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppColorsResolved colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 14, color: colors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12.5, color: colors.textSecondary),
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _showAddressesSheet() {
    final colors = AppColorsResolved.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textHint.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Addresses',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address map picker opened.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                  label: const Text('Add New'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddressCard(
              title: 'Home',
              subtitle: 'GEC Circle, Nasirabad, Chittagong',
              isDefault: true,
              icon: Icons.home_rounded,
              colors: colors,
              onTap: () {
                setState(() => _userAddress = 'Home - Chittagong (GEC Circle)');
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 10),
            _buildAddressCard(
              title: 'Office',
              subtitle: 'Agrabad C/A, Commercial Area, Chittagong',
              isDefault: false,
              icon: Icons.business_rounded,
              colors: colors,
              onTap: () {
                setState(() => _userAddress = 'Office - Agrabad C/A, Chittagong');
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String subtitle,
    required bool isDefault,
    required IconData icon,
    required AppColorsResolved colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDefault ? AppColors.primary.withValues(alpha: 0.06) : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDefault ? AppColors.primary : colors.border,
            width: isDefault ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDefault ? AppColors.primary : colors.textHint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDefault ? Colors.white : colors.textPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded, color: isDefault ? AppColors.primary : Colors.transparent, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet() {
    final colors = AppColorsResolved.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textHint.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Linked Payment Accounts',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _buildPaymentMethodTile(
              title: 'bKash Wallet',
              account: '018****4567 (Verified)',
              color: const Color(0xFFE2136E),
              icon: Icons.account_balance_wallet_rounded,
              colors: colors,
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodTile(
              title: 'Nagad Account',
              account: '017****8890 (Linked)',
              color: const Color(0xFFF7941D),
              icon: Icons.payments_rounded,
              colors: colors,
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodTile(
              title: 'Visa Platinum Card',
              account: '•••• 4092 (Expires 08/28)',
              color: const Color(0xFF1A1F71),
              icon: Icons.credit_card_rounded,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String account,
    required Color color,
    required IconData icon,
    required AppColorsResolved colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  account,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  void _showSettingsModal() {
    final colors = AppColorsResolved.of(context);
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isModalDark = ref.watch(themeModeProvider) == ThemeMode.dark;
          final modalLocale = ref.watch(localeProvider);

          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textHint.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Settings & Privacy Preferences',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Dark mode switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isModalDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Dark Theme Mode',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                        ),
                      ),
                      Switch.adaptive(
                        value: isModalDark,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Language Selector
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.language_rounded, color: Color(0xFF10B981), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'App Language (${l10n.language})',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('English (US)')),
                              selected: modalLocale.languageCode == 'en',
                              onSelected: (_) {
                                ref.read(localeProvider.notifier).state = const Locale('en');
                                setModalState(() {});
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: modalLocale.languageCode == 'en' ? Colors.white : colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('বাংলা (BN)')),
                              selected: modalLocale.languageCode == 'bn',
                              onSelected: (_) {
                                ref.read(localeProvider.notifier).state = const Locale('bn');
                                setModalState(() {});
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: modalLocale.languageCode == 'bn' ? Colors.white : colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Push notifications
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Push Notifications & Alerts',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    final colors = AppColorsResolved.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out from your ServiceHub account on this device?',
          style: TextStyle(color: colors.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed out successfully.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18, topPadding + 12, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Profile Header Card ─────────────────────────────────────
            _buildProfileHeaderCard(colors),

            const SizedBox(height: 18),

            // ─── 2. Quick Stats Row ─────────────────────────────────────────
            _buildQuickStatsRow(colors),

            const SizedBox(height: 20),

            // ─── 3. Active Booking Spotlight Banner ─────────────────────────
            _buildActiveBookingBanner(colors),

            const SizedBox(height: 20),

            // ─── 3.5 Switch to Provider Mode Hero Banner ────────────────────
            _buildSwitchToProviderBanner(colors),

            const SizedBox(height: 24),

            // ─── 4. Account & Activity Section ──────────────────────────────
            _buildSectionTitle('Account & Activity', colors),
            const SizedBox(height: 10),
            _buildMenuContainer(
              colors: colors,
              items: [
                _MenuItemData(
                  icon: Icons.storefront_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Switch to Provider Mode',
                  subtitle: 'Earn money offering plumbing, repair & cleaning',
                  badgeText: 'Driver Mode',
                  badgeColor: const Color(0xFF8B5CF6),
                  onTap: () {
                    context.push('/provider-dashboard');
                  },
                ),
                _MenuItemData(
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'My Bookings',
                  subtitle: 'History & scheduled home services',
                  badgeText: '1 Active',
                  badgeColor: AppColors.success,
                  onTap: () {
                    context.push(
                      '/tracking',
                      extra: {
                        'providerName': 'Rahim Uddin',
                        'profession': 'Plumber · 8 yrs exp',
                        'eta': '12 mins',
                        'distance': '1.8 km',
                      },
                    );
                  },
                ),
                _MenuItemData(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Saved Addresses',
                  subtitle: _userAddress,
                  onTap: _showAddressesSheet,
                ),
                _MenuItemData(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFFE2136E),
                  title: 'Payment Methods',
                  subtitle: 'bKash, Nagad, Visa Cards',
                  onTap: _showPaymentMethodsSheet,
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ─── 5. Preferences & Settings Section ──────────────────────────
            _buildSectionTitle('Preferences & System', colors),
            const SizedBox(height: 10),
            _buildMenuContainer(
              colors: colors,
              items: [
                _MenuItemData(
                  icon: Icons.tune_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Settings & Privacy',
                  subtitle: 'Theme, Language, Notifications',
                  onTap: _showSettingsModal,
                ),
                _MenuItemData(
                  icon: Icons.headset_mic_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: '24/7 Help & Support',
                  subtitle: 'Live safety concierge & dispute desk',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Support line connected: 16216 (Toll-Free).'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ─── 6. Log Out Button ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                onTap: _showLogoutDialog,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
                subtitle: const Text(
                  'Sign out of this device securely',
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.error, size: 15),
              ),
            ),

            const SizedBox(height: 18),

            // App Version Footer
            Center(
              child: Text(
                'ServiceHub Enterprise v2.4.0 (Build 880)\nSecured with End-to-End Encryption',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textHint.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Profile Header Card ───────────────────────────────────────────────────

  Widget _buildProfileHeaderCard(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            Color(0xFF4C1D95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Large Circular Avatar with Camera overlay
              Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white24,
                          child: const Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _showEditProfileDialog,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name, Email, & Member Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF67E8F9)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.military_tech_rounded, size: 13, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text(
                            'VIP GOLD MEMBER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 14),

          // Bottom Edit Profile Button
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Edit Profile Information',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Stats Row ───────────────────────────────────────────────────────

  Widget _buildQuickStatsRow(AppColorsResolved colors) {
    return Row(
      children: [
        // Total Bookings Card
        Expanded(
          child: _buildStatCard(
            title: 'Total Bookings',
            value: '$_totalBookings',
            subtitle: 'Lifetime Completed',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF3B82F6),
            colors: colors,
          ),
        ),
        const SizedBox(width: 12),

        // Reward Points Card
        Expanded(
          child: _buildStatCard(
            title: 'Reward Points',
            value: '$_rewardPoints',
            subtitle: '৳450 Wallet Value',
            icon: Icons.stars_rounded,
            color: const Color(0xFFF59E0B),
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required AppColorsResolved colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.arrow_outward_rounded, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Active Booking Spotlight Banner ───────────────────────────────────────

  Widget _buildActiveBookingBanner(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            const Color(0xFF10B981).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.success, blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE ONGOING SERVICE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '12 MINS AWAY',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=200',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: AppColors.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rahim Uddin (Plumber)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'En route to GEC Circle, Nasirabad',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      '/tracking',
                      extra: {
                        'providerName': 'Rahim Uddin',
                        'profession': 'Plumber · 8 yrs exp',
                        'eta': '12 mins',
                        'distance': '1.8 km',
                      },
                    );
                  },
                  icon: const Icon(Icons.near_me_rounded, size: 15, color: Colors.white),
                  label: const Text('Live Tracking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      '/chat',
                      extra: {
                        'providerName': 'Rahim Uddin',
                        'serviceName': 'Plumber · 8 yrs exp',
                      },
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                  label: const Text('Live Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Switch to Provider Mode Banner ────────────────────────────────────────

  Widget _buildSwitchToProviderBanner(AppColorsResolved colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
            Color(0xFF4338CA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/provider-dashboard');
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'PARTNER / DRIVER MODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'EARN ৳50K+/MO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Switch to Provider Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Accept live requests, track earnings & manage orders like Uber / Fiverr.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.82),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Open Provider Dashboard',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Color(0xFF1E1B4B),
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

  // ─── Menu Container & Items ───────────────────────────────────────────────

  Widget _buildSectionTitle(String title, AppColorsResolved colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: colors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildMenuContainer({
    required AppColorsResolved colors,
    required List<_MenuItemData> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: isLast ? const Radius.circular(20) : Radius.zero,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Row(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (item.badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (item.badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.badgeColor ?? AppColors.primary,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: item.badgeColor ?? AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      )
                    : null,
                trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: colors.border,
                  indent: 58,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    required this.onTap,
  });
}
