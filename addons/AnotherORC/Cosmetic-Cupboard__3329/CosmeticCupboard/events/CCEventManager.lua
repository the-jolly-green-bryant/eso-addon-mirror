local CCCallbackManager = ZO_CallbackObject:Subclass()

function CCCallbackManager:New(...)
  local eventManager = ZO_CallbackObject.New(self)
  eventManager:Initialize(...)
  return eventManager
end

function CCCallbackManager:Initialize()
  self.updateEvents = {}
end

-- Create an event manager for us
CC_CALLBACK_MANAGER = CCCallbackManager:New()
