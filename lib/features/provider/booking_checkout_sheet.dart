import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Payment method options supported in the checkout flow
enum PaymentMethod {
  bKash,
  nagad,
  cashOnDelivery,
}

/// A highly interactive, Pathao/Daraz style Booking and Checkout bottom sheet.
class BookingCheckoutSheet extends StatefulWidget {
  final String providerName;
  final String serviceName;
  final String rate;
  final Color avatarColor;
  final String? avatarUrl;
  final BuildContext? parentContext;

  const BookingCheckoutSheet({
    super.key,
    required this.providerName,
    required this.serviceName,
    required this.rate,
    required this.avatarColor,
    this.avatarUrl,
    this.parentContext,
  });

  /// Convenient static helper to show this sheet
  static Future<void> show({
    required BuildContext context,
    required String providerName,
    required String serviceName,
    required String rate,
    required Color avatarColor,
    String? avatarUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => BookingCheckoutSheet(
        providerName: providerName,
        serviceName: serviceName,
        rate: rate,
        avatarColor: avatarColor,
        avatarUrl: avatarUrl,
        parentContext: context,
      ),
    );
  }

  @override
  State<BookingCheckoutSheet> createState() => _BookingCheckoutSheetState();
}

class _BookingCheckoutSheetState extends State<BookingCheckoutSheet> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 1;
  PaymentMethod _selectedPayment = PaymentMethod.bKash;
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isPromoApplied = false;
  bool _isSubmitting = false;

  // Platform & Service charges calculation
  late int _serviceFee;
  static const int _platformFee = 35;
  static const int _promoDiscount = 50;

  final List<Map<String, String>> _dates = [
    {'label': 'Today', 'day': '01', 'weekday': 'Thu', 'month': 'Oct'},
    {'label': 'Tomorrow', 'day': '02', 'weekday': 'Fri', 'month': 'Oct'},
    {'label': 'Sat', 'day': '03', 'weekday': 'Sat', 'month': 'Oct'},
    {'label': 'Sun', 'day': '04', 'weekday': 'Sun', 'month': 'Oct'},
    {'label': 'Mon', 'day': '05', 'weekday': 'Mon', 'month': 'Oct'},
    {'label': 'Tue', 'day': '06', 'weekday': 'Tue', 'month': 'Oct'},
  ];

  final List<Map<String, dynamic>> _timeSlots = [
    {'time': '09:00 AM', 'period': 'Morning', 'icon': Icons.wb_sunny_outlined},
    {'time': '11:30 AM', 'period': 'Morning', 'icon': Icons.wb_sunny_outlined},
    {'time': '02:00 PM', 'period': 'Afternoon', 'icon': Icons.wb_sunny_rounded},
    {'time': '04:30 PM', 'period': 'Afternoon', 'icon': Icons.wb_twilight_rounded},
    {'time': '06:00 PM', 'period': 'Evening', 'icon': Icons.nightlight_round},
    {'time': '08:00 PM', 'period': 'Night', 'icon': Icons.nights_stay_rounded},
  ];

  @override
  void initState() {
    super.initState();
    // Parse numeric fee from rate string (e.g. '৳500/hr' -> 500)
    final numRegex = RegExp(r'\d+');
    final match = numRegex.firstMatch(widget.rate);
    _serviceFee = match != null ? int.tryParse(match.group(0)!) ?? 500 : 500;
  }

  @override
  void dispose() {
    _promoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _totalAmount {
    final subtotal = _serviceFee + _platformFee;
    return _isPromoApplied ? (subtotal - _promoDiscount) : subtotal;
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'PATHAO50' || code == 'DARAZ50' || code == 'SERVICE50' || code.isNotEmpty) {
      setState(() => _isPromoApplied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Promo applied! ৳50 discount added.'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onConfirmBooking() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final selectedDate = _dates[_selectedDateIndex];
    final selectedTime = _timeSlots[_selectedTimeIndex]['time'] as String;
    final paymentName = switch (_selectedPayment) {
      PaymentMethod.bKash => 'bKash',
      PaymentMethod.nagad => 'Nagad',
      PaymentMethod.cashOnDelivery => 'Cash on Delivery',
    };

    // Capture the active parent context before closing bottom sheet
    final targetContext = widget.parentContext ?? Navigator.of(context, rootNavigator: true).context;
    if (!targetContext.mounted) return;

    // Close bottom sheet
    Navigator.of(context).pop();

    // Show celebratory success dialog on the active parent context
    _showSuccessDialog(
      context: targetContext,
      providerName: widget.providerName,
      serviceName: widget.serviceName,
      dateStr: '${selectedDate['label']} (${selectedDate['day']} ${selectedDate['month']})',
      timeStr: selectedTime,
      paymentMethod: paymentName,
      totalAmount: _totalAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Drag Handle & Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.textHint.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Checkout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Pathao Express & Daraz Guaranteed',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, size: 18, color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ─── Scrollable Content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Provider & Location Snapshot Card
                  _buildProviderCard(colors),

                  const SizedBox(height: 20),

                  // 2. Select Date
                  _buildSectionTitle(
                    title: 'Select Date',
                    subtitle: 'Technician arrives on scheduled day',
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalDateList(colors),

                  const SizedBox(height: 22),

                  // 3. Select Time Slot
                  _buildSectionTitle(
                    title: 'Select Time Slot',
                    subtitle: 'Choose preferred arrival window',
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _buildTimeSlotGrid(colors),

                  const SizedBox(height: 24),

                  // 4. Payment Methods (bKash, Nagad, Cash on Delivery)
                  _buildSectionTitle(
                    title: 'Payment Method',
                    subtitle: 'Instant MFS or Pay after service',
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethods(colors),

                  const SizedBox(height: 24),

                  // 5. Promo Code Input (Pathao / Daraz voucher style)
                  _buildPromoCodeSection(colors),

                  const SizedBox(height: 24),

                  // 6. Order Summary & Cost Breakdown
                  _buildOrderSummary(colors),

                  const SizedBox(height: 20),

                  // 7. Safety & Trust assurance note
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: AppColors.success, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Daraz & Pathao 100% Service Protection Guarantee with 30-Day Free Rework.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ─── Sticky Bottom Action Bar ──────────────────────────────────────
          _buildStickyConfirmBar(colors, bottomPadding),
        ],
      ),
    );
  }

  // ─── Section 1: Provider Snapshot ──────────────────────────────────────────

  Widget _buildProviderCard(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.avatarColor.withValues(alpha: 0.15),
              border: Border.all(color: widget.avatarColor, width: 1.5),
            ),
            child: ClipOval(
              child: widget.avatarUrl != null
                  ? Image.network(
                      widget.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person_rounded,
                        color: widget.avatarColor,
                        size: 26,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: widget.avatarColor,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.providerName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF1D9BF0)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.serviceName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              widget.rate,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section 2: Date Selector ──────────────────────────────────────────────

  Widget _buildHorizontalDateList(AppColorsResolved colors) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isSelected = i == _selectedDateIndex;
          final d = _dates[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : colors.border,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    d['label']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white.withValues(alpha: 0.9) : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d['day']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : colors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d['month']!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white.withValues(alpha: 0.85) : colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Section 3: Time Slot Grid ─────────────────────────────────────────────

  Widget _buildTimeSlotGrid(AppColorsResolved colors) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_timeSlots.length, (i) {
        final isSelected = i == _selectedTimeIndex;
        final slot = _timeSlots[i];
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : colors.border,
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  slot['icon'] as IconData,
                  size: 15,
                  color: isSelected ? AppColors.primary : colors.textHint,
                ),
                const SizedBox(width: 6),
                Text(
                  slot['time'] as String,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Section 4: Payment Methods (bKash, Nagad, Cash) ───────────────────────

  Widget _buildPaymentMethods(AppColorsResolved colors) {
    return Column(
      children: [
        // 1. bKash (Pink)
        _PaymentOptionCard(
          title: 'bKash',
          subtitle: 'Instant Mobile Payment · Fast & Secured',
          brandColor: const Color(0xFFE2136E),
          badgeText: '৳10 Cashback',
          isSelected: _selectedPayment == PaymentMethod.bKash,
          iconWidget: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE2136E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'bK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          onTap: () => setState(() => _selectedPayment = PaymentMethod.bKash),
        ),

        const SizedBox(height: 10),

        // 2. Nagad (Orange)
        _PaymentOptionCard(
          title: 'Nagad',
          subtitle: 'Post Office Digital Banking · Zero Fee',
          brandColor: const Color(0xFFF7931E),
          badgeText: 'Instant',
          isSelected: _selectedPayment == PaymentMethod.nagad,
          iconWidget: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF7931E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
            ),
          ),
          onTap: () => setState(() => _selectedPayment = PaymentMethod.nagad),
        ),

        const SizedBox(height: 10),

        // 3. Cash on Delivery (Green)
        _PaymentOptionCard(
          title: 'Cash on Delivery',
          subtitle: 'Pay after service is completed to your satisfaction',
          brandColor: const Color(0xFF10B981),
          badgeText: 'Recommended',
          isSelected: _selectedPayment == PaymentMethod.cashOnDelivery,
          iconWidget: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.payments_rounded, color: Colors.white, size: 22),
            ),
          ),
          onTap: () => setState(() => _selectedPayment = PaymentMethod.cashOnDelivery),
        ),
      ],
    );
  }

  // ─── Section 5: Promo Code / Voucher ───────────────────────────────────────

  Widget _buildPromoCodeSection(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              const Icon(Icons.confirmation_num_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Apply Promo / Voucher',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
              const Spacer(),
              if (!_isPromoApplied)
                GestureDetector(
                  onTap: () {
                    _promoController.text = 'PATHAO50';
                    _applyPromo();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Use PATHAO50',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    enabled: !_isPromoApplied,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: _isPromoApplied ? 'PATHAO50 (Applied)' : 'Enter promo code',
                      hintStyle: TextStyle(fontSize: 12, color: colors.textHint),
                      filled: true,
                      fillColor: colors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: _isPromoApplied
                      ? () => setState(() {
                            _isPromoApplied = false;
                            _promoController.clear();
                          })
                      : _applyPromo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPromoApplied ? colors.textHint : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(
                    _isPromoApplied ? 'Remove' : 'Apply',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Section 6: Order Summary ──────────────────────────────────────────────

  Widget _buildOrderSummary(AppColorsResolved colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Guaranteed Rate',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Service Charge (${widget.serviceName.split('·').first.trim()})',
            value: '৳$_serviceFee',
            colors: colors,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Platform & Safety Protection Fee',
            value: '৳$_platformFee',
            colors: colors,
          ),
          if (_isPromoApplied) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Voucher Discount (PATHAO50)',
              value: '- ৳$_promoDiscount',
              colors: colors,
              isHighlight: true,
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payable',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'Inclusive of all local VAT & taxes',
                    style: TextStyle(fontSize: 11, color: colors.textHint),
                  ),
                ],
              ),
              Text(
                '৳$_totalAmount',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Sticky Confirm Button Bar ─────────────────────────────────────────────

  Widget _buildStickyConfirmBar(AppColorsResolved colors, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Payable',
                style: TextStyle(fontSize: 11.5, color: colors.textHint, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                '৳$_totalAmount',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: GestureDetector(
              onTap: _isSubmitting ? null : _onConfirmBooking,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confirm Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required AppColorsResolved colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ],
    );
  }

  // ─── Celebratory Success Dialog ────────────────────────────────────────────

  void _showSuccessDialog({
    required BuildContext context,
    required String providerName,
    required String serviceName,
    required String dateStr,
    required String timeStr,
    required String paymentMethod,
    required int totalAmount,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final dialogColors = AppColorsResolved.of(context);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: dialogColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated badge icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: AppColors.success, size: 44),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Booking Confirmed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: dialogColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your request has been accepted. $providerName will arrive at your specified time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: dialogColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),

                // Order summary container inside dialog
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: dialogColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: dialogColors.border),
                  ),
                  child: Column(
                    children: [
                      _DialogRow(label: 'Booking ID', value: '#SH-${DateTime.now().millisecondsSinceEpoch % 100000}', colors: dialogColors),
                      const SizedBox(height: 8),
                      _DialogRow(label: 'Professional', value: providerName, colors: dialogColors),
                      const SizedBox(height: 8),
                      _DialogRow(label: 'Service', value: serviceName.split('·').first.trim(), colors: dialogColors),
                      const SizedBox(height: 8),
                      _DialogRow(label: 'Schedule', value: '$dateStr, $timeStr', colors: dialogColors),
                      const SizedBox(height: 8),
                      _DialogRow(label: 'Payment', value: paymentMethod, colors: dialogColors),
                      const SizedBox(height: 8),
                      _DialogRow(label: 'Total Paid', value: '৳$totalAmount', isHighlight: true, colors: dialogColors),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    // Track Provider Button (Primary)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          context.push(
                            '/tracking',
                            extra: {
                              'providerName': providerName,
                              'profession': serviceName.split('·').first.trim(),
                              'avatarUrl': widget.avatarUrl ??
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
                              'rating': 4.9,
                              'etaMinutes': 12,
                              'distanceKm': 1.4,
                              'vehicleType': 'Yamaha FZ-S (White)',
                              'plateNumber': 'Dhaka Metro HA-44-1290',
                              'phone': '+880 1712-345678',
                            },
                          );
                        },
                        icon: const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Track Provider Live',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Done Button (Secondary)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                          // Show confirmation floating snackbar with Track action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.celebration_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Service booked with $providerName for $dateStr at $timeStr!'),
                                  ),
                                ],
                              ),
                              action: SnackBarAction(
                                label: 'Track',
                                textColor: Colors.white,
                                onPressed: () {
                                  context.push(
                                    '/tracking',
                                    extra: {
                                      'providerName': providerName,
                                      'profession': serviceName.split('·').first.trim(),
                                      'avatarUrl': widget.avatarUrl ??
                                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
                                      'rating': 4.9,
                                      'etaMinutes': 12,
                                      'distanceKm': 1.4,
                                    },
                                  );
                                },
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: dialogColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: dialogColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Payment Option Card Widget ──────────────────────────────────────────────

class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color brandColor;
  final String badgeText;
  final bool isSelected;
  final Widget iconWidget;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.brandColor,
    required this.badgeText,
    required this.isSelected,
    required this.iconWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsResolved.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? brandColor.withValues(alpha: 0.06) : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandColor : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: brandColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
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
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: brandColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Radio circle indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? brandColor : colors.textHint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: brandColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cost Breakdown Row Helper ───────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorsResolved colors;
  final bool isHighlight;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.colors,
    this.isHighlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? AppColors.success : colors.textSecondary,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Dialog Row Helper ───────────────────────────────────────────────────────

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorsResolved colors;
  final bool isHighlight;

  const _DialogRow({
    required this.label,
    required this.value,
    required this.colors,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: isHighlight ? AppColors.primary : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
