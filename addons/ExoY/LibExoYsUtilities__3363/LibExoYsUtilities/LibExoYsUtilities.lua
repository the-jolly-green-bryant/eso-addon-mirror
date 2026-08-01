LibExoYsUtilities = LibExoYsUtilities or {}
local LibExoY = LibExoYsUtilities

local CM = ZO_CallbackObject:New()
local EM = GetEventManager() 

LibExoY.name = "LibExoYsUtilities"

--[[ --------------------------------- ]]
--[[ -- (Initial) Player Activation -- ]]
--[[ --------------------------------- ]]

local initialActivationDone = false

function LibExoY.RegisterForInitialPlayerActivated(callback)
    if initialActivationDone then return end
    if not LibExoY.IsFunc(callback) then return end
    CM:RegisterCallback('InitialPlayerActivated', callback)
end

function LibExoY.RegisterForPlayerActivated(callback)
    if not LibExoY.IsFunc(callback) then return end
    CM:RegisterCallback('PlayerActivated', callback)
end

function LibExoY.UnregisterForPlayerActivated(callback)
    CM:UnregisterCallback('PlayerActivated', callback)
end

local function OnPlayerActivated() 
    if not initialActivationDone then 
        CM:FireCallbacks('InitialPlayerActivated')
        initialActivationDone = true
        CM:UnregisterAllCallbacks('InitialPlayerActivated')
    end
    CM:FireCallbacks('PlayerActivated')
end


--[[ -------------------- ]]
--[[ -- Initialization -- ]]
--[[ -------------------- ]]

local function InitModule(module) 
    LibExoY.CallFunc( LibExoY[module.."_InitFunc"] )
end 


local function Initialize()
    LibExoY.vars = {}
    LibExoY.vars.charId = GetCurrentCharacterId()

    EM:RegisterForEvent(LibExoY.name.."InitialActivation", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    InitModule("Debug")
    InitModule("Dialogs")
    InitModule("CombatStateManager")
    InitModule("Units")
    InitModule("Chat") 
    --IniTModule("ActivityManager") 
end


local function OnAddonLoaded(_, addonName)
    if addonName == LibExoY.name then
        EM:UnregisterForEvent(LibExoY.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end
  

EM:RegisterForEvent(LibExoY.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

