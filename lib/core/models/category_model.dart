import 'package:flutter/foundation.dart';

/// Represents a service category in the Utsho marketplace.
@immutable
class CategoryModel {
  final String id;
  final String name;
  final String? nameBn;
  final String icon;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameBn,
    required this.icon,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  /// Creates a [CategoryModel] instance from a Supabase JSON map.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameBn: json['name_bn'] as String?,
      icon: json['icon'] as String? ?? 'build_rounded',
      imageUrl: json['image_url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts this [CategoryModel] to a JSON map for Supabase storage.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      if (nameBn != null) 'name_bn': nameBn,
      'icon': icon,
      if (imageUrl != null) 'image_url': imageUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Returns localized category name based on language code ('bn' or 'en').
  String localizedName(String languageCode) {
    if (languageCode == 'bn' && nameBn != null && nameBn!.isNotEmpty) {
      return nameBn!;
    }
    return name;
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? nameBn,
    String? icon,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          nameBn == other.nameBn &&
          icon == other.icon &&
          imageUrl == other.imageUrl &&
          sortOrder == other.sortOrder &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      nameBn.hashCode ^
      icon.hashCode ^
      imageUrl.hashCode ^
      sortOrder.hashCode ^
      isActive.hashCode;
}
