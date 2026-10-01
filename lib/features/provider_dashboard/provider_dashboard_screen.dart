import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Model representing an incoming service request for the provider
class ProviderJobRequest {
  final String id;
  final String customerName;
  final String customerAvatar;
  final String serviceTitle;
  final String serviceCategory;
  final String address;
  final String distance;
  final String estimatedEarnings;
  final String timeAgo;
  final bool isUrgent;

  const ProviderJobRequest({
    required this.id,
    required this.customerName,
    required this.customerAvatar,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.address,
    required this.distance,
    required this.estimatedEarnings,
    required this.timeAgo,
    this.isUrgent = false,
  });
}

/// Model representing an ongoing job in progress
class ProviderActiveJob {
  final String id;
  final String customerName;
  final String customerAvatar;
  final String serviceTitle;
  final String address;
  final String estimatedEarnings;
  final String paymentMethod;
  final String status;
  final String eta;

  const ProviderActiveJob({
    required this.id,
    required this.customerName,
    required this.customerAvatar,
    required this.serviceTitle,
    required this.address,
    required this.estimatedEarnings,
    required this.paymentMethod,
    required this.status,
    required this.eta,
  });
}

/// A premium, Uber Driver & Fiverr style Provider Dashboard.
/// Enables service professionals to toggle online/offline availability,
/// review live daily earnings, accept/decline incoming requests,
/// and manage active ongoing jobs with GPS and in-app chat integration.
class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  int _todayEarnings = 1500;
  int _todayJobsCount = 3;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // New incoming requests queue
  final List<ProviderJobRequest> _newRequests = [
    const ProviderJobRequest(
      id: 'req-101',
      customerName: 'Tariqul Alam',
      customerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
      serviceTitle: 'Water Pipe Hairline Leak & Kitchen Seepage',
      serviceCategory: 'Plumbing & Sanitary',
      address: 'House 14, Road 71, Gulshan 2, Dhaka',
      distance: '1.2 km away',
      estimatedEarnings: '৳800',
      timeAgo: '2 mins ago',
      isUrgent: true,
    ),
    const ProviderJobRequest(
      id: 'req-102',
      customerName: 'Nusrat Jahan',
      customerAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=400',
      serviceTitle: 'Bathroom Tap Replacement & Pressure Check',
      serviceCategory: 'Plumbing & Sanitary',
      address: 'Block E, Banani DOHS, Dhaka',
      distance: '2.5 km away',
      estimatedEarnings: '৳650',
      timeAgo: '5 mins ago',
      isUrgent: false,
    ),
  ];

  // Active ongoing jobs
  final List<ProviderActiveJob> _activeJobs = [
    const ProviderActiveJob(
      id: 'job-501',
      customerName: 'Fahim Shakir',
      customerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=400',
      serviceTitle: 'Emergency Basin Drain Unclogging',
      address: 'Flat 4B, Sector 3, Uttara, Dhaka',
      estimatedEarnings: '৳950',
      paymentMethod: 'bKash Paid (Online)',
      status: 'On The Way · 8 Mins Away',
      eta: '8 mins',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _acceptRequest(ProviderJobRequest request) {
    HapticFeedback.heavyImpact();
    setState(() {
      _newRequests.removeWhere((r) => r.id == request.id);
      _activeJobs.insert(
        0,
        ProviderActiveJob(
          id: 'job-${DateTime.now().millisecondsSinceEpoch % 10000}',
          customerName: request.customerName,
          customerAvatar: request.customerAvatar,
          serviceTitle: request.serviceTitle,
          address: request.address,
          estimatedEarnings: request.estimatedEarnings,
          paymentMethod: 'bKash Paid (Online)',
          status: 'Accepted · Heading to Location',
          eta: '12 mins',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Job Accepted! Heading to ${request.address.split(',').first}.'),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Track GPS',
          textColor: Colors.white,
          onPressed: () {
            context.push(
              '/tracking',
              extra: {
                'providerName': request.customerName,
                'profession': request.serviceTitle,
                'eta': '12 mins',
                'distance': request.distance,
              },
            );
          },
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _declineRequest(ProviderJobRequest request) {
    HapticFeedback.lightImpact();
    setState(() {
      _newRequests.removeWhere((r) => r.id == request.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request from ${request.customerName} declined.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markJobCompleted(ProviderActiveJob job) {
    HapticFeedback.mediumImpact();
    final parsedFee = int.tryParse(job.estimatedEarnings.replaceAll(RegExp(r'[^\d]'), '')) ?? 800;

    setState(() {
      _activeJobs.removeWhere((j) => j.id == job.id);
      _todayEarnings += parsedFee;
      _todayJobsCount += 1;
    });

    showDialog(
      context: context,
      builder: (ctx) {
        final colors = AppColorsResolved.of(ctx);
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.verified_rounded, color: AppColors.success, size: 26),
              SizedBox(width: 8),
              Text('Job Completed!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Great work! You completed the service for ${job.customerName}.',
                style: TextStyle(color: colors.textSecondary, fontSize: 13.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Earnings Credited:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      job.estimatedEarnings,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue Working', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors, isDark),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 0. KYC Verification Warning Card ────────────────────────────
            _buildKycWarningCard(colors, isDark),

            const SizedBox(height: 16),

            // ─── 1. Online / Offline Status Beacon ───────────────────────────
            _buildAvailabilityStatusBar(colors),

            const SizedBox(height: 16),

            // ─── 2. Earnings Summary Hero Card ──────────────────────────────
            _buildEarningsHeroCard(colors),

            const SizedBox(height: 20),

            // ─── 3. Quick Performance Metrics ────────────────────────────────
            _buildPerformanceRow(colors),

            const SizedBox(height: 24),

            // ─── 4. New Incoming Job Requests ───────────────────────────────
            _buildNewRequestsSection(colors),

            const SizedBox(height: 24),

            // ─── 5. Active Jobs In Progress ──────────────────────────────────
            _buildActiveJobsSection(colors),

            const SizedBox(height: 24),

            // ─── 6. Provider Toolkit & Settings ──────────────────────────────
            _buildPartnerToolkit(colors),
          ],
        ),
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
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Provider Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF1D9BF0)),
                ],
              ),
              Text(
                'Rahim Uddin · Master Plumber',
                style: TextStyle(fontSize: 11, color: colors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Badge.count(
            count: 3,
            backgroundColor: AppColors.error,
            textColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
            child: const Icon(Icons.notifications_outlined),
          ),
          color: colors.textPrimary,
          tooltip: 'Notifications',
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: _isOnline
                  ? AppColors.success.withValues(alpha: 0.12)
                  : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnline ? AppColors.success.withValues(alpha: 0.5) : colors.border,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.success : colors.textHint,
                    shape: BoxShape.circle,
                    boxShadow: _isOnline
                        ? [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _isOnline ? AppColors.success : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.75,
                  child: Switch.adaptive(
                    value: _isOnline,
                    activeTrackColor: AppColors.success,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      setState(() => _isOnline = val);
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? 'Status updated: You are now Online.'
                                : 'Status updated: You are now Offline.',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ─── KYC Verification Warning Card ──────────────────────────────────────────

  Widget _buildKycWarningCard(AppColorsResolved colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF2E1C0A),
                  const Color(0xFF1E1408),
                ]
              : [
                  const Color(0xFFFFFBEB),
                  const Color(0xFFFEF3C7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.45 : 0.65),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.16 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD97706),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Identity Unverified',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: isDark ? Colors.amber.shade200 : const Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACTION REQUIRED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Identity Unverified: Complete your KYC to start receiving jobs',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFE5D5B8) : const Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/provider-kyc');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.verified_user_rounded, size: 16),
                      label: const Text(
                        'Verify Now',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
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
    );
  }

  // ─── Online / Offline Status Beacon ─────────────────────────────────────────

  Widget _buildAvailabilityStatusBar(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isOnline ? AppColors.success.withValues(alpha: 0.08) : colors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isOnline ? AppColors.success.withValues(alpha: 0.3) : colors.border,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Animated green beacon if online
          if (_isOnline) ...[
            FadeTransition(
              opacity: _pulseAnimation,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.success, blurRadius: 8),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: colors.textHint,
                shape: BoxShape.circle,
              ),
            ),
          ],
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'You are Online & Receiving Jobs' : 'You are Currently Offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _isOnline ? AppColors.success : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isOnline ? 'Available for instant orders within 5km' : 'Turn on switch to get new job alerts',
                  style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),

          // Online / Offline Switch
          Switch.adaptive(
            value: _isOnline,
            activeTrackColor: AppColors.success,
            onChanged: (val) {
              setState(() => _isOnline = val);
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val ? 'Status updated: You are now Online.' : 'Status updated: You are now Offline.'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Earnings Summary Card ──────────────────────────────────────────────────

  Widget _buildEarningsHeroCard(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white70),
                    SizedBox(width: 5),
                    Text(
                      'TODAY\'S REVENUE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: Color(0xFF4ADE80), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+24% vs yesterday',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '৳$_todayEarnings',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BDT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 14),

          // Sub-stats: Total Jobs & Weekly payout
          Row(
            children: [
              _buildEarningsSubMetric(
                label: 'Jobs Completed',
                value: '$_todayJobsCount Completed',
                icon: Icons.check_circle_outline_rounded,
              ),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.15)),
              _buildEarningsSubMetric(
                label: 'Weekly Payout',
                value: '৳9,800',
                icon: Icons.account_balance_wallet_outlined,
              ),
              const Spacer(),
              // Withdraw button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Instant Payout initiated to linked bKash wallet.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Withdraw', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSubMetric({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white60),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ─── Quick Performance Metrics Row ──────────────────────────────────────────

  Widget _buildPerformanceRow(AppColorsResolved colors) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Acceptance Rate',
            value: '98.5%',
            badge: 'High Priority',
            icon: Icons.handshake_rounded,
            color: const Color(0xFF3B82F6),
            colors: colors,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            title: 'Provider Rating',
            value: '4.92 ⭐',
            badge: '127 Reviews',
            icon: Icons.star_rounded,
            color: const Color(0xFFF59E0B),
            colors: colors,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            title: 'On-Time Arrival',
            value: '99.1%',
            badge: 'Guaranteed',
            icon: Icons.timer_rounded,
            color: const Color(0xFF10B981),
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String badge,
    required IconData icon,
    required Color color,
    required AppColorsResolved colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
              Icon(icon, color: color, size: 18),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── New Incoming Requests Section ──────────────────────────────────────────

  Widget _buildNewRequestsSection(AppColorsResolved colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'New Job Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_newRequests.length} Waiting',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (_newRequests.isNotEmpty)
              Text(
                'Auto-refreshes in 15s',
                style: TextStyle(fontSize: 11, color: colors.textHint),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (!_isOnline)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.cloud_off_rounded, size: 40, color: colors.textHint),
                  const SizedBox(height: 8),
                  Text(
                    'You are currently offline',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toggle the switch at the top to online mode to receive nearby customer bookings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else if (_newRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.radar_rounded, size: 40, color: AppColors.primary),
                  const SizedBox(height: 10),
                  Text(
                    'Radar Scanning for Nearby Jobs...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We will automatically notify you when customers request plumbing assistance in Gulshan/Banani.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ..._newRequests.map((req) => _buildRequestCard(req, colors)),
      ],
    );
  }

  Widget _buildRequestCard(ProviderJobRequest req, AppColorsResolved colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: req.isUrgent ? AppColors.error.withValues(alpha: 0.4) : colors.border,
          width: req.isUrgent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Distance, Urgent tag, and time
          Row(
            children: [
              if (req.isUrgent) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 12, color: AppColors.error),
                      SizedBox(width: 3),
                      Text(
                        'URGENT LEAK',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '📍 ${req.distance}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              Text(
                req.timeAgo,
                style: TextStyle(fontSize: 11, color: colors.textHint, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer + Fee Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  req.customerAvatar,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
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
                      req.customerName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      req.serviceTitle,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: colors.textHint),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            req.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Fee Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    req.estimatedEarnings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'Fixed Payout',
                    style: TextStyle(fontSize: 10, color: colors.textHint),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 12),

          // Accept & Decline Buttons
          Row(
            children: [
              // Decline Button (Red)
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _declineRequest(req),
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Accept Button (Green Gradient)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptRequest(req),
                    icon: const Icon(Icons.check_circle_rounded, size: 17, color: Colors.white),
                    label: const Text(
                      'Accept Job',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Active Jobs In Progress Section ────────────────────────────────────────

  Widget _buildActiveJobsSection(AppColorsResolved colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Jobs In Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_activeJobs.length} Ongoing',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_activeJobs.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Center(
              child: Text(
                'No jobs currently in progress.',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ),
          )
        else
          ..._activeJobs.map((job) => _buildActiveJobCard(job, colors)),
      ],
    );
  }

  Widget _buildActiveJobCard(ProviderActiveJob job, AppColorsResolved colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                job.status,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.success),
              ),
              const Spacer(),
              Text(
                job.paymentMethod,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer details
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  job.customerAvatar,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 46,
                    height: 46,
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
                      job.customerName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.serviceTitle,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                job.estimatedEarnings,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 12),

          // Quick Action buttons: Navigate (GPS), Chat, Complete
          Row(
            children: [
              // GPS Tracking button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      '/tracking',
                      extra: {
                        'providerName': job.customerName,
                        'serviceName': job.serviceTitle,
                        'eta': job.eta,
                        'distance': '1.4 km',
                      },
                    );
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 16, color: AppColors.primary),
                  label: const Text('GPS Route'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Chat button
              IconButton(
                onPressed: () {
                  context.push(
                    '/chat',
                    extra: {
                      'providerName': job.customerName,
                      'serviceName': job.serviceTitle,
                      'avatarUrl': job.customerAvatar,
                    },
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 8),

              // Complete Job Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _markJobCompleted(job),
                  icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Provider Toolkit & Settings ───────────────────────────────────────────

  Widget _buildPartnerToolkit(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Partner Toolkit & Settings',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildToolkitTile(
            icon: Icons.map_rounded,
            title: 'Service Radius',
            subtitle: 'Currently set to 5.0 km (Dhaka North)',
            colors: colors,
          ),
          Divider(color: colors.border, height: 16),
          _buildToolkitTile(
            icon: Icons.payments_rounded,
            title: 'Payout Accounts',
            subtitle: 'bKash Wallet (018****4567) Linked',
            colors: colors,
          ),
          Divider(color: colors.border, height: 16),
          _buildToolkitTile(
            icon: Icons.shield_rounded,
            title: 'Utsho Partner Insurance',
            subtitle: '৳50,000 Safety Shield active',
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildToolkitTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppColorsResolved colors,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              Text(subtitle, style: TextStyle(fontSize: 11.5, color: colors.textSecondary)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
      ],
    );
  }
}
