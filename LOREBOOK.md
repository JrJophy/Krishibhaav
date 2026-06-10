# The Krishibhaav Lorebook (The Story So Far)

**The Awakening (Phases 1-2)**
Our journey began with a clear mission: to build *Krishibhaav*, an ambitious MCA academic project designed to bring real-time Rubber price intelligence to the farmers of Kerala. We laid down the scaffolding—setting up Flutter and Firebase—and established our dual-role hierarchy (Agents and Farmers). Constrained by the free Firebase Spark tier, we couldn't rely on expensive SMS providers. Instead, we engineered an ingenious simulated OTP authentication system, complete with a unique, deterministic temporary password system tailored for farmers. 

**The Dual Worlds (Phases 3-4)**
With the gates open, we built the Agent Core. Agents gained a powerful, centralized dashboard to dictate Open Market, Company, and Global Agent prices, and began assembling their roster of farmers. Then, the Farmers awoke. We constructed their real-time dashboard, binding the flow of prices to strict market hours (Mon-Sat, 9AM-5PM). Along the way, we defeated our first major nemesis: a cryptic "invalid-credential" bug that haunted our farmer logins, ultimately tracing it back to orphaned Firebase Auth users and rogue whitespace. We recreated the accounts, migrated the data, and stabilized the realm.

**Sight and Control (Phases 5-6)**
The data needed a voice. We forged the Charts & Statistics phase, wrestling with stubborn RenderFlex overflows and parsing anomalies until a beautiful 30-day `fl_chart` and responsive stats grid illuminated the screen. Immediately after, we granted Agents surgical precision in Farmer Management. Through a sleek new Farmer Detail Sheet, Agents could now isolate individual farmers in their roster, toggle custom prices, and watch the UI dynamically flip their status badges in real-time between "Global" and "Custom".

**The Road Ahead (Phases 7-10)**
As we stand victorious at the end of Phase 6, the skies are preparing to thunder. We are now embarking on **Phase 7: Push Notifications**. Because our Spark plan forbids server-side Cloud Functions, we must architect a cunning client-side FCM REST dispatch. The Agent's device itself will act as the master server, silently beaming push notifications directly to the farmers' devices the moment rubber prices shift. 

Following this triumph, we will:
- Polish the user profiles and UI components to perfection (Phase 8).
- Unleash a Python web scraper into the wild, hosted on Render.com, to autonomously fetch official Kottayam RSS4 updates (Phase 9).
- Finally, forge the release-ready Android APK for deployment (Phase 10).

The grand academic vision of Krishibhaav is within reach!
