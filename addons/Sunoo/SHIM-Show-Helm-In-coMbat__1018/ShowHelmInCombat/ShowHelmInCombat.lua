SHIM = {}

function SHIM.OnCombatState()
	if IsUnitInCombat("player") then
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "0" )
	else
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "1" )
	end

end

EVENT_MANAGER:RegisterForEvent("ShowHelmInCombat", EVENT_PLAYER_COMBAT_STATE, SHIM.OnCombatState)