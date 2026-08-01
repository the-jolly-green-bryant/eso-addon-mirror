AT = AT or {}
AT.name = "AsylumTimers"

function AT.updateFont(font)
	AsylumTimers_LlothisTitle:SetFont(font)
	AsylumTimers_LlothisTimer:SetFont(font)
	AsylumTimers_FelmsTitle:SetFont(font)
	AsylumTimers_FelmsTimer:SetFont(font)
	AsylumTimers_BashTimer:SetFont(font)
	AsylumTimers_KiteTitle:SetFont(font)
	AsylumTimers_KiteTimer:SetFont(font)
	AsylumTimers_JumpTimer:SetFont(font)
	
	AsylumTimers_LlothisTitle:SetHeight(AsylumTimers_LlothisTitle:GetFontHeight())
	AsylumTimers_LlothisTimer:SetHeight(AsylumTimers_LlothisTimer:GetFontHeight())
	AsylumTimers_FelmsTitle:SetHeight(AsylumTimers_FelmsTitle:GetFontHeight())
	AsylumTimers_FelmsTimer:SetHeight(AsylumTimers_FelmsTimer:GetFontHeight())
	AsylumTimers_BashTimer:SetHeight(AsylumTimers_BashTimer:GetFontHeight())
	AsylumTimers_KiteTitle:SetHeight(AsylumTimers_KiteTitle:GetFontHeight())
	AsylumTimers_KiteTimer:SetHeight(AsylumTimers_KiteTimer:GetFontHeight())
	AsylumTimers_JumpTimer:SetHeight(AsylumTimers_JumpTimer:GetFontHeight())
end

function AT.updateText()
	--Llothis
	if (AT.time_Llothis <= 0 and AT.isLlothisEnraged == false and AT.hasLlothisSpawned) or AT.isLlothisEnraged then
		AT.isLlothisEnraged = true
		AsylumTimers_LlothisTimer:SetText("ENRAGED")
		AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha)
	elseif AT.time_Llothis > 0 then 
		AsylumTimers_LlothisTimer:SetText(ZO_FormatTime(AT.time_Llothis, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS))
		AT.time_Llothis = AT.time_Llothis - 1 
	end
	
	--Felms
	if (AT.time_Felms <= 0 and AT.isFelmsEnraged == false and AT.hasFelmsSpawned) or AT.isFelmsEnraged then
		AT.isFelmsEnraged = true
		AsylumTimers_FelmsTimer:SetText("ENRAGED")
		AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha)
	elseif AT.time_Felms > 0 then 
		AsylumTimers_FelmsTimer:SetText(ZO_FormatTime(AT.time_Felms, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS))
		AT.time_Felms = AT.time_Felms - 1 
	end
	
	--Kite
	if AT.displayKite == true then
		AsylumTimers_KiteTimer:SetText("KITE")
		AsylumTimers_KiteTimer:SetColor(AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha)
	elseif AT.time_Kite > 0 then
		AT.time_Kite = AT.time_Kite - 1
		AsylumTimers_KiteTimer:SetText(ZO_FormatTime(AT.time_Kite, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS))
		AsylumTimers_KiteTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif DoesUnitExist("boss1") then
		local health, maxHealth, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
		if health/maxHealth <= 0.9 then
			AsylumTimers_KiteTimer:SetText("SOON")
			AsylumTimers_KiteTimer:SetColor(AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha)
		end
	end
	
	--Bash
	if AT.activeBash then
		AsylumTimers_BashTimer:SetText("(BASH)")
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha)
	elseif AT.time_Bash > 0 then 
		AsylumTimers_BashTimer:SetText("("..ZO_FormatTime(AT.time_Bash, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)..")")
		AT.time_Bash = AT.time_Bash - 1
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif AT.hasLlothisSpawned then
		AsylumTimers_BashTimer:SetText("(SOON)")
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha)
	end
	
	--Jump (Felms)
	if AT.felmsJumps ~= 0 then
		AsylumTimers_JumpTimer:SetText("(JUMPING)")
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha)
	elseif AT.time_Jump > 0 then
		AsylumTimers_JumpTimer:SetText("("..ZO_FormatTime(AT.time_Jump, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)..")")
		AT.time_Jump = AT.time_Jump - 1
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif AT.hasFelmsSpawned then
		AsylumTimers_JumpTimer:SetText("(SOON)")
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha)
	end
end

function AT.onEffect(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID, sourceType)
	--Player notices miniboss for the first time.
	if AT.hasLlothisSpawned == false and string.find(unitName, "Llothis") ~= nil then
		if AT.spawnTimes[tostring(unitID)] == nil then AT.spawnTimes[tostring(unitID)] = GetGameTimeSeconds() end
		AT.hasLlothisSpawned = true
		
		if AT.spawnTimes[tostring(unitID)] == nil then
			AT.time_Llothis = 180
		else
			AT.time_Llothis = 180 - (GetGameTimeSeconds() - AT.spawnTimes[tostring(unitID)])
		end
		
		AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		AT.time_Bash = AT.cooldowns.bash - (GetGameTimeSeconds() - AT.spawnTimes[tostring(unitID)])
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif AT.hasFelmsSpawned == false and string.find(unitName, "Felms") ~= nil then	
		if AT.spawnTimes[tostring(unitID)] == nil then AT.spawnTimes[tostring(unitID)] = GetGameTimeSeconds() end
		AT.hasFelmsSpawned = true
		
		if AT.spawnTimes[tostring(unitID)] == nil then
			AT.time_Felms = 180
		else
			AT.time_Felms = 180 - (GetGameTimeSeconds() - AT.spawnTimes[tostring(unitID)])
		end
		
		AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		AT.time_Jump = AT.cooldowns.jump - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	end
	
	if abilityID == 99990 then --Dormant
		if changeType == EFFECT_RESULT_GAINED  then
			
			if string.find(unitName, "Llothis") ~= nil then
				
				AT.time_Llothis = 45
				AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha)
				AT.isLlothisEnraged = false
			elseif string.find(unitName, "Felms") ~= nil then
				
				AT.time_Felms = 45
				AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha)
				AT.isFelmsEnraged = false
			end
		
		elseif changeType == EFFECT_RESULT_FADED then
			
			if string.find(unitName, "Llothis") ~= nil then
				
				AT.time_Llothis = 180
				AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
			elseif string.find(unitName, "Felms") ~= nil then
				
				AT.time_Felms = 180
				AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
			end
			
		end
	elseif abilityID == 101354 and changeType == EFFECT_RESULT_GAINED then --Enrage	
		if string.find(unitName, "Llothis") ~= nil then
			
			AT.isLlothisEnraged = true
		elseif string.find(unitName, "Felms") ~= nil then
			
			AT.isFelmsEnraged = true
		end
	end
end

function AT.onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _log, sourceUnitID, targetUnitID, abilityID, overflow)
	--Player hits miniboss for the first time.
	if AT.hasLlothisSpawned == false and string.find(targetName, "Llothis") ~= nil then
		AT.hasLlothisSpawned = true
		
		if AT.spawnTimes[tostring(targetID)] == nil then
			AT.time_Llothis = 180
		else
			AT.time_Llothis = 180 - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		end
		
		AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		AT.time_Bash = AT.cooldowns.bash - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif AT.hasFelmsSpawned == false and string.find(targetName, "Felms") ~= nil then	
		AT.hasFelmsSpawned = true
		
		if AT.spawnTimes[tostring(targetID)] == nil then
			AT.time_Felms = 180
		else
			AT.time_Felms = 180 - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		end
		
		AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		AT.time_Jump = AT.cooldowns.jump - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	end
	
	if abilityID == 10298 then --ad spawns, only lets us use targetID
		if AT.hasFelmsSpawned == false or AT.hasLlothisSpawned == false then
			AT.spawnTimes[tostring(targetID)] = GetGameTimeSeconds()
		end
	elseif abilityID == 95687 or abilityID == 9566 then --Oppressive Bolt
		AT.activeBash = true
	elseif abilityID == 98535 then --Storm the heavens
		if AT.activeKite == false then
			AT.displayKite = true
			AT.activeKite = true
			zo_callLater(function ()
				AT.time_Kite = AT.cooldowns.kite
				AT.displayKite = false
				end, 5000)
			zo_callLater(function ()
				AT.activeKite = false
			end, 10000)
		end
	elseif abilityID == 99138 then --teleport strike
		AT.felmsJumps = AT.felmsJumps + 1
		AT.hasFelmsJumpedRecently = true
		zo_callLater(function() AT.hasFelmsJumpedRecently = false end, 250)
		
		if AT.felmsJumps == 3 then
			AT.felmsJumps = 0
			AT.time_Jump = AT.cooldowns.jump
			AsylumTimers_JumpTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		end
	end
	
	--Llothis Bash
	if result == ACTION_RESULT_INTERRUPT then
		AT.time_Bash = AT.cooldowns.bash
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		
		AT.activeBash = false
		zo_callLater(function()
			AT.activeBash = false 
		end, 2500)
	end
end

function AT.onWipeOrKill(eventCode, inCombat)
	zo_callLater(function ()
		if IsUnitInCombat("player") == false and IsUnitDead("player") == false then
			AsylumTimers_BashTimer:SetText("")
			AsylumTimers_FelmsTimer:SetText("")
			AsylumTimers_JumpTimer:SetText("")
			AsylumTimers_KiteTimer:SetText("")
			AsylumTimers_LlothisTimer:SetText("")
			
			AT.time_Felms = 0
			AT.time_Llothis = 0
			AT.time_Bash = 0
			AT.time_Jump = 0
			AT.time_Kite = 0
			AT.felmsJumps = 0
			AT.activeBash = false
			AT.activeKite = false
			AT.hasLlothisSpawned = false
			AT.hasFelmsSpawned = false
			AT.isLlothisEnraged = false
			AT.isFelmsEnraged = false
			AT.spawnTimes = { }
		end
	end, 4000)
end

function AT.onNewZone(eventCode, initial)
	local zoneID, _, _, _ = GetUnitRawWorldPosition("player")
	
	if zoneID == 1000 then
		AsylumTimers:SetHidden(AT.savedVariables.isHidden)
		if AT.isRegistered == false then
			AT.isRegistered = true
			
			EVENT_MANAGER:RegisterForUpdate(AT.name, 1000, AT.updateText)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_EFFECT_CHANGED, AT.onEffect)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_ALIVE, AT.onWipeOrKill)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_COMBAT_STATE, AT.onWipeOrKill)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_COMBAT_EVENT, AT.onCombatEvent)
		end
	else
		AsylumTimers:SetHidden(true)
		if AT.isRegistered then 
			AT.isRegistered = false
			
			EVENT_MANAGER:UnregisterForUpdate(AT.name, AT.updateText)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_EFFECT_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_PLAYER_ALIVE)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_PLAYER_COMBAT_STATE)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_COMBAT_EVENT)
		end
	end
end

local function fragmentChange(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWN then
		local zoneID, _, _, _ = GetUnitRawWorldPosition("player")
	
		if zoneID == 1000 then
			AsylumTimers:SetHidden(AT.savedVariables.isHidden)
		end
	elseif newState == SCENE_FRAGMENT_HIDDEN then
		AsylumTimers:SetHidden(true)
	end
end

function AT.Initialize()
	
	AT.defaults = {
		selectedFontNumber_Timers = "22", --I'm preserving old variable names to not mess with user settings.
		fontStyle = "GAMEPAD_MEDIUM_FONT",
		fontWeight = "soft-shadow-thick",

		normalColor = {
			red = 1.0,
			green = 1.0,
			blue = 1.0,
			alpha = 1.0,
		},
		mechColor = {
			red = 0.0,
			green = 1.0,
			blue = 1.0,
			alpha = 1.00,
		},
		enragedColor = {
			red = 1.0,
			green = 0.0,
			blue = 0.0,
			alpha = 1.0,
		},
		soonColor = {
			red = 1.0,
			green = 0.0,
			blue = 0.0,
			alpha = 1.0,
		},
		downedColor = {
			red = 0,
			green = 1,
			blue = 0,
			alpha = 1,
		},
		
		isHidden = false,
		offset_x = 0,
		offset_y = 0,
	}
	
	AT.cooldowns = {
		bash = 12,
		kite = 35,
		jump = 20,
	}
	
	AT.isRegistered = false
	AT.time_Llothis = 0
	AT.time_Felms = 0
	AT.time_Bash = 0
	AT.time_Kite = 0
	AT.time_Jump = 0
	AT.felmsJumps = 0
	AT.activeKite = false
	AT.displayKite = false
	AT.activeBash = false
	AT.hasLlothisSpawned = false
	AT.hasFelmsSpawned = false
	AT.isLlothisEnraged = false
	AT.isFelmsEnraged = false
	AT.hasFelmsJumpedRecently = false
	AT.spawnTimes = { }
	
	
	AT.savedVariables = ZO_SavedVars:NewAccountWide("ATSavedVariables", 1, nil, AT.defaults, GetWorldName())
	AT.updateFont(string.format("$(%s)|%s|%s", AT.savedVariables.fontStyle, AT.savedVariables.selectedFontNumber_Timers, AT.savedVariables.fontWeight))
	AsylumTimers:ClearAnchors()
	AsylumTimers:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AT.savedVariables.offset_x, AT.savedVariables.offset_y)


	HUD_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
	AT.setupSettings()

	EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_ACTIVATED, AT.onNewZone)
	AT.onNewZone(_, _)
end
	
function AT.OnAddOnLoaded(event, addonName)
	if addonName == AT.name then
		AT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_ADD_ON_LOADED, AT.OnAddOnLoaded)