# Quality checks

| Layer | What it covers | Run |
|---|---|---|
| Unit (core) | Money, rounding, validators, TOTP, NGX hours, address rules | `cd packages/jarina_core && dart test` |
| Unit (app) | Fake backends: ledger, trading, crypto, payments, Autopilot engine | `flutter test test/features` |
| Flows | Every critical journey through the real router and screens | `flutter test test/flows` |
| Routes | Every route opens for the session allowed to see it; guards redirect | `flutter test test/app/app_routes_test.dart` |
| Accessibility | All screens at 200% text on a 360pt phone; 48pt tap targets, labels, WCAG AA contrast; every button pressable by a screen reader | `flutter test test/app/accessibility_test.dart` |
| App lock | Lock on launch, relock after 2 min in background, 5 wrong PINs sign out | `flutter test test/app/security_shell_test.dart` |
| Goldens | 10 key screens × light EN/HA/FR, dark, small phone (macOS only) | `make goldens` to update; `flutter test --tags golden` to check |
| Device journeys | The flow suite on a real device / simulator | `flutter test integration_test/journeys_test.dart -d DEVICE` |
| Screenshots | Walkthroughs per phase, saved to `build/screenshots/` | `flutter drive --driver test_driver/integration_test.dart --target integration_test/<phase>_screens_test.dart -d DEVICE` |
| Performance | Frame timings while scrolling with live prices (profile mode, real Android phone) | `flutter drive --profile --driver test_driver/perf_driver.dart --target integration_test/perf_test.dart -d DEVICE` |

CI (Linux) runs format, analyze, codegen freshness, core tests and all app tests except goldens.

## Budgets

- Frames: 90th percentile build and raster < 16 ms; < 5% missed frames on a low-end Android (e.g. Tecno/Itel/Samsung A0x class).
- Download size: ≤ 25 MB per ABI (now ~20 MB arm64, ~17.5 MB armeabi-v7a).
- Cold start to first frame: < 2 s on the same phone.
