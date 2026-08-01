BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Capture = {}

local SAMPLE_NAME = "BGMeterScoreSample"
local SAMPLE_MS   = 5000

local active = nil
local baseline = nil
local obj_lookup = {}
local obj_last = {}
local relic_lookup = {}

local MAX_OBJ_EVENTS = 600

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d
end

local function team_list()
    local C = BGMeter.zenimax.constants
    return { C.BATTLEGROUND_TEAM_FIRE_DRAKES, C.BATTLEGROUND_TEAM_PIT_DAEMONS, C.BATTLEGROUND_TEAM_STORM_LORDS }
end

local function current_round()
    local A = BGMeter.zenimax.api
    return safe(A.get_bg_round_index) or 1
end

local function read_score(i, stype, round)
    local A = BGMeter.zenimax.api
    local v = safe(A.get_entry_cumulative, i, stype, round)
    if v == nil then v = safe(A.get_entry_score, i, stype, round) end
    return (v or 0) + 0
end

local function clean_name(raw)
    if not raw or raw == "" then return nil end
    if type(zo_strformat) == "function" then
        local ok, f = pcall(zo_strformat, "<<1>>", raw)
        if ok and f and f ~= "" then return f end
    end
    return (raw:gsub("%^.*$", ""))
end

local function count_entry_medals(i, round)
    local A = BGMeter.zenimax.api
    local count, last, ids, counts = 0, nil, {}, {}

    safe(A.gen_cumulative_medals, i, round)
    for _ = 1, 64 do
        local id = safe(A.get_next_cumulative_medal, last)
        if not id then break end
        local n = safe(A.get_cumulative_medal_count, id) or 1
        count = count + n
        ids[#ids + 1] = id
        counts[id] = n
        last = id
    end

    if count == 0 then
        last = nil
        for _ = 1, 64 do
            local id = safe(A.get_next_entry_medal, i, round, last)
            if not id then break end
            local n = safe(A.get_entry_medal_count, i, id, round) or 1
            count = count + n
            ids[#ids + 1] = id
            counts[id] = n
            last = id
        end
    end

    return count, ids, counts
end

function Capture.read_battle(m)
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local Match = BGMeter.Match
    local round = current_round()
    local n = safe(A.get_num_entries, round) or 0

    m.battle = {}
    for i = 1, n do
        local row = Match.new_row()
        local charName, displayName, team, isLocal = safe(A.get_entry_info, i, round)
        row.charName    = clean_name(charName)
        row.displayName = clean_name(displayName)
        row.team        = team or safe(A.get_entry_team, i, round)
        row.isLocal     = isLocal and true or false
        row.classId     = safe(A.get_entry_class, i, round)
        row.lives       = safe(A.get_entry_lives, i, round)
        row.damage      = read_score(i, C.SCORE_TRACKER_TYPE_DAMAGE_DONE, round)
        row.healing     = read_score(i, C.SCORE_TRACKER_TYPE_HEALING_DONE, round)
        row.taken       = read_score(i, C.SCORE_TRACKER_TYPE_DAMAGE_TAKEN, round)
        row.kills       = read_score(i, C.SCORE_TRACKER_TYPE_KILL, round)
        row.deaths      = read_score(i, C.SCORE_TRACKER_TYPE_DEATH, round)
        row.assists     = read_score(i, C.SCORE_TRACKER_TYPE_ASSISTS, round)
        row.score       = read_score(i, C.SCORE_TRACKER_TYPE_SCORE, round)
        row.caps        = read_score(i, C.SCORE_TRACKER_TYPE_FLAG_CAPTURED, round)
        row.defPts      = read_score(i, C.SCORE_TRACKER_TYPE_CAPTURE_DEFENSE_POINTS, round)
        row.carried     = read_score(i, C.SCORE_TRACKER_TYPE_FLAG_CARRIED_TIME, round)
        row.carrierKills = read_score(i, C.SCORE_TRACKER_TYPE_KILLED_FLAG_CARRIER, round)
        row.medals, row.medalIds, row.medalCounts = count_entry_medals(i, round)
        m.battle[#m.battle + 1] = row
    end
    return m
end

local function read_teams(m)
    local A = BGMeter.zenimax.api
    local round = current_round()
    local present = {}
    for _, row in ipairs(m.battle) do
        if row.team ~= nil then present[row.team] = true end
    end
    local order = {}
    for _, t in ipairs(team_list()) do
        if t ~= nil and (present[t] or next(present) == nil) then
            order[#order + 1] = t
        end
    end
    local teams = {}
    for _, t in ipairs(order) do
        teams[#teams + 1] = {
            team      = t,
            score     = safe(A.get_team_score, round, t) or 0,
            roundsWon = safe(A.get_rounds_won, t) or 0,
        }
    end
    m.teams = teams
    m.numRounds = (m.bgId and safe(A.get_num_rounds, m.bgId)) or 1
end

local function read_result(localTeam)
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    if localTeam == nil then return nil end
    local r = safe(A.get_result_for_team, localTeam)
    if r == nil then return nil end
    return C.RESULT_LABEL[r]
end

local function obj_key(keepId, objectiveId)
    return tostring(keepId) .. ":" .. tostring(objectiveId)
end

local function register_objective(keepId, objectiveId, ctx, name)
    if not active or not active.objectives then return nil end
    local key = obj_key(keepId, objectiveId)
    local idx = obj_lookup[key]
    if idx then
        local cleaned = clean_name(name)
        if cleaned then active.objectives.list[idx].name = cleaned end
        return idx
    end
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local list = active.objectives.list
    idx = #list + 1
    local desig = safe(A.get_objective_designation, keepId, objectiveId, ctx)
    list[idx] = {
        keepId = keepId,
        objectiveId = objectiveId,
        ctx = ctx,
        letter = (desig ~= nil and C.OBJ_LETTER[desig]) or tostring(idx),
        name = clean_name(name),
    }
    obj_lookup[key] = idx
    return idx
end

local function record_obj_event(idx, controlEvent, controlState, owner)
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local ob = active.objectives
    if #ob.t >= MAX_OBJ_EVENTS then return false end
    local last = obj_last[idx]
    if controlEvent == C.OBJ_EVENT_INFLUENCE and last
        and last.st == controlState and last.own == owner then
        return false
    end
    local slot = obj_last[idx]
    if slot then
        slot.st, slot.own = controlState, owner
    else
        obj_last[idx] = { st = controlState, own = owner }
    end
    local i = #ob.t + 1
    ob.t[i]   = (safe(A.now_ms) or 0) - (active.startMs or 0)
    ob.r[i]   = current_round()
    ob.o[i]   = idx
    ob.ev[i]  = controlEvent or -1
    ob.st[i]  = controlState or -1
    ob.own[i] = owner or -1
    return true
end

local function scan_objectives(reason)
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local Log = BGMeter.Log
    local n = safe(A.get_num_objectives) or 0
    for i = 1, n do
        local keepId, objectiveId, ctx = safe(A.get_objective_ids, i)
        if keepId and objectiveId then
            local isBg = safe(A.is_bg_objective, keepId, objectiveId, ctx)
            local otype = safe(A.get_objective_type, keepId, objectiveId, ctx)
            local name = safe(A.get_objective_info, keepId, objectiveId, ctx)
            if isBg and otype == C.OBJECTIVE_CAPTURE_AREA then
                local idx = register_objective(keepId, objectiveId, ctx, name)
                if idx then
                    local st = safe(A.get_objective_control_state, keepId, objectiveId, ctx)
                    local owner = safe(A.get_capture_area_owner, keepId, objectiveId, ctx)
                    record_obj_event(idx, -1, st, owner)
                    Log.debug("scan: [%s] %s st=%s own=%s ids=%s:%s",
                        tostring(active.objectives.list[idx].letter), tostring(clean_name(name)),
                        tostring(C.OBJ_STATE_LABEL[st] or st), tostring(owner),
                        tostring(keepId), tostring(objectiveId))
                end
            elseif isBg then
                Log.debug("scan: skipped non-capture-area objective type=%s name=%s ids=%s:%s",
                    tostring(otype), tostring(clean_name(name)), tostring(keepId), tostring(objectiveId))
            end
        end
    end
    Log.debug("objective scan (%s): %d total, %d capture areas tracked",
        tostring(reason), n, active and #active.objectives.list or 0)
end

function Capture.on_objective(_, keepId, objectiveId, ctx, name, controlEvent, controlState, owner)
    if not active or not active.objectives then return end
    local idx = register_objective(keepId, objectiveId, ctx, name)
    if not idx then return end
    if record_obj_event(idx, controlEvent, controlState, owner) then
        local C = BGMeter.zenimax.constants
        BGMeter.Log.debug("obj %s ev=%s st=%s own=%s",
            tostring(active.objectives.list[idx].letter),
            tostring(C.OBJ_EVENT_LABEL[controlEvent] or controlEvent),
            tostring(C.OBJ_STATE_LABEL[controlState] or controlState),
            tostring(owner))
    end
end

local function obj_elapsed()
    local A = BGMeter.zenimax.api
    return (safe(A.now_ms) or 0) - ((active and active.startMs) or 0)
end

local MAX_RELIC_EVENTS = 400
local caps_snap = {}

local function snap_caps()
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local round = current_round()
    local n = safe(A.get_num_entries, round) or 0
    for i = 1, n do
        local charName, disp = safe(A.get_entry_info, i, round)
        local nm = clean_name(disp or charName)
        if nm then
            caps_snap[nm] = read_score(i, C.SCORE_TRACKER_TYPE_FLAG_CAPTURED, round)
        end
    end
end

local function scan_goal(rl, evIdx, team)
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local round = current_round()
    local n = safe(A.get_num_entries, round) or 0
    local bestName, bestDelta = nil, 0
    for i = 1, n do
        local charName, disp, eteam = safe(A.get_entry_info, i, round)
        local nm = clean_name(disp or charName)
        if nm then
            local caps = read_score(i, C.SCORE_TRACKER_TYPE_FLAG_CAPTURED, round)
            local d = caps - (caps_snap[nm] or 0)
            caps_snap[nm] = caps
            if d > bestDelta and (not team or team == 0 or eteam == team) then
                bestName, bestDelta = nm, d
            end
        end
    end
    if bestName then
        rl.who[evIdx] = bestName
        BGMeter.Log.debug("goal attribution: %s (+%d caps) -> relic event %d", bestName, bestDelta, evIdx)
    else
        BGMeter.Log.debug("goal attribution: no caps delta visible for relic event %d", evIdx)
    end
end

local function record_relic_event(keepId, objectiveId, name, home, controlEvent, hold, last)
    local rl = active.relics
    if not rl or #rl.t >= MAX_RELIC_EVENTS then return nil end
    local key = obj_key(keepId, objectiveId)
    local idx = relic_lookup[key]
    if not idx then
        idx = #rl.list + 1
        rl.list[idx] = { keepId = keepId, objectiveId = objectiveId, name = clean_name(name), home = home }
        relic_lookup[key] = idx
    elseif home and home ~= 0 and not rl.list[idx].home then
        rl.list[idx].home = home
    end
    local i = #rl.t + 1
    rl.t[i]    = obj_elapsed()
    rl.r[i]    = current_round()
    rl.o[i]    = idx
    rl.ev[i]   = controlEvent or -1
    rl.hold[i] = hold or 0
    rl.last[i] = last or 0
    return i
end

function Capture.on_flag(_, keepId, objectiveId, ctx, name, controlEvent, controlState, origOwner, holder, lastHolder, pinType)
    if not active then return end
    local C = BGMeter.zenimax.constants
    local ei = record_relic_event(keepId, objectiveId, name, origOwner, controlEvent, holder, lastHolder)
    local evl = C.OBJ_EVENT_LABEL[controlEvent]
    if evl == "flag_taken" then
        snap_caps()
    elseif evl == "captured" and ei then
        local rl = active.relics
        local team = lastHolder
        local function attribute()
            if rl.who[ei] == nil then scan_goal(rl, ei, team) end
        end
        if type(zo_callLater) == "function" then
            zo_callLater(attribute, 800)
            zo_callLater(attribute, 2500)
            zo_callLater(attribute, 6000)
        else
            attribute()
        end
    end
    BGMeter.Log.debug("relic t=%s %s ev=%s st=%s orig=%s hold=%s last=%s pin=%s ids=%s:%s",
        BGMeter.Format.duration(obj_elapsed()), tostring(clean_name(name)),
        tostring(C.OBJ_EVENT_LABEL[controlEvent] or controlEvent),
        tostring(C.OBJ_STATE_LABEL[controlState] or controlState),
        tostring(origOwner), tostring(holder), tostring(lastHolder),
        tostring(pinType), tostring(keepId), tostring(objectiveId))
end

function Capture.on_murderball(_, keepId, objectiveId, ctx, name, controlEvent, controlState, holder, lastHolder, holderRaw, holderDisp, lastRaw, lastDisp, pinType)
    if not active then return end
    local C = BGMeter.zenimax.constants
    local ei = record_relic_event(keepId, objectiveId, name, nil, controlEvent, holder, lastHolder)
    if ei and C.OBJ_EVENT_LABEL[controlEvent] == "flag_taken" then
        active.relics.who[ei] = clean_name(holderDisp or holderRaw)
    end
    BGMeter.Log.debug("ball t=%s %s ev=%s st=%s hold=%s(%s) last=%s(%s) pin=%s ids=%s:%s",
        BGMeter.Format.duration(obj_elapsed()), tostring(clean_name(name)),
        tostring(C.OBJ_EVENT_LABEL[controlEvent] or controlEvent),
        tostring(C.OBJ_STATE_LABEL[controlState] or controlState),
        tostring(holder), tostring(clean_name(holderDisp) or clean_name(holderRaw) or "?"),
        tostring(lastHolder), tostring(clean_name(lastDisp) or clean_name(lastRaw) or "?"),
        tostring(pinType), tostring(keepId), tostring(objectiveId))
end

local function sample_scores()
    if not active or not active.timeline then return end
    local A = BGMeter.zenimax.api
    local tl = active.timeline
    local round = current_round()
    if active.lastRound and round ~= active.lastRound then
        BGMeter.Log.debug("round change: r%s -> r%s (rescanning objectives)",
            tostring(active.lastRound), tostring(round))
        scan_objectives("round change")
    end
    active.lastRound = round
    local i = #tl.t + 1
    tl.t[i] = (safe(A.now_ms) or 0) - (active.startMs or 0)
    tl.r[i] = round
    local teams = team_list()
    tl.s1[i] = (teams[1] ~= nil and safe(A.get_team_score, round, teams[1])) or 0
    tl.s2[i] = (teams[2] ~= nil and safe(A.get_team_score, round, teams[2])) or 0
    tl.s3[i] = (teams[3] ~= nil and safe(A.get_team_score, round, teams[3])) or 0
end

local function start_sampler()
    BGMeter.zenimax.events.register_update(SAMPLE_NAME, SAMPLE_MS, sample_scores)
end

local function stop_sampler()
    BGMeter.zenimax.events.unregister_update(SAMPLE_NAME)
end

function Capture.begin()
    local A = BGMeter.zenimax.api
    local Match = BGMeter.Match
    local Vet = BGMeter.Veterancy

    active = Match.new()
    active.startMs   = safe(A.now_ms) or 0
    active.bgId      = safe(A.get_bg_id)
    active.name      = clean_name(active.bgId and safe(A.get_bg_name, active.bgId) or nil)
    active.gameType  = safe(A.get_bg_game_type)
    active.localTeam = safe(A.get_local_team)
    active.teamSize  = active.bgId and safe(A.get_bg_team_size, active.bgId) or nil
    if active.teamSize then active.competitive = (active.teamSize == 4) end
    active.timeline  = { t = {}, r = {}, s1 = {}, s2 = {}, s3 = {}, teams = team_list() }
    active.killfeed  = {}
    active.objectives = { list = {}, t = {}, r = {}, o = {}, ev = {}, st = {}, own = {} }
    active.relics = { list = {}, t = {}, r = {}, o = {}, ev = {}, hold = {}, last = {}, who = {} }
    obj_lookup = {}
    obj_last = {}
    relic_lookup = {}
    caps_snap = {}

    baseline = {
        ap  = safe(A.get_alliance_points) or 0,
        cp  = safe(A.get_cp_earned) or 0,
        vet = Vet.snapshot(),
    }
    active.haul.vetStart = baseline.vet

    start_sampler()
    sample_scores()

    local C = BGMeter.zenimax.constants
    BGMeter.Log.debug("match begin: bg=%s id=%s gameType=%s rounds=%s localTeam=%s teamSize=%s competitive=%s ap0=%d",
        tostring(active.name), tostring(active.bgId),
        tostring(C.GAME_TYPE_LABEL[active.gameType] or active.gameType),
        tostring(active.bgId and safe(A.get_num_rounds, active.bgId)),
        tostring(active.localTeam), tostring(active.teamSize), tostring(active.competitive), baseline.ap)
    scan_objectives("match begin")
end

function Capture.on_ap(_, alliancePoints, _playSound, difference)
    if not active or not difference then return end
    active.haul.apGained = active.haul.apGained + difference
end

function Capture.on_xp(_, reason, _level, prev, current)
    if not active or not prev or not current then return end
    active.haul.xpGained = active.haul.xpGained + math.max(0, current - prev)
end

function Capture.on_cp(_, delta)
    if not active or not delta then return end
    active.haul.cpGained = active.haul.cpGained + delta
end

function Capture.on_reward_track(_, rewardTrackType, _trackId, prevTier, newTier)
    if not active then return end
    local C = BGMeter.zenimax.constants
    if rewardTrackType ~= C.REWARD_TRACK_TYPE_AVA_VETERANCY then return end
    if newTier and prevTier and newTier > prevTier then
        active.haul.vetRankUp = true
        BGMeter.Log.debug("veterancy tier up: %s -> %s", tostring(prevTier), tostring(newTier))
    end
end

function Capture.on_kill(_, killedChar, killedDisp, killedTeam, killerChar, killerDisp, killerTeam, killType)
    if not active or not active.killfeed then return end
    local A = BGMeter.zenimax.api
    local killer = clean_name(killerDisp or killerChar)
    local killed = clean_name(killedDisp or killedChar)
    BGMeter.Log.debug("bg kill: %s (t%s) killed %s (t%s) type=%s",
        tostring(killer), tostring(killerTeam),
        tostring(killed), tostring(killedTeam), tostring(killType))
    local myDisp = safe(A.get_display_name)
    local myChar = safe(A.get_char_name)
    local kind = nil
    if (killerDisp and killerDisp == myDisp) or (killerChar and killerChar == myChar) then
        kind = "kill"
    elseif (killedDisp and killedDisp == myDisp) or (killedChar and killedChar == myChar) then
        kind = "death"
    end
    local t = (safe(A.now_ms) or 0) - (active.startMs or 0)
    active.killfeed[#active.killfeed + 1] = {
        t = t, kind = kind,
        kn = killer, dn = killed,
        kt = killerTeam, dt = killedTeam,
        ty = killType,
    }
end

function Capture.finalize()
    if not active then return nil end
    local A = BGMeter.zenimax.api
    local Match = BGMeter.Match

    stop_sampler()
    sample_scores()

    active.endMs = safe(A.now_ms) or active.startMs
    active.capturedAt = safe(A.get_timestamp)
    active.result = read_result(active.localTeam)

    Capture.read_battle(active)
    read_teams(active)

    if baseline then
        local apNow = safe(A.get_alliance_points)
        local cpNow = safe(A.get_cp_earned)
        if apNow then active.haul.apGained = math.max(active.haul.apGained, apNow - baseline.ap) end
        if cpNow then active.haul.cpGained = math.max(active.haul.cpGained, cpNow - baseline.cp) end
    end

    active.haul.vetEnd = BGMeter.Veterancy.snapshot()
    local lr = Match.local_row(active)
    if lr then active.haul.medals = lr.medals end

    Match.derive(active)

    local finished = active
    active, baseline = nil, nil
    return finished
end

function Capture.rescan(reason)
    if not active then return end
    scan_objectives(reason)
end

function Capture.abort()
    if not active then return end
    stop_sampler()
    BGMeter.Log.debug("capture aborted (left battleground mid-match)")
    active, baseline = nil, nil
end

function Capture.is_active() return active ~= nil end

function Capture.live()
    if not active then return nil end
    local A = BGMeter.zenimax.api
    return active.name, (safe(A.now_ms) or 0) - (active.startMs or 0)
end

function Capture.snapshot_now()
    local A = BGMeter.zenimax.api
    local Match = BGMeter.Match
    local Vet = BGMeter.Veterancy
    local m = Match.new()
    m.bgId     = safe(A.get_bg_id)
    m.name     = clean_name(m.bgId and safe(A.get_bg_name, m.bgId) or nil)
    m.gameType = safe(A.get_bg_game_type)
    m.localTeam = safe(A.get_local_team)
    m.teamSize = m.bgId and safe(A.get_bg_team_size, m.bgId) or nil
    if m.teamSize then m.competitive = (m.teamSize == 4) end
    m.result   = read_result(m.localTeam)
    Capture.read_battle(m)
    read_teams(m)
    m.haul.vetEnd = Vet.snapshot()
    return m
end

BGMeter.Capture = Capture
