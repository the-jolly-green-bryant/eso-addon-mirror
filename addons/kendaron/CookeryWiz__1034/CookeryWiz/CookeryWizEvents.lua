
CookeryWizEvents = {}
CookeryWizEvents.events = {}
CookeryWizEvents.traceEnabled = false

local function trace(msg)
    if CookeryWizEvents.traceEnabled then
      d(GetTimeString()..":"..msg)
    end
end

local function RandomString(length)
  length = length or 1
  if length < 1 then return nil end
  local array = {}
  for i = 1, length do
    array[i] = string.char(math.random(65, 90))
  end
  return table.concat(array)
end

function CookeryWizEvents:new(name)
  if not name then
    name = RandomString(12)
  end
  
  local o = {}
  o.name = name
  o.events = {}
  setmetatable(o, self)
  self.__index = self
  return o  
end

-- Checks to see if the event has been registered
function CookeryWizEvents:GetRegisteredEvent(eventId)
  local event
  
  -- check if exists
  for i = 1, #self.events do
    event = self.events[i]
    if event.eventId == eventId then
      return event
    end
  end
  
  return nil
end

-- Will register the event. If it has been registered before it will not do it again
-- NOTE:the event is not actually enabled at this point
function CookeryWizEvents:RegisterEvent(eventId, callback)
  
  local event = self:GetRegisteredEvent(eventId)
  if not event then
    event = {}  
    event.isEnabled = false
    event.eventId = eventId
    event.callback = callback
    self.events[#self.events + 1] = event
  end
  
  return true
end

-- Will register the event. If it has been registered before it will not do it again
-- NOTE:the event is not actually enabled at this point
function CookeryWizEvents:UnregisterEvent(eventId)  
  local event
  
  -- check if exists
  for i = 1, #self.events do
    event = self.events[i]
    if event.eventId == eventId then
      self:DisableEvents(eventId)
      self.events[i] = nil
      return
    end
  end
  
end

-- Will register the event. If it has been registered before it will not do it again
-- NOTE:the event is not actually enabled at this point
function CookeryWizEvents:UnregisterEvents(...)
  -- because of 'self' use local arg
  local arg = {...}  
  local event
  
  for i, v in ipairs(arg) do
    event = self:GetRegisteredEvent(v)
    for i = 1, #self.events do
      event = self.events[i]
      if event.eventId == v then
        self:DisableEvents(v)
        self.events[i] = nil
        break
      end
    end
  end 
  
end

-- Regsiters and enables the specific events passed
function CookeryWizEvents:EnableEvents(...)
  -- because of 'self' use local arg
  local arg = {...}
  local event
  --for i = 2, select("#",...) do
  for i, v in ipairs(arg) do
    event = self:GetRegisteredEvent(v)
    if event.eventId == v and not event.isEnabled then
      trace(string.format("Enabling and Registering Event %s", event.eventId))
      EVENT_MANAGER:RegisterForEvent(self.name,  event.eventId, event.callback)
      event.isEnabled = true        
    end
  end
  return true
end

-- unregisters and disables the specific events passed
function CookeryWizEvents:DisableEvents(...)
  -- because of 'self' use local arg
  local arg = {...}  
  local event
  for i, v in ipairs(arg) do
    event = self:GetRegisteredEvent(v)
    if event.eventId == v and event.isEnabled then
      trace(string.format("Disabling and Unregistering Event %s", event.eventId))
      EVENT_MANAGER:UnregisterForEvent(self.name,  event.eventId)
      event.isEnabled = false          
    end
  end
  return true
end

-- unregisters all events
function CookeryWizEvents:EnableAllEvents(enable)
  local event
  
  -- check if exists
  for i = 1, #self.events do
    event = self.events[i]
    if event then
      if enable and not event.isEnabled then
        trace(string.format("Enabling and Registering Event %s", event.eventId))
        EVENT_MANAGER:RegisterForEvent(self.name,  event.eventId, event.callback)
        event.isEnabled = true        
      elseif not enable and event.isEnabled then
        trace(string.format("Disabling and Unregistering Event %s", event.eventId))
        EVENT_MANAGER:UnregisterForEvent(self.name,  event.eventId)
        event.isEnabled = false          
      end
    end
  end
  
  return true
end
