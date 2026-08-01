--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global callbacks
]]--
TGT_MAP_PING_CHANGED = "TGT-MapPingChanged"

--[[
	Local variables
]]--
local LGPS = LibStub("LibGPS2", true)
if(not LGPS) then
	error("Cannot load without LibGPS2")
end

local LMP = LibStub("LibMapPing")
if(not LMP) then
	error("Cannot load without LibMapPing")
end

-- Set to local for faster access
local COLDHARBOUR_MAP_INDEX = COLDHARBOUR_MAP_INDEX

local _logger = nil

local _name = "TGT-Communicator"

--[[
	Table TGT_Communicator
]]--
TGT_Communicator = {}
TGT_Communicator.__index = TGT_Communicator

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Called on map ping from LibMapPing
]]--
local function OnMapPing(pingType, pingTag, offsetX, offsetY, isLocalPlayerOwner)
	if (pingType == MAP_PIN_TYPE_PING or pingType == MAP_PIN_TYPE_PLAYER_WAYPOINT) then
        local functionTimestamp = GetGameTimeMilliseconds()

        LGPS:PushCurrentMap()
	    SetMapToMapListIndex(COLDHARBOUR_MAP_INDEX)

	    local offsetX, offsetY = LMP:GetMapPing(pingType, pingTag)

	    LGPS:PopCurrentMap()
        LMP:SuppressPing(pingType, pingTag)

        if (LMP:IsPositionOnMap(offsetX, offsetY)) then
            local pingPlayer = TGT_Messages.GetPlayerFromMessagePing(offsetX, offsetY)

            if (pingPlayer ~= nil) then
                pingPlayer.PingTag = pingTag
                FireCallbacksAsync(TGT_MAP_PING_CHANGED, pingPlayer)
            end
        end

        _logger:logTrace("TGT_Communicator -> OnMapPing", GetGameTimeMilliseconds() - functionTimestamp)
    end
end

--[[
	Called on map ping from LibMapPing
]]--
local function OnMapPingRemoved(pingType, pingTag, offsetX, offsetY, isLocalPlayerOwner)
    local offsetX, offsetY = LMP:GetMapPing(pingType, pingTag) -- load from LMP, because offsetX, offsetY from PING_EVENT_REMOVED are 0,0
	
    if ((pingType == MAP_PIN_TYPE_PING or pingType == MAP_PIN_TYPE_PLAYER_WAYPOINT) and
        LMP:IsPositionOnMap(offsetX, offsetY)) then
        LMP:UnsuppressPing(pingType, pingTag)
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Called on refresh of timer
]]--
function TGT_Communicator.SendData(player, messageType)
    if (player ~= nil) then
        local functionTimestamp = GetGameTimeMilliseconds()
        LGPS:PushCurrentMap()
        SetMapToMapListIndex(COLDHARBOUR_MAP_INDEX)

        local x, y = TGT_Messages.GetMessagePing(messageType, player)

        local pingType = MAP_PIN_TYPE_PING
        if (TGT_MOCKED) then pingType = MAP_PIN_TYPE_PLAYER_WAYPOINT end

        LMP:SetMapPing(pingType, MAP_TYPE_LOCATION_CENTERED, x, y)

        LGPS:PopCurrentMap()
        _logger:logTrace("TGT_Communicator -> SendData", GetGameTimeMilliseconds() - functionTimestamp)
    else
        _logger:logError("TGT_Communicator -> SendData; player nil")
    end
end

--[[
	Initialize initializes TGT_Communicator
]]--
function TGT_Communicator.Initialize()
    _logger = TGT_LOGGER

    -- Register events
    LMP:RegisterCallback("BeforePingAdded", OnMapPing)
    LMP:RegisterCallback("AfterPingRemoved", OnMapPingRemoved)

    _logger:logTrace("TGT_Communicator -> Initialized")
end