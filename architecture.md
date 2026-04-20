# AmaahPay — Architecture Document

## 1. Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (`flutter_riverpod`) for robust provider-based state tracking.
- **Routing:** GoRouter (`go_router`) for declarative routing and role-based redirect guards.
- **Backend / Auth / Remote Database:** Supabase (`supabase_flutter`).
- **Local Database (Offline-First):** `sqflite` for relational SQLite, or `isar` for fast NoSQL docs. For this financial/transactional app, `sqflite` is recommended to maintain strict relational constraints (Users -> Sales -> Products).

## 2. Directory Structure

```text
lib/
├── core/
│   ├── constants/       # Theme, colors, styles
│   ├── routing/         # go_router configuration & guards
│   ├── localization/    # English/Somali translation dictionaries
│   └── utils/           # Dual-currency formatters, date helpers
├── data/
│   ├── models/          # Dart data classes (User, Customer, Sale, Product)
│   ├── local/           # SQLite database helper, DAOs
│   ├── remote/          # Supabase service layer
│   └── repositories/    # unified offline-first repository layer
├── features/
│   ├── auth/            # Login, Auth state providers
│   ├── admin/           # Admin user management, billing UI
│   ├── merchant_home/   # Merchant dashboard
│   ├── customers/       # Customer CRUD & ledgers
│   ├── products/        # Product catalog
│   ├── sales/           # POS checkout flow
│   └── settings/        # Language, currency convertor
└── main.dart            # Entry point & ProviderScope
```

## 3. Data Flow (Offline-First Sync)
1. **Reads:** The UI reads entirely from the local SQLite database via the Repository layer. This guarantees a 0ms load time and offline capability.
2. **Writes:** 
   - A write (e.g., New Sale) is committed directly to the local SQLite database.
   - A background sync queue or service attempts to push the mutation to Supabase.
   - If offline, the mutation is flagged as `pending_sync = true`.
3. **Background Sync:** Periodically (or upon network restore), the app pushes `pending_sync` records to Supabase, and fetches new remote events from Supabase to update the local SQLite database.

## 4. Role-Based Routing Logic
- The `go_router` uses a `redirect` callback that watches the current auth state:
  - If `user == null` → Redirect to `/login`
  - If `user.role == 'admin'` → Restrict access to `/admin/*`, redirect from merchant paths.
  - If `user.role == 'merchant'` → Verify active billing status. If disabled, force redirect to `/deactivated`. Otherwise, allow access to `/merchant/*`.
