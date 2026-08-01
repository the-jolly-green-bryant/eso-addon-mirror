ROTracker = {
	name = "ROTracker",

	-- Default settings
	defaults = {
		left = 1000,
		top = 500,
		maxRows = 12,
		givenSlayer = true;
		colors = {
			["slayer"] = {
				0, 1, 0, 1,
			},
			["cooldown"] = {
				0, .5, 0, 1,
			},
		},
		playSound = true,
		sound = "Duel_Boundary_Warning",
		soundDelay = 0,
		cooldownTextSize = 48,

	},

	roleIcons = {
		[LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
		[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
		[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
		[LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds",
	},

	enabled = false,
	groupSize = 0,
	canReceive = 0,
	activeRO = 0,
	lastLength = 0,
	topTimer = 0,
	lastSoundPlayed = 0,
	RO = false,
	units = { },
	panels = { },
}

function ROTracker.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= ROTracker.name) then return end
	EVENT_MANAGER:UnregisterForEvent(ROTracker.name, EVENT_ADD_ON_LOADED)

	ROTracker.vars = ZO_SavedVars:NewCharacterIdSettings("ROTrackerSavedVariables", 1, nil, ROTracker.defaults, GetWorldName())
	ROTracker.InitializeControls()

	ROTracker.setupMenu()
	ROTracker.gearUpdate()

	EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_PLAYER_ACTIVATED, ROTracker.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_RAID_TRIAL_STARTED, ROTracker.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(ROTracker.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ROTracker.gearUpdate)
	EVENT_MANAGER:AddFilterForEvent(ROTracker.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
end

function ROTracker.CheckActivation( eventCode )
	-- Check wiki.esoui.com/AvA_Zone_Detection if we want to enable this for PvP
	ROTracker.Reset()

		-- Workaround for when the game reports that the player is not in a group shortly after zoning
	if (ROTracker.groupSize == 0) then
		zo_callLater(ROTracker.Reset, 5000)
	end
	if (not ROTracker.enabled) then
		ROTracker.enabled = true
		EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_GROUP_MEMBER_JOINED, ROTracker.GroupUpdate)
		EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_GROUP_MEMBER_LEFT, ROTracker.GroupUpdate)
		EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, ROTracker.GroupMemberRoleChanged)
		EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, ROTracker.GroupSupportRangeUpdate)
		EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_EFFECT_CHANGED, ROTracker.EffectChanged)

		SCENE_MANAGER:GetScene("hud"):AddFragment(ROTracker.fragment)
		SCENE_MANAGER:GetScene("hudui"):AddFragment(ROTracker.fragment)
	end
end

function ROTracker.GroupUpdate( eventCode )
	zo_callLater(ROTracker.Reset, 500)
end

function ROTracker.GroupMemberRoleChanged( eventCode, unitTag, newRole )
	if (ROTracker.units[unitTag]) then
		ROTracker.panels[ROTracker.units[unitTag].panelId].role:SetTexture(ROTracker.roleIcons[newRole])
	end
end

function ROTracker.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (ROTracker.units[unitTag]) then
		ROTracker.UpdateRange(ROTracker.units[unitTag].panelId, status)
	end
end

function ROFade(unitTag)
	if(ROTracker.units[unitTag]) then
		ROTracker.units[unitTag].timer = ROTracker.units[unitTag].timer - 1.0;
		if(ROTracker.units[unitTag].timer == 2+ROTracker.vars.soundDelay) then
			if(ROTracker.lastSoundPlayed <= 0 and ROTracker.vars.playSound and ROTracker.RO) then
				PlaySound(ROTracker.vars.sound)
				EVENT_MANAGER:RegisterForUpdate("ROTrackerSound", 1000, function() ROTracker.SoundFinish() end)
			end
		end
		if(ROTracker.units[unitTag].timer == 2) then
			-- We can now register this person can receive RO again
			ROTracker.canReceive = ROTracker.canReceive + 1
			ROTrackerFrameReceive:SetText(ROTracker.canReceive)
		elseif(ROTracker.units[unitTag].timer <= 0) then
			ROTracker.units[unitTag].timer = 0;
			ROTracker.UpdateStatus(unitTag)
			EVENT_MANAGER:UnregisterForUpdate("ROTrackerCooldown"..unitTag)
		end
		if(ROTracker.topTimer > ROTracker.units[unitTag].timer) then
			ROTracker.topTimer = ROTracker.units[unitTag].timer
			ROTrackerFrameTime:SetText(ROTracker.topTimer)
		end
		ROTracker.panels[ROTracker.units[unitTag].panelId].name:SetText(GetUnitDisplayName(unitTag) .. " " .. ROTracker.units[unitTag].timer)
	end
end

function ROTracker.SoundFinish()
	ROTracker.lastSoundPlayed = ROTracker.lastSoundPlayed - 1
	if(ROTracker.lastSoundPlayed <= 0) then
		ROTracker.lastSoundPlayed = 0
		EVENT_MANAGER:UnregisterForUpdate("ROTrackerSound")
	end
end

function ROTracker.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	-- Ensure the source i	s from the player (unless set to allow for everyone)
	if (true) then
		-- Ensure this is the RO buff and that the player recieving it is in the group / being tracked
		if (ROTrackerData.effects[abilityId] and ROTracker.units[unitTag]) then
			if (changeType == EFFECT_RESULT_FADED) then
				if (ROTracker.units[unitTag].effects[abilityId]) then
					ROTracker.units[unitTag].count = ROTracker.units[unitTag].count - 1
					ROTracker.UpdateStatus(unitTag)
				end
				ROTracker.units[unitTag].effects[abilityId] = nil
			elseif (stackCount >= ROTrackerData.effects[abilityId]) then
				if (not ROTracker.units[unitTag].effects[abilityId]) then
					ROTracker.canReceive = ROTracker.canReceive - 1
					ROTrackerFrameReceive:SetText(ROTracker.canReceive)
					if(ROTracker.topTimer <= 0) then
						ROTracker.topTimer = 22
						ROTrackerFrameTime:SetText(ROTracker.topTimer)
					end
					ROTracker.lastLength = endTime - beginTime
					ROTracker.units[unitTag].timer = 22.0
					ROTracker.panels[ROTracker.units[unitTag].panelId].name:SetText(GetUnitDisplayName(unitTag) .. " 22")
					EVENT_MANAGER:RegisterForUpdate("ROTrackerCooldown"..unitTag, 1000, function() ROFade(unitTag) end)
					ROTracker.units[unitTag].count = ROTracker.units[unitTag].count + 1
					ROTracker.UpdateStatus(unitTag)
				end
				ROTracker.units[unitTag].effects[abilityId] = endTime
			end

			if (ROTracker.debug) then
				local entry = string.format("[%d] [%d/%d] %s - %d/%s/%d - %d", changeType, GetTimeStamp(), GetGameTimeMilliseconds(), GetUnitDisplayName(unitTag), abilityId, effectName, endTime, ROTracker.units[unitTag].count)
				table.insert(ROTracker.vars.debug, entry)
				if (ROTracker.units[unitTag].self) then
					CHAT_SYSTEM:AddMessage(entry)
				end
			end
		end
	end
end

function ROTracker.AttributeVisualChanged( eventCode, unitTag, unitAttributeVisual, _, _, _, value, newValue )
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA) then
		if (eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED) then
			ROTracker.units[unitTag].trauma = value
		elseif (eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED) then
			ROTracker.units[unitTag].trauma = 0
		elseif (eventCode == EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED) then
			ROTracker.units[unitTag].trauma = newValue
		end
		ROTracker.UpdateStatus(unitTag)
	end
end

function ROTracker.OnMoveStop( )
	ROTracker.vars.left = ROTrackerFrame:GetLeft()
	ROTracker.vars.top = ROTrackerFrame:GetTop()
end

function ROTracker.InitializeControls( )
	local wm = GetWindowManager()

	for i = 1, GROUP_SIZE_MAX do
			local panel = wm:CreateControlFromVirtual("ROTrackerPanel" .. i, ROTrackerFrame, "ROTrackerPanel")

		ROTracker.panels[i] = {
			panel = panel,
			bg = panel:GetNamedChild("Backdrop"),
			name = panel:GetNamedChild("Name"),
			role = panel:GetNamedChild("Role"),
			stat = panel:GetNamedChild("Stat"),
		}

		ROTracker.panels[i].bg:SetEdgeColor(0, 0, 0, 0)
		ROTracker.panels[i].bg:SetCenterColor(0, 0, 0, .5)
		ROTracker.panels[i].stat:SetColor(1, 0, 1, 1)
	end

	ROTrackerFrame:ClearAnchors()
	ROTrackerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ROTracker.vars.left, ROTracker.vars.top)

	ROTracker.fragment = ZO_HUDFadeSceneFragment:New(ROTrackerFrame)
end

function ROTracker.UpdateFont( size )
    ROTrackerFrameTime:SetFont("$(CHAT_FONT)|" ..size .. "|soft-shadow-thick")
	ROTrackerFrameReceive:SetFont("$(CHAT_FONT)|" .. size .. "|soft-shadow-thick")
end

function ROTracker.Reset( )
	if (ROTracker.debug) then
		CHAT_SYSTEM:AddMessage("[RO Tracker] Resetting")
	end

	ROTracker.groupSize = GetGroupSize()
	ROTracker.canReceive = GetGroupSize()
	ROTracker.units = { }

    ROTracker.UpdateFont( ROTracker.vars.cooldownTextSize )

	for i = 1, GROUP_SIZE_MAX do
		local soloPanel = i == 1 and ROTracker.groupSize == 0

		if (i <= ROTracker.groupSize or soloPanel) then
			local unitTag = (soloPanel) and "player" or GetGroupUnitTagByIndex(i)

			ROTracker.units[unitTag] = {
				panelId = i,
				count = 0,
				effects = { },
				trauma = 0,
				timer = 0.0,
				self = AreUnitsEqual("player", unitTag),
			}

			ROTrackerFrameReceive:SetText(ROTracker.canReceive)

			ROTracker.panels[i].name:SetText(GetUnitDisplayName(unitTag) .. " 0")
			ROTracker.panels[i].role:SetTexture(ROTracker.roleIcons[GetGroupMemberSelectedRole(unitTag)])

			ROTracker.UpdateStatus(unitTag)
			ROTracker.UpdateRange(i, IsUnitInGroupSupportRange(unitTag))

			if(not ROTracker.RO) then
				ROTracker.panels[i].panel:SetHidden(true)
			else
				ROTracker.panels[i].panel:SetHidden(false)
			end
		else

			ROTracker.panels[i].name:SetText("")
			ROTracker.panels[i].role:SetTexture(ROTracker.roleIcons[LFG_ROLE_INVALID])

			if(i > 12 or not ROTracker.RO) then
				ROTracker.panels[i].panel:SetHidden(true)
			else
				ROTracker.panels[i].panel:SetHidden(false)
			end
		end
		
		if (i == 1) then
			ROTracker.panels[i].panel:SetAnchor(TOPLEFT, ROTrackerFrame, TOPLEFT, 0, 0)
		elseif (i <= ROTracker.vars.maxRows) then
			ROTracker.panels[i].panel:SetAnchor(TOPLEFT, ROTracker.panels[i - 1].panel, BOTTOMLEFT, 0, 0)
		else
			ROTracker.panels[i].panel:SetAnchor(TOPLEFT, ROTracker.panels[i - ROTracker.vars.maxRows].panel, TOPRIGHT, 0, 0)
		end

	end
end

function ROTracker.UpdateStatus( unitTag )
	local bg = ROTracker.panels[ROTracker.units[unitTag].panelId].bg

	if (ROTracker.units[unitTag].count < 1) then
		if(ROTracker.units[unitTag].timer > 0) then
			bg:SetCenterColor(unpack(ROTracker.vars.colors.cooldown))
		else
			bg:SetCenterColor(0, 0, 0, 0.5)
		end
	else
		bg:SetCenterColor(unpack(ROTracker.vars.colors.slayer))
	end

	local stat = ROTracker.panels[ROTracker.units[unitTag].panelId].stat

	if (ROTracker.units[unitTag].trauma == 0) then
		stat:SetText("")
	else
		stat:SetText(string.format("%dk", (ROTracker.units[unitTag].trauma + 500) / 1000))
	end
end

function ROTracker.UpdateRange( panelId, status )
	if (status) then
		ROTracker.panels[panelId].panel:SetAlpha(1)
	else
		ROTracker.panels[panelId].panel:SetAlpha(0.5)
	end
end

function ROTracker.gearUpdate()
	ROTracker.RO = ROTracker.hasRO()
	if ROTracker.RO then
		ROTrackerFrameReceive:SetHidden(false)
		ROTrackerFrameTime:SetHidden(false)
	else
		ROTrackerFrameReceive:SetHidden(true)
		ROTrackerFrameTime:SetHidden(true)
	end
	for i = 1, 12 do
		if(not ROTracker.RO) then
			ROTracker.panels[i].panel:SetHidden(true)
		else
			ROTracker.panels[i].panel:SetHidden(false)
		end
	end
end

local types = {
	[1] = "|H1:item:162508:364:50:45884:370:50:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
	[2] = "|H1:item:162044:363:50:0:0:0:0:0:0:0:0:0:0:0:1:102:0:1:0:10000:0|h|h",
}

function ROTracker.hasRO()
	local np, p = 0, 0
	_,_,_,np,_,_,p = GetItemLinkSetInfo(types[1], true)
	if (np >= 3) or (p >= 3) then return true end
	return false
end

EVENT_MANAGER:RegisterForEvent(ROTracker.name, EVENT_ADD_ON_LOADED, ROTracker.OnAddOnLoaded)
