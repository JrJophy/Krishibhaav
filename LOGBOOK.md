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
---
