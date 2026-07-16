# Krishibhaav V2 Specification

## Ordered Phase List

- Phase 1: Barrel Schema Design (Agent inventory and Farmer requests)
- Phase 2: Agent Stock Management UI
- Phase 3: Farmer Barrel Booking Form
  - **RETURN FORK Design Decision:**
    - **Path A "Returned Empty":** status `returned_empty`, `returnedEmptyAt`; increment `availableBarrels`; no product txn.
    - **Path B "Returned Filled":** status `returned_filled`, `returnedFilledAt`; do NOT increment `availableBarrels`; increment a new metric (`filledInventory` / `barrelsPendingShipment`); triggers weigh -> effectivePrice -> payout flow.
    - *Note:* `returnBooking()`/`decideReturn()` remain in code, to be reworked into the A/B fork in Phase 3. Do not delete them.
  - **Implementation Notes:**
    - `filledBarrels` is inert. It is NOT incremented in Phase 3; V3 payout ledger wires this.
    - `decideReturnEmpty` and `decideReturnFilled` have been added but owe Phase 7 tests.
- Phase 4: Real-Time State Sync
- Phase 5: Dynamic Price Chart Resizing
- Phase 6: Live Open-Market Data Verification
- Phase 7: Comprehensive Integration Testing
- Phase 8: Service Worker and UI Polish
- Phase 9: Bug Resolution and Edge Case Squashing
- Phase 10: Version Two Release Production Build

**Notes:**
- Under Phase 5, chart collapse/minimise was pulled forward. Phase 5 only owes remaining resize work.
- Layout reorder was done early (pulled from Phase 8 polish territory).

## V2 Register
- V2: normalize status .trim() in BarrelBookingModel.fromMap — DONE (Part A follow-up)

## V2 Post-Audit / Cleanup Notes
- **V2 Cleanup (Optional):** Migrate `FarmerBarrelBookingCard` and `BarrelBookingCard` to consume the new `bookingStatusLabel` helper to eliminate the two inline status switches, fixing the agent card's raw rendering for `returned_empty` and missing split-status cases.
- **V2 Test Debt:** `completedAt` getter in `BarrelBookingModel` has no direct unit test (Timestamp/Firebase boundary). Cover it indirectly via a V2 widget/integration test asserting that `BookingHistoryRow` shows the correct parsed "Completed: <date>" label.

## V3 Seeds

### Custom Price Validation Range + Multi-Grade Rate Cards
- **Status:** IDEA ONLY — not approved for implementation.
- Constrain per-farmer custom prices to within ±₹2/kg of the current Open Market price for that grade.
- Extend the existing Latex-only custom price to also support Scrap rubber.
- Open questions: Scrap reference price source (manual agent entry vs. scraper vs. formula), whether `globalAgentPriceScrap` is needed, server-side enforcement approach (Cloud Function vs. Rules `get()`), farmer UI layout for multi-grade display.
- Scraper currently only handles RSS4/RSS5 from rubberboard.org.in — no Scrap feed exists yet.

### WhatsApp Market Data Panel
- **Status:** IDEA ONLY — not approved for implementation.
- **Concept:** Replace (or supplement) the current `fl_chart`-based price chart with a direct data panel showing RSS4, RSS5, Latex, Scrap, and "Lot" values parsed from the pasted WhatsApp market message.
- **Existing infrastructure:** `MarketMessageParser` (`lib/core/market_message_parser.dart`) already parses RSS4/RSS5 from the WhatsApp message format. `PasteMarketMessageSheet` (`lib/widgets/paste_market_message_sheet.dart`) provides the paste UI. Tests in `test/market_message_parser_test.dart`.
- **What would need to extend:** Parser to also extract Scrap (multiple grades: 80%/78%/75%/70%) and Latex (range value, e.g. "258 to 260") from the same raw message format.
- **Open questions:**
  1. Does this fully replace the `fl_chart` historical trend view, or sit alongside it as a "current snapshot" panel while the chart still shows history? Removing `fl_chart` entirely is a real regression risk since farmers currently rely on the historical trend view — confirm intent before removal.
  2. Scrap has 4 sub-grades (80/78/75/70%) — does the UI show all four, or does the agent pick a primary one?
  3. "Lot" needs disambiguation — DRYLOT and KOCHILOT are distinct fields in the raw message, not a single "Lot" value.
  4. Overlaps with the Scrap open questions under the Custom Price ±2 seed above (Scrap reference price source) — worth resolving both together.


