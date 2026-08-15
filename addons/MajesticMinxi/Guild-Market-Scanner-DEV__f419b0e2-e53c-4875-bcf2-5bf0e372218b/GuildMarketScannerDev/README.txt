Guild Market Scanner DEV — v0.2.4 RECOVERY
Author: MajesticMinxi

RECOVERY-ONLY BUILD

Purpose
-------
GMS reached the console add-on memory ceiling at login. This build is NOT
for scanning. It exists only to recover the existing market database safely.

On startup it:
1. Loads the existing GMS SavedVariables.
2. Immediately deletes any lingering saved export cache.
3. Clears transient exporter/scanner references.
4. Runs garbage collection twice.
5. Counts the existing flat permanent database.
6. Reports memory.
7. Does NOT register trader events or enable scanning/exporting.

TEST
----
1. Keep normal addons enabled.
2. Install/update GMS to v0.2.4.
3. At Character Select, enable GMS.
4. Log in.
5. If ESO stays loaded, open chat and photograph the [GMS] RECOVERY lines.
6. If the message says the export was removed, run /reloadui ONCE so that
   deletion is committed to SavedVariables.
7. After reload, photograph the recovery memory lines again.

DO NOT:
- scan traders
- run /gmsexport
- uninstall GMS
- delete ESO saved data

If enabling this recovery build still causes ESO to disable all addons before
the recovery messages can appear, leave GMS disabled. That would indicate the
permanent SavedVariables themselves are already too expensive to load alongside
the user's normal addon set, and the next step must be a storage migration
strategy rather than an export fix.
