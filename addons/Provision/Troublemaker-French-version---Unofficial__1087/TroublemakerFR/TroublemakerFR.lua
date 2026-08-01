TROUBLEMAKERFR = {}
TROUBLEMAKERFR.version = 0.33

ZO_CreateStringId("SI_BINDING_NAME_TROUBLEMAKERFR", "TroublemakerFR")

function ternary(cond, T, F)
    if cond then return T else return F end
end

local function TroublemakerFR()
	local before = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, 1 - before)
	
	d("Emp\195\170cher d'attaquer des innocents : "..ternary(tonumber(before) == 1, "|cF03000D\195\169sa", "|cE0F0F0A").."ctiv\195\169|r")
end

SLASH_COMMANDS["/trouble"] = TroublemakerFR