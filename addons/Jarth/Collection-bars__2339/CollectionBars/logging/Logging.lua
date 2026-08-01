--[[
Author: Jarth
Filename: Logging.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local loggers = base.Loggers
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function base:InitializeLog(...)
	if LibDebugLogger ~= nil and loggers.Logger == nil then
		loggers.Logger = LibDebugLogger(base.Addon.Name)
		loggers.Debug = loggers.Logger:Create("debug")
		loggers.Verbose = loggers.Logger:Create("verbose")
		base:Info(...)
		base:SetLogsEnabled()
	end
end

function base:SetLogsEnabled()
	if base.Saved then
		base:LogSetEnabled(loggers.Logger, base.Saved and base.Saved.Logging.Info, "Logging")
		base:LogSetEnabled(loggers.Debug, base.Saved and base.Saved.Logging.Debug, "Logging debug")
		base:LogSetEnabled(loggers.Verbose, base.Saved and base.Saved.Logging.Verbose, "Logging verbose")
	end
end

function base:LogSetEnabled(logger, doLogging, loggerType)
	if logger ~= nil then
		logger:SetEnabled(doLogging)
		logger:Info("LogSetEnabled:", loggerType, doLogging)
		return true
	end
end

function base:Info(...)
	if loggers.Logger ~= nil and ... ~= nil then
		loggers.Logger:Info(...)
	end
end

function base:Debug(...)
	if loggers.Debug ~= nil and ... ~= nil then
		loggers.Debug:Debug(...)
	end
end

function base:Verbose(...)
	if loggers.Verbose ~= nil and ... ~= nil then
		loggers.Verbose:Verbose(...)
	end
end
