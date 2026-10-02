import 'package:flutter/foundation.dart';

/// Lifecycle status of an Order / Service Booking.
enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled;

  static OrderStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'inprogress':
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  String toDbString() {
    if (this == OrderStatus.inProgress) return 'in_progress';
    return name;
  }
}

/// Escrow payment status for an Order in Utsho.
enum PaymentStatus {
  pending,
  heldInEscrow,
  released,
  refunded;

  static PaymentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'held_in_escrow':
      case 'heldinescrow':
        return PaymentStatus.heldInEscrow;
      case 'released':
        return PaymentStatus.released;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  String toDbString() {
    if (this == PaymentStatus.heldInEscrow) return 'held_in_escrow';
    return name;
  }
}

/// Represents a customer booking or service order in Utsho.
@immutable
class OrderModel {
  final String id;
  final String customerId;
  final String providerId;
  final String itemId;
  final String itemTitle;
  final double itemPrice;
  final DateTime bookingDate;
  final String timeSlot;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double serviceFee;
  final double platformFee;
  final double discountAmount;
  final double totalAmount;
  final String address;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.itemId,
    this.itemTitle = '',
    this.itemPrice = 0.0,
    required this.bookingDate,
    required this.timeSlot,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    required this.serviceFee,
    this.platformFee = 20.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    required this.address,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates an [OrderModel] instance from a Supabase JSON map.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      providerId: json['provider_id'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
      itemTitle: json['item_title'] as String? ?? '',
      itemPrice: (json['item_price'] as num?)?.toDouble() ?? 0.0,
      bookingDate: json['booking_date'] != null
          ? DateTime.tryParse(json['booking_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      timeSlot: json['time_slot'] as String? ?? '',
      status: OrderStatus.fromString(json['status'] as String?),
      paymentStatus: PaymentStatus.fromString(json['payment_status'] as String?),
      serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 20.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [OrderModel] to a JSON map for Supabase storage.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'customer_id': customerId,
      'provider_id': providerId,
      if (itemId.isNotEmpty) 'item_id': itemId,
      if (itemTitle.isNotEmpty) 'item_title': itemTitle,
      if (itemPrice > 0) 'item_price': itemPrice,
      'booking_date': bookingDate.toUtc().toIso8601String(),
      'time_slot': timeSlot,
      'status': status.toDbString(),
      'payment_status': paymentStatus.toDbString(),
      'service_fee': serviceFee,
      'platform_fee': platformFee,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'address': address,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? providerId,
    String? itemId,
    String? itemTitle,
    double? itemPrice,
    DateTime? bookingDate,
    String? timeSlot,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    double? serviceFee,
    double? platformFee,
    double? discountAmount,
    double? totalAmount,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemPrice: itemPrice ?? this.itemPrice,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      serviceFee: serviceFee ?? this.serviceFee,
      platformFee: platformFee ?? this.platformFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          providerId == other.providerId &&
          itemId == other.itemId &&
          status == other.status &&
          paymentStatus == other.paymentStatus &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      id.hashCode ^
      customerId.hashCode ^
      providerId.hashCode ^
      itemId.hashCode ^
      status.hashCode ^
      paymentStatus.hashCode ^
      totalAmount.hashCode;
}
