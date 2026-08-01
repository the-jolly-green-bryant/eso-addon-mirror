local Addon = LarvalTearMod
local EquipmentDeposit = Addon.Modules.EquipmentDeposit
local EquipmentChange = Addon.Modules.EquipmentChange
local EquipmentFetch = Addon.Modules.EquipmentFetch
local BuildStore = Addon.Modules.BuildStore

local DEPOSIT_POLL_INTERVAL_MS = 100
local DEPOSIT_POLL_MAX_ATTEMPTS = 30

local CLEANUP_SCOPE_CURRENT_BUILD = "current_build"
local CLEANUP_SCOPE_ALL_BUILD_CARDS = "all_build_cards"
local SAFETY_MODE_STRICT = "strict"
local SAFETY_MODE_NORMAL = "normal"
local SAFETY_MODE_AGGRESSIVE = "aggressive"
local ITEM_FILTER_ALL_EQUIPMENT = "all_equipment"
local ITEM_FILTER_SAVED_BUILD_GEAR_ONLY = "saved_build_gear_only"

local function IsSupportedDepositBag(bagId)
    if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        return true
    end

    if type(IsHouseBankBag) == "function" and IsHouseBankBag(bagId) then
        return true
    end

    return false
end

local function GetCurrentDepositBag()
    if type(IsBankOpen) ~= "function" or IsBankOpen() ~= true then
        return nil, "deposit_storage_closed"
    end

    if type(GetBankingBag) ~= "function" then
        return nil, "deposit_storage_unavailable"
    end

    local bankingBag = GetBankingBag()
    if type(bankingBag) ~= "number" or not IsSupportedDepositBag(bankingBag) then
        return nil, "deposit_storage_invalid"
    end

    return bankingBag, nil
end

local function NormalizeCleanupScope(scope)
    if scope == CLEANUP_SCOPE_CURRENT_BUILD then
        return CLEANUP_SCOPE_CURRENT_BUILD
    end

    return CLEANUP_SCOPE_ALL_BUILD_CARDS
end

local function NormalizeSafetyMode(mode)
    if mode == SAFETY_MODE_STRICT or mode == SAFETY_MODE_AGGRESSIVE then
        return mode
    end

    return SAFETY_MODE_NORMAL
end

local function NormalizeItemFilter(value)
    if value == ITEM_FILTER_ALL_EQUIPMENT then
        return ITEM_FILTER_ALL_EQUIPMENT
    end

    return ITEM_FILTER_SAVED_BUILD_GEAR_ONLY
end

local function GetItemUniqueIdString(bagId, slotIndex)
    if type(GetItemUniqueId) ~= "function" or type(Id64ToString) ~= "function" then
        return nil
    end

    local uniqueId = GetItemUniqueId(bagId, slotIndex)
    if uniqueId == nil then
        return nil
    end

    uniqueId = Id64ToString(uniqueId)
    return type(uniqueId) == "string" and uniqueId ~= "" and uniqueId or nil
end

local function BuildItemState(bagId, slotIndex)
    if type(GetItemLink) ~= "function" or type(GetItemId) ~= "function" then
        return nil
    end

    local itemId = GetItemId(bagId, slotIndex)
    if type(itemId) ~= "number" or itemId <= 0 then
        return nil
    end

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    local traitType = type(GetItemLinkTraitInfo) == "function" and GetItemLinkTraitInfo(itemLink) or nil
    local linkQuality = type(GetItemLinkDisplayQuality) == "function" and GetItemLinkDisplayQuality(itemLink) or nil
    local infoQuality = type(GetItemInfo) == "function" and select(9, GetItemInfo(bagId, slotIndex)) or nil

    return {
        bagId = bagId,
        slotIndex = slotIndex,
        uniqueId = GetItemUniqueIdString(bagId, slotIndex),
        itemLink = itemLink,
        itemId = itemId,
        traitType = type(traitType) == "number" and traitType > 0 and traitType or nil,
        quality = type(linkQuality) == "number" and linkQuality or nil,
        displayQuality = type(linkQuality) == "number" and linkQuality or nil,
        itemInfoDisplayQuality = type(infoQuality) == "number" and infoQuality or nil,
    }
end

local function IsFallbackTargetMatch(targetEntry, itemState)
    if type(targetEntry) ~= "table" or type(itemState) ~= "table" then
        return false
    end

    if targetEntry.itemLink ~= nil and itemState.itemLink == targetEntry.itemLink then
        return true
    end

    if targetEntry.itemId ~= nil
        and itemState.itemId ~= nil
        and targetEntry.itemId == itemState.itemId then
        local traitMatches = targetEntry.traitType == nil or targetEntry.traitType == itemState.traitType
        local qualityMatches = targetEntry.quality == nil or targetEntry.quality == itemState.quality
        return traitMatches and qualityMatches
    end

    return false
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

local function IsMythicItem(itemState)
    if type(itemState) ~= "table" then
        return false
    end

    return IsMythicByDisplayQuality(itemState.displayQuality or itemState.quality)
        or IsMythicByDisplayQuality(itemState.itemInfoDisplayQuality)
end

local function AddProtectedEquipment(protectedState, equipment)
    if type(protectedState) ~= "table" or type(equipment) ~= "table" then
        return
    end

    for _, slotEntry in pairs(equipment) do
        local targetEntry = type(EquipmentChange) == "table"
            and type(EquipmentChange.NormalizeTargetEntry) == "function"
            and EquipmentChange:NormalizeTargetEntry(slotEntry)
            or nil
        if type(targetEntry) == "table" then
            if type(targetEntry.uniqueId) == "string" and targetEntry.uniqueId ~= "" then
                protectedState.uniqueIds[targetEntry.uniqueId] = true
            else
                protectedState.fallbackTargets[#protectedState.fallbackTargets + 1] = targetEntry
            end
        end
    end
end

local function BuildProtectedEquipmentState(scope, currentBuildId)
    local protectedState = {
        uniqueIds = {},
        fallbackTargets = {},
    }

    if type(BuildStore) ~= "table" then
        return protectedState
    end

    if scope == CLEANUP_SCOPE_CURRENT_BUILD then
        local buildId = type(currentBuildId) == "string" and currentBuildId ~= "" and currentBuildId or nil
        if buildId == nil
            and type(BuildStore.GetSelectedPageId) == "function"
            and type(BuildStore.GetSelectedBuildIdForPage) == "function" then
            local pageId = BuildStore:GetSelectedPageId()
            buildId = type(pageId) == "string" and BuildStore:GetSelectedBuildIdForPage(pageId) or nil
        end

        local build = type(buildId) == "string"
            and type(BuildStore.GetPreferredBuildById) == "function"
            and BuildStore:GetPreferredBuildById(buildId)
            or nil
        AddProtectedEquipment(protectedState, type(build) == "table" and build.equipment or nil)
        return protectedState
    end

    local buildList = type(BuildStore.GetBuildListForCurrentCharacter) == "function"
        and BuildStore:GetBuildListForCurrentCharacter()
        or {}
    for _, build in pairs(type(buildList) == "table" and buildList or {}) do
        AddProtectedEquipment(protectedState, type(build) == "table" and build.equipment or nil)
    end

    return protectedState
end

local function IsBuildProtected(protectedState, itemState)
    if type(protectedState) ~= "table" or type(itemState) ~= "table" then
        return false
    end

    if type(itemState.uniqueId) == "string"
        and itemState.uniqueId ~= ""
        and protectedState.uniqueIds[itemState.uniqueId] == true then
        return true
    end

    for _, targetEntry in ipairs(protectedState.fallbackTargets or {}) do
        if IsFallbackTargetMatch(targetEntry, itemState) then
            return true
        end
    end

    return false
end

local function SlotHasFilterType(bagId, slotIndex, expectedType)
    if type(expectedType) ~= "number" or type(GetItemFilterTypeInfo) ~= "function" then
        return false
    end

    local filterTypes = { GetItemFilterTypeInfo(bagId, slotIndex) }
    for _, filterType in ipairs(filterTypes) do
        if filterType == expectedType then
            return true
        end
    end

    return false
end

local function IsEquipmentFilterType(bagId, slotIndex)
    return (type(ITEMFILTERTYPE_WEAPONS) == "number" and SlotHasFilterType(bagId, slotIndex, ITEMFILTERTYPE_WEAPONS))
        or (type(ITEMFILTERTYPE_ARMOR) == "number" and SlotHasFilterType(bagId, slotIndex, ITEMFILTERTYPE_ARMOR))
        or (type(ITEMFILTERTYPE_APPAREL) == "number" and SlotHasFilterType(bagId, slotIndex, ITEMFILTERTYPE_APPAREL))
        or (type(ITEMFILTERTYPE_JEWELRY) == "number" and SlotHasFilterType(bagId, slotIndex, ITEMFILTERTYPE_JEWELRY))
end

local function IsQuestItem(bagId, slotIndex)
    return type(ITEMFILTERTYPE_QUEST) == "number"
        and SlotHasFilterType(bagId, slotIndex, ITEMFILTERTYPE_QUEST)
end

local function IsSafetyProtected(mode, itemState)
    if mode == SAFETY_MODE_AGGRESSIVE then
        return false
    end

    local bagId = itemState.bagId
    local slotIndex = itemState.slotIndex
    if type(IsItemPlayerLocked) == "function" and IsItemPlayerLocked(bagId, slotIndex) == true then
        return true
    end

    if mode == SAFETY_MODE_STRICT then
        if IsMythicItem(itemState) then
            return true
        end
        if type(IsItemBound) == "function" and IsItemBound(bagId, slotIndex) == true then
            return true
        end
    end

    return false
end

local function IterateBackpackSlots()
    if type(GetBagSize) == "function" then
        local bagSize = tonumber(GetBagSize(BAG_BACKPACK)) or 0
        local index = -1
        return function()
            index = index + 1
            if index < bagSize then
                return index
            end
            return nil
        end
    end

    if type(ZO_IterateBagSlots) == "function" then
        return ZO_IterateBagSlots(BAG_BACKPACK)
    end

    return function()
        return nil
    end
end

local function BuildDepositPlan(options)
    local bankingBag, bagErr = GetCurrentDepositBag()
    if type(bankingBag) ~= "number" then
        return false, bagErr or "deposit_storage_unavailable", nil
    end

    local scope = NormalizeCleanupScope(type(options) == "table" and options.cleanupScope or nil)
    local safetyMode = NormalizeSafetyMode(type(options) == "table" and options.safetyMode or nil)
    local itemFilter = NormalizeItemFilter(type(options) == "table" and options.itemFilter or nil)
    local protectedState = BuildProtectedEquipmentState(scope, type(options) == "table" and options.currentBuildId or nil)
    local savedBuildGearState = itemFilter == ITEM_FILTER_SAVED_BUILD_GEAR_ONLY
        and BuildProtectedEquipmentState(CLEANUP_SCOPE_ALL_BUILD_CARDS, type(options) == "table" and options.currentBuildId or nil)
        or nil
    local plan = {
        bankingBag = bankingBag,
        items = {},
        queuedSlots = 0,
        depositedSlots = 0,
        protectedSlots = 0,
        filteredOutSlots = 0,
    }

    for slotIndex in IterateBackpackSlots() do
        local itemState = BuildItemState(BAG_BACKPACK, slotIndex)
        if type(itemState) == "table"
            and not IsQuestItem(BAG_BACKPACK, slotIndex)
            and not (type(IsItemStolen) == "function" and IsItemStolen(BAG_BACKPACK, slotIndex) == true)
            and IsEquipmentFilterType(BAG_BACKPACK, slotIndex) then
            if IsBuildProtected(protectedState, itemState) then
                plan.protectedSlots = plan.protectedSlots + 1
            elseif itemFilter == ITEM_FILTER_SAVED_BUILD_GEAR_ONLY
                and not IsBuildProtected(savedBuildGearState, itemState) then
                plan.filteredOutSlots = plan.filteredOutSlots + 1
            elseif IsSafetyProtected(safetyMode, itemState) then
                plan.protectedSlots = plan.protectedSlots + 1
            else
                plan.queuedSlots = plan.queuedSlots + 1
                plan.items[#plan.items + 1] = itemState
            end
        end
    end

    return true, nil, plan
end

local function FindFirstEmptySlot(destBag)
    if type(FindFirstEmptySlotInBag) == "function" then
        local slotIndex = FindFirstEmptySlotInBag(destBag)
        if type(slotIndex) == "number" then
            return slotIndex
        end
    end

    if type(GetBagSize) ~= "function" or type(GetItemId) ~= "function" then
        return nil
    end

    local bagSize = GetBagSize(destBag)
    for slotIndex = 0, bagSize - 1 do
        if GetItemId(destBag, slotIndex) == 0 then
            return slotIndex
        end
    end

    return nil
end

local function ResolveDestinationBag(candidate, preferredBag)
    if type(DoesBagHaveSpaceFor) == "function"
        and DoesBagHaveSpaceFor(preferredBag, candidate.bagId, candidate.slotIndex) == true then
        return preferredBag, nil
    end

    if preferredBag == BAG_BANK
        and type(IsESOPlusSubscriber) == "function"
        and IsESOPlusSubscriber() == true
        and type(DoesBagHaveSpaceFor) == "function"
        and DoesBagHaveSpaceFor(BAG_SUBSCRIBER_BANK, candidate.bagId, candidate.slotIndex) == true then
        return BAG_SUBSCRIBER_BANK, nil
    end

    return nil, "deposit_storage_full"
end

local function DidMoveArrive(candidate, destBag, destSlot)
    if type(candidate) ~= "table" or type(destBag) ~= "number" or type(destSlot) ~= "number" then
        return false
    end

    if type(candidate.uniqueId) == "string" and candidate.uniqueId ~= "" then
        local movedUniqueId = GetItemUniqueIdString(destBag, destSlot)
        if movedUniqueId ~= nil then
            return movedUniqueId == candidate.uniqueId
        end
    end

    return type(GetItemId) == "function" and (GetItemId(destBag, destSlot) or 0) > 0
end

local function ExecuteMove(candidate, destBag, destSlot)
    if type(CallSecureProtected) ~= "function" then
        return false, "move_secure_unavailable"
    end

    local ok, err = pcall(CallSecureProtected, "RequestMoveItem", candidate.bagId, candidate.slotIndex, destBag, destSlot, 1)
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

    return "LTM_EquipmentDepositMove" .. tostring(timeSeed) .. "_" .. tostring(moveIndex or 0)
end

local function CallLaterOrNow(callback, delayMs)
    if type(callback) ~= "function" then
        return
    end

    if type(zo_callLater) == "function" then
        zo_callLater(callback, delayMs or 0)
        return
    end

    callback()
end

function EquipmentDeposit:IsDepositContextAvailable()
    local bankingBag = select(1, GetCurrentDepositBag())
    return type(bankingBag) == "number"
end

function EquipmentDeposit:IsBusy()
    return self.pendingDepositContext ~= nil
end

function EquipmentDeposit:NormalizeCleanupScope(scope)
    return NormalizeCleanupScope(scope)
end

function EquipmentDeposit:NormalizeSafetyMode(mode)
    return NormalizeSafetyMode(mode)
end

function EquipmentDeposit:NormalizeItemFilter(value)
    return NormalizeItemFilter(value)
end

function EquipmentDeposit:BeginDeposit(options, completion)
    if self:IsBusy() then
        return false, "equipment_deposit_busy", nil
    end

    if type(EquipmentFetch) == "table"
        and type(EquipmentFetch.IsBusy) == "function"
        and EquipmentFetch:IsBusy() == true then
        return false, "equipment_fetch_busy", nil
    end

    local planOk, planErr, plan = BuildDepositPlan(options)
    if planOk ~= true then
        return false, planErr, plan
    end

    if plan.queuedSlots <= 0 then
        return true, "nothing_to_deposit", plan
    end

    if type(completion) ~= "function" then
        return false, "deposit_completion_required", plan
    end
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return false, "deposit_event_manager_unavailable", plan
    end

    local context = {
        plan = plan,
        moveIndex = 1,
        finished = false,
    }
    self.pendingDepositContext = context

    local function Finish(success, err)
        if context.finished then
            return
        end

        context.finished = true
        EquipmentDeposit.pendingDepositContext = nil
        completion(success == true, err, context.plan)
    end

    local function MoveNext()
        if context.finished then
            return
        end

        if type(IsBankOpen) ~= "function" or IsBankOpen() ~= true then
            Finish(false, "deposit_storage_closed")
            return
        end

        local candidate = context.plan.items[context.moveIndex]
        if type(candidate) ~= "table" then
            Finish(true, nil)
            return
        end

        local destBag, destErr = ResolveDestinationBag(candidate, context.plan.bankingBag)
        if type(destBag) ~= "number" then
            Finish(false, destErr or "deposit_storage_full")
            return
        end

        local destSlot = FindFirstEmptySlot(destBag)
        if type(destSlot) ~= "number" then
            Finish(false, "deposit_storage_full")
            return
        end

        local moveOk, moveErr = ExecuteMove(candidate, destBag, destSlot)
        if moveOk ~= true then
            Finish(false, moveErr or "deposit_move_failed")
            return
        end

        local updateName = BuildUpdateName(context.moveIndex)
        local attempts = 0

        EVENT_MANAGER:RegisterForUpdate(updateName, DEPOSIT_POLL_INTERVAL_MS, function()
            if context.finished then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                return
            end

            if type(IsBankOpen) ~= "function" or IsBankOpen() ~= true then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                Finish(false, "deposit_storage_closed")
                return
            end

            attempts = attempts + 1
            if DidMoveArrive(candidate, destBag, destSlot) then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                context.plan.depositedSlots = context.plan.depositedSlots + 1
                context.moveIndex = context.moveIndex + 1
                CallLaterOrNow(MoveNext, DEPOSIT_POLL_INTERVAL_MS)
                return
            end

            if attempts >= DEPOSIT_POLL_MAX_ATTEMPTS then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                Finish(false, "deposit_move_timeout")
            end
        end)
    end

    MoveNext()
    return true, "deferred", plan
end
