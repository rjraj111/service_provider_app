import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Voice Search screen — placeholder for voice-based search UI.
class VoiceSearchScreen extends StatelessWidget {
  const VoiceSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(
          'Voice Search',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.voiceSearchGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_rounded,
                  size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Voice Search',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the mic and describe what you need',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
