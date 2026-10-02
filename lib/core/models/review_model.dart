import 'package:flutter/foundation.dart';

/// Represents a customer review, rating, and tip for a completed service in Utsho.
@immutable
class ReviewModel {
  final String id;
  final String orderId;
  final String customerId;
  final String providerId;
  final int rating;
  final String? comment;
  final double tipAmount;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    this.comment,
    this.tipAmount = 0.0,
    required this.createdAt,
  });

  /// Creates a [ReviewModel] instance from a Supabase JSON map.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      providerId: json['provider_id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String?,
      tipAmount: (json['tip_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts this [ReviewModel] to a JSON map for Supabase storage.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'provider_id': providerId,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'tip_amount': tipAmount,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? providerId,
    int? rating,
    String? comment,
    double? tipAmount,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tipAmount: tipAmount ?? this.tipAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderId == other.orderId &&
          customerId == other.customerId &&
          providerId == other.providerId &&
          rating == other.rating &&
          tipAmount == other.tipAmount;

  @override
  int get hashCode =>
      id.hashCode ^
      orderId.hashCode ^
      customerId.hashCode ^
      providerId.hashCode ^
      rating.hashCode ^
      tipAmount.hashCode;
}
