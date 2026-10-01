import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

// ─── AI Diagnostic Preset Model ──────────────────────────────────────────────

class _AiDiagnosisModel {
  final String title;
  final String category;
  final String detectedIssue;
  final String severity;
  final String estTime;
  final String estCost;
  final double confidence;
  final String analysisText;
  final List<String> recommendedParts;
  final List<Map<String, dynamic>> matchedPros;

  const _AiDiagnosisModel({
    required this.title,
    required this.category,
    required this.detectedIssue,
    required this.severity,
    required this.estTime,
    required this.estCost,
    required this.confidence,
    required this.analysisText,
    required this.recommendedParts,
    required this.matchedPros,
  });
}

// ─── AI Search Screen ────────────────────────────────────────────────────────

/// Next-generation multimodal AI Search & Diagnostic Screen.
/// Users can type, speak, or upload images/videos to diagnose problems with AI.
class AiSearchScreen extends StatefulWidget {
  const AiSearchScreen({super.key});

  @override
  State<AiSearchScreen> createState() => _AiSearchScreenState();
}

class _AiSearchScreenState extends State<AiSearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  _AiDiagnosisModel? _currentDiagnosis;
  bool _isSearching = false;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerAiAnalysis({
    String mediaType = 'Photo',
    String? customQuery,
  }) {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _AiScanningBottomSheet(mediaType: mediaType),
    ).then((_) {
      // Upon closing the simulated scanner, display the smart results
      setState(() {
        _currentDiagnosis = _resolveDiagnosis(customQuery ?? _searchController.text);
      });
    });
  }

  void _showMediaPickerSheet() {
    final colors = AppColorsResolved.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Upload Problem for AI Vision Analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Take a photo of pipe leak, switchboard, or appliance'),
              onTap: () {
                Navigator.of(ctx).pop();
                _triggerAiAnalysis(mediaType: 'Camera Photo');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF06B6D4)),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Select existing photo or video recording'),
              onTap: () {
                Navigator.of(ctx).pop();
                _triggerAiAnalysis(mediaType: 'Gallery Image');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.video_library_rounded, color: AppColors.accent),
              ),
              title: const Text('Attach Diagnostic Video Clip', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Analyze sound of motor vibration or leaking water'),
              onTap: () {
                Navigator.of(ctx).pop();
                _triggerAiAnalysis(mediaType: 'Diagnostic Video');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Advanced AI Search Bar ────────────────────────────────────
              _buildTopSearchBar(colors),

              // ─── Main Body (Empty State or Smart Results) ──────────────────
              Expanded(
                child: _currentDiagnosis != null
                    ? _buildSmartResultsView(colors)
                    : _buildDefaultAiPortalView(colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Advanced Search Bar UI ────────────────────────────────────────────────

  Widget _buildTopSearchBar(AppColorsResolved colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: 10),

          // Search Field Container with Action Icons
          Expanded(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35 + (_glowAnimation.value * 0.2)),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08 * _glowAnimation.value),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          _triggerAiAnalysis(customQuery: query);
                        }
                      },
                      onChanged: (text) => setState(() => _isSearching = text.isNotEmpty),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Describe issue or upload media...',
                        hintStyle: TextStyle(fontSize: 13, color: colors.textHint, fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_isSearching)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                          _currentDiagnosis = null;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.clear_rounded, size: 18, color: colors.textHint),
                      ),
                    ),
                  // Camera Icon
                  GestureDetector(
                    onTap: () => _triggerAiAnalysis(mediaType: 'Camera Photo'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(Icons.camera_alt_rounded, size: 21, color: colors.textSecondary),
                    ),
                  ),
                  // Attachment / File Icon
                  GestureDetector(
                    onTap: _showMediaPickerSheet,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(Icons.attach_file_rounded, size: 21, color: colors.textSecondary),
                    ),
                  ),
                  // Mic Icon (Voice Search)
                  GestureDetector(
                    onTap: () => _triggerAiAnalysis(mediaType: 'Voice Diagnostics'),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6, left: 4),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 16),
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

  // ─── Default Portal View: Hero & Quick Prompts ─────────────────────────────

  Widget _buildDefaultAiPortalView(AppColorsResolved colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Hero Diagnostic Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  const Color(0xFF00D9A6).withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'POWERED BY GEMINI VISION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Upload. Diagnose. Resolve.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Snap a photo or short video of any leaking pipe, sparking switch, or noisy AC. Our multimodal AI identifies the root cause and summons the top verified technician.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _triggerAiAnalysis(mediaType: 'Camera Photo'),
                        icon: const Icon(Icons.camera_alt_rounded, size: 17),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showMediaPickerSheet,
                        icon: const Icon(Icons.upload_file_rounded, size: 17),
                        label: const Text('Upload File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Common Symptoms / Quick Prompt Chips
          Text(
            'Try Common Problem Scenarios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any scenario to run instant AI vision simulation',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 12),

          _buildQuickPromptCard(
            icon: Icons.water_drop_rounded,
            color: const Color(0xFF0284C7),
            title: 'Water pipe leak under bathroom basin',
            subtitle: 'Pipe burst, water dripping constantly, joint loose',
            colors: colors,
            onTap: () {
              _searchController.text = 'Water pipe leak';
              _triggerAiAnalysis(mediaType: 'Simulated Water Leak Image', customQuery: 'Water pipe leak');
            },
          ),
          const SizedBox(height: 10),
          _buildQuickPromptCard(
            icon: Icons.ac_unit_rounded,
            color: const Color(0xFF06B6D4),
            title: 'AC running but blowing room-temp air',
            subtitle: 'Compressor not starting, possible gas leak / capacitor',
            colors: colors,
            onTap: () {
              _searchController.text = 'AC warm air';
              _triggerAiAnalysis(mediaType: 'Simulated AC Compressor Photo', customQuery: 'AC warm air');
            },
          ),
          const SizedBox(height: 10),
          _buildQuickPromptCard(
            icon: Icons.bolt_rounded,
            color: const Color(0xFFF59E0B),
            title: 'Main circuit breaker trips when geyser starts',
            subtitle: 'Short circuit, earthing fault, heavy overload',
            colors: colors,
            onTap: () {
              _searchController.text = 'Circuit breaker trip';
              _triggerAiAnalysis(mediaType: 'Simulated Switchboard Photo', customQuery: 'Circuit breaker trip');
            },
          ),
          const SizedBox(height: 10),
          _buildQuickPromptCard(
            icon: Icons.format_paint_rounded,
            color: const Color(0xFFEF4444),
            title: 'Damp wall with peeling paint & mold',
            subtitle: 'Waterproofing required, internal wall seepage',
            colors: colors,
            onTap: () {
              _searchController.text = 'Wall damp paint';
              _triggerAiAnalysis(mediaType: 'Simulated Damp Wall Photo', customQuery: 'Wall damp paint');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required AppColorsResolved colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.textHint),
          ],
        ),
      ),
    );
  }

  // ─── Smart Results View ────────────────────────────────────────────────────

  Widget _buildSmartResultsView(AppColorsResolved colors) {
    final diag = _currentDiagnosis!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── AI Diagnosis Summary Card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.surface,
                  colors.surfaceVariant.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag + Confidence badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 5),
                          Text(
                            'AI VISION DIAGNOSIS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(diag.confidence * 100).toStringAsFixed(1)}% Match',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Detected Issue Header
                Text(
                  'Detected: ${diag.detectedIssue}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Recommended Service: ',
                      style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    ),
                    Text(
                      diag.category,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: colors.border),
                const SizedBox(height: 10),

                // Analysis Explanation
                Text(
                  diag.analysisText,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 14),

                // Metrics Pills (Time, Cost, Severity)
                Row(
                  children: [
                    _buildMetricPill(
                      icon: Icons.timer_outlined,
                      label: 'Est. Fix: ${diag.estTime}',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricPill(
                      icon: Icons.price_check_rounded,
                      label: 'Labor: ${diag.estCost}',
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricPill(
                      icon: Icons.warning_amber_rounded,
                      label: diag.severity,
                      color: AppColors.warning,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                // Suggested Spare Parts
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: diag.recommendedParts.map((part) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔧 $part',
                        style: TextStyle(fontSize: 11, color: colors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Matched Top Verified Specialists ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Specialists for this Issue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Verified Pros',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Provider Cards List
          ...diag.matchedPros.map((pro) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MatchedProviderCard(
                proData: pro,
                onTap: () {
                  context.push('/provider-details', extra: pro);
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          // Re-scan or Try Another Query CTA
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() => _currentDiagnosis = null);
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Clear and Scan Another Problem'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Matched Provider Card ───────────────────────────────────────────────────

class _MatchedProviderCard extends StatelessWidget {
  final Map<String, dynamic> proData;
  final VoidCallback onTap;

  const _MatchedProviderCard({
    required this.proData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final avatarColor = proData['avatarColor'] as Color? ?? AppColors.primary;
    final avatarUrl = proData['avatarUrl'] as String?;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: avatarColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: avatarColor, size: 28),
                            )
                          : Icon(Icons.person_rounded, color: avatarColor, size: 28),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Pro Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            proData['name'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF1D9BF0)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      proData['service'] as String,
                      style: TextStyle(fontSize: 12.5, color: colors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 15),
                        const SizedBox(width: 2),
                        Text(
                          '${proData['rating']}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.textPrimary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${proData['reviews']} reviews) · 1.5 km away',
                          style: TextStyle(fontSize: 11, color: colors.textHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price & Book CTA
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    proData['rate'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Book Pro',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
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

// ─── Simulated AI Vision Scanning Bottom Sheet ───────────────────────────────

class _AiScanningBottomSheet extends StatefulWidget {
  final String mediaType;
  const _AiScanningBottomSheet({required this.mediaType});

  @override
  State<_AiScanningBottomSheet> createState() => _AiScanningBottomSheetState();
}

class _AiScanningBottomSheetState extends State<_AiScanningBottomSheet> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  int _currentStepIndex = 0;
  Timer? _stepTimer;

  final List<String> _scanSteps = [
    'Uploading 4K frame to Gemini Vision...',
    'Extracting multimodal visual features...',
    'Cross-referencing Dhaka technician catalog...',
    'Detecting defects & matching local experts...',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Step-by-step text progress
    _stepTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (mounted && _currentStepIndex < _scanSteps.length - 1) {
        setState(() => _currentStepIndex++);
      }
    });

    // Auto-complete after ~2.6 seconds
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111118),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 36),

          // Futuristic Holographic Orb with Rotating Ring
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating gradient ring
                RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.accent,
                          Color(0xFF9D4EDD),
                          AppColors.primary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Inner dark cutout
                Container(
                  width: 114,
                  height: 114,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF111118),
                  ),
                ),
                // Pulsing Center AI icon
                ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.15).animate(
                    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Analyzing Media with AI...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Source: ${widget.mediaType} · Neural Engine v3.2',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Animated Step Status Banner
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_currentStepIndex),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _scanSteps[_currentStepIndex],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Preset Diagnoses Resolver ───────────────────────────────────────────────

_AiDiagnosisModel _resolveDiagnosis(String query) {
  final q = query.toLowerCase();

  if (q.contains('ac') || q.contains('air') || q.contains('cool') || q.contains('heat')) {
    return const _AiDiagnosisModel(
      title: 'AC Diagnosis',
      category: 'AC & HVAC Servicing',
      detectedIssue: 'Refrigerant Gas Leak & Capacitor Degradation',
      severity: 'Medium Severity',
      estTime: '45 - 60 mins',
      estCost: '৳800',
      confidence: 0.982,
      analysisText:
          'Thermal signature and acoustic profiling indicate low gas pressure and a struggling condenser fan. The unit is drawing 30% more power than rated. Requires leak check, pressure testing, and refrigerant refill.',
      recommendedParts: ['R32 Refrigerant Gas (500g)', '45uF Run Capacitor', 'Flare Nut Fitting'],
      matchedPros: [
        {
          'name': 'Kamal Hossain',
          'service': 'AC Repair · 12 yrs exp',
          'rating': 4.8,
          'reviews': 94,
          'rate': '৳800/visit',
          'avatarColor': Color(0xFF06B6D4),
          'isAvailable': true,
          'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
        },
        {
          'name': 'Rahim Uddin',
          'service': 'AC Master Technician',
          'rating': 4.9,
          'reviews': 127,
          'rate': '৳750/visit',
          'avatarColor': Color(0xFF3B82F6),
          'isAvailable': true,
          'avatarUrl': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=400',
        },
      ],
    );
  } else if (q.contains('elect') || q.contains('breaker') || q.contains('wire') || q.contains('switch')) {
    return const _AiDiagnosisModel(
      title: 'Electrical Diagnosis',
      category: 'Master Electrician',
      detectedIssue: 'Neutral Overload & Distribution Breaker Fault',
      severity: 'High Hazard',
      estTime: '30 - 45 mins',
      estCost: '৳450',
      confidence: 0.991,
      analysisText:
          'Visual inspection highlights burn discolouration on the sub-distribution terminal. The 32A MCB is tripping under high-inductive geyser load. Requires terminal replacement and load redistribution to prevent short circuit.',
      recommendedParts: ['Havells 32A Double Pole MCB', 'Copper Neutral Busbar', 'Heat Shrink Sleeves'],
      matchedPros: [
        {
          'name': 'Arif Khan',
          'service': 'Electrician · 6 yrs exp',
          'rating': 4.7,
          'reviews': 63,
          'rate': '৳450/hr',
          'avatarColor': Color(0xFFF59E0B),
          'isAvailable': true,
          'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=400',
        },
      ],
    );
  } else if (q.contains('paint') || q.contains('wall') || q.contains('damp') || q.contains('mold')) {
    return const _AiDiagnosisModel(
      title: 'Painting & Damp Diagnosis',
      category: 'Professional Painting',
      detectedIssue: 'Sub-surface Moisture Seepage & Wall Paint Peeling',
      severity: 'Medium',
      estTime: '1 - 2 Days',
      estCost: '৳600/hr',
      confidence: 0.974,
      analysisText:
          'Moisture mapping shows 72% relative humidity inside the masonry plaster. The topcoat has delaminated due to efflorescence salts. Recommended procedure: strip to bare plaster, apply crystalline waterproof primer, and 2 coats of anti-fungal paint.',
      recommendedParts: ['Berger Dampproof Primer', 'WeatherCoat Anti-Fungal', 'Plaster Putty (5kg)'],
      matchedPros: [
        {
          'name': 'Sumon Das',
          'service': 'Painter · 10 yrs exp',
          'rating': 4.9,
          'reviews': 201,
          'rate': '৳600/hr',
          'avatarColor': Color(0xFFEF4444),
          'isAvailable': true,
          'avatarUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=400',
        },
      ],
    );
  }

  // Default: Water pipe leak
  return const _AiDiagnosisModel(
    title: 'Plumbing Diagnosis',
    category: 'Plumbing & Sanitary',
    detectedIssue: 'Water Pipe Leak & Joint Corrosion',
    severity: 'Urgent Attention',
    estTime: '30 - 50 mins',
    estCost: '৳500/hr',
    confidence: 0.987,
    analysisText:
        'Multimodal vision detected a microscopic hairline fracture near the threaded elbow joint under the sink basin. Pressure build-up is causing continuous water seepage. Recommend replacing the threaded adapter and resealing with Teflon tape.',
    recommendedParts: ['1/2 inch Brass Threaded Elbow', 'Teflon Sealing Tape', 'Heavy Duty PVC Union'],
    matchedPros: [
      {
        'name': 'Rahim Uddin',
        'service': 'Plumber · 8 yrs exp',
        'rating': 4.9,
        'reviews': 127,
        'rate': '৳500/hr',
        'avatarColor': Color(0xFF3B82F6),
        'isAvailable': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=400',
      },
      {
        'name': 'Nasir Ahmed',
        'service': 'Emergency Plumbing Pro',
        'rating': 4.8,
        'reviews': 156,
        'rate': '৳700/hr',
        'avatarColor': Color(0xFF8B5CF6),
        'isAvailable': true,
        'avatarUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=400',
      },
    ],
  );
}
