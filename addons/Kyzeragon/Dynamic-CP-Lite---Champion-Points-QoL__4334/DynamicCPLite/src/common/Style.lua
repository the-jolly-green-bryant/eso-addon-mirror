---------------------------------------------------------------------
---------------------------------------------------------------------
local KEYBOARD_STYLE = {
    smallFont = "ZoFontGameSmall",
    gameFont = "ZoFontGame",
    gameBoldFont = "ZoFontGameBold",
    GetSizedFont = function(size)
        return string.format("$(BOLD_FONT)|%d|soft-shadow-thick", math.floor(size))
    end,
}

local GAMEPAD_STYLE = {
    smallFont = "$(GAMEPAD_BOLD_FONT)|13|soft-shadow-thick",
    gameFont = "$(GAMEPAD_MEDIUM_FONT)|18|soft-shadow-thick",
    gameBoldFont = "$(GAMEPAD_BOLD_FONT)|18|soft-shadow-thick",
    GetSizedFont = function(size)
        return string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick", math.floor(size))
    end,
}


---------------------------------------------------------------------
-- Apply styles to... everything
---------------------------------------------------------------------
local activeStyles = GAMEPAD_STYLE
local function ApplyStyle(style)
    activeStyles = style

    DynamicCP.ApplyPulldownFonts()
    DynamicCP.ReanchorPulldown()

    DynamicCP.ApplyQuickstarsFonts()

    DynamicCPInfoLabel:SetFont(style.gameBoldFont)
    DynamicCPInfoLabel:ClearAnchors()
    if (activeStyles == GAMEPAD_STYLE) then
        DynamicCPInfoLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 8, 8)
    else
        DynamicCPInfoLabel:SetAnchor(TOPLEFT, ZO_ChampionPerksKeyboardStatusPointHeader, BOTTOMLEFT, 0, 4)
    end

    DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
end

local function GetStyles()
    return activeStyles
end
DynamicCP.GetStyles = GetStyles


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local initialized = false
function DynamicCP.InitializeStyles()
    if (initialized) then
        return
    end
    initialized = true

    ZO_PlatformStyle:New(ApplyStyle, KEYBOARD_STYLE, GAMEPAD_STYLE)
end