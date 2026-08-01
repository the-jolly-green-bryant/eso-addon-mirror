local function Initialize()
	COMBATPET_COOLDOWN.savedVariables 	= ZO_SavedVars:NewAccountWide("CombatPetCooldownSavedVars", 1, nil, COMBATPET_COOLDOWN.defaults, GetWorldName())
	COMBATPET_COOLDOWN.enable 			= COMBATPET_COOLDOWN.savedVariables.enable
	COMBATPET_COOLDOWN.cooldown 		= COMBATPET_COOLDOWN.savedVariables.cooldown

	COMBATPET_COOLDOWN.CreateSettingsWindow()
end

local function CombatPetState(returnActiveState)
	for i = 1, GetNumBuffs("player") do
		local _, _, _, slotId, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", i)
		for k, v in pairs(COMBATPET_COOLDOWN.abilityID) do
			if abilityId == v then 
				if not returnActiveState then
					CancelBuff(slotId)
				else
					return true
				end
			end
		end
	end
	return false
end

local function coolDownLoop()
	if COMBATPET_COOLDOWN.enable then
		if CombatPetState(true) and (IsUnitInCombat("player") or IsUnitInDungeon("player") or IsPlayerMoving()) then
			COMBATPET_COOLDOWN.time = 0
		else
			if CombatPetState(true) then -- 
				COMBATPET_COOLDOWN.time = COMBATPET_COOLDOWN.time + 1
				if COMBATPET_COOLDOWN.time == COMBATPET_COOLDOWN.cooldown then CombatPetState(false) end
			else
				COMBATPET_COOLDOWN.time = 0
			end
		end
	end
	
	-- for debugging, show cooldown timer state in chat
	--d(tostring(COMBATPET_COOLDOWN.time).."/"..tostring(COMBATPET_COOLDOWN.cooldown))
	
	zo_callLater(function() coolDownLoop() end, 1000)
end

-------------------------
-- Register
-------------------------
EVENT_MANAGER:RegisterForEvent(
	COMBATPET_COOLDOWN.name.."_OnAddonLoaded", EVENT_ADD_ON_LOADED,
	function(_, addOnName)
		if(addOnName ~= COMBATPET_COOLDOWN.name) then return end
		Initialize()
		EVENT_MANAGER:UnregisterForEvent(COMBATPET_COOLDOWN.name.."_OnAddonLoaded", EVENT_ADD_ON_LOADED)
	end
)

EVENT_MANAGER:RegisterForEvent(
	COMBATPET_COOLDOWN.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED,
	function ()
		coolDownLoop()
		EVENT_MANAGER:UnregisterForEvent(COMBATPET_COOLDOWN.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)	
	end
)