Derived document — regenerated from LOGBOOK.md and PROGRESS_TRACKER.md at each phase closure. Not a source of truth.
# The Krishibhaav Lorebook (The Story So Far)

**The Awakening (Phases 1-2)**
Our journey began with a clear mission: to build *Krishibhaav*, an ambitious MCA academic project designed to bring real-time Rubber price intelligence to the farmers of Kerala. We laid down the scaffolding—setting up Flutter and Firebase—and established our dual-role hierarchy (Agents and Farmers). Constrained by the free Firebase Spark tier, we couldn't rely on expensive SMS providers. Instead, we engineered an ingenious simulated OTP authentication system, complete with a unique, deterministic temporary password system tailored for farmers.

**The Dual Worlds (Phases 3-4)**
With the gates open, we built the Agent Core. Agents gained a powerful, centralized dashboard to dictate Open Market, Company, and Global Agent prices, and began assembling their roster of farmers. Then, the Farmers awoke. We constructed their real-time dashboard, binding the flow of prices to strict market hours (Mon-Sat, 9AM-5PM). Along the way, we defeated our first major nemesis: a cryptic "invalid-credential" bug that haunted our farmer logins, ultimately tracing it back to orphaned Firebase Auth users and rogue whitespace. We recreated the accounts, migrated the data, and stabilized the realm.

**Sight and Control (Phases 5-6)**
The data needed a voice. We forged the Charts & Statistics phase, wrestling with stubborn RenderFlex overflows and parsing anomalies until a beautiful 30-day `fl_chart` and responsive stats grid illuminated the screen. Immediately after, we granted Agents surgical precision in Farmer Management. Through a sleek new Farmer Detail Sheet, Agents could now isolate individual farmers in their roster, toggle custom prices, and watch the UI dynamically flip their status badges in real-time between "Global" and "Custom".

**The Messenger's Trial (Phase 7)**
To awaken devices with real-time updates, we embarked on Phase 7: Push Notifications. Denied the luxury of server-side Cloud Functions by our Firebase Spark tier, we architected a daring client-side Firebase Cloud Messaging (FCM) v1 REST dispatch. The Agent's device itself became the orchestrator.

This phase tested our resolve. We first executed a strict security ritual, aggressively ignoring our `assets/service_account.json` to prevent catastrophic credential leaks—acknowledging client-side credentials as a necessary academic compromise to be resolved in a future V2 server migration. We built the `fcm_dispatch_service.dart` to beam payloads straight to Google's API. 

But the path was fraught. We battled stubborn browsers refusing to fetch FCM tokens, tracing the silent failures back to the treacherous realm of Incognito mode. We patched `use_build_context_synchronously` warnings across three different async gaps, enforcing strict `mounted` checks and scope refactoring. We eradicated two newly spawned RenderFlex overflows in the Agent and Farmer dashboards with strategic `Expanded` wrappers. Our notification copy evolved dynamically—undergoing three revisions before the master decree established our uniform standard: `"<X> Price Updated. Price: ₹<value>/kg"`.

And then, the ultimate victory: the first live push notification successfully broke through to a farmer's browser.

**Identity and Armor (Phase 8)**
With the notifications flowing, it was time to lock down the perimeter and polish the user experience. In Phase 8, we hardened our router's authentication guards against role-route mismatch vulnerabilities and mid-OTP escape hatch exploits. We meticulously preserved our offline cache fallback mechanism to ensure Farmers could still view prices without a connection. We even extracted the router's decision logic into a pure, testable function and fortified it with comprehensive unit tests.

Simultaneously, we unified the identity management. We forged a dynamic, multi-role `ProfileSheet` accessible directly from the dashboards, giving Farmers and Agents the power to view and edit their profiles. We also polished the interface, fixing a phantom password visibility eye-toggle on the Registration tab and gracing the dashboards with dynamic, time-of-day greetings ("Good Morning", "Good Afternoon").

But Phase 8 had one final twist: the Records Saga. A silent editor-buffer conflict threatened to destroy our tracking history, overwriting `PROGRESS_TRACKER.md` with stale data. We caught the discrepancy, forced a complete disk-read verification, and established a new, unshakeable law: all tracking documents must be verified from the disk immediately after every write. The truth lives on the disk.

**The Brand Forge (Phase 8.5)**
Before moving towards deployment, the UI demanded an aesthetic overhaul to match the ambitious academic scope of Krishibhaav. Enter Phase 8.5: the Stitch Designs Restyle. We faced a crucial design decision and emerged with a hybrid teal/green aesthetic, preserving the legacy "Krishibhaav Green" for positive values while painting the core app in a modern, vibrant teal with comprehensive dark mode support. 

To execute this, we exercised strict "strip-list discipline", ruthlessly breaking the massive overhaul down into self-contained sub-phases while maintaining an absolute "zero logic changes" mandate. What was originally scoped as seven sub-phases was expertly compressed into four highly focused strikes:
- **8.5a:** Tokenized the color palettes (Light/Dark) and established the ThemeProvider.
- **8.5b:** Restyled the Farmer Home Screen and Price Chart to strictly match the Stitch renders.
- **8.5c:** Overhauled all Agent surfaces (dashboard, sheets, dialogs), and crucially, replaced the generic SnackBar with a custom, theme-aware floating Overlay toast for notifications.
- **8.5d:** Applied the new brand assets (symbol, lockup), injected the dark theme toggle into the Profile Sheet, and configured the launcher icons.

With the brand identity solidified and the UI gleaming in both light and dark, Phase 8.5 concluded smoothly.

**The Road Ahead**
Our epic approaches its final chapters:
- **Phase 9:** A Python web scraper will be unleashed into the wild, hosted on Render.com, to autonomously fetch official Kottayam RSS4 updates.
- **Phase 10:** Finally, we will forge the release-ready Android APK for deployment.

The grand academic vision of Krishibhaav is within reach!

## Current Chapter (live)
[2026-06-11] 8.5 polish: Executed final visual polish pass (app bar branding, stats grid theme-awareness, input field ghosting fixes, and dark mode login contrast).
