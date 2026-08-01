function btg.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= btg.name) then return end

	EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_ADD_ON_LOADED)

	btg.savedVars = ZO_SavedVars:NewCharacterIdSettings("BuffTheGroupSavedVariables", btg.variableVersion, nil, btg.defaults, nil, GetWorldName())
	btg.InitializeControls()
	SLASH_COMMANDS["/btg"] = btg.HandleCommandInput
	SLASH_COMMANDS["/btgrefresh"] = btg.CheckActivation

	EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_PLAYER_ACTIVATED, btg.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_RAID_TRIAL_STARTED, btg.CheckActivation)
	btg.buildMenu()
end

function btg.HandleCommandInput(args)
	
	btg.savedVars.enabled = not btg.savedVars.enabled
	CHAT_SYSTEM:AddMessage("[BTG] " .. (btg.savedVars.enabled and "Enabled" or "Disabled"))
	btg.CheckActivation()
end

function btg.CheckActivation( eventCode )
	-- Check wiki.esoui.com/AvA_Zone_Detection if we want to enable this for PvP
	local zoneId = GetZoneId(GetUnitZoneIndex("player"))
	if (((btgData.zones[zoneId] and GetGroupSize() > 1) or btg.debug) and btg.savedVars.enabled) then
		btg.Reset()

		if (not btg.showUI) then
			btg.showUI = true

			EVENT_MANAGER:AddFilterForEvent(btg.name, EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, btg.GroupMemberRoleChanged)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, btg.GroupSupportRangeUpdate)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_EFFECT_CHANGED, btg.EffectChanged)
			EVENT_MANAGER:RegisterForUpdate(btg.name.."Cycle", 100, btg.refreshUI)

			if(not btg.debug) then
				EVENT_MANAGER:AddFilterForEvent(btg.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
			end
		end
		for index, fragment in pairs(btg.fragments) do
			if(btg.savedVars.trackedBuffs[index]) then
				SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
				SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
			else
				SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
				SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)
			end
		end
	else
		if (btg.showUI) then
			btg.showUI = false

			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_CREATED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_JOINED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_LEFT)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_ROLE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_EFFECT_CHANGED)

			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
		end
		for _, fragment in pairs(btg.fragments) do
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)
		end
	end
end

function btg.GroupUpdate( eventCode )
	zo_callLater(btg.CheckActivation, 500)
end

function btg.GroupMemberRoleChanged( eventCode, unitTag, newRole )
	local unit = btg.units[unitTag]
	if (unit) then
		for i, _ in pairs(btgData.buffs) do
			btg.frames[i].panels[unit.panelId].role:SetTexture(btgData.roleIcons[newRole])
			zo_callLater(btg.CheckActivation, 500)
		end
	end
end

function btg.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (btg.units[unitTag]) then
		for i, _ in pairs(btgData.buffs) do
			btg.UpdateRange(i, btg.units[unitTag].panelId, status)
		end
	end
end

function btg.refreshUI()
	for i, _ in pairs(btgData.buffs) do
		local unitsWithBuff = 0
		local minBuffDuration = 999
		local minBuffEndTime
		for unitTag, unit in pairs(btg.units) do
			if(btg.savedVars.minimalMode) then
				local buffData = unit.buffs[i]	
				if(buffData and buffData.hasBuff) then
					unitsWithBuff = unitsWithBuff + 1
					if ( minBuffDuration > buffData.buffDuration ) then
						minBuffDuration = buffData.buffDuration
						minBuffEndTime = buffData.endTime
					end
				end
			else
				btg.UpdateStatus(i, unitTag)
			end
		end
		if(btg.savedVars.minimalMode) then
			btg.UpdatePercent(i, unitsWithBuff, minBuffDuration, minBuffEndTime)
		end
	end
end

function btg.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	for index, buffId in pairs(btgData.buffs) do
		if (btg.savedVars.trackedBuffs[index]) then
			if (buffId == abilityId and btg.units[unitTag]) then
				if index < 1000 then
					if (changeType == EFFECT_RESULT_FADED) then
						btg.units[unitTag].buffs[index].hasBuff = false
						btg.units[unitTag].buffs[index].endTime = 0
					elseif ((changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) and (beginTime == 0 or endTime == 0 or beginTime == endTime)) then -- gained permanent (or decaying) effect	
						btg.units[unitTag].buffs[index].hasBuff = true
						btg.units[unitTag].buffs[index].endTime = -1
						btg.units[unitTag].buffs[index].buffDuration = -1
					else
						btg.units[unitTag].buffs[index].hasBuff = true
						btg.units[unitTag].buffs[index].endTime = endTime
						btg.units[unitTag].buffs[index].buffDuration = endTime - beginTime
					end
				else
					-- is a decaying buff being tracked
					if(changeType == EFFECT_RESULT_GAINED) then
						btg.units[unitTag].buffs[index].hasBuff = true
						btg.units[unitTag].buffs[index].endTime = -1
						btg.units[unitTag].buffs[index].buffDuration = -1
					elseif (changeType == EFFECT_RESULT_FADED) then
						local cooldownId = btgData.buffDecayedIDs[index]
						btg.units[unitTag].buffs[index].hasBuff = true
						btg.units[unitTag].buffs[index].endTime = GetGameTimeMilliseconds()/1000 + GetAbilityDuration(cooldownId)/1000 - GetAbilityDuration(abilityId)/1000
						btg.units[unitTag].buffs[index].buffDuration = GetAbilityDuration(cooldownId)/1000
					end
				end
			end
		end
	end
end

function btg.OnMoveStop(i, frame)
	btg.savedVars.framePositions[i].left = frame:GetLeft()
	btg.savedVars.framePositions[i].top = frame:GetTop()
end

function btg.InitializeControls( )
	local wm = GetWindowManager()

	for i, _ in pairs(btgData.buffs) do
		local frame = wm:CreateControlFromVirtual("btgFrame" .. i, btgUI, "btgFrame")

		frame:SetHandler("OnMoveStop", function() btg.OnMoveStop(i, frame) end)

		btg.frames[i] = {
			frame = frame,
			panels = {},
		}
		
		_G["btgFrame"..i.."MinimalBackdrop"]:SetEdgeColor(0, 0, 0, 0)
		_G["btgFrame"..i.."MinimalBackdrop"]:SetCenterColor(0, 0, 0, 0.5)


		for j = 1, GROUP_SIZE_MAX do
			local panel = wm:CreateControlFromVirtual("btgPanel" .. i .. "_" .. j, frame, "btgPanel")

			btg.frames[i].panels[j] = {
				panel = panel,
				bg = panel:GetNamedChild("Backdrop"),
				name = panel:GetNamedChild("Name"),
				role = panel:GetNamedChild("Role"),
				stat = panel:GetNamedChild("Stat"),
			}

			btg.frames[i].panels[j].bg:SetEdgeColor(0, 0, 0, 0)
			btg.frames[i].panels[j].bg:SetCenterColor(0, 0, 0, 0.5)
			btg.frames[i].panels[j].stat:SetColor(1, 1, 1, 1)
			btg.frames[i].panels[j].stat:SetText("0")
		end

		frame:ClearAnchors()
		frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btg.savedVars.framePositions[i].left, btg.savedVars.framePositions[i].top)

		btg.fragments[i] = ZO_HUDFadeSceneFragment:New(frame)
	end
end

function btg.Reset( )

	for i, _ in pairs(btgData.buffs) do
		for j = 1, GROUP_SIZE_MAX do
			btg.frames[i].panels[j].panel:ClearAnchors()
			btg.frames[i].panels[j].panel:SetHidden(true)
		end
	end

	btg.groupSize = GetGroupSize()
	btg.units = {}
	
	for i, _ in pairs(btgData.buffs) do
		_G["btgFrame"..i.."Icon"]:SetTexture(btgData.buffIcons[i])
		_G["btgFrame"..i.."MinimalBackdrop"]:SetHidden(not btg.savedVars.minimalMode)
		_G["btgFrame"..i.."Percent"]:SetHidden(not btg.savedVars.minimalMode)
	end

	local panelIndex = 1
	for j = 1, GROUP_SIZE_MAX do
		if (j <= btg.groupSize or j == 1 and btg.groupSize == 0) then
			local unitTag = (j == 1 and btg.groupSize == 0) and "player" or GetGroupUnitTagByIndex(j)
			if (not btg.savedVars.showOnlyDPS or GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_DPS) then
				btg.units[unitTag] = {
					panelId = panelIndex,
					self = AreUnitsEqual("player", unitTag),
					buffs = {},
				}
				panelIndex = panelIndex + 1
				for i, _ in pairs(btgData.buffs) do
					btg.units[unitTag].buffs[i] = {
						hasBuff = false,
						endTime = 0,
						buffDuration = 0,
					}
				end
			end
		end
	end

	for i, _ in pairs(btgData.buffs) do
		panelIndex = 1
		for j = 1, GROUP_SIZE_MAX do
			local soloPanel = j == 1 and btg.groupSize == 0
			local unitTag = (soloPanel) and "player" or GetGroupUnitTagByIndex(j)
			if (not btg.savedVars.showOnlyDPS or GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_DPS) then
				if (j <= btg.groupSize or soloPanel) then

					btg.frames[i].panels[panelIndex].name:SetText(GetUnitDisplayName(unitTag))
					btg.frames[i].panels[panelIndex].role:SetTexture(btgData.roleIcons[GetGroupMemberSelectedRole(unitTag)])

					btg.UpdateStatus(i, unitTag)
					btg.UpdateRange(i, panelIndex, IsUnitInGroupSupportRange(unitTag))

					if (panelIndex == 1) then
						btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btgFrame, TOPLEFT, 0, 0)
					elseif (panelIndex <= btg.savedVars.maxRows) then
						btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btg.frames[i].panels[panelIndex - 1].panel, BOTTOMLEFT, 0, 0)
					else
						btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btg.frames[i].panels[panelIndex - btg.savedVars.maxRows].panel, TOPRIGHT, 0, 0)
					end

					btg.frames[i].panels[panelIndex].panel:SetHidden(btg.savedVars.minimalMode)
				else
					btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btgFrame, TOPLEFT, 0, 0)
					btg.frames[i].panels[panelIndex].panel:SetHidden(true)
				end
				panelIndex = panelIndex + 1
			end
		end
	end
end

function btg.UpdateStatus( buffIndex, unitTag )
	local unit = btg.units[unitTag]
	local buffData = unit.buffs[buffIndex]
	local panel = btg.frames[buffIndex].panels[unit.panelId]
	local now = GetFrameTimeMilliseconds() / 1000

	if( buffData.endTime ) then
		local buffRemaining = buffData.endTime - now

		local startR, startG, startB = btg.savedVars.startR, btg.savedVars.startG, btg.savedVars.startB
		local endR, endG, endB = btg.savedVars.endR, btg.savedVars.endG, btg.savedVars.endB

		local progress = btg.savedVars.gradientMode and btgUtil.Clamp(1 - buffRemaining / buffData.buffDuration, 0, 1) or 0
		local r, g, b = (btg.savedVars.gradientMode and btgUtil.Interpolate(startR, endR, progress) or startR) / 255,
		                (btg.savedVars.gradientMode and btgUtil.Interpolate(startG, endG, progress) or startG) / 255,
		                (btg.savedVars.gradientMode and btgUtil.Interpolate(startB, endB, progress) or startB) / 255

		if ( buffRemaining > 0 ) then
			panel.stat:SetText(string.format("%.1f", buffRemaining))
			if (unit.self) then
				panel.bg:SetCenterColor(r, g, b, 1-0.4*progress)
			else
				panel.bg:SetCenterColor(r, g, b, 0.8-0.5*progress)
			end
		elseif ( buffData.endTime == -1 ) then 
			panel.stat:SetText("")
			if (unit.self) then
				panel.bg:SetCenterColor(r, g, b, 1)
			else
				panel.bg:SetCenterColor(r, g, b, 0.8)
			end
		else
			panel.bg:SetCenterColor(0, 0, 0, 0.5)
			panel.stat:SetText("0")
			if(not buffData.hasBuff) then
				buffData.endTime = nil
			end
		end
	end
end

function btg.UpdatePercent( buffIndex, unitsWithBuff, minBuffDuration, minBuffEndTime )
	_G["btgFrame"..buffIndex.."Percent"]:SetText(string.format("%i%%", unitsWithBuff * 100 / btg.groupSize))
	_G["btgFrame"..buffIndex.."MinimalBackdrop"]:SetCenterColor(0, 0, 0, 0.5)

	local now = GetFrameTimeMilliseconds() / 1000

	if( minBuffEndTime ) then
		
		local buffRemaining = minBuffEndTime - now

		local startR, startG, startB = btg.savedVars.startR, btg.savedVars.startG, btg.savedVars.startB
		local endR, endG, endB = btg.savedVars.endR, btg.savedVars.endG, btg.savedVars.endB

		local progress = btg.savedVars.gradientMode and btgUtil.Clamp(1 - buffRemaining / minBuffDuration, 0, 1) or 0
		local r, g, b = (btg.savedVars.gradientMode and btgUtil.Interpolate(startR, endR, progress) or startR) / 255,
		                (btg.savedVars.gradientMode and btgUtil.Interpolate(startG, endG, progress) or startG) / 255,
		                (btg.savedVars.gradientMode and btgUtil.Interpolate(startB, endB, progress) or startB) / 255

		if ( buffRemaining > 0 ) then 
			_G["btgFrame"..buffIndex.."MinimalBackdrop"]:SetCenterColor(r, g, b, 1-0.4*progress)
		elseif ( minBuffEndTime == -1) then
			_G["btgFrame"..buffIndex.."MinimalBackdrop"]:SetCenterColor(r, g, b, 1)
		else
			_G["btgFrame"..buffIndex.."Percent"]:SetText(string.format("%i%%", 0))
			_G["btgFrame"..buffIndex.."MinimalBackdrop"]:SetCenterColor(0, 0, 0, 0.5)
		end
	end

end

function btg.UpdateRange( buffIndex, panelId, status )
	if (status) then
		btg.frames[buffIndex].panels[panelId].panel:SetAlpha(1)
	else
		btg.frames[buffIndex].panels[panelId].panel:SetAlpha(0.5)
	end
end

EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_ADD_ON_LOADED, btg.OnAddOnLoaded)
