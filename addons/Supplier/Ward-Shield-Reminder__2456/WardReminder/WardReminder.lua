-- Ward Reminder
-- This addon alerts the user when his/her ward is low or if it is is destroyed/deactivated. 
-- Author: Supplier (Nicholas)

WR = {}

WR.name = "WardReminder"
WR.displayVersion = "1.1"

WR.Default = {
	offsetX = 900,
	offsetY = 400,
	wardWarningPercentage = 0.45,
	baseThreshold = 2500
}

function WR.OnAddOnLoaded(event, addonName) 
  if addonName == WR.name then
	WR:Initialize()
  end
end

function WR:Initialize()
	WR.inCombat = IsUnitInCombat("player")
	
	wardThreshold = 0
	shieldStr = 0
	
	EVENT_MANAGER:RegisterForEvent(WR.name, EVENT_PLAYER_COMBAT_STATE, WR.OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(WR.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, WR.OnAnyWardChange)
	EVENT_MANAGER:RegisterForEvent(WR.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, WR.OnAnyWardChange)
	EVENT_MANAGER:RegisterForEvent(WR.name, EVENT_EFFECT_CHANGED, WR.WardCheck)
	WR.createReminderIcon()
	
	WR.savedVariables = ZO_SavedVars:NewCharacterIdSettings("WRSavedVariables", 1, nil, WR.Default)
	WR:RestoreValues()
	
	SLASH_COMMANDS["/wrm"] = showIndicator
	SLASH_COMMANDS["/wrmb"] = changeBaseThres
end

--FUNC - a function for slash command '/wrm'
function showIndicator(toDo)
	if toDo == "show" then
		WRWindow:SetHidden(false)
	elseif toDo == "hide" then
		WRWindow:SetHidden(true)
	elseif toDo == "value" then
		d("Threshold Percentage at: " .. wardWarningPercentage)
	else 
		toDo = tonumber(toDo)
		if toDo ~= nil and toDo >= 0.05 and toDo <= 0.99 then
			wardWarningPercentage = toDo
			WR.savedVariables.wardWarningPercentage = toDo
			d("Threshold Percentage set at: " .. wardWarningPercentage)
		else
			d("Error! Please choose a number between 0.05 and 0.99!")
		end
	end
end

--FUNC - a function for slash command '/wrmb'
function changeBaseThres(toChange)
	if toChange == 'value' then
		d("Base Threshold at: " .. baseThreshold)
	else 
		toChange = tonumber(toChange)
		if toChange ~= nil and toChange >= 500 and toChange <= 10000 then
			baseThreshold = toChange
			WR.savedVariables.baseThreshold = toChange
			d("Base Threshold set at: " .. baseThreshold)
		else
			d("Error! Please choose a number between 500 and 10000!")
		end
	end
end

--FUNC - saves offset X and Y
function WR.OnIndicatorMoveStop()
	WR.savedVariables.offsetX = WRWindow:GetLeft()
	WR.savedVariables.offsetY = WRWindow:GetTop()
end

--FUNC - restores position when addon initializes
function WR:RestoreValues()
  local offsetX = WR.savedVariables.offsetX
  local offsetY = WR.savedVariables.offsetY

  WRWindow:ClearAnchors()
  WRWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
  wardWarningPercentage = WR.savedVariables.wardWarningPercentage
  baseThreshold = WR.savedVariables.baseThreshold
  
end

--FUNC - creates the image and label for the alert window
function WR.createReminderIcon()
	local image = WINDOW_MANAGER:CreateControl("WRWindowImage", WRWindow, CT_TEXTURE)
	image:SetAnchor(TOPLEFT, WRWindow, TOPLEFT, 0, 0)
	image:SetTexture("/esoui/art/repair/inventory_tabicon_repair_up.dds")
	image:SetDimensions(75,75)
	
	labelShield = WINDOW_MANAGER:CreateControl("WRLabel", WRWindow, CT_LABEL)
	labelShield:SetFont("ZoFontAlert")
	labelShield:SetAnchor(TOPLEFT, WRWINDOW, TOPLEFT, 70, 15)
	labelShield:SetDimensions(250, 250)
	
	WRWindow:SetHidden(true)
end

--FUNC - triggers whenever shield is added, updated, removed. Saves player's shield value whenever a shield is added or updated.
function WR.OnAnyWardChange(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
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
function WR.WardCheck(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
	if unitTag ~= "player" then return end
	
	--PROC - If ability type is Damage Shield related, then continue.
	if abilityType == 15 then
		--PROC - if shield was added, then do this.
		if changeType == 1 then
			--PROC - calculates ward threshold when a shield is added
			wardThreshold = shieldStr * wardWarningPercentage
			WRWindow:SetHidden(true)
			
		--PROC - else if shield was removed, then do this.
		elseif changeType == 2 then
			--PROC - if there is no shield left, then displays WARD LOW alert. Else, recalculate for ward threshold. This accounts for situations
			--		 where more than one shield is added to player
			existingShieldStr = (GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH))
			if existingShieldStr == nil and WR.inCombat then
				labelShield:SetText("Ward DOWN!")
				labelShield:SetColor(255,0,0)
				WRWindow:SetHidden(false)
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
			if wardThreshold >= shieldStr or baseThreshold >= shieldStr and WR.inCombat then
				labelShield:SetColor(255,255,255)
				labelShield:SetText("Ward LOW!")
				WRWindow:SetHidden(false)
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
function WR.OnPlayerCombatState(event, inCombat)
	if inCombat ~= WR.inCombat then
		WR.inCombat = inCombat
		--PROC - if in combat and no shield, then display WARD DOWN alert
		if inCombat then
			existingShieldStr = (GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH))
			if existingShieldStr == nil then
				labelShield:SetText("Ward DOWN!")
				labelShield:SetColor(255,0,0)
				WRWindow:SetHidden(false)
			end
		else
			WRWindow:SetHidden(true)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(WR.name, EVENT_ADD_ON_LOADED, WR.OnAddOnLoaded)