--///////////////////////////////////////////////////////////////////////////////
-- Drakhyr's Assistant Core module

--///////////////////////////////////////////////////////////////////////////////
--Event handler

local function onEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
	--if unitTag == "player" and changeType == EFFECT_RESULT_FADED and GetAbilityDuration(abilityId) > 600000 and DA.savedVariables.FoodCheckEnabled then
		-- DA.foodCheckOnEventChange(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId) 
	-- end
	if DA.savedVariables.LogEffects and changeType == EFFECT_RESULT_GAINED then
		if DA.savedVariables.LogFilter == "All" then
			d(effectName..": "..abilityId.." ("..unitName..")")
		end
		if DA.savedVariables.LogFilter == "Group" and string.find(unitTag,"group") then
			d(effectName..": "..abilityId.." ("..unitName..")")
		end
		if DA.savedVariables.LogFilter == "Me" and unitTag == "player" then
			d(effectName..": "..abilityId.." ("..unitName..")")
		end
	end
	if effectName == DA.savedVariables.Effect1 and changeType == EFFECT_RESULT_GAINED then
		DA.savedVariables.Count1 = DA.savedVariables.Count1 + 1
		--DA_COUNTERLabelCounter:SetText(DA.savedVariables.Effect1..": "..DA.savedVariables.Count)
		DA_COUNTEREffect1:SetText(DA.savedVariables.Effect1)
		DA_COUNTERCount1:SetText(DA.savedVariables.Count1)
	end
	
	if abilityId == 29099 then
		d("Prayer Shawl Passive (29099)")
	elseif abilityId == 34504 then
		d("Prayer Shawl Active (34504)")
	end
	-- if effectName == DA.savedVariables.Effect2 and changeType == EFFECT_RESULT_GAINED then
		-- DA.savedVariables.Count2 = DA.savedVariables.Count2 + 1
		-- DA_COUNTERName2:SetText(DA.savedVariables.Effect2)
		-- DA_COUNTERCount2:SetText(DA.savedVariables.Count2)
	-- end
end

--Note: In most cases combat events will only return relevant values if the player character is either the source or the target of the event! In most other cases they only return the abilityId and the target's unitId!
local function onCombatChanged(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, 
    targetUnitId, abilityId)
  
    if isError then return end
    -- if abilityName == DA.savedVariables.Effect1 then
		-- DA.savedVariables.Count1 = DA.savedVariables.Count + 1
		-- DA_COUNTERName1:SetText(DA.savedVariables.Effect1)
		-- DA_COUNTERCount1:SetText(DA.savedVariables.Count1)
	-- end
	-- if abilityName == DA.savedVariables.Effect2 then
		-- DA.savedVariables.Count2 = DA.savedVariables.Count2 + 1
		-- DA_COUNTERName2:SetText(DA.savedVariables.Effect2)
		-- DA_COUNTERCount2:SetText(DA.savedVariables.Count2)
	-- end
    --special VD implementation
	if abilityName == "Vicious Death" then
		-- local damageOut = false
		-- if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET then 
			-- damageOut = true 
		-- end
		if result == ACTION_RESULT_DAMAGE and damageOut then
		    CHAT_SYSTEM:AddMessage("|cFFFF00" .. abilityName .. " damaged " .. targetName .. " for " .. hitValue .."|r")
		    DA.savedVariables.Count2 = DA.savedVariables.Count2 + 1
			DA_COUNTEREffect2:SetText(DA.savedVariables.Effect2)
			DA_COUNTERCount2:SetText(DA.savedVariables.Count2)
			PlaySound(SOUNDS.CHAMPION_RESPEC_TOGGLED)
		--elseif (result == ACTION_RESULT_KILLING_BLOW or result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP) and sourceType == COMBAT_UNIT_TYPE_PLAYER then
		elseif result == ACTION_RESULT_KILLING_BLOW or result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then
			CHAT_SYSTEM:AddMessage("|cFF0000" .. abilityName .. " killed "  .. targetName .."|r" .. abilityName)
			DA.savedVariables.Count2 = DA.savedVariables.Count2 + 1
			DA_COUNTEREffect2:SetText(DA.savedVariables.Effect2)
			DA_COUNTERCount2:SetText(DA.savedVariables.Count2)
			PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
		end
	end
	if abilityId == 76937 then
		d("Vicious Death Passive (76937)")
	elseif abilityId == 76938 then
		d("Vicious Death Active 1 (76938)")
	elseif abilityId == 82987 then
		d("Vicious Death Active 2 (82987)")
	end
end

--[[local function onPower(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	--if unitTag == "player" then
		--DA.log("Index: "..tostring(powerIndex)..", type: "..tostring(powerType)..", val: "..tostring(powerValue)..", max: "..tostring(powerMax)..", effmax: "..tostring(powerEffectiveMax))
	if (powerValue ~= nil and powerMax ~= nil and powerMax > 0) then
		if powerType == POWERTYPE_HEALTH and powerValue < powerMax then
			--d("Index: "..tostring(powerIndex)..", type: "..tostring(powerType)..", val: "..tostring(powerValue)..", max: "..tostring(powerMax)..", effmax: "..tostring(powerEffectiveMax))
			CurrentHealthPercentage = powerValue / powerMax
			if CurrentHealthPercentage < 1 then DA.BelowMaxHealth = true else DA.BelowMaxHealth = false end
			if CurrentHealthPercentage < DA.savedVariables.HealthPercentageLimit/100 then 
				DA.BelowHealthLimit = true else DA.BelowHealthLimit = false 
			end
			DA.slotSwitchLogic()
		end
		-- if powerType == POWERTYPE_STAMINA and powerValue < powerMax then
			-- --d("Index: "..tostring(powerIndex)..", type: "..tostring(powerType)..", val: "..tostring(powerValue)..", max: "..tostring(powerMax)..", effmax: "..tostring(powerEffectiveMax))
			-- CurrentStamPercentage = powerValue / powerMax
			-- if CurrentStamPercentage < 1 then DA.BelowMaxStam = true else DA.BelowMaxStam = false end
			-- if CurrentStamPercentage < DA.savedVariables.StamPercentageLimit/100 then 
				-- DA.BelowStamLimit = true else DA.BelowStamLimit = false 
			-- end
			-- DA.slotSwitchLogic()
		-- end
		-- if powerType == POWERTYPE_MAGICKA and powerValue < powerMax then
			-- --d("Index: "..tostring(powerIndex)..", type: "..tostring(powerType)..", val: "..tostring(powerValue)..", max: "..tostring(powerMax)..", effmax: "..tostring(powerEffectiveMax))
			-- CurrentMagPercentage = powerValue / powerMax
			-- if CurrentMagPercentage < 1 then DA.BelowMaxMag = true else DA.BelowMaxMag = false end
			-- if CurrentMagPercentage < DA.savedVariables.MagPercentageLimit/100 then 
				-- DA.BelowMagLimit = true else DA.BelowMagLimit = false 
			-- end
			-- DA.slotSwitchLogic()
		-- end
	end
end]]--


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Toggle modules. Unregister from events if possible

function DA.ToggleFXCounter(isSet)
	if (isSet) then
		EVENT_MANAGER:RegisterForEvent(DA.name, EVENT_EFFECT_CHANGED, onEffectChanged)
		--if DA.savedVariables.FilterPlayer then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player") end
		--if DA.savedVariables.FilterGroup then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") end
		if DA.savedVariables.EffectFilter == "Me" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player") end
		if DA.savedVariables.EffectFilter == "Group" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") end
		--EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 46327)--[46327] = 46324,   
		DA.savedVariables.FXCounterEnabled = true
		DA.log("FXCounterEnabled enabled: "..tostring(DA.savedVariables.FXCounterEnabled))
		--PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
		
		--EVENT_MANAGER:RegisterForEvent(DA.name, EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:RegisterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:RegisterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:RegisterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 76937)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 76938)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 82987)
		--EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_EFFECT_NAME, "Vicious Death")
		--if DA.savedVariables.EffectFilter == "Me" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player") end
		--if DA.savedVariables.EffectFilter == "Group" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") end
		if DA.savedVariables.EffectFilter == "Me" then 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player")
			EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player") 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player") 
		end
		if DA.savedVariables.EffectFilter == "Group" then 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") 
		end
	else
		EVENT_MANAGER:UnregisterForEvent(DA.name, EVENT_EFFECT_CHANGED)
		DA.savedVariables.FXCounterEnabled = false
		DA.log("FXCounterEnabled enabled: "..tostring(DA.savedVariables.FXCounterEnabled))
		PlaySound(SOUNDS.PLAYER_MENU_ENTRY_DISABLED)
		
		EVENT_MANAGER:UnregisterForEvent(DA.name, EVENT_COMBAT_EVENT)
	end
end

function DA.FXFilterSwitch()
	EVENT_MANAGER:UnregisterForEvent(DA.name, EVENT_EFFECT_CHANGED)
	zo_callLater(function ()
		EVENT_MANAGER:RegisterForEvent(DA.name, EVENT_EFFECT_CHANGED, onEffectChanged)
		if DA.savedVariables.EffectFilter == "Me" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player") end
		if DA.savedVariables.EffectFilter == "Group" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") end
		DA.log("EffectFilter switched to: "..tostring(DA.savedVariables.EffectFilter))
	end, 500)
	--PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
end

function DA.ToggleLogEffects(isSet)
	if (isSet) then
		DA.savedVariables.LogEffects = true
		DA.log("LogEffects enabled: "..tostring(DA.savedVariables.LogEffects))
		--PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
	else
		DA.savedVariables.LogEffects = false
		DA.log("LogEffects enabled: "..tostring(DA.savedVariables.LogEffects))
		PlaySound(SOUNDS.PLAYER_MENU_ENTRY_DISABLED)
	end
end

--[[function DA.ToggleFilterPlayer(isSet)
	if (isSet) then
		DA.savedVariables.FilterPlayer = true
		DA.log("FilterPlayer enabled: "..tostring(DA.savedVariables.FilterPlayer))
		--PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
	else
		DA.savedVariables.FilterPlayer = false
		DA.log("FilterPlayer enabled: "..tostring(DA.savedVariables.FilterPlayer))
		PlaySound(SOUNDS.PLAYER_MENU_ENTRY_DISABLED)
	end
end

function DA.ToggleFilterGroup(isSet)
	if (isSet) then
		DA.savedVariables.FilterGroup = true
		DA.log("FilterGroup enabled: "..tostring(DA.savedVariables.FilterGroup))
		--PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
	else
		DA.savedVariables.FilterGroup = false
		DA.log("FilterGroup enabled: "..tostring(DA.savedVariables.FilterGroup))
		PlaySound(SOUNDS.PLAYER_MENU_ENTRY_DISABLED)
	end
end--]]

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function initialise(eventCode, addOnName)
    -- Only initialize our own addon
	if (DA.name ~= addOnName) then return end
	-- Load the saved variables
    --DA.savedVariables = ZO_SavedVars:NewAccountWide("DA_SavedVariables", 1, nil, DA.defaults) --acount wide
	DA.savedVariables = ZO_SavedVars:New("DA_SavedVariables", 1, nil, DA.defaults) --per character
	
	--Events
	if DA.savedVariables.FXCounterEnabled then
		EVENT_MANAGER:RegisterForEvent(DA.name, EVENT_EFFECT_CHANGED, onEffectChanged)
		--if DA.savedVariables.FilterPlayer then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player") end
		--if DA.savedVariables.FilterGroup then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") end
		if DA.savedVariables.EffectFilter == "Me" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player") end
		if DA.savedVariables.EffectFilter == "Group" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") end
		--EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 46327)--[46327] = 46324,   
		
		--combat events
		--EVENT_MANAGER:RegisterForEvent(DA.name, EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:RegisterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:RegisterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:RegisterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, onCombatChanged)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 76937)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 76938)
		EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 82987)
		--EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_EFFECT_NAME, "Vicious Death")
		--if DA.savedVariables.EffectFilter == "Me" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player") end
		--if DA.savedVariables.EffectFilter == "Group" then EVENT_MANAGER:AddFilterForEvent(DA.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") end
		if DA.savedVariables.EffectFilter == "Me" then 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player")
			EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player") 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player") 
		end
		if DA.savedVariables.EffectFilter == "Group" then 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."1", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."2", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") 
			EVENT_MANAGER:AddFilterForEvent(DA.name.."3", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG_PREFIX, "group") 
		end
	end

	--Call setup in Settings module
	DA.setupUI()

	----------------------
    DA.initialised = true
	EVENT_MANAGER:UnregisterForEvent(DA.name, EVENT_ADD_ON_LOADED)
	
end -- DA.Initialise


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
EVENT_MANAGER:RegisterForEvent(DA.name, EVENT_ADD_ON_LOADED, initialise)