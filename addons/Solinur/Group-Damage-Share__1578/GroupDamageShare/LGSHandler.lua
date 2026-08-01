-- The Group Resource Protocol
-- *bitArray* flags (6), *uint2+16* (exponent+significant) "float" [*uint16* integer Time, *bit* MainResource (Magicka/Stamina)  15 bits unused]
-- flags:
--   1: isFullUpdate - the user is sending Data Soouce and other info instead
--   2: requestsFullUpdate - the user does not have all the necessary data and wants to have a full update from everyone (e.g. after reloading the ui)
--   3: HPS or DPS - what type of data is sent.
--   4: not used for now.
--   5: not used for now.
--   6; not used for now.
-- Time: Combat time in seconds


local _

local LGS = LibStub("LibGroupSocket")

local type, version = LGS.MESSAGE_TYPE_COMBATSTATS, 2
local handler, db = LGS:RegisterHandler(type, version)

if (not handler) then return end

local LibCombat = LibCombat
if LibCombat == nil then return end

local ON_DATA_UPDATE = "OnCombatStatsDataUpdate" -- change this string if you copy this code !

local MIN_SEND_TIMEOUT = 1150
local MIN_COMBAT_SEND_TIMEOUT = 1150

local Log = LGS.Log
local SKIP_CREATE = true
local isActive = false
local debugon = false
local ismagicka

handler.data = {}
handler.db = db

local data = handler.data

local sendFullUpdate = true
local sendFinalUpdate = false

local needFullUpdate = true

local lastSendTime = 0
local lastFullUpdate = 0

local defaultData = {

	version = 1,
	enabled = true,

}

local function GetCachedUnitResources(unitTag, skipCreate)

	local unitName = GetUnitName(unitTag)
	local unitData = data[unitName]

	if not (unitData or skipCreate) then

		data[unitName] = {
			hasFullData = false,
			lastUpdate = 0,
			class = nil,
		}

		unitData = data[unitName]

	end

	return unitData
end

function handler:GetLastUpdateTime(unitTag)

	local unitData = GetCachedUnitResources(unitTag, SKIP_CREATE)

	if unitData then return unitData.lastUpdate else return -1 end

end

function handler:RegisterForValueChanges(callback)

	LGS.cm:RegisterCallback(ON_DATA_UPDATE, callback)

end

function handler:UnregisterForValueChanges(callback)

	LGS.cm:UnregisterCallback(ON_DATA_UPDATE, callback)

end

function handler:SetDebug(isdebug)

	debugon = isdebug

end

function handler:SetRole(isheal)

	db.isheal = isheal

end

local fightdata = {}
handler.fightdata = fightdata

local function FightRecapCallback(_, data) --DPSOut, DPSIn, hps, HPSIn, dpstime

	fightdata.DPSOut 	= data.DPSOut
	fightdata.HPSOut	= data.HPSOut
	fightdata.dpstime	= data.dpstime
	fightdata.hpstime	= data.hpstime

end

local function GetDHPSData()

	if db.isheal and fightdata.HPSOut ~= nil then

		return fightdata.HPSOut, fightdata.hpstime, true

	elseif fightdata.DPSOut ~= nil then

		return fightdata.DPSOut, fightdata.dpstime, false

	end
end

local function IntToBits(value, length, bits) -- bits is optional, will be used to attach new bits to it

	local bits = bits or {}
	local offset = #bits

    for i = length, 1, -1 do

		local bit = math.fmod(value, 2)

        bits[i + offset] = (bit == 1)

        value = (value - bit) / 2

    end

	return bits

end

local function BitsToInt(bits, length) -- length is optional, if used it will return the remaining bits

	local length = length or #bits
	local value = 0

    for i = 1, length do

		local bit = (table.remove(bits, 1) and 1) or 0
		value = value + bit * 2 ^ (length - i)

	end

	return value, bits

end

local function OnData(unitTag, data, isSelf) --needs to be updated

	-- Read Flags

	local index = 1
	local bitIndex = 1
	local isheal, isFullUpdate, requestsFullUpdate

	isFullUpdate, index, bitIndex = LGS:ReadBit(data, index, bitIndex)

	requestsFullUpdate, index, bitIndex = LGS:ReadBit(data, index, bitIndex)

	isheal, index, bitIndex = LGS:ReadBit(data, index, bitIndex)

	bitIndex = bitIndex + 3	-- skip unused flags

	--if debugon then Log("OnData %s (%d byte): is full: %s, needs full: %s, Heal: %s", GetUnitName(unitTag), #data, tostring(isFullUpdate), tostring(requestsFullUpdate), tostring(isheal)) end

	if(not isSelf and requestsFullUpdate) then

		sendFullUpdate = true

	end

	local expectedLength = isFullUpdate and 6 or 3

	if #data < expectedLength then

		if debugon then Log("ResourceHandler received only %d of %d byte", #data, expectedLength) end
		return

	end

	local unitData = GetCachedUnitResources(unitTag)

	-- Read Data

	local bits = {}

	for i = 1,2 do

		bits[i], index, bitIndex = LGS:ReadBit(data, index, bitIndex)

	end

	local ex = BitsToInt(bits, 2)

	local basevalue, index = LGS:ReadUint16(data, index)

	local value = basevalue * (10 ^ ex) * 2 -- value precision is +/- 2

	local class

	if isFullUpdate then

		bits = {}

		local dpstime, index = LGS:ReadUint16(data, index)

		dpstime = math.max(dpstime/10, 0)

		bits = {}

		for i = 1, 4 do

			 bits[i], index, bitIndex = LGS:ReadBit(data, index, bitIndex)

		end
		_,_ = BitsToInt(bits, 4) --was source, not needed anymore
		unitData.hasFullData = true

		local ismagickaUser, index, bitIndex = LGS:ReadBit(data, index, bitIndex)

		class = math.min(GetUnitClassId(unitTag), 8) + (ismagickaUser and 8 or 0) -- 1-8 stamina, 8-16 magicka

		unitData.class = class

	elseif not (unitData.hasFullData or isSelf) then

		needFullUpdate = true

	end

	unitData.lastUpdate = GetTimeStamp()

	class = class or unitData.class or math.min(GetUnitClassId(unitTag), 8) + 16

	--if debugon then Log("Value: %d, Heal: %s, Source: %d, Time: %d, Self: %s", value, tostring(isheal), source, dpstime, tostring(isSelf)) end

	local data = {

		unitTag = unitTag,
		value 	= value,
		isHeal 	= isheal,
		dpstime = dpstime,
		isSelf  = isSelf,
		class   = class,

	}

	LGS.cm:FireCallbacks(ON_DATA_UPDATE, data)
end

local function StopSending()

	if isActive and not IsUnitInCombat("player") then

		EVENT_MANAGER:UnregisterForUpdate("LibGroupSocketDamageHandler")
		isActive = false

	end
end

function handler:Send()

	if sendFinalUpdate then

		StopSending()
		sendFinalUpdate = false

	end

	if not (db.enabled and IsUnitGrouped("player")) then return end

	local now = GetGameTimeMilliseconds()
	local timeout = IsUnitInCombat("player") and MIN_COMBAT_SEND_TIMEOUT or MIN_SEND_TIMEOUT

	if (now - lastSendTime) < timeout then return end
	if (now - lastFullUpdate) > 3 * timeout or sendFinalUpdate then sendFullUpdate = true end

	local value, activeTime, isheal = GetDHPSData()

	if value == nil then return end

	local data = {}
	local index, bitIndex = 1, 1

	index, bitIndex = LGS:WriteBit(data, index, bitIndex, sendFullUpdate)
	index, bitIndex = LGS:WriteBit(data, index, bitIndex, needFullUpdate)
	index, bitIndex = LGS:WriteBit(data, index, bitIndex, isheal)

	bitIndex = bitIndex + 3 -- unused indices

	value = value / 2 -- value precision is +/- 2

	if value < 0 or value > 50000000 then value = 50001000 end -- (2^16)*(10^3)-1 is the maximum value, it will be used as error

	local size = math.log(value) / math.log(10) -- get if value is big
	local ex = math.ceil(math.max(size, 4) - 4) -- the decimal exponent
	local val = math.ceil(value / (10  ^ ex))  -- the base number

	local bits = {} -- will contain the bits

    bits = IntToBits(ex, 2, bits)

	for i = 1, 2 do

		index, bitIndex = LGS:WriteBit(data, index, bitIndex, bits[i])

	end

	index = LGS:WriteUint16(data, index, val)

	if sendFullUpdate then

		activeTime = zo_round(activeTime * 10)

		index = LGS:WriteUint16(data, index, activeTime)

		bits = IntToBits(0, 4, nil)

		for i = 1,4 do

			index, bitIndex = LGS:WriteBit(data, index, bitIndex, bits[i])

		end

		index, bitIndex = LGS:WriteBit(data, index, bitIndex, ismagicka)
	end

	--if debugon then Log("Send %d byte: is full: %s, needs full: %s, is heal: %s, Value: %d, Time: %d ", #data, tostring(sendFullUpdate), tostring(needFullUpdate), tostring(isheal), val, dpstime) end

	if LGS:Send(type, data) then

		lastSendTime = now

		if sendFullUpdate then lastFullUpdate = now end

		sendFullUpdate = false
		needFullUpdate = false

	end
end

local function OnUpdate()

	handler:Send()

end

local function StartSending()

	if not isActive and db.enabled and IsUnitGrouped("player") and IsUnitInCombat("player") then

		EVENT_MANAGER:RegisterForUpdate("LibGroupSocketDamageHandler", MIN_SEND_TIMEOUT, OnUpdate)
		isActive = true

	end
end

local function OnUnitCreated(_, unitTag)

	sendFullUpdate = true

end

local function OnUnitDestroyed(_, unitTag)

	data[GetUnitName(unitTag)] = nil

	if isActive and not IsUnitGrouped("player") then

		StopSending()

	end
end

local function OnCombatState(_, inCombat)

	inCombat = inCombat or IsUnitInCombat("player")

	if IsUnitGrouped("player") and inCombat then

		local _, mag = GetUnitPower("player", POWERTYPE_MAGICKA)
		local _, stam = GetUnitPower("player", POWERTYPE_STAMINA)

		ismagicka = mag > stam
		StartSending()

	elseif (not inCombat) and isActive then

		sendFinalUpdate = true

	end
end

function handler:InitializeSettings(optionsData, IsSendingDisabled) -- TODO: localization

	optionsData[#optionsData + 1] = {

		type = "header",
		name = "Group Damage Share",

	}
	optionsData[#optionsData + 1] = {

		type = "checkbox",
		name = "Enable sending",
		tooltip = "Controls if the handler does send data. It will still receive and process incoming data.",
		getFunc = function() return db.enabled end,
		setFunc = function(value)
			db.enabled = value
			if(value) then StartSending() else StopSending() end
		end,
		disabled = IsSendingDisabled,
		default = defaultData.enabled

	}
end

local function InitializeSaveData(data)

    db = data

    if not db.version then ZO_DeepTableCopy(defaultData, db) end

    --  if(saveData.version == 1) then
    --      -- update it
    --  end
end

local function Unload()

	LGS.cm:UnregisterCallback(type, handler.dataHandler)

	EVENT_MANAGER:UnregisterForEvent("LibGroupSocketDamageHandler", EVENT_UNIT_CREATED)
	EVENT_MANAGER:UnregisterForEvent("LibGroupSocketDamageHandler", EVENT_UNIT_DESTROYED)
	EVENT_MANAGER:UnregisterForEvent("LibGroupSocketDamageHandler", EVENT_PLAYER_COMBAT_STATE)

	StopSending()

end

local function Load()

	handler.dataHandler = OnData

	LGS.cm:RegisterCallback(type, OnData)

	EVENT_MANAGER:RegisterForEvent("LibGroupSocketDamageHandler", EVENT_UNIT_CREATED, OnUnitCreated)
	EVENT_MANAGER:RegisterForEvent("LibGroupSocketDamageHandler", EVENT_UNIT_DESTROYED, OnUnitDestroyed)
	EVENT_MANAGER:RegisterForEvent("LibGroupSocketDamageHandler", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
	handler.Unload = Unload

	StartSending()

    InitializeSaveData(db)

    LGS.cm:RegisterCallback("savedata-ready",

		function(data)

			InitializeSaveData(data.handlers[type])

		end
	)

	LibCombat:RegisterCallbackType(LIBCOMBAT_EVENT_FIGHTRECAP, FightRecapCallback, GDS.name)
end

if handler.Unload then handler.Unload() end

Load()