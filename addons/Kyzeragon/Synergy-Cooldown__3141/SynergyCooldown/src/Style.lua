local SynCool = SynergyCooldown

---------------------------------------------------------------------
---------------------------------------------------------------------
local KEYBOARD_STYLE = {
    labelFont = "$(BOLD_FONT)|14|soft-shadow-thick",
    timerFont = "$(BOLD_FONT)|14|outline",
}

local GAMEPAD_STYLE = {
    labelFont = "$(GAMEPAD_BOLD_FONT)|14|soft-shadow-thick",
    timerFont = "$(GAMEPAD_BOLD_FONT)|14|outline",
}


---------------------------------------------------------------------
-- Apply styles to... everything
---------------------------------------------------------------------
local activeStyles = GAMEPAD_STYLE
local function ApplyStyle(style)
    activeStyles = style
    SynCool.ApplyStyles()
    SynCool.ApplyStylesOthers()
end

local function GetStyles()
    return activeStyles
end
SynCool.GetStyles = GetStyles


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local initialized = false
function SynCool.InitializeStyles()
    if (initialized) then
        return
    end
    initialized = true

    ZO_PlatformStyle:New(ApplyStyle, KEYBOARD_STYLE, GAMEPAD_STYLE)
end
