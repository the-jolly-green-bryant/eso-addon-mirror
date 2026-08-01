AsylumNotifier = {
	name = "AsylumNotifier",

	-- Default settings
	defaults = {
		left = 400,
		top = 300,
		dimmed_opacity = 0.7,
		notify = {
			oppressive_bolts = true,
			teleport_strike = true,
			exhaustive_charges = true,
			add_spawn = false,
		},
	},

	ids = {
		asylumZone = 1000,
		boss_aura = 10298,
		find_turret = 64508,
		defiling_dye_blast = 95545,
		oppressive_bolts_channel = 95585,
		oppressive_bolts_damage = 95687,
		teleport_strike = 99138,
		teleport_strike2 = 95723,
		teleport_check = 99139,
		pernicious_transmission = 99819,
		storm_the_heavens = 98535,
		maim = 95657,
		dormant = 99990,
		enrage = 101354,
		exhaustive_charges = 100437,
	},

	pollingInterval = 500, -- 0.5 seconds

	-- Row assignments:
	-- 1: Llothis
	-- 2: Felms
	-- 3: Storm the Heavens
	-- 4: Protector Spawn
	-- 5: Maim
	maxRows = 5,
	rows = { },

	listening = false,
	monitoringOlms = false,
	units = { },
	spawnTimes = { },
	unitIdLlothis = 0,
	unitIdFelms = 0,
	unitIdProtector = 0,
	verifiedProtector = false,
	lastSpawn = 0,
	lastProtectorDeath = 0,
	lastTransmission = 0,
	lastBolts = 0,
	lastBlast = 0,
	lastTeleport = 0,
	teleportCount = 0,
	teleportCooldown = 0,
	lastStorm = 0,
	maimEnd = 0,
	unitNameOlms = "Olms",
	unitNameLlothis = "Llothis",
	unitNameFelms = "Felms",
	unitNameProtector = "Ordinated Protector"
};

function AsylumNotifier.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= AsylumNotifier.name) then return end

	EVENT_MANAGER:UnregisterForEvent(AsylumNotifier.name, EVENT_ADD_ON_LOADED);

	AsylumNotifier.vars = ZO_SavedVars:NewAccountWide("AsylumNotifierSavedVariables", 1, nil, AsylumNotifier.defaults, nil, "$InstallationWide");

	AsylumNotifierFrame:ClearAnchors();
	AsylumNotifierFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AsylumNotifier.vars.left, AsylumNotifier.vars.top);

	AsylumNotifier.title = AsylumNotifierFrame:GetNamedChild("Title");

	for i = 1, AsylumNotifier.maxRows do
		AsylumNotifier.rows[i] = AsylumNotifierFrame:GetNamedChild("Row" .. i);
		AsylumNotifier.rows[i].label = AsylumNotifier.rows[i]:GetNamedChild("Label");
		AsylumNotifier.rows[i].note = AsylumNotifier.rows[i]:GetNamedChild("Note");
		AsylumNotifier.rows[i].timeMain = AsylumNotifier.rows[i]:GetNamedChild("TimeMain");
		AsylumNotifier.rows[i].timeMech = {
			AsylumNotifier.rows[i]:GetNamedChild("TimeMech1"),
			AsylumNotifier.rows[i]:GetNamedChild("TimeMech2"),
			AsylumNotifier.rows[i]:GetNamedChild("TimeMech3"),
		};
		AsylumNotifier.rows[i].enabled = false;
	end

	-- Localization
	local locale = GetCVar("language.2");
	if locale == "en" then
		AsylumNotifier.unitNameOlms = "Olms";
		AsylumNotifier.unitNameLlothis = "Llothis";
		AsylumNotifier.unitNameFelms = "Felms";
		AsylumNotifier.unitNameProtector = "Ordinated Protector";
	elseif locale == "jp" then
		AsylumNotifier.unitNameOlms = "オルムス";
		AsylumNotifier.unitNameLlothis = "ロシス";
		AsylumNotifier.unitNameFelms = "フェルムス";
		AsylumNotifier.unitNameProtector = "スフィア";
	end

	AsylumNotifier.fragment = ZO_HUDFadeSceneFragment:New(AsylumNotifierFrame);

	EVENT_MANAGER:RegisterForEvent(AsylumNotifier.name, EVENT_PLAYER_ACTIVATED, AsylumNotifier.PlayerActivated);
end

function AsylumNotifier.PlayerActivated( eventCode, initial )
	if (GetZoneId(GetUnitZoneIndex("player")) == AsylumNotifier.ids.asylumZone) then
		if (not AsylumNotifier.listening) then
			AsylumNotifier.listening = true;
			AsylumNotifier.StopMonitoringOlms(true);

			EVENT_MANAGER:RegisterForEvent(AsylumNotifier.name, EVENT_PLAYER_COMBAT_STATE, AsylumNotifier.PlayerCombatState);
			EVENT_MANAGER:RegisterForEvent(AsylumNotifier.name, EVENT_EFFECT_CHANGED, AsylumNotifier.EffectChanged);
			EVENT_MANAGER:RegisterForEvent(AsylumNotifier.name, EVENT_COMBAT_EVENT, AsylumNotifier.CombatEvent);

			EVENT_MANAGER:RegisterForUpdate(AsylumNotifier.name, AsylumNotifier.pollingInterval, AsylumNotifier.Poll);

			SCENE_MANAGER:GetScene("hud"):AddFragment(AsylumNotifier.fragment);
			SCENE_MANAGER:GetScene("hudui"):AddFragment(AsylumNotifier.fragment);

			if (IsUnitInCombat("player")) then
				AsylumNotifier.PlayerCombatState(nil, true);
			end
		end
	else
		if (AsylumNotifier.listening) then
			AsylumNotifier.listening = false;
			AsylumNotifier.StopMonitoringOlms(true);

			EVENT_MANAGER:UnregisterForEvent(AsylumNotifier.name, EVENT_PLAYER_COMBAT_STATE);
			EVENT_MANAGER:UnregisterForEvent(AsylumNotifier.name, EVENT_EFFECT_CHANGED);
			EVENT_MANAGER:UnregisterForEvent(AsylumNotifier.name, EVENT_COMBAT_EVENT);

			EVENT_MANAGER:UnregisterForUpdate(AsylumNotifier.name);

			SCENE_MANAGER:GetScene("hud"):RemoveFragment(AsylumNotifier.fragment);
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(AsylumNotifier.fragment);
		end
	end
end

function AsylumNotifier.PlayerCombatState( eventCode, inCombat )
	if (inCombat and string.find(string.lower(GetUnitName("boss1")), string.lower(AsylumNotifier.unitNameOlms))) then
		AsylumNotifier.StartMonitoringOlms();
	else
		-- Avoid false positives of combat end, often caused by combat rezzes
		zo_callLater(function() if (not IsUnitInCombat("player")) then AsylumNotifier.StopMonitoringOlms() end end, 3000);
	end
end

function AsylumNotifier.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	if (AsylumNotifier.monitoringOlms) then
		AsylumNotifier.IdentifyUnit(unitId, unitName);
	end

	if (abilityId == AsylumNotifier.ids.dormant) then
		AsylumNotifier.InitializeUnit(unitId);

		if (changeType == EFFECT_RESULT_FADED) then
			AsylumNotifier.units[unitId].isActive = true;
			AsylumNotifier.units[unitId].dormancyEnd = GetGameTimeMilliseconds();
		elseif (changeType == EFFECT_RESULT_GAINED) then
			AsylumNotifier.units[unitId].isActive = false;
			AsylumNotifier.units[unitId].dormancyEnd = endTime * 1000;
			AsylumNotifier.units[unitId].enrage = 0;

			if (unitId == AsylumNotifier.unitIdLlothis) then
				AsylumNotifier.lastTransmission = 0;
				AsylumNotifier.lastBolts = 0;
				AsylumNotifier.lastBlast = 0;
			end
		end
	elseif (abilityId == AsylumNotifier.ids.enrage) then
		AsylumNotifier.InitializeUnit(unitId);

		if (changeType == EFFECT_RESULT_FADED) then
			AsylumNotifier.units[unitId].enrage = 0;
		else
			AsylumNotifier.units[unitId].enrage = stackCount;
		end
	elseif (abilityId == AsylumNotifier.ids.maim and unitTag == "player") then
		if (changeType == EFFECT_RESULT_FADED) then
			AsylumNotifier.rows[5].enabled = false;
			AsylumNotifier.rows[5]:SetHidden(true);
		else
			AsylumNotifier.maimEnd = endTime * 1000;
			AsylumNotifier.rows[5].enabled = true;
			AsylumNotifier.rows[5]:SetHidden(false);
		end
	elseif (abilityId == AsylumNotifier.ids.teleport_check) then
		--[[
		if (changeType ~= EFFECT_RESULT_FADED and stackCount == 3) then
			AsylumNotifier.teleportCooldown = endTime * 1000;
		end
		--]]
	end
end

function AsylumNotifier.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
	if (AsylumNotifier.monitoringOlms) then
		AsylumNotifier.IdentifyUnit(sourceUnitId, sourceName);
		AsylumNotifier.IdentifyUnit(targetUnitId, targetName);
	end

	if (result == ACTION_RESULT_BEGIN and abilityId == AsylumNotifier.ids.oppressive_bolts_channel and hitValue == 1000) then
		AsylumNotifier.lastBolts = GetGameTimeMilliseconds();
		--[[
		if (AsylumNotifier.vars.notify.oppressive_bolts) then
			AsylumNotifier.Notify(string.format(GetString(SI_ASSP_NOTIFY_OPPRESSIVE_BOLTS), GetAbilityName(AsylumNotifier.ids.oppressive_bolts_damage)), SOUNDS.TELVAR_MULTIPLIERMAX);
		end
		--]]
	elseif (result == ACTION_RESULT_BEGIN and abilityId == AsylumNotifier.ids.teleport_strike and targetType == COMBAT_UNIT_TYPE_PLAYER) then
		--[[
		if (AsylumNotifier.vars.notify.teleport_strike) then
			AsylumNotifier.Notify(string.format(GetString(SI_ASSP_NOTIFY_TELEPORT_STRIKE), GetAbilityName(AsylumNotifier.ids.teleport_strike)), SOUNDS.JUSTICE_STATE_CHANGED);
		end
		--]]
	elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == AsylumNotifier.ids.exhaustive_charges and targetType == COMBAT_UNIT_TYPE_PLAYER) then
		--[[
		if (AsylumNotifier.vars.notify.exhaustive_charges) then
			AsylumNotifier.Notify(string.format(GetString(SI_ASSP_NOTIFY_EXHAUSTIVE_CHARGES), abilityName), SOUNDS.DUEL_START);
		end
		--]]
	elseif (result == ACTION_RESULT_BEGIN and abilityId == AsylumNotifier.ids.teleport_strike2) then
		local currentTime = GetGameTimeMilliseconds();
		if (currentTime - AsylumNotifier.lastTeleport > 10000) then
			AsylumNotifier.teleportCount = 0
		end
		AsylumNotifier.lastTeleport = currentTime
		AsylumNotifier.teleportCount = AsylumNotifier.teleportCount + 1
		if (AsylumNotifier.teleportCount == 3) then
			AsylumNotifier.teleportCooldown = currentTime + 20000
		end
	elseif (result == ACTION_RESULT_BEGIN and abilityId == AsylumNotifier.ids.storm_the_heavens and hitValue == 500) then
		AsylumNotifier.lastStorm = GetGameTimeMilliseconds();

		if (not AsylumNotifier.rows[3].enabled) then
			AsylumNotifier.rows[3].enabled = true;
			AsylumNotifier.rows[3]:SetHidden(false);
		end
	elseif (AsylumNotifier.monitoringOlms and result == ACTION_RESULT_BEGIN and abilityId == AsylumNotifier.ids.pernicious_transmission) then
		AsylumNotifier.lastTransmission = GetGameTimeMilliseconds();
	elseif (AsylumNotifier.monitoringOlms and result == ACTION_RESULT_BEGIN and abilityId == AsylumNotifier.ids.defiling_dye_blast and hitValue == 2000) then
		AsylumNotifier.lastBlast = GetGameTimeMilliseconds();
	elseif (AsylumNotifier.monitoringOlms and result == ACTION_RESULT_EFFECT_GAINED and abilityId == AsylumNotifier.ids.boss_aura and hitValue == 1) then
		local currentTime = GetGameTimeMilliseconds();

		AsylumNotifier.spawnTimes[targetUnitId] = currentTime;

		if (currentTime - AsylumNotifier.lastSpawn > 100) then
			AsylumNotifier.spawnValid = true;

			zo_callLater(function( )
				if (AsylumNotifier.spawnValid) then
					AsylumNotifier.ProtectorSpawn(targetUnitId, false);
				end
			end, 300);
		else
			AsylumNotifier.spawnValid = false;
		end

		AsylumNotifier.lastSpawn = currentTime;
	elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == AsylumNotifier.ids.find_turret) then
		if (not AsylumNotifier.spawnTimes[targetUnitId]) then
			-- This code should never run
			d("WARNING: Protector spawn time not found; please report this incident to the addon author!");
			AsylumNotifier.spawnTimes[targetUnitId] = GetGameTimeMilliseconds();
		end

		AsylumNotifier.ProtectorSpawn(targetUnitId, true);
	elseif (result == ACTION_RESULT_DIED and targetUnitId == AsylumNotifier.unitIdProtector) then
		AsylumNotifier.unitIdProtector = 0;
		AsylumNotifier.verifiedProtector = false;
		AsylumNotifier.lastProtectorDeath = GetGameTimeMilliseconds();
	end
end

function AsylumNotifier.OnMoveStop( )
	AsylumNotifier.vars.left = AsylumNotifierFrame:GetLeft();
	AsylumNotifier.vars.top = AsylumNotifierFrame:GetTop();
end

function AsylumNotifier.Reset( )
	local ResetField = function( control )
		control:SetColor(1, 1, 1, 1);
		control:SetAlpha(1);
		control:SetText("");
	end

	AsylumNotifier.title:SetHidden(true);

	-- Reset all rows
	for i = 1, AsylumNotifier.maxRows do
		ResetField(AsylumNotifier.rows[i].label);
		ResetField(AsylumNotifier.rows[i].note);
		ResetField(AsylumNotifier.rows[i].timeMain);
		for j = 1, 3 do
			ResetField(AsylumNotifier.rows[i].timeMech[j]);
		end
		AsylumNotifier.rows[i].enabled = false;
		AsylumNotifier.rows[i]:SetHidden(true);
	end

	AsylumNotifier.rows[1].timeMech[2]:SetColor(1, 0.4, 0.2, 1);
	AsylumNotifier.rows[1].timeMech[3]:SetColor(0.5, 1, 0.5, 1);
	AsylumNotifier.rows[3].label:SetText(GetAbilityName(AsylumNotifier.ids.storm_the_heavens));
	AsylumNotifier.rows[4].label:SetText(AsylumNotifier.unitNameProtector);
	AsylumNotifier.rows[5].label:SetText(GetAbilityName(AsylumNotifier.ids.maim));

	AsylumNotifier.units = { };
	AsylumNotifier.spawnTimes = { };
	AsylumNotifier.unitIdLlothis = 0;
	AsylumNotifier.unitIdFelms = 0;
	AsylumNotifier.unitIdProtector = 0;
	AsylumNotifier.verifiedProtector = false;
	AsylumNotifier.lastProtectorDeath = 0;
	AsylumNotifier.lastTransmission = 0;
	AsylumNotifier.lastBolts = 0;
	AsylumNotifier.lastBlast = 0;
	AsylumNotifier.teleportCooldown = 0;
	AsylumNotifier.lastStorm = 0;
end

function AsylumNotifier.StartMonitoringOlms( )
	if (not AsylumNotifier.monitoringOlms) then
		AsylumNotifier.monitoringOlms = true;
		AsylumNotifier.Reset();
	end
end

function AsylumNotifier.StopMonitoringOlms( manual )
	if (AsylumNotifier.monitoringOlms or manual) then
		AsylumNotifier.monitoringOlms = false;
		AsylumNotifier.Reset();
		AsylumNotifier.title:SetHidden(false);
	end
end

function AsylumNotifier.Poll( )
	for i = 1, AsylumNotifier.maxRows do
		if (AsylumNotifier.rows[i].enabled) then
			if (i <= 2) then
				local unit = AsylumNotifier.units[AsylumNotifier.rows[i].unitId];
				local time = GetGameTimeMilliseconds() - unit.dormancyEnd;
				local timeMechanic = { };

				if (unit.isActive) then
					if (unit.enrage > 0) then
						AsylumNotifier.rows[i].timeMain:SetColor(1, 0, 0, 1);
					elseif (time >= 170000) then
						AsylumNotifier.rows[i].timeMain:SetColor(1, 0.5, 0, 1);
					elseif (time >= 135000) then
						AsylumNotifier.rows[i].timeMain:SetColor(1, 1, 0, 1);
					else
						AsylumNotifier.rows[i].timeMain:SetColor(1, 1, 1, 1);
					end

					if (i == 1) then
						if (AsylumNotifier.lastTransmission > 0) then
							timeMechanic[1] = GetGameTimeMilliseconds() - AsylumNotifier.lastTransmission;

							if (timeMechanic[1] < 24500) then
								AsylumNotifier.rows[i].timeMech[1]:SetAlpha(AsylumNotifier.vars.dimmed_opacity);
							else
								AsylumNotifier.rows[i].timeMech[1]:SetAlpha(1);
							end
						end

						if (AsylumNotifier.lastBolts > 0) then
							timeMechanic[2] = GetGameTimeMilliseconds() - AsylumNotifier.lastBolts;

							if (timeMechanic[2] < 10500) then
								AsylumNotifier.rows[i].timeMech[2]:SetAlpha(AsylumNotifier.vars.dimmed_opacity);
							else
								AsylumNotifier.rows[i].timeMech[2]:SetAlpha(1);
							end
						end

						if (AsylumNotifier.lastBlast > 0) then
							timeMechanic[3] = GetGameTimeMilliseconds() - AsylumNotifier.lastBlast;

							if (timeMechanic[3] < 19500) then
								AsylumNotifier.rows[i].timeMech[3]:SetAlpha(AsylumNotifier.vars.dimmed_opacity);
							else
								AsylumNotifier.rows[i].timeMech[3]:SetAlpha(1);
							end
						end
					elseif (i == 2) then
						if (AsylumNotifier.teleportCooldown > 0) then
							timeMechanic[1] = AsylumNotifier.teleportCooldown - GetGameTimeMilliseconds();

							if (timeMechanic[1] > 5500) then
								AsylumNotifier.rows[i].timeMech[1]:SetAlpha(AsylumNotifier.vars.dimmed_opacity);
							else
								AsylumNotifier.rows[i].timeMech[1]:SetAlpha(1);
							end
						end
					end
				else
					time = time * -1;

					if (time <= 5000) then
						AsylumNotifier.rows[i].timeMain:SetColor(0.25, 0.75, 1, 1);
					else
						AsylumNotifier.rows[i].timeMain:SetColor(0, 1, 0, 1);
					end
				end

				AsylumNotifier.rows[i].timeMain:SetText(AsylumNotifier.FormatTime(time));

				for j = 1, 3 do
					if (timeMechanic[j]) then
						AsylumNotifier.rows[i].timeMech[j]:SetText(AsylumNotifier.FormatTime(timeMechanic[j], true));
					else
						AsylumNotifier.rows[i].timeMech[j]:SetText("");
					end
				end

				if (unit.enrage > 0) then
					AsylumNotifier.rows[i].note:SetColor(1, 0, 0, 1);
					AsylumNotifier.rows[i].note:SetText(unit.enrage);
				else
					AsylumNotifier.rows[i].note:SetText("");
				end
			elseif (i == 3) then
				local time = GetGameTimeMilliseconds() - AsylumNotifier.lastStorm;

				if (time >= 38000) then
					AsylumNotifier.rows[i].timeMain:SetColor(1, 0, 1, 1);
				else
					AsylumNotifier.rows[i].timeMain:SetColor(1, 1, 1, 1);
				end

				AsylumNotifier.rows[i].timeMain:SetText(AsylumNotifier.FormatTime(time));
			elseif (i == 4) then
				local time;

				if (AsylumNotifier.unitIdProtector ~= 0) then
					time = GetGameTimeMilliseconds() - AsylumNotifier.spawnTimes[AsylumNotifier.unitIdProtector];

					if (time >= 75000) then
						AsylumNotifier.rows[i].timeMain:SetColor(1, 0.5, 0, 1);
					else
						AsylumNotifier.rows[i].timeMain:SetColor(1, 1, 1, 1);
					end
				else
					time = GetGameTimeMilliseconds() - AsylumNotifier.lastProtectorDeath;

					AsylumNotifier.rows[i].timeMain:SetColor(0, 1, 0, 1);
				end

				AsylumNotifier.rows[i].timeMain:SetText(AsylumNotifier.FormatTime(time));
			elseif (i == 5) then
				local time = AsylumNotifier.maimEnd - GetGameTimeMilliseconds();
				AsylumNotifier.rows[i].timeMain:SetText(AsylumNotifier.FormatTime(time));
			end
		end
	end
end

function AsylumNotifier.ProtectorSpawn( unitId, verified )
	local register = function( notify )
		AsylumNotifier.unitIdProtector = unitId;
		AsylumNotifier.verifiedProtector = verified;

		if (not AsylumNotifier.rows[4].enabled) then
			AsylumNotifier.rows[4].enabled = true;
			AsylumNotifier.rows[4]:SetHidden(false);
		end

		--[[
		if (notify and AsylumNotifier.vars.notify.add_spawn) then
			AsylumNotifier.Notify(GetString(SI_ASSP_NOTIFY_ADD_SPAWN), SOUNDS.DISPLAY_ANNOUNCEMENT);
		end
		--]]
	end

	if (AsylumNotifier.unitIdProtector == 0) then
		-- No protector is currently up
		register(true);
	elseif (verified) then
		-- Protector is up, and we just got a verified protector
		if (not AsylumNotifier.verifiedProtector) then
			-- Always override a non-verified protector
			register(false);
		elseif (AsylumNotifier.spawnTimes[unitId] - AsylumNotifier.spawnTimes[AsylumNotifier.unitIdProtector] < 85000) then
			-- If a verified protector spawns while another verified protector
			-- is alive, and we are not yet due for a penalty protector, then
			-- somehow the existing protector's death event had been missed
			--d("WARNING: Protector spawn override; please report this incident to the addon author!");
			register(true);
		end
	end
end

function AsylumNotifier.InitializeUnit( unitId, unitName, rowId )
	if (not AsylumNotifier.units[unitId]) then
		AsylumNotifier.units[unitId] = {
			isActive = true,
			dormancyEnd = GetGameTimeMilliseconds(),
			enrage = 0,
		};

		if (AsylumNotifier.spawnTimes[unitId]) then
			AsylumNotifier.units[unitId].dormancyEnd = AsylumNotifier.spawnTimes[unitId];
		end

		if (rowId) then
			AsylumNotifier.rows[rowId].unitId = unitId;
			AsylumNotifier.rows[rowId].label:SetText(unitName);
			AsylumNotifier.rows[rowId].enabled = true;
			AsylumNotifier.rows[rowId]:SetHidden(false);
		end
	end
end

function AsylumNotifier.IdentifyUnit( unitId, unitName )
	if (AsylumNotifier.unitIdLlothis == 0 and string.find(string.lower(unitName), string.lower(AsylumNotifier.unitNameLlothis))) then
		AsylumNotifier.unitIdLlothis = unitId;
		AsylumNotifier.InitializeUnit(unitId, LocalizeString("<<1>>", unitName), 1);
	elseif (AsylumNotifier.unitIdFelms == 0 and string.find(string.lower(unitName), string.lower(AsylumNotifier.unitNameFelms))) then
		AsylumNotifier.unitIdFelms = unitId;
		AsylumNotifier.InitializeUnit(unitId, LocalizeString("<<1>>", unitName), 2);
	end
end

function AsylumNotifier.FormatTime( ms, useShort )
	if (ms < 0) then ms = 0 end

	if (useShort) then
		return(string.format("%ds", math.floor(ms / 1000)));
	else
		return(string.format(
			"%d:%02d",
			math.floor(ms / 60000),
			math.floor(ms / 1000) % 60
		));
	end
end

function AsylumNotifier.Notify( message, sound )
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, sound);
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL);
	params:SetText(message);
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params);
end

EVENT_MANAGER:RegisterForEvent(AsylumNotifier.name, EVENT_ADD_ON_LOADED, AsylumNotifier.OnAddOnLoaded);
