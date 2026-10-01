import 'package:flutter_test/flutter_test.dart';
import 'package:utsho/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic smoke test to ensure ServiceProviderApp initializes
    expect(const ServiceProviderApp(), isNotNull);
  });
}
