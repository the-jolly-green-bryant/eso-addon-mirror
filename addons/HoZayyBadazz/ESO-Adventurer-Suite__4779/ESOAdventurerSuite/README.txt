ESO ADVENTURER SUITE
Version 0.29.197
Author: HoZayyBadazz
Status: Public Beta

AI DEVELOPMENT DISCLOSURE
ESO Adventurer Suite uses AI-assisted code generation and review. HoZayyBadazz is responsible for testing, publishing, maintaining, and supporting the addon.

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

0.29.197 RELEASE HIGHLIGHTS
- Added Keep desktop UI while using controller: ESO Gamepad Mode can stay On/Automatic for controller input while the logged-in interface remains the normal desktop/keyboard layout.
- Suite controller binding glyphs still follow the real native controller state while the desktop UI lock is active.
- Smart Combat Advisor now uses Highlight Action Bar as the preferred normal-combat presentation; the large Full/Compact card is no longer forced on existing installs after the one-time display migration.
- Full Overlay and Compact Next Skill remain available as optional Smart Advisor display choices.
- Weapon-bar SWAP guidance is now its own movable overlay in HUD Layout Mode, saves its position, and resets with RESET LAYOUT.
- Dual Action Bar continues to show both weapon bars, Skill Style art, timers/stacks, binding glyphs, Ultimate charge, inactive-bar emphasis, and Smart Advisor highlighting.
- Default active-bar indicator remains a texture-only ESO weapons icon with a soft gold glow: no number, arrow, or keybind letter.
- LibMapPing, LibDebugLogger, and LibChatMessage are declared required alongside the LibGPS stack.
- Map Teleporter remains intentionally mouse/keyboard operated.

KEY FEATURE AREAS
- Tamriel Codex, notes, checkpoints, and journal tools
- Quest Finder, active quest tracking, routing, map/minimap support
- Map Teleporter and travel helpers
- Smart Combat Advisor, Dual Action Bar HUD, ability overlays, combat stats, detailed fight reports
- Group/raid/companion/player unit frames and HUD overlays
- MAX POWER skills/morphs/passives/Champion/attribute planning
- Saved Builds, gear optimization, companion optimization, gear/loadout tools
- Infinite Archive Verse/Vision advisor
- Treasure/Survey/Clue locator and resource pins
- Antiquity lead/dig assistance
- Recipe & Style Learner and Alchemy Potion/Poison Maker
- Golden Pursuits, dungeon/activity history, stable/repair/performance/quickslot utilities

CONTROLLER NOTES
- Keep desktop UI while using controller prevents the logged-in interface from changing to ESO's console-style Gamepad UI while preserving the player's Gamepad Mode setting and controller input.
- Character-select/login UI is loaded before addons and cannot be converted by the Suite.
- Ability/Ultimate binding glyphs can follow ESO automatically.
- Force PlayStation changes displayed in-game glyph art after addons load; it does not change actual bindings.
- Login/character-select glyphs are outside addon control.
- The Map Teleporter is mouse/keyboard operated.

SAFETY / INPUT BOUNDARIES
Smart Combat Advisor, Dual Action Bar, highlights, unit frames, minimap, combat reports, and most HUD systems are display/guidance systems. They do not cast abilities, block, dodge, target, move the character, or synthesize controller/keyboard/mouse gameplay input. Optional maintenance/crafting/learning features operate only through ESO-exposed APIs and are documented in SECURITY.txt.

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
