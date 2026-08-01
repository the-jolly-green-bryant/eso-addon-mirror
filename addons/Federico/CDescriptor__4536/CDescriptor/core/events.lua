CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Events = {}

local EVENT_MANAGER = EVENT_MANAGER

local M = CDescriptor.Events

function M.register_addon_loaded(name, callback)
  EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == name then
      EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
      callback()
    end
  end)
end
