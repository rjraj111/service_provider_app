import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Shows the review, rating and tipping bottom sheet.
///
/// Example usage:
/// ```dart
/// showReviewBottomSheet(
///   context,
///   providerName: 'Rahim Uddin',
///   serviceName: 'Master AC Servicing',
///   onSubmit: (rating, feedback, tip) {
///     // Handle rating submission
///   },
/// );
/// ```
Future<void> showReviewBottomSheet(
  BuildContext context, {
  String providerName = 'Rahim Uddin',
  String serviceName = 'Master AC Servicing',
  String? avatarUrl,
  Color avatarColor = const Color(0xFF3B82F6),
  void Function(int rating, String feedback, int? tipAmount)? onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => ReviewBottomSheet(
      providerName: providerName,
      serviceName: serviceName,
      avatarUrl: avatarUrl,
      avatarColor: avatarColor,
      onSubmit: onSubmit,
    ),
  );
}

/// A highly interactive, premium Review, Rating & Tips Bottom Sheet.
/// Appears when a service order is marked complete to collect user feedback,
/// star ratings, optional compliments, and provider appreciation tips.
class ReviewBottomSheet extends StatefulWidget {
  final String providerName;
  final String serviceName;
  final String? avatarUrl;
  final Color avatarColor;
  final void Function(int rating, String feedback, int? tipAmount)? onSubmit;

  const ReviewBottomSheet({
    super.key,
    this.providerName = 'Rahim Uddin',
    this.serviceName = 'Master AC Servicing',
    this.avatarUrl,
    this.avatarColor = const Color(0xFF3B82F6),
    this.onSubmit,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController();

  // Tipping options: null = no tip, -1 = custom 'Other'
  int? _selectedTipAmount;
  bool _isCustomTipSelected = false;
  bool _isSubmitting = false;

  final List<String> _complimentTags = [
    'Punctual',
    'Clean Work',
    'Polite',
    'Expert Advice',
    'Fair Pricing',
  ];
  final Set<String> _selectedCompliments = {};

  @override
  void dispose() {
    _feedbackController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  int? get _resolvedTipAmount {
    if (_isCustomTipSelected) {
      return int.tryParse(_customTipController.text.trim());
    }
    return _selectedTipAmount;
  }

  String _getRatingFeedbackLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Exceptional service!';
      case 4:
        return 'Great job!';
      case 3:
        return 'Good service';
      case 2:
        return 'Could be better';
      case 1:
        return 'Disappointing';
      default:
        return 'Tap a star to rate';
    }
  }

  void _selectPresetTip(int amount) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedTipAmount == amount && !_isCustomTipSelected) {
        _selectedTipAmount = null; // deselect
      } else {
        _selectedTipAmount = amount;
        _isCustomTipSelected = false;
        _customTipController.clear();
      }
    });
  }

  void _selectCustomTip() {
    HapticFeedback.selectionClick();
    setState(() {
      _isCustomTipSelected = true;
      _selectedTipAmount = null;
    });
  }

  void _toggleCompliment(String tag) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedCompliments.contains(tag)) {
        _selectedCompliments.remove(tag);
      } else {
        _selectedCompliments.add(tag);
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    // Brief simulated network dispatch delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final finalTip = _resolvedTipAmount;
    final feedbackText = _feedbackController.text.trim();

    widget.onSubmit?.call(
      _selectedRating,
      feedbackText,
      finalTip,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                finalTip != null && finalTip > 0
                    ? 'Thank you! Your $_selectedRating-star review & ৳$finalTip tip were sent to ${widget.providerName}.'
                    : 'Thank you! Your $_selectedRating-star review was submitted for ${widget.providerName}.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final tip = _resolvedTipAmount;
    final submitButtonLabel = (tip != null && tip > 0)
        ? 'Submit Review & Pay ৳$tip Tip'
        : 'Submit Review';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ─── 1. Drag Handle ──────────────────────────────────────
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textHint.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── 2. Provider Avatar & Header ─────────────────────────
                  _buildHeader(colors, isDark),

                  const SizedBox(height: 20),

                  // ─── 3. Interactive 5-Star Rating ────────────────────────
                  _buildStarRatingSection(colors),

                  const SizedBox(height: 16),

                  // ─── 4. Quick Compliment Chips ───────────────────────────
                  _buildComplimentsSection(colors),

                  const SizedBox(height: 18),

                  // ─── 5. Feedback Input Field ─────────────────────────────
                  _buildFeedbackField(colors),

                  const SizedBox(height: 22),

                  // ─── 6. Tipping Section (Crucial) ────────────────────────
                  _buildTippingSection(colors, isDark),

                  const SizedBox(height: 24),

                  // ─── 7. Submit Review Button ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (tip != null && tip > 0)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.favorite_rounded, size: 18, color: Colors.pinkAccent),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.rate_review_rounded, size: 18),
                                  ),
                                Text(
                                  submitButtonLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Safe escrow guarantee microcopy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 13,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Verified ServiceHub Review · 100% Transparent',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header: Profile Picture & Title ─────────────────────────────────────────

  Widget _buildHeader(AppColorsResolved colors, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Provider Profile Picture Placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.avatarColor,
                border: Border.all(
                  color: colors.surface,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.avatarColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        widget.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                      ),
                    )
                  : _buildAvatarPlaceholder(),
            ),

            // Verified Completed Service Checkmark Badge
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Exact Title Request: 'How was your service with Rahim Uddin?'
        Text(
          'How was your service with ${widget.providerName}?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        // Subtitle with service info
        Text(
          '${widget.serviceName} · Service Completed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Text(
        widget.providerName.isNotEmpty ? widget.providerName[0] : 'P',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ─── Interactive 5-Star Rating ───────────────────────────────────────────────

  Widget _buildStarRatingSection(AppColorsResolved colors) {
    return Column(
      children: [
        // 5 Star Rating Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isFilled = starNumber <= _selectedRating;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedRating = starNumber);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  scale: isFilled ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 42,
                    color: isFilled
                        ? const Color(0xFFF59E0B)
                        : colors.textHint.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Dynamic Rating Caption
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _getRatingFeedbackLabel(_selectedRating),
            key: ValueKey<int>(_selectedRating),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD97706),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Compliments Selection ──────────────────────────────────────────────────

  Widget _buildComplimentsSection(AppColorsResolved colors) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: _complimentTags.map((tag) {
        final isSelected = _selectedCompliments.contains(tag);

        return InkWell(
          onTap: () => _toggleCompliment(tag),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : colors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : colors.border,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Feedback Text Field ─────────────────────────────────────────────────────

  Widget _buildFeedbackField(AppColorsResolved colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: TextField(
        controller: _feedbackController,
        maxLines: 3,
        style: TextStyle(
          fontSize: 13.5,
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Write an optional feedback...',
          hintStyle: TextStyle(
            fontSize: 13.5,
            color: colors.textHint,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    );
  }

  // ─── Tipping Section (Crucial) ───────────────────────────────────────────────

  Widget _buildTippingSection(AppColorsResolved colors, bool isDark) {
    final presetTips = [20, 50, 100];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF281C26),
                  const Color(0xFF1E1724),
                ]
              : [
                  const Color(0xFFFDF2F8),
                  const Color(0xFFF5F3FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEC4899).withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipping Header with Heart/Gift Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: Color(0xFFEC4899),
                ),
              ),
              const SizedBox(width: 10),
              // Exact Header wording: 'Say thanks with a tip (100% goes to the provider)'
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Say thanks with a tip (100% goes to the provider)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Directly rewards great craftsmanship',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Selectable Tip Chips: '৳20', '৳50', '৳100', 'Other'
          Row(
            children: [
              ...presetTips.map((amount) {
                final isSelected =
                    _selectedTipAmount == amount && !_isCustomTipSelected;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildTipChip(
                      label: '৳$amount',
                      isSelected: isSelected,
                      onTap: () => _selectPresetTip(amount),
                      colors: colors,
                      isDark: isDark,
                    ),
                  ),
                );
              }),

              // 'Other' Custom Chip
              Expanded(
                child: _buildTipChip(
                  label: 'Other',
                  isSelected: _isCustomTipSelected,
                  onTap: _selectCustomTip,
                  colors: colors,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // Custom Tip Inline Input Field (when 'Other' is tapped)
          if (_isCustomTipSelected) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '৳',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEC4899),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _customTipController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter custom tip amount',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: colors.textHint,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_customTipController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.cancel_rounded, size: 16, color: colors.textHint),
                      onPressed: () {
                        setState(() {
                          _customTipController.clear();
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppColorsResolved colors,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEC4899)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEC4899)
                : colors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? Colors.white
                : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
