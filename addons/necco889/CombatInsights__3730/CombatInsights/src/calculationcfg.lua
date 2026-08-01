CombatInsightsCalculationCfg = CombatInsightsCalculationCfg or {}

local function AlwaysTruePredicate()
    return true
end

function CombatInsightsCalculationCfg:New(category, description, icon, predicate, fUptimeExtractor, tfCurrentGain, tfPossibleGain)
    local o = {}
    o.category = category
    o.description = description
    o.icon = icon
    o.predicate = predicate or AlwaysTruePredicate
    o.fUptimeExtractor = fUptimeExtractor
    o.tfCurrentGain = tfCurrentGain
    o.tfPossibleGain = tfPossibleGain
    setmetatable(o, self)
    self.__index = self
    return o
end
