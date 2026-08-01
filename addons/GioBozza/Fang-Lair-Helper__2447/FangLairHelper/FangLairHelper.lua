FangLairHelper = {
	Name = "FangLairHelper",
	Initialized = false,
	Listening = false,
	BufferTable = {},
}

function FangLairHelper.OnAddOnLoaded(eventCode, addonName)
	if (addonName ~= FangLairHelper.Name) then return end
	EVENT_MANAGER:UnregisterForEvent(FangLairHelper.Name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(FangLairHelper.Name, EVENT_PLAYER_ACTIVATED, FangLairHelper.PlayerActivated)
end

function FangLairHelper.PlayerActivated(eventCode, initial)
	if (not FangLairHelper.Initialized) then
		FangLairHelper.Initialized = true
		FangLairHelper.InitializeUI()
		EVENT_MANAGER:RegisterForEvent(FangLairHelper.Name, EVENT_PLAYER_COMBAT_STATE, FangLairHelper.PlayerCombatState)
		if (IsUnitInCombat("player")) then
			FangLairHelper.PlayerCombatState(nil, true)
		end
	end
end

function FangLairHelper.InitializeUI()
	FangLairHelperNotifications:ClearAnchors()
	FangLairHelperNotifications:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -100)
	FangLairHelperNotifications:SetHidden(false)
	FangLairHelper.Banners = {}
	for i = 1, 2 do
		local control = FangLairHelperNotifications:GetNamedChild("Banner" .. i)
		table.insert(FangLairHelper.Banners, {
			active = false,
			control = control,
		})
		control:SetAlpha(0)
	end
end

function FangLairHelper.PlayerCombatState(eventCode, inCombat)
	if (inCombat) then
		FangLairHelper.StartListening()
	else
		zo_callLater(function() if (not IsUnitInCombat("player")) then FangLairHelper.StopListening() end end, 3000)
	end
end

function FangLairHelper.StartListening()
	if (not FangLairHelper.Listening) then
		FangLairHelper.Listening = true
		EVENT_MANAGER:RegisterForEvent(FangLairHelper.Name, EVENT_COMBAT_EVENT, FangLairHelper.CombatEvent)
	end
end

function FangLairHelper.StopListening()
	if (FangLairHelper.Listening) then
		FangLairHelper.Listening = false
		EVENT_MANAGER:UnregisterForEvent(FangLairHelper.Name, EVENT_COMBAT_EVENT)
	end
end

function FangLairHelper.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	--if (abilityId == 97012 or abilityId == 97029 or abilityId == 97036 or abilityId == 99020 or abilityId == 99022 or abilityId == 99024 or abilityId == 99025 or abilityId == 103445 or abilityId == 103446 or abilityId == 95758 or abilityId == 95780 or abilityId == 98575 or abilityId == 98576 or abilityId == 98577 or abilityId == 99023 or abilityId == 105857 or abilityId == 105858) then
	--	d(abilityId.." "..abilityName)
	--end
	if (result == ACTION_RESULT_EFFECT_GAINED and abilityId == 96687) then
		if not FangLairHelper.BufferReached("shalks_buffer", 2) then return; end
		FangLairHelper.Alert(nil, "SHALKS", "FF6600", SOUNDS.DUEL_START, 3000)
	elseif (abilityId == 96556) then
		if not FangLairHelper.BufferReached("necrotic_swarm_buffer", 10) then return; end
		FangLairHelper.Alert(nil, "INTERRUPT or BLOCK", "FF6600", SOUNDS.DUEL_START, 5000) -- TODO only once
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 97011) then
		FangLairHelper.Alert(nil, "Ghosts "..abilityId, "FF6600", SOUNDS.DUEL_START, 5000) -- TODO directions
	elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == 102554) then
		FangLairHelper.Alert(nil, "Plague Breath", "FF6600", SOUNDS.DUEL_START, 5000) -- OK
	elseif (abilityId == 96680) then
		if not FangLairHelper.BufferReached("empowered_necrotic_swarm_buffer", 10) then return; end
		FangLairHelper.Alert(nil, "BLOCK", "FF6600", SOUNDS.DUEL_START, 5000) -- TODO only once
	end
end

function FangLairHelper.Alert(textMinor, textMajor, color, sound, duration)
	if (not textMinor or textMinor == "") then textMinor = " "; end
	if (not sound) then sound = SOUNDS.DUEL_START; end
	if (not duration) then duration = 2000; end
	local banner = FangLairHelper.Banners[(FangLairHelper.Banners[1].active and not FangLairHelper.Banners[2].active) and 2 or 1]
	banner.active = true
	banner.control:GetNamedChild("Minor"):SetText(textMinor)
	banner.control:GetNamedChild("Major"):SetText(string.format("|c%s%s|r", color, textMajor))
	banner.control:SetAlpha(1)
	PlaySound(sound)
	zo_callLater(function() banner.active = false; banner.control:SetAlpha(0) end, duration)
end

function FangLairHelper.BufferReached(key, buffer)
	if (key == nil) then return true; end
	if (FangLairHelper.BufferTable[key] == nil) then FangLairHelper.BufferTable[key] = {}; end
	FangLairHelper.BufferTable[key].buffer = buffer
	FangLairHelper.BufferTable[key].now = GetFrameTimeSeconds()
	if (FangLairHelper.BufferTable[key].last == nil) then
		FangLairHelper.BufferTable[key].last = FangLairHelper.BufferTable[key].now
		return true
	end
	FangLairHelper.BufferTable[key].diff = FangLairHelper.BufferTable[key].now - FangLairHelper.BufferTable[key].last
	FangLairHelper.BufferTable[key].eval = FangLairHelper.BufferTable[key].diff >= FangLairHelper.BufferTable[key].buffer
	if (FangLairHelper.BufferTable[key].eval) then FangLairHelper.BufferTable[key].last = FangLairHelper.BufferTable[key].now; end
	return FangLairHelper.BufferTable[key].eval
end

EVENT_MANAGER:RegisterForEvent(FangLairHelper.Name, EVENT_ADD_ON_LOADED, FangLairHelper.OnAddOnLoaded)
