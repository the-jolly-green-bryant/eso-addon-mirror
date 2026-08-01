-- BuildTracker_LibSetsAdapter.lua
--
-- Every call into the LibSets library lives in this one file. LibSets is
-- actively developed and its function names/signatures have shifted between
-- versions (see its changelog). By routing everything through BuildTracker.Sets,
-- a future LibSets update only requires editing this file, not the rest of
-- the addon.
--
-- Before relying on this in-game, sanity check the wrapped calls against the
-- LibSets version you actually have installed:
--   /libsets   -> lists supported debug/slash commands
-- and the function reference at the top of LibSets.lua in your install,
-- under the "Global helper functions" section.

BuildTracker = BuildTracker or {}
BuildTracker.Sets = {}

local Sets = BuildTracker.Sets

local function GetLib()
    if LibSets == nil then
        BuildTracker.Debug("LibSets is not loaded! Check your DependsOn / install order.")
        return nil
    end
    return LibSets
end

-- Returns a display name for a setId, or nil if unknown.
function Sets.GetSetName(setId)
    local lib = GetLib()
    if not lib then return nil end
    -- LibSets exposes localized set names; GetSetName is the documented call.
    local ok, name = pcall(lib.GetSetName, setId)
    if ok then return name end
    return nil
end

-- Resolve a concrete itemId for a given set + equip slot (+ optional weight/
-- weapon type to disambiguate). This deliberately does NOT use LibSets'
-- GetSetItemId - that function's precomputed table returned stale, dead
-- itemIds from pre-level-unification item data (confirmed in practice: it
-- returned itemId 89638, a legacy id with equipType=0 in current game data,
-- instead of the correct current itemId 108766 for the exact same set+slot).
--
-- Instead: pull every itemId LibSets knows about for the set via
-- GetSetItemIds (a keyed table - keys are itemIds, values are just a
-- membership marker, NOT an array - confirmed via /bt debugsetitems), then
-- ask the BASE GAME (not LibSets) what each one actually is right now via
-- GetItemLinkEquipType/GetItemLinkArmorType/GetItemLinkWeaponType. Dead
-- legacy itemIds consistently report equipType=0 and get skipped.
--
-- equipSlotId is required now too - Main Hand/Backup Main can hold a
-- two-handed weapon, but Off Hand/Backup Off never can (see
-- BuildTracker.CAN_BE_TWO_HANDED_SLOTS), and equipType alone can't tell
-- those apart since all four weapon slots share the same default
-- (EQUIP_TYPE_ONE_HAND) in BuildTracker.SLOT_TO_EQUIP_TYPE.
--
-- armorType/weaponType are optional. If provided, they narrow an ambiguous
-- multi-weight/multi-weapon-type set down to the exact piece. If omitted
-- and multiple current, valid matches exist, this returns the first one
-- found and logs the alternatives via Debug so that ambiguity is visible
-- rather than silently arbitrary.
--
-- Weapon types that are inherently EQUIP_TYPE_TWO_HAND rather than
-- EQUIP_TYPE_ONE_HAND - confirmed real constant names (there is no
-- "WEAPONTYPE_MACE"; one-handed maces are WEAPONTYPE_HAMMER, two-handed
-- ones are the separate WEAPONTYPE_TWO_HANDED_HAMMER). Used below so a
-- weapon slot's caller-supplied equipType (always EQUIP_TYPE_ONE_HAND, from
-- BuildTracker.SLOT_TO_EQUIP_TYPE) doesn't wrongly exclude two-handed
-- pieces once a specific weaponType narrows things down - the weaponType
-- is the more reliable signal for which hand-type is actually correct.
local TWO_HANDED_WEAPON_TYPES = {
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_BOW] = true,
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_HEALING_STAFF] = true,
}

-- Public accessor so the set-picker UI can also exclude two-handed weapon
-- types from the disambiguation dropdown for Off Hand/Backup Off, not just
-- have resolution reject them after the fact.
function Sets.IsTwoHandedWeaponType(weaponType)
    return TWO_HANDED_WEAPON_TYPES[weaponType] == true
end

function Sets.GetItemIdForSlot(setId, equipSlotId, equipType, armorType, weaponType)
    local lib = GetLib()
    if not lib or not equipType then return nil end

    -- Only Main Hand/Backup Main can ever hold a two-handed weapon - Off
    -- Hand/Backup Off must always resolve to a one-handed item (see
    -- BuildTracker.CAN_BE_TWO_HANDED_SLOTS's own comment).
    local canBeTwoHanded = BuildTracker.CAN_BE_TWO_HANDED_SLOTS[equipSlotId] == true

    -- The set of equip types actually acceptable for this attempt. A
    -- specific weaponType (once chosen via disambiguation) tells us the
    -- real hand-type more reliably than the caller's default guess. With no
    -- weaponType yet and a weapon-slot default (EQUIP_TYPE_ONE_HAND), accept
    -- either hand-type on this first pass (main-hand-like slots only) - if
    -- that turns up more than one match, SetBuildSlot's caller already
    -- knows to show a disambiguation UI, same as it already does for
    -- multiple weaponTypes at one hand-type.
    local requiredEquipTypes
    if weaponType and TWO_HANDED_WEAPON_TYPES[weaponType] then
        if not canBeTwoHanded then
            -- A two-handed weaponType was requested for a slot that can
            -- never hold one - no valid resolution, not an error to guess around.
            return nil
        end
        requiredEquipTypes = { [EQUIP_TYPE_TWO_HAND] = true }
    elseif weaponType then
        requiredEquipTypes = { [EQUIP_TYPE_ONE_HAND] = true }
    elseif equipType == EQUIP_TYPE_ONE_HAND and canBeTwoHanded then
        requiredEquipTypes = { [EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_TWO_HAND] = true }
    else
        requiredEquipTypes = { [equipType] = true }
    end

    local ok, itemIdSet = pcall(lib.GetSetItemIds, setId)
    if not ok or type(itemIdSet) ~= "table" then
        BuildTracker.Debug("GetSetItemIds(%s) failed or returned non-table (ok=%s, type=%s)",
            tostring(setId), tostring(ok), type(itemIdSet))
        return nil
    end

    -- isWeaponAttempt: true only when the caller hasn't picked a specific
    -- weaponType yet AND this is a weapon slot - used below to tell a
    -- genuine "this set offers several different weapon types, ask the
    -- user" ambiguity apart from harmless alias itemIds (see the comment
    -- lower down). Recorded per-candidate so it doesn't need a second pass.
    local isWeaponAttempt = not weaponType and not armorType
        and (requiredEquipTypes[EQUIP_TYPE_ONE_HAND] or requiredEquipTypes[EQUIP_TYPE_TWO_HAND])

    -- Mirror of isWeaponAttempt for body-armor slots: no armorType chosen
    -- yet and this isn't a weapon slot (weapon slots have no "weight"
    -- concept). Almost every armor set - not just monster sets - has a
    -- separate itemId per weight (Light/Medium/Heavy), all sharing the same
    -- equipType, so without this check every armor slot silently collapsed
    -- onto whichever weight happened to have the highest itemId instead of
    -- ever asking - the set-picker's armor-weight disambiguation buttons
    -- (BuildTracker_SetPickerUI.lua) were built for exactly this case but
    -- had no way to trigger since this function never returned nil for it.
    local isArmorAttempt = not armorType and not weaponType and not BuildTracker.IsWeaponSlot(equipSlotId)

    local matches = {}
    for itemId in pairs(itemIdSet) do
        local link = Sets.BuildItemLink(itemId)
        if link then
            local ok2, actualEquipType = pcall(GetItemLinkEquipType, link)
            -- equipType 0 = EQUIP_TYPE_INVALID, i.e. a dead/legacy itemId - skip it.
            if ok2 and actualEquipType ~= 0 and requiredEquipTypes[actualEquipType] then
                local isMatch = true
                local candidateWeaponType = nil
                local candidateArmorType = nil
                if armorType then
                    local ok3, actualArmorType = pcall(GetItemLinkArmorType, link)
                    isMatch = ok3 and actualArmorType == armorType
                elseif weaponType then
                    local ok4, actualWeaponType = pcall(GetItemLinkWeaponType, link)
                    isMatch = ok4 and actualWeaponType == weaponType
                elseif isWeaponAttempt then
                    -- No weaponType chosen yet - record each candidate's real
                    -- weaponType so we can tell whether they actually differ.
                    local ok4, actualWeaponType = pcall(GetItemLinkWeaponType, link)
                    candidateWeaponType = ok4 and actualWeaponType or nil
                elseif isArmorAttempt then
                    -- No armorType chosen yet - record each candidate's real
                    -- armorType so we can tell whether they actually differ.
                    local ok5, actualArmorType = pcall(GetItemLinkArmorType, link)
                    candidateArmorType = ok5 and actualArmorType or nil
                end
                if isMatch then
                    table.insert(matches, { itemId = itemId, weaponType = candidateWeaponType, armorType = candidateArmorType })
                end
            end
        end
    end

    if #matches == 0 then
        BuildTracker.Debug("No live, current itemId found for setId=%s equipType=%s armorType=%s weaponType=%s",
            tostring(setId), tostring(equipType), tostring(armorType), tostring(weaponType))
        return nil
    end

    -- Genuinely different weapon types available (e.g. this set has both a
    -- sword and a two-handed staff option) is a real choice the user should
    -- make, not something to silently guess - previously this silently
    -- picked whichever candidate had the highest itemId regardless of
    -- weapon type, which is why sets with several weapon options always
    -- seemed to resolve to the same one instead of ever asking. Return nil
    -- so the caller's existing disambiguation UI takes over, same as it
    -- already does for the "no matches at requested sub-type" case above.
    if isWeaponAttempt then
        local firstWeaponType = matches[1].weaponType
        for _, m in ipairs(matches) do
            if m.weaponType ~= firstWeaponType then
                return nil
            end
        end
    end

    -- Same idea for armor weight: genuinely different weights available
    -- (e.g. this set offers Light, Medium, and Heavy versions of this piece)
    -- is a real choice for the user, not something to silently guess.
    if isArmorAttempt then
        local firstArmorType = matches[1].armorType
        for _, m in ipairs(matches) do
            if m.armorType ~= firstArmorType then
                return nil
            end
        end
    end

    -- Multiple valid, current itemIds can legitimately tie on equipType+weight
    -- (or, here, equipType+weaponType) - confirmed in practice for setId 29's
    -- chest slot (89638 and 108766 are both real, non-dead items with
    -- identical equipType/armorType - true aliases, not a meaningful choice).
    -- Item ids increase roughly chronologically as ZOS adds content, and the
    -- higher one matched the item actually sitting in a real Set Collection
    -- in testing, so prefer the highest id as the more likely "current" one.
    -- This is a heuristic, not a guarantee - if a set ever resolves to the
    -- wrong tie, /bt setitem remains available as a manual override.
    table.sort(matches, function(a, b) return a.itemId > b.itemId end)
    if #matches > 1 then
        local otherIds = {}
        for i = 2, #matches do table.insert(otherIds, matches[i].itemId) end
        BuildTracker.Debug("Multiple current itemIds tied for setId=%s equipType=%s - using highest (%s), others were: %s",
            tostring(setId), tostring(equipType), tostring(matches[1].itemId), table.concat(otherIds, ", "))
    end
    return matches[1].itemId
end

-- Builds a usable itemLink string for a resolved itemId, e.g. for tooltips
-- or for feeding back into GetItemLinkSetInfo to confirm numEquipped/maxEquipped.
-- NOTE: the real LibSets function is lowercase "buildItemLink", not
-- "BuildItemLink" - confirmed by enumerating the live LibSets table rather
-- than trusting secondhand documentation, after the capitalized version
-- turned out not to exist.
--
-- Always requests quality subtype 370 (Legendary/gold) - the itemLink is
-- always level 50/CP160 regardless of this value (per LibSets.lua's own
-- comment on buildItemLink), only the cosmetic quality/color changes, so
-- this is purely a display choice, not something that could affect
-- equipType/armorType/weaponType/set-info lookups elsewhere that also
-- build a link through this same function. Matches LibSets' own SearchUI,
-- which hardcodes this same 370 for its own item displays.
function Sets.BuildItemLink(itemId)
    local lib = GetLib()
    if not lib or not itemId then return nil end
    local ok, link = pcall(lib.buildItemLink, itemId, 370)
    if ok then return link end
    return nil
end

-- Bakes an optional trait and/or enchantId into a synthetic link, so the
-- paperdoll's tooltip preview can show the user's chosen customizations
-- (BuildTracker_SlotOptionsUI.lua) as the item's own native lines instead
-- of separate explicit "Desired..." lines. Field positions (1-indexed after
-- itemId, 21 fields total, confirmed via precise field-splitting - see
-- PROJECT_STATUS.md gotcha #12) come from the real UESP `Online:Item_Link`
-- reference the user supplied:
--   field 4 = EnchantId, field 5 = EnchantSubType, field 6 = EnchantLevel,
--   field 7 = "Writ1/TransmuteTrait" (confirmed by UESP itself: "For
--   transmuted items, the TransmuteTrait field contains the new trait
--   value for the item" - i.e. this is the real game mechanism for
--   overriding a displayed trait post-Transmutation, independent of
--   itemId - gotcha #12's attempt #2, confirmed working in-game).
-- EnchantSubType/EnchantLevel are always maxed out (370/50, matching the
-- item's own quality/level) whenever an enchantId is given - not
-- independently confirmed what these two specifically control, but the
-- caller verifies the actual result via GetItemLinkAppliedEnchantId before
-- trusting it, so a wrong value here just fails that verification safely
-- rather than showing incorrect data.
--
-- Either traitType or enchantId (or both) may be nil - the corresponding
-- field(s) just stay at their normal BuildItemLink default in that case.
-- Caller is expected to verify each requested customization independently
-- (GetItemLinkTraitType / GetItemLinkAppliedEnchantId) before trusting this
-- link for display, and fall back to plain BuildItemLink + an explicit
-- line for whichever one didn't verify.
local ITEM_LINK_CUSTOM_PATTERN = "|H1:item:%d:%d:50:%d:%d:%d:%d:0:0:0:0:0:0:0:0:%d:0:0:0:%d:0|h|h"
function Sets.BuildCustomizedItemLink(itemId, traitType, enchantId)
    if not itemId then return nil end
    if not traitType and not enchantId then return Sets.BuildItemLink(itemId) end
    local style = ITEMSTYLE_NONE or 0
    local enchantSubType = enchantId and 370 or 0
    local enchantLevel = enchantId and 50 or 0
    local ok, link = pcall(string.format, ITEM_LINK_CUSTOM_PATTERN,
        itemId, 370, enchantId or 0, enchantSubType, enchantLevel, traitType or 0, style, 10000)
    if ok then return link end
    return Sets.BuildItemLink(itemId)
end

-- Raw, unshaped wrapper around GetSetItemIds - used by the /bt debugsetitems
-- command to inspect the actual return shape before we build real filtering
-- logic on top of it. Deliberately does NOT try to interpret the result.
function Sets.GetSetItemIdsRaw(setId)
    local lib = GetLib()
    if not lib then return false, nil end
    return pcall(lib.GetSetItemIds, setId)
end

-- Returns the base-game Collections "setId:itemSetCollectionSlotId" key for
-- an itemLink. Confirmed to exist on the live LibSets table. This is the
-- bridge between LibSets' own bonus-calculation setId and the base game's
-- Collections itemSetId - the two turned out NOT to be the same number
-- space for at least one real set tested, so this must be used to find the
-- correct Collections itemSetId rather than assuming it equals LibSets' setId.
function Sets.GetCollectionsSlotKey(itemLink)
    local lib = GetLib()
    if not lib or not itemLink then return nil end
    local ok, key = pcall(lib.GetItemSetCollectionsSlotKey, itemLink)
    if ok then return key end
    return nil
end

-- Human-readable "where to find it" tooltip text for a set, one line per
-- drop mechanic (a set can have more than one, e.g. a monster set that's
-- both a random-dungeon-reward AND an Imperial City vault reward). Sourced
-- entirely from LibSets' own bundled data (GetDropMechanic/GetZoneName) -
-- LibSets ships this same dataset LibSetSourceInfo curates, so there's no
-- need for a second addon dependency just to show it.
--
-- Deliberately does NOT call LibSets.BuildSetDataText (the function backing
-- LibSets' own tooltip hook) - that function's output is gated behind
-- LibSets' own SearchUI tooltip SavedVariables (useCustomTooltip,
-- setTypePlaceholder, etc, see LibSets_Tooltips.lua), so it can silently
-- return an empty string on an install where the user never touched those
-- settings. Building the line from the raw data functions here means this
-- always works regardless of the other addon's own settings.
--
-- Returns nil for craftable sets (see the isCrafted branch below - use
-- Sets.GetCraftLocationText instead) or if LibSets has no source data at
-- all for this setId (a handful of Special/PvP sets aren't zone-bound).
function Sets.GetSetSourceText(setId)
    local lib = GetLib()
    if not lib or not setId then return nil end
    local lang = lib.clientLang

    local okCrafted, isCrafted = pcall(lib.IsCraftedSet, setId)
    if okCrafted and isCrafted then return nil end

    local okMech, mechanicIds, mechanicNames, _, locationNames, zoneIds =
        pcall(lib.GetDropMechanic, setId, true, lang)
    if not okMech or not mechanicIds or #mechanicIds == 0 then return nil end

    local lines = {}
    for i in ipairs(mechanicIds) do
        local mechanicName = mechanicNames and mechanicNames[i] and mechanicNames[i][lang]
        local locationName = locationNames and locationNames[i] and locationNames[i][lang]
        local zoneId = zoneIds and zoneIds[i]
        local zoneName
        if zoneId then
            local okZone, result = pcall(lib.GetZoneName, zoneId, lang)
            if okZone and result and result ~= "" then zoneName = result end
        end

        if mechanicName and mechanicName ~= "" then
            local line = mechanicName
            if zoneName then line = line .. ": " .. zoneName end
            if locationName and locationName ~= "" then line = line .. " (" .. locationName .. ")" end
            table.insert(lines, line)
        end
    end
    if #lines == 0 then return nil end
    return table.concat(lines, "\n")
end

-- "Craftable" line for a craftable set - just the flat word by default, or
-- "Craftable (<Zone>)" when LibSets' set info includes the zone the
-- crafting station sits in (GetSetInfo's zoneIds field covers this for
-- crafted sets too, e.g. Grave-Stake Collector -> Murkmire). Returns nil
-- for non-craftable sets (use Sets.GetSetSourceText for those).
function Sets.GetCraftLocationText(setId)
    local lib = GetLib()
    if not lib or not setId then return nil end

    local okCrafted, isCrafted = pcall(lib.IsCraftedSet, setId)
    if not okCrafted or not isCrafted then return nil end

    local okInfo, info = pcall(lib.GetSetInfo, setId, true)
    local zoneId = okInfo and info and info.zoneIds and info.zoneIds[1]
    if zoneId then
        local okZone, zoneName = pcall(lib.GetZoneName, zoneId, lib.clientLang)
        if okZone and zoneName and zoneName ~= "" then
            return "Craftable (" .. zoneName .. ")"
        end
    end
    return "Craftable"
end

-- Transmute Crystal cost to reconstruct an already-collected piece of this
-- set from the account-wide Set Item Collection at a Transmutation station -
-- the base-game "get a copy of a piece you've bound before without
-- re-farming it" feature, distinct from the (also crystal-based) trait
-- change most players think of first. Requires the real itemLink, not just
-- the setId - IsItemLinkSetCollectionPiece(itemLink) is exactly the gate
-- LibSets' own reconstruction-cost code (LibSets_Tooltips.lua) checks
-- before calling GetItemReconstructionCurrencyOptionCost, so mirroring it
-- here avoids showing a cost for items the game wouldn't actually let you
-- reconstruct (crafted sets, some PvP/currency-bound sets, etc).
function Sets.GetSetReconstructionCost(setId, itemLink)
    if not setId or not itemLink then return nil end
    if not IsItemLinkSetCollectionPiece or not GetItemReconstructionCurrencyOptionCost or not CURT_CHAOTIC_CREATIA then
        return nil
    end
    local okCheck, isReconstructable = pcall(IsItemLinkSetCollectionPiece, itemLink)
    if not okCheck or not isReconstructable then return nil end
    local okCost, cost = pcall(GetItemReconstructionCurrencyOptionCost, setId, CURT_CHAOTIC_CREATIA)
    if okCost and cost and cost > 0 then return cost end
    return nil
end

-- Raw, unshaped wrapper around GetSetItemIds - used by the /bt debugsetitems
-- command to inspect the actual return shape before we build real filtering
-- logic on top of it. Deliberately does NOT try to interpret the result.
function Sets.GetSetItemIdsRaw(setId)
    local lib = GetLib()
    if not lib then return false, nil end
    return pcall(lib.GetSetItemIds, setId)
end

-- Every known setId, sorted ascending - used to populate the paperdoll's
-- set-picker list. LibSets.GetAllSetIds() returns a table KEYED BY setId
-- (values are just a membership marker), the same shape gotcha already
-- confirmed for GetSetItemIds - iterate with pairs(), not by value.
function Sets.GetAllSetIdsSorted()
    local lib = GetLib()
    if not lib then return {} end

    local ok, setIdSet = pcall(lib.GetAllSetIds)
    if not ok or type(setIdSet) ~= "table" then
        BuildTracker.Debug("GetAllSetIds() failed or returned non-table (ok=%s, type=%s)", tostring(ok), type(setIdSet))
        return {}
    end

    local ids = {}
    for setId in pairs(setIdSet) do
        table.insert(ids, setId)
    end
    table.sort(ids)
    return ids
end

-- Every EQUIP_TYPE_* present anywhere in a set's items (a table keyed by
-- equipType, values all true) - used by the set picker to filter out sets
-- that have no item for the slot being clicked (e.g. a monster set with no
-- neck piece shouldn't show up when picking for the Neck slot). Memoized
-- per setId - it never changes during a session, and re-scanning every item
-- of every one of 600+ sets on every picker open would be wasteful.
local setEquipTypeCache = {}
function Sets.GetSetEquipTypes(setId)
    if setEquipTypeCache[setId] then
        return setEquipTypeCache[setId]
    end

    local equipTypes = {}
    local lib = GetLib()
    if lib then
        local ok, itemIdSet = pcall(lib.GetSetItemIds, setId)
        if ok and type(itemIdSet) == "table" then
            for itemId in pairs(itemIdSet) do
                local link = Sets.BuildItemLink(itemId)
                if link then
                    local ok2, equipType = pcall(GetItemLinkEquipType, link)
                    -- equipType 0 = EQUIP_TYPE_INVALID, a dead/legacy itemId - skip it.
                    if ok2 and equipType and equipType ~= 0 then
                        equipTypes[equipType] = true
                    end
                end
            end
        end
    end

    setEquipTypeCache[setId] = equipTypes
    return equipTypes
end

-- Every distinct WEAPONTYPE_* a set offers, across both one- and two-handed
-- items (a table keyed by weaponType, values all true) - used to filter the
-- set-picker's weapon-type disambiguation dropdown down to only the options
-- this specific set actually has, instead of showing the full generic list
-- (most of which would just fail to resolve if picked). Not memoized like
-- GetSetEquipTypes - only called on the rare "this set is ambiguous" path,
-- not on every picker open.
function Sets.GetSetWeaponTypes(setId)
    local lib = GetLib()
    local weaponTypes = {}
    if lib then
        local ok, itemIdSet = pcall(lib.GetSetItemIds, setId)
        if ok and type(itemIdSet) == "table" then
            for itemId in pairs(itemIdSet) do
                local link = Sets.BuildItemLink(itemId)
                if link then
                    local ok2, equipType = pcall(GetItemLinkEquipType, link)
                    if ok2 and (equipType == EQUIP_TYPE_ONE_HAND or equipType == EQUIP_TYPE_TWO_HAND) then
                        local ok3, weaponType = pcall(GetItemLinkWeaponType, link)
                        if ok3 and weaponType then
                            weaponTypes[weaponType] = true
                        end
                    end
                end
            end
        end
    end
    return weaponTypes
end

-- Does this set have an item usable in the given equip slot? Used to filter
-- the set picker per-slot. Main Hand/Backup Main accept EITHER
-- EQUIP_TYPE_ONE_HAND or EQUIP_TYPE_TWO_HAND - resolution
-- (Sets.GetItemIdForSlot) handles both, so a two-handed-only set (e.g.
-- Maelstrom Arena weapon sets, which are staves/bows/greatswords) correctly
-- shows up instead of being hidden. Off Hand/Backup Off can never hold a
-- two-handed weapon, so those only accept EQUIP_TYPE_ONE_HAND - a set that
-- only has a two-handed piece has nothing valid to offer that slot.
function Sets.SetSupportsSlot(setId, slotId)
    local equipTypes = Sets.GetSetEquipTypes(setId)
    if BuildTracker.IsWeaponSlot(slotId) then
        if BuildTracker.CAN_BE_TWO_HANDED_SLOTS[slotId] then
            return equipTypes[EQUIP_TYPE_ONE_HAND] == true or equipTypes[EQUIP_TYPE_TWO_HAND] == true
        end
        return equipTypes[EQUIP_TYPE_ONE_HAND] == true
    end
    local equipType = BuildTracker.SLOT_TO_EQUIP_TYPE[slotId]
    if not equipType then return false end
    return equipTypes[equipType] == true
end

-- Lightweight existence check, used before we let a user assign a set to a
-- build so we fail fast with a clear message instead of a nil itemId later.
function Sets.SetExists(setId)
    local lib = GetLib()
    if not lib then return false end
    local ok, name = pcall(lib.GetSetName, setId)
    return ok and name ~= nil and name ~= ""
end
