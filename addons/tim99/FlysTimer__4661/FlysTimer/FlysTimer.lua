local ADDON_NAME = "FlysTimer"

local TT = {}

TT.window = nil
TT.label = nil
TT.endTime = 0
TT.updateName = ADDON_NAME .. "Update"
TT.sv = nil
TT.warningPlayed = false
TT.lastTickSecond = nil

local defaults = {
    timerSeconds = 300,
    warningSeconds = 90,
    windowLeft = nil,
    windowTop = nil,
}

ZO_CreateStringId("SI_BINDING_NAME_FLYSTIMER_START_TIMER", "Start Timer")

local function FormatSeconds(seconds)
    seconds = math.max(0, math.floor(seconds))

    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60

    return string.format("%d:%02d", minutes, secs)
end

local function ParseTimerInput(input)
    input = tostring(input or ""):match("^%s*(.-)%s*$")

    if input == "" then
        return nil
    end

    local minutes, seconds = input:match("^(%d+):(%d%d?)$")
    if minutes then
        minutes = tonumber(minutes)
        seconds = tonumber(seconds)

        if seconds >= 60 then
            return nil
        end

        return minutes * 60 + seconds
    end

    local raw = input:match("^(%d+)$")
    if raw then
        if #raw <= 2 then
            return tonumber(raw)
        end

        minutes = tonumber(raw:sub(1, -3))
        seconds = tonumber(raw:sub(-2))

        if seconds >= 60 then
            return nil
        end

        return minutes * 60 + seconds
    end

    return nil
end

local function PrintRed(message)
    d("|cFF0000" .. message .. "|r")
end

function TT.SaveWindowPosition()
    if not TT.window or not TT.sv then
        return
    end

    TT.sv.windowLeft = TT.window:GetLeft()
    TT.sv.windowTop = TT.window:GetTop()
end

function TT.CreateWindow()
    local wm = WINDOW_MANAGER

    TT.window = wm:CreateTopLevelWindow("FlysTimerWindow")
    TT.window:SetDimensions(180, 60)
    TT.window:SetMovable(true)
    TT.window:SetMouseEnabled(true)
    TT.window:SetClampedToScreen(true)
    TT.window:SetHidden(true)

    if TT.sv.windowLeft and TT.sv.windowTop then
        TT.window:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            TT.sv.windowLeft,
            TT.sv.windowTop
        )
    else
        TT.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    end

    TT.window:SetHandler("OnMoveStop", TT.SaveWindowPosition)

    local bg = wm:CreateControl("$(parent)Background", TT.window, CT_BACKDROP)
    bg:SetAnchorFill(TT.window)
    bg:SetCenterColor(0, 0, 0, 0.75)
    bg:SetEdgeColor(1, 1, 1, 0.35)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    TT.label = wm:CreateControl("$(parent)Label", TT.window, CT_LABEL)
    TT.label:SetAnchor(CENTER, TT.window, CENTER, 0, 0)
    TT.label:SetFont("ZoFontWinH2")
    TT.label:SetColor(1, 1, 1, 1)
    TT.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

function TT.StopTimer(showMessage)
    EVENT_MANAGER:UnregisterForUpdate(TT.updateName)

    if TT.window then
        TT.window:SetHidden(true)
    end

    TT.label:SetColor(1, 1, 1, 1)

    if showMessage then
        PrintRed(FormatSeconds(TT.sv.timerSeconds) ..
            " timer finished at " .. GetTimeString())
    end

    TT.endTime = 0
    TT.warningPlayed = false
    TT.lastTickSecond = nil
end

function TT.UpdateTimer()
    local remaining = math.ceil(TT.endTime - GetFrameTimeSeconds())

    if remaining <= 0 then
        TT.StopTimer(true)
        return
    end

    TT.label:SetText(FormatSeconds(remaining))

    if TT.sv.warningSeconds > 0
        and not TT.warningPlayed
        and remaining <= TT.sv.warningSeconds then

        TT.warningPlayed = true
        PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    end

    if remaining <= 5 then
        TT.label:SetColor(1, 0, 0, 1)

        if TT.lastTickSecond ~= remaining then
            TT.lastTickSecond = remaining
            PlaySound(SOUNDS.COUNTDOWN_WARNING)
        end
    else
        TT.label:SetColor(1, 1, 1, 1)
    end
end

function TT.StartTimer()
    if not TT.sv.timerSeconds or TT.sv.timerSeconds <= 0 then
        d("|cFF6666Please set a timer first using /timer 530 or /timer 5:30.|r")
        return
    end

    TT.warningPlayed = false
    TT.lastTickSecond = nil

    TT.endTime = GetFrameTimeSeconds() + TT.sv.timerSeconds

    TT.label:SetText(FormatSeconds(TT.sv.timerSeconds))
    TT.label:SetColor(1, 1, 1, 1)
    TT.window:SetHidden(false)

    EVENT_MANAGER:UnregisterForUpdate(TT.updateName)
    EVENT_MANAGER:RegisterForUpdate(TT.updateName, 1000, TT.UpdateTimer)
end

function TT.TimerSlashCommand(args)
    local seconds = ParseTimerInput(args)

    if not seconds or seconds <= 0 then
        d("|cFF6666Usage: /timer 530 or /timer 5:30|r")
        return
    end

    TT.sv.timerSeconds = seconds

    d("|c9B30FFTimer duration set to "
        .. FormatSeconds(seconds) .. ".|r")
end

function TT.SoundSlashCommand(args)
    local seconds = ParseTimerInput(args)

    if not seconds or seconds <= 0 then
        d("|cFF6666Usage: /timerton 90 or /timerton 1:30|r")
        return
    end

    TT.sv.warningSeconds = seconds

    d("|c9B30FFWarning sound set to "
        .. FormatSeconds(seconds)
        .. " remaining time.|r")
end

function FlysTimer_StartTimerFromKeybind()
    TT.StartTimer()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    TT.sv = ZO_SavedVars:NewAccountWide(
        "FlysTimer_SavedVariables",
        1,
        nil,
        defaults
    )

    TT.CreateWindow()

    SLASH_COMMANDS["/timer"] = TT.TimerSlashCommand
    SLASH_COMMANDS["/timerton"] = TT.SoundSlashCommand
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)