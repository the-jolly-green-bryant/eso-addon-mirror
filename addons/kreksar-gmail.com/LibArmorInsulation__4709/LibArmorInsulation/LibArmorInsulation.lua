-- LibArmorInsulation.lua
-- Entry point and public API surface.
--
-- ─────────────────────────────────────────────────────────────────────────────
-- STAGGERED TIER SYSTEM (v2.6.0+)
-- ─────────────────────────────────────────────────────────────────────────────
-- Insulation is expressed as one of eleven fixed TIERS, staggered in
-- increments of 10 from -10 to 90 (see LibArmorInsulation.Data.TIER_VALUES /
-- TierInfo in the StyleData module for the full ladder and descriptions).
-- Every style, outfit piece, costume, and polymorph resolves to one of these
-- tiers. Armor/outfit pieces are then ADJUSTED BY A PERCENTAGE based on which
-- body slot they occupy (head/chest/legs/hands/feet/waist/shoulders — see
-- SlotCoverage / OutfitSlotCoverage), since a helmet and a full robe don't
-- insulate the same fraction of the body. Full costumes and polymorphs are
-- whole-body and are NOT slot-adjusted — their tier IS the total.
--
-- Public API summary:
--
--   LibArmorInsulation.GetTotalInsulation()
--     → integer -10–90 : total insulation for the current player state
--
--   LibArmorInsulation.GetInsulationBreakdown()
--     → table : { source, total, slots, costumeId, costumeName }
--     source values: "polymorph" | "costume" | "outfit" | "armor" | "naked"
--
--   LibArmorInsulation.GetInsulationForStyle(styleId)
--     → integer -10–90 : full-set reference tier for a given ITEM_STYLE_* id
--
--   LibArmorInsulation.SetOverride(idType, id, value)
--     Sets a persisted insulation override — one of the eleven tier values
--     (-10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90). In the Settings panel this
--     is chosen from a dropdown rather than typed in, so it can never drift
--     off-tier; values passed programmatically are snapped to the nearest
--     tier as a safety net.
--     idType : "style"   → ITEM_STYLE_* integer (armor)
--              "outfit"  → collectible ID (outfit style piece)
--              "costume" → collectible ID (costume or polymorph)
--     For "style"/"outfit" the tier is a FULL-BODY reference value — the
--     actual per-slot contribution is still calculated from it based on
--     which slot the item occupies. For "costume" the tier IS the total,
--     unadjusted, since costumes cover the whole body at once.
--     value = nil removes the override.
--
--   LibArmorInsulation.ResetOverrides()
--     Clears all user overrides (does not clear the costume or outfit-style caches).
--
--   LibArmorInsulation.VERSION     → string  (e.g. "2.6.0")
--   LibArmorInsulation.ADDON_NAME  → string
--
-- Saved variables (account-wide):
--   sv.overrides    : { ["style_N"|"outfit_N"|"costume_N"] = tier integer (-10..90) }
--   sv.costumeCache : { [collectibleId] = { name, insulation, autoRated, matchSource } }
--                     Populated by /scancostumes; persists across sessions.
--                     `insulation` here is still a pre-snap raw value — it is
--                     snapped onto the nearest tier at lookup time.
--   sv.outfitStyleCache : { [collectibleId] = { name, baseMaterial, coverage, flavorBonus, autoRated, matchSource } }
--                     Populated by /scanoutfitstyles; persists across sessions.

local ADDON_NAME    = "LibArmorInsulation"
local ADDON_VERSION = "2.7.11"
local SAVED_VARS_VERSION = 5   -- bumped: overrides migrated from free-floating 0-100 to the staggered tier system

LibArmorInsulation = LibArmorInsulation or {}
local Lib = LibArmorInsulation

-- Slash command functions are defined below at file scope (so they close over
-- Lib and the other locals in this file normally), but are only actually
-- registered into SLASH_COMMANDS from inside OnAddonLoaded, once Lib.sv is
-- guaranteed to exist -- see the registration loop at the end of
-- OnAddonLoaded. This container just holds them until then.
local PendingSlashCommands = {}

Lib.VERSION    = ADDON_VERSION
Lib.ADDON_NAME = ADDON_NAME

-- ─────────────────────────────────────────────────────────────────────────────
-- Saved variables schema
-- ─────────────────────────────────────────────────────────────────────────────
local SV_DEFAULTS = {
    version      = SAVED_VARS_VERSION,
    overrides    = {},  -- keyed "style_N", "outfit_N", "costume_N" → tier integer (-10..90)
    costumeCache = {},  -- keyed by collectible ID (number) → { name, insulation, autoRated, matchSource }
                        -- populated at runtime by /scancostumes; persists across sessions
    outfitStyleCache = {}, -- keyed by collectible ID (number) → { name, baseMaterial, coverage, flavorBonus, autoRated, matchSource }
                        -- populated at runtime by /scanoutfitstyles; persists across sessions
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Initialization
-- ─────────────────────────────────────────────────────────────────────────────
local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    -- Populate the slot-coverage tables now that EQUIP_SLOT_* and
    -- OUTFIT_SLOT_* globals are guaranteed to be non-nil.
    LibArmorInsulation.Data.InitSlotTables()

    -- Build the style name ↔ ID runtime maps by iterating GetItemStyleName()
    -- for every ID up to GetHighestItemStyleId().  This inverts the id→name
    -- mapping so the Styles data table can be keyed by stable English names
    -- rather than raw integers that may be reassigned between API updates.
    LibArmorInsulation.Calc.BuildStyleIdMaps()

    -- Load saved variables. ZO_SavedVars:NewAccountWide creates a per-account
    -- table so overrides carry across characters on the same account.
    -- Namespaced by GetWorldName() ("EU Megaserver" / "NA Megaserver" / "PTS")
    -- so each server keeps its own overrides/caches rather than all three
    -- sharing (and overwriting) one account-wide table.
    -- Ref: https://wiki.esoui.com/ZO_SavedVars
    Lib.sv = ZO_SavedVars:NewAccountWide(
        "LibArmorInsulation_SavedVars",   -- global saved variable name (must match .txt)
        SAVED_VARS_VERSION,
        GetWorldName(),                   -- namespace: separates EU / NA / PTS data
        SV_DEFAULTS
    )

    -- Migrate if the saved var version is old.
    -- Version 3 added costumeCache; preserve overrides from version 2.
    -- Version 4 added outfitStyleCache; preserve overrides/costumeCache from version 3.
    -- Version 5 introduced the staggered tier system: overrides used to be a
    -- free-floating 0-100 value and are now one of the eleven fixed tiers
    -- (-10, 0, 10, ..., 90). Existing overrides are snapped onto the nearest
    -- tier rather than discarded, so a player's manual tuning carries forward
    -- as closely as the new scale allows.
    if Lib.sv.version ~= SAVED_VARS_VERSION then
        if Lib.sv.version == 2 then
            -- Keep overrides; just add the missing cache tables.
            Lib.sv.costumeCache     = Lib.sv.costumeCache or {}
            Lib.sv.outfitStyleCache = Lib.sv.outfitStyleCache or {}
        elseif Lib.sv.version == 3 or Lib.sv.version == 4 then
            -- Keep overrides and existing caches; just add any missing table.
            Lib.sv.outfitStyleCache = Lib.sv.outfitStyleCache or {}
        else
            Lib.sv.overrides        = {}
            Lib.sv.costumeCache     = {}
            Lib.sv.outfitStyleCache = {}
        end

        -- Snap any carried-forward overrides onto the nearest tier (allowing
        -- the full -10..90 range, since these are deliberate user choices —
        -- e.g. a style previously overridden to 95 to look flame-atronach-hot
        -- should land on 90, not be clamped into the mundane range).
        if Lib.sv.version and Lib.sv.version < SAVED_VARS_VERSION and Lib.sv.overrides then
            for key, value in pairs(Lib.sv.overrides) do
                Lib.sv.overrides[key] = LibArmorInsulation.Calc.SnapToTier(value, true)
            end
        end

        Lib.sv.version = SAVED_VARS_VERSION
    end
    -- Ensure the cache tables exist even on a fresh install with an old-format SV.
    Lib.sv.costumeCache     = Lib.sv.costumeCache or {}
    Lib.sv.outfitStyleCache = Lib.sv.outfitStyleCache or {}

    -- Initialize the settings panel
    LibArmorInsulation.Settings.Initialize(Lib.sv)

    -- Register slash commands only now, after Lib.sv is guaranteed to exist --
    -- every slash command handler above references Lib.sv, so registering
    -- them any earlier risks a nil-index error if a command were somehow
    -- invoked before this event fires.
    for command, handler in pairs(PendingSlashCommands) do
        SLASH_COMMANDS[command] = handler
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)

-- ─────────────────────────────────────────────────────────────────────────────
-- Public API
-- ─────────────────────────────────────────────────────────────────────────────

-- Returns the total insulation value for the player's current state,
-- respecting the priority cascade and any user overrides.
function Lib.GetTotalInsulation()
    return LibArmorInsulation.Calc.GetTotalInsulation(Lib.sv and Lib.sv.overrides or nil)
end

-- Returns the full breakdown table (see Calculator module for schema).
function Lib.GetInsulationBreakdown()
    return LibArmorInsulation.Calc.GetInsulationBreakdown(Lib.sv and Lib.sv.overrides or nil)
end

-- Returns the insulation-per-coverage-unit value for a given style,
-- respecting user overrides.
function Lib.GetInsulationForStyle(styleId)
    return LibArmorInsulation.Calc.GetInsulationForStyle(
        styleId,
        Lib.sv and Lib.sv.overrides or nil
    )
end

-- Programmatically set an override for an armor style, outfit collectible, or costume.
-- idType  : "style" | "outfit" | "costume"
-- id      : number (ITEM_STYLE_* for armor; collectible ID for outfit/costume)
-- value   : one of the tier values (-10, 0, 10, ..., 90), or nil to remove
--           the override. Any other number is snapped to the nearest tier
--           rather than rejected, so callers don't need to hardcode the ladder.
function Lib.SetOverride(idType, id, value)
    if not Lib.sv then return end
    Lib.sv.overrides = Lib.sv.overrides or {}
    local prefix = (idType == "outfit" and "outfit_") or (idType == "costume" and "costume_") or "style_"
    local key = prefix .. tostring(id)
    if value == nil then
        Lib.sv.overrides[key] = nil
    else
        Lib.sv.overrides[key] = LibArmorInsulation.Calc.SnapToTier(value, true)
    end
end

-- Reset all user overrides to database defaults.
function Lib.ResetOverrides()
    if Lib.sv then
        Lib.sv.overrides = {}
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Slash commands
-- /insulation    – total insulation + per-slot breakdown
-- /styleids      – style name and ID for each slot (armor or outfit)
-- /costumeids    – ID, name, and match status of the active costume/polymorph
-- /scancostumes  – scans all owned costumes and writes results to the cache
-- /diagcollectibles – lists all collectible categories with type integers (debug)
-- /outfitids       – collectible name and ID for each slot of the active outfit
-- /outfitactive    – diagnostic: probes for a "is outfit currently worn" API
-- /clearcostumecache – wipe the runtime costume cache (re-run /scancostumes to rebuild)
-- ─────────────────────────────────────────────────────────────────────────────

-- /insulation : total + per-slot insulation values
PendingSlashCommands["/insulation"] = function()
    local breakdown = Lib.GetInsulationBreakdown()
    local totalTierLabel = LibArmorInsulation.Calc.GetTierLabel and
        LibArmorInsulation.Calc.SnapToTier and
        LibArmorInsulation.Calc.GetTierLabel(LibArmorInsulation.Calc.SnapToTier(breakdown.total, true))
    CHAT_SYSTEM:AddMessage(string.format(
        "|cFFD700LibArmorInsulation:|r Source: %s  |  Total insulation: %d  (~%s)",
        breakdown.source, breakdown.total, totalTierLabel or "?"
    ))
    for slotKey, slotData in pairs(breakdown.slots) do
        local label = LibArmorInsulation.Calc.GetSlotLabel(slotKey)
        local displayName = slotData.name or slotData.styleName or "?"
        local idLabel
        if slotData.collectibleId then
            idLabel = string.format("collectible %d, %s", slotData.collectibleId, displayName)
        elseif slotData.styleId and slotData.styleId ~= 0 then
            idLabel = string.format("style %d, %s", slotData.styleId, displayName)
        else
            idLabel = "—"
        end
        local suffix = slotData.armorFallback and " [armor]" or ""
        local pctStr = slotData.slotPercentage and string.format(" x %d%%", math.floor(slotData.slotPercentage * 100 + 0.5)) or ""
        local tierStr = slotData.tier and string.format(" [tier %d %s]", slotData.tier, LibArmorInsulation.Calc.GetTierLabel(slotData.tier)) or ""
        CHAT_SYSTEM:AddMessage(string.format(
            "  %s: %d  (%s, %s)%s%s%s",
            label, slotData.insulation, idLabel, slotData.material, suffix, tierStr, pctStr
        ))
    end
end

-- /styleids : list the style name and ID worn in each armor/outfit slot.
-- Useful when you want to enter a style into the override editor.
PendingSlashCommands["/styleids"] = function()
    local breakdown = Lib.GetInsulationBreakdown()
    if breakdown.source ~= "armor" and breakdown.source ~= "outfit" then
        CHAT_SYSTEM:AddMessage(string.format(
            "|cFFD700LibArmorInsulation:|r No worn armor or outfit detected (source: %s).",
            breakdown.source
        ))
        return
    end
    local sourceLabel = breakdown.source == "outfit" and "Outfit style IDs" or "Worn armor style IDs"
    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r " .. sourceLabel .. ":")
    for slotKey, slotData in pairs(breakdown.slots) do
        local label = LibArmorInsulation.Calc.GetSlotLabel(slotKey)
        local styleStr
        if slotData.collectibleId then
            local name = GetCollectibleName(slotData.collectibleId) or "?"
            styleStr = string.format("collectible %d (%s)", slotData.collectibleId, name)
        elseif slotData.styleId and slotData.styleId ~= 0 then
            local db   = LibArmorInsulation.Data.Styles
            local data = db[slotData.styleId] or db["DEFAULT"]
            local name = data and data.name or "?"
            styleStr = string.format("style %d (%s)", slotData.styleId, name)
        else
            styleStr = "style 0 (unknown — will use DEFAULT)"
        end
        local suffix = slotData.armorFallback and " [armor fallback]" or ""
        local tierStr = slotData.tier and string.format("  [tier %d %s]", slotData.tier, LibArmorInsulation.Calc.GetTierLabel(slotData.tier)) or ""
        CHAT_SYSTEM:AddMessage(string.format("  %s: %s%s%s", label, styleStr, suffix, tierStr))
    end
end

-- /costumeids : prints the ID, name, and current insulation of the active costume/polymorph,
-- and whether it is matched by ID, by name, or falling back to the default.
PendingSlashCommands["/costumeids"] = function()
    local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
    if not collectibleId or collectibleId == 0 then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r No costume or polymorph is currently active.")
        return
    end
    local rawName  = GetCollectibleName(collectibleId) or ""
    local normName = rawName:lower():gsub("%s+", " "):match("^%s*(.-)%s*$")
    local idDb     = LibArmorInsulation.Data.CostumeInsulationById or {}
    local nameDb   = LibArmorInsulation.Data.CostumeInsulation or {}
    local overrides = Lib.sv and Lib.sv.overrides or {}
    local overrideKey = "costume_" .. tostring(collectibleId)
    local Calc = LibArmorInsulation.Calc
    local matchType
    if overrides[overrideKey] then
        local tier = overrides[overrideKey]
        matchType = string.format("user override (tier %d, %s)", tier, Calc.GetTierLabel(tier))
    elseif idDb[collectibleId] then
        local tier = Calc.SnapToTier(idDb[collectibleId].totalInsulation, idDb[collectibleId].magical)
        matchType = string.format("ID table (tier %d, %s)", tier, Calc.GetTierLabel(tier))
    elseif nameDb[normName] then
        local tier = Calc.SnapToTier(nameDb[normName].totalInsulation, nameDb[normName].magical)
        matchType = string.format("name table (tier %d, %s)", tier, Calc.GetTierLabel(tier))
    else
        local fallback = nameDb["DEFAULT_COSTUME"] or {totalInsulation=35}
        local tier = Calc.SnapToTier(fallback.totalInsulation, fallback.magical)
        matchType = string.format("DEFAULT_COSTUME (tier %d, %s)", tier, Calc.GetTierLabel(tier))
    end
    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Active costume/polymorph:")
    CHAT_SYSTEM:AddMessage(string.format("  ID     : %d", collectibleId))
    CHAT_SYSTEM:AddMessage(string.format("  Name   : %s", rawName))
    CHAT_SYSTEM:AddMessage(string.format("  Lookup : %s", matchType))
    CHAT_SYSTEM:AddMessage(string.format("  Key    : costume_%d  (for override panel)", collectibleId))
    CHAT_SYSTEM:AddMessage("  → Run /scancostumes to register all owned costumes at once.")
end

-- /scancostumes : walks every owned costume and polymorph in the Collections
-- system, auto-rates each by name keywords, and writes the results into
-- sv.costumeCache.  The cache is checked by the Calculator on every insulation
-- query, so costumes are recognised immediately after scanning without any file
-- editing or reload.  Run once after installing; re-run after unlocking new
-- costumes.  Individual values can be adjusted via the Settings panel.
--
-- Confirmed API (from /diagcollectibles diagnostic output):
--   GetNumCollectibleCategories()
--     → count of top-level categories (e.g. 16)
--   GetCollectibleCategoryInfo(catIndex)
--     → r1 = category name string  (e.g. "Appearance")
--       (top-level categories are groupings; COLLECTIBLE_CATEGORY_TYPE_COSTUME
--        does NOT match any top-level category type — do not use for filtering)
--   GetCollectibleSubCategoryInfo(catIndex, subIndex)
--     → r1 = subcategory name string  (e.g. "Costumes", "Polymorphs")
--       r2 = collectible count in that subcategory
--       (GetNumCollectibleSubCategories does NOT exist — do not call it)
--   GetCollectibleId(catIndex, subIndex, collectibleIndex)
--     → collectible ID, or 0 when the list is exhausted
--       subIndex is 1-based within the subcategory list for a given catIndex
--   GetCollectibleInfo(id)
--     → r1=name  r5=isUnlocked
--       (no category/subcategory type is returned — do not attempt to use r8
--        for type filtering; it is a count, not a type integer)
--
-- Costumes  → Appearance (catIndex varies) → subcategory named "Costumes"
-- Polymorphs → Appearance (same catIndex)  → subcategory named "Polymorphs"
-- Both are scanned because both affect the insulation calculation.
-- ─────────────────────────────────────────────────────────────────────────────
-- Shared keyword-rating table (used by /scancostumes and /scanoutfitstyles)
-- ─────────────────────────────────────────────────────────────────────────────
-- Keyword → auto insulation value (checked in order; first match wins).
-- Scale: 0=body of ice, 50=neutral everyday clothing, 100=arctic explorer
-- This is the single source of truth for name/description keyword matching —
-- both costumes (whole-body, flat value) and outfit style pieces (per-slot,
-- same flat value applied since costumes/style pieces have no slot breakdown
-- in their own right) draw from this list so a new pattern only needs adding
-- once.
local KEYWORD_RATINGS = {
    { pattern = "flame atronach",     value = 92 },
    { pattern = "fire form",          value = 90 },
    { pattern = "werewolf",           value = 78 },
    { pattern = "bear",               value = 68 },
    { pattern = "nordic.*ceremonial", value = 68 },
    { pattern = "nord.*ceremonial",   value = 65 },
    { pattern = "fur%-lined",         value = 65 },
    { pattern = "fur.*cloak",         value = 62 },
    { pattern = "frost atronach",     value =  2 },
    { pattern = "ice.*form",          value =  2 },
    { pattern = "ice wraith",         value =  0 },
    { pattern = "storm atronach",     value = 10 },
    { pattern = "skeleton",           value =  5 },
    { pattern = "undead",             value =  8 },
    { pattern = "lich",               value =  8 },
    { pattern = "scarecrow",          value = 12 },
    { pattern = "senche",             value = 50 },
    { pattern = "guar",               value = 35 },
    { pattern = "welwa",              value = 25 },
    { pattern = "dwarven spider",     value = 15 },
    { pattern = "indrik",             value = 18 },
    { pattern = "wormmouth",          value = 20 },
    { pattern = "fur",                value = 62 },
    { pattern = "pelt",               value = 60 },
    { pattern = "northern",           value = 58 },
    { pattern = "winter",             value = 58 },
    { pattern = "snowfall",           value = 58 },
    { pattern = "stormcloak",         value = 58 },
    { pattern = "ceremonial",         value = 58 },
    { pattern = "robe",               value = 52 },
    { pattern = "vestment",           value = 52 },
    { pattern = "raiment",            value = 50 },
    { pattern = "armor",              value = 50 },
    { pattern = "knight",             value = 52 },
    { pattern = "templar",            value = 52 },
    { pattern = "guard",              value = 50 },
    { pattern = "mercenary",          value = 50 },
    { pattern = "scout",              value = 47 },
    { pattern = "ranger",             value = 45 },
    { pattern = "gown",               value = 38 },
    { pattern = "dress",              value = 35 },
    { pattern = "silk",               value = 30 },
    { pattern = "dancer",             value = 20 },
    { pattern = "bather",             value = 12 },
    { pattern = "bath",               value = 12 },
    { pattern = "towel",              value =  8 },
    { pattern = "swim",               value = 10 },
}

-- AutoRate(name, description)
-- Checks the name first (deliberately worded, e.g. "Nordic Ceremonial Robe"),
-- then falls back to description/flavor text if the name has no hit.
-- Returns: value (pre-snap raw authoring value, still 0-100 scale — snapped
--          onto a tier at lookup time by Calc.SnapToTier()), autoRated
--          (always true), matchSource ("name" | "description" | "none")
local function AutoRate(name, description)
    local nameLower = tostring(name or ""):lower()
    local descLower = tostring(description or ""):lower()

    for _, entry in ipairs(KEYWORD_RATINGS) do
        if nameLower:find(entry.pattern) then
            return entry.value, true, "name"
        end
    end
    for _, entry in ipairs(KEYWORD_RATINGS) do
        if descLower:find(entry.pattern) then
            return entry.value, true, "description"
        end
    end
    return 50, true, "none"   -- DEFAULT fallback (neutral midpoint), no match anywhere
end

PendingSlashCommands["/scancostumes"] = function()
    if not Lib.sv then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Saved variables not loaded yet — try again in a moment.")
        return
    end
    Lib.sv.costumeCache = Lib.sv.costumeCache or {}

    -- Scan one subcategory's worth of collectibles and write owned ones to cache.
    local idDb = LibArmorInsulation.Data.CostumeInsulationById or {}
    local found    = 0
    local cached   = 0
    local hardcoded = 0

    local function ScanSubCategory(catIndex, subIndex, subLabel)
        for ci = 1, 9999 do
            local id = GetCollectibleId(catIndex, subIndex, ci)
            if not id or id == 0 then break end
            local name, _, _, _, isUnlocked = GetCollectibleInfo(id)
            if isUnlocked then
                found = found + 1
                local nameStr = tostring(name)
                if idDb[id] then
                    hardcoded = hardcoded + 1
                    CHAT_SYSTEM:AddMessage(string.format(
                        "  [data] %s %d: %s  → %d",
                        subLabel, id, nameStr, idDb[id].totalInsulation
                    ))
                else
                    local overrideKey = "costume_" .. tostring(id)
                    local hasOverride = Lib.sv.overrides and Lib.sv.overrides[overrideKey]
                    local insulation, autoRated, matchSource
                    if hasOverride then
                        insulation = hasOverride
                        autoRated  = false
                        matchSource = "override"
                    elseif Lib.sv.costumeCache[id] and not Lib.sv.costumeCache[id].autoRated then
                        insulation = Lib.sv.costumeCache[id].insulation
                        autoRated  = false
                        matchSource = Lib.sv.costumeCache[id].matchSource or "manual"
                    else
                        local description = GetCollectibleDescription and GetCollectibleDescription(id) or ""
                        insulation, autoRated, matchSource = AutoRate(nameStr, description)
                    end
                    Lib.sv.costumeCache[id] = {
                        name        = nameStr,
                        insulation  = insulation,
                        autoRated   = autoRated,
                        matchSource = matchSource,
                    }
                    cached = cached + 1
                    local tag = hasOverride and "[override]" or (autoRated and "[auto]" or "[manual]")
                    -- Flag genuinely unmatched auto-rated entries inline so they're
                    -- visible without needing a separate pass, while keeping the
                    -- full reviewable list available via /costumesneedreview.
                    local note = (matchSource == "none") and "  (NO KEYWORD MATCH — needs review)" or ""
                    CHAT_SYSTEM:AddMessage(string.format(
                        "  %s %s %d: %s  -> %d%s",
                        tag, subLabel, id, nameStr, insulation, note
                    ))
                end
            end
        end
    end

    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Scanning owned costumes...")

    -- Walk top-level categories to find "Appearance", then probe its subcategories
    -- for the ones named "Costumes" and "Polymorphs".
    -- GetCollectibleCategoryInfo(catIndex) → r1 = category name
    -- GetCollectibleSubCategoryInfo(catIndex, subIndex) → r1 = subcat name
    -- Both are confirmed present from the /diagcollectibles diagnostic.
    local numCats = GetNumCollectibleCategories()
    local appearanceCatIndex = nil
    for catIndex = 1, (numCats or 0) do
        local catName = GetCollectibleCategoryInfo(catIndex)
        if tostring(catName):lower() == "appearance" then
            appearanceCatIndex = catIndex
            break
        end
    end

    if not appearanceCatIndex then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Could not find the Appearance category.")
        CHAT_SYSTEM:AddMessage("  Run /diagcollectibles and report the output.")
        return
    end

    -- Probe subcategories of Appearance for "Costumes" and "Polymorphs".
    -- We iterate up to 50 subcategory indices; GetCollectibleSubCategoryInfo
    -- returns a nil or empty name when the index is out of range.
    local costumeSubsFound = 0
    for subIndex = 1, 50 do
        local subName = GetCollectibleSubCategoryInfo(appearanceCatIndex, subIndex)
        if not subName or subName == "" then break end
        local subLower = subName:lower()
        if subLower == "costumes" or subLower == "polymorphs" then
            costumeSubsFound = costumeSubsFound + 1
            ScanSubCategory(appearanceCatIndex, subIndex, subName)
        end
    end

    if costumeSubsFound == 0 then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r No Costumes or Polymorphs subcategory found under Appearance.")
        CHAT_SYSTEM:AddMessage("  Run /diagcollectibles and report the output.")
        return
    end

    CHAT_SYSTEM:AddMessage(string.format(
        "|cFFD700LibArmorInsulation:|r Scan complete. %d owned: " ..
        "%d in data table, %d written to cache.",
        found, hardcoded, cached
    ))
    if found == 0 then
        CHAT_SYSTEM:AddMessage("  No owned costumes or polymorphs found.")
        CHAT_SYSTEM:AddMessage("  Run /diagcollectibles if this seems wrong.")
    else
        CHAT_SYSTEM:AddMessage("  Cache active immediately. Adjust values via")
        CHAT_SYSTEM:AddMessage("  Addon Settings > LibArmorInsulation > Manual Overrides.")
    end
end

-- /clearcostumecache : wipes the runtime costume cache built by /scancostumes.
-- Use this if you want to force a full rescan (e.g. after the keyword ratings
-- are updated in a new version of the addon).
PendingSlashCommands["/clearcostumecache"] = function()
    if not Lib.sv then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Saved variables not loaded.")
        return
    end
    local count = 0
    if Lib.sv.costumeCache then
        for _ in pairs(Lib.sv.costumeCache) do count = count + 1 end
        Lib.sv.costumeCache = {}
    end
    CHAT_SYSTEM:AddMessage(string.format(
        "|cFFD700LibArmorInsulation:|r Costume cache cleared (%d entries removed). Run /scancostumes to rebuild.",
        count
    ))
end

-- /diagcollectibles : deep diagnostic.
-- Phase 1: lists every top-level category with its type, subcategory count,
--          and how many collectibles are directly accessible at subcatIndex 0.
-- Phase 2: for the "Appearance" category specifically (the one most likely to
--          contain costumes), drills into every subcategory and reports its
--          name, type, and collectible count.
-- Phase 3: probes GetNumCollectibleSubCategories on each top-level category
--          to confirm that function exists and returns useful values.
-- Run this and report the full output if /scancostumes still finds 0 costumes.
PendingSlashCommands["/diagcollectibles"] = function()
    local numCats = GetNumCollectibleCategories()
    CHAT_SYSTEM:AddMessage(string.format(
        "|cFFD700LibArmorInsulation:|r PHASE 1 — %d top-level categories  (COSTUME const=%s):",
        numCats or 0, tostring(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
    ))

    local appearanceCatIndex = nil

    for catIndex = 1, (numCats or 0) do
        local catName = GetCollectibleCategoryInfo(catIndex) or "?"
        local catType = GetCollectibleCategoryType(catIndex)

        -- Count collectibles at subcat index 0 (top-level slot)
        local directCount = 0
        for ci = 1, 9999 do
            local id = GetCollectibleId(catIndex, 0, ci)
            if not id or id == 0 then break end
            directCount = directCount + 1
        end

        -- Count subcategories via GetNumCollectibleSubCategories
        local numSubCats = 0
        local ok, val = pcall(GetNumCollectibleSubCategories, catIndex)
        if ok and val then numSubCats = val end

        local marker = (catType == COLLECTIBLE_CATEGORY_TYPE_COSTUME) and " <<<< COSTUME" or ""
        CHAT_SYSTEM:AddMessage(string.format(
            "  [%d] %s  type=%s  subcats=%d  directCount=%d%s",
            catIndex, tostring(catName), tostring(catType), numSubCats, directCount, marker
        ))

        -- Track Appearance category for Phase 2 drill-down
        if tostring(catName):lower():find("appearance") then
            appearanceCatIndex = catIndex
        end
    end

    -- Phase 2: drill into Appearance subcategories
    if appearanceCatIndex then
        CHAT_SYSTEM:AddMessage(string.format(
            "|cFFD700LibArmorInsulation:|r PHASE 2 — Appearance subcategories (catIndex=%d):",
            appearanceCatIndex
        ))
        local ok2, numSubs = pcall(GetNumCollectibleSubCategories, appearanceCatIndex)
        local subCount = (ok2 and numSubs) or 0
        CHAT_SYSTEM:AddMessage(string.format("  GetNumCollectibleSubCategories → %s", tostring(numSubs)))

        for subIndex = 1, math.max(subCount, 20) do
            -- Try GetCollectibleSubCategoryInfo for name/type
            local subName, subType
            local ok3, sn, st = pcall(GetCollectibleSubCategoryInfo, appearanceCatIndex, subIndex)
            if ok3 then subName = sn; subType = st end
            if not subName and subIndex > subCount then break end

            -- Count collectibles in this subcategory
            local count = 0
            for ci = 1, 9999 do
                local id = GetCollectibleId(appearanceCatIndex, subIndex, ci)
                if not id or id == 0 then break end
                count = count + 1
            end

            local marker2 = (subType == COLLECTIBLE_CATEGORY_TYPE_COSTUME) and " <<<< COSTUME" or ""
            CHAT_SYSTEM:AddMessage(string.format(
                "  subcat[%d] %s  type=%s  count=%d%s",
                subIndex, tostring(subName), tostring(subType), count, marker2
            ))
        end
    else
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r PHASE 2 — no Appearance category found by name.")
    end

    -- Phase 3: confirm the first collectible we can find in any subcat and what info it returns
    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r PHASE 3 — first reachable collectible per category:")
    for catIndex = 1, (numCats or 0) do
        local ok2, numSubs = pcall(GetNumCollectibleSubCategories, catIndex)
        local subCount = (ok2 and numSubs) or 0
        for subIndex = 0, math.max(subCount, 1) do
            local id = GetCollectibleId(catIndex, subIndex, 1)
            if id and id ~= 0 then
                local r1,r2,r3,r4,r5,r6,r7,r8,r9,r10 = GetCollectibleInfo(id)
                local catName = GetCollectibleCategoryInfo(catIndex) or "?"
                CHAT_SYSTEM:AddMessage(string.format(
                    "  cat[%d/%s] sub[%d] id=%d name=%s unlocked=%s r8=%s",
                    catIndex, tostring(catName), subIndex, id,
                    tostring(r1), tostring(r5), tostring(r8)
                ))
                break  -- one per top-level category is enough
            end
        end
    end
end

-- /outfitids : prints the collectible ID and name applied to each slot of the
-- player's outfit(s), mirroring what /styleids shows for worn armor.
-- Only reports outfits that have at least one slot styled.
-- /scanoutfitstyles : walks every unlocked outfit's 7 slots (same enumeration
-- as /outfitids) and, for any collectible ID not already in the hand-curated
-- OutfitStyles table, auto-rates it via name+description keyword matching
-- (same KEYWORD_RATINGS as /scancostumes) and writes a guessed
-- {baseMaterial, coverage, flavorBonus} entry into sv.outfitStyleCache.
-- Re-run this after unlocking/equipping a new style page to pick it up.
PendingSlashCommands["/scanoutfitstyles"] = function()
    if not Lib.sv then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Saved variables not loaded yet — try again in a moment.")
        return
    end
    if not ZO_OUTFIT_MANAGER then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r ZO_OUTFIT_MANAGER unavailable.")
        return
    end
    Lib.sv.outfitStyleCache = Lib.sv.outfitStyleCache or {}

    local numOutfits = GetNumUnlockedOutfits()
    if not numOutfits or numOutfits == 0 then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r No unlocked outfits found.")
        return
    end

    local slotDefs = {
        { slot = OUTFIT_SLOT_HEAD,      label = "Head"      },
        { slot = OUTFIT_SLOT_SHOULDERS, label = "Shoulders" },
        { slot = OUTFIT_SLOT_CHEST,     label = "Chest"     },
        { slot = OUTFIT_SLOT_HANDS,     label = "Hands"     },
        { slot = OUTFIT_SLOT_WAIST,     label = "Waist"     },
        { slot = OUTFIT_SLOT_LEGS,      label = "Legs"      },
        { slot = OUTFIT_SLOT_FEET,      label = "Feet"      },
    }

    local found, hardcoded, cached = 0, 0, 0
    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Scanning equipped outfit style pieces...")

    for outfitIndex = 1, numOutfits do
        local om = ZO_OUTFIT_MANAGER:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitIndex)
        if not om then break end

        local outfitName = GetOutfitName(outfitIndex) or ("Outfit " .. outfitIndex)
        for _, def in ipairs(slotDefs) do
            local sm  = om:GetSlotManipulator(def.slot)
            local cid = sm and sm:GetCurrentCollectibleId() or 0
            if cid ~= 0 then
                found = found + 1
                local name = GetCollectibleName(cid) or "?"
                local matchedStyleName = LibArmorInsulation.Calc.NormaliseOutfitStyleName
                                          and LibArmorInsulation.Calc.NormaliseOutfitStyleName(name)
                local matchedStyleEntry = matchedStyleName and LibArmorInsulation.Data.Styles[matchedStyleName]

                if LibArmorInsulation.Data.OutfitStyles[cid] then
                    hardcoded = hardcoded + 1
                    CHAT_SYSTEM:AddMessage(string.format(
                        "  [data] %s %s %d: %s", outfitName, def.label, cid, name
                    ))
                elseif matchedStyleEntry then
                    -- Name matches an existing crafted-armor motif in Styles[] —
                    -- no need to guess; GetOutfitStyleData() will resolve this
                    -- the same way at lookup time, so nothing to cache here.
                    CHAT_SYSTEM:AddMessage(string.format(
                        "  [motif-match] %s %s %d: %s  -> matched Styles[\"%s\"]",
                        outfitName, def.label, cid, name, matchedStyleName
                    ))
                else
                    local overrideKey = "outfit_" .. tostring(cid)
                    local hasOverride = Lib.sv.overrides and Lib.sv.overrides[overrideKey]
                    local existing = Lib.sv.outfitStyleCache[cid]
                    local tag, matchSource, baseMaterial

                    if hasOverride then
                        tag = "[override]"
                        matchSource = "override"
                    elseif existing and not existing.autoRated then
                        tag = "[manual]"
                        matchSource = existing.matchSource or "manual"
                        baseMaterial = existing.baseMaterial
                    else
                        local description = GetCollectibleDescription and GetCollectibleDescription(cid) or ""
                        local target, autoRated, source = AutoRate(name, description)
                        matchSource  = source
                        baseMaterial = LibArmorInsulation.Calc.NearestMaterialForTarget(target)
                        Lib.sv.outfitStyleCache[cid] = {
                            name         = name,
                            baseMaterial = baseMaterial,
                            coverage     = 1.0,
                            flavorBonus  = 0,
                            flavorNote   = description or "",
                            autoRated    = autoRated,
                            matchSource  = matchSource,
                        }
                        cached = cached + 1
                        tag = "[auto]"
                    end

                    local note = (matchSource == "none") and "  (NO KEYWORD MATCH — needs review)" or ""
                    CHAT_SYSTEM:AddMessage(string.format(
                        "  %s %s %s %d: %s  -> material=%s%s",
                        tag, outfitName, def.label, cid, name, tostring(baseMaterial or "?"), note
                    ))
                end
            end
        end
    end

    CHAT_SYSTEM:AddMessage(string.format(
        "|cFFD700LibArmorInsulation:|r Scan complete. %d found: %d in data table, %d written to cache.",
        found, hardcoded, cached
    ))
    if found == 0 then
        CHAT_SYSTEM:AddMessage("  No equipped style pieces found across unlocked outfits.")
    else
        CHAT_SYSTEM:AddMessage("  Cache active immediately. Adjust values via")
        CHAT_SYSTEM:AddMessage("  Addon Settings > LibArmorInsulation > Manual Overrides.")
    end
end

-- /costumesneedreview : filters sv.costumeCache down to entries where the
-- keyword scan found no match at all in either the name or description
-- (matchSource == "none"), so they're sitting on the generic 50 fallback.
-- This is your worklist for manual UESP-backed CostumeInsulationById entries.
PendingSlashCommands["/costumesneedreview"] = function()
    if not Lib.sv or not Lib.sv.costumeCache then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r No costume cache yet — run /scancostumes first.")
        return
    end
    local count = 0
    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Costumes needing manual review (no keyword match):")
    for id, entry in pairs(Lib.sv.costumeCache) do
        if entry.matchSource == "none" then
            count = count + 1
            CHAT_SYSTEM:AddMessage(string.format("  %d: %s  -> %d (default)", id, entry.name, entry.insulation))
        end
    end
    if count == 0 then
        CHAT_SYSTEM:AddMessage("  None — every cached costume matched a keyword.")
    else
        CHAT_SYSTEM:AddMessage(string.format("  %d total. Add CostumeInsulationById entries to override.", count))
    end
end

-- /outfitstylesneedreview : same as /costumesneedreview, but for sv.outfitStyleCache.
PendingSlashCommands["/outfitstylesneedreview"] = function()
    if not Lib.sv or not Lib.sv.outfitStyleCache then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r No outfit style cache yet — run /scanoutfitstyles first.")
        return
    end
    local count = 0
    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Outfit style pieces needing manual review (no keyword match):")
    for id, entry in pairs(Lib.sv.outfitStyleCache) do
        if entry.matchSource == "none" then
            count = count + 1
            CHAT_SYSTEM:AddMessage(string.format("  %d: %s  -> material=%s (guessed)", id, entry.name, entry.baseMaterial))
        end
    end
    if count == 0 then
        CHAT_SYSTEM:AddMessage("  None — every cached outfit style piece matched a keyword.")
    else
        CHAT_SYSTEM:AddMessage(string.format("  %d total. Add OutfitStyles entries to override.", count))
    end
end


PendingSlashCommands["/outfitids"] = function()
    if not ZO_OUTFIT_MANAGER then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r ZO_OUTFIT_MANAGER unavailable.")
        return
    end
    local numOutfits = GetNumUnlockedOutfits()
    if not numOutfits or numOutfits == 0 then
        CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r No unlocked outfits found.")
        return
    end

    local slotDefs = {
        { slot = OUTFIT_SLOT_HEAD,      label = "Head"      },
        { slot = OUTFIT_SLOT_SHOULDERS, label = "Shoulders" },
        { slot = OUTFIT_SLOT_CHEST,     label = "Chest"     },
        { slot = OUTFIT_SLOT_HANDS,     label = "Hands"     },
        { slot = OUTFIT_SLOT_WAIST,     label = "Waist"     },
        { slot = OUTFIT_SLOT_LEGS,      label = "Legs"      },
        { slot = OUTFIT_SLOT_FEET,      label = "Feet"      },
    }

    for outfitIndex = 1, numOutfits do
        local om = ZO_OUTFIT_MANAGER:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitIndex)
        if not om then break end

        local outfitName = GetOutfitName(outfitIndex) or ("Outfit " .. outfitIndex)
        local hasAny = false
        local lines  = {}
        for _, def in ipairs(slotDefs) do
            local sm  = om:GetSlotManipulator(def.slot)
            local cid = sm and sm:GetCurrentCollectibleId() or 0
            if cid ~= 0 then
                hasAny = true
                local name = GetCollectibleName(cid) or "?"
                lines[#lines + 1] = string.format("  %s: %d (%s)", def.label, cid, name)
            end
        end

        if hasAny then
            CHAT_SYSTEM:AddMessage(string.format(
                "|cFFD700LibArmorInsulation:|r %s collectible IDs:", outfitName
            ))
            for _, line in ipairs(lines) do
                CHAT_SYSTEM:AddMessage(line)
            end
        end
    end
end

-- /outfitactive : diagnostic — probes free functions and outfitManipulator methods
-- to find a reliable way to detect whether an outfit is currently equipped on the
-- character (vs. stored but not worn). Run this with outfit equipped, then unequipped.
PendingSlashCommands["/outfitactive"] = function()
    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Probing worn-outfit detection...")

    local freeFunctions = {
        "GetActiveOutfitIndex", "GetWornOutfitIndex", "GetEquippedOutfitIndex",
        "GetCurrentOutfitIndex", "GetActiveRestyleSetIndex", "GetCharacterOutfitIndex",
    }
    for _, name in ipairs(freeFunctions) do
        local fn = _G[name]
        if fn then
            local ok, val = pcall(fn)
            CHAT_SYSTEM:AddMessage(string.format(
                "  %s() ok=%s val=%s", name, tostring(ok), tostring(val)
            ))
        else
            CHAT_SYSTEM:AddMessage(string.format("  %s: nil", name))
        end
    end

    if not ZO_OUTFIT_MANAGER then
        CHAT_SYSTEM:AddMessage("  ZO_OUTFIT_MANAGER: nil")
        return
    end
    local om = ZO_OUTFIT_MANAGER:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, 1)
    if not om then
        CHAT_SYSTEM:AddMessage("  outfitManipulator(1): nil")
        return
    end
    local methodCandidates = {
        "IsActive", "IsWorn", "IsEquipped", "GetWornIndex",
        "IsCurrentlyEquipped", "GetActiveOutfitIndex",
    }
    for _, name in ipairs(methodCandidates) do
        local fn = om[name]
        if fn then
            local ok, val = pcall(fn, om)
            CHAT_SYSTEM:AddMessage(string.format(
                "  om:%s() ok=%s val=%s", name, tostring(ok), tostring(val)
            ))
        else
            CHAT_SYSTEM:AddMessage(string.format("  om:%s: nil", name))
        end
    end
end
