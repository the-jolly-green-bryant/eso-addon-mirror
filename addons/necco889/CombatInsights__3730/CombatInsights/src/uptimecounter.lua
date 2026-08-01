CombatInsightsUptimeCounter = {}
local UptimeCounter = CombatInsightsUptimeCounter

function UptimeCounter:New()
    local o = {}
    o.entries = {}
    o.targetIds = {}
    o.abilityIds = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function UptimeCounter:Get(targetIds, abilityIds)
    targetIds = targetIds or self.targetIds
    abilityIds = abilityIds or self.abilityIds
    local numActive = 0
    local numInactive = 0
    for t,_ in pairs(targetIds) do
        for a,_ in pairs(abilityIds) do
            local t2 = self.entries[t]
            if t2 then
                local e = t2[a]
                if e then
                    numActive = numActive + e.numActive
                    numInactive = numInactive + e.numInactive
                end
            end
        end
    end
    return numActive / (numActive + numInactive) * 100
end

function UptimeCounter:NewSample(value, targetId, abilityId)
    self.targetIds[targetId] = true
    self.abilityIds[abilityId] = true
    local t2 = self.entries[targetId]
    if not t2 then
        t2 = {}
        self.entries[targetId] = t2
    end

    local e = t2[abilityId]
    if not e then
        e = {numActive = 0, numInactive = 0}
        t2[abilityId] = e
    end

    if value then
        e.numActive = e.numActive + 1
    else
        e.numInactive = e.numInactive + 1
    end
end
