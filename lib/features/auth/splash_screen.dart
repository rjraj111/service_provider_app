import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Premium animated Splash Screen for ServiceHub.
/// Features a smooth multi-phase entrance animation, ambient brand glow,
/// and automatically navigates to /login after a 3-second delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _logoScaleAnim;
  late final Animation<double> _logoFadeAnim;
  late final Animation<double> _contentFadeAnim;
  late final Animation<Offset> _contentSlideAnim;
  late final Animation<double> _pulseAnim;

  Timer? _navTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Logo entrance: Scale & Fade
    _logoScaleAnim = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    // Text & Content entrance: Fade & Slide
    _contentFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Subtle breathing pulse for the ambient ring
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();

    // Navigate to /login after exactly 3 seconds
    _navTimer = Timer(const Duration(milliseconds: 3000), _navigateToLogin);
  }

  void _navigateToLogin() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navTimer?.cancel();
    context.go('/login');
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0C0D14) : const Color(0xFFF7F8FC);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: bgColor,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: bgColor,
              ),
        child: GestureDetector(
          onTap: _navigateToLogin, // Tap anywhere to skip instantly
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ─── Ambient Glow Highlights ─────────────────────────────────
              Positioned(
                top: -100,
                left: -60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -60,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF9D4EDD).withValues(alpha: isDark ? 0.20 : 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Main Centered Brand Content ──────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Logo Emblem
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnim.value * _pulseAnim.value,
                          child: Opacity(
                            opacity: _logoFadeAnim.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.35),
                              blurRadius: 36,
                              spreadRadius: 2,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: const Color(0xFF9D4EDD).withValues(alpha: isDark ? 0.30 : 0.20),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Inner subtle glow sheen
                            Positioned(
                              top: 8,
                              left: 12,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                            ),
                            // Hub / Handshake modern icon
                            const Icon(
                              Icons.hub_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Animated App Name & Tagline
                    SlideTransition(
                      position: _contentSlideAnim,
                      child: FadeTransition(
                        opacity: _contentFadeAnim,
                        child: Column(
                          children: [
                            // "ServiceHub" Brand Wordmark
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Service',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFF6C63FF), Color(0xFFB388FF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Hub',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Subtitle Tagline
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                ),
                              ),
                              child: Text(
                                'On-Demand Pros & Trusted Services',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Bottom Footer & Sleek Loading Pulse ─────────────────────
              Positioned(
                bottom: 42,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _contentFadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minimalist animated loading bar
                      SizedBox(
                        width: 52,
                        height: 3.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: const LinearProgressIndicator(
                            backgroundColor: Color(0x1F6C63FF),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verified Local Professionals in Bangladesh',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colors.textHint.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
