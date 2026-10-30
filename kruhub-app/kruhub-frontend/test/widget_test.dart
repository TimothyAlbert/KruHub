import 'package:flutter_test/flutter_test.dart';
import 'package:kruhub_mobile/main.dart';

void main() {
  testWidgets('KruHub app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KruHubApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
