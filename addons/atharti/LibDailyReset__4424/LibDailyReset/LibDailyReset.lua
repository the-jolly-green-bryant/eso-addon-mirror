LibDailyReset = {}
LibDailyReset.name = "LibDailyReset"

local LDR = LibDailyReset
LDR.callbacks = {}
LDR.initialized = false
LDR.sv = nil

local WORLD_NAME = GetWorldName()

local SERVER_RESET_HOURS = {
    ["EU Megaserver"] = 3,
    ["NA Megaserver"] = 10,
    ["PTS"] = 10,
}

local RESET_TIMER_EVENT = LDR.name .. "_ResetTimer"

--------------------------------------------------
-- Internal Helpers
--------------------------------------------------

local function GetServerResetHourUTC()
    return SERVER_RESET_HOURS[WORLD_NAME]
end

local function GetServerDayNumber()
    local now = GetTimeStamp()
    local resetHour = GetServerResetHourUTC()

    local dateTable = os.date("!*t", now)

    if dateTable.hour < resetHour then
        now = now - 86400
    end

    return math.floor(now / 86400)
end

--------------------------------------------------
-- Public API
--------------------------------------------------

function LDR.IsNewDay()
    local currentDay = GetServerDayNumber()
    return currentDay ~= LDR.sv.lastKnownDay
end

function LDR.GetCurrentServerDay()
    return GetServerDayNumber()
end

function LDR.GetSecondsUntilReset()
    return GetTimeUntilNextDailyLoginRewardClaimS()
end

--------------------------------------------------
-- Callback System
--------------------------------------------------

function LDR:RegisterCallback(name, func)
    LDR.callbacks[name] = LDR.callbacks[name] or {}
    table.insert(LDR.callbacks[name], func)
end

function LDR:UnregisterCallback(name, func)
    if not LDR.callbacks[name] then return end

    for i, f in ipairs(LDR.callbacks[name]) do
        if f == func then
            table.remove(LDR.callbacks[name], i)
            return
        end
    end
end

local function FireCallbacks(name)
    if not LDR.callbacks[name] then return end
    for _, func in ipairs(LDR.callbacks[name]) do
        func()
    end
end

--------------------------------------------------
-- Reset Scheduler
--------------------------------------------------

local function ScheduleNextReset()
    local secondsUntilReset = GetTimeUntilNextDailyLoginRewardClaimS()

    EVENT_MANAGER:UnregisterForUpdate(RESET_TIMER_EVENT)

    EVENT_MANAGER:RegisterForUpdate(
        RESET_TIMER_EVENT,
        secondsUntilReset * 1000,
        function()
            FireCallbacks("OnDailyReset")

            local currentDay = GetServerDayNumber()
            if currentDay <= LDR.sv.lastKnownDay then
                LDR.sv.lastKnownDay = LDR.sv.lastKnownDay + 1
            else
                LDR.sv.lastKnownDay = currentDay
            end

            ScheduleNextReset()
        end
    )
end

--------------------------------------------------
-- Debug Slash Command
--------------------------------------------------

SLASH_COMMANDS["/ldrdebug"] = function()
    local server = GetWorldName()
    local now = GetTimeStamp()
    local dateTableUTC = os.date("!*t", now)
    local dateStr = string.format("%04d-%02d-%02d %02d:%02d:%02d UTC",
        dateTableUTC.year, dateTableUTC.month, dateTableUTC.day,
        dateTableUTC.hour, dateTableUTC.min, dateTableUTC.sec
    )

    local serverDay = LDR.GetCurrentServerDay()
    local secondsUntilReset = LDR.GetSecondsUntilReset()

    d("=== LibDailyReset Debug ===")
    d("Server: " .. server)
    d("UTC Date/Time: " .. dateStr)
    d("Server Day Number: " .. serverDay)
    d("Saved Last Known Day: " .. tostring(LDR.sv.lastKnownDay))
    d("Seconds Until Next Reset (API): " .. tostring(secondsUntilReset))
    d("==========================")
end

SLASH_COMMANDS["/ldrtestreset"] = function()
    LDR.sv.lastKnownDay = LDR.GetCurrentServerDay() - 1
    if LDR.IsNewDay() then
        LDR.sv.lastKnownDay = LDR.GetCurrentServerDay()
        d("LibDailyReset: Forced reset triggered!")
        FireCallbacks("OnDailyReset")
    end
end

--------------------------------------------------
-- Initialization
--------------------------------------------------

function LDR.Initialize()
    if LDR.initialized then return end
    LDR.initialized = true

    EVENT_MANAGER:UnregisterForEvent(LDR.name, EVENT_ADD_ON_LOADED)

    local currentDay = GetServerDayNumber()

    LDR.sv = ZO_SavedVars:NewAccountWide(
        "LibDailyReset_SavedVariables",
        1,
        nil,
        {
            lastKnownDay = currentDay
        }
    )

    EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(LDR.name, EVENT_PLAYER_ACTIVATED)

        local currentDay = GetServerDayNumber()

        if currentDay ~= LDR.sv.lastKnownDay then
            LDR.sv.lastKnownDay = currentDay
            FireCallbacks("OnDailyReset")
        end

        ScheduleNextReset()
    end)
end

EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == LDR.name then
        LDR.Initialize()
    end
end)