import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utsho/features/reviews/review_bottom_sheet.dart';

void main() {
  testWidgets(
      'ReviewBottomSheet renders header, stars, feedback field, tip chips, and submits review',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int? submittedRating;
    String? submittedFeedback;
    int? submittedTip;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showReviewBottomSheet(
                  context,
                  providerName: 'Rahim Uddin',
                  serviceName: 'Master AC Servicing',
                  onSubmit: (rating, feedback, tip) {
                    submittedRating = rating;
                    submittedFeedback = feedback;
                    submittedTip = tip;
                  },
                );
              },
              child: const Text('Open Review Sheet'),
            ),
          ),
        ),
      ),
    );

    // 1. Open the bottom sheet
    await tester.tap(find.text('Open Review Sheet'));
    await tester.pumpAndSettle();

    // 2. Verify Header
    expect(find.text('How was your service with Rahim Uddin?'), findsOneWidget);
    expect(find.text('Master AC Servicing · Service Completed'), findsOneWidget);

    // 3. Verify Stars and dynamic caption
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    expect(find.text('Exceptional service!'), findsOneWidget);

    // 4. Verify Feedback field hint
    expect(find.text('Write an optional feedback...'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'Great work on fixing the AC coolant leak quickly!',
    );
    await tester.pump();

    // 5. Verify Tipping Section header
    expect(
      find.text('Say thanks with a tip (100% goes to the provider)'),
      findsOneWidget,
    );

    // 6. Verify Selectable Tip Chips
    expect(find.text('৳20'), findsOneWidget);
    expect(find.text('৳50'), findsOneWidget);
    expect(find.text('৳100'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // Select ৳50 tip
    await tester.tap(find.text('৳50'));
    await tester.pump();

    // Verify submit button updates with tip amount
    expect(find.text('Submit Review & Pay ৳50 Tip'), findsOneWidget);

    // Test 'Other' custom tip chip
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    expect(find.text('Enter custom tip amount'), findsOneWidget);

    // Enter custom tip 150
    final customTipField = find.widgetWithText(TextField, 'Enter custom tip amount');
    await tester.enterText(customTipField, '150');
    await tester.pump();

    expect(find.text('Submit Review & Pay ৳150 Tip'), findsOneWidget);

    // 7. Submit Review
    await tester.tap(find.text('Submit Review & Pay ৳150 Tip'));
    await tester.pump();

    // Wait for the simulated submission delay
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify onSubmit callback received all values
    expect(submittedRating, 5);
    expect(submittedFeedback, 'Great work on fixing the AC coolant leak quickly!');
    expect(submittedTip, 150);

    // Verify confirmation feedback snackbar appears
    expect(
      find.textContaining('Thank you! Your 5-star review & ৳150 tip were sent to Rahim Uddin.'),
      findsOneWidget,
    );
  });
}
