import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:service_hub/features/checkout/secure_checkout_screen.dart';

void main() {
  testWidgets(
      'SecureCheckoutScreen renders order summary, escrow badge, payment methods, and completes 2s payment flow',
      (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/checkout',
      routes: [
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const SecureCheckoutScreen(
            serviceName: 'Master AC Servicing',
            serviceFee: 500,
            platformFee: 20,
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: testRouter,
      ),
    );

    await tester.pump();

    // 1. Verify AppBar title
    expect(find.text('Secure Checkout'), findsOneWidget);

    // 2. Verify Escrow Trust Badge text (exact wording from user request)
    expect(
      find.text(
        'Secure Escrow Payment. Your money is held safely and only released to the provider after the job is 100% completed.',
      ),
      findsOneWidget,
    );

    // 3. Verify Order Summary Card items
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('Master AC Servicing'), findsOneWidget);
    expect(find.text('৳500'), findsOneWidget);
    expect(find.text('৳20'), findsOneWidget);
    expect(find.text('৳520'), findsOneWidget);

    // 4. Verify Payment Methods
    expect(find.text('bKash'), findsOneWidget);
    expect(find.text('Nagad'), findsOneWidget);
    expect(find.text('Credit/Debit Card'), findsOneWidget);

    // Test selecting Nagad payment method
    await tester.scrollUntilVisible(find.text('Nagad'), 100);
    await tester.tap(find.text('Nagad'));
    await tester.pump();

    // 5. Verify Action Button has exact text 'Pay ৳520 Securely'
    final payButton = find.text('Pay ৳520 Securely');
    expect(payButton, findsOneWidget);

    // 6. Tap action button
    await tester.tap(payButton);
    await tester.pump();

    // Verify 2-second loading state is active
    expect(find.text('Securing funds in escrow...'), findsOneWidget);

    // Wait for the simulated 2-second payment delay
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // 7. Verify Success Dialog appears with exact prompt requirement
    expect(find.text('Payment Secured & Booking Confirmed!'), findsOneWidget);

    // 8. Tap Back to Home button and verify navigation to /home
    final homeBtn = find.text('Back to Home');
    expect(homeBtn, findsOneWidget);
    await tester.tap(homeBtn);
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });
}
