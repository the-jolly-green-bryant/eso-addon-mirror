--- LWTPriceInfoLogger - Structured logging utility for LWT Price Info
-- Provides leveled logging with optional file output for diagnostics.
-- Log levels: DEBUG, INFO, WARN, ERROR (increasing severity).
-- Usage: LWTPriceInfoLogger:Debug("message"), LWTPriceInfoLogger:Info("message"), etc.

local LOG_PREFIX = "[LWT-PI]"
local LOG_LEVELS = {
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
}

local currentLogLevel = LOG_LEVELS.INFO
local logBuffer = {}
local MAX_BUFFER_SIZE = 200

local LWTPriceInfoLogger = {}

--- Set the minimum log level. Messages below this level are suppressed.
-- @param level string One of "DEBUG", "INFO", "WARN", "ERROR"
function LWTPriceInfoLogger.SetLevel(level)
	if LOG_LEVELS[level] then
		currentLogLevel = LOG_LEVELS[level]
	end
end

--- Get the current log level name.
-- @return string Current log level name
function LWTPriceInfoLogger.GetLevel()
	for name, val in pairs(LOG_LEVELS) do
		if val == currentLogLevel then
			return name
		end
	end
	return "INFO"
end

--- Internal logging function
-- @param level number Log level value
-- @param levelName string Log level name
-- @param message string Log message
-- @param ... any Additional arguments (passed through tostring)
local function log(level, levelName, message, ...)
	if level < currentLogLevel then
		return
	end

	local extra = ""
	local n = select("#", ...)
	if n > 0 then
		local parts = {}
		for i = 1, n do
			parts[i] = tostring(select(i, ...))
		end
		extra = " | " .. table.concat(parts, ", ")
	end

	local logEntry = string.format("%s [%s] %s%s", LOG_PREFIX, levelName, tostring(message), extra)

	table.insert(logBuffer, logEntry)
	if #logBuffer > MAX_BUFFER_SIZE then
		table.remove(logBuffer, 1)
	end

	if level >= LOG_LEVELS.WARN then
		d(logEntry)
	end
end

--- Log a DEBUG message (lowest severity)
-- @param message string The message
-- @param ... any Additional context
function LWTPriceInfoLogger:Debug(message, ...)
	log(LOG_LEVELS.DEBUG, "DEBUG", message, ...)
end

--- Log an INFO message
-- @param message string The message
-- @param ... any Additional context
function LWTPriceInfoLogger:Info(message, ...)
	log(LOG_LEVELS.INFO, "INFO", message, ...)
end

--- Log a WARN message
-- @param message string The message
-- @param ... any Additional context
function LWTPriceInfoLogger:Warn(message, ...)
	log(LOG_LEVELS.WARN, "WARN", message, ...)
end

--- Log an ERROR message (highest severity)
-- @param message string The message
-- @param ... any Additional context
function LWTPriceInfoLogger:Error(message, ...)
	log(LOG_LEVELS.ERROR, "ERROR", message, ...)
end

--- Get all buffered log entries as a single string
-- @return string All log entries joined by newline
function LWTPriceInfoLogger.GetBuffer()
	return table.concat(logBuffer, "\n")
end

--- Clear the log buffer
function LWTPriceInfoLogger.ClearBuffer()
	logBuffer = {}
end

LWTPriceInfo.Logger = LWTPriceInfoLogger
