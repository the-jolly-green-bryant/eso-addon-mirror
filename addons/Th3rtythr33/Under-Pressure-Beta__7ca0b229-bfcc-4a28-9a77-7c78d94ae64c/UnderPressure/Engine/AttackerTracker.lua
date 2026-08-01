-- =============================================================================
-- Under Pressure -- AttackerTracker.lua
-- =============================================================================
-- Maintains a rolling map of distinct attackers seen within a configurable
-- window. Used to drive the small counter rendered under the indicator shape.
--
-- Two modes:
--   * "solo" (Not Tank) -- count attackers targeting the local player
--   * "tank"            -- count attackers targeting any groupmate (best
--                          effort: the console runtime may not report every
--                          attack on every groupmate; whatever the local
--                          client observes is what we count)
--
-- A distinct attacker is identified by sourceUnitId. When sourceUnitId is
-- zero, missing, or not numeric (e.g., siege, environmental) we fall back to
-- sourceName as the identity key. DoT ticks from the same source therefore
-- count as one attacker, not N.
--
-- The window is configurable via tunables.attacker_window_s. Default 3s.
-- =============================================================================

UP = UP or {}
UP.Attackers = {}

-- Single map of identity -> lastSeenMs. Earlier versions split this into
-- player / NPC / unknown buckets, but ESO's console runtime does not expose
-- sourceType so the split was a no-op. Reverted to a single attacker count
-- in 0.2.6.
local seenAttackers = {}

-- Group-membership cache. Rebuilt on demand (cheap, max 12 entries). Used in
-- Tank mode to test whether a combat-event target is a groupmate.
--   groupNames[lowercasedName] = true
--   groupUnitIds[unitId] = true   (only populated if the unit-id lookup works)
local groupNames   = {}
local groupUnitIds = {}
local groupCacheBuiltMs = 0
local GROUP_CACHE_TTL_MS = 1500  -- rebuild at most every 1.5s

local function lower(s)
    if type(s) ~= "string" then return nil end
    return s:lower()
end

local function rebuildGroupCache(nowMs)
    groupNames   = {}
    groupUnitIds = {}
    groupCacheBuiltMs = nowMs

    -- GetGroupSize returns 0 when not in a group. Cap at 24 to be safe across
    -- ESO group-size eras (4, 12, 24 raid).
    local size = (type(GetGroupSize) == "function") and GetGroupSize() or 0
    if size <= 0 then return end
    if size > 24 then size = 24 end

    for i = 1, size do
        local tag = ("group%d"):format(i)
        if type(GetUnitName) == "function" then
            local ok, name = pcall(GetUnitName, tag)
            if ok and type(name) == "string" and name ~= "" then
                groupNames[name:lower()] = true
            end
        end
        if type(GetUnitId) == "function" then
            local ok2, uid = pcall(GetUnitId, tag)
            if ok2 and type(uid) == "number" and uid > 0 then
                groupUnitIds[uid] = true
            end
        end
    end
end

local function ensureGroupCacheFresh(nowMs)
    if nowMs - groupCacheBuiltMs >= GROUP_CACHE_TTL_MS then
        rebuildGroupCache(nowMs)
    end
end

-- ---------------------------------------------------------------------------
-- Identity key for an attacker
-- ---------------------------------------------------------------------------
-- Returns the unit ID as a NUMBER, or the source name as a STRING, or nil.
--
-- Previously both were formatted into prefixed strings ("u:123" / "n:Name"),
-- which allocated a string on every combat event -- the busiest path in the
-- addon. The prefixes existed to keep the two ID spaces from colliding, but
-- Lua table keys are type-aware: the number 123 and the string "123" are
-- distinct keys already, so the prefixes bought nothing.
local function attackerKey(sourceUnitId, sourceName)
    if type(sourceUnitId) == "number" and sourceUnitId > 0 then
        return sourceUnitId
    end
    if type(sourceName) == "string" and sourceName ~= "" then
        return sourceName
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Public ingest from EventIngest
-- ---------------------------------------------------------------------------
-- Called for every hostile combat event.
--
-- Args:
--   nowMs        -- event timestamp
--   sourceUnitId -- numeric or nil
--   sourceName   -- string or nil
--   targetScope  -- "self" (local player), "group" (groupmate), "other" (ignored)
function UP.Attackers.Record(nowMs, sourceUnitId, sourceName, targetScope)
    if targetScope ~= "self" and targetScope ~= "group" then return end

    local sv = UP.sv or {}
    local mode = sv.attacker_mode or "solo"
    -- Solo mode: only count attackers on the local player.
    -- Tank mode: count attackers on any groupmate (which includes the local
    -- player -- a tank may also take hits directly).
    if mode == "solo" and targetScope ~= "self" then return end

    local key = attackerKey(sourceUnitId, sourceName)
    if not key then return end
    seenAttackers[key] = nowMs
end

-- ---------------------------------------------------------------------------
-- Helpers exposed for EventIngest
-- ---------------------------------------------------------------------------
-- Returns "self", "group", or "other" given the event's target identifiers.
-- The local-player check is the cheapest, so we do it first.
function UP.Attackers.ClassifyTarget(targetType, targetUnitId, targetName, nowMs)
    -- Local player. EventIngest already filters most events to targetType ==
    -- COMBAT_UNIT_TYPE_PLAYER for the local player; we keep the check here
    -- so this function is safe to call from any callsite.
    if type(COMBAT_UNIT_TYPE_PLAYER) == "number"
       and targetType == COMBAT_UNIT_TYPE_PLAYER then
        return "self"
    end

    -- Groupmate check is only meaningful when the target is another player.
    if type(COMBAT_UNIT_TYPE_OTHER_PLAYER) == "number"
       and targetType ~= COMBAT_UNIT_TYPE_OTHER_PLAYER then
        return "other"
    end

    -- Only useful in Tank mode; cheap enough to always compute.
    ensureGroupCacheFresh(nowMs)

    if type(targetUnitId) == "number" and groupUnitIds[targetUnitId] then
        return "group"
    end
    local key = lower(targetName)
    if key and groupNames[key] then
        return "group"
    end
    return "other"
end

-- ---------------------------------------------------------------------------
-- Counter readout
-- ---------------------------------------------------------------------------
-- Returns count of distinct attackers seen in the configured window.
--
-- Memoised per timestamp. The UI refresh and the debug overlay both want the
-- count in the same pass, and this walk also prunes expired entries, so
-- without the memo the map got walked twice per refresh whenever the overlay
-- was open. UP.Attackers.LastCount() reads the memo without walking.
local lastCountMs, lastCount = -1, 0

function UP.Attackers.LastCount()
    return lastCount
end

function UP.Attackers.Counts(nowMs)
    if nowMs == lastCountMs then return lastCount end

    local sv = UP.sv or {}
    local tun = sv.tunables or {}
    local windowS = tun.attacker_window_s or UP.Defaults.attacker_window_s
    if type(windowS) ~= "number" or windowS <= 0 then windowS = 3 end
    local cutoff = nowMs - (windowS * 1000)

    local n = 0
    for k, t in pairs(seenAttackers) do
        if t >= cutoff then n = n + 1 else seenAttackers[k] = nil end
    end

    lastCountMs, lastCount = nowMs, n
    return n
end

-- Returns mode string, useful for the indicator label
function UP.Attackers.Mode()
    local sv = UP.sv or {}
    return sv.attacker_mode or "solo"
end

-- Reset (called on combat-state leaving, optional)
function UP.Attackers.Clear()
    seenAttackers = {}
    lastCountMs, lastCount = -1, 0
end
