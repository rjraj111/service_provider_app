import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../reviews/review_bottom_sheet.dart';

// ─── Promo Banner Data ──────────────────────────────────────────────────────

class _PromoBanner {
  final String title;
  final String subtitle;
  final String badge;
  final String imageUrl;
  final Color ctaColor; // CTA button text color

  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.imageUrl,
    required this.ctaColor,
  });
}

const List<_PromoBanner> _promoBanners = [
  _PromoBanner(
    title: '50% Off AC Repair',
    subtitle: 'Beat the heat! Expert AC service at half price this season.',
    badge: 'LIMITED OFFER',
    imageUrl: 'lib/assets/images/ac repair.png',
    ctaColor: Color(0xFF0284C7),
  ),
  _PromoBanner(
    title: 'Eid Special Cleaning',
    subtitle: 'Sparkling home for Eid! Deep cleaning packages from ৳999.',
    badge: 'EID SPECIAL',
    imageUrl: 'lib/assets/images/home cleaning.png',
    ctaColor: Color(0xFF059669),
  ),
  _PromoBanner(
    title: 'Plumbing Offers',
    subtitle: 'Free inspection on all plumbing repairs this week only!',
    badge: 'THIS WEEK',
    imageUrl: 'lib/assets/images/plumbing solution.png',
    ctaColor: Color(0xFFD97706),
  ),
  _PromoBanner(
    title: 'Pro Electricians',
    subtitle: 'Certified electricians available 24/7. Book now, pay later.',
    badge: 'NEW',
    imageUrl: 'lib/assets/images/electrician working pic.png',
    ctaColor: Color(0xFF4F46E5),
  ),
];

// ─── Home Screen ────────────────────────────────────────────────────────────

/// Home screen with promo banner, unified search bar, service categories,
/// and top professionals.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _bannerController;
  Timer? _autoScrollTimer;
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 1.0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_bannerController.hasClients) return;
      final nextPage = (_currentBanner + 1) % _promoBanners.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColorsResolved.of(context);

    // Build localized category data
    final categories = _buildCategories(l10n);

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showReviewBottomSheet(
            context,
            providerName: 'Rahim Uddin',
            serviceName: 'Master AC Servicing',
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.star_rounded, size: 22, color: Colors.amber),
        label: const Text(
          'Review & Tip (Demo)',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Top Header with greeting & notification ────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.hello,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.findAService,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification bell
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
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
                    ),
                  ],
                ),
              ),
            ),

            // --- Universal Search Bar ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: () => context.push('/ai-search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.searchHint,
                            style: TextStyle(
                              fontSize: 15,
                              color: colors.textHint,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showVoiceSearch(context),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.voiceSearchGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Promo Banner Carousel ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 188,
                      child: PageView.builder(
                        controller: _bannerController,
                        itemCount: _promoBanners.length,
                        onPageChanged: (index) {
                          setState(() => _currentBanner = index);
                        },
                        itemBuilder: (context, index) {
                          return _PromoBannerCard(
                            banner: _promoBanners[index],
                          );
                        },
                      ),
                    ),
                    // ─── Dot Indicator ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _DotIndicator(
                        count: _promoBanners.length,
                        activeIndex: _currentBanner,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Service Categories Header ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.serviceCategories,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/explore'),
                      child: Text(
                        l10n.seeAll,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Horizontal Category List ───────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                      icon: category['icon'] as IconData,
                      label: category['label'] as String,
                      color: category['color'] as Color,
                      image: category['image'] as String?,
                    );
                  },
                ),
              ),
            ),

            // ─── Top Rated Professionals Header ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.topRatedProfessionals,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.near_me_rounded, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Sorted by: Nearest first (Dhaka)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.seeAll,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Professionals Vertical List ────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: _professionals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final pro = _professionals[index];
                  return _ProfessionalCard(
                    name: pro['name'] as String,
                    service: pro['service'] as String,
                    rating: pro['rating'] as double,
                    reviews: pro['reviews'] as int,
                    rate: pro['rate'] as String,
                    distanceKm: (pro['distanceKm'] as num?)?.toDouble() ?? 1.2,
                    avatarColor: pro['avatarColor'] as Color,
                    isAvailable: pro['isAvailable'] as bool,
                    avatarUrl: pro['avatarUrl'] as String?,
                    l10n: l10n,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Promo Banner Card ──────────────────────────────────────────────────────

class _PromoBannerCard extends StatelessWidget {
  final _PromoBanner banner;

  const _PromoBannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 188,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ─── Background photo ────────────────────────────────
              Image.asset(
                banner.imageUrl,
                fit: BoxFit.cover,
              ),

              // ─── Deep gradient overlay (left: #0F0F13, right: transparent)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.55, 1.0],
                    colors: [
                      const Color(0xFF0F0F13).withValues(alpha: 0.92),
                      const Color(0xFF0F0F13).withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ─── Text & CTA — overflow-safe layout ──────────────
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                right: 80, // leave right edge clear (photo shows through)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge pill
                    IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          banner.badge,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title — maxLines: 1, never wraps
                    Text(
                      banner.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle — Flexible so it can shrink, never overflows
                    Text(
                      banner.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grab Now CTA
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Grab Now →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: banner.ctaColor,
                          ),
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
    );
  }
}

// ─── Dot Indicator ──────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _DotIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Build Localized Categories ─────────────────────────────────────────────

List<Map<String, dynamic>> _buildCategories(AppLocalizations l10n) {
  return [
    {'icon': Icons.plumbing_rounded, 'label': l10n.categoryPlumber, 'color': const Color(0xFF3B82F6), 'image': 'lib/assets/images/plumbing solution.png'},
    {'icon': Icons.ac_unit_rounded, 'label': l10n.categoryAcRepair, 'color': const Color(0xFF06B6D4), 'image': 'lib/assets/images/ac repair.png'},
    {'icon': Icons.electrical_services_rounded, 'label': l10n.categoryElectrician, 'color': const Color(0xFFF59E0B), 'image': 'lib/assets/images/electrician working pic.png'},
    {'icon': Icons.format_paint_rounded, 'label': l10n.categoryPainter, 'color': const Color(0xFFEF4444), 'image': 'lib/assets/images/painting and decor.png'},
    {'icon': Icons.cleaning_services_rounded, 'label': l10n.categoryCleaning, 'color': const Color(0xFF22C55E), 'image': 'lib/assets/images/home cleaning.png'},
    {'icon': Icons.carpenter_rounded, 'label': l10n.categoryCarpenter, 'color': const Color(0xFF8B5CF6), 'image': 'lib/assets/images/curpentry and furniture.png'},
    {'icon': Icons.local_shipping_rounded, 'label': l10n.categoryMovers, 'color': const Color(0xFFEC4899), 'image': 'lib/assets/images/packers and movers.png'},
    {'icon': Icons.home_repair_service_rounded, 'label': l10n.categoryAppliance, 'color': const Color(0xFF14B8A6), 'image': 'lib/assets/images/appliance repair.png'},
  ];
}

// ─── Dummy Professionals Data ───────────────────────────────────────────────

final List<Map<String, dynamic>> _professionals = [
  {
    'name': 'Rahim Uddin',
    'service': 'Plumber · 8 yrs exp',
    'rating': 4.9,
    'reviews': 127,
    'rate': '৳500/hr',
    'distanceKm': 0.8,
    'avatarColor': const Color(0xFF3B82F6),
    'isAvailable': true,
    'avatarUrl': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=400',
  },
  {
    'name': 'Kamal Hossain',
    'service': 'AC Repair · 12 yrs exp',
    'rating': 4.8,
    'reviews': 94,
    'rate': '৳800/visit',
    'distanceKm': 1.5,
    'avatarColor': const Color(0xFF06B6D4),
    'isAvailable': true,
    'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
  },
  {
    'name': 'Arif Khan',
    'service': 'Electrician · 6 yrs exp',
    'rating': 4.7,
    'reviews': 63,
    'rate': '৳450/hr',
    'distanceKm': 2.2,
    'avatarColor': const Color(0xFFF59E0B),
    'isAvailable': false,
    'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=400',
  },
  {
    'name': 'Sumon Das',
    'service': 'Painter · 10 yrs exp',
    'rating': 4.9,
    'reviews': 201,
    'rate': '৳600/hr',
    'distanceKm': 3.1,
    'avatarColor': const Color(0xFFEF4444),
    'isAvailable': true,
    'avatarUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=400',
  },
  {
    'name': 'Nasir Ahmed',
    'service': 'Carpenter · 15 yrs exp',
    'rating': 4.8,
    'reviews': 156,
    'rate': '৳700/hr',
    'distanceKm': 4.0,
    'avatarColor': const Color(0xFF8B5CF6),
    'isAvailable': true,
    'avatarUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=400',
  },
];

// ─── Category Card Widget ───────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? image;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/explore', extra: label),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.35 : 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: image != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            image!,
                            fit: BoxFit.cover,
                          ),
                          // Dark gradient overlay for text and icon readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.60),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(icon, color: Colors.white, size: 24),
                          ),
                        ],
                      )
                    : Container(
                        color: color.withValues(alpha: 0.1),
                        child: Icon(icon, color: color, size: 28),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Professional Card Widget ───────────────────────────────────────────────

class _ProfessionalCard extends StatelessWidget {
  final String name;
  final String service;
  final double rating;
  final int reviews;
  final String rate;
  final double distanceKm;
  final Color avatarColor;
  final bool isAvailable;
  final String? avatarUrl;
  final AppLocalizations l10n;

  const _ProfessionalCard({
    required this.name,
    required this.service,
    required this.rating,
    required this.reviews,
    required this.rate,
    required this.distanceKm,
    required this.avatarColor,
    required this.isAvailable,
    this.avatarUrl,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(
            '/provider-details',
            extra: {
              'name': name,
              'service': service,
              'rating': rating,
              'reviews': reviews,
              'rate': rate,
              'distanceKm': distanceKm,
              'avatarColor': avatarColor,
              'isAvailable': isAvailable,
              'avatarUrl': avatarUrl,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: avatarColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: avatarUrl != null
                          ? (avatarUrl!.startsWith('http')
                              ? Image.network(
                                  avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person_rounded,
                                    color: avatarColor,
                                    size: 28,
                                  ),
                                )
                              : Image.asset(
                                  avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person_rounded,
                                    color: avatarColor,
                                    size: 28,
                                  ),
                                ))
                          : Icon(
                              Icons.person_rounded,
                              color: avatarColor,
                              size: 28,
                            ),
                    ),
                  ),
                  // Online indicator
                  if (isAvailable)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFBBF24), size: 16),
                            const SizedBox(width: 3),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${l10n.reviews(reviews)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textHint,
                              ),
                            ),
                          ],
                        ),
                        // Stylish Distance Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '📍 $distanceKm km away',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price & availability
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rate,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.success.withValues(alpha: 0.1)
                          : colors.textHint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAvailable ? l10n.available : l10n.busy,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isAvailable ? AppColors.success : colors.textHint,
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
}

/// Opens the Google-Assistant-style voice search bottom sheet.
void _showVoiceSearch(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const _VoiceSearchSheet(),
  );
}

// --- Voice Search Bottom Sheet ---

class _VoiceSearchSheet extends StatefulWidget {
  const _VoiceSearchSheet();

  @override
  State<_VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<_VoiceSearchSheet>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barHeights;
  bool _isListening = true;

  static const int _barCount = 5;
  static const List<double> _barDelays = [0.0, 0.15, 0.3, 0.15, 0.0];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pulseScale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _barControllers = List.generate(_barCount, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      Future.delayed(
        Duration(milliseconds: (_barDelays[i] * 1000).toInt()),
        () { if (mounted) ctrl.repeat(reverse: true); },
      );
      return ctrl;
    });
    _barHeights = _barControllers.map((ctrl) {
      return Tween<double>(begin: 6.0, end: 28.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    for (final c in _barControllers) { c.dispose(); }
    super.dispose();
  }

  void _toggleListening() {
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      _pulseController.repeat();
      for (var i = 0; i < _barControllers.length; i++) {
        Future.delayed(
          Duration(milliseconds: (_barDelays[i] * 1000).toInt()),
          () { if (mounted) _barControllers[i].repeat(reverse: true); },
        );
      }
    } else {
      _pulseController.stop();
      for (final c in _barControllers) { c.stop(); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: colors.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Text('Voice Search',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: colors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.textHint.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 18,
                      color: colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Pulsing mic
          GestureDetector(
            onTap: _toggleListening,
            child: SizedBox(
              width: 140, height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isListening)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary
                                .withValues(alpha: _pulseOpacity.value),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(
                          alpha: _isListening ? 0.12 : 0.06),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                            alpha: _isListening ? 0.4 : 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isListening
                          ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(colors: [
                              colors.textHint.withValues(alpha: 0.3),
                              colors.textHint.withValues(alpha: 0.2),
                            ]),
                      boxShadow: _isListening
                          ? [BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 20, offset: const Offset(0, 6))]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                      color: Colors.white, size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Wave bars
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_barCount, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedBuilder(
                    animation: _barControllers[i],
                    builder: (_, __) {
                      final h = _isListening ? _barHeights[i].value : 6.0;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 5, height: h,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.primary.withValues(alpha: 0.8)
                              : colors.textHint.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isListening ? 'Listening... Speak now' : 'Tap mic to start',
              key: ValueKey(_isListening),
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500,
                color: _isListening ? AppColors.primary : colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isListening ? 'Try: "Find AC repair near me"' : 'Voice search is paused',
            style: TextStyle(fontSize: 12, color: colors.textHint),
          ),
          const SizedBox(height: 32),
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: colors.border, width: 1.5),
              ),
              child: Text('Cancel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: colors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}
