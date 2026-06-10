---
# Krishibhaav Project Logbook

## Project Overview
App: Krishibhaav — Kerala Rubber Price Intelligence App
Stack: Flutter + Firebase (Spark plan)
Repos: 
  Flutter: c:\Joel\Projects\Krishibhaav\
  Scraper: c:\Joel\Projects\KrishibhaavScraper\
Last Updated: 2026-06-09T14:45:00+05:30

## Recovery Instructions
If Antigravity crashes or connection is lost, read this file first.
Then read PROGRESS_TRACKER.md.
Resume from the last incomplete phase. Do not redo completed phases.

## VERSION_ROADMAP
V1 = current 10-phase spec (locked). V2 Phase 1 reserved: WhatsApp market-message paste-and-parse feature. New ideas go to V2+, never into V1.

## Pre-Coding Decisions Log
[2026-06-09] Project scoped as MCA academic project
[2026-06-09] App name decided: Krishibhaav
[2026-06-09] Platform: Flutter (Web + Android APK)
[2026-06-09] Backend: Firebase Spark plan (free tier)
[2026-06-09] Auth: Email/Password with simulated OTP (no real SMS)
[2026-06-09] State management: Provider + RxDart (no Riverpod)
[2026-06-09] Notifications: Client-side FCM REST API (no Cloud Functions)
[2026-06-09] Scraper: Separate repo, Python, deploys to Render.com
[2026-06-09] Seed data: Real RSS4 Kottayam prices, manually entered
[2026-06-09] Temp password format: First 4 letters name + last 4 digits mobile
[2026-06-09] Market hours: Mon-Sat 9AM-5PM IST (calculated from device time)
[2026-06-09] Two roles: Agent (sets prices) and Farmer (reads prices)
[2026-06-09] Three prices: Open Market, Company, Agent (global + per-farmer)
[2026-06-09] Implementation plan finalized and approved

## Change Log
[2026-06-09] | Phase 1 | LOGBOOK.md | Created file | Initial tracking setup
[2026-06-09] | Phase 1 | PROGRESS_TRACKER.md | Created file | Initial tracking setup
[2026-06-09] | Phase 1 | PROGRESS_TRACKER.md | Added blocker | flutter not in PATH
[2026-06-09] | Phase 1 | pubspec.yaml | Created file | App dependencies and setup
[2026-06-09] | Phase 1 | lib/main.dart | Created file | App entry point & provider setup
[2026-06-09] | Phase 1 | lib/utils/theme.dart | Created file | App material theme
[2026-06-09] | Phase 1 | lib/screens/splash_screen.dart | Created file | Initial splash screen UI
[2026-06-09] | Phase 1 | lib/*/.* | Created .gitkeep | Scaffolded models, services, providers folders
[2026-06-10] | Phase 2 | lib/models/user_model.dart | Created file | User schema
[2026-06-10] | Phase 2 | lib/services/auth_service.dart | Created file | Firebase Auth and User creation
[2026-06-10] | Phase 2 | lib/providers/auth_provider.dart | Created file | App auth state management
[2026-06-10] | Phase 2 | lib/screens/auth/* | Created files | Login and OTP screens
[2026-06-10] | Phase 3 | lib/models/* | Created files | AgentSettingsModel and FarmerPriceModel
[2026-06-10] | Phase 3 | lib/services/agent_service.dart | Created file | Agent Firestore interactions
[2026-06-10] | Phase 3 | lib/providers/agent_provider.dart | Created file | App agent state management
[2026-06-10] | Phase 3 | lib/widgets/* | Created files | PriceEditDialog and FarmerListCard
[2026-06-10] | Phase 3 | lib/screens/agent/* | Created files | AgentHomeScreen and AddFarmerSheet
[2026-06-10] | Phase 4 | lib/services/cache_service.dart | Created file | Shared prefs local caching
[2026-06-10] | Phase 4 | lib/services/farmer_service.dart | Created file | RxDart stream combining
[2026-06-10] | Phase 4 | lib/providers/farmer_provider.dart | Created file | Farmer state management
[2026-06-10] | Phase 4 | lib/core/market_status.dart | Created file | Time-based open/close logic
[2026-06-10] | Phase 4 | lib/screens/farmer/farmer_home_screen.dart | Created file | Real-time price display
[2026-06-10] | Phase 4 | lib/services/farmer_service.dart | Fixed combine logic | Treat missing farmer doc as no custom price
[2026-06-10] | Phase 4 | lib/providers/farmer_provider.dart | Fixed cache logic | Wrapped cache save in try-catch
[2026-06-10] | Phase 4 | lib/main.dart | Bug fix | Added FirebaseOptions to initialization
[2026-06-10] | Phase 4 | lib/screens/splash_screen.dart | Bug fix | Added missing navigation to auth route
[2026-06-10] | Phase 4 | lib/screens/auth/login_register_screen.dart | Bug fix | Fixed multiple tickers crash
[2026-06-10] | Phase 4 | lib/app_router.dart | Bug fix | Added pending-verification escape hatch and caching methods
[2026-06-10] | Phase 4 | lib/screens/auth/login_register_screen.dart | Bug fix | Set isAwaitingOtp before register
[2026-06-10] | Phase 4 | lib/screens/auth/otp_screen.dart | Bug fix | Handled isAwaitingOtp on success
[2026-06-10] | Phase 4 | lib/providers/auth_provider.dart | Bug fix | Reset router cache on signOut
[2026-06-10] | Phase 4 | lib/providers/auth_provider.dart | UX fix | Mapped Firebase auth errors to user-friendly messages
[2026-06-10] | Phase 4 | lib/screens/auth/login_register_screen.dart | Bug fix | Replaced invalid navigation routes
[2026-06-10] | Phase 4 | Diagnostics | Bug hunt | Added debugPrints for invalid-credential error, applied .trim() to inputs
[2026-06-10] | Phase 5 | pubspec.yaml | Dependency | Added fl_chart dependency
[2026-06-10] | Phase 5 | lib/models/price_point.dart | Created file | PricePoint data model
[2026-06-10] | Phase 5 | lib/services/price_history_service.dart | Created file | Firestore history fetcher and stats computer
[2026-06-10] | Phase 5 | lib/widgets/price_chart_widget.dart | Created file | fl_chart implementation
[2026-06-10] | Phase 5 | lib/widgets/stats_grid_widget.dart | Created file | 2x2 grid for 7-day and 30-day stats
[2026-06-10] | Phase 5 | lib/screens/farmer/farmer_home_screen.dart | Modification | Wired chart and stats grid into farmer UI
[2026-06-10] | Phase 5 | lib/screens/agent/agent_home_screen.dart | Modification | Added collapsed chart in agent UI
[2026-06-10] | Phase 5 | Multiple | Bug fix | Resolved analyzer warnings (unused imports, const constructors, missing colors)
[2026-06-10] | Phase 5 | lib/models/price_point.dart | Bug fix | Robust string/field-name parsing for PricePoint to fix flat chart (0.0 values) and stats
[2026-06-10] | Phase 5 | lib/widgets/price_chart_widget.dart | Bug fix | Enforced interval: 1 on X-axis and dynamic padding to fix repeating labels and scaling
[2026-06-10] | Phase 5 | lib/widgets/stats_grid_widget.dart | Bug fix | Fixed RenderFlex overflow by adjusting childAspectRatio to 1.8 and using FittedBox
[2026-06-10] | Phase 5 | lib/models/price_point.dart | Bug fix | Applied actual robust parsing fix (previous fix was reported but not properly applied)
[2026-06-10] | Phase 5 | Diagnostics | Instrumentation | Removed temporary debugPrints from price_history_service.dart and price_chart_widget.dart
[2026-06-10] | Phase 5 | lib/widgets/stats_grid_widget.dart | Bug fix | Wrapped grid Column in FittedBox to elegantly prevent RenderFlex overflows at any size
[2026-06-10] | Phase 5 | Summary | Phase Closure | Phase 5 debugging root causes were data-layer (Firestore field-name whitespace) and session hygiene — core service/widget code correct after fromMap field fix.
[2026-06-10] | Phase 6 | lib/screens/agent/farmer_detail_sheet.dart | Creation | Built detail sheet for farmer profile edits and custom price toggles
[2026-06-10] | Phase 6 | lib/services/agent_service.dart | Modification | Added setCustomPrice, clearCustomPrice, and updateFarmerProfile methods
[2026-06-10] | Phase 6 | lib/screens/agent/agent_home_screen.dart | Modification | Wired FarmerDetailSheet to FarmerListCard tap, customized Remove Farmer confirmation dialog
[2026-06-10] | Phase 6 | lib/screens/agent/agent_home_screen.dart | Bug fix | Updated empty-state message to handle active search queries correctly
[2026-06-10] | Phase 6 | Summary | Phase Closure | Detail sheet, custom pricing, search, live badges, and remove logic all verified end-to-end.
[2026-06-10] | Pre-Phase 7 | PROGRESS_TRACKER.md | Bug fix | Marked Phase 4 sign-in blocker as RESOLVED (root cause: orphaned/duplicate Auth UIDs and whitespace in Firestore data; resolution: Auth user recreated and Firestore docs migrated to the correct UID)
[2026-06-10] | Pre-Phase 7 | LOREBOOK.md | Documentation | Created an overarching narrative lorebook documenting the project journey from Phase 1 to Phase 6, and the roadmap ahead.
[2026-06-10] | Phase 7 | .gitignore | Security | Added assets/service_account.json to prevent credential leakage
[2026-06-10] | Phase 7 | SETUP.md | Documentation | Added manual setup steps for service_account.json and FCM
[2026-06-10] | Phase 7 | pubspec.yaml | Modification | Added googleapis_auth dependency and assets/service_account.json
[2026-06-10] | Phase 7 | web/firebase-messaging-sw.js | Creation | Created background service worker for FCM on Web
[2026-06-10] | Phase 7 | lib/services/notification_service.dart | Creation | Handles FCM token generation, saving to Firestore users collection, and foreground SnackBar display
[2026-06-10] | Phase 7 | lib/services/fcm_dispatch_service.dart | Creation | Client-side OAuth2 dispatcher using FCM REST v1 API to send notifications
[2026-06-10] | Phase 7 | lib/screens/agent/agent_home_screen.dart | Modification | Initialized NotificationService upon loading Agent dashboard
[2026-06-10] | Phase 7 | lib/screens/farmer/farmer_home_screen.dart | Modification | Initialized NotificationService upon loading Farmer dashboard
[2026-06-10] | Phase 7 | lib/providers/agent_provider.dart | Modification | Hooked FcmDispatchService.notifyGlobalPriceUpdate into updatePrice method
[2026-06-10] | Phase 7 | lib/screens/farmer/farmer_home_screen.dart | Bug fix | Added mounted check to resolve use_build_context_synchronously warning; wrapped Row children in Expanded to fix RenderFlex overflow
[2026-06-10] | Phase 7 | lib/services/fcm_dispatch_service.dart | Modification | Updated notification triggers and copy according to user mandate (Open Market, Company, Agent, Custom Set/Revert)
[2026-06-10] | Phase 7 | lib/providers/agent_provider.dart | Modification | Hooked new Open Market and Company price triggers into updatePrice
[2026-06-10] | Phase 7 | lib/screens/agent/farmer_detail_sheet.dart | Modification | Passed price values to FCM dispatch calls
[2026-06-10] | Phase 7 | lib/screens/agent/agent_home_screen.dart | Bug fix | Wrapped label Text in _buildPriceRow with Expanded to fix RenderFlex overflow
[2026-06-10] | Phase 7 | lib/screens/agent/farmer_detail_sheet.dart | Bug fix | Moved context-dependent globalPrice read before the await block to fix use_build_context_synchronously warning
[2026-06-10] | Phase 7 | lib/services/fcm_dispatch_service.dart | Modification | Updated trigger 4 (custom price set) copy per user mandate
---
