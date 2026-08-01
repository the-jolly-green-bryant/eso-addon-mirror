--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Handlers)
--------------------------------------------------------------------------------

local ZAR      = Zolan_AR
local Handler  = ZAR.Handler
local Repairer = ZAR.Repairer
local Util     = ZAR.Util

-- ZO
local EVENT_ADD_ON_LOADED                = EVENT_ADD_ON_LOADED
local EVENT_MANAGER                      = EVENT_MANAGER
local EVENT_OPEN_STORE                   = EVENT_OPEN_STORE
local EVENT_PLAYER_ACTIVATED             = EVENT_PLAYER_ACTIVATED
local SLASH_COMMANDS                     = SLASH_COMMANDS
local d                                  = d
-- Lua
local string                             = string

function Handler.handleOnAddOnLoad(event, addonName)
    if not ZAR.loaded then ZAR.loadVariables() end

    if addonName ~= ZAR.addonName then return end

    d("Zolan's Auto Repair: Loaded")

    ZAR.AddonMenu.initializeAddonMenu()

    EVENT_MANAGER:UnregisterForEvent("ZAR_OnAddOnLoad", EVENT_ADD_ON_LOADED)
    Handler.loadEventHandlers()
    Handler.registerSlashCommands()
end

function Handler.handleOpenStore()
    ZAR.debug("Handler -> handleOpenStore")

    Repairer.repairItems()
end

function Handler.handlePlayerActivated()
    ZAR.debug("Handler -> handlePlayerActivated")

    Util.sendMessageToChat(string.format(
        "%s%s Version %s%s%s Loaded.",
        ZAR.Vars.outputHeader,
        ZAR.Vars.defaultColor,
        ZAR.Vars.currencyColor,
        ZAR.appVersion,
        ZAR.Vars.defaultColor
    ))

    EVENT_MANAGER:UnregisterForEvent("ZAR_PlayerActivated", EVENT_PLAYER_ACTIVATED)
end

function Handler.loadEventHandlers()
    EVENT_MANAGER:RegisterForEvent("ZAR_OpenStore",               EVENT_OPEN_STORE,                   Handler.handleOpenStore)
    EVENT_MANAGER:RegisterForEvent("ZAR_PlayerActivated",         EVENT_PLAYER_ACTIVATED,             Handler.handlePlayerActivated)
end

function Handler.registerSlashCommands()
    SLASH_COMMANDS["/repair"]   = Repairer.repairDamagedItems
    SLASH_COMMANDS["/armorstats"] = Repairer.checkArmorStats
end

EVENT_MANAGER:RegisterForEvent("ZAR_OnAddOnLoad", EVENT_ADD_ON_LOADED, Handler.handleOnAddOnLoad)
