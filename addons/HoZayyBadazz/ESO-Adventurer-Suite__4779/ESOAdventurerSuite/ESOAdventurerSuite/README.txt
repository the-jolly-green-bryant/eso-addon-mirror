Update 0.27.59
- ESOUI upload compliance pass: synchronized metadata and dependency floors, and removed Suite-controlled nameplate changes so native ESO nameplate settings remain user-controlled.
- Required dependencies: LibAddonMenu-2.0>=43, LibMapData>=101, LibGPS>=30, and LibMapPins-1.0>=47.

- Custom ESO-style reticle selector with multiple styles, colors, size, and opacity controls.
Update 0.27.08
- ESOUI compliance review completed against the current upload rules, best-practice guidance, and AddOn capability restrictions.
- Removed the Nearby / Seen Players reticle-tracking source from the public Group Finder. Public listings and guild roster members remain available.
- Current package uses LibAddonMenu-2.0 r43, LibMapData, LibGPS 3.x, and LibMapPins-1.0 as external required dependencies, APIVersion 101050 101051, and contains no executables, nested archives, telemetry, network access, or arbitrary file access.
- Added/retained current travel tools (quest wayshrines, nearest merchant, nearest guild store, guild-leader primary residence) and paged Dungeon / Activity history.

Update 0.25.47
- ESOUI upload-readiness audit: LibAddonMenu-2.0 is declared as a required DependsOn dependency with minimum AddOnVersion 43.
- EVENT_COMBAT_EVENT analytics use ESO event-manager result/source/target filters instead of broad Lua-side result classification.
- Reduced idle Lua work by attaching Codex and Gear Loadout resize OnUpdate handlers only while resizing.
- Release metadata, AI disclosure/credits, and server-separated account-wide SavedVariables notes were rechecked for ESOUI review.

Update 0.25.23

Update 0.25.22
- Removed the custom movable/resizable quest direction arrow and its Settings controls.
- Quest Tracking still supports Active Quest, Golden Pursuits, and Main Quest as independent sources, with the selected source driving ESO's native assisted quest/compass guidance.

Update 0.25.21
- Quest direction guidance is now synchronized with ESO's native assisted quest compass. The selected Suite source is the only assisted quest, and the custom movable arrow uses matching map heading data.

Update 0.25.20
- Quest direction tracking is strictly bound to the source chosen in Settings: Active Quest, Golden Pursuits, or Main Quest. No cross-source fallback is allowed.
- Switching sources clears stale quest/breadcrumb state and the arrow uses live camera heading while turning.

Update 0.25.19
- Quest direction arrow now follows ESO's live breadcrumb position for the exact Active Quest, Golden Pursuit quest, or Main Quest selected in Quest Tracking settings.
- The arrow and player heading now use the same ESO map-coordinate system so direction updates correctly while moving and turning.

Update 0.25.18
- Added Champion Level Overlay visibility settings: Always On or Champion Point Gain Only.
- Gain-only mode shows the Champion overlay for 10 seconds whenever any Craft, Warfare, or Fitness Champion Point is earned, then hides it again.

Update 0.25.17
- Quest direction HUD now shows the selected source, tracked quest name, exact target objective, and relative direction so the arrow is never ambiguous.
- If ESO does not expose a mappable position for the selected objective, the HUD says so instead of showing a misleading arrow.

Update 0.25.16
- Quest Tracking Settings are now authoritative: Active Quest, Golden Pursuits, and Main Quest are independent, and only the selected source controls the quest HUD, direction arrow, and ESO assisted quest.
- Suite Quest Finder selections no longer require a second selection in ESO's native Quest Finder before the overlay changes.

Update 0.25.15
- Champion overlay now uses ESO native Champion symbols, correct earned CP totals, and separate Craft/Warfare/Fitness pool counts. Pre-Champion characters show their actual level.

Update 0.25.14
- Quest Tracking now has three independent sources: Active Quest, Golden Pursuits, and Main Quest.
- Main Story quests no longer interfere with the Active Quest source.
- Only the selected source drives the quest HUD and movable/resizable direction arrow.

AI DEVELOPMENT DISCLOSURE
=========================
ESO Adventurer Suite was developed with assistance from OpenAI, including AI-assisted code generation and review. The author, HoZayyBadazz, is responsible for publishing, testing, maintaining, and responding to issues in the addon.

Update 0.25.13
- Quest Tracking settings now let you choose one source: Active Quest or Golden Pursuits. Only that source controls the gameplay tracker and direction arrow.
- Quest Finder and Golden Pursuits selections are stored separately, and the direction arrow can be enabled and resized from settings or moved/resized in HUD Layout Mode.

Update 0.25.12
- Quest Finder selections now directly control the Suite Active Quest HUD and quest direction arrow.
- Added a movable/resizable quest-direction arrow that uses ESO-provided objective or breadcrumb coordinates; it does not invent a direction when ESO exposes no mappable quest position.
- Selecting a matching Golden Pursuit quest can drive the same HUD/navigation target.

Update 0.25.11
- Quest Finder selections for accepted quests now immediately switch the Active Quest overlay to the selected quest.

Update 0.25.10
- Removed the Active Quest header label so the quest HUD shows only the quest content with a cleaner compact layout.

Update 0.25.09
- Golden Pursuits and Active Quest HUD boxes now use more compact vertical sizing while remaining movable/resizable. Existing tall saved heights migrate once to the new compact defaults.

Update 0.25.08
- Golden Pursuits gameplay HUD is now intentionally minimal: GOLDEN PURSUITS header plus active quest name only.

Update 0.25.07
- Fixed the Golden Pursuits HUD Lua syntax error from v0.25.06.

Update 0.25.06
- Simplified the Golden Pursuits gameplay HUD so it shows the GOLDEN PURSUITS header with the active quest underneath and no extra Selected Pursuit / Active Golden Pursuit labels.

Update 0.25.05
- Replaced the duplicate Golden Pursuits presentation with one Suite-owned HUD; ESO's native promotional-event tracker is suppressed while the Suite is active.
- Golden Pursuits HUD is now movable and resizable in HUD Layout Mode and remembers its position and size.
- Restyled the regular Active Quest overlay to match the Golden Pursuits HUD with the same inset dark card, gold border, spacing, and resize treatment.

Update 0.25.04
- Golden Pursuits gameplay tracker now shows the pursuit selected in the Codex and the matched assisted journal quest name when one exists.
- The synced Active panel follows the movable Golden Pursuits tracker and obeys the same gameplay-only/menu-hide behavior.

Update 0.25.03
- Live Equipment panel borders are now drawn inside their controls so the full top/side/bottom strokes remain visible at smaller overlay scales.

Update 0.25.02
- Live Equipment layout cleanup: wider center breathing room, clearer gaps between gear cards and character stage, and a larger dedicated Active Weapon Bar panel with non-overlapping status text.

Update 0.25.01
- Live Equipment now uses a much larger centered current-character paper-doll presentation with the ESO-provided player silhouette, character identity, and alliance-theme accent treatment.
- ESO does not expose a true custom 3D dressed-character renderer to normal addons, so the overlay uses the game-provided silhouette rather than claiming a 3D model.

Update 0.25.00
- Normal PvE/overland minimap now uses ESO native map/POI artwork in the same style as the Cyrodiil PvP layer.
- Visible discovered POIs stay available on the overland minimap, native wayshrine/fast-travel artwork is no longer addon-tinted, and missing native POIs are omitted instead of replaced by generic white diamonds.
- Golden Pursuits continues to keep active and completed tasks in separate views.

Update 0.24.92
- Expanded Codex lists now use clean name-only selection rows with more breathing room.
- Full row metadata remains available in the Selected/detail panel instead of being duplicated in every row.
- Live Gear paper-doll is player-only; Companion mode was removed.
- Codex list workspaces show more rows with larger readable row text.
- Dungeon Finder ROLE: HEALER control width was increased to prevent clipping.

ESO ADVENTURER SUITE 0.24.78 - PUBLIC BETA
=================================================================

Version 0.24.78 replaces the old Lore Book presentation with an advanced translucent glass command-center interface inspired by modern Figma-style workspace layouts. The Codex is movable and resizable, remembers its position and dimensions, uses a left navigation rail and compact top command bar, and preserves every existing Codex tool and data page.

Version 0.24.74 adds separate BEST WEAPONS and BEST JEWELRY optimizer actions, a BEST ABILITIES action that slots purchased recommended skills into active-bar positions 1-5 (and Ultimate when available), and BEST POTIONS which places up to four highest-scoring backpack potions onto the quickslot wheel. All actions are explicit, out-of-combat requests; the addon does not cast abilities or consume potions automatically.

Version 0.24.73 adds movable Champion overlay support, explicit Best Light/Medium/Heavy Codex armor actions, immediate Inventory-close handling for the repair/recharge estimate, and an alphabetical runtime Dungeon Finder with Base Game vs DLC / Chapter labels. It also incorporates ESOUI review best practices for filtered combat events, server-separated account-wide SavedVariables, manifest dependency syntax, and AI disclosure.

Version 0.24.8 was the public-beta release candidate for the refreshed minimap, Codex travel/Quest Finder fixes, Alliance Rank presentation, and interaction/keybinding cleanup. The minimap keeps ESO's normal top compass, uses smoother movement and a less destructive zoom range, and remains usable while Suite Interaction Mode is active. All prior Codex, unit-frame, ability, repair/recharge, checkpoint, companion, and progression features remain.
OWNERSHIP AND DISTRIBUTION
--------------------------
Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.

ESO Adventurer Suite is source-visible for normal ESO add-on installation, but
source visibility does not grant permission to redistribute, re-upload, rebrand,
publish forks/derivative versions, copy substantial source into another public
project, sell the add-on, or claim the work as your own. Private personal-use
modifications are permitted. See LICENSE.txt and NOTICE.txt for the complete
terms and ownership notice.

Official public releases are intended to be published by HoZayyBadazz through the
project's authorized ESOUI/Minion listing.

DEVELOPMENT DISCLOSURE
----------------------
Author: HoZayyBadazz

Version 0.21.0 keeps the Tamriel Codex on ESO's native Lore Reader book medium and retains the v0.19.4 editing/readability fixes: Notes now use a clear TITLE field with the note body underneath, Checkpoints have a prominent custom-name field, and INDEX / PREV / NEXT / THEME / CLOSE are anchored inside the actual book pages so they remain readable at different UI scales. Interactive Gear, Quest, Travel, and Activity rows remain clickable inside the book, and dense page text uses explicit word wrapping with a smaller readable font when needed.

This add-on was developed with assistance from OpenAI. The packaged Lua/XML has
been statically reviewed for prohibited automation, external file/network access,
and unsafe gameplay actions. Earlier builds have been live-tested by the project
owner. Version 0.10.3 makes Session Play controls respond immediately when switching between Continuous, 30, 60, 120, and Custom durations without waiting on the full 1.2-second planner refresh. Version 0.10.2 separates the Quest action area from the global footer/navigation so Route to Starter and the footer remain readable. Version 0.10.1 fixes Quest-tab row/footer and title/status overlap and adds a clear selected-quest highlight. Version 0.10.0 removes the redundant PLAYER + COMPANION status label from solo companion Group frames while preserving dynamic roster sizing. Version 0.9.4 makes Group and Raid containers dynamically size to the visible roster so solo player + companion and small groups no longer leave large empty panel space. Version 0.9.3 makes the Player frame contextual (combat, damage, or active Magicka/Stamina use), makes Live Combat Stats combat-only, strengthens dark HUD readability, and force-hides every EPC gameplay layer in Pause/Character/Inventory/Map and other ESO menu scenes. Version 0.9.2 fixed a live-client companion-level crash caused by a multi-return ESO API being passed directly to tonumber() and hardened numeric reads in UnitFrames and MiniMap against the same Lua multi-return/base pitfall. Version 0.9.1 adds group-frame deduplication plus stricter native group/raid suppression. Version 0.9.0 expands the gameplay-only replacement HUD with compact self buffs/debuffs and a flagship intelligent Mini Map. The map adds SMART/QUEST/EXPLORE/GROUP/MINIMAL/CUSTOM profiles, context-aware adaptive zoom, off-screen edge guidance, live POI prioritization and clustering, rally/group-leader awareness, breadcrumbs, coordinates, and navigation-direction context while keeping expensive POI enumeration throttled. It should remain a public beta until this exact build has completed wider in-game testing.

WHAT IT IS
----------
ESO Adventurer Suite is an adaptive, role-aware character command center. It
combines progression guidance, Target Builds, combat analytics, activity planning,
quest-aware travel, inventory intelligence, crafting research, collections/zone
completion, dailies, and smart loot guidance using data exposed by ESO's UI API.

The gameplay HUD does not display the author or add-on version. Its header uses
the active character's name and character information.


TAMRIEL CODEX
------------------
Assign Open / Close Tamriel Codex under:
Controls > Keybindings > General > ESO Adventurer Suite

The Tamriel Codex includes:
- Personal notes organized by category
- Automatic saving when switching notes/tabs or closing
- Read Mode and Edit Mode
- Personal location pins saved from your current map position
- World Map custom pin rendering where ESO's custom-pin API is available
- Set Waypoint and Delete Pin actions
- Roleplay dice: d4, d6, d8, d10, d12, d20, d100
- Coin toss
- Active Quest documents
- Recent Achievement documents and point summary where exposed
- Character/game statistics page
- Crafting Codex quick-reference pages for Alchemy, Enchanting runes, and material tiers
- Parchment, Midnight, Daedric, and Frost page themes

Slash command: /esosuite codex

MOVABLE CLOCK
-------------
A compact 12-hour clock (for example 3:50 PM) is enabled by default.
Use /esosuite frames move to drag it with the other HUD elements, then
/esosuite frames lock to save the layout. You can also use:
/esosuite clock show
/esosuite clock hide
/esosuite clock reset

CORE MODULES
------------
BUILD
- Leveling/endgame guidance and unified Next Best Move
- AUTO plus DPS, GOLD, XP/CP, GEAR, DUNGEONS, TRIALS, SOLO, QUESTING focus modes
- Target Build completion and missing-gap analysis

GEAR
- Equipped set, trait, enchantment, quality, armor-weight, and weapon analysis
- Named Target Set tracking
- Read-only upgrade guidance
- Searchable Equipment Set Journal using ESO's live Item Set Collection
- Browse armor/weapon sets by source, collection progress, and source category
- ROUTE SOURCE selects a matching discovered wayshrine; ZONE QUESTS opens matching quest records as navigation leads

SKILLS
- Skill-point and weapon-bar guidance
- Level 50+ Champion slottable audit
- Role-aware Damage / Healer / Tank priorities

COMBAT
- Role-aware live/post-fight metrics
- Damage: DPS, damage, critical-event share, HPS
- Healer: HPS, healing, critical-heal share, DPS
- Tank: DTPS, damage taken, blocked-hit share, HPS
- Personal bests and best-effort observed group/raid damage/healing summaries

ACTIVITY
- XP, GOLD, or BALANCED ranking
- Continuous or optional timed session plans
- Journal-quest reward/location awareness
- Local learning from completed quest XP/gold/time samples
- Endgame/role-aware repeatable activity priorities

MAP
- Focused-quest routing and QUEST BEST wayshrine ranking
- Explicit-click travel to discovered wayshrines
- Explicit-click friend, guild-member, and group-member travel
- Current-zone exploration hint from zone-completion and skyshard data

TOOLS - UTILITY COMMAND CENTER
------------------------------
TOOLS is a new seventh module with five views:

OVERVIEW
- Backpack/bank pressure
- Open research capacity
- Current-zone completion snapshot
- Daily/repeatable-value summary

INVENTORY
- Backpack and bank usage
- Craft-bag summary where ESO exposes it
- Approximate NPC vendor sell value for scanned items
- Research candidates and Target Set items
- Local account snapshots for characters that have loaded the add-on
- Cross-character item-name search through saved snapshots

RESEARCH
- Blacksmithing, Clothier, Woodworking, and Jewelry trait progress
- Active/maximum research slots where available
- Current research timers
- Researchable items currently found in the backpack
- Advisory only: the add-on never starts research automatically

COLLECTIONS
- Current-zone POI completion summary
- Current-zone skyshard discovered/total progress
- Nearest unfinished skyshard hint using ESO-exposed world positions when available
- Account lore-book known/total summary
- Target Set Sticker Book collection progress
- Set-name search with collection counts

DAILIES
- Accepted repeatable quest summary
- Daily login reward availability where exposed
- Random dungeon/Battleground daily reward eligibility where exposed
- Curated high-value repeatable activity suggestions

SMART LOOT GUIDANCE
-------------------
New backpack items may receive advisory messages such as:
- TARGET KEEP - matches one of your named Target Sets
- LEARN - the item can teach an available collectible/knowledge entry
- RESEARCH - the item's trait can be researched
- COLLECTION - an uncollected set piece was detected

The add-on never automatically equips, locks, sells, destroys, deconstructs,
researches, learns, deposits, withdraws, or marks items as junk.

ACCOUNT INVENTORY SEARCH
------------------------
Each character can save a compact inventory snapshot when it loads the add-on.
Shared inventory is also summarized from ESO-accessible bank data. Search is
case-insensitive by item name.

Examples:
/esosuite scan
/esosuite find pillar
/esosuite find dreugh wax

Snapshots are not a live database of characters that have never loaded this
version of the add-on, and may reflect the last time that character was scanned.

SET COLLECTION SEARCH
---------------------
Search ESO-exposed Item Set Collections by set name:

/esosuite set pillar
/esosuite set orders wrath

Results show collected/total collection slots when ESO exposes those values.
This feature does not include or copy proprietary third-party add-on databases.

PERSISTENT PLAYER / TARGET / GROUP / RAID HUD
------------------------------------------------
Version 0.7.0 adds a separate persistent HUD layer that is independent from the
large suite window.

PLAYER FRAME
- Gameplay-only by default, independent from the large suite window
- Health, Magicka, and Stamina bars/values with no resource-name labels
- No player name, level/CP, or companion text in the persistent frame
- Player and Target use matching ESO-style Health/Magicka/Stamina bars with independent size controls
- Buffs are integrated above Health and debuffs below Health on both frames; the old standalone Player Effects overlay is retired
- Every player buff/debuff exposed by ESO is shown as compact target-style icons with timers/stacks; no +N overflow summary

TARGET FRAME
- Appears when ESO exposes a valid reticle target
- Target name plus level/Champion status
- Health only; target Magicka and Stamina are intentionally omitted
- 3-6 prioritized live buff icons and 3-6 debuff icons with stack/timer overlays
- Buffs and debuffs share one compact side-by-side aura band instead of two tall rows
- Additional auras are summarized as +N so the frame never grows vertically
- Debuffs cast by the local player are prioritized in the visible strip

GROUP FRAME
- Used automatically for groups of 1-4 (and for player + active companion while solo)
- Member name, level/CP, role/status, leader marker, and Health
- Companion name + companion level where ESO exposes the unit
- Offline, dead, and out-of-support-range status indicators

RAID FRAME
- Used automatically for groups larger than 4
- Multi-column layout sized from ESO's current group-size capability
- Member name, level/CP, role/status, leader marker, and Health

LIVE COMBAT STATS
- PEN: offensive penetration
- PWR: Weapon/Spell Damage
- SR: Spell Resistance
- PR: Physical Resistance
- CC: Critical Chance
- CD: Critical Damage

HUD LAYOUT MODE
/esosuite frames move
/esosuite frames lock
/esosuite frames reset
/esosuite frames show
/esosuite frames hide

Layout Mode temporarily shows preview frames and releases the mouse so Player,
Target, Group, Raid, Live Combat Stats, and Mini Map can each be dragged independently. Mini Map Move Mode uses a dedicated full-size drag surface, so dragging anywhere on the map works even over tiles or pins.
Their positions, scale, HUD opacity, and soft-background opacity persist through SavedVariables.

The persistent frames are display-only. They do not target units, cast skills,
change roles, or perform combat actions when clicked.

MINI MAP - INTELLIGENT NAVIGATION (0.9.0)
-----------------------------------------
The persistent HUD includes a player-centered north-up Mini Map built from ESO's
current map tiles and live UI API rather than a bundled third-party map database.

INTELLIGENCE MODES
- SMART: normal default; declutters POIs/trail/wayshrines automatically in combat
- QUEST: objective/waypoint-first navigation
- EXPLORE: emphasizes unfinished/current-map POIs plus a short breadcrumb trail
- GROUP: emphasizes teammates, group leader, rally point, quest, and waypoint
- MINIMAL: quest + waypoint only
- CUSTOM: honors all configured map layers

FLAGSHIP NAVIGATION FEATURES
- Adaptive zoom: slightly wider while mounted and tighter during combat
- Edge guidance: important off-screen quest/waypoint/rally/leader pins stay on edge
- Live current-map POIs prioritized by undiscovered/nearby/completion relevance
- Grid clustering and configurable POI density to limit icon spam
- Short fading movement breadcrumb trail
- Player waypoint, focused quest, wayshrines, group members, active companion, rally
- Group leader receives distinct emphasis
- N/E/S/W compass labels, optional coordinates, area name, and active mode badge
- Bottom context line can show destination bearing, group state, exploration count,
  and nearest unfinished POI direction/name
- Static POI enumeration is throttled; player/map motion updates stay responsive

The Mini Map and all EPC gameplay HUD elements hide when Pause, Character,
Inventory, Journal, Crafting, Store, Collections, or the full World Map is open.
They re-sync and return automatically after gameplay resumes.

Move it independently:
/esosuite minimap move
/esosuite minimap lock
/esosuite minimap reset
/esosuite minimap show | hide
/esosuite minimap mode smart|quest|explore|group|minimal|custom
/esosuite minimap zoom 0.70-2.00

Size, base zoom, opacity, map-art opacity, POI density, adaptive zoom, edge
guidance, and marker categories are configurable through optional LibAddonMenu.
Mouse-wheel zoom is available while Mini Map Move Mode is active.

The Mini Map is informational only. It never auto-travels, sets waypoints, moves
the character, targets units, or performs combat interactions.

PREMIUM UI / INTERACTION
------------------------
The interface now uses seven modules, role-aware accent themes, larger readable
cards, hover/pressed button states, a dedicated Utility Command Center, adaptive
content height, and the existing character-name header.

No default key is forced. Configure:
Esc > Controls > Keybindings > General > ESO Adventurer Suite

Show / Hide Coach
- Toggles the main command center.

Interact with Suite
- Opens/expands the coach if needed and enters ESO UI mouse mode so controls can
  be clicked during gameplay.
- Press the same key again or Esc to return to normal camera control.

When the main coach is hidden, the add-on intentionally does NOT show utility,
quest, inventory, or recommendation overlays. During combat only, the optional
compact role-aware combat HUD can appear so performance remains visible without
cluttering normal gameplay.

TARGET BUILD
------------
Choose AUTO, DAMAGE, HEALER, TANK, or SOLO target profiles. Optionally name two
specific item sets. Build completion considers available signals such as set
completion, traits, enchants, item quality, CP slottable coverage, and general
build readiness.

Examples:
/esosuite target damage
/esosuite targetset 1 Pillar of Nirn
/esosuite targetset 2 Order's Wrath

The score is a coaching checklist, not an authoritative meta ranking or a promise
that a character can clear particular veteran content.

TRAVEL SAFETY
-------------
Travel is never automatic. The player must choose a destination and separately
press TRAVEL. Direct wayshrine travel uses discovered/unlocked nodes. Social
travel uses ESO's normal Travel to Player functions and remains subject to ESO's
ownership, combat, campaign, instance, status, and access restrictions.

MARKET / MAP DATA LIMITS
------------------------
ESO Adventurer Suite does not bundle a web client, external market scraper, or
another add-on's proprietary database. Therefore:
- It does not claim universal live guild-trader prices.
- NPC sell-value estimates are not player-market prices.
- It does not ship a giant third-party map-pin database.
- Zone completion, skyshard, lore, set-collection, inventory, research, quest,
  combat, and travel information comes from ESO-exposed API data or local saved
  observations.

Future optional integrations with separately installed price/data add-ons can be
added without making them mandatory.

UPDATE COMPATIBILITY
--------------------
Compatibility.lua compares the running ESO API with the tested API and probes
major feature capabilities. If a changed API breaks one guarded module, the coach
tries to isolate that module rather than taking down the entire interface.

/esosuite frames move|lock|reset|show|hide
/esosuite minimap show|hide|move|lock|reset|zoom <0.70-2.00>
/esosuite hud move|lock|reset
/esosuite compat

This is compatibility awareness, not a self-updater. New code releases should be
distributed through ESOUI/Minion after ESO updates are tested.

COMMANDS
--------
/esosuite
/esosuite show | hide | toggle | interact
/esosuite codex
/esosuite clock show|hide|move|lock|reset
/esosuite lock | unlock | reset
/esosuite role auto|damage|healer|tank
/esosuite goal xp|gold|balanced
/esosuite focus auto|dps|gold|xp_cp|gear|dungeons|trials|solo|questing
/esosuite session continuous|30|60|120|custom
/esosuite target auto|damage|healer|tank|solo
/esosuite targetset 1 <set name>
/esosuite targetset 2 <set name>
/esosuite tools overview|inventory|research|collections|dailies
/esosuite scan
/esosuite find <item name>
/esosuite set <set name>
/esosuite hud move|lock|reset
/esosuite frames move|lock|reset|show|hide
/esosuite minimap show|hide|move|lock|reset|zoom <0.70-2.00>
/esosuite compat

INSTALLATION
------------
Extract the ESOAdventurerSuite folder into:
Documents/Elder Scrolls Online/live/AddOns/

The final manifest path must be:
Documents/Elder Scrolls Online/live/AddOns/ESOAdventurerSuite/ESOAdventurerSuite.txt

Before testing 0.17.1, remove the old AddOns/ESOProgressionCoach folder so both
packages do not load at once. Do NOT delete ESOProgressionCoachSavedVars; the new
package intentionally keeps that SavedVariables name so your existing settings
can migrate with the rename.

Keep your SavedVariables when upgrading so preferences, target settings, combat
bests, local quest history, inventory snapshots, Tamriel Codex notes/checkpoints, and HUD frame,
Stable Training, Clock, and Mini Map positions remain available.
LibAddonMenu-2.0 r43+, LibMapData, LibGPS 3.x, and LibMapPins-1.0 is required and should be installed separately
panel.

PRIVACY AND SECURITY
--------------------
- No executable files, DLLs, installers, or bundled external applications.
- No web/network calls or arbitrary local file access.
- No telemetry upload.
- ESO SavedVariables only for settings and local observations/snapshots.
- No movement, combat, casting, blocking, dodge, targeting, looting, crafting,
  buying, selling, trading, mail, quickslot, Champion assignment, research,
  deconstruction, item destruction, or chat automation.
- Travel occurs only after explicit player selection and TRAVEL click.
- ROUTE QUEST changes quest assistance/routing only; it does not complete travel.

PUBLIC BETA
-----------
Keep Advanced UI Errors enabled when testing a new release. If an error appears,
report the complete first error, current ESO API, selected module, and action that
triggered it.

ZeniMax / ESO DISCLAIMER
------------------------
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc.
or its affiliates. The Elder Scrolls® and related logos are registered trademarks
or trademarks of ZeniMax Media Inc. in the United States and/or other countries.
All rights reserved.


MOVABLE COMBAT HUD (0.6.2)
==========================
The hidden-state combat meter now shows all personal combat telemetry at once instead of hiding metrics based on role. Use /esosuite hud move to show a draggable preview, move it anywhere, then /esosuite hud lock. /esosuite hud reset returns it to the upper-right. Position, scale, and opacity persist in SavedVariables.


0.7.1 FRAMELESS HUD UPDATE
--------------------------
Persistent Player, Target, Group, Raid, and Live Stats frames now default to a
frameless floating style. Large dark panel backgrounds, member-row panels, and
stat-cell panels are hidden during normal gameplay. Health/Magicka/Stamina bar
tracks remain lightly shaded for readability. Target aura icons keep thin edges
without opaque tiles. Layout Mode temporarily restores faint panel hit areas so
frames are still easy to drag. A settings toggle can restore panel backgrounds.


QUEST DISCOVERY
Use the QUESTS tab or /esosuite quest <name/zone>. Version 0.12.0 replaces the old 20-entry curated browser with a runtime best-effort index of ESO quest records, scanned in small chunks to avoid a long UI stall. NOT STARTED excludes active and completed quest IDs. ESO does not provide one global iterator that says which unaccepted quest records are currently obtainable, so obsolete/internal records are filtered heuristically and the index should be treated as discovery guidance rather than an authoritative completion database. Active quests can be assisted directly; unstarted quests route toward their exposed zone, while accepting the quest still requires normal interaction with the quest giver/object.


AUTO MAINTENANCE (0.12.0)
-------------------------
The suite can automatically check equipped gear when entering and leaving combat. Equipped chargeable weapons below the configured charge threshold are recharged with filled soul gems from the backpack. Equipped armor below the configured condition threshold is repaired with repair kits from the backpack. Crown repair kits are protected from automatic use by default. Configure this under Settings > ESO Adventurer Suite > Automatic Equipment Maintenance, or run /esosuite maintain for a manual check.


STABLE TRAINING TIMER
---------------------
The movable Stable overlay is intentionally minimal: it shows only STABLE and the
riding-training cooldown. For example:

STABLE  18:42:07
STABLE  0

A value of 0 means a riding upgrade is available at a stable. If all three riding
stats are fully trained it displays STABLE  MAX. Toggle it in Settings > ESO
Adventurer Suite > Stable Training Timer.

0.12 INTERNAL COMPATIBILITY NOTE
--------------------------------
The public add-on name is ESO Adventurer Suite. The internal Lua namespace and
SavedVariables name remain ESOProgressionCoach / ESOProgressionCoachSavedVars so
existing local settings survive the rename. /esocoach remains as a legacy slash
alias, but new documentation uses /esosuite.


0.21.0 HUD/CODEX NOTES
- Player and Target effects are integrated directly into their matching ESO-style unit frames: buffs above Health and debuffs below Health.
- Stable shows only STABLE and the riding-training cooldown; 0 means training is available.
- Active Quest is a background-free movable and resizable text/objective overlay that follows the focused/tracked quest. Long quest names and objectives wrap to the chosen width. In HUD Layout Mode, drag the tracker to move it or use its edges/corners to resize it; the size is saved.
- The Tamriel Codex now uses a two-page book presentation with animated page turns.

NAMED CHECKPOINTS
-----------------
Tamriel Codex > Checkpoints can save named locations such as XP farms, resource routes, fishing spots, bosses, or other places you want to revisit. Type a name and press SAVE / UPDATE HERE while standing at the location. Selecting a saved checkpoint and pressing WAYPOINT restores the relevant map and places ESO's normal player waypoint at the stored coordinates.

Slash commands:
/esosuite checkpoint save Skyreach XP Farm
/esosuite checkpoint go Skyreach XP Farm
/esosuite checkpoint delete Skyreach XP Farm
/esosuite checkpoint list
/esosuite checkpoint open

A checkpoint is a saved map position/waypoint, not a direct teleport. Travel to it using ESO's normal movement, wayshrines, group travel, housing, or other game travel systems.


Update 0.24.79
- Tamriel Codex received an enhanced Figma-style glass redesign with a more advanced dashboard presentation, stronger navigation hierarchy, and premium translucent panel styling.


Update 0.24.86
- The Figma Codex can now be resized much smaller. Cyrodiil Elder Scroll pins prefer ESO native objective artwork and preserve native colors.


Update 0.24.87
- Dungeon Finder now lets you select a dungeon, choose Normal/Veteran and role, queue that dungeon, host a Group Finder listing, request replacements, and cancel the Activity Finder queue from the selected-side action panel.


Update 0.24.88
- Cleaned up Dungeon Finder selected-side spacing so queue/host controls no longer overlap dungeon details.


Update 0.24.89
- Gear & Sets opens a live equipment paper-doll overlay with armor, jewelry and both weapon bars.
- Switch between player and active companion gear where ESO exposes BAG_COMPANION_WORN.
- The panel refreshes as equipped items or the active weapon pair change.

Update 0.24.90
- Live Gear overlay now follows the active Codex/Figma theme accent.
- Companion mode resolves the active companion directly and shows its equipped BAG_COMPANION_WORN gear instead of silently falling back to Player.
- If no companion is active, the Companion view stays selected and clearly says to summon one.
- Player view identifies the actual current character by name, race, class, and level/Champion Points.
- ESO exposes race/gender silhouette art to addons, but not a stable arbitrary live 3D character model for a custom overlay, so the center remains an ESO silhouette with live equipment around it.



0.24.98 UPDATE
- Golden Pursuits detail action now reads TRAVEL / QUEST instead of OPEN ESO GOLDEN PURSUITS.
- The button tracks the selected pursuit, assists a matching journal quest when available, and routes to the nearest safe discovered wayshrine using the Suite's existing Golden Pursuits routing logic.



LIVE GROUP FINDER
------------------------
The GROUP FINDER Codex tab monitors ESO player-created listings with real-time event-driven updates, category cycling, Normal/Veteran switching where applicable, actual role counts, instanced-content short codes, and live empty-category monitoring.

Use /esosuite groupfinder or assign the Group Finder keybinds under Controls > Keybindings > General > ESO Adventurer Suite.


CURRENT-BUILD SKILL OPTIMIZER
- Skills & CP previews a recommended active skill bar from role, resource build, equipped weapons, worn sets, and unlocked/morphed abilities.
- RESPEC + BUILD uses ESO's current free, shrine-free skill respec flow to rebuild combat actives, choose the best available morphs when morph-ready, rank relevant passives, and fill both weapon bars (1-5 + Ultimate) from the detected current build. The complete build is staged first and requires one final confirmation before it is committed. Surplus points remain unspent.
