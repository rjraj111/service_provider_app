import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

/// Riverpod provider delivering the singleton instance of [SupabaseService].
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Riverpod provider for the currently logged in user's profile.
final currentUserProfileProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  final userId = service.currentUserId;
  if (userId == null) return null;
  return await service.getUserProfile(userId);
});

/// Riverpod provider for active marketplace categories fetched from Supabase.
final categoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getCategories(activeOnly: true);
});

/// Comprehensive data access and CRUD service for the Utsho marketplace.
class SupabaseService {
  SupabaseService();

  // ── Database Table Names ────────────────────────────────────────────────────
  static const String tableUsers = 'users';
  static const String tableCategories = 'categories';
  static const String tableItems = 'items';
  static const String tableOrders = 'orders';
  static const String tableReviews = 'reviews';

  /// Provides direct access to the underlying [SupabaseClient].
  SupabaseClient get client => Supabase.instance.client;

  // ── Auth Operations ─────────────────────────────────────────────────────────

  /// Current authenticated Supabase user or null if unauthenticated.
  User? get currentAuthUser => client.auth.currentUser;

  /// Current user ID string or null.
  String? get currentUserId => client.auth.currentUser?.id;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Registers a new user with email and password and creates their profile.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.customer,
    String? phone,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.toDbString(),
        if (phone != null) 'phone': phone,
      },
    );

    if (response.user != null) {
      final userModel = UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );
      await client.from(tableUsers).upsert(userModel.toJson());
    }

    return response;
  }

  /// Signs in an existing user with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sends an OTP to the user's phone for passwordless verification.
  Future<void> signInWithOtp({required String phone}) async {
    await client.auth.signInWithOtp(phone: phone);
  }

  /// Verifies a 6-digit phone OTP code.
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Signs out the current user session.
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ── User / Profile Operations ───────────────────────────────────────────────

  /// Fetches the profile of a user by their UUID.
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from(tableUsers)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Updates or inserts a user's profile record.
  Future<UserModel> updateUserProfile(UserModel user) async {
    final data = user.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await client
        .from(tableUsers)
        .upsert(data)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  /// Updates provider KYC identity verification status.
  Future<void> updateKycStatus({
    required String userId,
    required bool isVerified,
  }) async {
    await client.from(tableUsers).update({
      'is_kyc_verified': isVerified,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // ── Category Operations ─────────────────────────────────────────────────────

  /// Retrieves list of service categories, optionally filtering for active only.
  Future<List<CategoryModel>> getCategories({bool activeOnly = true}) async {
    try {
      var query = client.from(tableCategories).select();

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('sort_order', ascending: true);
      return (response as List<dynamic>)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Retrieves a single category by its ID.
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final response = await client
          .from(tableCategories)
          .select()
          .eq('id', categoryId)
          .maybeSingle();

      if (response == null) return null;
      return CategoryModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching category by ID: $e');
      return null;
    }
  }

  // ── Item / Service Operations ───────────────────────────────────────────────

  /// Fetches service items with optional category, provider, or search query filters.
  Future<List<ItemModel>> getItems({
    String? categoryId,
    String? providerId,
    String? searchQuery,
    int limit = 50,
  }) async {
    try {
      var query = client.from(tableItems).select().eq('is_available', true).eq('is_deleted', false);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      if (providerId != null && providerId.isNotEmpty) {
        query = query.eq('provider_id', providerId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      final response = await query.order('rating', ascending: false).limit(limit);
      return (response as List<dynamic>)
          .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching items: $e');
      return [];
    }
  }

  /// Retrieves a specific service item by ID.
  Future<ItemModel?> getItemById(String itemId) async {
    try {
      final response = await client
          .from(tableItems)
          .select()
          .eq('id', itemId)
          .maybeSingle();

      if (response == null) return null;
      return ItemModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching item by ID: $e');
      return null;
    }
  }

  /// Creates a new service offering item.
  Future<ItemModel> createItem(ItemModel item) async {
    final response = await client
        .from(tableItems)
        .insert(item.toJson())
        .select()
        .single();
    return ItemModel.fromJson(response);
  }

  /// Updates an existing service offering item.
  Future<ItemModel> updateItem(ItemModel item) async {
    final data = item.toJson();
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();

    final response = await client
        .from(tableItems)
        .update(data)
        .eq('id', item.id)
        .select()
        .single();
    return ItemModel.fromJson(response);
  }

  /// Deletes or deactivates a service item with soft deletion to avoid orphaned order FK errors.
  Future<void> deleteItem(String itemId, {bool softDelete = true}) async {
    if (softDelete) {
      await client.from(tableItems).update({
        'is_deleted': true,
        'is_available': false,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', itemId);
    } else {
      await client.from(tableItems).delete().eq('id', itemId);
    }
  }

  // ── Order / Booking Operations ──────────────────────────────────────────────

  /// Creates a new order/booking in the Utsho database.
  Future<OrderModel> createOrder(OrderModel order) async {
    final response = await client
        .from(tableOrders)
        .insert(order.toJson())
        .select()
        .single();
    return OrderModel.fromJson(response);
  }

  /// Retrieves all orders made by a customer.
  Future<List<OrderModel>> getOrdersForCustomer(String customerId) async {
    try {
      final response = await client
          .from(tableOrders)
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching customer orders: $e');
      return [];
    }
  }

  /// Retrieves all service orders assigned to a provider.
  Future<List<OrderModel>> getOrdersForProvider(String providerId) async {
    try {
      final response = await client
          .from(tableOrders)
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching provider orders: $e');
      return [];
    }
  }

  /// Retrieves order details by order ID.
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await client
          .from(tableOrders)
          .select()
          .eq('id', orderId)
          .maybeSingle();

      if (response == null) return null;
      return OrderModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching order by ID: $e');
      return null;
    }
  }

  /// Updates the order fulfillment status (e.g. in_progress, completed).
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    await client.from(tableOrders).update({
      'status': status.toDbString(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  /// Updates the escrow payment status (e.g. held_in_escrow, released, refunded).
  Future<void> updateEscrowPaymentStatus({
    required String orderId,
    required PaymentStatus status,
  }) async {
    await client.from(tableOrders).update({
      'payment_status': status.toDbString(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  // ── Review Operations ───────────────────────────────────────────────────────

  /// Submits a new customer review, rating, and tip.
  Future<ReviewModel> createReview(ReviewModel review) async {
    final response = await client
        .from(tableReviews)
        .insert(review.toJson())
        .select()
        .single();
    return ReviewModel.fromJson(response);
  }

  /// Retrieves all customer reviews received by a service provider.
  Future<List<ReviewModel>> getReviewsForProvider(String providerId) async {
    try {
      final response = await client
          .from(tableReviews)
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching provider reviews: $e');
      return [];
    }
  }

  // ── Realtime Subscriptions ──────────────────────────────────────────────────

  /// Streams real-time order updates for a given user (as customer or provider).
  Stream<List<Map<String, dynamic>>> streamOrdersForUser(
    String userId, {
    bool isProvider = false,
  }) {
    final filterColumn = isProvider ? 'provider_id' : 'customer_id';
    return client
        .from(tableOrders)
        .stream(primaryKey: ['id'])
        .eq(filterColumn, userId)
        .order('created_at', ascending: false);
  }
}
