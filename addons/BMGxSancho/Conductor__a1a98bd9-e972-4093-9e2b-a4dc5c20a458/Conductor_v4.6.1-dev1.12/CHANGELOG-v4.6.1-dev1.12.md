# Conductor v4.6.1-dev1.12

## Performance stabilization

- Coalesced group roster events into one delayed scan.
- Separated lightweight roster refreshes from expensive local capability scans.
- Changed the periodic safety scan from 15 seconds to 30 seconds and made it roster-only.
- Consolidated zone activation into one settled post-load refresh.
- Removed redundant capability-profile scheduling from Network group and activation handlers.
- Kept discovery independent and active while grouped.
- Reduced universal Buffs & Debuffs countdown refresh from 500 ms to 1,000 ms while preserving event-driven gain/fade updates.
- Avoided effect-cache expiration scans when the cache is empty.
- Prevented Combat Context actor rescans while disabled or fully idle and ungrouped.
- Preserved Timeline, encounter profiles, sharing, saved teams, assignments, and UI behavior.
