# Krishibhaav — Bug & Defect Register
Last updated: 2026-06-12 (V1 complete, V1.1 polish). Severity: H/M/L/C(osmetic). Status: OPEN / BY-DESIGN / FIXED / WAIVED.

| ID | Sev | Status | Area | Description | Fix target |
|----|-----|--------|------|-------------|-----------|
| B01 | H | OPEN | Security | Firestore in TEST MODE — rules may carry built-in expiry date; app dies when it passes. Verify expiry in console. | V2 #1 (URGENT survival check now) |
| B02 | H | OPEN | Security | FCM dispatched client-side using bundled service-account JSON (gitignored but ships in app assets) | V2 #2 |
| B03 | M | OPEN | Auth | Simulated OTP (password = mobile-derived); not real SMS verification | V2 #3 |
| B04 | M | OPEN | Ops | GitHub Actions cron auto-disables after 60 days repo inactivity — scraper will silently stop (~mid-Aug 2026) | Keep-alive commit/workflow |
| B05 | M | OPEN | UI/Web | Input label/hint ghosting — hintText in price_edit_dialog never floats (diagnosis on file, 2-line fix unapplied by V1 ruling) | V2 #13 |
| B06 | M | OPEN | UI/Web | Login TextFields: select-all/clear unreliable on web (cosmetic cousin of B05) | V2 #14 |
| B07 | L | BY-DESIGN | Notifications | Foreground push shows in-app toast only, never system tray (no flutter_local_notifications) | V2 #15 |
| B08 | L | OPEN | Notifications | No default notification channel meta-data in AndroidManifest (Firebase fallback channel in use) | V2 #16 |
| B09 | C | OPEN | UI | Farmer chart section title still reads "Agent Price Trend" (stale vs Phase 9 farmer-effective spec) | V2 #19 |
| B10 | C | OPEN | UI | Chart Y-axis prints duplicate labels (118/118, 110/110) | V2 #19 |
| B11 | C | OPEN | Data | Phase 9 test-era history docs (112–118→110) remain in Rajan's history; visible dip in chart until aged out or deleted | V2 planning |
| B12 | C | OPEN | Web | apple-mobile-web-app-title lowercase "krishibhaav" (iOS home-screen label only) | V3 #14 |
| B13 | L | OPEN | Build | Release APK signed with DEBUG keystore — fine for sideload, blocks Play Store | V2 #18 |
| B14 | L | OPEN | Code | 16 debugPrint calls in lib/ incl. FCM token log — dev-log only, wrap in kDebugMode | V2 #17 |
| B15 | L | OPEN | Perf | FCM token fan-out is N+1 Firestore queries per notification trigger | V2 planning |

## Process lessons (recurring failure modes)
- Phantom fixes: Antigravity edit-review buffers must be ACCEPTED before any gate/build/commit; verify with findstr; a "1 file changed" commit that should contain more is the tell.
- Stale web UI after deploy: Flutter service worker serves cached app; verify server-truth in Incognito, then DevTools > Application > Service workers > Update on reload + Clear site data.
- Records files must never be left open in an editor (buffer-conflict staleness); autopush.bat reads LOGBOOK.md by relative path — moving records breaks commit messages.
- Gradle NDK auto-download can corrupt mid-extract (folder without source.properties); Gradle won't self-heal — kill java daemon, rmdir + verify with dir, reinstall via sdkmanager (JAVA_HOME = Android Studio jbr).
- "Notification not working" reports must record app state (foreground vs background vs killed) — delivery behavior differs by design.
