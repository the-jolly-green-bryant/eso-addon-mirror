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
    version = "0.3.0",
    slashCommand = "/up",
    registerForRefresh = true,
    registerForDefaults = true,
}

local function sv()
    return UP.sv
end

-- Every tunable read AND write goes through here, which makes it the one
-- place that can reliably invalidate the engine's cached tunables table.
-- Invalidating on reads too is harmless -- getFunc only runs while the panel
-- is open -- and it means no individual setFunc can forget to do it.
local function tun()
    sv().tunables = sv().tunables or {}
    if UP.Engine and UP.Engine.MarkTunablesDirty then
        UP.Engine.MarkTunablesDirty()
    end
    return sv().tunables
end

local optionsTable = {
    {
        type = "header", name = "Display",
    },
    {
        type = "checkbox", name = "Threat Indicator",
        tooltip = "Master toggle. Set to Off to hide the Threat Indicator at all times and under all conditions.",
        getFunc = function() return not (sv().hidden or false) end,
        setFunc = function(v)
            sv().hidden = not v
            if UP.UI and UP.UI.UpdateVisibility then UP.UI.UpdateVisibility() end
        end,
        default = true,
    },
    {
        type = "checkbox", name = "Always show indicator",
        tooltip = "By default the Threat Indicator is hidden when you are out of combat or dead. Turn this on to keep it on screen at all times (subject to the master 'Threat Indicator' toggle above).",
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
        -- Wording deliberately tracks the published description (see
        -- ## Description in UnderPressure.addon and Docs/UnderPressure.md).
        type = "description", text = "A counter beside the Threat Indicator shows how many distinct mobs you are taking damage from. Counts only mobs attacking you.",
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
        -- Range comes from the gamepad font ladder (UI/Fonts.lua), not from
        -- arbitrary pixel bounds. Values snap to the nearest font that
        -- actually exists on console, so the on-screen size moves in steps.
        min = UP.Fonts.MIN_SIZE, max = UP.Fonts.MAX_SIZE, step = 1,
        tooltip = "Size of the counter number. Snaps to the nearest available console font size, so small adjustments may not change anything visible.",
        getFunc = function() return sv().counter_font_size or 27 end,
        setFunc = function(v)
            sv().counter_font_size = v
            if UP.UI and UP.UI.ApplyCounterFontSize then
                UP.UI.ApplyCounterFontSize(v)
            end
        end,
        default = 27,
    },

    {
        type = "header", name = "Silence Indicator",
    },
    {
        type = "description", text = "A ring appears just below your reticle whenever you are silenced, and stays until the silence ends. Silence blocks every ability, including the heal or shield you would normally answer trouble with.",
    },
    {
        -- Its own switch, NOT gated on the Threat Indicator master toggle: that
        -- toggle's help text promises to hide the Threat Indicator specifically,
        -- and this is a separate indicator.
        type = "checkbox", name = "Silence Indicator",
        tooltip = "Set to Off to never show the silence ring. Independent of the Threat Indicator toggle -- turning the threat shape off leaves this running.",
        getFunc = function() return sv().silence_ring ~= false end,
        setFunc = function(v)
            sv().silence_ring = v
            if UP.SilenceRing and UP.SilenceRing.UpdateVisibility then
                UP.SilenceRing.UpdateVisibility()
            end
        end,
        default = true,
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

    -- The "Pressure weighting" section was removed in 0.2.9: nine sliders for
    -- the window weights, burst multiplier, debuff risk-bonus weight, pressure
    -- DPS floor and state persistence. The model is tuned and the controls only
    -- gave users a way to un-tune it. The tunables still exist in UP.Defaults
    -- and are still read by the engine every tick -- only the UI is gone, so
    -- restoring a slider is a matter of re-adding the entry here.
    --
    -- Saved overrides written by 0.2.8 users are cleared once on upgrade (see
    -- REMOVED_TUNABLES in UnderPressure.lua); without that they would persist
    -- forever with no control left to change or reset them.

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
        -- Expected on console: LAM does not work there. The manifest lists it
        -- as OptionalDependsOn precisely so this path is survivable -- the
        -- addon runs with saved-variable defaults and no settings UI.
        UP.Note("LibAddonMenu-2.0 not found. Settings UI unavailable; defaults applied.")
        return
    end
    -- RegisterAddonPanel returns the panel control. Keep it: it is the only
    -- correct argument for LAM:OpenToPanel, and the main entry checks for it
    -- to decide whether to claim the "/up" slash command.
    UP.Settings.panel = LAM:RegisterAddonPanel(PANEL_NAME, panelData)
    LAM:RegisterOptionControls(PANEL_NAME, optionsTable)
end
