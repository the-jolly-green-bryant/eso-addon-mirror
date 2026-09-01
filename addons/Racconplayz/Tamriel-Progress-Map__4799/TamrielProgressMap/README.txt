Tamriel Progress Map 2.6.34_Beta
===============================
Author: Raccoonplayz
Requires: LibAddonMenu-2.0 r43+ / LibZone 8.99+
ESO API: 101050 / 101051
Languages: German / English / Russian / French

2.6.31_Beta
----------
- Fixes the critical ESO UI error caused by enumerating the global API table while searching for the Tamriel Tomes HUD tracker.
- Skyshard HUD detection no longer touches private ESO API functions such as GetMarketProductInfo.
- Keeps the safe native HUD tracker registry lookup and visible UI-tree fallback from 2.6.15.
- Keeps the custom clickable/scrollable TPM zone-focus dropdown from 2.6.15.

2.6.14
----------
- Fixes Progress page 3 category localization when TPM language differs from the ESO client language.
- Adds a Progress focus selector: All Tamriel or one specific supported zone.
- Zone focus recalculates summary cards, completion categories and the zone list for the selected zone only.
- Keeps history, milestones, goals, Collections and Achievements account/Tamriel-wide.
- Adds Skyshard HUD position 1/2 around the Tamriel Tomes tracker.
- Skyshard HUD now hides with the normal HUD on World Map/menu scenes (M / ESC).

2.6.1
----------
- Adds three pages to the Progress completion block: Completion Categories / Collections / Achievements.
- Shows account-wide ESO collection counts (owned / total) for 15 collectible types.
- Collections are informational only and never change Tamriel completion %.
- Achievement points are read live from ESO by category and never change Tamriel completion %.
- Use the arrows beside the category heading to switch between Completion, Collections and Achievements.

2.4.57 HOTFIXES INCLUDED
------------------------
- /tpm stats and /tpm statistics open Standalone Statistics without requiring the World Map.
- Native ESO keybinding for Tamriel Statistics.
- Votan's Minimap/full-map visibility fixes.
- Quest Reward window works independently from Show Zone Progress.
- Improved delayed auto-sizing for long/Skill Point reward lines.
- Reward Details popup opens outside the Quest Reward window.
- Gamepad progress header uses a separate upper-right anchor.
- Completion-category bars are shorter so 100% does not overlap the bar.
- Live settings localization refresh improved, including ON/OFF text.
- Full DE / EN / RU / FR interface support.
- Log Info popup measures localized text dynamically.

MAIN FEATURES
-------------
- Zone completion percentages directly on the world map.
- Quick filters: All / Incomplete / <50% / 100% / Statistics.
- Progress, Economy and PvE / PvP statistics pages.
- Completion categories plus account-wide Collections and Achievement pages.
- Optional Quest Reward window.
- Character/Companion XP progress.
- Per-character combat and activity logs capped at 100 entries each.
- World Event participation tracking.
- Per-character play-time display using ESO's /played API.
- Immediate in-addon language switching: DE / EN / RU / FR.

COMMANDS
--------
/tpm stats                         Open/close standalone Statistics
/tpm statistics                    Same as /tpm stats
Keybinding                         Default: Num5; change under Controls > Keybindings > Tamriel Progress Map
/tpm page progress                 Open Progress
/tpm page economy                  Open Economy
/tpm page history                  Open PvE / PvP
/tpm lang auto|de|en|ru|fr         Set addon language
/tpm refresh                       Refresh the map display
/tpm checkpoint                    Save an in-memory history checkpoint
/tpm debugreport                   Print a compact bug-report line
/tpm version                       Print the installed TPM version

INSTALLATION
------------
Extract the TamrielProgressMap folder into:
Documents/Elder Scrolls Online/live/AddOns/

LibAddonMenu-2.0 and LibZone are required and are not bundled.


2.6.32_Beta - Standalone Statistics Update
- Detailed Gold Statistics behind the existing Gold card.
- Zone-specific Gold economy tracking starts with 2.6.32.
- Zone Focus, Zone Records, Crime & Theft and Bank views.
- Tracking information localized in DE/EN/FR/RU.

- 2.6.32 polish: real ESO selection menus, Current Zone shortcut, saved detail-window position, filtered rankings and corrected Crime Net.

- Optional Alliance Territory overlay: DC blue, AD gold, EP red; supported neutral base-game territories white. Chapter/DLC zones stay unchanged.


2.6.33_Beta
- Hardened optional Alliance Territory overlay.
- Daggerfall Covenant: blue; Aldmeri Dominion: gold; Ebonheart Pact: red.
- Supported neutral base-game territories can be shown in white.
- Chapter and DLC zones remain unchanged.
- Reliable ESO border/glow texture for territory markers.
- Strict original-zone whitelist to avoid accidental DLC/chapter coloring.
- Includes the complete 2.6.32 Standalone Statistics and Detailed Economy patches.


2.6.34_Beta - Standalone & Alliance Bugfix
- Num5/standalone Statistics now enables the UI mouse cursor immediately.
- ESC closes standalone Statistics and releases TPM UI mode.
- Fixed UI error caused by an early TPM_HideAchievementTooltip call.
- Overall completion percentage is smaller and centered in the Ouroboros.
- Economy main page is cleaner; transaction/zone detail remains in Detailed Statistics.
- Added a fourth Alliances statistics page after PvE / PvP with Your Alliance plus DC/AD/EP progress.
- Alliance classification prefers language-independent ESO base-game/alliance data; DLC/chapter zones stay excluded.


2.6.35_Beta Hotfix
- Fixed startup UI error in CreateProgressPlaytimeCard caused by an invalid leftover 'line:SetAnchor' call.
- Retains the 2.6.34 Standalone Statistics, ESC/cursor, Economy layout, percentage layout and Alliances page changes.

2.6.36_Beta
- Redesigned the Alliances statistics page with a current-alliance hero card, progress bars, selectable DC/AD/EP cards and detailed category progress.
- Fixed ESO grammar suffixes such as ^n being visible in alliance names.
- Increased Alliance Territory marker glow visibility on the Tamriel map.
- Note: TPM still uses marker-based map overlays; exact geographic zone polygon borders require dedicated zone mask artwork and are not faked by this build.

2.6.37_Beta Hotfix
- Fixed Alliance Statistics crash: "table index is nil" in GetAllianceCategoryStatisticsData.
- Alliance detail categories now use only completion-type constants that exist in the active ESO API.
- Added defensive handling for invalid/unsupported detail category and selected-alliance values.

2.6.38_Beta
- Fixed Alliance Statistics changing when TPM language is switched.
- DC/AD/EP membership now uses stable ESO zone IDs only; localized zone names no longer influence calculations.
- Alliance percentages, zone counts and objectives remain identical in DE/EN/FR/RU.
- Improved Detailed Gold Statistics with compact Income, Expenses, Net and Transactions cards.
- Improved Focus/View selectors and reduced unused empty space.

2.6.39_Beta
- Fixed Detailed Gold Statistics appearing behind the main Statistics/PvE-PvP window.
- Raised the Gold detail window draw level above other TPM statistics panels.
- Fixed Focus/View popup menus appearing behind the Gold detail window and other controls.
- Improved Focus/View selector spacing and readability.

2.6.40_Beta
- Kept the main Gold economy card unchanged.
- Reworked only the Detailed Gold Statistics toolbar.
- Focus and View selectors are now grouped compactly in the upper-right area.
- Retains the 2.6.39 draw-order fixes so the detail window and popup menus stay above Statistics.

2.6.41_Beta - Experimental Alliance Territory Borders
- Added a real world-map border layer for alliance territories on the Tamriel overview.
- Daggerfall Covenant borders are blue, Aldmeri Dominion gold, Ebonheart Pact red.
- Supported neutral territory border is white when neutral highlighting is enabled.
- Borders use a subtle glow plus a sharp inner line and follow the World Map container during zoom/pan.
- Existing percentage markers and Alliance Statistics remain unchanged.
- This is an experimental hand-tuned border layer because ESO does not expose the rendered zone polygons as recolorable addon controls.

2.6.42_Beta - Community Territory Pass
- Replaced the coarse alliance-region prototype with individual per-zone territory outlines.
- Added individual borders for the original Daggerfall Covenant, Aldmeri Dominion and Ebonheart Pact base-game zones.
- Optional neutral white outlines remain supported.
- Chapter and DLC territories are not colored.
- Alliance calculations continue to use stable zone IDs and therefore remain identical in DE/EN/FR/RU.
- Border controls are non-interactive and do not replace ESO map art or TPM completion percentages.
- This remains a hand-tuned overlay because ESO does not expose its painted zone polygons to addons.

2.6.43_Beta - Map Overlay + Gold Restore
- Restored the detailed Gold statistics window and its refresh layout from 2.6.37.
- Removed the experimental CT_LINE territory renderer.
- Added a transparent DDS Alliance Territory overlay attached directly to ZO_WorldMapContainer.
- Overlay is shown only while the World Map scene is open and the current map is Tamriel (MAPTYPE_WORLD).
- Overlay is hidden immediately when the World Map closes.
- Existing Alliance Territory setting controls the overlay.

2.6.44_Beta
- Economy page restored to the full Gold ledger layout.
- Zone focus selector added directly to the Economy header.
- Focused-zone Received/Spent/Net summary added beside it.
- Gold ledger values now use the selected zone focus while Cash/Bank/Total remain live balances.
- Removed the Gold detail button from the main Gold card.
- Alliance overlay now anchors to ZO_WorldMapContainer1, the actual ESO map texture surface.
- Overlay is hidden when the World Map closes and shown only on the Tamriel world map when enabled.

2.6.45_Beta - Alliance Map + Economy Polish
- Removed the experimental overlay from ESO's normal M world map.
- Added a dedicated Tamriel Alliance Territory map to the Alliance Statistics page.
- DC, AD and EP territories are visually separated; neutral territory remains neutral.
- Clicking an alliance card highlights the map panel with that alliance color.
- Economy header cleaned up: removed the green mini-summary.
- Zone Focus remains directly in the Economy header and drives the Gold ledger values.

2.6.46_Beta - Economy Cache Recovery + Detailed Alliance Map
- Restored historical global Economy Received/Spent/Fence/Stolen/Bounty totals for the All Tamriel focus.
- Existing Economy saved-variable history is preserved; no totals are reset.
- Added safe fallback migration for older character-name/player Economy caches without summing duplicate caches.
- One-time migration resets Economy focus to All Tamriel so historical totals are visible immediately.
- Selecting a specific zone still shows that zone's ledger (zone history starts with the zone-tracking feature and cannot be reconstructed retroactively).
- Reworked Alliance Statistics map with individual base-game alliance zone regions.
- Selected alliance now receives its own highlighted map texture.

2.6.47_Beta - Economy Focus UI
- Reworked the Economy zone Focus selector into a compact ESO-journal style control.
- Removed the oversized selector appearance.
- Replaced the standard ESO context menu with a TPM-owned dropdown.
- Economy Focus dropdown is parented to the Statistics top-level and rendered at draw level 9900.
- Dropdown can no longer open behind the Statistics window.
- Added mouse-wheel scrolling for long zone lists.

2.6.48_Beta - Economy Focus Dropdown Polish
- Fixed Economy focus rows so zone entries can actually be selected with the mouse.
- Rebuilt row interaction using mouse-enabled labels with OnMouseUp handling.
- Added hover backgrounds and a clear selected-zone highlight.
- Added a visible right-side scrollbar rail and dynamic scroll thumb.
- Added up/down scroll buttons while retaining mouse-wheel scrolling.
- Dropdown draw level raised to 9950.

2.6.49_Beta - Real Tamriel Alliance Map
- Replaced the stylized Alliance Statistics map with the supplied detailed Tamriel map artwork.
- Added DC blue, AD gold and EP red territory markings directly on the map asset.
- Neutral/core territory remains mostly uncolored with a subtle white outline.
- Clicking DC / AD / EP continues to switch to a stronger highlighted variant for that alliance.
- The normal ESO M map remains untouched.

2.6.50_Beta - Economy Focus Click Fix
- Rebuilt Economy dropdown rows as real CT_BUTTON controls.
- Fixed zone selection clicks not firing reliably.
- Row labels no longer consume mouse input.
- Added cleaner ESO-style dropdown chevron control.
- Existing hover, selection highlighting, scrollbar and mouse-wheel scrolling retained.

2.6.51_Beta - Economy Top-Level Dropdown Fix
- Rebuilt the Economy Focus dropdown as a real TopLevelWindow.
- Fixes ESO mouse hit-testing where a visible dropdown could still be behind the Statistics journal for clicks.
- Dropdown now uses draw level 20000 and is explicitly brought to the top when opened.
- Zone rows now handle OnMouseUp directly, with OnClicked retained as fallback.
- Economy dropdown is hidden automatically when the Statistics window closes or the page changes.

2.6.52_Beta - Localized PvE/PvP Timestamps
- PvE/PvP combat and activity log timestamps now follow TPM's selected language.
- German: DD.MM.YYYY + 24-hour clock.
- English: MM/DD/YYYY + 12-hour AM/PM clock.
- French: DD/MM/YYYY + 24-hour clock.
- Russian: DD.MM.YYYY + 24-hour clock.
- Existing log rows are reformatted dynamically from their stored timestamp, so old German-formatted cached strings no longer remain visible after switching language.

2.6.53_Beta - Alliance Dashboard Redesign
- Completely reorganized the Alliance Statistics page around practical alliance progression.
- Tamriel map now preserves the supplied 2048x1724 map aspect ratio instead of being stretched.
- Added a dedicated per-zone progress checklist for the selected alliance.
- Alliance base-game zones are sorted from highest progress to lowest progress.
- Each zone shows name, completion percent, objective count and a progress bar.
- Compact alliance selector cards now update map, zone list and category details together.
- Category progress was rebuilt into larger two-row progress entries with bars.
- Own-alliance summary remains at the top in a more compact format.

2.6.54_Beta - Activity Log Hotfix
- Fixed UI error B370381 in AddActivityLogEntry after the localized timestamp refactor.
- Replaced stale TPM_GetLogDateText calls with the new localized date formatter.
- PvE kill/activity logging no longer calls a removed helper function.

2.6.55_Beta - Alliance Completion Planner
- Removed approximate alliance territory masks from the Alliance page.
- Added a neutral supplied Tamriel map for orientation only.
- Added Next 100% Target and Biggest Backlog recommendations.
- Zone list now prioritizes unfinished zones, with the closest-to-complete zone first.
- Every zone shows remaining objectives.
- Zone rows are clickable and open that zone directly in TPM's Progress page.
- Category rows now also show remaining objectives.
- Planner is based on real ESO zone progress rather than approximate map geometry.

2.6.56_Beta - Version Label + PvE/PvP Naming
- Added a compact "v2.6.56 Beta" label next to the Tamriel Statistics window title.
- Removed "Beta" from the visible PvE / PvP tab and PvE / PvP page title.
- The addon build itself remains a Beta build and is identified by the new version label.

2.6.57_Beta - Version Label Position
- Moved the Beta build label directly beside the Tamriel Statistics title.
- Version information now sits before the language selector instead of between language and calculation mode.
- Reduced the label size and contrast so it reads as secondary build information.

2.6.58_Beta - Category Gear Position
- Moved the Progress Categories settings gear from beside the section title to the control gap before the category sort buttons.
- No other Progress-page layout elements were changed.

2.6.59_Beta - Economy Zone Localization
- Economy Focus zone names now use TPM/LibZone localization instead of the ESO client language.
- Switching DE/EN/FR/RU immediately rebuilds an already-open Economy Focus dropdown.
- Selected Economy Focus text is refreshed in the new language at the same time.
- Alliance Planner zone names now use the same TPM-language-aware zone-name source.

2.6.60_Beta - Economy Localization Hotfix
- Fixed UI error CC5B0776 in GetEconomyZoneName.
- GetEconomyZoneName no longer calls the later local SafeZoneName helper before it is in lexical scope.
- Economy Focus zone names still follow TPM's selected DE/EN/FR/RU language through LibZone.
- Added safe native ESO fallback for zones not yet known to LibZone.
- Immediate dropdown refresh on language switch remains enabled.

2.6.61_Beta - Version Label Styling
- Increased the Statistics version label size to match the top-bar controls.
- Changed the version label from muted gray to clear near-white.
- Vertically aligned the label more closely with the language and calculation controls.

2.6.62_Beta - Alliance Font Scale
- Increased font sizes throughout the Alliance Completion Planner.
- Enlarged alliance names, percentages, zone progress rows, recommendation boxes and category details.
- Increased helper/note text sizes for better readability at 1440p.
- Added small spacing adjustments to prevent the larger text from overlapping.

2.6.63_Beta - Progress Title Version
- Version/Beta text is now shown only on the Progress page.
- Progress title now reads "<localized Tamriel Statistics>-v2.6.63-Beta".
- Economy, PvE / PvP and Alliance pages no longer show a separate Beta/version label in the header.

2.6.64_Beta - Interactive Alliance Planner Map
- Added an ornate ESO-style frame around the Alliance Planner Tamriel map.
- Added map zoom from 100% to 250% using + / - buttons or the mouse wheel.
- Added a one-click 100% zoom reset.
- Added an optional Alliance Colors mode inspired by Selavias Nite's community request.
- Alliance Colors mode highlights the selected alliance consistently across the map frame and real zone-progress rows without inventing inaccurate territory geometry.
- Added DC / AD / EP / Neutral legend.
- Progress page title version advanced automatically to v2.6.64-Beta.

2.6.65_Beta - Alliance Map Pan + Layer Hotfix
- Fixed the Alliance Planner map becoming dark/obscured after the interactive-map update.
- Removed the erroneous overlay draw layer from the entire planner panel.
- Map frame now stays behind the map texture and controls.
- Added drag-to-pan while zoomed above 100%.
- Pan position is saved and clamped so the map cannot be dragged outside its valid texture area.
- At 100% zoom the map automatically recenters.
- Mouse-wheel zoom, + / -, 100% reset, Alliance Colors and legend remain available.
- Progress title version advanced to v2.6.65-Beta.

2.6.66_Beta - Alliance Map Interaction Polish
- Rebuilt the Alliance Planner map viewport with a clean single-line frame.
- Removed overlapping map note/legend text from the recommendation area.
- Zoom now centers around the mouse cursor instead of always zooming toward the middle.
- Mouse wheel zoom remains available from 100% to 250%.
- Left-click drag pans the zoomed map inside the viewport.
- + / - buttons use the same cursor-centered zoom behavior.
- 100% reset recenters the map.
- Alliance Colors control remains available as a compact overlay control.
- Progress title version advanced to v2.6.66-Beta.

2.6.67_Beta - Community Alliance Page Layout
- Rebuilt the Alliance page to match the requested community-oriented layout.
- Uses the supplied alliance-region map as the in-addon Alliance Planner texture.
- Large central map with drag-to-pan and cursor-centered mouse-wheel zoom.
- Added a dedicated right-side Alliance Colors panel with DC/AD/EP/Neutral legend and zoom controls.
- Zone Progress moved below the tools panel on the right.
- Left-side alliance cards and bottom progress details retained.
- Progress title version advanced to v2.6.67-Beta.

2.6.68_Beta - Playtime + World Event Activity Fix
- Fixed the Progress-page Today's playtime line being permanently hidden.
- Added a robust direct today's-playtime calculation from ESO /played snapshots and the active session.
- Tightened World Event participation detection to stop unrelated quest XP from producing false Dolmen entries.
- Removed the unsafe single-active-event-in-zone participation fallback.
- Evidence-only World Event trackers now require real encounter evidence before being logged.
- Progress title version advanced to v2.6.68-Beta.

2.6.69_Beta - Alliance Page / Map Repair
- Replaced the broken Alliance Planner texture with the newly supplied alliance map.
- Rebuilt the source as a 1024x1024 Power-of-Two DDS for maximum ESO texture compatibility.
- Map viewport preserves the supplied 918:662 visual aspect ratio.
- Mouse-wheel cursor zoom, + / -, 100% reset and left-click drag-to-pan remain enabled.
- Removed the redundant Alliance Colors ON/OFF control because the supplied map already contains the territory colors.
- Repacked the right tools/zone panels and moved Progress Details fully above the page tabs.
- Fixed the Alliance page layout overlapping the bottom navigation.
- Progress title version advanced to v2.6.69-Beta.

- World Event false-positive protection retained: normal quest XP no longer promotes a nearby Dolmen by itself.

2.6.70_Beta - Test Final Alliance Polish
- Final-pass visual polish for the Alliance page.
- Enlarged right-side Alliance legend, zoom display and zone progress rows.
- Added a compact Alliance Overview with finished zones, remaining zones/objectives and next target.
- Improved 100% zone readability and progress row spacing.
- Kept the supplied alliance map, mouse-wheel zoom, +/- controls and drag-to-pan unchanged.
- Tightened bottom progress details so the page remains clean above navigation tabs.
- Progress title version advanced to v2.6.70-Beta.

2.6.71_Beta - Alliance Alpha Label + Remapped Keybind Mouse Fix
- Alliance page top-right status now shows an Alpha Test label.
- Fixed standalone Statistics opened through a user-remapped Controls key sometimes appearing without a mouse cursor.
- Standalone UI mode is now re-asserted after the key event (immediate + delayed safety pass).
- Custom bindings such as 9 now use the same standalone mouse behavior as the original NumPad5 binding.
- Progress title version advanced to v2.6.71-Beta.

2.6.72_Beta - Keybind Wrapper Hotfix
- Fixed UI error "function expected instead of nil" from the Tamriel Statistics keybinding.
- Restored the global TamrielProgressMap_KeybindToggleStatistics() function required by bindings.xml.
- The remapped-key mouse/UI-mode fix from 2.6.71 remains active.
- Progress title version advanced to v2.6.72-Beta.
