local BA = BMGAdventures
BA.Diagnostics = BA.Diagnostics or {}

function BA.Diagnostics:Initialize()
    self.events = {}
    self.metrics = {
        normalizedEvents = 0,
        challengeCandidates = 0,
        challengeEvaluations = 0,
        maxCandidates = 0,
        transactions = 0,
        duplicateCompletionsBlocked = 0,
        unlocksGranted = 0,
        errors = 0,
    }
end

function BA.Diagnostics:Record(kind, detail)
    if not self.events then return end
    local row = { t = GetTimeStamp and GetTimeStamp() or 0, kind = kind, detail = detail }
    table.insert(self.events, row)
    while #self.events > BA.Constants.MAX_DIAGNOSTIC_EVENTS do
        table.remove(self.events, 1)
    end
end

function BA.Diagnostics:Count(key, amount)
    amount = amount or 1
    self.metrics[key] = (self.metrics[key] or 0) + amount
end

function BA.Diagnostics:GetAverageCandidates()
    local e = self.metrics.normalizedEvents or 0
    if e == 0 then return 0 end
    return (self.metrics.challengeCandidates or 0) / e
end

function BA.Diagnostics:ResetRuntimeMetrics()
    local errors = self.metrics.errors or 0
    self:Initialize()
    self.metrics.errors = errors
end
