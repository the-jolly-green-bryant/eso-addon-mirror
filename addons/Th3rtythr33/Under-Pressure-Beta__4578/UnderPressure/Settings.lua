-- =============================================================================
-- Under Pressure -- Settings.lua
-- =============================================================================
-- LibAddonMenu-2.0 settings panel. Every tunable defined in the engine is
-- exposed here. The panel name is "Under Pressure" and shows under
-- Settings > Addons in-game.
-- =============================================================================

UP = UP or {}
UP.Settings = {}

-- Newer LibAddonMenu-2.0 releases (r36+) removed LibStub and expose the
-- library exclusively as the global LibAddonMenu2. We prefer the global and
-- fall back to LibStub for older installs.
local LAM = LibAddonMenu2 or (LibStub and LibStub("LibAddonMenu-2.0", true))

local PANEL_NAME = "UnderPressureSettingsPanel"

local panelData = {
    type    = "panel",
    name    = "Under Pressure",
    displayName = "Under Pressure",
    author  = "Th3rtythr33",
    version = "0.2.6",
    slashCommand = "/up",
    registerForRefresh = true,
    registerForDefaults = true,
}

local function sv()
    return UnderPressureSavedVars
end

local function tun()
    sv().tunables = sv().tunables or {}
    return sv().tunables
end

local optionsTable = {
    {
        type = "header", name = "Display",
    },
    {
        type = "checkbox", name = "Show indicator",
        tooltip = "Master toggle. Unchecking this hides the indicator unconditionally.",
        getFunc = function() return not (sv().hidden or false) end,
        setFunc = function(v)
            sv().hidden = not v
            if UP.UI and UP.UI.UpdateVisibility then UP.UI.UpdateVisibility() end
        end,
        default = true,
    },
    {
        type = "checkbox", name = "Always show indicator",
        tooltip = "By default the indicator is hidden when you are out of combat or dead. Check this to keep it on screen at all times (subject to the master 'Show indicator' toggle above).",
        getFunc = function() return sv().always_show == true end,
        setFunc = function(v)
            sv().always_show = v
            if UP.UI and UP.UI.UpdateVisibility then UP.UI.UpdateVisibility() end
        end,
        default = false,
    },
    {
        type = "slider", name = "Indicator scale",
        min = 0.5, max = 2.5, step = 0.05, decimals = 2,
        getFunc = function() return sv().scale or 1.0 end,
        setFunc = function(v)
            sv().scale = v
            if UP.UI and UP.UI.ApplyAnchor then
                UP.UI.ApplyAnchor(sv().offset_x or 0, sv().offset_y or -140, v)
            end
        end,
        default = 1.0,
    },
    {
        type = "slider", name = "Horizontal offset", min = -800, max = 800, step = 5,
        getFunc = function() return sv().offset_x or 0 end,
        setFunc = function(v)
            sv().offset_x = v
            if UP.UI and UP.UI.ApplyAnchor then
                UP.UI.ApplyAnchor(v, sv().offset_y or -140, sv().scale or 1.0)
            end
        end,
        default = 0,
    },
    {
        type = "slider", name = "Vertical offset", min = -500, max = 500, step = 5,
        getFunc = function() return sv().offset_y or -140 end,
        setFunc = function(v)
            sv().offset_y = v
            if UP.UI and UP.UI.ApplyAnchor then
                UP.UI.ApplyAnchor(sv().offset_x or 0, v, sv().scale or 1.0)
            end
        end,
        default = -140,
    },

    {
        type = "header", name = "Attacker counter",
    },
    {
        type = "description", text = "A counter beside the indicator shows how many distinct things have attacked recently -- useful for knowing how many mobs you are (or aren't) tanking. Tank mode counts attackers on any groupmate the client sees being hit (best-effort: limited to combat events the local client receives). Not Tank counts attackers on you only.",
    },
    {
        type = "dropdown", name = "Counter mode",
        choices = { "Tank", "Not Tank" },
        getFunc = function()
            local m = sv().attacker_mode or "solo"
            return (m == "tank") and "Tank" or "Not Tank"
        end,
        setFunc = function(v)
            sv().attacker_mode = (v == "Tank") and "tank" or "solo"
            if UP.Ingest and UP.Ingest.Rewire then UP.Ingest.Rewire() end
        end,
        default = "Not Tank",
    },
    {
        type = "slider", name = "Counter window (sec)",
        min = 1, max = 5, step = 1,
        tooltip = "Rolling window used to count distinct recent attackers.",
        getFunc = function() return tun().attacker_window_s or UP.Defaults.attacker_window_s end,
        setFunc = function(v) tun().attacker_window_s = v end,
        default = UP.Defaults.attacker_window_s,
    },
    {
        type = "checkbox", name = "Show counter",
        getFunc = function() return sv().show_counter ~= false end,
        setFunc = function(v)
            sv().show_counter = v
            if UP.UI and UP.UI.SetCounter then UP.UI.SetCounter(0) end
        end,
        default = true,
    },
    {
        type = "slider", name = "Counter text size",
        min = 14, max = 36, step = 1,
        tooltip = "Font size (in pixels) for the counter number.",
        getFunc = function() return sv().counter_font_size or 24 end,
        setFunc = function(v)
            sv().counter_font_size = v
            if UP.UI and UP.UI.ApplyCounterFontSize then
                UP.UI.ApplyCounterFontSize(v)
            end
        end,
        default = 24,
    },

    {
        type = "header", name = "TTD thresholds (seconds)",
    },
    {
        type = "slider", name = "Three triangles (lethal) below",
        min = 0.3, max = 2.0, step = 0.1, decimals = 1,
        getFunc = function() return tun().red_three_ttd or UP.Defaults.red_three_ttd end,
        setFunc = function(v) tun().red_three_ttd = v end,
        default = UP.Defaults.red_three_ttd,
    },
    {
        type = "slider", name = "Two triangles below",
        min = 0.5, max = 4.0, step = 0.1, decimals = 1,
        getFunc = function() return tun().red_two_ttd or UP.Defaults.red_two_ttd end,
        setFunc = function(v) tun().red_two_ttd = v end,
        default = UP.Defaults.red_two_ttd,
    },
    {
        type = "slider", name = "One triangle below",
        min = 1.0, max = 6.0, step = 0.1, decimals = 1,
        getFunc = function() return tun().red_one_ttd or UP.Defaults.red_one_ttd end,
        setFunc = function(v) tun().red_one_ttd = v end,
        default = UP.Defaults.red_one_ttd,
    },
    {
        type = "slider", name = "Filled yellow circle below",
        min = 2.0, max = 12.0, step = 0.1, decimals = 1,
        getFunc = function() return tun().yellow_filled_ttd or UP.Defaults.yellow_filled_ttd end,
        setFunc = function(v) tun().yellow_filled_ttd = v end,
        default = UP.Defaults.yellow_filled_ttd,
    },
    {
        type = "slider", name = "Recent-pressure window (sec)",
        min = 3, max = 30, step = 1,
        getFunc = function() return tun().recent_pressure_window_s or UP.Defaults.recent_pressure_window_s end,
        setFunc = function(v) tun().recent_pressure_window_s = v end,
        default = UP.Defaults.recent_pressure_window_s,
    },

    {
        type = "header", name = "Pressure weighting",
    },
    {
        type = "slider", name = "1s window weight",
        min = 0.5, max = 2.5, step = 0.05, decimals = 2,
        getFunc = function() return tun().weight_1s or UP.Defaults.weight_1s end,
        setFunc = function(v) tun().weight_1s = v end,
        default = UP.Defaults.weight_1s,
    },
    {
        type = "slider", name = "2s window weight",
        min = 0.5, max = 2.5, step = 0.05, decimals = 2,
        getFunc = function() return tun().weight_2s or UP.Defaults.weight_2s end,
        setFunc = function(v) tun().weight_2s = v end,
        default = UP.Defaults.weight_2s,
    },
    {
        type = "slider", name = "3s window weight",
        min = 0.5, max = 2.5, step = 0.05, decimals = 2,
        getFunc = function() return tun().weight_3s or UP.Defaults.weight_3s end,
        setFunc = function(v) tun().weight_3s = v end,
        default = UP.Defaults.weight_3s,
    },
    {
        type = "slider", name = "6s window weight",
        min = 0.2, max = 1.5, step = 0.05, decimals = 2,
        getFunc = function() return tun().weight_6s or UP.Defaults.weight_6s end,
        setFunc = function(v) tun().weight_6s = v end,
        default = UP.Defaults.weight_6s,
    },
    {
        type = "slider", name = "Burst multiplier",
        min = 1.0, max = 2.5, step = 0.05, decimals = 2,
        getFunc = function() return tun().burst_multiplier or UP.Defaults.burst_multiplier end,
        setFunc = function(v) tun().burst_multiplier = v end,
        default = UP.Defaults.burst_multiplier,
    },
    {
        type = "slider", name = "Debuff risk-bonus weight",
        min = 0.0, max = 2.0, step = 0.05, decimals = 2,
        tooltip = "Multiplier applied to risk bonuses from active debuffs (e.g. defile, dots, executes). 0 disables debuff contribution entirely.",
        getFunc = function() return tun().effect_weight or UP.Defaults.effect_weight end,
        setFunc = function(v) tun().effect_weight = v end,
        default = UP.Defaults.effect_weight,
    },
    {
        type = "slider", name = "Pressure DPS floor",
        min = 0, max = 1000, step = 10,
        getFunc = function() return tun().pressure_floor or UP.Defaults.pressure_floor end,
        setFunc = function(v) tun().pressure_floor = v end,
        default = UP.Defaults.pressure_floor,
    },
    {
        type = "slider", name = "State persistence (ms)",
        min = 0, max = 1000, step = 25,
        tooltip = "How long a new state must remain stable before being displayed. Prevents flicker.",
        getFunc = function() return tun().state_persistence_ms or UP.Defaults.state_persistence_ms end,
        setFunc = function(v) tun().state_persistence_ms = v end,
        default = UP.Defaults.state_persistence_ms,
    },

    {
        type = "header", name = "Debug",
    },
    {
        type = "checkbox", name = "Show debug overlay",
        getFunc = function() return sv().debug or false end,
        setFunc = function(v)
            sv().debug = v
            if UP.Debug and UP.Debug.SetVisible then UP.Debug.SetVisible(v) end
        end,
        default = false,
    },
}

function UP.Settings.Init()
    -- Re-resolve at init time because LibAddonMenu2 may not be set when this
    -- file is parsed (depends on add-on load order). At Init() we are called
    -- from EVENT_ADD_ON_LOADED, by which point all DependsOn libs are present.
    LAM = LAM or LibAddonMenu2 or (LibStub and LibStub("LibAddonMenu-2.0", true))
    if not LAM then
        d("[Under Pressure] LibAddonMenu-2.0 not found. Settings UI unavailable; defaults applied.")
        return
    end
    LAM:RegisterAddonPanel(PANEL_NAME, panelData)
    LAM:RegisterOptionControls(PANEL_NAME, optionsTable)
end
