
local CallbackManager = {}
local Events = {}

ResourceRadar:RegisterModule("callbackManager", CallbackManager)
ResourceRadar:RegisterModule("events", Events)

CallbackManager.callbacks = {}
Events.lastAddedEventId = 0
function Events:AddEvent(eventName)
	self.lastAddedEventId = self.lastAddedEventId + 1
	self[eventName] = self.lastAddedEventId
	CallbackManager.callbacks[self.lastAddedEventId] = {}
end

Events:AddEvent("SETTING_CHANGED")
Events:AddEvent("HARVEST_NODE_VISIBLE")
Events:AddEvent("HARVEST_NODE_HIDDEN")
Events:AddEvent("HARVEST_NODE_LIST_UPDATED")
Events:AddEvent("HARVEST_NODE_PINTYPE_UPDATED")


function CallbackManager:RegisterCallback(event, callback)
	assert(callback)
	assert(event)
	table.insert(self.callbacks[event], callback)
end

function CallbackManager:UnregisterCallback(event, callback)
	for index, entry in pairs(self.callbacks[event]) do
		if entry == callback then
			self.callbacks[event][index] = nil
			return true
		end
	end
	return false
end

function CallbackManager:FireCallbacks(event, ...)
	for _, callback in pairs(self.callbacks[event]) do
		callback(event, ...)
	end
end
