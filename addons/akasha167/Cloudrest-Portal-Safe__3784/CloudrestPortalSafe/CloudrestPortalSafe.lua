CRPS = CRPS or {}
CRPS.name = "CloudrestPortalSafe"
CRPS.version = "1.0.5"
CRPS.varsName = "CRPSVars"
CRPS.varsVersion = 1

CRPS.isMovable = false

CRPS.isCloudrest = false
CRPS.isInCombat = false
CRPS.playerName = ""
CRPS.playerId = 0
CRPS.group = {}
CRPS.nameById = {}
CRPS.tanksInPortal = 0
CRPS.spearsDone = 0
CRPS.startedAt = 0

CRPS.defaults = {
	debugEnabled = false,
	alertMyself = false,
	showSpearsDone = false,
	alertDuration = 4,
	alertFontSize = 48,
	alertFontColor = {1, 1, 1, 1},
	soundEnabled = true,
	soundId = "ANTIQUITIES_FANFARE_COMPLETED",
	soundVolume = 1,
	offsetX = 0,
	offsetY = 0 - GuiRoot:GetHeight() / 4,
}

function CRPS.onZoneChange(_, _)
	local zone, x, y, z = GetUnitWorldPosition("player")

	if zone == 1051 then
		CRPS.group = {}
		CRPS.tanksInPortal = 0
		CRPS.isCloudrest = true
		CRPS.loadUnits()

		-- regitering units
		EVENT_MANAGER:RegisterForEvent(CRPS.name, EVENT_GROUP_UPDATE, CRPS.onGroupUpdate)
		-- regitering unitIds
		EVENT_MANAGER:RegisterForEvent(CRPS.name, EVENT_EFFECT_CHANGED, CRPS.onEffectChanged)
		-- entering combat
		EVENT_MANAGER:RegisterForEvent(CRPS.name, EVENT_PLAYER_COMBAT_STATE, CRPS.onCombatStateChanged)
		-- unit enters/exits portal
		EVENT_MANAGER:RegisterForEvent(CRPS.name, EVENT_COMBAT_EVENT, CRPS.onCombatEvent)
		-- unit dies
		EVENT_MANAGER:RegisterForEvent(CRPS.name, EVENT_UNIT_DEATH_STATE_CHANGED, CRPS.onUnitDeath)

		CRPS.debug(GetString(CRPS_EVENT_ADDONENABLED))
	elseif CRPS.isCloudrest then
		-- unregister events
		EVENT_MANAGER:UnregisterForEvent(CRPS.name, EVENT_GROUP_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(CRPS.name, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(CRPS.name, EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForEvent(CRPS.name, EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(CRPS.name, EVENT_UNIT_DEATH_STATE_CHANGED)

		CRPS.group = {}
		CRPS.tanksInPortal = 0
		CRPS.isCloudrest = false

		CRPS.console(GetString(CRPS_EVENT_ADDONDISABLED))
	end
end

function CRPS.onGroupUpdate(_)
	CRPS.debug(GetString(CRPS_MSG_GROUPUPDATE))
	local playerGroupUnitTag = GetGroupUnitTagByIndex(GetGroupIndexByUnitTag("player")) or nil
	local group = CRPS.group
	CRPS.group = {}
	if playerGroupUnitTag then
		for n = 0, 12 do
			local unitTag = GetGroupUnitTagByIndex(n)
			local unitName = GetUnitName(unitTag)
			if unitName and group[unitName] then
				CRPS.group[unitName] = group[unitName]
			elseif IsUnitPlayer(unitTag) then
				CRPS.registerUnit(unitTag, unitName)
				CRPS.debug(string.format(GetString(CRPS_MSG_NEWPLAYER), unitName))
			elseif unitTag then
				CRPS.debug(string.format(GetString(CRPS_MSG_NOTAPLAYER), tostring(n)))
			end
		end
	else
		local unitName = GetUnitName(unitTag)
		CRPS.registerUnit("player", GetUnitName("player"))
	end
	for id, name in pairs(CRPS.nameById) do
		if not CRPS.group[name] then
			CRPS.nameById[id] = nil
		end
	end
end

function CRPS.onEffectChanged(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId, _, _)
	-- don't register NPCs, don't register ID twice
	if not unitId or unitId == 0 or IsUnitPlayer(unitTag) ~= true or CRPS.nameById[unitId] then return end

	CRPS.nameById[unitId] = GetUnitName(unitTag)
end

function CRPS.onCombatStateChanged(_, inCombat)
	-- entering or exiting portal world will cause a instant combat end/start
	-- call the check after 1s delay to confirm it is a new combat
	zo_callLater(function() CRPS.toggleCombat(inCombat) end, 1000)
end

function CRPS.onCombatEvent(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, unitId, abilityId)
	local targetName = CRPS.nameById[unitId]
	if CRPS.group[targetName] then
		if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
			if abilityId == 108045 then
				-- Portal enter
				CRPS.enteredPortal(targetName)
			elseif abilityId == 103983 then -- or abilityId == 103987 then
				-- Malevolent Core is carried
				zo_callLater(function() CRPS.malevolentCoreTaken(targetName) end, 125)
			end
		elseif result == ACTION_RESULT_EFFECT_FADED then
			if abilityId == 108045 then
				-- Portal exit, or player is dead
				-- added delay to let the death event triggers, as faded effect occurs before the player death
				zo_callLater(function() CRPS.exitedPortal(targetName) end, 500)
			end
			if abilityId == 103983 then -- or abilityId == 103987 then
				-- Malevolent Core is delivered, or player is dead
				zo_callLater(function() CRPS.malevolentCoreLost(targetName) end, 125)
			end
		end
	end
end

function CRPS.onUnitDeath(_, unitTag, isDead)
	if IsUnitPlayer(unitTag) ~= true or isDead ~= true then return end

	local unitName = GetUnitName(unitTag)
	if CRPS.group[unitName] then
		CRPS.died(unitName)
	end
end

function CRPS.loadUnits()
	CRPS.debug(GetString(CRPS_MSG_LOADUNITS))
	local playerUnitTag = GetGroupUnitTagByIndex(GetGroupIndexByUnitTag("player")) or nil
	if playerUnitTag then
		for n = 0, 12 do
			local unitTag = GetGroupUnitTagByIndex(n)
			if IsUnitPlayer(unitTag) then
				CRPS.registerUnit(unitTag, GetUnitName(unitTag))
				CRPS.debug(string.format(GetString(CRPS_MSG_NEWPLAYER), GetUnitName(unitTag)))
			elseif unitTag then
				CRPS.debug(string.format(GetString(CRPS_MSG_NOTAPLAYER), tostring(n)))
			end
		end
	else
		CRPS.registerUnit("player", GetUnitName("player"))
	end
end

function CRPS.registerUnit(unitTag, unitName)
	CRPS.group[unitName]= {}
	CRPS.group[unitName].role = GetGroupMemberSelectedRole(unitTag)
	CRPS.group[unitName].isPlayer = unitName == CRPS.playerName
	CRPS.group[unitName].isInPortal = false
	CRPS.group[unitName].hasMalevolentCore = false
	CRPS.group[unitName].isDead = false

	CRPS.debug(string.format(GetString(CRPS_MSG_UNITREGISTERED), unitName, unitTag))
end

function CRPS.getUnitByName(unitName)
	local unit = CRPS.group[unitName]
	if not unit then
		-- register unit
	end
	return unit
end

function CRPS.toggleCombat(inCombat)
	local isReallyInCombat = IsUnitInCombat("player")
	if isReallyInCombat and not CRPS.isInCombat then
		CRPS.tanksInPortal = 0
		CRPS.spearsDone = 0
		CRPS.debug(GetString(CRPS_MSG_COMBATSTARTED))
	end
	CRPS.isInCombat = isReallyInCombat
end

function CRPS.enteredPortal(unitName)
	local unit = CRPS.getUnitByName(unitName)
	unit.isDead = false
	CRPS.debug(string.format(GetString(CRPS_MSG_UNITENTEREDPORTAL), unitName))
	if unit.role == LFG_ROLE_TANK and not unit.isInPortal then
		CRPS.tanksInPortal = CRPS.tanksInPortal + 1
		if CRPS.tanksInPortal == 1 then
			local msg = GetString(CRPS_MSG_TANKINPORTAL)
			CRPS.debug(msg)
			CRPS.sendAlertForUnit(string.format(GetString(CRPS_ALERT_SAFE), msg), unitName)
		elseif CRPS.tanksInPortal > 1 then
			local msg = string.format(GetString(CRPS_MSG_NTANKSINPORTAL), CRPS.tanksInPortal)
			CRPS.debug(msg)
			CRPS.sendAlertForUnit(string.format(GetString(CRPS_ALERT_OVERSAFE), msg), unitName)
		end
	end
	unit.isInPortal = true
end

function CRPS.malevolentCoreTaken(unitName)
	local unit = CRPS.getUnitByName(unitName)
	if not unit.hasMalevolentCore then
		CRPS.debug(string.format(GetString(CRPS_MSG_CORETAKEN), unitName))
	end
	unit.hasMalevolentCore = true
end

function CRPS.malevolentCoreLost(unitName)
	local unit = CRPS.getUnitByName(unitName)
	if not unit.isDead and unit.hasMalevolentCore then
		CRPS.spearsDone = CRPS.spearsDone + 1
		CRPS.debug(string.format(GetString(CRPS_MSG_COREDELIVERED), unitName))
		if CRPS.spearsDone == 3 then
			if CRPS.vars.showSpearsDone then
				CRPS.sendAlert(string.format(GetString(CRPS_ALERT_SPEARDONE), CRPS.spearsDone))
			end
		end
	end
	unit.hasMalevolentCore = false
end

function CRPS.exitedPortal(unitName)
	local unit = CRPS.getUnitByName(unitName)
	local reason = GetString(CRPS_MSG_UNITLEFTPORTAL)
	if unit.isDead then
		reason = GetString(CRPS_MSG_UNITDIEDPORTAL)
	end
	if unit.role == LFG_ROLE_TANK then
		if CRPS.tanksInPortal == 1 then
			-- the last tank left the portal
			if CRPS.spearsDone == 3 then
				CRPS.spearsDone = 0
				CRPS.debug(GetString(CRPS_MSG_PORTALDONE))
				CRPS.sendAlert(GetString(CRPS_ALERT_DONE))
			else
				local msg = GetString(CRPS_MSG_NOTANKINPORTAL)
				CRPS.debug(msg)
				CRPS.sendAlertForUnit(string.format(GetString(CRPS_ALERT_UNSAFE), msg))
			end
		end
		if CRPS.tanksInPortal > 0 then
			-- don't go below 0
			CRPS.tanksInPortal = CRPS.tanksInPortal - 1
		end
	end
	unit.isInPortal = false
	CRPS.debug(string.format(reason, unitName))
end

function CRPS.died(unitName)
	local unit = CRPS.getUnitByName(unitName)
 	if not unit.isDead then
		unit.isDead = true
		unit.isInPortal = false
		CRPS.debug(string.format(GetString(CRPS_MSG_UNITDIED), unitName))
	end
end

function CRPS.sendAlertForUnit(message, unitName)
	if CRPS.vars.alertMyself == true or CRPS.playerName ~= unitName then
		CRPS.sendAlert(message)
	end
end

function CRPS.sendAlert(message)
	CRPS.debug(message)
	CRPS.startedAt = GetGameTimeMilliseconds()
	CRPS.playSound()
	CloudrestPortalSafeLabel:SetText(message)
	CRPS.setVisible(true)
	zo_callLater(CRPS.dismissAlert, CRPS.vars.alertDuration * 1000)
end

function CRPS.dismissAlert()
	duration = CRPS.vars.alertDuration * 1000
	if GetGameTimeMilliseconds() > CRPS.startedAt + duration then
		CRPS.setVisible(false)
	end
end

function CRPS.playSound()
	if CRPS.vars.soundEnabled == true then
		for i = 1, CRPS.vars.soundVolume do
			PlaySound(SOUNDS[CRPS.vars.soundId])
		end
	end
end

function CRPS.toggleMovable()
	CRPS.isMovable = not CRPS.isMovable
	if CRPS.isMovable then
		CloudrestPortalSafe:SetDimensions(CloudrestPortalSafeLabel:GetTextWidth(), CloudrestPortalSafeLabel:GetTextHeight())
		CRPS.setVisible(true)
		CloudrestPortalSafe:SetMovable(true)
	else
		CloudrestPortalSafe:SetMovable(false)
		CRPS.setVisible(false)
	end
end

function CRPS.setVisible(visible)
	--CloudrestPortalSafeBackdrop:SetHidden(not visible)
	CloudrestPortalSafe:SetHidden(not visible)
end

function CRPS.resetAnchors()
	CloudrestPortalSafe:ClearAnchors()
	CloudrestPortalSafe:SetAnchor(CENTER, GuiRoot, CENTER, CRPS.vars["offsetX"], CRPS.vars["offsetY"])
end

function CRPS.resetParams()
	CRPS.vars.debugEnabled = CRPS.defaults.debugEnabled
	CRPS.vars.alertMyself = CRPS.defaults.alertMyself
	CRPS.vars.showSpearsDone = CRPS.defaults.showSpearsDone
	CRPS.vars.alertDuration = CRPS.defaults.alertDuration
	CRPS.vars.alertFontSize = CRPS.defaults.alertFontSize
	CRPS.vars.alertFontColor = CRPS.defaults.alertFontColor
	CRPS.vars.soundEnabled = CRPS.defaults.soundEnabled
	CRPS.vars.soundId = CRPS.defaults.soundId
	CRPS.vars.soundVolume = CRPS.defaults.soundVolume
	CRPS.vars.offsetX = CRPS.defaults.offsetX
	CRPS.vars.offsetY = CRPS.defaults.offsetY
	CRPS.resetAnchors()
end

function CRPS.setFont(size, color)
	local path = "EsoUI/Common/Fonts/univers67.otf"
	local outline = "soft-shadow-thick"
	CloudrestPortalSafeLabel:SetFont(path .. "|" .. size .. "|" .. outline)
	CloudrestPortalSafeLabel:SetColor(unpack(color))
	CloudrestPortalSafe:SetDimensions(CloudrestPortalSafeLabel:GetTextWidth(), CloudrestPortalSafeLabel:GetTextHeight())
end

function CRPS.savePosition()
     local centerX, centerY = CloudrestPortalSafe:GetCenter()
     CRPS.vars["offsetX"] = centerX
     CRPS.vars["offsetY"] = centerY
end

function CRPS.debug(message)
	if CRPS.vars.debugEnabled == true then CRPS.console(message) end
end

function CRPS.console(message)
	d("|c8F7FFFCR|cFFFFFFPS|cDBDBDB: " .. tostring(message) .. "|r")
end

function CRPS.onAddOnLoaded(event, addonName)
	if addonName ~= CRPS.name then return end

	EVENT_MANAGER:UnregisterForEvent(CRPS.name, EVENT_ADD_ON_LOADED)

	CRPS.playerId = GetCurrentCharacterId()
	CRPS.playerName = GetUnitName("player")

	CRPS.console(string.format(GetString(CRPS_EVENT_ADDONLOADING), tostring(CRPS.playerName)))

	CRPS.vars = ZO_SavedVars:NewAccountWide(CRPS.varsName, CRPS.varsVersion, nil, CRPS.defaults)

	CRPS.initializeSettingsMenu()
	CRPS.setFont(CRPS.vars.alertFontSize, CRPS.vars.alertFontColor)
	CRPS.resetAnchors()

	EVENT_MANAGER:RegisterForEvent(CRPS.name, EVENT_PLAYER_ACTIVATED, CRPS.onZoneChange)
	
	zo_callLater(function() CRPS.console(GetString(CRPS_EVENT_ADDONLOADED)) end, 1)
end

EVENT_MANAGER:RegisterForEvent(CRPS.name, EVENT_ADD_ON_LOADED, CRPS.onAddOnLoaded)