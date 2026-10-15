
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoach_pro/app/app.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('eCoach Pro app launches', (WidgetTester tester) async {
    final storage = await LocalStorage.create();

    await tester.pumpWidget(EcoachApp(storage: storage));

    expect(find.byType(EcoachApp), findsOneWidget);
  });
}