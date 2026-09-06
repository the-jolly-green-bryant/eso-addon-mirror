- HUD Layout Mode can move/scale ESO's native focused-compass information label independently from the compass itself.
- HUD Layout Mode can move/scale both ESO's native Request / Invite Prompt and the real native fading alert stack used for group invite results, wayshrine/location notices, duel results and similar alerts; settings include harmless test previews for both.
- HUD Layout Mode can move/scale ESO's native player request/invite prompt (group, trade, shared quest, etc.) without reskinning any other ESO HUD element.
- Potion Maker and Turbo Learner hotkeys now open on the first press and can switch directly between the two pages.
- Potion Maker and Turbo Learner now each have a dedicated top-menu icon and assignable Open / Close hotkey under Controls > Keybindings > General > ESO Adventurer Suite. Their options are grouped under Crafting & Learning in Suite Settings.
- Turbo Recipe & Style Learner now opens from its own top main-menu icon, previews all unknown learnable recipes/plans/motifs/styles, and only starts after LEARN ALL is pressed.
- The Suite Quickslot view now fully suppresses native Quickslot hover surfaces to prevent one-frame ESO UI flashes.
- Quickslot Collection picker now stays limited to actual wheel-compatible content such as Mementos, Polymorphs, Companions and Emotes.
- Quickslot picker also acts as a usable Collections launcher for Costumes, Assistants, Markings and other equip/use collectibles that ESO does not permit on the current Quickslot wheel.
- The Quickslot picker includes backpack items, valid Collection actions (including mementos, polymorphs, companions and assistants), and Quickslot-compatible emotes.
- Quickslot picker includes eligible unlocked Collections items as well as backpack items.
- Shared keyboard crafting inventory panels use the Suite rarity-colored grid while keeping ESO station filtering and selection logic intact.
- Quickslot picker now lists all backpack items that can be placed anywhere on the item Quickslot wheel.
- Inventory special tabs now fully clean up Quickslot picker state when switching to Currency or other inventory modes.
- Inventory groups show their item count, sort highest rarity first, and Quickslots can be filled directly from the Suite Quickslots tab.
- Inventory Grid supports collapsible AutoCategory-style groups. If AutoCategory - Revised is installed, its injected category headers are mirrored into the Suite grid; otherwise the Suite builds useful groups itself.
- Quickslot cards can be selected for replacement, then filled by left-clicking a valid item from Items.
- Currency and Quickslots now use Suite-styled card/grid views; locked inventory items use ESO’s native lock texture.
- Inventory Grid now respects all five top inventory modes and uses ESO-native item slot interaction/context menus from the custom grid.
- Inventory Grid now follows the active filtered inventory list while keeping ESO native rows hidden on tab/filter changes.
- Inventory Grid now uses brighter item cards, no black count box, and better sync with the native inventory category filters and sorting.
- Added a Suite-native inventory grid on the desktop inventory scene for a more visual item browser.
- Missing potion/poison ingredients now show per-ingredient route details and travel cycling when more than one material is missing.
ESO ADVENTURER SUITE
Version 0.29.322
Author: HoZayyBadazz
Status: Public Beta

OVERVIEW
ESO Adventurer Suite is an all-in-one Elder Scrolls Online dashboard and utility addon. It combines the Tamriel Codex, quest/travel tools, combat guidance and reports, a Dual Action Bar HUD, minimap/navigation tools, build optimization, companion/group HUD tools, treasure/antiquity assistance, crafting helpers, notes/checkpoints, Golden Pursuits integration, and configurable overlays.

REQUIRED LIBRARIES
Install separately through Minion/ESOUI:
- LibAddonMenu-2.0 >= 43
- LibMapData >= 101
- LibGPS >= 73
- LibMapPins-1.0 >= 47

LibGPS support libraries:
- LibMapPing
- LibDebugLogger
- LibChatMessage

OPTIONAL FEATURE LIBRARIES
- LibTreasure >= 24: Treasure Map, Crafting Survey, and Tales of Tribute clue location data
- CustomCompassPins >= 138: Treasure/Survey/Clue compass markers

INSTALL / UPDATE
1. Install the required libraries.
2. For manual updates, delete the old ESOAdventurerSuite folder first. This avoids stale files from older builds.
3. Extract the release so the manifest path is:
   Documents/Elder Scrolls Online/live/AddOns/ESOAdventurerSuite/ESOAdventurerSuite.txt
4. Enable ESO Adventurer Suite and the required libraries at character select.
5. Log in. Settings are under Settings > Addons > ESO Adventurer Suite.
6. /reloadui can be used after changing addon files or when troubleshooting UI state.

0.29.208 RELEASE HIGHLIGHTS
- Removed the orange/paper-doll silhouette from the Enhanced Character Gear Screen. Your real framed 3D player is now the only character shown in the center.
- Reframes the real player to the center of the actual free equipment canvas rather than the physical center of the monitor.
- Rebalanced the layout farther left to use the previously empty desktop space while still respecting the inventory boundary.
- Equipment text now expands outward away from the character instead of inward over the model.
- Increased label width and added two-line name/set support so full item and set names are readable instead of being cut off.
- Main Character Size now controls the real 3D player framing size; Character Camera Distance remains available as the advanced base-distance control.
- Damaged gear warnings remain on the affected slot/condition text instead of tinting a removed silhouette.

0.29.207 RELEASE HIGHLIGHTS
- Reworked the Enhanced Character Gear Screen for 16:9 / 1440p readability after the initial layout could overlap the character, stats and inventory.
- Adaptive safe-area layout now detects the usable center space and keeps equipment away from the right inventory panel.
- Compact gear information is the new default: item name + set count without the extra equipment-type line.
- Added Compact / Detailed / Icons Only information density options.
- Added Character Stats Panel Auto / Always Show / Always Hide. Auto hides the large native stat list on standard-width screens and keeps it available on ultrawide layouts.
- Reduced vertical spacing and moved weapon slots upward so gear no longer crowds the bottom Stack All / Exit keybind strip.
- Player and companion layouts use the same adaptive positioning while preserving ESO's native slot buttons and controller navigation.

0.29.206 RELEASE HIGHLIGHTS
- New Suite-native enhanced Character Gear Screen for the desktop inventory/character view.
- Equipment slots are arranged around the character while remaining ESO's real interactive slot buttons.
- Shows item quality borders, armor condition / weapon charge, level/CP requirement, item name/type, equipped set count, and outfit/costume status.
- Companion equipment gets the same enhanced presentation.
- Configure slot size, detail font size, repair/charge/level warning thresholds, center-figure scale, and 3D character camera distance.
- Damaged gear can color the center figure red for an immediate maintenance warning.
- Compatible with Desktop UI + Gamepad Controls and last-input controller navigation.

0.29.205 RELEASE HIGHLIGHTS
- Added true last-input menu handoff while keeping the desktop visual UI.
- Controller becomes the menu owner when used: D-pad/left stick navigate desktop controls and Primary selects.
- Move/click the mouse and the same menu immediately returns to normal cursor control; touch the controller to switch back.
- Infinite Archive Verse/Vision choices are explicitly prioritized so the controller can move between and select the offered choices.
- New Auto-switch menu control by last input option is enabled by default.
- No Gamepad Mode, Keybind Display Mode, scene-template, or gameplay-input switching is performed.

0.29.204 RELEASE HIGHLIGHTS
- Boss Mechanics overlay visibility is now configurable.
- Default: only appears for active mechanics/reactions.
- Optional modes: boss combat, any combat, or always.
- Pre-pull briefing is optional and OFF by default.

0.29.203 RELEASE HIGHLIGHTS
- Boss Mechanics Coach and BLOCK NOW are now one unified Boss Mechanics / Combat Reaction overlay.
- Generic heavy attacks route into that same overlay even outside recognized boss encounters.
- Drag the Boss Mechanics panel edges/corners in HUD Layout Mode to resize it; size is saved.
- Boss Coach width/height settings and Reset Size are available in Settings.
- Text, spacing, controller glyphs, and mechanic lines reflow as the panel changes size.
- Fixed the remaining Desktop UI + controller-icon mismatch in ESO's native keybind presentation layer.
- Desktop/keyboard UI stays selected while controller movement/combat remains owned by ESO.
- When Keybind Display Mode is Gamepad, native desktop action-bar labels now select the gamepad binding device and GAMEPAD_ACTION_BUTTON actions instead of keyboard bindings.
- Ability, Ultimate, Quickslot, weapon-swap, and other registered native labels are repainted after binding/input/display-mode changes and player activation.
- Suite Ability/Ultimate, Smart Combat Advisor, Dual Action Bar, Quickslot Overlay, and Boss Mechanics Coach prompts prefer the player's actual gamepad bindings and ESO controller artwork.
- The Suite does not change Gamepad Mode, remap controls, synthesize input, or switch scenes to obtain controller glyphs.
- Infinite Archive Boss Mechanics Coach support remains included: known returning bosses reuse full profiles and Archive-only bosses keep generic live coaching.

KEY FEATURE AREAS
- Tamriel Codex, notes, checkpoints, and journal tools
- Quest Finder, active quest tracking, routing, map/minimap support
- Map Teleporter and travel helpers
- Boss Mechanics Coach, Smart Combat Advisor, Dual Action Bar HUD, ability overlays, combat stats, detailed fight reports
- Group/raid/companion/player unit frames and HUD overlays
- MAX POWER skills/morphs/passives/Champion/attribute planning
- Saved Builds, gear optimization, companion optimization, gear/loadout tools
- Infinite Archive Verse/Vision advisor
- Treasure/Survey/Clue locator and resource pins
- Antiquity lead/dig assistance
- Recipe & Style Learner and Alchemy Potion/Poison Maker
- Golden Pursuits, dungeon/activity history, stable/repair/performance/quickslot utilities

CONTROLLER NOTES
- Keep desktop UI while using controller selects the desktop interface without changing ESO's real controller input setting; changing this bridge requires Reload UI for a clean template reload.
- Auto-switch menu control by last input lets controller focus/navigation and the desktop mouse cursor hand the same keyboard-style menu back and forth without changing UI templates.
- Character-select/login UI is loaded before addons and cannot be converted by the Suite.
- Ability/Ultimate, Rotation Advisor, Quickslot, and Boss Mechanics Coach prompts follow the Suite controller mode and the player's actual bindings.
- Force PlayStation changes displayed in-game glyph art after addons load; it does not change actual bindings.
- Login/character-select glyphs are outside addon control.
- The Map Teleporter is mouse/keyboard operated.

SAFETY / INPUT BOUNDARIES
Boss Mechanics Coach, Smart Combat Advisor, Dual Action Bar, highlights, unit frames, minimap, combat reports, and most HUD systems are display/guidance systems. They do not cast abilities, block, dodge, target, move the character, or synthesize controller/keyboard/mouse gameplay input. Optional maintenance/crafting/learning features operate only through ESO-exposed APIs and are documented in SECURITY.txt.

SUPPORT / COMMUNITY
Creator: HoZayyBadazz
In Game User ID: @ShadowOps187
Discord Community: The Legends Den
Discord Invite: discord.gg/Tj72TAEqat

Optional gifts: in-game gold or Crown Store gifts. ESO Adventurer Suite and community support are free. No feature, update, addon access, Discord membership, or support is sold, required, or exchanged for gold, Crowns, gifts, or real money.

LICENSE / ATTRIBUTION
See LICENSE.txt, NOTICE.txt, ESO_ADVENTURER_SUITE_THIRD_PARTY_NOTICES.txt, and LoreBooks/ESO_ADVENTURER_SUITE_LOREBOOKS_LICENSE_NOTICE.txt.

DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls and related marks are property of their respective owners.
