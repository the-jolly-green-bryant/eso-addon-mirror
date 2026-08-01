-- =============================================================================
-- Under Pressure -- UI/Debug.lua
-- =============================================================================
-- Optional debug overlay. Toggled via the slash command /updebug and via
-- the settings panel. Shows:
--   * feature-detect probe results
--   * rolling-window damage totals
--   * adjusted pressure DPS, burst multiplier, risk bonus
--   * current TTD, candidate state, published state
--   * last 8 normalized events
-- =============================================================================

UP = UP or {}
UP.Debug = UP.Debug or {}

local LOG_MAX = 8
local logBuffer = {}
local header, body, root

local function fmtNum(n)
    if n == math.huge then return "inf" end
    if not n then return "-" end
    return ("%.1f"):format(n)
end

function UP.Debug.LogEvent(event)
    local line
    if event.kind == "damage" or event.kind == "shieldHit" then
        line = ("%s  dmg=%-6d ability=%-7s"):format(event.kind, event.amount or 0,
            tostring(event.abilityId or "-"))
    elseif event.kind == "effect" then
        line = ("effect   cat=%-13s ability=%-7s"):format(tostring(event.category),
            tostring(event.abilityId or "-"))
    else
        line = tostring(event.kind)
    end
    table.insert(logBuffer, 1, line)
    while #logBuffer > LOG_MAX do table.remove(logBuffer) end
end

function UP.Debug.Log(msg)
    if type(msg) ~= "string" then msg = tostring(msg) end
    table.insert(logBuffer, 1, msg)
    while #logBuffer > LOG_MAX do table.remove(logBuffer) end
end

function UP.Debug.Init()
    root   = UP_DebugRoot
    if not root then return false end
    header = root:GetNamedChild("Header")
    body   = root:GetNamedChild("Body")
    return true
end

function UP.Debug.SetVisible(visible)
    if root then root:SetHidden(not visible) end
end

function UP.Debug.Toggle()
    if not root then return end
    root:SetHidden(not root:IsHidden())
end

-- Repainted every tick by main loop
function UP.Debug.Refresh()
    if not root or root:IsHidden() then return end
    if not (UP.Engine and UP.Engine.Snapshot) then return end
    local s = UP.Engine.Snapshot()

    -- Feature detection results. Every flag in FeatureDetect.lua is mirrored
    -- here so you can see at a glance what the console runtime actually exposes.
    -- Symbol legend: + = probe succeeded, - = probe returned false, ! = fatal absence
    local f = UP.features or {}
    local function mark(v) return v and "+" or "-" end
    local featLine1 = ("feats: gameTime%s combatEvtFilter%s combatState%s"):format(
        f.gameTime and "+" or "!",
        mark(f.combatFilter),
        mark(f.combatStateEvent))
    local featLine2 = ("       visAttrEvts%s statusType%s grpTags%s"):format(
        mark(f.attributeVisual),
        mark(f.statusEffectType),
        mark(f.groupTags))

    header:SetText(("UP debug | TTD %s s | %s"):format(
        fmtNum(s.ttd), tostring(s.publishedState)))

    local effectCount = 0
    for _ in pairs(s.activeEffects or {}) do effectCount = effectCount + 1 end

    local lines = {
        featLine1,
        featLine2,
        ("hp=%d / %d   inCombat=%s"):format(
            s.health or 0, s.maxHealth or 0, tostring(s.inCombat and true or false)),
        ("pressureDPS=%s  burstMul=%s  riskBonus=%s"):format(
            fmtNum(s.pressureDps), fmtNum(s.burstMul), fmtNum(s.riskBonus)),
        ("attackers: %s mode  count=%d"):format(
            tostring(s.attackerMode or "?"), s.attackerCount or 0),
        ("dmgEvts=%d  activeDebuffs=%d  cand=%s"):format(
            s.damageEventCount or 0, effectCount, tostring(s.candidateState)),
        "--- recent events ---",
    }
    for i = 1, math.min(LOG_MAX, #logBuffer) do
        table.insert(lines, logBuffer[i])
    end
    body:SetText(table.concat(lines, "\n"))
end
