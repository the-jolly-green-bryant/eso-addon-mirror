BMG ADVENTURES v0.0.01-dev2.3
A BMG Addon
Created and maintained by @BMGXSANCHO

Purpose
-------
This is the first engine-validation build for the BMG Adventures progression system.
It intentionally excludes QR transport, BMG Connect, Discord, group broadcasting,
reticle profiles, Above Me renderer changes, and production seasonal content.

What this build proves
----------------------
ESO native events -> normalized activity -> indexed challenge evaluation ->
transaction -> XP/score -> unlock -> persistent account profile.

Dependencies
------------
LibHarvensAddonSettings
On the console uploader, use the console package dependency appropriate for that library.

Development warnings
--------------------
Developer simulated events are tagged DEVELOPMENT and are not intended to become
leaderboard-eligible evidence later.

There are no RegisterForUpdate loops in this build.


DEV2 FOCUS
- Automatic one-time ESO achievement catalog scan.
- Language-independent storage of every completed native achievement ID.
- Initial English-name discovery mappings for six high-prestige trial accomplishments.
- Generic Trial/Dungeon native achievement milestone import for English category labels.
- Dungeon Delver simulation coverage.
- Diagnostic-only Activity Finder dungeon and World Event event capture.
- No QR, Discord, BMG Connect, LGB, or recurring update loops.


v0.0.01-dev2.4: Returned Challenge Browser and Developer Tools to LibHarvensAddonSettings-owned controls; removed custom gamepad scenes. Added CollectionEngine beta and Native Activity Validation summary.
