# Mobile security (OWASP MASVS L2)

Status of the app against the [MASVS](https://mas.owasp.org/MASVS/) controls that matter for a money app.
✅ done in the app · 🟡 needs the backend · ⬜ to do.

## Storage (MASVS-STORAGE)

| Control | Status | Where |
|---|---|---|
| Session tokens in the Keychain / Android Keystore, never in SharedPreferences | ✅ | `SessionStore` (flutter_secure_storage) |
| Keychain items not migrated to other devices or readable before first unlock | ✅ | `KeychainAccessibility.first_unlock_this_device` |
| PIN never stored on the device; checked by the server | ✅ | `SecurityRepository.verifyPin` |
| Reinstall doesn't sign in as the previous user (iOS keeps Keychain items) | ✅ | `bootstrap.dart` clears on first launch |
| No cloud backup or device-to-device transfer of app data | ✅ | `allowBackup=false`, `data_extraction_rules.xml` |
| No balances, tokens or PINs in logs | ✅ | `log()` only in error hooks; crash vendor to scrub |
| Screenshots / screen recording / app-switcher previews blocked | ✅ Android release (`FLAG_SECURE`), iOS privacy cover | `MainActivity.kt`, `SecurityShell` |

## Authentication (MASVS-AUTH)

| Control | Status | Where |
|---|---|---|
| WhatsApp OTP + TOTP 2FA, no password | ✅ app · 🟡 server | onboarding / `AuthRepository` |
| Step-up PIN for every money movement; PIN + 2FA for withdrawals, cross-border, sells to bank | ✅ app · 🟡 server enforces | `confirmWithPin`, `confirmWithPinAnd2fa` |
| 5 wrong PINs lock the PIN | ✅ app · 🟡 server is the source of truth | `FakeBackend.maxPinAttempts` |
| App locks on launch and after 2 min in the background; 5 wrong PINs sign out | ✅ | `AppLock`, `SecurityShell` |
| 2FA can't be turned off on Tier 2 | ✅ | `AccountScreen` |
| Backup codes regenerate only with 2FA; trusted devices can be signed out | ✅ app · 🟡 server | `SecurityRepository` |
| Short-lived step-up tokens bound to the action and amount | 🟡 | API contract |
| Biometrics (Face ID / fingerprint) for small payments | ⬜ preference stored; wire `local_auth` with a server-side limit | `BiometricsSetting` |

## Network (MASVS-NETWORK)

| Control | Status |
|---|---|
| HTTPS only (`usesCleartextTraffic=false`, iOS ATS default) | ✅ |
| Certificate / public-key pinning to the API's intermediate CA, with a backup pin | 🟡 add with the real API client (staging first) |
| Request signing / replay protection for money-moving calls (idempotency keys) | 🟡 |

## Platform (MASVS-PLATFORM)

| Control | Status |
|---|---|
| No exported components besides the launcher activity | ✅ |
| Deep links (`jarina://verify/{id}`) validated and never auto-execute payments | ⬜ when receipts verification ships |
| Clipboard: only addresses/codes the user explicitly copies | ✅ |
| Text fields for secrets don't offer autofill/suggestions | ✅ PIN uses the in-app keypad |

## Code & resilience (MASVS-CODE, MASVS-RESILIENCE)

| Control | Status |
|---|---|
| Release builds obfuscated, symbols kept privately for crash decoding | ✅ `make release-android` / `release-ios` |
| R8 shrinking on Android | ✅ |
| Root / jailbreak detection: warn the user and send the signal to the server | ✅ warning · 🟡 server limits withdrawals | `jarina/device` channel |
| Release signing keys outside the repo | ✅ `android/key.properties` (git-ignored) |
| Dependency updates and vulnerability scanning in CI | ⬜ add Dependabot / `osv-scanner` |
| Crash reporting with PII scrubbing | ⬜ choose vendor (Sentry/Crashlytics); hooks are in `bootstrap.dart` |
| Play Integrity / App Attest on sensitive calls | 🟡 |

## Before the first public release

1. Pinning + idempotency keys in the API client.
2. Crash reporting with scrubbing.
3. Biometrics via `local_auth`.
4. External penetration test against MASVS L2 (app + API).
