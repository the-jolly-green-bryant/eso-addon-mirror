-- Transmute Set Crafter — Enchanting / glyph automation
--
-- Integrates with LibLazyCrafting to:
--   • Detect when the player visits the enchanting station
--   • For each queued entry with status "needs_enchant", request a glyph craft
--     (or apply an already-owned glyph if one matches)
--   • When LLC reports the glyph as crafted, locate the reconstructed item and
--     apply the glyph via EnchantItem()
--   • On any inventory change, scan queue entries and remove ones whose item
--     now carries the requested enchantment

local TSC = TransmuteSetCrafter
local ADDON_NAME = TSC.name

local LLC = nil  -- LibLazyCrafting addon handle, populated on EVENT_ADD_ON_LOADED

-- Map of "our craft reference string" → queue entry table. Used to look up
-- the right entry when LLC fires LLC_CRAFT_SUCCESS, because queue indexes
-- shift as entries are removed during a multi-craft session.
local pendingCrafts = {}

-- ── Enchantment-name → LibLazyCrafting enchantId ─────────
-- Integers are LLC's internal glyph IDs from LibLazyCrafting/Enchanting.lua
-- (the glyphInfo table). Column 1 of glyphInfo = negative parity (e.g. weapon
-- damage-dealing glyphs); column 2 = positive parity. LLC derives parity from
-- the enchantId itself, so we only need the integer.

local ENCHANT_ID = {
    -- Armor (positive parity, max-stat glyphs)
    ["Health"]              = 17,
    ["Magicka"]             = 19,
    ["Stamina"]             = 25,
    ["Prismatic Defense"]   = 146,

    -- Weapon
    ["Absorb Health"]       = 29,
    ["Absorb Magicka"]      = 83,
    ["Absorb Stamina"]      = 82,
    ["Crushing"]            = 7,
    ["Decrease Health"]     = 84,
    ["Flame"]               = 10,
    ["Foulness (Disease)"]  = 3,
    ["Frost"]               = 15,
    ["Hardening"]           = 16,
    ["Poison"]              = 24,
    ["Prismatic Onslaught"] = 147,
    ["Shock"]               = 6,
    ["Weakening"]           = 28,

    -- Jewelry
    ["Bashing"]                = 88,
    ["Decrease Physical Harm"] = 94,
    ["Decrease Spell Harm"]    = 95,
    ["Disease Resist"]         = 9,
    ["Flame Resist"]           = 11,
    ["Frost Resist"]           = 14,
    ["Health Recovery"]        = 18,
    ["Increase Weapon Damage"] = 92,  -- Glyph of Increase Weapon Damage (jewelry)
    ["Magicka Recovery"]       = 20,
    ["Poison Resist"]          = 23,
    ["Potion Boost"]           = 90,
    ["Potion Speed"]           = 91,
    ["Prismatic Recovery"]     = 179,
    ["Reduce Feat Cost"]       = 87,
    ["Reduce Magicka Cost"]    = 86,  -- alias for Reduce Spell Cost
    ["Reduce Spell Cost"]      = 86,
    ["Shielding"]              = 89,
    ["Shock Resist"]           = 31,
    ["Spell Damage"]           = 93,  -- Increase Magical Harm
    ["Stamina Recovery"]       = 26,

    -- Weapon (continued — paired with Weakening on the Okoma rune)
    ["Weapon Damage"]          = 4,   -- Glyph of Weapon Damage (Berserker proc)
}

-- ── Reverse lookup: read an equipped item's enchant ──────
-- Parse fields 4 (glyph itemId) and 5 (subtype) from an item link, then
-- reverse-map through LLC's published tables to recover (TSC enchant name,
-- functional quality). Returns nil for either if the item has no glyph or
-- the glyph isn't in LLC's known set.

local llcEnchantIdToName  -- [llcEnchantId] = TSC enchantment name
local subtypeToQuality    -- [subtype]      = ITEM_FUNCTIONAL_QUALITY_*

function TSC.GetEnchantInfoFromItemLink(link)
    if not link or link == "" then return nil, nil end
    if not LibLazyCrafting or not LibLazyCrafting.glyphEssenceIdInfo
       or not LibLazyCrafting.enchantCPQualityInfo then
        return nil, nil
    end

    -- Item link fields are colon-separated:
    --   |H<style>:item:<itemId>:<subtype>:<level>:<enchantItemId>:<enchSubtype>:...
    local glyphItemId, enchSubtype =
        link:match("^|H%d:item:%d+:%d+:%d+:(%d+):(%d+):")
    glyphItemId  = tonumber(glyphItemId)
    enchSubtype  = tonumber(enchSubtype)
    if not glyphItemId or glyphItemId == 0 then return nil, nil end

    -- Lazy-build reverse maps from LLC tables.
    if not llcEnchantIdToName then
        llcEnchantIdToName = {}
        for name, llcId in pairs(ENCHANT_ID) do
            -- ENCHANT_ID has aliases (e.g., Reduce Magicka Cost → 86 ==
            -- Reduce Spell Cost). Keep the first-seen name per id.
            if not llcEnchantIdToName[llcId] then
                llcEnchantIdToName[llcId] = name
            end
        end
    end
    if not subtypeToQuality then
        subtypeToQuality = {}
        local cp160 = LibLazyCrafting.enchantCPQualityInfo[160]
        if cp160 then
            for q, st in ipairs(cp160) do subtypeToQuality[st] = q end
        end
    end

    local llcEnchantId
    for _, row in ipairs(LibLazyCrafting.glyphEssenceIdInfo) do
        if     row[3] == glyphItemId then llcEnchantId = row[1]; break
        elseif row[4] == glyphItemId then llcEnchantId = row[2]; break
        end
    end
    if not llcEnchantId then return nil, nil end

    return llcEnchantIdToName[llcEnchantId], subtypeToQuality[enchSubtype]
end

-- ── Item-link enchantment fields (for tooltip preview) ────
-- Returns (glyphItemId, subtype, lvl) suitable for fields 4/5/6 of an item
-- link, given a TSC enchantment-name + quality. Uses LLC's published tables.
-- Hardcoded to CP160 max because the addon doesn't otherwise track item levels.
function TSC.GetItemLinkEnchantedFields(enchantmentName, quality)
    local llcEnchantId = ENCHANT_ID[enchantmentName]
    if not llcEnchantId then return nil end
    if not LibLazyCrafting or not LibLazyCrafting.glyphEssenceIdInfo
       or not LibLazyCrafting.enchantCPQualityInfo then
        return nil
    end

    local glyphItemId
    for _, row in ipairs(LibLazyCrafting.glyphEssenceIdInfo) do
        if     row[1] == llcEnchantId then glyphItemId = row[3]; break
        elseif row[2] == llcEnchantId then glyphItemId = row[4]; break
        end
    end
    if not glyphItemId then return nil end

    local qualityNum = quality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
    local cp160      = LibLazyCrafting.enchantCPQualityInfo[160]
    local subtype    = cp160 and cp160[qualityNum]
    if not subtype then return nil end

    return glyphItemId, subtype, 50
end

-- ── Inventory helpers ─────────────────────────────────────

-- Find the reconstructed item in the backpack that belongs to `entry`.
-- `entry.pieceId` is an item-set-collection piece ID, NOT the item ID — those
-- are different identifiers. Look up pieceData and derive the real itemId from
-- the piece's item link before comparing.
local function FindReconstructedItem(entry)
    if not entry or not entry.pieceId then return nil end
    local pieceData = TSC.GetPieceData(entry.pieceId)
    if not pieceData then return nil end
    local expectedItemId = GetItemLinkItemId(pieceData:GetItemLink())
    if not expectedItemId then return nil end

    for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local link = GetItemLink(BAG_BACKPACK, slot)
        if link and link ~= "" then
            if GetItemLinkItemId(link) == expectedItemId then
                local trait   = GetItemLinkTraitInfo(link)
                local quality = GetItemLinkFunctionalQuality(link)
                if trait == entry.traitType and quality == entry.quality then
                    return BAG_BACKPACK, slot
                end
            end
        end
    end
    return nil
end

-- Match a glyph in inventory by LLC enchantId + quality.
local function FindGlyphForEntry(entry)
    local enchantId = ENCHANT_ID[entry.enchantment]
    if not enchantId then return nil end
    for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local link = GetItemLink(BAG_BACKPACK, slot)
        if link and link ~= "" then
            local itemType = GetItemLinkItemType(link)
            if itemType == ITEMTYPE_GLYPH_WEAPON or
               itemType == ITEMTYPE_GLYPH_ARMOR  or
               itemType == ITEMTYPE_GLYPH_JEWELRY then
                local glyphQuality = GetItemLinkFunctionalQuality(link)
                if glyphQuality == entry.enchantQuality then
                    -- Compare via the glyph's resulting itemId encoded in the link.
                    -- LLC's glyphInfo columns 3 and 4 are the resulting itemIds for
                    -- the (-) and (+) variants, so we look up by itemId.
                    local glyphItemId = GetItemLinkItemId(link)
                    -- LLC exposes the table directly — use it to map itemId back to enchantId.
                    if LibLazyCrafting and LibLazyCrafting.glyphEssenceIdInfo then
                        for _, row in ipairs(LibLazyCrafting.glyphEssenceIdInfo) do
                            if (row[3] == glyphItemId and row[1] == enchantId) or
                               (row[4] == glyphItemId and row[2] == enchantId) then
                                return BAG_BACKPACK, slot
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- ── Public: aggregate glyph rune counts for all queued enchantments ──────
-- Returns a table mapping rune itemId → count needed. Empty if LLC is missing.

function TSC.GetGlyphRuneCounts()
    local counts = {}
    if not LibLazyCrafting or not LibLazyCrafting.EnchantAttributesToGlyphIds then
        return counts
    end
    for _, entry in ipairs(TSC.queue) do
        if entry.enchantment and entry.enchantment ~= "" then
            local enchantId = ENCHANT_ID[entry.enchantment]
            if enchantId then
                local quality = entry.enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
                local potency, essence, aspect =
                    LibLazyCrafting.EnchantAttributesToGlyphIds(true, 160, enchantId, quality)
                if potency then counts[potency] = (counts[potency] or 0) + 1 end
                if essence then counts[essence] = (counts[essence] or 0) + 1 end
                if aspect  then counts[aspect]  = (counts[aspect]  or 0) + 1 end
            end
        end
    end
    return counts
end

-- ── Crafting + applying ───────────────────────────────────

-- Public: true if at least one queue entry has been reconstructed but still
-- needs its glyph applied (status == "needs_enchant" with a real enchantment).
-- Used to gate the enchanting-station auto-open so the window only pops up
-- when there's actually glyph work pending.
function TSC.HasPendingGlyphs()
    if not TSC.queue then return false end
    for _, entry in ipairs(TSC.queue) do
        if entry.status == "needs_enchant"
           and entry.enchantment and entry.enchantment ~= "" then
            return true
        end
    end
    return false
end

-- Public: at the enchanting station, queue glyph crafts for needs_enchant entries
-- (or apply an existing matching glyph if one is already in the bag).
function TSC.CraftMissingGlyphs()
    if not LLC then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_NO_LLC))
        return
    end
    if GetCraftingInteractionType() ~= CRAFTING_TYPE_ENCHANTING then return end

    local requested, applied, unmapped = 0, 0, 0
    for i, entry in ipairs(TSC.queue) do
        if entry.status == "needs_enchant" and entry.enchantment and entry.enchantment ~= "" then
            local enchantId = ENCHANT_ID[entry.enchantment]
            if not enchantId then
                unmapped = unmapped + 1
                TSC.NotifyF(TSC.NOTIFY_WARN, SI_TSC_MSG_NO_LLC_MAPPING, entry.enchantment)
            else
                local existingBag, existingSlot = FindGlyphForEntry(entry)
                if existingBag then
                    local targetBag, targetSlot = FindReconstructedItem(entry)
                    if targetBag then
                        local capturedTargetBag, capturedTargetSlot = targetBag, targetSlot
                        local capturedGlyphBag,  capturedGlyphSlot  = existingBag, existingSlot
                        local capturedName  = entry.pieceName
                        local capturedEntry = entry
                        zo_callLater(function()
                            EnchantItem(capturedTargetBag, capturedTargetSlot, capturedGlyphBag, capturedGlyphSlot)
                            TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_APPLIED_EXISTING, capturedName)
                            zo_callLater(function() RemoveEntryFromQueue(capturedEntry) end, 400)
                        end, 300)
                        applied = applied + 1
                    else
                        TSC.NotifyF(TSC.NOTIFY_WARN, SI_TSC_MSG_GLYPH_HAVE_NO_ITEM, entry.pieceName)
                    end
                else
                    -- LLC:CraftEnchantingGlyphByAttributes(isCP, level, enchantId, quality, autocraft, reference)
                    -- Reference is a unique string we use to look up the entry on callback —
                    -- NOT a queue index (the queue shifts as entries get removed).
                    local quality = entry.enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
                    local ref     = string.format("TSC_%d_%d", GetGameTimeMilliseconds(), i)
                    pendingCrafts[ref] = entry
                    LLC:CraftEnchantingGlyphByAttributes(true, 160, enchantId, quality, true, ref)
                    requested = requested + 1
                end
            end
        end
    end

    if requested > 0 or applied > 0 then
        TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_GLYPH_SUMMARY, requested, applied)
    end
end

-- Remove a queue entry by reference equality (the index may have shifted since
-- we issued the craft request, so we look the entry up freshly by reference).
local function RemoveEntryFromQueue(entry)
    for i, e in ipairs(TSC.queue) do
        if e == entry then
            table.remove(TSC.queue, i)
            TSC.savedVars.queue = TSC.queue
            TSC.RefreshQueueList()
            TSC.UpdateCostDisplay()
            TSC.UpdateTransmuteButton()
            return
        end
    end
end

-- LLC callback. result = { bag, slot, link, uniqueId, quantity, reference }
local function OnLLCCallback(event, station, result)
    if station ~= CRAFTING_TYPE_ENCHANTING then return end

    -- Surface LLC failure events so the user knows why a queued glyph wasn't
    -- crafted. Without these branches the request just disappears silently
    -- and the queue entry stays in "needs_enchant" with no explanation.
    if event == LLC_INSUFFICIENT_MATERIALS or event == LLC_ENCHANTMENT_FAILED then
        local ref   = result and result.reference
        local entry = ref and pendingCrafts[ref]
        local name  = entry and entry.pieceName or "queued glyph"
        if ref then pendingCrafts[ref] = nil end
        if event == LLC_INSUFFICIENT_MATERIALS then
            TSC.NotifyF(TSC.NOTIFY_WARN, SI_TSC_MSG_GLYPH_INSUFFICIENT, name)
        else
            TSC.NotifyF(TSC.NOTIFY_ERROR, SI_TSC_MSG_GLYPH_FAILED, name)
        end
        return
    end

    if event ~= LLC_CRAFT_SUCCESS then return end
    if not result or not result.reference then return end

    -- Look up the entry by our unique reference — NOT by queue index, since the
    -- queue mutates as previous crafts complete and their entries get removed.
    local entry = pendingCrafts[result.reference]
    if not entry then
        return  -- not one of our crafts (or callback already handled)
    end
    pendingCrafts[result.reference] = nil

    if entry.status ~= "needs_enchant" then
        -- Dev diagnostic; not surfaced to the user under normal flow.
        TSC.Notify(TSC.NOTIFY_WARN, zo_strformat(
            "LLC callback: entry '<<1>>' has status '<<2>>', skipping",
            entry.pieceName or "?", entry.status or "?"))
        return
    end

    local glyphBag, glyphSlot = result.bag, result.slot
    if not glyphBag or not glyphSlot then
        TSC.Notify(TSC.NOTIFY_WARN,
                   "LLC callback: result has no bag/slot for the crafted glyph")
        return
    end

    local targetBag, targetSlot = FindReconstructedItem(entry)
    if not targetBag then
        TSC.NotifyF(TSC.NOTIFY_WARN, SI_TSC_MSG_GLYPH_NO_ITEM, entry.pieceName)
        return
    end

    -- LLC enforces a 260ms cooldown between EnchantItem calls to avoid being
    -- kicked. After the apply lands, remove the queue entry.
    local capturedEntry = entry
    zo_callLater(function()
        EnchantItem(targetBag, targetSlot, glyphBag, glyphSlot)
        TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_APPLIED_GLYPH, capturedEntry.pieceName)
        zo_callLater(function() RemoveEntryFromQueue(capturedEntry) end, 400)
    end, 300)
end

-- ── Inventory watcher (intentionally not registered) ─────
--
-- An earlier version of this file listened for EVENT_INVENTORY_SINGLE_SLOT_UPDATE
-- and removed queue entries whose item had "any" enchant. That misfired in two
-- ways:
--   1. Reconstructed items often come with a default enchant from the set
--      design (e.g. Healthy on armor), which the loose check counts as "done"
--      and removes the entry before the user's chosen glyph is applied.
--   2. Removing entries asynchronously while ProcessNextQueueEntry was iterating
--      shifted queue indexes, so subsequent RECONSTRUCT_RESPONSE events wrote
--      the wrong entry's status (or no entry's at all).
--
-- Queue cleanup now happens through two deterministic paths:
--   • OnLLCCallback → EnchantItem → zo_callLater RemoveEntryFromQueue
--   • CraftMissingGlyphs apply-existing-glyph path → same
--   • Manual X click on a queue row (user-driven)
--
-- If the user manually applies a glyph outside the addon flow, they need to
-- click X on the row themselves — that's a documented limitation.

-- ── Wire everything up after the addon loads ─────────────

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Enchanting", EVENT_ADD_ON_LOADED)

    if LibLazyCrafting then
        LLC = LibLazyCrafting:AddRequestingAddon(ADDON_NAME, true, OnLLCCallback)
    end

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_EnchantStation",
        EVENT_CRAFTING_STATION_INTERACT,
        function(_, craftingType)
            if craftingType == CRAFTING_TYPE_ENCHANTING then
                if TSC.savedVars and TSC.savedVars.openAtEnchantStation
                   and TSC.HasPendingGlyphs() then
                    TSC.OpenWindow()
                end
                TSC.CraftMissingGlyphs()
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_EnchantStationEnd",
        EVENT_END_CRAFTING_STATION_INTERACT,
        function(_, craftingType)
            if craftingType == CRAFTING_TYPE_ENCHANTING
               and TSC.savedVars and TSC.savedVars.closeOnEnchantExit then
                TSC.CloseWindow()
            end
        end
    )
    -- Note: no EVENT_INVENTORY_SINGLE_SLOT_UPDATE registration. See the comment
    -- above where OnInventoryUpdate used to live for why.
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Enchanting", EVENT_ADD_ON_LOADED, OnAddonLoaded)
