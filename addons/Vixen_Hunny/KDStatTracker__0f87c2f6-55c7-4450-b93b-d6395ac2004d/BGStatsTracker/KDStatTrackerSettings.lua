KDStatTracker = KDStatTracker or {}
KDStatTrackerUI = KDStatTrackerUI or {}
KDStatTracker.name = "KDStatTracker"
KDStatTracker.version = "3.0"
KDStatTracker.author = "Vixen Hunny"
KDStatTracker.isLoaded = KDStatTracker.isLoaded or false
KDStatTrackerSettings = KDStatTrackerSettings or {}
KDStatTracker.default_settings = {
    showKD = true,
    scale = 1.0,
    fontSize = 18,
    x = 500,
    y = 500,
    fontColor = "FFFFFF",
}

function CreateSettingsMenu()
    local LAM2 = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "KDStatTracker",
        displayName = "|cD4266FKDStat|r|c8822AATracker|r",
        author = KDStatTracker.author,
        version = KDStatTracker.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    KDStatTrackerSettings.settingsPanel = LAM2:RegisterAddonPanel("KDStatTrackerSettingsPanel", panelData)
    EVENT_MANAGER:UnregisterForEvent(KDStatTracker.name, EVENT_ADD_ON_LOADED)
    KDStatTracker.db = ZO_SavedVars:NewAccountWide("KDStatTrackerSettings", 1, nil, KDStatTracker.default_settings)

    local optionsData = {
        {
            type = "header",
            name = "|cD4266FDisplay Settings|r",
        },
        {
            type = "checkbox",
            name = "Show KD Display",
            tooltip = "Toggle the stat tracker panel on or off.",
            getFunc = function() return KDStatTracker.db.showKD end,
            setFunc = function(v)
                KDStatTracker.db.showKD = v
                KDStatTrackerUI.UpdateVisibility()
            end,
        },
        {
            type = "slider",
            name = "UI Scale",
            tooltip = "Adjust the size of the tracker panel.",
            min = 50, max = 200, step = 5,
            getFunc = function() return math.floor((KDStatTracker.db.scale or 1.0) * 100) end,
            setFunc = function(v)
                KDStatTracker.db.scale = v / 100
                if KDStatTrackerUI.kdDisplay then
                    KDStatTrackerUI.kdDisplay:SetScale(v / 100)
                end
            end,
            default = 100,
        },
        {
            type = "slider",
            name = "Font Size",
            tooltip = "Adjust the base font size for the panel.",
            min = 12, max = 36, step = 1,
            getFunc = function() return KDStatTracker.db.fontSize end,
            setFunc = function(v)
                KDStatTracker.db.fontSize = v
                KDStatTrackerUI.CreateUI()
            end,
            default = 18,
        },
        {
            type = "editbox",
            name = "Font Color (Hex)",
            tooltip = "Set the hex color for chat messages (e.g. FFFFFF for white).",
            getFunc = function() return KDStatTracker.db.fontColor end,
            setFunc = function(v)
                KDStatTracker.db.fontColor = v
                KDStatTrackerUI.CreateUI()
            end,
            default = "FFFFFF",
        },
        {
            type = "header",
            name = "|cD4266FPosition|r",
        },
        {
            type = "slider",
            name = "X Position",
            min = 0, max = GuiRoot:GetWidth(), step = 1,
            getFunc = function() return KDStatTracker.db.x end,
            setFunc = function(v)
                KDStatTracker.db.x = v
                KDStatTrackerUI.CreateUI()
            end,
            default = 500,
        },
        {
            type = "slider",
            name = "Y Position",
            min = 0, max = GuiRoot:GetHeight(), step = 1,
            getFunc = function() return KDStatTracker.db.y end,
            setFunc = function(v)
                KDStatTracker.db.y = v
                KDStatTrackerUI.CreateUI()
            end,
            default = 500,
        },
        {
            type = "button",
            name = "Reset Position",
            tooltip = "Reset the panel to its default position.",
            func = function()
                KDStatTracker.db.x = 500
                KDStatTracker.db.y = 500
                KDStatTrackerUI.CreateUI()
            end,
        },
        {
            type = "header",
            name = "|cD4266FData|r",
        },
        {
            type = "button",
            name = "Reset Killstreak History",
            tooltip = "Clear all saved killstreak records.",
            warning = "This will permanently delete all killstreak history!",
            func = function()
                if KDStatTracker.savedVars then
                    KDStatTracker.savedVars.killStreakHistory = {}
                    KDStatTracker.savedVars.totalKillStreaks = 0
                    KDStatTrackerUI.UpdateUI()
                    d("|cD4266F[KDStatTracker]|r Killstreak history cleared.")
                end
            end,
        },
    }

    LAM2:RegisterOptionControls("KDStatTrackerSettingsPanel", optionsData)
end

EVENT_MANAGER:RegisterForEvent(KDStatTracker.name .. "Settings", EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == "KDStatTracker" and KDStatTracker.isLoaded == true then
        CreateSettingsMenu()
    end
end)
