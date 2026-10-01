import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:utsho/features/auth/otp_verification_screen.dart';

void main() {
  testWidgets(
      'OtpVerificationScreen renders header, subtitle, 6 boxes, resend text, and verify button',
      (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/otp',
      routes: [
        GoRoute(
          path: '/otp',
          builder: (context, state) => const OtpVerificationScreen(
            phoneNumber: '+880 1712 345 678',
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

    // Pump frames to complete entry animation
    await tester.pump(const Duration(milliseconds: 600));

    // Verify header text
    expect(find.text('Verify your phone number'), findsOneWidget);

    // Verify subtitle text with phone number
    expect(find.textContaining('+880 1712 345 678'), findsOneWidget);

    // Verify 6 input boxes via TextField
    expect(find.byType(TextField), findsOneWidget);

    // Verify resend code timer text
    expect(find.textContaining('Resend code in'), findsOneWidget);

    // Verify button
    expect(find.text('Verify & Secure Login'), findsOneWidget);

    // Test entering demo OTP
    final demoChip = find.textContaining('Autofill Demo Code: 749205');
    expect(demoChip, findsOneWidget);
    await tester.tap(demoChip);
    await tester.pump();

    // Verify button is tapped
    final verifyButton = find.text('Verify & Secure Login');
    await tester.tap(verifyButton);
    await tester.pump();

    // Verifying state shows progress
    expect(find.text('Authenticating...'), findsOneWidget);

    // Wait for the 1-second delay and navigation
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();

    // Verify navigated to home
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
