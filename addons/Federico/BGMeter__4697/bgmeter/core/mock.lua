BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Mock = {}
BGMeter.Mock = Mock

local ROSTER = {
    "Velladocuments", "@StormLord", "Shadowmend", "Brakka gro-Mug",
    "Lyra Heartwood", "@FrostCaller", "Dro-mathra", "@HealBot",
    "@NightAxe", "Serenna Vox", "@Kagouti", "Tullius Rane",
    "@BogBlossom", "Yrsa Frost", "@PortalMonk", "Vexara",
}

local function rev(map, label)
    for k, v in pairs(map) do
        if v == label then return k end
    end
    return nil
end

local function jit(i, a, b)
    local x = math.sin(i * 12.9898) * 43758.5453
    local f = x - math.floor(x)
    return math.floor(a + f * (b - a))
end

local function make_rows(m, n, teams, tracker)
    local Match = BGMeter.Match
    for i = 1, n do
        local r = Match.new_row()
        r.displayName = ROSTER[i]
        r.isLocal = (i == 5)
        r.team = teams[((i - 1) % #teams) + 1]
        r.damage  = jit(i, 40000, 420000)
        r.healing = (i % 4 == 0) and jit(i + 30, 180000, 700000) or jit(i + 60, 2000, 90000)
        r.taken   = math.floor(r.damage * 0.6)
        r.kills, r.deaths, r.assists = jit(i + 1, 0, 12), jit(i + 2, 1, 9), jit(i + 3, 2, 20)
        r.score  = (r.kills * 400) + jit(i + 4, 0, 2500)
        r.medals = jit(i + 5, 2, 18)
        if tracker then tracker(r, i) end
        m.battle[#m.battle + 1] = r
    end
end

local function make_timeline(m, teams, dur, rounds, top1, top2, step)
    local tl = { t = {}, r = {}, s1 = {}, s2 = {}, s3 = {}, teams = teams }
    local n = 72
    for i = 1, n do
        local p = i / n
        local rnd = math.min(rounds, math.floor(p * rounds) + 1)
        local rp = (p * rounds) - (rnd - 1)
        tl.t[i] = math.floor(p * dur)
        tl.r[i] = rnd
        if step then
            tl.s1[i] = math.floor(top1 * (p * 0.92) / step + 0.001) * step
            tl.s2[i] = math.floor(top2 * p / step + 0.001) * step
        else
            tl.s1[i] = math.floor(top1 * rp * (0.85 + 0.15 * math.sin(p * 9)))
            tl.s2[i] = math.floor(top2 * rp * (0.90 + 0.10 * math.sin(3 + p * 7)))
        end
        tl.s3[i] = 0
    end
    m.timeline = tl
end

local function make_killfeed(m, dur, teams, bias)
    m.killfeed = {}
    local n = math.min(#m.battle, #ROSTER)
    for i = 1, 34 do
        local ki = jit(i + 200, 1, n)
        if bias and teams[bias] and jit(i + 500, 0, 100) < 74 then
            local tries = 0
            while m.battle[ki].team ~= teams[bias] and tries < 8 do
                ki = (ki % n) + 1
                tries = tries + 1
            end
        end
        local di = ((ki + jit(i + 300, 0, n - 2)) % n) + 1
        local kr, dr = m.battle[ki], m.battle[di]
        if kr and dr and kr.team ~= dr.team then
            local kind
            if kr.isLocal then kind = "kill" elseif dr.isLocal then kind = "death" end
            m.killfeed[#m.killfeed + 1] = {
                t = math.floor(dur * i / 36), kind = kind,
                kn = kr.displayName, kt = kr.team,
                dn = dr.displayName, dt = dr.team,
            }
        end
    end
end

local function make_objectives(m, flags, script)
    local CZ = BGMeter.zenimax.constants
    local ob = { list = {}, t = {}, r = {}, o = {}, ev = {}, st = {}, own = {} }
    for i, f in ipairs(flags) do
        ob.list[i] = { letter = f[1], name = f[2], keepId = 0, objectiveId = 550 + i }
    end
    for _, e in ipairs(script) do
        local i = #ob.t + 1
        ob.t[i], ob.r[i], ob.o[i] = e[1], 1, e[2]
        ob.ev[i] = (e[3] == -1) and -1 or (rev(CZ.OBJ_EVENT_LABEL, e[3]) or -1)
        ob.st[i], ob.own[i] = -1, e[4]
    end
    m.objectives = ob
end

local function make_relics(m, list, script)
    local CZ = BGMeter.zenimax.constants
    local rl = { list = {}, t = {}, r = {}, o = {}, ev = {}, hold = {}, last = {}, who = {} }
    for i, e in ipairs(list) do
        rl.list[i] = { keepId = 0, objectiveId = 520 + i, name = e.name, home = e.home }
    end
    table.sort(script, function(a, z) return a[1] < z[1] end)
    for _, e in ipairs(script) do
        local i = #rl.t + 1
        rl.t[i], rl.r[i], rl.o[i] = e[1], 1, e[2]
        rl.ev[i] = rev(CZ.OBJ_EVENT_LABEL, e[3]) or -1
        rl.hold[i], rl.last[i] = e[4] or 0, e[5] or 0
        rl.who[i] = e[6]
    end
    m.relics = rl
end

local function relic_run(script, o, tTake, holdSec, team, outcome, who)
    script[#script + 1] = { tTake * 1000, o, "flag_taken", team, 0 }
    local tEnd = (tTake + holdSec) * 1000
    if outcome == "goal" then
        script[#script + 1] = { tEnd, o, "captured", 0, team, who }
        script[#script + 1] = { tEnd + 20000, o, "flag_spawned", 0, team }
    else
        script[#script + 1] = { tEnd, o, "flag_dropped", 0, team }
        script[#script + 1] = { tEnd + 5000, o, "flag_returned", 0, team }
        script[#script + 1] = { tEnd + 5000, o, "flag_spawned", 0, team }
    end
end

local function flag_cycle(script, o, t0, own1, own2)
    local s = function(dt, ev, own) script[#script + 1] = { t0 + dt, o, ev, own } end
    s(0,      "neutral",            0)
    s(6000,   "lost",               own1)
    s(12000,  "captured",           own1)
    s(20000,  "fully_held",         own1)
    s(34000,  "under_attack",       own1)
    s(40000,  "assaulted",          own1)
    s(41000,  "neutral",            0)
    s(45000,  "lost",               own2)
    s(52000,  "captured",           own2)
    s(58000,  "captured",           own2)
    s(64000,  "deactivate_pending", own2)
    s(74000,  "deactivated",        0)
end

local function finish(m, mode)
    local Match = BGMeter.Match
    local A = BGMeter.zenimax.api
    m.capturedAt = (type(A.get_timestamp) == "function") and A.get_timestamp() or 0
    local medalIds = BGMeter.Icons.scan_medal_ids(300, 6)
    local lr = Match.local_row(m)
    if lr and #medalIds > 0 then
        lr.medalIds, lr.medalCounts = medalIds, {}
        local total = 0
        for i, id in ipairs(medalIds) do
            local c = (i % 3 == 0) and 3 or 1
            lr.medalCounts[id] = c
            total = total + c
        end
        lr.medals = total
    end
    m.haul.apGained, m.haul.xpGained, m.haul.cpGained, m.haul.medals = 9800, 41200, 1, lr and lr.medals or 6
    m.haul.vetStart = { rank = 14, tier = 14, percent = 0.73, progressToNext = 3650, tierTotal = 5000, seasonName = "Whitestrake's Mayhem", secondsLeft = 387600, inZone = true }
    m.haul.vetEnd   = { rank = 14, tier = 14, percent = 0.79, progressToNext = 3950, tierTotal = 5000, rankTitle = "Veteran Lieutenant", seasonName = "Whitestrake's Mayhem", secondsLeft = 387600, inZone = true }
    Match.derive(m)
    if m.competitive then
        m.standing = { rank = 214, prevRank = 221, rankDelta = 7, score = 5350, prevScore = 5105, scoreDelta = 245, mmr = 1580, impacts = true }
    end
    BGMeter.Session.record(m)
    BGMeter.History.push(m)
    BGMeter.UI.window.show_match(1)
    if m.result == "WIN" then BGMeter.Sound.play("win") end
    BGMeter.Log.say("mock %s injected -- %d players, %s, %s",
        mode, #m.battle, m.competitive and "competitive" or "casual", m.result)
end

local BUILDERS = {}

function BUILDERS.deathmatch()
    local CZ = BGMeter.zenimax.constants
    local m = BGMeter.Match.new()
    local teams = { CZ.BATTLEGROUND_TEAM_FIRE_DRAKES, CZ.BATTLEGROUND_TEAM_PIT_DAEMONS }
    m.name, m.result = "Foyada Quarry DM", "WIN"
    m.gameType = rev(CZ.GAME_TYPE_LABEL, "deathmatch")
    m.teamSize, m.competitive = 4, true
    m.localTeam = teams[1]
    m.startMs, m.endMs = 0, 12 * 60000
    m.numRounds = 3
    m.teams = {
        { team = teams[1], score = 500, roundsWon = 2 },
        { team = teams[2], score = 500, roundsWon = 1 },
    }
    make_rows(m, 8, teams)
    make_timeline(m, teams, 12 * 60000, 3, 500, 460)
    make_killfeed(m, 12 * 60000, teams)
    finish(m, "deathmatch")
end

function BUILDERS.domination()
    local CZ = BGMeter.zenimax.constants
    local m = BGMeter.Match.new()
    local teams = { CZ.BATTLEGROUND_TEAM_FIRE_DRAKES, CZ.BATTLEGROUND_TEAM_PIT_DAEMONS }
    m.name, m.result = "Istirus Outpost DOM", "WIN"
    m.gameType = rev(CZ.GAME_TYPE_LABEL, "domination")
    m.teamSize, m.competitive = 4, true
    m.localTeam = teams[1]
    m.startMs, m.endMs = 0, 13 * 60000
    m.numRounds = 1
    m.teams = {
        { team = teams[1], score = 512, roundsWon = 0 },
        { team = teams[2], score = 430, roundsWon = 0 },
    }
    make_rows(m, 8, teams, function(r, i)
        r.caps   = jit(i + 70, 0, 13)
        r.defPts = r.caps * jit(i + 80, 30, 60)
    end)
    make_timeline(m, teams, 13 * 60000, 1, 512, 430)
    make_killfeed(m, 13 * 60000, teams)
    local script = {}
    local flip = { { 90, 1 }, { 150, 2 }, { 260, 1 }, { 300, 2 }, { 420, 1 }, { 540, 2 }, { 620, 1 } }
    for fi, flag in ipairs({ "West Flag", "East Flag" }) do
        local s = function(t, ev, own) script[#script + 1] = { t * 1000, fi, ev, own } end
        s(54 + fi * 4, "neutral", 0)
        for k, e in ipairs(flip) do
            local own = (fi == 2) and (3 - e[2]) or e[2]
            s(e[1] + fi * 6,      "lost",       own)
            s(e[1] + fi * 6 + 8,  "captured",   own)
            s(e[1] + fi * 6 + 16, "fully_held", own)
            if k % 3 == 0 then s(e[1] + fi * 6 + 30, "captured", own) end
        end
    end
    table.sort(script, function(a, z) return a[1] < z[1] end)
    make_objectives(m, { { "A", "West Flag" }, { "B", "East Flag" } }, script)
    finish(m, "domination")
end

function BUILDERS.crazy_king()
    local CZ = BGMeter.zenimax.constants
    local m = BGMeter.Match.new()
    local teams = { CZ.BATTLEGROUND_TEAM_FIRE_DRAKES, CZ.BATTLEGROUND_TEAM_PIT_DAEMONS }
    m.name, m.result = "City CK 50", "LOSS"
    m.gameType = rev(CZ.GAME_TYPE_LABEL, "crazy_king")
    m.teamSize, m.competitive = 8, false
    m.localTeam = teams[1]
    m.startMs, m.endMs = 0, 11 * 60000
    m.numRounds = 1
    m.teams = {
        { team = teams[1], score = 411, roundsWon = 0 },
        { team = teams[2], score = 500, roundsWon = 0 },
    }
    make_rows(m, 16, teams, function(r, i)
        r.caps   = jit(i + 90, 0, 11)
        r.defPts = r.caps * jit(i + 95, 25, 55)
    end)
    make_timeline(m, teams, 11 * 60000, 1, 411, 500)
    make_killfeed(m, 11 * 60000, teams)
    local flags = {
        { "A", "Central Plaza Flag" }, { "D", "Fire Drake Plaza Flag" },
        { "C", "Pit Daemon Plaza Flag" }, { "B", "Church Plaza Flag" },
        { "A", "West Alley Flag" }, { "D", "South Alley Flag" },
        { "C", "Market Plaza Flag" }, { "B", "Dufort Inn Flag" },
    }
    local script = {}
    for o = 1, #flags do
        local own1 = (o % 2 == 0) and 2 or 1
        flag_cycle(script, o, 55000 + (o - 1) * 76000, own1, 3 - own1)
    end
    flag_cycle(script, 1, 500000, 2, 1)
    flag_cycle(script, 2, 300000, 1, 2)
    table.sort(script, function(a, z) return a[1] < z[1] end)
    make_objectives(m, flags, script)
    finish(m, "crazy king")
end

function BUILDERS.murderball()
    local CZ = BGMeter.zenimax.constants
    local m = BGMeter.Match.new()
    local teams = { CZ.BATTLEGROUND_TEAM_FIRE_DRAKES, CZ.BATTLEGROUND_TEAM_PIT_DAEMONS }
    m.name, m.result = "City Streets Chaosball", "WIN"
    m.gameType = rev(CZ.GAME_TYPE_LABEL, "murderball")
    m.teamSize, m.competitive = 8, false
    m.localTeam = teams[1]
    m.startMs, m.endMs = 0, 10 * 60000
    m.numRounds = 1
    m.teams = {
        { team = teams[1], score = 500, roundsWon = 0 },
        { team = teams[2], score = 377, roundsWon = 0 },
    }
    make_rows(m, 16, teams, function(r, i)
        if i == 7 then
            r.carried, r.caps, r.carrierKills = 0, 0, 8
        else
            r.carried = jit(i + 100, 0, 240)
            r.caps = math.floor(r.carried * (0.8 + (i % 5) * 0.12))
            r.carrierKills = jit(i + 110, 0, 3)
        end
    end)
    make_timeline(m, teams, 10 * 60000, 1, 500, 377)
    make_killfeed(m, 10 * 60000, teams)
    local balls = { { name = "Chaosball" }, { name = "Chaosball" }, { name = "Chaosball" } }
    local carriers = {
        { "Velladocuments", "Shadowmend", "Lyra Heartwood", "@NightAxe" },
        { "@StormLord", "Brakka gro-Mug", "@FrostCaller", "Serenna Vox" },
    }
    local script = {}
    for o = 1, 3 do
        local t = 22000 + o * 4000
        script[#script + 1] = { t - 3000, o, "flag_spawned", 0, 0 }
        local ti = (o % 2 == 0) and 2 or 1
        while t < 560000 do
            local hold = jit(o * 100 + t, 18, 65) * 1000
            local tm = teams[ti]
            local who = carriers[ti][jit(o * 400 + t, 1, 5)]
            script[#script + 1] = { t, o, "flag_taken", tm, 0, who }
            script[#script + 1] = { t + hold, o, "flag_dropped", 0, tm }
            local loose = jit(o * 200 + t, 4, 22) * 1000
            script[#script + 1] = { t + hold + loose, o, "flag_timer_return", 0, tm }
            t = t + hold + loose + jit(o * 300 + t, 3, 14) * 1000
            ti = 3 - ti
        end
    end
    make_relics(m, balls, script)
    finish(m, "chaosball")
end

function BUILDERS.capture_the_flag()
    local CZ = BGMeter.zenimax.constants
    local m = BGMeter.Match.new()
    local teams = { CZ.BATTLEGROUND_TEAM_FIRE_DRAKES, CZ.BATTLEGROUND_TEAM_PIT_DAEMONS }
    m.name, m.result = "Sewer CTF 50", "LOSS"
    m.gameType = rev(CZ.GAME_TYPE_LABEL, "capture_the_flag")
    m.teamSize, m.competitive = 8, false
    m.localTeam = teams[1]
    m.startMs, m.endMs = 0, math.floor(14.6 * 60000)
    m.numRounds = 1
    m.teams = {
        { team = teams[1], score = 200, roundsWon = 0 },
        { team = teams[2], score = 500, roundsWon = 0 },
    }
    local capsPlan = { [2] = 300, [4] = 100, [6] = 100, [9] = 100, [13] = 100 }
    make_rows(m, 16, teams, function(r, i)
        r.caps = capsPlan[i] or 0
        r.carried = (r.caps > 0) and jit(i + 120, 40, 430) or ((i % 4 == 1) and jit(i + 130, 0, 150) or 0)
        r.carrierKills = (i % 6 == 0) and jit(i + 140, 1, 2) or 0
    end)
    make_timeline(m, teams, math.floor(14.6 * 60000), 1, 200, 500, 100)
    make_killfeed(m, math.floor(14.6 * 60000), teams, 1)
    local relics = {
        { name = "Fire Drakes Relic", home = teams[1] },
        { name = "Pit Daemons Relic", home = teams[2] },
    }
    local script = {}
    relic_run(script, 1, 109, 279, teams[2], "stopped")
    relic_run(script, 1, 401, 50,  teams[2], "goal", "@StormLord")
    relic_run(script, 1, 487, 103, teams[2], "goal", "@StormLord")
    relic_run(script, 1, 615, 21,  teams[2], "goal", "Brakka gro-Mug")
    relic_run(script, 1, 661, 25,  teams[2], "goal", "@FrostCaller")
    relic_run(script, 1, 862, 15,  teams[2], "goal", "@StormLord")
    relic_run(script, 2, 117, 260, teams[1], "stopped")
    relic_run(script, 2, 460, 45,  teams[1], "goal", "@NightAxe")
    relic_run(script, 2, 700, 30,  teams[1], "goal", "@BogBlossom")
    relic_run(script, 2, 800, 30,  teams[1], "stopped")
    make_relics(m, relics, script)
    finish(m, "capture the relic")
end

local ALIAS = {
    dm = "deathmatch", deathmatch = "deathmatch",
    dom = "domination", domination = "domination",
    ck = "crazy_king", crazyking = "crazy_king", king = "crazy_king",
    ball = "murderball", chaosball = "murderball", murderball = "murderball", mb = "murderball",
    relic = "capture_the_flag", ctf = "capture_the_flag", flag = "capture_the_flag",
}

function Mock.run(arg)
    local mode = ALIAS[(arg or ""):lower():gsub("%s+", "")]
    if not mode then
        BGMeter.Log.say("mock modes: dm  dom  ck  ball  relic")
        return
    end
    BUILDERS[mode]()
end
