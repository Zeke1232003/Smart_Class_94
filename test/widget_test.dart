import 'package:flutter_test/flutter_test.dart';

import 'package:smart_class_app/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartClassApp());

    expect(find.text('Smart Class Check-in'), findsOneWidget);
    expect(find.text('Check-in (Before Class)'), findsOneWidget);
    expect(find.text('Finish Class (After Class)'), findsOneWidget);
  });
}
