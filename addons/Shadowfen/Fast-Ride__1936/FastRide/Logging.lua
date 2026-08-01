--[[
Copyright (c) 2017-2019 Dolores Scott
All rights reserved.
See LICENSE file for terms.
]]

local SF = LibSFUtils
local color = SF.hex

-- FastRide namespace is already created before we get here
local FR = FastRide


local LOGGER_TEMPLATE = "[%s] "

local Logger = ZO_Object:Subclass()

function Logger:New(name)
    assert(type(name) == "string" and name ~= "", "Invalid addon name for logger")
    local obj = ZO_Object.New(self)
    obj.enabled = true
    obj.tag = LOGGER_TEMPLATE:format(name)
	obj.name = name
	
	-- decide which logging system to use
	if LibDebugLogger then
		obj.logger = LibDebugLogger:CreateLogger(name)
		obj.logger.debugmode = false
		setmetatable(obj,ldlogger)
	else
		obj.logger = SF.addonChatter:New(name)
		obj.logger:disableDebug()
		setmetatable(obj,sflogger)
	end
	obj.logger:setLevel(4)
    return obj
end

function Logger:enable(val)
	if type(val) ~= "boolean" then val = true end
	self.enabled = val
end

function Logger:setLevel(lvl)
	if lvl < 1 then lvl = 1 end
	if lvl > 4 then lvl = 4 end
	
	if lvl == 1 then
		self.Debug = self.DebugF or self.DoNothing
		self.Info = self.InfoF or self.DoNothing
		self.Warn = self.WarnF or self.DoNothing
	elseif lvl == 2 then
		self.Debug = self.DoNothing
		self.Info = self.InfoF or self.DoNothing
		self.Warn = self.WarnF or self.DoNothing
	elseif lvl == 3 then
		self.Debug = self.DoNothing
		self.Info = self.DoNothing
		self.Warn = self.WarnF or self.DoNothing
	elseif lvl == 4 then
		self.Debug = self.DoNothing
		self.Info = self.DoNothing
		self.Warn = self.DoNothing
	end
	self.Error = self.ErrorF
	self.level = lvl
end

function Logger:DoNothing(...)
	-- required
end

-------------------------------
local sflogger = {}

sflogger.DebugF = function(self,...)
		self.logger:debugMsg(...)
	end
sflogger.InfoF = sflogger.DebugF
sflogger.WarnF = sflogger.DebugF
function sflogger.ErrorF(self,...)
	-- required
    self.logger:systemMessage(...)
end


-------------------------------
local ldllogger = {}

function ldllogger.DebugF(self,...)
    ldllogger.logger:Debug(...)
end
function ldllogger.InfoF(self,...)
    ldllogger.logger:info(...)
end
function ldllogger.WarnF(self,...)
    ldllogger.logger:Warn(...)
end
function ldllogger.ErrorF(self,...)
	-- required
    ldllogger.logger:Error(...)
end


-- create a logger for FastRide if possible
function FR.CreateLogger(name)
	return Logger:New(name)
end

