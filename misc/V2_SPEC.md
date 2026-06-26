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

