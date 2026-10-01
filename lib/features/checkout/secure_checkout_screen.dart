import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Supported digital payment methods for the checkout
enum CheckoutPaymentMethod {
  bkash,
  nagad,
  card,
}

/// A world-class, premium Fintech/Marketplace Secure Checkout & Escrow Payment Screen.
/// Designed for high financial trust with an Escrow Guarantee Banner,
/// itemized Order Summary, selectable localized payment options (bKash, Nagad, Card),
/// 2-second cryptographically simulated payment loading, and an escrow confirmation dialog.
class SecureCheckoutScreen extends StatefulWidget {
  final String serviceName;
  final String providerName;
  final double providerRating;
  final int serviceFee;
  final int platformFee;
  final String dateTime;
  final String address;

  const SecureCheckoutScreen({
    super.key,
    this.serviceName = 'Master AC Servicing',
    this.providerName = 'Rahim Uddin',
    this.providerRating = 4.9,
    this.serviceFee = 500,
    this.platformFee = 20,
    this.dateTime = 'Tomorrow, 10:00 AM - 11:30 AM',
    this.address = 'House 14, Road 71, Gulshan 2, Dhaka',
  });

  @override
  State<SecureCheckoutScreen> createState() => _SecureCheckoutScreenState();
}

class _SecureCheckoutScreenState extends State<SecureCheckoutScreen> {
  CheckoutPaymentMethod _selectedMethod = CheckoutPaymentMethod.bkash;
  bool _isProcessing = false;
  bool _isCouponApplied = false;

  int get _discountAmount => _isCouponApplied ? 50 : 0;
  int get _totalAmount => (widget.serviceFee + widget.platformFee) - _discountAmount;

  void _toggleCoupon() {
    HapticFeedback.lightImpact();
    setState(() => _isCouponApplied = !_isCouponApplied);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCouponApplied
              ? 'Coupon COOL20 applied! ৳50 discount deducted.'
              : 'Coupon removed.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    // Simulate 2-second bank / escrow authorization delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isProcessing = false);

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
                // Glowing Animated Shield & Checkmark Badge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Dialog Header - Exact prompt wording
                Text(
                  'Payment Secured & Booking Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: colors.textPrimary,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),

                // Escrow explanation
                Text(
                  '৳$_totalAmount has been transferred to the ServiceHub Escrow Vault. Funds will only be released to ${widget.providerName} after you verify the job is 100% completed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 18),

                // Transaction info card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Transaction Ref', '#TXN-SH-9402198', colors),
                      const SizedBox(height: 6),
                      _buildReceiptRow('Escrow Status', 'Protected in Vault', colors, isGreen: true),
                      const SizedBox(height: 6),
                      _buildReceiptRow('Payment Method', _getMethodLabel(_selectedMethod), colors),
                      const SizedBox(height: 6),
                      _buildReceiptRow('Amount Paid', '৳$_totalAmount', colors, isBold: true),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Primary Button: Go to Home
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/home');
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
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Secondary Button: Track Provider Live
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.push('/tracking', extra: {
                        'providerName': widget.providerName,
                        'serviceName': widget.serviceName,
                        'eta': '12 mins',
                        'distance': '1.8 km',
                      });
                    },
                    icon: const Icon(Icons.navigation_rounded, size: 16),
                    label: const Text(
                      'Track Provider Live',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
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

  Widget _buildReceiptRow(String label, String value, AppColorsResolved colors,
      {bool isGreen = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isGreen
                ? AppColors.success
                : (isBold ? colors.textPrimary : colors.textPrimary),
          ),
        ),
      ],
    );
  }

  String _getMethodLabel(CheckoutPaymentMethod method) {
    switch (method) {
      case CheckoutPaymentMethod.bkash:
        return 'bKash Wallet';
      case CheckoutPaymentMethod.nagad:
        return 'Nagad Wallet';
      case CheckoutPaymentMethod.card:
        return 'Credit/Debit Card';
    }
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
              context.go('/home');
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Secure Checkout',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          // Escrow protection pill
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: isDark ? 0.16 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'ESCROW VAULT',
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
          // ─── Scrollable Checkout Form ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 1. Escrow Trust Hero Banner ──────────────────────────
                  _buildEscrowTrustBadge(colors, isDark),

                  const SizedBox(height: 20),

                  // ─── 2. Order Summary Card ────────────────────────────────
                  _buildOrderSummaryCard(colors, isDark),

                  const SizedBox(height: 24),

                  // ─── 3. Payment Methods Section ───────────────────────────
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All transactions are 256-bit encrypted and tokenized for security.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Option 1: bKash
                  _buildPaymentMethodTile(
                    method: CheckoutPaymentMethod.bkash,
                    title: 'bKash',
                    subtitle: 'Instant 1-tap checkout with bKash wallet',
                    badgeText: 'Most Popular',
                    brandColor: const Color(0xFFE2136E),
                    icon: Icons.account_balance_wallet_rounded,
                    colors: colors,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 12),

                  // Option 2: Nagad
                  _buildPaymentMethodTile(
                    method: CheckoutPaymentMethod.nagad,
                    title: 'Nagad',
                    subtitle: 'Instant payment via Nagad Postal Gateway',
                    badgeText: '0% Surcharge',
                    brandColor: const Color(0xFFF7941D),
                    icon: Icons.payments_rounded,
                    colors: colors,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 12),

                  // Option 3: Credit/Debit Card
                  _buildPaymentMethodTile(
                    method: CheckoutPaymentMethod.card,
                    title: 'Credit/Debit Card',
                    subtitle: 'Visa, Mastercard, AMEX & UnionPay',
                    badgeText: '3D Secure',
                    brandColor: const Color(0xFF1E40AF),
                    icon: Icons.credit_card_rounded,
                    colors: colors,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 20),

                  // ─── Security Microcopy Banner ────────────────────────────
                  _buildSecurityFooterNotice(colors, isDark),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ─── Bottom Persistent Action Container ──────────────────────────
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
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Guarantee Subtext
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 15,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Zero risk · 100% money released after completion only',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Large Action Button: 'Pay ৳520 Securely'
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isProcessing
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
                                  'Securing funds in escrow...',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_rounded, size: 19),
                                const SizedBox(width: 8),
                                Text(
                                  'Pay ৳$_totalAmount Securely',
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
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

  // ─── 1. Escrow Trust Badge Component ────────────────────────────────────────

  Widget _buildEscrowTrustBadge(AppColorsResolved colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF042B21),
                  const Color(0xFF071F18),
                ]
              : [
                  const Color(0xFFE8FAF3),
                  const Color(0xFFD6F5E8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glowing Shield Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: isDark ? 0.25 : 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Escrow Trust Banner Text - Exact requirement
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ServiceHub Escrow Vault',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: isDark ? Colors.teal.shade200 : const Color(0xFF065F46),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '100% PROTECTED',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Secure Escrow Payment. Your money is held safely and only released to the provider after the job is 100% completed.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFC7EBD9) : const Color(0xFF064E3B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.3),
              ),
              const SizedBox(height: 10),

              // Trust points checklist
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTrustPoint('7-Day Warranty', isDark),
                  _buildTrustPoint('Full Refundable', isDark),
                  _buildTrustPoint('Zero Risk', isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustPoint(String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 14,
          color: AppColors.accent,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFC7EBD9) : const Color(0xFF047857),
          ),
        ),
      ],
    );
  }

  // ─── 2. Order Summary Card Component ────────────────────────────────────────

  Widget _buildOrderSummaryCard(AppColorsResolved colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: colors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Standard Booking',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Service details container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.hvac_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              widget.providerName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            Text(
                              '${widget.providerRating}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Schedule & Location notes
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: colors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.dateTime,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.place_outlined, size: 14, color: colors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.address,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 14),

            // Price Item 1: Service Fee (৳500)
            _buildPriceRow(
              label: 'Service Fee',
              amount: '৳${widget.serviceFee}',
              colors: colors,
            ),

            const SizedBox(height: 8),

            // Price Item 2: Platform Fee (৳20)
            _buildPriceRow(
              label: 'Platform Fee (Escrow & Insurance)',
              amount: '৳${widget.platformFee}',
              colors: colors,
            ),

            if (_isCouponApplied) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                label: 'Promo Discount (COOL20)',
                amount: '-৳$_discountAmount',
                colors: colors,
                isDiscount: true,
              ),
            ],

            const SizedBox(height: 10),

            // Coupon Code Toggle Chip
            GestureDetector(
              onTap: _toggleCoupon,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isCouponApplied
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isCouponApplied
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCouponApplied ? Icons.check_circle_rounded : Icons.local_offer_outlined,
                      size: 14,
                      color: _isCouponApplied ? AppColors.success : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isCouponApplied ? 'Coupon COOL20 Applied (-৳50)' : 'Apply Promo COOL20',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _isCouponApplied ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 14),

            // Price Item 3: Total Amount (৳520)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Includes all local VAT & taxes',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
                Text(
                  '৳$_totalAmount',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String amount,
    required AppColorsResolved colors,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDiscount ? AppColors.success : colors.textSecondary,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDiscount ? AppColors.success : colors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── 3. Payment Methods Component ───────────────────────────────────────────

  Widget _buildPaymentMethodTile({
    required CheckoutPaymentMethod method,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color brandColor,
    required IconData icon,
    required AppColorsResolved colors,
    required bool isDark,
  }) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedMethod = method);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? brandColor.withValues(alpha: isDark ? 0.12 : 0.05)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? brandColor
                : colors.border,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: brandColor.withValues(alpha: isDark ? 0.25 : 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            // Branded Icon Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: brandColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                icon,
                color: brandColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Method Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: brandColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? brandColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? brandColor : colors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Security Footer Notice ─────────────────────────────────────────────────

  Widget _buildSecurityFooterNotice(AppColorsResolved colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_person_outlined,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your financial credentials are never saved on our servers. bKash, Nagad, and PCI-DSS compliant gateways process payments with end-to-end tokenization.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
