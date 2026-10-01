import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'booking_checkout_sheet.dart';

// ─── Portfolio Work Item ─────────────────────────────────────────────────────

class _PortfolioItem {
  final String imageUrl;
  final String title;
  final String category;

  const _PortfolioItem({
    required this.imageUrl,
    required this.title,
    required this.category,
  });
}

// ─── Review Model ────────────────────────────────────────────────────────────

class _Review {
  final String name;
  final String avatar;
  final double rating;
  final String comment;
  final String date;
  final String projectType;

  const _Review({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.projectType,
  });
}

// ─── Provider Details Screen ─────────────────────────────────────────────────

/// Premium Fiverr/Upwork style professional service details screen with
/// cover image, overlapping profile picture, verified badges, stats,
/// portfolio gallery, package offerings, reviews, and a sticky Book Service bar.
class ProviderDetailsScreen extends StatefulWidget {
  final String name;
  final String service;
  final double rating;
  final int reviews;
  final String rate;
  final Color avatarColor;
  final bool isAvailable;
  final String? avatarUrl;

  const ProviderDetailsScreen({
    super.key,
    this.name = 'Rahim Uddin',
    this.service = 'Plumber · 8 yrs exp',
    this.rating = 4.9,
    this.reviews = 127,
    this.rate = '৳500/hr',
    this.avatarColor = const Color(0xFF3B82F6),
    this.isAvailable = true,
    this.avatarUrl,
  });

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  bool _isSaved = false;
  int _selectedPackageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final portfolioItems = _getPortfolioFor(widget.service);
    final reviews = _getReviewsFor(widget.service);
    final skills = _getSkillsFor(widget.service);
    final packages = _getPackagesFor(widget.service, widget.rate);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            // ─── Scrollable Content ──────────────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Header: Cover + Overlapping Profile Card ────────────────
                SliverToBoxAdapter(
                  child: _CoverAndProfileHeader(
                    name: widget.name,
                    service: widget.service,
                    rating: widget.rating,
                    reviews: widget.reviews,
                    avatarColor: widget.avatarColor,
                    avatarUrl: widget.avatarUrl ?? _getDefaultAvatarFor(widget.name),
                    isAvailable: widget.isAvailable,
                    isSaved: _isSaved,
                    onSaveToggle: () {
                      setState(() => _isSaved = !_isSaved);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isSaved
                                ? 'Added ${widget.name} to your saved pros'
                                : 'Removed from saved pros',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onShare: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Profile link copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),

                // ─── Key Stats Metrics Row ───────────────────────────────────
                SliverToBoxAdapter(
                  child: _StatsMetricRow(
                    rating: widget.rating,
                    reviews: widget.reviews,
                  ),
                ),

                // ─── About Section ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionCard(
                    title: 'About the Professional',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getBioFor(widget.name, widget.service),
                          style: TextStyle(
                            fontSize: 14.5,
                            color: colors.textSecondary,
                            height: 1.65,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Trust badges
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _TrustBadge(
                              icon: Icons.verified_user_rounded,
                              label: 'Background Checked',
                              color: AppColors.accent,
                            ),
                            _TrustBadge(
                              icon: Icons.shield_rounded,
                              label: '30-Day Guarantee',
                              color: AppColors.primary,
                            ),
                            _TrustBadge(
                              icon: Icons.bolt_rounded,
                              label: 'Emergency 24/7',
                              color: AppColors.warning,
                            ),
                            _TrustBadge(
                              icon: Icons.translate_rounded,
                              label: 'Bengali & English',
                              color: Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Skills & Expertise ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionCard(
                    title: 'Skills & Specializations',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) => _SkillChip(label: skill)).toList(),
                    ),
                  ),
                ),

                // ─── Service Packages (Fiverr / Upwork Style) ────────────────
                SliverToBoxAdapter(
                  child: _SectionCard(
                    title: 'Service Packages',
                    subtitle: 'Upfront & Transparent',
                    child: Column(
                      children: [
                        // Package Selector Tabs
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: List.generate(packages.length, (i) {
                              final isSelected = i == _selectedPackageIndex;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedPackageIndex = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? colors.surface : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.06),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        packages[i]['name'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? AppColors.primary : colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Selected Package Card
                        _PackageDetailCard(
                          packageData: packages[_selectedPackageIndex],
                          onSelect: () => _openBookingSheet(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Portfolio / Previous Work ───────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionCard(
                    title: 'Portfolio & Previous Work',
                    subtitle: '${portfolioItems.length} photos',
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: portfolioItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        return _PortfolioGridTile(
                          item: portfolioItems[index],
                          onTap: () => _showImagePreviewDialog(context, portfolioItems[index]),
                        );
                      },
                    ),
                  ),
                ),

                // ─── Ratings & Reviews ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionCard(
                    title: 'Ratings & Client Reviews',
                    subtitle: '${widget.reviews} verified reviews',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RatingBreakdownBar(
                          rating: widget.rating,
                          reviews: widget.reviews,
                        ),
                        const SizedBox(height: 18),
                        ...reviews.map((r) => _ReviewCard(review: r)),
                      ],
                    ),
                  ),
                ),

                // ─── Bottom Safe Space for Fixed Bar ────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomPadding + 100),
                ),
              ],
            ),

            // ─── Sticky Fixed Bottom Bar ─────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _StickyBottomBar(
                rate: widget.rate,
                isAvailable: widget.isAvailable,
                bottomPadding: bottomPadding,
                onBook: () => _openBookingSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBookingSheet(BuildContext context) {
    BookingCheckoutSheet.show(
      context: context,
      providerName: widget.name,
      serviceName: widget.service,
      rate: widget.rate,
      avatarColor: widget.avatarColor,
      avatarUrl: widget.avatarUrl ?? _getDefaultAvatarFor(widget.name),
    );
  }

  void _showImagePreviewDialog(BuildContext context, _PortfolioItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: const Color(0xFF161622),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Image.network(
                      item.imageUrl,
                      height: 320,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 320,
                        color: Colors.black45,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_rounded, color: Colors.white54, size: 48),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Completed for a verified residential client in Dhaka with 100% satisfaction.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
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

// ─── Cover & Profile Header Widget ───────────────────────────────────────────

class _CoverAndProfileHeader extends StatelessWidget {
  final String name;
  final String service;
  final double rating;
  final int reviews;
  final Color avatarColor;
  final String avatarUrl;
  final bool isAvailable;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final VoidCallback onShare;

  const _CoverAndProfileHeader({
    required this.name,
    required this.service,
    required this.rating,
    required this.reviews,
    required this.avatarColor,
    required this.avatarUrl,
    required this.isAvailable,
    required this.isSaved,
    required this.onSaveToggle,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final coverUrl = _getCoverFor(service);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ─── Cover Image ───────────────────────────────────────────────────
        SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  );
                },
              ),
              // Top & bottom gradients for buttons and contrast
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Overlay action bar (Back, Bookmark, Share)
              Positioned(
                top: topPadding + 8,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _FrostedCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    _FrostedCircleButton(
                      icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      iconColor: isSaved ? AppColors.warning : Colors.white,
                      onTap: onSaveToggle,
                    ),
                    const SizedBox(width: 10),
                    _FrostedCircleButton(
                      icon: Icons.share_rounded,
                      onTap: onShare,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ─── Profile Card overlapping cover ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 200, 16, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF1D9BF0),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Upwork / Fiverr badge pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            const Color(0xFF9D4EDD).withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'TOP RATED',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Location, Availability, and Response time tags
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 15, color: colors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      'Dhaka, Bangladesh',
                      style: TextStyle(fontSize: 12.5, color: colors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.flash_on_rounded, size: 15, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      'Replies in ~15 mins',
                      style: TextStyle(fontSize: 12.5, color: colors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick Action Bar: Message & Call
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            '/chat',
                            extra: {
                              'providerName': name,
                              'serviceName': service,
                              'avatarUrl': avatarUrl,
                              'avatarColor': avatarColor,
                            },
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                        label: const Text('Send Message'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border, width: 1.3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling $name (+880 1712-345678)...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone_outlined, size: 17),
                        label: const Text('Contact Pro'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border, width: 1.3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ─── Profile Avatar Overlapping Cover ──────────────────────────────
        Positioned(
          top: 155,
          left: 36,
          child: Stack(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surface,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: avatarColor,
                      child: Center(
                        child: Text(
                          name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Online / Status indicator dot
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isAvailable ? AppColors.success : colors.textHint,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Key Stats Metric Row ────────────────────────────────────────────────────

class _StatsMetricRow extends StatelessWidget {
  final double rating;
  final int reviews;

  const _StatsMetricRow({
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _StatColumn(
              icon: Icons.star_rounded,
              iconColor: AppColors.warning,
              value: rating.toStringAsFixed(1),
              label: '$reviews reviews',
            ),
            _VerticalLine(color: colors.border),
            const _StatColumn(
              icon: Icons.task_alt_rounded,
              iconColor: AppColors.accent,
              value: '100%',
              label: 'Job Success',
            ),
            _VerticalLine(color: colors.border),
            const _StatColumn(
              icon: Icons.history_rounded,
              iconColor: AppColors.primary,
              value: '250+',
              label: 'Jobs Done',
            ),
            _VerticalLine(color: colors.border),
            const _StatColumn(
              icon: Icons.schedule_rounded,
              iconColor: Color(0xFFEC4899),
              value: '99%',
              label: 'On Time',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalLine extends StatelessWidget {
  final Color color;
  const _VerticalLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: color,
    );
  }
}

// ─── Section Card Wrapper ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Trust Badge Widget ──────────────────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skill Chip ──────────────────────────────────────────────────────────────

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Package Detail Card ─────────────────────────────────────────────────────

class _PackageDetailCard extends StatelessWidget {
  final Map<String, dynamic> packageData;
  final VoidCallback onSelect;

  const _PackageDetailCard({
    required this.packageData,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final features = packageData['features'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                packageData['name'] as String,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                packageData['price'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            packageData['description'] as String,
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.accent),
              const SizedBox(width: 5),
              Text(
                'Turnaround: ${packageData['delivery']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...features.map(
            (feat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feat,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
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
}

// ─── Portfolio Grid Tile ─────────────────────────────────────────────────────

class _PortfolioGridTile extends StatelessWidget {
  final _PortfolioItem item;
  final VoidCallback onTap;

  const _PortfolioGridTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF232336),
                child: const Center(
                  child: Icon(Icons.broken_image_rounded, color: Colors.white38),
                ),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF1E1E2C),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Gradient tag on bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ratings Breakdown Bar ───────────────────────────────────────────────────

class _RatingBreakdownBar extends StatelessWidget {
  final double rating;
  final int reviews;

  const _RatingBreakdownBar({
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: colors.textPrimary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) {
                  return const Icon(
                    Icons.star_rounded,
                    color: AppColors.warning,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$reviews total reviews',
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              children: [
                _StarBar(stars: '5★', percentage: 0.92),
                SizedBox(height: 4),
                _StarBar(stars: '4★', percentage: 0.06),
                SizedBox(height: 4),
                _StarBar(stars: '3★', percentage: 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarBar extends StatelessWidget {
  final String stars;
  final double percentage;

  const _StarBar({
    required this.stars,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Row(
      children: [
        Text(
          stars,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(percentage * 100).toInt()}%',
          style: TextStyle(fontSize: 10, color: colors.textHint),
        ),
      ],
    );
  }
}

// ─── Review Card Widget ──────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Initials circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                  ),
                  child: Center(
                    child: Text(
                      review.avatar,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.name,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < review.rating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_half_rounded,
                              color: AppColors.warning,
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            review.projectType,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textHint,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  review.date,
                  style: TextStyle(fontSize: 11, color: colors.textHint),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky Bottom Bar ───────────────────────────────────────────────────────

class _StickyBottomBar extends StatelessWidget {
  final String rate;
  final bool isAvailable;
  final double bottomPadding;
  final VoidCallback onBook;

  const _StickyBottomBar({
    required this.rate,
    required this.isAvailable,
    required this.bottomPadding,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rate display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Starting at',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rate,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Prominent Book Service button
          Expanded(
            child: GestureDetector(
              onTap: isAvailable ? onBook : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: isAvailable ? AppColors.primaryGradient : null,
                  color: isAvailable ? null : colors.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isAvailable
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable ? 'Book Service' : 'Currently Busy',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Frosted Circle Button ───────────────────────────────────────────────────

class _FrostedCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _FrostedCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

// ─── Helpers & Mock Data ─────────────────────────────────────────────────────

String _getDefaultAvatarFor(String name) {
  if (name.contains('Rahim')) {
    return 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=400';
  } else if (name.contains('Kamal')) {
    return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400';
  } else if (name.contains('Arif')) {
    return 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=400';
  } else if (name.contains('Sumon')) {
    return 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=400';
  }
  return 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=400';
}

String _getCoverFor(String service) {
  final s = service.toLowerCase();
  if (s.contains('plumb')) {
    return 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?auto=format&fit=crop&q=80&w=1200';
  } else if (s.contains('ac') || s.contains('hvac')) {
    return 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?auto=format&fit=crop&q=80&w=1200';
  } else if (s.contains('electr')) {
    return 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=1200';
  } else if (s.contains('paint')) {
    return 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&q=80&w=1200';
  } else if (s.contains('carp')) {
    return 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&q=80&w=1200';
  }
  return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=1200';
}

String _getBioFor(String name, String service) {
  final trade = service.split('·').first.trim();
  final exp = service.contains('·') ? service.split('·').last.trim() : 'several years';
  return 'Hi, I am $name! Certified $trade specialist with over $exp of dedicated hands-on experience serving residential and commercial clients across Dhaka. Whether you need an emergency repair, regular maintenance, or a brand-new installation, I pride myself on punctuality, pristine craftsmanship, and transparent pricing. All work includes a 30-day satisfaction guarantee!';
}

List<String> _getSkillsFor(String service) {
  final s = service.toLowerCase();
  if (s.contains('plumb')) {
    return ['Pipe Leak Repair', 'Water Heater Setup', 'Bathroom Sanitary', 'Drain Unclogging', 'Water Tank Cleaning', 'Kitchen Sinks'];
  } else if (s.contains('ac') || s.contains('hvac')) {
    return ['Split AC Install', 'Gas Charging / Refill', 'Master Servicing', 'Compressor Check', 'Leak Diagnostics', 'Duct Inspection'];
  } else if (s.contains('electr')) {
    return ['Short Circuit Fix', 'Distribution Board', 'Ceiling Fan Wiring', 'LED Architectural Lights', 'Generator Line', 'Appliance Repair'];
  } else if (s.contains('paint')) {
    return ['Interior Wall Paint', 'Exterior Weathercoat', 'Wood Enamel & Polish', 'Waterproofing Wall', 'Texture Finishes', 'Ceiling Distemper'];
  } else if (s.contains('carp')) {
    return ['Custom Woodwork', 'Door & Lock Fitting', 'Modular Kitchen Cabinets', 'Furniture Repair', 'Wardrobe Building', 'Wood Varnishing'];
  }
  return ['General Maintenance', 'Emergency Repairs', 'Equipment Installation', 'Quality Inspection', 'Consultation'];
}

List<Map<String, dynamic>> _getPackagesFor(String service, String baseRate) {
  return [
    {
      'name': 'Basic Inspection',
      'price': baseRate,
      'description': 'On-site diagnosis, minor adjustments, and immediate issue troubleshooting.',
      'delivery': '1-2 Hours',
      'features': [
        'Comprehensive on-site inspection',
        'Minor quick fixes included',
        'Detailed cost estimate for larger parts',
      ],
    },
    {
      'name': 'Standard Repair',
      'price': '৳1,200',
      'description': 'Complete troubleshooting, parts replacement labor, and full testing.',
      'delivery': 'Same Day',
      'features': [
        'Full service & component replacement',
        'Clean-up after completion',
        '30-day work warranty guarantee',
      ],
    },
    {
      'name': 'Full Installation',
      'price': '৳2,500',
      'description': 'Brand new fixture/appliance installation with safety certification.',
      'delivery': '1-2 Days',
      'features': [
        'End-to-end professional fitting',
        'Safety compliance check',
        '60-day priority warranty',
      ],
    },
  ];
}

List<_PortfolioItem> _getPortfolioFor(String service) {
  final s = service.toLowerCase();
  if (s.contains('plumb')) {
    return const [
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=600',
        title: 'Modern Bathroom Plumbing',
        category: 'Plumbing',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&q=80&w=600',
        title: 'High Pressure Pipe Fitting',
        category: 'Pipe Line',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?auto=format&fit=crop&q=80&w=600',
        title: 'Designer Basin Fixtures',
        category: 'Sanitary',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&q=80&w=600',
        title: 'Kitchen Sink Drain Unit',
        category: 'Drainage',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?auto=format&fit=crop&q=80&w=600',
        title: 'Water Heater Installation',
        category: 'Heater',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&q=80&w=600',
        title: 'Emergency Main Valve Repair',
        category: 'Emergency',
      ),
    ];
  } else if (s.contains('ac') || s.contains('hvac')) {
    return const [
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?auto=format&fit=crop&q=80&w=600',
        title: 'Inverter AC Installation',
        category: 'AC Setup',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=600',
        title: 'Deep Master Jet Wash',
        category: 'Servicing',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=600',
        title: 'Gas Refill & Leak Fix',
        category: 'Cooling',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&q=80&w=600',
        title: 'Compressor PCB Repair',
        category: 'Electrical',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&q=80&w=600',
        title: 'Commercial Duct Work',
        category: 'Commercial',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&q=80&w=600',
        title: 'Thermostat Calibration',
        category: 'Controls',
      ),
    ];
  } else if (s.contains('electr')) {
    return const [
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=600',
        title: 'Distribution Board Upgrade',
        category: 'Wiring',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&q=80&w=600',
        title: 'Safety Breaker Fitting',
        category: 'Safety',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=600',
        title: 'False Ceiling LED Lights',
        category: 'Lighting',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&q=80&w=600',
        title: 'Generator Changeover Switch',
        category: 'Power',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=600',
        title: 'Concealed Cable Routing',
        category: 'Wiring',
      ),
      _PortfolioItem(
        imageUrl: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?auto=format&fit=crop&q=80&w=600',
        title: 'Smart Home Switchboard',
        category: 'Smart Home',
      ),
    ];
  }
  return const [
    _PortfolioItem(
      imageUrl: 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&q=80&w=600',
      title: 'Precision Renovation Work',
      category: 'Carpentry',
    ),
    _PortfolioItem(
      imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&q=80&w=600',
      title: 'Interior Wall Finish',
      category: 'Painting',
    ),
    _PortfolioItem(
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=600',
      title: 'Deep Sanitization Service',
      category: 'Cleaning',
    ),
    _PortfolioItem(
      imageUrl: 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&q=80&w=600',
      title: 'Appliance Fitting & Setup',
      category: 'Appliance',
    ),
    _PortfolioItem(
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&q=80&w=600',
      title: 'Cabinet & Door Assembly',
      category: 'Furniture',
    ),
    _PortfolioItem(
      imageUrl: 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?auto=format&fit=crop&q=80&w=600',
      title: 'Commercial Repair Project',
      category: 'Maintenance',
    ),
  ];
}

List<_Review> _getReviewsFor(String service) {
  return const [
    _Review(
      name: 'Tanvir Hossain',
      avatar: 'TH',
      rating: 5.0,
      comment: 'Top notch service! Arrived in under 20 minutes, diagnosed the problem immediately, and had all spare parts in his toolkit. Absolutely worth every taka.',
      date: 'Yesterday',
      projectType: 'Verified Job in Banani',
    ),
    _Review(
      name: 'Sabrina Rahman',
      avatar: 'SR',
      rating: 5.0,
      comment: 'Super polite, wore shoe covers before entering the apartment, and cleaned up the workspace completely before leaving. Outstanding professionalism!',
      date: '3 days ago',
      projectType: 'Verified Job in Dhanmondi',
    ),
    _Review(
      name: 'Mahmudul Hasan',
      avatar: 'MH',
      rating: 4.5,
      comment: 'Very skilled technician. Fixed our issue that two previous handymen couldn’t figure out. Highly recommended for any complex job in Dhaka.',
      date: '1 week ago',
      projectType: 'Verified Job in Uttara',
    ),
  ];
}
