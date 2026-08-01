local AST = AsylumTracker
local EM = EVENT_MANAGER
local ASYLUM_SANCTORIUM = 1000

AST.unitIds = {}
--[[
	Because combat events do not return unitNames when you are in a group, we have to use unitIDs.
	The problem is unitIds are not stable and there is no API function to convert a unitID to a unitName.
	OnEffectChanged is an exception to this and returns both unitNames and unitIds; therefore, we can use this function to build a table of unitIds to unitNames.
]]
local function OnEffectChanged(_, _, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId)
     if GetZoneNameById(ASYLUM_SANCTORIUM) == GetUnitZone("player") then
          unitName = zo_strformat("<<1>>", unitName)
          AST.unitIds[unitId] = unitName
          AST.dbgunits(unitName .. " [" .. unitId .. "] has been added to unitIds")
     end
end
-- Returns the unitName for a given player's unitId if it is in the table, otherwise returns an empty string
function AST.GetNameForUnitId(unitId)
     return AST.unitIds[unitId] or ""
end

function AST.RegisterUnitIndexing()
     EM:RegisterForEvent(AST.name .. "_Units_Effect_Changed", EVENT_EFFECT_CHANGED, OnEffectChanged)
end
