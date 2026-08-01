local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local ADDON_NAME = KRT.name

local DEFAULTS = {
    kal = {
        enabled = true,
        enableChat = true,
        actualLead = "",
        kickingPerson = "",
        kickDelay = 2,
        returnDelay = 2,
        kickMaxRetries = 5,
        returnMaxRetries = 5,
        kalPhase = 0, -- 0 idle, 1 waiting for drop, 2 waiting for rebuild/return
        knownAccounts = {},
    }
}

KRT.KAL = {
    id = "kal",
    defaults = DEFAULTS.kal,
}

local KALChoices = { "Select" }
local KALValues = { "" }

local POLL_UPDATE_NAME = ADDON_NAME .. "_KAL_Poll"

local state = {
    lastDifficultyKey = nil,
    isZoning = false,
    lastActivationTime = 0,

    kickPassTimer = nil,
    returnPassTimer = nil,

    preKickGroupSize = 0,
    expectedGroupSize = 0,
    lowestObservedGroupSize = 0,
    lastObservedGroupSize = -1,
    highWaterGroupSize = 0,
    lastSizeChangeMs = 0,
    polling = false,

    kickPassAttempts = 0,
    returnPassAttempts = 0,
}

local cachedSV = nil
local function SV()
    if cachedSV then return cachedSV end
    KRT.sv = KRT.sv or {}
    if not KRT.sv.kal then
        KRT.sv.kal = ZO_DeepTableCopy(DEFAULTS.kal)
    end

    if KRT.sv.kal.knownAccounts == nil then
        KRT.sv.kal.knownAccounts = {}
    end
    if KRT.sv.kal.kickMaxRetries == nil then
        KRT.sv.kal.kickMaxRetries = DEFAULTS.kal.kickMaxRetries
    end
    if KRT.sv.kal.returnMaxRetries == nil then
        KRT.sv.kal.returnMaxRetries = DEFAULTS.kal.returnMaxRetries
    end

    cachedSV = KRT.sv.kal
    return KRT.sv.kal
end

local function Lower(value)
    return string.lower(value or "")
end

local Now = GetGameTimeMilliseconds

local function Notice(msg)
    if SV().enableChat then
        d("[Kwibus AutoLeadPass] " .. tostring(msg))
    end
end

local function ClearTimer(timerId)
    if timerId then
        zo_removeCallLater(timerId)
    end
    return nil
end

local function StopPolling()
    if state.polling then
        EM:UnregisterForUpdate(POLL_UPDATE_NAME)
        state.polling = false
    end
end

local function StartPolling(pollFunc)
    if state.polling then
        return
    end
    state.polling = true
    EM:RegisterForUpdate(POLL_UPDATE_NAME, 1000, pollFunc)
end

local function ClearAllTimers()
    state.kickPassTimer = ClearTimer(state.kickPassTimer)
    state.returnPassTimer = ClearTimer(state.returnPassTimer)
end

local function ResetWorkflow()
    ClearAllTimers()
    StopPolling()

    SV().kalPhase = 0
    state.preKickGroupSize = 0
    state.expectedGroupSize = 0
    state.lowestObservedGroupSize = 0
    state.lastObservedGroupSize = -1
    state.lastSizeChangeMs = 0
    state.returnPassAttempts = 0
end

local function UpdateObservedGroupSize(currentSize)
    currentSize = currentSize or (GetGroupSize() or 0)

    if currentSize > state.highWaterGroupSize then
        state.highWaterGroupSize = currentSize
    end

    if currentSize ~= state.lastObservedGroupSize then
        state.lastObservedGroupSize = currentSize
        state.lastSizeChangeMs = Now()
    end
end

local function GetDifficultyKey()
    if IsGroupUsingVeteranDifficulty ~= nil then
        return IsGroupUsingVeteranDifficulty() and 2 or 1
    end
    return nil
end

local function OnPlayerDeactivated()
    state.isZoning = true
end

local function OnPlayerActivated()
    state.isZoning = false
    state.lastActivationTime = Now()
end

local function RememberAccount(name)
    if not name or name == "" then
        return
    end
    SV().knownAccounts[name] = true
end

local function RefreshDropdownControl(control)
    if not control then
        return
    end

    if control.UpdateChoices then
        control:UpdateChoices(KALChoices, KALValues)
    end

    if control.UpdateValue then
        control:UpdateValue(false)
    end
end

local function RebuildGroupRosterChoices()
    ZO_ClearTable(KALChoices)
    ZO_ClearTable(KALValues)

    table.insert(KALChoices, "Select")
    table.insert(KALValues, "")

    local added = {}
    local sv = SV()
    local gs = GetGroupSize() or 0

    for i = 1, gs do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and DoesUnitExist(unitTag) then
            local acc = GetUnitDisplayName(unitTag) or ""
            if acc ~= "" and not added[acc] then
                table.insert(KALChoices, acc)
                table.insert(KALValues, acc)
                added[acc] = true
            end
        end
    end

    local savedNames = {}
    for acc, flag in pairs(sv.knownAccounts) do
        if flag and acc ~= "" and not added[acc] then
            table.insert(savedNames, acc)
        end
    end
    table.sort(savedNames)

    for _, acc in ipairs(savedNames) do
        table.insert(KALChoices, acc .. " (Saved)")
        table.insert(KALValues, acc)
        added[acc] = true
    end

    if sv.kickingPerson and sv.kickingPerson ~= "" and not added[sv.kickingPerson] then
        table.insert(KALChoices, sv.kickingPerson .. " (Saved)")
        table.insert(KALValues, sv.kickingPerson)
        added[sv.kickingPerson] = true
    end

    if sv.actualLead and sv.actualLead ~= "" and not added[sv.actualLead] then
        table.insert(KALChoices, sv.actualLead .. " (Saved)")
        table.insert(KALValues, sv.actualLead)
        added[sv.actualLead] = true
    end

    RefreshDropdownControl(KRT_KAL_Kicker_Dropdown)
    RefreshDropdownControl(KRT_KAL_Lead_Dropdown)
end

local function FindGroupUnitTagByName(targetName)
    if not targetName or targetName == "" then
        return nil
    end

    local targetLower = Lower(targetName)

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local accName = Lower(GetUnitDisplayName(unitTag) or "")
            if accName == targetLower then
                return unitTag
            end

            local rawCharName = GetUnitName(unitTag) or ""
            local charName = Lower(zo_strformat("<<1>>", rawCharName))
            if charName == targetLower then
                return unitTag
            end
        end
    end

    return nil
end

local function PassLeadTo(targetName)
    if not IsUnitGroupLeader("player") then
        return false, "I am not the group leader"
    end

    if not targetName or targetName == "" then
        return false, "Target name is empty"
    end

    local unitTag = FindGroupUnitTagByName(targetName)
    if not unitTag then
        return false, "Target not found in current group"
    end

    GroupPromote(unitTag)
    return true, nil
end

local function IsLocalPlayerConfiguredKicker()
    local kicker = SV().kickingPerson or ""
    return kicker ~= "" and Lower(kicker) == Lower(GetDisplayName() or "")
end

local function ArmPhase(phase, targetSize, observedSize)
    ClearAllTimers()

    SV().kalPhase = phase
    state.preKickGroupSize = targetSize
    state.expectedGroupSize = targetSize
    state.lowestObservedGroupSize = observedSize
    state.lastObservedGroupSize = observedSize
    state.lastSizeChangeMs = Now()
    state.returnPassAttempts = 0
end

local PollWorkflow

local function EnsureLocalKickerWorkflow()
    if not SV().enabled then
        return
    end

    if (SV().kalPhase or 0) ~= 0 then
        return
    end

    if not IsUnitGroupLeader("player") then
        return
    end

    if not IsLocalPlayerConfiguredKicker() then
        return
    end

    local actualLead = SV().actualLead or ""
    if actualLead == "" then
        return
    end

    local currentSize = GetGroupSize() or 0
    UpdateObservedGroupSize(currentSize)

    ArmPhase(1, currentSize, currentSize)
    StartPolling(PollWorkflow)
end

local function ScheduleKickPass(delayMs, kicker)
    if state.kickPassTimer then
        return
    end

    state.kickPassAttempts = state.kickPassAttempts or 0

    state.kickPassTimer = zo_callLater(function()
        state.kickPassTimer = nil

        if not SV().enabled then
            return
        end

        local ok = PassLeadTo(kicker)
        if ok then
            Notice("Passed lead to Kicking Person: " .. tostring(kicker))
            state.kickPassAttempts = 0
            return
        end

        state.kickPassAttempts = state.kickPassAttempts + 1
        local maxRetries = SV().kickMaxRetries or 5

        if state.kickPassAttempts >= maxRetries then
            Notice("Could not pass lead to Kicking Person (" .. tostring(kicker) .. ") after " .. tostring(maxRetries) .. " attempts. Giving up.")
            state.kickPassAttempts = 0
            return
        end

        ScheduleKickPass(1000, kicker)
    end, delayMs)
end

local function ScheduleReturnPass(delayMs)
    if state.returnPassTimer then
        return
    end

    state.returnPassTimer = zo_callLater(function()
        state.returnPassTimer = nil

        local phase = SV().kalPhase or 0
        local currentSize = GetGroupSize() or 0
        local requiredSize = state.preKickGroupSize or 0

        if not SV().enabled or phase ~= 2 then
            return
        end

        -- Strictly require reaching or exceeding the pre-kick group size
        if requiredSize == 0 or currentSize < requiredSize then
            return
        end

        local actualLead = SV().actualLead or ""
        if actualLead == "" then
            return
        end

        if Lower(actualLead) == Lower(GetDisplayName() or "") then
            ResetWorkflow()
            return
        end

        local ok = PassLeadTo(actualLead)
        if ok then
            Notice("Passed lead back to Actual Lead: " .. tostring(actualLead))
            ResetWorkflow()
            return
        end

        state.returnPassAttempts = state.returnPassAttempts + 1
        local maxRetries = SV().returnMaxRetries or 5

        if state.returnPassAttempts >= maxRetries then
            Notice("Could not pass lead back to Actual Lead (" .. tostring(actualLead) .. ") after " .. tostring(maxRetries) .. " attempts. Giving up.")
            ResetWorkflow()
            return
        end

        ScheduleReturnPass(1000)
    end, delayMs)
end

PollWorkflow = function()
    if not SV().enabled then
        StopPolling()
        return
    end

    EnsureLocalKickerWorkflow()

    local phase = SV().kalPhase or 0
    if phase == 0 then
        StopPolling()
        return
    end

    local currentSize = GetGroupSize() or 0
    UpdateObservedGroupSize(currentSize)

    if phase == 1 then
        if state.preKickGroupSize > 0 and currentSize < state.preKickGroupSize then
            state.lowestObservedGroupSize = currentSize
            SV().kalPhase = 2
            state.returnPassAttempts = 0
        end
        return
    end

    if phase == 2 then
        if state.lowestObservedGroupSize == 0 or currentSize < state.lowestObservedGroupSize then
            state.lowestObservedGroupSize = currentSize
        end

        if state.preKickGroupSize > 0 and currentSize >= state.preKickGroupSize then
            ScheduleReturnPass((SV().returnDelay or 2) * 1000)
        else
            state.returnPassTimer = ClearTimer(state.returnPassTimer)
        end
    end
end

local function CheckGroupState()
    local currentSize = GetGroupSize() or 0
    UpdateObservedGroupSize(currentSize)

    EnsureLocalKickerWorkflow()

    if (SV().kalPhase or 0) ~= 0 then
        StartPolling(PollWorkflow)
        PollWorkflow()
    end
end

local function OnDifficultyChanged()
    if not SV().enabled then
        return
    end

    local currentSize = GetGroupSize() or 0
    if currentSize <= 1 then
        return
    end

    local newKey = GetDifficultyKey()
    if newKey == nil then
        return
    end

    if state.isZoning or (Now() - state.lastActivationTime < 2500) then
        state.lastDifficultyKey = newKey
        return
    end

    if state.lastDifficultyKey == nil then
        state.lastDifficultyKey = newKey
        return
    end

    if newKey == state.lastDifficultyKey then
        return
    end

    state.lastDifficultyKey = newKey
    UpdateObservedGroupSize(currentSize)

    -- Capture exact group count BEFORE kicks/re-invites begin
    state.preKickGroupSize = currentSize

    if IsLocalPlayerConfiguredKicker() then
        ArmPhase(1, currentSize, currentSize)
        StartPolling(PollWorkflow)
        PollWorkflow()
        return
    end

    local kicker = SV().kickingPerson or ""
    if kicker == "" then
        return
    end

    if not IsUnitGroupLeader("player") then
        return
    end

    state.kickPassAttempts = 0
    ScheduleKickPass((SV().kickDelay or 2) * 1000, kicker)
end

function KRT.KAL:Initialize()
    SV()
    ResetWorkflow()
    state.lastDifficultyKey = GetDifficultyKey()
    UpdateObservedGroupSize(GetGroupSize() or 0)

    zo_callLater(function()
        EnsureLocalKickerWorkflow()
    end, 1500)

    EM:RegisterForEvent(ADDON_NAME .. "_KAL_Deactivated", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
    EM:RegisterForEvent(ADDON_NAME .. "_KAL_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    EM:RegisterForEvent(ADDON_NAME .. "_KAL_VetChanged", EVENT_VETERAN_DIFFICULTY_CHANGED, OnDifficultyChanged)
    EM:RegisterForEvent(ADDON_NAME .. "_KAL_Joined", EVENT_GROUP_MEMBER_JOINED, CheckGroupState)
    EM:RegisterForEvent(ADDON_NAME .. "_KAL_Left", EVENT_GROUP_MEMBER_LEFT, CheckGroupState)
    EM:RegisterForEvent(ADDON_NAME .. "_KAL_Leader", EVENT_LEADER_UPDATE, CheckGroupState)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel and panel.GetName and panel:GetName() == ADDON_NAME .. "_Panel" then
            RebuildGroupRosterChoices()
        end
    end)

    RebuildGroupRosterChoices()
end

function KRT.KAL:GetLAMSubmenu()
    return {
        type = "submenu",
        name = "Kwibus Auto Lead Pass",
        controls = {
            {
                type = "checkbox",
                name = "Enable Auto Pass",
                tooltip = "Enable the automated lead passing workflow.",
                getFunc = function()
                    return SV().enabled
                end,
                setFunc = function(value)
                    SV().enabled = value
                    if not value then
                        ResetWorkflow()
                    else
                        EnsureLocalKickerWorkflow()
                    end
                end,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Enable Chat Notifications",
                tooltip = "Show lead-pass messages in chat.",
                getFunc = function()
                    return SV().enableChat
                end,
                setFunc = function(value)
                    SV().enableChat = value
                end,
                width = "full",
                default = true,
                disabled = function()
                    return not SV().enabled
                end,
            },
            {
                type = "dropdown",
                name = "Kicking Person (Pick from group or saved)",
                tooltip = "Who should receive lead after difficulty changes? Saves AccountName.",
                choices = KALChoices,
                choicesValues = KALValues,
                getFunc = function()
                    return SV().kickingPerson or ""
                end,
                setFunc = function(value)
                    if value and value ~= "" then
                        SV().kickingPerson = value
                        RememberAccount(value)
                        RebuildGroupRosterChoices()
                        EnsureLocalKickerWorkflow()
                    end
                end,
                reference = "KRT_KAL_Kicker_Dropdown",
                width = "full",
                disabled = function()
                    return not SV().enabled
                end,
            },
            {
                type = "slider",
                name = "Delay: Pass to Kicker",
                tooltip = "Seconds to wait after difficulty change before passing lead to the kicker.",
                min = 1,
                max = 10,
                step = 1,
                getFunc = function()
                    return SV().kickDelay
                end,
                setFunc = function(value)
                    SV().kickDelay = value
                end,
                width = "full",
                disabled = function()
                    return not SV().enabled
                end,
            },
            {
                type = "slider",
                name = "Retries: Pass to Kicker",
                tooltip = "How many times to attempt passing lead to the kicker if they are not found.",
                min = 1,
                max = 20,
                step = 1,
                getFunc = function()
                    return SV().kickMaxRetries
                end,
                setFunc = function(value)
                    SV().kickMaxRetries = value
                end,
                width = "full",
                disabled = function()
                    return not SV().enabled
                end,
            },
            {
                type = "dropdown",
                name = "Actual Lead (Pick from group or saved)",
                tooltip = "Who should receive lead back after reinvites/rebuild? Saves AccountName.",
                choices = KALChoices,
                choicesValues = KALValues,
                getFunc = function()
                    return SV().actualLead or ""
                end,
                setFunc = function(value)
                    if value and value ~= "" then
                        SV().actualLead = value
                        RememberAccount(value)
                        RebuildGroupRosterChoices()
                        EnsureLocalKickerWorkflow()
                    end
                end,
                reference = "KRT_KAL_Lead_Dropdown",
                width = "full",
                disabled = function()
                    return not SV().enabled
                end,
            },
            {
                type = "slider",
                name = "Delay: Return to Lead",
                tooltip = "Seconds to wait after rebuild before returning lead.",
                min = 1,
                max = 10,
                step = 1,
                getFunc = function()
                    return SV().returnDelay
                end,
                setFunc = function(value)
                    SV().returnDelay = value
                end,
                width = "full",
                disabled = function()
                    return not SV().enabled
                end,
            },
            {
                type = "slider",
                name = "Retries: Return to Lead",
                tooltip = "How many times to attempt returning lead if the actual lead is not found.",
                min = 1,
                max = 20,
                step = 1,
                getFunc = function()
                    return SV().returnMaxRetries
                end,
                setFunc = function(value)
                    SV().returnMaxRetries = value
                end,
                width = "full",
                disabled = function()
                    return not SV().enabled
                end,
            },
            {
                type = "description",
                text = "Both kicking player and actual lead need to have addon installed. Then actual lead auto-passes you lead once instance in reset, and when kicking player did the spaulder kicks - lead is auto passed to actual lead",
                width = "full",
            },
        }
    }
end

KRT:RegisterModule(KRT.KAL)