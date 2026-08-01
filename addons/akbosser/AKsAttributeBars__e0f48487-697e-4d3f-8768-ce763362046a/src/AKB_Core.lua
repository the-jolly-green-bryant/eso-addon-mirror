-- ============================================================================
-- AKsAttributeBars - Core Module
-- ============================================================================
-- Core initialization and main addon structure

local ADDON_NAME = "AKsAttributeBars"

-- Create global addon namespace
AKsAttributeBars = AKsAttributeBars or {}
local AKB = AKsAttributeBars

-- Version and metadata
AKB.name = ADDON_NAME
AKB.version = "4.0.0"
AKB.author = "akbosser"

-- Core state variables
AKB.isInitialized = false
AKB.isEnabled = false
AKB.settings = nil

-- Output function for important messages (console-safe)
function AKB.Print(msg)
    local message = "[AKsAttributeBars] " .. tostring(msg)
    
    -- Try multiple output methods for console compatibility
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(message)
    elseif d then
        -- d() function may not take parameters on console
        pcall(d, message)
    else
        -- Fallback for console - just ensure the message is available somewhere
        print(message)
    end
end

-- Console-safe initialization check
function AKB.IsAPIReady()
    -- Check if essential ESO API functions are available
    local requiredAPIs = {
        "EVENT_MANAGER",
        "WINDOW_MANAGER", 
        "GuiRoot",
        "GetUnitPower",
        "GetUnitName",
        "GetUnitLevel"
    }
    
    for _, apiName in ipairs(requiredAPIs) do
        if not _G[apiName] then
            return false
        end
    end
    
    return true
end

-- Initialize the addon (console-safe)
function AKB.Initialize()
    if AKB.isInitialized then
        return
    end
    
    -- Check if API is ready before initializing
    if not AKB.IsAPIReady() then
        -- Try again after a short delay
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_DelayedInit", 1000, function()
                EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DelayedInit")
                AKB.Initialize()
            end)
        end
        return
    end
    
    -- Initialize saved variables
    if AKB.Settings and AKB.Settings.Initialize then
        AKB.Settings.Initialize()
    end
    
    -- Initialize UI components
    if AKB.UI and AKB.UI.Initialize then
        AKB.UI.Initialize()
    end
    
    -- Initialize animation system
    if AKB.Animation and AKB.Animation.Initialize then
        AKB.Animation.Initialize()
    end
    
    -- Initialize gridlines system
    if AKB.Gridlines and AKB.Gridlines.Initialize then
        AKB.Gridlines.Initialize()
    end
    
    -- Initialize events
    if AKB.Events and AKB.Events.Initialize then
        AKB.Events.Initialize()
    end
    
    -- Initialize enemy bars
    if AKB.EnemyBars and AKB.EnemyBars.Initialize then
        AKB.EnemyBars.Initialize()
    end
    
    -- Initialize food indicator
    if AKB.FoodIndicator and AKB.FoodIndicator.Initialize then
        AKB.FoodIndicator.Initialize()
    end
    
    -- Setup commands
    if AKB.Commands and AKB.Commands.Initialize then
        AKB.Commands.Initialize()
    end
    
    -- Create settings menu
    if AKB.Menu and AKB.Menu.Initialize then
        AKB.Menu.Initialize()
    end
    
    AKB.isInitialized = true
end

-- Main addon loaded event (console-safe)
local function OnAddOnLoaded(eventCode, addonName)
    if addonName == ADDON_NAME then
        if EVENT_MANAGER then
            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        end
        AKB.Initialize()
    end
end

-- Register for addon loaded event (console-safe)
if EVENT_MANAGER and EVENT_ADD_ON_LOADED then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
else
    -- Fallback for console if event system is different
    AKB.Initialize()
end
