# Krishibhaav — Kerala Rubber Price Intelligence

3-tier rubber price visibility (Board Rate scraped from the Rubber Board / Open Market via agent WhatsApp parsing / per-farmer agent prices) for Kerala rubber farmers and agents. Built initially as an MCA academic project (V1), it is evolving toward a free real-world application for the rubber farming community.

## Features
- **Role-based Auth:** Distinct experiences and controls for Farmers and Agents.
- **Security:** Role-scoped Firestore security rules, published and verified.
- **Live Board Rate Scraping:** Automated daily fetching of RSS4/RSS5 rates with holiday carry-forward logic.
- **WhatsApp Paste-Parser:** Smart parsing of Open Market prices directly from agent WhatsApp messages.
- **Granular Pricing:** Per-farmer custom prices and visibility controls managed by agents.
- **Analytics:** Farmer effective-price history chart with 7-day and 30-day statistical insights.
- **Push Notifications:** Real-time FCM push notifications for price updates.
- **Cross-Platform:** Available on Flutter Web and Android.
- **Theming:** Full Light/Dark theme support.

## Architecture
- **Frontend:** Flutter (State management via Provider + RxDart, routing via `go_router`, charting via `fl_chart`).
- **Backend:** Firebase Spark Plan (Firebase Auth, Firestore hosted in `asia-south1`, Firebase Cloud Messaging).
- **Data Pipeline:** Companion Python scraper repository (`KrishibhaavScraper`) running on a GitHub Actions cron job, automatically writing to `board_rates` and `price_history` collections.

## Live Demo
[https://krishibhaav.web.app](https://krishibhaav.web.app) *(demo/test access only)*

## Getting Started
```bash
flutter pub get
flutter run -d chrome
```
*Note:* Local execution requires `assets/service_account.json` and `android/app/google-services.json`, which are required but intentionally gitignored for security.

## Status
**V1 Completed (Full Release).**

*Known limitations scheduled for resolution in V2:*
- Simulated OTP for authentication.
- Client-side FCM dispatch.
