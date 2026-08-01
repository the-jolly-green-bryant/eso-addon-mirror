-- TraitTimer Settings Panel (LibAddonMenu-2.0)
-- Optional: only registers if LAM is available at init time

TraitTimer = TraitTimer or {}

local TT = TraitTimer

local function BuildOptions()
    local sv = TT.sv
    local UI = TT.UI

    local optionsData = {
        -- General header
        {
            type = "header",
            name = GetString(TT_SETTINGS_GENERAL),
        },

        -- Hide in combat
        {
            type = "checkbox",
            name = GetString(TT_SETTINGS_HIDE_COMBAT),
            tooltip = GetString(TT_SETTINGS_HIDE_COMBAT_TT),
            getFunc = function() return sv.hideInCombat end,
            setFunc = function(value) sv.hideInCombat = value end,
            default = true,
        },

        -- Lock position
        {
            type = "checkbox",
            name = GetString(TT_SETTINGS_LOCK),
            tooltip = GetString(TT_SETTINGS_LOCK_TT),
            getFunc = function() return sv.locked end,
            setFunc = function(value)
                sv.locked = value
                TraitTimerHUD:SetMovable(not value)
            end,
            default = false,
        },

        -- Default view mode
        {
            type = "dropdown",
            name = GetString(TT_SETTINGS_VIEW_MODE),
            tooltip = GetString(TT_SETTINGS_VIEW_MODE_TT),
            choices = { GetString(TT_MODE_TIMERS), GetString(TT_MODE_MISSING) },
            choicesValues = { "timers", "missing" },
            getFunc = function() return sv.viewMode end,
            setFunc = function(value)
                sv.viewMode = value
                TT.viewMode = value
                if value == "missing" then
                    TT:ScanMissingTraits()
                else
                    TT:ScanAllResearch()
                end
                UI:Rebuild()
            end,
            default = "timers",
        },

        -- Background opacity
        {
            type = "slider",
            name = GetString(TT_SETTINGS_BG_ALPHA),
            tooltip = GetString(TT_SETTINGS_BG_ALPHA_TT),
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return sv.bgAlpha or 80 end,
            setFunc = function(value)
                sv.bgAlpha = value
                UI:ApplyBgAlpha()
            end,
            default = 80,
        },

        -- Reset position & size
        {
            type = "button",
            name = GetString(TT_SETTINGS_RESET),
            tooltip = GetString(TT_SETTINGS_RESET_TT),
            func = function()
                sv.anchorPoint = TOPRIGHT
                sv.relativePoint = TOPRIGHT
                sv.offsetX = -20
                sv.offsetY = 80
                sv.widgetWidth = 420
                sv.widgetHeight = nil

                local hud = TraitTimerHUD
                hud:ClearAnchors()
                hud:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 80)
                UI:ApplyWidth(420)
                UI:Rebuild()
            end,
        },
    }

    return optionsData
end

function TT:InitSettings()
    local LAM2 = LibAddonMenu2
    if not LAM2 then return end

    local panelData = {
        type = "panel",
        name = "TraitTimer",
        author = "HMariou",
        version = self.version,
        registerForRefresh = true,
    }

    LAM2:RegisterAddonPanel("TraitTimerSettings", panelData)
    LAM2:RegisterOptionControls("TraitTimerSettings", BuildOptions())
end
