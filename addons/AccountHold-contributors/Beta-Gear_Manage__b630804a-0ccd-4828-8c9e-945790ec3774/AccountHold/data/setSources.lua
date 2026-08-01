-- AccountHold/data/setSources.lua
-- Bundled set-source database (contract A). Set id -> where that set drops.
--
-- =============================================================================
-- WHY THIS FILE EXISTS AT ALL
-- =============================================================================
-- ESO does not expose set acquisition locations to add-ons. The Item Set
-- Collections API can tell us which PIECES exist and which are unlocked, but
-- GetItemSetCollectionPieceInfo(itemSetId, index) returns only `pieceId, slot`
-- (ESOUIDocumentation.txt :17906) -- no zone, no activity, no source. There is
-- no other accessor that answers "where does this drop?". Epics 0002 and 0005
-- reached that conclusion independently.
--
-- So the mapping has to ship WITH the add-on and be maintained BY HAND. That
-- makes this file the one place in the code base where a plausible-looking typo
-- has a real-world cost: a wrong entry sends a player to farm the wrong dungeon
-- for an evening. Treat it accordingly.
--
-- =============================================================================
-- THE RULE: OMISSION IS SAFE, A WRONG ENTRY IS NOT
-- =============================================================================
-- A set that is absent here is handled honestly: SetSources:IsUnknown returns
-- true and both consuming epics are required to surface an explicit
-- "source unknown" row rather than silently dropping the set (0005 acceptance
-- criteria; contract B). Nothing breaks, and the player is told the truth.
--
-- A set that is present but WRONG is invisible -- it looks exactly like a
-- correct entry and the player only finds out after wasting the evening.
--
-- Therefore: if you cannot corroborate BOTH the numeric set id AND the drop
-- location, LEAVE THE SET OUT. Coverage is not the goal; correctness is. This
-- seed intentionally covers 31 sets, not the ~900 that exist.
--
-- =============================================================================
-- HOW TO ADD AN ENTRY
-- =============================================================================
-- 1. Find the numeric itemSetId AND its English name in a machine-readable
--    source (see PROVENANCE below). Do not guess an id from the set's name --
--    the ids are not ordered, not contiguous, and several sets have very
--    similar names.
-- 2. Corroborate the DROP LOCATION in a second, independent source (the UESP
--    dungeon page's "Sets" table). One source establishes the id, the other
--    establishes the place. If the two disagree, stop and leave the set out.
-- 3. Reuse the shared activity constant if the activity already exists below;
--    only add a new constant for an activity that is not yet listed.
-- 4. Add `[setId] = ACTIVITY` (or `{ ACTIVITY_A, ACTIVITY_B }` when the set
--    genuinely drops in more than one place), with a trailing comment naming
--    the set so the table is readable without a lookup.
-- 5. Every record MUST carry a `citation`. An entry without one cannot be
--    re-verified later and is indistinguishable from a guess.
--
-- Record shape (contract A -- frozen, do not add or rename fields here; a
-- consumer may see records from a future generated file and must ignore any
-- field it does not know):
--
--     activityKey  = "dungeon:fungal_grotto_1"  -- STABLE id, used for de-dup
--     activityName = "Fungal Grotto I"          -- display text
--     activityType = "dungeon"                  -- frozen enum, see below
--     zoneName     = "Stonefalls"               -- travel lookup; may be nil
--     citation     = "libsets:z283+uesp:..."    -- provenance, REQUIRED
--
-- activityType is exactly one of:
--   "dungeon" | "trial" | "arena" | "overland" | "crafted" | "pvp" | "other"
-- SetSources coerces anything else to "other" so a typo here can never reach a
-- consumer's icon/type switch as an unexpected value.
--
-- activityKey is the de-duplication key and is effectively permanent: it is
-- what the rollup groups on, so changing one silently splits an activity in two
-- for anyone holding a saved plan. Display names may be corrected freely.
--
-- activityName is English. Localizing it would mean resolving the zone name
-- from a zone id at runtime, which is a different (and much larger) piece of
-- work; the epics ship English activity names in v1. Do NOT route these through
-- AccountHold.L -- this file must stay dependency-free and load before anything
-- else (contract A).
--
-- =============================================================================
-- PROVENANCE OF THIS SEED
-- =============================================================================
-- Every entry below was verified against TWO independent sources:
--
--   (1) IDS AND NAMES -- LibSets by @Baertram, the community set database.
--       Read directly from branch `LibSets-reworked`, pinned commit
--       76f2adab4e495f0b3ddb9884cb10c47f32e9f4b1 (its own header states
--       "Last updated: API 101050, 2026-05-25"):
--         LibSets/Data/LibSets_Data_SetNames.lua  -- [setId] = { ["en"] = name }
--         LibSets/Data/LibSets_Data_Sets.lua      -- [setId] = { zoneIds, setType, dlcId, ... }
--         LibSets/Data/LibSets_Data_Zones.lua     -- [dungeonZoneId] = { parentZoneId, ... }
--       LibSets is CC BY-NC-ND 4.0. Nothing from it is copied or redistributed
--       here: the ~31 numeric ids below are cited as facts and were each
--       re-checked against source (2). Credit: https://github.com/Baertram/LibSets
--
--   (2) DROP LOCATIONS -- the UESP wiki page for each dungeon, specifically its
--       "Sets" table. A set was only seeded when the UESP page for the activity
--       lists that set by name. Citation slugs below are page titles under
--       https://en.uesp.net/wiki/Online:<slug>.
--
-- Derivation rule used for LibSets `zoneIds` (worth writing down, because the
-- field is easy to misread): a set's zoneIds list mixes DUNGEON zone ids with
-- the containing OVERLAND zone ids, and sometimes carries trailing overland ids
-- whose meaning we could not establish. Only ids that resolve to a dungeon in
-- LibSets_Data_Zones.lua were treated as activities; overland ids were used for
-- `zoneName` only, via the dungeon's own parentZoneId. That rule reproduced the
-- UESP "Sets" tables exactly for all 31 sets, including every I/II pair, which
-- is why it is trusted here -- and why the unexplained trailing ids are ignored
-- rather than guessed at.
--
-- The citation string is `libsets:z<dungeonZoneId>+uesp:<page slug>`. Both
-- halves are needed: LibSets pins the id, UESP pins the place.
--
-- =============================================================================
-- MULTI-ACTIVITY SETS
-- =============================================================================
-- Several base-game sets drop in BOTH the original dungeon and its "II"
-- counterpart -- these are separate dungeons with separate group finder
-- entries, not difficulty modes, so they are two distinct activities. UESP
-- states it outright on Darkshade Caverns I: "The following item sets will drop
-- both Darkshade Caverns I and II: Armor of Truth, Netch's Touch, and Strength
-- of the Automaton."
--
-- Those sets map to an ARRAY of records. The rollup credits the set's full
-- outstanding count to EACH listed activity, because either one can drop the
-- piece -- see the note on SetSources:RollupActivities before "fixing" it.
--
-- =============================================================================
-- BULK IMPORT (this file is expected to be generated one day)
-- =============================================================================
-- The shape below is deliberately importer-friendly: shared activity constants
-- + a flat `[setId] = record | { record, ... }` map. A generator should emit
-- the same two-part layout so hand edits and generated output stay diffable.
-- Note that Lua silently keeps only the LAST value for a duplicated key, so a
-- generator MUST reject duplicate set ids itself; nothing at runtime can detect
-- them. Source files and the derivation rule are listed under PROVENANCE.
--
-- =============================================================================

AccountHold = AccountHold or {}

-- Activity records are SHARED between sets (16 dungeons here are referenced by
-- 31 sets, and a generated file would share far more aggressively). Two
-- consequences worth knowing:
--   * fixing a dungeon's display name is a one-line change, and
--   * these tables are READ-ONLY. SetSources hands them out by reference
--     rather than copying, so mutating one would corrupt every set that shares
--     it. Nothing in the add-on writes to them; the rollup copies fields into
--     fresh tables.

local FUNGAL_GROTTO_1 = {
    activityKey = "dungeon:fungal_grotto_1", activityName = "Fungal Grotto I",
    activityType = "dungeon", zoneName = "Stonefalls",
    citation = "libsets:z283+uesp:Fungal_Grotto_I",
}
local FUNGAL_GROTTO_2 = {
    activityKey = "dungeon:fungal_grotto_2", activityName = "Fungal Grotto II",
    activityType = "dungeon", zoneName = "Stonefalls",
    citation = "libsets:z934+uesp:Fungal_Grotto_II",
}
local SPINDLECLUTCH_1 = {
    activityKey = "dungeon:spindleclutch_1", activityName = "Spindleclutch I",
    activityType = "dungeon", zoneName = "Glenumbra",
    citation = "libsets:z144+uesp:Spindleclutch_I",
}
local SPINDLECLUTCH_2 = {
    activityKey = "dungeon:spindleclutch_2", activityName = "Spindleclutch II",
    activityType = "dungeon", zoneName = "Glenumbra",
    citation = "libsets:z936+uesp:Spindleclutch_II",
}
local ELDEN_HOLLOW_1 = {
    activityKey = "dungeon:elden_hollow_1", activityName = "Elden Hollow I",
    activityType = "dungeon", zoneName = "Grahtwood",
    citation = "libsets:z126+uesp:Elden_Hollow_I",
}
local ELDEN_HOLLOW_2 = {
    activityKey = "dungeon:elden_hollow_2", activityName = "Elden Hollow II",
    activityType = "dungeon", zoneName = "Grahtwood",
    citation = "libsets:z931+uesp:Elden_Hollow_II",
}
local WAYREST_SEWERS_1 = {
    activityKey = "dungeon:wayrest_sewers_1", activityName = "Wayrest Sewers I",
    activityType = "dungeon", zoneName = "Stormhaven",
    citation = "libsets:z146+uesp:Wayrest_Sewers_I",
}
local WAYREST_SEWERS_2 = {
    activityKey = "dungeon:wayrest_sewers_2", activityName = "Wayrest Sewers II",
    activityType = "dungeon", zoneName = "Stormhaven",
    citation = "libsets:z933+uesp:Wayrest_Sewers_II",
}
local BANISHED_CELLS_1 = {
    activityKey = "dungeon:banished_cells_1", activityName = "The Banished Cells I",
    activityType = "dungeon", zoneName = "Auridon",
    citation = "libsets:z380+uesp:The_Banished_Cells_I",
}
local BANISHED_CELLS_2 = {
    activityKey = "dungeon:banished_cells_2", activityName = "The Banished Cells II",
    activityType = "dungeon", zoneName = "Auridon",
    citation = "libsets:z935+uesp:The_Banished_Cells_II",
}
local DARKSHADE_CAVERNS_1 = {
    activityKey = "dungeon:darkshade_caverns_1", activityName = "Darkshade Caverns I",
    activityType = "dungeon", zoneName = "Deshaan",
    citation = "libsets:z63+uesp:Darkshade_Caverns_I",
}
local DARKSHADE_CAVERNS_2 = {
    activityKey = "dungeon:darkshade_caverns_2", activityName = "Darkshade Caverns II",
    activityType = "dungeon", zoneName = "Deshaan",
    citation = "libsets:z930+uesp:Darkshade_Caverns_II",
}
local CRYPT_OF_HEARTS_1 = {
    activityKey = "dungeon:crypt_of_hearts_1", activityName = "Crypt of Hearts I",
    activityType = "dungeon", zoneName = "Rivenspire",
    citation = "libsets:z130+uesp:Crypt_of_Hearts_I",
}
local CRYPT_OF_HEARTS_2 = {
    activityKey = "dungeon:crypt_of_hearts_2", activityName = "Crypt of Hearts II",
    activityType = "dungeon", zoneName = "Rivenspire",
    citation = "libsets:z932+uesp:Crypt_of_Hearts_II",
}
local CITY_OF_ASH_1 = {
    activityKey = "dungeon:city_of_ash_1", activityName = "City of Ash I",
    activityType = "dungeon", zoneName = "Greenshade",
    citation = "libsets:z176+uesp:City_of_Ash_I",
}
local CITY_OF_ASH_2 = {
    activityKey = "dungeon:city_of_ash_2", activityName = "City of Ash II",
    activityType = "dungeon", zoneName = "Greenshade",
    citation = "libsets:z681+uesp:City_of_Ash_II",
}
local DIREFROST_KEEP = {
    activityKey = "dungeon:direfrost_keep", activityName = "Direfrost Keep",
    activityType = "dungeon", zoneName = "Eastmarch",
    citation = "libsets:z449+uesp:Direfrost_Keep",
}
local SELENES_WEB = {
    activityKey = "dungeon:selenes_web", activityName = "Selene's Web",
    activityType = "dungeon", zoneName = "Reaper's March",
    citation = "libsets:z31+uesp:Selene's_Web",
}
local BLESSED_CRUCIBLE = {
    activityKey = "dungeon:blessed_crucible", activityName = "Blessed Crucible",
    activityType = "dungeon", zoneName = "The Rift",
    citation = "libsets:z64+uesp:Blessed_Crucible",
}
local VOLENFELL = {
    activityKey = "dungeon:volenfell", activityName = "Volenfell",
    activityType = "dungeon", zoneName = "Alik'r Desert",
    citation = "libsets:z22+uesp:Volenfell",
}
local VAULTS_OF_MADNESS = {
    activityKey = "dungeon:vaults_of_madness", activityName = "Vaults of Madness",
    activityType = "dungeon", zoneName = "Coldharbour",
    citation = "libsets:z11+uesp:Vaults_of_Madness",
}
local TEMPEST_ISLAND = {
    activityKey = "dungeon:tempest_island", activityName = "Tempest Island",
    activityType = "dungeon", zoneName = "Malabal Tor",
    citation = "libsets:z131+uesp:Tempest_Island",
}
local ARX_CORINIUM = {
    activityKey = "dungeon:arx_corinium", activityName = "Arx Corinium",
    activityType = "dungeon", zoneName = "Shadowfen",
    citation = "libsets:z148+uesp:Arx_Corinium",
}
local BLACKHEART_HAVEN = {
    activityKey = "dungeon:blackheart_haven", activityName = "Blackheart Haven",
    activityType = "dungeon", zoneName = "Bangkorai",
    citation = "libsets:z38+uesp:Blackheart_Haven",
}

-- [setId] = record | { record, ... }
--
-- Grouped by activity because that is how it is maintained: you almost always
-- add "another set from a dungeon already listed". Trailing comments carry the
-- English set name from LibSets_Data_SetNames.lua so the table can be read and
-- audited without a second lookup. Sets whose id we could not corroborate are
-- deliberately absent -- e.g. UESP lists Spider Cultist Cowl for Fungal Grotto
-- I, Spelunker for Spindleclutch I and Draugr Hulk for Direfrost Keep, but none
-- of those ids surfaced in the LibSets data read, so they are left unknown
-- rather than guessed.
AccountHold.SetSourcesData = {

    -- Arx Corinium (Shadowfen)
    [156] = ARX_CORINIUM,                                 -- Undaunted Infiltrator

    -- Blackheart Haven (Bangkorai)
    [157] = BLACKHEART_HAVEN,                             -- Undaunted Unweaver

    -- Blessed Crucible (The Rift)
    [46]  = BLESSED_CRUCIBLE,                             -- Noble Duelist's Silks
    [72]  = BLESSED_CRUCIBLE,                             -- Nikulas' Heavy Armor

    -- City of Ash I + II (Greenshade)
    [158] = { CITY_OF_ASH_1, CITY_OF_ASH_2 },             -- Embershield
    [159] = { CITY_OF_ASH_1, CITY_OF_ASH_2 },             -- Sunderflame
    [160] = { CITY_OF_ASH_1, CITY_OF_ASH_2 },             -- Burning Spellweave

    -- Crypt of Hearts I + II (Rivenspire)
    [122] = { CRYPT_OF_HEARTS_1, CRYPT_OF_HEARTS_2 },     -- Ebon Armory
    [134] = { CRYPT_OF_HEARTS_1, CRYPT_OF_HEARTS_2 },     -- Shroud of the Lich

    -- Darkshade Caverns I + II (Deshaan)
    [96]  = { DARKSHADE_CAVERNS_1, DARKSHADE_CAVERNS_2 }, -- Armor of Truth

    -- Direfrost Keep (Eastmarch)
    -- UESP's set table spells 53 "Ice Furnace"; LibSets carries the in-game
    -- English name "The Ice Furnace". Same set, same dungeon.
    [53]  = DIREFROST_KEEP,                               -- The Ice Furnace
    [103] = DIREFROST_KEEP,                               -- Magicka Furnace

    -- Elden Hollow I + II (Grahtwood)
    [28]  = { ELDEN_HOLLOW_1, ELDEN_HOLLOW_2 },           -- Barkskin
    [155] = { ELDEN_HOLLOW_1, ELDEN_HOLLOW_2 },           -- Undaunted Bastion

    -- Fungal Grotto I + II (Stonefalls)
    [33]  = { FUNGAL_GROTTO_1, FUNGAL_GROTTO_2 },         -- Viper's Sting
    [61]  = { FUNGAL_GROTTO_1, FUNGAL_GROTTO_2 },         -- Dreugh King Slayer

    -- Selene's Web (Reaper's March)
    [19]  = SELENES_WEB,                                  -- Vestments of the Warlock
    [71]  = SELENES_WEB,                                  -- Durok's Bane
    [123] = SELENES_WEB,                                  -- Hircine's Veneer

    -- Spindleclutch I + II (Glenumbra)
    [35]  = { SPINDLECLUTCH_1, SPINDLECLUTCH_2 },         -- Knightmare
    [55]  = { SPINDLECLUTCH_1, SPINDLECLUTCH_2 },         -- Prayer Shawl

    -- Tempest Island (Malabal Tor)
    [186] = TEMPEST_ISLAND,                               -- Jolting Arms
    [188] = TEMPEST_ISLAND,                               -- Storm Master

    -- The Banished Cells I + II (Auridon)
    [110] = { BANISHED_CELLS_1, BANISHED_CELLS_2 },       -- Sanctuary
    [197] = { BANISHED_CELLS_1, BANISHED_CELLS_2 },       -- Tormentor

    -- Vaults of Madness (Coldharbour)
    [91]  = VAULTS_OF_MADNESS,                            -- Oblivion's Edge
    [124] = VAULTS_OF_MADNESS,                            -- The Worm's Raiment

    -- Volenfell (Alik'r Desert)
    [77]  = VOLENFELL,                                    -- Crusader
    [102] = VOLENFELL,                                    -- Duneripper's Scales

    -- Wayrest Sewers I + II (Stormhaven)
    [29]  = { WAYREST_SEWERS_1, WAYREST_SEWERS_2 },       -- Sergeant's Mail
    [194] = { WAYREST_SEWERS_1, WAYREST_SEWERS_2 },       -- Combat Physician
}
