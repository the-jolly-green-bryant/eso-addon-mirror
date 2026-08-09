local BB = BetterBuffs
BB.Analytics = BB.Analytics or {}
local A = BB.Analytics

local function Now() return GetFrameTimeSeconds() end

function A:Initialize()
    self.encounter = nil
    self.lastReport = nil
end

function A:Start()
    if self.encounter then return end
    local now = Now()
    self.encounter = { startTime=now, effects={} }
end

function A:Ensure(key, now)
    if not self.encounter then return nil end
    local item = self.encounter.effects[key]
    if not item then
        item = { active=false, activeSince=nil, activeTotal=0, applications=0, gapSince=now or Now(), longestGap=0,
            coverageIntegral=0, coverageSeconds=0, lastCoverage=0, lowestCoverage=nil, lastSample=now or Now() }
        self.encounter.effects[key] = item
    end
    return item
end

function A:Observe(key, snapshot, now, application)
    if not self.encounter then return end
    now = now or Now()
    local item = self:Ensure(key, now)
    if not item then return end
    local dt = math.max(0, now - (item.lastSample or now))
    if dt > 0 then
        item.coverageIntegral = item.coverageIntegral + (item.lastCoverage or 0) * dt
        item.coverageSeconds = item.coverageSeconds + dt
    end
    item.lastSample = now
    item.lastCoverage = tonumber(snapshot.covered) or 0
    if snapshot.target and snapshot.target > 0 then
        item.lowestCoverage = item.lowestCoverage == nil and item.lastCoverage or math.min(item.lowestCoverage, item.lastCoverage)
    end

    if snapshot.active and not item.active then
        item.active = true
        item.activeSince = now
        if item.gapSince then
            item.longestGap = math.max(item.longestGap or 0, math.max(0, now-item.gapSince))
            item.gapSince = nil
        end
        item.applications = item.applications + 1
    elseif not snapshot.active and item.active then
        item.activeTotal = item.activeTotal + math.max(0, now-(item.activeSince or now))
        item.active = false
        item.activeSince = nil
        item.gapSince = now
    elseif application then
        item.applications = item.applications + 1
    end
end

function A:Finish(reason)
    local enc = self.encounter
    if not enc then return nil end
    local now = Now()
    local duration = math.max(0, now - enc.startTime)
    local report = { duration=duration, reason=reason or "ENDED", effects={} }
    for key,item in pairs(enc.effects) do
        if item.active then item.activeTotal = item.activeTotal + math.max(0, now-(item.activeSince or now)) end
        if item.gapSince then item.longestGap = math.max(item.longestGap or 0, math.max(0, now-item.gapSince)) end
        local dt = math.max(0, now-(item.lastSample or now))
        item.coverageIntegral = item.coverageIntegral + (item.lastCoverage or 0)*dt
        item.coverageSeconds = item.coverageSeconds + dt
        report.effects[key] = {
            uptime = duration > 0 and zo_clamp((item.activeTotal/duration)*100,0,100) or 0,
            applications = item.applications or 0,
            longestGap = item.longestGap or 0,
            averageCoverage = item.coverageSeconds > 0 and (item.coverageIntegral/item.coverageSeconds) or 0,
            lowestCoverage = item.lowestCoverage,
        }
    end
    self.encounter = nil
    self.lastReport = report
    if BB.saved.uptime and BB.saved.uptime.enabled ~= false and duration >= (tonumber(BB.saved.uptime.minimumCombatSeconds) or 5) then
        self:Print(report)
    end
    return report
end

function A:Print(report)
    d(string.format("|cFFD447Better Buffs Encounter|r |cFFFFFF%.1fs|r", report.duration or 0))
    for _,definition in ipairs(BB.Registry.definitions) do
        local row = report.effects[definition.key]
        if row and BB:IsEffectEnabled(definition.key) and (row.applications > 0 or row.uptime > 0) then
            local text = string.format("|cD9D9D9%s|r  |cFFFFFF%.0f%%|r  x%d  gap %.1fs", definition.name, row.uptime, row.applications, row.longestGap)
            if definition.coverage and BB.saved.uptime.showAdvanced ~= false then
                text = text .. string.format("  avg %.1f  low %s", row.averageCoverage or 0, row.lowestCoverage == nil and "-" or tostring(row.lowestCoverage))
            end
            d(text)
        end
    end
end

function A:GetLastReport() return self.lastReport end
