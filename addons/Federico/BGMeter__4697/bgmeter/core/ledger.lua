BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Ledger = {}

local MARK_KEYS = { "damage", "healing", "kills", "assists", "ap", "streak" }

local function sv()
    return BGMeter.zenimax.savedvars.get()
end

local function root()
    local data = sv()
    if not data then return nil end
    if not data.ledger then
        data.ledger = { v = 1, arenas = {}, modes = {}, marks = {}, streak = 0 }
    end
    local L = data.ledger
    L.arenas = L.arenas or {}
    L.modes = L.modes or {}
    L.marks = L.marks or {}
    L.streak = L.streak or 0
    return L
end

local function bump(bucket, key, label, m, lr)
    local e = bucket[key]
    if not e then
        e = { name = label, n = 0, w = 0, l = 0, t = 0, dmg = 0, heal = 0, kills = 0, deaths = 0, best = 0, bestAt = 0, last = 0 }
        bucket[key] = e
    end
    if label and label ~= "" then e.name = label end
    e.n = e.n + 1
    if m.result == "WIN" then e.w = e.w + 1
    elseif m.result == "LOSS" then e.l = e.l + 1
    else e.t = e.t + 1 end
    if lr then
        e.dmg = e.dmg + (lr.damage or 0)
        e.heal = e.heal + (lr.healing or 0)
        e.kills = e.kills + (lr.kills or 0)
        e.deaths = e.deaths + (lr.deaths or 0)
        if (lr.damage or 0) > (e.best or 0) then
            e.best = lr.damage or 0
            e.bestAt = m.capturedAt or 0
        end
    end
    if (m.capturedAt or 0) > (e.last or 0) then e.last = m.capturedAt end
    return e
end

local function mark(L, key, value, m)
    if not value or value <= 0 then return false end
    local cur = L.marks[key]
    if not cur or value > (cur.v or 0) then
        L.marks[key] = { v = value, at = m.capturedAt or 0, arena = m.name, mode = Ledger.mode_of(m) }
        return true
    end
    return false
end

function Ledger.mode_of(m)
    local C = BGMeter.zenimax.constants
    return (m and C.GAME_TYPE_LABEL[m.gameType]) or "unknown"
end

function Ledger.arena_of(m)
    if m.name and m.name ~= "" then return m.name end
    if m.bgId then return "arena " .. tostring(m.bgId) end
    return "unknown arena"
end

function Ledger.record(m)
    local L = root()
    if not L or not m then return false end
    local lr = BGMeter.Match.local_row(m)
    local arena = Ledger.arena_of(m)
    bump(L.arenas, arena, arena, m, lr)
    local mode = Ledger.mode_of(m)
    bump(L.modes, mode, mode, m, lr)
    if lr then
        mark(L, "damage", lr.damage, m)
        mark(L, "healing", lr.healing, m)
        mark(L, "kills", lr.kills, m)
        mark(L, "assists", lr.assists, m)
    end
    mark(L, "ap", m.haul and m.haul.apGained, m)
    if m.result == "WIN" then
        L.streak = L.streak + 1
        mark(L, "streak", L.streak, m)
    elseif m.result == "LOSS" then
        L.streak = 0
    end
    return true
end

function Ledger.backfill()
    local data = sv()
    if not data or data.ledger_seeded then return 0 end
    data.ledger_seeded = true
    local matches = data.matches or {}
    local n = 0
    for i = #matches, 1, -1 do
        if Ledger.record(matches[i]) then n = n + 1 end
    end
    BGMeter.Log.debug("ledger: seeded from %d stored matches", n)
    return n
end

local function sorted(bucket)
    local out = {}
    for key, e in pairs(bucket) do
        out[#out + 1] = {
            key = key, name = e.name or key, n = e.n, w = e.w, l = e.l, t = e.t,
            win = (e.n > 0) and (e.w / e.n) or 0,
            avg_dmg = (e.n > 0) and (e.dmg / e.n) or 0,
            avg_heal = (e.n > 0) and (e.heal / e.n) or 0,
            avg_kills = (e.n > 0) and (e.kills / e.n) or 0,
            avg_deaths = (e.n > 0) and (e.deaths / e.n) or 0,
            best = e.best or 0, bestAt = e.bestAt or 0, last = e.last or 0,
        }
    end
    table.sort(out, function(a, b)
        if a.n ~= b.n then return a.n > b.n end
        return a.name < b.name
    end)
    return out
end

function Ledger.arenas()
    local L = root()
    return L and sorted(L.arenas) or {}
end

function Ledger.modes()
    local L = root()
    return L and sorted(L.modes) or {}
end

function Ledger.marks()
    local L = root()
    local out = {}
    if not L then return out end
    for _, key in ipairs(MARK_KEYS) do
        local e = L.marks[key]
        if e then out[#out + 1] = { key = key, v = e.v, at = e.at, arena = e.arena, mode = e.mode } end
    end
    return out
end

function Ledger.streak()
    local L = root()
    return L and L.streak or 0
end

function Ledger.totals()
    local out = { n = 0, w = 0, l = 0, t = 0 }
    local L = root()
    if not L then return out end
    for _, e in pairs(L.modes) do
        out.n = out.n + (e.n or 0)
        out.w = out.w + (e.w or 0)
        out.l = out.l + (e.l or 0)
        out.t = out.t + (e.t or 0)
    end
    return out
end

function Ledger.find_match(at)
    if not at or at <= 0 then return nil end
    local H = BGMeter.History
    for i = 1, H.count() do
        local m = H.get(i)
        if m and m.capturedAt == at then return i end
    end
    return nil
end

function Ledger.forget()
    local data = sv()
    if not data then return end
    data.ledger = nil
end

BGMeter.Ledger = Ledger
