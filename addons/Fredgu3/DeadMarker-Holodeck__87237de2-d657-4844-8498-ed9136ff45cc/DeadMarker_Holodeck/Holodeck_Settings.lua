--=====================================================================
-- Holodeck_Settings.lua — LibAddonMenu preferences (v0.0.14)
-- Slash = actions; this panel = set-and-forget policy.
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
        dhd("LibAddonMenu-2.0 not found — settings panel skipped. Slash still works.")
        return
    end

    local sv = H.savedVars
    if type(sv) ~= "table" then return end

    local panelData = {
        type = "panel",
        name = "DeadMarker Holodeck",
        displayName = "DeadMarker Holodeck",
        author = "Skye-Forge",
        version = H.version or "0.0.18",
        slashCommand = "/hdsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local startModeChoices = { "Manual only", "Any combat", "Boss bar only" }
    local startModeValues  = { "manual", "combat", "boss" }
    local playChoices = { "Once (park at end)", "Loop" }
    local playValues  = { "once", "loop" }
    -- No "Off" here — the Capture elites checkbox is on/off. Tier only filters.
    local eliteChoices = {
        "Deadly only",
        "Hard + Deadly",
        "Normal +",
        "Any hostile on reticle (pack minis / captains)",
    }
    local eliteValues = { 1, 2, 3, 4 }

    local optionsData = {
        { type = "header", name = "About" },
        {
            type = "description",
            text = "Training packs are |cC0E0FFlean keyframes|r (boss/mini), not video streams.\n"
                .. "Actions: |cC0E0FF/hd|r …  ·  Texture kinds: |cC0E0FF/hd textures|r  ·  Probe: |cC0E0FF/hd record probe|r",
        },

        { type = "header", name = "Recorder policy" },
        {
            type = "checkbox",
            name = "Auto-arm in dungeons / trials",
            getFunc = function() return sv.autoArmInInstances == true end,
            setFunc = function(v) sv.autoArmInInstances = v end,
            default = true,
        },
        {
            type = "dropdown",
            name = "Auto-start recording when…",
            tooltip = "Only while ARMED.\nManual / any combat / boss bar only.\nPack elites often have NO boss bar — use Manual or Any combat.",
            choices = startModeChoices,
            choicesValues = startModeValues,
            getFunc = function() return sv.recordStartMode or "boss" end,
            setFunc = function(v) sv.recordStartMode = v end,
            default = "boss",
        },
        {
            type = "checkbox",
            name = "Auto-stop when combat ends",
            getFunc = function() return sv.recordAutoStop ~= false end,
            setFunc = function(v) sv.recordAutoStop = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Auto-save take",
            tooltip = "Saves lean pack with zone/target name. Empty takes are not saved.",
            getFunc = function() return sv.recordAutoSave == true end,
            setFunc = function(v) sv.recordAutoSave = v end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Require /hd plant before record",
            tooltip = "ON: refuse record start without plant. OFF: auto-plant at player (relative take).",
            getFunc = function() return sv.recordRequirePlant == true end,
            setFunc = function(v) sv.recordRequirePlant = v end,
            default = false,
        },
        {
            type = "slider",
            name = "Sample interval (ms)",
            tooltip = "Poll rate while recording. Lean mode still collapses to keyframes.",
            min = 150, max = 1000, step = 50,
            getFunc = function() return tonumber(sv.recordIntervalMs) or 400 end,
            setFunc = function(v) sv.recordIntervalMs = v end,
            default = 400,
        },

        { type = "header", name = "What to capture" },
        {
            type = "description",
            text = "Default: |cFFAA66bosses + reticle elites|r, no team ghosts.\n"
                .. "Elites: |cC0E0FFsoft aim|r (crosshair on mob) is enough — not only Tab hard-lock.\n"
                .. "Looking at adds while casting will sample them too if filter allows.\n"
                .. "Debug: |cC0E0FF/hd record probe|r with crosshair on the mob.",
        },
        {
            type = "checkbox",
            name = "Capture bosses (boss1–8 + reticle if no bar)",
            tooltip = "Boss bar units always. If no boss bar, aimed hostile can be stored as training boss.",
            getFunc = function() return sv.recordCaptureBosses ~= false end,
            setFunc = function(v) sv.recordCaptureBosses = v end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Capture elites via reticle (soft aim)",
            tooltip = "Samples unit under crosshair each tick (soft aim or hard-lock).\n"
                .. "Not a room scan — glance = sample if filter allows.\nON/OFF is this checkbox — not the tier dropdown.",
            getFunc = function() return sv.recordCaptureElites ~= false end,
            setFunc = function(v)
                sv.recordCaptureElites = v
                if v and (not sv.recordEliteTier or tonumber(sv.recordEliteTier) == 0) then
                    sv.recordEliteTier = 4
                end
            end,
            default = true,
        },
        {
            type = "dropdown",
            name = "Elite filter (when elites ON)",
            tooltip = "How picky when difficulty is known.\n"
                .. "Unknown difficulty: only high-HP (≥200k) or named mini/captain — NOT all trash.\n"
                .. "'Any hostile' = every hostile under the crosshair (can flood the take).\n"
                .. "Does NOT turn capture off (use checkbox above).",
            choices = eliteChoices,
            choicesValues = eliteValues,
            getFunc = function()
                local t = tonumber(sv.recordEliteTier) or 4
                if t < 1 then t = 4 end
                if t > 4 then t = 4 end
                return t
            end,
            setFunc = function(v) sv.recordEliteTier = v end,
            default = 4,
        },
        {
            type = "checkbox",
            name = "Capture trial team (group)",
            tooltip = "OFF default. ON = dense review mode with group ghosts.",
            getFunc = function() return sv.recordCaptureTeam == true end,
            setFunc = function(v) sv.recordCaptureTeam = v end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Capture self",
            getFunc = function() return sv.recordCaptureSelf == true end,
            setFunc = function(v) sv.recordCaptureSelf = v end,
            default = false,
        },

        { type = "header", name = "Sharing (consumers)" },
        {
            type = "description",
            text = "Most raiders only |cC0E0FFplant + open/play|r. Leaders build packs.\n"
                .. "Live group broadcast is stubbed; export/open works now.",
        },
        {
            type = "checkbox",
            name = "Accept shared packs (receive)",
            tooltip = "When ON, /hd share apply and future group broadcasts can load packs.\nTurn OFF if you never want remote packs applied.",
            getFunc = function() return sv.shareReceiveEnabled ~= false end,
            setFunc = function(v) sv.shareReceiveEnabled = v end,
            default = true,
        },

        { type = "header", name = "Your saves" },
        {
            type = "description",
            text = "Saved fights open in a |cC0E0FFworld panel|r (not this long settings list).\n"
                .. "Use the button below, or type |cC0E0FF/hd saves|r in chat.",
        },
        {
            type = "button",
            name = "Open saved fights panel",
            tooltip = "Shows a movable list: open with /hd open 1, /hd open last, or full id.",
            func = function()
                if type(H.ShowSavesPanel) == "function" then
                    H.ShowSavesPanel(true)
                    dhd("Saves panel opened — /hd open 1 .. n  ·  /hd saves off to close")
                else
                    dhd("Saves panel not ready — /reloadui or use /hd saves")
                end
            end,
        },

        { type = "header", name = "Playback & panels" },
        {
            type = "dropdown",
            name = "Default play mode",
            choices = playChoices,
            choicesValues = playValues,
            getFunc = function() return sv.playMode or "once" end,
            setFunc = function(v) sv.playMode = v; H.playMode = v end,
            default = "once",
        },
        {
            type = "checkbox",
            name = "Legend bar on",
            tooltip = "Bottom command strip. Also: /hd legend on|off",
            getFunc = function() return sv.legendOn == true or sv.legendOn == nil end,
            setFunc = function(v)
                sv.legendOn = (v == true)
                if type(H.RefreshUI) == "function" then H.RefreshUI() end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Path sheet panel on",
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
            getFunc = function() return sv.pathOn ~= false end,
            setFunc = function(v)
                sv.pathOn = v
                if type(H.RebuildPathGfx) == "function" then H.RebuildPathGfx() end
                if type(H.RefreshUI) == "function" then H.RefreshUI() end
            end,
            default = true,
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
    end
end
