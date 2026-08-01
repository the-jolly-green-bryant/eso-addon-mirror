[size=6][b]LibArmorInsulation[/b][/size]
[i]by @Kreksar5 and Claude.ai[/i] · License: MIT

[color=orange][b]AI-ASSISTED ADDON.[/b][/color] Large portions of this addon's code (the costume/outfit scanning commands, the resolver priority logic, and several data-table structures) and its UESP-sourced costume/style insulation data were written with Claude.ai. Material/insulation assignments carry an explicit [confidence: high|medium|low] tag in LibArmorInsulation_StyleData.lua where applicable — "low"-confidence entries in particular are thematic inferences, not verified facts, and are good candidates for manual re-checking against UESP or in-game testing before being trusted as accurate.

A reusable ESO addon library that calculates a [b]staggered-tier thermal insulation score (-10 to 90, in steps of 10)[/b] for the player based on their current visual appearance — taking into account armor style, material composition, body-slot coverage, and flavor-text bonuses or penalties from the style database. The score mirrors ESO's own visual-priority rules: polymorphs beat costumes, costumes beat outfits, outfits beat worn armor.

For the full version history, see the Change Log tab, or CHANGELOG.md included in the download.

[size=5][b]Installation[/b][/size]

[list=1]
[*]Drop the LibArmorInsulation folder into [code]...\Elder Scrolls Online\live\AddOns\[/code]
[*]Ensure LibAddonMenu-2.0 is also installed (newest version — see Dependencies below).
[*]Enable the addon in the ESO Addon Manager.
[/list]

[size=5][b]Dependencies[/b][/size]

Please install the newest available version of each:

[list]
[*][b]LibAddonMenu-2.0[/b] — [b]Required.[/b] Settings panel only. The calculation API works without LAM, but the settings panel will be unavailable.
[*][b]LibStyleInfo[/b] — Not used. Its confirmed public API exposes style ID-to-name lookups and light/medium/heavy weight flags, but not material composition, body-coverage percentage, or flavor text.
[*][b]LibMotifCategories[/b] — Not used. Motif category data (crafted/overland/dungeon/etc.) does not map to thermal properties.
[/list]

[i]Why maintain an internal style database?[/i] Both evaluated libraries were ruled out because neither provides the material or coverage data needed for insulation math. LibArmorInsulation therefore ships its own hand-authored table keyed on ITEM_STYLE_* integer constants, which every ESO item carries natively.

[size=5][b]Insulation Model[/b][/size]

[size=4][b]Scale[/b][/size]

All values resolve to one of [b]eleven fixed tiers[/b], staggered in increments of 10 from [b]-10 to 90[/b]:

[list]
[*][b]-10[/b] Magically Cooled — magically cooled equipment (e.g. refrigeration)
[*][b]0[/b] No Insulation — no insulation
[*][b]10[/b] Minimal — underwear/swimwear
[*][b]20[/b] Light — light silks, breathable thin fabrics, or minimal coverage
[*][b]30[/b] Coarse Light — linens, coarser fabrics, or small amounts of leather with light coverage
[*][b]40[/b] Layered/Leather — thick or many-layered fabrics, or majority-coverage leathers
[*][b]50[/b] Full Leather/Light Metal — full coverage leathers, mild coverage metals, or full-coverage multi-layered thick fabrics
[*][b]60[/b] Heavy Leather/Fur — full coverage heavy/thick leathers, mild coverage furs, or moderate coverage metals
[*][b]70[/b] Full Fur/Metal — full coverage furs or full coverage metals
[*][b]80[/b] Heavy Fur/Metal — full coverage heavy furs and/or metals
[*][b]90[/b] Magically Heated — magically heated equipment
[/list]

-10 and 90 are reserved for entries explicitly flagged magical = true in the data tables (Flame Atronach, Ice Wraith, etc.). Every other entry is clamped to the mundane [b]0–80[/b] range before being snapped to the nearest tier, so ordinary armor and clothing can never accidentally read as magically hot or cold.

[i]Why a tier ladder instead of a continuous score?[/i] It's a much better fit for anything that has to display insulation — a UI can show one of 11 discrete states/icons instead of trying to render 101 shades of meaning. It's also easier to reason about and balance by hand.

[size=4][b]How an entry becomes a tier[/b][/size]

Armor styles and outfit style pieces keep their existing baseMaterial + coverage + flavorBonus authoring fields. The Calculator computes the same full-body reference score it always has, then snaps that score onto the nearest tier:

[code]
raw  = 0.90 x styleCoverage x materialCoeff x SCALE_FACTOR + flavorBonus
tier = SnapToTier(raw, magical)   -- nearest of {-10,0,10,...,80,90}
       -- clamped to [0,80] first unless the entry has magical = true
[/code]

SCALE_FACTOR = 55.556 — anchors a full set of standard leather armor at coverage 1.0 to exactly tier 50.

Costumes and polymorphs keep their existing hand-authored totalInsulation field, which is likewise snapped to the nearest tier at lookup time (again clamped to 0–80 unless magical = true).

[size=4][b]Per-slot percentage adjustment (unless it's a full costume)[/b][/size]

A style/outfit piece's tier is its [b]full-body reference value[/b]. Individual armor/outfit slots then contribute a [b]percentage[/b] of that tier based on how much of the body they cover:

[code]
slot_contribution = round(tier x slotPercentage)
total             = sum(slot_contribution for every worn slot)
[/code]

Slot percentages sum to exactly [b]1.00[/b] across the 7 thermally-relevant slots, so a full matching set (every slot the same tier) reproduces that tier as the total. Missing slots count as bare skin (tier 0) for that percentage of the body.

[b]Costumes and polymorphs are NOT slot-adjusted.[/b] They represent the whole body at once, so their snapped tier is the total, unadjusted.

[size=4][b]Slot coverage weights[/b][/size]

[list]
[*]Chest — 33%
[*]Legs — 28%
[*]Head — 11%
[*]Shoulders — 11%
[*]Hands — 6%
[*]Feet — 6%
[*]Waist — 5%
[*]Rings, Neck, Weapons — 0%
[/list]

[size=4][b]Material coefficients[/b][/size]

[list]
[*]fur — 1.8 (full-set reference 90, snaps to 80, mundane cap)
[*]wool — 1.5 (75 → 70, tie rounds down)
[*]heavy_leather — 1.3 (65 → 60, tie rounds down)
[*]leather — 1.0 (50, baseline)
[*]scale — 0.8 (40)
[*]runic — 0.8 (40)
[*]bone — 0.7 (35 → 30, tie rounds down)
[*]cloth — 0.7 (35 → 30, tie rounds down)
[*]chitin — 0.6 (30)
[*]hide — 0.6 (30)
[*]iron — 0.5 (25 → 20, tie rounds down)
[*]steel — 0.5 (25 → 20, tie rounds down)
[*]silk — 0.5 (25 → 20, tie rounds down)
[*]linen — 0.4 (20)
[*]aetherial — 0.4 (20)
[*]daedric — 0.3 (15 → 10, tie rounds down)
[*]crystal — 0.2 (10)
[*]none — 0.0 (0)
[/list]

Ties (raw score exactly halfway between two tiers) round [b]down[/b] to the lower tier. "Full-set reference" assumes coverage 1.0 and no flavor bonus; per-style coverage/flavorBonus modifiers shift the raw score before it's snapped.

[size=4][b]Costume & polymorph scoring[/b][/size]

Costumes and polymorphs bypass per-slot math entirely. They return a single snapped tier looked up from CostumeInsulationById (by collectible ID), then CostumeInsulation (by normalized lowercase name), then the appropriate default:

[list]
[*]DEFAULT_COSTUME — raw default 50, snapped tier 50
[*]DEFAULT_POLYMORPH — raw default 38, snapped tier 40
[/list]

[b]Costume lookup priority:[/b] user override (already a tier — used as-is) → CostumeInsulationById (by collectible ID) → CostumeInsulation (by name, manually curated) → sv.costumeCache (populated by /scancostumes) → DEFAULT_COSTUME. Run /scancostumes to populate the cache with keyword-derived auto-ratings for anything not already in the manual tables.

[size=5][b]Visual Priority Cascade[/b][/size]

GetTotalInsulation() and GetInsulationBreakdown() mirror ESO's own visual priority rules, evaluated top-to-bottom:

[list=1]
[*][b]Polymorph[/b] — detected via GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME) combined with keyword/ID matching against polymorph entries. Returns a flat body-wide score; slot math is skipped.
[*][b]Costume[/b] — same detection mechanism. Returns a flat body-wide score; slot math is skipped.
[*][b]Active Outfit[/b] — detected via GetEquippedOutfitIndex(). Slot insulation is calculated from the collectible ID on each OUTFIT_SLOT_* using ZO_OUTFIT_MANAGER. Only slots with a non-zero style override contribute; if no outfit slots are overridden, falls through to armor.
[*][b]Worn Armor[/b] — calls GetItemLink(BAG_WORN, equipSlot) then GetItemLinkItemStyle(itemLink) for each thermally relevant EQUIP_SLOT_*. GetItemLinkItemStyle is used (not GetItemStyle) because it returns the correct visual style for all item origins — crafted, dropped, set, and Crown Store items alike.
[*][b]Naked[/b] — returns 0.
[/list]

[size=5][b]Public API[/b][/size]

[code]
-- Total insulation score, one of the 11 tiers for costume/polymorph;
-- a composite (-10..90) for armor/outfit made of per-slot tier contributions
local total = LibArmorInsulation.GetTotalInsulation()

-- Full breakdown table
local info = LibArmorInsulation.GetInsulationBreakdown()
-- info.source       : "polymorph" | "costume" | "outfit" | "armor" | "naked"
-- info.total        : integer, -10..90
-- info.slots        : table {
--                       [slotKey] = {
--                         styleId,        -- ITEM_STYLE_* (armor path) or nil
--                         styleName,      -- resolved armor style name (from the game's own
--                                         -- GetItemStyleName/StyleNameById map), or nil.
--                                         -- Populated even when the style isn't one of the
--                                         -- entries LibArmorInsulation's data tables recognize.
--                         collectibleId,  -- collectible ID (outfit/costume/polymorph path) or nil
--                         name,           -- resolved outfit/costume/polymorph collectible name
--                                         -- (from GetCollectibleName), or nil. Likewise populated
--                                         -- regardless of data-table recognition.
--                         insulation,     -- integer slot contribution (== tier for costume/polymorph)
--                         tier,           -- the style/costume's own full-body tier (-10..90)
--                         slotPercentage, -- 0-1 weight of this slot; nil for costume/polymorph
--                         material,       -- string material key
--                         flavorNote,     -- string human-readable note, or ""
--                         armorFallback,  -- boolean: true if outfit slot fell back to worn armor
--                       }
--                     }
-- info.costumeId    : number | nil   (collectible ID of active costume/polymorph)
-- info.costumeName  : string | nil   (lower-cased collectible name)

-- Full-set reference tier for a given ITEM_STYLE_* id (respects overrides)
-- Returns one of {-10,0,10,20,30,40,50,60,70,80,90}
local tier = LibArmorInsulation.GetInsulationForStyle(styleId)

-- Set a persisted insulation override — one of the 11 tier values
-- idType : "style"   -> ITEM_STYLE_* integer  (worn armor)
--          "outfit"  -> collectible ID         (outfit slot piece)
--          "costume" -> collectible ID         (costume or polymorph)
-- value = nil removes the override. Non-tier numbers are snapped to the
-- nearest tier rather than rejected. In the Settings panel this is always a
-- dropdown, so it can't drift off-tier.
LibArmorInsulation.SetOverride(idType, id, value)

-- Remove all user overrides (does not clear the costume cache)
LibArmorInsulation.ResetOverrides()
[/code]

[size=4][b]Constants[/b][/size]

[code]
LibArmorInsulation.VERSION    -- e.g. "2.7.6"
LibArmorInsulation.ADDON_NAME -- "LibArmorInsulation"
[/code]

[size=4][b]Saved variables schema (account-wide, per-server)[/b][/size]

[code]
sv.overrides    -- { ["style_N" | "outfit_N" | "costume_N"] = tier integer (-10..90) }
sv.costumeCache -- { [collectibleId] = { name, insulation, autoRated } }
                -- Populated by /scancostumes; persists across sessions.
                -- `insulation` here is a pre-snap raw value, snapped to the
                -- nearest tier at lookup time.
[/code]

Override keys follow the pattern <idType>_<id> (e.g. style_42, outfit_1234567, costume_9876543). This unified key space means a single SetOverride call handles all three entity types without ambiguity.

[size=5][b]Slash Commands[/b][/size]

[size=4][b]General[/b][/size]
[list]
[*][b]/insulation[/b] — Prints the current source, total score with its nearest tier label, and per-slot breakdown — style/collectible ID, insulation contribution, tier, slot percentage, material — to chat.
[*][b]/styleids[/b] — Prints the ITEM_STYLE_* ID worn in each armor slot. Use this to find the ID to enter in the override editor when working with worn armor.
[/list]

[size=4][b]Outfit commands[/b][/size]
[list]
[*][b]/outfitids[/b] — Prints the collectible ID and name applied to each slot of every styled outfit. Use this to find the collectible ID to enter as an outfit_ override.
[*][b]/outfitactive[/b] — Diagnostic — probes free functions and outfitManipulator methods to determine whether each outfit is actively equipped versus merely stored. Run with an outfit equipped, then unequipped, and compare output.
[*][b]/scanoutfitstyles[/b] — Walks every equipped slot across all unlocked outfits and, for any collectible ID not already in the hand-curated OutfitStyles table, keyword-rates it (by name, then description) and saves a guessed material/coverage/flavor set to sv.outfitStyleCache. Run this after unlocking/equipping a new style page.
[/list]

[size=4][b]Costume & polymorph commands[/b][/size]
[list]
[*][b]/costumeids[/b] — Prints the collectible ID, display name, and current lookup method (user override / ID table / name table / DEFAULT_COSTUME) for the active costume or polymorph. Also prints the override key (costume_<id>) to use in the settings panel.
[*][b]/scancostumes[/b] — Walks every owned costume and polymorph in the Collections system and assigns a keyword-derived auto-rating to each (checking the name first, then the in-game description if the name has no match), saving the results in sv.costumeCache. Run this once — and again after acquiring new costumes.
[*][b]/clearcostumecache[/b] — Removes all entries from sv.costumeCache. Re-run /scancostumes afterward to repopulate.
[/list]

[size=4][b]Review commands[/b][/size]
[list]
[*][b]/costumesneedreview[/b] — Filters sv.costumeCache down to entries where the keyword scan found no match in either the name or description (sitting on the generic 50 default). Use this as a worklist for manual UESP-backed CostumeInsulationById entries.
[*][b]/outfitstylesneedreview[/b] — Same as /costumesneedreview, but for sv.outfitStyleCache entries with no keyword match. Use as a worklist for manual OutfitStyles entries.
[/list]

[size=4][b]Diagnostic commands[/b][/size]
[list]
[*][b]/diagcollectibles[/b] — Three-phase diagnostic that enumerates every collectible category and subcategory, identifies which one ESO marks as COLLECTIBLE_CATEGORY_TYPE_COSTUME, and reports the first reachable collectible per category. Run this and share the output if /scancostumes finds 0 costumes.
[/list]

[size=5][b]Settings Panel[/b][/size]

Accessible via [b]Addon Settings[/b] in the ESO main menu.

[list]
[*][b]Current Insulation[/b] — Live breakdown of every slot's contribution, tier, slot percentage, the source (outfit / armor / costume / polymorph), material, and any flavor note. Press Refresh to recalculate.
[*][b]Manual Overrides[/b] — Pick a Layer (Costume/Polymorph, Outfit, or Armor) and, for Outfit/Armor, a Slot — each selection does a fresh live lookup of that specific layer/slot and auto-fills Override Type/ID/Tier with it. Adjust the Tier if you like, then press Apply Override. Choosing "(no override)" removes an existing override.
[*][b]Active Overrides[/b] — Lists all currently active overrides with their keys, tier values, and tier labels.
[*][b]Reset[/b] — Reset All Overrides removes every override and reverts to database defaults. The costume cache is not affected.
[/list]

[i]Tip: Use /styleids to find worn armor style IDs, /outfitids for outfit collectible IDs, and /costumeids for the active costume's collectible ID before entering values in the override editor.[/i]

[size=5][b]Adding / Editing Style Data[/b][/size]

All style data lives in LibArmorInsulation_StyleData.lua, under LibArmorInsulation.Data.

[size=4][b]Armor styles (LibArmorInsulation.Data.Styles)[/b][/size]

Keys are ITEM_STYLE_* integer constants. Full list: [url=https://wiki.esoui.com/ItemStyle]wiki.esoui.com/ItemStyle[/url]

[code]
[styleId] = {
    baseMaterial = "leather",  -- string key from MaterialCoefficient table
    coverage     = 1.0,        -- style-level coverage modifier
    flavorBonus  = 0,          -- flat integer bonus/penalty (can be negative)
    flavorNote   = "",         -- human-readable reason shown in settings & /insulation
},
[/code]

Any style not in the table falls back to ["DEFAULT"] (leather, coverage 1.0, no bonus → score 50).

[size=4][b]Outfit styles (LibArmorInsulation.Data.OutfitStyles)[/b][/size]

Keys are [b]collectible IDs[/b] (Collections system integers), not ITEM_STYLE_* values. The two number spaces are unrelated. Use /outfitids to find collectible IDs.

[code]
[collectibleId] = {
    baseMaterial = "leather",
    coverage     = 1.0,
    flavorBonus  = 0,
    flavorNote   = "",
},
[/code]

Falls back to ["DEFAULT"] (leather, coverage 0.9).

[size=4][b]Costume & polymorph entries (LibArmorInsulation.Data.CostumeInsulationById and CostumeInsulation)[/b][/size]

CostumeInsulationById is keyed by collectible ID (preferred); CostumeInsulation is keyed by lowercase display name (legacy fallback). Both use flat totalInsulation values.

[code]
[collectibleId] = { totalInsulation = 72, flavorNote = "Heavy bear-fur costume" },
-- or by name:
["worm cult robes"] = { totalInsulation = 30, flavorNote = "Thin ceremonial cloth" },
[/code]

Special keys ["DEFAULT_COSTUME"] (50) and ["DEFAULT_POLYMORPH"] (38) are the last-resort fallbacks.

[size=5][b]ESO API Functions Used[/b][/size]

[list]
[*]GetActiveCollectibleByType(type) — Detect active costume / polymorph
[*]GetCollectibleName(id) — Resolve collectible display name for data lookup
[*]GetCollectibleId(catIndex, subIndex, index) — Iterate collectibles for costume scanning
[*]GetCollectibleInfo(id) — Read unlock state during /scancostumes
[*]GetNumCollectibleCategories() — Enumerate categories in /diagcollectibles
[*]GetCollectibleCategoryInfo(catIndex) — Get category name in /diagcollectibles
[*]GetEquippedOutfitIndex() — Detect whether an outfit is actively worn (confirmed in-game)
[*]GetNumUnlockedOutfits() — Count unlocked outfits (takes no arguments)
[*]GetOutfitName(outfitIndex) — Outfit display name for /outfitids
[*]ZO_OUTFIT_MANAGER:GetOutfitManipulator(actorCategory, outfitIndex) — Access outfit slot data (actorCategory is required)
[*]outfitManipulator:GetSlotManipulator(OUTFIT_SLOT_*) — Access individual outfit slots
[*]slotManipulator:GetCurrentCollectibleId() — Collectible ID on a given outfit slot
[*]GetItemLink(bagId, slotIndex, linkStyle) — Item link string for a worn equipment slot
[*]GetItemLinkItemStyle(itemLink) — Visual style ID for any item regardless of origin
[*]BAG_WORN — Constant — the equipped item bag
[*]EQUIP_SLOT_* — Equipment slot constants
[*]OUTFIT_SLOT_* — Outfit slot constants
[*]COLLECTIBLE_CATEGORY_TYPE_COSTUME — Collectible category constant
[*]GetWorldName() — Identifies EU/NA/PTS for server-namespaced saved variables
[*]ZO_SavedVars:NewAccountWide(...) — Account-wide saved variables
[*]EVENT_MANAGER:RegisterForEvent(...) — Addon load event
[*]CHAT_SYSTEM:AddMessage(...) — Chat output
[*]SLASH_COMMANDS[...] — Slash command registration
[*]LibAddonMenu2:RegisterAddonPanel(...) — Settings panel registration (LAM)
[*]LibAddonMenu2:RegisterOptionControls(...) — Settings controls (LAM)
[/list]

[i]GetItemLinkItemStyle vs GetItemStyle:[/i] GetItemStyle() only returns non-zero for player-crafted items; every dropped, set, or Crown Store piece returns ITEM_STYLE_NONE (0). GetItemLinkItemStyle(itemLink) returns the correct visual style for all item origins and is the correct choice here.

[i]GetNumUnlockedOutfits():[/i] Takes no arguments. A GameplayActorCategory parameter does not exist on this function. GetNumOutfits() is not a real ESO API function and will crash with "function expected instead of nil".

[i]GetEquippedOutfitIndex():[/i] The correct gate for the outfit path. Confirmed working in-game; returns the 1-based index of the worn outfit, or nil if none.

[size=5][b]Design Notes & Limitations[/b][/size]

[b]No per-item flavor text scraping.[/b] ESO does not provide a Lua API to read raw item flavor text at runtime (the tooltip system renders it as formatted strings, not structured data). The flavorBonus values in the style database are therefore authored by hand based on in-game style descriptions and motif book lore.

[b]Item set names are ignored.[/b] The library uses only the base ITEM_STYLE_* of each piece, not the set it belongs to. Set bonuses are mechanical gameplay systems unrelated to visual insulation.

[b]Outfit "no override" slots fall through.[/b] If a player has an outfit active but has not overridden every slot, only overridden slots contribute from the outfit source. If no outfit slots are overridden, the library falls through to worn armor styles entirely.

[b]Costume vs. outfit visual conflict.[/b] If a player has both a costume collectible active and an outfit applied, the costume wins visually in-game (costumes always take priority). LibArmorInsulation mirrors this by detecting costumes before outfits.

[b]Polymorphs override costumes.[/b] A polymorph replaces the entire character model. LibArmorInsulation checks for polymorphs before costumes, consistent with ESO's in-game visual priority.

[b]Outfit collectible IDs ≠ ITEM_STYLE_* IDs.[/b] Outfit slots yield Collections-system collectible IDs, an entirely separate number space from ITEM_STYLE_* integers. The library maintains separate lookup tables (OutfitStyles and Styles) for this reason, and the override key prefix (outfit_ vs style_) distinguishes them in saved variables.

[b]Costume cache is opt-in.[/b] The sv.costumeCache table is only populated when you run /scancostumes. Until then, unrecognized costumes fall back to DEFAULT_COSTUME (50). Cache entries persist across sessions.

[b]Saved variables, server-namespaced.[/b] Saved variables are namespaced per server (EU/NA/PTS) via GetWorldName(), so overrides and caches don't overwrite each other across servers. The upgrade path from v3 preserves existing overrides and costumeCache, and adds the missing outfitStyleCache table; from v2, preserves overrides and adds both cache tables. Saves from v1 are reset to defaults to avoid schema conflicts.

[size=5][b]License[/b][/size]

MIT — free to use, modify, and redistribute with attribution.
