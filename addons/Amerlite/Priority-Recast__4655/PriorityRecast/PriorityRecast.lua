PriorityRecast = ZO_CallbackObject:Subclass()

-------------------------------------------------------------------------------
-- GAME EVENT FUNCTIONS
-------------------------------------------------------------------------------

local EVENT_MANAGER = EVENT_MANAGER
local ADDON_NAME    = "PriorityRecast"


function PriorityRecast:On(event, func)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, event, func)
end


function PriorityRecast:Forget(event)
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, event)
end


function PriorityRecast:OnUpdate(time, func)
	EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, time, func)
end


function PriorityRecast:ForgetUpdate()
	EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME)
end


PriorityRecast:On(EVENT_ADD_ON_LOADED, function(_, loadName)
	if loadName ~= ADDON_NAME then return end
	PriorityRecast:Forget(EVENT_ADD_ON_LOADED)
	PriorityRecast:FireCallbacks("AddonLoaded")
end)
