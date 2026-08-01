function ImperialCartographer_Logger(name)
    if not LibDebugLogger then return function(...) end end

    local logger = LibDebugLogger:Create(name or 'ImperialCartographer')
    logger:SetMinLevelOverride(LibDebugLogger.LOG_LEVEL_DEBUG)

    local level = LibDebugLogger.LOG_LEVEL_DEBUG

    local function inner(...)
        logger:Log(level, ...)
    end

    return inner
end