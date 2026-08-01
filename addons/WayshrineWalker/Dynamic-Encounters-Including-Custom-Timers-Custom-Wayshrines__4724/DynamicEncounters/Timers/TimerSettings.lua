--[[----------------------------------------------------------------------
    Dynamic Encounters : Timer Settings
    LibAddonMenu-2.0 panel entries for the custom timer system.
----------------------------------------------------------------------]]--

DynamicEncounters.Timers = DynamicEncounters.Timers or {}
local T = DynamicEncounters.Timers
local HE = DynamicEncounters

function T.Settings_Initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "DynamicEncountersTimers",
        displayName = "|c66CCFFDynamic Encounters|r — Timers",
        author = "WayshrineWalker",
        version = HE.version,
        slashCommand = "/dectimers",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(HE.name .. "Timers", panelData)

    local sizeChoices = { "Small", "Medium", "Large" }
    local sizeValues  = { T.SIZE_SMALL, T.SIZE_MEDIUM, T.SIZE_LARGE }

    local function ts() return (HE.sv and HE.sv.timerSettings) or {} end

    local options = {
        { type = "header", name = "Timer Controls" },
        {
            type = "checkbox",
            name = "Lock All Timers",
            tooltip = "When locked, no timer can be dragged or resized.",
            getFunc = function() return ts().globalLock end,
            setFunc = function(v) T.SetGlobalLock(v) end,
            default = T.defaults.timerSettings.globalLock,
        },
        {
            type = "button",
            name = "New Timer",
            tooltip = "Create a new countdown timer (uses default duration below).",
            func = function()
                local id = T.CreateTimer("New Timer")
                if T.UI_PromptEditDuration then T.UI_PromptEditDuration(id) end
            end,
        },
        {
            type = "button",
            name = "Toggle All Timers",
            tooltip = "Start all stopped timers and stop all running timers.",
            func = function() T.ToggleAllTimers() end,
        },
        {
            type = "button",
            name = "Delete All Timers",
            tooltip = "Remove all custom timers. This cannot be undone.",
            func = function()
                for id, _ in pairs(ts().list) do T.DeleteTimer(id) end
            end,
            warning = "This will delete ALL custom timers. Continue?",
        },

        { type = "header", name = "Defaults for New Timers" },
        {
            type = "dropdown",
            name = "Default Size",
            tooltip = "Size applied to newly created timers.",
            choices = sizeChoices,
            choicesValues = sizeValues,
            getFunc = function() return ts().defaultSize end,
            setFunc = function(v) ts().defaultSize = v end,
            default = T.defaults.timerSettings.defaultSize,
        },
        {
            type = "slider",
            name = "Default Duration (minutes)",
            tooltip = "Countdown duration for newly created timers.",
            min = 1, max = 180, step = 1,
            getFunc = function() return math.floor((ts().defaultDuration or 300) / 60) end,
            setFunc = function(v) ts().defaultDuration = v * 60 end,
            default = math.floor(T.defaults.timerSettings.defaultDuration / 60),
        },

        { type = "header", name = "Diagnostics" },
        {
            type = "checkbox",
            name = "Show Debug Output",
            tooltip = "When ON, diagnostic messages are printed to chat.",
            getFunc = function() return HE.sv and HE.sv.debugMode or false end,
            setFunc = function(v)
                if HE.sv then HE.sv.debugMode = v end
                T._zoneResolveDiagDone = nil
                T._tableDiagDone = nil
                T._zoneMapDiagDone = nil
                T._fbDiagDone = nil
                T._fbAssignDiagDone = nil
                T._debugDumpDone = nil
                T._svDebugWritten = nil
                T._apiProbeDone = nil
            end,
            default = false,
        },

        { type = "header", name = "How To Use" },
        {
            type = "description",
            text = "Each timer is a floating widget.\n" ..
                   "- Click > / || to start / pause.\n" ..
                   "- Click the lock icon (top-left) to lock/unlock that timer.\n" ..
                   "- Right-click the label to rename it.\n" ..
                   "- SHIFT+right-click the label to set its duration.\n" ..
                   "  Accepts minutes (60), MM:SS (1:30), or suffix (90m, 45s).\n" ..
                   "- Drag to move; + (bottom-right) cycles size.\n" ..
                   "- SHIFT+LEFT-click wayshrine icon: assign nearest wayshrine.\n" ..
                   "- SHIFT+RIGHT-click wayshrine icon: browse/search ALL wayshrines.\n" ..
                   "Timers keep counting while you are logged out.",
        },

        { type = "header", name = "Button Style" },
        {
            type = "checkbox",
            name = "Use Icon Textures",
            tooltip = "When ON, play/pause buttons use ESO icon textures. When OFF (default), text glyphs (>, ||) are used. If icons appear blank, turn this OFF.",
            getFunc = function()
                if T.UI_GetIconMode then return T.UI_GetIconMode() end
                return false
            end,
            setFunc = function(v)
                if T.UI_SetIconMode then T.UI_SetIconMode(v) end
            end,
            default = false,
        },

        { type = "header", name = "Countdown Appearance" },
        {
            type = "slider",
            name = "Warning Threshold (seconds)",
            tooltip = "When a running timer has this many seconds or fewer left, the countdown turns red. Set to 0 to disable.",
            min = 0, max = 300, step = 5,
            getFunc = function()
                if T.UI_GetWarnThreshold then return T.UI_GetWarnThreshold() end
                return 30
            end,
            setFunc = function(v)
                if T.UI_SetWarnThreshold then T.UI_SetWarnThreshold(v) end
            end,
            default = 30,
        },
        {
            type = "description",
            text = "Customize the colors of your timer widgets. Changes apply immediately.",
        },
        {
            type = "colorpicker",
            name = "Normal Countdown",
            tooltip = "Color of the countdown text when the timer is running normally.",
            getFunc = function()
                if T.UI_GetColors then local c = T.UI_GetColors().normal return c[1], c[2], c[3] end
                return 1, 1, 1
            end,
            setFunc = function(r, g, b)
                if T.UI_SetColors then T.UI_SetColors({ normal = { r, g, b } }) end
            end,
        },
        {
            type = "colorpicker",
            name = "Warning Countdown",
            tooltip = "Color of the countdown text when the timer enters the warning zone.",
            getFunc = function()
                if T.UI_GetColors then local c = T.UI_GetColors().warning return c[1], c[2], c[3] end
                return 1, 0.25, 0.25
            end,
            setFunc = function(r, g, b)
                if T.UI_SetColors then T.UI_SetColors({ warning = { r, g, b } }) end
            end,
        },
        {
            type = "colorpicker",
            name = "Running Indicator",
            tooltip = "Color of the pause button and border when a timer is running.",
            getFunc = function()
                if T.UI_GetColors then local c = T.UI_GetColors().running return c[1], c[2], c[3] end
                return 0.30, 0.80, 0.40
            end,
            setFunc = function(r, g, b)
                if T.UI_SetColors then T.UI_SetColors({ running = { r, g, b } }) end
            end,
        },
        {
            type = "colorpicker",
            name = "Stopped Indicator",
            tooltip = "Color of the start button and border when a timer is stopped.",
            getFunc = function()
                if T.UI_GetColors then local c = T.UI_GetColors().stopped return c[1], c[2], c[3] end
                return 0.60, 0.75, 0.95
            end,
            setFunc = function(r, g, b)
                if T.UI_SetColors then T.UI_SetColors({ stopped = { r, g, b } }) end
            end,
        },
        {
            type = "colorpicker",
            name = "Expired Indicator",
            tooltip = "Color of the restart button and border when a timer has expired.",
            getFunc = function()
                if T.UI_GetColors then local c = T.UI_GetColors().expired return c[1], c[2], c[3] end
                return 0.90, 0.30, 0.20
            end,
            setFunc = function(r, g, b)
                if T.UI_SetColors then T.UI_SetColors({ expired = { r, g, b } }) end
            end,
        },
        {
            type = "colorpicker",
            name = "Status Text",
            tooltip = "Color of status text (e.g. No data yet, Spawning, Active now) on linked encounter timers.",
            getFunc = function()
                if T.UI_GetColors then local c = T.UI_GetColors().status return c[1], c[2], c[3] end
                return 0.95, 0.80, 0.35
            end,
            setFunc = function(r, g, b)
                if T.UI_SetColors then T.UI_SetColors({ status = { r, g, b } }) end
            end,
        },
        {
            type = "button",
            name = "Reset Colors",
            tooltip = "Restore the default timer colors.",
            func = function()
                if T.UI_SetColors then
                    T.UI_SetColors({
                        normal  = { 1, 1, 1 },
                        warning = { 1, 0.25, 0.25 },
                        running = { 0.30, 0.80, 0.40 },
                        stopped = { 0.60, 0.75, 0.95 },
                        expired = { 0.90, 0.30, 0.20 },
                        status  = { 0.95, 0.80, 0.35 },
                    })
                end
                if T.UI_SetWarnThreshold then T.UI_SetWarnThreshold(30) end
            end,
        },
    }

    LAM:RegisterOptionControls(HE.name .. "Timers", options)
end
