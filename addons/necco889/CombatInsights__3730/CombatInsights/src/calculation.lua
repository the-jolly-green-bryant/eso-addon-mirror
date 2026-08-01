CombatInsightsCalculation = CombatInsightsCalculation or {}

function CombatInsightsCalculation:New(config)
    local o = {}
    o.config = config
    if config.fUptimeExtractor then
        o.uptimeCounter = CombatInsightsUptimeCounter:New()
    end
    if config.tfCurrentGain then
        o.cmpForCurrentGain = CombatInsightsCompareTable:New(nil)
    end
    if config.tfPossibleGain then
        o.cmpForPossibleGain = CombatInsightsCompareTable:New(nil)
    end
    setmetatable(o, self)
    self.__index = self
    return o
end
