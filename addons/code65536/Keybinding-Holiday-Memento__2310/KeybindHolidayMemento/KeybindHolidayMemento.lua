local NAME = "KeybindHolidayMemento"

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function( )
	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)
	CHAT_ROUTER:AddSystemMessage("With the changes to how in-game events operate, the Keybinding: Holiday Memento addon has been rendered almost completely obsolete and irrelevant, and so it has been discontinued and should be uninstalled.\nFor players who want a keybind for the latest Jubilee Cake, this function is now a part of the Event Collectibles addon.")
end)
