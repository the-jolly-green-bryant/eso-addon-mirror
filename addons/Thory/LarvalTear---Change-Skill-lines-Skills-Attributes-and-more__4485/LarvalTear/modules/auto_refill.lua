local Addon = LarvalTearMod
local AutoRefill = Addon.Modules.AutoRefill
local Log = Addon.Common.Log
local FoodHelper = Addon.Modules.FoodHelper
local QuickslotFetch = Addon.Modules.QuickslotFetch
local QuickslotProfiles = Addon.Modules.QuickslotProfiles

local AUTO_REFILL_EVENT_NAME = "LTM_AutoRefill"
local AUTO_REFILL_UPDATE_NAME = "LTM_AutoRefillBankMonitor"
local AUTO_REFILL_MONITOR_INTERVAL_MS = 1000
local AUTO_REFILL_OPEN_RETRY_DELAY_MS = 250
local AUTO_REFILL_OPEN_RETRY_MAX_ATTEMPTS = 6
local AUTO_REFILL_SCENES = {
    "bank",
    "houseBank",
}
local FETCH_MODE_MISSING = "missing"
local FETCH_MODE_REFILL_MAX = "refill_max"

local state = {
    bankOpen = false,
    nextRunId = 0,
    currentRunId = nil,
    quickSlotDone = false,
    quickSlotRunning = false,
    foodHelperDone = false,
    notifiedQuickSlot = false,
    notifiedFoodHelper = false,
    openAttemptGeneration = 0,
    sourceBankingBag = nil,
    openSources = {},
    summaryFlushed = false,
    sessionBankingBag = nil,
    quickslotStatus = "pending",
    quickslotReason = nil,
    quickslotFetchedItems = 0,
    foodStatus = "pending",
    foodReason = nil,
    foodFetchedItems = 0,
}

local function Debug(...)
    Log.LogDebugSummary(...)
end

local function DebugMonitor(status)
    Debug("Auto Refill monitor", "status=" .. tostring(status))
end

local function IsNoSourceReason(reason, summary)
    if reason == "no_fetchable_items" or reason == "fetch_source_missing" then
        return true
    end

    return reason == "refill_partial" and (tonumber(type(summary) == "table" and summary.fetchedItems or 0) or 0) <= 0
end

local function ResetSessionSummary()
    state.summaryFlushed = false
    state.sessionBankingBag = nil
    state.quickslotStatus = "pending"
    state.quickslotReason = nil
    state.quickslotFetchedItems = 0
    state.foodStatus = "pending"
    state.foodReason = nil
    state.foodFetchedItems = 0
end

local function BuildTargetSummary(status, reason)
    status = type(status) == "string" and status ~= "" and status or "pending"
    return status .. ":" .. tostring(reason or "unknown")
end

local function IsSessionSummaryComplete()
    return state.quickslotStatus ~= "pending" and state.foodStatus ~= "pending"
end

local function TryFlushSessionSummary(flushReason, force)
    if state.summaryFlushed == true then
        return
    end
    if state.currentRunId == nil and state.bankOpen ~= true then
        return
    end
    if force ~= true and not IsSessionSummaryComplete() then
        return
    end

    if force == true then
        if state.quickslotStatus == "pending" and state.quickslotReason == nil then
            state.quickslotReason = flushReason
        end
        if state.foodStatus == "pending" and state.foodReason == nil then
            state.foodReason = flushReason
        end
    end

    state.summaryFlushed = true
    Debug(
        "Auto Refill session summary",
        "runId=" .. tostring(state.currentRunId),
        "flush=" .. tostring(flushReason or "complete"),
        "bankingBag=" .. tostring(state.sessionBankingBag or state.sourceBankingBag),
        "sources=" .. tostring(table.concat(state.openSources or {}, ",")),
        "quickslot=" .. BuildTargetSummary(state.quickslotStatus, state.quickslotReason),
        "quickslotFetchedItems=" .. tostring(tonumber(state.quickslotFetchedItems) or 0),
        "food=" .. BuildTargetSummary(state.foodStatus, state.foodReason),
        "foodFetchedItems=" .. tostring(tonumber(state.foodFetchedItems) or 0),
        "totalFetchedItems=" .. tostring((tonumber(state.quickslotFetchedItems) or 0) + (tonumber(state.foodFetchedItems) or 0))
    )
end

local function RecordTargetSkipped(target, reason)
    if target == "quickslot" then
        state.quickslotStatus = "skipped"
        state.quickslotReason = reason
        state.quickslotFetchedItems = 0
    elseif target == "food" then
        state.foodStatus = "skipped"
        state.foodReason = reason
        state.foodFetchedItems = 0
    end
    TryFlushSessionSummary("complete", false)
end

local function RecordTargetResult(target, success, reason, summary)
    local status = "done"
    if success ~= true then
        if IsNoSourceReason(reason, summary) then
            status = "skipped"
        else
            status = "failed"
        end
    elseif IsNoSourceReason(reason, summary) then
        status = "skipped"
    end

    local fetchedItems = tonumber(type(summary) == "table" and summary.fetchedItems or 0) or 0
    if target == "quickslot" then
        state.quickslotStatus = status
        state.quickslotReason = reason
        state.quickslotFetchedItems = fetchedItems
    elseif target == "food" then
        state.foodStatus = status
        state.foodReason = reason
        state.foodFetchedItems = fetchedItems
    end
    TryFlushSessionSummary("complete", false)
end

local function WriteChat(stringIdName, params)
    Log.WriteChat(Addon.GetStringText(stringIdName, params))
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

local function GetCurrentFetchBag()
    local sourceBankingBag = tonumber(state.sourceBankingBag)
    if sourceBankingBag ~= nil and IsSupportedFetchBag(sourceBankingBag) then
        return sourceBankingBag, nil
    end

    if type(GetBankingBag) ~= "function" then
        return nil, "get_banking_bag_unavailable"
    end

    local bankingBag = GetBankingBag()
    if type(bankingBag) ~= "number" or not IsSupportedFetchBag(bankingBag) then
        return nil, "banking_bag_unsupported"
    end

    return bankingBag, nil
end

local function IsBankOpenSafe()
    if type(IsBankOpen) ~= "function" or IsBankOpen() ~= true then
        return false, "bank_closed"
    end

    local bankingBag, err = GetCurrentFetchBag()
    if type(bankingBag) ~= "number" then
        return false, err
    end

    return true, nil, bankingBag
end

local function IsInCombat()
    return type(IsUnitInCombat) == "function" and IsUnitInCombat("player") == true
end

local function AppendOpenSource(source)
    if type(source) ~= "string" or source == "" then
        return
    end

    state.openSources = state.openSources or {}
    for _, existing in ipairs(state.openSources) do
        if existing == source then
            return
        end
    end
    state.openSources[#state.openSources + 1] = source
end

local function NotifyQuickSlotNoItemsOnce()
    if state.notifiedQuickSlot == true then
        return
    end

    state.notifiedQuickSlot = true
    WriteChat("SI_LTM_AUTO_REFILL_QUICKSLOT_NO_ITEMS")
end

local function NotifyFoodNoItemsOnce()
    if state.notifiedFoodHelper == true then
        return
    end

    state.notifiedFoodHelper = true
    WriteChat("SI_LTM_AUTO_REFILL_FOOD_NO_ITEMS")
end

local function NotifyQuickSlotFailedOnce(reason)
    if state.notifiedQuickSlot == true then
        return
    end

    state.notifiedQuickSlot = true
    WriteChat("SI_LTM_AUTO_REFILL_QUICKSLOT_FAILED", {
        reason = Log.LocalizeErrorReason(reason),
    })
end

local function NotifyFoodFailedOnce(reason)
    if state.notifiedFoodHelper == true then
        return
    end

    state.notifiedFoodHelper = true
    WriteChat("SI_LTM_AUTO_REFILL_FOOD_FAILED", {
        reason = Log.LocalizeErrorReason(reason),
    })
end

local function RefreshQuickSlotsIfVisible()
    Addon:NotifyQuickSlotsChanged("auto_refill")
end

local function HandleQuickSlotFetchResult(success, reason, summary)
    if success ~= true then
        if IsNoSourceReason(reason, summary) then
            NotifyQuickSlotNoItemsOnce()
        else
            NotifyQuickSlotFailedOnce(reason)
        end
    elseif IsNoSourceReason(reason, summary) then
        NotifyQuickSlotNoItemsOnce()
    end

    RecordTargetResult("quickslot", success == true, reason, summary)
    RefreshQuickSlotsIfVisible()
end

local function HandleFoodFetchResult(success, reason, summary)
    if success ~= true then
        if IsNoSourceReason(reason, summary) then
            NotifyFoodNoItemsOnce()
        else
            NotifyFoodFailedOnce(reason)
        end
    elseif IsNoSourceReason(reason, summary) then
        NotifyFoodNoItemsOnce()
    end

    RecordTargetResult("food", success == true, reason, summary)
end

local function BeginFetch(profile, mode, completion)
    return QuickslotFetch:BeginFetch(profile, {
        mode = mode,
        preferLowCondition = type(Addon.savedVars) == "table" and Addon.savedVars.quickslotFetchPreferLowCondition == true,
        sourceBankingBag = state.sourceBankingBag,
    }, completion)
end

local function RunQuickSlotMissingFallback(profile, onDone, runId)
    local ok, err, summary = BeginFetch(profile, FETCH_MODE_MISSING, function(success, completionErr, completionSummary)
        if runId ~= nil and state.currentRunId ~= runId then
            return
        end
        HandleQuickSlotFetchResult(success, completionErr, completionSummary)
        onDone()
    end)

    if ok == true and err == "deferred" then
        return
    end

    HandleQuickSlotFetchResult(ok == true, err, summary)
    onDone()
end

local function RunFoodMissingFallback(profile, onDone, runId)
    local ok, err, summary = BeginFetch(profile, FETCH_MODE_MISSING, function(success, completionErr, completionSummary)
        if runId ~= nil and state.currentRunId ~= runId then
            return
        end
        HandleFoodFetchResult(success, completionErr, completionSummary)
        onDone()
    end)

    if ok == true and err == "deferred" then
        return
    end

    HandleFoodFetchResult(ok == true, err, summary)
    onDone()
end

local function GetActiveFoodCard()
    for _, card in ipairs(FoodHelper:GetCardList() or {}) do
        if type(card) == "table" and card.isActive == true then
            return card
        end
    end

    return nil
end

local function BuildFoodProfile(card)
    local itemId = tonumber(type(card) == "table" and card.itemId or nil)
    if itemId == nil then
        return nil
    end

    return {
        id = "auto_refill_food",
        displayName = card.name or card.itemLink or tostring(itemId),
        slotCount = 1,
        slots = {
            [1] = {
                slotIndex = 1,
                actionType = rawget(_G, "ACTION_TYPE_ITEM"),
                itemId = itemId,
                itemLink = card.itemLink,
                name = card.name,
                icon = card.icon,
                savedCount = tonumber(card.backpackCount) or 0,
            },
        },
    }
end

function AutoRefill:BeginRun()
    state.nextRunId = state.nextRunId + 1
    state.currentRunId = state.nextRunId
    state.quickSlotDone = false
    state.quickSlotRunning = false
    state.foodHelperDone = false
    state.notifiedQuickSlot = false
    state.notifiedFoodHelper = false
    ResetSessionSummary()
end

function AutoRefill:ResetRun()
    if state.bankOpen == true or state.currentRunId ~= nil then
        TryFlushSessionSummary("bank_close", true)
    end

    state.bankOpen = false
    state.currentRunId = nil
    state.quickSlotDone = false
    state.quickSlotRunning = false
    state.foodHelperDone = false
    state.notifiedQuickSlot = false
    state.notifiedFoodHelper = false
    state.sourceBankingBag = nil
    state.openSources = {}
    state.openAttemptGeneration = state.openAttemptGeneration + 1
    ResetSessionSummary()
end

function AutoRefill:RunFoodHelperAutoRefill()
    if state.foodHelperDone == true then
        return
    end
    state.foodHelperDone = true

    if Addon:IsAutoRefillFoodHelperEnabled() ~= true then
        RecordTargetSkipped("food", "setting_off")
        return
    end
    if IsInCombat() then
        RecordTargetSkipped("food", "combat")
        return
    end
    if QuickslotFetch:IsBusy() == true then
        RecordTargetSkipped("food", "fetch_busy")
        return
    end

    local card = GetActiveFoodCard()
    if type(card) ~= "table" then
        RecordTargetSkipped("food", "active_card_missing")
        return
    end

    local profile = BuildFoodProfile(card)
    if type(profile) ~= "table" then
        RecordTargetSkipped("food", "food_profile_invalid")
        return
    end

    local mode = (tonumber(card.backpackCount) or 0) > 0 and FETCH_MODE_REFILL_MAX or FETCH_MODE_MISSING
    local runId = state.currentRunId
    local ok, err, summary = BeginFetch(profile, mode, function(success, completionErr, completionSummary)
        if state.currentRunId ~= runId then
            return
        end
        HandleFoodFetchResult(success, completionErr, completionSummary)
    end)

    if ok == true and err == "deferred" then
        return
    end

    if ok == true and err == "no_refill_targets" and mode == FETCH_MODE_REFILL_MAX then
        RunFoodMissingFallback(profile, function()
        end, runId)
        return
    end

    HandleFoodFetchResult(ok == true, err, summary)
end

function AutoRefill:RunQuickSlotAutoRefill(onDone)
    if state.quickSlotDone == true then
        if state.quickSlotRunning ~= true and type(onDone) == "function" then
            onDone()
        end
        return
    end
    state.quickSlotDone = true

    local function Finish()
        state.quickSlotRunning = false
        if state.bankOpen == true and type(onDone) == "function" then
            onDone()
        end
    end

    if Addon:IsAutoRefillQuickSlotEnabled() ~= true then
        RecordTargetSkipped("quickslot", "setting_off")
        Finish()
        return
    end
    if IsInCombat() then
        RecordTargetSkipped("quickslot", "combat")
        Finish()
        return
    end
    if QuickslotFetch:IsBusy() == true then
        RecordTargetSkipped("quickslot", "fetch_busy")
        Finish()
        return
    end

    local profile = QuickslotProfiles:GetActiveProfile()
    if type(profile) ~= "table" then
        RecordTargetSkipped("quickslot", "active_profile_missing")
        Finish()
        return
    end

    state.quickSlotRunning = true
    local runId = state.currentRunId
    local ok, err, summary = BeginFetch(profile, FETCH_MODE_REFILL_MAX, function(success, completionErr, completionSummary)
        if state.currentRunId ~= runId then
            return
        end
        HandleQuickSlotFetchResult(success, completionErr, completionSummary)
        Finish()
    end)

    if ok == true and err == "deferred" then
        return
    end

    if ok == true and err == "no_refill_targets" then
        RunQuickSlotMissingFallback(profile, Finish, runId)
        return
    end

    HandleQuickSlotFetchResult(ok == true, err, summary)
    Finish()
end

function AutoRefill:TryRunAutoRefillOnBankOpen(bankBag)
    bankBag = tonumber(bankBag)
    if bankBag ~= nil and IsSupportedFetchBag(bankBag) then
        state.sourceBankingBag = bankBag
    end

    local isOpen, reason, bankingBag = IsBankOpenSafe()
    if not isOpen then
        Debug("Auto Refill bank open skipped", "reason=" .. tostring(reason))
        return
    end

    if state.bankOpen ~= true then
        state.bankOpen = true
        self:BeginRun()
        state.sessionBankingBag = bankingBag
        Debug(
            "Auto Refill bank open summary",
            "bankingBag=" .. tostring(bankingBag),
            "runId=" .. tostring(state.currentRunId),
            "sources=" .. tostring(table.concat(state.openSources or {}, ","))
        )
    end

    if state.quickSlotDone == true and state.foodHelperDone == true then
        return
    end

    self:RunQuickSlotAutoRefill(function()
        AutoRefill:RunFoodHelperAutoRefill()
    end)
end

function AutoRefill:OnBankStateMaybeChanged()
    if IsBankOpenSafe() then
        self:TryRunAutoRefillOnBankOpen()
        return
    end

    if state.bankOpen == true then
        self:ResetRun()
    end
end

function AutoRefill:ScheduleBankOpenAttempt(attempt, generation, bankBag, source)
    attempt = tonumber(attempt) or 1
    generation = tonumber(generation) or state.openAttemptGeneration
    bankBag = tonumber(bankBag)
    AppendOpenSource(source)
    if bankBag ~= nil and IsSupportedFetchBag(bankBag) then
        state.sourceBankingBag = bankBag
    end

    if generation ~= state.openAttemptGeneration or state.bankOpen == true then
        return
    end

    local isOpen = IsBankOpenSafe()
    if isOpen then
        self:TryRunAutoRefillOnBankOpen(bankBag)
        return
    end

    if attempt >= AUTO_REFILL_OPEN_RETRY_MAX_ATTEMPTS or type(zo_callLater) ~= "function" then
        state.openSources = {}
        return
    end

    zo_callLater(function()
        AutoRefill:ScheduleBankOpenAttempt(attempt + 1, generation, bankBag, source)
    end, AUTO_REFILL_OPEN_RETRY_DELAY_MS)
end

function AutoRefill:RegisterEvents()
    if self.eventsRegistered == true then
        return
    end
    if type(EVENT_MANAGER) ~= "table" or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return
    end

    self.eventsRegistered = true
    EVENT_MANAGER:RegisterForUpdate(AUTO_REFILL_UPDATE_NAME, AUTO_REFILL_MONITOR_INTERVAL_MS, function()
        AutoRefill:OnBankStateMaybeChanged()
    end)
    if type(EVENT_MANAGER.RegisterForEvent) == "function" and rawget(_G, "EVENT_OPEN_BANK") ~= nil then
        EVENT_MANAGER:RegisterForEvent(AUTO_REFILL_EVENT_NAME .. "_OpenBank", EVENT_OPEN_BANK, function(_, bankBag)
            AutoRefill:ScheduleBankOpenAttempt(1, state.openAttemptGeneration, bankBag, "event_open_bank")
        end)
    end
    if type(EVENT_MANAGER.RegisterForEvent) == "function" and rawget(_G, "EVENT_CLOSE_BANK") ~= nil then
        EVENT_MANAGER:RegisterForEvent(AUTO_REFILL_EVENT_NAME .. "_CloseBank", EVENT_CLOSE_BANK, function()
            AutoRefill:ResetRun()
        end)
    end
end

function AutoRefill:RegisterSceneCallbacks()
    if self.scenesRegistered == true or type(SCENE_MANAGER) ~= "table" or type(SCENE_MANAGER.GetScene) ~= "function" then
        return
    end

    self.scenesRegistered = true
    for _, sceneName in ipairs(AUTO_REFILL_SCENES) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if type(scene) == "table" and type(scene.RegisterCallback) == "function" then
            scene:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                    AutoRefill:ScheduleBankOpenAttempt(
                        1,
                        state.openAttemptGeneration,
                        nil,
                        "scene_" .. tostring(sceneName) .. "_" .. tostring(newState)
                    )
                elseif newState == SCENE_HIDDEN then
                    AutoRefill:ResetRun()
                end
            end)
        else
            Debug("Auto Refill bank scene unavailable", "scene=" .. tostring(sceneName))
        end
    end
end

function AutoRefill:Initialize()
    self:RegisterEvents()
    self:RegisterSceneCallbacks()
    DebugMonitor("initialized")
end
