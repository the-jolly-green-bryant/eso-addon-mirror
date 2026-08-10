# HousingForge 1.4

HousingForge is a console-first ESO housing addon for recording, restoring, sharing, and precisely editing furnishing layouts with a gamepad.

## Shipped workflow

1. Record an owned house or copy a visited house into an account-wide local layout.
2. Preview which required furnishings are available before applying anything.
3. Apply owned matches, clean then apply, or place without cleaning through a paced, pausable request queue.
4. Automatically record a bounded recovery snapshot before destructive cleanup.
5. Select placed furnishings and align, distribute, mirror, move, or rotate them as a group with one-level undo.
6. Save named per-house furnishing groups for later precision work.
7. Export HFv2 data through a user-configured HTTP(S) endpoint, or import validated HFv2 data as a collision-safe local layout.

The dashboard, main-menu entry, precision tools, mini map, calibration workflow, and apply-queue pause/resume/cancel/retry controls are gamepad-accessible. Slash commands remain available for exact numeric operations and naming.

## Runtime layout

The two manifests are intentionally identical because the console uploader requires both `HousingForge.addon` and `HousingForge.txt`.

- `Constants.lua` — namespace, defaults, runtime state, helpers
- `LayoutRecorder.lua` — full-house snapshots, parent/state/path metadata, recovery retention
- `LayoutApplier.lua` — ownership matching, cleanup/apply queue, result tracking, safety checks
- `BlueprintTools.lua` — selection, named groups, relative transforms, paced operations, undo
- `MissingItemMarkers.lua` — nearest-first 3D missing-item markers with distance fade
- `MiniMap.lua` — furnishing scan and filtered housing overlay
- `LayoutExport.lua` — HFv1/HFv2 serialization, URL queue, endpoint validation, HFv2 import
- `Calibration.lua` — optional room-marker calibration
- `OwnedFurnishingsExport.lua` — furnishing inventory export
- `MarketplaceCatalog.lua` — bundled static console catalog
- `MainMenu.lua`, `HousingForgeUI.lua`, `HousingForgeUI.xml` — controller navigation and dashboard

## Safety invariants

- Never apply a layout whose nonzero `houseId` differs from the current house.
- Never clean a house the player does not own.
- Record a complete transform/state recovery layout before cleanup when cleanup safety is enabled.
- Block safety-enabled cleanup when linked furnishings or paths are present, because 1.4 records but does not yet restore those relationships.
- Rebuild the owned furnishing index after cleanup before placement starts.
- Pace all housing requests and expose pause, resume, cancel, and retry controls.
- Capture furnishing transforms before a precision operation and allow one undo.
- Keep export disabled until the player configures a valid `http://` or `https://` endpoint.
- Treat imported data as untrusted: only HFv2 is accepted, values are validated, and imported layouts receive a new local ID.

## Snapshot model

Layout snapshots use `snapshotVersion = 2` and `coordinateSpace = "world"`. Each furnishing stores its identity hints, world position, orientation, object state, stable string form of the source furniture ID, parent source ID, and path metadata when available. Older saved layouts remain readable; absent v2 fields are optional. Version 1.4 restores transforms and object states, but not parent links or furniture paths; safety-enabled cleanup blocks when either is detected.

Precision groups are stored account-wide but scoped by house ID. Their furnishing IDs only identify objects already placed in that same house; they are not portable inventory IDs. Layout exports remain the portable sharing format.

## Console constraints

ESO addons cannot silently contact arbitrary services or write to the system clipboard. Export therefore uses `RequestOpenUnsafeURL` and requires user approval for each URL. A console marketplace must be shipped as static Lua data in an addon update; it cannot live-download layouts into SavedVariables.

## Release verification

Before uploading a release:

1. Run the dual-manifest validator and parse every Lua/XML file.
2. Inspect the archive for one top-level `HousingForge/` folder and both manifests.
3. In an owned test house, verify record, preview, clean safety snapshot, clean-then-apply, pause/resume/cancel, state restoration, and retry behavior.
4. Verify precision selection, every transform, undo, named group save/load, and leaving/re-entering the house.
5. Verify marker disable/re-enable, endpoint rejection, HFv2 import, and an export round-trip against the configured server.
6. Upload Xbox and PlayStation packages only after the in-game pass succeeds.
