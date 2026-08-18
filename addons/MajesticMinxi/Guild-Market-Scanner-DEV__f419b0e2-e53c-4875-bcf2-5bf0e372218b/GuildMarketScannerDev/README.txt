Guild Market Scanner DEV — v0.5.2
Author: MajesticMinxi

BUILD 0502 — STREAMING WEEKLY PREP

FIX
---
Large real-world scans (28k+ items / 93k+ guild snapshots) exposed a
low-memory failure when /gmsweekly was run.

Cause in v0.5.1:
- copied every item key into a temporary array
- retained one Lua table for every exportable price item
- duplicated those rows again into final price records/sections
- then created browser chunks
This temporarily held several copies of the weekly dataset at once.

v0.5.2:
- walks SavedVariables incrementally with next()
- never builds the giant key list
- never retains per-item price-row tables
- packs each price record immediately into ~3.9K browser chunks
- keeps only compact Top-25 opportunity candidates per guild
- finalization builds only the small opportunity section
- runs frame-safe batches and GC after preparation

UNCHANGED
---------
- scan database and saved market data
- frame-safe trader scan finalization
- price calculations
- guild opportunity scoring
- Cloudflare/D1 URL and transport format
- /gmsweekly, /gmsweeklynext, /gmsweeklypart workflow

IMPORTANT
---------
Do not run /gmsweekly on v0.5.1 again with the large stress-test database.
Install v0.5.2 first, re-enable add-ons, reload/login, then run /gmsweekly.
