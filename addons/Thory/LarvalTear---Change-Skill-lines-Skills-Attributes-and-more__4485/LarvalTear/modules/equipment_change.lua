local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_EQUIPMENT_CHANGE = Addon.Modules.EquipmentChange
local EQUIPMENT_SLOT_IDS = Addon.Common.Domains.EquipmentSlotIds

local WEAPON_SLOT_IDS = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local SEARCH_BAG_IDS = {
    BAG_WORN,
    BAG_BACKPACK,
}

local MYTHIC_PRECLEAR_POLL_MS = 250
local MYTHIC_PRECLEAR_MAX_ATTEMPTS = 20
local WEAPON_MOVE_POLL_MS = 100
local WEAPON_MOVE_MAX_ATTEMPTS = 30
local WEAPON_STAGE_POLL_MS = 100
local WEAPON_STAGE_MAX_ATTEMPTS = 30
local EQUIPMENT_FINAL_VERIFY_POLL_MS = 150
local EQUIPMENT_FINAL_VERIFY_MAX_ATTEMPTS = 20
local EQUIPMENT_FINAL_VERIFY_MYTHIC_MAX_ATTEMPTS = 40

local function CountMapEntries(entries)
    local count = 0
    for _ in pairs(entries or {}) do
        count = count + 1
    end
    return count
end

local function IsWeaponSlot(equipSlotId)
    for _, weaponSlotId in ipairs(WEAPON_SLOT_IDS) do
        if weaponSlotId == equipSlotId then
            return true
        end
    end

    return false
end

local function TraceEquipmentDebug(...)
    if type(Log.LogDebugSummary) ~= "function" then
        return
    end

    Log.LogDebugSummary(...)
end

local function IterateBagSlotsSafe(bagId)
    if bagId == BAG_WORN then
        local index = 0
        return function()
            local equipSlotId = EQUIPMENT_SLOT_IDS[index + 1]
            index = index + 1
            return equipSlotId
        end
    end

    if type(ZO_IterateBagSlots) == "function" then
        return ZO_IterateBagSlots(bagId)
    end

    local bagSize = type(GetBagSize) == "function" and GetBagSize(bagId) or -1
    local index = -1
    return function()
        index = index + 1
        if index <= bagSize then
            return index
        end
        return nil
    end
end

local function BuildItemState(bagId, slotIndex)
    if type(GetItemLink) ~= "function" then
        return nil
    end

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    local itemName = type(GetItemLinkName) == "function" and GetItemLinkName(itemLink) or nil
    if type(itemLink) ~= "string" or itemLink == ""
        or (type(GetItemLinkName) == "function" and (type(itemName) ~= "string" or itemName == "")) then
        return nil
    end

    local itemId = type(GetItemId) == "function" and GetItemId(bagId, slotIndex) or nil
    if (type(itemId) ~= "number" or itemId <= 0) and type(GetItemLinkItemId) == "function" then
        itemId = GetItemLinkItemId(itemLink)
    end

    local traitType = type(GetItemLinkTraitInfo) == "function" and GetItemLinkTraitInfo(itemLink) or nil
    local quality = type(GetItemLinkDisplayQuality) == "function" and GetItemLinkDisplayQuality(itemLink) or nil
    local itemInfoDisplayQuality = type(GetItemInfo) == "function" and select(9, GetItemInfo(bagId, slotIndex)) or nil
    local uniqueId = type(GetItemUniqueId) == "function" and GetItemUniqueId(bagId, slotIndex) or nil
    if uniqueId ~= nil and type(Id64ToString) == "function" then
        uniqueId = Id64ToString(uniqueId)
    end

    return {
        bagId = bagId,
        slotIndex = slotIndex,
        uniqueId = type(uniqueId) == "string" and uniqueId ~= "" and uniqueId or nil,
        itemLink = itemLink,
        itemId = type(itemId) == "number" and itemId > 0 and itemId or nil,
        traitType = type(traitType) == "number" and traitType > 0 and traitType or nil,
        quality = type(quality) == "number" and quality or nil,
        displayQuality = type(quality) == "number" and quality or nil,
        itemInfoDisplayQuality = type(itemInfoDisplayQuality) == "number" and itemInfoDisplayQuality or nil,
    }
end

local function NormalizeTargetEntry(slotEntry)
    if type(slotEntry) ~= "table" then
        return nil
    end

    -- Newer saved builds persist uniqueId. When it exists, treat it as the
    -- primary identity so duplicate rings/weapons do not collapse onto the
    -- same item instance.
    local itemLink = type(slotEntry.itemLink) == "string" and slotEntry.itemLink ~= "" and slotEntry.itemLink or nil
    if itemLink == nil then
        return nil
    end

    local itemId = type(GetItemLinkItemId) == "function" and GetItemLinkItemId(itemLink) or nil
    local displayQuality = type(GetItemLinkDisplayQuality) == "function" and GetItemLinkDisplayQuality(itemLink) or nil
    return {
        uniqueId = type(slotEntry.uniqueId) == "string" and slotEntry.uniqueId ~= "" and slotEntry.uniqueId or nil,
        itemLink = itemLink,
        itemId = type(itemId) == "number" and itemId > 0 and itemId or nil,
        traitType = type(slotEntry.traitType) == "number" and slotEntry.traitType > 0 and slotEntry.traitType or nil,
        quality = type(slotEntry.quality) == "number" and slotEntry.quality or nil,
        displayQuality = type(displayQuality) == "number" and displayQuality
            or (type(slotEntry.quality) == "number" and slotEntry.quality or nil),
    }
end

local function IsTargetMatch(targetEntry, itemState)
    if type(targetEntry) ~= "table" or type(itemState) ~= "table" then
        return false, "missing_entry"
    end

    if targetEntry.uniqueId ~= nil then
        if itemState.uniqueId == targetEntry.uniqueId then
            return true, "unique_id"
        end

        return false, "unique_id_mismatch"
    end

    if targetEntry.itemLink ~= nil and itemState.itemLink == targetEntry.itemLink then
        return true, "item_link"
    end

    if targetEntry.itemId ~= nil
        and itemState.itemId ~= nil
        and targetEntry.itemId == itemState.itemId then
        local traitMatches = targetEntry.traitType == nil or targetEntry.traitType == itemState.traitType
        local qualityMatches = targetEntry.quality == nil or targetEntry.quality == itemState.quality
        if traitMatches and qualityMatches then
            if targetEntry.traitType ~= nil or targetEntry.quality ~= nil then
                return true, "item_id_with_saved_modifiers"
            end

            return true, "item_id_only"
        end
    end

    return false, "not_matched"
end

local function BuildTargetMatchKey(targetEntry, matchedBy)
    if type(targetEntry) ~= "table" then
        return "target_entry_invalid"
    end

    if matchedBy == "unique_id" and targetEntry.uniqueId ~= nil then
        return "uniqueId=" .. tostring(targetEntry.uniqueId)
    end

    if matchedBy == "item_link" and targetEntry.itemLink ~= nil then
        return "itemLink=" .. tostring(targetEntry.itemLink)
    end

    if targetEntry.uniqueId ~= nil then
        return "uniqueId=" .. tostring(targetEntry.uniqueId)
    end

    if targetEntry.itemId ~= nil then
        return "itemId=" .. tostring(targetEntry.itemId)
    end

    return "itemLink=" .. tostring(targetEntry.itemLink)
end

local function BuildItemIdentity(itemState)
    if type(itemState) ~= "table" then
        return "empty"
    end

    if type(itemState.uniqueId) == "string" and itemState.uniqueId ~= "" then
        return "uniqueId=" .. tostring(itemState.uniqueId)
    end

    if type(itemState.itemId) == "number" and itemState.itemId > 0 then
        return "itemId=" .. tostring(itemState.itemId)
            .. ":trait=" .. tostring(itemState.traitType)
            .. ":quality=" .. tostring(itemState.quality)
    end

    return "itemLink=" .. tostring(itemState.itemLink)
end

local function BuildReservationSlotKey(itemState)
    if type(itemState) ~= "table" then
        return nil
    end

    return tostring(itemState.bagId) .. ":" .. tostring(itemState.slotIndex)
end

local function IsReservedCandidate(reservedCandidates, itemState)
    if type(reservedCandidates) ~= "table" or type(itemState) ~= "table" then
        return false
    end

    if type(itemState.uniqueId) == "string" and itemState.uniqueId ~= "" then
        return reservedCandidates.uniqueIds[itemState.uniqueId] == true
    end

    local slotKey = BuildReservationSlotKey(itemState)
    return slotKey ~= nil and reservedCandidates.bagSlots[slotKey] == true or false
end

local function ReserveCandidate(reservedCandidates, itemState)
    if type(reservedCandidates) ~= "table" or type(itemState) ~= "table" then
        return
    end

    if type(itemState.uniqueId) == "string" and itemState.uniqueId ~= "" then
        reservedCandidates.uniqueIds[itemState.uniqueId] = true
        return
    end

    local slotKey = BuildReservationSlotKey(itemState)
    if slotKey ~= nil then
        reservedCandidates.bagSlots[slotKey] = true
    end
end

local function FindMatchingItem(targetEntry, equipSlotId, reservedCandidates)
    for _, bagId in ipairs(SEARCH_BAG_IDS) do
        for slotIndex in IterateBagSlotsSafe(bagId) do
            local itemState = BuildItemState(bagId, slotIndex)
            if type(itemState) == "table" then
                local matches, matchedBy = IsTargetMatch(targetEntry, itemState)
                if matches
                    and not (bagId == BAG_WORN and slotIndex == equipSlotId)
                    and not IsReservedCandidate(reservedCandidates, itemState) then
                    itemState.matchedBy = matchedBy
                    return itemState
                end
            end
        end
    end

    return nil
end

local function FindWeaponWornMove(targetEntry, targetSlot, excludedSourceSlots)
    if type(targetEntry) ~= "table" or not IsWeaponSlot(targetSlot) then
        return nil
    end

    for _, sourceSlot in ipairs(WEAPON_SLOT_IDS) do
        if sourceSlot ~= targetSlot and not (type(excludedSourceSlots) == "table" and excludedSourceSlots[sourceSlot] == true) then
            local itemState = BuildItemState(BAG_WORN, sourceSlot)
            if type(itemState) == "table" then
                local matches, matchedBy = IsTargetMatch(targetEntry, itemState)
                if matches then
                    itemState.matchedBy = matchedBy
                    return itemState
                end
            end
        end
    end

    return nil
end

local function ExecuteRequestMoveItem(sourceBag, sourceSlot, destBag, destSlot)
    if type(CallSecureProtected) ~= "function" then
        return false, "request_move_secure_unavailable"
    end

    local ok, err = pcall(CallSecureProtected, "RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, 1)
    if not ok then
        return false, err or "request_move_item_failed"
    end

    return true
end

local function ExecuteEquip(candidate, equipSlotId)
    if type(candidate) ~= "table" or type(equipSlotId) ~= "number" then
        return false, "equip_request_invalid"
    end

    if candidate.bagId == BAG_WORN and candidate.slotIndex ~= equipSlotId then
        return false, "worn_to_worn_direct_equip_blocked"
    end

    if type(EquipItem) == "function" then
        local ok, err = pcall(EquipItem, candidate.bagId, candidate.slotIndex, equipSlotId)
        if not ok then
            return false, err or "equip_item_failed"
        end
        return true
    end

    if type(RequestEquipItem) == "function" then
        local ok, err = pcall(RequestEquipItem, candidate.bagId, candidate.slotIndex, BAG_WORN, equipSlotId)
        if not ok then
            return false, err or "request_equip_item_failed"
        end
        return true
    end

    return false, "equip_api_unavailable"
end

local function IsMythicByDisplayQuality(displayQuality)
    if type(displayQuality) ~= "number" then
        return false
    end

    if type(ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE) == "number" then
        return displayQuality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE
    end

    return displayQuality == 6
end

local function IsMythicItemState(itemState)
    if type(itemState) ~= "table" then
        return false
    end

    if IsMythicByDisplayQuality(itemState.displayQuality or itemState.quality)
        or IsMythicByDisplayQuality(itemState.itemInfoDisplayQuality) then
        return true
    end

    return false
end

local function IsMythicTargetEntry(targetEntry)
    if type(targetEntry) ~= "table" then
        return false
    end

    if IsMythicByDisplayQuality(targetEntry.displayQuality or targetEntry.quality) then
        return true
    end

    return false
end

local function FindTargetMythic(targetEquipment)
    local firstMythic = nil
    local count = 0

    for _, equipSlotId in ipairs(EQUIPMENT_SLOT_IDS) do
        local targetEntry = NormalizeTargetEntry(targetEquipment[equipSlotId])
        if IsMythicTargetEntry(targetEntry) then
            count = count + 1
            if firstMythic == nil then
                firstMythic = {
                    equipSlotId = equipSlotId,
                    targetEntry = targetEntry,
                }
            end
        end
    end

    return firstMythic, count
end

local function FindCurrentMythic()
    for _, equipSlotId in ipairs(EQUIPMENT_SLOT_IDS) do
        local itemState = BuildItemState(BAG_WORN, equipSlotId)
        if IsMythicItemState(itemState) then
            return {
                equipSlotId = equipSlotId,
                itemState = itemState,
            }
        end
    end

    return nil
end

local function FindFirstBackpackEmptySlot()
    if type(FindFirstEmptySlotInBag) == "function" then
        local slotIndex = FindFirstEmptySlotInBag(BAG_BACKPACK)
        if type(slotIndex) == "number" then
            return slotIndex
        end
    end

    if type(GetBagSize) ~= "function" or type(GetItemId) ~= "function" then
        return nil
    end

    local bagSize = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, bagSize - 1 do
        if GetItemId(BAG_BACKPACK, slotIndex) == 0 then
            return slotIndex
        end
    end

    return nil
end

local function FindMatchingBackpackItem(targetEntry)
    if type(targetEntry) ~= "table" then
        return nil
    end

    for slotIndex in IterateBagSlotsSafe(BAG_BACKPACK) do
        local itemState = BuildItemState(BAG_BACKPACK, slotIndex)
        if type(itemState) == "table" then
            local matches, matchedBy = IsTargetMatch(targetEntry, itemState)
            if matches then
                itemState.matchedBy = matchedBy
                return itemState
            end
        end
    end

    return nil
end

local function BuildMythicPreclearPlan(targetEquipment)
    local targetMythic, targetMythicCount = FindTargetMythic(targetEquipment)
    if targetMythic == nil then
        return nil, "target_mythic_absent", {
            targetMythicCount = targetMythicCount,
        }
    end

    if targetMythicCount > 1 then
        return false, "target_mythic_multiple", {
            targetMythicCount = targetMythicCount,
        }
    end

    local currentMythic = FindCurrentMythic()
    if currentMythic == nil then
        return nil, "current_mythic_absent", {
            targetMythicCount = targetMythicCount,
            targetMythicSlot = targetMythic.equipSlotId,
        }
    end

    local targetEntry = targetMythic.targetEntry
    local currentItem = currentMythic.itemState
    local currentMatchesTarget = IsTargetMatch(targetEntry, currentItem)
    if currentMatchesTarget then
        return nil, "current_mythic_matches_target", {
            targetMythicCount = targetMythicCount,
            targetMythicSlot = targetMythic.equipSlotId,
            currentMythicSlot = currentMythic.equipSlotId,
        }
    end

    return {
        targetMythicSlot = targetMythic.equipSlotId,
        currentMythicSlot = currentMythic.equipSlotId,
        currentUniqueId = currentItem.uniqueId,
        targetUniqueId = targetEntry.uniqueId,
    }, nil, {
        targetMythicCount = targetMythicCount,
        targetMythicSlot = targetMythic.equipSlotId,
        currentMythicSlot = currentMythic.equipSlotId,
    }
end

local function ExecuteMythicPreclear(plan)
    local destSlot = FindFirstBackpackEmptySlot()
    if type(destSlot) ~= "number" then
        return false, "mythic_preclear_no_backpack_slot"
    end

    if type(CallSecureProtected) ~= "function" then
        return false, "mythic_preclear_move_unavailable"
    end

    local moveOk, moveErr = ExecuteRequestMoveItem(BAG_WORN, plan.currentMythicSlot, BAG_BACKPACK, destSlot)
    if not moveOk then
        return false, moveErr or "mythic_preclear_move_failed"
    end

    plan.destBagId = BAG_BACKPACK
    plan.destSlotIndex = destSlot
    return true
end

local function IsMythicPreclearReady(plan)
    local current = FindCurrentMythic()
    if current == nil then
        return true
    end

    if type(plan) ~= "table" or plan.currentUniqueId == nil then
        return current.equipSlotId ~= plan.currentMythicSlot
    end

    return current.itemState.uniqueId ~= plan.currentUniqueId
end

function LTM_EQUIPMENT_CHANGE:BeginMythicPreclearIfNeeded(targetEquipment, completion)
    if type(targetEquipment) ~= "table" then
        return false, "equipment_config_invalid", nil
    end

    local plan, planErr, planSummary = BuildMythicPreclearPlan(targetEquipment)
    if plan == nil then
        return nil, planErr, planSummary
    end
    if plan == false then
        return false, planErr, planSummary
    end

    if type(completion) ~= "function" then
        return false, "mythic_preclear_completion_required", planSummary
    end
    if type(zo_callLater) ~= "function" then
        return false, "mythic_preclear_async_unavailable", planSummary
    end

    local moveOk, moveErr = ExecuteMythicPreclear(plan)
    if not moveOk then
        return false, moveErr, planSummary
    end

    TraceEquipmentDebug(
        "Equipment mythic preclear requested",
        "currentMythicSlot=" .. tostring(plan.currentMythicSlot),
        "targetMythicSlot=" .. tostring(plan.targetMythicSlot),
        "destSlot=" .. tostring(plan.destSlotIndex)
    )

    local context = {
        attemptIndex = 0,
        finished = false,
        plan = plan,
    }

    local function Finish(success, err)
        if context.finished then
            return
        end

        context.finished = true
        completion(success == true, err)
    end

    local function Poll()
        if context.finished then
            return
        end

        context.attemptIndex = context.attemptIndex + 1
        if IsMythicPreclearReady(context.plan) then
            TraceEquipmentDebug(
                "Equipment mythic preclear ready",
                "attemptIndex=" .. tostring(context.attemptIndex)
            )
            Finish(true, nil)
            return
        end

        if context.attemptIndex >= MYTHIC_PRECLEAR_MAX_ATTEMPTS then
            TraceEquipmentDebug(
                "Equipment mythic preclear timeout",
                "attemptIndex=" .. tostring(context.attemptIndex)
            )
            Finish(false, "mythic_preclear_timeout")
            return
        end

        zo_callLater(Poll, MYTHIC_PRECLEAR_POLL_MS)
    end

    zo_callLater(Poll, MYTHIC_PRECLEAR_POLL_MS)
    return true, "deferred", planSummary
end

local function BuildFinalVerifySummary(targetEquipment)
    local verifySummary = {
        targetSlots = 0,
        matchedSlots = 0,
        mismatchedSlots = 0,
        mythicTargetSlots = 0,
        mythicMismatchedSlots = 0,
        emptyTargetSlots = 0,
        slotResults = {},
    }

    if type(targetEquipment) ~= "table" then
        return verifySummary
    end

    for _, equipSlotId in ipairs(EQUIPMENT_SLOT_IDS) do
        local targetEntry = NormalizeTargetEntry(targetEquipment[equipSlotId])
        local slotResult = {
            equipSlotId = equipSlotId,
        }

        if targetEntry == nil then
            slotResult.status = "empty_target_noop"
            verifySummary.emptyTargetSlots = verifySummary.emptyTargetSlots + 1
        else
            local isMythicTarget = IsMythicTargetEntry(targetEntry)
            if isMythicTarget then
                verifySummary.mythicTargetSlots = verifySummary.mythicTargetSlots + 1
            end
            verifySummary.targetSlots = verifySummary.targetSlots + 1
            local currentItem = BuildItemState(BAG_WORN, equipSlotId)
            local matched, matchedBy = false, nil
            if type(currentItem) == "table" then
                matched, matchedBy = IsTargetMatch(targetEntry, currentItem)
            end

            if matched then
                slotResult.status = "matched"
                slotResult.matchedBy = matchedBy
                verifySummary.matchedSlots = verifySummary.matchedSlots + 1
            else
                slotResult.status = "mismatch"
                slotResult.reason = type(currentItem) == "table" and "target_mismatch" or "slot_empty_or_unreadable"
                slotResult.isMythicTarget = isMythicTarget
                slotResult.expectedIdentity = BuildItemIdentity(targetEntry)
                slotResult.actualIdentity = BuildItemIdentity(currentItem)
                slotResult.matchKey = BuildTargetMatchKey(targetEntry, matchedBy)
                verifySummary.mismatchedSlots = verifySummary.mismatchedSlots + 1
                if isMythicTarget then
                    verifySummary.mythicMismatchedSlots = verifySummary.mythicMismatchedSlots + 1
                end
            end
        end

        verifySummary.slotResults[#verifySummary.slotResults + 1] = slotResult
    end

    return verifySummary
end

local function MergeFinalVerifySummary(summary, verifySummary)
    if type(summary) ~= "table" then
        summary = {}
    end

    summary.finalVerify = verifySummary
    summary.finalMatchedSlots = type(verifySummary) == "table" and verifySummary.matchedSlots or 0
    summary.finalMismatchedSlots = type(verifySummary) == "table" and verifySummary.mismatchedSlots or 0
    summary.finalMythicMismatchedSlots = type(verifySummary) == "table" and verifySummary.mythicMismatchedSlots or 0

    local applySlotResultsById = {}
    for _, slotResult in ipairs(summary.slotResults or {}) do
        if type(slotResult) == "table" and type(slotResult.equipSlotId) == "number" then
            applySlotResultsById[slotResult.equipSlotId] = slotResult
        end
    end

    local prepassSlotResultsById = {}
    local weaponPrepass = type(summary.weaponPrepass) == "table" and summary.weaponPrepass or nil
    for _, slotResult in ipairs(type(weaponPrepass) == "table" and weaponPrepass.slotResults or {}) do
        if type(slotResult) == "table" and type(slotResult.equipSlotId) == "number" then
            prepassSlotResultsById[slotResult.equipSlotId] = slotResult
        end
    end

    for _, slotResult in ipairs(type(verifySummary) == "table" and verifySummary.slotResults or {}) do
        if type(slotResult) == "table" and slotResult.status == "mismatch" then
            local applySlotResult = applySlotResultsById[slotResult.equipSlotId]
            local prepassSlotResult = prepassSlotResultsById[slotResult.equipSlotId]
            slotResult.applyStatus = type(applySlotResult) == "table" and applySlotResult.status or "unknown"
            slotResult.sourceItemFound = type(applySlotResult) == "table"
                and applySlotResult.status ~= "unresolved"
                or false
            slotResult.prepassTarget = IsWeaponSlot(slotResult.equipSlotId)
            slotResult.prepassStatus = type(prepassSlotResult) == "table" and prepassSlotResult.status or "not_target"
        end
    end

    return summary
end

local function AreAllFinalMismatchesMissingItems(summary)
    local finalVerify = type(summary) == "table" and summary.finalVerify or nil
    local weaponPrepass = type(summary) == "table" and summary.weaponPrepass or nil
    if type(finalVerify) ~= "table"
        or (finalVerify.mismatchedSlots or 0) <= 0
        or (finalVerify.mythicMismatchedSlots or 0) > 0
        or (type(summary) == "table" and (summary.failedSlots or 0) > 0)
        or type(weaponPrepass) ~= "table"
        or weaponPrepass.success ~= true then
        return false
    end

    local mismatchCount = 0
    for _, slotResult in ipairs(finalVerify.slotResults or {}) do
        if type(slotResult) == "table" and slotResult.status == "mismatch" then
            mismatchCount = mismatchCount + 1
            if slotResult.applyStatus ~= "unresolved" then
                return false
            end
        end
    end

    return mismatchCount == finalVerify.mismatchedSlots
end

local function LogFinalVerifyMismatches(verifySummary, attemptIndex)
    if type(verifySummary) ~= "table" then
        return
    end

    for _, slotResult in ipairs(verifySummary.slotResults or {}) do
        if type(slotResult) == "table" and slotResult.status == "mismatch" then
            TraceEquipmentDebug(
                "Equipment final verify mismatch",
                "slotId=" .. tostring(slotResult.equipSlotId),
                "expected=" .. tostring(slotResult.expectedIdentity),
                "actual=" .. tostring(slotResult.actualIdentity or "empty"),
                "matchKey=" .. tostring(slotResult.matchKey),
                "sourceItemFound=" .. tostring(slotResult.sourceItemFound == true),
                "attemptIndex=" .. tostring(attemptIndex),
                "prepassTarget=" .. tostring(slotResult.prepassTarget == true),
                "prepassResult=" .. tostring(slotResult.prepassStatus)
            )
        end
    end
end

local function ShouldFinishFinalVerifyAfterFirstPoll(summary, verifyMetadata)
    local weaponPrepass = type(summary) == "table" and summary.weaponPrepass or nil
    if type(verifyMetadata) ~= "table"
        or verifyMetadata.allFinalMismatchesMissingItems ~= true
        or type(summary) ~= "table"
        or summary.requestedSlots ~= 0
        or summary.equippedSlots ~= 0
        or type(weaponPrepass) ~= "table"
        or weaponPrepass.detectedMoves ~= 0
        or verifyMetadata.mythicPreclearPerformed == true then
        return false
    end

    return true
end

local function BeginFinalVerifyWait(targetEquipment, summary, verifyMetadata, completion)
    if type(completion) ~= "function" then
        return false, "equipment_final_verify_completion_required"
    end
    if type(zo_callLater) ~= "function" then
        return false, "equipment_final_verify_async_unavailable"
    end

    verifyMetadata = type(verifyMetadata) == "table" and verifyMetadata or {}
    verifyMetadata.allFinalMismatchesMissingItems = false
    verifyMetadata.isMissingItemPartial = false
    local context = {
        attemptIndex = 0,
        finished = false,
    }

    local function Finish(success, err, verifySummary)
        if context.finished then
            return
        end

        context.finished = true
        verifyMetadata.isMissingItemPartial = success ~= true
            and err == "equipment_final_verify_timeout"
            and verifyMetadata.allFinalMismatchesMissingItems == true
        TraceEquipmentDebug(
            "Equipment final verify summary",
            "success=" .. tostring(success == true),
            "targetSlots=" .. tostring(type(verifySummary) == "table" and verifySummary.targetSlots or 0),
            "matchedSlots=" .. tostring(type(verifySummary) == "table" and verifySummary.matchedSlots or 0),
            "mismatchedSlots=" .. tostring(type(verifySummary) == "table" and verifySummary.mismatchedSlots or 0),
            "mythicMismatchedSlots=" .. tostring(type(verifySummary) == "table" and verifySummary.mythicMismatchedSlots or 0),
            "attemptIndex=" .. tostring(context.attemptIndex),
            "error=" .. tostring(err)
        )
        if success ~= true then
            LogFinalVerifyMismatches(verifySummary, context.attemptIndex)
        end
        completion(success == true, err, summary)
    end

    local function Poll()
        if context.finished then
            return
        end

        context.attemptIndex = context.attemptIndex + 1
        local verifySummary = BuildFinalVerifySummary(targetEquipment)
        MergeFinalVerifySummary(summary, verifySummary)
        verifyMetadata.allFinalMismatchesMissingItems = AreAllFinalMismatchesMissingItems(summary)
        if verifySummary.mismatchedSlots == 0 then
            Finish(true, nil, verifySummary)
            return
        end

        if context.attemptIndex == 1
            and ShouldFinishFinalVerifyAfterFirstPoll(summary, verifyMetadata) then
            Finish(false, "equipment_final_verify_timeout", verifySummary)
            return
        end

        local maxAttempts = verifySummary.mythicMismatchedSlots > 0
            and EQUIPMENT_FINAL_VERIFY_MYTHIC_MAX_ATTEMPTS
            or EQUIPMENT_FINAL_VERIFY_MAX_ATTEMPTS
        if context.attemptIndex >= maxAttempts then
            local timeoutReason = verifySummary.mythicMismatchedSlots > 0
                and "mythic_target_not_equipped"
                or "equipment_final_verify_timeout"
            Finish(false, timeoutReason, verifySummary)
            return
        end

        zo_callLater(Poll, EQUIPMENT_FINAL_VERIFY_POLL_MS)
    end

    zo_callLater(Poll, EQUIPMENT_FINAL_VERIFY_POLL_MS)
    return true, "deferred"
end

local function BuildWeaponPrepassSummary(targetEquipment)
    local summary = {
        targetSlots = 0,
        detectedMoves = 0,
        movedSlots = 0,
        stagedSlots = 0,
        stageTimeoutSlots = 0,
        stageFailedSlots = 0,
        timeoutSlots = 0,
        failedSlots = 0,
        successfulSlots = {},
        slotResults = {},
    }

    if type(targetEquipment) ~= "table" then
        return summary
    end

    for _, targetSlot in ipairs(WEAPON_SLOT_IDS) do
        local targetEntry = NormalizeTargetEntry(targetEquipment[targetSlot])
        if targetEntry ~= nil then
            summary.targetSlots = summary.targetSlots + 1
        end
    end

    return summary
end

local function BeginWeaponPrepass(targetEquipment, completion)
    if type(completion) ~= "function" then
        return false, "equipment_weapon_prepass_completion_required", nil
    end
    if type(zo_callLater) ~= "function" then
        return false, "equipment_weapon_prepass_async_unavailable", nil
    end

    local summary = BuildWeaponPrepassSummary(targetEquipment)
    TraceEquipmentDebug(
        "Equipment weapon prepass start",
        "targetSlots=" .. tostring(summary.targetSlots)
    )

    local context = {
        index = 0,
        finished = false,
        move = nil,
    }

    local function Finish(success, err)
        if context.finished then
            return
        end

        context.finished = true
        summary.success = success == true
        TraceEquipmentDebug(
            "Equipment weapon prepass summary",
            "success=" .. tostring(success == true),
            "targetSlots=" .. tostring(summary.targetSlots),
            "detectedMoves=" .. tostring(summary.detectedMoves),
            "stagedSlots=" .. tostring(summary.stagedSlots),
            "movedSlots=" .. tostring(summary.movedSlots),
            "stageTimeoutSlots=" .. tostring(summary.stageTimeoutSlots),
            "stageFailedSlots=" .. tostring(summary.stageFailedSlots),
            "timeoutSlots=" .. tostring(summary.timeoutSlots),
            "failedSlots=" .. tostring(summary.failedSlots),
            "error=" .. tostring(err)
        )
        completion(success == true, err, summary)
    end

    local MoveNext
    local WaitForMove

    local function WaitForStage()
        local move = context.move
        if type(move) ~= "table" then
            MoveNext()
            return
        end

        move.stageAttemptIndex = (move.stageAttemptIndex or 0) + 1
        local stagedItem = BuildItemState(BAG_BACKPACK, move.stageDestSlot)
        local matched, matchedBy = false, nil
        if type(stagedItem) == "table" then
            matched, matchedBy = IsTargetMatch(move.targetEntry, stagedItem)
        end
        if not matched then
            stagedItem = FindMatchingBackpackItem(move.targetEntry)
            if type(stagedItem) == "table" then
                matched = true
                matchedBy = stagedItem.matchedBy
            end
        end

        if matched then
            summary.stagedSlots = summary.stagedSlots + 1
            move.slotResult.stageStatus = "staged"
            move.slotResult.stageAttemptIndex = move.stageAttemptIndex
            move.slotResult.stagedBagId = BAG_BACKPACK
            move.slotResult.stagedSlotIndex = stagedItem.slotIndex
            move.slotResult.stageMatchedBy = matchedBy
            TraceEquipmentDebug(
                "Equipment weapon stage to backpack success",
                "sourceSlot=" .. tostring(move.sourceSlot),
                "targetSlot=" .. tostring(move.targetSlot),
                "backpackSlot=" .. tostring(stagedItem.slotIndex),
                "attemptIndex=" .. tostring(move.stageAttemptIndex),
                "matchedBy=" .. tostring(matchedBy)
            )
            move.stagedItem = stagedItem
            TraceEquipmentDebug(
                "Equipment weapon equip from staged backpack start",
                "backpackSlot=" .. tostring(stagedItem.slotIndex),
                "targetSlot=" .. tostring(move.targetSlot),
                "itemLink=" .. tostring(move.targetEntry.itemLink),
                "matchKey=" .. tostring(move.matchKey)
            )
            local equipOk, equipErr = ExecuteEquip(stagedItem, move.targetSlot)
            if not equipOk then
                summary.failedSlots = summary.failedSlots + 1
                move.slotResult.status = "failed"
                move.slotResult.reason = tostring(equipErr or "equipment_weapon_stage_equip_failed")
                if summary.firstFatalReason == nil then
                    summary.firstFatalReason = "equipment_weapon_stage_equip_failed"
                end
                context.move = nil
                MoveNext()
                return
            end

            move.equipAttemptIndex = 0
            zo_callLater(WaitForMove, WEAPON_MOVE_POLL_MS)
            return
        end

        if move.stageAttemptIndex >= WEAPON_STAGE_MAX_ATTEMPTS then
            summary.stageTimeoutSlots = summary.stageTimeoutSlots + 1
            move.slotResult.status = "stage_timeout"
            move.slotResult.reason = "equipment_weapon_stage_timeout"
            move.slotResult.stageAttemptIndex = move.stageAttemptIndex
            if summary.firstFatalReason == nil then
                summary.firstFatalReason = "equipment_weapon_stage_timeout"
            end
            TraceEquipmentDebug(
                "Equipment weapon stage to backpack timeout",
                "sourceSlot=" .. tostring(move.sourceSlot),
                "targetSlot=" .. tostring(move.targetSlot),
                "backpackSlot=" .. tostring(move.stageDestSlot),
                "attemptIndex=" .. tostring(move.stageAttemptIndex),
                "itemLink=" .. tostring(move.targetEntry.itemLink),
                "matchKey=" .. tostring(move.matchKey)
            )
            context.move = nil
            MoveNext()
            return
        end

        zo_callLater(WaitForStage, WEAPON_STAGE_POLL_MS)
    end

    WaitForMove = function()
        local move = context.move
        if type(move) ~= "table" then
            MoveNext()
            return
        end

        move.equipAttemptIndex = (move.equipAttemptIndex or 0) + 1
        local currentItem = BuildItemState(BAG_WORN, move.targetSlot)
        local matched, matchedBy = false, nil
        if type(currentItem) == "table" then
            matched, matchedBy = IsTargetMatch(move.targetEntry, currentItem)
        end

        if matched then
            summary.movedSlots = summary.movedSlots + 1
            summary.successfulSlots[move.targetSlot] = true
            move.slotResult.status = "moved"
            move.slotResult.matchedBy = matchedBy
            move.slotResult.attemptIndex = move.equipAttemptIndex
            TraceEquipmentDebug(
                "Equipment weapon move wait success",
                "sourceSlot=" .. tostring(move.sourceSlot),
                "targetSlot=" .. tostring(move.targetSlot),
                "attemptIndex=" .. tostring(move.equipAttemptIndex),
                "matchedBy=" .. tostring(matchedBy)
            )
            context.move = nil
            MoveNext()
            return
        end

        if move.equipAttemptIndex >= WEAPON_MOVE_MAX_ATTEMPTS then
            summary.timeoutSlots = summary.timeoutSlots + 1
            move.slotResult.status = "timeout"
            move.slotResult.reason = "weapon_move_wait_timeout"
            move.slotResult.attemptIndex = move.equipAttemptIndex
            if summary.firstFatalReason == nil then
                summary.firstFatalReason = "equipment_weapon_prepass_incomplete"
            end
            TraceEquipmentDebug(
                "Equipment weapon move wait timeout",
                "sourceSlot=" .. tostring(move.sourceSlot),
                "targetSlot=" .. tostring(move.targetSlot),
                "attemptIndex=" .. tostring(move.equipAttemptIndex),
                "itemLink=" .. tostring(move.targetEntry.itemLink),
                "matchKey=" .. tostring(move.matchKey)
            )
            context.move = nil
            MoveNext()
            return
        end

        zo_callLater(WaitForMove, WEAPON_MOVE_POLL_MS)
    end

    MoveNext = function()
        if context.finished then
            return
        end

        context.index = context.index + 1
        local targetSlot = WEAPON_SLOT_IDS[context.index]
        if targetSlot == nil then
            local ok = summary.failedSlots == 0
                and summary.timeoutSlots == 0
                and summary.stageTimeoutSlots == 0
                and summary.stageFailedSlots == 0
            if ok then
                Finish(true, nil)
            else
                Finish(false, summary.firstFatalReason or "equipment_weapon_prepass_incomplete")
            end
            return
        end

        local targetEntry = NormalizeTargetEntry(targetEquipment[targetSlot])
        if targetEntry == nil then
            MoveNext()
            return
        end

        local currentItem = BuildItemState(BAG_WORN, targetSlot)
        local currentMatches = type(currentItem) == "table" and IsTargetMatch(targetEntry, currentItem) or false
        if currentMatches then
            summary.slotResults[#summary.slotResults + 1] = {
                equipSlotId = targetSlot,
                status = "already_matched",
            }
            MoveNext()
            return
        end

        local sourceItem = FindWeaponWornMove(targetEntry, targetSlot, summary.successfulSlots)
        if type(sourceItem) ~= "table" then
            summary.slotResults[#summary.slotResults + 1] = {
                equipSlotId = targetSlot,
                status = "no_worn_move",
            }
            MoveNext()
            return
        end

        summary.detectedMoves = summary.detectedMoves + 1
        local matchKey = BuildTargetMatchKey(targetEntry, sourceItem.matchedBy)
        local slotResult = {
            equipSlotId = targetSlot,
            status = "requested",
            sourceBagId = BAG_WORN,
            sourceSlotIndex = sourceItem.slotIndex,
            candidateMatchedBy = sourceItem.matchedBy,
            matchKey = matchKey,
        }
        summary.slotResults[#summary.slotResults + 1] = slotResult

        TraceEquipmentDebug(
            "Equipment weapon worn-to-worn detected",
            "sourceSlot=" .. tostring(sourceItem.slotIndex),
            "targetSlot=" .. tostring(targetSlot),
            "itemLink=" .. tostring(targetEntry.itemLink),
            "matchKey=" .. tostring(matchKey)
        )
        local stageDestSlot = FindFirstBackpackEmptySlot()
        if type(stageDestSlot) ~= "number" then
            summary.stageFailedSlots = summary.stageFailedSlots + 1
            slotResult.status = "stage_failed"
            slotResult.reason = "equipment_weapon_stage_no_backpack_slot"
            if summary.firstFatalReason == nil then
                summary.firstFatalReason = "equipment_weapon_stage_failed"
            end
            MoveNext()
            return
        end

        TraceEquipmentDebug(
            "Equipment weapon stage to backpack start",
            "sourceSlot=" .. tostring(sourceItem.slotIndex),
            "targetSlot=" .. tostring(targetSlot),
            "backpackSlot=" .. tostring(stageDestSlot),
            "itemLink=" .. tostring(targetEntry.itemLink),
            "matchKey=" .. tostring(matchKey)
        )

        local stageOk, stageErr = ExecuteRequestMoveItem(BAG_WORN, sourceItem.slotIndex, BAG_BACKPACK, stageDestSlot)
        if not stageOk then
            summary.stageFailedSlots = summary.stageFailedSlots + 1
            if summary.firstFatalReason == nil then
                summary.firstFatalReason = "equipment_weapon_stage_failed"
            end
            summary.failedSlots = summary.failedSlots + 1
            slotResult.status = "stage_failed"
            slotResult.reason = tostring(stageErr or "equipment_weapon_stage_failed")
            TraceEquipmentDebug(
                "Equipment weapon stage to backpack failed",
                "sourceSlot=" .. tostring(sourceItem.slotIndex),
                "targetSlot=" .. tostring(targetSlot),
                "backpackSlot=" .. tostring(stageDestSlot),
                "error=" .. tostring(stageErr),
                "matchKey=" .. tostring(matchKey)
            )
            context.move = nil
            MoveNext()
            return
        end

        context.move = {
            targetSlot = targetSlot,
            sourceSlot = sourceItem.slotIndex,
            targetEntry = targetEntry,
            slotResult = slotResult,
            matchKey = matchKey,
            stageDestSlot = stageDestSlot,
            stageAttemptIndex = 0,
            equipAttemptIndex = 0,
        }
        zo_callLater(WaitForStage, WEAPON_STAGE_POLL_MS)
    end

    MoveNext()
    return true, "deferred", summary
end

function LTM_EQUIPMENT_CHANGE:NormalizeTargetEntry(slotEntry)
    return NormalizeTargetEntry(slotEntry)
end

function LTM_EQUIPMENT_CHANGE:CreateReservationState()
    return {
        uniqueIds = {},
        bagSlots = {},
    }
end

function LTM_EQUIPMENT_CHANGE:ReserveItemState(reservedCandidates, itemState)
    ReserveCandidate(reservedCandidates, itemState)
end

function LTM_EQUIPMENT_CHANGE:FindMatchingWornItemAtSlot(targetEntry, equipSlotId)
    if type(targetEntry) ~= "table" or type(equipSlotId) ~= "number" then
        return nil
    end

    local itemState = BuildItemState(BAG_WORN, equipSlotId)
    local matches, matchedBy = IsTargetMatch(targetEntry, itemState)
    if matches ~= true then
        return nil
    end

    itemState.matchedBy = matchedBy
    return itemState
end

function LTM_EQUIPMENT_CHANGE:FindMatchingItemInBags(targetEntry, equipSlotId, searchBagIds, reservedCandidates)
    if type(targetEntry) ~= "table" or type(searchBagIds) ~= "table" then
        return nil
    end

    for _, bagId in ipairs(searchBagIds) do
        for slotIndex in IterateBagSlotsSafe(bagId) do
            local itemState = BuildItemState(bagId, slotIndex)
            if type(itemState) == "table" then
                local matches, matchedBy = IsTargetMatch(targetEntry, itemState)
                if matches
                    and not (bagId == BAG_WORN and slotIndex == equipSlotId)
                    and not IsReservedCandidate(reservedCandidates, itemState) then
                    itemState.matchedBy = matchedBy
                    return itemState
                end
            end
        end
    end

    return nil
end

function LTM_EQUIPMENT_CHANGE:ApplyEquipment(targetEquipment, options)
    if type(targetEquipment) ~= "table" then
        return false, "equipment_config_invalid", {
            slotResults = {},
            slotCount = 0,
        }
    end

    options = type(options) == "table" and options or {}
    local skipSlots = type(options.skipSlots) == "table" and options.skipSlots or nil
    local summary = {
        slotCount = CountMapEntries(targetEquipment),
        targetSlots = 0,
        matchedSlots = 0,
        equippedSlots = 0,
        requestedSlots = 0,
        unresolvedSlots = 0,
        failedSlots = 0,
        emptyTargetSlots = 0,
        matchedByUniqueId = 0,
        matchedByItemLink = 0,
        matchedByItemIdWithSavedModifiers = 0,
        matchedByItemIdOnly = 0,
        mythicTargetSlots = 0,
        mythicRequestedSlots = 0,
        prepassSkippedSlots = 0,
        slotResults = {},
    }
    if type(options.weaponPrepass) == "table" then
        summary.weaponPrepass = options.weaponPrepass
    end
    local reservedCandidates = {
        uniqueIds = {},
        bagSlots = {},
    }

    for _, equipSlotId in ipairs(EQUIPMENT_SLOT_IDS) do
        local targetEntry = NormalizeTargetEntry(targetEquipment[equipSlotId])
        local currentItem = BuildItemState(BAG_WORN, equipSlotId)
        local slotResult = {
            equipSlotId = equipSlotId,
        }

        if targetEntry == nil then
            slotResult.status = "empty_target_noop"
            summary.emptyTargetSlots = summary.emptyTargetSlots + 1
        else
            local isMythicTarget = IsMythicTargetEntry(targetEntry)
            slotResult.isMythicTarget = isMythicTarget
            if isMythicTarget then
                summary.mythicTargetSlots = summary.mythicTargetSlots + 1
            end

            summary.targetSlots = summary.targetSlots + 1
            if skipSlots ~= nil and skipSlots[equipSlotId] == true then
                slotResult.status = "prepass_equipped"
                summary.prepassSkippedSlots = summary.prepassSkippedSlots + 1
                summary.equippedSlots = summary.equippedSlots + 1
                if type(currentItem) == "table" then
                    local prepassMatches, prepassMatchedBy = IsTargetMatch(targetEntry, currentItem)
                    if prepassMatches then
                        slotResult.matchedBy = prepassMatchedBy
                        ReserveCandidate(reservedCandidates, currentItem)
                    end
                end
            else
                local currentMatches = type(currentItem) == "table" and IsTargetMatch(targetEntry, currentItem) or false
                if currentMatches then
                    slotResult.status = "matched"
                    summary.matchedSlots = summary.matchedSlots + 1
                    ReserveCandidate(reservedCandidates, currentItem)
                else
                    local candidate = FindMatchingItem(targetEntry, equipSlotId, reservedCandidates)
                    if type(candidate) ~= "table" then
                        slotResult.status = "unresolved"
                        slotResult.reason = "target_item_not_found"
                        summary.unresolvedSlots = summary.unresolvedSlots + 1
                    else
                        ReserveCandidate(reservedCandidates, candidate)
                        slotResult.candidateBagId = candidate.bagId
                        slotResult.candidateSlotIndex = candidate.slotIndex
                        slotResult.candidateMatchedBy = candidate.matchedBy
                        local equipOk, equipErr = ExecuteEquip(candidate, equipSlotId)
                        if not equipOk then
                            slotResult.status = "failed"
                            slotResult.reason = tostring(equipErr)
                            summary.failedSlots = summary.failedSlots + 1
                        else
                            local postEquipItem = BuildItemState(BAG_WORN, equipSlotId)
                            local postMatches, matchedBy = false, nil
                            if type(postEquipItem) == "table" then
                                postMatches, matchedBy = IsTargetMatch(targetEntry, postEquipItem)
                            end

                            if postMatches then
                                slotResult.status = "equipped"
                                slotResult.matchedBy = matchedBy
                                summary.equippedSlots = summary.equippedSlots + 1
                            else
                                slotResult.status = "requested"
                                summary.requestedSlots = summary.requestedSlots + 1
                                if isMythicTarget then
                                    slotResult.reason = "mythic_target_pending_or_rejected"
                                    summary.mythicRequestedSlots = summary.mythicRequestedSlots + 1
                                end
                            end
                        end
                    end
                end
            end
        end

        summary.slotResults[#summary.slotResults + 1] = slotResult
        if slotResult.status ~= "empty_target_noop" then
            local matchedBy = slotResult.matchedBy or slotResult.candidateMatchedBy
            if matchedBy == "unique_id" then
                summary.matchedByUniqueId = summary.matchedByUniqueId + 1
            elseif matchedBy == "item_link" then
                summary.matchedByItemLink = summary.matchedByItemLink + 1
            elseif matchedBy == "item_id_with_saved_modifiers" then
                summary.matchedByItemIdWithSavedModifiers = summary.matchedByItemIdWithSavedModifiers + 1
            elseif matchedBy == "item_id_only" then
                summary.matchedByItemIdOnly = summary.matchedByItemIdOnly + 1
            end
        end
    end

    local ok = summary.unresolvedSlots == 0 and summary.failedSlots == 0
    local reason = nil
    if not ok then
        if summary.failedSlots > 0 then
            reason = "equip_request_failed"
        elseif summary.unresolvedSlots > 0 then
            reason = "equipment_item_not_found"
        else
            reason = "equipment_apply_incomplete"
        end
    end

    TraceEquipmentDebug(
        "Equipment change summary",
        "targetSlots=" .. tostring(summary.targetSlots),
        "matchedSlots=" .. tostring(summary.matchedSlots),
        "equippedSlots=" .. tostring(summary.equippedSlots),
        "requestedSlots=" .. tostring(summary.requestedSlots),
        "unresolvedSlots=" .. tostring(summary.unresolvedSlots),
        "failedSlots=" .. tostring(summary.failedSlots),
        "prepassSkippedSlots=" .. tostring(summary.prepassSkippedSlots),
        "mythicTargetSlots=" .. tostring(summary.mythicTargetSlots),
        "mythicRequestedSlots=" .. tostring(summary.mythicRequestedSlots),
        "matchedByUniqueId=" .. tostring(summary.matchedByUniqueId),
        "matchedByItemLink=" .. tostring(summary.matchedByItemLink),
        "matchedByItemIdWithSavedModifiers=" .. tostring(summary.matchedByItemIdWithSavedModifiers),
        "matchedByItemIdOnly=" .. tostring(summary.matchedByItemIdOnly)
    )

    return ok, reason, summary
end

function LTM_EQUIPMENT_CHANGE:BeginApplyEquipment(targetEquipment, completion, verifyMetadata)
    if type(targetEquipment) ~= "table" then
        if type(completion) == "function" then
            completion(false, "equipment_config_invalid", {
                slotResults = {},
                slotCount = 0,
            })
        end
        return false, "equipment_config_invalid", nil
    end
    if type(completion) ~= "function" then
        return false, "equipment_apply_completion_required", nil
    end
    if type(zo_callLater) ~= "function" then
        return false, "equipment_apply_async_unavailable", nil
    end

    local prepassOk, prepassErr = BeginWeaponPrepass(targetEquipment, function(prepassSuccess, weaponPrepassErr, prepassSummary)
        if prepassSuccess ~= true then
            local fatalErr = type(prepassSummary) == "table" and prepassSummary.firstFatalReason or nil
            completion(false, fatalErr or weaponPrepassErr or "equipment_weapon_prepass_incomplete", prepassSummary)
            return
        end

        local applyOk, applyErr, summary = self:ApplyEquipment(targetEquipment, {
            skipSlots = type(prepassSummary) == "table" and prepassSummary.successfulSlots or nil,
            weaponPrepass = prepassSummary,
        })

        local waitOk, waitErr = BeginFinalVerifyWait(
            targetEquipment,
            summary,
            verifyMetadata,
            function(verified, verifyErr, verifySummary)
                if verified == true then
                    completion(true, nil, verifySummary)
                    return
                end

                local hasApplyFatal = type(summary) == "table" and (summary.failedSlots or 0) > 0
                completion(
                    false,
                    hasApplyFatal and (applyErr or verifyErr)
                        or verifyErr
                        or applyErr
                        or "equipment_final_verify_mismatch",
                    verifySummary
                )
            end
        )

        if waitOk ~= true then
            completion(false, waitErr or applyErr or "equipment_final_verify_unavailable", summary)
        end
    end)

    if prepassOk ~= true then
        return false, prepassErr or "equipment_weapon_prepass_failed", nil
    end

    return true, "deferred", nil
end
