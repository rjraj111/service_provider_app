import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Data class representing an item in the KYC document submission checklist
class _KycDocItem {
  final String id;
  final String title;
  final String subtitle;
  final String tip;
  final IconData icon;
  bool isUploaded = false;
  String? fileName;
  String? fileSize;
  String? uploadTime;

  _KycDocItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tip,
    required this.icon,
  });
}

/// A highly secure, professional Provider KYC (Know Your Customer) Verification Screen.
/// Includes a 3-step progress tracker, custom dashed-border upload cards for NID front,
/// NID back, and Live Selfie, 256-bit encryption trust badges, and an interactive review submission.
class ProviderKycScreen extends StatefulWidget {
  const ProviderKycScreen({super.key});

  @override
  State<ProviderKycScreen> createState() => _ProviderKycScreenState();
}

class _ProviderKycScreenState extends State<ProviderKycScreen> {
  bool _isSubmitting = false;

  late final List<_KycDocItem> _documents;

  @override
  void initState() {
    super.initState();
    _documents = [
      _KycDocItem(
        id: 'nid_front',
        title: 'Upload NID Front',
        subtitle: 'Clear front photo showing your face and National ID number',
        tip: 'JPG, PNG or PDF (Max 5MB)',
        icon: Icons.credit_card_rounded,
      ),
      _KycDocItem(
        id: 'nid_back',
        title: 'Upload NID Back',
        subtitle: 'Back side showing your address, blood group, and barcode',
        tip: 'Ensure all 4 corners are clearly visible',
        icon: Icons.flip_to_back_rounded,
      ),
      _KycDocItem(
        id: 'selfie',
        title: 'Take a Live Selfie',
        subtitle: 'Real-time face verification in good lighting without glasses or caps',
        tip: 'Hold camera directly at eye level',
        icon: Icons.face_rounded,
      ),
    ];
  }

  int get _uploadedCount => _documents.where((d) => d.isUploaded).length;

  int get _currentStepIndex {
    if (_documents[0].isUploaded && _documents[1].isUploaded && _documents[2].isUploaded) {
      return 2; // Step 3: Review
    } else if (_documents[0].isUploaded && _documents[1].isUploaded) {
      return 1; // Step 2: Selfie
    }
    return 0; // Step 1: ID Document
  }

  void _autofillAllDemoDocs() {
    HapticFeedback.lightImpact();
    setState(() {
      _documents[0].isUploaded = true;
      _documents[0].fileName = 'nid_smart_card_front.jpg';
      _documents[0].fileSize = '2.4 MB';
      _documents[0].uploadTime = 'Just now';

      _documents[1].isUploaded = true;
      _documents[1].fileName = 'nid_smart_card_back.jpg';
      _documents[1].fileSize = '1.8 MB';
      _documents[1].uploadTime = 'Just now';

      _documents[2].isUploaded = true;
      _documents[2].fileName = 'live_selfie_biometric.jpg';
      _documents[2].fileSize = '3.1 MB';
      _documents[2].uploadTime = 'Just now';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Demo documents attached: NID Front, Back & Selfie',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showUploadPicker(_KycDocItem item) {
    HapticFeedback.lightImpact();
    final colors = AppColorsResolved.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textHint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.tip,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(height: 1, color: colors.divider),
                const SizedBox(height: 12),

                // Option 1: Camera
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: colors.textPrimary, size: 20),
                  ),
                  title: Text(
                    item.id == 'selfie' ? 'Take Live Selfie' : 'Take Photo with Camera',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Instant capture with auto-focus and alignment check',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _simulateUpload(item, fromCamera: true);
                  },
                ),

                // Option 2: Gallery / Files
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library_rounded, color: colors.textPrimary, size: 20),
                  ),
                  title: Text(
                    'Upload from Device Gallery',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Pick existing clear document photo or scan',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _simulateUpload(item, fromCamera: false);
                  },
                ),

                // Option 3: Remove if already uploaded
                if (item.isUploaded) ...[
                  const SizedBox(height: 6),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    ),
                    title: const Text(
                      'Remove Uploaded File',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        item.isUploaded = false;
                        item.fileName = null;
                        item.fileSize = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulateUpload(_KycDocItem item, {required bool fromCamera}) {
    HapticFeedback.mediumImpact();
    setState(() {
      item.isUploaded = true;
      if (item.id == 'nid_front') {
        item.fileName = fromCamera ? 'nid_camera_front_scan.jpg' : 'nid_card_front.jpg';
        item.fileSize = '2.3 MB';
      } else if (item.id == 'nid_back') {
        item.fileName = fromCamera ? 'nid_camera_back_scan.jpg' : 'nid_card_back.jpg';
        item.fileSize = '1.9 MB';
      } else {
        item.fileName = 'live_selfie_verified.jpg';
        item.fileSize = '2.8 MB';
      }
      item.uploadTime = 'Just now';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${item.title} attached successfully.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    // Ensure all 3 documents are uploaded
    if (_uploadedCount < 3) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please upload NID Front, NID Back, and a Live Selfie to proceed.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    // Brief simulated network encryption & upload delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final colors = AppColorsResolved.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Animated Success Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4022C55E),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Dialog Header
                Text(
                  'Documents Submitted!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: colors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Exact prompt requirement subtitle
                Text(
                  'Documents submitted for review. It usually takes 24 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Reference verification badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tracking Reference',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const Text(
                        '#KYC-BD-892401',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Return to dashboard button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/provider-dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/provider-dashboard');
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Identity Verification',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          // Security Status Pill
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 13, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'SECURE KYC',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Main Scrollable Content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Step-by-Step Progress Tracker ────────────────────────
                  _buildStepTracker(colors, isDark),

                  const SizedBox(height: 20),

                  // Header Explainer Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Government ID Verification',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'To comply with Bangladesh local service regulations and build trust with customers, please verify your authentic identity.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Demo Autofill Helper Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _autofillAllDemoDocs,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 16),
                      label: const Text(
                        'Autofill Demo Documents',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Upload Cards (Dashed Borders) ────────────────────────
                  _buildUploadCard(
                    item: _documents[0],
                    colors: colors,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  _buildUploadCard(
                    item: _documents[1],
                    colors: colors,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  _buildUploadCard(
                    item: _documents[2],
                    colors: colors,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // ─── Verification Guidelines Card ─────────────────────────
                  _buildVerificationGuidelines(colors),

                  const SizedBox(height: 20),

                  // ─── Security Trust Badge ─────────────────────────────────
                  _buildSecurityTrustBadge(colors, isDark),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ─── Bottom Persistent Submit Container ──────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(
                  color: colors.border.withValues(alpha: 0.6),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Upload completion counter
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verification Progress',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                        Text(
                          '$_uploadedCount of 3 uploaded',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _uploadedCount == 3
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Large Submit Documents Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _uploadedCount == 3
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.85),
                        foregroundColor: Colors.white,
                        elevation: _uploadedCount == 3 ? 4 : 0,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Encrypting & Submitting...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Documents',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
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

  // ─── Sleek Step-by-Step Progress Tracker ─────────────────────────────────────

  Widget _buildStepTracker(AppColorsResolved colors, bool isDark) {
    final steps = [
      {'number': '1', 'title': 'ID Document'},
      {'number': '2', 'title': 'Selfie'},
      {'number': '3', 'title': 'Review'},
    ];

    final currentIndex = _currentStepIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentIndex || (index == 0 && _documents[0].isUploaded && _documents[1].isUploaded) || (index == 1 && _documents[2].isUploaded);
          final isCurrent = index == currentIndex;

          return Expanded(
            child: Row(
              children: [
                // Step Circle & Label
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.success
                              : isCurrent
                                  ? AppColors.primary
                                  : colors.surfaceVariant,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.success
                                : isCurrent
                                    ? AppColors.primary
                                    : colors.border,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (isCurrent)
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                steps[index]['number']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isCurrent
                                      ? Colors.white
                                      : colors.textSecondary,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[index]['title']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent || isCompleted
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCurrent || isCompleted
                              ? colors.textPrimary
                              : colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),

                // Connecting Line between steps
                if (index < steps.length - 1)
                  Container(
                    width: 24,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: isCompleted
                        ? AppColors.success
                        : colors.border,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Dashed-Border Upload Card ──────────────────────────────────────────────

  Widget _buildUploadCard({
    required _KycDocItem item,
    required AppColorsResolved colors,
    required bool isDark,
  }) {
    final isUploaded = item.isUploaded;

    return InkWell(
      onTap: () => _showUploadPicker(item),
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: isUploaded
            ? null
            : DashedRRectPainter(
                color: AppColors.primary.withValues(alpha: isDark ? 0.5 : 0.4),
                strokeWidth: 1.6,
                dashWidth: 6.0,
                dashSpace: 4.0,
                borderRadius: 16.0,
              ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUploaded
                ? (isDark ? const Color(0xFF14241B) : const Color(0xFFF0FDF4))
                : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isUploaded
                ? Border.all(
                    color: AppColors.success.withValues(alpha: 0.8),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isUploaded
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUploaded
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      isUploaded ? Icons.task_alt_rounded : item.icon,
                      color: isUploaded ? AppColors.success : AppColors.primary,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (isUploaded)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 13,
                                      color: AppColors.success,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'READY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Upload Action / Status Pill
              if (isUploaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.fileName} (${item.fileSize})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'Replace',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tap to upload or take photo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.tip,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  // ─── Verification Guidelines ────────────────────────────────────────────────

  Widget _buildVerificationGuidelines(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 17,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'Approval Checklist',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildChecklistBullet(
            'Ensure the NID number and date of birth are razor sharp and readable.',
            colors,
          ),
          const SizedBox(height: 4),
          _buildChecklistBullet(
            'Capture in well-lit environment without camera glare or flash reflection.',
            colors,
          ),
          const SizedBox(height: 4),
          _buildChecklistBullet(
            'Keep your face neutral with both ears and eyes visible for selfie matching.',
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistBullet(String text, AppColorsResolved colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle_outline, size: 13, color: AppColors.success),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Security Trust Badge ───────────────────────────────────────────────────

  Widget _buildSecurityTrustBadge(AppColorsResolved colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 15,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bank-Grade Confidentiality',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your data is 256-bit encrypted and securely stored for safety purposes only.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: colors.textSecondary,
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

/// Custom painter for dashed rounded rectangle border
class DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  const DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.borderRadius != borderRadius;
  }
}
