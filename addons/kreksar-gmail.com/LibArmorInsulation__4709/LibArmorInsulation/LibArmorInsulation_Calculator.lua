-- LibArmorInsulation_Calculator.lua
-- Handles all insulation calculations. Reads from LibArmorInsulation.Data and
-- applies user overrides from the saved variables table.
--
-- ESO API functions used (all confirmed in the ESO Lua API reference):
--
--   GetActiveCollectibleByType(collectibleCategoryType)
--     → collectibleId (number) or 0 if none active
--     Ref: https://wiki.esoui.com/GetActiveCollectibleByType
--     NOTE: COLLECTIBLE_CATEGORY_TYPE_COSTUME is the only confirmed category
--     constant for appearance collectibles. There is no separate
--     COLLECTIBLE_CATEGORY_TYPE_POLYMORPH in the ESO constants.
--
--   GetCollectibleName(collectibleId)
--     → name (string) – localized display name
--     Ref: https://wiki.esoui.com/GetCollectibleName
--
--   GetCollectibleId(categoryIndex, subcategoryIndex, collectibleIndex)
--     → collectibleId (number)
--     Ref: https://wiki.esoui.com/GetCollectibleId
--     NOTE: Used to iterate all collectibles and find one that is active,
--     because there is no single "get active outfit index" function in the
--     confirmed ESO API.
--
--   GetItemLink(bagId, slotIndex, linkStyle)
--     → itemLink (string) or "" if slot is empty
--     Ref: https://wiki.esoui.com/GetItemLink
--
--   GetItemLinkItemStyle(itemLink)
--     → itemStyle (number) – ITEM_STYLE_* for any item regardless of origin
--     Ref: https://wiki.esoui.com/GetItemLinkItemStyle
--     NOTE: This is the correct function for style lookups. GetItemStyle()
--     only returns non-zero for player-crafted items; every dropped, set,
--     or crown-store piece returns ITEM_STYLE_NONE (0) from GetItemStyle.
--
--   GetEquippedOutfitIndex()
--     → integer (1-based outfit index) if an outfit is worn, nil if none.
--     Confirmed in-game. This is the correct gate for the outfit path.
--
--   ZO_OUTFIT_MANAGER:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitIndex)
--     → outfitManipulator object, or nil if no outfit at that index.
--     outfitIndex is 1-based and matches GetEquippedOutfitIndex().
--     The single-arg form returns nil (actorCategory required).
--
--   outfitManipulator:GetSlotManipulator(OUTFIT_SLOT_*)
--     → slotManipulator object for the given slot constant.
--
--   slotManipulator:GetCurrentCollectibleId()
--     → collectibleId (number) — Collections-system ID of the style on this
--     slot, or 0 if none. NOT an ITEM_STYLE_* integer.
--     Confirmed in-game: returns correct IDs for all 7 body slots.
--
--   GetNumUnlockedOutfits()
--     → numOutfits (number) – total number of outfits the player has unlocked
--     Ref: https://forums.elderscrollsonline.com/en/discussion/388894/update-17-api-patch-notes-change-log-pts
--     NOTE: This function takes NO arguments. A GameplayActorCategory parameter
--     does NOT exist on this function per the confirmed API documentation.
--     GetNumOutfits() is not a real API function and will crash with
--     "function expected instead of nil".
--
--   BAG_WORN constant
--     Ref: https://wiki.esoui.com/Bag
--
--   GetItemStyleName(styleId)
--     → name (string) – English display name for the given StyleItemIndex integer.
--     Called during BuildStyleIdMaps() at init to invert the id→name mapping.
--     Ref: https://wiki.esoui.com/GetItemStyleName
--
--   GetHighestItemStyleId()
--     → integer – the largest StyleItemIndex currently defined by the game engine.
--     Used as the upper bound when iterating all styles in BuildStyleIdMaps().
--     Ref: https://wiki.esoui.com/GetHighestItemStyleId

LibArmorInsulation = LibArmorInsulation or {}
LibArmorInsulation.Data = LibArmorInsulation.Data or {}

local Calc = {}
LibArmorInsulation.Calc = Calc

-- ─────────────────────────────────────────────────────────────────────────────
-- Style ID ↔ Name maps
-- ─────────────────────────────────────────────────────────────────────────────
-- WHY NAME-KEYED?
-- StyleItemIndex integers can be reassigned between ESO API updates (ZOS has
-- done this with style IDs in the past — the same thing that can happen to zone
-- IDs).  The English name returned by GetItemStyleName() is stable across those
-- reassignments.  We therefore key LibArmorInsulation.Data.Styles by English
-- name (see StyleData.lua) and maintain two runtime maps that are rebuilt from
-- the live game data every time the addon loads:
--
--   LibArmorInsulation.Data.StyleIdByName  – { ["Nord"] = 5, … }
--   LibArmorInsulation.Data.StyleNameById  – { [5] = "Nord", … }
--
-- All lookups in this file go: styleId → StyleNameById → styleName → Styles[].
-- The raw integer still flows in from GetItemLinkItemStyle() — that API is
-- unchanged — but the integer is only ever used as a transient key into the
-- runtime maps, never stored or hardcoded.

-- BuildStyleIdMaps()
-- Must be called once from LibArmorInsulation.lua inside EVENT_ADD_ON_LOADED,
-- after ESO's API is fully initialised (GetItemStyleName is nil before that).
-- Iterates every style ID from 1 to GetHighestItemStyleId(), normalises the
-- English name, and writes both forward and reverse maps.
function Calc.BuildStyleIdMaps()
    local byName = {}
    local byId   = {}
    local highest = GetHighestItemStyleId and GetHighestItemStyleId() or 0
    for id = 1, highest do
        local name = GetItemStyleName(id)
        if name and name ~= "" then
            -- Normalise: collapse whitespace, trim, but preserve case because
            -- Styles[] keys in StyleData.lua use title-case English names.
            name = name:gsub("%s+", " "):match("^%s*(.-)%s*$")
            byName[name] = id
            byId[id]     = name
        end
    end
    LibArmorInsulation.Data.StyleIdByName = byName
    LibArmorInsulation.Data.StyleNameById = byId
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Internal helpers
-- ─────────────────────────────────────────────────────────────────────────────

-- Returns the data entry for a given StyleItemIndex integer.
-- Resolution order:
--   1. StyleNameById[styleId]  → English name from the live runtime map
--   2. Styles[name]            → data keyed by that stable name
--   3. Styles["DEFAULT"]       → fallback if the style is unknown
-- This means a ZOS reassignment of integers only invalidates the runtime maps
-- (rebuilt automatically at next login), never the data table itself.
local function GetStyleData(styleId)
    local db   = LibArmorInsulation.Data.Styles
    local name = LibArmorInsulation.Data.StyleNameById[styleId]
    if name then
        return db[name] or db["DEFAULT"], name
    end
    return db["DEFAULT"], nil
end

-- Returns the data entry for a given outfit collectible ID, or the DEFAULT
-- entry. Outfit slots yield collectible IDs (Collections system integers),
-- not ITEM_STYLE_* values — these two number spaces are unrelated.
--
-- Lookup priority (highest to lowest), mirroring the costume resolver:
--   1. OutfitStyles[id]              (hand-curated data table, most reliable)
--   2. sv.outfitStyleCache[id]        (runtime cache built by /scanoutfitstyles)
--   3. OutfitStyles["DEFAULT"]        (leather-equivalent fallback)
-- Per-slot direct overrides ("outfit_N") are checked separately, one level up,
-- in ComputeOutfitSlotInsulation — they always win over all three of these.
-- Strips a trailing " Style" suffix from a collectible name, since outfit-style
-- collectibles are often named "X Style" while the matching Styles[] table key
-- (shared with crafted-armor motifs) is just "X". E.g. "Necrom Armiger Style"
-- -> "Necrom Armiger". Also trims whitespace and collapses internal spaces,
-- mirroring the normalisation already used in BuildStyleIdMaps().
function LibArmorInsulation.Calc.NormaliseOutfitStyleName(name)
    if not name or name == "" then return nil end
    name = name:gsub("%s+", " "):match("^%s*(.-)%s*$")
    name = name:gsub("%s+Style$", "")
    return name
end

-- Returns the data entry for a given outfit collectible ID, or the DEFAULT
-- entry. Outfit slots yield collectible IDs (Collections system integers),
-- not ITEM_STYLE_* values — these two number spaces are unrelated.
--
-- Lookup priority (highest to lowest), mirroring the costume resolver:
--   1. OutfitStyles[id]              (hand-curated data table, most reliable)
--   2. Styles[name]                  (the SAME table used for crafted-armor
--                                     motifs — most outfit-style collectibles
--                                     are just account-wide unlockable motifs,
--                                     so the name usually matches an existing
--                                     entry. Name is derived from
--                                     GetCollectibleName(id), since there is
--                                     no direct collectibleId -> styleName API
--                                     the way GetItemStyleName() works for
--                                     ITEM_STYLE_* integers.)
--   3. sv.outfitStyleCache[id]        (runtime cache built by /scanoutfitstyles)
--   4. OutfitStyles["DEFAULT"]        (leather-equivalent fallback)
-- Per-slot direct overrides ("outfit_N") are checked separately, one level up,
-- in ComputeOutfitSlotInsulation — they always win over all four of these.
local function GetOutfitStyleData(collectibleId)
    local db = LibArmorInsulation.Data.OutfitStyles
    if db[collectibleId] then
        return db[collectibleId]
    end

    local rawName = GetCollectibleName and GetCollectibleName(collectibleId)
    local styleName = Calc.NormaliseOutfitStyleName(rawName)
    if styleName then
        local styleEntry = LibArmorInsulation.Data.Styles[styleName]
        if styleEntry then
            return styleEntry
        end
    end

    local cache = LibArmorInsulation
                  and LibArmorInsulation.sv
                  and LibArmorInsulation.sv.outfitStyleCache
                  and LibArmorInsulation.sv.outfitStyleCache[collectibleId]
    if cache then
        return {
            baseMaterial = cache.baseMaterial,
            coverage     = cache.coverage,
            flavorBonus  = cache.flavorBonus,
            flavorNote   = cache.flavorNote,
        }
    end
    return db["DEFAULT"]
end

-- Scale factor normalises the raw formula so that a full set of standard
-- leather armor at coverage 1.0 scores exactly 50 (the tier 50 midpoint).
-- Derivation: slotWeightSum(0.90) * coverage(1.0) * leather(1.0) * SCALE = 50
-- → SCALE = 50 / (0.90 * 1.0 * 1.0) = 55.556
local SCALE_FACTOR = 50 / (0.90 * 1.0 * 1.0)

-- ─────────────────────────────────────────────────────────────────────────────
-- Tier snapping
-- ─────────────────────────────────────────────────────────────────────────────
-- Rounds a raw continuous score onto the nearest of the eleven fixed tiers
-- in LibArmorInsulation.Data.TIER_VALUES. Mundane entries (allowMagical is
-- falsy/nil) are clamped to [MUNDANE_MIN, MUNDANE_MAX] (0-80) BEFORE snapping,
-- so ordinary materials can never land on the -10/90 tiers reserved for
-- magically cooled/heated sources. Entries with `magical = true` (e.g. Flame
-- Atronach, Ice Wraith) are clamped to the full tier range instead.
function Calc.SnapToTier(rawValue, allowMagical)
    local tiers = LibArmorInsulation.Data.TIER_VALUES
    local v = rawValue or 0

    if allowMagical then
        v = math.max(tiers[1], math.min(tiers[#tiers], v))
    else
        v = math.max(LibArmorInsulation.Data.MUNDANE_MIN, math.min(LibArmorInsulation.Data.MUNDANE_MAX, v))
    end

    local best, bestDiff = tiers[1], math.huge
    for _, tier in ipairs(tiers) do
        local diff = math.abs(tier - v)
        if diff < bestDiff then
            bestDiff = diff
            best = tier
        end
    end
    return best
end

-- Returns the display label for a tier value (e.g. 60 -> "Heavy Leather/Fur").
function Calc.GetTierLabel(tierValue)
    local info = LibArmorInsulation.Data.TierInfo[tierValue]
    return info and info.label or "Unknown"
end

-- Rounds to the nearest integer, handling negative values correctly
-- (math.floor(x + 0.5) alone rounds negatives toward positive infinity,
-- which is wrong for our purposes since tiers can be negative).
local function RoundToInt(x)
    if x >= 0 then
        return math.floor(x + 0.5)
    end
    return -math.floor(-x + 0.5)
end

-- Converts a flat AutoRate target into a baseMaterial guess for OutfitStyles,
-- since outfit style pieces use the same full-body formula as armor styles
-- (not a flat whole-body value like costumes). We pick the material whose
-- full-coverage reference value is closest to the target, with coverage=1.0
-- and flavorBonus=0 implied — i.e. let the material coefficient alone carry
-- the guess, the same way most hand-authored Styles[] entries do.
--
-- CORRECTION (v2.6.0): this previously used `coeff * SCALE_FACTOR` (55.556),
-- omitting the 0.90 slot-weight-sum factor baked into every other full-body
-- reference calculation in this file (see GetStyleTier below and the historic
-- GetInsulationForStyle formula). That meant NearestMaterialForTarget's
-- reference numbers (fur=100, leather=55.6, ...) did not match the documented
-- full-set reference table at the top of LibArmorInsulation_StyleData.lua
-- (fur=90, leather=50, ...). Fixed to multiply by 0.90 like everywhere else.
function LibArmorInsulation.Calc.NearestMaterialForTarget(target)
    local bestMaterial, bestDiff = "leather", math.huge
    for material, coeff in pairs(LibArmorInsulation.Data.MaterialCoefficient) do
        if material ~= "none" then
            local reference = 0.90 * coeff * SCALE_FACTOR
            local diff = math.abs(reference - target)
            if diff < bestDiff then
                bestDiff = diff
                bestMaterial = material
            end
        end
    end
    return bestMaterial
end

-- Returns the material insulation coefficient.
local function GetMaterialCoeff(materialName)
    local coeffs = LibArmorInsulation.Data.MaterialCoefficient
    return coeffs[materialName] or coeffs["leather"]
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Style / outfit-style TIER resolution
-- ─────────────────────────────────────────────────────────────────────────────
-- Returns the intrinsic, FULL-BODY reference TIER (-10..90, always one of
-- LibArmorInsulation.Data.TIER_VALUES) for a given ITEM_STYLE_* integer.
-- A user override always wins and is honoured as-is — overrides are chosen
-- from the tier dropdown in Settings, so they are already a valid tier value.
-- Returns: tier (integer), resolved style name (or nil if unknown/overridden)
function Calc.GetStyleTier(styleId, overrides)
    local overrideKey = "style_" .. tostring(styleId)
    if overrides and overrides[overrideKey] ~= nil then
        return overrides[overrideKey], nil
    end
    local data, styleName = GetStyleData(styleId)
    local matCoeff = GetMaterialCoeff(data.baseMaterial)
    local raw = 0.90 * data.coverage * matCoeff * SCALE_FACTOR + data.flavorBonus
    return Calc.SnapToTier(raw, data.magical), styleName
end

-- Same as Calc.GetStyleTier, but for outfit-style collectible IDs.
function Calc.GetOutfitStyleTier(collectibleId, overrides)
    local overrideKey = "outfit_" .. tostring(collectibleId)
    if overrides and overrides[overrideKey] ~= nil then
        return overrides[overrideKey]
    end
    local data = GetOutfitStyleData(collectibleId)
    local matCoeff = GetMaterialCoeff(data.baseMaterial)
    local raw = 0.90 * data.coverage * matCoeff * SCALE_FACTOR + (data.flavorBonus or 0)
    return Calc.SnapToTier(raw, data.magical)
end

-- Computes a single armor slot's CONTRIBUTION to the total: the style's
-- full-body tier scaled down (or up) by what percentage of the body this
-- slot covers. This is the "adjusted by a percentage based on what slot of
-- armor it is" step — the tier itself never changes, only its weight in the
-- final sum.
-- slotPercentage : 0-1 weight from SlotCoverage table (sums to 1.00 overall)
-- styleId        : StyleItemIndex integer from GetItemLinkItemStyle()
-- overrides      : saved-variable overrides table (may be nil)
-- Returns        : contribution (integer, rounded), resolved style name, tier
local function ComputeSlotInsulation(slotPercentage, styleId, overrides)
    if slotPercentage == 0 then return 0, nil, nil end
    local tier, styleName = Calc.GetStyleTier(styleId, overrides)
    return RoundToInt(tier * slotPercentage), styleName, tier
end

-- Same as ComputeSlotInsulation, but for outfit slots (collectible IDs).
-- Returns: contribution (integer, rounded), tier
local function ComputeOutfitSlotInsulation(slotPercentage, collectibleId, overrides)
    if slotPercentage == 0 then return 0, nil end
    local tier = Calc.GetOutfitStyleTier(collectibleId, overrides)
    return RoundToInt(tier * slotPercentage), tier
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Costume / Polymorph detection
-- ─────────────────────────────────────────────────────────────────────────────
-- GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME) returns the
-- collectible id of whichever costume or polymorph is currently active, or 0.
-- COLLECTIBLE_CATEGORY_TYPE_COSTUME is the confirmed constant for this.
-- There is no separate COLLECTIBLE_CATEGORY_TYPE_POLYMORPH constant.
--
-- IMPORTANT - name matching limitation:
-- GetCollectibleName returns the *localized* display name (e.g. in French on
-- a French client). Our data table is keyed on lowercase English strings.
-- If the name does not match any table entry we fall through to DEFAULT_COSTUME.
-- The collectible ID is stored in result.costumeId so callers or future
-- versions can look up by ID instead.

local function GetActiveAppearanceCollectible()
    local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
    if collectibleId and collectibleId ~= 0 then
        local name = GetCollectibleName(collectibleId)
        if name then
            -- Normalize: lowercase, collapse multiple spaces, trim ends.
            -- This makes the name-keyed table lookup more robust against minor
            -- formatting differences between client versions or locales.
            name = name:lower()
            name = name:gsub("%s+", " ")
            name = name:match("^%s*(.-)%s*$")
        end
        return collectibleId, name or ""
    end
    return nil, nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Outfit detection
-- ─────────────────────────────────────────────────────────────────────────────
-- Confirmed working API path (verified in-game):
--
--   GetEquippedOutfitIndex()
--     → integer (1-based) if an outfit is currently worn, nil if none equipped.
--     This is the correct gate for the outfit path — GetCurrentCollectibleId()
--     returns saved slot data regardless of whether the outfit is worn, so
--     without this check the outfit path fires even when the player is showing
--     their actual armor.
--
--   ZO_OUTFIT_MANAGER:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitIndex)
--     → outfit manipulator object, or nil if no outfit at that index.
--     outfitIndex is 1-based and matches the value from GetEquippedOutfitIndex().
--     The single-arg form GetOutfitManipulator(outfitIndex) returns nil.
--
--   outfitManipulator:GetSlotManipulator(OUTFIT_SLOT_*)
--     → slot manipulator object for the given slot constant.
--
--   slotManipulator:GetCurrentCollectibleId()
--     → collectible ID (Collections system integer) for the style applied to
--     this slot, or 0 if no style is set. NOT an ITEM_STYLE_* integer.
--
-- Confirmed non-working approaches (kept to avoid re-investigation):
--   GetOutfitSlotInfo(outfitIndex, outfitSlot)  — only returns data for one
--     slot regardless of how many are styled (the last slot touched in the UI).
--   GetActiveOutfitIndex(), GetOutfitStyleId(), GetOutfitSlotData()  — nil.
--   GetCollectibleInfo r7 (isActive) on outfit-style collectibles  — always false.
--   ZO_OUTFIT_MANAGER:GetOutfitManipulator(outfitIndex) single-arg form  — nil.
--   All other "get active/worn/equipped outfit index" free functions  — nil.

-- Maps each OUTFIT_SLOT_* constant to a stable string key and its paired
-- EQUIP_SLOT_* constant for the armor-fallback lookup.
-- Built lazily post-init so OUTFIT_SLOT_* and EQUIP_SLOT_* globals are valid.
local outfitSlotMeta = nil

local function BuildOutfitSlotMeta()
    outfitSlotMeta = {
        [OUTFIT_SLOT_HEAD]      = { key = "head",      equipSlot = EQUIP_SLOT_HEAD },
        [OUTFIT_SLOT_CHEST]     = { key = "chest",     equipSlot = EQUIP_SLOT_CHEST },
        [OUTFIT_SLOT_LEGS]      = { key = "legs",      equipSlot = EQUIP_SLOT_LEGS },
        [OUTFIT_SLOT_HANDS]     = { key = "hands",     equipSlot = EQUIP_SLOT_HAND },
        [OUTFIT_SLOT_FEET]      = { key = "feet",      equipSlot = EQUIP_SLOT_FEET },
        [OUTFIT_SLOT_WAIST]     = { key = "waist",     equipSlot = EQUIP_SLOT_WAIST },
        [OUTFIT_SLOT_SHOULDERS] = { key = "shoulders", equipSlot = EQUIP_SLOT_SHOULDERS },
    }
end

local function GetFirstStyledOutfitInsulation(overrides)
    -- GetEquippedOutfitIndex() returns the 1-based index of the outfit currently
    -- worn by the player, or nil if no outfit is equipped. Confirmed in-game:
    --   equipped → integer (e.g. 1)
    --   unequipped → nil
    -- This replaces the previous "iterate all outfits" approach, which incorrectly
    -- triggered on saved-but-unequipped outfits because GetCurrentCollectibleId()
    -- returns stored slot data regardless of whether the outfit is worn.
    if not ZO_OUTFIT_MANAGER then return nil end

    local equippedIndex = GetEquippedOutfitIndex()
    if not equippedIndex then return nil end  -- no outfit worn

    if not outfitSlotMeta then BuildOutfitSlotMeta() end

    local outfitManipulator = ZO_OUTFIT_MANAGER:GetOutfitManipulator(
        GAMEPLAY_ACTOR_CATEGORY_PLAYER, equippedIndex
    )
    if not outfitManipulator then return nil end

    local outfitSlotCoverage = LibArmorInsulation.Data.OutfitSlotCoverage
    local total       = 0
    local slots       = {}
    local hasAnyStyle = false

    for outfitSlot, slotCoverage in pairs(outfitSlotCoverage) do
        if slotCoverage > 0 then
            local meta = outfitSlotMeta[outfitSlot]
            if meta then
                local slotManipulator = outfitManipulator:GetSlotManipulator(outfitSlot)
                local collectibleId   = slotManipulator and
                    slotManipulator:GetCurrentCollectibleId() or 0

                if collectibleId ~= 0 then
                    hasAnyStyle = true
                    local ins, tier = ComputeOutfitSlotInsulation(slotCoverage, collectibleId, overrides)
                    local data = GetOutfitStyleData(collectibleId)
                    total = total + ins
                    slots[meta.key] = {
                        collectibleId  = collectibleId,
                        name           = (GetCollectibleName and GetCollectibleName(collectibleId)) or nil,
                        insulation     = ins,
                        tier           = tier,
                        slotPercentage = slotCoverage,
                        material       = data.baseMaterial,
                        flavorNote     = data.flavorNote,
                    }
                else
                    -- No outfit style on this slot — the underlying worn armor
                    -- piece shows through visually, so use its style instead.
                    local itemLink = GetItemLink(BAG_WORN, meta.equipSlot)
                    if itemLink and itemLink ~= "" then
                        local armorStyleId = GetItemLinkItemStyle(itemLink) or 0
                        local ins, styleName, tier = ComputeSlotInsulation(slotCoverage, armorStyleId, overrides)
                        local data = GetStyleData(armorStyleId)
                        total = total + ins
                        slots[meta.key] = {
                            styleId        = armorStyleId,
                            styleName      = styleName,
                            insulation     = ins,
                            tier           = tier,
                            slotPercentage = slotCoverage,
                            material       = data.baseMaterial,
                            flavorNote     = data.flavorNote,
                            armorFallback  = true,
                        }
                    end
                end
            end
        end
    end

    if hasAnyStyle then
        -- Clamp total to the tier range after summing rounded slot
        -- contributions (a small rounding artifact is possible since each
        -- slot is rounded independently, but should never push total outside
        -- the -10..90 range the tiers themselves are bounded by).
        return math.max(-10, math.min(90, total)), slots
    end
    return nil
end

-- Maps each EQUIP_SLOT_* constant to its stable string key.
-- Built lazily post-init alongside outfitSlotMeta.
local equipSlotMeta = nil

local function BuildEquipSlotMeta()
    equipSlotMeta = {
        [EQUIP_SLOT_HEAD]      = "head",
        [EQUIP_SLOT_CHEST]     = "chest",
        [EQUIP_SLOT_LEGS]      = "legs",
        [EQUIP_SLOT_HAND]      = "hands",
        [EQUIP_SLOT_FEET]      = "feet",
        [EQUIP_SLOT_WAIST]     = "waist",
        [EQUIP_SLOT_SHOULDERS] = "shoulders",
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Public API
-- ─────────────────────────────────────────────────────────────────────────────

-- GetInsulationForStyle(styleId)
-- Returns the full-set reference TIER of a style (-10..90, one of the eleven
-- fixed tiers). This is the value a complete matching set in this style
-- would contribute as the total (a full set reproduces its tier exactly,
-- since per-slot percentages sum to 1.00 — see ComputeSlotInsulation).
-- styleId : StyleItemIndex integer from GetItemLinkItemStyle()
-- returns : tier (integer), English style name (or nil if unknown/overridden)
function Calc.GetInsulationForStyle(styleId, overrides)
    return Calc.GetStyleTier(styleId, overrides)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Independent per-layer resolvers (Settings panel "Layer" dropdown)
-- ─────────────────────────────────────────────────────────────────────────────
-- GetInsulationBreakdown() below follows ESO's visual precedence — polymorph/
-- costume beats outfit beats worn armor — and only reports on whichever layer
-- is actually WINNING. That's correct for "what insulation am I getting right
-- now", but it means you can't ask "what's my armor style on this slot" while
-- a costume is active, since the breakdown short-circuits before ever look at
-- armor. The three functions below answer each layer's question directly,
-- with no precedence involved, so the Settings panel's Layer/Slot dropdowns
-- can look up live data for ANY layer regardless of what's currently showing.

-- Resolves whatever costume or polymorph is currently active (independent of
-- outfit/armor state — GetActiveCollectibleByType() is checked directly).
-- Returns : {
--   active          : boolean — false if no costume/polymorph is active
--   isPolymorph     : boolean
--   collectibleId   : number or nil
--   collectibleName : string or nil (raw display name, original case)
--   tier            : integer -10..90 (a placeholder DEFAULT_COSTUME-based
--                     tier when not active, so the Settings panel always has
--                     something sensible to prefill)
--   note            : string
-- }
function Calc.ResolveCostumeOrPolymorph(overrides)
    local collectibleId, collectibleName = GetActiveAppearanceCollectible()
    local costumeDb = LibArmorInsulation.Data.CostumeInsulation

    if not collectibleId then
        return {
            active          = false,
            isPolymorph     = false,
            collectibleId   = nil,
            collectibleName = nil,
            tier            = Calc.SnapToTier(costumeDb["DEFAULT_COSTUME"].totalInsulation),
            note            = "No costume or polymorph is currently active.",
        }
    end

    local polymorphDb   = LibArmorInsulation.Data.PolymorphInsulation
    local polymorphIdDb = LibArmorInsulation.Data.PolymorphInsulationById or {}
    local costumeIdDb   = LibArmorInsulation.Data.CostumeInsulationById or {}

    -- Polymorphs and costumes share the SAME override key namespace
    -- ("costume_<id>") and the same GetActiveCollectibleByType() detection
    -- path (ESO has no separate COLLECTIBLE_CATEGORY_TYPE_POLYMORPH), so an
    -- override's mere presence can't be used to decide which one this is —
    -- that classification must come ONLY from table membership.
    local overrideKey   = "costume_" .. tostring(collectibleId)
    local overrideValue = overrides and overrides[overrideKey]

    -- Check polymorph tables first (ID, then name) — membership only.
    local polymorphEntry = polymorphIdDb[collectibleId] or polymorphDb[collectibleName]
    if polymorphEntry then
        local tier = overrideValue or Calc.SnapToTier(polymorphEntry.totalInsulation, polymorphEntry.magical)
        return {
            active          = true,
            isPolymorph     = true,
            collectibleId   = collectibleId,
            collectibleName = (GetCollectibleName and GetCollectibleName(collectibleId)) or collectibleName,
            tier            = tier,
            note            = overrideValue and ("User override: " .. tostring(overrideValue) .. " (" .. Calc.GetTierLabel(overrideValue) .. ")") or polymorphEntry.flavorNote,
        }
    end

    -- Not a polymorph — treat as costume.
    -- Lookup priority (highest to lowest):
    --   1. User override  "costume_NNNN"  (Settings panel; always wins)
    --   2. CostumeInsulationById[id]       (hard-coded data table, most reliable)
    --   3. CostumeInsulation[normName]     (manually-curated name table — PRIMARY default source;
    --                                       may fail on non-EN clients)
    --   4. sv.costumeCache[id]             (runtime cache built by /scancostumes — fills gaps
    --                                       the manual table doesn't cover)
    --   5. DEFAULT_COSTUME fallback (leather-equivalent) — only when neither the manual table
    --                                       nor the scanner has an entry
    local costumeEntry = costumeIdDb[collectibleId]
    local nameEntry     = (not costumeEntry) and costumeDb[collectibleName]
    local cacheEntry    = (not costumeEntry)
                          and (not nameEntry)
                          and LibArmorInsulation.sv
                          and LibArmorInsulation.sv.costumeCache
                          and LibArmorInsulation.sv.costumeCache[collectibleId]
    local tier
    local note
    if overrideValue then
        tier = overrideValue
        note = "User override: " .. tostring(overrideValue) .. " (" .. Calc.GetTierLabel(overrideValue) .. ")"
    elseif costumeEntry then
        tier = Calc.SnapToTier(costumeEntry.totalInsulation, costumeEntry.magical)
        note = costumeEntry.flavorNote or ""
    elseif nameEntry then
        tier = Calc.SnapToTier(nameEntry.totalInsulation, nameEntry.magical)
        note = nameEntry.flavorNote or ""
    elseif cacheEntry then
        tier = Calc.SnapToTier(cacheEntry.insulation, cacheEntry.magical)
        local tag = cacheEntry.autoRated and " [auto-rated]" or ""
        note = cacheEntry.name .. tag
    else
        tier = Calc.SnapToTier(costumeDb["DEFAULT_COSTUME"].totalInsulation)
        note = "Unknown costume (ID " .. tostring(collectibleId) .. ") — run /scancostumes to register"
    end

    return {
        active          = true,
        isPolymorph     = false,
        collectibleId   = collectibleId,
        collectibleName = (GetCollectibleName and GetCollectibleName(collectibleId)) or collectibleName,
        tier            = tier,
        note            = note,
    }
end

-- Resolves the ARMOR style worn in a specific canonical slot ("head", "chest",
-- etc.), independent of whether an outfit or costume is currently displayed
-- instead. Always reads GetItemLink(BAG_WORN, ...) directly.
-- Returns : {
--   active    : boolean — false if nothing is equipped in this slot
--   styleId   : number or nil
--   styleName : string or nil
--   tier      : integer -10..90 (tier 50 placeholder when nothing's equipped)
--   note      : string
-- }
function Calc.ResolveArmorSlot(slotKey, overrides)
    local equipSlot = LibArmorInsulation.Data.EquipSlotByKey[slotKey]
    if not equipSlot then
        return { active = false, tier = 50, note = "Unknown slot." }
    end
    local itemLink = GetItemLink(BAG_WORN, equipSlot)
    if not itemLink or itemLink == "" then
        return { active = false, tier = 50, note = "Nothing is equipped in this slot." }
    end
    local styleId = GetItemLinkItemStyle(itemLink) or 0
    local tier, styleName = Calc.GetStyleTier(styleId, overrides)
    return { active = true, styleId = styleId, styleName = styleName, tier = tier }
end

-- Resolves the OUTFIT style set for a specific canonical slot, independent of
-- whether a costume is currently displayed instead. Always checks whichever
-- outfit is actually EQUIPPED (GetEquippedOutfitIndex()) — NOT the armor
-- fallback GetFirstStyledOutfitInsulation() uses; that fallback belongs to
-- the "what's actually showing" precedence question, not "what does my
-- outfit say for this slot", which is what this function answers.
-- Returns : {
--   active        : boolean — false if no outfit equipped, or no style set on this slot
--   collectibleId : number or nil
--   name          : string or nil
--   tier          : integer -10..90 (tier 50 placeholder when not active)
--   note          : string
-- }
function Calc.ResolveOutfitSlot(slotKey, overrides)
    if not ZO_OUTFIT_MANAGER then
        return { active = false, tier = 50, note = "No outfit system available." }
    end
    local equippedIndex = GetEquippedOutfitIndex()
    if not equippedIndex then
        return { active = false, tier = 50, note = "No outfit is currently equipped." }
    end
    local outfitSlotConst = LibArmorInsulation.Data.OutfitSlotByKey[slotKey]
    if not outfitSlotConst then
        return { active = false, tier = 50, note = "Unknown slot." }
    end
    local om = ZO_OUTFIT_MANAGER:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, equippedIndex)
    if not om then
        return { active = false, tier = 50, note = "No outfit is currently equipped." }
    end
    local sm = om:GetSlotManipulator(outfitSlotConst)
    local collectibleId = sm and sm:GetCurrentCollectibleId() or 0
    if collectibleId == 0 then
        return { active = false, tier = 50, note = "No outfit style is set for this slot (worn armor shows through)." }
    end
    local tier = Calc.GetOutfitStyleTier(collectibleId, overrides)
    local name = (GetCollectibleName and GetCollectibleName(collectibleId)) or nil
    return { active = true, collectibleId = collectibleId, name = name, tier = tier }
end

-- GetInsulationBreakdown()
-- Returns a table describing the current insulation for the player.
-- Returns : {
--     source      : "polymorph" | "costume" | "outfit" | "armor" | "naked",
--     total       : number, -10..90 (composite for armor/outfit; an exact
--                   tier value for costume/polymorph, which are not
--                   slot-adjusted)
--     slots       : { [slotKey] = {
--                       styleId | collectibleId, styleName, insulation,
--                       tier            -- the style/costume's own -10..90 tier
--                       slotPercentage  -- 0-1, omitted for costume/polymorph
--                       material, flavorNote, armorFallback
--                   } },
--     costumeId   : number or nil,
--     costumeName : string or nil,
-- }
-- For armor/outfit slots: insulation = round(tier * slotPercentage), i.e. the
-- slot's share of the total. For costume/polymorph: insulation == tier (the
-- whole-body value, unadjusted).
function Calc.GetInsulationBreakdown(overrides)
    local result = {
        source      = "naked",
        total       = 0,
        slots       = {},
        costumeId   = nil,
        costumeName = nil,
    }

    -- ── PRIORITY 1 & 2: Polymorph / Costume ─────────────────────────────────
    -- Both detected via COLLECTIBLE_CATEGORY_TYPE_COSTUME. See
    -- Calc.ResolveCostumeOrPolymorph() above for the full lookup order.
    local costumeInfo = Calc.ResolveCostumeOrPolymorph(overrides)
    if costumeInfo.active then
        result.source      = costumeInfo.isPolymorph and "polymorph" or "costume"
        result.costumeId   = costumeInfo.collectibleId
        result.costumeName = costumeInfo.collectibleName
        result.total       = costumeInfo.tier
        local slotKey = costumeInfo.isPolymorph and "[Polymorph]" or "[Costume]"
        result.slots[slotKey] = {
            collectibleId = costumeInfo.collectibleId,
            name          = costumeInfo.collectibleName,
            insulation    = costumeInfo.tier,
            tier          = costumeInfo.tier,
            material      = costumeInfo.isPolymorph and "form" or "costume",
            flavorNote    = costumeInfo.note,
        }
        return result
    end

    -- ── PRIORITY 3: Outfit styles ────────────────────────────────────────────
    -- GetEquippedOutfitIndex() gates this path: returns the 1-based index of
    -- the worn outfit, or nil if none is equipped. Without this gate,
    -- GetCurrentCollectibleId() would return saved slot data even for outfits
    -- the player is not currently wearing.
    local outfitTotal, outfitSlots = GetFirstStyledOutfitInsulation(overrides)
    if outfitTotal ~= nil then
        result.source = "outfit"
        result.total  = outfitTotal
        result.slots  = outfitSlots
        return result
    end

    -- ── PRIORITY 4: Worn armor ───────────────────────────────────────────────
    -- GetItemLink(BAG_WORN, slot) → item link string, or "" if empty.
    -- GetItemLinkItemStyle(link) → ITEM_STYLE_* for any item regardless of origin.
    -- Slots are keyed by stable lowercase strings ("head", "chest", etc.) —
    -- NOT by raw EQUIP_SLOT_* integers — so that GetSlotLabel resolves them
    -- consistently regardless of which path populated the slot.
    if not equipSlotMeta then BuildEquipSlotMeta() end

    local slotCoverageMap = LibArmorInsulation.Data.SlotCoverage
    local total           = 0
    local hasAnyArmor     = false

    for equipSlot, slotCoverage in pairs(slotCoverageMap) do
        if slotCoverage > 0 then
            local key = equipSlotMeta[equipSlot]
            if key then
                local itemLink = GetItemLink(BAG_WORN, equipSlot)
                if itemLink and itemLink ~= "" then
                    hasAnyArmor   = true
                    local styleId = GetItemLinkItemStyle(itemLink) or 0
                    local ins, styleName, tier = ComputeSlotInsulation(slotCoverage, styleId, overrides)
                    local data = GetStyleData(styleId)
                    total = total + ins
                    result.slots[key] = {
                        styleId        = styleId,
                        styleName      = styleName,
                        insulation     = ins,
                        tier           = tier,
                        slotPercentage = slotCoverage,
                        material       = data.baseMaterial,
                        flavorNote     = data.flavorNote,
                    }
                end
            end
        end
    end

    if hasAnyArmor then
        result.source = "armor"
        -- Clamp to the tier range after summing rounded slot contributions
        -- (see the matching comment in GetFirstStyledOutfitInsulation).
        result.total  = math.max(-10, math.min(90, total))
        return result
    end

    -- ── PRIORITY 5: Nothing – naked ──────────────────────────────────────────
    result.source = "naked"
    result.total  = 0
    return result
end

-- GetTotalInsulation()
-- Convenience wrapper – returns just the number.
function Calc.GetTotalInsulation(overrides)
    return Calc.GetInsulationBreakdown(overrides).total
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Slot label helper
-- ─────────────────────────────────────────────────────────────────────────────
-- result.slots is keyed by stable lowercase strings ("head", "chest", etc.)
-- regardless of whether the slot was populated by the outfit path or the armor
-- path. This map translates those keys to human-readable display labels.
-- The special string keys "[Costume]" and "[Polymorph]" are handled directly.
local slotLabelMap = {
    ["head"]        = "Head",
    ["chest"]       = "Chest",
    ["legs"]        = "Legs",
    ["hands"]       = "Hands",
    ["feet"]        = "Feet",
    ["waist"]       = "Belt",
    ["shoulders"]   = "Shoulders",
    ["[Costume]"]   = "Costume",
    ["[Polymorph]"] = "Polymorph",
}

function Calc.GetSlotLabel(slotKey)
    return slotLabelMap[slotKey] or ("Slot " .. tostring(slotKey))
end
