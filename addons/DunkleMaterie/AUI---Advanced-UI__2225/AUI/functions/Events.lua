local function OnActionLayerPopped(eventCode, layerIndex, activeLayerIndex)
	if layerIndex ~= 5 then
		if AUI_MINIMAP_SCENE_FRAGMENT then
			AUI_MINIMAP_SCENE_FRAGMENT.allowToggle = true
		end
	end
	
	AUI.HideMouseMenu()
end

local function OnActionLayerPushed(eventCode, layerIndex, activeLayerIndex)
	if layerIndex ~= 7 then
		if AUI_MINIMAP_SCENE_FRAGMENT then
			AUI_MINIMAP_SCENE_FRAGMENT.allowToggle = false	
		end
	end
	
	AUI.HideMouseMenu()
end

local function OnPlayerActivated(_eventCode)
	if AUI.IsLoaded() then
		AUI.SendStartMessage()
	end

	OnActionLayerPopped(0, 0, 0)

	if AUI.Actionbar.IsEnabled() then	
		AUI.Actionbar.UpdateUI()	
	end
	
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Theme.Load()	
		AUI.Minimap.Map.Refresh()		
	end

	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.OnPlayerActivated()
	end
	
	if AUI.Buffs.IsEnabled() then
		AUI.Buffs.OnPlayerActivated()
	end	

	if AUI.Combat.IsEnabled() then
		local powerValue, powerMax, powerEffectiveMax = GetUnitPower(AUI_PLAYER_UNIT_TAG, POWERTYPE_ULTIMATE)
		AUI.Combat.OnPowerUpdate(AUI_PLAYER_UNIT_TAG, 4, POWERTYPE_ULTIMATE, powerValue, powerMax, powerEffectiveMax)
		AUI.Combat.OnGroupUpdate()
	end
	
	if AUI.FrameMover.IsEnabled() then
		AUI.FrameMover.OnPlayerActivated()
	end		
end

local function OnPlayerDeactivated(_eventCode)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RemovePins()
	end
end

local function OnPowerUpdate(_eventCode, _unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	if _unitTag == nil or _powerType == nil then
		return
	end	
	
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	end
	
	if AUI.Actionbar.IsEnabled() then
		AUI.Actionbar.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	end			
	
	if AUI.Combat.IsEnabled() then
		AUI.Combat.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	end		
end

local function OnUnitAttributeVisualAdded(_eventCode, _unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax)
	if _unitTag == nil or _powerType == nil then
		return
	end

	if AUI.Attributes.IsEnabled() then
		if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then	
			_, _powerMax, _ = GetUnitPower(_unitTag, _powerType)	
		end

		AUI.Attributes.AddAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _powerMax, true)
	end
end

local function OnUnitAttributeVisualRemoved(_eventCode, _unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax)
	if _unitTag == nil or _powerType == nil then
		return
	end

	if AUI.Attributes.IsEnabled() then
		if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then	
			_, _powerMax, _ = GetUnitPower(_unitTag, _powerType)
			_powerValue = 0		
		else
			_powerValue = 0
			_powerMax = 0
		end	
		
		AUI.Attributes.RemoveAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _powerMax, true)
	end
end

local function OnUnitAttributeVisualUpdated(_eventCode, _unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _oldPowerValue, _newPowerValue, _oldPowerMaxValue, _newPowerMaxValue)
	if _unitTag == nil or _powerType == nil then
		return
	end

	if AUI.Attributes.IsEnabled() then
		if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then	
			_, _newPowerMaxValue, _ = GetUnitPower(_unitTag, _powerType)
			
		end	

		AUI.Attributes.UpdateAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _newPowerValue, _newPowerMaxValue, _newPowerMaxValue, true)	
	end		
end

local function OnUnitDeathStateChanged(_eventCode, _unitTag, _isDead)
	if _unitTag ~= AUI_PLAYER_UNIT_TAG then
		if AUI.Attributes.IsEnabled() then
			AUI.Attributes.Update(_unitTag)
		end
	end
end

local function OnPlayerAlive(_eventCode)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Update(AUI_PLAYER_UNIT_TAG)
		AUI.Attributes.Target.OnChanged()		
	end
end

local function OnPlayerDead(_eventCode)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Update(AUI_PLAYER_UNIT_TAG)
	end
end

local function OnUnitCreated(eventCode, _unitTag)
	zo_callLater(function()
		if AUI.Unit.IsGroupUnitTag(_unitTag) then
			if AUI.Attributes.IsEnabled() then
				AUI.Attributes.Group.UpdateUI(_unitTag)
			end	
			
			if AUI.Combat.IsEnabled() then
				AUI.Combat.OnGroupUpdate()
			end	
		end
	end, 60)
end

local function OnUnitDestroyed(eventCode, _unitTag)
	zo_callLater(function()
		if AUI.Unit.IsGroupUnitTag(_unitTag) then
			if AUI.Attributes.IsEnabled() then
				AUI.Attributes.Update(_unitTag)
				AUI.Attributes.Group.UpdateUI(_unitTag)
			end

			if AUI.Combat.IsEnabled() then
				AUI.Combat.OnGroupUpdate()
			end
		end
	end, 60)	
end

local function OnUnitFrameUpdate(eventCode, _unitTag)
	if AUI.Attributes.IsEnabled() and AUI.Unit.IsGroupUnitTag(_unitTag) then
		AUI.Attributes.Update(_unitTag)
	end
end

local function OnUnitLeaderUpdate(_eventCode, _unitTag)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Group.UpdateUI(_unitTag)
	end	
end

local function OnGroupMemberConnectedStatus(_eventCode, _unitTag, _isOnline)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Update(_unitTag)
	end
end

local function OnGroupTypeChanged(_eventCode, _largeGroup)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Group.UpdateUI()
	end
end

local function OnLevelUpdate(_eventCode, _unitTag, _level)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Update(_unitTag)
	end	
	
	if AUI.Combat.IsEnabled() then		
		AUI.Combat.OnLevelUpdate()			
	end		
end

local function OnGroupSupportRangeUpdate(_eventCode, _unitTag, _status)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Update(_unitTag)
	end	
end

local function OnReticleTargetChanged(_eventCode)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.OnReticleTargetChanged()
	end
	
	if AUI.Buffs.IsEnabled() then
		AUI.Buffs.OnTargetChanged()
	end	
end

local function OnCombatEvent(_eventCode, _result, _isError, _abilityName, _abilityGraphic, _abilityActionSlotType, _sourceName, _sourceType, _targetName, _targetType, _hitValue, _powerType, _damageType, _log, _sourceUnitId_, _targetUnitId_, _abilityId)
	if AUI.Combat.IsEnabled() then
		AUI.Combat.OnCombatEvent(_eventCode, _result, _isError, _abilityName, _abilityGraphic, _abilityActionSlotType, _sourceName, _sourceType, _targetName, _targetType, _hitValue, _powerType, _damageType, _log, _sourceUnitId_, _targetUnitId_, _abilityId)
	end		
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
	if AUI.Combat.IsEnabled() then	
		AUI.Combat.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)	
	end	

	if AUI.Actionbar.IsEnabled() then			
		AUI.Actionbar.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)	
	end	
	
	if AUI.Buffs.IsEnabled() then			
		AUI.Buffs.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)	
	end	
end

local function OnEffectsFullUpdate(eventCode)
	if AUI.Buffs.IsEnabled() then			
		AUI.Buffs.OnEffectChanged(AUI_PLAYER_UNIT_TAG)
		AUI.Buffs.OnEffectChanged(AUI_TARGET_UNIT_TAG)
	end		
end

local function OnPlayerCombatState(_eventCode, _inCombat)
	if AUI.Combat.IsEnabled() then			
		AUI.Combat.OnPlayerCombatState(_inCombat)	
	end	
	
	if _inCombat then		
		if AUI.Minimap.IsEnabled() and AUI.Settings.Minimap.enable then
			if AUI.Settings.Minimap.hide_in_combat then
				AUI.Minimap.Hide()
			end
		end		
	else		
		if AUI.Minimap.IsEnabled() and AUI.Settings.Minimap.hide_in_combat and AUI.Settings.Minimap.enable then
			if AUI.Settings.Minimap.hide_in_combat then
				AUI.Minimap.Show()
			end
		end
	end	
end

local function OnWerewolfStateChanged(eventCode, werewolf)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Update(AUI_PLAYER_UNIT_TAG)
	end	
end

local function OnAssistStateChanged(unassistedData, assistedData)
	if unassistedData then
		if AUI.Minimap.IsEnabled() then
			AUI.Minimap.Pin.RefreshSingleQuestPin(unassistedData:GetJournalIndex())
		end
	end
	
	if assistedData then
		if AUI.Minimap.IsEnabled() then
			AUI.Minimap.Pin.RefreshSingleQuestPin(assistedData:GetJournalIndex())
		end
	end
	
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.Update()
	end			
end

local function OnQuestAdvanced(eventCode, journalIndex, questName, isPushed, isComplete, mainStepChanged)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshSingleQuestPin(journalIndex)
	end
	
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.Update()
	end		
end

local function OnQuestAdded(eventCode, journalIndex, questName, objectiveName)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshQuestPins()
	end
	
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.Update()
	end		
end

local function OnQuestRemoved(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshSingleQuestPin(journalIndex)
	end
	
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.Update()
	end		
end

local function OnQuestListUpdated(eventCode)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshQuestPins()
	end
	
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.Update()
	end		
end

local function OnLinkedWorldPositionChanged(eventCode)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshQuestPins()
	end
end

local function OnQuestConditionCounterChanged(eventCode, journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshSingleQuestPin(journalIndex)
	end
	
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.Update()
	end		
end

local function OnQuestPositionRequestComplete(eventCode, taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.AddQuestPin(taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)
	end
end

local function OnQuestTimerUpdated(eventCode, journalIndex)
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.UpdateQuestTimer(journalIndex)
	end		
end

local function OnActionSlotUpdated(eventCode, slotId)
	if AUI.Actionbar.IsEnabled() then
		AUI.Actionbar.OnActionSlotUpdated(slotId)
	end
end

local function OnActionUpdateCooldowns(eventCode) 
	if AUI.Combat.IsEnabled() then
		AUI.Combat.OnActionUpdateCooldowns()
	end	
	
	if AUI.Actionbar.IsEnabled() then
		AUI.Actionbar.UpdateCooldowns()
	end	
end

local function OnActionSlotsFullUpdate(eventCode, isHotbarSwap)
	if AUI.Actionbar.IsEnabled() then
		AUI.Actionbar.OnActionSlotsFullUpdate(isHotbarSwap)
	end
end

local function OnKeepInitialized(eventCode, keepId, bgContext)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshKeep(keepId, bgContext)
	end
end

local function OnKeepAllianceOwnerChanged(eventCode, keepId, bgContext, owningAlliance) 
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshKeep(keepId, bgContext)
	end
end

local function OnKeepGateStateChanged(eventCode, keepId, open)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshKeep(keepId, BGQUERY_LOCAL)
	end
end

local function OnKeepResourceUpdate(eventCode, keepId)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshKeep(keepId, BGQUERY_LOCAL)
	end
end

local function OnKeepUnderAttackChanged(eventCode, keepId, bgContext, underAttack)
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.RefreshKeep(keepId, bgContext)
	end
end

local function OnBeginSiegeControl(eventCode) 
	AUI.Attributes.UpdateSingleBar(AUI_CONTROLED_SIEGE_UNIT_TAG, POWERTYPE_HEALTH)
end

local function OnEndSiegeControl(eventCode) 
	AUI.Attributes.UpdateSingleBar(AUI_CONTROLED_SIEGE_UNIT_TAG, POWERTYPE_HEALTH)
end

local function OnLeaveRamEscort(eventCode) 
	AUI.Attributes.UpdateSingleBar(AUI_CONTROLED_SIEGE_UNIT_TAG, POWERTYPE_HEALTH)
end

local function OnBossesChanged(eventCode)
	AUI.Attributes.Bossbar.OnChanged()
end

local function OnExperienceUpdate(eventCode, unitTag, currentExp, maxExp, reason)
	if reason ~= CURRENCY_CHANGE_REASON_PLAYER_INIT then
		if AUI.Combat.IsEnabled() then
			if unitTag == AUI_PLAYER_UNIT_TAG then
				AUI.Combat.OnExperienceUpdate(unitTag, currentExp, maxExp, reason)
			end
		end
	end
end

local function OnAlliancePointUpdate(eventCode, alliancePoints, playSound, difference)
	AUI.Combat.OnAlliancePointUpdate(alliancePoints, difference)
end

local function OnInventoryItemUsed(eventCode, itemSoundCategory)
	if AUI.Combat.IsEnabled() then
		AUI.Combat.OnInventoryItemUsed(itemSoundCategory)
	end	
end

local function OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason)
	if AUI.Actionbar.IsEnabled() then			
		AUI.Actionbar.OnInventorySingleSlotUpdate(bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason)	
	end	
	
	if AUI.Combat.WeaponChargeWarner.IsEnabled() and bagId == BAG_WORN then			
		AUI.Combat.WeaponChargeWarner.Update(slotId)
	end		
end

local function OnTelVarStoneUpdate(eventCode, newTelvarStones, oldTelvarStones, reason)
	if reason ~= CURRENCY_CHANGE_REASON_PLAYER_INIT then
		AUI.Combat.OnTelVarStoneUpdate(newTelvarStones, oldTelvarStones)
	end
end

local function OnScreenResized(eventCode, x, y, guiName)
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.UpdateUI()
	end	
	
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Pin.UpdatePins()
	end	
end

local function OnGamepadPreferredModeChanged(eventCode, gamepadPreferred)
	if AUI.Actionbar.IsEnabled() then
		AUI.Actionbar.OnGamepadPreferredModeChanged(gamepadPreferred)
	end	
	
	if AUI.FrameMover.IsEnabled() then
		AUI.FrameMover.OnGamepadPreferredModeChanged(gamepadPreferred)
	end		
end

function AUI.LoadEvents()
	--Abilities, Attributes, and XP 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_POWER_UPDATE", EVENT_POWER_UPDATE, OnPowerUpdate)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_LEVEL_UPDATE", EVENT_LEVEL_UPDATE, OnLevelUpdate)	
	
	--Life and Death
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_UNIT_DEATH_STATE_CHANGED", EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeathStateChanged)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_PLAYER_ALIVE", EVENT_PLAYER_ALIVE, OnPlayerAlive)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_PLAYER_DEAD ", EVENT_PLAYER_DEAD , OnPlayerDead)	
	
	--UI 	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)			
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_PLAYER_DEACTIVATED", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)			
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_SCREEN_RESIZED", EVENT_SCREEN_RESIZED, OnScreenResized)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_ACTION_LAYER_POPPED", EVENT_ACTION_LAYER_POPPED, OnActionLayerPopped)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_ACTION_LAYER_PUSHED", EVENT_ACTION_LAYER_PUSHED, OnActionLayerPushed)	
 	 
	--Groups 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_LEADER_UPDATE", EVENT_LEADER_UPDATE, OnUnitLeaderUpdate)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_GROUP_MEMBER_CONNECTED_STATUS", EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupMemberConnectedStatus)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_GROUP_TYPE_CHANGED", EVENT_GROUP_TYPE_CHANGED, OnGroupTypeChanged)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_GROUP_SUPPORT_RANGE_UPDATE", EVENT_GROUP_SUPPORT_RANGE_UPDATE, OnGroupSupportRangeUpdate)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_UNIT_CREATED", EVENT_UNIT_CREATED, OnUnitCreated)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_UNIT_DESTROYED", EVENT_UNIT_DESTROYED, OnUnitDestroyed)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_UNIT_FRAME_UPDATE", EVENT_UNIT_FRAME_UPDATE, OnUnitFrameUpdate)	
	
	--Keep
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_KEEP_INITIALIZED", EVENT_KEEP_INITIALIZED, OnKeepInitialized)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_KEEP_ALLIANCE_OWNER_CHANGED", EVENT_KEEP_ALLIANCE_OWNER_CHANGED, OnKeepAllianceOwnerChanged)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_KEEP_GATE_STATE_CHANGED", EVENT_KEEP_GATE_STATE_CHANGED, OnKeepGateStateChanged)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_KEEP_RESOURCE_UPDATE", EVENT_KEEP_RESOURCE_UPDATE, OnKeepResourceUpdate)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_KEEP_UNDER_ATTACK_CHANGED", EVENT_KEEP_UNDER_ATTACK_CHANGED, OnKeepUnderAttackChanged)	
	
	--Combat 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnUnitAttributeVisualAdded)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnUnitAttributeVisualRemoved)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnUnitAttributeVisualUpdated)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_COMBAT_EVENT", EVENT_COMBAT_EVENT, OnCombatEvent)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)			
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_BOSSES_CHANGED", EVENT_BOSSES_CHANGED, OnBossesChanged)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED, OnEffectChanged)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_EFFECTS_FULL_UPDATE", EVENT_EFFECTS_FULL_UPDATE, OnEffectsFullUpdate)
    EVENT_MANAGER:RegisterForEvent("AUI_EVENT_WEREWOLF_STATE_CHANGED", EVENT_WEREWOLF_STATE_CHANGED, OnWerewolfStateChanged)

	--Experience
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_EXPERIENCE_UPDATE", EVENT_EXPERIENCE_UPDATE, OnExperienceUpdate)
	
	--Inventory and Money 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_ALLIANCE_POINT_UPDATE", EVENT_ALLIANCE_POINT_UPDATE, OnAlliancePointUpdate)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_INVENTORY_ITEM_USED", EVENT_INVENTORY_ITEM_USED, OnInventoryItemUsed)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdate)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_TELVAR_STONE_UPDATE", EVENT_TELVAR_STONE_UPDATE, OnTelVarStoneUpdate)
	
	--Action Bar 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_ACTION_SLOT_UPDATED", EVENT_ACTION_SLOT_UPDATED, OnActionSlotUpdated)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_ACTION_UPDATE_COOLDOWNS", EVENT_ACTION_UPDATE_COOLDOWNS, OnActionUpdateCooldowns)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_ACTION_SLOT_STATE_UPDATED", EVENT_ACTION_SLOTS_FULL_UPDATE , OnActionSlotsFullUpdate)
	
	--Quests
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_QUEST_ADDED", EVENT_QUEST_ADDED, OnQuestAdded)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_QUEST_REMOVED", EVENT_QUEST_REMOVED, OnQuestRemoved)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_QUEST_LIST_UPDATED", EVENT_QUEST_LIST_UPDATED, OnQuestListUpdated)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_QUEST_CONDITION_COUNTER_CHANGED", EVENT_QUEST_CONDITION_COUNTER_CHANGED, OnQuestConditionCounterChanged)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_QUEST_ADVANCED", EVENT_QUEST_ADVANCED, OnQuestAdvanced)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_QUEST_POSITION_REQUEST_COMPLETE", EVENT_QUEST_POSITION_REQUEST_COMPLETE, OnQuestPositionRequestComplete)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_QUEST_TIMER_UPDATED", EVENT_QUEST_TIMER_UPDATED, OnQuestTimerUpdated)		
	
	--Siege Weapons 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_BEGIN_SIEGE_CONTROL", EVENT_BEGIN_SIEGE_CONTROL, OnBeginSiegeControl)	
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_END_SIEGE_CONTROL", EVENT_END_SIEGE_CONTROL, OnEndSiegeControl)
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_LEAVE_RAM_ESCORT", EVENT_LEAVE_RAM_ESCORT, OnLeaveRamEscort)	
	
	--Miscellaneous 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_LINKED_WORLD_POSITION_CHANGED", EVENT_LINKED_WORLD_POSITION_CHANGED, OnLinkedWorldPositionChanged)
	
	--UI Gamepad 
	EVENT_MANAGER:RegisterForEvent("AUI_EVENT_GAMEPAD_PREFERRED_MODE_CHANGED", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)
	
	--Callbacks
	FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", OnAssistStateChanged)	
end