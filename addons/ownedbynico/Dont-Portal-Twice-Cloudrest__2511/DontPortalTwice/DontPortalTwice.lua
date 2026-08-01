DPT = DPT or {}
DPT.name = "DontPortalTwice"
DPT.version = "1.3"

DPT.portalSynergy = "collectible_memento_pearlsummon"
DPT.portalDebuff = 104542 --Hollowing Torment
DPT.cursed = false

DPT.creeperDebuff = 106656 --Razerthorn

DPT.group = {}
DPT.tanksInPortal = 0

DPT.bypass = false

function DPT.onZoneChange(_, _)

	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if zone == 1051 then
		-- portal debuff, creeper root, index group
		EVENT_MANAGER:RegisterForEvent(DPT.name, EVENT_EFFECT_CHANGED, DPT.onEffectChanged)
		
		-- tank enter/exit portal
		EVENT_MANAGER:RegisterForEvent(DPT.name, EVENT_COMBAT_EVENT, DPT.onCombatEvent)
		
		-- remove debuff and tank exit portal
		EVENT_MANAGER:RegisterForEvent(DPT.name, EVENT_UNIT_DEATH_STATE_CHANGED, DPT.onUnitDeath)
		
		-- renew synergy
		EVENT_MANAGER:RegisterForEvent(DPT.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, DPT.onWeaponSwap)
		
		DPT.group = {}
		DPT.tanksInPortal = 0
		
		DPT.debugd("Enabled")
	else
		EVENT_MANAGER:UnregisterForEvent(DPT.name, EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForEvent(DPT.name, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(DPT.name, EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(DPT.name, EVENT_UNIT_DEATH_STATE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(DPT.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
		DPT.debugd("Disabled")
	end
end

function DPT.portalFallback()
	DPT.bypass = true
	-- refresh synergy if player stands right on top of portal
	SYNERGY:OnSynergyAbilityChanged()
	DPT.debugd("Bypassing synergy block for 5s. (if you are not cursed)")
	
	zo_callLater(function()
		-- reset fallback hotkey
		DPT.bypass = false
		DPT.debugd("Not longer bypassing synergy block.")
	end, 5000)
end

function DPT.onWeaponSwap(_, didChange, _, _)
	if didChange == true then
		SYNERGY:OnSynergyAbilityChanged()
	end
end

function DPT.onUnitDeath(_, unitTag, isDead)
	
	if IsUnitPlayer(unitTag) ~= true then return end
	if isDead ~= true then return end
	
	--DPT.debugd("DEAD! " .. GetUnitName(unitTag) .. "::" .. GetGroupMemberSelectedRole(unitTag))
	
	for id in pairs(DPT.group) do
		if DPT.group[id].name == GetUnitName(unitTag) then
			if DPT.group[id].role == LFG_ROLE_TANK and DPT.group[id].portal == true then
				DPT.tanksInPortal = DPT.tanksInPortal - 1
				DPT.debugd("Tank " .. DPT.group[id].name .. " left portal.")
				DPT.debugd("There is/are " .. DPT.tanksInPortal .. " Tank(s) in Portal.")
			end
			DPT.group[id].portal = false
		end
	end

	if AreUnitsEqual(unitTag, "player") == true then
		DPT.cursed = false
		DPT.debugd("Removed debuff (if you had one) because you died.")
	end
end

function DPT.onCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceType, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)

	if abilityId == 108045 then
		if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
			-- Portal enter
			DPT.group[targetUnitId].portal = true
			if DPT.group[targetUnitId].role == LFG_ROLE_TANK then
				DPT.tanksInPortal = DPT.tanksInPortal + 1
				DPT.debugd("Tank " .. DPT.group[targetUnitId].name .. " entered the portal.")
				DPT.debugd("There is/are " .. DPT.tanksInPortal .. " Tank(s) in Portal.")
			else
				--DPT.debugd("Player " .. DPT.group[targetUnitId].name .. " entered the portal.")
			end
		elseif result == ACTION_RESULT_EFFECT_FADED then
			-- Portal exit
			DPT.group[targetUnitId].portal = false
			if DPT.group[targetUnitId].role == LFG_ROLE_TANK then
				DPT.tanksInPortal = DPT.tanksInPortal - 1
				DPT.debugd("Tank " .. DPT.group[targetUnitId].name .. " left the portal.")
				DPT.debugd("There is/are " .. DPT.tanksInPortal .. " Tank(s) in Portal.")
			else
				--DPT.debugd("Player " .. DPT.group[targetUnitId].name .. " left the portal.")
			end
		end
	end
end

function DPT.onEffectChanged(_, _, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, _, unitId, abilityId, sourceType)
	
	if IsUnitPlayer(unitTag) ~= true then return end
	
	if abilityId == DPT.portalDebuff and unitTag == "player" then
		local cooldown = endTime - beginTime
		if cooldown > 0 then
			DPT.cursed = true
			DPT.debugd("You are now cursed!")
			
			zo_callLater(function()
				DPT.cursed = false
				DPT.debugd("You are no longer cursed.")
			end, cooldown * 1000)
		end
	end
	
	if abilityId == DPT.creeperDebuff and DPT.savedVariables.showCreeperRoot == true and unitTag == "player" then
		if beginTime > 0 then
			PurpleBorder:SetHidden(false)
			DPT.debugd("You are rooted. Dodge!")
		else
			PurpleBorder:SetHidden(true)
			DPT.debugd("You are not longer rooted by a creeper.")
		end
	end
	
	if unitId == nil or unitId == 0 then return end
	if DPT.group[unitId] ~= nil then return end
	
	DPT.group[unitId] = {}
	DPT.group[unitId].name = GetUnitName(unitTag)
	DPT.group[unitId].tag = unitTag
	DPT.group[unitId].role = GetGroupMemberSelectedRole(unitTag)
	DPT.group[unitId].portal = false
end

function DPT.isZMajaFight()
	if DoesUnitExist("boss1") and GetUnitName("boss1"):find("Z'Maja") ~= nil then
		return true
	end
	return false
end

function DPT.overridePortalSynergy()
	ZO_PreHook(SYNERGY, 'OnSynergyAbilityChanged',
	function(self)
		local name, icon = GetSynergyInfo()
		if name and icon:find(DPT.portalSynergy) and DPT.isZMajaFight() == true and (DPT.cursed == true or DPT.savedVariables.blockPortal == true or (DPT.savedVariables.waitForTank == true and DPT.tanksInPortal <= 0 and GetSelectedLFGRole() ~= LFG_ROLE_TANK)) then
			-- bypass block
			if DPT.bypass == true and DPT.cursed == false then return false end
			SYNERGY:SetHidden(true)
			DPT.debugd("Blocked portal synergy!")
			return true
		end
	end)
end

function DPT.debugd(message)
	if DPT.savedVariables.debugd == true then
		d("|cFFFFFFD|cDC143CP|cFFFFFFT|cDBDBDB: " .. tostring(message) .. "|r")
	end
end

function DPT.onAddOnLoaded(event, addonName)
	if addonName ~= DPT.name then return end
	
	DPT.initializeSettingsMenu()
	DPT.overridePortalSynergy()
	ZO_CreateStringId("SI_BINDING_NAME_DPT_PORTALFALLBACK", "Bypass Synergy Block")
	EVENT_MANAGER:RegisterForEvent(DPT.name, EVENT_PLAYER_ACTIVATED, DPT.onZoneChange)
	
	zo_callLater(function()
		DPT.debugd("Addon loaded.")
	end, 1)
end


EVENT_MANAGER:RegisterForEvent(DPT.name, EVENT_ADD_ON_LOADED, DPT.onAddOnLoaded)