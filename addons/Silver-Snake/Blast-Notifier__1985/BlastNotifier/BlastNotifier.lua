BlastNotifier = {
	name = "BlastNotifier",
	defaults = {
		left = 400,
		top = 300,
	},
	ids = {
		asylumZone = 1000,
		defiling_dye_blast = 95545,
		dormant = 99990,
	},
	pollingInterval = 500, -- 0.5 seconds
	listening = false,
	monitoringOlms = false,
	unitIdLlothis = 0,
	llotisIsActive = false,
	lastBlast = 0,
	firstBlast = false,
	wasNotAnnounced = false,
};

function BlastNotifier.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= BlastNotifier.name) then return end
	EVENT_MANAGER:UnregisterForEvent(BlastNotifier.name, EVENT_ADD_ON_LOADED);
	BlastNotifier.vars = ZO_SavedVars:NewAccountWide("BlastNotifierSavedVariables", 1, nil, BlastNotifier.defaults, nil, "$InstallationWide");
	BlastNotifierFrame:ClearAnchors();
	BlastNotifierFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlastNotifier.vars.left, BlastNotifier.vars.top);
	BlastNotifier.fragment = ZO_HUDFadeSceneFragment:New(BlastNotifierFrame);
	EVENT_MANAGER:RegisterForEvent(BlastNotifier.name, EVENT_PLAYER_ACTIVATED, BlastNotifier.PlayerActivated);
end

function BlastNotifier.PlayerActivated( eventCode, initial )
	if (GetZoneId(GetUnitZoneIndex("player")) == BlastNotifier.ids.asylumZone) then
		if (not BlastNotifier.listening) then
			BlastNotifier.listening = true;
			BlastNotifier.StopMonitoringOlms(true);

			EVENT_MANAGER:RegisterForEvent(BlastNotifier.name, EVENT_PLAYER_COMBAT_STATE, BlastNotifier.PlayerCombatState);
			EVENT_MANAGER:RegisterForEvent(BlastNotifier.name, EVENT_EFFECT_CHANGED, BlastNotifier.EffectChanged);
			EVENT_MANAGER:RegisterForEvent(BlastNotifier.name, EVENT_COMBAT_EVENT, BlastNotifier.CombatEvent);
			EVENT_MANAGER:RegisterForUpdate(BlastNotifier.name, BlastNotifier.pollingInterval, BlastNotifier.Poll);
			SCENE_MANAGER:GetScene("hud"):AddFragment(BlastNotifier.fragment);
			SCENE_MANAGER:GetScene("hudui"):AddFragment(BlastNotifier.fragment);
			BlastNotifier.Reset();
			if (IsUnitInCombat("player")) then
				BlastNotifier.PlayerCombatState(nil, true);
			end
		end
	else
		if (BlastNotifier.listening) then
			BlastNotifier.listening = false;
			BlastNotifier.StopMonitoringOlms(true);
			EVENT_MANAGER:UnregisterForEvent(BlastNotifier.name, EVENT_PLAYER_COMBAT_STATE);
			EVENT_MANAGER:UnregisterForEvent(BlastNotifier.name, EVENT_EFFECT_CHANGED);
			EVENT_MANAGER:UnregisterForEvent(BlastNotifier.name, EVENT_COMBAT_EVENT);
			EVENT_MANAGER:UnregisterForUpdate(BlastNotifier.name);
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(BlastNotifier.fragment);
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BlastNotifier.fragment);
		end
	end
end

function BlastNotifier.PlayerCombatState( eventCode, inCombat )
	if (inCombat and string.find(string.lower(GetUnitName("boss1")), "olms")) then
		BlastNotifier.StartMonitoringOlms();
	else
		-- Avoid false positives of combat end, often caused by combat rezzes
		zo_callLater(function() if (not IsUnitInCombat("player")) then BlastNotifier.StopMonitoringOlms() end end, 3000);
	end
end

function BlastNotifier.StartMonitoringOlms( )
	if (not BlastNotifier.monitoringOlms) then
		BlastNotifier.monitoringOlms = true;
		BlastNotifier.Reset();
	end
end

function BlastNotifier.StopMonitoringOlms( manual )
	if (BlastNotifier.monitoringOlms or manual) then
		BlastNotifier.monitoringOlms = false;
		BlastNotifier.Reset();
	end
end

function BlastNotifier.InitializeLlothis(unitId)
	BlastNotifier.unitIdLlothis = unitId;
	BlastNotifier.llotisIsActive = true;
	BlastNotifier.firstBlast = true;			--
	BlastNotifier.wasNotAnnounced = true;
end

function BlastNotifier.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	if (BlastNotifier.monitoringOlms and BlastNotifier.unitIdLlothis == 0 and string.find(string.lower(unitName), "llothis")) then
		BlastNotifier.InitializeLlothis(unitId);
	end
	if (abilityId == BlastNotifier.ids.dormant and unitId == BlastNotifier.unitIdLlothis) then
		if (changeType == EFFECT_RESULT_FADED and unitId == BlastNotifier.unitIdLlothis) then
			BlastNotifier.llotisIsActive = true;
			BlastNotifier.firstBlast = true;
			BlastNotifier.wasNotAnnounced = true;
		elseif (changeType == EFFECT_RESULT_GAINED and unitId == BlastNotifier.unitIdLlothis) then
			BlastNotifier.llotisIsActive = false;
			BlastNotifier.lastBlast = 0;
			BlastNotifier.wasNotAnnounced = false;
			BlastNotifier.firstBlast = true;
		end
	end
end

function BlastNotifier.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
	if (BlastNotifier.monitoringOlms and BlastNotifier.unitIdLlothis == 0) then
		if (string.find(string.lower(sourceName), "llothis")) then
			BlastNotifier.InitializeLlothis(sourceUnitId);
		end
		if (string.find(string.lower(targetName), "llothis")) then
			BlastNotifier.InitializeLlothis(targetUnitId);
		end
	end
	if (BlastNotifier.monitoringOlms and BlastNotifier.llotisIsActive == true and result == ACTION_RESULT_BEGIN and abilityId == BlastNotifier.ids.defiling_dye_blast and hitValue == 2000) then
		BlastNotifier.lastBlast = GetGameTimeMilliseconds();
		BlastNotifier.firstBlast = false;
		BlastNotifier.wasNotAnnounced = true;
	end
end

function BlastNotifier.Poll( )
	if (BlastNotifier.monitoringOlms) then
		if (BlastNotifier.llotisIsActive) then
			if (BlastNotifier.firstBlast and BlastNotifier.wasNotAnnounced) then
				BlastNotifier.wasNotAnnounced = false;
				BlastNotifier.Notify(string.format("|c00cc00%s|r", "YOU ARE NOT PREPARED!!!"), SOUNDS.DUEL_START);
			end
			if (BlastNotifier.lastBlast > 0) then
				local timeMechanic = GetGameTimeMilliseconds() - BlastNotifier.lastBlast;
				BlastNotifierFrameCounter:SetText(BlastNotifier.FormatTime(timeMechanic));
				if (timeMechanic > 19499 and BlastNotifier.wasNotAnnounced) then
					BlastNotifier.wasNotAnnounced = false;
					BlastNotifier.Notify(string.format("|c00cc00%s|r", "SHIELDS UP!!!"), SOUNDS.DUEL_START);
				end
			end
		else
			BlastNotifierFrameCounter:SetText("0");
		end
	end
end

function BlastNotifier.Reset( )
	BlastNotifierFrameCounter:SetText("0");
	BlastNotifier.unitIdLlothis = 0;
	BlastNotifier.llotisIsActive = false;
	BlastNotifier.lastBlast = 0;
	BlastNotifier.firstBlast = false;
	BlastNotifier.wasNotAnnounced = false;
end

function BlastNotifier.OnMoveStop( )
	BlastNotifier.vars.left = BlastNotifierFrame:GetLeft();
	BlastNotifier.vars.top = BlastNotifierFrame:GetTop();
end

function BlastNotifier.FormatTime(ms)
	if (ms < 0) then ms = 0 end
	return(string.format("%d", math.floor(ms / 1000)));
end

function BlastNotifier.Notify( message, sound )
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, sound);
	--local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound);
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL);
	params:SetText(message);
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params);
end

EVENT_MANAGER:RegisterForEvent(BlastNotifier.name, EVENT_ADD_ON_LOADED, BlastNotifier.OnAddOnLoaded);