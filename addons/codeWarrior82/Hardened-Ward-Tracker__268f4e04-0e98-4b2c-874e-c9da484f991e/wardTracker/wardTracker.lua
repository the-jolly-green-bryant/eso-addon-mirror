local appName = "wardTracker"

local isLoaded = false
local isInCombat = IsUnitInCombat("player")
local wardWarningPercentage = 0.50
local wardThreshold = 0
local shieldStr = 0
local isMenuOpen = false

wardTracker = {}

wardTracker.defaults = {
    trackWard = true,
    yAxisText = 680,
    xAxisText = 740,
}


--print message to chat box
local function printMessageTest(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--FUNC - triggers whenever shield is added, updated, removed. Saves player's shield value whenever a shield is added or updated.
local function OnAnyWardChange(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
	if unitTag ~= "player" then return end
	if unitAttributeVisual ~= 5 then return end

	if eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED then
		shieldStr = oldValue
	elseif eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED then
		shieldStr = newValue
	--elseif eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then

	else return end
end

--FUNC - triggers whenever shield is added, updated, removed. updates shield threshold, displays alerts to the user based on shield value.
function WardCheck(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
	if unitTag ~= "player" then return end
	
	--PROC - If ability type is Damage Shield related, then continue.
	if abilityType == 15 then
		--PROC - if shield was added, then do this.
		if changeType == 1 then
			--PROC - calculates ward threshold when a shield is added
			wardThreshold = shieldStr * wardWarningPercentage
            wardTrackAddonTextIcon:SetText("")
			wardTrackAddonText:SetHidden(true) --WRWindow:SetHidden(true)
			
		--PROC - else if shield was removed, then do this.
		elseif changeType == 2 then
			--PROC - if there is no shield left, then displays WARD LOW alert. Else, recalculate for ward threshold. This accounts for situations
			--		 where more than one shield is added to player
			local existingShieldStr = (GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH))
			if existingShieldStr == nil and isInCombat then
				wardTrackAddonTextIcon:SetText("Shield DOWN Re-Cast!")
				wardTrackAddonTextIcon:SetColor(255, 0, 0, 255)
				wardTrackAddonText:SetHidden(false)
				wardThreshold = 0
			elseif existingShieldStr ~= nil then
				wardThreshold = shieldStr * wardWarningPercentage
				--d("threshold2: " .. wardThreshold)
			else
				wardThreshold = 0
				--d("threshold2: " .. wardThreshold)
			end
			
		--PROC - else if shield was updated, then do this
		elseif changeType == 3 then
			--PROC - if shield threshold or base threshold is greater than the current shield str and in combat, then display WARD LOW alert.
			if wardThreshold == nil then return end
			if wardThreshold >= shieldStr and isInCombat then
				wardTrackAddonTextIcon:SetColor(255, 0, 0, 255)
				wardTrackAddonTextIcon:SetText("Shield LOW Re-Cast!")
				wardTrackAddonText:SetHidden(false)
			end
		else end
	end

	--for future reference...
	--if effectName == "Hardened Ward" or "Annulment" then
		--d(changeType)	 -- 1 is gained, 2 is gone, 3 is update
		--d(effectType)	 -- 1 is debuff, 0 is buff
		--d(abilityType)   -- 15 is damage shield
		--d(statusEffectType)	-- 0 is statue type none
	--end
end

--FUNC - triggers when player is in and out of combat
function OnPlayerCombatState(event, inCombat)
	if inCombat ~= isInCombat then
		isInCombat = inCombat
		--PROC - if in combat and no shield, then display WARD DOWN alert
	--	if inCombat then
	--		local existingShieldStr = (GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH))
	--		if existingShieldStr == nil then
	--			wardTrackAddonTextIcon:SetText("Shield DOWN Re-Cast!")
	--			wardTrackAddonTextIcon:SetColor(255, 0, 0, 255)
	--			wardTrackAddonText:SetHidden(false)
	--		end
	--	else
	--		wardTrackAddonText:SetHidden(true)
	--	end
        if not inCombat then
            wardTrackAddonTextIcon:SetText("")
            wardTrackAddonText:SetHidden(true)
        end
	end
end

--register for notifications about mask buff and debuff
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("hwtEvent", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent("hwtEvent", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnAnyWardChange)
	EVENT_MANAGER:RegisterForEvent("hwtEvent", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnAnyWardChange)
	EVENT_MANAGER:RegisterForEvent("hwtEvent", EVENT_EFFECT_CHANGED, WardCheck)
end

--unregister for notifications about mask buff and debuff
local function unRegisterAlerts()
    EVENT_MANAGER:RegisterForEvent("hwtEvent", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent("hwtEvent", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
	EVENT_MANAGER:UnregisterForEvent("hwtEvent", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
    EVENT_MANAGER:UnregisterForEvent("hwtEvent", EVENT_EFFECT_CHANGED)
end

--when UI opens
local function onMenuOpened()
	isMenuOpen = true
    wardTrackAddonText:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    wardTrackAddonText:SetHidden(false)--if player has shield show when exiting menu
end

--menu has been opened
local function onSceneStateChange(scene, oldState, newState)
    if isLoaded then
        local sceneName = SCENE_MANAGER:GetCurrentScene():GetName()

        if sceneName == "hud" then
            if  newState == SCENE_HIDING then onMenuOpened()
            elseif  newState == SCENE_HIDDEN then onMenuClosed()
            end
        end
    end
end

local function onAddOnLoadedWard(event, name)
    --if add-on loaded was not this add-on quit
    if name ~= appName then
        return
    end

    --unregister for notifications of add-on loaded
    EVENT_MANAGER:UnregisterForEvent(appName, EVENT_ADD_ON_LOADED)

	--notify that add-on has been loaded
	zo_callLater(function() printMessageTest("add-on successfully loaded") end, 500)

    --load saved variables
    --wardTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("wardTrackAddonVars", 1, "Settings", wardTracker.defaults, GetUnitName("player"))

    --setup text field areas
    wardTrackAddonText:SetMovable(true)
    wardTrackAddonTextIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_61)|soft-shadow-thick")
    wardTrackAddonTextIcon:SetText("")
    wardTrackAddonTextIcon:SetColor(255, 0, 0, 255)
    wardTrackAddonText:SetHidden(true)
    --setAnchorStartupIcon(wardTracker.savedVariables.xAxisText, wardTracker.savedVariables.yAxisText)

    --register for combat alerts
    registerAlerts()

    --register for notifications of menu or map opening
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneStateChange)

    --setup add on menu options
    --createOptions()

    --set is loaded boolean for use later, to stop scene change hiding tracker icon at first load in
    zo_callLater(function () isLoaded = true end, 2000)

end

--register for notification that an addon has been loaded
EVENT_MANAGER:RegisterForEvent(appName, EVENT_ADD_ON_LOADED, onAddOnLoadedWard)

























