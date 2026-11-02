# Jarina app (Flutter)

Production rebuild of the `../jarina-mobile` prototype. Plan and phases: [`../ROADMAP.md`](../ROADMAP.md).

## Layout

```
apps/mobile/            the app (com.jarina.app)
packages/jarina_core/   pure Dart: Money, Currency, Result, Failure, formatting
packages/jarina_ui/     design system: generated tokens, theme, Poppins, icons, flags, components
tools/bin/              generators that read the prototype (tokens, i18n → ARB, seed data)
```

One pub workspace: run `flutter pub get` once at the root.

## Run

```bash
make run                      # dev flavor, fake data
cd apps/mobile && flutter run -t lib/main_staging.dart
cd apps/mobile && flutter run -t lib/main_local.dart   # account features against the local API
```

`main_local.dart` needs the backend running (`cd ../jarina_backend && make up && make dev`, port 3100). The WhatsApp code is `OTP_DEV_CODE` from its `.env` (123456); 2FA needs a real authenticator app. An Android emulator also needs `--dart-define=JARINA_API_URL=http://10.0.2.2:3100`. Live: sign-up, login, KYC details, username, address, PIN, 2FA, profile, backup codes, devices, and Markets (catalogue, real Quidax prices over the WebSocket, charts; stocks from a sandbox feed). Still fake: the ID and liveness checks (until Smile ID) and money movements (fake trades fill at the live prices). Add `--dart-define=JARINA_LIVE_WALLET=true` for the real naira wallet too (funding account, test deposits, balances, activity); demo trades then don't change those real balances.

In non-prod builds, the gold **DEV** chip opens the route index. There you can open any of the 63 screens, switch the session state (signed in / KYC done / 2FA) to test the router guards, and change theme and language.

## Docs

- [`docs/QUALITY.md`](docs/QUALITY.md): test layers, how to run them, budgets
- [`docs/SECURITY.md`](docs/SECURITY.md): OWASP MASVS L2 status
- [`docs/RELEASE.md`](docs/RELEASE.md): signing, store builds, privacy labels

## Generated code

| What | Source | Command |
|---|---|---|
| `jarina_tokens.g.dart` | `jarina-mobile/design/tokens.json` | `make tokens` |
| `lib/l10n/app_{en,ha,fr}.arb` | `jarina-mobile/i18n/*.json` | `make arb` |
| `assets/seed/*.json` | `jarina-mobile/js/01-data.js` | `make seed` (needs Node) |
| `lib/l10n/gen/` | ARB files | `make l10n` |
| `*.g.dart` (Riverpod, freezed, json) | annotations | `make codegen` |

`make gen` runs all of them. CI fails if generated files are out of date.

ARB ids are derived from the English text (`step1Of11YourCountry`). When you build a screen, rename its ids to meaningful names in `app_en.arb`; the generator keeps renamed ids on re-runs.

## Conventions

- **Money is never `double`.** Use `Money` / `Decimal` from `jarina_core`; format with `MoneyFormat`.
- Route names are the prototype screen ids (`AppRoute` in `app/router/routes.dart`). 2FA gating is declared per route (`gated: true`) and enforced in `route_guard.dart`.
- Features live in `apps/mobile/lib/features/<name>/{domain,data,application,presentation}`. Repositories return `Result<T>`.
- Read theme values with `context.colors` / `context.text`, not hard-coded colours.

## Checks

```bash
make analyze    # very_good_analysis, --fatal-infos
make test
```
# jarina-app
