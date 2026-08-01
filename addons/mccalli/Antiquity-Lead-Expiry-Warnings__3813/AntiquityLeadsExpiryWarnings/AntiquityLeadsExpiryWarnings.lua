ALEW = {}
ALEW.name = "AntiquityLeadsExpiryWarnings"

ALEW.SLASH_COMMAND="/alew"

ALEW.SECONDS_PER_DAY = 86400

ALEW.NORMAL_MESSAGE_COLOR = "|cFFFFFF"    -- white
ALEW.WARNING_MESSAGE_COLOR = "|cFF0000"   -- red

ALEW.SAVED_VARIABLES_FILENAME = "AntiquityLeadsExpiryWarnings_SavedVariables"
ALEW.SAVED_VARIABLES_VERSION = 4

ALEW.CONSOLE_OPTIONS_ALL = "All"
ALEW.CONSOLE_OPTION_EXPIRING_ONLY = "Expiring"
ALEW.CONSOLE_OPTIONS_NONE = "None"


function ALEW.IsWithinWarningThreshold(secondsRemaining)
    local isWithinThreshold

    if secondsRemaining == 0 then
        isWithinThreshold = false; -- this skips non-expiring leads, which return 0 as their thresholds
    else
        isWithinThreshold = secondsRemaining <= ALEW.SECONDS_PER_DAY * ALEW.savedVars.thresholdDays
    end

    return isWithinThreshold
end

function ALEW.Notification(message, secondsRemaining)
    local isExpiryMessage = ALEW.IsWithinWarningThreshold(secondsRemaining)

    if ALEW.savedVars.showInConsoleOptions ~= ALEW.CONSOLE_OPTIONS_NONE then
        if (ALEW.savedVars.showInConsoleOptions == ALEW.CONSOLE_OPTIONS_ALL) or isExpiryMessage then
            if (secondsRemaining ~= 0) or (secondsRemaining == 0 and ALEW.savedVars.suppressNonExpiringLeads == false) then
                d(message)
            end
        end
    end

    if isExpiryMessage then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)

        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        messageParams:SetText(message)

        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end
end

function ALEW.CheckAntiquityLeadsExpiry()
    local antiquities = ALEW.GetAntiquityLeads()

    for i = 1, #antiquities, 1 do
        local antiquity = antiquities[i]

        local secondsRemaining = GetAntiquityLeadTimeRemainingSeconds(antiquity.id)
        local formattedTimeRemaining = ZO_FormatTime(secondsRemaining, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_TWELVE_HOUR)
	local messageTextColor = (ALEW.IsWithinWarningThreshold(secondsRemaining) and ALEW.WARNING_MESSAGE_COLOR or ALEW.NORMAL_MESSAGE_COLOR) 
	
        local antiquityColorDef = GetAntiquityQualityColor(antiquity.difficulty)
        local coloredAntiquityName = antiquityColorDef:Colorize(antiquity.name)

        local antiquityMessage = string.format("%s %slead ", coloredAntiquityName, messageTextColor)

        if ALEW.savedVars.includeZoneInMessage then
            antiquityMessage = string.format("%s in %s ", antiquityMessage, antiquity.zone)
        end

        if secondsRemaining == 0 then
            antiquityMessage = antiquityMessage .. "does not expire"
        else
            antiquityMessage = string.format("%s expires in %s", antiquityMessage, formattedTimeRemaining)
        end

        ALEW.Notification(antiquityMessage, secondsRemaining)
    end
end

function ALEW.GetAntiquityLeads()
    local leads = {}
	
    local antiquityId = GetNextAntiquityId()
    while antiquityId do
        local haveLead = DoesAntiquityHaveLead(antiquityId)
        
        if haveLead then
            local setId = GetAntiquitySetId(antiquityId)
            local rewardName = GetAntiquitySetName(setId)
            local rewardQuality = GetAntiquitySetQuality(setId)
            local rewardId = GetAntiquityRewardId(antiquityId)
			
            if rewardName == "" then
                rewardName = REWARDS_MANAGER:GetRewardContextualTypeString(rewardId)
                rewardQuality = GetAntiquityQuality(antiquityId)
            end
			
            local antiquityDifficulty = GetAntiquityDifficulty(antiquityId)
            if rewardQuality < ANTIQUITY_DIFFICULTY_ADVANCED then
                antiquityDifficulty = rewardQuality
            end
			
            leads[#leads+1] = {
                id = antiquityId,
                name = zo_strformat("<<C:1>>", GetAntiquityName(antiquityId)),
                difficulty = antiquityDifficulty,
                zone = zo_strformat("<<C:1>>", GetZoneNameById(GetAntiquityZoneId(antiquityId))),
                reward = {
                    name = zo_strformat("<<C:1>>", rewardName),
                    quality = rewardQuality,
                },
            }
        end
        antiquityId = GetNextAntiquityId(antiquityId)
    end

    table.sort(leads, ALEW.LeadSortOrderComparator)

    return leads
end

function ALEW.LeadSortOrderComparator(lead1, lead2)
    -- Bit inelegant this, because otherwise lua throws an 'invalid order for sorting' error
    -- We sort by difficulty first to group them, putting the most difficult at the end.
    -- After difficulty, we sort alphabetically

    if lead1.difficulty < lead2.difficulty then
        return true
    elseif lead1.difficulty > lead2.difficulty then
        return false
    elseif lead1.name < lead2.name then
        return true
    else
        return false
    end
end

function ALEW.RegisterSlashCommands()
    local lsc = LibSlashCommander

    if lsc then 
        local cmd 
        cmd = lsc:Register(ALEW.SLASH_COMMAND, ALEW.CheckAntiquityLeadsExpiry, "List antiquity lead expiries and warnings")
    else
        SLASH_COMMANDS[ALEW.SLASH_COMMAND] = ALEW.CheckAntiquityLeadsExpiry
    end
end

function ALEW.OnAddonLoaded(event, addonName)
    if addonName == ALEW.name then
        EVENT_MANAGER:UnregisterForEvent(ALEW.name, EVENT_ADD_ON_LOADED)

	ALEW.DefaultSettings = {
            thresholdDays = 7,
            showInConsoleOptions = ALEW.CONSOLE_OPTIONS_ALL,
            pauseAtStartUpInSeconds = 5,
            suppressNonExpiringLeads = true,
            includeZoneInMessage = true
        }

	ALEW.savedVars = ZO_SavedVars:NewAccountWide(ALEW.SAVED_VARIABLES_FILENAME, ALEW.SAVED_VARIABLES_VERSION, nil, ALEW.DefaultSettings, GetWorldName())

        EVENT_MANAGER:RegisterForEvent(ALEW.name, EVENT_PLAYER_ACTIVATED, ALEW.OnPlayerActivated)

    end
end

function ALEW.OnUpdateEvent()
    EVENT_MANAGER:UnregisterForUpdate(ALEW.name)
 
    ALEW.CreateAddOnSettingsMenu() 
    ALEW.RegisterSlashCommands()
    ALEW.CheckAntiquityLeadsExpiry()
end

function ALEW.OnPlayerActivated(eventCode, initial)
    EVENT_MANAGER:UnregisterForEvent(ALEW.name, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:RegisterForUpdate(ALEW.name, ALEW.savedVars.pauseAtStartUpInSeconds * 1000, ALEW.OnUpdateEvent) -- time delay is in millis, hence conversion
end

function ALEW.CreateAddOnSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Antiquity Leads Expiry Warnings",
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
            name = "Show lead expiries in console",
            tooltip = "Will show when the leads expire in the console on login or running " .. ALEW.SLASH_COMMAND,
            choices = {ALEW.CONSOLE_OPTIONS_ALL, ALEW.CONSOLE_OPTION_EXPIRING_ONLY, ALEW.CONSOLE_OPTIONS_NONE},
            getFunc = function() return ALEW.savedVars.showInConsoleOptions end,
            setFunc = function(value) ALEW.savedVars.showInConsoleOptions = value end,
            width = "full",
        },
        [4] = {
            type = "checkbox",
            name = "Include zone name in messages",
            tooltip = "If checked, will show which zone the lead is for, along with the expiry time.",
            getFunc = function() return ALEW.savedVars.includeZoneInMessage end,
            setFunc = function(value) ALEW.savedVars.includeZoneInMessage = value end,
            width = "full",
        },
        [5] = {
            type = "checkbox",
            name = "Supress leads without expiry in console",
            tooltip = "Some leads have no expiry - selecting this option will ensure they are not printed in the console. Note that leads with no expiry will never be shown as on-screen warnings.",
            getFunc = function() return ALEW.savedVars.suppressNonExpiringLeads end,
            setFunc = function(value) ALEW.savedVars.suppressNonExpiringLeads = value end,
            width = "full",
        },
        [6] = {
            type = "slider",
            name = "Expiry Threshold",
            tooltip = "If the remaing expiry dips below these days is checked, you will be warned on-screen. Setting to 0 means that no warnings will be shown on-screen.",
            min = 0,
            max = 30,
            step = 1,
            getFunc = function() return ALEW.savedVars.thresholdDays end,
            setFunc = function(value) ALEW.savedVars.thresholdDays = value end,
            width = "full",
        
        },
        [7] = {
            type = "slider",
            name = "Pause at startup (in seconds)",
            tooltip = "Other add-ons can take a while to load, set a higher value here if you would like to see your report near the end",
            min = 1,
            max = 60,
            step = 1,
            getFunc = function() return ALEW.savedVars.pauseAtStartUpInSeconds end,
            setFunc = function(value) ALEW.savedVars.pauseAtStartUpInSeconds = value end,
            width = "full",
        
        },

    }

    local panelName = ALEW.name .. "SettingsPanel"

    local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end


EVENT_MANAGER:RegisterForEvent(ALEW.name, EVENT_ADD_ON_LOADED, ALEW.OnAddonLoaded)
