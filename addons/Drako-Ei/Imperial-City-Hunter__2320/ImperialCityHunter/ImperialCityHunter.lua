-- NAMESPACE
ImperialCityHunter = {}

-- PROPERTIES
ImperialCityHunter.name = "ImperialCityHunter"
ImperialCityHunter.isEnabled = false
ImperialCityHunter.loopID = "ImperialCityHunter_LoopID_2380321"
ImperialCityHunter.loopInverval = 5000
ImperialCityHunter.bossRespawnTime = 900000
ImperialCityHunter.bosses = {
	['Glorgoloch the Destroyer'] = {
		['location'] = 'Arena District',
	},
	['King Khrogo'] = {
		['location'] = 'Arena District',
	},
	['Lady Malygda'] = {
		['location'] = 'Arboretum District',
	},
	['Ysenda Resplendent'] = {
		['location'] = 'Arboretum District',
	},
	['Zoal the Ever-Wakeful'] = {
		['location'] = 'Elven Gardens District',
	},
	['The Screeching Matron'] = {
		['location'] = 'Elven Gardens District',
	},
	['Volghass'] = {
		['location'] = 'Memorial District',
	},
	['Nunatak'] = {
		['location'] = 'Memorial District',
	},
	['Baron Thirsk'] = {
		['location'] = 'Nobles District',
	},
	['Amoncrul'] = {
		['location'] = 'Nobles District',
	},
	['Immolator Charr'] = {
		['location'] = 'Temple District',
	},
	['Mazaluhad'] = {
		['location'] = 'Temple District',
	}
}
ImperialCityHunter.districts = {
	['Arena District'] = nil,
	['Arboretum District'] = nil,
	['Elven Gardens District'] = nil,
	['Memorial District'] = nil,
	['Nobles District'] = nil,
	['Temple District'] = nil,
}

-- ENTRY POINT
function ImperialCityHunter.OnAddOnLoaded(event, addonName)
	if addonName == ImperialCityHunter.name then
		ImperialCityHunter:Initialize()
	end
end

function ImperialCityHunter:Initialize()
	-- SAVED VARIABLES
	ImperialCityHunter.savedVariables = ZO_SavedVars:New("ImperialCityHunterSavedVariables", 1, nil, {})

	-- CREATE GUI
	ImperialCityHunter:createGUI()
	if (ImperialCityHunter.savedVariables.left ~= nil) then
		ImperialCityHunter:restoreWinPos()
	end

	-- ACTIVATE IF PLAYER IS INSIDE IMPERIAL CITY
	ImperialCityHunter.onSpawnEvent(0, false)

	-- REGISTER EVENTS
	EVENT_MANAGER:RegisterForEvent(ImperialCityHunter.name, EVENT_PLAYER_ACTIVATED, ImperialCityHunter.onSpawnEvent)
end

-- FUNCTIONS

function ImperialCityHunter:getMilliseconds()
	return GetFrameTimeMilliseconds()
end

function ImperialCityHunter:isImperialCityBoss(name)
	return ImperialCityHunter.bosses[name] ~= nil
end

function ImperialCityHunter:registerBossCorpse(name)
	local district = ImperialCityHunter.bosses[name]['location']
	ImperialCityHunter:setDistrictRespawnTime(district, ImperialCityHunter.bossRespawnTime)
	ImperialCityHunter.districts[district] = ImperialCityHunter:getMilliseconds()
end

function ImperialCityHunter:unregisterBossCorpse(name)
	local district = ImperialCityHunter.bosses[name]['location']
	if (district ~= nil) then
		ImperialCityHunter:enableDistrictIcon(district)
		ImperialCityHunter.districts[district] = nil
	end
end

function ImperialCityHunter:corpseIsRegistered(name)
	local district = ImperialCityHunter.bosses[name]['location']
	return ImperialCityHunter.districts[district] ~= nil
end

function ImperialCityHunter:calculateRespawnMilliseconds(lastTime, currentTime)
	return ImperialCityHunter.bossRespawnTime + lastTime - currentTime
end

function ImperialCityHunter:setEnabled(enabled)
	if (ImperialCityHunter.isEnabled ~= enabled) then
		ImperialCityHunter.districts = {
			['Arena District'] = nil,
			['Arboretum District'] = nil,
			['Elven Gardens District'] = nil,
			['Memorial District'] = nil,
			['Nobles District'] = nil,
			['Temple District'] = nil,
		}
		ImperialCityHunter.isEnabled = enabled
		ImperialCityHunter:resetIcons()
		if (enabled) then
			-- START LOOP
			EVENT_MANAGER:RegisterForUpdate(ImperialCityHunter.loopID, ImperialCityHunter.loopInverval, ImperialCityHunter.updateLoop)
			-- REGISTER EVENTS
			EVENT_MANAGER:RegisterForEvent(ImperialCityHunter.name, EVENT_RETICLE_TARGET_CHANGED, ImperialCityHunter.onReticleEvent)
			EVENT_MANAGER:RegisterForEvent(ImperialCityHunter.name, EVENT_UNIT_DEATH_STATE_CHANGED, ImperialCityHunter.onDeathEvent)
			-- SHOW GUI
			ImperialCityHunterWIN:SetHidden(false)
		else
			-- STOP LOOP
			EVENT_MANAGER:UnregisterForUpdate(ImperialCityHunter.loopID)
			-- UNREGISTER EVENTS
			EVENT_MANAGER:UnregisterForEvent(ImperialCityHunter.name, EVENT_RETICLE_TARGET_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(ImperialCityHunter.name, EVENT_UNIT_DEATH_STATE_CHANGED)
			-- HIDE GUI
			ImperialCityHunterWIN:SetHidden(true)
		end
	end
end
-- LOOP

function ImperialCityHunter.updateLoop()
	local currentTime = ImperialCityHunter:getMilliseconds()
	for k, v in pairs(ImperialCityHunter.districts) do
		local respawnMilliseconds = ImperialCityHunter:calculateRespawnMilliseconds(v, currentTime);
		if (respawnMilliseconds < 0) then
			ImperialCityHunter:enableDistrictIcon(k)
			ImperialCityHunter.districts[k] = nil
		else
			ImperialCityHunter:setDistrictRespawnTime(k, respawnMilliseconds)
		end
	end
end

-- EVENTS

function ImperialCityHunter.onReticleEvent(e)
	local unitName = GetUnitNameHighlightedByReticle()
	if (unitName ~= nil or unitName ~= '') then
		if (ImperialCityHunter:isImperialCityBoss(unitName)) then
			if (IsUnitDead('reticleover')) then
				if (not ImperialCityHunter:corpseIsRegistered(unitName)) then
					ImperialCityHunter:registerBossCorpse(unitName)
				end
			else
				ImperialCityHunter:unregisterBossCorpse(unitName)
			end
		end
	end
end

function ImperialCityHunter.onDeathEvent(e, unitTag, isDead)
	local unitName = GetUnitName(unitTag)
	if (unitName ~= nil or unitName ~= '') then
		if (isDead and ImperialCityHunter:isImperialCityBoss(unitName)) then
			ImperialCityHunter:registerBossCorpse(unitName)
		end
	end
end

function ImperialCityHunter.onSpawnEvent(e, initial)
	local zone = GetUnitZone('player')
	ImperialCityHunter:setEnabled((zone == 'Imperial Sewers' or zone == 'Imperial City'))
end

-- CALL ENTRY POINT
EVENT_MANAGER:RegisterForEvent(ImperialCityHunter.name, EVENT_ADD_ON_LOADED, ImperialCityHunter.OnAddOnLoaded)