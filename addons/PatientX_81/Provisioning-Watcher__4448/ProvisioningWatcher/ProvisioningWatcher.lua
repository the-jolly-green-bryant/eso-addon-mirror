local addonName = "ProvisioningWatcher"
local savedVarsName = "ProvisioningWatcherSavedVars"

ProvisioningWatcher = {}
ProvisioningWatcher.window = nil
ProvisioningWatcher.label = nil
ProvisioningWatcher.bg = nil
ProvisioningWatcher.dragBar = nil
ProvisioningWatcher.sv = nil
ProvisioningWatcher.flashState = false
ProvisioningWatcher.lastNoBuffSoundTime = 0

-------------------------------------------------
-- Font options
-------------------------------------------------

local FONT_OPTIONS = {
    [1] = "ZoFontGame",
    [2] = "ZoFontWinH1",
    [3] = "ZoFontHeader3",
}

-------------------------------------------------
-- Save / Restore Window Position
-------------------------------------------------

local function SavePosition()
    local left = ProvisioningWatcher.window:GetLeft()
    local top = ProvisioningWatcher.window:GetTop()

    ProvisioningWatcher.sv.left = left
    ProvisioningWatcher.sv.top = top
end

local function RestorePosition()
    ProvisioningWatcher.window:ClearAnchors()

    if ProvisioningWatcher.sv.left then
        ProvisioningWatcher.window:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            ProvisioningWatcher.sv.left,
            ProvisioningWatcher.sv.top
        )
    else
        ProvisioningWatcher.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
end

-------------------------------------------------
-- UI settings
-------------------------------------------------

local function ApplyBoxVisibility()
    if ProvisioningWatcher.bg then
        ProvisioningWatcher.bg:SetHidden(not ProvisioningWatcher.sv.showBox)
    end
end

local function ApplyFontSize()
    if ProvisioningWatcher.label then
        local fontName = FONT_OPTIONS[ProvisioningWatcher.sv.fontSize] or "ZoFontWinH1"
        ProvisioningWatcher.label:SetFont(fontName)
    end
end

-------------------------------------------------
-- Buff Detection
-------------------------------------------------

local function GetFoodRemaining()
    for i = 1, GetNumBuffs("player") do
        local buffName, startTime, endTime = GetUnitBuffInfo("player", i)

        if buffName then
            local duration = endTime - startTime
            local remaining = endTime - GetFrameTimeSeconds()

            if duration > 900 and remaining > 0 then
                return remaining
            end
        end
    end

    return nil
end

-------------------------------------------------
-- Update Display
-------------------------------------------------

local function UpdateLabel()
    local remaining = GetFoodRemaining()

    if remaining then
        ProvisioningWatcher.lastNoBuffSoundTime = 0

        if ProvisioningWatcher.sv.showOnlyWarning and remaining > 300 then
            ProvisioningWatcher.window:SetHidden(true)
            return
        end

        ProvisioningWatcher.window:SetHidden(false)

        local minutes = math.floor(remaining / 60)
        local seconds = math.floor(remaining % 60)

        ProvisioningWatcher.label:SetText(
            string.format("Provisioning: %02d:%02d", minutes, seconds)
        )

        if remaining <= 60 then
            ProvisioningWatcher.flashState = not ProvisioningWatcher.flashState

            if ProvisioningWatcher.flashState then
                ProvisioningWatcher.label:SetColor(1, 0, 0, 1)
            else
                ProvisioningWatcher.label:SetColor(1, 1, 1, 1)
            end
        elseif remaining <= 300 then
            ProvisioningWatcher.label:SetColor(1, 0, 0, 1)
        else
            ProvisioningWatcher.label:SetColor(0, 1, 0, 1)
        end

    else
        ProvisioningWatcher.window:SetHidden(false)
        ProvisioningWatcher.label:SetText("NO PROVISIONING BUFF")

        ProvisioningWatcher.flashState = not ProvisioningWatcher.flashState

        if ProvisioningWatcher.flashState then
            ProvisioningWatcher.label:SetColor(1, 0, 0, 1)
        else
            ProvisioningWatcher.label:SetColor(1, 1, 1, 1)
        end

        if ProvisioningWatcher.sv.soundEnabled then
            local now = GetFrameTimeSeconds()
            if ProvisioningWatcher.lastNoBuffSoundTime == 0 or (now - ProvisioningWatcher.lastNoBuffSoundTime) >= 10 then
                PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
                ProvisioningWatcher.lastNoBuffSoundTime = now
            end
        end
    end
end

-------------------------------------------------
-- Slash Commands
-------------------------------------------------

local function ToggleLock()
    ProvisioningWatcher.sv.locked = not ProvisioningWatcher.sv.locked

    if ProvisioningWatcher.sv.locked then
        ProvisioningWatcher.window:SetMovable(false)
        d("Provisioning Watcher locked")
    else
        ProvisioningWatcher.window:SetMovable(true)
        d("Provisioning Watcher unlocked")
    end
end

local function ToggleWarningMode()
    ProvisioningWatcher.sv.showOnlyWarning = not ProvisioningWatcher.sv.showOnlyWarning

    if ProvisioningWatcher.sv.showOnlyWarning then
        d("Provisioning Watcher warning mode ON")
    else
        d("Provisioning Watcher warning mode OFF")
    end

    UpdateLabel()
end

local function ToggleBox()
    ProvisioningWatcher.sv.showBox = not ProvisioningWatcher.sv.showBox
    ApplyBoxVisibility()

    if ProvisioningWatcher.sv.showBox then
        d("Provisioning Watcher box ON")
    else
        d("Provisioning Watcher box OFF")
    end
end

local function SetFontSize(sizeText)
    local size = tonumber(sizeText)

    if not size or not FONT_OPTIONS[size] then
        d("Usage: /pwfont 1, 2, or 3")
        return
    end

    ProvisioningWatcher.sv.fontSize = size
    ApplyFontSize()
    d("Provisioning Watcher font size set to " .. size)
end

local function ToggleSound()
    ProvisioningWatcher.sv.soundEnabled = not ProvisioningWatcher.sv.soundEnabled

    if ProvisioningWatcher.sv.soundEnabled then
        d("Provisioning Watcher sound ON")
    else
        d("Provisioning Watcher sound OFF")
    end
end

local function ShowHelp()
    d("Provisioning Watcher Commands:")
    d("/pwlock  - Lock or unlock the window")
    d("/pwwarn  - Show only at 5 minutes or less, or when no buff")
    d("/pwbox   - Toggle background box on or off")
    d("/pwfont 1, 2, or 3  - Change font size")
    d("/pwsound - Toggle no-buff reminder sound on or off")
    d("/pwhelp  - Show this help list")
end

-------------------------------------------------
-- UI Creation
-------------------------------------------------

local function CreateUI()
    ProvisioningWatcher.window = WINDOW_MANAGER:CreateTopLevelWindow("PW_MainWindow")
    ProvisioningWatcher.window:SetDimensions(420, 120)
    ProvisioningWatcher.window:SetMovable(true)
    ProvisioningWatcher.window:SetMouseEnabled(true)
    ProvisioningWatcher.window:SetClampedToScreen(true)

    ProvisioningWatcher.bg = WINDOW_MANAGER:CreateControl(nil, ProvisioningWatcher.window, CT_BACKDROP)
    ProvisioningWatcher.bg:SetAnchorFill(ProvisioningWatcher.window)
    ProvisioningWatcher.bg:SetCenterColor(0, 0, 0, 0.7)
    ProvisioningWatcher.bg:SetEdgeColor(1, 1, 0, 1)

    ProvisioningWatcher.dragBar = WINDOW_MANAGER:CreateControl(nil, ProvisioningWatcher.window, CT_BACKDROP)
    ProvisioningWatcher.dragBar:SetDimensions(420, 20)
    ProvisioningWatcher.dragBar:SetAnchor(TOP, ProvisioningWatcher.window, TOP)
    ProvisioningWatcher.dragBar:SetCenterColor(0.2, 0.2, 0.2, 0.8)

    ProvisioningWatcher.dragBar:SetHandler("OnMouseDown", function()
        if not ProvisioningWatcher.sv.locked then
            ProvisioningWatcher.window:StartMoving()
        end
    end)

    ProvisioningWatcher.dragBar:SetHandler("OnMouseUp", function()
        ProvisioningWatcher.window:StopMovingOrResizing()
        SavePosition()
    end)

    ProvisioningWatcher.label = WINDOW_MANAGER:CreateControl(nil, ProvisioningWatcher.window, CT_LABEL)
    ProvisioningWatcher.label:SetAnchor(CENTER, ProvisioningWatcher.window, CENTER, 0, 10)
end

-------------------------------------------------
-- Event
-------------------------------------------------

local function OnPlayerActivated()
    ProvisioningWatcher.sv = ZO_SavedVars:NewAccountWide(savedVarsName, 1, nil, {
        left = nil,
        top = nil,
        locked = false,
        showOnlyWarning = false,
        showBox = true,
        fontSize = 2,
        soundEnabled = true,
    })

    CreateUI()
    RestorePosition()
    ApplyBoxVisibility()
    ApplyFontSize()
    UpdateLabel()

    EVENT_MANAGER:RegisterForUpdate("PW_Update", 500, UpdateLabel)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

SLASH_COMMANDS["/pwlock"] = ToggleLock
SLASH_COMMANDS["/pwwarn"] = ToggleWarningMode
SLASH_COMMANDS["/pwbox"] = ToggleBox
SLASH_COMMANDS["/pwfont"] = SetFontSize
SLASH_COMMANDS["/pwsound"] = ToggleSound
SLASH_COMMANDS["/pwhelp"] = ShowHelp
