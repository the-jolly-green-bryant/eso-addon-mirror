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
        version = H.version or "0.0.24",
        slashCommand = "/hdsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local playChoices = { "Once (park at end)", "Loop" }
    local playValues  = { "once", "loop" }

    local optionsData = {
        { type = "header", name = "About" },
        {
            type = "description",
            text = "|cC0E0FF/hd plant|r  →  |cC0E0FF/hd list|r  →  |cC0E0FF/hd load N|r  →  |cC0E0FF/hd play|r\n"
                .. "Library picker is |cC0E0FF/hd list|r (left). Cue card is the legend (right).",
        },

        { type = "header", name = "Playback" },
        {
            type = "dropdown",
            name = "When playback ends",
            tooltip = "Once parks ghosts at the last pose (training). Loop only if you want the movie to restart by itself.",
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
            name = "Boss / mini names on pins",
            tooltip = "World labels from the pack (Vashai vs S'kinrai). Also: /hd names on|off",
            getFunc = function() return sv.namesOn ~= false end,
            setFunc = function(v)
                sv.namesOn = (v == true)
                if type(H.ApplyTimeline) == "function" then
                    H.ApplyTimeline(H.playT or 0, false)
                end
                if type(H.RefreshUI) == "function" then H.RefreshUI() end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Path rings / dots on",
            tooltip = "Sandbox path overlay.",
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
            name = "Fight frame (dots / split / 30s path)",
            tooltip = "After load: room-size ring, N/E/S/W, gold split line (Twins candles), first 30s of boss paths. Plant is the fight center.",
            getFunc = function() return sv.frameOn ~= false end,
            setFunc = function(v)
                sv.frameOn = (v == true)
                if type(H.RebuildPathGfx) == "function" then H.RebuildPathGfx() end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Portal! alert on pad windows",
            tooltip = "Banner + glowing floor pads for this pack's teleports, and two tag marks per side while adds are up. Also: /hd alerts on|off",
            getFunc = function() return sv.alertsOn ~= false end,
            setFunc = function(v)
                sv.alertsOn = (v == true)
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
