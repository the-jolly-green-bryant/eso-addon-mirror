
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Ava = {}

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d
end

Ava.SOURCES = {
    { key = "kills",   label = "Kills",        color = { 0.89, 0.26, 0.20, 1 } },
    { key = "offense", label = "Keep offense", color = { 0.95, 0.80, 0.35, 1 } },
    { key = "defense", label = "Keep defense", color = { 0.35, 0.65, 0.85, 1 } },
    { key = "rez",     label = "Resurrects",   color = { 0.30, 0.78, 0.45, 1 } },
    { key = "bg",      label = "Battlegrounds",color = { 0.55, 0.50, 0.95, 1 } },
    { key = "other",   label = "Other",        color = { 0.55, 0.55, 0.60, 1 } },
}

local _reason_map = nil
local function reason_map()
    if _reason_map then return _reason_map end
    local R = BGMeter.zenimax.constants.AP_REASON or {}
    local m = {}
    if R.KILL          ~= nil then m[R.KILL]          = "kills"   end
    if R.KILL_TRANSFER ~= nil then m[R.KILL_TRANSFER] = "kills"   end
    if R.KEEP_OFFENSE  ~= nil then m[R.KEEP_OFFENSE]  = "offense" end
    if R.KEEP_DEFENSE  ~= nil then m[R.KEEP_DEFENSE]  = "defense" end
    if R.RESURRECT     ~= nil then m[R.RESURRECT]     = "rez"     end
    if R.BATTLEGROUND  ~= nil then m[R.BATTLEGROUND]  = "bg"      end
    _reason_map = m
    return m
end

local function bucket_for(reason)
    if reason == nil then return "other" end
    return reason_map()[reason] or "other"
end

local function blank_session()
    return {
        active   = false,
        startMs  = safe(BGMeter.zenimax.api.now_ms) or 0,
        ap       = 0,
        xp       = 0,
        gains    = 0,
        zone     = nil,
        vetStart = nil,
        sources  = { kills = 0, offense = 0, defense = 0, rez = 0, bg = 0, other = 0 },
    }
end

Ava.session = blank_session()

Ava.probe = false

function Ava.in_ava()
    local A = BGMeter.zenimax.api
    local v = safe(A.is_player_in_ava_world)
    if v == nil then v = safe(A.is_in_ava_zone) end
    return v and true or false
end

function Ava.begin_session()
    local A = BGMeter.zenimax.api
    local s = blank_session()
    s.active   = true
    s.startMs  = safe(A.now_ms) or 0
    s.zone     = safe(A.get_zone_name)
    s.vetStart = BGMeter.Veterancy and BGMeter.Veterancy.snapshot() or nil
    Ava.session = s
    BGMeter.Log.debug("ava session begin: zone=%s", tostring(s.zone))
end

function Ava.end_session()
    if not Ava.session.active then return end
    Ava.session.active = false
    BGMeter.Log.debug("ava session end: ap=%d", Ava.session.ap)
end

function Ava.reset()
    if Ava.in_ava() then Ava.begin_session()
    else Ava.session = blank_session() end
end

function Ava.on_ap(_, _alliancePoints, _playSound, difference, reason)
    if not difference or difference <= 0 then return end
    if not Ava.in_ava() then
        if Ava.probe then
            BGMeter.Log.say("|cffd700AP|r +%d  reason=%s (outside AvA)",
                difference, tostring(reason))
        end
        return
    end

    if not Ava.session.active then Ava.begin_session() end
    local s = Ava.session
    local bucket = bucket_for(reason)
    s.ap = s.ap + difference
    s.sources[bucket] = (s.sources[bucket] or 0) + difference
    s.gains = s.gains + 1

    if Ava.probe then
        BGMeter.Log.say("|cffd700AP|r +%d  reason=%s  -> %s  (session %s)",
            difference, tostring(reason), bucket, BGMeter.Format.commas(s.ap))
    end
end

function Ava.on_xp(_, _reason, _level, prev, current)
    if not Ava.session.active then return end
    if not prev or not current then return end
    Ava.session.xp = Ava.session.xp + math.max(0, current - prev)
end

function Ava.on_player_activated()
    if Ava.in_ava() then
        if not Ava.session.active then Ava.begin_session() end
    else
        Ava.end_session()
    end
end

function Ava.ap_per_hour()
    local s = Ava.session
    local nowMs = safe(BGMeter.zenimax.api.now_ms) or s.startMs
    local hours = (nowMs - s.startMs) / 3600000
    if hours <= 0.0001 then return 0 end
    return s.ap / hours
end

function Ava.breakdown()
    local s = Ava.session
    local total = s.ap > 0 and s.ap or 1
    local out = {}
    for _, src in ipairs(Ava.SOURCES) do
        local ap = s.sources[src.key] or 0
        if ap > 0 then
            out[#out + 1] = { key = src.key, label = src.label, color = src.color,
                              ap = ap, pct = ap / total }
        end
    end
    table.sort(out, function(a, b) return a.ap > b.ap end)
    return out
end

function Ava.summary()
    local s = Ava.session
    if s.ap == 0 and not s.active then return nil end
    local F = BGMeter.Format
    return string.format("AvA session: %s AP  ·  %s AP/hr  ·  %s XP%s",
        F.commas(s.ap), F.commas(Ava.ap_per_hour()), F.commas(s.xp),
        s.active and "" or "  (ended)")
end

function Ava.init()
    local E = BGMeter.zenimax.events
    local C = BGMeter.zenimax.constants
    local P = "BGMeterAva_"

    E.register(P .. "AP",   C.EVENT_ALLIANCE_POINT_UPDATE,        Ava.on_ap)
    E.register(P .. "XP",   C.EVENT_EXPERIENCE_GAIN,              Ava.on_xp)
    E.register(P .. "Zone", C.EVENT_PLAYER_ACTIVATED,             Ava.on_player_activated)

    if Ava.in_ava() then Ava.begin_session() end
    BGMeter.Log.debug("ava engine wired (in_ava=%s)", tostring(Ava.in_ava()))
end

BGMeter.Ava = Ava
