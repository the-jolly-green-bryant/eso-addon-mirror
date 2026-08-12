local ADDON_NAME = "VeterancyBar"
local bg
local VeterancyBar = {
    window = nil,
    bar = nil,
    label = nil,
    savedVars = nil,
    version = "1.5.0",
}

VeterancyBar.defaults = {
    x = 200,
    y = 200,
    isLocked = false,
    onlyInPvp = true,
    progressColor = {
        R = 1,
        G = 1,
        B = 0,
        A = 1
    },
    bgColor = {
        R = 1,
        G = 1,
        B = 1,
        A = 1
    },
    fontColor = {
        R = 0.05,
        G = 0.05,
        B = 0.05,
        A = 1
    }
}
------------------------------------------------------------
-- Get current veterancy data
------------------------------------------------------------

local function GetVeterancyProgress()
    local trackType = REWARD_TRACK_TYPE_AVA_VETERANCY
    local trackId = GetActiveReferenceTrackIdsForRewardTrackType(trackType)

    if not trackId then
        return 0, 100, 0
    end

    local trackIndex = GetReferenceTrackIndex(trackType, trackId)

    if not trackIndex then
        return 0, 100, 0
    end

    local _, rank, progress = GetInfoForRewardTrack(trackType, trackIndex)

    local total = GetTotalProgressAtRewardTrackTier(
        GetRewardTrackIdFromReferenceTrackId(trackType, trackId),
        rank
    )

    return progress, (total and total > 0) and total or 100, rank
end

------------------------------------------------------------
-- Update
------------------------------------------------------------

function VeterancyBar.Update()
    local current, max, rank = GetVeterancyProgress()

    VeterancyBar.bar:SetMinMax(0, max)
    VeterancyBar.bar:SetValue(current)

    if rank >= 100 then
        VeterancyBar.label:SetText("Vet Max Rank")
    else
        VeterancyBar.label:SetText(string.format("Vet %d  %d%%", rank, math.floor(current / max * 100))
    )
    end
end

------------------------------------------------------------
-- UI
------------------------------------------------------------

function VeterancyBar.CreateUI()
    local wm = WINDOW_MANAGER

    VeterancyBar.window = wm:CreateTopLevelWindow("VeterancyBarWindow")
    VeterancyBar.window:SetDimensions(260, 25)

    VeterancyBar.window:ClearAnchors()
    VeterancyBar.window:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        VeterancyBar.savedVars.x,
        VeterancyBar.savedVars.y
    )

    VeterancyBar.window:SetMovable(true)
    VeterancyBar.window:SetClampedToScreen(true)

    --------------------------------------------------------
    -- Background
    --------------------------------------------------------

    bg = wm:CreateControl(nil, VeterancyBar.window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(r,g,b,a)

    --------------------------------------------------------
    -- Progress bar
    --------------------------------------------------------

    VeterancyBar.bar = wm:CreateControl(nil, VeterancyBar.window, CT_STATUSBAR)
    VeterancyBar.bar:SetAnchorFill()
    VeterancyBar.bar:SetColor(r,g,b,a)

    --------------------------------------------------------
    -- Label
    --------------------------------------------------------

    VeterancyBar.label = wm:CreateControl(nil, VeterancyBar.window, CT_LABEL)
    VeterancyBar.label:SetAnchor(CENTER, VeterancyBar.window, CENTER)
    VeterancyBar.label:SetFont("ZoFontGameMedium")
    VeterancyBar.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    VeterancyBar.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    VeterancyBar.label:SetColor(r,g,b,a)

    --------------------------------------------------------
    -- Drag control
    --------------------------------------------------------

    local dragger = wm:CreateControl(nil, VeterancyBar.window, CT_CONTROL)
    dragger:SetAnchorFill()
    dragger:SetMouseEnabled(true)

    dragger:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            VeterancyBar.window:StartMoving()
        end
    end)

    dragger:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            VeterancyBar.window:StopMovingOrResizing()

            VeterancyBar.savedVars.x = VeterancyBar.window:GetLeft()
            VeterancyBar.savedVars.y = VeterancyBar.window:GetTop()
        end
    end)
end

--Set Window Lock
function VeterancyBar:SetWindowLock(shouldLock)
    VeterancyBar.savedVars.isLocked = shouldLock
    local canMove = not shouldLock
    
    -- Target your specific TopLevelControl
    if VeterancyBarWindow then
        VeterancyBarWindow:SetMovable(canMove)
        VeterancyBarWindow:SetMouseEnabled(canMove)
    end
end

function VeterancyBar:ToggleLock()
    VeterancyBar:SetWindowLock(not VeterancyBar.savedVars.isLocked)
end

--Show or Hide the Window based on PvP status and user preference
function VeterancyBar:UpdateWindowVisibility()
    if not VeterancyBarWindow then return end 

    local onlyInPvp = false
    if VeterancyBar.savedVars and VeterancyBar.savedVars.onlyInPvp then
        onlyInPvp = true
    end

    if onlyInPvp then
        local isInPvp = IsPlayerInAvAWorld() or IsActiveWorldBattleground()
        VeterancyBarWindow:SetHidden(not isInPvp)
    else
        VeterancyBarWindow:SetHidden(false) 
    end
end 

-- Event binding for transition tracking
function VeterancyBar:OnZoneChanged(eventCode)
    VeterancyBar:UpdateWindowVisibility()
end

-- Apply Progress Bar Color
function VeterancyBar:ApplyBarColor()
    if VeterancyBar.bar then
        VeterancyBar.bar:SetColor(
            VeterancyBar.savedVars.progressColor.R,
            VeterancyBar.savedVars.progressColor.G,
            VeterancyBar.savedVars.progressColor.B,
            VeterancyBar.savedVars.progressColor.A
        )
        local current = VeterancyBar.bar:GetValue()
        VeterancyBar.bar:SetValue(current)
    end
end

function VeterancyBar:UpdateBackgroundColor()
    if not bg then return end
    bg:SetCenterColor(VeterancyBar.savedVars.bgColor.R, VeterancyBar.savedVars.bgColor.G, VeterancyBar.savedVars.bgColor.B, VeterancyBar.savedVars.bgColor.A)
end

-- Apply Font Color
function VeterancyBar:ApplyFontColor()
    if VeterancyBar.label then
        VeterancyBar.label:SetColor(
            VeterancyBar.savedVars.fontColor.R,
            VeterancyBar.savedVars.fontColor.G,
            VeterancyBar.savedVars.fontColor.B,
            VeterancyBar.savedVars.fontColor.A
        )
    end
end

function VeterancyBar:UpdateFontColor()
    if not VeterancyBar.label then return end
    VeterancyBar.label:SetColor(VeterancyBar.savedVars.fontColor.R, VeterancyBar.savedVars.fontColor.G, VeterancyBar.savedVars.fontColor.B, VeterancyBar.savedVars.fontColor.A)
end

function VeterancyBar:Initialize()
    VeterancyBar:UpdateBackgroundColor(
                VeterancyBar.savedVars.bgColor.R, 
                VeterancyBar.savedVars.bgColor.G, 
                VeterancyBar.savedVars.bgColor.B,
                VeterancyBar.savedVars.bgColor.A
                )
    VeterancyBar:ApplyBarColor(
                VeterancyBar.savedVars.progressColor.R, 
                VeterancyBar.savedVars.progressColor.G, 
                VeterancyBar.savedVars.progressColor.B, 
                VeterancyBar.savedVars.progressColor.A
                )
    VeterancyBar:ApplyFontColor(
                VeterancyBar.savedVars.fontColor.R,
                VeterancyBar.savedVars.fontColor.G,
                VeterancyBar.savedVars.fontColor.B,
                VeterancyBar.savedVars.fontColor.A
                )
    EVENT_MANAGER:RegisterForEvent("VeterancyBar_Event", EVENT_PLAYER_ACTIVATED, function(eventCode)
        VeterancyBar:OnZoneChanged(eventCode)
    end)
    VeterancyBar:SetWindowLock(VeterancyBar.savedVars.isLocked)
end

-- Settings Panel
function initializeVeterancyBarOptions()

    local panelName = "VeterancyBarOptions"

    local panelData = {
        type = "panel",
		name = "Veterancy Bar",
        displayName = "|c2046e5Veterancy Bar|r",
        author = "Noxenrom, Settings by:|c2046e5s|r|c403cccs|r|c6032b2h|r|c802898o|r|c9f1e7eg|r|cbf1465r|r|cdf0a4bi|r|cff0031n|r",
        version = VeterancyBar.version,
        registerForRefresh = true,
    }

    local optionsTable = {
    [1] = {
        type = "checkbox",
        name = "Lock Window Position",
        tooltip = "Check this to lock the window in place to prevent moving it with the mouse.",
        getFunc = function() return VeterancyBar.savedVars.isLocked end,
        setFunc = function(value) VeterancyBar:SetWindowLock(value) end,
        },
    [2] = {
         type = "checkbox",
            name = "Only Display Window in PvP Zones",
            tooltip = "When enabled, this window automatically vanishes unless you are in Cyrodiil, Imperial City, or Battlegrounds.",
            getFunc = function() return VeterancyBar.savedVars.onlyInPvp end,
            setFunc = function(value) 
                VeterancyBar.savedVars.onlyInPvp = value
                VeterancyBar:UpdateWindowVisibility() -- Immediately update UI when checked/unchecked
            end,
        },
    [3] = {
        type = "colorpicker",
        name = "Progress Bar Color",
        tooltip = "Select the color for the progress bar.",
        getFunc = function() 
            return VeterancyBar.savedVars.progressColor.R, VeterancyBar.savedVars.progressColor.G, VeterancyBar.savedVars.progressColor.B, VeterancyBar.savedVars.progressColor.A 
        end,
        setFunc = function(r, g, b, a)
            VeterancyBar.savedVars.progressColor.R = r
            VeterancyBar.savedVars.progressColor.G = g
            VeterancyBar.savedVars.progressColor.B = b
            VeterancyBar.savedVars.progressColor.A = a
            VeterancyBar:ApplyBarColor() 
        end
        },
    [4] = {
        type = "colorpicker",
        name = "Background Bar Color",
        tooltip = "Select the color for the background.",
        getFunc = function() 
            return VeterancyBar.savedVars.bgColor.R, VeterancyBar.savedVars.bgColor.G, VeterancyBar.savedVars.bgColor.B, VeterancyBar.savedVars.bgColor.A 
        end,
        setFunc = function(r, g, b, a) 
            VeterancyBar.savedVars.bgColor.R = r
            VeterancyBar.savedVars.bgColor.G = g
            VeterancyBar.savedVars.bgColor.B = b
            VeterancyBar.savedVars.bgColor.A = a
            VeterancyBar:UpdateBackgroundColor()
        end,
        },
    [5] = {
        type = "colorpicker",
        name = "Font Color",
        tooltip = "Select the color for the Font.",
        getFunc = function() 
            return VeterancyBar.savedVars.fontColor.R, VeterancyBar.savedVars.fontColor.G, VeterancyBar.savedVars.fontColor.B, VeterancyBar.savedVars.fontColor.A 
        end,
        setFunc = function(r, g, b, a)
            VeterancyBar.savedVars.fontColor.R = r
            VeterancyBar.savedVars.fontColor.G = g
            VeterancyBar.savedVars.fontColor.B = b
            VeterancyBar.savedVars.fontColor.A = a
            VeterancyBar:UpdateFontColor() 
        end
        }, 
    }

    local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end

------------------------------------------------------------
-- Events
------------------------------------------------------------

local function RefreshAfterActivation()
    VeterancyBar.Update()

    zo_callLater(VeterancyBar.Update, 500)
    zo_callLater(VeterancyBar.Update, 1500)
end

local function OnRewardTrackProgress(_, trackType)
    if trackType == REWARD_TRACK_TYPE_AVA_VETERANCY then
        VeterancyBar.Update()
    end
end

local function OnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    VeterancyBar.savedVars = ZO_SavedVars:NewAccountWide("VeterancyBarSavedVariables", 1, nil, VeterancyBar.defaults)

    initializeVeterancyBarOptions()
    VeterancyBar.CreateUI()
    VeterancyBar.Update()
    VeterancyBar:Initialize()
    

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_REWARD_TRACK_PROGRESS_GAINED, OnRewardTrackProgress)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, RefreshAfterActivation)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)