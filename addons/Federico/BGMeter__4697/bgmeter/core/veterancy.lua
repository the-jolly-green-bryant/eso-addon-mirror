
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
    local tierTotal = rewardTrackId and safe(A.get_tier_total_progress, rewardTrackId, currentRank) or nil

    return {
        tier           = currentRank,
        progressToNext = progressToNext or 0,
        tierTotal      = tierTotal,
        endTime        = endTime,
    }
end

function V.snapshot()
    local A = BGMeter.zenimax.api
    local snap = {}

    snap.seasonActive = safe(A.is_veterancy_season_active) and true or false
    snap.seasonId     = safe(A.get_season_id)
    snap.seasonName   = safe(A.get_season_name)
    snap.secondsLeft  = safe(A.get_season_time_remaining)
    snap.inZone       = safe(A.is_in_veterancy_zone) and true or false

    local rank = safe(A.get_unit_veterancy_rank)
    snap.rank = rank
    if rank then
        snap.rankTitle = safe(A.get_veterancy_rank_title, rank, snap.seasonId)
        snap.rankIcon  = safe(A.get_veterancy_large_icon, rank, snap.seasonId)
                      or safe(A.get_veterancy_rank_icon, rank, snap.seasonId)
    end

    local track = read_track()
    if track then
        snap.tier           = track.tier
        snap.progressToNext = track.progressToNext
        snap.tierTotal      = track.tierTotal
        if track.tierTotal == nil then snap.percent = nil
        elseif track.tierTotal == 0 then snap.percent = 1
        else snap.percent = track.progressToNext / track.tierTotal end
    end

    return snap
end

function V.progress_value(snap)
    if not snap then return 0 end
    local tier = snap.tier or 0
    local within = snap.progressToNext or 0
    return tier * 1000000 + within
end

BGMeter.Veterancy = V
