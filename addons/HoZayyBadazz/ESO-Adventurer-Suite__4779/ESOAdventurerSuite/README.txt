ESO ADVENTURER SUITE
Version 0.29.143
Author: HoZayyBadazz
Status: Public Beta

AI DEVELOPMENT DISCLOSURE
ESO Adventurer Suite uses AI-assisted code generation and review. ESO Adventurer Suite is responsible for testing, publishing, maintaining, and supporting the addon.

OVERVIEW
ESO Adventurer Suite is an all-in-one Elder Scrolls Online dashboard and utility addon built around the Tamriel Codex. It includes questing, travel, finders, combat statistics, HUD tools, minimap features, gear/build tools, companion tools, notes, checkpoints, Golden Pursuits integration, and configurable utility overlays.

CREATOR, SUPPORT & COMMUNITY
Creator: HoZayyBadazz
In Game User ID: @ShadowOps187
Discord Community: The Legends Den
Discord Invite: discord.gg/Tj72TAEqat

Optional gifts may be sent as in-game gold or Crown Store gifts. ESO Adventurer Suite and community support are free. No feature, update, access, Discord membership, or support is sold or required.

REQUIRED LIBRARIES
- LibAddonMenu-2.0 >= 43
- LibMapData >= 101
- LibGPS >= 73
- LibMapPins-1.0 >= 47

Install required libraries separately through Minion/ESOUI.

RELEASE NOTES - 0.29.143

- Optimized Teleporter opening so expanding the panel reuses the last destination list immediately instead of rebuilding travel data on the same input frame.
- Coalesced opening into at most one deferred destination refresh after the panel is already visible.
- Added a one-minute owned-house cache and background guild-cache prewarm to remove repeated collection/guild work from normal opens.

- Removed the VIEW prefix from every Map Teleporter destination mode. The active button now reads ALL DESTINATIONS, ZONES, CURRENT MAP, WAYSHRINES, and so on.
- Shortened the two longest destination labels and added adaptive font sizing so every destination mode remains inside the top button.

- Removed all Teleporter control over ESO map completion / zone-guide UI. The stock map completion interface is now left entirely alone.
- Reorganized the Teleporter top toolbar: View is wider, Favorites and Tools are aligned beside it, and all three buttons use consistent spacing and height.

- World Map mode now docks the Teleporter completely OUTSIDE the parchment: the Teleporter right edge attaches to the map left edge.
- Disabled screen clamping for the map-docked Teleporter so ESO cannot pull the outside sidebar back over the map.
- PLAYER and ZONE search fields are recalculated from the final panel width after docking, preventing the ZONE box from running off the right edge.


- In Open with World Map mode, the Teleporter now docks flush to the left side of the World Map instead of floating over the middle of it.
- The collapsed Teleporter drawer is now tucked into the map's top-left corner.

- Core.lua syntax correction: removed an accidental editor/Python expression from the version line that prevented the addon from loading.
- Revalidated all Lua files in the packaged addon for syntax before release.

- Rebuilt outside-map Teleporter interaction on ESO's native registered top-level UI path so closing reliably returns movement/camera control and the hotkey can reopen it.
- Same Teleporter hotkey now uses session state only: press once to open, press again to close.
- Click-outside now closes on the completed global mouse-up event, then returns directly to gameplay.
- Open with World Map is explicitly map-attached: the drawer anchors to the stable ZO_WorldMap window, never the zoom/pan canvas, so it follows the map without zooming with it.

- Teleporter hotkey close now fully releases ESO camera/UI input before returning to gameplay, preventing movement/camera controls from remaining stuck after the panel closes.
- Teleporter now uses ESO's camera UI-mode API with the scene manager only as a fallback, matching the Suite's proven main interaction-mode behavior.

- Retired the permanent TELEPORTER > gameplay drawer. Outside the World Map, Hotkey / Outside Map now stays completely hidden until the assigned Teleporter hotkey is pressed.
- Fixed the Teleporter hotkey as a true open/close toggle even after ESO changes UI/window state.
- Added click-outside-to-close for the outside-map Teleporter and reliable return to gameplay/UI mode.
- Repair: <gold> now mirrors the actual rendered HUD fade alpha used by the Suite FPS/Latency overlay, with ESO action-bar alpha as a fallback, so it cannot remain visible after the rest of the HUD fades.

- Repair: <gold> and the collapsed Teleporter drawer now use the exact same native HUD-fade ownership pattern as the working FPS overlay during normal gameplay.
- Removed normal-gameplay top-level promotion/BringWindowToTop behavior that could keep those two overlays visible after the rest of the HUD faded.
- Teleporter remains raised and fully interactive only on the World Map, in HUD Layout Mode, or while explicitly opened by its hotkey.

- Added an Open / Close Map Teleporter keybinding for Always / HUD Overlay mode. The hotkey opens the Teleporter outside the World Map, puts you in UI mode so you can interact with it, and pressing the same key again closes it back to gameplay.
- Clicking the Teleporter drawer while it is open from the HUD hotkey also closes it back to gameplay outside the map.
- Folded Teleporter now shows only the TELEPORTER drawer tab; destination names and expanded controls can no longer leak into the closed 136x42 overlay.
- Always / HUD Overlay reliably appears during normal gameplay outside the World Map and returns after leaving menus/maps while still following ESO HUD-fade behavior.
- Teleporter options now appear in a dedicated Map Teleporter submenu in Suite Settings.
- HUD Layout Mode positioning and native ESC/Map/R/zoom behavior remain unchanged.

RELEASE NOTES - 0.29.130
- Added Teleporter visibility modes: Open with World Map and Always / HUD Overlay.
- Always mode makes the collapsible Teleporter drawer usable outside the map and attaches it to ESO's native HUD-fade behavior so it disappears/returns with normal gameplay overlays.
- The Teleporter remains available on the World Map in either visibility mode without capturing ESC, Map, R/player-position, zoom, or other native map keys.
- Added Map Teleporter support to the Suite HUD Layout Mode with a dedicated drag strip and saved screen position.
- Reset Layout now restores the Teleporter position along with the other Suite HUD overlays.
- Preserved the 0.29.129 zoom isolation: map zoom/pan never scales or shifts the Teleporter.

RELEASE NOTES - 0.29.129
- Map Teleporter zoom isolation: the drawer stays fixed while the World Map zooms or pans.
- Removed Teleporter mouse-wheel page switching so map zoom gestures never alter the destination list.
- Fixed live health depletion and regeneration for player, companion, group, and raid unit frames.
- Health bars now use ESO's filtered live health events and update from the event values on damage and healing.
- Expanded group/raid live-health handling to the complete roster and group companion unit tags without adding high-frequency polling.

RELEASE NOTES - 0.29.126
- Ability overlays now use the player's real Controls > Keybindings assignments for every active-bar ability and Ultimate. A player who binds Ultimate to a key other than U sees that key on the Suite overlay automatically.
- Binding text is cached for FPS safety and refreshed only when ESO reports a binding/input-mode change.
- Removed Repair: <gold> forced-alpha refreshes so it fades/hides through the same ESO HUD fragment behavior already working correctly for Suite FPS / Latency.

RELEASE NOTES - 0.29.125
- Fixed Repair: <gold> and Suite FPS / Latency not appearing after the 0.29.124 HUD-idle change. Both now use ESO's native ZO_HUDFadeSceneFragment instead of inferring HUD visibility from action-bar alpha.
- Removed the repair overlay's HUD visibility poll; idle fading is now owned by ESO's HUD fragment system.
- Performance overlay continues its lightweight 500ms value refresh and only suppresses ESO's stock meter after the Suite replacement control exists.
- Moved all packaged Suite DDS art to a versioned Art029125 resource path to bypass stale ESO shader-cache entries that can make updated addon images render blank/transparent.
- Added proactive preload calls for the main Suite UI textures where ESO exposes PreloadTexture.

RELEASE NOTES - 0.29.124
- Repair: <gold> in Always mode now follows ESO's actual automatic gameplay-HUD visibility, with no separate Suite idle timer.
- Added a Suite FPS / Latency overlay that follows the same gameplay-HUD visibility, is movable in HUD Layout Mode, and has an adjustable scale.
- Added an option to suppress ESO's built-in FPS / latency display while the Suite replacement is enabled.
- Performance values refresh at a lightweight 500 ms cadence; repair visibility checks do not rescan equipped gear.

RELEASE NOTES - 0.29.123
- Fixed Quest Finder hover LabelControlSetColorLua spam: mouse exit now restores only the background because hover never changes row text colors.
- Hardened dynamic modern-UI label colors so invalid/stale values are converted to safe numeric RGBA channels before ESO receives them.
- /easscan now reports errors from the current UI session instead of presenting historical saved errors as if they are still active. Older Bug Catcher history is retained separately until cleared.

RELEASE NOTES - 0.29.122
- Full FPS/performance pass: removed Quest Finder hover rebuilds and reduced unnecessary high-frequency map/marker/UI polling.

RELEASE NOTES - 0.29.121
- Removed the separate 5-second idle timeout from Repair: <gold>.
- The compact repair HUD now follows normal Suite/ESO HUD suppression only; standing still by itself will not hide it.

RELEASE NOTES - 0.29.120
- Repair: <gold> now hides with idle gameplay HUD state and returns on movement/combat.
- Game Combat compact pages now keep recorded text readable at minimum size instead of revealing rows only after enlargement.
- Added a dedicated TGT page and structured Fight Snapshot label/value rows.

RELEASE NOTES - 0.29.119
- Redesigned Game Combat as a compact combat analyzer instead of an oversized dashboard.
- Reduced report constraints from 1040x720 to 760x500 and changed the default/reset size to 860x560.
- Existing installs receive the compact size once automatically; the report remains freely resizable afterward.
- Added an always-visible KPI strip for Player DPS, All DPS, HPS, Incoming DPS, and fight time.
- Slimmed the header and left navigation rail, tightened panel chrome/padding, and changed section headings to a cleaner left-aligned style.
- Overview now focuses on Fight Snapshot + Top Damage + Damage Share instead of repeating build/resource cards.
- Healing and Incoming pages now show page-specific summary data rather than the generic damage summary.
- Side navigation buttons retain short labels at small size and show their full page name on hover.
- Preserved single-line ellipsis and responsive table columns so the new 760x500 minimum does not reintroduce text overlap.

RELEASE NOTES - 0.29.118
- Added a Suite-native left-side navigation rail to Game Combat with Overview, Damage, Healing, Incoming, Group, Buffs, Resources, Graph, and Build pages.
- The active page uses the report space instead of forcing all combat tables into one small layout.
- Damage shows ability and target damage; Healing and Incoming filter to their own sources; Group focuses on players, companions, pets, and observed contribution; Resources and Build separate resource use from effective PEN/PWR/SR/PR/CC/CD.
- Graph shows recorded damage distribution by ability.
- Removed the Interact with Suite, Group Finder Next Category, and Group Finder Toggle Normal/Veteran public keybindings.
- `Repair: <gold>` no longer appears over the ESO pause/game menu.

RELEASE NOTES - 0.29.117
- Fixed Game Mode Combat Report text/column collisions at the minimum 1040x720 size and at larger ESO UI scales.
- Report labels now stay inside their cells with single-line ellipsis instead of wrapping or drawing into neighboring rows/columns.
- Added a compact minimum-width header so mode/zone text no longer collides with the centered report title.
- Rebalanced the minimum bottom layout to give Ability Breakdown more horizontal space while preserving Group / Companion / Pet / Target data.
- Effective Combat Stats section headings now use the full stats row instead of sharing width with an empty value cell.

RELEASE NOTES - 0.29.116
- Game Combat now identifies local companions with ESO's COMBAT_UNIT_TYPE_PLAYER_COMPANION and keeps combat pets/summons separate from the player.
- Personal DPS/HPS is player-only; pets and companions no longer inflate the player's DPS. The report also exposes a combined You + Pets + Companion DPS total.
- Added actor rows for companions, pets, and observed group summons, with owner attribution when ESO exposes enough information to do so.
- Group contributors roll owned companion/pet contribution into the correct player when ownership is known; unknown group summons are never guessed onto a teammate.
- Live Combat HUD shows the combined ALL DPS in its status line whenever your pet or companion contributes while its main DPS value remains player-only.
- Strengthened Modern UI image rendering with resident custom DDS textures, full-size ESO-native class/companion fallbacks, and a native shell fallback behind custom artwork.
- Custom DDS files remain packaged in the canonical ESOAdventurerSuite/Art path. A full ESO client restart is still required when the game has not yet loaded newly replaced texture files.

RELEASE NOTES - 0.29.115
- Linked the Combat page, Live Combat Stats, and Game Mode Combat Report to one shared fight recorder.
- Live Combat Stats keeps PEN / PWR / SR / PR / CC / CD and Game Combat now records fight-weighted effective values from that exact same source.
- Added a FULL COMBAT REPORT action directly from the Combat page.
- Added Magicka and Stamina use/regeneration tracking with per-second fight values.
- Added buff/debuff uptime and max-stack tracking for the player during each fight.
- Added incoming damage source and ability breakdowns to the detailed combat report.
- Kept combat collection lightweight with native ESO event filters, cached live-stat sampling, and heavier report analysis outside the event path.

RELEASE NOTES - 0.29.114
- Fixed the World Map opening/closing hitch caused by the built-in teleporter.
- Guild travel destinations are now gathered in small frame-sliced batches instead of scanning entire guild rosters on the map-open frame.
- Added short-lived destination caching and coalesced duplicate World Map scene refreshes.
- Deferred the first teleporter refresh until the map finishes opening and reduced repeated full refresh frequency.
- Optimized the map-close hotkey lookup to avoid repeatedly walking ESO action layers.

RELEASE NOTES - 0.29.40
- Fixed Game Mode Combat Report target/group row crash in LabelControlSetColorLua.
- Target rows and group/contributor rows now unpack their RGBA palette before calling SetColor, so Clannfear, enemies, group members, and other report entries render safely.
- No combat-report data collection or minimap/Antiquity behavior was changed by this hotfix.

RELEASE NOTES - 0.29.39
- Rebuilt the Augur helper as a scan optimizer instead of a fake exact-location predictor. Only an ESO Green result is labeled as guaranteed DIG HERE.
- Added more ESO digging-UI fallbacks plus faster live tile caching to capture the Augur row/column before the mouse leaves the board.
- Recommended scans are chosen only from cells still considered possible by the helper model, maximizing the chance of hitting Green while narrowing the search.
- The opening scan is now recommended automatically, and all Yellow / Orange / Red instructions are clearly labeled BEST NEXT AUGUR rather than a shovel location.

RELEASE NOTES - 0.29.36
- Fixed the exact Antiquity dig-site shovel marker texture by using ESO's built-in Heavy Shovel icon directly, preventing the red question-mark placeholder.
- Fixed the Game Mode Combat Report duplicate-control crash when opening it from its hotkey.
- Report UI controls now use a collision-safe root and anonymous children, preventing stale UI controls from breaking the overlay after an update/re-initialization.
- Failed window creation is now handled safely instead of producing a second nil-value error.

RELEASE NOTES - 0.29.33
- The Suite minimap continues to change automatically as you travel between zones, cities, houses, delves, interiors, and other local maps. It is not anchored to the parent zone.
- When the current mapId changes, old static pins are hidden immediately and only the new current area's data is rebuilt.
- Added guarded live native-pin snapshots after map transitions so current-area icons can refresh without carrying positions from the previous map.
- Live snapshots are only stored when ESO confirms the active map matches the player's location and the mapId matches the minimap.

RELEASE NOTES - 0.29.32
- The 3D Antiquity shovel no longer marks the approximate center of the search area. It now appears only when ESO exposes the exact excavation mound as the current Excavate / Dig Site target.
- ESO's normal Antiquarian's Eye blue mist remains untouched and continues to guide you toward the mound.
- Fixed the Excavation Augur helper losing its selected tile when you move the mouse from the grid to the Green / Yellow / Orange / Red buttons.
- The Suite now caches the last valid Augur grid cell and confirms the captured row/column after a successful probe.
- If ESO does not expose a cell coordinate, Green still resolves immediately; Yellow / Orange / Red open a small 10x10 Suite grid so you can identify the tile manually and continue the solver.
- World-map and Suite-minimap Antiquity search-area pins remain available.

RELEASE NOTES - 0.29.30
- Added a detailed, hotkey-only Game Mode Combat Report covering overland, dungeons, trials, arenas, Infinite Archive, Battlegrounds, and Alliance War combat.
- The report includes player damage, hit results, current resources/build stats, active buffs and debuffs, targets/group contributions, and ability breakdowns.
- Assign Open / Close Game Mode Combat Report under Controls > Keybindings > ESO Adventurer Suite. The same key closes it, and the report never opens automatically.
- Up to 30 recent fights can be reviewed with previous/next controls. The window is movable and resizable.
- Active Antiquity search areas now have Heavy Shovel markers on the world map, Suite minimap, and in the 3D world.
- Excavation now includes an Augur color helper that points to the best next grid cell.
- The Augur Guide and Tile Selector can be repositioned from HUD Layout Mode so they do not cover the excavation board.
- The Skills page includes Scrying and Excavation upgrade recommendations with rank requirements and skill-point costs.

DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls and related marks are property of their respective owners.

Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.