HF.LayoutApplier = {}

local DEFAULT_REQUEST_DELAY_MS = 350
local activeQueue = nil

local function GetHousingDelayMs()
    if HF.GetHousingRequestDelayMs then
        return HF.GetHousingRequestDelayMs()
    end
    return DEFAULT_REQUEST_DELAY_MS
end

local function FurnitureIdKey(furnitureId)
    if furnitureId == nil then return nil end
    if Id64ToString then
        local ok, value = pcall(Id64ToString, furnitureId)
        if ok and value and value ~= "" then return value end
    end
    return tostring(furnitureId)
end

local IsCollectibleAvailable

local function BuildBagScanOrder()
    local bags = {}
    local function AddBag(bagId)
        if bagId ~= nil then
            table.insert(bags, bagId)
        end
    end

    AddBag(BAG_BACKPACK)
    AddBag(BAG_BANK)
    AddBag(BAG_SUBSCRIBER_BANK)
    AddBag(BAG_FURNITURE_VAULT)
    AddBag(BAG_HOUSE_BANK_ONE)
    AddBag(BAG_HOUSE_BANK_TWO)
    AddBag(BAG_HOUSE_BANK_THREE)
    AddBag(BAG_HOUSE_BANK_FOUR)
    AddBag(BAG_HOUSE_BANK_FIVE)
    AddBag(BAG_HOUSE_BANK_SIX)
    AddBag(BAG_HOUSE_BANK_SEVEN)
    AddBag(BAG_HOUSE_BANK_EIGHT)
    AddBag(BAG_HOUSE_BANK_NINE)
    AddBag(BAG_HOUSE_BANK_TEN)

    return bags
end

local function IsValidBag(bagId)
    if bagId == nil or not GetBagSize then return false end
    local ok, bagSize = pcall(GetBagSize, bagId)
    return ok and bagSize ~= nil
end

local function GetSafeBagSize(bagId)
    if bagId == nil or not GetBagSize then return 0 end
    local ok, bagSize = pcall(GetBagSize, bagId)
    if ok and bagSize then return bagSize end
    return 0
end

function HF.LayoutApplier.BuildItemIndex()
    local index = {
        byItemId = {},
        byFurnitureDataId = {},
        scannedBags = 0,
        scannedItems = 0,
    }
    for _, bagId in ipairs(BuildBagScanOrder()) do
        if IsValidBag(bagId) then
            index.scannedBags = index.scannedBags + 1
            local bagSize = GetSafeBagSize(bagId)
            for slotIndex = 0, bagSize - 1 do
                if HasItemInSlot and HasItemInSlot(bagId, slotIndex) then
                    index.scannedItems = index.scannedItems + 1
                    local itemId = GetItemId and GetItemId(bagId, slotIndex) or 0
                    local furnitureDataId = GetItemFurnitureDataId and GetItemFurnitureDataId(bagId, slotIndex) or 0
                    local _, stack = GetItemInfo(bagId, slotIndex)
                    local candidate = { bagId = bagId, slotIndex = slotIndex, remaining = stack or 1, itemId = itemId or 0, furnitureDataId = furnitureDataId or 0 }
                    if itemId and itemId ~= 0 then
                        if not index.byItemId[itemId] then index.byItemId[itemId] = {} end
                        table.insert(index.byItemId[itemId], candidate)
                    end
                    if furnitureDataId and furnitureDataId ~= 0 then
                        if not index.byFurnitureDataId[furnitureDataId] then index.byFurnitureDataId[furnitureDataId] = {} end
                        table.insert(index.byFurnitureDataId[furnitureDataId], candidate)
                    end
                end
            end
        end
    end
    return index
end

local function CountCandidateList(candidates)
    local total = 0
    for _, candidate in ipairs(candidates or {}) do
        total = total + (candidate.remaining or 0)
    end
    return total
end

function HF.LayoutApplier.BuildOwnedPreview(layout)
    local itemIndex = HF.LayoutApplier.BuildItemIndex()
    local required = {}
    local owned = 0
    local missing = 0
    local unknown = 0

    for _, item in ipairs((layout and layout.items) or {}) do
        local furnitureDataId = tonumber(item.furnitureDataId) or 0
        local itemId = tonumber(item.itemId) or 0
        local collectibleId = tonumber(item.collectibleId) or 0
        local key = (furnitureDataId ~= 0 or itemId ~= 0 or collectibleId ~= 0)
            and (tostring(furnitureDataId) .. ":" .. tostring(itemId) .. ":" .. tostring(collectibleId))
            or ("name:" .. tostring(item.itemName or "Unknown Furniture"))
        local entry = required[key]
        if not entry then
            entry = {
                itemName = tostring(item.itemName or "Unknown Furniture"),
                needed = 0,
                owned = 0,
                missing = 0,
                furnitureDataId = furnitureDataId,
                itemId = itemId,
                collectibleId = collectibleId,
            }
            required[key] = entry
        end
        entry.needed = entry.needed + 1

        local available = 0
        if item.furnitureDataId and item.furnitureDataId ~= 0 then
            available = available + CountCandidateList(itemIndex.byFurnitureDataId[item.furnitureDataId])
        end
        if available == 0 and item.itemId and item.itemId ~= 0 then
            available = available + CountCandidateList(itemIndex.byItemId[item.itemId])
        end
        if available == 0 and item.collectibleId and item.collectibleId ~= 0 and IsCollectibleAvailable(item.collectibleId) then
            available = 1
        end

        if available > entry.owned then
            entry.owned = math.min(entry.needed, available)
        end
    end

    local list = {}
    for _, entry in pairs(required) do
        entry.missing = math.max(0, entry.needed - entry.owned)
        owned = owned + entry.owned
        missing = missing + entry.missing
        if entry.furnitureDataId == 0 and entry.itemId == 0 and entry.collectibleId == 0 then
            unknown = unknown + entry.needed
        end
        table.insert(list, entry)
    end
    table.sort(list, function(a, b)
        if (a.missing > 0) ~= (b.missing > 0) then return a.missing > 0 end
        return (a.itemName or "") < (b.itemName or "")
    end)

    return {
        layoutName = layout and layout.name or "",
        total = (layout and layout.items and #layout.items) or 0,
        owned = owned,
        missing = missing,
        unknown = unknown,
        required = list,
        scannedBags = itemIndex.scannedBags,
        scannedItems = itemIndex.scannedItems,
    }
end

IsCollectibleAvailable = function(collectibleId)
    if not collectibleId or collectibleId == 0 then return false end
    if IsCollectibleUnlocked and IsCollectibleUnlocked(collectibleId) then return true end
    if GetCollectibleUnlockStateById then
        local state = GetCollectibleUnlockStateById(collectibleId)
        return state == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED or state == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_SUBSCRIPTION or state == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_TRIAL
    end
    return false
end

local function PlaceCollectible(item)
    if not IsCollectibleAvailable(item.collectibleId) then
        return false, "collectible not unlocked"
    end
    local result = HousingEditorRequestCollectiblePlacement(item.collectibleId, item.worldX, item.worldY, item.worldZ, item.pitch, item.yaw, item.roll)
    return result == HOUSING_REQUEST_RESULT_SUCCESS, result
end

local function PlaceItem(item, itemIndex, deferConsumption, pendingRequest)
    if (not item.itemId or item.itemId == 0) and (not item.furnitureDataId or item.furnitureDataId == 0) then
        return false, "no item or furniture id"
    end
    local candidates = nil
    if item.furnitureDataId and item.furnitureDataId ~= 0 then
        candidates = itemIndex.byFurnitureDataId[item.furnitureDataId]
    end
    if (not candidates or #candidates == 0) and item.itemId and item.itemId ~= 0 then
        candidates = itemIndex.byItemId[item.itemId]
    end
    while candidates and #candidates > 0 and (candidates[1].remaining or 0) <= 0 do
        table.remove(candidates, 1)
    end
    if not candidates or #candidates == 0 then
        return false, "item not found"
    end
    local candidate = candidates[1]
    if pendingRequest then
        pendingRequest.candidate = candidate
        pendingRequest.candidateList = candidates
    end
    local result = HousingEditorRequestItemPlacement(candidate.bagId, candidate.slotIndex, item.worldX, item.worldY, item.worldZ, item.pitch, item.yaw, item.roll)
    if result == HOUSING_REQUEST_RESULT_SUCCESS and not deferConsumption then
        candidate.remaining = (candidate.remaining or 1) - 1
        if candidate.remaining <= 0 then
            table.remove(candidates, 1)
        end
    end
    return result == HOUSING_REQUEST_RESULT_SUCCESS, result, candidate, candidates
end

local QUEUE_EVENT_NAMESPACE = "HousingForge_LayoutApplierQueue"
local REQUEST_ACK_TIMEOUT_MS = 5000
local CLEAN_SETTLE_DELAY_MS = 1500

local StepPlacementQueue
local StepRemovalQueue
local UnregisterQueueEvents

local function GetRequestAckTimeoutMs()
    return math.min(10000, math.max(REQUEST_ACK_TIMEOUT_MS, GetHousingDelayMs() * 8))
end

local function GetCleanSettleDelayMs()
    return math.min(5000, math.max(CLEAN_SETTLE_DELAY_MS, GetHousingDelayMs() * 3))
end

local function BuildPlacedFurnitureIdSet()
    local result = {}
    for _, furnitureId in ipairs(HF.LayoutRecorder.GetAllPlacedFurnitureIds()) do
        result[FurnitureIdKey(furnitureId)] = true
    end
    return result
end

local function IsFurniturePlaced(furnitureId)
    local targetKey = FurnitureIdKey(furnitureId)
    local currentId = nil
    while true do
        currentId = GetNextPlacedHousingFurnitureId(currentId)
        if not currentId then return false end
        if FurnitureIdKey(currentId) == targetKey then return true end
    end
end

local function DoesPlacedFurnitureMatch(item, furnitureId, eventCollectibleId, placementSource)
    if placementSource ~= "item" and item.collectibleId and item.collectibleId ~= 0 then
        if eventCollectibleId and eventCollectibleId ~= 0 then
            return eventCollectibleId == item.collectibleId
        end
        if GetPlacedFurnitureLink then
            local ok, _, collectibleLink = pcall(GetPlacedFurnitureLink, furnitureId, LINK_STYLE_DEFAULT)
            if ok and collectibleLink and collectibleLink ~= "" then
                local placedCollectibleId = tonumber(string.match(collectibleLink, "|H.-:collectible:(%d+)")) or 0
                return placedCollectibleId == item.collectibleId
            end
        end
    end

    if item.furnitureDataId and item.furnitureDataId ~= 0 and GetPlacedHousingFurnitureInfo then
        local ok, _, _, furnitureDataId = pcall(GetPlacedHousingFurnitureInfo, furnitureId)
        if ok and furnitureDataId then
            return furnitureDataId == item.furnitureDataId
        end
    end

    if item.itemId and item.itemId ~= 0 and GetPlacedFurnitureLink and GetItemLinkItemId then
        local ok, itemLink = pcall(GetPlacedFurnitureLink, furnitureId, LINK_STYLE_DEFAULT)
        if ok and itemLink and itemLink ~= "" then
            return GetItemLinkItemId(itemLink) == item.itemId
        end
    end

    return not item.furnitureDataId or item.furnitureDataId == 0
end

local function FindNewMatchingFurniture(state, item, placementSource)
    local furnitureId = nil
    while true do
        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
        if not furnitureId then return nil end
        local key = FurnitureIdKey(furnitureId)
        if not state.knownFurnitureIds[key] then
            if DoesPlacedFurnitureMatch(item, furnitureId, 0, placementSource) then
                return furnitureId
            end
            state.knownFurnitureIds[key] = true
        end
    end
end

local function ClearActiveQueue(state)
    if activeQueue == state then
        activeQueue = nil
    end
    if HF.runtime then
        HF.runtime.applyQueue = nil
    end
    if UnregisterQueueEvents then
        UnregisterQueueEvents()
    end
end

local function AbortQueue(state, message)
    if not state or activeQueue ~= state then return end
    state.canceled = true
    state.pending = nil
    ClearActiveQueue(state)
    HF.Chat(message or "Housing queue stopped.")
    if HF.RefreshUI then HF.RefreshUI() end
end

local function ScheduleQueueCallback(state, callback, delayMs, allowWhenCanceled)
    if not zo_callLater then
        AbortQueue(state, "Housing queue stopped because the UI scheduler is unavailable.")
        return false
    end
    zo_callLater(function()
        if activeQueue == state and (allowWhenCanceled or not state.canceled) then
            callback()
        end
    end, delayMs)
    return true
end

local function IsQueueInStartingHouse(state)
    if not GetCurrentZoneHouseId then return false end
    return GetCurrentZoneHouseId() == state.houseId
end

local function EnsureQueueStillInStartingHouse(state)
    if IsQueueInStartingHouse(state) then return true end
    AbortQueue(state, "Housing queue stopped because you left or changed the starting house. An accepted request may still finish.")
    return false
end

local function IsRecoverySnapshotEnabled()
    return not HF.savedVars
        or not HF.savedVars.settings
        or HF.savedVars.settings.autoRecordBeforeCleanup ~= false
end

local function CountUnsupportedRecoveryRelationships(layout)
    local linked = 0
    local pathed = 0
    for _, item in ipairs(layout and layout.items or {}) do
        local parentId = tostring(item.parentSourceFurnitureId or "")
        if parentId ~= "" and parentId ~= "0" then linked = linked + 1 end
        if item.path and item.path.nodes and #item.path.nodes > 0 then pathed = pathed + 1 end
    end
    return linked, pathed
end

local function CreateRecoveryLayout(actionType, expectedFurnitureIds)
    if not HF.LayoutRecorder or not HF.LayoutRecorder.RecordRecoverySnapshot then
        HF.Chat("Cannot continue safely: the layout recorder is unavailable.")
        return nil
    end

    local timestamp = GetTimeStamp and GetTimeStamp() or 0
    local previousSelection = HF.savedVars and HF.savedVars.lastSelectedLayoutId or nil
    local previousSelectedLayout = HF.GetSelectedLayout and HF.GetSelectedLayout() or nil
    local previousSelectedLayoutId = previousSelectedLayout and previousSelectedLayout.id or previousSelection
    local recoveryReason = actionType == "clean" and "before cleaning" or "before clean and apply"
    local ok, recoveryLayout, reason = pcall(HF.LayoutRecorder.RecordRecoverySnapshot, recoveryReason, expectedFurnitureIds)
    if HF.savedVars then
        HF.savedVars.lastSelectedLayoutId = previousSelection
    end
    if not ok or not recoveryLayout then
        local failureReason = not ok and recoveryLayout or reason
        HF.Chat("Cannot continue safely: recovery layout recording failed" .. (failureReason and (" (" .. tostring(failureReason) .. ")") or "."))
        return nil
    end

    if previousSelectedLayoutId and HF.BuildLayoutList then
        HF.BuildLayoutList()
        for index, layout in ipairs(HF.ui and HF.ui.sortedLayouts or {}) do
            if layout.id == previousSelectedLayoutId then
                HF.ui.selectedLayoutIndex = index
                break
            end
        end
    end

    recoveryLayout.isRecovery = true
    recoveryLayout.recoveryFor = actionType
    recoveryLayout.recoveryCreatedAt = timestamp
    local linkedCount, pathCount = CountUnsupportedRecoveryRelationships(recoveryLayout)
    if linkedCount > 0 or pathCount > 0 then
        HF.Chat(string.format("Cleanup blocked: this house has %d linked furnishing(s) and %d furnishing path(s). HousingForge 1.4 records them but cannot restore those relationships yet. The snapshot was kept as a reference; use /hf safety off only if you accept permanent link/path loss.", linkedCount, pathCount))
        return nil
    end
    HF.Chat(string.format("Recovery layout saved as '%s' before %s.", recoveryLayout.name or "Recovery", actionType == "clean" and "cleaning" or "clean and apply"))
    return recoveryLayout
end

local function NewPendingRequest(state, kind, item, furnitureId)
    state.requestSerial = (state.requestSerial or 0) + 1
    local pending = {
        token = state.requestSerial,
        kind = kind,
        item = item,
        furnitureId = furnitureId,
    }
    state.pending = pending
    return pending
end

local function ConsumePendingCandidate(pending)
    if not pending or pending.candidateConsumed or not pending.candidate then return end
    pending.candidateConsumed = true
    local candidate = pending.candidate
    candidate.remaining = (candidate.remaining or 1) - 1
    if candidate.remaining <= 0 then
        for index, listedCandidate in ipairs(pending.candidateList or {}) do
            if listedCandidate == candidate then
                table.remove(pending.candidateList, index)
                break
            end
        end
    end
end

local function AdvancePlacementQueue(state)
    local cleanOffset = state.actionType == "cleanThenApply" and #(state.removeIds or {}) or 0
    state.processed = cleanOffset + state.index
    state.index = state.index + 1
    state.pending = nil
    HF.runtime.applyQueue = state
    if HF.RefreshUI then HF.RefreshUI() end
    if state.canceled then
        AbortQueue(state, "Housing queue canceled after the final accepted request settled.")
        return
    end
    ScheduleQueueCallback(state, StepPlacementQueue, GetHousingDelayMs())
end

local function RecordPlacementFailure(state, pending, result)
    local item = pending.item
    if result == "item not found" or result == "collectible not unlocked" or result == "no item or furniture id" then
        item.missingReason = result
        table.insert(state.missing, item)
    else
        item.failureReason = tostring(result)
        table.insert(state.failed, item)
    end
    AdvancePlacementQueue(state)
end

local function RecordStateWarning(state, item, reason)
    item.stateFailureReason = tostring(reason)
    state.stateRestoreFailed = (state.stateRestoreFailed or 0) + 1
    table.insert(state.stateFailures, item)
end

local function FinishObservedPlacement(state, pending)
    table.insert(state.placed, pending.item)
    AdvancePlacementQueue(state)
end

local function FinishStateRestore(state, pending, restored, reason)
    if restored then
        state.statesRestored = (state.statesRestored or 0) + 1
    else
        RecordStateWarning(state, pending.item, reason or "state change was not confirmed")
    end
    FinishObservedPlacement(state, pending)
end

local function BeginStateRestore(state, placementPending, furnitureId)
    if state.canceled then
        FinishObservedPlacement(state, placementPending)
        return
    end
    local item = placementPending.item
    local desiredStateIndex = tonumber(item.stateIndex)
    if desiredStateIndex == nil or not HousingEditorRequestChangeState then
        FinishObservedPlacement(state, placementPending)
        return
    end

    local currentStateIndex = nil
    if GetPlacedHousingFurnitureCurrentObjectStateIndex then
        local ok, value = pcall(GetPlacedHousingFurnitureCurrentObjectStateIndex, furnitureId)
        if ok then currentStateIndex = value end
    end
    if currentStateIndex == desiredStateIndex then
        FinishObservedPlacement(state, placementPending)
        return
    end

    if GetPlacedHousingFurnitureNumObjectStates then
        local ok, numStates = pcall(GetPlacedHousingFurnitureNumObjectStates, furnitureId)
        if ok and numStates and (desiredStateIndex < 0 or desiredStateIndex >= numStates) then
            RecordStateWarning(state, item, string.format("recorded state %d is unavailable", desiredStateIndex))
            FinishObservedPlacement(state, placementPending)
            return
        end
    end

    local pending = NewPendingRequest(state, "state", item, furnitureId)
    pending.desiredStateIndex = desiredStateIndex
    local ok, result = pcall(HousingEditorRequestChangeState, furnitureId, desiredStateIndex)
    if activeQueue ~= state or state.pending ~= pending then return end
    if not ok or result ~= HOUSING_REQUEST_RESULT_SUCCESS then
        FinishStateRestore(state, pending, false, ok and ("state request rejected: " .. tostring(result)) or ("state request error: " .. tostring(result)))
        return
    end

    pending.requestAccepted = true
    ScheduleQueueCallback(state, function()
        if state.pending ~= pending then return end
        if not EnsureQueueStillInStartingHouse(state) then return end
        local observedStateIndex = nil
        if GetPlacedHousingFurnitureCurrentObjectStateIndex then
            local stateOk, value = pcall(GetPlacedHousingFurnitureCurrentObjectStateIndex, furnitureId)
            if stateOk then observedStateIndex = value end
        end
        FinishStateRestore(state, pending, observedStateIndex == desiredStateIndex, "state request accepted but completion was not observed")
    end, GetRequestAckTimeoutMs(), true)
end

local function CompleteObservedPlacement(state, pending, furnitureId)
    ConsumePendingCandidate(pending)
    state.knownFurnitureIds[FurnitureIdKey(furnitureId)] = true
    state.placedFurnitureIds[state.index] = furnitureId
    state.pending = nil
    BeginStateRestore(state, pending, furnitureId)
end

local function CompleteRemovalAttempt(state, pending, removed, reason)
    if removed then
        state.removed = (state.removed or 0) + 1
        state.knownFurnitureIds[FurnitureIdKey(pending.furnitureId)] = nil
    else
        state.removeFailed = (state.removeFailed or 0) + 1
        table.insert(state.removeFailures, { furnitureId = pending.furnitureId, reason = tostring(reason or "removal was not confirmed") })
    end
    state.removeIndex = state.removeIndex + 1
    state.processed = state.removeIndex - 1
    state.pending = nil
    HF.runtime.applyQueue = state
    if HF.RefreshUI then HF.RefreshUI() end
    if state.canceled then
        AbortQueue(state, "Housing queue canceled after the final accepted request settled.")
        return
    end
    ScheduleQueueCallback(state, StepRemovalQueue, GetHousingDelayMs())
end

local function OnFurniturePlaced(_, furnitureId, collectibleId)
    local state = activeQueue
    if not state then return end
    if not EnsureQueueStillInStartingHouse(state) then return end
    state.knownFurnitureIds[FurnitureIdKey(furnitureId)] = true
    local pending = state.pending
    if pending and pending.kind == "place" and DoesPlacedFurnitureMatch(pending.item, furnitureId, collectibleId, pending.source) then
        CompleteObservedPlacement(state, pending, furnitureId)
    end
end

local function OnFurnitureRemoved(_, furnitureId)
    local state = activeQueue
    if not state then return end
    if not EnsureQueueStillInStartingHouse(state) then return end
    state.knownFurnitureIds[FurnitureIdKey(furnitureId)] = nil
    local pending = state.pending
    if pending and pending.kind == "remove" and FurnitureIdKey(pending.furnitureId) == FurnitureIdKey(furnitureId) then
        CompleteRemovalAttempt(state, pending, true)
    end
end

local function OnFurnitureStateChanged(_, furnitureId, objectStateIndex)
    local state = activeQueue
    if not state then return end
    if not EnsureQueueStillInStartingHouse(state) then return end
    local pending = state.pending
    if pending and pending.kind == "state" and FurnitureIdKey(pending.furnitureId) == FurnitureIdKey(furnitureId) and pending.desiredStateIndex == objectStateIndex then
        FinishStateRestore(state, pending, true)
    end
end

local function RegisterQueueEvents()
    if not EVENT_MANAGER then return end
    EVENT_MANAGER:RegisterForEvent(QUEUE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_PLACED, OnFurniturePlaced)
    EVENT_MANAGER:RegisterForEvent(QUEUE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_REMOVED, OnFurnitureRemoved)
    EVENT_MANAGER:RegisterForEvent(QUEUE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_STATE_CHANGED, OnFurnitureStateChanged)
end

UnregisterQueueEvents = function()
    if not EVENT_MANAGER then return end
    EVENT_MANAGER:UnregisterForEvent(QUEUE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_PLACED)
    EVENT_MANAGER:UnregisterForEvent(QUEUE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_REMOVED)
    EVENT_MANAGER:UnregisterForEvent(QUEUE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_STATE_CHANGED)
end

local function FinishQueue(state)
    ClearActiveQueue(state)
    HF.runtime.ownedItems = state.placed or {}
    HF.runtime.missingItems = state.missing or {}
    HF.runtime.failedItems = state.failed or {}
    HF.runtime.failedLayoutHouseId = state.houseId
    HF.runtime.failedLayoutName = state.layout and state.layout.name or nil
    HF.ui.lastApplySummary = {
        placed = #(state.placed or {}),
        missing = #(state.missing or {}),
        failed = #(state.failed or {}),
        stateFailed = state.stateRestoreFailed or 0,
        statesRestored = state.statesRestored or 0,
        removed = state.removed or 0,
        removeFailed = state.removeFailed or 0,
        total = state.layoutTotal or 0,
        layoutName = state.layout and state.layout.name or "",
    }
    if #(state.missing or {}) > 0 then
        HF.MissingItemMarkers.SetItems(state.missing)
    else
        HF.MissingItemMarkers.Clear()
    end
    local stateWarning = (state.stateRestoreFailed or 0) > 0 and string.format(", %d state warning(s)", state.stateRestoreFailed) or ""
    local removalWarning = (state.removeFailed or 0) > 0 and string.format(", %d removal failure(s)", state.removeFailed) or ""
    HF.Chat(string.format("%s complete: %d placed, %d missing, %d failed%s%s.", state.actionType or "Apply", #(state.placed or {}), #(state.missing or {}), #(state.failed or {}), stateWarning, removalWarning))
    local hasWarnings = #(state.failed or {}) > 0 or (state.stateRestoreFailed or 0) > 0 or (state.removeFailed or 0) > 0
    if PlaySound then PlaySound(not hasWarnings and SOUNDS.OBJECTIVE_COMPLETED or SOUNDS.GENERAL_ALERT_ERROR) end
    if HF.RefreshUI then HF.RefreshUI() end
end

local function FinishCleanQueue(state)
    ClearActiveQueue(state)
    local recoveryText = state.recoveryLayoutName and (" Recovery: " .. state.recoveryLayoutName .. ".") or ""
    HF.Chat(string.format("Clean complete: %d removals confirmed, %d failed.%s", state.removed or 0, state.removeFailed or 0, recoveryText))
    if PlaySound then PlaySound((state.removeFailed or 0) == 0 and SOUNDS.OBJECTIVE_COMPLETED or SOUNDS.GENERAL_ALERT_ERROR) end
    if HF.RefreshUI then HF.RefreshUI() end
end

local function StopCleanThenApplyAfterRemovalFailures(state)
    ClearActiveQueue(state)
    HF.runtime.ownedItems = {}
    HF.runtime.missingItems = {}
    HF.runtime.failedItems = {}
    HF.runtime.failedLayoutHouseId = state.houseId
    HF.runtime.failedLayoutName = state.layout and state.layout.name or nil
    HF.ui.lastApplySummary = {
        placed = 0,
        missing = 0,
        failed = 0,
        stateFailed = 0,
        statesRestored = 0,
        removed = state.removed or 0,
        removeFailed = state.removeFailed or 0,
        total = state.layoutTotal or 0,
        layoutName = state.layout and state.layout.name or "",
    }
    local recoveryText = state.recoveryLayoutName and string.format(" Recovery '%s' was kept.", state.recoveryLayoutName) or ""
    HF.Chat(string.format("Clean and apply stopped: %d removal(s) failed, so layout placement did not start.%s", state.removeFailed or 0, recoveryText))
    if PlaySound then PlaySound(SOUNDS.GENERAL_ALERT_ERROR) end
    if HF.RefreshUI then HF.RefreshUI() end
end

local function BeginApplyAfterClean(state)
    state.phase = "settling"
    state.pending = nil
    HF.runtime.applyQueue = state
    HF.Chat(string.format("Removal pass complete: %d confirmed, %d failed. Waiting for inventory to settle.", state.removed or 0, state.removeFailed or 0))
    if HF.RefreshUI then HF.RefreshUI() end
    ScheduleQueueCallback(state, function()
        if not EnsureQueueStillInStartingHouse(state) then return end
        state.itemIndex = HF.LayoutApplier.BuildItemIndex()
        state.knownFurnitureIds = BuildPlacedFurnitureIdSet()
        state.phase = "apply"
        state.index = 1
        HF.runtime.applyQueue = state
        HF.Chat("Inventory settled; starting layout placement.")
        StepPlacementQueue()
    end, GetCleanSettleDelayMs())
end

StepPlacementQueue = function()
    local state = activeQueue
    if not state or state.phase ~= "apply" or state.pending then return end
    if not EnsureQueueStillInStartingHouse(state) then return end
    if state.canceled then
        AbortQueue(state, "Apply queue canceled.")
        return
    end
    if state.paused then
        if HF.RefreshUI then HF.RefreshUI() end
        return
    end

    local item = state.items[state.index]
    if not item then
        FinishQueue(state)
        return
    end

    item.missingReason = nil
    item.failureReason = nil
    item.stateFailureReason = nil
    local pending = NewPendingRequest(state, "place", item)
    local success = false
    local result = nil
    if item.collectibleId and item.collectibleId ~= 0 then
        pending.source = "collectible"
        success, result = PlaceCollectible(item)
        if not success and ((item.itemId and item.itemId ~= 0) or (item.furnitureDataId and item.furnitureDataId ~= 0)) then
            pending.source = "item"
            success, result = PlaceItem(item, state.itemIndex, true, pending)
        end
    else
        pending.source = "item"
        success, result = PlaceItem(item, state.itemIndex, true, pending)
    end

    if activeQueue ~= state or state.pending ~= pending then return end
    if not success then
        RecordPlacementFailure(state, pending, result)
        return
    end

    pending.requestAccepted = true
    ScheduleQueueCallback(state, function()
        if state.pending ~= pending then return end
        if not EnsureQueueStillInStartingHouse(state) then return end
        local furnitureId = FindNewMatchingFurniture(state, item, pending.source)
        if furnitureId then
            CompleteObservedPlacement(state, pending, furnitureId)
        else
            RecordPlacementFailure(state, pending, "placement accepted but completion was not observed")
        end
    end, GetRequestAckTimeoutMs(), true)
end

StepRemovalQueue = function()
    local state = activeQueue
    if not state or state.phase ~= "clean" or state.pending then return end
    if not EnsureQueueStillInStartingHouse(state) then return end
    if state.canceled then
        AbortQueue(state, "Clean queue canceled.")
        return
    end
    if state.paused then
        if HF.RefreshUI then HF.RefreshUI() end
        return
    end

    local furnitureId = state.removeIds[state.removeIndex]
    if not furnitureId then
        if state.actionType == "cleanThenApply" then
            if (state.removeFailed or 0) > 0 then
                StopCleanThenApplyAfterRemovalFailures(state)
            else
                BeginApplyAfterClean(state)
            end
        else
            FinishCleanQueue(state)
        end
        return
    end

    local pending = NewPendingRequest(state, "remove", nil, furnitureId)
    local ok, result = pcall(HousingEditorRequestRemoveFurniture, furnitureId)
    if activeQueue ~= state or state.pending ~= pending then return end
    if not ok or result ~= HOUSING_REQUEST_RESULT_SUCCESS then
        CompleteRemovalAttempt(state, pending, false, ok and ("request rejected: " .. tostring(result)) or ("request error: " .. tostring(result)))
        return
    end

    pending.requestAccepted = true
    ScheduleQueueCallback(state, function()
        if state.pending ~= pending then return end
        if not EnsureQueueStillInStartingHouse(state) then return end
        CompleteRemovalAttempt(state, pending, not IsFurniturePlaced(furnitureId), "removal accepted but completion was not observed")
    end, GetRequestAckTimeoutMs(), true)
end

local function IsAnyHousingQueueActive()
    return activeQueue ~= nil
        or (HF.BlueprintTools and HF.BlueprintTools.IsBusy and HF.BlueprintTools.IsBusy())
end

local function StartApplyQueue(layout, mode, recoveryLayout)
    if IsAnyHousingQueueActive() then
        HF.Chat("A HousingForge apply, clean, or precision queue is already running.")
        return false
    end

    local removeIds = mode == "cleanapply" and HF.LayoutRecorder.GetAllPlacedFurnitureIds() or {}
    if mode == "cleanapply" and #removeIds > 0 and not recoveryLayout and IsRecoverySnapshotEnabled() then
        recoveryLayout = CreateRecoveryLayout("cleanThenApply", removeIds)
        if not recoveryLayout then return false end
    end

    local currentHouseId = GetCurrentZoneHouseId()
    local itemIndex = nil
    if mode ~= "cleanapply" then
        itemIndex = HF.LayoutApplier.BuildItemIndex()
    end
    activeQueue = {
        actionType = mode == "cleanapply" and "cleanThenApply" or "apply",
        phase = mode == "cleanapply" and "clean" or "apply",
        houseId = currentHouseId,
        layout = layout,
        items = layout.items or {},
        itemIndex = itemIndex,
        index = 1,
        processed = 0,
        layoutTotal = #(layout.items or {}),
        total = #removeIds + #(layout.items or {}),
        placed = {},
        placedFurnitureIds = {},
        missing = {},
        failed = {},
        stateFailures = {},
        statesRestored = 0,
        stateRestoreFailed = 0,
        paused = false,
        canceled = false,
        pending = nil,
        requestSerial = 0,
        removeIds = removeIds,
        removeIndex = 1,
        removed = 0,
        removeFailed = 0,
        removeFailures = {},
        knownFurnitureIds = mode == "cleanapply" and {} or BuildPlacedFurnitureIdSet(),
        recoveryLayoutId = recoveryLayout and recoveryLayout.id or nil,
        recoveryLayoutName = recoveryLayout and recoveryLayout.name or nil,
    }
    HF.runtime.applyQueue = activeQueue
    RegisterQueueEvents()
    local recoveryText = recoveryLayout and string.format(" Recovery: '%s'.", recoveryLayout.name or "saved") or ""
    HF.Chat(string.format("%s started: %d furniture step(s), %dms pacing.%s", activeQueue.actionType, activeQueue.total, GetHousingDelayMs(), recoveryText))
    if activeQueue.phase == "clean" then
        StepRemovalQueue()
    else
        StepPlacementQueue()
    end
    return true
end

function HF.LayoutApplier.ApplyLayout(layout)
    if not layout or not layout.items then
        HF.Chat("No layout selected.")
        return nil
    end
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 then
        HF.Chat("You must be inside a house to apply a layout.")
        return nil
    end
    if not IsOwnerOfCurrentHouse or not IsOwnerOfCurrentHouse() then
        HF.Chat("You must own this house to place furniture.")
        return nil
    end

    local mode = HF.GetApplyMode and HF.GetApplyMode() or "cleanapply"
    if mode == "preview" then
        HF.LayoutApplier.PreviewLayout(layout)
        return nil
    end

    local currentHouseId = GetCurrentZoneHouseId()
    local layoutHouseId = tonumber(layout.houseId) or 0
    if layoutHouseId ~= 0 and layoutHouseId ~= currentHouseId then
        HF.Chat(string.format("Apply refused: layout '%s' belongs to %s (house %d), but you are in %s (house %d).", layout.name or "Unnamed Layout", layout.houseName or "another house", layoutHouseId, HF.GetCurrentHouseName and HF.GetCurrentHouseName() or "the current house", currentHouseId))
        return nil
    end

    if StartApplyQueue(layout, mode == "owned" and "noclean" or mode) then
        HF.MissingItemMarkers.Clear()
    end
    return nil
end

function HF.LayoutApplier.CleanCurrentHouse()
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 then
        HF.Chat("You must be inside a house to clean it.")
        return 0
    end
    if not IsOwnerOfCurrentHouse or not IsOwnerOfCurrentHouse() then
        HF.Chat("You must own this house to remove furniture.")
        return 0
    end

    if IsAnyHousingQueueActive() then
        HF.Chat("A HousingForge apply, clean, or precision queue is already running.")
        return 0, 0
    end

    local removeIds = HF.LayoutRecorder.GetAllPlacedFurnitureIds()
    if #removeIds == 0 then
        HF.Chat("This house is already empty; there is nothing to clean.")
        return 0, 0
    end
    local recoveryLayout = nil
    if IsRecoverySnapshotEnabled() then
        recoveryLayout = CreateRecoveryLayout("clean", removeIds)
        if not recoveryLayout then return 0, 0 end
    end

    HF.MissingItemMarkers.Clear()
    activeQueue = {
        actionType = "clean",
        phase = "clean",
        houseId = GetCurrentZoneHouseId(),
        removeIds = removeIds,
        removeIndex = 1,
        removed = 0,
        removeFailed = 0,
        removeFailures = {},
        processed = 0,
        total = 0,
        paused = false,
        canceled = false,
        pending = nil,
        requestSerial = 0,
        knownFurnitureIds = BuildPlacedFurnitureIdSet(),
        recoveryLayoutId = recoveryLayout and recoveryLayout.id or nil,
        recoveryLayoutName = recoveryLayout and recoveryLayout.name or nil,
    }
    activeQueue.total = #activeQueue.removeIds
    HF.runtime.applyQueue = activeQueue
    RegisterQueueEvents()
    local recoveryText = recoveryLayout and string.format(" Recovery: '%s'.", recoveryLayout.name or "saved") or " Cleanup safety snapshot is disabled."
    HF.Chat(string.format("Clean started: %d item(s), %dms pacing.%s", activeQueue.total, GetHousingDelayMs(), recoveryText))
    StepRemovalQueue()
    return 0, 0
end

function HF.LayoutApplier.PreviewLayout(layout)
    if not layout then
        HF.Chat("No layout selected.")
        return nil
    end
    local preview = HF.LayoutApplier.BuildOwnedPreview(layout)
    HF.runtime.ownedPreview = preview
    HF.Chat(string.format("Preview '%s': %d owned, %d missing, %d unknown.", layout.name or "layout", preview.owned, preview.missing, preview.unknown))
    if HF.RefreshUI then HF.RefreshUI() end
    return preview
end

function HF.LayoutApplier.GetQueue()
    return activeQueue or (HF.runtime and HF.runtime.applyQueue) or nil
end

function HF.LayoutApplier.PauseQueue()
    local queue = HF.LayoutApplier.GetQueue()
    if not queue then HF.Chat("No apply/clean queue is running.") return false end
    queue.paused = true
    HF.runtime.applyQueue = queue
    HF.Chat("Housing queue paused.")
    if HF.RefreshUI then HF.RefreshUI() end
    return true
end

function HF.LayoutApplier.ResumeQueue()
    local queue = HF.LayoutApplier.GetQueue()
    if not queue then HF.Chat("No apply/clean queue is running.") return false end
    queue.paused = false
    activeQueue = queue
    HF.runtime.applyQueue = queue
    HF.Chat("Housing queue resumed.")
    if not queue.pending then
        if queue.phase == "clean" then
            StepRemovalQueue()
        elseif queue.phase == "apply" then
            StepPlacementQueue()
        end
    end
    return true
end

function HF.LayoutApplier.CancelQueue()
    local queue = HF.LayoutApplier.GetQueue()
    if not queue then HF.Chat("No apply/clean queue is running.") return false end
    local hadPendingRequest = queue.pending and queue.pending.requestAccepted
    if hadPendingRequest then
        queue.canceled = true
        queue.paused = false
        queue.phase = "canceling"
        HF.runtime.applyQueue = queue
        HF.Chat("Cancel requested. Waiting for the final accepted housing request to settle; no further requests will be sent.")
        if HF.RefreshUI then HF.RefreshUI() end
    else
        AbortQueue(queue, "Housing queue canceled.")
    end
    return true
end

function HF.LayoutApplier.RetryFailed()
    if IsAnyHousingQueueActive() then
        HF.Chat("A HousingForge apply, clean, or precision queue is already running.")
        return false
    end
    local queue = HF.LayoutApplier.GetQueue()
    local failed = queue and queue.failed or (HF.runtime and HF.runtime.failedItems) or {}
    if not failed or #failed == 0 then
        HF.Chat("No failed placements to retry.")
        return false
    end
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 or not IsOwnerOfCurrentHouse or not IsOwnerOfCurrentHouse() then
        HF.Chat("You must be inside a house you own to retry placements.")
        return false
    end
    local failedHouseId = HF.runtime and tonumber(HF.runtime.failedLayoutHouseId) or 0
    local currentHouseId = GetCurrentZoneHouseId()
    if failedHouseId and failedHouseId ~= 0 and failedHouseId ~= currentHouseId then
        HF.Chat(string.format("Retry refused: those failures belong to house %d, but you are in house %d.", failedHouseId, currentHouseId))
        return false
    end
    local layout = {
        name = "Retry Failed - " .. tostring(HF.runtime and HF.runtime.failedLayoutName or "Layout"),
        houseId = failedHouseId,
        items = failed,
    }
    return StartApplyQueue(layout, "noclean")
end
