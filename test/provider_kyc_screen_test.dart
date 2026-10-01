import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:utsho/features/provider_dashboard/provider_dashboard_screen.dart';
import 'package:utsho/features/provider_dashboard/provider_kyc_screen.dart';

void main() {
  testWidgets('ProviderKycScreen renders all key elements and submits successfully',
      (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/provider-kyc',
      routes: [
        GoRoute(
          path: '/provider-kyc',
          builder: (context, state) => const ProviderKycScreen(),
        ),
        GoRoute(
          path: '/provider-dashboard',
          builder: (context, state) => const Scaffold(body: Text('Dashboard Screen')),
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
    expect(find.text('Identity Verification'), findsOneWidget);

    // 2. Verify Step Progress Tracker
    expect(find.text('ID Document'), findsOneWidget);
    expect(find.text('Selfie'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);

    // 3. Verify Dashed Upload Cards
    expect(find.text('Upload NID Front'), findsOneWidget);
    expect(find.text('Upload NID Back'), findsOneWidget);
    expect(find.text('Take a Live Selfie'), findsOneWidget);

    // 4. Verify Security Trust Badge text
    expect(
      find.textContaining('Your data is 256-bit encrypted and securely stored for safety purposes only.'),
      findsOneWidget,
    );

    // 5. Verify Submit button
    expect(find.text('Submit Documents'), findsOneWidget);

    // 6. Autofill Demo Documents
    final autofillButton = find.text('Autofill Demo Documents');
    expect(autofillButton, findsOneWidget);
    await tester.tap(autofillButton);
    await tester.pump();

    // Progress counter should update to 3 of 3
    expect(find.text('3 of 3 uploaded'), findsOneWidget);

    // 7. Tap Submit Documents
    final submitButton = find.text('Submit Documents');
    await tester.tap(submitButton);
    await tester.pump();

    // Verify loading spinner / text is shown
    expect(find.text('Encrypting & Submitting...'), findsOneWidget);

    // Wait for the simulated submission delay
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump();

    // 8. Verify Success Dialog appears with exact prompt requirement
    expect(find.text('Documents Submitted!'), findsOneWidget);
    expect(
      find.text('Documents submitted for review. It usually takes 24 hours.'),
      findsOneWidget,
    );

    // 9. Tap return to dashboard
    final returnBtn = find.text('Back to Dashboard');
    expect(returnBtn, findsOneWidget);
    await tester.tap(returnBtn);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Screen'), findsOneWidget);
  });

  testWidgets(
      'ProviderDashboardScreen displays KYC warning card with Verify Now button routing to /provider-kyc',
      (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/provider-dashboard',
      routes: [
        GoRoute(
          path: '/provider-dashboard',
          builder: (context, state) => const ProviderDashboardScreen(),
        ),
        GoRoute(
          path: '/provider-kyc',
          builder: (context, state) =>
              const Scaffold(body: Text('KYC Verification Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: testRouter,
      ),
    );

    // Pump frame for dashboard initialization
    await tester.pump(const Duration(milliseconds: 300));

    // Verify KYC warning card title and text
    expect(
      find.text('Identity Unverified: Complete your KYC to start receiving jobs'),
      findsOneWidget,
    );

    // Verify 'Verify Now' button is present
    final verifyNowBtn = find.text('Verify Now');
    expect(verifyNowBtn, findsOneWidget);

    // Tap 'Verify Now' button and verify route transition
    await tester.tap(verifyNowBtn);
    await tester.pumpAndSettle();

    expect(find.text('KYC Verification Screen'), findsOneWidget);
  });
}
