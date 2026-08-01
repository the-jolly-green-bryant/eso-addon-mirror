HealerBFF = {
	name = "HealerBFF",

	-- Default settings
	defaults = {
		left = 1000,
		top = 500,
		maxRows = 6,
	},

	roleIcons = {
		[LFG_ROLE_DPS ] = "/esoui/art/lfg/lfg_icon_dps.dds",
		[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
		[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
	},

	enabled = false,
	groupSize = 0,
	units = { },
	panels = { },

	debug = false,
};

function HealerBFF.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= HealerBFF.name) then return end

	EVENT_MANAGER:UnregisterForEvent(HealerBFF.name, EVENT_ADD_ON_LOADED);

	HealerBFF.vars = ZO_SavedVars:NewAccountWide("HealerBFFSavedVariables", 1, nil, HealerBFF.defaults, nil, "$InstallationWide");
	HealerBFF.InitializeControls();

	EVENT_MANAGER:RegisterForEvent(HealerBFF.name, EVENT_PLAYER_ACTIVATED, HealerBFF.PlayerActivated);

	HealerBFF.initializeSlashCommands()
end

function HealerBFF.initializeSlashCommands()
    SLASH_COMMANDS["/bff"] = HealerBFF.Reset
end

function HealerBFF.PlayerActivated( eventCode, initial )
	-- Check wiki.esoui.com/AvA_Zone_Detection if we want to enable this for PvP

	if (HealerBFFData.zones[GetZoneId(GetUnitZoneIndex("player"))] or HealerBFF.debug) then
		HealerBFF.Reset();

		if (not HealerBFF.enabled) then
			HealerBFF.enabled = true;

			EVENT_MANAGER:RegisterForEvent(HealerBFF.name, EVENT_GROUP_MEMBER_JOINED, HealerBFF.GroupUpdate);
			EVENT_MANAGER:RegisterForEvent(HealerBFF.name, EVENT_GROUP_MEMBER_LEFT, HealerBFF.GroupUpdate);
			EVENT_MANAGER:RegisterForEvent(HealerBFF.name, EVENT_GROUP_MEMBER_ROLES_CHANGED, HealerBFF.GroupMemberRolesChanged);
			EVENT_MANAGER:RegisterForEvent(HealerBFF.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, HealerBFF.GroupSupportRangeUpdate);
			EVENT_MANAGER:RegisterForEvent(HealerBFF.name, EVENT_EFFECT_CHANGED, HealerBFF.EffectChanged);

			SCENE_MANAGER:GetScene("hud"):AddFragment(HealerBFF.fragment);
			SCENE_MANAGER:GetScene("hudui"):AddFragment(HealerBFF.fragment);
		end
	else
		if (HealerBFF.enabled) then
			HealerBFF.enabled = false;

			EVENT_MANAGER:UnregisterForEvent(HealerBFF.name, EVENT_GROUP_MEMBER_JOINED);
			EVENT_MANAGER:UnregisterForEvent(HealerBFF.name, EVENT_GROUP_MEMBER_LEFT);
			EVENT_MANAGER:UnregisterForEvent(HealerBFF.name, EVENT_GROUP_MEMBER_ROLES_CHANGED);
			EVENT_MANAGER:UnregisterForEvent(HealerBFF.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE);
			EVENT_MANAGER:UnregisterForEvent(HealerBFF.name, EVENT_EFFECT_CHANGED);

			SCENE_MANAGER:GetScene("hud"):RemoveFragment(HealerBFF.fragment);
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(HealerBFF.fragment);
		end
	end
	zo_callLater(HealerBFF.Reset, 500);
end

function HealerBFF.GroupUpdate( eventCode )
	zo_callLater(HealerBFF.Reset, 500);
end

function HealerBFF.GroupMemberRolesChanged( eventCode, unitTag, dps, healer, tank )
	zo_callLater(function()
		if (HealerBFF.units[unitTag]) then
			HealerBFF.panels[HealerBFF.units[unitTag].panelId].role:SetTexture(HealerBFF.roleIcons[HealerBFF.GetRole(unitTag)]);
		end
	end, 1500);
end

function HealerBFF.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (HealerBFF.units[unitTag]) then
		HealerBFF.UpdateRange(HealerBFF.units[unitTag].panelId, status);
	end
end

function HealerBFF.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	if (HealerBFFData.effects[abilityId] and HealerBFF.units[unitTag]) then
		if (changeType ~= EFFECT_RESULT_FADED) then
			if (not HealerBFF.units[unitTag].effects[abilityId]) then
				HealerBFF.units[unitTag].count = HealerBFF.units[unitTag].count + 1;
				HealerBFF.UpdateStatus(unitTag);
			end
			HealerBFF.units[unitTag].effects[abilityId] = endTime;
		else
			if (HealerBFF.units[unitTag].effects[abilityId]) then
				HealerBFF.units[unitTag].count = HealerBFF.units[unitTag].count - 1;
				HealerBFF.UpdateStatus(unitTag);
			end
			HealerBFF.units[unitTag].effects[abilityId] = nil;
		end

		if (HealerBFF.debug) then
			local entry = string.format("[%d] [%d/%d] %s - %d/%s/%d - %d", changeType, GetTimeStamp(), GetGameTimeMilliseconds(), GetUnitDisplayName(unitTag), abilityId, effectName, endTime, HealerBFF.units[unitTag].count);
			table.insert(HealerBFF.vars.debug, entry);
			if (HealerBFF.units[unitTag].self) then
				CHAT_SYSTEM:AddMessage(entry);
			end
		end
	end
end

function HealerBFF.OnMoveStop( )
	HealerBFF.vars.left = HealerBFFFrame:GetLeft();
	HealerBFF.vars.top = HealerBFFFrame:GetTop();
end

function HealerBFF.InitializeControls( )
	local wm = GetWindowManager();

	for i = 1, GROUP_SIZE_MAX do
		local panel = wm:CreateControlFromVirtual("HealerBFFPanel" .. i, HealerBFFFrame, "HealerBFFPanel");

		HealerBFF.panels[i] = {
			panel = panel,
			bg = panel:GetNamedChild("Backdrop"),
			name = panel:GetNamedChild("Name"),
			role = panel:GetNamedChild("Role"),
		};

		HealerBFF.panels[i].bg:SetEdgeColor(0, 0, 0, 0);
	end

	HealerBFFFrame:ClearAnchors();
	HealerBFFFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HealerBFF.vars.left, HealerBFF.vars.top);

	HealerBFF.fragment = ZO_HUDFadeSceneFragment:New(HealerBFFFrame);
end

function HealerBFF.Reset( )
	if (HealerBFF.debug) then
		CHAT_SYSTEM:AddMessage("[Healer BFF] Resetting");
	end

	HealerBFF.groupSize = GetGroupSize();
	HealerBFF.units = { };
	local width, height = HealerBFF.panels[1].panel:GetDimensions();

	for i = 1, GROUP_SIZE_MAX do
		local soloPanel = i == 1 and HealerBFF.groupSize == 0;

		if (i <= HealerBFF.groupSize or soloPanel) then
			local unitTag = (soloPanel) and "player" or GetGroupUnitTagByIndex(i);

			HealerBFF.units[unitTag] = {
				panelId = i,
				count = 0,
				effects = { },
				self = AreUnitsEqual("player", unitTag),
			};

			HealerBFF.panels[i].name:SetText(GetUnitDisplayName(unitTag));
			HealerBFF.panels[i].role:SetTexture(HealerBFF.roleIcons[HealerBFF.GetRole(unitTag)]);

			HealerBFF.UpdateStatus(unitTag);
			HealerBFF.UpdateRange(i, IsUnitInGroupSupportRange(unitTag));

			HealerBFF.panels[i].panel:SetAnchor(TOPLEFT, HealerBFFFrame, TOPLEFT, width * math.floor((i - 1) / HealerBFF.vars.maxRows), height * ((i - 1) % HealerBFF.vars.maxRows));
			HealerBFF.panels[i].panel:SetHidden(false);
		else
			HealerBFF.panels[i].panel:SetAnchor(TOPLEFT, HealerBFFFrame, TOPLEFT, 0, 0);
			HealerBFF.panels[i].panel:SetHidden(true);
		end
	end
end

function HealerBFF.GetRole( unitTag )
	local role = GetGroupMemberAssignedRole(unitTag);

	if (role == LFG_ROLE_INVALID) then
		local _, isHealer, isTank = GetGroupMemberRoles(unitTag);

		if (isTank) then
			role = LFG_ROLE_TANK;
		elseif (isHealer) then
			role = LFG_ROLE_HEAL;
		else
			role = LFG_ROLE_DPS;
		end
	end

	return(role);
end

function HealerBFF.UpdateStatus( unitTag )
	local bg = HealerBFF.panels[HealerBFF.units[unitTag].panelId].bg;

	if (HealerBFF.units[unitTag].count < 1) then
		bg:SetCenterColor(0, 0, 0, 0.5);
	elseif (HealerBFF.units[unitTag].self) then
		bg:SetCenterColor(0, 0.8, 0, 1);
	else
		bg:SetCenterColor(0.2, 0.6, 0, 0.8);
	end
end

function HealerBFF.UpdateRange( panelId, status )
	if (status) then
		HealerBFF.panels[panelId].panel:SetAlpha(1);
	else
		HealerBFF.panels[panelId].panel:SetAlpha(0.5);
	end
end

function HealerBFF.EnableDebug( )
	HealerBFF.debug = true;

	HealerBFFData.effects[17906] = true; -- Crusher
	HealerBFFData.effects[17945] = true; -- Weakening
	HealerBFFData.effects[36245] = true; -- Concealed Weapon IV
	HealerBFFData.effects[37921] = true; -- Crippling Grasp IV
	HealerBFFData.effects[43083] = true; -- Consuming Trap IV
	HealerBFFData.effects[78046] = true; -- Ruthless Salvo Bleed (unused?)

	if (not HealerBFF.vars.debug) then
		HealerBFF.vars.debug = { };
	end

	HealerBFF.PlayerActivated();
end

EVENT_MANAGER:RegisterForEvent(HealerBFF.name, EVENT_ADD_ON_LOADED, HealerBFF.OnAddOnLoaded);