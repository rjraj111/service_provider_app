import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../main_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/video_feed/video_feed_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/provider/provider_details_screen.dart';
import '../../features/search/ai_search_screen.dart';
import '../../features/tracking/live_tracking_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/provider_dashboard/provider_dashboard_screen.dart';
import '../../features/provider_dashboard/provider_kyc_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/explore/explore_services_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_verification_screen.dart';

/// Provides the app-wide GoRouter instance via Riverpod.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final phone = (state.extra as String?) ??
              state.uri.queryParameters['phone'] ??
              '+880 1712 345 678';
          return CustomTransitionPage(
            key: state.pageKey,
            child: OtpVerificationScreen(phoneNumber: phone),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/video-feed',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/provider-details',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return ProviderDetailsScreen(
              name: extra['name'] as String? ?? 'Rahim Uddin',
              service: extra['service'] as String? ?? 'Plumber · 8 yrs exp',
              rating: (extra['rating'] as num?)?.toDouble() ?? 4.9,
              reviews: extra['reviews'] as int? ?? 127,
              rate: extra['rate'] as String? ?? '৳500/hr',
              avatarColor: extra['avatarColor'] as Color? ?? const Color(0xFF3B82F6),
              isAvailable: extra['isAvailable'] as bool? ?? true,
              avatarUrl: extra['avatarUrl'] as String?,
            );
          }
          return const ProviderDetailsScreen();
        },
      ),
      GoRoute(
        path: '/ai-search',
        builder: (context, state) => const AiSearchScreen(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final pName = (extra['providerName'] ?? extra['name']) as String? ?? 'Rahim Uddin';
            final sName = (extra['serviceName'] ?? extra['service'] ?? extra['profession']) as String? ?? 'Plumber · 8 yrs exp';
            final etaStr = (extra['eta'] ?? (extra['etaMinutes'] != null ? '${extra['etaMinutes']} mins' : null)) as String? ?? '12 mins';
            final distStr = (extra['distance'] ?? (extra['distanceKm'] != null ? '${extra['distanceKm']} km' : null)) as String? ?? '1.8 km';

            return LiveTrackingScreen(
              providerName: pName,
              serviceName: sName,
              avatarUrl: extra['avatarUrl'] as String?,
              avatarColor: extra['avatarColor'] as Color? ?? const Color(0xFF3B82F6),
              initialEta: etaStr,
              initialDistance: distStr,
            );
          }
          return const LiveTrackingScreen();
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final pName = (extra['providerName'] ?? extra['name']) as String? ?? 'Rahim Uddin';
            final sName = (extra['serviceName'] ?? extra['service'] ?? extra['profession']) as String? ?? 'Plumber · 8 yrs exp';
            return ChatScreen(
              providerName: pName,
              serviceName: sName,
              avatarUrl: extra['avatarUrl'] as String?,
              avatarColor: extra['avatarColor'] as Color? ?? const Color(0xFF3B82F6),
            );
          }
          return const ChatScreen();
        },
      ),
      GoRoute(
        path: '/provider-dashboard',
        builder: (context, state) => const ProviderDashboardScreen(),
      ),
      GoRoute(
        path: '/provider-kyc',
        builder: (context, state) => const ProviderKycScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is String) {
            return ExploreServicesScreen(initialQuery: extra);
          }
          return const ExploreServicesScreen();
        },
      ),
    ],
  );
});
