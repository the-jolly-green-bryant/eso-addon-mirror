local BA = BMGAdventures
BA.Settings = BA.Settings or {}

local function addLabel(panel, text)
    panel:AddSetting({ type=LibHarvensAddonSettings.ST_LABEL, label=text })
end

local function addSection(panel, text)
    panel:AddSetting({ type=LibHarvensAddonSettings.ST_SECTION, label=text })
end

local function rebuildPanel(panel)
    -- LibHarvensAddonSettings' documented console-safe way to rebuild a
    -- selected settings page so dynamic labels/heights are recalculated.
    if panel and panel.selected and panel.Select then
        panel.selected = false
        panel:Select()
    elseif panel and panel.RefreshSettings then
        panel:RefreshSettings()
    end
end

local function addButton(panel, label, text, fn, tooltip)
    panel:AddSetting({
        type=LibHarvensAddonSettings.ST_BUTTON,
        label=label,
        buttonText=text,
        tooltip=tooltip,
        clickHandler=function()
            fn()
            rebuildPanel(panel)
        end,
    })
end

local function challengeLabel(def)
    return function()
        local state = BA.account.challenges[def.id] or {v=0,c=false}
        local mark = state.c and "|c66FF66✓|r" or "|cAAAAAA•|r"
        return string.format("%s %s  [%d/%d]", mark, def.name, state.v or 0, def.goal or 1)
    end
end

function BA.Settings:Initialize()
    local LHA = LibHarvensAddonSettings
    if not LHA then
        d("|cFF4444[BMG Adventures]|r LibHarvensAddonSettings not found; settings panel disabled.")
        return
    end

    local panel = LHA:AddAddon("BMG Adventures", { allowDefaults=false, allowRefresh=true })
    if not panel then return end
    self.panel = panel

    addLabel(panel, "|cFFD700A BMG ADDON|r\nCreated and maintained by @BMGXSANCHO")

    addSection(panel, "Adventure Journal")
    panel:AddSetting({ type=LHA.ST_LABEL, label=function() return BA.Journal:GetSummary() end })

    addSection(panel, "Collections - Beta")
    panel:AddSetting({ type=LHA.ST_LABEL, label=function()
        if BA.CollectionEngine then return BA.CollectionEngine:GetSummary() end
        return "Collections unavailable."
    end })

    addSection(panel, "Settings")
    panel:AddSetting({ type=LHA.ST_CHECKBOX, label="Notifications", default=true,
        getFunction=function() return BA.settings.notifications end,
        setFunction=function(v) BA.settings.notifications=v end })
    panel:AddSetting({ type=LHA.ST_CHECKBOX, label="Leaderboard Participation", tooltip="Development build only. No data is submitted in dev2.5.", default=false,
        getFunction=function() return BA.settings.leaderboardEnabled end,
        setFunction=function(v) BA.settings.leaderboardEnabled=v end })

    addSection(panel, "Legacy Achievement Import")
    panel:AddSetting({ type=LHA.ST_LABEL, label=function() return BA.LegacyImport:GetSummary() end })
    panel:AddSetting({ type=LHA.ST_CHECKBOX, label="Automatic Legacy Import", tooltip="Scans ESO native achievement completion once on first activation. Nothing leaves the game.", default=true,
        getFunction=function() return BA.settings.autoLegacyImport ~= false end,
        setFunction=function(v) BA.settings.autoLegacyImport=v end })
    addButton(panel, "Re-scan Legacy Achievements", "Scan", function()
        BA.LegacyImport:Run(true)
    end)

    -- Developer actions are ordinary Harvens buttons again. The settings
    -- library owns vertical navigation/scrolling; BMG Adventures owns only
    -- what happens when a button is activated.
    addSection(panel, "Developer Tools")
    addButton(panel, "Simulate Quest", "Run", function() BA.DeveloperTools:Simulate("QUEST_COMPLETE", "DEV_QUEST", 1) end)
    addButton(panel, "Simulate POI", "Run", function() BA.DeveloperTools:Simulate("POI_DISCOVERED", "DEV_POI", 1) end)
    addButton(panel, "Simulate Trial", "Run", function() BA.DeveloperTools:Simulate("TRIAL_CLEAR", "ROCKGROVE", 1) end)
    addButton(panel, "Simulate Dungeon", "Run", function() BA.DeveloperTools:Simulate("DUNGEON_CLEAR", "DEV_DUNGEON", 1) end)
    addButton(panel, "Simulate BG Kill", "Run", function() BA.DeveloperTools:Simulate("BG_KILL", "DEV_TARGET", 1) end)
    addButton(panel, "Simulate Craft", "Run", function() BA.DeveloperTools:Simulate("CRAFT_COMPLETE", "DEV_CRAFT", 1) end)
    addButton(panel, "Stress Test 1,000 Events", "Run", function()
        BA.DeveloperTools:Stress(1000)
        d("[BMG Adventures] "..BA.DeveloperTools:GetMetricsString())
    end)
    addButton(panel, "Preview Profile Snapshot", "Print", function()
        d("[BMG Adventures Snapshot] "..BA.SnapshotBuilder:ToDebugString())
    end)
    addButton(panel, "Print Recent Native Diagnostics", "Print", function()
        d("[BMG Adventures Diagnostics]\n"..BA.DeveloperTools:GetRecentDiagnostics(20))
    end)
    addButton(panel, "Reset Development Profile", "Reset", function()
        BA.Profile:ResetForDevelopment()
        if BA.CollectionEngine then BA.CollectionEngine:ReconcileAll(false) end
        d("[BMG Adventures] Development profile reset.")
    end)
    panel:AddSetting({ type=LHA.ST_LABEL, label=function()
        return "Diagnostics: " .. BA.DeveloperTools:GetMetricsString()
    end })

    addSection(panel, "Native Activity Validation")
    panel:AddSetting({ type=LHA.ST_LABEL, label=function()
        return BA.DeveloperTools:GetNativeValidationSummary()
    end })

    -- Each challenge is its own settings row. This deliberately avoids one
    -- oversized multiline label and avoids left/right page controls. Harvens
    -- owns the normal console vertical scrolling for the complete list.
    addSection(panel, "Challenge Browser - Beta")
    for _, def in ipairs(BA.Challenges) do
        if not def.secret then
            panel:AddSetting({ type=LHA.ST_LABEL, label=challengeLabel(def) })
        end
    end
end
