local AST = AsylumTracker
local EM = EVENT_MANAGER

AST.unitIds = {}

-- Combat events provide unit IDs for source and target, but names for group members are
-- empty strings. There is no direct API to convert a unit ID to a name, but
-- EVENT_EFFECT_CHANGED is an exception: it returns both unitName and unitId together.
-- We use it to build a live id → name cache that OnCombatEvent can look up in O(1).
local function OnEffectChanged(_, _, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId)
     unitName = zo_strformat("<<1>>", unitName)
     AST.unitIds[unitId] = unitName
     AST.dbgunits(unitName .. " [" .. unitId .. "] has been added to unitIds")
end

-- Returns the name for a unit ID, or an empty string if not yet seen.
function AST.GetNameForUnitId(unitId)
     return AST.unitIds[unitId] or ""
end

function AST.RegisterUnitIndexing()
     EM:RegisterForEvent(AST.name .. "_Units_Effect_Changed", EVENT_EFFECT_CHANGED, OnEffectChanged)
end

function AST.UnregisterUnitIndexing()
     EM:UnregisterForEvent(AST.name .. "_Units_Effect_Changed", EVENT_EFFECT_CHANGED)
end
