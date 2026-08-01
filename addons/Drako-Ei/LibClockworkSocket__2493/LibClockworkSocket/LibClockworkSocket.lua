local LIB_IDENTIFIER = "LibClockworkSocket"
local lib = LibStub:NewLibrary(LIB_IDENTIFIER, 1)

if not lib then
	return -- already loaded and no upgrade necessary
end

lib.oficialAddons = {
	['Chess'] = 21
}

lib.channels = {}

local LGPS = LibStub('LibGPS2')
local LMP = LibStub('LibMapPing')

local MAP_INDEX = 31
local MAP_STEP_SIZE = 1.4285034012573e-005

-- UTILS

local function Clamp(x, min, max)
	return math.min(max, math.max(x, min))
end

local function Clamp255Int(x)
	return Clamp(x, 0, 255)
end

local function PrintMessage(msg)
	zo_callLater(function() d('[LibClockworkSocket] '..msg) end, 0)
	
end

-- LIBRARY FUNCTIONS

function lib:RegisterSafeChannel(addonName, OnReciveData) -- OnReciveData(tag, b0, b1, b2, isLocalPlayerOwner)
	local addonName = tostring(addonName)
	if (lib.oficialAddons[addonName] ~= nil) then
		local channel = lib.oficialAddons[addonName]
		lib.channels[channel] = OnReciveData
		return true
	else
		PrintMessage('[LibSocket] Failed to open channel for ' .. AddonName .. ', addon not registered, use RegisterUnsafeChannel instead')
		return false
	end
end

function lib:RegisterUnsafeChannel(channelNumber, OnReciveData) -- OnReciveData(tag, b0, b1, b2, isLocalPlayerOwner)
	local channelNumber = tonumber(channelNumber)
	if (channelNumber <= 0 or channelNumber >= 256) then
		PrintMessage('Failed to open channel: ' .. tostring(channelNumber) .. ', channel number must be between 1 and 255')
		return false
	end
	for key, value in pairs(lib.oficialAddons) do
		if (value == channelNumber) then
			PrintMessage('Failed to open channel: ' .. tostring(channelNumber) .. ', channel is being used by: '..key)
			return false
		end
	end

	if (lib.channels[channelNumber] ~= nil) then
		PrintMessage('Failed to open channel: ' .. tostring(channelNumber) .. ', channel already in use')
		return false
	else
		if (channelNumber <= 20) then
			PrintMessage('Warning, channels 1-20 are reserved for testing')
		end
		lib.channels[channelNumber] = OnReciveData
		return true
	end
end

function lib:UnregisterUnsafeChannel(channelNumber)
	for key, value in pairs(lib.oficialAddons) do
		if (value == channelNumber) then
			PrintMessage('Failed to close channel: ' .. tostring(channelNumber) .. ', use UnregisterSafeChannel instead')
			return
		end
	end
	lib.channels[channelNumber] = nil
end

function lib:UnregisterSafeChannel(addonName)
	if (lib.oficialAddons[addonName] ~= nil) then
		local channel = lib.oficialAddons[addonName]
		lib.channels[channel] = nil
	else
		PrintMessage('Failed to close channel: ' .. tostring(addonName) .. ', addon is not registered, use UnregisterUnsafeChannel instead')
	end
end

function lib:SendSafeData(addonName, b0, b1, b2)
	if (lib.oficialAddons[addonName] ~= nil) then
		local channel = lib.oficialAddons[addonName]
		lib:SendUnsafeData(channel, b0, b1, b2)
	else
		PrintMessage('Failed to send data for: ' .. tostring(addonName) .. ', addon is not registered, use SendUnsafeData instead')
	end
end

function lib:SendUnsafeData(channel, b0, b1, b2)

	local b3 = Clamp255Int(b2 or 0)
	local b2 = Clamp255Int(b1 or 0)
	local b1 = Clamp255Int(b0 or 0)
	local b0 = Clamp255Int(channel or 0)

	if (lib.channels[b0] ~= nil) then

		local x = (b0 * 0x100 + b1) * MAP_STEP_SIZE
		local y = (b2 * 0x100 + b3) * MAP_STEP_SIZE

		LGPS:PushCurrentMap()
		SetMapToMapListIndex(MAP_INDEX)
		LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, x, y)
		LGPS:PopCurrentMap()

	end

end

-- LIBRARY EVENTS
local function OnClockworkMapPing(pingType, pingTag, offsetX, offsetY, isLocalPlayerOwner)
	if pingType == MAP_PIN_TYPE_PING then
		LGPS:PushCurrentMap()
		SetMapToMapListIndex(MAP_INDEX)
		local offsetX, offsetY = LMP:GetMapPing(pingType, pingTag)
		LGPS:PopCurrentMap()
		if offsetX == 0 and offsetY == 0 or LMP:IsPositionOnMap(offsetX, offsetY) then
			LMP:SuppressPing(pingType, pingTag)
			local x = math.floor(offsetX / MAP_STEP_SIZE + 0.5)
			local y = math.floor(offsetY / MAP_STEP_SIZE + 0.5)
			-- CHANNEL
			local b0 = math.floor(x / 0x100)
			-- DATA
			local b1 = x % 0x100
			local b2 = math.floor(y / 0x100)
			local b3 = y % 0x100

			if (b0 ~= 0 and lib.channels[b0] ~= nil) then
				lib.channels[b0](tag, b1, b2, b3, isLocalPlayerOwner)
			end
		else
			LMP:UnsuppressPing(pingType, pingTag)
		end
	end
end

local function OnClockworkMapPingRemoved(pingType, pingTag, offsetX, offsetY, isLocalPlayerOwner)
	LMP:UnsuppressPing(pingType, pingTag)
end



local function OnAddOnLoaded(event, addonName)
	if addonName == LIB_IDENTIFIER then
		function LMP.cm:UnregisterAllCallbacks(callback)
			-- OVERRIDE LIB MAP PINS'S UNREGISTER ALL FUNCTION TO KEEP ANNOYING ADDONS FROM UNREGISTERING LIBCLOCKWORKSOCKET
		end
		LMP:RegisterCallback("BeforePingAdded", OnClockworkMapPing)
		LMP:RegisterCallback("AfterPingRemoved", OnClockworkMapPingRemoved)
	end
end

EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_ADD_ON_LOADED, OnAddOnLoaded)