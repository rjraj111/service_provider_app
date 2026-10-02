import 'package:flutter/foundation.dart';

/// Represents a marketplace service item / offering provided on Utsho.
@immutable
class ItemModel {
  final String id;
  final String categoryId;
  final String providerId;
  final String title;
  final String description;
  final double price;
  final double? discountPrice;
  final int durationMinutes;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ItemModel({
    required this.id,
    required this.categoryId,
    required this.providerId,
    required this.title,
    required this.description,
    required this.price,
    this.discountPrice,
    this.durationMinutes = 60,
    this.imageUrl,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// The effective price after checking if a discount is active.
  double get effectivePrice => discountPrice ?? price;

  /// Returns true if there is a valid discount on this item.
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Creates an [ItemModel] instance from a Supabase JSON map.
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      providerId: json['provider_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [ItemModel] to a JSON map for Supabase storage.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'category_id': categoryId,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'price': price,
      if (discountPrice != null) 'discount_price': discountPrice,
      'duration_minutes': durationMinutes,
      if (imageUrl != null) 'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'is_available': isAvailable,
      'is_deleted': isDeleted,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  ItemModel copyWith({
    String? id,
    String? categoryId,
    String? providerId,
    String? title,
    String? description,
    double? price,
    double? discountPrice,
    int? durationMinutes,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoryId == other.categoryId &&
          providerId == other.providerId &&
          title == other.title &&
          price == other.price &&
          discountPrice == other.discountPrice &&
          isAvailable == other.isAvailable &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      categoryId.hashCode ^
      providerId.hashCode ^
      title.hashCode ^
      price.hashCode ^
      discountPrice.hashCode ^
      isAvailable.hashCode ^
      isDeleted.hashCode;
}
