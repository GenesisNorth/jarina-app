import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jarina/app/app.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/security/app_security.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Walks the whole sign-up on a real device/simulator and captures each step.
///
/// ```sh
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/onboarding_screens_test.dart -d DEVICE_ID
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding screens', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    SharedPreferences.setMockInitialValues({'installed': true});
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          envProvider.overrideWithValue(Env.staging),
          lockOnLaunchProvider.overrideWithValue(false),
          sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        ],
        child: const JarinaApp(),
      ),
    );
    await tester.pumpAndSettle();

    var n = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot('${(++n).toString().padLeft(2, '0')}-$name');
    }

    Future<void> button(String label) async {
      final f = find.widgetWithText(JButton, label);
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Future<void> keys(String digits) async {
      for (final d in digits.split('')) {
        await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    }

    Future<void> type(Finder f, String text) async {
      await tester.enterText(f, text);
      await tester.pump();
    }

    Future<void> hideKeyboard() async {
      FocusManager.instance.primaryFocus?.unfocus();
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await tester.pumpAndSettle();
    }

    await shot('welcome');
    await button('Create account');
    await shot('country');
    await tester.tap(find.bySemanticsLabel('Nigeria'));
    await tester.pumpAndSettle();
    await shot('language');
    await button('Continue');
    await shot('phone');
    await type(find.byType(TextField), '08012345678');
    await hideKeyboard();
    await shot('phone-filled');
    await button('Send WhatsApp code');
    await keys('12');
    await shot('otp');
    await keys(FakeBackend.demoCode.substring(2));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    await tapContinueEmpty(tester);
    await shot('details-errors');
    final f = find.byType(TextField);
    await type(f.at(0), 'Aminu');
    await type(f.at(2), 'Bello');
    await type(f.at(3), '12051990');
    await type(f.at(4), 'aminu@example.com');
    await hideKeyboard();
    await button('Continue');

    await type(find.byType(TextField), 'aminu');
    await tester.pump(const Duration(milliseconds: 600));
    await hideKeyboard();
    await shot('username-taken');
    await tester.tap(find.text('@bello.aminu'));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('username-available');
    await button('Claim @bello.aminu');

    await type(find.byType(TextField), '22212345678');
    await hideKeyboard();
    await shot('identity');
    await button('Continue');

    await shot('liveness');
    await button('Start camera');
    await tester.pump(const Duration(seconds: 3));
    await shot('liveness-done');
    await button('Continue');

    await tester.tap(find.text('Select state'));
    await tester.pumpAndSettle();
    await shot('address-states');
    await type(find.descendant(of: find.byType(BottomSheet), matching: find.byType(TextField)), 'kan');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Kano')));
    await tester.pumpAndSettle();
    final a = find.byType(TextField);
    await type(a.at(0), 'Kano');
    await type(a.at(1), 'No. 12 Zoo Road');
    await hideKeyboard();
    await tester.ensureVisible(find.text('Trader'));
    await tester.tap(find.text('Trader'));
    await shot('address');
    await button('Continue');

    await keys('739');
    await shot('pin-create');
    await keys('462');
    await keys('739462');

    await shot('twofa-setup');
    await type(find.byType(TextField), FakeBackend.demoCode);
    await hideKeyboard();
    await button('Verify & turn on 2FA');
    await shot('verified');
  });
}

Future<void> tapContinueEmpty(WidgetTester tester) async {
  final f = find.widgetWithText(JButton, 'Continue');
  await tester.tap(f);
  await tester.pumpAndSettle();
}
