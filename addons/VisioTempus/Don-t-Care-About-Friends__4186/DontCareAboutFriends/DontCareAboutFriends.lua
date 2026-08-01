local DCAF = {
  name = "DontCareAboutFriends",
  version = "1.0.0",
  author = "VisioTempus",
}

function DCAF.FriendsMessageHook() 
  local handlers = ZO_ChatSystem_GetEventHandlers()

	local function EventHook()
		return true
	end
	ZO_PreHook(handlers, EVENT_FRIEND_PLAYER_STATUS_CHANGED, EventHook)
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function DCAF.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == DCAF.name then
    --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
    EVENT_MANAGER:UnregisterForEvent(DCAF.name, EVENT_ADD_ON_LOADED)
    
    --PreHook when receiving friends messages.
    DCAF.FriendsMessageHook()
    
  end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(DCAF.name, EVENT_ADD_ON_LOADED, DCAF.OnAddOnLoaded)