--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Handlers)
--------------------------------------------------------------------------------

local ZSC       = Zolan_SC
local AddonMenu = ZSC.AddonMenu
local Handler   = ZSC.Handler
local Slashes   = ZSC.Slashes
local Util      = ZSC.Util

-- ZO
local EVENT_ADD_ON_LOADED    = EVENT_ADD_ON_LOADED
local EVENT_MANAGER          = EVENT_MANAGER
local EVENT_PLAYER_ACTIVATED = EVENT_PLAYER_ACTIVATED
local d                      = d
-- Lua
local string                 = string

function Handler.handleOnAddOnLoad(event, addonName)
    if not ZSC.loaded then ZSC.loadVariables() end

    if addonName ~= ZSC.addonName then return end

    d("Zolan's Slash Commands: Loaded")

    AddonMenu.initializeAddonMenu()

    Slashes.loadSlashCommands()

    EVENT_MANAGER:UnregisterForEvent("ZSC_OnAddOnLoad", EVENT_ADD_ON_LOADED)
    Handler.loadEventHandlers()
end

function Handler.handlePlayerActivated()
    ZSC.debug("Handler -> handlePlayerActivated")

    Util.sendMessageToChat(string.format(
        "%s%s Version %s%s%s Loaded.",
        ZSC.Vars.outputHeader,
        ZSC.Vars.defaultColor,
        ZSC.Vars.currencyColor,
        ZSC.appVersion,
        ZSC.Vars.defaultColor
    ))

    EVENT_MANAGER:UnregisterForEvent("ZSC_PlayerActivated", EVENT_PLAYER_ACTIVATED)
end

function Handler.loadEventHandlers()
    EVENT_MANAGER:RegisterForEvent("ZSC_PlayerActivated", EVENT_PLAYER_ACTIVATED, Handler.handlePlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("ZSC_OnAddOnLoad", EVENT_ADD_ON_LOADED, Handler.handleOnAddOnLoad)
