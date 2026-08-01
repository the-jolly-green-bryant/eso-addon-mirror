--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global values
]]--
COLDHARBOUR_MAP_INDEX = 23

MESSAGE_PLAYER_RESOURCES = 1
MESSAGE_PLAYER_DPS = 2
MESSAGE_PLAYER_HPS = 3

--[[
	Local variables
]]--
local COLDHARBOUR_MAP_STEP_SIZE = 1.4285034012573e-005
local MESSAGE_PLAYER_RESOURCES_IDENTIFIER = 0x1e
local MESSAGE_PLAYER_DPS_IDENTIFIER = 0x32
local MESSAGE_PLAYER_HPS_IDENTIFIER = 0x3c
local EARTHGORE_PROCC_IDENTIFIER = 0xc8

local _logger = nil

local _name = "TGT-Messages"

--[[
	Table TGT_Messages
]]--
TGT_Messages = {}
TGT_Messages.__index = TGT_Messages

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--- Converts normalized map ping coordinates into 4 bytes of data
--- returns 4 integers between 0 and 255
local function DecodeData(x, y)
	local x = math.floor(x / COLDHARBOUR_MAP_STEP_SIZE + 0.5) -- round to next integer
	local y = math.floor(y / COLDHARBOUR_MAP_STEP_SIZE + 0.5)

	local b0 = math.floor(x / 0x100)
	local b1 = x % 0x100
	local b2 = math.floor(y / 0x100)
	local b3 = y % 0x100

	return b0, b1, b2, b3
end

--- Converts 4 bytes of data into coordinates for a map ping
--- b0 to b3 - integers between 0 and 255
--- returns normalized x and y coordinates
local function EncodeData(b0, b1, b2, b3)
	local b0 = b0 or 0
	local b1 = b1 or 0
	local b2 = b2 or 0
	local b3 = b3 or 0

	return (b0 * 0x100 + b1) * COLDHARBOUR_MAP_STEP_SIZE, (b2 * 0x100 + b3) * COLDHARBOUR_MAP_STEP_SIZE
end

--- Converts 3 bytes of data into 24bit integer
--- b0 to b3 - integers between 0 and 255
--- returns 24bit integer
local function BytesToInt24(b1, b2, b3)
    return (b1 * 0x10000) + (b2 * 0x100) + b3
end

--- Converts 24bit integer into 3 bytes of data
--- returns 3 integers between 0 and 255
local function Uint24IntoBytes(value)
    local b1 = math.floor(value / 0x10000)
    local b2 = math.floor((value % 0x10000) / 0x100)
    local b3 = value % 0x100

    return b1, b2, b3
end

--- Converts 8bit integer into bit table
--- returns a table of 8 bits, most significant first.
local function Convert8BitIntegerIntoBitArray(value)
    local bits = 8
    local bitTable = {} -- will contain the bits        

    for index = bits, 1, -1 do
        bitTable[index] = math.fmod(value, 2)
        value = math.floor((value - bitTable[index]) / 2)
    end

    return bitTable
end

--[[
	GetMessagePingForPlayerHPS gets message (MESSAGE_PLAYER_HPS_IDENTIFIER, HPS) as normalized x, y ping
]]--
local function GetMessagePingForPlayerHPS(player)
    local b0 = MESSAGE_PLAYER_HPS_IDENTIFIER
    local b1, b2, b3 = Uint24IntoBytes(player.HealingToSend)

    return EncodeData(b0, b1, b2, b3)
end

--[[
	GetMessagePingForPlayerDPS gets message (MESSAGE_PLAYER_DPS_IDENTIFIER, DPS) as normalized x, y ping
]]--
local function GetMessagePingForPlayerDPS(player)
    local b0 = MESSAGE_PLAYER_DPS_IDENTIFIER
    local b1, b2, b3 = Uint24IntoBytes(player.DamageToSend)

    return EncodeData(b0, b1, b2, b3)
end

--[[
	GetMessagePingForPlayerResources gets message (ulti/earthgore procc, relUlti, relMag, relStam) as normalized x, y ping
]]--
local function GetMessagePingForPlayerResources(player)
    local b0 = player.UltimateGroup.GroupAbilityPing
    local b1 = player.RelativeUltimate
    local b2 = player.RelativeMagicka
    local b3 = player.RelativeStamina

    if (player.IsEarthgoreProcced) then
        player.IsEarthgoreProcced = false
        b0 = EARTHGORE_PROCC_IDENTIFIER
    end

    return EncodeData(b0, b1, b2, b3)
end

--[[
	GetPlayerResources gets player resources from byte informations
]]--
local function GetPlayerResources(b0, b1, b2, b3)
    local pingPlayer = {
        MessageType = MESSAGE_PLAYER_RESOURCES,
        GroupAbilityPing = b0,
        RelativeUltimate = b1,
        RelativeMagicka = b2,
        RelativeStamina = b3
    }

    if (b0 == EARTHGORE_PROCC_IDENTIFIER) then
        pingPlayer.IsEarthgoreProcced = true
    end

    return pingPlayer
end

--[[
	GetPlayerDps gets player DPS from byte informations
]]--
local function GetPlayerDps(b0, b1, b2, b3)
    local pingPlayer = {
        MessageType = MESSAGE_PLAYER_DPS,
        DamageReceived = BytesToInt24(b1, b2, b3)
    }

    return pingPlayer
end

--[[
	GetPlayerHps gets player HPS from byte informations
]]--
local function GetPlayerHps(b0, b1, b2, b3)
    local pingPlayer = {
        MessageType = MESSAGE_PLAYER_HPS,
        HealingReceived = BytesToInt24(b1, b2, b3)
    }

    return pingPlayer
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	GetPlayerFromMessagePing gets player as player object from normalized x, y coordinates
]]--
function TGT_Messages.GetPlayerFromMessagePing(x, y)
    local b0, b1, b2, b3 = DecodeData(x, y)

    if ((b0 > 0 and b0 < MESSAGE_PLAYER_RESOURCES_IDENTIFIER) or b0 == EARTHGORE_PROCC_IDENTIFIER) then
        return GetPlayerResources(b0, b1, b2, b3)
    elseif (b0 == MESSAGE_PLAYER_DPS_IDENTIFIER) then
        return GetPlayerDps(b0, b1, b2, b3)
    elseif (b0 == MESSAGE_PLAYER_HPS_IDENTIFIER) then
        return GetPlayerHps(b0, b1, b2, b3)
    else
        -- should not happen
        _logger:logError(zo_strformat("TGT_Messages -> GetPlayerFromMessagePing; Message Type not valid (<<1>>)", b0))
        return nil
    end
end

--[[
	GetMessagePing gets message as normalized x, y ping
]]--
function TGT_Messages.GetMessagePing(messageType, player)
    if (messageType == MESSAGE_PLAYER_RESOURCES) then
        return GetMessagePingForPlayerResources(player)
    elseif (messageType == MESSAGE_PLAYER_DPS) then
        return GetMessagePingForPlayerDPS(player)
    elseif (messageType == MESSAGE_PLAYER_HPS) then
        return GetMessagePingForPlayerHPS(player)
    else
        -- should not happen
        _logger:logError(zo_strformat("TGT_Messages -> GetPlayerFromMessagePing; Message Type not valid (<<1>>)", messageType))
    end
end

--[[
	Initialize initializes TGT_Messages
]]--
function TGT_Messages.Initialize()
    _logger = TGT_LOGGER
    _logger:logTrace("TGT_Messages -> Initialized")
end