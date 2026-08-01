local wtb = WTBConduits
local EM = EVENT_MANAGER

wtb.unitIds = {}

local function OnEffectChanged(_, _, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId)
	unitName = zo_strformat("<<1>>", unitName)
	if unitName ~= "Offline" then
		if wtb.unitIds[unitId] ~= unitName then
			wtb.unitIds[unitId] = unitName
		end
	end
end

function wtb.GetNameForUnitId(unitId)
	return wtb.unitIds[unitId] or ""
end

function wtb.RegisterUnitIndexing()
	EM:RegisterForEvent(wtb.name .. "_Units_Effect_Changed", EVENT_EFFECT_CHANGED, OnEffectChanged)
end
