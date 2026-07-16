# Project State Checkpoint - 2026-07-16

This document maps the exact technical state of the Krishibhaav codebase and live environments for context loading.

---

## 1. FILE TREE

```
.
├── .firebaserc
├── .flutter-plugins-dependencies
├── .metadata
├── README.md
├── TESTING.md
├── analysis_options.yaml
├── firebase.json
├── firestore-debug.log
├── firestore.rules
├── krishibhaav.iml
├── pubspec.lock
├── pubspec.yaml
├── .firebase/
│   └── hosting.YnVpbGRcd2Vi.cache
├── .idea/
│   ├── modules.xml
│   ├── workspace.xml
│   └── libraries/
│       ├── Dart_SDK.xml
│       └── KotlinJavaRuntime.xml
│   └── runConfigurations/
│       └── main_dart.xml
├── assets/
│   └── branding/
│       ├── icon_tile.png
│       ├── lockup.png
│       ├── symbol.png
│       └── symbol_white.png
├── docs/
│   ├── COMMIT_INDEX.md
│   └── SETUP.md
├── firestore_tests/
│   ├── fetch_rajan.js
│   ├── fetch_suresh.js
│   ├── firestore-debug.log
│   ├── package-lock.json
│   ├── package.json
│   └── test/
│       └── gatekeeper_rules.test.js
├── functions/
│   ├── index.js
│   └── package.json
├── lib/
│   ├── app_router.dart
│   ├── firebase_options.dart
│   ├── main.dart
│   ├── core/
│   │   ├── barrel_logic.dart
│   │   ├── colors.dart
│   │   ├── market_message_parser.dart
│   │   ├── market_status.dart
│   │   └── text_styles.dart
│   ├── models/
│   │   ├── agent_settings_model.dart
│   │   ├── barrel_booking_model.dart
│   │   ├── barrel_stock_model.dart
│   │   ├── board_rate_model.dart
│   │   ├── farmer_price_model.dart
│   │   ├── open_market_price_point.dart
│   │   ├── price_point.dart
│   │   └── user_model.dart
│   ├── providers/
│   │   ├── agent_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── farmer_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── booking_history_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── agent/
│   │   │   ├── add_farmer_sheet.dart
│   │   │   ├── agent_home_screen.dart
│   │   │   ├── barrel_booking_detail_sheet.dart
│   │   │   ├── farmer_detail_sheet.dart
│   │   │   └── pending_requests_screen.dart
│   │   ├── auth/
│   │   │   ├── login_register_screen.dart
│   │   │   └── otp_screen.dart
│   │   └── farmer/
│   │       ├── farmer_barrel_action_sheet.dart
│   │       ├── farmer_barrel_request_sheet.dart
│   │       ├── farmer_home_screen.dart
│   │       └── request_link_screen.dart
│   ├── services/
│   │   ├── agent_service.dart
│   │   ├── auth_service.dart
│   │   ├── barrel_service.dart
│   │   ├── board_rate_service.dart
│   │   ├── cache_service.dart
│   │   ├── farmer_history_service.dart
│   │   ├── farmer_service.dart
│   │   ├── fcm_dispatch_service.dart
│   │   ├── notification_service.dart
│   │   └── price_history_service.dart
│   ├── utils/
│   │   └── theme.dart
│   └── widgets/
│       ├── barrel_booking_card.dart
│       ├── barrel_stock_edit_dialog.dart
│       ├── booking_history_row.dart
│       ├── farmer_barrel_booking_card.dart
│       ├── farmer_list_card.dart
│       ├── paste_market_message_sheet.dart
│       ├── price_chart_widget.dart
│       ├── price_edit_dialog.dart
│       ├── profile_sheet.dart
│       └── stats_grid_widget.dart
├── misc/
│   ├── BUG_REPORT.md
│   ├── DATABASE_SCHEMA.md
│   ├── LOGBOOK.md
│   ├── LOREBOOK.md
│   ├── PROGRESS_TRACKER.md
│   ├── project_structure.md
│   └── V2_SPEC.md
├── test/
│   ├── barrel_booking_model_test.dart
│   ├── barrel_logic_test.dart
│   ├── farmer_history_service_test.dart
│   ├── gatekeeper_link_test.dart
│   ├── market_message_parser_test.dart
│   ├── router_redirect_test.dart
│   ├── ui_integration_test.dart
│   └── user_model_test.dart
└── web/
    ├── favicon.png
    ├── firebase-messaging-sw.js
    ├── index.html
    ├── manifest.json
    ├── downloads/
    │   └── README.txt
    └── icons/
        ├── Icon-192.png
        ├── Icon-512.png
        ├── Icon-maskable-192.png
        └── Icon-maskable-512.png
```

---

## 2. STACK & VERSIONS

| Package Name | Current Version | Source / Notes |
| :--- | :--- | :--- |
| **Flutter SDK** | `>=3.2.0 <4.0.0` | `pubspec.yaml` environment bounds. |
| `provider` | `^6.1.1` | State management. |
| `rxdart` | `^0.27.7` | Reactive extensions (streams, pricing math). |
| `go_router` | `^13.2.0` | Decoupled UI routing. |
| `firebase_core` | `^4.12.1` | Firebase base setup. |
| `firebase_auth` | `^6.5.6` | Firebase authentication support. |
| `cloud_firestore` | `^6.7.1` | Live document database support. |
| `firebase_messaging` | `^16.4.3` | Push notifications support. |
| `cloud_functions` | `^6.3.5` | Callable Cloud Functions interface. |
| `google_fonts` | `^6.1.0` | Outfit, Inter typography. |
| `intl` | `^0.18.1` | Currency/date utilities. |
| `shared_preferences`| `^2.2.2` | Offline pricing caching. |
| `http` | `^1.1.2` | REST endpoint fetching. |
| `googleapis_auth` | `^1.4.1` | Google OAuth credentials fetching. |
| `fl_chart` | `^0.69.0` | Render line charts. |
| `url_launcher` | `^6.3.2` | External URL opening helper. |
| `package_info_plus` | `^10.1.0` | App metadata inspection. |
| `firebase-admin` | `^12.0.0` | Node.js Server/Functions admin access. |
| `firebase-functions`| `^5.0.0` | Node.js Functions handler API. |

---

## 3. MODULE MAP

### Models (`lib/models/`)
*   `agent_settings_model.dart`: Models global price configurations per agent. Classes: `AgentSettingsModel`.
*   `barrel_booking_model.dart`: Models the states and timestamps of physical barrel requests. Classes: `BarrelBookingModel`.
*   `barrel_stock_model.dart`: Models total and available barrel stocks for agents. Classes: `BarrelStockModel`.
*   `board_rate_model.dart`: Models read-only daily Rubber Board scraped pricing. Classes: `BoardRateModel`.
*   `farmer_price_model.dart`: Models farmer visibility rights and custom pricing overrides. Classes: `FarmerPriceModel`.
*   `open_market_price_point.dart`: Maps scraped open market history rates for chart feeds. Classes: `OpenMarketPricePoint`.
*   `price_point.dart`: Maps farmer effective price history lists for charts. Classes: `PricePoint`.
*   `user_model.dart`: Maps user profile attributes and roles (Agent vs. Farmer). Classes: `UserModel`.

### Providers (`lib/providers/`)
*   `agent_provider.dart`: Exposes price metrics edits, rosters, and incoming link requests. Classes: `AgentProvider`.
*   `auth_provider.dart`: Manages registration, logins, and OTP validations. Classes: `AuthProvider`.
*   `farmer_provider.dart`: Channels streams for effective pricing, stock, and booking actions. Classes: `FarmerProvider`.
*   `theme_provider.dart`: Dictates dark/light theme switching. Classes: `ThemeProvider`.

### Screens (`lib/screens/`)
*   `booking_history_screen.dart`: Renders completed barrel bookings with filter controls. Classes: `BookingHistoryScreen`.
*   `splash_screen.dart`: Handles initialization delay and auth direction routes. Classes: `SplashScreen`.
*   `agent/add_farmer_sheet.dart`: Agent's form to create new farmer accounts. Classes: `AddFarmerSheet`.
*   `agent/agent_home_screen.dart`: Primary agent dashboard (price grids and rosters). Classes: `AgentHomeScreen`.
*   `agent/barrel_booking_detail_sheet.dart`: Handles booking validations (approve, dispatch actions). Classes: `BarrelBookingDetailSheet`.
*   `agent/farmer_detail_sheet.dart`: Bottom panel to customize price rates and toggle source rights. Classes: `FarmerDetailSheet`.
*   `agent/pending_requests_screen.dart`: Agent UI to resolve unlinked farmer associations. Classes: `PendingRequestsScreen`.
*   `auth/login_register_screen.dart`: Forms for logins and registering mobile numbers. Classes: `LoginRegisterScreen`.
*   `auth/otp_screen.dart`: Form to enter SMS OTP codes. Classes: `OtpScreen`.
*   `farmer/farmer_barrel_action_sheet.dart`: Bottom panel to trigger returns or cancel booking requests. Classes: `FarmerBarrelActionSheet`.
*   `farmer/farmer_barrel_request_sheet.dart`: Validation sheet to request physical barrels. Classes: `FarmerBarrelRequestSheet`.
*   `farmer/farmer_home_screen.dart`: Farmer dashboard (price trends, history charts, active bookings). Classes: `FarmerHomeScreen`.
*   `farmer/request_link_screen.dart`: Form for unlinked farmers to submit link requests. Classes: `RequestLinkScreen`.

### Services (`lib/services/`)
*   `agent_service.dart`: Reads/writes agent settings, custom prices, and rosters in Firestore. Classes: `AgentService`.
*   `auth_service.dart`: Integrates Firebase Phone Auth and profiles creation. Classes: `AuthService`.
*   `barrel_service.dart`: Runs Firestore transactions for bookings and stock adjustments. Classes: `BarrelService`.
*   `board_rate_service.dart`: Streams scraped daily Rubber Board document. Classes: `BoardRateService`.
*   `cache_service.dart`: Simple offline cache layer for prices. Classes: `CacheService`.
*   `farmer_history_service.dart`: Queries history datasets and parses statistical trends. Classes: `FarmerHistoryService`.
*   `farmer_service.dart`: Resolves combined effective price streams for farmers. Classes: `FarmerService`.
*   `fcm_dispatch_service.dart`: Dispatches notification requests to Callable Cloud Functions. Classes: `FcmDispatchService`.
*   `notification_service.dart`: Handles device registrations and displays foreground overlays. Classes: `NotificationService`.
*   `price_history_service.dart`: Handles general open market price streams. Classes: `PriceHistoryService`.

### Utils & Widgets
*   `utils/theme.dart`: Colors (money green, modern teal, dark mode styling tokens).
*   `widgets/booking_history_row.dart`: Row list item for completed bookings. Classes: `BookingHistoryRow`.
*   `widgets/price_chart_widget.dart`: Draws responsive trend graphs. Classes: `PriceChartWidget`.
*   `widgets/stats_grid_widget.dart`: 2x2 grid showing high/low stats. Classes: `StatsGridWidget`.
*   `widgets/profile_sheet.dart`: Drawer panel to edit user info. Classes: `ProfileSheet`.

---

## 4. DATA LAYER

Detailed document schemas, collections, fields, and security policies are tracked separately.
*   See [misc/DATABASE_SCHEMA.md](file:///c:/Joel/Projects/Krishibhaav/misc/DATABASE_SCHEMA.md) for full mappings.

---

## 5. FEATURE STATUS

| Feature | Status | Notes |
| :--- | :--- | :--- |
| **Phone Authentication** | Done | Firebase SMS auth replaced OTP simulation. |
| **Agent Pricing Panel** | Done | Grid edits of Open Market, Company, and Global prices. |
| **Effective Pricing Stream** | Done | Blends global, custom overrides, and visibility rights. |
| **Price Trend Charts** | Done | Collapsible 30-day graphs with toggles. |
| **Farmer Link Workflows** | Done | Gatekeeper linking request flow with push alarms. |
| **Barrel Bookings** | Done | Deduct-on-approve, transaction-bound booking states. |
| **Barrel Stock Inventory** | Done | Limits requests to available stocks; updates on cancel/returns. |
| **Daily Scraping Automation** | Done | Runs scraper cron to update Board rates. |
| **Booking History** | Done | Shows completed booking lists with date range filters. |

---

## 6. KNOWN ISSUES / OPEN RISKS

*   **Critical:** Firestore rules lack a matcher for `/link_requests/{requestId}` collection. Farmers attempting client-side request additions in [request_link_screen.dart](file:///c:/Joel/Projects/Krishibhaav/lib/screens/farmer/request_link_screen.dart#L68) will trigger `PERMISSION_DENIED` in production.
*   **Medium:** GitHub Actions scraper cron job auto-disables after 60 days repository inactivity; risks scraper stopping (~Mid-Aug 2026).
*   **Low:** `price_history` has duplicates for June 5, 2026 (IDs: `"2026-06-05"` and `"2026-06-05 "`). Trailing-space ID uses legacy field schema (`rss4Price` instead of `openMarketPrice`).
*   **Low:** Raw debugPrint logging exposes sensitive info (FCM device registration tokens) in dev builds.
*   **Low:** Android builds compile with the debug keystore, blocking Play Store upload target.

---

## 7. DEPLOYMENT STATE

*   **Code Version:** `2.0.0+1` (in `pubspec.yaml`).
*   **Web Hosting:** Deployed to `https://krishibhaav.web.app` (Match? UNVERIFIED).
*   **Firestore Rules:** Enforced local `firestore.rules` (Match? UNVERIFIED).
*   **Cloud Functions:** Local `functions/index.js` contains 8 handlers (Match: **NO**, local-only).
*   **Prerequisites Pending Deployment:**
    *   **Blaze Plan Upgrade:** Firebase project `krishibhaav` is on the Spark plan. Deploys of Functions v2 (dependent on Cloud Run API) are blocked.
    *   **Phone Auth Activation:** Enable Phone provider in Firebase Authentication console.
    *   **SHA Fingerprints:** Register Android SHA-1 / SHA-256 signatures in Firebase project to enable SMS captcha bypass.

---

## 8. RECENT ACTIVITY

### Commits
*   **2026-07-14 \| 7faadf6:** feat: implement Firebase Cloud Messaging service with foreground notifications and add price edit dialog UI
*   **2026-07-14 \| 4a2a320:** feat: implement navigation routing, color palette, and farmer state management services
*   **2026-07-09 \| 701baf8:** feat: configure firestore rules in firebase.json
*   **2026-06-26 \| 94788a7:** fix: trim agentId at UserModel.fromMap boundary + unit test
*   **2026-06-26 \| 2d632b1:** Booking History screen, /history route, date filter + entry points (B2)
*   **2026-06-26 \| 15d276a:** docs: refresh progress tracker for Booking History + Phase 10 state
*   **2026-06-26 \| c1493e7:** add Booking History row widget + shared status helpers (B1)
*   **2026-06-26 \| 04a65c3:** docs: correct stale Firestore rules status in README
*   **2026-06-18 \| bc37308:** V2 Phase 7: widget integration tests via mock providers
*   **2026-06-18 \| 3befffa:** Phase 6 re-verification PASSED (OM chart and stats fix).
*   **2026-06-18 \| 523b262:** feat: V2 Phase 2 - agent stock UI, txn guard, B19 auth-gate, return deferred
*   **2026-06-17 \| 0e92206:** chore: gitignore firebase hosting cache
*   **2026-06-17 \| e04acc4:** feat: V2 Phase 1.5 - pure barrel logic extraction + unit tests

### Uncommitted Changes
*   `lib/app_router.dart`
*   `lib/providers/agent_provider.dart`
*   `lib/providers/auth_provider.dart`
*   `lib/providers/farmer_provider.dart`
*   `lib/screens/agent/agent_home_screen.dart`
*   `lib/screens/auth/login_register_screen.dart`
*   `lib/screens/auth/otp_screen.dart`
*   `lib/screens/farmer/farmer_home_screen.dart`
*   `lib/services/auth_service.dart`
*   `lib/services/fcm_dispatch_service.dart`
*   `lib/widgets/price_chart_widget.dart`
*   `misc/LOGBOOK.md`
*   `misc/V2_SPEC.md`
*   `pubspec.yaml`
*   `test/ui_integration_test.dart`
*   `lib/screens/agent/pending_requests_screen.dart`
*   `lib/screens/farmer/request_link_screen.dart`
*   `misc/DATABASE_SCHEMA.md`
*   `test/gatekeeper_link_test.dart`

---

## 9. NEXT DECISIONS PENDING

*   **Rules Fix:** Should we declare rules matching `/link_requests/{requestId}` in `firestore.rules` to allow client-side creates, or migrate submissions to Cloud Functions?
*   **Upgrade to Blaze Plan:** Confirm authorization to upgrade Firebase project to Blaze plan to support Cloud Functions deployment.
*   **Play Store Keystore Setup:** Decide if a release keystore configuration should be established for compilation, or continue with debug builds.
*   **Scraper Auto-Disable:** Confirm approach to bypass GitHub Actions keep-alive restrictions (e.g. scheduling keep-alive dummy commits).
