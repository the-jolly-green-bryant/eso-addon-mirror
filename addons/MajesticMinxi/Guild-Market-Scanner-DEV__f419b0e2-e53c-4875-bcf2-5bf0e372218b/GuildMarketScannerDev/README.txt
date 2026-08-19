Guild Market Scanner DEV — v0.7.3
Author: MajesticMinxi

BUILD 0703 — CONSOLE-SAFE SYNC URL SIZE

WHY
---
v0.7.2 correctly generated real Market Sync data, but a ~13.2K browser URL
did not open on ESO/PlayStation.

FIX
---
- syncChunkTargetBytes reduced from 13,500 to 6,000
- no other scanner or sync logic changed

UNCHANGED
---------
- incremental guild-only Market Sync
- pending guild tracking
- v0.7.2 current-snapshot timestamp fix
- compact v10 scanner storage
- trusted / observed price calculations
- Top-25 guild opportunities
- unified Market Sync pages
- /gmssyncretry and /gmssyncconfirm
- Worker v0.9 protocol
- D1 selective merge behavior

TEST
----
Keep the same 7 pending guilds.
Start /gmssync and generate Page 1 only.
Confirm the PlayStation browser actually opens and the Worker reports
non-zero Price updates.
