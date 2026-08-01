local ADDON_NAME = "EasyTravel_AEM"
EasyTravel_AEM = {}

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

local function Print(message, ...)
	df("[%s] %s", ADDON_NAME, message:format(...))
end

EasyTravel_AEM.WrapFunction = WrapFunction
EasyTravel_AEM.Print = Print
