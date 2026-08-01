PurgeTracker = {
	name = "PurgeTracker",

	-- Default settings
	defaults = {
		left = 1000,
		top = 500,
		maxRows = 6,
	},

	roleIcons = {
		[LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
		[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
		[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
		[LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds",
	},

	enabled = false,
	groupSize = 0,
	units = { },
	panels = { },

	debug = false,
}

function PurgeTracker.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= PurgeTracker.name) then return end

	EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_ADD_ON_LOADED)

	PurgeTracker.vars = ZO_SavedVars:NewAccountWide("PurgeTrackerSavedVariables", 1, nil, PurgeTracker.defaults, nil, "$InstallationWide")
	PurgeTracker.InitializeControls()

	EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_PLAYER_ACTIVATED, PurgeTracker.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_RAID_TRIAL_STARTED, PurgeTracker.CheckActivation)
end

function PurgeTracker.CheckActivation( eventCode )
	-- Check wiki.esoui.com/AvA_Zone_Detection if we want to enable this for PvP
	local zoneId = GetZoneId(GetUnitZoneIndex("player"))

	if (PurgeTrackerData.zones[zoneId] or PurgeTracker.debug) then
		PurgeTracker.Reset()

		-- Workaround for when the game reports that the player is not in a group shortly after zoning
		if (PurgeTracker.groupSize == 0) then
			zo_callLater(PurgeTracker.Reset, 5000)
		end

		if (not PurgeTracker.enabled) then
			PurgeTracker.enabled = true

			EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_GROUP_MEMBER_JOINED, PurgeTracker.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_GROUP_MEMBER_LEFT, PurgeTracker.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, PurgeTracker.GroupMemberRoleChanged)
			EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, PurgeTracker.GroupSupportRangeUpdate)
			EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_EFFECT_CHANGED, PurgeTracker.EffectChanged)
			EVENT_MANAGER:AddFilterForEvent(PurgeTracker.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

			if (PurgeTrackerData.zonesTrauma[zoneId] or PurgeTracker.debug) then
				EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, PurgeTracker.AttributeVisualChanged)
				EVENT_MANAGER:AddFilterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
				EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, PurgeTracker.AttributeVisualChanged)
				EVENT_MANAGER:AddFilterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
				EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, PurgeTracker.AttributeVisualChanged)
				EVENT_MANAGER:AddFilterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
			end

			SCENE_MANAGER:GetScene("hud"):AddFragment(PurgeTracker.fragment)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(PurgeTracker.fragment)
		end
	else
		if (PurgeTracker.enabled) then
			PurgeTracker.enabled = false

			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_GROUP_MEMBER_JOINED)
			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_GROUP_MEMBER_LEFT)
			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_GROUP_MEMBER_ROLE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_EFFECT_CHANGED)

			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
			EVENT_MANAGER:UnregisterForEvent(PurgeTracker.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)

			SCENE_MANAGER:GetScene("hud"):RemoveFragment(PurgeTracker.fragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PurgeTracker.fragment)
		end
	end
end

function PurgeTracker.GroupUpdate( eventCode )
	zo_callLater(PurgeTracker.Reset, 500)
end

function PurgeTracker.GroupMemberRoleChanged( eventCode, unitTag, newRole )
	if (PurgeTracker.units[unitTag]) then
		PurgeTracker.panels[PurgeTracker.units[unitTag].panelId].role:SetTexture(PurgeTracker.roleIcons[newRole])
	end
end

function PurgeTracker.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (PurgeTracker.units[unitTag]) then
		PurgeTracker.UpdateRange(PurgeTracker.units[unitTag].panelId, status)
	end
end

function PurgeTracker.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	if (PurgeTrackerData.effects[abilityId] and PurgeTracker.units[unitTag]) then
		if (changeType == EFFECT_RESULT_FADED) then
			if (PurgeTracker.units[unitTag].effects[abilityId]) then
				PurgeTracker.units[unitTag].count = PurgeTracker.units[unitTag].count - 1
				PurgeTracker.UpdateStatus(unitTag)
			end
			PurgeTracker.units[unitTag].effects[abilityId] = nil
		elseif (stackCount >= PurgeTrackerData.effects[abilityId]) then
			if (not PurgeTracker.units[unitTag].effects[abilityId]) then
				PurgeTracker.units[unitTag].count = PurgeTracker.units[unitTag].count + 1
				PurgeTracker.UpdateStatus(unitTag)
			end
			PurgeTracker.units[unitTag].effects[abilityId] = endTime
		end

		if (PurgeTracker.debug) then
			local entry = string.format("[%d] [%d/%d] %s - %d/%s/%d - %d", changeType, GetTimeStamp(), GetGameTimeMilliseconds(), GetUnitDisplayName(unitTag), abilityId, effectName, endTime, PurgeTracker.units[unitTag].count)
			table.insert(PurgeTracker.vars.debug, entry)
			if (PurgeTracker.units[unitTag].self) then
				CHAT_SYSTEM:AddMessage(entry)
			end
		end
	end
end

function PurgeTracker.AttributeVisualChanged( eventCode, unitTag, unitAttributeVisual, _, _, _, value, newValue )
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA) then
		if (eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED) then
			PurgeTracker.units[unitTag].trauma = value
		elseif (eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED) then
			PurgeTracker.units[unitTag].trauma = 0
		elseif (eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED) then
			PurgeTracker.units[unitTag].trauma = newValue
		end
		PurgeTracker.UpdateStatus(unitTag)
	end
end

function PurgeTracker.OnMoveStop( )
	PurgeTracker.vars.left = PurgeTrackerFrame:GetLeft()
	PurgeTracker.vars.top = PurgeTrackerFrame:GetTop()
end

function PurgeTracker.InitializeControls( )
	local wm = GetWindowManager()

	for i = 1, GROUP_SIZE_MAX do
		local panel = wm:CreateControlFromVirtual("PurgeTrackerPanel" .. i, PurgeTrackerFrame, "PurgeTrackerPanel")

		PurgeTracker.panels[i] = {
			panel = panel,
			bg = panel:GetNamedChild("Backdrop"),
			name = panel:GetNamedChild("Name"),
			role = panel:GetNamedChild("Role"),
			stat = panel:GetNamedChild("Stat"),
		}

		PurgeTracker.panels[i].bg:SetEdgeColor(0, 0, 0, 0)
		PurgeTracker.panels[i].stat:SetColor(1, 0, 1, 1)
	end

	PurgeTrackerFrame:ClearAnchors()
	PurgeTrackerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PurgeTracker.vars.left, PurgeTracker.vars.top)

	PurgeTracker.fragment = ZO_HUDFadeSceneFragment:New(PurgeTrackerFrame)
end

function PurgeTracker.Reset( )
	if (PurgeTracker.debug) then
		CHAT_SYSTEM:AddMessage("[Purge Tracker] Resetting")
	end

	PurgeTracker.groupSize = GetGroupSize()
	PurgeTracker.units = { }

	for i = 1, GROUP_SIZE_MAX do
		local soloPanel = i == 1 and PurgeTracker.groupSize == 0

		if (i <= PurgeTracker.groupSize or soloPanel) then
			local unitTag = (soloPanel) and "player" or GetGroupUnitTagByIndex(i)

			PurgeTracker.units[unitTag] = {
				panelId = i,
				count = 0,
				effects = { },
				trauma = 0,
				self = AreUnitsEqual("player", unitTag),
			}

			PurgeTracker.panels[i].name:SetText(GetUnitDisplayName(unitTag))
			PurgeTracker.panels[i].role:SetTexture(PurgeTracker.roleIcons[GetGroupMemberSelectedRole(unitTag)])

			PurgeTracker.UpdateStatus(unitTag)
			PurgeTracker.UpdateRange(i, IsUnitInGroupSupportRange(unitTag))

			if (i == 1) then
				PurgeTracker.panels[i].panel:SetAnchor(TOPLEFT, PurgeTrackerFrame, TOPLEFT, 0, 0)
			elseif (i <= PurgeTracker.vars.maxRows) then
				PurgeTracker.panels[i].panel:SetAnchor(TOPLEFT, PurgeTracker.panels[i - 1].panel, BOTTOMLEFT, 0, 0)
			else
				PurgeTracker.panels[i].panel:SetAnchor(TOPLEFT, PurgeTracker.panels[i - PurgeTracker.vars.maxRows].panel, TOPRIGHT, 0, 0)
			end

			PurgeTracker.panels[i].panel:SetHidden(false)
		else
			PurgeTracker.panels[i].panel:SetAnchor(TOPLEFT, PurgeTrackerFrame, TOPLEFT, 0, 0)
			PurgeTracker.panels[i].panel:SetHidden(true)
		end
	end
end

function PurgeTracker.UpdateStatus( unitTag )
	local bg = PurgeTracker.panels[PurgeTracker.units[unitTag].panelId].bg

	if (PurgeTracker.units[unitTag].count < 1) then
		bg:SetCenterColor(0, 0, 0, 0.5)
	elseif (PurgeTracker.units[unitTag].self) then
		bg:SetCenterColor(1, 0, 0, 1)
	else
		bg:SetCenterColor(0.8, 0.2, 0, 0.8)
	end

	local stat = PurgeTracker.panels[PurgeTracker.units[unitTag].panelId].stat

	if (PurgeTracker.units[unitTag].trauma == 0) then
		stat:SetText("")
	else
		stat:SetText(string.format("%dk", (PurgeTracker.units[unitTag].trauma + 500) / 1000))
	end
end

function PurgeTracker.UpdateRange( panelId, status )
	if (status) then
		PurgeTracker.panels[panelId].panel:SetAlpha(1)
	else
		PurgeTracker.panels[panelId].panel:SetAlpha(0.5)
	end
end

function PurgeTracker.EnableDebug( )
	PurgeTracker.debug = true

	PurgeTrackerData.effects[17906] = 0 -- Crusher
	PurgeTrackerData.effects[17945] = 0 -- Weakening
	PurgeTrackerData.effects[36245] = 0 -- Concealed Weapon IV
	PurgeTrackerData.effects[37921] = 0 -- Crippling Grasp IV
	PurgeTrackerData.effects[43083] = 0 -- Consuming Trap IV
	PurgeTrackerData.effects[88991] = 0 -- Weakened to Shock
	PurgeTrackerData.effects[88992] = 0 -- Shocked

	if (not PurgeTracker.vars.debug) then
		PurgeTracker.vars.debug = { }
	end

	PurgeTracker.CheckActivation()
end

EVENT_MANAGER:RegisterForEvent(PurgeTracker.name, EVENT_ADD_ON_LOADED, PurgeTracker.OnAddOnLoaded)
