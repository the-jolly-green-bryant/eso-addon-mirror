-- Addon Settings Menu File
local LAM = LibAddonMenu2

function CurrencyTracker.InitializeLAM()
    -- LibAddonMenu-2.0 Setup
    local saveData = CurrencyTracker.savedVariables

    -- Test if addon is launched for first time for each value picked by user
    if saveData.displayAddonLoadedMessage == nil then
        saveData.displayAddonLoadedMessage = true
    end

    if saveData.eventTickets == nil then
        saveData.eventTickets = {}
    end
    if saveData.eventTickets.tracking == nil then
        saveData.eventTickets.tracking = true
    end
    if saveData.eventTickets.GUILeft == nil then
        saveData.eventTickets.GUILeft = 1800
    end
    if saveData.eventTickets.GUITop == nil then
        saveData.eventTickets.GUITop = 400
    end
    if saveData.eventTickets.alwaysDisplay == nil then
        saveData.eventTickets.alwaysDisplay = false
    end
    if saveData.eventTickets.amountThreshold == nil then
        saveData.eventTickets.amountThreshold = 10
    end

    if saveData.writVouchers == nil then
        saveData.writVouchers = {}
    end
    if saveData.writVouchers.tracking == nil then
        saveData.writVouchers.tracking = true
    end
    if saveData.writVouchers.GUILeft == nil then
        saveData.writVouchers.GUILeft = 1800
    end
    if saveData.writVouchers.GUITop == nil then
        saveData.writVouchers.GUITop = 450
    end
    if saveData.writVouchers.alwaysDisplay == nil then
        saveData.writVouchers.alwaysDisplay = false
    end
    if saveData.writVouchers.amountThreshold == nil then
        saveData.writVouchers.amountThreshold = 200
    end

    local settingsPanel
    local settingsPanelName = CurrencyTracker.name .. "SettingsPanel"
    local settingsPanelData = {
        type = "panel",
        name = CurrencyTracker.name,
        author = CurrencyTracker.author,
        version = CurrencyTracker.version,
        website = CurrencyTracker.website
    }

    local settingsOptionsData = {{
        type = "header",
        name = "general"
    }, {
        type = "checkbox",
        name = "Enable start message",
        getFunc = function()
            return saveData.displayAddonLoadedMessage
        end,
        setFunc = function(value)
            saveData.displayAddonLoadedMessage = value
        end
    }, {
        type = "header",
        name = "Event tickets"
    }, {
        type = "checkbox",
        name = "Enable event tickets tracking",
        getFunc = function()
            return saveData.eventTickets.tracking
        end,
        setFunc = function(value)
            saveData.eventTickets.tracking = value
        end
    }, {
        type = "checkbox",
        name = "Hide warning when amount is under treshold",
        getFunc = function()
            return not saveData.eventTickets.alwaysDisplay
        end,
        setFunc = function(value)
            saveData.eventTickets.alwaysDisplay = not value
        end
    }, {
        type = "slider",
        name = "Amount required to trigger display",
        min = 0,
        max = 12,
        getFunc = function()
            return saveData.eventTickets.amountThreshold
        end,
        setFunc = function(value)
            saveData.eventTickets.amountThreshold = value
            CurrencyTracker.EventTickets.OnAmountThresholdChanged()
        end
    }, {
        type = "header",
        name = "Writ vouchers"
    }, {
        type = "checkbox",
        name = "Enable writ vouchers tracking",
        getFunc = function()
            return saveData.writVouchers.tracking
        end,
        setFunc = function(value)
            saveData.writVouchers.tracking = value
        end
    }, {
        type = "checkbox",
        name = "Hide warning when amount is under treshold",
        getFunc = function()
            return not saveData.writVouchers.alwaysDisplay
        end,
        setFunc = function(value)
            saveData.writVouchers.alwaysDisplay = not value
        end
    }, {
        type = "slider",
        name = "Amount required to trigger display",
        min = 0,
        max = 10000,
        getFunc = function()
            return saveData.writVouchers.amountThreshold
        end,
        setFunc = function(value)
            saveData.writVouchers.amountThreshold = value
            CurrencyTracker.WritVouchers.OnAmountThresholdChanged()
        end
    }}

    settingsPanel = LAM:RegisterAddonPanel(settingsPanelName, settingsPanelData)
    LAM:RegisterOptionControls(settingsPanelName, settingsOptionsData)
end
