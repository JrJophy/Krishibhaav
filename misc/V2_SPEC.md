# Krishibhaav V2 Specification

## Ordered Phase List

- Phase 1: Barrel Schema Design (Agent inventory and Farmer requests)
- Phase 2: Agent Stock Management UI
- Phase 3: Farmer Barrel Booking Form
  - **RETURN FORK Design Decision:**
    - **Path A "Returned Empty":** status `returned_empty`, `returnedEmptyAt`; increment `availableBarrels`; no product txn.
    - **Path B "Returned Filled":** status `returned_filled`, `returnedFilledAt`; do NOT increment `availableBarrels`; increment a new metric (`filledInventory` / `barrelsPendingShipment`); triggers weigh -> effectivePrice -> payout flow.
    - *Note:* `returnBooking()`/`decideReturn()` remain in code, to be reworked into the A/B fork in Phase 3. Do not delete them.
- Phase 4: Real-Time State Sync
- Phase 5: Dynamic Price Chart Resizing
- Phase 6: Live Open-Market Data Verification
- Phase 7: Comprehensive Integration Testing
- Phase 8: Service Worker and UI Polish
- Phase 9: Bug Resolution and Edge Case Squashing
- Phase 10: Version Two Release Production Build
