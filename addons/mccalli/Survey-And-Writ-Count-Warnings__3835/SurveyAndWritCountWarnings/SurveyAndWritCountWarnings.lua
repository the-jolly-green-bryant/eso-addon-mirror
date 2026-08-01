SAWCW = {}
SAWCW.name = "SurveyAndWritCountWarnings"

SAWCW.SLASH_COMMAND="/sawcw"

SAWCW.SECONDS_PER_DAY = 86400
SAWCW.MAX_BAG_SIZE = 215

SAWCW.NORMAL_MESSAGE_COLOR = "|cFFFFFF"    -- white
SAWCW.WARNING_MESSAGE_COLOR = "|cFF0000"   -- red

SAWCW.SAVED_VARIABLES_FILENAME = "SurveyAndWritCountWarnings_SavedVariables"
SAWCW.SAVED_VARIABLES_VERSION = 1

SAWCW.CONSOLE_OPTIONS_ALL = "All"
SAWCW.CONSOLE_OPTION_THRESHOLD_WARNINGS_ONLY = "Threshold warnings"
SAWCW.CONSOLE_OPTIONS_NONE = "None"


function SAWCW.IsWithinWarningThreshold(secondsRemaining)
    local isWithinThreshold

    if secondsRemaining == 0 then
        isWithinThreshold = false; -- this skips non-expiring leads, which return 0 as their thresholds
    else
        isWithinThreshold = secondsRemaining <= SAWCW.SECONDS_PER_DAY * SAWCW.savedVars.writsWarningThreshold
    end

    return isWithinThreshold
end

function SAWCW.Notification(message, threshold, isWarning)
    if SAWCW.savedVars.showInConsoleOptions ~= SAWCW.CONSOLE_OPTIONS_NONE then
        if (SAWCW.savedVars.showInConsoleOptions == SAWCW.CONSOLE_OPTIONS_ALL) or isWarning then
            d(message)
        end
    end

    if (threshold ~= 0) and isWarning then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)

        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        messageParams:SetText(message)

        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end
end


function SAWCW.GetSurveyAndWritStats()
    local stats = {
        bagSize = GetBagSize(BAG_BACKPACK),
        writCount = 0,
        surveyCount = 0,
        surveyInventorySlotsCount = 0
    }

    for i = 1, stats.bagSize, 1 do
	local itemType, sItemType = GetItemType(BAG_BACKPACK, i)

        if itemType == ITEMTYPE_TROPHY and (sItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT) then
            stats.surveyInventorySlotsCount = stats.surveyInventorySlotsCount + 1

            local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_BACKPACK, i)
            stats.surveyCount = stats.surveyCount + stack
        elseif itemType == ITEMTYPE_MASTER_WRIT then
            stats.writCount = stats.writCount + 1
        end
    end

    return stats
end


function SAWCW.ReportSurveyAndWritStats()
    local stats = SAWCW.GetSurveyAndWritStats();
    local surveyWarningThresholdBreach = (SAWCW.savedVars.surveysWarningThreshold ~= 0) and (stats.surveyCount >= SAWCW.savedVars.surveysWarningThreshold)
    local surveyInventorySlotsWarningThresholdBreach = (SAWCW.savedVars.surveyInventorySlotsWarningThreshold ~= 0) and (stats.surveyInventorySlotsCount >= SAWCW.savedVars.surveyInventorySlotsWarningThreshold)
    local writWarningThresholdBreach = (stats.writCount >= SAWCW.savedVars.writsWarningThreshold)

    local surveyMessage = string.format("Carrying %d survey(s) in your inventory", stats.surveyCount)
    local surveyInventorySlotsMessage = string.format("Using %d inventory slots for surveys", stats.surveyInventorySlotsCount)
    local writMessage = string.format("Carrying %d writ(s) in your inventory", stats.writCount)

    if surveyWarningThresholdBreach then
        surveyMessage = string.format("%sWARNING: %s", SAWCW.WARNING_MESSAGE_COLOR, surveyMessage)
    end

    if surveyInventorySlotsWarningThresholdBreach then
        surveyInventorySlotsMessage = string.format("%sWARNING: %s", SAWCW.WARNING_MESSAGE_COLOR, surveyInventorySlotsMessage)
    end

    if writWarningThresholdBreach then
        writMessage = string.format("%sWARNING: %s", SAWCW.WARNING_MESSAGE_COLOR, writMessage)
    end
    
    SAWCW.Notification(surveyMessage, SAWCW.savedVars.surveysWarningThreshold, surveyWarningThresholdBreach)
    SAWCW.Notification(surveyInventorySlotsMessage, SAWCW.savedVars.surveyInventorySlotsWarningThreshold, surveyInventorySlotsWarningThresholdBreach)
    SAWCW.Notification(writMessage, SAWCW.savedVars.writsWarningThreshold, writWarningThresholdBreach)
end


function SAWCW.RegisterSlashCommands()
    local lsc = LibSlashCommander

    if lsc then 
        local cmd 
        cmd = lsc:Register(SAWCW.SLASH_COMMAND, SAWCW.ReportSurveyAndWritStats, "Report on surveys and writs in inventory")
    else
        SLASH_COMMANDS[SAWCW.SLASH_COMMAND] = SAWCW.ReportSurveyAndWritStats
    end
end


function SAWCW.OnAddonLoaded(event, addonName)
    if addonName == SAWCW.name then
        EVENT_MANAGER:UnregisterForEvent(SAWCW.name, EVENT_ADD_ON_LOADED)

	SAWCW.DefaultSettings = {
            showInConsoleOptions = SAWCW.CONSOLE_OPTIONS_ALL,
            pauseAtStartUpInSeconds = 5,
            writsWarningThreshold = 0,
            surveysWarningThreshold = 0,
            surveyInventorySlotsWarningThreshold = 0
        }

	SAWCW.savedVars = ZO_SavedVars:NewAccountWide(SAWCW.SAVED_VARIABLES_FILENAME, SAWCW.SAVED_VARIABLES_VERSION, nil, SAWCW.DefaultSettings, GetWorldName())

        EVENT_MANAGER:RegisterForEvent(SAWCW.name, EVENT_PLAYER_ACTIVATED, SAWCW.OnPlayerActivated)

    end
end

function SAWCW.OnUpdateEvent()
    EVENT_MANAGER:UnregisterForUpdate(SAWCW.name)
 
    SAWCW.CreateAddOnSettingsMenu() 
    SAWCW.RegisterSlashCommands()
    SAWCW.ReportSurveyAndWritStats();
end

function SAWCW.OnPlayerActivated(eventCode, initial)
    EVENT_MANAGER:UnregisterForEvent(SAWCW.name, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:RegisterForUpdate(SAWCW.name, SAWCW.savedVars.pauseAtStartUpInSeconds * 1000, SAWCW.OnUpdateEvent) -- time delay is in millis, hence conversion
end

function SAWCW.CreateAddOnSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Survey And Writ Count Warnings",
        author = "mccalli",
    }

    local optionsTable = {
        [1] = {
            type = "header",
            name = "Warnings Threshold",
            width = "full",
        },
        [2] = {
            type = "description",
            title = nil,	--(optional)
            text = "If the remaing expiry dips below these days, you will be warned on-screen",
            width = "full",
        },
        [3] = {
            type = "dropdown",
            name = "Show counts in console",
            tooltip = "Will show the count of how many surveys and writs you have in the console on login or running " .. SAWCW.SLASH_COMMAND,
            choices = {SAWCW.CONSOLE_OPTIONS_ALL, SAWCW.CONSOLE_OPTION_EXPIRING_ONLY, SAWCW.CONSOLE_OPTIONS_NONE},
            getFunc = function() return SAWCW.savedVars.showInConsoleOptions end,
            setFunc = function(value) SAWCW.savedVars.showInConsoleOptions = value end,
            width = "full",
        },
        [4] = {
            type = "slider",
            name = "Master Writs Warning Threshold",
            tooltip = "If you have this many master writs, you will be warned on-screen. Setting to 0 means that no warnings will be shown on-screen.",
            min = 0,
            max = SAWCW.MAX_BAG_SIZE,
            step = 1,
            getFunc = function() return SAWCW.savedVars.writsWarningThreshold end,
            setFunc = function(value) SAWCW.savedVars.writsWarningThreshold = value end,
            width = "full",
        
        },
        [5] = {
            type = "slider",
            name = "Crafting Surveys Warning Threshold",
            tooltip = "If you have this many crafting surveys, you will be warned on-screen. Setting to 0 means that no warnings will be shown on-screen.",
            min = 0,
            max = SAWCW.MAX_BAG_SIZE,
            step = 1,
            getFunc = function() return SAWCW.savedVars.surveysWarningThreshold end,
            setFunc = function(value) SAWCW.savedVars.surveysWarningThreshold = value end,
            width = "full",

        },
        [6] = {
            type = "slider",
            name = "Crafting Surveys Inventory Slot Warning Threshold",
            tooltip = "If you are using this many inventory slots for crafting surveys, you will be warned on-screen. Different to a pure count as surveys can be stacked. Setting to 0 means that no warnings will be shown on-screen.",
            min = 0,
            max = SAWCW.MAX_BAG_SIZE,
            step = 1,
            getFunc = function() return SAWCW.savedVars.surveyInventorySlotsWarningThreshold end,
            setFunc = function(value) SAWCW.savedVars.surveyInventorySlotsWarningThreshold = value end,
            width = "full",
        
        },
        [7] = {
            type = "slider",
            name = "Pause at startup (in seconds)",
            tooltip = "Other add-ons can take a while to load, set a higher value here if you would like to see your report near the end",
            min = 1,
            max = 60,
            step = 1,
            getFunc = function() return SAWCW.savedVars.pauseAtStartUpInSeconds end,
            setFunc = function(value) SAWCW.savedVars.pauseAtStartUpInSeconds = value end,
            width = "full",
        
        },

    }

    local panelName = SAWCW.name .. "SettingsPanel"

    local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end


EVENT_MANAGER:RegisterForEvent(SAWCW.name, EVENT_ADD_ON_LOADED, SAWCW.OnAddonLoaded)
