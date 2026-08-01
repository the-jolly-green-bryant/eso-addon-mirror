local GST = GroupSynergyTracker
local EM = EVENT_MANAGER

GST.unitIds = {}

local function OnEffectChanged(_, _, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId)
	unitName = zo_strformat("<<1>>", unitName)
	if unitName ~= "Offline" then
		if GST.unitIds[unitId] ~= unitName and GST.sv.debug.unitIndexing then
			GST.unitIds[unitId] = unitName
			d("Registering " .. unitName .. " as " .. unitId)
		else
			GST.unitIds[unitId] = unitName
		end
	end
end

function GST.GetNameForUnitId(unitId)
	return GST.unitIds[unitId] or ""
end

function GST.RegisterUnitIndexing()
	EM:RegisterForEvent(GST.name .. "_Units_Effect_Changed", EVENT_EFFECT_CHANGED, OnEffectChanged)
end
