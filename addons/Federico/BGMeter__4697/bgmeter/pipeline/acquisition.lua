BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Acquisition = {}

local PREFIX = "BGMeter_"

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a = pcall(fn, ...)
    if not ok then return nil end
    return a
end

local function is_live_state(state)
    local C = BGMeter.zenimax.constants
    return state == C.BATTLEGROUND_STATE_STARTING
        or state == C.BATTLEGROUND_STATE_PREROUND
        or state == C.BATTLEGROUND_STATE_RUNNING
        or state == C.BATTLEGROUND_STATE_POSTROUND
end

local function on_state_change(_, previousState, currentState)
    local C = BGMeter.zenimax.constants
    local Capture = BGMeter.Capture

    BGMeter.Log.debug("bg state: %s -> %s",
        tostring(C.BG_STATE_LABEL[previousState] or previousState),
        tostring(C.BG_STATE_LABEL[currentState] or currentState))

    if not Capture.is_active() and is_live_state(currentState) then
        Capture.begin()
    end

    if currentState == C.BATTLEGROUND_STATE_RUNNING and Capture.is_active() then
        Capture.rescan("gates open")
    end

    if currentState == C.BATTLEGROUND_STATE_FINISHED then
        local match = Capture.finalize()
        if match then BGMeter.Pipeline.presentation.publish(match) end
    end
end

local function on_player_activated()
    local A = BGMeter.zenimax.api
    local Capture = BGMeter.Capture
    if safe(A.is_active_bg) then
        local st = safe(A.get_bg_state)
        if not Capture.is_active() and is_live_state(st) then
            Capture.begin()
        end
    else
        if Capture.is_active() then Capture.abort() end
        BGMeter.Pipeline.presentation.on_player_activated()
    end
end

function Acquisition.init()
    local E = BGMeter.zenimax.events
    local C = BGMeter.zenimax.constants
    local Capture = BGMeter.Capture

    E.register(PREFIX .. "State", C.EVENT_BATTLEGROUND_STATE_CHANGED, on_state_change)
    E.register(PREFIX .. "Act",   C.EVENT_PLAYER_ACTIVATED,          on_player_activated)
    E.register(PREFIX .. "AP",    C.EVENT_ALLIANCE_POINT_UPDATE,      Capture.on_ap)
    E.register(PREFIX .. "XP",    C.EVENT_EXPERIENCE_GAIN,            Capture.on_xp)
    E.register(PREFIX .. "CP",    C.EVENT_CHAMPION_POINT_GAINED,      Capture.on_cp)
    E.register(PREFIX .. "Vet",   C.EVENT_REWARD_TRACK_PROGRESS_GAINED, Capture.on_reward_track)
    E.register(PREFIX .. "Kill",  C.EVENT_BATTLEGROUND_KILL,          Capture.on_kill)
    E.register(PREFIX .. "Obj",   C.EVENT_CAPTURE_AREA_STATE_CHANGED, Capture.on_objective)
    if C.EVENT_CAPTURE_FLAG_STATE_CHANGED then
        E.register(PREFIX .. "Relic", C.EVENT_CAPTURE_FLAG_STATE_CHANGED, Capture.on_flag)
    end
    if C.EVENT_MURDERBALL_STATE_CHANGED then
        E.register(PREFIX .. "Ball", C.EVENT_MURDERBALL_STATE_CHANGED, Capture.on_murderball)
    end
    E.register(PREFIX .. "Board", C.EVENT_BATTLEGROUND_LEADERBOARD_DATA_RECEIVED, BGMeter.Standing.on_data)

    on_player_activated()

    BGMeter.Log.debug("acquisition wired")
end

BGMeter.Pipeline = BGMeter.Pipeline or {}
BGMeter.Pipeline.acquisition = Acquisition
