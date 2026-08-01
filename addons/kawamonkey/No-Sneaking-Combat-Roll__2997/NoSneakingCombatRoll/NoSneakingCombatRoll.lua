local function OnStealthStateChanged(eventCode, unitTag, stealthState)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ROLL_DODGE_DOUBLE_TAP, tostring(stealthState == STEALTH_STATE_NONE))
end

local function OnAddOnLoaded(eventCode, addonName)
	if addonName == "NoSneakingCombatRoll" then
		EVENT_MANAGER:RegisterForEvent("NoSneakingCombatRoll", EVENT_STEALTH_STATE_CHANGED, OnStealthStateChanged)
		EVENT_MANAGER:AddFilterForEvent("NoSneakingCombatRoll", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	end
end

EVENT_MANAGER:RegisterForEvent("NoSneakingCombatRoll", EVENT_ADD_ON_LOADED, OnAddOnLoaded)