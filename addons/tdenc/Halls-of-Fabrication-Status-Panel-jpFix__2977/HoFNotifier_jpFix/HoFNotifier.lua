HoFNotifier = {
	name = "HoFNotifier",

	combatMonitoring = false,
	pollingActive = false,
	pollingInterval = 500, -- 0.5 seconds

	-- Default settings
	defaults = {
		left = 400,
		top = 300,
		forceTimer = false,
	},

	maxRows = 5,
	rows = { },
	mode = -1,
	bosses = 0,

	b2Split = {
		id = 90681,
		cast = 0,
		last = 0,
	},
	b2Hammer = {
		id = 90889,
		cast = 0,
		last = 0,
	},
	b2ScaldStacks = 0,
	b2ScaldEnd = 0,
	b2LastSplit = 0,
	b4TimerEnabled = false,
	b4LastSwap = 0,
	b4LastLimbs = 0,
	b4HasChanneled = false,
	b5LastExhaustion = 0,
};

function HoFNotifier.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= HoFNotifier.name) then return end

	EVENT_MANAGER:UnregisterForEvent(HoFNotifier.name, EVENT_ADD_ON_LOADED);

	HoFNotifier.vars = ZO_SavedVars:NewAccountWide("HoFNotifierSavedVariables", 1, nil, HoFNotifier.defaults, nil, "$InstallationWide");

	HoFNotifierFrame:ClearAnchors();
	HoFNotifierFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HoFNotifier.vars.left, HoFNotifier.vars.top);

	HoFNotifier.icon = HoFNotifierFrame:GetNamedChild("Icon");

	for i = 1, HoFNotifier.maxRows do
		HoFNotifier.rows[i] = HoFNotifierFrame:GetNamedChild("Row" .. i);
		HoFNotifier.rows[i].value = HoFNotifier.rows[i]:GetNamedChild("Value");
		HoFNotifier.rows[i].label = HoFNotifier.rows[i]:GetNamedChild("Label");
	end

	HoFNotifier.fragment = ZO_HUDFadeSceneFragment:New(HoFNotifierFrame);

	HoFNotifier.BossesChanged();

	EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_LEADER_UPDATE, HoFNotifier.GroupUpdate);
	EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_GROUP_MEMBER_ROLES_CHANGED, HoFNotifier.GroupUpdate);
	EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_BOSSES_CHANGED, HoFNotifier.BossesChanged);
	EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_PLAYER_ACTIVATED, HoFNotifier.BossesChanged);

	SLASH_COMMANDS["/hofntimer"] = HoFNotifier.ToggleForceTimer;
end

function HoFNotifier.GroupUpdate( )
	if (HoFNotifier.mode == 4) then
		local _, _, isTank = GetPlayerRoles();
		HoFNotifier.b4TimerEnabled = HoFNotifier.vars.forceTimer or isTank or IsUnitSoloOrGroupLeader("player");
	end
end

function HoFNotifier.BossesChanged( eventCode )
	local bossModes = {
		-- EN
		["hunter-killer negatrix"] = 1,
		["pinnacle factotum"] = 2,
		["reactor"] = 4,
		["assembly general"] = 5,

		-- DE
		["abfänger negatrix"] = 1,
		["perfektionierte faktotum"] = 2,
		["reaktor"] = 4,
		["montagegeneral"] = 5,

		-- FR
		["chasseur-tueur négatrix"] = 1,
		["factotum du pinâcle"] = 2,
		["réacteur"] = 4,
		["assembleur général"] = 5,

		-- JP
		["ハンターキラー・ネガトリクス"] = 1,
		["ピナクル・ファクトタム"] = 2,
		["リアクター"] = 4,
		["アセンブリ・ジェネラル"] = 5,
	};

	local newMode = bossModes[string.lower(GetUnitName("boss1"))];

	if (HoFNotifier.mode ~= newMode) then
		HoFNotifier.mode = newMode;
	else
		return;
	end

	-- Reset all rows
	for i = 1, HoFNotifier.maxRows do
		HoFNotifier.rows[i]:SetHidden(true);
		HoFNotifier.rows[i].value:SetColor(1, 1, 1, 1);
	end

	if (HoFNotifier.mode == 1) then
		HoFNotifier.bosses = 2;

		local _, _, _, icon = GetAchievementInfo(1839);
		HoFNotifier.icon:SetTexture(icon);

		for i = 1, HoFNotifier.bosses do
			HoFNotifier.rows[i].label:SetText(GetUnitName("boss" .. i));
			HoFNotifier.rows[i]:SetHidden(false);
		end

		HoFNotifier.UpdateBossHealth();

		SCENE_MANAGER:GetScene("hud"):AddFragment(HoFNotifier.fragment);
		SCENE_MANAGER:GetScene("hudui"):AddFragment(HoFNotifier.fragment);

		HoFNotifier.StartMonitoringCombatState();
	elseif (HoFNotifier.mode == 2) then
		local icon = GetAbilityIcon(90918);
		HoFNotifier.icon:SetTexture(icon);

		HoFNotifier.rows[1]:SetHidden(false);
		HoFNotifier.rows[1].label:SetText(GetString(SI_HOFNOTIFIER_SCALDED_LABEL));
		HoFNotifier.rows[2].label:SetText(GetString(SI_STAT_GAMEPAD_TIME_REMAINING));
		HoFNotifier.UpdateScaldedStacks();

		HoFNotifier.rows[4].value:SetText("0s");
		HoFNotifier.rows[4].label:SetText(GetString(SI_HOFNOTIFIER_SPLIT_TIMER_LABEL));
		HoFNotifier.b2LastSplit = 0;

		SCENE_MANAGER:GetScene("hud"):AddFragment(HoFNotifier.fragment);
		SCENE_MANAGER:GetScene("hudui"):AddFragment(HoFNotifier.fragment);

		_, HoFNotifier.b2Split.cast = GetAbilityCastInfo(HoFNotifier.b2Split.id);
		_, HoFNotifier.b2Hammer.cast = GetAbilityCastInfo(HoFNotifier.b2Hammer.id);

		HoFNotifier.b2Split.last = 0;
		HoFNotifier.b2Hammer.last = 0;

		HoFNotifier.b2WarnMessage = string.format(GetString(SI_HOFNOTIFIER_ZOSFUCKED_MESSAGE), GetAbilityName(HoFNotifier.b2Split.id), GetAbilityName(HoFNotifier.b2Hammer.id));

		EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_EFFECT_CHANGED, HoFNotifier.EffectChanged);
		EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_COMBAT_EVENT, HoFNotifier.CombatEvent);
	elseif (HoFNotifier.mode == 4) then
		HoFNotifier.bosses = 3;

		local icon = GetItemLinkInfo("|H1:item:124294:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h");
		HoFNotifier.icon:SetTexture(icon);

		for i = 1, HoFNotifier.bosses do
			HoFNotifier.rows[i].label:SetText(GetUnitName("boss" .. i));
			HoFNotifier.rows[i]:SetHidden(false);
		end

		HoFNotifier.GroupUpdate();
		HoFNotifier.UpdateBossHealth();

		HoFNotifier.b4LastSwap = 0;
		HoFNotifier.b4LastLimbs = 0;

		SCENE_MANAGER:GetScene("hud"):AddFragment(HoFNotifier.fragment);
		SCENE_MANAGER:GetScene("hudui"):AddFragment(HoFNotifier.fragment);

		if (HoFNotifier.b4TimerEnabled) then
			HoFNotifier.rows[4].value:SetText("0s");
			HoFNotifier.rows[4].label:SetText(GetString(SI_HOFNOTIFIER_SWAP_TIMER_LABEL));
			HoFNotifier.rows[4]:SetHidden(false);

			HoFNotifier.rows[5].value:SetText("0s");
			HoFNotifier.rows[5].label:SetText(GetString(SI_HOFNOTIFIER_LIMBS_TIMER_LABEL));

			EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_EFFECT_CHANGED, HoFNotifier.EffectChanged);
			EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_COMBAT_EVENT, HoFNotifier.CombatEvent);
		end

		HoFNotifier.StartMonitoringCombatState();
	elseif (HoFNotifier.mode == 5) then
		local icon = GetAbilityIcon(96132);
		HoFNotifier.icon:SetTexture(icon);

		HoFNotifier.rows[1].value:SetText("0s");
		HoFNotifier.rows[1]:SetHidden(false);

		SCENE_MANAGER:GetScene("hud"):RemoveFragment(HoFNotifier.fragment);
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment(HoFNotifier.fragment);

		HoFNotifier.b5LastExhaustion = 0;

		EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_EFFECT_CHANGED, HoFNotifier.EffectChanged);
	else
		EVENT_MANAGER:UnregisterForEvent(HoFNotifier.name, EVENT_EFFECT_CHANGED);
		EVENT_MANAGER:UnregisterForEvent(HoFNotifier.name, EVENT_COMBAT_EVENT);
		HoFNotifier.StopMonitoringCombatState();
		HoFNotifier.StopPolling();

		SCENE_MANAGER:GetScene("hud"):RemoveFragment(HoFNotifier.fragment);
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment(HoFNotifier.fragment);
	end
end

function HoFNotifier.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	if (HoFNotifier.mode == 2 and abilityId == 90916 and unitTag == "player") then
		if (changeType ~= EFFECT_RESULT_FADED) then
			HoFNotifier.b2ScaldEnd = endTime;
			HoFNotifier.b2ScaldStacks = stackCount;
			HoFNotifier.rows[2]:SetHidden(false);
			HoFNotifier.StartPolling();
		else
			HoFNotifier.b2ScaldStacks = 0;
			HoFNotifier.rows[2]:SetHidden(true);
		end

		HoFNotifier.UpdateScaldedStacks();
	elseif (HoFNotifier.mode == 4) then
		if (changeType == EFFECT_RESULT_GAINED and (abilityId == 94736 or abilityId == 94757)) then
			HoFNotifier.b4LastSwap = GetTimeStamp();
			HoFNotifier.b4HasChanneled = true;
		end
	elseif (HoFNotifier.mode == 5 and unitTag == "player") then
		-- 96132 is the only ID observed in gameplay
		if ((changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) and (abilityId == 96132 or abilityId == 96133 or abilityId == 96138)) then
			HoFNotifier.b5LastExhaustion = GetTimeStamp();

			HoFNotifier.rows[1].label:SetText(string.format("%s (%d)", effectName, stackCount));

			if (changeType == EFFECT_RESULT_GAINED) then
				SCENE_MANAGER:GetScene("hud"):AddFragment(HoFNotifier.fragment);
				SCENE_MANAGER:GetScene("hudui"):AddFragment(HoFNotifier.fragment);
				HoFNotifier.Notify(string.format(GetString(SI_HOFNOTIFIER_EXHAUSTION_MESSAGE), effectName));
			end

			HoFNotifier.StartPolling();
		end
	end
end

function HoFNotifier.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
	if (HoFNotifier.mode == 2 and result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER) then
		local comboWarn = false;

		if (abilityId == HoFNotifier.b2Split.id) then
			HoFNotifier.b2Split.last = GetGameTimeMilliseconds();
			comboWarn = HoFNotifier.b2Split.last - HoFNotifier.b2Hammer.last < HoFNotifier.b2Hammer.cast - 250;
		elseif (abilityId == HoFNotifier.b2Hammer.id) then
			HoFNotifier.b2Hammer.last = GetGameTimeMilliseconds();
			comboWarn = HoFNotifier.b2Hammer.last - HoFNotifier.b2Split.last < HoFNotifier.b2Split.cast - 250;
		end

		if (comboWarn) then
			HoFNotifier.Notify(HoFNotifier.b2WarnMessage);
		end
	end

	if (HoFNotifier.mode == 2 and result == ACTION_RESULT_BEGIN and abilityId == HoFNotifier.b2Split.id) then
		HoFNotifier.b2LastSplit = GetTimeStamp();
		HoFNotifier.rows[4]:SetHidden(false);
		HoFNotifier.StartPolling();
	elseif (HoFNotifier.mode == 4 and result == ACTION_RESULT_BEGIN and abilityId == 90265) then
		if (GetTimeStamp() - HoFNotifier.b4LastLimbs > 10) then
			-- The game always registers two casts and in rare instances even more, so a time check is used to filter out the dupes
			HoFNotifier.b4LastLimbs = GetTimeStamp();
			HoFNotifier.rows[5]:SetHidden(false);
		end
	end
end

function HoFNotifier.OnPlayerCombatState( eventCode, inCombat )
	if (inCombat) then
		if (not HoFNotifier.pollingActive) then
			if (HoFNotifier.mode == 4 and not HoFNotifier.rows[4]:IsControlHidden()) then
				HoFNotifier.b4LastSwap = GetTimeStamp();
				HoFNotifier.b4HasChanneled = false;
			end

			HoFNotifier.StartPolling();
		end
	else
		-- Avoid false positives of combat end, often caused by combat rezes
		zo_callLater(function() if (not IsUnitInCombat("player")) then HoFNotifier.CombatEnded() end end, 3000);
	end
end

function HoFNotifier.CombatEnded( )
	HoFNotifier.StopPolling();

	if (HoFNotifier.mode and HoFNotifier.mode > 0) then
		HoFNotifier.mode = -1;
		HoFNotifier.BossesChanged();
	end
end

function HoFNotifier.ToggleForceTimer( command )
	HoFNotifier.vars.forceTimer = not HoFNotifier.vars.forceTimer;
	local status = GetString("SI_ADDONLOADSTATE", HoFNotifier.vars.forceTimer and ADDON_STATE_ENABLED or ADDON_STATE_DISABLED);
	CHAT_SYSTEM:AddMessage("[HoFNotifier] Timer Override: " .. status);
	HoFNotifier.GroupUpdate();
end

function HoFNotifier.OnMoveStop( )
	HoFNotifier.vars.left = HoFNotifierFrame:GetLeft();
	HoFNotifier.vars.top = HoFNotifierFrame:GetTop();
end

function HoFNotifier.Poll( )
	if (HoFNotifier.mode == 1) then
		HoFNotifier.UpdateBossHealth();
	elseif (HoFNotifier.mode == 2) then
		HoFNotifier.rows[2].value:SetText(string.format("%ds", HoFNotifier.b2ScaldEnd - GetFrameTimeSeconds()));

		if (HoFNotifier.b2LastSplit > 0) then
			local elapsed = GetTimeStamp() - HoFNotifier.b2LastSplit;
			HoFNotifier.rows[4].value:SetText(string.format("%ds", elapsed));

			if (elapsed >= 40) then
				HoFNotifier.rows[4].value:SetColor(0.25, 0.75, 1, 1);
			else
				HoFNotifier.rows[4].value:SetColor(1, 1, 1, 1);
			end
		end
	elseif (HoFNotifier.mode == 4) then
		HoFNotifier.UpdateBossHealth();

		if (HoFNotifier.b4LastSwap > 0) then
			local elapsed = GetTimeStamp() - HoFNotifier.b4LastSwap;
			HoFNotifier.rows[4].value:SetText(string.format("%ds", elapsed));

			if (HoFNotifier.b4HasChanneled and elapsed <= 10) then
				HoFNotifier.rows[4].value:SetColor(1, 0, 0, 1);
			elseif (elapsed >= 25) then
				HoFNotifier.rows[4].value:SetColor(1, 0.75, 0, 1);
			else
				HoFNotifier.rows[4].value:SetColor(0, 1, 0, 1);
			end
		end

		if (HoFNotifier.b4LastLimbs > 0) then
			local elapsed = GetTimeStamp() - HoFNotifier.b4LastLimbs;
			HoFNotifier.rows[5].value:SetText(string.format("%ds", elapsed));

			if (elapsed >= 25) then
				HoFNotifier.rows[5].value:SetColor(0.25, 0.75, 1, 1);
			else
				HoFNotifier.rows[5].value:SetColor(1, 1, 1, 1);
			end
		end
	elseif (HoFNotifier.mode == 5) then
		if (HoFNotifier.b5LastExhaustion > 0) then
			local elapsed = GetTimeStamp() - HoFNotifier.b5LastExhaustion;
			HoFNotifier.rows[1].value:SetText(string.format("%ds", elapsed));
		end
	end
end

function HoFNotifier.StartMonitoringCombatState( )
	if (not HoFNotifier.combatMonitoring) then
		HoFNotifier.combatMonitoring = true;
		EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_PLAYER_COMBAT_STATE, HoFNotifier.OnPlayerCombatState);

		if (IsUnitInCombat("player")) then
			HoFNotifier.OnPlayerCombatState(nil, true);
		end
	end
end

function HoFNotifier.StopMonitoringCombatState( )
	if (HoFNotifier.combatMonitoring) then
		HoFNotifier.combatMonitoring = false;
		EVENT_MANAGER:UnregisterForEvent(HoFNotifier.name, EVENT_PLAYER_COMBAT_STATE);
	end
end

function HoFNotifier.StartPolling( )
	if (not HoFNotifier.pollingActive) then
		HoFNotifier.pollingActive = true;
		EVENT_MANAGER:RegisterForUpdate(HoFNotifier.name, HoFNotifier.pollingInterval, HoFNotifier.Poll);
		HoFNotifier.StartMonitoringCombatState();
	end
end

function HoFNotifier.StopPolling( )
	if (HoFNotifier.pollingActive) then
		HoFNotifier.pollingActive = false;
		EVENT_MANAGER:UnregisterForUpdate(HoFNotifier.name);
	end
end

function HoFNotifier.UpdateBossHealth( )
	for i = 1, HoFNotifier.bosses do
		local current, _, effectiveMax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH);
		local health = 0;

		if (effectiveMax > 0) then	-- Avoid division by zero
			health = 100 * current / effectiveMax;
		end

		HoFNotifier.rows[i].value:SetText(string.format("%d%%", health));

		if (HoFNotifier.mode == 4) then
			if (health == 0) then
				HoFNotifier.rows[i].value:SetColor(0, 0.75, 0.75, 1);
			elseif ( (health >= 73 and health < 76) or
			         (health >= 43 and health < 46) or
			         (health >= 23 and health < 26) ) then
				HoFNotifier.rows[i].value:SetColor(1, 1, 0, 1);
			elseif ( (health >= 70 and health < 73) or
			         (health >= 40 and health < 43) or
			         (health >= 20 and health < 23) ) then
				HoFNotifier.rows[i].value:SetColor(0.75, 0, 0, 1);
			else
				HoFNotifier.rows[i].value:SetColor(1, 1, 1, 1);
			end
		end
	end
end

function HoFNotifier.UpdateScaldedStacks( )
	local r, g, b = HoFNotifier.HSL2RGB((10 - HoFNotifier.b2ScaldStacks) / 30, 1, 0.5);
	HoFNotifier.rows[1].value:SetColor(r, g, b, 1);
	HoFNotifier.rows[1].value:SetText(string.format("%d%%", 10 * HoFNotifier.b2ScaldStacks));
end

function HoFNotifier.HSL2RGB( h, s, l )
	if (s == 0) then
		return l, l, l;
	else
		local q, p;

		local hue2rgb = function( p, q, t )
			if (t < 0) then t = t + 1 end
			if (t > 1) then t = t - 1 end
			if (t < 1/6) then return p + (q - p) * 6 * t end
			if (t < 1/2) then return q end
			if (t < 2/3) then return p + (q - p) * (2/3 - t) * 6 end
			return p;
		end

		if (l < 1/2) then
			q = l * (1 + s);
		else
			q = l + s - l * s;
		end

		p = 2 * l - q;

		r = hue2rgb(p, q, h + 1/3);
		g = hue2rgb(p, q, h);
		b = hue2rgb(p, q, h - 1/3);

		return r, g, b;
	end
end

function HoFNotifier.Notify( message )
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.DUEL_START);
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL);
	params:SetText(message);
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params);
end

EVENT_MANAGER:RegisterForEvent(HoFNotifier.name, EVENT_ADD_ON_LOADED, HoFNotifier.OnAddOnLoaded);
