import 'package:flutter_test/flutter_test.dart';

import 'package:fap_online_ui/main.dart';

void main() {
  testWidgets('App builds AuthGate', (WidgetTester tester) async {
    await tester.pumpWidget(const FapOnlineApp());
    expect(find.byType(FapOnlineApp), findsOneWidget);
  });
}
