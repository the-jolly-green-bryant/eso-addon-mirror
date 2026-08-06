local ADDON_NAME = "VeterancyBar"

local VeterancyBar = {
    window = nil,
    bar = nil,
    label = nil,
    savedVars = nil,
}

------------------------------------------------------------
-- NEW: Convert HEX color to ESO RGB values
------------------------------------------------------------

local function HexToRGB(hex)
    if not hex then
        return nil
    end

    -- Remove spaces and #
    hex = string.gsub(hex, "%s+", "")
    hex = string.gsub(hex, "#", "")

    -- Force uppercase
    hex = string.upper(hex)

    if string.len(hex) ~= 6 then
        return nil
    end

    local r = tonumber(string.sub(hex, 1, 2), 16)
    local g = tonumber(string.sub(hex, 3, 4), 16)
    local b = tonumber(string.sub(hex, 5, 6), 16)

    if not r or not g or not b then
        return nil
    end

    return r / 255, g / 255, b / 255
end

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

    VeterancyBar.label:SetText(string.format(
        "Vet %d  %d%%",
        rank,
        math.floor(current / max * 100)
    ))
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

    local bg = wm:CreateControl(nil, VeterancyBar.window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(1, 1, 1, 1)

    --------------------------------------------------------
    -- Progress bar
    --------------------------------------------------------

    VeterancyBar.bar = wm:CreateControl(nil, VeterancyBar.window, CT_STATUSBAR)
    VeterancyBar.bar:SetAnchorFill()

    -- NEW: Use saved color
    VeterancyBar.bar:SetColor(
        VeterancyBar.savedVars.r,
        VeterancyBar.savedVars.g,
        VeterancyBar.savedVars.b,
        1
    )

    --------------------------------------------------------
    -- Label
    --------------------------------------------------------

    VeterancyBar.label = wm:CreateControl(nil, VeterancyBar.window, CT_LABEL)
    VeterancyBar.label:SetAnchor(CENTER, VeterancyBar.window, CENTER)
    VeterancyBar.label:SetFont("ZoFontGameMedium")
    VeterancyBar.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    VeterancyBar.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    VeterancyBar.label:SetColor(0.05, 0.05, 0.05, 1)

    --------------------------------------------------------
    -- Drag control
    --------------------------------------------------------

    local dragger = wm:CreateControl(nil, VeterancyBar.window, CT_CONTROL)
    dragger:SetAnchorFill()
    dragger:SetMouseEnabled(true)

    -- NEW: Only allow movement when unlocked
    dragger:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT
        and not VeterancyBar.savedVars.locked then

            VeterancyBar.window:StartMoving()
        end
    end)

    dragger:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT
        and not VeterancyBar.savedVars.locked then

            VeterancyBar.window:StopMovingOrResizing()

            VeterancyBar.savedVars.x = VeterancyBar.window:GetLeft()
            VeterancyBar.savedVars.y = VeterancyBar.window:GetTop()
        end
    end)
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

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    VeterancyBar.savedVars = ZO_SavedVars:NewAccountWide(
        "VeterancyBarSavedVariables",
        1,
        nil,
        {
            x = 200,
            y = 200,

            -- NEW: Lock setting
            locked = false,

            -- NEW: Default bar color
            r = 0.094,
            g = 1,
            b = 0.976,
        }
    )

    VeterancyBar.CreateUI()
    VeterancyBar.Update()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_REWARD_TRACK_PROGRESS_GAINED,
        OnRewardTrackProgress
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_PLAYER_ACTIVATED,
        RefreshAfterActivation
    )

    --------------------------------------------------------
    -- NEW: Lock / Unlock command
    --------------------------------------------------------

    SLASH_COMMANDS["/vetlock"] = function()

        VeterancyBar.savedVars.locked =
            not VeterancyBar.savedVars.locked

        if VeterancyBar.savedVars.locked then
            d("VeterancyBar locked.")
        else
            d("VeterancyBar unlocked.")
        end
    end

--------------------------------------------------------
-- NEW: Change color command
--------------------------------------------------------

	SLASH_COMMANDS["/vetcolor"] = function(text)

		local r, g, b = HexToRGB(text)

		if not r then
			d("Invalid color. Use: /vetcolor RRGGBB")
			d("Example: /vetcolor FF0000")
			return
		end

		VeterancyBar.savedVars.r = r
		VeterancyBar.savedVars.g = g
		VeterancyBar.savedVars.b = b

		if VeterancyBar.bar then
			VeterancyBar.bar:SetColor(
				r,
				g,
				b,
				1
			)
		end

		d("VeterancyBar color changed.")
	end


	--------------------------------------------------------
	-- NEW: Help command
	--------------------------------------------------------

	SLASH_COMMANDS["/vethelp"] = function()

		d("|c00FFFFVeterancyBar commands:|r")
		d("/vetlock - Locks and unlocks the bar")
		d("/vetcolor FFXXXX - Changes bar color (example: /vetcolor FF0000)")

	end
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnLoaded
)