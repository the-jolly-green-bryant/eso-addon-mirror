local ADDON_NAME = "DuesPaid"
local ADDON_AUTHOR = "tuckerscorpions"
local ADDON_VERSION = "3.7"
local ADDON_TITLE = "Dues Paid"
local ADDON_TITLE_DISPLAY = "|c00ff00Dues Paid|r"
local ADDON_SAVEDVARS = "DuesPaid_Settings"
local shown = true
local firstTimeRun = true
DUESPAIDTable = DUESPAIDTable or {}
local DUESPAID = DUESPAIDTable
DUESPAID.Settings = {}
DUESPAID.Defaults = {SavedSettings = {DUESPAID.showMessage, DUESPAID.day, DUESPAID.messageHeader, DUESPAID.message, DUESPAID.popupOrNotification}}
local LAM2 = LibAddonMenu2


----------------------------------------------------------------------------------
-- pay dues message --
----------------------------------------------------------------------------------

-- Libraries
local LN = LibNotifications
local LN_provider = LN:CreateProvider()

local function RemoveNotification(notificationId)
    local provider = LN_provider
    table.remove(provider.notifications, notificationId)
    provider:UpdateNotifications()
end
 
local function acceptNotification(data)
    DUESPAID.Settings.SavedSettings[1] = false
    RemoveNotification(data.notificationId)
end
 
local function declineNotification(data)
    DUESPAID.Settings.SavedSettings[1] = true
    RemoveNotification(data.notificationId)
end
-- Function to add custom notification
local function addNotification()
    -- Custom notification info
    local msg = {
        dataType                = NOTIFICATIONS_YES_NO_DATA,
        secsSinceRequest        = ZO_NormalizeSecondsSince(0),
        message                 = DUESPAID.Settings.SavedSettings[4],
        heading                 = DUESPAID.Settings.SavedSettings[3],
        texture                 = "EsoUI/Art/bank/bank_tabicon_deposit_down.dds",
        shortDisplayText        = "!",
        controlsOwnSounds       = false,
        keyboardAcceptCallback  = function(data) acceptNotification(data) end,
        keybaordDeclineCallback = function(data) declineNotification(data) end,
        gamepadAcceptCallback   = function(data) acceptNotification(data) end,
        gamepadDeclineCallback  = function(data) declineNotification(data) end,
        }
        if shown == true then
            shown = false
    LN_provider.notifications[1] = msg
    LN_provider:UpdateNotifications()
    end
end

local function popupMenu()
    if firstTimeRun == true then
    local question = string.sub(DUESPAID.Settings.SavedSettings[4],1,50)
    local title = string.sub(DUESPAID.Settings.SavedSettings[3],1,25)
    DuesPaidXMLBackdropOutput:SetText(question)
    DuesPaidXMLBackdropTitle:SetText(title)
    DuesPaidXML:SetHidden(false)
    DuesPaidXMLBackdropButtonYES:SetText("YES")
    DuesPaidXMLBackdropButtonNO:SetText("NO")
    DuesPaidXMLBackdropButtonYES:ClearAnchors()
    DuesPaidXMLBackdropButtonYES:SetAnchor(BOTTOM,DuesPaidXMLBackdrop, BOTTOM, -100, -15 )
    DuesPaidXMLBackdropButtonNO:SetAnchor(BOTTOM,DuesPaidXMLBackdrop, BOTTOM, 100, -15 )
    DuesPaidXMLBackdropOutput:SetAnchor(CENTER,DuesPaidXMLBackdrop, CENTER, 0, -6 )
    firstTimeRun = false
    end
end

function DUESPAIDTable.resetWindowClose(settingChoice)
    if shown == true then
        shown = false
    end       
    if settingChoice == true then 
        DUESPAID.Settings.SavedSettings[1] = false
    else
        DUESPAID.Settings.SavedSettings[1] = true  
    end
end

local function DayAndMessage()
    local doIShowTheMessage = DUESPAID.Settings.SavedSettings[1]
    local day = DUESPAID.Settings.SavedSettings[2]
    local popupOrNotify = DUESPAID.Settings.SavedSettings[5]
    local dayOfTheWeek = os.date("%A")
    if day ~= dayOfTheWeek then
        DUESPAID.Settings.SavedSettings[1] = true
    end
    if day == dayOfTheWeek then 
        if shown == true then
            if doIShowTheMessage == true then
                if popupOrNotify == "Popup Window" then
                    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, 1, popupMenu)           
                else 
                    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, 1, addNotification)
                end
            end
        end
    end
end



-----------------------------------------------------------------------------------
--  Menu Functions --
-----------------------------------------------------------------------------------


local function SettingsMenu()  
    local panelData = {
        type = "panel",
        name = ADDON_TITLE,    
        displayName = ADDON_TITLE_DISPLAY,   
        author = "|cff0000TuckerScorpions|r",   
        version = ADDON_VERSION,    
        slash_numCommand = "/duespaid",	   
        registerForRefresh = true,	
        registerForDefaults = true,	
    } 
    LAM2:RegisterAddonPanel(ADDON_NAME, panelData) 
    
    local optionsTable = {
        [1] = {
            type = "header",
            name = "Dues Paid Settings",
            width = "full",	
        },
        [2] = {
            type = "dropdown",  
            name = "What Window to display?",   
            tooltip = "popup or notifications",    
            choices = {"Popup Window", "Notification Window"},   
            getFunc = function() return DUESPAID.Settings.SavedSettings[5] end,    
            setFunc = function(var) 
                DUESPAID.Settings.SavedSettings[5] = var
                DUESPAID.Settings.SavedSettings[1] = true
             end,   
            width = "full",  
            warning = "Will need to reload the UI.",
        },
        [3] = {
            type = "dropdown",  
            name = "Day to show the message:",   
            tooltip = "Day for Message",    
            choices = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"},   
            getFunc = function() return DUESPAID.Settings.SavedSettings[2] end,    
            setFunc = function(var) DUESPAID.Settings.SavedSettings[2] = var end,   
            width = "full",  
            warning = "Will need to reload the UI.",
        },
        [4] = {
            type = "editbox",
            name = "Message header:",
            tooltip = "Message header",
            getFunc = function() return DUESPAID.Settings.SavedSettings[3] end,
            setFunc = function(text) DUESPAID.Settings.SavedSettings[3] = text end,
            isMultiline = false,	
            isExtraWide = false,
            width = "full",	
            default = DUESPAID.Defaults.SavedSettings[3],
            warning = "Limit 25 characters",
        },
        [5] = {
            type = "editbox",
            name = "Message to display:",
            tooltip = "Message to display",
            getFunc = function() return DUESPAID.Settings.SavedSettings[4] end,
            setFunc = function(text) DUESPAID.Settings.SavedSettings[4] = text end,
            isMultiline = false,	
            isExtraWide = true,
            width = "full",	
            default = DUESPAID.Defaults.SavedSettings[4], 
            warning = "Limit 50 characters",   
        },
    }
        
    LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)
end

-- ===============================================================================
-- Load addon into memory
-- ===============================================================================

local function OnAddonLoaded(event, addon)	
	DUESPAID.Settings = ZO_SavedVars:NewAccountWide(ADDON_SAVEDVARS, ADDON_VERSION, "Settings", DUESPAID.Defaults)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    DayAndMessage()	   
    SettingsMenu()	
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)