Guild Market Scanner DEV — v0.2.2
Author: MajesticMinxi

BATCHED PRICE DATA EXPORT

Fixes the console CPU-time error from v0.2.1.

What changed
------------
- /gmsexport no longer processes the entire market database in one frame.
- Export is built in small batches across many frames.
- Progress is printed periodically in chat.
- Existing scanner database and Guild Scan Registry are preserved.
- /gmscancelxport cancels an in-progress export.
- /gmsclearexport clears the saved export after it has been retrieved.

Test
----
1. Update to v0.2.2 and reload UI.
2. Do NOT rescan the trader unless you want to. The completed scan from v0.2.1 is already in the database.
3. Run /gmsexport.
4. Let it finish; do not reload while EXPORT PROGRESS is running.
5. Send the final EXPORT READY line and the memory line.
6. Then /reloadui once to persist the generated export.
