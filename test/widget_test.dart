import 'package:flutter_test/flutter_test.dart';

import 'package:barkod_hub/main.dart';

void main() {
  testWidgets('BarkodHubApp opens home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BarkodHubApp());

    expect(find.text('Barkod Hub'), findsWidgets);
    expect(find.text('Barkod Tara'), findsOneWidget);
    expect(find.text('Manuel Barkod Gir'), findsOneWidget);
  });
}