local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_EQUIPMENT_FETCH = Addon.Modules.EquipmentFetch
local LTM_EQUIPMENT_CHANGE = Addon.Modules.EquipmentChange
local LTM_EQUIPMENT_DEPOSIT = Addon.Modules.EquipmentDeposit
local EQUIPMENT_SLOT_IDS = Addon.Common.Domains.EquipmentSlotIds

local OWNED_BAG_IDS = {
    BAG_WORN,
    BAG_BACKPACK,
}

local FETCH_POLL_INTERVAL_MS = 100
local FETCH_POLL_MAX_ATTEMPTS = 30

local function TraceFetchDebug(...)
    if type(Log.LogDebugSummary) ~= "function" then
        return
    end

    Log.LogDebugSummary(...)
end

local function IsSupportedFetchBag(bagId)
    if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        return true
    end

    if type(IsHouseBankBag) == "function" and IsHouseBankBag(bagId) then
        return true
    end

    return false
end

local function BuildSourceBagList()
    if type(IsBankOpen) ~= "function" or IsBankOpen() ~= true then
        return nil, "fetch_source_closed", nil
    end

    if type(GetBankingBag) ~= "function" then
        return nil, "fetch_source_unavailable", nil
    end

    local bankingBag = GetBankingBag()
    if type(bankingBag) ~= "number" or not IsSupportedFetchBag(bankingBag) then
        return nil, "fetch_source_invalid", bankingBag
    end

    local bagIds = {}
    local seen = {}

    local function AddBag(bagId)
        if type(bagId) ~= "number" or seen[bagId] == true then
            return
        end

        seen[bagId] = true
        bagIds[#bagIds + 1] = bagId
    end

    AddBag(bankingBag)

    if bankingBag == BAG_BANK or bankingBag == BAG_SUBSCRIBER_BANK then
        AddBag(BAG_BANK)
        if type(IsESOPlusSubscriber) == "function" and IsESOPlusSubscriber() == true then
            AddBag(BAG_SUBSCRIBER_BANK)
        end
    end

    return bagIds, nil, bankingBag
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

local function DidMoveArrive(candidate, destSlot)
    if type(candidate) ~= "table" or type(destSlot) ~= "number" then
        return false
    end

    if type(GetItemLink) ~= "function" then
        return false
    end

    local itemLink = GetItemLink(BAG_BACKPACK, destSlot, LINK_STYLE_DEFAULT)
    if type(itemLink) ~= "string" or itemLink == "" then
        return false
    end

    if type(candidate.uniqueId) == "string" and candidate.uniqueId ~= ""
        and type(GetItemUniqueId) == "function"
        and type(Id64ToString) == "function" then
        local movedUniqueId = GetItemUniqueId(BAG_BACKPACK, destSlot)
        if movedUniqueId ~= nil then
            movedUniqueId = Id64ToString(movedUniqueId)
        end
        return movedUniqueId == candidate.uniqueId
    end

    return itemLink == candidate.itemLink
end

local function BuildFetchPlan(targetEquipment)
    if type(targetEquipment) ~= "table" then
        return false, "equipment_config_invalid", nil
    end

    if type(LTM_EQUIPMENT_CHANGE) ~= "table"
        or type(LTM_EQUIPMENT_CHANGE.NormalizeTargetEntry) ~= "function"
        or type(LTM_EQUIPMENT_CHANGE.CreateReservationState) ~= "function"
        or type(LTM_EQUIPMENT_CHANGE.FindMatchingWornItemAtSlot) ~= "function"
        or type(LTM_EQUIPMENT_CHANGE.FindMatchingItemInBags) ~= "function"
        or type(LTM_EQUIPMENT_CHANGE.ReserveItemState) ~= "function" then
        return false, "equipment_change_unavailable", nil
    end

    local sourceBagIds, sourceErr, bankingBag = BuildSourceBagList()
    if type(sourceBagIds) ~= "table" then
        return false, sourceErr or "fetch_source_unavailable", {
            sourceBagIds = {},
            targetSlots = 0,
            alreadyOwnedSlots = 0,
            queuedSlots = 0,
            unavailableSlots = 0,
            fetchedSlots = 0,
        }
    end

    local plan = {
        sourceBagIds = sourceBagIds,
        bankingBag = bankingBag,
        items = {},
        targetSlots = 0,
        alreadyOwnedSlots = 0,
        queuedSlots = 0,
        unavailableSlots = 0,
        fetchedSlots = 0,
    }
    local reservedCandidates = LTM_EQUIPMENT_CHANGE:CreateReservationState()

    for _, equipSlotId in ipairs(EQUIPMENT_SLOT_IDS) do
        local targetEntry = LTM_EQUIPMENT_CHANGE:NormalizeTargetEntry(targetEquipment[equipSlotId])
        if type(targetEntry) == "table" then
            plan.targetSlots = plan.targetSlots + 1

            local ownedItem = LTM_EQUIPMENT_CHANGE:FindMatchingWornItemAtSlot(targetEntry, equipSlotId)
            if type(ownedItem) ~= "table" then
                ownedItem = LTM_EQUIPMENT_CHANGE:FindMatchingItemInBags(
                    targetEntry,
                    equipSlotId,
                    OWNED_BAG_IDS,
                    reservedCandidates
                )
            end
            if type(ownedItem) == "table" then
                plan.alreadyOwnedSlots = plan.alreadyOwnedSlots + 1
                LTM_EQUIPMENT_CHANGE:ReserveItemState(reservedCandidates, ownedItem)
            else
                local sourceItem = LTM_EQUIPMENT_CHANGE:FindMatchingItemInBags(targetEntry, equipSlotId, sourceBagIds, reservedCandidates)
                if type(sourceItem) == "table" then
                    plan.queuedSlots = plan.queuedSlots + 1
                    plan.items[#plan.items + 1] = {
                        equipSlotId = equipSlotId,
                        bagId = sourceItem.bagId,
                        slotIndex = sourceItem.slotIndex,
                        uniqueId = sourceItem.uniqueId,
                        itemLink = sourceItem.itemLink,
                    }
                    LTM_EQUIPMENT_CHANGE:ReserveItemState(reservedCandidates, sourceItem)
                else
                    plan.unavailableSlots = plan.unavailableSlots + 1
                end
            end
        end
    end

    TraceFetchDebug(
        "Equipment fetch plan",
        "sourceBag=" .. tostring(bankingBag),
        "targetSlots=" .. tostring(plan.targetSlots),
        "alreadyOwnedSlots=" .. tostring(plan.alreadyOwnedSlots),
        "queuedSlots=" .. tostring(plan.queuedSlots),
        "unavailableSlots=" .. tostring(plan.unavailableSlots)
    )

    return true, nil, plan
end

local function ExecuteMove(candidate, destSlot)
    if type(CallSecureProtected) ~= "function" then
        return false, "move_secure_unavailable"
    end

    local ok, err = pcall(CallSecureProtected, "RequestMoveItem", candidate.bagId, candidate.slotIndex, BAG_BACKPACK, destSlot, 1)
    if not ok then
        return false, err or "request_move_item_failed"
    end

    return true
end

local function BuildUpdateName(moveIndex)
    local timeSeed = 0
    if type(GetFrameTimeMilliseconds) == "function" then
        timeSeed = GetFrameTimeMilliseconds() or 0
    elseif type(GetTimeStamp) == "function" then
        timeSeed = GetTimeStamp() or 0
    end

    return "LTM_EquipmentFetchMove" .. tostring(timeSeed) .. "_" .. tostring(moveIndex or 0)
end

function LTM_EQUIPMENT_FETCH:IsFetchContextAvailable()
    local bagIds = select(1, BuildSourceBagList())
    return type(bagIds) == "table" and #bagIds > 0
end

function LTM_EQUIPMENT_FETCH:IsBusy()
    return self.pendingFetchContext ~= nil
end

function LTM_EQUIPMENT_FETCH:BeginFetch(targetEquipment, completion)
    if self:IsBusy() then
        return false, "equipment_fetch_busy", nil
    end

    if type(LTM_EQUIPMENT_DEPOSIT) == "table"
        and type(LTM_EQUIPMENT_DEPOSIT.IsBusy) == "function"
        and LTM_EQUIPMENT_DEPOSIT:IsBusy() == true then
        return false, "equipment_deposit_busy", nil
    end

    local planOk, planErr, plan = BuildFetchPlan(targetEquipment)
    if planOk ~= true then
        return false, planErr, plan
    end

    if plan.queuedSlots <= 0 then
        if plan.unavailableSlots > 0 then
            return true, "no_fetchable_items", plan
        end

        return true, "nothing_missing", plan
    end

    if type(completion) ~= "function" then
        return false, "fetch_completion_required", plan
    end

    local context = {
        plan = plan,
        moveIndex = 1,
        finished = false,
    }
    self.pendingFetchContext = context

    local function Finish(success, err)
        if context.finished then
            return
        end

        context.finished = true
        LTM_EQUIPMENT_FETCH.pendingFetchContext = nil
        completion(success == true, err, context.plan)
    end

    local function MoveNext()
        if context.finished then
            return
        end

        local candidate = context.plan.items[context.moveIndex]
        if type(candidate) ~= "table" then
            Finish(true, nil)
            return
        end

        if type(DoesBagHaveSpaceFor) == "function"
            and DoesBagHaveSpaceFor(BAG_BACKPACK, candidate.bagId, candidate.slotIndex) ~= true then
            Finish(false, "inventory_full")
            return
        end

        local destSlot = FindFirstBackpackEmptySlot()
        if type(destSlot) ~= "number" then
            Finish(false, "inventory_full")
            return
        end

        local moveOk, moveErr = ExecuteMove(candidate, destSlot)
        if moveOk ~= true then
            Finish(false, moveErr or "move_failed")
            return
        end

        local updateName = BuildUpdateName(context.moveIndex)
        local attempts = 0

        EVENT_MANAGER:RegisterForUpdate(updateName, FETCH_POLL_INTERVAL_MS, function()
            if context.finished then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                return
            end

            attempts = attempts + 1
            if DidMoveArrive(candidate, destSlot) then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                context.plan.fetchedSlots = context.plan.fetchedSlots + 1
                context.moveIndex = context.moveIndex + 1
                zo_callLater(MoveNext, FETCH_POLL_INTERVAL_MS)
                return
            end

            if attempts >= FETCH_POLL_MAX_ATTEMPTS then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                Finish(false, "fetch_move_timeout")
            end
        end)
    end

    MoveNext()
    return true, "deferred", plan
end
