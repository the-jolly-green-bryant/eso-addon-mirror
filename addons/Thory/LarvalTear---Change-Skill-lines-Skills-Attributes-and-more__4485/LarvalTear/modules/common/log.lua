local Addon = LarvalTearMod
local M = Addon.Common.Log
local LOGGER_STATE = Addon.Common.LoggerState
local LOGGER_ROOT_TAG = "LarvalTear"

local LOG_KIND_CHAT = "Chat"
local LOG_KIND_DEBUG = "Debug"
local LOG_KIND_SUMMARY = "Summary"
local LOG_KIND_ERROR = "Error"

local function FormatMessage(...)
    local parts = { ... }
    for index = 1, #parts do
        parts[index] = tostring(parts[index])
    end

    return table.concat(parts, " ")
end

local function HasSavedVars()
    return type(Addon.savedVars) == "table"
end

local function HasLibDebugLogger()
    return type(LibDebugLogger) == "table" and type(LibDebugLogger.Create) == "function"
end

local function GetLoggerRoot()
    if not HasLibDebugLogger() then
        return nil
    end

    local existing = rawget(LOGGER_STATE, "root")
    if existing ~= nil then
        return existing or nil
    end

    local ok, logger = pcall(function()
        return LibDebugLogger:Create(LOGGER_ROOT_TAG)
    end)
    if ok and logger ~= nil then
        LOGGER_STATE.root = logger
        return logger
    end

    LOGGER_STATE.root = false
    return nil
end

local function GetNamedLogger(kind)
    local root = GetLoggerRoot()
    if root == nil then
        return nil
    end

    local loggers = rawget(LOGGER_STATE, "children")
    if type(loggers) ~= "table" then
        loggers = {}
        LOGGER_STATE.children = loggers
    end

    local existing = loggers[kind]
    if existing ~= nil then
        return existing or nil
    end

    local ok, logger = pcall(function()
        return root:Create(kind)
    end)
    if ok and logger ~= nil then
        loggers[kind] = logger
        return logger
    end

    loggers[kind] = false
    return nil
end

function M.GetChildLogger(kind)
    if type(kind) ~= "string" or kind == "" then
        return nil
    end
    return GetNamedLogger(kind)
end

local function ApplyLoggerOverrides(logger)
    if logger == nil or type(logger.SetMinLevelOverride) ~= "function" then
        return
    end

    if M.IsDebugEnabled() then
        logger:SetMinLevelOverride("D")
    else
        logger:SetMinLevelOverride(nil)
    end
end

local function EmitStructured(kind, level, message)
    local logger = GetNamedLogger(kind)
    if logger == nil or type(message) ~= "string" or message == "" then
        return
    end

    ApplyLoggerOverrides(logger)

    local method = logger[level]
    if type(method) ~= "function" then
        return
    end

    method(logger, message)
end

local function IsPrintMessagesEnabled()
    if type(Addon.savedVars) ~= "table" then
        return true
    end

    return Addon:IsPrintMessagesEnabled()
end

local function IsErrorOrWarningMessage(message)
    local text = string.lower(tostring(message or ""))
    if text == "" then
        return false
    end

    return string.find(text, "error", 1, true) ~= nil
        or string.find(text, "warn", 1, true) ~= nil
        or string.find(text, "failed", 1, true) ~= nil
        or string.find(text, "fail", 1, true) ~= nil
        or string.find(text, "cannot", 1, true) ~= nil
        or string.find(text, "invalid", 1, true) ~= nil
        or string.find(text, "unavailable", 1, true) ~= nil
        or string.find(text, "detected", 1, true) ~= nil
        or string.find(text, "required", 1, true) ~= nil
        or string.find(text, "differs", 1, true) ~= nil
        or string.find(text, "skipped", 1, true) ~= nil
        or string.find(text, "エラー", 1, true) ~= nil
        or string.find(text, "警告", 1, true) ~= nil
        or string.find(text, "失敗", 1, true) ~= nil
        or string.find(text, "できません", 1, true) ~= nil
        or string.find(text, "利用できません", 1, true) ~= nil
        or string.find(text, "検出", 1, true) ~= nil
        or string.find(text, "異な", 1, true) ~= nil
        or string.find(text, "不足", 1, true) ~= nil
end

function M.IsDebugEnabled()
    return HasSavedVars() and Addon.savedVars.debugRunCompact == true
end

local function EmitNormal(message)
    local formatted = string.format("[LTM] %s", tostring(message))
    if IsPrintMessagesEnabled() or IsErrorOrWarningMessage(message) then
        d(formatted)
    end
    EmitStructured(LOG_KIND_CHAT, "Info", formatted)
end

local function EmitImportant(message)
    local formatted = string.format("[LTM] %s", tostring(message))
    d(formatted)
    EmitStructured(LOG_KIND_CHAT, "Info", formatted)
end

local function EmitDebug(message)
    if not M.IsDebugEnabled() then
        return
    end

    local formatted = string.format("[LTM][DEBUG] %s", tostring(message))
    EmitStructured(LOG_KIND_DEBUG, "Debug", formatted)
end

local function EmitDebugSummary(message)
    if not M.IsDebugEnabled() then
        return
    end

    local formatted = string.format("[LTM][DEBUG] %s", tostring(message))
    EmitStructured(LOG_KIND_SUMMARY, "Debug", formatted)
end

local function EmitError(message)
    local formatted = string.format("[LTM] %s", tostring(message))
    d(formatted)
    EmitStructured(LOG_KIND_ERROR, "Error", formatted)
end

function M.WriteChat(...)
    EmitNormal(FormatMessage(...))
end

function M.WriteImportantChat(...)
    EmitImportant(FormatMessage(...))
end

local function ReplaceParams(text, params)
    if type(text) ~= "string" then
        return ""
    end

    return (text:gsub("{([%w_]+)}", function(key)
        local value = type(params) == "table" and params[key] or nil
        if value == nil then
            return ""
        end

        return tostring(value)
    end))
end

local function GetStringValue(stringIdName, fallback, params)
    if type(stringIdName) ~= "string" or stringIdName == "" then
        return fallback
    end

    local stringId = rawget(_G, stringIdName)
    local value = type(GetString) == "function" and stringId ~= nil and GetString(stringId) or nil
    if type(value) ~= "string" or value == "" or value == stringIdName then
        value = fallback
    end

    return ReplaceParams(value, params)
end

function M.LogStart(buildName)
    EmitNormal(GetStringValue("SI_LTM_LOG_RESPEC_START", "{buildName} Respec Start", {
        buildName = tostring(buildName or GetStringValue("SI_LTM_COMMON_BUILD", "Build")),
    }))
end

function M.LogEnd(buildName)
    EmitNormal(GetStringValue("SI_LTM_LOG_RESPEC_END", "{buildName} Respec End", {
        buildName = tostring(buildName or GetStringValue("SI_LTM_COMMON_BUILD", "Build")),
    }))
end

function M.LogDebugSaved()
    if not M.IsDebugEnabled() then
        return
    end

    EmitNormal("debug log saved.")
end

local function NormalizeReasonStringIdName(reason)
    if type(reason) ~= "string" or reason == "" then
        return nil
    end

    local normalized = string.upper(reason)
    normalized = string.gsub(normalized, "[^%w]+", "_")
    normalized = string.gsub(normalized, "_+", "_")
    normalized = string.gsub(normalized, "^_", "")
    normalized = string.gsub(normalized, "_$", "")
    if normalized == "" then
        return nil
    end

    return "SI_LTM_ERROR_REASON_" .. normalized
end

local function GetLocalizedStringByName(stringIdName)
    if type(stringIdName) ~= "string" or stringIdName == "" then
        return nil
    end

    local stringId = rawget(_G, stringIdName)
    if stringId == nil or type(GetString) ~= "function" then
        return nil
    end

    local text = GetString(stringId)
    if type(text) ~= "string" or text == "" or text == stringIdName then
        return nil
    end

    return text
end

function M.ResolveLocalizedErrorReason(reason)
    return GetLocalizedStringByName(NormalizeReasonStringIdName(reason))
end

function M.LocalizeErrorReason(reason)
    local localized = M.ResolveLocalizedErrorReason(reason)
    if localized ~= nil then
        return localized
    end

    return tostring(reason or "unknown_error")
end

function M.LogError(buildName, phase, target, reason)
    EmitError(GetStringValue("SI_LTM_LOG_ERROR", "Error: {phase} {target} failed. Reason: {reason}", {
        phase = tostring(phase or GetStringValue("SI_LTM_COMMON_UNKNOWN", "Unknown")),
        target = tostring(target or GetStringValue("SI_LTM_COMMON_TARGET", "Target")),
        reason = M.LocalizeErrorReason(reason),
    }))
end

function M.LogSavedVarsMigrationError()
    EmitError(GetStringValue(
        "SI_LTM_LOG_SAVED_VARS_MIGRATION_FAILED",
        "SavedVariables migration failed. Backing up your SavedVariables and reviewing them is recommended."
    ))
end

function M.Debug(...)
    if not M.IsDebugEnabled() then
        return
    end

    EmitDebug(FormatMessage(...))
end

function M.LogDebugSummary(...)
    if not M.IsDebugEnabled() then
        return
    end

    EmitDebugSummary(FormatMessage(...))
end

function M.IsSummaryDebugEnabled()
    return M.IsDebugEnabled()
end
