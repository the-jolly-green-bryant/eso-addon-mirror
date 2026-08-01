-- Transmute Set Crafter — Queue management and execution
--
-- A queue entry is:
--   { pieceId, pieceName, setName, pieceIcon,
--     traitType, traitName, quality, qualityName,
--     crystalCost, currencyType }

local TSC = TransmuteSetCrafter
local ADDON_NAME = TSC.name

-- ── Queue state ────────────────────────────────────────────

TSC.queue = TSC.queue or {}
local processingQueue = false
local processingIndex = nil

-- ── Helpers: derive display strings from pieceData ────────

local function GetPieceType(pieceData)
    local link       = pieceData:GetItemLink()
    local weaponType = GetItemLinkWeaponType(link)
    if weaponType ~= WEAPONTYPE_NONE then
        -- ZOS's SI_WEAPONTYPE strings don't distinguish 1H from 2H: both
        -- maces map to "Mace", both swords to "Sword", both axes to "Axe".
        -- Disambiguate by checking equip slot and tagging 2H weapons.
        local name = GetString("SI_WEAPONTYPE", weaponType)
        if GetItemLinkEquipType(link) == EQUIP_TYPE_TWO_HAND then
            name = name .. GetString(SI_TSC_TWO_HANDED_SUFFIX)
        end
        return name
    end
    local equipType = GetItemLinkEquipType(link)
    if not equipType or equipType == EQUIP_TYPE_INVALID then
        return ""
    end
    local typeName = GetString("SI_EQUIPTYPE", equipType)
    local letter   = TSC.ArmorLetter[GetItemLinkArmorType(link)]
    return letter and (typeName .. " (" .. letter .. ")") or typeName
end

-- ── Hydration ─────────────────────────────────────────────
-- A queue entry has six PRIMARY fields stored as-is (pieceId, traitType,
-- quality, enchantment, enchantQuality, status). Everything else
-- (pieceName, pieceType, armorType, setName, pieceIcon, traitName,
-- qualityName, crystalCost, currencyType) is DERIVED from those + live API
-- data, and recomputed on every load via HydrateQueueEntry. Returns false
-- if the source pieceData can't be resolved (caller should drop the entry).

function TSC.HydrateQueueEntry(entry)
    local pieceData = TSC.GetPieceData(entry.pieceId)
    if not pieceData then return false end

    local setData      = pieceData:GetItemSetCollectionData()
    local currencyType = TSC.GetReconCurrencyType()

    entry.pieceName    = pieceData:GetFormattedName()
    entry.pieceType    = GetPieceType(pieceData)
    entry.pieceIcon    = pieceData:GetIcon()
    entry.armorType    = GetItemLinkArmorType(pieceData:GetItemLink())
    entry.setName      = setData and setData:GetFormattedName() or ""
    entry.traitName    = GetString("SI_ITEMTRAITTYPE", entry.traitType or ITEM_TRAIT_TYPE_NONE)
    entry.qualityName  = GetString("SI_ITEMQUALITY",   entry.quality   or ITEM_FUNCTIONAL_QUALITY_NORMAL)
    entry.crystalCost  = setData and setData:GetReconstructionCurrencyOptionCost(currencyType) or 0
    entry.currencyType = currencyType
    -- Clear any obsolete fields from earlier schemas.
    entry.pieceWeight  = nil
    return true
end

-- ── Public: Add a piece to the queue ──────────────────────

function TSC.AddToQueue(pieceId, traitType, quality, enchantment, enchantQuality)
    local entry = {
        pieceId        = pieceId,
        traitType      = traitType,
        quality        = quality,
        enchantment    = enchantment or "",
        enchantQuality = enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY,
        status         = "pending",  -- "pending" or "needs_enchant"
    }
    if not TSC.HydrateQueueEntry(entry) then return end

    table.insert(TSC.queue, entry)
    TSC.savedVars.queue = TSC.queue

    TSC.RefreshQueueList()
    TSC.UpdateCostDisplay()
end

-- ── Public: Update existing queue entry in place ──────────

function TSC.UpdateQueueEntry(index, traitType, quality, enchantment, enchantQuality)
    local entry = TSC.queue[index]
    if not entry then return end

    entry.traitType      = traitType
    entry.quality        = quality
    entry.enchantment    = enchantment or ""
    entry.enchantQuality = enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
    TSC.HydrateQueueEntry(entry)

    TSC.savedVars.queue = TSC.queue
    TSC.RefreshQueueList()
    TSC.UpdateCostDisplay()
end

-- ── Public: Remove by queue index ──────────────────────────

function TSC.RemoveFromQueue(index)
    if TSC.queue[index] then
        table.remove(TSC.queue, index)
        TSC.savedVars.queue = TSC.queue
        TSC.RefreshQueueList()
        TSC.UpdateCostDisplay()
    end
end

-- ── Public: Remove via row control ─────────────────────────

function TSC.RemoveQueueRow(rowControl)
    if rowControl and rowControl.data then
        TSC.RemoveFromQueue(rowControl.data.queueIndex)
    end
end

-- ── Public: Clear entire queue ─────────────────────────────

function TSC.ClearQueue()
    TSC.queue = {}
    TSC.savedVars.queue = TSC.queue
    processingQueue = false
    processingIndex = nil
    TSC.RefreshQueueList()
    TSC.UpdateCostDisplay()
end

-- ── Public: Total crystal cost ─────────────────────────────

function TSC.GetTotalCrystalCost()
    local total = 0
    for _, entry in ipairs(TSC.queue) do
        if entry.status ~= "needs_enchant" then
            total = total + (entry.crystalCost or 0)
        end
    end
    return total
end

function TSC.GetPendingCount()
    local n = 0
    for _, entry in ipairs(TSC.queue) do
        if entry.status ~= "needs_enchant" then
            n = n + 1
        end
    end
    return n
end

-- ── Public: Execute queue ──────────────────────────────────

function TSC.ExecuteQueue()
    if not ZO_RETRAIT_STATION_MANAGER or
       not ZO_RETRAIT_STATION_MANAGER:IsReconstructFragmentShowing() then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_NOT_AT_STATION))
        return
    end

    if TSC.GetPendingCount() == 0 then
        TSC.Notify(TSC.NOTIFY_INFO, GetString(SI_TSC_EMPTY_QUEUE))
        return
    end

    local cost         = TSC.GetTotalCrystalCost()
    local currencyType = TSC.GetReconCurrencyType()
    local location     = GetCurrencyPlayerStoredLocation(currencyType)
    local available    = GetCurrencyAmount(currencyType, location)
    if cost > available then
        TSC.NotifyF(TSC.NOTIFY_WARN, SI_TSC_INSUFFICIENT_CRYSTALS, cost, available)
        return
    end

    processingQueue = true
    processingIndex = 1
    TSC.ProcessNextQueueEntry()
end

-- ── Internal: Process one entry ────────────────────────────

function TSC.ProcessNextQueueEntry()
    if not processingQueue then return end

    -- Walk forward, skipping already-reconstructed (needs_enchant) entries,
    -- pruning any whose source piece has gone missing, and stop at the first
    -- pending entry to request a reconstruction.
    while processingIndex <= #TSC.queue do
        local entry = TSC.queue[processingIndex]
        if entry and entry.status ~= "needs_enchant" then
            local pieceData = TSC.GetPieceData(entry.pieceId)
            if not pieceData then
                TSC.NotifyF(TSC.NOTIFY_WARN, SI_TSC_ITEM_NOT_FOUND, entry.pieceName)
                table.remove(TSC.queue, processingIndex)
                TSC.savedVars.queue = TSC.queue
                TSC.RefreshQueueList()
                TSC.UpdateCostDisplay()
                -- index now points at what was the next entry; loop continues
            else
                RequestItemReconstruction(entry.pieceId, entry.traitType, entry.quality, entry.currencyType)
                return  -- wait for OnReconstructResponse
            end
        else
            processingIndex = processingIndex + 1
        end
    end

    -- No more pending entries
    processingQueue = false
    processingIndex = nil
    TSC.Notify(TSC.NOTIFY_INFO, GetString(SI_TSC_MSG_ALL_DONE))
    TSC.UpdateTransmuteButton()
end

-- ── Event: Reconstruct response ────────────────────────────

local function OnReconstructResponse(_, result)
    if not processingQueue then return end

    if result == RECONSTRUCT_RESPONSE_SUCCESS then
        local entry = TSC.queue[processingIndex]
        if entry and entry.enchantment and entry.enchantment ~= "" then
            -- Reconstruction done; entry stays in queue until glyph is applied
            entry.status = "needs_enchant"
            processingIndex = processingIndex + 1
        else
            -- No enchant planned, entry is fully complete
            table.remove(TSC.queue, processingIndex)
            -- processingIndex now points at the next entry due to the shift
        end
        TSC.savedVars.queue = TSC.queue
        TSC.RefreshQueueList()
        TSC.UpdateCostDisplay()
        TSC.UpdateTransmuteButton()
        zo_callLater(function() TSC.ProcessNextQueueEntry() end, 200)
    else
        local errStr = GetString("SI_RECONSTRUCTRESPONSE", result)
        TSC.NotifyF(TSC.NOTIFY_ERROR, SI_TSC_TRANSMUTE_FAILED, errStr)
        processingQueue = false
        processingIndex = nil
    end
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME .. "_Queue",
    EVENT_RECONSTRUCT_RESPONSE,
    OnReconstructResponse
)

-- ── Restore queue from saved vars ──────────────────────────

function TSC.RestoreQueue()
    local saved = TSC.savedVars.queue or {}
    local cleaned = {}
    for _, raw in ipairs(saved) do
        -- Rebuild the entry from primary keys only, then hydrate. This drops
        -- any stale derived fields (or fields from older schemas) without
        -- needing a version bump or migration table.
        local entry = {
            pieceId        = raw.pieceId,
            traitType      = raw.traitType,
            quality        = raw.quality,
            enchantment    = raw.enchantment or "",
            enchantQuality = raw.enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY,
            status         = raw.status or "pending",
        }
        if TSC.HydrateQueueEntry(entry) then
            table.insert(cleaned, entry)
        end
    end
    TSC.queue = cleaned
    TSC.savedVars.queue = TSC.queue
end
