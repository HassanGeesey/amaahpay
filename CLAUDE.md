# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AmaahPay is a Flutter-based financial app for merchants (primarily agri-focused small businesses). It supports an offline-first architecture with dual-currency display (USD/SOS).

## Tech Stack

- **Framework:** Flutter (Dart ^3.11.4)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Routing:** GoRouter (`go_router`)
- **Backend/Auth:** Supabase (`supabase_flutter`)
- **Local Database:** sqflite (SQLite)
- **Fonts:** Google Fonts (Outfit for headings, Inter for body)

## Common Commands

```bash
# Run the app
flutter run

# Run on specific device
flutter run -d <device_id>

# List devices
flutter devices

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Fix formatting
flutter format lib/

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade
```

## Architecture

### Directory Structure (lib/)

```
lib/
├── core/
│   ├── constants/       # Theme, colors, styles
│   ├── routing/         # go_router configuration & guards
│   ├── localization/    # English/Somali translations
│   └── utils/           # Dual-currency formatters, date helpers
├── data/
│   ├── models/          # Data classes (UserModel, CustomerModel, etc.)
│   ├── local/           # SQLite database helpers and DAOs
│   ├── remote/          # Supabase service layer
│   └── repositories/    # Offline-first repository layer
├── features/
│   ├── auth/
│   ├── admin/
│   ├── merchant_home/
│   ├── customers/
│   ├── products/
│   ├── sales/
│   └── settings/
└── main.dart
```

### Key Architectural Patterns

1. **Offline-First Sync:**
   - UI reads from local SQLite only (0ms load time, offline capable)
   - Writes commit to SQLite first, then sync to Supabase in background
   - Pending syncs flagged with `pending_sync = true`

2. **Role-Based Routing:**
   - `routerProvider` in `core/routing/router.dart` handles auth redirects
   - Unauthenticated users → `/login`
   - `UserRole.admin` → `/admin/*` routes
   - `UserRole.merchant` → `/merchant/*` routes (with billing status check)

3. **Dual-Currency Display:**
   - Use `DualCurrencyText(usd: 10, sos: 27000)` widget in `lib/shared/widgets/dual_currency_text.dart`
   - Format: `$10.00 / 27,000 SOS` with SOS visually de-emphasized

4. **Billing Lifecycle (Admin-Merchant):**
   - Admin creates user → account starts **disabled**
   - Admin activates after payment confirmation, sets billing cycle (monthly/yearly) and price
   - App warns user 3 days before expiry; red banner during grace period (last 3 days)
   - Account **auto-deactivates** at cycle end; admin reactivates after next payment

5. **Credit/Deposit Sales Logic:**
   - Customer deposits with outstanding credit → amount first deducts credit, remainder goes to deposit
   - Customer uses credit with deposit funds → amount first deducts deposit, remainder becomes credit

6. **Password Reset:** Users cannot self-reset. Flow: user contacts admin → admin creates new password.

## Design System

- **Primary:** `#E65100` (Warm Sunset Orange) - `Colors.orange[900]`
- **Secondary:** `#4E342E` (Deep Earth Brown) - `Colors.brown[800]`
- **Background:** `#FAFAFA` (Off-White)
- **Success:** `#2E7D32` (Muted Green)
- **Error:** `#D32F2F` (Soft Red)

Typography via GoogleFonts: Outfit (headings), Inter (body).

## Model Conventions

- Models use `fromJson`/`toJson` for serialization
- DateTime fields parsed with `DateTime.parse()`
- Numeric fields cast with `(json['field'] as num?)?.toDouble() ?? 0.0`
- See `lib/data/models/user_model.dart` and `lib/data/models/customer_model.dart` for examples

## Key Screens & UI Patterns

- **Merchant Dashboard:** Bottom nav (Home, Customers, Sales, Settings). Customer list shows avatar (initials), name, phone, credit (red) and deposit (green).
- **Sales Flow:** Cart with sliding bottom sheet for payment breakdown popup.
- **Modals:** `AlertDialog` for alerts (deactivation warnings), `showModalBottomSheet` for forms (add product/customer on fly).
- **Admin Dashboard:** Bottom nav (Users, Reports, Settings). User cards with active/disabled badges (gray = disabled, green = active).

## Testing

- Widget tests use `flutter_test` package
- Wrap app with `ProviderScope` when testing widgets that depend on Riverpod providers
- Use `tester.pumpWidget()` and `tester.pump()` for async operations

## References

- `architecture.md` - Full architecture document
- `ui.md` - UI & design specifications
- `prd.md` - Product requirements
