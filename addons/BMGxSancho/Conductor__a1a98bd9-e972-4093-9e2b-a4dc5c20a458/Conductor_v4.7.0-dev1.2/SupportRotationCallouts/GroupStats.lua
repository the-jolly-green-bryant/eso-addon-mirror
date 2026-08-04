local SRC = SupportRotationCallouts
SRC.GroupStats = SRC.GroupStats or {}
local G = SRC.GroupStats

G.READY = "READY"
G.NOT_READY = "NOT_READY"
G.UNKNOWN = "UNKNOWN"
G.UNAVAILABLE = "UNAVAILABLE"
G.STALE_MS = 7000
G.SPEND_MIN_DROP = 10
G.SPEND_DROP_RATIO = 0.05
G.SPEND_REARM_MS = 1000

local function Snapshot(data)
    if not data then return nil end
    return {
        ultValue = tonumber(data.ultValue) or 0,
        ult1ID = tonumber(data.ult1ID) or 0,
        ult1Cost = tonumber(data.ult1Cost) or 0,
        ult2ID = tonumber(data.ult2ID) or 0,
        ult2Cost = tonumber(data.ult2Cost) or 0,
        lastUpdated = tonumber(data._lastUpdated) or GetGameTimeMilliseconds(),
    }
end

local function IsFresh(data)
    return data
        and data._lastUpdated
        and GetGameTimeMilliseconds() - data._lastUpdated <= G.STALE_MS
end

function G:GetDefinitions()
    return {
        COLOSSUS = {
            ids = SRC.Colossus and SRC.Colossus.ABILITY_IDS,
            rotation = SRC.ColossusRotation,
        },
        WARHORN = {
            ids = SRC.Warhorn and SRC.Warhorn.ABILITY_IDS,
            rotation = SRC.WarhornRotation,
        },
        BARRIER = {
            ids = SRC.Barrier and SRC.Barrier.ABILITY_IDS,
            rotation = SRC.BarrierRotation,
        },
    }
end

function G:Initialize()
    self.client = nil
    self.cache = {}
    self.snapshots = {}
    self.spendTrackers = {}

    if not LibGroupCombatStats then
        SRC.Diagnostics:Add("GROUP_STATS", "LibGroupCombatStats unavailable")
        return
    end

    self.client = LibGroupCombatStats.RegisterAddon(SRC.name, { "ULT" })
    if not self.client then
        SRC.Diagnostics:Add("GROUP_STATS", "LibGroupCombatStats registration failed")
        return
    end

    self.client:RegisterForEvent(
        LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE,
        function(unitTag, data)
            self:OnUltimateUpdate(unitTag, data)
        end
    )

    self.client:RegisterForEvent(
        LibGroupCombatStats.EVENT_PLAYER_ULT_UPDATE,
        function(unitTag, data)
            self:OnUltimateUpdate(unitTag, data)
        end
    )

    SRC.Diagnostics:Add("GROUP_STATS", "LibGroupCombatStats registered")
end

function G:GetTrackedSlot(snapshot, ids)
    if not snapshot or not ids then return nil end

    local slots = {
        { id = snapshot.ult1ID, cost = snapshot.ult1Cost, bar = 1 },
        { id = snapshot.ult2ID, cost = snapshot.ult2Cost, bar = 2 },
    }

    local selected = nil
    for _, slot in ipairs(slots) do
        if ids[slot.id] and slot.cost > 0 then
            if not selected or slot.cost < selected.cost then
                selected = slot
            end
        end
    end

    return selected
end

function G:GetSpendTracker(account, key)
    self.spendTrackers[account] = self.spendTrackers[account] or {}
    self.spendTrackers[account][key] = self.spendTrackers[account][key] or {}
    return self.spendTrackers[account][key]
end

function G:DetectSpend(account, key, current, definition)
    if not current or not definition or not definition.ids then return nil end

    local slot = self:GetTrackedSlot(current, definition.ids)
    local tracker = self:GetSpendTracker(account, key)
    local nowMs = GetGameTimeMilliseconds()

    if not slot then
        tracker.abilityId = nil
        tracker.cost = nil
        tracker.peakValue = nil
        tracker.lastValue = current.ultValue
        tracker.emitted = false
        tracker.emittedAtMs = nil
        return nil
    end

    if tracker.abilityId ~= slot.id or tracker.cost ~= slot.cost then
        tracker.abilityId = slot.id
        tracker.cost = slot.cost
        tracker.peakValue = current.ultValue
        tracker.lastValue = current.ultValue
        tracker.emitted = false
        tracker.emittedAtMs = nil
        return nil
    end

    if tracker.emitted then
        local rearmByTime = current.ultValue >= slot.cost
            and tracker.emittedAtMs
            and nowMs - tracker.emittedAtMs >= self.SPEND_REARM_MS
        local rearmByGain = tracker.lastValue and current.ultValue > tracker.lastValue

        if rearmByTime or rearmByGain then
            tracker.emitted = false
            tracker.peakValue = current.ultValue
            tracker.emittedAtMs = nil
        end
    end

    if not tracker.peakValue or current.ultValue > tracker.peakValue then
        tracker.peakValue = current.ultValue
    end

    local threshold = zo_max(self.SPEND_MIN_DROP, slot.cost * self.SPEND_DROP_RATIO)
    local decline = (tracker.peakValue or current.ultValue) - current.ultValue
    local wasCastable = (tracker.peakValue or 0) >= slot.cost

    tracker.lastValue = current.ultValue

    if tracker.emitted or not wasCastable or decline < threshold then
        return nil
    end

    tracker.emitted = true
    tracker.emittedAtMs = nowMs

    return {
        abilityId = slot.id,
        abilityCost = slot.cost,
        bar = slot.bar,
        observedSpend = decline,
        previousUlt = tracker.peakValue,
        currentUlt = current.ultValue,
    }
end

function G:OnUltimateUpdate(unitTag, data)
    if not unitTag or not data then return end

    local displayName = GetUnitDisplayName(unitTag)
    if not displayName or displayName == "" then return end

    local account = SRC:NormalizeAccountName(displayName)
    local current = Snapshot(data)
    self.cache[account] = data
    self.snapshots[account] = current

    SRC.Diagnostics:AddFields("ULT", "Raw ultimate callback", {
        account = account,
        unitTag = unitTag,
        ultValue = current.ultValue,
        ult1ID = current.ult1ID,
        ult1Cost = current.ult1Cost,
        ult2ID = current.ult2ID,
        ult2Cost = current.ult2Cost,
        lastUpdated = current.lastUpdated,
    })

    if SRC.saved and SRC.saved.enabled then
        for key, definition in pairs(self:GetDefinitions()) do
            local spend = self:DetectSpend(account, key, current, definition)
            if spend and definition.rotation and definition.rotation.OnUltimateSpendCandidate then
                SRC.Diagnostics:AddFields("ULT_SPEND", "Ultimate spend candidate", {
                    module = key,
                    account = account,
                    abilityId = spend.abilityId,
                    abilityCost = spend.abilityCost,
                    observedSpend = spend.observedSpend,
                    previousUlt = spend.previousUlt,
                    currentUlt = spend.currentUlt,
                })

                definition.rotation:OnUltimateSpendCandidate({
                    accountName = account,
                    sourceName = GetUnitName(unitTag),
                    sourceIdentity = account,
                    unitTag = unitTag,
                    abilityId = spend.abilityId,
                    abilityCost = spend.abilityCost,
                    observedSpend = spend.observedSpend,
                    fromUltimateSpend = true,
                })
            end
        end
    end

    for _, definition in pairs(self:GetDefinitions()) do
        if definition.rotation and definition.rotation.OnReadinessUpdated then
            definition.rotation:OnReadinessUpdated(account)
        end
    end
end

function G:GetUnitData(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then return nil end

    if self.client and self.client.GetUnitULT then
        local data = self.client:GetUnitULT(unitTag)
        if data then return data end
    end

    local cache = self.cache or {}
    return cache[SRC:NormalizeAccountName(GetUnitDisplayName(unitTag))]
end

function G:GetReadinessInfoFor(key, account)
    local info = {
        account = account,
        state = self.UNKNOWN,
        value = nil,
        cost = nil,
        percent = nil,
        abilityId = nil,
        unitTag = nil,
    }

    local definition = self:GetDefinitions()[key]
    if not definition or not definition.ids then return info end

    local unitTag = SRC.Roster:GetUnitTagFromAccount(account)
    info.unitTag = unitTag

    if not unitTag or not DoesUnitExist(unitTag) or IsUnitDead(unitTag) then
        info.state = self.UNAVAILABLE
        return info
    end

    local data = self:GetUnitData(unitTag)
    if not data then return info end

    info.value = tonumber(data.ultValue) or 0
    if not IsFresh(data) then return info end

    local snapshot = Snapshot(data)
    local slot = self:GetTrackedSlot(snapshot, definition.ids)
    if not slot then
        info.state = self.UNAVAILABLE
        return info
    end

    info.cost = slot.cost
    info.abilityId = slot.id
    info.percent = math.floor((info.value / info.cost) * 100 + 0.5)
    info.state = info.value >= info.cost and self.READY or self.NOT_READY
    return info
end

function G:GetAnyUltimateReadiness(account)
    local info = { account = account, state = self.UNKNOWN, value = nil, cost = nil, percent = nil, abilityId = nil, unitTag = nil }
    local unitTag = SRC.Roster:GetUnitTagFromAccount(account)
    info.unitTag = unitTag
    if not unitTag or not DoesUnitExist(unitTag) or IsUnitDead(unitTag) then info.state = self.UNAVAILABLE; return info end
    local data = self:GetUnitData(unitTag)
    if not data or not IsFresh(data) then return info end
    local snapshot = Snapshot(data)
    info.value = snapshot.ultValue
    local selected = nil
    for _, slot in ipairs({ {id=snapshot.ult1ID,cost=snapshot.ult1Cost}, {id=snapshot.ult2ID,cost=snapshot.ult2Cost} }) do
        if slot.id > 0 and slot.cost > 0 and (not selected or slot.cost < selected.cost) then selected = slot end
    end
    if not selected then info.state = self.UNAVAILABLE; return info end
    info.cost = selected.cost
    info.abilityId = selected.id
    info.percent = math.floor((info.value / info.cost) * 100 + 0.5)
    info.state = info.value >= info.cost and self.READY or self.NOT_READY
    return info
end

function G:GetReadinessInfo(account)
    return self:GetReadinessInfoFor("COLOSSUS", account)
end

function G:GetReadiness(account)
    local info = self:GetReadinessInfo(account)
    return info.state, info.unitTag and self:GetUnitData(info.unitTag) or nil
end
