local LCA = LibCombatAlerts
local CA2 = CombatAlerts2

local PT = {
	name = "CA_PurgeTracker",

	registrants = { },
	listening = false,
	visible = false,
	isSmallGroup = false,

	units = { },
}

function PT.OnEffectChanged( _, changeType, _, _, unitTag, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId )
	local threshold = PT.GetThreshold(abilityId)
	if (threshold) then
		if (not PT.units[unitId]) then
			PT.units[unitId] = { count = 0 }
		end
		local unit = PT.units[unitId]

		if (changeType == EFFECT_RESULT_FADED) then
			if (unit[abilityId]) then
				unit.count = unit.count - 1
			end
			unit[abilityId] = nil
		elseif (stackCount >= threshold) then
			if (not unit[abilityId]) then
				unit.count = unit.count + 1
			end
			unit[abilityId] = endTime -- For now, the time is not used for anything aside from serving as a non-nil value
		end

		local color = nil
		if (unit.count >= 1) then
			color = 0xFF000099
			PT.TogglePanel(true)
		end
		CA2.GroupPanelUpdate(unitTag, nil, color)
	end
end

function PT.GetThreshold( abilityId )
	for _, effects in pairs(PT.registrants) do
		if (effects[abilityId]) then
			return effects[abilityId]
		end
	end
	return nil
end

function PT.ToggleListen( )
	if (not PT.listening and next(PT.registrants)) then
		PT.listening = true
		PT.units = { }
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_EFFECT_CHANGED, PT.OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent(PT.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	elseif (PT.listening and not next(PT.registrants)) then
		PT.listening = false
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_EFFECT_CHANGED)
		PT.TogglePanel(false)
	end
end

function PT.TogglePanel( enable )
	if (not PT.visible and enable and (CA2.sv.bypassPurgeSlotCheck or LCA.DoesPlayerHaveAoePurgeSlotted())) then
		PT.visible = true
		CA2.GroupPanelEnable({
			headerText = GetString(SI_CA_PURGEABLE_EFFECTS),
			paneWidth = PT.isSmallGroup and 160 or 128,
			columns = PT.isSmallGroup and 1 or 2,
			statWidth = 0,
			useUnitId = false,
		})
	elseif (PT.visible and not enable) then
		PT.visible = false
		CA2.GroupPanelDisable()
	end
end

function CA2.TogglePurgeTracker( id, effects, isSmallGroup )
	if (type(effects) == "table") then
		PT.registrants[id] = effects
		PT.isSmallGroup = isSmallGroup == true
	else
		PT.registrants[id] = nil
	end
	PT.ToggleListen()
end

function CA2.DisablePurgeTracker( )
	PT.registrants = { }
	PT.ToggleListen()
end
