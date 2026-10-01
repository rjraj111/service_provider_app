import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Elite Uber/Pathao style Live Tracking Screen.
/// Displays an interactive simulated map with animated moving provider pin,
/// route path, top ETA card, live journey timeline, and quick action panel.
class LiveTrackingScreen extends StatefulWidget {
  final String providerName;
  final String serviceName;
  final String? avatarUrl;
  final Color avatarColor;
  final String initialEta;
  final String initialDistance;

  const LiveTrackingScreen({
    super.key,
    this.providerName = 'Rahim Uddin',
    this.serviceName = 'Plumber · 8 yrs exp',
    this.avatarUrl = 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=400',
    this.avatarColor = const Color(0xFF3B82F6),
    this.initialEta = '12 mins',
    this.initialDistance = '1.8 km',
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with TickerProviderStateMixin {
  late final AnimationController _radarController;
  late final AnimationController _movementController;
  late final Animation<double> _radarRadius;
  late final Animation<double> _radarOpacity;

  int _minutesRemaining = 12;
  double _distanceRemaining = 1.8;
  Timer? _countdownTimer;

  // Live journey steps
  final List<Map<String, dynamic>> _journeySteps = [
    {'title': 'Booking Accepted', 'time': '10:45 AM', 'isDone': true},
    {'title': 'Technician on the Way', 'time': '10:50 AM', 'isDone': true, 'isActive': true},
    {'title': 'Arrived at Destination', 'time': 'Estimated 11:02 AM', 'isDone': false},
    {'title': 'Service Started', 'time': 'Estimated 11:05 AM', 'isDone': false},
  ];

  @override
  void initState() {
    super.initState();
    // Parse minutes from initial ETA if possible
    final numRegex = RegExp(r'\d+');
    final match = numRegex.firstMatch(widget.initialEta);
    if (match != null) {
      _minutesRemaining = int.tryParse(match.group(0)!) ?? 12;
    }

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _radarRadius = Tween<double>(begin: 20, end: 75).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );
    _radarOpacity = Tween<double>(begin: 0.65, end: 0.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );

    // Subtle GPS movement oscillation
    _movementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Simulated countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (mounted && _minutesRemaining > 1) {
        setState(() {
          _minutesRemaining--;
          _distanceRemaining = (_distanceRemaining - 0.15).clamp(0.2, 5.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _radarController.dispose();
    _movementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF101018) : const Color(0xFFF3F4F8),
        body: Stack(
          children: [
            // ─── 1. Simulated Map Canvas with GPS Route ──────────────────────
            Positioned.fill(
              child: _buildSimulatedMap(isDark),
            ),

            // ─── 2. Top Header & Prominent ETA Card ──────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _buildTopEtaCard(colors),
            ),

            // ─── 3. Floating Map Action Buttons (Recenter & Safety) ──────────
            Positioned(
              right: 16,
              bottom: 340 + bottomPadding,
              child: _buildFloatingMapControls(colors),
            ),

            // ─── 4. Sleek Bottom Sheet Panel (Uber/Pathao Style) ─────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomProviderPanel(colors, bottomPadding),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Simulated Map with Route & Animated GPS Pins ──────────────────────────

  Widget _buildSimulatedMap(bool isDark) {
    return AnimatedBuilder(
      animation: _movementController,
      builder: (context, child) {
        // Subtle offset simulation to mimic real-time movement
        final moveOffset = _movementController.value * 8.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Base Map Image
            Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=1200',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: isDark ? const Color(0xFF14141E) : const Color(0xFFE5E7EB),
                child: const Center(
                  child: Icon(Icons.map_rounded, size: 72, color: Colors.white24),
                ),
              ),
            ),

            // Contrast Tint Overlay (adapts to light / dark mode)
            Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.25),
            ),

            // Custom Painted GPS Route Line
            CustomPaint(
              painter: _GpsRoutePainter(
                routeColor: AppColors.primary,
                pulseProgress: _movementController.value,
              ),
            ),

            // ─── Customer Destination Marker (Gulshan 2, Dhaka) ─────────────
            Positioned(
              top: MediaQuery.of(context).size.height * 0.26,
              right: 80,
              child: _buildDestinationPin(),
            ),

            // ─── Moving Provider Marker with Radar Waves ────────────────────
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.42) - moveOffset,
              left: 100 + moveOffset,
              child: _buildMovingProviderMarker(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDestinationPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_rounded, color: AppColors.accent, size: 14),
              SizedBox(width: 4),
              Text(
                'Your Home (Gulshan 2)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMovingProviderMarker() {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Expanding Radar Wave 1
            Container(
              width: _radarRadius.value * 2,
              height: _radarRadius.value * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: _radarOpacity.value),
              ),
            ),
            // Outer Ring
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            // Central Provider Avatar Badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.avatarUrl != null
                    ? Image.network(
                        widget.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.two_wheeler_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.two_wheeler_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
            // Floating Vehicle / Service Badge
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: Colors.black,
                  size: 11,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Top Floating ETA Card ─────────────────────────────────────────────────

  Widget _buildTopEtaCard(AppColorsResolved colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),

        // Prominent ETA Banner Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Live radar pulse dot
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
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE TRACKING · EN ROUTE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_distanceRemaining.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Arriving in $_minutesRemaining mins',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.providerName} is approaching via Kamal Ataturk Ave',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Trip progress indicator bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 4,
                    backgroundColor: colors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Floating Map Controls (Recenter & Safety) ─────────────────────────────

  Widget _buildFloatingMapControls(AppColorsResolved colors) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Safety Toolkit active: Emergency contacts notified.'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Map recentered on provider route.'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
              ],
            ),
            child: Icon(Icons.my_location_rounded, color: colors.textPrimary, size: 20),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Sheet Panel (Uber/Pathao Style) ────────────────────────────────

  Widget _buildBottomProviderPanel(AppColorsResolved colors, double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 16),

          // Provider Profile & Vehicle Info
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: widget.avatarUrl != null
                      ? Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: widget.avatarColor,
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                          ),
                        )
                      : Container(
                          color: widget.avatarColor,
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.providerName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF1D9BF0)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.serviceName.split('·').first.trim()} · Hero Splendor (Metro-Ha 42-9018)',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
                        const SizedBox(width: 3),
                        Text(
                          '4.9 (127 jobs)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Mask & Toolbag Checked',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 14),

          // ─── Journey Step Timeline ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_journeySteps.length, (i) {
              final step = _journeySteps[i];
              final isDone = step['isDone'] as bool;
              final isActive = step['isActive'] as bool? ?? false;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (i > 0)
                          Expanded(
                            child: Container(
                              height: 2.5,
                              color: isDone ? AppColors.primary : colors.border,
                            ),
                          ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? AppColors.primary
                                : isActive
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : colors.surfaceVariant,
                            border: Border.all(
                              color: isDone || isActive ? AppColors.primary : colors.border,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                                : isActive
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                        if (i < _journeySteps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2.5,
                              color: isDone && !isActive ? AppColors.primary : colors.border,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : isDone
                                ? colors.textPrimary
                                : colors.textHint,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // ─── Quick Action Buttons: Call, Message, Share ────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dialing ${widget.providerName} (+880 1712-345678)...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening chat with ${widget.providerName}...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Live tracking link copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(Icons.share_rounded, size: 18, color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Custom GPS Route Painter ────────────────────────────────────────────────

class _GpsRoutePainter extends CustomPainter {
  final Color routeColor;
  final double pulseProgress;

  _GpsRoutePainter({
    required this.routeColor,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.32, size.height * 0.42);
    final end = Offset(size.width * 0.72, size.height * 0.28);
    final controlPoint1 = Offset(size.width * 0.42, size.height * 0.34);
    final controlPoint2 = Offset(size.width * 0.58, size.height * 0.40);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );

    // Glow under path
    final glowPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.3)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, glowPaint);

    // Solid core path
    final corePaint = Paint()
      ..color = routeColor
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant _GpsRoutePainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
