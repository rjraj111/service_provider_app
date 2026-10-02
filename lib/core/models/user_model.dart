import 'package:flutter/foundation.dart';

/// User roles in the Utsho marketplace ecosystem.
enum UserRole {
  customer,
  provider,
  admin;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'provider':
        return UserRole.provider;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String toDbString() => name;
}

/// Represents a registered user (Customer, Service Provider, or Admin) in Utsho.
@immutable
class UserModel {
  final String id;
  final String? email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final bool isKycVerified;
  final double rating;
  final int totalJobs;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.isKycVerified = false,
    this.rating = 5.0,
    this.totalJobs = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [UserModel] instance from a Supabase/PostgreSQL JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String?,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      isKycVerified: json['is_kyc_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalJobs: (json['total_jobs'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [UserModel] instance into a JSON map for Supabase storage.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (email != null && email!.isNotEmpty) 'email': email,
      'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role.toDbString(),
      'is_kyc_verified': isKycVerified,
      'rating': rating,
      'total_jobs': totalJobs,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  /// Creates a copy of this [UserModel] with optionally updated properties.
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? isKycVerified,
    double? rating,
    int? totalJobs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          phone == other.phone &&
          avatarUrl == other.avatarUrl &&
          role == other.role &&
          isKycVerified == other.isKycVerified &&
          rating == other.rating &&
          totalJobs == other.totalJobs;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      phone.hashCode ^
      avatarUrl.hashCode ^
      role.hashCode ^
      isKycVerified.hashCode ^
      rating.hashCode ^
      totalJobs.hashCode;
}
