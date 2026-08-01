local ADDON_NAME = "Medic"

local Medic = {
    internal = {
        class = {},
        modules = {},
        logger = LibDebugLogger(ADDON_NAME),
    }
}
_G[ADDON_NAME] = Medic
local internal = Medic.internal
local logger = internal.logger

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
    local eventHandleName = ADDON_NAME .. nextEventHandleIndex
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    nextEventHandleIndex = nextEventHandleIndex + 1
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
    if(type(object) == "string") then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, name)
    end)
end

internal.UnregisterForEvent = UnregisterForEvent
internal.RegisterForEvent = RegisterForEvent
internal.WrapFunction = WrapFunction

local function TryRunOnModule(module, func, info, warning, ...)
    local status, err = pcall(func, module, ...)
    if not status then
        logger:Warn(warning, module:GetId(), err)
        return false
    end
    logger:Info(info, module:GetId())
    return true
end

local function TryLoad(module, oldSaveData, newSaveData)
    return TryRunOnModule(module, module.Load, "Loaded", "Could not load", oldSaveData, newSaveData)
end

local function TryEnable(module)
    return TryRunOnModule(module, module.Enable, "Enabled", "Could not enable")
end

local function TryDisable(module)
    return TryRunOnModule(module, module.Disable, "Disabled", "Could not disable")
end

internal.TryEnable = TryEnable
internal.TryDisable = TryDisable

local function InitializeSettings()
    local displayName = GetDisplayName()
    Medic_Data = Medic_Data or {}
    local oldSaveData = Medic_Data[displayName] or {}
    local newSaveData = {} -- if a module does not load it means it has been removed or became obsolete, so we discard old saveData
    Medic_Data[displayName] = newSaveData
    return oldSaveData, newSaveData
end

OnAddonLoaded(function()
    local oldSaveData, newSaveData = InitializeSettings()

    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = "Medic - UI Fixes",
        author = "sirinsidiator",
        version = "2.2.0.185",
        registerForRefresh = true,
        registerForDefaults = true
    }
    LAM:RegisterAddonPanel("MedicOptions", panelData)

    local optionsData = {}
    local modules = internal.modules
    if #modules == 0 then
        optionsData[#optionsData + 1] = {
            type = "description",
            text = "No fixes available right now.", -- TODO: localization
        }
    else
        local currentAPIVersion = GetAPIVersion()
        for i, module in ipairs(modules) do
            local shouldLoad = module:ShouldLoad(currentAPIVersion)
            logger:Debug(module:GetId(), shouldLoad)
            if shouldLoad and TryLoad(module, oldSaveData, newSaveData) then
                if module:IsEnabled() then
                    TryEnable(module)
                end
                module:CreateSettings(optionsData)
            else
                module:Unload(newSaveData)
            end
        end
    end
    LAM:RegisterOptionControls("MedicOptions", optionsData)
end)

function internal:AddModule(module)
    local modules = self.modules
    modules[#modules + 1] = module
end
