local addonName = "AdditionalReminders"

local function loadAddon()
	local defaultVars = {
		executeThreshold = 25,
		foodThreshold = 0,
		foodShowMode = "scored", -- or vet, trials
		snap = 3,
		executeScale = 1,
	}
	local vars = ZO_SavedVars:NewAccountWide("AdditionalRemindersSavedVars", 1, nil, defaultVars, nil, "$InstallationWide")

	local OnReticleTargetChanged
	local strformat = string.format

	local LCA = LibCombatAlerts
	local executeHandler = LCA.MoveableControl:New(AdditionalRemindersTopLevelExecuteTimer)
	if vars.executePos then
		executeHandler:UpdatePosition(vars.executePos)
	end
	executeHandler:SetSnap(vars.snap)
	AdditionalRemindersTopLevelExecuteTimer:SetTransformScale(vars.executeScale)

	executeHandler:RegisterCallback("AdditionalRemindersTopLevelExecuteTimerMove", LCA.EVENT_CONTROL_MOVE_STOP, function(newPos)
		vars.executePos = newPos
		SCENE_MANAGER:Show("hud")

		
		OnReticleTargetChanged()

		local current, max, effectiveMax = GetUnitPower('reticleover', COMBAT_MECHANIC_FLAGS_HEALTH)
		if current/max*100 <= vars.executeThreshold then
			AdditionalRemindersTopLevelExecuteTimer:SetText(strformat("|cFF0000Execute Now! (%.1f%%)|r", current/max*100))
		else
			AdditionalRemindersTopLevelExecuteTimer:SetText("")
		end

	end)

	SLASH_COMMANDS["/aexecutesetsize"] = function(num)
		local scale = tonumber(num)
		vars.executeScale = scale
		AdditionalRemindersTopLevelExecuteTimer:SetTransformScale(scale)
	end

	SLASH_COMMANDS["/aexecutesetthreshold"] = function(num)
		local threshold = tonumber(num)
		vars.executeThreshold = threshold
	end
	SLASH_COMMANDS["/moveaexecute"] = function(num)
		executeHandler:ToggleGamepadMove(true)
		AdditionalRemindersTopLevelExecuteTimer:SetText("|cFF0000Execute Now! (100%)|r")
		AdditionalRemindersTopLevelExecuteTimer:SetHidden(false)
	end


	local function OnPowerUpdate(_, unitTag, _, _, powerValue, powerMax, powerEffectiveMax)
		if powerValue/powerMax*100 <= vars.executeThreshold then
			AdditionalRemindersTopLevelExecuteTimer:SetText(strformat("|cFF0000Execute Now! (%.1f%%)|r", powerValue/powerMax*100))
		else
			AdditionalRemindersTopLevelExecuteTimer:SetText("")
		end
	end

    EVENT_MANAGER:RegisterForEvent("AdditionalRemindersBossHealth", EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("AdditionalRemindersBossHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
    EVENT_MANAGER:AddFilterForEvent("AdditionalRemindersBossHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)


    OnReticleTargetChanged = function()
    	local current, max, effectiveMax = GetUnitPower('reticleover', COMBAT_MECHANIC_FLAGS_HEALTH)
    	if max == 0 then
    		AdditionalRemindersTopLevelExecuteTimer:SetHidden(true)
    	else
    		AdditionalRemindersTopLevelExecuteTimer:SetHidden(false)
    	end

    end
    EVENT_MANAGER:RegisterForEvent("AdditionalRemindersBossHealth", EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)


end



EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, function(event, addon)
	if addon ~= addonName then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
	loadAddon()
end)