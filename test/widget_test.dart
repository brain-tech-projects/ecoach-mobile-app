import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/core/theme/app_theme.dart';
import 'package:ecoach_pro/features/auth/presentation/pages/login_page.dart';
import 'package:ecoach_pro/features/onboarding/data/onboarding_content.dart';
import 'package:ecoach_pro/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ecoach_pro/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  late LocalStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = await LocalStorage.create();
  });

  tearDown(Get.reset);

  Future<void> pumpOnboarding(WidgetTester tester) async {
    // iPhone 16: 393 x 852 logical points @3x.
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    Get.put<OnboardingController>(OnboardingController(storage));

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark,
        initialRoute: '/',
        getPages: <GetPage<dynamic>>[
          GetPage<void>(name: '/', page: () => const OnboardingPage()),
          GetPage<void>(name: AppRoutes.login, page: () => const LoginPage()),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  test('onboarding content has 4 slides, last one is the free-trial text', () {
    expect(OnboardingContent.pages, hasLength(4));
    expect(OnboardingContent.pages.last.description, contains('7 Day Free Trial'));
  });

  testWidgets('first slide shows its title, pills and Skip', (tester) async {
    await pumpOnboarding(tester);

    expect(find.text('Coaching and Training'), findsOneWidget);
    expect(find.text('Professional-led Training'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('last slide shows Continue instead of Skip', (tester) async {
    await pumpOnboarding(tester);

    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
    }

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('Skip stores the flag and opens login', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(storage.isOnboardingCompleted, isTrue);
    expect(Get.currentRoute, AppRoutes.login);
  });
}