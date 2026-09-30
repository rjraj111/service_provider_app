import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

/// Profile screen with language switcher and account settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColorsResolved.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ─── Profile Header ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourProfile,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'user@example.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_rounded,
                    color: Colors.white.withValues(alpha: 0.7), size: 22),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── Language Section ──────────────────────────────────────
          _SectionHeader(title: l10n.language, color: colors.textPrimary),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
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
              children: [
                _LanguageTile(
                  label: l10n.english,
                  subtitle: 'English',
                  isSelected: currentLocale.languageCode == 'en',
                  colors: colors,
                  onTap: () {
                    ref.read(localeProvider.notifier).state =
                        const Locale('en');
                  },
                ),
                Divider(
                    height: 1,
                    color: colors.border,
                    indent: 56,
                    endIndent: 16),
                _LanguageTile(
                  label: l10n.bengali,
                  subtitle: 'বাংলা',
                  isSelected: currentLocale.languageCode == 'bn',
                  colors: colors,
                  onTap: () {
                    ref.read(localeProvider.notifier).state =
                        const Locale('bn');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── Settings Section ─────────────────────────────────────
          _SectionHeader(title: l10n.settings, color: colors.textPrimary),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
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
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: l10n.notifications,
                  iconColor: AppColors.info,
                  textColor: colors.textPrimary,
                  hintColor: colors.textHint,
                  onTap: () {},
                ),
                Divider(
                    height: 1,
                    color: colors.border,
                    indent: 56,
                    endIndent: 16),
                // ─── Dark Mode Toggle ─────────────────────────────────
                _DarkModeToggleTile(
                  label: l10n.darkMode,
                  isDark: isDark,
                  colors: colors,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                Divider(
                    height: 1,
                    color: colors.border,
                    indent: 56,
                    endIndent: 16),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  label: l10n.helpAndSupport,
                  iconColor: AppColors.accent,
                  textColor: colors.textPrimary,
                  hintColor: colors.textHint,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── Log Out Button ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.logOut),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

// ─── Language Tile ──────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final AppColorsResolved colors;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Language icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.language_rounded,
                color: isSelected ? AppColors.primary : colors.textHint,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : colors.textPrimary,
                    ),
                  ),
                  if (label != subtitle)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            // Selected check
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      key: const ValueKey('selected'),
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16),
                    )
                  : Container(
                      key: const ValueKey('unselected'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: colors.border, width: 2),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dark Mode Toggle Tile ──────────────────────────────────────────────────

class _DarkModeToggleTile extends StatelessWidget {
  final String label;
  final bool isDark;
  final AppColorsResolved colors;
  final ValueChanged<bool> onChanged;

  const _DarkModeToggleTile({
    required this.label,
    required this.isDark,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: isDark,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Settings Tile ──────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final Color hintColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.hintColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: hintColor, size: 22),
          ],
        ),
      ),
    );
  }
}
