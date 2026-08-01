local ACTIVITY_FINDER_PLUS = ACTIVITY_FINDER_PLUS

local readyCheckNotificationActive = false
local finderActionButtonKeys = { "checkPledges", "checkSets", "checkSkillQuests" }

local function IsBusyActivityFinderStatus(statusCode)
    return statusCode == ACTIVITY_FINDER_STATUS_QUEUED
        or statusCode == ACTIVITY_FINDER_STATUS_IN_PROGRESS
        or statusCode == ACTIVITY_FINDER_STATUS_FORMING_GROUP
        or statusCode == ACTIVITY_FINDER_STATUS_READY_CHECK
end

local function ForEachFinderActionButton(callback)
    for _, key in ipairs(finderActionButtonKeys) do
        local state = ACTIVITY_FINDER_PLUS[key]
        local button = state and state.button
        if button then
            callback(state, button)
        end
    end
end

local function ReadyCheckStillVisible()
    return readyCheckNotificationActive and HasLFGReadyCheckNotification()
end

local function PlayReadyCheckSound()
    PlaySound(SOUNDS.QUEST_SHARE_SENT)
    PlaySound(SOUNDS.QUEST_SHARE_SENT)
end

local function LoopSoundNotification()
    if not ReadyCheckStillVisible() then return end

    PlayReadyCheckSound()
    zo_callLater(function() PlaySound(SOUNDS.QUEST_STEP_FAILED) end, 333)
    zo_callLater(LoopSoundNotification, ACTIVITY_FINDER_PLUS.NotifyDelay * 1000)
end

local function LoopScreenNotification(messageText)
    if not ReadyCheckStillVisible() then return end

    ACTIVITY_FINDER_PLUS.printCenter(messageText)
    zo_callLater(function() LoopScreenNotification(messageText) end, 5000)
end

local function RefreshFinderActionButtons(statusCode)
    local isBusy = IsBusyActivityFinderStatus(statusCode)
    ForEachFinderActionButton(function(state, button)
        if isBusy then
            if ACTIVITY_FINDER_PLUS.perfectPixelCompat then
                button:SetHidden(true)
            else
                button:SetState(BSTATE_DISABLED)
                state.state = BSTATE_DISABLED
            end
        else
            button:SetState(BSTATE_NORMAL)
            state.state = BSTATE_NORMAL
        end
    end)
end

local function RefreshPerfectPixelButtonVisibility(statusCode)
    if not ACTIVITY_FINDER_PLUS.perfectPixelCompat then return end

    local shouldHide = not ACTIVITY_FINDER_PLUS.showSpecificDung or statusCode == ACTIVITY_FINDER_STATUS_QUEUED
    ForEachFinderActionButton(function(_, button)
        button:SetHidden(shouldHide)
    end)
end

local function RefreshActivityFinderChrome(statusCode)
    if ACTIVITY_FINDER_PLUS.EnhanceGAF then
        RefreshFinderActionButtons(statusCode)
    end
    RefreshPerfectPixelButtonVisibility(statusCode)
end

local function StopReadyCheckNotifications()
    readyCheckNotificationActive = false
end

local function StartReadyCheckNotifications()
    if readyCheckNotificationActive then return end

    readyCheckNotificationActive = true
    if ACTIVITY_FINDER_PLUS.AutoAccept then
        if ACTIVITY_FINDER_PLUS.ScreenNotify then
            ACTIVITY_FINDER_PLUS.print(GetString(SI_ACTIVITY_FINDER_PLUS_LFG_CHAT_A))
            ACTIVITY_FINDER_PLUS.printCenter(GetString(SI_ACTIVITY_FINDER_PLUS_LFG_SCREEN))
        end
        if ACTIVITY_FINDER_PLUS.SoundNotify then
            PlayReadyCheckSound()
        end
        zo_callLater(AcceptLFGReadyCheckNotification, 3000)
    else
        if ACTIVITY_FINDER_PLUS.ScreenNotify then
            ACTIVITY_FINDER_PLUS.print(GetString(SI_ACTIVITY_FINDER_PLUS_LFG_CHAT))
            LoopScreenNotification(GetString(SI_ACTIVITY_FINDER_PLUS_LFG_SCREEN))
        end
        if ACTIVITY_FINDER_PLUS.SoundNotify then
            LoopSoundNotification()
        end
    end
end

function ACTIVITY_FINDER_PLUS.OnActivityFinderStatusUpdate(_, statusCode)
    if ACTIVITY_FINDER_PLUS.activityFinderCode == statusCode then
        if statusCode == ACTIVITY_FINDER_STATUS_READY_CHECK and not HasLFGReadyCheckNotification() then
            StopReadyCheckNotifications()
        end
        return
    end

    ACTIVITY_FINDER_PLUS.activityFinderCode = statusCode
    RefreshActivityFinderChrome(statusCode)
    ACTIVITY_FINDER_PLUS.RefreshGamepadQuickSelectKeybind()

    if statusCode ~= ACTIVITY_FINDER_STATUS_READY_CHECK or not HasLFGReadyCheckNotification() then
        StopReadyCheckNotifications()
        return
    end

    StartReadyCheckNotifications()
end

function ACTIVITY_FINDER_PLUS.OnCooldownsUpdate()
    for cooldownType, _ in pairs(ACTIVITY_FINDER_PLUS.coolDownStatus) do
        ACTIVITY_FINDER_PLUS.coolDownStatus[cooldownType] = GetLFGCooldownTimeRemainingSeconds(cooldownType) > 0
    end
end
