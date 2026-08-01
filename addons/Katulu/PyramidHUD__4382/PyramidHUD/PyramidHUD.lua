local LAM2 = LibAddonMenu2
local ADDON_NAME = "PyramidHUD"

-- Local addon table --

local PyramidHUD = {
    name      = ADDON_NAME,
    version   = "1.6",
    svVersion = 4,

    default = {
        -- Keyboard --
        keyboardOffsetX = 0,
        keyboardOffsetY = -89,

        -- Gamepad --
        gamepadOffsetX  = 0,
        gamepadOffsetY  = -89,

        -- Scale (1.0 = 100%) --
        scale = 1.0,

        -- Health bar vertical fine adjustment --
        healthVerticalAdjust = 0,
    },

    sv = nil,
}

-------------------------------------------------
-- Apply scale
-------------------------------------------------

function PyramidHUD.ApplyScale()
    local scale = PyramidHUD.sv.scale or 1.0

    ZO_PlayerAttributeHealth:SetScale(scale)
    ZO_PlayerAttributeMagicka:SetScale(scale)
    ZO_PlayerAttributeStamina:SetScale(scale)
end

-------------------------------------------------
-- Pyramid layout positioning
-------------------------------------------------

function PyramidHUD.Reposition()
    local offsetX, offsetY

    if IsInGamepadPreferredMode() then
        offsetX = PyramidHUD.sv.gamepadOffsetX
        offsetY = PyramidHUD.sv.gamepadOffsetY
    else
        offsetX = PyramidHUD.sv.keyboardOffsetX
        offsetY = PyramidHUD.sv.keyboardOffsetY
    end

    local healthAdjust = PyramidHUD.sv.healthVerticalAdjust or 0

    ZO_PlayerAttributeHealth:ClearAnchors()
    ZO_PlayerAttributeMagicka:ClearAnchors()
    ZO_PlayerAttributeStamina:ClearAnchors()

    -- Health (independent vertical adjustment)
    ZO_PlayerAttributeHealth:SetAnchor(
        BOTTOM,
        ActionButton5,
        BOTTOM,
        offsetX,
        offsetY + healthAdjust
    )

    -- Magicka
    ZO_PlayerAttributeMagicka:SetAnchor(
        BOTTOMRIGHT,
        ActionButton5,
        BOTTOM,
        offsetX - 0.4,
        offsetY + 15
    )

    -- Stamina
    ZO_PlayerAttributeStamina:SetAnchor(
        BOTTOMLEFT,
        ActionButton5,
        BOTTOM,
        offsetX + 0.9,
        offsetY + 15
    )

    ZO_ActionBar1KeybindBG:SetHidden(true)

    PyramidHUD.ApplyScale()
end

-------------------------------------------------
-- Keyboard / Gamepad switcher
-------------------------------------------------

local function OnGamepadModeChanged()
    PyramidHUD.Reposition()
end

-------------------------------------------------
-- Settings menu
-------------------------------------------------

function PyramidHUD.CreateSettings()
    if not LAM2 then return end

    local panelData = {
        type = "panel",
        name = ADDON_NAME,
        displayName = "PyramidHUD",
        version = PyramidHUD.version,
    }

    local optionsData = {

        {
            type = "header",
            name = "General",
        },

        {
            type = "slider",
            name = "Bar scale (80% – 120%)",
            tooltip = "Adjusts the overall scale of the health, magicka and stamina bars.",
            min = 80,
            max = 120,
            step = 1,
            getFunc = function()
                return math.floor((PyramidHUD.sv.scale or 1.0) * 100)
            end,
            setFunc = function(value)
                PyramidHUD.sv.scale = value / 100
                PyramidHUD.ApplyScale()
            end,
        },

        {
            type = "slider",
            name = "Top bar separation",
            tooltip = "Vertical adjustment for the top (health) bar only. Does not affect magicka or stamina bars.",
            min = -50,
            max = 50,
            step = 1,
            getFunc = function()
                return PyramidHUD.sv.healthVerticalAdjust or 0
            end,
            setFunc = function(value)
                PyramidHUD.sv.healthVerticalAdjust = value
                PyramidHUD.Reposition()
            end,
        },

        {
            type = "description",
            text = "|cFF9933Note:|r When scaling above 100%, bars may slightly overlap due to vanilla UI limitations. Use the slider above to correct their position if needed.",
        },

        {
            type = "header",
            name = "Keyboard mode",
        },

        {
            type = "slider",
            name = "Horizontal offset (Default 0)",
            tooltip = "Moves the entire pyramid horizontally when using keyboard mode.",
            min = -300,
            max = 300,
            step = 1,
            getFunc = function()
                return PyramidHUD.sv.keyboardOffsetX
            end,
            setFunc = function(value)
                PyramidHUD.sv.keyboardOffsetX = value
                if not IsInGamepadPreferredMode() then
                    PyramidHUD.Reposition()
                end
            end,
        },

        {
            type = "slider",
            name = "Vertical offset (Default -89)",
            tooltip = "Moves the entire pyramid vertically when using keyboard mode.",
            min = -300,
            max = 300,
            step = 1,
            getFunc = function()
                return PyramidHUD.sv.keyboardOffsetY
            end,
            setFunc = function(value)
                PyramidHUD.sv.keyboardOffsetY = value
                if not IsInGamepadPreferredMode() then
                    PyramidHUD.Reposition()
                end
            end,
        },

        {
            type = "header",
            name = "Gamepad mode",
        },

        {
            type = "slider",
            name = "Horizontal offset (Default 0)",
            tooltip = "Moves the entire pyramid horizontally when using gamepad mode.",
            min = -300,
            max = 300,
            step = 1,
            getFunc = function()
                return PyramidHUD.sv.gamepadOffsetX
            end,
            setFunc = function(value)
                PyramidHUD.sv.gamepadOffsetX = value
                if IsInGamepadPreferredMode() then
                    PyramidHUD.Reposition()
                end
            end,
        },

        {
            type = "slider",
            name = "Vertical offset (Default -89)",
            tooltip = "Moves the entire pyramid vertically when using gamepad mode.",
            min = -300,
            max = 300,
            step = 1,
            getFunc = function()
                return PyramidHUD.sv.gamepadOffsetY
            end,
            setFunc = function(value)
                PyramidHUD.sv.gamepadOffsetY = value
                if IsInGamepadPreferredMode() then
                    PyramidHUD.Reposition()
                end
            end,
        },

        {
            type = "divider",
        },

        {
            type = "button",
            name = "Reload UI",
            tooltip = "Reloads the interface to ensure all changes are properly saved and applied.",
            func = function()
                ReloadUI()
            end,
            width = "full",
        },
    }

    LAM2:RegisterAddonPanel("PyramidHUDMenu", panelData)
    LAM2:RegisterOptionControls("PyramidHUDMenu", optionsData)
end

-------------------------------------------------
-- Initialization
-------------------------------------------------

function PyramidHUD.Initialize()
    local worldName = GetWorldName()

    PyramidHUD.sv = ZO_SavedVars:NewAccountWide(
        "PyramidHUDVars",
        PyramidHUD.svVersion,
        worldName,
        PyramidHUD.default
    )

    PyramidHUD.Reposition()
    PyramidHUD.ApplyScale()
    PyramidHUD.CreateSettings()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
        OnGamepadModeChanged
    )
end

-------------------------------------------------
-- Addon Loaded
-------------------------------------------------

local function OnAddOnLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    PyramidHUD.Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
