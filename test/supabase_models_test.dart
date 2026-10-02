import 'package:flutter_test/flutter_test.dart';
import 'package:utsho/core/config/supabase_config.dart';
import 'package:utsho/core/models/models.dart';

void main() {
  group('SupabaseConfig Tests', () {
    test('SupabaseConfig holds valid configured credentials', () {
      expect(SupabaseConfig.supabaseUrl, isNotEmpty);
      expect(SupabaseConfig.supabaseAnonKey, isNotEmpty);
      expect(SupabaseConfig.isConfigured, isTrue);
    });
  });

  group('UserModel Serialization', () {
    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'usr-123',
        email: 'jahedul.islam@utsho.com',
        fullName: 'Jahedul Islam',
        phone: '+8801812345678',
        avatarUrl: 'https://example.com/avatar.jpg',
        role: UserRole.provider,
        isKycVerified: true,
        rating: 4.95,
        totalJobs: 42,
        createdAt: now,
      );

      final json = user.toJson();
      expect(json['id'], 'usr-123');
      expect(json['role'], 'provider');
      expect(json['is_kyc_verified'], true);
      expect(json['rating'], 4.95);

      final restored = UserModel.fromJson(json);
      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.role, UserRole.provider);
      expect(restored.isKycVerified, true);
      expect(restored.totalJobs, 42);
    });
  });

  group('CategoryModel Serialization', () {
    test('toJson and fromJson support bilingual names', () {
      final now = DateTime.now();
      final category = CategoryModel(
        id: 'cat-1',
        name: 'AC Servicing',
        nameBn: 'এসি সার্ভিসিং',
        icon: 'ac_unit_rounded',
        imageUrl: 'https://example.com/ac.png',
        sortOrder: 1,
        isActive: true,
        createdAt: now,
      );

      final json = category.toJson();
      expect(json['name_bn'], 'এসি সার্ভিসিং');
      expect(json['sort_order'], 1);

      final restored = CategoryModel.fromJson(json);
      expect(restored.name, 'AC Servicing');
      expect(restored.localizedName('bn'), 'এসি সার্ভিসিং');
      expect(restored.localizedName('en'), 'AC Servicing');
    });
  });

  group('ItemModel Serialization', () {
    test('toJson and fromJson preserve price and discount calculations', () {
      final now = DateTime.now();
      final item = ItemModel(
        id: 'item-101',
        categoryId: 'cat-1',
        providerId: 'usr-123',
        title: 'Master AC Servicing',
        description: 'Complete jet pump servicing and gas check',
        price: 800.0,
        discountPrice: 650.0,
        durationMinutes: 90,
        rating: 4.9,
        reviewCount: 38,
        createdAt: now,
      );

      expect(item.hasDiscount, isTrue);
      expect(item.effectivePrice, 650.0);

      final json = item.toJson();
      expect(json['price'], 800.0);
      expect(json['discount_price'], 650.0);

      final restored = ItemModel.fromJson(json);
      expect(restored.id, 'item-101');
      expect(restored.effectivePrice, 650.0);
    });
  });

  group('OrderModel Serialization', () {
    test('toJson and fromJson preserve enums and escrow statuses', () {
      final now = DateTime.now();
      final order = OrderModel(
        id: 'ord-555',
        customerId: 'cust-1',
        providerId: 'prov-2',
        itemId: 'item-101',
        bookingDate: now,
        timeSlot: '10:00 AM - 12:00 PM',
        status: OrderStatus.inProgress,
        paymentStatus: PaymentStatus.heldInEscrow,
        serviceFee: 500.0,
        platformFee: 20.0,
        discountAmount: 50.0,
        totalAmount: 470.0,
        address: 'Gulshan 2, Dhaka',
        notes: 'Please bring ladder',
        createdAt: now,
      );

      final json = order.toJson();
      expect(json['status'], 'in_progress');
      expect(json['payment_status'], 'held_in_escrow');
      expect(json['total_amount'], 470.0);

      final restored = OrderModel.fromJson(json);
      expect(restored.status, OrderStatus.inProgress);
      expect(restored.paymentStatus, PaymentStatus.heldInEscrow);
      expect(restored.notes, 'Please bring ladder');
    });
  });

  group('ReviewModel Serialization', () {
    test('toJson and fromJson preserve rating and tip', () {
      final now = DateTime.now();
      final review = ReviewModel(
        id: 'rev-999',
        orderId: 'ord-555',
        customerId: 'cust-1',
        providerId: 'prov-2',
        rating: 5,
        comment: 'Excellent service and on-time arrival!',
        tipAmount: 50.0,
        createdAt: now,
      );

      final json = review.toJson();
      expect(json['rating'], 5);
      expect(json['tip_amount'], 50.0);

      final restored = ReviewModel.fromJson(json);
      expect(restored.rating, 5);
      expect(restored.tipAmount, 50.0);
      expect(restored.comment, 'Excellent service and on-time arrival!');
    });
  });
}
