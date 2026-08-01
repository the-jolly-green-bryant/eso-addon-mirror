-- CharacterMarkdown - API Layer - Time
-- Abstraction for timestamp and date formatting

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.time = {}

local api = CM.api.time

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNow()
    return CM.SafeCall(GetTimeStamp) or 0
end

function api.FormatDate(timestamp)
    if not timestamp or timestamp == 0 then
        return ""
    end
    return CM.SafeCall(GetDateStringFromTimestamp, timestamp) or ""
end

function api.FormatDuration(seconds, style, precision)
    style = style or TIME_FORMAT_STYLE_DESCRIPTIVE
    precision = precision or TIME_FORMAT_PRECISION_SECONDS
    return ZO_FormatTime(seconds, style, precision)
end

-- Composition functions moved to collector level
