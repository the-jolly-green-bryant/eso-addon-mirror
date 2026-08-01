CombatInsightsFightData = {
    name = 'CombatInsightsFightData',
    variableVersion = 1,
	addonVersion = 10200,
	defaults = {
		fights = {}
	}
}
local self = CombatInsightsFightData

local function OnAddOnLoaded(event, addOnName)
    if addOnName ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED);
    self.SV = ZO_SavedVars:NewAccountWide("CombatInsightsFightDataSV", self.variableVersion, nil, self.defaults)
end

EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
