# Releasing

## One-time setup

**Android signing.** Create an upload key and keep it out of git:

```bash
keytool -genkey -v -keystore ~/keys/jarina-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`apps/mobile/android/key.properties` (git-ignored):

```
storeFile=/Users/you/keys/jarina-upload.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

Without this file, release builds are signed with the debug key (fine for internal testing, rejected by Play). Enrol in **Play App Signing** so Google holds the app-signing key.

**iOS.** Needs an Apple Developer account (organisation, D-U-N-S number for the company). In Xcode set the team for `com.jarina.app`, create the App Store Connect record, and enable automatic signing.

## Build

```bash
make release-android   # build/app/outputs/bundle/release/app-release.aab
make release-ios       # build/ios/ipa/*.ipa
```

Both builds are obfuscated; keep `apps/mobile/build/symbols/` for each release (needed to read crash stack traces). Bump `version:` in `apps/mobile/pubspec.yaml` (`1.2.0+42` → name 1.2.0, build 42) before every upload.

Today these point at `main_prod.dart`, which throws until the real API exists. Use `-t lib/main_staging.dart` for internal tracks with fake data.

## Test tracks

- **Android:** Play Console → Testing → Internal testing → upload the `.aab`, add tester emails.
- **iOS:** upload the `.ipa` with Transporter or `xcrun altool`, then TestFlight → Internal testing.

## Store listing checklist

- [ ] App icon 1024×1024 (no transparency) and adaptive icon (foreground + background layers)
- [ ] Screenshots: 6.7" and 5.5" iPhone; Android phone. Generate from the `integration_test/*_screens_test.dart` walkthroughs
- [ ] Short and full descriptions in English, Hausa and French
- [ ] Privacy policy URL and support URL
- [ ] Financial services declarations (Play) and the licensing partner names

## Privacy labels / Data safety

| Data | Collected | Why | Shared |
|---|---|---|---|
| Name, date of birth, address | Yes | KYC (regulatory) | KYC vendor, licensed partners |
| Phone number, email | Yes | Login (WhatsApp OTP), receipts | Messaging provider |
| Government ID (BVN/NIN/passport), selfie | Yes | Identity verification, liveness | KYC vendor |
| Financial info (balances, transactions) | Yes | Core service | Broker, exchange, payment partners |
| Device ID, root/jailbreak signal | Yes | Fraud prevention, device binding | No |
| Crash logs | Yes (once added) | Stability | Crash vendor (scrubbed) |
| Location, contacts, photos library | No | — | — |

Data is encrypted in transit; users can request deletion (support chat → account closure, subject to record-keeping law).
