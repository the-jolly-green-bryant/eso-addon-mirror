-- =============================================================================
-- Under Pressure -- AttackerTracker.lua
-- =============================================================================
-- Maintains a rolling map of distinct attackers seen within a configurable
-- window. Used to drive the small counter rendered under the indicator shape.
--
-- Counts attackers targeting the LOCAL PLAYER, and nothing else.
--
-- Tank mode -- a second counting mode that widened this to attackers on any
-- groupmate -- was removed in 0.2.9. It needed a group-membership cache and a
-- target-scope classification on every combat event, and it never worked as
-- intended: the local client only receives a subset of the combat events
-- happening to groupmates, so the count was quietly incomplete in exactly the
-- content (trials, big pulls) where a tank would rely on it. See
-- Docs/UnderPressure.md for the full reasoning.
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
-- Called for every hostile combat event that targets the local player. The
-- caller is responsible for that filtering -- see EventIngest.onCombatEvent,
-- which returns early on any other target before reaching this.
--
-- Args:
--   nowMs        -- event timestamp
--   sourceUnitId -- numeric or nil
--   sourceName   -- string or nil
function UP.Attackers.Record(nowMs, sourceUnitId, sourceName)
    local key = attackerKey(sourceUnitId, sourceName)
    if not key then return end
    seenAttackers[key] = nowMs
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

-- Reset (called on combat-state leaving, optional)
function UP.Attackers.Clear()
    seenAttackers = {}
    lastCountMs, lastCount = -1, 0
end
