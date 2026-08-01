local ADK = AntiDK2
local M   = {}
ADK.Combat.Events.Corrosive = M

local ID = ADK.IDS.CORROSIVE_ARMOR

-- per-second window state
local hitsThisWindow = 0
local windowHandle   = nil

-- in-range duration state
local inRange        = false
local rangeStart     = 0
local tickHandle     = nil

local function FormatElapsed()
    local elapsed = math.floor((GetFrameTimeMilliseconds() - rangeStart) / 1000)
    return string.format("%d:%02d", math.floor(elapsed / 60), elapsed % 60)
end

local function StartDurationTick()
    if tickHandle then return end
    tickHandle = zo_callLater(function()
        tickHandle = nil
        if inRange then
            ADK.UI.Corrosive.UpdateTimer(FormatElapsed())
            StartDurationTick()
        end
    end, 1000)
end

local function OnHit(result)
    hitsThisWindow = hitsThisWindow + 1
    -- Use ACTION_RESULT_CRITICAL_DAMAGE which is a confirmed ESO constant
    local isCrit = (result == ACTION_RESULT_DOT_TICK_CRITICAL)
    if not inRange then
        inRange    = true
        rangeStart = GetFrameTimeMilliseconds()
        StartDurationTick()
    end
    ADK.UI.Corrosive.Show(hitsThisWindow, isCrit)
    if windowHandle then zo_removeCallLater(windowHandle) end
    windowHandle = zo_callLater(function()
        windowHandle   = nil
        hitsThisWindow = 0
    end, 1000)
end

local function StopTracking()
    inRange        = false
    hitsThisWindow = 0
    if tickHandle   then zo_removeCallLater(tickHandle);   tickHandle   = nil end
    if windowHandle then zo_removeCallLater(windowHandle); windowHandle = nil end
    ADK.UI.Corrosive.Hide()
end

function M.Register()
    EVENT_MANAGER:RegisterForEvent(
        ADK.name .. "_Corrosive", EVENT_COMBAT_EVENT,
        function(_, result, _, _, _, _, sourceName, sourceType, targetName, _, _, _, _, _, _, targetUnitId, abilityId)
            if not ADK.savedVars.trackCorrosive  then return end
            if abilityId ~= ID                   then return end
            local name = zo_strformat("<<1>>", sourceName)
            if name == GetUnitName("player") then return end
            local tName = zo_strformat("<<1>>", targetName)
            if tName ~= GetUnitName("player") then return end
            if result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL then
                OnHit(result)
            end
            --ADK.Combat.Events.Wings.TrackEnemy(sourceName, sourceType)
            if sourceType == COMBAT_UNIT_TYPE_PLAYER then return end
            -- Accept any damage result (DOT_TICK constant not available in all ESO builds)
        end
    )
end

function M.Unregister()
    EVENT_MANAGER:UnregisterForEvent(ADK.name .. "_Corrosive", EVENT_COMBAT_EVENT)
end

function M.Reset()
    StopTracking()
end