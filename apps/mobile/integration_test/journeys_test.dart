import 'package:integration_test/integration_test.dart';

import '../test/app/security_shell_test.dart' as lock;
import '../test/flows/automation_flow_test.dart' as automation;
import '../test/flows/crypto_flow_test.dart' as crypto;
import '../test/flows/money_flow_test.dart' as money;
import '../test/flows/onboarding_flow_test.dart' as onboarding;
import '../test/flows/payments_flow_test.dart' as payments;
import '../test/flows/stocks_flow_test.dart' as stocks;

/// Critical journeys on a real device: the same flows as the widget tests
/// (sign-up and login with 2FA, buy stock, swap and withdraw crypto with 2FA,
/// bank / cross-border / P2P sends, bills, Autopilot, app lock).
///
/// ```sh
/// flutter test integration_test/journeys_test.dart -d DEVICE_ID
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  onboarding.main();
  money.main();
  stocks.main();
  crypto.main();
  payments.main();
  automation.main();
  lock.main();
}
