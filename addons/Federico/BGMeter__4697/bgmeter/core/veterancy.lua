BGMeter = BGMeter or {}
local BGMeter = BGMeter

local V = {}

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d
end

local function read_track()
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local ttype = C.REWARD_TRACK_TYPE_AVA_VETERANCY
    if ttype == nil then return nil end

    local refId = safe(A.get_active_ref_track_ids, ttype)
    if not refId then return nil end
    local refIdx = safe(A.get_ref_track_index, ttype, refId)
    if not refIdx then return nil end

    local _trackId, currentRank, progressToNext, endTime = safe(A.get_info_for_reward_track, ttype, refIdx)
    if not currentRank then return nil end

    local rewardTrackId = safe(A.get_reward_track_id_from_ref, ttype, refId)
    local baseTiers = rewardTrackId and safe(A.get_num_base_tiers, rewardTrackId) or nil
    local repeatIdx = rewardTrackId and safe(A.get_repeatable_tier, rewardTrackId) or nil
    if (not repeatIdx or repeatIdx <= 0) and baseTiers and baseTiers > 0 then repeatIdx = baseTiers + 1 end

    local pastMax = baseTiers ~= nil and baseTiers > 0 and currentRank > baseTiers
    local totalIdx = pastMax and repeatIdx or currentRank
    local tierTotal = rewardTrackId and safe(A.get_tier_total_progress, rewardTrackId, totalIdx) or nil
    if pastMax and (not tierTotal or tierTotal <= 0) then
        tierTotal = safe(A.get_tier_total_progress, rewardTrackId, currentRank)
    end

    local claimed, claimable = nil, nil
    if pastMax then
        claimed, claimable = safe(A.get_repeatable_claimed, ttype, refIdx, repeatIdx, C.REWARD_TRACK_COMPONENT_PRIMARY)
    end

    local waiting = 0
    local component = C.REWARD_TRACK_COMPONENT_PRIMARY
    if rewardTrackId and baseTiers and baseTiers > 0 then
        local top = currentRank
        if top > baseTiers then top = baseTiers end
        for tier = 1, top do
            local n = safe(A.get_num_rewards_at_tier, rewardTrackId, tier, component) or 0
            if n > 0 then
                local isClaimed = safe(A.get_reward_claimed_state, ttype, refIdx, tier, component, 1)
                if isClaimed == false then waiting = waiting + n end
            end
        end
    end
    if pastMax and claimable and claimable > 0 then waiting = waiting + claimable end
    local has_unclaimed = safe(A.has_unclaimed_rewards, ttype, refIdx) == true
    if has_unclaimed and waiting == 0 then waiting = 1 end

    return {
        tier           = currentRank,
        progressToNext = progressToNext or 0,
        tierTotal      = tierTotal,
        endTime        = endTime,
        rewardTrackId  = rewardTrackId,
        baseTiers      = baseTiers,
        repeatIdx      = repeatIdx,
        pastMax        = pastMax,
        claimed        = claimed,
        claimable      = claimable,
        waiting        = waiting,
        refIdx         = refIdx,
    }
end

local function fold_laps(track)
    local within = track.progressToNext or 0
    local total = track.tierTotal
    local laps = 0
    if track.pastMax then
        if total and total > 0 and within >= total then
            laps = math.floor(within / total)
            within = within - laps * total
        end
        if track.repeatIdx and track.tier > track.repeatIdx then
            laps = laps + (track.tier - track.repeatIdx)
        end
        if track.claimed and track.claimed > laps then laps = track.claimed end
    end
    return within, laps
end

function V.snapshot()
    local A = BGMeter.zenimax.api
    local snap = {}

    snap.seasonActive = safe(A.is_veterancy_season_active) and true or false
    snap.seasonId     = safe(A.get_season_id)
    snap.seasonName   = safe(A.get_season_name)
    snap.secondsLeft  = safe(A.get_season_time_remaining)
    snap.inZone       = safe(A.is_in_veterancy_zone) and true or false

    local track = read_track()

    local rank = safe(A.get_unit_veterancy_rank)
    snap.rank = rank
    if rank then
        local cap = track and track.baseTiers
        local shown = (cap and cap > 0 and rank > cap) and cap or rank
        snap.iconRank  = shown
        snap.rankTitle = safe(A.get_veterancy_rank_title, shown, snap.seasonId)
        snap.rankIcon  = safe(A.get_veterancy_large_icon, shown, snap.seasonId)
                      or safe(A.get_veterancy_rank_icon, shown, snap.seasonId)
    end

    if track then
        local within, laps = fold_laps(track)
        snap.tier           = track.tier
        snap.rawProgress    = track.progressToNext
        snap.progressToNext = within
        snap.tierTotal      = track.tierTotal
        snap.pastMax        = track.pastMax
        snap.laps           = laps
        snap.claimable      = track.waiting or 0
        if track.tierTotal == nil then snap.percent = nil
        elseif track.tierTotal == 0 then snap.percent = 1
        else snap.percent = math.min(1, within / track.tierTotal) end
    end

    return snap
end

function V.claimable()
    local track = read_track()
    if not track then return 0 end
    return track.waiting or 0
end

function V.claim()
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local track = read_track()
    if not track or (track.waiting or 0) <= 0 then return false end
    if type(A.claim_all_rewards) ~= "function" then return false end
    local ok = pcall(A.claim_all_rewards, C.REWARD_TRACK_TYPE_AVA_VETERANCY, track.refIdx)
    return ok == true
end

function V.progress_value(snap)
    if not snap then return 0 end
    local tier = (snap.tier or 0) + (snap.laps or 0)
    local within = snap.progressToNext or 0
    return tier * 1000000 + within
end

function V.raw_lines()
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local K = BGMeter.Constants
    local out = {}
    local function add(k, ...)
        local parts, n = {}, 0
        for i = 1, select("#", ...) do
            if (select(i, ...)) ~= nil then n = i end
        end
        for i = 1, n do parts[i] = tostring((select(i, ...))) end
        out[#out + 1] = string.format("%-22s %s", k, n > 0 and table.concat(parts, "  ") or "nil")
    end
    add("bgmeter", K.VERSION)
    add("api", safe(A.get_api_version))
    add("season_active", safe(A.is_veterancy_season_active))
    add("season_id", safe(A.get_season_id))
    add("season_name", safe(A.get_season_name))
    add("in_zone", safe(A.is_in_veterancy_zone))
    add("unit_rank", safe(A.get_unit_veterancy_rank))
    local ttype = C.REWARD_TRACK_TYPE_AVA_VETERANCY
    add("track_type", ttype)
    local refId = safe(A.get_active_ref_track_ids, ttype)
    add("ref_track_id", refId)
    local refIdx = refId and safe(A.get_ref_track_index, ttype, refId)
    add("ref_track_index", refIdx)
    local rewardTrackId = refId and safe(A.get_reward_track_id_from_ref, ttype, refId)
    add("reward_track_id", rewardTrackId)
    local _t, cur, prog, endTime
    if refIdx then _t, cur, prog, endTime = safe(A.get_info_for_reward_track, ttype, refIdx) end
    add("info.track_id", _t)
    add("info.current_rank", cur)
    add("info.progress", prog)
    add("info.end_time", endTime)
    local base = rewardTrackId and safe(A.get_num_base_tiers, rewardTrackId)
    add("base_tiers", base)
    add("has_repeatable", rewardTrackId and safe(A.has_repeatable_tier, rewardTrackId))
    local rep = rewardTrackId and safe(A.get_repeatable_tier, rewardTrackId)
    add("repeatable_index", rep)
    if rewardTrackId then
        add("total@current", cur and safe(A.get_tier_total_progress, rewardTrackId, cur))
        add("total@repeatable", rep and safe(A.get_tier_total_progress, rewardTrackId, rep))
        add("total@base", base and safe(A.get_tier_total_progress, rewardTrackId, base))
        add("total@base+1", base and safe(A.get_tier_total_progress, rewardTrackId, base + 1))
        add("total@base+2", base and safe(A.get_tier_total_progress, rewardTrackId, base + 2))
    end
    if refIdx and rep then
        add("repeat_claimed", safe(A.get_repeatable_claimed, ttype, refIdx, rep, C.REWARD_TRACK_COMPONENT_PRIMARY))
    end
    local s = V.snapshot()
    add("snap.tier", s.tier)
    add("snap.raw_progress", s.rawProgress)
    add("snap.progress", s.progressToNext)
    add("snap.total", s.tierTotal)
    add("snap.percent", s.percent)
    add("snap.past_max", s.pastMax)
    add("snap.laps", s.laps)
    add("has_unclaimed", refIdx and safe(A.has_unclaimed_rewards, ttype, refIdx))
    add("snap.waiting", s.claimable)
    add("snap.icon_rank", s.iconRank)
    add("snap.title", s.rankTitle)
    return out
end

BGMeter.Veterancy = V
