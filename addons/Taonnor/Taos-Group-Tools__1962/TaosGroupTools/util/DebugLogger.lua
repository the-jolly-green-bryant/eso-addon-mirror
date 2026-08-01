--[[
	Addon: util
	Author: TProg Taonnor
	Created by @Taonnor
]]--

-- Version Control
local VERSION = 6

--[[
	Local variables
]]--
local LIBMW = LibStub("LibMsgWin-1.0", true)
if(not LIBMW) then
	error("Cannot load without LibMsgWin-1.0")
end

--[[
	Class definition
]]--
-- A table in hole lua workspace must be unique
-- The debug logger is global util table, used in several of my addons
if (TaosDebugLogger == nil or TaosDebugLogger.Version == nil or TaosDebugLogger.Version < VERSION) then
	TaosDebugLogger = {}
	TaosDebugLogger.__index = TaosDebugLogger
    TaosDebugLogger.Version = VERSION

	setmetatable(TaosDebugLogger, {
		__call = function (cls, ...)
			return cls.new(...)
		end,
	})

	--[[
		Class constructor
	]]--
	function TaosDebugLogger.new(name, command, traceActive, debugActive, errorActive, directPrint, catchLuaErrors, logFile)
		local self = setmetatable({}, TaosDebugLogger)
		
		-- class members
		self.name = name
        self.logFileName = logFile
		self.buffer = {}
        self.lastTraceTimestamp = GetGameTimeMilliseconds()

        self.loggerMessageWindow = LIBMW:CreateMsgWindow(name .. "LogWindow", name .. " Log Window")
        self.loggerMessageWindow:SetDimensions(768, 256)
        self.loggerMessageWindow.WindowFrame = _G[name .. "LogWindow"]
        self.loggerMessageWindow.WindowFrame:SetHidden(true)
        self.loggerMessageWindow.buffer = _G[name .. "LogWindow" .. "Buffer"]
        self.loggerMessageWindow.buffer:SetMaxHistoryLines(1000)

		self.TRACE_ACTIVE = traceActive
		self.DEBUG_ACTIVE = debugActive
		self.ERROR_ACTIVE = errorActive
		self.DIRECT_PRINT = directPrint
		self.CATCH_LUA_ERRORS = catchLuaErrors

		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(eventCode) self:OnPlayerActivated(eventCode) end)
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LUA_ERROR, function(eventCode, errorOutput) self:OnLuaError(eventCode, errorOutput) end)
		
		return self
	end
    
	--[[
		Initializes LogFile
	]]--
    function TaosDebugLogger:InitLogFile()
        if (self.logFile == nil and self.logFileName ~= nil) then
            self.logFile = ZO_SavedVars:NewAccountWide(self.logFileName, VERSION, nil, { ["Logs"] = {}})
        else
            self.logFile = nil
        end
    end

	--[[
		Trace
	]]--
	function TaosDebugLogger:logTrace(functionName, functionElapsed)
		if (self.TRACE_ACTIVE == false) then return end

        local elapsed = GetGameTimeMilliseconds() - self.lastTraceTimestamp

        if (functionElapsed ~= nil) then
            local formatMessage = "[%s - %s ms - Function %s ms - TRACE] %s"
            self:logMessage(formatMessage:format(GetTimeString(), tostring(elapsed), tostring(functionElapsed), functionName))
        else
            local formatMessage = "[%s - %s ms - TRACE] %s"
            self:logMessage(formatMessage:format(GetTimeString(), tostring(elapsed), functionName))
        end

        self.lastTraceTimestamp = GetGameTimeMilliseconds()
	end

	--[[
		Debug
	]]--
	function TaosDebugLogger:logDebug(...)
		if (self.DEBUG_ACTIVE == false) then return end

		local formatMessage = "[%s - DEBUG] %s"
		local msg = ""
		
		for i = 1, select("#", ...) do
			if (i == 1) then
				msg = tostring(select(i, ...))
			else
				msg = msg .. "; " .. tostring(select(i, ...))
			end
		end
		
		self:logMessage(formatMessage:format(GetTimeString(), msg))
	end

	--[[
		Error
	]]--
	function TaosDebugLogger:logError(...)
		if (self.ERROR_ACTIVE == false) then return end

		local formatMessage = "[%s - ERROR] %s"
		local msg = ""
		
		for i = 1, select("#", ...) do
			if (i == 1) then
				msg = tostring(select(i, ...))
			else
				msg = msg .. "; " .. tostring(select(i, ...))
			end
		end
		
		self:logMessage(formatMessage:format(GetTimeString(), msg))
	end

	--[[
		Log
	]]--
	function TaosDebugLogger:logMessage(msg)
		self:AddMessage(msg)

		if (self.DIRECT_PRINT) then
			d(msg)
		else
            if (self.loggerMessageWindow.WindowFrame:IsHidden() == false) then
                self.loggerMessageWindow:AddText(msg, 1, 1, 1)
            end
        end
	end

	--[[
		Adds messages to buffer
	]]--
	function TaosDebugLogger:AddMessage(msg)
		if(not msg or self.buffer == nil) then return end

		local buf = self.buffer
		buf[#buf + 1] = msg
        
        if(self.logFile ~= nil) then
            if (self.logFile.Logs[os.date("%x")] == nil) then
                self.logFile.Logs[os.date("%x")] = {}
            end

		    local logs = self.logFile.Logs[os.date("%x")]
            logs[#logs + 1] = msg

            if (#logs > 100) then
                table.remove(logs, 1)
            end
        end
	end

	--[[
		Print buffered messages
	]]--
	function TaosDebugLogger:PrintMessages()
		if(self.buffer == nil) then return end
		
        for i,msg in ipairs(self.buffer) do
		    d(msg)
		end

        -- Clear buffer
        for i = #self.buffer, 1, -1 do
            table.remove(self.buffer, i)
        end
	end
    
	--[[
		Print buffered messages into log window and/or shows/hide it
	]]--
    function TaosDebugLogger:ToggleLogWindow()
        if(self.buffer == nil) then return end

        if (self.loggerMessageWindow.WindowFrame:IsHidden()) then
            self.loggerMessageWindow.WindowFrame:SetHidden(false)

            for i,msg in ipairs(self.buffer) do
		        self.loggerMessageWindow:AddText(msg, 1, 1, 1)
		    end
            
            -- Clear buffer
            for i = #self.buffer, 1, -1 do
                table.remove(self.buffer, i)
            end
        else
            self.loggerMessageWindow.WindowFrame:SetHidden(true)
            self.loggerMessageWindow.buffer:Clear()
        end
    end

	--[[
		Prints buffered outputs
	]]--
	function TaosDebugLogger:OnPlayerActivated(eventCode)
        if (self.DIRECT_PRINT) then
		    self:PrintMessages()
        end
        
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
	end

	--[[
		Catches lua errors
	]]--
	function TaosDebugLogger:OnLuaError(eventCode, errorOutput)
		if (self.CATCH_LUA_ERRORS == false) then return end
		
		self:logMessage(errorOutput)
		ZO_UIErrors_HideCurrent()
	end

	--[[
		Shows logs on different ways
	]]--
	function TaosDebugLogger:ShowLogs()
        if (self.DIRECT_PRINT) then
            self:PrintMessages()
        else
            self:ToggleLogWindow()
        end
	end
end