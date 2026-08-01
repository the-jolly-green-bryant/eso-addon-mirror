DoIHaveAzureblight = {
	name = "DoIHaveAzureblight",

	-- Default settings
	defaults = {
		left = 1000,
		top = 500,
		maxRows = 6,  -- was 6
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

function DoIHaveAzureblight.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= DoIHaveAzureblight.name) then return end

	EVENT_MANAGER:UnregisterForEvent(DoIHaveAzureblight.name, EVENT_ADD_ON_LOADED);

	DoIHaveAzureblight.vars = ZO_SavedVars:NewAccountWide("DoIHaveAzureblightSavedVariables", 1, nil, DoIHaveAzureblight.defaults, nil, "$InstallationWide");
	DoIHaveAzureblight.InitializeControls();

	EVENT_MANAGER:RegisterForEvent(DoIHaveAzureblight.name, EVENT_PLAYER_ACTIVATED, DoIHaveAzureblight.PlayerActivated);

	DoIHaveAzureblight.initializeSlashCommands()
end

function DoIHaveAzureblight.initializeSlashCommands()
    SLASH_COMMANDS["/azureblight"] = DoIHaveAzureblight.Reset
end

function DoIHaveAzureblight.PlayerActivated( eventCode, initial )
	-- This add-on is enabled 100% of the time, because of "or 1==1"
	if (DoIHaveAzureblightData.zones[GetZoneId(GetUnitZoneIndex("player"))] or DoIHaveAzureblight.debug or 1 == 1) then
		DoIHaveAzureblight.Reset();

		if (not DoIHaveAzureblight.enabled) then
			DoIHaveAzureblight.enabled = true;

			EVENT_MANAGER:RegisterForEvent(DoIHaveAzureblight.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, DoIHaveAzureblight.GroupSupportRangeUpdate);
			EVENT_MANAGER:RegisterForEvent(DoIHaveAzureblight.name, EVENT_EFFECT_CHANGED, DoIHaveAzureblight.EffectChanged);

			SCENE_MANAGER:GetScene("hud"):AddFragment(DoIHaveAzureblight.fragment);
			SCENE_MANAGER:GetScene("hudui"):AddFragment(DoIHaveAzureblight.fragment);
		end
	else
		if (DoIHaveAzureblight.enabled) then
			DoIHaveAzureblight.enabled = false;

			EVENT_MANAGER:UnregisterForEvent(DoIHaveAzureblight.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE);
			EVENT_MANAGER:UnregisterForEvent(DoIHaveAzureblight.name, EVENT_EFFECT_CHANGED);

			SCENE_MANAGER:GetScene("hud"):RemoveFragment(DoIHaveAzureblight.fragment);
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(DoIHaveAzureblight.fragment);
		end
	end
	zo_callLater(DoIHaveAzureblight.Reset, 500);
end

function DoIHaveAzureblight.GroupUpdate( eventCode )
	zo_callLater(DoIHaveAzureblight.Reset, 500);
end

function DoIHaveAzureblight.GroupMemberRolesChanged( eventCode, unitTag, dps, healer, tank )
	zo_callLater(function()
		if (DoIHaveAzureblight.units[unitTag]) then
			DoIHaveAzureblight.panels[DoIHaveAzureblight.units[unitTag].panelId].role:SetTexture(DoIHaveAzureblight.roleIcons[DoIHaveAzureblight.GetRole(unitTag)]);
		end
	end, 1500);
end

function DoIHaveAzureblight.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (DoIHaveAzureblight.units[unitTag]) then
		DoIHaveAzureblight.UpdateRange(DoIHaveAzureblight.units[unitTag].panelId, status);
	end
end

function DoIHaveAzureblight.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	if (DoIHaveAzureblightData.effects[abilityId] and DoIHaveAzureblight.units[unitTag]) then
		if (changeType ~= EFFECT_RESULT_FADED) then
			if (not DoIHaveAzureblight.units[unitTag].effects[abilityId]) then
				DoIHaveAzureblight.units[unitTag].count = DoIHaveAzureblight.units[unitTag].count + 1;
				--DoIHaveAzureblight.units[unitTag].stacks = stackCount;
				DoIHaveAzureblight.UpdateStatus(unitTag);
			end
			DoIHaveAzureblight.units[unitTag].effects[abilityId] = endTime;
		else
			if (DoIHaveAzureblight.units[unitTag].effects[abilityId]) then
				DoIHaveAzureblight.units[unitTag].count = DoIHaveAzureblight.units[unitTag].count - 1;
				--DoIHaveAzureblight.units[unitTag].stacks = stackCount;
				DoIHaveAzureblight.UpdateStatus(unitTag);
			end
			DoIHaveAzureblight.units[unitTag].effects[abilityId] = nil;
		end
		
		-- Display the stackcount when we have the effect on us
		local stat = DoIHaveAzureblight.panels[DoIHaveAzureblight.units[unitTag].panelId].stat
		if (DoIHaveAzureblight.units[unitTag].count > 0) then
			stat:SetText(stackCount)
		else
			stat:SetText("0")
		end
		
		-- Change the background colour as the stacks go up
		-- Background colour format: (r, g, b, transparency)
		local bg = DoIHaveAzureblight.panels[DoIHaveAzureblight.units[unitTag].panelId].bg;
		if (DoIHaveAzureblight.units[unitTag].count == 0) then
			bg:SetCenterColor(0, 0, 0, 0.3);
		elseif (stackCount <= 4) then
			bg:SetCenterColor(0.4, 0.7, 1, 0.8);
		elseif ((stackCount > 4)  and (stackCount <= 9)) then
			bg:SetCenterColor(0.2, 0.3, 0.8, 1);
		elseif ((stackCount > 9)  and (stackCount <= 14)) then
			bg:SetCenterColor(0.6, 0.2, 0.7, 1);
		elseif (stackCount > 14) then
			bg:SetCenterColor(0.9, 0, 0, 1);
		else
			bg:SetCenterColor(0, 0, 0, 0.3);
		end

		-- Change the text displayed based on the stacks
		local textdisplay = DoIHaveAzureblight.panels[DoIHaveAzureblight.units[unitTag].panelId].name
		if (DoIHaveAzureblight.units[unitTag].count == 0) then
			textdisplay:SetText(" Blight Seed ")	
		elseif (stackCount < 10) then
			textdisplay:SetText(" Blight Seed ")
		elseif ((stackCount >= 10) and (stackCount < 17)) then
			textdisplay:SetText("  MOVE AWAY!!! ")	
		elseif (stackCount >= 17) then
			textdisplay:SetText("  KABOOM!!! ")	
		else
			textdisplay:SetText(" Blight Seed ")	
		end

		if (DoIHaveAzureblight.debug) then
			local entry = string.format("%d/%s/ Stacks: %d - Count: %d", abilityId, effectName, stackCount, DoIHaveAzureblight.units[unitTag].count);
			-- !! ^^ this stackCount correctly logs the stacks to chat in debug. See if I can get this logged to the display ^^ !! --
			if (DoIHaveAzureblight.units[unitTag].self) then
				CHAT_SYSTEM:AddMessage(entry);
			end
		end
	end
end

function DoIHaveAzureblight.OnMoveStop( )
	DoIHaveAzureblight.vars.left = DoIHaveAzureblightFrame:GetLeft();
	DoIHaveAzureblight.vars.top = DoIHaveAzureblightFrame:GetTop();
end

function DoIHaveAzureblight.InitializeControls( )
	local wm = GetWindowManager();

	for i = 1, GROUP_SIZE_MAX do
		local panel = wm:CreateControlFromVirtual("DoIHaveAzureblightPanel" .. i, DoIHaveAzureblightFrame, "DoIHaveAzureblightPanel");

		DoIHaveAzureblight.panels[i] = {
			panel = panel,
			bg = panel:GetNamedChild("Backdrop"),
			name = panel:GetNamedChild("Name"),
			stat = panel:GetNamedChild("Stat"),
		};

		DoIHaveAzureblight.panels[i].bg:SetEdgeColor(0, 0, 0, 0);
	end

	DoIHaveAzureblightFrame:ClearAnchors();
	DoIHaveAzureblightFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DoIHaveAzureblight.vars.left, DoIHaveAzureblight.vars.top);

	DoIHaveAzureblight.fragment = ZO_HUDFadeSceneFragment:New(DoIHaveAzureblightFrame);
end


function DoIHaveAzureblight.Reset()
	if (DoIHaveAzureblight.debug) then
		CHAT_SYSTEM:AddMessage("[AzureTracker] Resetting");
	end

	local unitTag = "player"
	
	DoIHaveAzureblight.units[unitTag] = {
		panelId = 1,
		count = 0,
		stacks = 0, 
		effects = {},
		self = true,
	}
	
	-- Start off black bg and transparent
	local bg = DoIHaveAzureblight.panels[DoIHaveAzureblight.units[unitTag].panelId].bg;
	bg:SetCenterColor(0, 0, 0, 0.3);

	-- Note we are tracking Blight Seed
	DoIHaveAzureblight.panels[1].name:SetText(" Blight Seed ")	
	DoIHaveAzureblight.UpdateStatus(unitTag)
	DoIHaveAzureblight.UpdateRange(1, IsUnitInGroupSupportRange(unitTag))

	DoIHaveAzureblight.panels[1].panel:SetAnchor(TOPLEFT, DoIHaveAzureblightFrame, TOPLEFT, 0, 0)
	DoIHaveAzureblight.panels[1].panel:SetHidden(false)

	for i = 2, GROUP_SIZE_MAX do
		DoIHaveAzureblight.panels[i].panel:SetHidden(true)
	end
end

function DoIHaveAzureblight.GetRole( unitTag )
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


function DoIHaveAzureblight.UpdateStatus( unitTag )
	--local bg = DoIHaveAzureblight.panels[DoIHaveAzureblight.units[unitTag].panelId].bg;
	--bg:SetCenterColor(0, 0, 0, 0.3);
end

function DoIHaveAzureblight.UpdateRange( panelId, status )
	if (status) then
		DoIHaveAzureblight.panels[panelId].panel:SetAlpha(1);
	else
		DoIHaveAzureblight.panels[panelId].panel:SetAlpha(0.5);
	end
end

function DoIHaveAzureblight.EnableDebug( )
	DoIHaveAzureblight.debug = true;

	DoIHaveAzureblightData.effects[17906] = true; -- Crusher

	if (not DoIHaveAzureblight.vars.debug) then
		DoIHaveAzureblight.vars.debug = { };
	end

	DoIHaveAzureblight.PlayerActivated();
end

EVENT_MANAGER:RegisterForEvent(DoIHaveAzureblight.name, EVENT_ADD_ON_LOADED, DoIHaveAzureblight.OnAddOnLoaded);