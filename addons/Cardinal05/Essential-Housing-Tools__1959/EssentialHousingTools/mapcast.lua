if not EHT then EHT = { } end
if not EHT.Mapcast then EHT.Mapcast = { } end
--[[
local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end

---[ Mapcast : Data ]---

-- Maximum time-to-live for any unit's queued broadcast message before it is discarded.
local QUEUE_TTL = 10 * 1000
local QUEUE_LIMIT = 100
local BROADCAST_BIT_RATE = 800 --ms
local MESSAGE_TYPE = { }
local COLDHARBOUR_MAP_INDEX = 23

local InboundQueue = { }
local OutboundQueue = { }

---[ Mapcast : Libraries ]---

local function IsMapcastEnabled()
	return EHT.GetSetting( "EnableMapcast" )
end

do
	local LGPS, LMP

	function EHT.Mapcast.GetLibGPS()
		local lib = nil

		if IsMapcastEnabled() then
			if not LGPS then
				LGPS = LibStub( "LibGPS2", true )
			end

			lib = LGPS
		end

		return lib
	end

	function EHT.Mapcast.GetLibMapPing()
		local lib = nil

		if IsMapcastEnabled() then
			if not LMP then
				LMP = LibStub( "LibMapPing", true )

				if LMP then
					LMP:RegisterCallback( "BeforePingAdded", EHT.Mapcast.OnMapPing )
				end
			end

			lib = LMP
		end

		return lib
	end

	function EHT.Mapcast.OnMapcastStateChanged()
		local enabled = IsMapcastEnabled()

		if LMP then
			if not enabled then
				LMP:UnregisterCallback( "BeforePingAdded", EHT.Mapcast.OnMapPing )
			else
				LMP:RegisterCallback( "BeforePingAdded", EHT.Mapcast.OnMapPing )
			end
		end
	end
end

---[ Mapcast : Data Functions ]---

local function GetIndexedBase10( data, decimalStart, decimalEnd )
	if type( data ) ~= "number" then return end
	if type( decimalStart ) ~= "number" or decimalStart < 1 or decimalStart > 6 then decimalStart = 1 end
	if type( decimalEnd ) ~= "number" or decimalEnd < 1 or decimalEnd > 6 or decimalEnd < decimalStart then decimalEnd = 6 end

	local value = math.floor( ( 10 ^ ( decimalEnd - decimalStart + 1 ) ) * round( ( ( 10 ^ ( decimalStart - 1 ) ) * data ) % 1, 7 ) )
	return value
end

local function GetIndexedBase16( data, hexIndex )
	if type( data ) ~= "number" or type( hexIndex ) ~= "number" then return 0 end

	local decimalIndex = 2 * ( hexIndex - 1 ) + 1
	local value = GetIndexedBase10( data, decimalIndex, decimalIndex + 1 )
	if nil == value then return 0 end

	value = math.floor( value / 6 )
	return value
end

local function GetMessageData( x, y )
	if type( x ) ~= "number" or type( y ) ~= "number" then return nil end

	local sequence = GetIndexedBase16( x, 1 )
	local hex = string.format( "%1x%1x%1x%1x%1x", GetIndexedBase16( x, 2 ), GetIndexedBase16( x, 3 ), GetIndexedBase16( y, 1 ), GetIndexedBase16( y, 2 ), GetIndexedBase16( y, 3 ) )
	local value = tonumber( hex, 16 )

	return sequence, value
end

local function NewMessageData( sequence, value )
	local hex = string.format( "%05x", value )
	local hexLen, hexIndex = #hex, 1
	local sX, sY = "", ""

	sX = string.format( "0.%02d%02d%02d", 3 + 6 * sequence, 3 + 6 * tonumber( string.sub( hex, 1, 1 ), 16 ), 3 + 6 * tonumber( string.sub( hex, 2, 2 ), 16 ) )
	sY = string.format( "0.%02d%02d%02d", 3 + 6 * tonumber( string.sub( hex, 3, 3 ), 16 ), 3 + 6 * tonumber( string.sub( hex, 4, 4 ), 16 ), 3 + 6 * tonumber( string.sub( hex, 5, 5 ), 16 ) )

	local x, y = tonumber( sX ), tonumber( sY )
	return x, y
end

local function IsValidMessageTypeId( msgTypeId )
	return nil ~= MESSAGE_TYPE[ msgTypeId ]
end

local function GetMessageType( msgTypeId )
	if "number" == type( msgTypeId ) then
		return msgTypeId, MESSAGE_TYPE[ msgTypeId ]
	elseif "string" == type( msgTypeId ) then
		local msgTypeName = string.lower( msgTypeId )

		for msgTypeId, msgType in pairs( MESSAGE_TYPE ) do
			if string.lower( msgType.Name ) == msgTypeName then return msgTypeId, msgType end
		end
	end
end

local function GetMessageTypeIdByName( msgTypeName )
	msgTypeName = string.lower( msgTypeName )

	for msgTypeId, msgType in pairs( MESSAGE_TYPE ) do
		if string.lower( msgType.Name ) == msgTypeName then return msgTypeId end
	end

	return nil
end

---[ Mapcast : Inbound Messages ]---

local function FlushInboundQueueData( tag )
	InboundQueue[ tag ] = nil
end

local function GetInboundQueue( tag )
	if nil == tag then return end

	local gtime = GetGameTimeMilliseconds()
	local queue = InboundQueue[ tag ]

	if nil == queue or ( gtime - ( queue.tstamp or 0 ) ) > QUEUE_TTL then
		queue = {
			tag = tag,
			tstamp = gtime,
			data = { }
		}

		InboundQueue[ tag ] = queue
	end

	return queue
end

local function ProcessMessage( tag, data )
	if "table" ~= type( data ) then return false end

	local msgTypeId = data[1]
	if nil == msgTypeId then
		return false
	end

	msgTypeId = tonumber( msgTypeId )
	local _, msgType = GetMessageType( msgTypeId )
	if nil == msgType then
		return false
	end

	local size = msgType.Size
	if #data ~= size then
		return false
	end

	-- Disregard all pings from anyone but the current zone homeowner
	-- unless the message is a Request Type (Message Id 900 or above).
	if msgTypeId < 900 and GetCurrentHouseOwner() ~= GetUnitDisplayName( tag ) then return end

	msgType.Handler( data )

	return true
end

local function AddInboundQueueData( tag, sequence, value )
	if type( tag ) ~= "string" or type( sequence ) ~= "number" or type( value ) ~= "number" then
		return false
	end

	if "waypoint" == tag then return false end

	local queue = GetInboundQueue( tag )
	if nil == queue then
		return false
	end

	table.insert( queue.data, sequence, value )

	EVENT_MANAGER:RegisterForUpdate( EHT.ADDON_NAME .. "OnInboundQueueUpdate", 50, EHT.Mapcast.OnInboundQueueUpdate )
	return true
end

function EHT.Mapcast.OnMapPing( pingType, tag, x, y, myPing )
	if myPing then return end
	if pingType ~= MAP_PIN_TYPE_PING then return end
	if 0 >= GetCurrentZoneHouseId() then return end

	local gps = EHT.Mapcast.GetLibGPS()
	local mp = EHT.Mapcast.GetLibMapPing()
	if not gps or not mp then return end

	gps:PushCurrentMap()
	SetMapToMapListIndex( COLDHARBOUR_MAP_INDEX )
	local x, y = mp:GetMapPing( MAP_PIN_TYPE_PING, tag )
	if not mp:IsPositionOnMap( x, y ) then return end
	gps:PopCurrentMap()

	local sequence, value = GetMessageData( x, y )
	if "number" == type( sequence ) and "number" == type( value ) then
		AddInboundQueueData( tag, sequence, value )
	end
end

function EHT.Mapcast.OnInboundQueueUpdate()
	EVENT_MANAGER:UnregisterForUpdate( EHT.ADDON_NAME .. "OnInboundQueueUpdate" )
	local data

	for tag, queue in pairs( InboundQueue ) do
		data = queue.data
		if ProcessMessage( queue.tag, data ) then FlushInboundQueueData( tag ) end
	end
end

---[ Mapcast : Message Handlers ]---

local function HandlePlaySound( data )
	local soundIndex = data[2]
	if type( soundIndex ) ~= "number" then
		return false
	end

	local soundId = EHT.SoundIds[ soundIndex ]
	if nil == soundId then
		return false
	end

	PlaySound( soundId )

	return true
end

---[ Mapcast : Outbound Messages ]---

local function FlushOutboundQueueData()
	OutboundQueue = { }
end

local function AddOutboundQueue( message )
	if "table" ~= type( message ) or nil == message.data then return false, "Invalid message." end
	if #OutboundQueue >= QUEUE_LIMIT then return false, "Outbound Queue is full." end

	table.insert( OutboundQueue, message )
	EVENT_MANAGER:RegisterForUpdate( EHT.ADDON_NAME .. "OnOutboundQueueUpdate", BROADCAST_BIT_RATE, EHT.Mapcast.OnOutboundQueueUpdate )

	return true
end

function EHT.Mapcast.OnOutboundQueueUpdate()
	local data, message = nil, OutboundQueue[1]

	if nil == message then
		EVENT_MANAGER:UnregisterForUpdate( EHT.ADDON_NAME .. "OnOutboundQueueUpdate" )
		return
	end

	if not IsUnitGrouped("player") then
		FlushOutboundQueueData()
		EVENT_MANAGER:UnregisterForUpdate( EHT.ADDON_NAME .. "OnOutboundQueueUpdate" )
		return
	end

	data = table.remove( message.data, 1 )

	if nil == data or nil == message.data[1] then
		table.remove( OutboundQueue, 1 )
	end

	if nil ~= data then
		local x, y = data[1], data[2]
		EHT.MuteMapPingSoundFrameTime = GetFrameTimeMilliseconds()

		local gps = EHT.Mapcast.GetLibGPS()
		local mp = EHT.Mapcast.GetLibMapPing()
		if not gps or not mp then return end

		gps:PushCurrentMap()
		SetMapToMapListIndex( COLDHARBOUR_MAP_INDEX )
		mp:SetMapPing( MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, x, y )
		gps:PopCurrentMap()
	end
end

function EHT.Mapcast.Broadcast( msgTypeName, data )
	local msgTypeId, msgType = GetMessageType( msgTypeName )
	if "number" ~= type( msgTypeId ) or "table" ~= type( msgType ) then
		return false, string.format( "Invalid message type specified '%s'.", tostring( msgTypeName or "" ) )
	end

	local size = ( msgType.Size - 1 )
	if "table" ~= type( data ) then
		return false, string.format( "Data type is invalid. Table expected." )
	end

	if #data ~= size then
		return false, string.format( "Data size (%d) does not match Message Type size (%d).", #data, size )
	end

	for index = 1, #data do
		if "number" ~= type( data[index] ) then
			return false, string.format( "Data index %d is an invalid type. Number expected.", index )
		end
	end

	local messages, x, y = { }, nil, nil
	x, y = NewMessageData( 1, msgTypeId )
	table.insert( messages, { x, y } )

	for index = 1, #data do
		x, y = NewMessageData( index + 1, data[index] )
		table.insert( messages, { x, y } )
	end

	AddOutboundQueue( { data = messages } )
	return true
end

function EHT.Mapcast.BroadcastPlaySound( soundIndex )
	if not EHT.SoundIds[ soundIndex ] then return false, string.format( "Invalid Sound index specified: %s", tostring( soundIndex or "nil" ) ) end

	return EHT.Mapcast.Broadcast( "Play Sound", { soundIndex } )
end

---[ Mapcast : Message Types ]---

MESSAGE_TYPE[ 100 ] = {
	Name = "Play Sound",
	Size = 2,
	Handler = HandlePlaySound,
}
]]
EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Mapcast = true