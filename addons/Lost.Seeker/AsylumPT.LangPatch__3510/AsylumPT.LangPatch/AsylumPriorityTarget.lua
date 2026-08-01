-- AsylumPriorityTarget, by Gordias. Modded dy Lost.Seeker

AsylumPriorityTarget = {
	-- AddOn information
	name = "AsylumPriorityTarget",
	version = 1.2.1,
	variableVersion = 1.1,
	-- Listener variables
	olmsActive = false,
	protectorActive = false,
	llothisActive = false,
	felmsActive = false,
	llothisEnrageTime = 0,
	felmsEnrageTime = 0,
	-- AddOn Variables
	debugFlag = true,
	priorityTarget = "Олмс",
	asylumZoneId = 1000,
	enrageTimer = 180000,
	enrageTimerThreshold = 75000,
	-- ID Definitions
	-- Olms IDs
	olmsIds = {
		["Dormant"] = 99990,
	},
	-- Llothis IDs
	llothisIds = {
		["UnravelingEnergies"] = 95466,
		["DefilingBlast"] = 95545,
		["SoulStainedCorruption"] = 95585,
		["OppressiveBolts"] = 95687,
		["CorrodingBolt"] = 95470,
		["NoxiousGas"] = 98353,
	},
	-- Felms IDs
	felmsIds = {
		["TeleportStrike"] = 99138,
		["Maim"] = 95657,
	},
	-- Protector IDs
	protectorIds = {
		["StaticShield"] = 96010,
	},
	-- Default settings
	default = {
		enrageTimerThreshold = 75000,
		offsetX = -100,
		offsetY = 200,
	},
	-- LAM Panel Data
	panelData = {
    type = "panel",
    name = "Asylum Priority Target",
    displayName = "Asylum Priority Target",
    author = "Gordias, перевод |c02fcffLost.Seeker|r",
    version = "1.2",
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	},
	-- LAM Options
	optionsTable = {
		[1] = {
	        type = "header",
	      --  name = "General Settings",
			name = "Основные настройки",
	        width = "full",	--or "half" (optional)
	    },
	    [2] = {
	        type = "slider",
	       -- name = "Enrage Timer Threshold",
			name = "Порог бешенства",
	      --  tooltip = "Llothis and/or Felms becomes a target when this amount of time is left before they enrage",
			tooltip = "Остаток времени до того как Ллотис и/или Фелмс впадут в бешенство",
	        min = 1,
	        max = 180,
	        step = 1,	--(optional)
	        getFunc = function() return AsylumPriorityTarget.enrageTimerThreshold / 1000 end,
			setFunc = function(value) AsylumPriorityTarget.enrageTimerThreshold = value * 1000
				 AsylumPriorityTarget.savedVariables.enrageTimerThreshold = value * 1000 end,
	        width = "full",	--or "half" (optional)
	        default = 75,	--(optional)
	    },
	    [3] = {
			type = "button",
		--	name = "Change UI Location",
			name = "Разблокировать окно",
		--	tooltip = "This button pops up the UI for you to move to a prefered location",
			tooltip = "Эта настройка позволяет переместить окно в удобное место на экране",
			func = function() APTWindow:SetHidden(false) end,
			width = "half",	--or "half" (optional)
		},
		[4] = {
			type = "button",
		--	name = "Set Default Location",
			name = "По умолчанию",
		--	tooltip = "This button moves the UI to the default location",
			tooltip = "Перемешает окно в позицию `по умолчанию`",
			func = function() 
				AsylumPriorityTarget.savedVariables.offsetX = AsylumPriorityTarget.default.offsetX
				AsylumPriorityTarget.savedVariables.offsetY = AsylumPriorityTarget.default.offsetY
				APTWindow:ClearAnchors()
				APTWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, AsylumPriorityTarget.savedVariables.offsetX, AsylumPriorityTarget.savedVariables.offsetY) 
			end,
			width = "half",	--or "half" (optional)
	    },
	},
}

-- Get reference to the LibAddonMenu-2.0 library table
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

-- This function is for debug purposes
function AsylumPriorityTarget.DebugText(text)
	if AsylumPriorityTarget.debugFlag then
		 d(text)
	end
end

-- This function saves the location of the GUI once it has been moved by the player
function AsylumPriorityTarget.SaveGUILocation()
	AsylumPriorityTarget.savedVariables.offsetX = APTWindow:GetRight() - GuiRoot:GetRight()
	AsylumPriorityTarget.savedVariables.offsetY = APTWindow:GetTop()
	APTWindow:ClearAnchors()
	APTWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, AsylumPriorityTarget.savedVariables.offsetX, AsylumPriorityTarget.savedVariables.offsetY) 
	APTWindow:SetHidden(true)
end

-- This function controls the textures based on the input flags
function AsylumPriorityTarget.SetTextures(olmsTextureFlag, llothisTextureFlag, felmsTextureFlag, protectorTextureFlag)

	APTWindowTextureOlms:SetHidden(olmsTextureFlag)
	APTWindowTextureLlothis:SetHidden(llothisTextureFlag)
	APTWindowTextureFelms:SetHidden(felmsTextureFlag)
	APTWindowTextureProtector:SetHidden(protectorTextureFlag)

end

-- This function updates the priority target based on the available information
function AsylumPriorityTarget.OnUpdateTarget()

	-- Initialize local variables
	local currentTime = GetGameTimeMilliseconds()
	local felmsTimeToEnrage = AsylumPriorityTarget.felmsEnrageTime - currentTime
	local llothisTimeToEnrage = AsylumPriorityTarget.llothisEnrageTime - currentTime
	local newPriorityTarget = "Олмс"

	-- Check if mini bosses are already enraged or simply in dormant state
	if felmsTimeToEnrage < 0 then if AsylumPriorityTarget.felmsActive then felmsTimeToEnrage = 0 else felmsTimeToEnrage = 450000 end end
	if llothisTimeToEnrage < 0 then if AsylumPriorityTarget.llothisActive then llothisTimeToEnrage = 0 else llothisTimeToEnrage = 450000 end end

	-- Felms is priority if both are enraged, thus "<=" in condition
	if AsylumPriorityTarget.felmsActive and felmsTimeToEnrage < AsylumPriorityTarget.enrageTimerThreshold and felmsTimeToEnrage <= llothisTimeToEnrage then
		newPriorityTarget = "Фелмс"
		AsylumPriorityTarget.SetTextures(true, true, false, true)
		APTWindowStatusBar:SetValue(felmsTimeToEnrage / AsylumPriorityTarget.enrageTimerThreshold)
		APTWindowStatusBar:SetColor(0, 0, 1, 1)
		APTWindowLabel:SetColor(0, 0, 1, 1)
	elseif AsylumPriorityTarget.llothisActive and llothisTimeToEnrage < AsylumPriorityTarget.enrageTimerThreshold and llothisTimeToEnrage < felmsTimeToEnrage then
		newPriorityTarget = "Ллотис"
		AsylumPriorityTarget.SetTextures(true, false, true, true)
		APTWindowStatusBar:SetValue(llothisTimeToEnrage / AsylumPriorityTarget.enrageTimerThreshold)
		APTWindowStatusBar:SetColor(0, 1, 0, 1) 
		APTWindowLabel:SetColor(0, 1, 0, 1)
	elseif AsylumPriorityTarget.protectorActive then
		newPriorityTarget = "Сфера"
		AsylumPriorityTarget.SetTextures(true, true, true, false)
		APTWindowStatusBar:SetValue(1)
		APTWindowStatusBar:SetColor(197/255, 194/255, 158/255, 1) 
		APTWindowLabel:SetColor(197/255, 194/255, 158/255, 1)
	else
		newPriorityTarget = "Олмс"
		AsylumPriorityTarget.SetTextures(false, true, true, true)
		local current, max, effectiveMax = GetUnitPower("boss1", POWERTYPE_HEALTH)
		if current > 0 then APTWindowStatusBar:SetValue(current / max) end
		APTWindowStatusBar:SetColor(1, 0, 0, 1) 
		APTWindowLabel:SetColor(1, 0, 0, 1)
	end

	-- Check if the target has changed
	if newPriorityTarget ~= AsylumPriorityTarget.priorityTarget then
		-- Assign the new target
		AsylumPriorityTarget.priorityTarget = newPriorityTarget
		-- Update the Label statusBar Text
		APTWindowLabel:SetText(newPriorityTarget)
		-- Play Sound
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
	end

	-- AsylumPriorityTarget.DebugText(zo_strformat("PT: <<1>>, <<2>>, <<3>>, <<4>>", newPriorityTarget, 
	--	tostring(AsylumPriorityTarget.llothisActive), tostring(AsylumPriorityTarget.felmsActive), tostring(AsylumPriorityTarget.protectorActive)))
	-- AsylumPriorityTarget.DebugText(zo_strformat("DT: <<1>>, <<2>>, <<3>>, <<4>>", GetUnitName("boss1"), GetUnitName("boss2"), GetUnitName("boss3"), GetUnitName("boss4")))

end

-- Event handler function for the EVENT_COMBAT_EVENT
function AsylumPriorityTarget.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, 
	iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
	
	-- Debug
	-- AsylumPriorityTarget.DebugText(zo_strformat("ChgEvnt: <<1>>, <<2>>, <<3>>", effectName, unitName, abilityId))

	-- Check if Llothis or Felms is up after dormant (Dormant Ability Id : 99990)
	if changeType == EFFECT_RESULT_FADED then
		if unitName:find("Llothis") or unitName:find("Ллотис") then
			-- Set Llothis as active
			AsylumPriorityTarget.llothisActive = true
			-- Set Llothis Enrage Timer as Spawn plus enrageTimer seconds
			AsylumPriorityTarget.llothisEnrageTime = GetGameTimeMilliseconds() + AsylumPriorityTarget.enrageTimer
			-- AsylumPriorityTarget.DebugText("Llothis Woke Up!")
		elseif unitName:find("Felms") or unitName:find("Фелмс") then
			-- Set Felms as active
			AsylumPriorityTarget.felmsActive = true
			-- Set Felms Enrage Timer as Spawn plus enrageTimer seconds
			AsylumPriorityTarget.felmsEnrageTime = GetGameTimeMilliseconds() + AsylumPriorityTarget.enrageTimer
			-- AsylumPriorityTarget.DebugText("Felms Woke Up!")
		end
	elseif changeType == EFFECT_RESULT_GAINED then
		if unitName:find("Llothis") or unitName:find("Ллотис") then
			-- Set Llothis as inactive
			AsylumPriorityTarget.llothisActive = false
			-- Set Llothis Enrage Timer as zero
			AsylumPriorityTarget.llothisEnrageTime = 0
			-- AsylumPriorityTarget.DebugText("Llothis Sleeping!")
		elseif unitName:find("Felms") or unitName:find("Фелмс") then
			-- Set Felms as inactive
			AsylumPriorityTarget.felmsActive = false
			-- Set Felms Enrage Timer as zero
			AsylumPriorityTarget.felmsEnrageTime = 0
			-- AsylumPriorityTarget.DebugText("Felms Sleeping!")
		end
	end

end

-- Event handler function for the Protector Event
function AsylumPriorityTarget.OnProtectorEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
	targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
		
	-- Check if the shield is up or down
	if result == ACTION_RESULT_EFFECT_GAINED then
		AsylumPriorityTarget.protectorActive = true
		-- AsylumPriorityTarget.DebugText("Protector/Shield Up!")
	elseif result == ACTION_RESULT_EFFECT_FADED then
		AsylumPriorityTarget.protectorActive = false
		-- AsylumPriorityTarget.DebugText("Protector/Shield Down!")
	end

	-- Debug
	-- AsylumPriorityTarget.DebugText(zo_strformat("OlmsEvnt: <<1>>, <<2>>, <<3>>, <<4>>", abilityName, sourceName, targetName, abilityId))

end

-- Event handler function for the Llothis Event
function AsylumPriorityTarget.OnLlothisEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
	targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	-- Check if Llothis is already registered as active
	if not AsylumPriorityTarget.llothisActive then
		-- Set Llothis as active
		AsylumPriorityTarget.llothisActive = true
		-- Set Llothis Enrage Timer as Spawn plus enrageTimer seconds
		AsylumPriorityTarget.llothisEnrageTime = GetGameTimeMilliseconds() + AsylumPriorityTarget.enrageTimer
		-- AsylumPriorityTarget.DebugText("Llothis Woke Up!")
	end

	-- Unregister Llothis' Combat Events, we can just track Dormant from now on
	for abilityName, abilityId in pairs(AsylumPriorityTarget.llothisIds) do
		EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT)
	end

	-- Debug
	-- AsylumPriorityTarget.DebugText(zo_strformat("lthEvnt: <<1>>, <<2>>, <<3>>, <<4>>", abilityName, sourceName, targetName, abilityId))
	
end

-- Event handler function for the Felms Event
function AsylumPriorityTarget.OnFelmsEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
	targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
		
	-- Check if Felms is already registered as active
	if not AsylumPriorityTarget.felmsActive then
		-- Set Felms as active
		AsylumPriorityTarget.felmsActive = true
		-- Set Felms Enrage Timer as Spawn plus enrageTimer seconds
		AsylumPriorityTarget.felmsEnrageTime = GetGameTimeMilliseconds() + AsylumPriorityTarget.enrageTimer
		-- AsylumPriorityTarget.DebugText("Felms Woke Up!")
	end

	-- Unregister Felms' Combat Events, we can just track Dormant from now on
	for abilityName, abilityId in pairs(AsylumPriorityTarget.felmsIds) do
		EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT)
	end

	-- Debug
	-- AsylumPriorityTarget.DebugText(zo_strformat("flmEvnt: <<1>>, <<2>>, <<3>>, <<4>>", abilityName, sourceName, targetName, abilityId))
	
end

-- Event handler function for the EVENT_PLAYER_ACTIVATED
function AsylumPriorityTarget.OnPlayerActivated(eventCode, initial)

	-- Check the current zone the player is in
	local currentZone = GetUnitZone("player")
	-- Asylum Sanctorium (zoneId : 1000)
	local asylumZone = GetZoneNameById(AsylumPriorityTarget.asylumZoneId)
	-- Register combat state event if the zone is Asylum Sanctorium
	if currentZone == asylumZone then
		EVENT_MANAGER:RegisterForEvent(AsylumPriorityTarget.name, EVENT_PLAYER_COMBAT_STATE, AsylumPriorityTarget.OnCombatState)
						d("|cBFBC99[|r|c02fcffLost.Seeker|r|cBFBC99]:|r запущен языковой патч для |ceaa514\"Asylum Priority Target\"|r.")
	else
		EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name, EVENT_PLAYER_COMBAT_STATE)
	end

end

-- Event handler function for the EVENT_PLAYER_COMBAT_STATE
function AsylumPriorityTarget.OnCombatState(eventCode, inCombat)

	-- Check if the fight is with Olms
	local boss1Name = GetUnitName("boss1")

	-- Debug
	-- AsylumPriorityTarget.DebugText(zo_strformat("CmbStt: <<1>>, <<2>>, <<3>>", boss1Name, tostring(inCombat), tostring(AsylumPriorityTarget.olmsActive)))

	-- There is a bug here sometimes, if the player is far away from the group when the fight starts, the boss name is returned as empty string
	if inCombat == true and AsylumPriorityTarget.olmsActive == false and boss1Name == "Saint Olms the Just" or "Святой Олмс Справедливый" then
		-- Set Olms as active
		AsylumPriorityTarget.olmsActive = true
		-- Show the GUI
		AsylumPriorityTarget.SetTextures(false, true, true, true)
		APTWindow:SetHidden(false)
		APTWindowLabel:SetText("Олмс")
		APTWindowStatusBar:SetColor(1, 0, 0, 1) 
		-- Register Update Event
		EVENT_MANAGER:RegisterForUpdate(AsylumPriorityTarget.name, 1000, AsylumPriorityTarget.OnUpdateTarget)
		-- Register Dormant event to track Mini Boss sleep state
		EVENT_MANAGER:RegisterForEvent(AsylumPriorityTarget.name .. "Сфера", EVENT_EFFECT_CHANGED, AsylumPriorityTarget.OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent(AsylumPriorityTarget.name .. "Сфера", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, AsylumPriorityTarget.olmsIds["Сфера"])
		-- Register ability ids to track Boss, Mini Boss and Protector spawn
		for abilityName, abilityId in pairs(AsylumPriorityTarget.protectorIds) do
			EVENT_MANAGER:RegisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT, AsylumPriorityTarget.OnProtectorEvent)
			EVENT_MANAGER:AddFilterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, AsylumPriorityTarget.protectorIds[abilityName])
		end
		for abilityName, abilityId in pairs(AsylumPriorityTarget.llothisIds) do
			EVENT_MANAGER:RegisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT, AsylumPriorityTarget.OnLlothisEvent)
			EVENT_MANAGER:AddFilterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, AsylumPriorityTarget.llothisIds[abilityName])
		end
		for abilityName, abilityId in pairs(AsylumPriorityTarget.felmsIds) do
			EVENT_MANAGER:RegisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT, AsylumPriorityTarget.OnFelmsEvent)
			EVENT_MANAGER:AddFilterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, AsylumPriorityTarget.felmsIds[abilityName])
		end
	elseif inCombat == false and AsylumPriorityTarget.olmsActive == true then
		-- Unregister the events if the fight is "really" over and not
		zo_callLater(
			function() 
				if (not IsUnitInCombat("player")) then 
					-- Set Olms as inactive
					AsylumPriorityTarget.olmsActive = false
					-- Hide and Reset the GUI
					AsylumPriorityTarget.SetTextures(false, true, true, true)
					APTWindow:SetHidden(true)
					APTWindowLabel:SetText("Олмс")
					APTWindowLabel:SetColor(1, 0, 0, 1)
					APTWindowStatusBar:SetColor(1, 0, 0, 1) 
					-- Reset Timers and Flags
					AsylumPriorityTarget.protectorActive = false
					AsylumPriorityTarget.llothisActive = false
					AsylumPriorityTarget.felmsActive = false
					AsylumPriorityTarget.llothisEnrageTime = 0
					AsylumPriorityTarget.felmsEnrageTime = 0
					-- Unregister Events
					EVENT_MANAGER:UnregisterForUpdate(AsylumPriorityTarget.name)
					EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name .. "Сфера", EVENT_EFFECT_CHANGED)
					for abilityName, abilityId in pairs(AsylumPriorityTarget.protectorIds) do
						EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT)
					end
					for abilityName, abilityId in pairs(AsylumPriorityTarget.llothisIds) do
						EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT)
					end
					for abilityName, abilityId in pairs(AsylumPriorityTarget.felmsIds) do
						EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name .. abilityName, EVENT_COMBAT_EVENT)
					end
				end 
			end, 
			2500);
	end

end

-- Initialization function
function AsylumPriorityTarget:Initialize()

	-- Load saved variables
	AsylumPriorityTarget.savedVariables = ZO_SavedVars:NewAccountWide("AsylumPriorityTargetVars", AsylumPriorityTarget.variableVersion, nil, AsylumPriorityTarget.default)

	-- Assign saved variables
	AsylumPriorityTarget.enrageTimerThreshold = AsylumPriorityTarget.savedVariables.enrageTimerThreshold

	-- Re-anchor the GUI to GuiRoot
	APTWindow:ClearAnchors()
	APTWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, AsylumPriorityTarget.savedVariables.offsetX, AsylumPriorityTarget.savedVariables.offsetY)

	-- Hide the GUI
	APTWindowStatusBar:SetColor(1, 0, 0, 1) 
	APTWindow:SetHidden(true)

	-- Initialize Settings
	LAM:RegisterAddonPanel("AsylumPriorityTargetOptions", AsylumPriorityTarget.panelData)
	LAM:RegisterOptionControls("AsylumPriorityTargetOptions", AsylumPriorityTarget.optionsTable)

	-- Register the event to check the zone the player is in
	EVENT_MANAGER:RegisterForEvent(AsylumPriorityTarget.name, EVENT_PLAYER_ACTIVATED, AsylumPriorityTarget.OnPlayerActivated)

	-- Unregister the initialization event
	EVENT_MANAGER:UnregisterForEvent(AsylumPriorityTarget.name, EVENT_ADD_ON_LOADED)

end

-- Event handler function for the "addon loaded" event
function AsylumPriorityTarget.OnAddOnLoaded(event, addonName)
	if addonName == AsylumPriorityTarget.name then
		AsylumPriorityTarget:Initialize()
	end
end
 
-- Register the initialization event
EVENT_MANAGER:RegisterForEvent(AsylumPriorityTarget.name, EVENT_ADD_ON_LOADED, AsylumPriorityTarget.OnAddOnLoaded)