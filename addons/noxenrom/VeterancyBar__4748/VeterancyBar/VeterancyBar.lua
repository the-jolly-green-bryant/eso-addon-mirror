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
    showRawXP = false,
    showRankTitle = true,
	showProgressText = true,

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
-- Veterancy Rank Titles
-- Exact rank names supplied from UESP
------------------------------------------------------------

local VETERANCY_RANK_TITLES = {
    [1] = "Novice",
    [2] = "Freelancer",
    [3] = "Freelancer I",
    [4] = "Freelancer II",
    [5] = "Freelancer III",
    [6] = "Regular",
    [7] = "Regular I",
    [8] = "Regular II",
    [9] = "Regular III",
    [10] = "Regular IV",

    [11] = "Lancer",
    [12] = "Lancer I",
    [13] = "Lancer II",
    [14] = "Lancer III",
    [15] = "Lancer IV",

    [16] = "Striker",
    [17] = "Striker I",
    [18] = "Striker II",
    [19] = "Striker III",
    [20] = "Striker IV",

    [21] = "Ransacker",
    [22] = "Ransacker I",
    [23] = "Ransacker II",
    [24] = "Ransacker III",
    [25] = "Ransacker IV",

    [26] = "Warmonger",
    [27] = "Warmonger I",
    [28] = "Warmonger II",
    [29] = "Warmonger III",
    [30] = "Warmonger IV",

    [31] = "Marauder",
    [32] = "Marauder I",
    [33] = "Marauder II",
    [34] = "Marauder III",
    [35] = "Marauder IV",

    [36] = "Champion",
    [37] = "Champion I",
    [38] = "Champion II",
    [39] = "Champion III",
    [40] = "Champion IV",

    [41] = "Conqueror",
    [42] = "Conqueror I",
    [43] = "Conqueror II",
    [44] = "Conqueror III",
    [45] = "Conqueror IV",

    [46] = "Warchief",
    [47] = "Warchief I",
    [48] = "Warchief II",
    [49] = "Warchief III",
    [50] = "Warchief IV",

    [51] = "Brutal Freelancer",
    [52] = "Brutal Freelancer I",
    [53] = "Brutal Freelancer II",
    [54] = "Brutal Freelancer III",
    [55] = "Brutal Freelancer IV",

    [56] = "Brutal Regular",
    [57] = "Brutal Regular I",
    [58] = "Brutal Regular II",
    [59] = "Brutal Regular III",
    [60] = "Brutal Regular IV",

    [61] = "Brutal Lancer",
    [62] = "Brutal Lancer I",
    [63] = "Brutal Lancer II",
    [64] = "Brutal Lancer III",
    [65] = "Brutal Lancer IV",

    [66] = "Brutal Striker",
    [67] = "Brutal Striker I",
    [68] = "Brutal Striker II",
    [69] = "Brutal Striker III",
    [70] = "Brutal Striker IV",

    [71] = "Brutal Ransacker",
    [72] = "Brutal Ransacker I",
    [73] = "Brutal Ransacker II",
    [74] = "Brutal Ransacker III",
    [75] = "Brutal Ransacker IV",

    [76] = "Brutal Warmonger",
    [77] = "Brutal Warmonger I",
    [78] = "Brutal Warmonger II",
    [79] = "Brutal Warmonger III",
    [80] = "Brutal Warmonger IV",

    [81] = "Brutal Marauder",
    [82] = "Brutal Marauder I",
    [83] = "Brutal Marauder II",
    [84] = "Brutal Marauder III",
    [85] = "Brutal Marauder IV",

    [86] = "Brutal Champion",
    [87] = "Brutal Champion I",
    [88] = "Brutal Champion II",
    [89] = "Brutal Champion III",
    [90] = "Brutal Champion IV",

    [91] = "Brutal Conqueror",
    [92] = "Brutal Conqueror I",
    [93] = "Brutal Conqueror II",
    [94] = "Brutal Conqueror III",
    [95] = "Brutal Conqueror IV",

    [96] = "Brutal Warchief",
    [97] = "Brutal Warchief I",
    [98] = "Brutal Warchief II",
    [99] = "Brutal Warchief III",
    [100] = "Sovereign"
}

------------------------------------------------------------
-- Get Veterancy Rank Title
------------------------------------------------------------

local function GetVeterancyRankTitle(rank)
    return VETERANCY_RANK_TITLES[rank] or ("Vet " .. tostring(rank))
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
    if not VeterancyBar.bar or not VeterancyBar.label then
        return
    end

    local current, max, rank = GetVeterancyProgress()

    VeterancyBar.bar:SetMinMax(0, max)
    VeterancyBar.bar:SetValue(current)

    --------------------------------------------------------
    -- Rank 100 = Sovereign
    --------------------------------------------------------

    if rank >= 100 then
        if VeterancyBar.savedVars.showRankTitle then
            VeterancyBar.label:SetText("Sovereign")
        else
            VeterancyBar.label:SetText("Vet Max Rank")
        end

        return
    end

    --------------------------------------------------------
    -- Determine rank display
    --------------------------------------------------------

    local rankDisplay

    if VeterancyBar.savedVars.showRankTitle then
        rankDisplay = GetVeterancyRankTitle(rank)
    else
        rankDisplay = string.format("Vet %d", rank)
    end

	--------------------------------------------------------
	-- Display XP or percentage
	--------------------------------------------------------

	if VeterancyBar.savedVars.showProgressText then

		if VeterancyBar.savedVars.showRawXP then

			VeterancyBar.label:SetText(
				string.format(
					"%s  %s / %s",
					rankDisplay,
					ZO_CommaDelimitNumber(current),
					ZO_CommaDelimitNumber(max)
				)
			)

		else

			local percentage = 0

			if max and max > 0 then
				percentage = math.floor((current / max) * 100)
			end

			VeterancyBar.label:SetText(
				string.format(
					"%s  %d%%",
					rankDisplay,
					percentage
				)
			)

		end

	else

		VeterancyBar.label:SetText(
			rankDisplay
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

    bg = wm:CreateControl(
        nil,
        VeterancyBar.window,
        CT_BACKDROP
    )

    bg:SetAnchorFill()

    bg:SetCenterColor(
        VeterancyBar.savedVars.bgColor.R,
        VeterancyBar.savedVars.bgColor.G,
        VeterancyBar.savedVars.bgColor.B,
        VeterancyBar.savedVars.bgColor.A
    )

    --------------------------------------------------------
    -- Progress bar
    --------------------------------------------------------

    VeterancyBar.bar = wm:CreateControl(
        nil,
        VeterancyBar.window,
        CT_STATUSBAR
    )

    VeterancyBar.bar:SetAnchorFill()

    VeterancyBar.bar:SetColor(
        VeterancyBar.savedVars.progressColor.R,
        VeterancyBar.savedVars.progressColor.G,
        VeterancyBar.savedVars.progressColor.B,
        VeterancyBar.savedVars.progressColor.A
    )

    --------------------------------------------------------
    -- Label
    --------------------------------------------------------

    VeterancyBar.label = wm:CreateControl(
        nil,
        VeterancyBar.window,
        CT_LABEL
    )

    VeterancyBar.label:SetAnchor(
        CENTER,
        VeterancyBar.window,
        CENTER
    )

    VeterancyBar.label:SetFont("ZoFontGameMedium")

    VeterancyBar.label:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    VeterancyBar.label:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    VeterancyBar.label:SetColor(
        VeterancyBar.savedVars.fontColor.R,
        VeterancyBar.savedVars.fontColor.G,
        VeterancyBar.savedVars.fontColor.B,
        VeterancyBar.savedVars.fontColor.A
    )

    --------------------------------------------------------
    -- Drag control
    --------------------------------------------------------

    local dragger = wm:CreateControl(
        nil,
        VeterancyBar.window,
        CT_CONTROL
    )

    dragger:SetAnchorFill()
    dragger:SetMouseEnabled(true)

    dragger:SetHandler(
        "OnMouseDown",
        function(_, button)

            if button == MOUSE_BUTTON_INDEX_LEFT then
                VeterancyBar.window:StartMoving()
            end

        end
    )

    dragger:SetHandler(
        "OnMouseUp",
        function(_, button)

            if button == MOUSE_BUTTON_INDEX_LEFT then

                VeterancyBar.window:StopMovingOrResizing()

                VeterancyBar.savedVars.x =
                    VeterancyBar.window:GetLeft()

                VeterancyBar.savedVars.y =
                    VeterancyBar.window:GetTop()

            end

        end
    )
end

------------------------------------------------------------
-- Set Window Lock
------------------------------------------------------------

function VeterancyBar:SetWindowLock(shouldLock)

    VeterancyBar.savedVars.isLocked = shouldLock

    local canMove = not shouldLock

    if VeterancyBarWindow then

        VeterancyBarWindow:SetMovable(canMove)
        VeterancyBarWindow:SetMouseEnabled(canMove)

    end
end

------------------------------------------------------------
-- Toggle Window Lock
------------------------------------------------------------

function VeterancyBar:ToggleLock()

    VeterancyBar:SetWindowLock(
        not VeterancyBar.savedVars.isLocked
    )

end

------------------------------------------------------------
-- Show / Hide Window based on PvP status
------------------------------------------------------------

function VeterancyBar:UpdateWindowVisibility()

    if not VeterancyBarWindow then
        return
    end

    local onlyInPvp = false

    if VeterancyBar.savedVars
        and VeterancyBar.savedVars.onlyInPvp then

        onlyInPvp = true

    end

    if onlyInPvp then

        local isInPvp =
            IsPlayerInAvAWorld()
            or IsActiveWorldBattleground()

        VeterancyBarWindow:SetHidden(not isInPvp)

    else

        VeterancyBarWindow:SetHidden(false)

    end
end

------------------------------------------------------------
-- Event binding for transition tracking
------------------------------------------------------------

function VeterancyBar:OnZoneChanged(eventCode)

    VeterancyBar:UpdateWindowVisibility()

end

------------------------------------------------------------
-- Apply Progress Bar Color
------------------------------------------------------------

function VeterancyBar:ApplyBarColor()

    if VeterancyBar.bar then

        VeterancyBar.bar:SetColor(
            VeterancyBar.savedVars.progressColor.R,
            VeterancyBar.savedVars.progressColor.G,
            VeterancyBar.savedVars.progressColor.B,
            VeterancyBar.savedVars.progressColor.A
        )

        local current =
            VeterancyBar.bar:GetValue()

        VeterancyBar.bar:SetValue(current)

    end
end

------------------------------------------------------------
-- Update Background Color
------------------------------------------------------------

function VeterancyBar:UpdateBackgroundColor()

    if not bg then
        return
    end

    bg:SetCenterColor(
        VeterancyBar.savedVars.bgColor.R,
        VeterancyBar.savedVars.bgColor.G,
        VeterancyBar.savedVars.bgColor.B,
        VeterancyBar.savedVars.bgColor.A
    )

end

------------------------------------------------------------
-- Apply Font Color
------------------------------------------------------------

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

------------------------------------------------------------
-- Update Font Color
------------------------------------------------------------

function VeterancyBar:UpdateFontColor()

    if not VeterancyBar.label then
        return
    end

    VeterancyBar.label:SetColor(
        VeterancyBar.savedVars.fontColor.R,
        VeterancyBar.savedVars.fontColor.G,
        VeterancyBar.savedVars.fontColor.B,
        VeterancyBar.savedVars.fontColor.A
    )

end

------------------------------------------------------------
-- Initialize
------------------------------------------------------------

function VeterancyBar:Initialize()

    VeterancyBar:UpdateBackgroundColor()

    VeterancyBar:ApplyBarColor()

    VeterancyBar:ApplyFontColor()

    EVENT_MANAGER:RegisterForEvent(
        "VeterancyBar_Event",
        EVENT_PLAYER_ACTIVATED,
        function(eventCode)

            VeterancyBar:OnZoneChanged(eventCode)

        end
    )

    VeterancyBar:SetWindowLock(
        VeterancyBar.savedVars.isLocked
    )

end

------------------------------------------------------------
-- Settings Panel
------------------------------------------------------------

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

        ----------------------------------------------------
        -- 1. Lock Window
        ----------------------------------------------------

        [1] = {
            type = "checkbox",

            name = "Lock Window Position",

            tooltip =
                "Check this to lock the window in place to prevent moving it with the mouse.",

            getFunc = function()

                return VeterancyBar.savedVars.isLocked

            end,

            setFunc = function(value)

                VeterancyBar:SetWindowLock(value)

            end,
        },

        ----------------------------------------------------
        -- 2. PvP Only
        ----------------------------------------------------

        [2] = {
            type = "checkbox",

            name = "Only Display Window in PvP Zones",

            tooltip =
                "When enabled, this window automatically vanishes unless you are in Cyrodiil, Imperial City, or Battlegrounds.",

            getFunc = function()

                return VeterancyBar.savedVars.onlyInPvp

            end,

            setFunc = function(value)

                VeterancyBar.savedVars.onlyInPvp = value

                VeterancyBar:UpdateWindowVisibility()

            end,
        },

        ----------------------------------------------------
        -- 3. Show Rank Title
        ----------------------------------------------------

        [3] = {
            type = "checkbox",

            name = "Show Veterancy Rank Title",

            tooltip =
                "When enabled, the Veterancy rank number is replaced by the actual Veterancy rank title, such as Champion, Champion I, Champion II, Brutal Champion, etc.",

            getFunc = function()

                return VeterancyBar.savedVars.showRankTitle

            end,

            setFunc = function(value)

                VeterancyBar.savedVars.showRankTitle = value

                VeterancyBar.Update()

            end,
        },

        ----------------------------------------------------
        -- 4. PROGRESS TEXT
        ----------------------------------------------------

        [4] = {

            type = "checkbox",

            name =
                "Show Progress Percentage / XP",

            tooltip =
                "When enabled, display Veterancy progress as either a percentage or raw XP. When disabled, only the rank is displayed.",

            getFunc = function()

                return VeterancyBar.savedVars.showProgressText

            end,

            setFunc = function(value)

                VeterancyBar.savedVars.showProgressText =
                    value

                VeterancyBar:
                    Update()

            end,
        },
		
        ----------------------------------------------------
        -- 5. Progress Bar Color
        ----------------------------------------------------

        [5] = {
            type = "colorpicker",

            name = "Progress Bar Color",

            tooltip =
                "Select the color for the progress bar.",

            getFunc = function()

                return
                    VeterancyBar.savedVars.progressColor.R,
                    VeterancyBar.savedVars.progressColor.G,
                    VeterancyBar.savedVars.progressColor.B,
                    VeterancyBar.savedVars.progressColor.A

            end,

            setFunc = function(r, g, b, a)

                VeterancyBar.savedVars.progressColor.R = r
                VeterancyBar.savedVars.progressColor.G = g
                VeterancyBar.savedVars.progressColor.B = b
                VeterancyBar.savedVars.progressColor.A = a

                VeterancyBar:ApplyBarColor()

            end
        },

        ----------------------------------------------------
        -- 6. Background Color
        ----------------------------------------------------

        [6] = {
            type = "colorpicker",

            name = "Background Bar Color",

            tooltip =
                "Select the color for the background.",

            getFunc = function()

                return
                    VeterancyBar.savedVars.bgColor.R,
                    VeterancyBar.savedVars.bgColor.G,
                    VeterancyBar.savedVars.bgColor.B,
                    VeterancyBar.savedVars.bgColor.A

            end,

            setFunc = function(r, g, b, a)

                VeterancyBar.savedVars.bgColor.R = r
                VeterancyBar.savedVars.bgColor.G = g
                VeterancyBar.savedVars.bgColor.B = b
                VeterancyBar.savedVars.bgColor.A = a

                VeterancyBar:UpdateBackgroundColor()

            end,
        },

        ----------------------------------------------------
        -- 7. Font Color
        ----------------------------------------------------

        [7] = {
            type = "colorpicker",

            name = "Font Color",

            tooltip =
                "Select the color for the Font.",

            getFunc = function()

                return
                    VeterancyBar.savedVars.fontColor.R,
                    VeterancyBar.savedVars.fontColor.G,
                    VeterancyBar.savedVars.fontColor.B,
                    VeterancyBar.savedVars.fontColor.A

            end,

            setFunc = function(r, g, b, a)

                VeterancyBar.savedVars.fontColor.R = r
                VeterancyBar.savedVars.fontColor.G = g
                VeterancyBar.savedVars.fontColor.B = b
                VeterancyBar.savedVars.fontColor.A = a

                VeterancyBar:UpdateFontColor()

            end
        },

        ----------------------------------------------------
        -- 8. Raw XP
        ----------------------------------------------------

        [8] = {
            type = "checkbox",

            name = "Show Raw XP Instead of Percentage",

            tooltip =
                "When enabled, the bar displays your current Veterancy XP and the XP required for the next rank instead of a percentage.",

            getFunc = function()

                return VeterancyBar.savedVars.showRawXP

            end,

            setFunc = function(value)

                VeterancyBar.savedVars.showRawXP = value

                VeterancyBar.Update()

            end,
        },
    }

    local LAM = LibAddonMenu2

    LAM:RegisterAddonPanel(
        panelName,
        panelData
    )

    LAM:RegisterOptionControls(
        panelName,
        optionsTable
    )
end

------------------------------------------------------------
-- Events
------------------------------------------------------------

local function RefreshAfterActivation()

    VeterancyBar.Update()

    zo_callLater(
        VeterancyBar.Update,
        500
    )

    zo_callLater(
        VeterancyBar.Update,
        1500
    )

end

------------------------------------------------------------
-- Veterancy Progress Event
------------------------------------------------------------

local function OnRewardTrackProgress(_, trackType)

    if trackType == REWARD_TRACK_TYPE_AVA_VETERANCY then

        VeterancyBar.Update()

    end
end

------------------------------------------------------------
-- Addon Loaded
------------------------------------------------------------

local function OnLoaded(_, addonName)

    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    VeterancyBar.savedVars =
        ZO_SavedVars:NewAccountWide(
            "VeterancyBarSavedVariables",
            1,
            nil,
            VeterancyBar.defaults
        )

    initializeVeterancyBarOptions()

    VeterancyBar.CreateUI()

    VeterancyBar.Update()

    VeterancyBar:Initialize()

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

end

------------------------------------------------------------
-- Register Addon
------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnLoaded
)