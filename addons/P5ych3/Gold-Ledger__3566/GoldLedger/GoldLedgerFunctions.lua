---------------------------------------------
--TIME FUNCTIONS
---------------------------------------------
function TimeFunctions_GetTimeZoneShift()
    local localTimeShift = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
	if localTimeShift < -43200 then
        return localTimeShift + 86400
    else
        return localTimeShift
    end
end

function TimeFunctions_GetLocalizedDate(timestamp, language)
    language = language or GetCVar("Language.2")

    --original, No longer required, seems to throw off log times..
    --local string = GetDateStringFromTimestamp(timestamp + TimeFunctions_GetTimeZoneShift())

    local string = GetDateStringFromTimestamp(timestamp) --P5YCH3 - Updated timestamp function.

    if language == "en" then
        return string
    else
        return string.gsub(string, "^(%d+)/(%d+)", "%2/%1")
    end
end

function TimeFunctions_GetLocalizedTime(timestamp, language)
    language = language or GetCVar("Language.2")
    local precision
    if (language == "en") then
        precision = TIME_FORMAT_PRECISION_TWELVE_HOUR
    else
        precision = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
    end
    return FormatTimeSeconds(timestamp % 86400 + TimeFunctions_GetTimeZoneShift(), TIME_FORMAT_STYLE_CLOCK_TIME, precision)
end

function TimeFunctions_GetLocalizedDateTime(...)
    return TimeFunctions_GetLocalizedDate(...) .. " " .. TimeFunctions_GetLocalizedTime(...)
end

---------------------------------------------
--TABLE FUNCTIONS
---------------------------------------------
-- Get numeric index of a value or nil
function table.indexOf(t, needle)
    for i = 1, #t do
        if t[i] == needle then
            return i
        end
    end
end