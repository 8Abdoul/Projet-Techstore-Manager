import 'package:flutter_test/flutter_test.dart';
import 'package:techstore_manager/main.dart';

void main() {
  testWidgets('TechStore app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const TechStoreApp());
    await tester.pumpAndSettle();

    // "TechStore" apparaît dans l'AppBar de l'écran Accueil
    expect(find.text('TechStore'), findsOneWidget);
  });
}
