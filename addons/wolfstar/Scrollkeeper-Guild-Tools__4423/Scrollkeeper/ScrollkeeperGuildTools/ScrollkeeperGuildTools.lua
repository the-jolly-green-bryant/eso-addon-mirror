-- Scrollkeeper Guild Tools
-- ScrollkeeperGuildTools


-- 🧠 Local references  
local Scrollkeeper = Scrollkeeper
local SF = Scrollkeeper.Framework
local SF_Set = Scrollkeeper.Settings

-- Initialize module
Scrollkeeper.GuildTools = Scrollkeeper.GuildTools or { Name = "ScrollkeeperGuildTools" }
local _addon = Scrollkeeper.GuildTools

-- Backward compatibility (DEPRECATED)
_G.ScrollkeeperGuildTools = Scrollkeeper.GuildTools

if type(SF) ~= "table" or not SF.initAddon then
  return
end

-- 🚀 Runtime init - just expose module info, no settings needed
function _addon.initialized()
  -- Module is loaded and available for inter-module communication
  -- No UI controls needed for this core module
end

-- 🔍 Module discovery for debugging
local function getAvailableModules()
  local list = {}
  if SF._settings then
    for modName, _ in pairs(SF._settings) do
      if modName ~= SF._addon.Name then  -- skip the core framework itself
        table.insert(list, modName)
      end
    end
  end
  return list
end

-- Initialize without registering any settings
local function initialize()
  _addon.initialized()
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, function()
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED)
  initialize()
end)

CALLBACK_MANAGER:RegisterCallback("Scrollkeeper_Initialized", initialize)