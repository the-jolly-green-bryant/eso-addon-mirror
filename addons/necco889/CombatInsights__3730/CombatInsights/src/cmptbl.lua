CombatInsightsCompareTable = {}
local CompareTable = CombatInsightsCompareTable
local Consts = CombatInsightsConsts

function CompareTable:New(config)
    local o = {}
    o.config = config
    o.description = config and config.description or "???"
    o.entries = {}
    o.targetIds = {}
    o.abilityIds = {}
    o.ignoredAbilities = { }
    -- o.errors = {}
    if Consts.DEBUG_MODE then
        o.hits = {}
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

function CompareTable:Hit(oldHit, newHit, targetId, abilityId)
    --FIXME remove
    -- if not targetId then targetId = 99999999 end
    -- if not abilityId then abilityId = 99999999 end

    self.targetIds[targetId] = true
    self.abilityIds[abilityId] = true
    local t2 = self.entries[targetId]
    if not t2 then
        t2 = {}
        self.entries[targetId] = t2
    end
    local e = t2[abilityId]
    if not e then
        e =
        {
            origNormal = 0,
            origCrit = 0,
            origTotal = 0,
            origTotalIgnored = 0,        --some abilities can be ignored during the calculations (eg lack of data about cps)
            newNormal = 0,
            newCrit = 0,
            newTotal = 0,
            numActive = 0,
            numInactive = 0,
        }
        t2[abilityId] = e
    end




    if Consts.DEBUG_MODE then
        table.insert(self.hits,{oldHit, newHit})
    end
    if not newHit.error then
        if oldHit.isCrit then
            e.origCrit = e.origCrit + oldHit.value
            e.origTotal = e.origTotal + oldHit.value
            e.newCrit = e.newCrit + newHit.value
            e.newTotal = e.newTotal + newHit.value
        else
            e.origNormal = e.origNormal + oldHit.value
            e.origTotal = e.origTotal + oldHit.value
            e.newNormal = e.newNormal + newHit.value
            e.newTotal = e.newTotal + newHit.value
        end
    else
        -- self.errors[newHit.error] = true
        self.ignoredAbilities[abilityId] = true
        e.origTotal = e.origTotal + oldHit.value
        if oldHit.isCrit then
            e.origCrit = e.origCrit + oldHit.value
        else
            e.origNormal = e.origNormal + oldHit.value
        end
        e.origTotalIgnored = e.origTotalIgnored + oldHit.value
    end
end

function CompareTable:Summarize(targetIds, abilityIds)
    targetIds = targetIds or self.targetIds
    abilityIds = abilityIds or self.abilityIds
    local sum =
    {
        origNormal = 0,
        origCrit = 0,
        origTotal = 0,
        origTotalIgnored = 0,
        newNormal = 0,
        newCrit = 0,
        newTotal = 0,
        numActive = 0,
        numInactive = 0,
    }
    for t,_ in pairs(targetIds) do
        for a,_ in pairs(abilityIds) do
            local t2 = self.entries[t]
            if t2 then
                local e = t2[a]
                if e then
                    sum.origNormal = sum.origNormal + e.origNormal
                    sum.origCrit = sum.origCrit + e.origCrit
                    sum.origTotal = sum.origTotal + e.origTotal
                    sum.origTotalIgnored = sum.origTotalIgnored + e.origTotalIgnored
                    sum.newNormal = sum.newNormal + e.newNormal
                    sum.newCrit = sum.newCrit + e.newCrit
                    sum.newTotal = sum.newTotal + e.newTotal
                    sum.numActive = sum.numActive + e.numActive
                    sum.numInactive = sum.numInactive + e.numInactive
                    
                end
            end
        end
    end


    local gainOnNew = 0
    local gainedOnOrig = 0
    local ignored = 0
    gainOnNew = sum.newTotal / (sum.origTotal - sum.origTotalIgnored) * 100 - 100
    gainedOnOrig = (sum.origTotal - sum.origTotalIgnored) / sum.newTotal * 100 - 100
    ignored = sum.origTotalIgnored / sum.origTotal * 100
    return ignored, gainedOnOrig, gainOnNew
end
