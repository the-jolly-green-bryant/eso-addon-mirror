-- ESO Adventurer Suite
-- v0.29.511 - high-density combat performance guard.
-- Large pulls, Infinite Archive waves and PvP can generate enormous combat-event
-- volume. Keep exact event totals, but reuse expensive character-stat snapshots
-- for a short window instead of recomputing them for every individual hit/heal.

local EPC = ESOProgressionCoach
if not EPC or not EPC.Combat then return end

local C = EPC.Combat
local CACHE_MS = 200

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    if type(GetGameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetGameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

if type(C.ReadCombatStatsSnapshot) == "function" and not C._easDensitySnapshotGuard029511 then
    C._easDensitySnapshotGuard029511 = true
    local baseRead = C.ReadCombatStatsSnapshot

    function C:ReadCombatStatsSnapshot(force)
        if force == true then
            self._easDensitySnapshot029511 = nil
            self._easDensitySnapshotAt029511 = 0
            local snapshot = baseRead(self, true)
            if type(snapshot) == "table" then
                self._easDensitySnapshot029511 = snapshot
                self._easDensitySnapshotAt029511 = nowMs()
            end
            return snapshot
        end

        local stamp = nowMs()
        local cached = self._easDensitySnapshot029511
        local cachedAt = tonumber(self._easDensitySnapshotAt029511) or 0
        if type(cached) == "table" and stamp >= cachedAt and (stamp - cachedAt) < CACHE_MS then
            return cached
        end

        local snapshot = baseRead(self, false)
        if type(snapshot) == "table" then
            self._easDensitySnapshot029511 = snapshot
            self._easDensitySnapshotAt029511 = stamp
        end
        return snapshot
    end
end

local function resetSnapshot(self)
    self._easDensitySnapshot029511 = nil
    self._easDensitySnapshotAt029511 = 0
end

if type(C.BeginFight) == "function" and not C._easDensityBeginWrapped029511 then
    C._easDensityBeginWrapped029511 = true
    local baseBegin = C.BeginFight
    function C:BeginFight(...)
        resetSnapshot(self)
        return baseBegin(self, ...)
    end
end

if type(C.EndFight) == "function" and not C._easDensityEndWrapped029511 then
    C._easDensityEndWrapped029511 = true
    local baseEnd = C.EndFight
    function C:EndFight(...)
        local result = baseEnd(self, ...)
        resetSnapshot(self)
        return result
    end
end

-- Avoid redundant refresh storms from modules that request the same global Suite
-- refresh repeatedly inside one dense combat frame. Requests are still delivered;
-- identical reasons inside 50 ms are coalesced into one call.
if type(EPC.RequestRefresh) == "function" and not EPC._easDensityRefreshGuard029511 then
    EPC._easDensityRefreshGuard029511 = true
    local baseRequestRefresh = EPC.RequestRefresh
    local lastReason, lastAt = nil, 0

    function EPC:RequestRefresh(reason, ...)
        local stamp = nowMs()
        local key = tostring(reason or "")
        if key ~= "" and key == lastReason and stamp >= lastAt and (stamp - lastAt) < 50 then
            return
        end
        lastReason, lastAt = key, stamp
        return baseRequestRefresh(self, reason, ...)
    end
end
