-- NORTimer.lua — Stopwatch & Countdown Timer for NOR Guild Tools

local Addon = NORGuildTools
Addon.Timer = Addon.Timer or {}
local T = Addon.Timer

T.window = nil
T.label = nil

local startTime, timerRunning, elapsedPausedTime, countdownTime = nil, false, 0, nil

------------------------------------------------------------
-- Create the Timer Window
------------------------------------------------------------
function T:CreateWindow()
    if self.window then return end

    local window = WINDOW_MANAGER:CreateTopLevelWindow("NORGuildTools_TimerWindow")
    self.window = window

    window:SetDimensions(280, 190)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(true)

    -- Logo
    local logo = WINDOW_MANAGER:CreateControl("NORGuildTools_TimerLogo", window, CT_TEXTURE)
    logo:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 10)
    logo:SetDimensions(50, 50)
    logo:SetTexture("NORGuildTools/Textures/norlogodds.dds")

    -- Background
    local backdrop = WINDOW_MANAGER:CreateControl("NORGuildTools_TimerBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0, 0, 0, 0.5)
    backdrop:SetDrawLayer(DL_BACKGROUND)

    -- Close Button
    local closeButton = WINDOW_MANAGER:CreateControlFromVirtual(
        "NORGuildTools_TimerCloseButton",
        window,
        "ZO_CloseButton"
    )
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -5, 5)
    closeButton:SetHandler("OnClicked", function() window:SetHidden(true) end)

    -- Title
    local title = WINDOW_MANAGER:CreateControl("NORGuildTools_TimerTitle", window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 15)
    title:SetFont("ZoFontGameShadow")
    title:SetText("Time Machine")
    title:SetScale(1.2)
    title:SetColor(0, 0.6, 1, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Timer Label
    T.label = WINDOW_MANAGER:CreateControl("NORGuildTools_TimerLabel", window, CT_LABEL)
    T.label:SetAnchor(TOP, window, TOP, 0, 50)
    T.label:SetFont("ZoFontGameLargeBold")
    T.label:SetText("00:00.00")
    T.label:SetColor(0, 1, 0, 1)
    T.label:SetScale(2.0)

    -- Buttons
    local startButton = WINDOW_MANAGER:CreateControlFromVirtual(
        "NORGuildTools_TimerStartButton",
        window,
        "ZO_DefaultButton"
    )
    startButton:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 10, -45)
    startButton:SetDimensions(80, 35)
    startButton:SetText("Start")
    startButton:SetHandler("OnClicked", function() T.StartTimer() end)

    local stopButton = WINDOW_MANAGER:CreateControlFromVirtual(
        "NORGuildTools_TimerStopButton",
        window,
        "ZO_DefaultButton"
    )
    stopButton:SetAnchor(BOTTOM, window, BOTTOM, 0, -45)
    stopButton:SetDimensions(80, 35)
    stopButton:SetText("Stop")
    stopButton:SetHandler("OnClicked", function() T.StopTimer() end)

    local resetButton = WINDOW_MANAGER:CreateControlFromVirtual(
        "NORGuildTools_TimerResetButton",
        window,
        "ZO_DefaultButton"
    )
    resetButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -45)
    resetButton:SetDimensions(80, 35)
    resetButton:SetText("Reset")
    resetButton:SetHandler("OnClicked", function() T.ResetTimer() end)

    -- Footer
    local footer = WINDOW_MANAGER:CreateControl("NORGuildTools_TimerFooter", window, CT_LABEL)
    footer:SetAnchor(BOTTOM, window, BOTTOM, 0, -10)
    footer:SetFont("ZoFontGameSmall")
    footer:SetText("Good things come to those who wait.")
    footer:SetColor(0.7, 0.7, 0.7, 1)
    footer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

------------------------------------------------------------
-- Timer Update Logic
------------------------------------------------------------
function T.UpdateTimer()
    if timerRunning and T.label then
        local elapsed = GetFrameTimeSeconds() - startTime + elapsedPausedTime
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
        local hundredths = math.floor((elapsed % 1) * 100)

        if seconds == 0 and hundredths == 0 then
            PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
        end

        T.label:SetText(string.format("%02d:%02d.%02d", minutes, seconds, hundredths))

        if countdownTime then
            local timeRemaining = countdownTime * 60 - elapsed
            local remainingMin = math.floor(timeRemaining / 60)
            local remainingSec = math.floor(timeRemaining % 60)

            if timeRemaining == 1 then
                PlaySound(SOUNDS.DEFER_ACCEPTED)
            end

            if timeRemaining <= 0 then
                T.ResetTimer()
                return
            end

            T.label:SetText(string.format("%02d:%02d.%02d", remainingMin, remainingSec, hundredths))

            if timeRemaining <= 10 then
                T.label:SetColor(1, 0, 0, 1)
            end
        end
    end
end

------------------------------------------------------------
-- Start / Stop / Reset
------------------------------------------------------------
function T.StartTimer(countdown)
    if not timerRunning then
        startTime = GetFrameTimeSeconds()
        timerRunning = true
        countdownTime = countdown
        EVENT_MANAGER:RegisterForUpdate("NORGuildTools_TimerUpdate", 10, T.UpdateTimer)
    end
end

function T.StopTimer()
    if timerRunning then
        elapsedPausedTime = elapsedPausedTime + (GetFrameTimeSeconds() - startTime)
        timerRunning = false
        EVENT_MANAGER:UnregisterForUpdate("NORGuildTools_TimerUpdate")
    end
end

function T.ResetTimer()
    timerRunning = false
    elapsedPausedTime = 0
    startTime = nil
    countdownTime = nil

    if T.label then
        T.label:SetText("00:00.00")
        T.label:SetColor(0, 1, 0, 1)
    end

    EVENT_MANAGER:UnregisterForUpdate("NORGuildTools_TimerUpdate")
end

------------------------------------------------------------
-- Slash Commands
------------------------------------------------------------
SLASH_COMMANDS["/timemachine"] = function()
    if not T.window then
        T:CreateWindow()
    end

    T.window:SetHidden(not T.window:IsHidden())
    SCENE_MANAGER:SetInUIMode(not T.window:IsHidden())

    CHAT_SYSTEM:AddMessage("|t20:20:NORGuildTools/Textures/norlogodds.dds|t |c00C0FFUse /countdown <minutes> to set a countdown timer.|r")
end

SLASH_COMMANDS["/countdown"] = function(time)
    local min = tonumber(time)
    if min then
        if not T.window then
            T:CreateWindow()
        end

        T.window:SetHidden(false)
        SCENE_MANAGER:SetInUIMode(true)
        T.StartTimer(min)

        CHAT_SYSTEM:AddMessage("|t20:20:NORGuildTools/Textures/norlogodds.dds|t |c00C0FFUse /timemachine to toggle the timer window.|r")
    end
end

------------------------------------------------------------
-- Initialize on AddOn Loaded
------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent("NORGuildTools_TimerInit", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == Addon.name then
        T:CreateWindow()
    end
end)
