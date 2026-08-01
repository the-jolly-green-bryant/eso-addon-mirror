# Opulent Ordeal Navigator

Prototype ESO addon for direct action guidance in the Opulent Ordeal trial.

The goal is to tell players what to do next, not merely what happened. The addon is built around:

- Long-way orb routing between Red/Cobwebs, Orange/Drylands, and Purple/Eclipse.
- Opulent Ordeal zone detection using ESO zone ID `1565`.
- Auto-detection for Affinity color and Essence route announcements.
- Named pickup, joined-area, drop-off, and final-holder markers.
- Self-assigned color teams so the addon can guide before affinity/debuff detection.
- A role-priority solo soak assignment where damage dealers are preferred over healers, and healers over tanks.
- Cumulative orb-placement preparation: first orb color, then first plus second, then all three colors; assignments begin on the bomb event.
- Phase 2 dual-soak assignment with left/right markers, using the same role priority.
- Personal soak warnings with a larger countdown for the assigned player.
- An optional raid-lead display showing the selected solo soaker or both dual soakers with their left/right sides.
- Static full-route marker guidance with labels/text from the marker renderer.
- A small movable HUD for manual route testing.

## Changelog

### 0.1.1

- Reworked proximity route display so the full route remains visible while the active path is highlighted.
- Improved route visibility with larger high-contrast route numbers and clearer active-route lines.
- Fixed route label shadowing caused by duplicate outline layers.
- Improved teammate overhead marker refresh when color assignments are made early.
- Fixed lamp buff detection against the confirmed Radiant Lamplight effect.
- Split solo-soak soon notifications from actual solo-soak assignments to avoid duplicate soak calls.
- Improved phase 2 dual-soak trigger handling and kept personal soak markers limited to assigned players.
- Added or refined phase 2 tank markers, raid-lead soak display, movable lamp timer, and debug command gating.

## Credits

Opulent Ordeal Navigator is standalone at runtime, but it was built with help from community reference work:

- MoreMarkers by Mor: original marker sets and saved-variable exports used to seed early route coordinates.
- CrutchAlerts and Code's Combat Alerts: public Opulent Ordeal mechanic references and combat IDs used to cross-check detection logic.

This addon bundles its own marker assets and local renderer, including world labels and route numbers. If CrutchAlerts is installed, Opulent Ordeal Navigator can use its drawing API instead, but it is not required.

## Current Commands

```text
/oon settings
/oon color <red|orange|purple|none>
/oon info <on|off|toggle>
/oon raidlead <on|off|toggle>
/oon debug <on|off|toggle>
/oon assign <@name> <color>
/oon roster
/oon route <orbColor> <spawnRoom>
/oon return <join|final>
/oon soak <room>
/oon doublesoak <room>
/oon marker <markerId>
/oon markers clear
/oon profile <profileKey>
/oon profiles
/oon display <full|proximity>
/oon proximity [radius]
/oon fullroute
/oon phase <1|2>
/oon lamps
/oon lamptimer [seconds]
/oon testpath
/oon stop
```

Examples:

```text
/oon color red
/oon info off
/oon raidlead on
/oon debug on
/oon assign @PlayerName red
/oon roster
/oon route purple red
/oon route purple orange
/oon return join
/oon return final
/oon soak red
/oon doublesoak purple
/oon marker red_join
/oon profiles
/oon profile pickup_red_in_purple_hand_to_orange
/oon display proximity
/oon proximity 250
/oon display full
/oon phase 2
/oon phase 1
/oon lamps
/oon lamptimer 15
/oon markers clear
/oon testpath
/oon stop
```

## Known Limits

ESO addons cannot move a player, block for them, or fully automate mechanic execution. This addon can choose recommended players and show instructions/markers.

Soak assignment is deterministic: if every player has the same detected color roster, every client will pick the same solo soaker or left/right dual soakers. It cannot be guaranteed if an affinity effect is missed, someone changes role mid-fight, disconnects, or dies before the addon sees the change.

Immediately before every solo or dual soak assignment, the candidate roster is rebuilt from the current group state. Dead, offline, missing, or otherwise invalid group units are excluded completely; the remaining eligible players are then ordered by damage dealer, healer, and tank priority.

Color assignment has an automatic fallback:

- `/oon color red` sets your own color.
- Players without a detected affinity are treated as `none` and stay in the center.
- Affinity debuffs automatically update assignments, including for grouped players who do not run the addon.
- Detection uses effect events plus throttled scans when entering the trial or when group membership changes; it does not continuously poll buffs.
- Manual player or raid-lead assignments are not overwritten by affinity fallback detection.
- Teammate overhead assignments use small color-blind shapes: red triangle, orange circle, and purple square. `none` has no overhead marker.
- `/oon info off` hides the information window.
- `/oon info on` shows it again, and `/oon info toggle` switches the saved choice.
- `/oon assign @PlayerName red` manually assigns another player for testing or raid-lead correction.
- `/oon roster` shows the currently known assignments.

The information window remembers its screen position and visibility choice. A player with no detected affinity is shown as `none` and told to stay in the center. Manual options are `red`, `orange`, `purple`, and `none`; the older `middle` and `center` inputs remain accepted as aliases.

Assignments are session-only. They reset to `none` when entering Opulent Ordeal and are cleared when leaving the trial. The information-box preference is also available in the addon settings menu as `Show information box`.

The information window is action-first: it tells the player where to go and what to kill, carry, place, soak, or follow. Detection details, route metadata, and debug diagnostics stay in chat instead of occupying the instruction panel.

Debug mode is saved between sessions and can be changed with `/oon debug on`, `/oon debug off`, `/oon debug toggle`, or the `Enable debug commands` addon setting. When disabled, manual route, soak, marker, profile, phase, lamp, and path-testing commands are blocked. Normal player commands remain available.

`/oon settings` opens the built-in settings window without requiring LibAddonMenu2. If LibAddonMenu2 is available, the same core settings also appear in ESO's addon settings menu.

Raid lead mode is saved between sessions and can be changed with `/oon raidlead on`, `/oon raidlead off`, `/oon raidlead toggle`, or the `Raid lead soak display` addon setting. It shows the selected player for a solo soak, or both selected players with `LEFT` and `RIGHT` for a dual soak. It does not grant extra world markers: only a player assigned to a soak sees their own soak marker.

`/oon doublesoak <color>` uses the same personal marker and warning flow as the detected phase 2 mechanic. If your name is shown as `LEFT` or `RIGHT`, you receive that world marker; unassigned players and raid leads who are not soaking do not.

ESO blocks addons from sending party chat directly, but addons can read party chat. Enable color sync with `/oon sync on`; `/oon color <color>` then prepares an OON party-chat packet and the player presses Enter to send it. `/oon share [color]` can prepare the same packet manually.

Some marker coordinates are seeded from decoded source exports. They are a first pass, not final in-game truth. Validate them in the trial, then move corrected values into `data/MarkerOverrides.lua`.

## Path Guidance

The addon has two route display modes: full route and proximity route.

Full route mode keeps every marker and route line in the selected route visible in the team's color until the route is cleared or replaced. Proximity route mode also shows the whole route, but proximity advances the current target and turns the active line segment white. The current target also gets a white arrow marker above it. When the player moves within the configured radius of the highlighted marker, the highlight advances to the next marker in the route. After the final marker, it jumps back to the first marker and stays there until a new route is loaded.

Colored route lines connect consecutive visible route markers. They can be disabled with the `Show route lines` setting. Route icons are raised slightly above their coordinates for clearer separation from the line.

Route lines use the bundled `assets/shape/route_line.dds`, adapted from the CrutchAlerts floor-square texture. Route numbers are raised independently above the route icons for readability.

By default, players only see their own team's path. This is controlled by `onlyOwnTeam = true`, and uses the player's `/oon color <color>` assignment. If a player has not set a color, the addon shows no path instead of showing everyone else's route.

Default path guidance settings:

- `onlyOwnTeam = true`: filters the route to the player's assigned color.
- `showFullPath = true`: full route mode.
- `proximityRadius = 250`: distance needed to advance the current target highlight when proximity is enabled.

This should be cheap because routes stay visible and only the active marker and active route-line state change when proximity is enabled.

Key objective anchors remain visible in proximity route mode because the full route remains visible: route start points, segment start/end points, pickups, joined/kill points, drops, final holders, middle, and tank markers.

Routes are now built from smaller path chunks. That lets us show only the player's current job, then switch to a return path after handoff or final placement:

- `/oon return join`: guide your team from its joined area back to middle.
- `/oon return final`: guide your team from its final holder back to middle.
- `/oon testpath`: starts the Red joined-area to middle path for marker/render testing.
- `/oon stop`: stops the current path guidance.

Actual rendering is handled by `WorldRenderer.lua` and `MarkerRenderer.lua`. Marker textures are bundled under `assets/shape/`, and world markers are drawn directly by this addon without requiring another addon.

Routes are also cleared automatically if all online group members are detected as dead, so stale paths do not remain after a full wipe. Individual mid-combat deaths do not clear the active route.

Phase 2 boss tank markers appear only after phase 2 is detected. For testing, use `/oon phase 2` to show them and `/oon phase 1` to hide them again.

Solo-soak, dual-soak, and phase 2 tank markers render flat on the ground. Route markers, labels, and direction arrows remain camera-facing.

Marker rendering test commands:

- `/oon marker red_join`: show one marker.
- `/oon profiles`: show all imported route profile keys.
- `/oon profile <profileKey>`: start one imported route profile directly.
- `/oon auto <orbColor> <spawnRoom> [pickup|relay|final]`: pick the correct team route from the orb/spawn state. If the final argument is omitted, your assigned color decides which team route you see.
- `/oon display proximity`: switch to proximity route mode.
- `/oon display full`: switch to full route mode.
- `/oon proximity`: shortcut for proximity route mode.
- `/oon fullroute`: shortcut for full route mode.
- `/oon proximity <radius>`: set the distance needed to advance to the next target marker, for example `/oon proximity 250`.
- `/oon phase 2`: test phase 2-only boss tank markers.
- `/oon phase 1`: hide phase 2-only boss tank markers again.
- `/oon lamps`: assign yourself Purple and show the six Purple lamp markers.
- `/oon markers clear`: clear all displayed world markers.
- `/oon testpath`: start the Red joined-area to middle path.

If `LibAddonMenu-2.0` happens to be installed and loaded before this addon, settings also appear under the game's addon settings menu as `Opulent Ordeal Navigator`.

Purple players automatically get the `Lamps in purple` marker group. The current lamp icon uses `OpulentOrdealNavigator/assets/shape/lamp.dds`. Swap `OON.MARKER_TEXTURES.lamp` in `data/M0RMarkerImports.lua` if that icon is replaced later.

The local Purple/Eclipse player gets an on-screen lamp-buff countdown using the effect's actual ending time. The timer can be dragged with the mouse and remembers its position. `/oon lamptimer 15` previews the timer for 15 seconds when debug mode is enabled.

Red/Cobwebs is modeled differently because it uses grapple points. Red chunks can have `movement = "grapple"` and should be captured as paired markers:

- `grapple_start`: where the player stands before grappling.
- `grapple_target`: what the player grapples to.

For grapple chunks, the animator keeps the relevant markers visible together instead of treating them like a smooth breadcrumb trail.

## Supplying Markers

Use [data/MarkerIntake.csv](data/MarkerIntake.csv) as the handoff form. Fill in whatever coordinates or IDs you can get from source marker exports or in-game testing.

Use [data/RedGrappleMarkerIntake.csv](data/RedGrappleMarkerIntake.csv) for Red/Cobwebs grapple-specific markers.

Required columns:

- `markerId`: must match the marker IDs in `data/Routes.lua`.
- `room`: `red`, `orange`, `purple`, or `center`.
- `kind`: `pickup`, `join`, `drop`, `final`, or `middle`.
- `label`: readable name.

Coordinate columns:

- `mapX`, `mapY`, `mapZ`: fill these if you can get world/normalized map positions.
- `notes`: use this for things like "this red pickup is used when going to orange."

Once the CSV is filled, I can move those values into [data/MarkerOverrides.lua](data/MarkerOverrides.lua). That file is loaded after the base route data, so it can safely override labels/coordinates without touching the route logic.

Imported route source data is documented in:

- [data/M0RMarkersDecoded_1565.csv](data/M0RMarkersDecoded_1565.csv)
- [data/M0RMarkersAnalysis.md](data/M0RMarkersAnalysis.md)
- [data/M0RMarkerImports.lua](data/M0RMarkerImports.lua)
- [data/M0RRouteProfiles.lua](data/M0RRouteProfiles.lua)

## Reference IDs

Code's Combat Alerts U49 module confirms these zone IDs:

- `1565`: Opulent Ordeal
- `1559`: Night Market
- `1562`: Gossamer Crypt
- `1563`: Mournful Catacomb
- `1564`: Timeless Wallow

Community combat-alert references include these useful Opulent Ordeal mechanic IDs:

- Affinity effects: `256680` Cobwebs/Red, `256681` Drylands/Orange, `256682` Eclipse/Purple. The Eclipse ID is also confirmed by CrutchAlerts; OON uses the effect duration for its own timer.
- Essence summons: `256159` Web Eater/Red, `256413` Arid Varlet/Orange, `256495` Knightshade/Purple.
- Essence done/stunned: `257928` Web Eater, `257929` Arid Varlet, `257930` Knightshade.
- Bomb timer hooks: `256383`, `256579`, `256483`, and `257513`.

Important: Essence summon combat events identify the Essence color, but not the spawn room. The route trigger uses the base-game center-screen announcement text, such as `Web Eater Essence Appeared in the Drylands`, because that text includes both the Essence and the room.

Current soak-call assumptions:

- `256383` Skittering Bomb -> Red/Cobwebs soak.
- `256483` Parch Bomb -> Orange/Drylands soak.
- `256579` Sorrow Bomb -> Purple/Eclipse soak.

Orb-placement soak behavior:

- First orb placed: prepare notification for that orb's color.
- Second orb placed: prepare notification for the first and second orb colors.
- Third orb placed: prepare notification for all three colors.
- The actual bomb event selects the current eligible soaker and starts the personal marker and countdown.

Phase 2 soak behavior:

- `257513` Smoke Step switches the addon into phase 2 dual-soak assignment.
- `257681` Call to the Cobweb triggers the Red/Cobwebs dual soak.
- `257676` Call to the Drylands triggers the Orange/Drylands dual soak.
- `257686` Call to the Eclipse triggers the Purple/Eclipse dual soak.
- Phase 2 bomb/soak calls assign two players for that color: left gets the highest-priority candidate, right gets the second.
- Left/right marker IDs are already wired through `OON.SOAK_MARKERS`: `<color>_drop_north` for left and `<color>_drop_south` for right.

These IDs were cross-checked from community combat-alert addons, but the exact room mapping should be validated in live testing. All automatic soak handling uses the same priority order: DDs first, then healers, then tanks.

## Files

- `OpulentOrdealNavigator.txt`: ESO addon manifest.
- `OpulentOrdealNavigator.lua`: addon startup, HUD, slash commands, route and soak logic.
- `PathAnimator.lua`: full-route marker display and optional proximity target highlighting.
- `WorldRenderer.lua`: local world-space marker drawing adapter.
- `MarkerRenderer.lua`: route marker display adapter.
- `EventDetection.lua`: Opulent Ordeal affinity and Essence route detection.
- `data/CombatIds.lua`: zone IDs and combat reference IDs.
- `data/Routes.lua`: room, marker, path, and long-route data.
- `data/M0RMarkerImports.lua`: legacy-named first-pass route source coordinates.
- `data/M0RRouteProfiles.lua`: legacy-named imported route profiles used by `/oon profile`.
- `data/MarkerIntake.csv`: marker handoff form.
- `data/RedGrappleMarkerIntake.csv`: Red/Cobwebs grapple marker handoff form.
- `data/MarkerOverrides.lua`: marker coordinate/label overrides.
