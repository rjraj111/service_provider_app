import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

// ─── Dummy Video Data ───────────────────────────────────────────────────────

class _VideoPost {
  final String providerName;
  final String description;
  final String service;
  final int likes;
  final int comments;
  final int shares;
  final List<Color> gradientColors;
  final IconData serviceIcon;

  const _VideoPost({
    required this.providerName,
    required this.description,
    required this.service,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.gradientColors,
    required this.serviceIcon,
  });
}

final List<_VideoPost> _dummyVideos = [
  const _VideoPost(
    providerName: 'Rahim Uddin',
    description: 'Fixing a 2-ton AC in Dhanmondi 🔧❄️',
    service: 'AC Repair',
    likes: 2847,
    comments: 312,
    shares: 89,
    gradientColors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    serviceIcon: Icons.ac_unit_rounded,
  ),
  const _VideoPost(
    providerName: 'Kamal Hossain',
    description: 'Complete bathroom plumbing makeover ✨🚿',
    service: 'Plumbing',
    likes: 5102,
    comments: 487,
    shares: 234,
    gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
    serviceIcon: Icons.plumbing_rounded,
  ),
  const _VideoPost(
    providerName: 'Arif Khan',
    description: 'Full house wiring in Gulshan — 4 hours timelapse ⚡',
    service: 'Electrician',
    likes: 8934,
    comments: 921,
    shares: 567,
    gradientColors: [Color(0xFF200122), Color(0xFF6F0000)],
    serviceIcon: Icons.electrical_services_rounded,
  ),
  const _VideoPost(
    providerName: 'Sumon Das',
    description: 'Transforming a living room wall — texture painting 🎨',
    service: 'Painter',
    likes: 3216,
    comments: 198,
    shares: 145,
    gradientColors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E), Color(0xFF3D1C56)],
    serviceIcon: Icons.format_paint_rounded,
  ),
  const _VideoPost(
    providerName: 'Nasir Ahmed',
    description: 'Custom wardrobe build — from scratch to finish 🪵',
    service: 'Carpenter',
    likes: 6750,
    comments: 534,
    shares: 312,
    gradientColors: [Color(0xFF141E30), Color(0xFF243B55)],
    serviceIcon: Icons.carpenter_rounded,
  ),
  const _VideoPost(
    providerName: 'Jamal Mia',
    description: 'Deep cleaning a 3-bedroom apartment 🧹✨',
    service: 'Cleaning',
    likes: 4521,
    comments: 267,
    shares: 178,
    gradientColors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
    serviceIcon: Icons.cleaning_services_rounded,
  ),
];

// ─── Video Feed Screen ──────────────────────────────────────────────────────

/// TikTok/Reels-style vertical video feed showcasing service providers.
class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // ─── Vertical PageView ──────────────────────────────────
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _dummyVideos.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _VideoPage(
                  video: _dummyVideos[index],
                  isActive: _currentPage == index,
                );
              },
            ),

            // ─── Top Bar Overlay ────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TopBarTab(label: 'Following', isActive: false),
          SizedBox(width: 24),
          _TopBarTab(label: 'For You', isActive: true),
          SizedBox(width: 24),
          _TopBarTab(label: 'Trending', isActive: false),
        ],
      ),
    );
  }
}

class _TopBarTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _TopBarTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 24 : 0,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─── Single Video Page ──────────────────────────────────────────────────────

class _VideoPage extends StatefulWidget {
  final _VideoPost video;
  final bool isActive;

  const _VideoPage({required this.video, required this.isActive});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isFollowing = false;
  bool _showPlayIcon = false;
  late AnimationController _playIconController;
  late Animation<double> _playIconAnimation;

  @override
  void initState() {
    super.initState();
    _playIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _playIconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _playIconController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _playIconController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() => _isLiked = true);
    _showPlayIcon = false;
    // Trigger heart animation via a snackbar-less visual cue
    HapticFeedback.lightImpact();
  }

  void _onSingleTap() {
    setState(() => _showPlayIcon = !_showPlayIcon);
    if (_showPlayIcon) {
      _playIconController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onTap: _onSingleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Video Background (gradient placeholder) ──────────
          _VideoBackground(
            gradientColors: video.gradientColors,
            serviceIcon: video.serviceIcon,
          ),

          // ─── Center play/pause indicator ──────────────────────
          if (_showPlayIcon)
            Center(
              child: FadeTransition(
                opacity: _playIconAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),

          // ─── Double-tap heart animation ───────────────────────
          if (_isLiked) const _HeartAnimation(),

          // ─── Bottom gradient for readability ──────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // ─── Right Side Action Buttons ────────────────────────
          Positioned(
            right: 12,
            bottom: bottomPadding + 100,
            child: _ActionButtons(
              video: video,
              isLiked: _isLiked,
              isFollowing: _isFollowing,
              onLikeTap: () => setState(() => _isLiked = !_isLiked),
              onFollowTap: () =>
                  setState(() => _isFollowing = !_isFollowing),
            ),
          ),

          // ─── Bottom Info Overlay ──────────────────────────────
          Positioned(
            left: 16,
            right: 80,
            bottom: bottomPadding + 20,
            child: _BottomInfo(
              video: video,
            ),
          ),

          // ─── Progress Bar ─────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            child: _VideoProgressBar(),
          ),
        ],
      ),
    );
  }
}

// ─── Video Background ───────────────────────────────────────────────────────

class _VideoBackground extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData serviceIcon;

  const _VideoBackground({
    required this.gradientColors,
    required this.serviceIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(),
            ),
          ),
          // Large service icon watermark
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    serviceIcon,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_filled_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Video Preview',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
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
    );
  }
}

// ─── Grid Pattern Painter ───────────────────────────────────────────────────

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Right Side Action Buttons ──────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final _VideoPost video;
  final bool isLiked;
  final bool isFollowing;
  final VoidCallback onLikeTap;
  final VoidCallback onFollowTap;

  const _ActionButtons({
    required this.video,
    required this.isLiked,
    required this.isFollowing,
    required this.onLikeTap,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Profile Picture ─────────────────────────────────
        _ProfileAvatar(
          name: video.providerName,
          isFollowing: isFollowing,
          onFollowTap: onFollowTap,
        ),
        const SizedBox(height: 20),

        // ─── Like Button ─────────────────────────────────────
        _ActionButton(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: _formatCount(video.likes + (isLiked ? 1 : 0)),
          color: isLiked ? const Color(0xFFFF2D55) : Colors.white,
          onTap: onLikeTap,
        ),
        const SizedBox(height: 18),

        // ─── Comment Button ──────────────────────────────────
        _ActionButton(
          icon: Icons.chat_bubble_rounded,
          label: _formatCount(video.comments),
          color: Colors.white,
          onTap: () {},
        ),
        const SizedBox(height: 18),

        // ─── Share Button ────────────────────────────────────
        _ActionButton(
          icon: Icons.send_rounded,
          label: _formatCount(video.shares),
          color: Colors.white,
          onTap: () {},
        ),
        const SizedBox(height: 18),

        // ─── Bookmark Button ─────────────────────────────────
        _ActionButton(
          icon: Icons.bookmark_border_rounded,
          label: 'Save',
          color: Colors.white,
          onTap: () {},
        ),
        const SizedBox(height: 18),

        // ─── Spinning Music Disc ─────────────────────────────
        _MusicDisc(),
      ],
    );
  }
}

// ─── Profile Avatar with Follow Badge ───────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final bool isFollowing;
  final VoidCallback onFollowTap;

  const _ProfileAvatar({
    required this.name,
    required this.isFollowing,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFollowTap,
      child: SizedBox(
        width: 52,
        height: 62,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Avatar circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  name.split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Follow / Following badge
            Positioned(
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isFollowing ? 28 : 24,
                height: isFollowing ? 20 : 24,
                decoration: BoxDecoration(
                  color: isFollowing ? AppColors.accent : const Color(0xFFFF2D55),
                  shape: isFollowing ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isFollowing ? BorderRadius.circular(10) : null,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isFollowing ? Icons.check_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: isFollowing ? 14 : 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Button ──────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: widget.color,
              size: 30,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Spinning Music Disc ────────────────────────────────────────────────────

class _MusicDisc extends StatefulWidget {
  @override
  State<_MusicDisc> createState() => _MusicDiscState();
}

class _MusicDiscState extends State<_MusicDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 8,
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF2D2D44)],
          ),
        ),
        child: const Center(
          child: Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
        ),
      ),
    );
  }
}

// ─── Bottom Info Overlay ────────────────────────────────────────────────────

class _BottomInfo extends StatelessWidget {
  final _VideoPost video;

  const _BottomInfo({required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Provider name + verified badge
        Row(
          children: [
            Text(
              '@${video.providerName.replaceAll(' ', '').toLowerCase()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 10),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                video.service,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          video.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w400,
            height: 1.4,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Scrolling music text + Book Now button
        Row(
          children: [
            // Music row
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.music_note_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '♫ Original Sound — ${video.providerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ─── Book Now Button ────────────────────────────────
            _BookNowButton(video: video),
          ],
        ),
      ],
    );
  }
}

// ─── Book Now Button ────────────────────────────────────────────────────────

class _BookNowButton extends StatefulWidget {
  final _VideoPost? video;

  const _BookNowButton({this.video});

  @override
  State<_BookNowButton> createState() => _BookNowButtonState();
}

class _BookNowButtonState extends State<_BookNowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          final video = widget.video;
          if (video != null) {
            context.push(
              '/provider-details',
              extra: {
                'name': video.providerName,
                'service': '${video.service} · Experienced Pro',
                'rating': 4.9,
                'reviews': 120,
                'rate': '৳500/hr',
                'isAvailable': true,
              },
            );
          } else {
            context.push('/provider-details');
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          listenable: _shimmerController,
          builder: (context, child) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    AppColors.primary,
                    AppColors.primaryLight,
                    AppColors.primary,
                  ],
                  stops: [
                    0.0,
                    _shimmerController.value,
                    1.0,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Animated Builder Helper ────────────────────────────────────────────────

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

// ─── Video Progress Bar ─────────────────────────────────────────────────────

class _VideoProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        children: [
          // Background track
          Container(
            height: 3,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          // Progress (simulated at 35%)
          FractionallySizedBox(
            widthFactor: 0.35,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Heart Animation ────────────────────────────────────────────────────────

class _HeartAnimation extends StatefulWidget {
  const _HeartAnimation();

  @override
  State<_HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<_HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFFF2D55),
                size: 100,
                shadows: [
                  Shadow(color: Colors.black38, blurRadius: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}
