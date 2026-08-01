local ADDON_NAME = "FirstPersonCameraLock"
FirstPersonCameraLock = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
	nextEventHandleIndex = nextEventHandleIndex + 1
	return eventHandleName
end

local function UnregisterForEvent(event, name)
	EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
	if(type(object) == "string") then
		wrapper = functionName
		functionName = object
		object = _G
	end
	local originalFunction = object[functionName]
	object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local messages = {}
local FlushMessages
local function LogDebug(message, ...)
	if CHAT_SYSTEM.primaryContainer then
		df("[%s] " .. message, ADDON_NAME, ...)
	else
		messages[#messages + 1] = {message, ...}
	end
end

function FlushMessages()
	if not CHAT_SYSTEM.primaryContainer then return end
	for i = 1, #messages do
		LogDebug(unpack(messages[i]))
	end
	messages = {}
end

local function OnAddonLoaded(callback)
	local eventHandle = ""
	eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
		if(name ~= ADDON_NAME) then return end
		zo_callLater(FlushMessages, 200)
		local f = LoadString(callback, "OnAddonLoadedCallback")
		if(f) then
			local context = {}
			setfenv(f, context)
			setmetatable(context, { __index = _G })
			context["hash"] = HashString(callback)
			context["LogDebug"] = LogDebug
			f()
		end
		UnregisterForEvent(event, name)
	end)
end

OnAddonLoaded([[
local MESSAGE_TIMEOUT = 1000
local oCameraZoomOut = CameraZoomOut
local oToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson

local function ReplaceMethod(name, message)
	local lastMessageTime = 0
	_G[name] = function(returnCheck)
		if(returnCheck) then return math.random() end
		local now = GetGameTimeMilliseconds()
		if(now - lastMessageTime > MESSAGE_TIMEOUT) then
			LogDebug(message)
			lastMessageTime = now
		end
	end
end

-- enforce first person mode
oCameraZoomOut() -- zoom out once to make sure we are not in first person mode
oToggleGameCameraFirstPerson()
LogDebug("Activated first person mode")

-- lock user out of third person mode
ReplaceMethod("CameraZoomOut", "Prevented zoom out")
ReplaceMethod("ToggleGameCameraFirstPerson", "Prevented toggle camera mode")

local function GenerateToken(seed, name)
	math.randomseed(seed)
	local result = tonumber(string.format("%04x", CameraZoomOut(true) * 10000) .. string.format("%04x", ToggleGameCameraFirstPerson(true) * 10000), 16)
	local checksum = HashString(string.format("%d.%d.%s", result, hash, name))
	return string.format("%s.%s", result, checksum)
end

SLASH_COMMANDS["/fplock"] = function(input)
	if(input == "") then
		StartChatInput(string.format("%04x", math.random() * 10000))
	else
		local seed = tonumber(input, 16)
		if(not seed) then
			local seed, name, token = zo_strsplit(",", input)
			local myToken = GenerateToken(tonumber(zo_strtrim(seed), 16), zo_strtrim(name))
			if(myToken == zo_strtrim(token)) then
				LogDebug("Token seems legit")
			else
				LogDebug("Token has been tampered with, or name does not match")
			end
		else
			StartChatInput(GenerateToken(seed, GetUnitName("player")))
		end
	end
end
]])
