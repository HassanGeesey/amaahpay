# AGENTS.md

## Essential Commands

```bash
flutter run              # Run app
flutter test            # Run tests
flutter analyze         # Lint + typecheck
flutter format lib/      # Fix formatting
flutter devices         # List available devices
flutter run -d <id>     # Run on specific device
```

## Verified Build Info

- **CI:** Flutter 3.41.7 (see `.github/workflows/build.yml`)
- **Lints:** Uses `package:flutter_lints/flutter.yaml`
- **APK output:** `build/app/outputs/flutter-apk/*.apk`

## Critical Files

- `lib/core/constants/env.dart` - Contains Supabase URL + anon key (hardcoded, **do not commit changes without warning**)
- `lib/main.dart` - App entry point, initializes Supabase + Riverpod
- `test/widget_test.dart` - Basic widget test (wrap in `ProviderScope` for Riverpod-dependent tests)

## Architectural Patterns

- **Offline-first:** UI reads from local SQLite, writes sync to Supabase with `pending_sync = true` flag
- **Role-based routing:** `routerProvider` in `core/routing/router.dart` enforces `/login`, `/admin/*`, `/merchant/*`
- **Dual-currency:** Use `DualCurrencyText(usd: X, sos: Y)` widget (format: `$10.00 / 27,000 SOS`)
- **Billing lifecycle:** Admin creates user → **disabled** → admin activates after payment → account auto-deactivates at cycle end
- **Credit/deposit logic:** Customer with both credit + deposit: payment **always** deducts credit first, then deposit

## Model Convention

```dart
// From CLAUDE.md verified pattern:
DateTime.parse(json['created_at'].toString())
(json['amount'] as num?)?.toDouble() ?? 0.0
```

## No Codegen

This repo has no build_runner/code generation commands. No custom generators beyond standard Flutter build.

## References

- `CLAUDE.md` - Full guidance for Claude Code sessions
- `architecture.md` - Detailed architecture docs
- `pubspec.yaml` - Dependencies (flutter_riverpod, go_router, supabase_flutter, sqflite, google_fonts)