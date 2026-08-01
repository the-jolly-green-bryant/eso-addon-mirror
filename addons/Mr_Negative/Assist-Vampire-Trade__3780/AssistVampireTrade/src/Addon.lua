--========================================
--        vars
--========================================
local l = {} -- Private table for local use
local m = {} -- Public table for module use
local NAME = 'AssistVampireTrade'
local VERSION = '|cefebbe1.3.0|r'

--========================================
--        l.
--========================================
l.actionMap = {} -- Store actions for bindings
l.dict = {} -- Store text mappings
l.extensionMap = {} -- Store extensions for types
l.registry = {} -- Registry for types
l.started = false
l.startListeners = {} -- Store start listeners for initiation

l.onAddonStarted = function(eventCode, addonName)
  if NAME ~= addonName then return end
  EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
  l.start()
end

l.start = function()
  if l.started then return end
  l.started = true
  while #l.startListeners > 0 do
    table.remove(l.startListeners, 1)()
  end
end

--========================================
--        m
--========================================
m.name = NAME
m.version = VERSION

m.addAction = function(key, action)
  l.actionMap[key] = action
end

m.doAction = function(key, ...)
  local targetAction = l.actionMap[key]
  targetAction(...)
end

m.extend = function(key, extension)
  local list = l.extensionMap[key] or {}
  table.insert(list, extension)
  l.extensionMap[key] = list
end

m.callExtension = function(key, ...)
  local list = l.extensionMap[key] or {}
  for _, var in ipairs(list) do
    var(...)
  end
end

m.hookStart = function(listener)
  if l.started then listener() end
  table.insert(l.startListeners, listener)
end

m.load = function(typeName)
  return l.registry[typeName]
end

m.putText = function(key, value)
  l.dict[key] = value
end

m.register = function(typeName, typeProto)
  l.registry[typeName] = typeProto
end

m.text = function(key, ...)
  if select('#', ...) == 0 then
    return l.dict[key] or key
  end
  return l.dict[key] and string.format(l.dict[key], ...) or string.format(key, ...)
end

--========================================
--        register
--========================================
_G[NAME] = m
EVENT_MANAGER:RegisterForEvent(m.name, EVENT_ADD_ON_LOADED, l.onAddonStarted)
