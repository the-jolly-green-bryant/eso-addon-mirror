-- Lionas's Food & Drink Reminder
-- Author: Lionas
local PanelTitle = "Lionas's Food & Drink Reminder"
local Version = "1.0.0"
local Author = "Lionas"

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

LioFADRMenu = {}

function LioFADRMenu.LoadLAM2Panel()
    local PanelData = 
    {
        type = "panel",
        name = PanelTitle,
        author = Author,
        version = Version,
        slashCommand = "/lfdr",
    }
    local OptionsData = 
    {
        [1] =
        {
            type = "description",
            text = GetString(LIO_FADR_DESCRIPTION),
        },
        [2] = {
			      type = "header",
			      name = GetString(LIO_FADR_TOP_SETTING_HEADER)
        },
        [3] = 
        {
            type = "checkbox",
            name = GetString(LIO_FADR_ENABLE_ACCOUNTWIDE_TITLE),
            tooltip = GetString(LIO_FADR_ENABLE_ACCOUNTWIDE_TOOLTIP),
            default = LioFADR.savedVariables.useAccountWide,
            getFunc = 
              function() 
                return LionasFoodAndDrinkReminder_SavedPrefs.Default[GetDisplayName()]['$AccountWide']["useAccountWide"]
              end,
            setFunc = 
              function(value) 
                LionasFoodAndDrinkReminder_SavedPrefs.Default[GetDisplayName()]['$AccountWide']["useAccountWide"] = value
                ReloadUI()
              end,
            warning = GetString(LIO_FADR_UI_WARN),
        },
        [4] = 
        {
            type = "checkbox",
            name = GetString(LIO_FADR_ENABLE_TITLE),
            tooltip = GetString(LIO_FADR_ENABLE_TOOLTIP),
            default = LioFADR.savedVariables.enable,
            getFunc = 
              function() 
                return LioFADR.savedVariables.enable
              end,
            setFunc = 
              function(value) 
                LioFADR.savedVariables.enable = value
				        if(value) then
					        LioFADR.setEnable()
			          else
                  LioFADR.setDisable()
                end
              end,
        },
        [5] = 
        {
            type = "slider",
            name = GetString(LIO_FADR_NOTIFY_THRESHOLD_TITLE),
            tooltip = GetString(LIO_FADR_NOTIFY_THRESHOLD_TOOLTIP),
            min = 1,
            max = 60,
            step = 1,
            default = 3,
            getFunc = 
              function() 
                return LioFADR.savedVariables.notifyThresholdMins
              end,
            setFunc = 
              function(value) 
                LioFADR.savedVariables.notifyThresholdMins = value
              end,
        },
        [6] = 
        {
            type = "checkbox",
            name = GetString(LIO_FADR_NOTIFY_IN_DUNGEON_TITLE),
            tooltip = GetString(LIO_FADR_NOTIFY_IN_DUNGEON_TOOLTIP),
            default = LioFADR.savedVariables.notifyInDungeon,
            getFunc = 
              function() 
                return LioFADR.savedVariables.notifyInDungeon
              end,
            setFunc = 
              function(value)
                LioFADRCommon.clearTable(LioFADR.notifyFirst)
                LioFADR.savedVariables.notifyInDungeon = value
              end,
        },
        [7] =
        {
            type = "checkbox",
            name = GetString(LIO_FADR_ENABLE_NOTIFY_TO_CHAT_TITLE),
            tooltip = GetString(LIO_FADR_ENABLE_NOTIFY_TO_CHAT_TOOLTIP),
            default = LioFADR.savedVariables.enableToChat,
            getFunc =
            function()
                return LioFADR.savedVariables.enableToChat
            end,
            setFunc =
            function(value)
                LioFADR.savedVariables.enableToChat = value
            end,
        },
        [8] =
        {
            type = "checkbox",
            name = GetString(LIO_FADR_ENABLE_NONE_TITLE),
            tooltip = GetString(LIO_FADR_ENABLE_NONE_TOOLTIP),
            default = LioFADR.savedVariables.enableNotifyAlreadyNone,
            getFunc =
            function()
                return LioFADR.savedVariables.enableNotifyAlreadyNone
            end,
            setFunc =
            function(value)
                LioFADR.savedVariables.enableNotifyAlreadyNone = value
            end,
        },
        [9] =
        {
            type = "checkbox",
            name = GetString(LIO_FADR_ENABLE_NOTIFY_ICON_TITLE),
            tooltip = GetString(LIO_FADR_ENABLE_NOTIFY_ICON_TOOLTIP),
            default = LioFADR.savedVariables.enableNotifyIcon,
            getFunc =
            function()
                return LioFADR.savedVariables.enableNotifyIcon
            end,
            setFunc =
            function(value)
                LioFADR.savedVariables.enableNotifyIcon = value
            end,
        },
        [10] = {
			      type = "header",
			      name = GetString(LIO_FADR_ZONE_SETTING_HEADER)
        },
        [11] =
        {
            type = "checkbox",
            name = GetString(LIO_FADR_NOTIFY_BY_ZONE_CHANGING_TITLE),
            tooltip = GetString(LIO_FADR_NOTIFY_BY_ZONE_CHANGING_TOOLTIP),
            default = LioFADR.savedVariables.notifyByZoneChanging,
            getFunc =
            function()
                return LioFADR.savedVariables.notifyByZoneChanging
            end,
            setFunc =
            function(value)
                LioFADR.savedVariables.notifyByZoneChanging = value
            end,
        },
        [12] = 
        {
            type = "slider",
            name = GetString(LIO_FADR_NOTIFY_COOLDOWN_TITLE),
            tooltip = GetString(LIO_FADR_NOTIFY_COOLDOWN_TOOLTIP),
            min = 0,
            max = 120,
            step = 5,
            default = 60,
            getFunc = 
              function() 
                return LioFADR.savedVariables.cooldownSec
              end,
            setFunc = 
              function(value) 
                LioFADR.savedVariables.cooldownSec = value
              end,
        },
        [13] = {
			      type = "header",
			      name = GetString(LIO_FADR_DEBUG_SETTING_HEADER)
        },
        [14] =
        {
            type = "checkbox",
            name = GetString(LIO_FADR_DEBUG_TITLE),
            tooltip = GetString(LIO_FADR_DEBUG_TOOLTIP),
            default = LioFADR.savedVariables.debug,
            getFunc =
            function()
                return LioFADR.savedVariables.debug
            end,
            setFunc =
            function(value)
                LioFADR.savedVariables.debug = value
            end,
        },
    }
    
    LAM2:RegisterAddonPanel(PanelTitle.."LAM2Options", PanelData)
    LAM2:RegisterOptionControls(PanelTitle.."LAM2Options", OptionsData)
    
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------