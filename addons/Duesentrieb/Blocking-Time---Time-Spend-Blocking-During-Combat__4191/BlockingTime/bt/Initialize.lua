local BT = BlockingTime


function BT.Initialize()
	BT.SV = ZO_SavedVars:NewAccountWide(BT.SVName, BT.SVVersion, GetWorldName(), BT.default)
	EVENT_MANAGER:RegisterForEvent(BT.name.."EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, BT.CombatState)
	BT.CreateSettingsWindow()
	BT.isLoaded = true
end


function BT.AddOnLoaded(_, name)
	if name == BT.name then
		BT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(BT.name.."EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(BT.name.."EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, BT.AddOnLoaded)