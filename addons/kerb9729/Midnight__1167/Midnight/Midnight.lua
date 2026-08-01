Midnight = {}
Midnight.name = "Midnight"

local function midnight()
    local tst = GetTST()
    local h = tst[1]
    local m = tst[2]
    local tzoffset = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
    if tzoffset < -12 * 60 * 60 then tzoffset = tzoffset + 86400 end

    -- Seconds till midnight
    --local stm = (((24 - h) * 3600) + ((60 - m) * 60)) / 4.1

    local stm = (((24 - h) * 3600) - ((60 - m) * 60)) / 4.1

    -- Seconds till 10 pm
    local sttpm = (((22 - h) * 3600) - ((60 - m) * 60)) / 4.1

    -- midnight timestamp
    local mts = GetTimeStamp() + tzoffset + stm

    -- 10pm timestamp
    local tts = GetTimeStamp() + tzoffset + sttpm

    d("Midnight in : " .. FormatTimeSeconds(stm, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_NONE))
    d("Midnight at : " .. FormatTimeSeconds(mts,
        TIME_FORMAT_STYLE_CLOCK_TIME,
        TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR,
        TIME_FORMAT_DIRECTION_NONE))
    d("10pm at : " .. FormatTimeSeconds(tts,
        TIME_FORMAT_STYLE_CLOCK_TIME,
        TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR,
        TIME_FORMAT_DIRECTION_NONE))
end

SLASH_COMMANDS["/midnight"] = midnight

