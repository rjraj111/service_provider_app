import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../main_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/video_feed/video_feed_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/provider/provider_details_screen.dart';

/// Provides the app-wide GoRouter instance via Riverpod.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
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
    ],
  );
});
