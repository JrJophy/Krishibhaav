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
---
