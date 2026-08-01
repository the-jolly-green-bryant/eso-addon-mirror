local Addon = LarvalTearMod
local LTM_SKILL_RESPEC_LOGGING = Addon.Modules.SkillRespecLogging
local M = LTM_SKILL_RESPEC_LOGGING
local Log = Addon.Common.Log
local SHARED_UTIL = Addon.Common.Util

function M.IsSummaryDebugEnabled()
    return type(Log.IsSummaryDebugEnabled) == "function" and Log.IsSummaryDebugEnabled() == true
end

function M.Log(...)
    if not M.IsSummaryDebugEnabled() then
        return
    end

    local parts = { ... }
    for index = 1, #parts do
        parts[index] = tostring(parts[index])
    end

    local message = "Skill respec " .. table.concat(parts, " ")
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(message)
    end
end

function M.FormatLineIdList(lineIds)
    if type(lineIds) ~= "table" or #lineIds == 0 then
        return "(none)"
    end

    local values = {}
    for index, lineId in ipairs(lineIds) do
        values[index] = tostring(lineId)
    end
    return table.concat(values, ",")
end

function M.FormatValueList(values)
    if type(values) ~= "table" or #values == 0 then
        return "(none)"
    end

    local formatted = {}
    for index, value in ipairs(values) do
        formatted[index] = tostring(value)
    end
    return table.concat(formatted, ",")
end

function M.BuildLineIdSignature(lineIds)
    return SHARED_UTIL:BuildLineIdSignature(lineIds)
end

function M.FormatOrderedOperations(operations)
    if type(operations) ~= "table" or #operations == 0 then
        return "(none)"
    end

    local values = {}
    for index, operation in ipairs(operations) do
        values[index] = string.format(
            "%s:%s:%s",
            tostring(operation.op),
            tostring(operation.skillLineId),
            tostring(operation.priority)
        )
    end
    return table.concat(values, ",")
end

function M.BuildReasonSummary(entries)
    if type(entries) ~= "table" or #entries == 0 then
        return "(none)"
    end

    local counts = {}
    local orderedReasons = {}
    for _, entry in ipairs(entries) do
        local reason = type(entry) == "table" and tostring(entry.reason or "unknown") or "unknown"
        if counts[reason] == nil then
            counts[reason] = 0
            orderedReasons[#orderedReasons + 1] = reason
        end
        counts[reason] = counts[reason] + 1
    end

    local parts = {}
    for _, reason in ipairs(orderedReasons) do
        parts[#parts + 1] = tostring(reason) .. "=" .. tostring(counts[reason] or 0)
    end
    return table.concat(parts, ",")
end

function M.FormatReasonCounts(reasonCounts)
    if type(reasonCounts) ~= "table" then
        return "(none)"
    end

    local reasons = {}
    for reason in pairs(reasonCounts) do
        reasons[#reasons + 1] = tostring(reason)
    end
    table.sort(reasons)

    local parts = {}
    for _, reason in ipairs(reasons) do
        parts[#parts + 1] = reason .. "=" .. tostring(reasonCounts[reason] or 0)
    end
    return #parts > 0 and table.concat(parts, ",") or "(none)"
end
