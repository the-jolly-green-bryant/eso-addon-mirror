local BB = BetterBuffs
BB.API = BB.API or {}
local API = BB.API

function API:Initialize()
    self.callbacks = self.callbacks or {}
end

function API:GetEffectState(key)
    return BB.Runtime and BB.Runtime:GetSnapshot(key, GetFrameTimeSeconds()) or nil
end

function API:GetTargetEffectState(key, targetKey)
    local targets = BB.Runtime and BB.Runtime.active and BB.Runtime.active[key]
    return targets and targets[targetKey] or nil
end

function API:GetGroupCoverage(key)
    local state = self:GetEffectState(key)
    if not state then return 0,0 end
    return state.covered or 0, state.target or 0
end

function API:GetEncounterUptime(key)
    local report = BB.Analytics and BB.Analytics:GetLastReport()
    return report and report.effects and report.effects[key] or nil
end

function API:RegisterCallback(eventName, callback)
    if type(callback) ~= "function" then return end
    self.callbacks[eventName] = self.callbacks[eventName] or {}
    table.insert(self.callbacks[eventName], callback)
end

function API:Fire(eventName, ...)
    for _,callback in ipairs(self.callbacks[eventName] or {}) do pcall(callback, ...) end
end
