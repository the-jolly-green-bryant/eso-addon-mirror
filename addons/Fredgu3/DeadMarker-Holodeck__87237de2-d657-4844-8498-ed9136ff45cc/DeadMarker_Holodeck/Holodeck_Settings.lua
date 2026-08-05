--=====================================================================
-- Holodeck_Settings.lua — LibAddonMenu preferences (v0.0.10)
-- Slash stays for actions; this panel is "set and forget" policy.
--=====================================================================

local H = Holodeck
if not H then return end

local function dhd(msg)
    d(string.format("|c69c0ff[%s]|r %s", H.displayName or "Holodeck", tostring(msg)))
end

function H.CreateSettingsMenu()
    local LAM = (LibStub and LibStub("LibAddonMenu-2.0", true))
        or _G["LibAddonMenu2"]
        or _G["LibAddonMenu-2.0"]
    if not LAM then
        dhd("LibAddonMenu-2.0 not found — settings panel skipped. Slash still works. /hd settings")
        return
    end

    local sv = H.savedVars
    if type(sv) ~= "table" then return end

    local panelData = {
        type = "panel",
        name = "DeadMarker Holodeck",
        displayName = "DeadMarker Holodeck",
        author = "Skye-Forge",
        version = H.version or "0.0.10",
        slashCommand = "/hdsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local startModeChoices = { "Manual only", "Any combat", "Boss bar only" }
    local startModeValues  = { "manual", "combat", "boss" }
    local playChoices = { "Once (park at end)", "Loop" }
    local playValues  = { "once", "loop" }

    local optionsData = {
        { type = "header", name = "About" },
        {
            type = "description",
            text = "Actions stay in chat: |cC0E0FF/hd plant|r · snap · play · arm · record …\n"
                .. "This menu is preferences only (auto-arm, panels, play default).",
        },

        { type = "header", name = "Recorder policy" },
        {
            type = "checkbox",
            name = "Auto-arm in dungeons / trials",
            tooltip = "When you enter a group instance, prepare the recorder (ARMED). Does not start sampling until combat rule matches.",
            getFunc = function() return sv.autoArmInInstances == true end,
            setFunc = function(v) sv.autoArmInInstances = v end,
            default = true,
        },
        {
            type = "dropdown",
            name = "Auto-start recording when…",
            tooltip = "Only applies while ARMED.\n• Manual: you /hd record start\n• Any combat: trash or boss\n• Boss bar only: skip most trash",
            choices = startModeChoices,
            choicesValues = startModeValues,
            getFunc = function() return sv.recordStartMode or "boss" end,
            setFunc = function(v) sv.recordStartMode = v end,
            default = "boss",
        },
        {
            type = "checkbox",
            name = "Auto-stop & apply when combat ends",
            tooltip = "On wipe/kill (leave combat), stop recording and load samples into sandbox for /hd play.",
            getFunc = function() return sv.recordAutoStop ~= false end,
            setFunc = function(v) sv.recordAutoStop = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Auto-save take to SavedVars",
            tooltip = "After auto-stop, also /hd save as rec_<timestamp>. Otherwise only sandbox until you save.",
            getFunc = function() return sv.recordAutoSave == true end,
            setFunc = function(v) sv.recordAutoSave = v end,
            default = false,
        },
        {
            type = "slider",
            name = "Sample interval (ms)",
            tooltip = "How often to sample positions while recording. Lower = smoother, more data.",
            min = 150,
            max = 1000,
            step = 50,
            getFunc = function() return tonumber(sv.recordIntervalMs) or 400 end,
            setFunc = function(v) sv.recordIntervalMs = v end,
            default = 400,
        },

        { type = "header", name = "What to capture" },
        {
            type = "description",
            text = "Holodeck is for |cC0E0FFteam training in a house|r — people walk the room themselves.\n"
                .. "Default: |cFFAA66bosses only|r (no ghost raid). Turn team on only if you want a video-style review of a real pull.",
        },
        {
            type = "checkbox",
            name = "Capture bosses (boss1–8)",
            tooltip = "Record boss-bar units for holodeck movement (recommended ON for training packs).",
            getFunc = function() return sv.recordCaptureBosses ~= false end,
            setFunc = function(v) sv.recordCaptureBosses = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Capture trial team (group members)",
            tooltip = "OFF (default): no group ghosts — your raid walks the holodeck live.\nON: sample other group members for pull review / “what we actually did”.",
            getFunc = function() return sv.recordCaptureTeam == true end,
            setFunc = function(v) sv.recordCaptureTeam = v end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Capture self",
            tooltip = "Record your own character path (e.g. OT kite). Usually OFF for shared training packs.",
            getFunc = function() return sv.recordCaptureSelf == true end,
            setFunc = function(v) sv.recordCaptureSelf = v end,
            default = false,
        },

        { type = "header", name = "Playback & panels" },
        {
            type = "dropdown",
            name = "Default play mode",
            choices = playChoices,
            choicesValues = playValues,
            getFunc = function() return sv.playMode or "once" end,
            setFunc = function(v)
                sv.playMode = v
                H.playMode = v
            end,
            default = "once",
        },
        {
            type = "checkbox",
            name = "Legend bar on",
            tooltip = "Bottom command strip. Toggle in-world with /hd legend on|off.",
            getFunc = function() return sv.legendOn ~= false end,
            setFunc = function(v)
                sv.legendOn = v
                if type(H.RefreshUI) == "function" then H.RefreshUI() end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Path sheet panel on",
            tooltip = "Stop list panel. /hd sheet on|off in the world.",
            getFunc = function() return sv.sheetOn == true end,
            setFunc = function(v)
                sv.sheetOn = v
                if type(H.RefreshUI) == "function" then H.RefreshUI() end
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Path rings / dots on",
            tooltip = "Ground path graphics. /hd path on|off.",
            getFunc = function() return sv.pathOn ~= false end,
            setFunc = function(v)
                sv.pathOn = v
                if type(H.RebuildPathGfx) == "function" then H.RebuildPathGfx() end
                if type(H.RefreshUI) == "function" then H.RefreshUI() end
            end,
            default = true,
        },

        { type = "header", name = "Display" },
        {
            type = "slider",
            name = "Boss icon size (m)",
            min = 0.5,
            max = 4,
            step = 0.1,
            getFunc = function() return tonumber(sv.bossSizeM) or 1.6 end,
            setFunc = function(v) sv.bossSizeM = v end,
            default = 1.6,
        },
        {
            type = "checkbox",
            name = "Debug chat",
            getFunc = function() return sv.debug == true end,
            setFunc = function(v) sv.debug = v end,
            default = false,
        },
    }

    local ok, err = pcall(function()
        LAM:RegisterAddonPanel("HolodeckSettingsPanel", panelData)
        LAM:RegisterOptionControls("HolodeckSettingsPanel", optionsData)
    end)
    if not ok then
        dhd("Settings menu failed: " .. tostring(err))
    else
        dhd("Settings: |cC0E0FF/hdsettings|r or Esc → Addons → DeadMarker Holodeck")
    end
end
