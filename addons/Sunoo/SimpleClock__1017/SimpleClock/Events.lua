---
-- Called whenever an addon is loaded, checks if it's our addon that loaded.
--
-- @param eventCode
-- @param addonName The name of that addon that just loaded.
sc.events.EVENT_ADD_ON_LOADED = function(eventCode, addonName)

	if (addonName == sc.config.name) then
		EVENT_MANAGER:UnregisterForEvent(sc.config.name, eventCode)
		sc:loadSavedVariables()
		sc.ui:create()
		buildControlPanel()
	end

end

-- Bind all declared handlers to their respective events.
for eventName, handler in pairs(sc.events) do
	EVENT_MANAGER:RegisterForEvent(sc.config.name, _G[eventName], handler)
end
