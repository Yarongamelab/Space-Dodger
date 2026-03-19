// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:space_dodger/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpaceDodgerApp());

    // Verify that the app displays the title.
    expect(find.text('SPACE'), findsOneWidget);
  });
}
