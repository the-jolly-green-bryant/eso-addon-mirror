--#region LOGGER
function IMP_PVP_UI_Logger(name)
    if not LibDebugLogger then return function(...) end end

    local logger = LibDebugLogger:Create(name or 'IMP_PVP_UI')
    logger:SetMinLevelOverride(LibDebugLogger.LOG_LEVEL_DEBUG)

    local level = LibDebugLogger.LOG_LEVEL_DEBUG

    local function inner(...)
        logger:Log(level, ...)
    end

    return inner
end
--#endregion LOGGER