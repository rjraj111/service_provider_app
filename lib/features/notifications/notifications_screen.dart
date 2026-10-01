import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Categories for notifications
enum NotificationCategory {
  all,
  unread,
  booking,
  promo,
  system,
}

/// Notification type determining icon, color scheme, and action behavior
enum NotificationType {
  bookingSuccess,
  promoDiscount,
  systemAlert,
  serviceUpdate,
  reward,
}

/// Data model representing a notification item
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationType type;
  bool isRead;
  final String? promoCode;
  final String? actionLabel;
  final String? actionRoute;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.promoCode,
    this.actionLabel,
    this.actionRoute,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timestamp,
    NotificationType? type,
    bool? isRead,
    String? promoCode,
    String? actionLabel,
    String? actionRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      promoCode: promoCode ?? this.promoCode,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}

/// A clean, modern, and interactive Notification Center for Utsho.
/// Features notification grouping, unread badges, filter tabs, swipe-to-dismiss,
/// and contextual actions for bookings, promos, and security alerts.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory _selectedCategory = NotificationCategory.all;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'notif-1',
      title: 'Booking Confirmed: Plumber at 11:30 AM',
      message:
          'Rahim Uddin (Master Plumber) has accepted your service request. He will arrive at Gulshan 2 with standard repair tools.',
      timestamp: '10 mins ago',
      type: NotificationType.bookingSuccess,
      isRead: false,
      actionLabel: 'Track Live Provider',
      actionRoute: '/tracking',
    ),
    NotificationItem(
      id: 'notif-2',
      title: 'Get 20% off on AC Servicing! Use code: COOL20',
      message:
          'Summer rush discount is here! Apply coupon COOL20 during checkout to get an instant ৳300 discount on master AC maintenance.',
      timestamp: '45 mins ago',
      type: NotificationType.promoDiscount,
      isRead: false,
      promoCode: 'COOL20',
      actionLabel: 'Copy Promo Code',
    ),
    NotificationItem(
      id: 'notif-3',
      title: 'New login detected on Windows PC',
      message:
          'Your Utsho account was logged in from Google Chrome on Windows 11 (IP: 103.114.98.22, Dhaka). If this wasn\'t you, tap to secure your account immediately.',
      timestamp: '2 hours ago',
      type: NotificationType.systemAlert,
      isRead: false,
      actionLabel: 'Review Security',
    ),
    NotificationItem(
      id: 'notif-4',
      title: 'Provider En Route: Rahim Uddin is nearby',
      message:
          'Your technician has crossed Gulshan 2 roundabout and is approximately 5 minutes away from your premises.',
      timestamp: 'Yesterday',
      type: NotificationType.serviceUpdate,
      isRead: true,
      actionLabel: 'Open Chat',
      actionRoute: '/chat',
    ),
    NotificationItem(
      id: 'notif-5',
      title: '50 Reward Points Added to Wallet!',
      message:
          'Thank you for rating your sanitary repair 5 stars! You\'ve received 50 bonus loyalty points (worth ৳50).',
      timestamp: '2 days ago',
      type: NotificationType.reward,
      isRead: true,
    ),
    NotificationItem(
      id: 'notif-6',
      title: 'Digital Payment Receipt: ৳850 via bKash',
      message:
          'Payment for order #SH-8841 was confirmed successfully. The verified tax invoice is ready for download in your profile.',
      timestamp: '3 days ago',
      type: NotificationType.bookingSuccess,
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get _filteredNotifications {
    switch (_selectedCategory) {
      case NotificationCategory.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationCategory.booking:
        return _notifications
            .where((n) =>
                n.type == NotificationType.bookingSuccess ||
                n.type == NotificationType.serviceUpdate)
            .toList();
      case NotificationCategory.promo:
        return _notifications
            .where((n) =>
                n.type == NotificationType.promoDiscount ||
                n.type == NotificationType.reward)
            .toList();
      case NotificationCategory.system:
        return _notifications
            .where((n) => n.type == NotificationType.systemAlert)
            .toList();
      case NotificationCategory.all:
        return _notifications;
    }
  }

  void _markAllAsRead() {
    HapticFeedback.mediumImpact();
    setState(() {
      for (final item in _notifications) {
        item.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.done_all_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('All notifications marked as read.'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _markSingleAsRead(NotificationItem item) {
    if (!item.isRead) {
      setState(() {
        item.isRead = true;
      });
    }
  }

  void _handleNotificationTap(NotificationItem item) {
    _markSingleAsRead(item);
    HapticFeedback.lightImpact();

    if (item.promoCode != null) {
      Clipboard.setData(ClipboardData(text: item.promoCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Promo code "${item.promoCode}" copied to clipboard!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (item.actionRoute != null) {
      if (item.actionRoute == '/tracking') {
        context.push(
          '/tracking',
          extra: {
            'providerName': 'Rahim Uddin',
            'profession': 'Plumber · 8 yrs exp',
            'eta': '12 mins',
            'distance': '1.8 km',
          },
        );
      } else if (item.actionRoute == '/chat') {
        context.push(
          '/chat',
          extra: {
            'providerName': 'Rahim Uddin',
            'serviceName': 'Plumber · 8 yrs exp',
          },
        );
      } else {
        context.push(item.actionRoute!);
      }
      return;
    }

    if (item.type == NotificationType.systemAlert) {
      _showSecurityAlertModal(item);
    }
  }

  void _showSecurityAlertModal(NotificationItem item) {
    final colors = AppColorsResolved.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.info, size: 24),
            SizedBox(width: 8),
            Text('Security Alert', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.message,
              style: TextStyle(color: colors.textSecondary, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device: Chrome on Windows 11', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Location: Gulshan, Dhaka, BD', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('IP Address: 103.114.98.22', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('This was me', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account secured! Other sessions terminated.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Secure Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _dismissNotification(int index, NotificationItem item) {
    HapticFeedback.lightImpact();
    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification removed.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accent,
          onPressed: () {
            setState(() {
              _notifications.insert(index, item);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayList = _filteredNotifications;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors, isDark),
      body: Column(
        children: [
          // ─── Filter Category Chips ──────────────────────────────────────
          _buildCategoryFilters(colors, isDark),

          // ─── Notification List ──────────────────────────────────────────
          Expanded(
            child: displayList.isEmpty
                ? _buildEmptyState(colors)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      return _buildDismissibleNotificationCard(
                        item: item,
                        index: index,
                        colors: colors,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppColorsResolved colors, bool isDark) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unreadCount new',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_unreadCount > 0)
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primary),
            label: const Text(
              'Mark all as read',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          )
        else
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications are up to date!'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.check_circle_outline_rounded, color: colors.textHint, size: 20),
            tooltip: 'All caught up',
          ),
        const SizedBox(width: 6),
      ],
    );
  }

  // ─── Filter Category Chips ──────────────────────────────────────────────────

  Widget _buildCategoryFilters(AppColorsResolved colors, bool isDark) {
    final categories = [
      {'cat': NotificationCategory.all, 'label': 'All (${_notifications.length})'},
      {'cat': NotificationCategory.unread, 'label': 'Unread ($_unreadCount)'},
      {'cat': NotificationCategory.booking, 'label': 'Bookings'},
      {'cat': NotificationCategory.promo, 'label': 'Promos & Rewards'},
      {'cat': NotificationCategory.system, 'label': 'System Alerts'},
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final item = categories[idx];
          final cat = item['cat'] as NotificationCategory;
          final isSelected = _selectedCategory == cat;

          return Center(
            child: ChoiceChip(
              label: Text(item['label'] as String),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedCategory = cat);
                  HapticFeedback.selectionClick();
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: colors.surface,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : colors.border.withValues(alpha: 0.8),
                width: isSelected ? 1.4 : 1,
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colors.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  // ─── Dismissible Notification Card ──────────────────────────────────────────

  Widget _buildDismissibleNotificationCard({
    required NotificationItem item,
    required int index,
    required AppColorsResolved colors,
    required bool isDark,
  }) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismissNotification(index, item),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remove',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
      child: _buildNotificationTile(item: item, colors: colors, isDark: isDark),
    );
  }

  // ─── Modern Notification Tile ───────────────────────────────────────────────

  Widget _buildNotificationTile({
    required NotificationItem item,
    required AppColorsResolved colors,
    required bool isDark,
  }) {
    // Unread styling: subtle background tint and distinct border
    final cardBg = item.isRead
        ? colors.surface
        : (isDark
            ? AppColors.primary.withValues(alpha: 0.16)
            : const Color(0xFFF3E8FF).withValues(alpha: 0.65));

    final borderColor = item.isRead
        ? colors.border
        : AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.3);

    final config = _getNotificationConfig(item.type);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: item.isRead ? 1 : 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: item.isRead ? 0.02 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(item),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Type Icon Container ──────────────────────────────────
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: config.iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: config.iconColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(config.icon, color: config.iconColor, size: 22),
                ),
                const SizedBox(width: 14),

                // ─── Main Content ─────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Type tag & Timestamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: config.iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              config.tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: config.iconColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                item.timestamp,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.textHint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (!item.isRead) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: AppColors.primary, blurRadius: 4),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                          color: colors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Body message
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                      ),

                      // ─── Contextual Action Button ─────────────────────────
                      if (item.actionLabel != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _handleNotificationTap(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: item.promoCode != null
                                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                      : AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: item.promoCode != null
                                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.promoCode != null
                                          ? Icons.copy_rounded
                                          : (item.actionRoute == '/tracking'
                                              ? Icons.near_me_rounded
                                              : (item.actionRoute == '/chat'
                                                  ? Icons.chat_rounded
                                                  : Icons.shield_rounded)),
                                      size: 13,
                                      color: item.promoCode != null
                                          ? const Color(0xFF10B981)
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      item.actionLabel!,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: item.promoCode != null
                                            ? const Color(0xFF10B981)
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (item.promoCode != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Text(
                                  item.promoCode!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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

  // ─── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppColorsResolved colors) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedCategory == NotificationCategory.unread
                  ? 'Great job! You\'re all caught up on all alerts.'
                  : 'You do not have any notifications in this section right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            if (_selectedCategory != NotificationCategory.all)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _selectedCategory = NotificationCategory.all);
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Show All Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  _NotificationTypeConfig _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.bookingSuccess:
        return const _NotificationTypeConfig(
          icon: Icons.check_circle_rounded,
          iconColor: Color(0xFF10B981),
          tag: 'BOOKING CONFIRMED',
        );
      case NotificationType.promoDiscount:
        return const _NotificationTypeConfig(
          icon: Icons.card_giftcard_rounded,
          iconColor: Color(0xFF8B5CF6),
          tag: 'PROMO / VOUCHER',
        );
      case NotificationType.systemAlert:
        return const _NotificationTypeConfig(
          icon: Icons.info_rounded,
          iconColor: Color(0xFF3B82F6),
          tag: 'SYSTEM SECURITY',
        );
      case NotificationType.serviceUpdate:
        return const _NotificationTypeConfig(
          icon: Icons.near_me_rounded,
          iconColor: Color(0xFFF97316),
          tag: 'LIVE UPDATE',
        );
      case NotificationType.reward:
        return const _NotificationTypeConfig(
          icon: Icons.stars_rounded,
          iconColor: Color(0xFFF59E0B),
          tag: 'REWARD EARNED',
        );
    }
  }
}

class _NotificationTypeConfig {
  final IconData icon;
  final Color iconColor;
  final String tag;

  const _NotificationTypeConfig({
    required this.icon,
    required this.iconColor,
    required this.tag,
  });
}
