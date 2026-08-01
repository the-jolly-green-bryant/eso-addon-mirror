
Vermilion = Vermilion or {}
Vermilion.zenimax = Vermilion.zenimax or {}
local Vermilion = Vermilion

Vermilion.zenimax.events = {}

local EVENT_MANAGER = EVENT_MANAGER
local d             = d
local pcall         = pcall
local tostring      = tostring

local M = Vermilion.zenimax.events

function M.register_addon_loaded(name, callback)
  EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == name then
      EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
      callback()
    end
  end)
end

function M.register(name, eventCode, handler)
  EVENT_MANAGER:RegisterForEvent(name, eventCode, function(_, ...)
    local ok, err = pcall(handler, ...)
    if not ok and Vermilion.Constants.DEBUG then
      d("[Vermilion] handler '" .. name .. "' error: " .. tostring(err))
    end
  end)
end

function M.unregister(name, eventCode)
  EVENT_MANAGER:UnregisterForEvent(name, eventCode)
end

function M.add_filter(name, eventCode, ...)
  EVENT_MANAGER:AddFilterForEvent(name, eventCode, ...)
end

function M.register_update(name, interval_ms, callback)
  EVENT_MANAGER:RegisterForUpdate(name, interval_ms, callback)
end

function M.unregister_update(name)
  EVENT_MANAGER:UnregisterForUpdate(name)
end
