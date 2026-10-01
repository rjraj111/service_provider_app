import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utsho/features/home/home_screen.dart';
import 'package:utsho/l10n/app_localizations.dart';

void main() {
  testWidgets('HomeScreen displays FloatingActionButton and opens ReviewBottomSheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('bn'),
          ],
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify FAB is displayed
    final fabFinder = find.text('Review & Tip (Demo)');
    expect(fabFinder, findsOneWidget);

    // Tap FAB
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Verify ReviewBottomSheet opened with header and elements
    expect(find.text('How was your service with Rahim Uddin?'), findsOneWidget);
    expect(find.text('Say thanks with a tip (100% goes to the provider)'), findsOneWidget);
    expect(find.text('Submit Review'), findsOneWidget);
  });
}
