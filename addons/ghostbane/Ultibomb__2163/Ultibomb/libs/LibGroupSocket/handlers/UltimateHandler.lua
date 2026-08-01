-- The Ultimate Protocol
-- *bitArray* flags, *uint8* ultimate[, *uint8* ultimateCost]
-- flags:
--   1: isFullUpdate - the user is sending cost in addition to percentages in this packet
--   2: requestsFullUpdate - the user does not have all the necessary data and wants to have a full update from everyone (e.g. after reloading the ui)

local LGS = LibStub("LibGroupSocket")
LGS.MESSAGE_TYPE_ULTIMATE = 21 -- aka, the code for 'u'
local type, version = LGS.MESSAGE_TYPE_ULTIMATE, 2
local handler, saveData = LGS:RegisterHandler(type, version)
if(not handler) then return end
local SKIP_CREATE = true
local ON_ULTIMATE_CHANGED = "OnUltimateChanged"
local MIN_SEND_TIMEOUT = 2
local MIN_COMBAT_SEND_TIMEOUT = 1
local Log = LGS.Log

handler.resources = {}
local resources = handler.resources
local sendFullUpdate = true
local needFullUpdate = true
local ultimateCost = 255
local lastSendTime = 0
local defaultData = {
    version = 1,
    enabled = true,
}
handler.callbacks = handler.callbacks or 0

handler._useStatusType = 'user';

local function GetCachedUnitResources(unitTag, skipCreate)
    local unitName = GetUnitName(unitTag)
    local unitResources = resources[unitName]
    if(not unitResources and not skipCreate) then
        resources[unitName] = {
            [POWERTYPE_ULTIMATE] = {current=0, cost=255},
            lastUpdate = 0,
        }
        unitResources = resources[unitName]
    end
    return unitResources
end

function handler:GetLastUpdateTime(unitTag)
    local unitResources = GetCachedUnitResources(unitTag, SKIP_CREATE)
    if(unitResources) then return unitResources.lastUpdate end
    return -1
end

function handler:SetUltimateCost(cost)
	if cost > 0 and cost <= 255 then
		ultimateCost = cost
	end
end

local function OnData(unitTag, data, isSelf)
    -- d('LGS.onData fired', data)



	if (handler.callbacks == 0) then return end --dont do anything if nobody is using this handler
	
    local index, bitIndex = 1, 1
    local isFullUpdate, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local requestsFullUpdate, index, bitIndex = LGS:ReadBit(data, index, bitIndex)

    --	Log("OnData %s (%d byte): is full: %s, needs full: %s", GetUnitName(unitTag), #data, tostring(isFullUpdate), tostring(requestsFullUpdate))
    index = index + 1
    if(not isSelf and requestsFullUpdate) then
        sendFullUpdate = true
    end

    local expectedLength = isFullUpdate and 3 or 2
    if(#data < expectedLength) then Log("UltimateHandler received only %d of %d byte", #data, expectedLength) return end

    local unitResources = GetCachedUnitResources(unitTag)
    local ultimate = unitResources[POWERTYPE_ULTIMATE]
    ultimate.current, index = LGS:ReadUint8(data, index)
    local ultiType, index = LGS:ReadUint8(data, index)
    if(isFullUpdate) then
		ultimate.cost, index = LGS:ReadUint8(data, index)
	end

    unitResources.lastUpdate = GetTimeStamp()

    -- Log("ultimate: %d, cost: %d, type: %d", ultimate.current, ultimate.cost, ultiType)
    LGS.cm:FireCallbacks(ON_ULTIMATE_CHANGED, unitTag, ultimate.current, ultimate.cost, isSelf, ultiType)
end

local function NumCallbacks()
	local registry = LGS.cm.callbackRegistry[ON_ULTIMATE_CHANGED]
	handler.callbacks = registry and #registry or 0
end

function handler:RegisterForUltimateChanges(callback)
    -- d('Added handler:RegisterForUltimateChanges callback')
    LGS.cm:RegisterCallback(ON_ULTIMATE_CHANGED, callback)
	NumCallbacks()
end

function handler:UnregisterForUltimateChanges(callback)
    LGS.cm:UnregisterCallback(ON_ULTIMATE_CHANGED, callback)
	NumCallbacks()
end

local function GetPowerValues(unitResources, powerType)
    local data = unitResources[powerType]
    local current, maximum = GetUnitPower("player", powerType)
    return data, current, 255 -- use hardcoded value since no ulti has higher cost
end

function handler:SetStatusType(type)
    handler._useStatusType = type
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local UltiManifest = {
    [1] = {
        ultiType = 1,
        abilityNames = {'Dawnbreaker','Flawless Dawnbreaker','Dawnbreaker of Smiting'}
    },
    [2] = {
        ultiType = 2,
        abilityNames = {'Negate Magic','Suppression Field','Absorption Field'}
    },
    [3] = {
        ultiType = 3,
        abilityNames = {'Sleet Storm','Northern Storm','Permafrost'}
    },
    [4] = {
        ultiType = 4,
        abilityNames = {'Panacea','Life Giver','Light\'s Champion'}
    },
    [5] = {
        ultiType = 5,
        abilityNames = {
            'Elemental Storm', 'Fire Storm', 'Ice Storm', 'Thunder Storm',
            'Eye of the Storm','Eye of Flame','Eye of Lightning','Eye of Frost',
            'Elemental Rage', 'Fiery Rage', 'Icy Rage', 'Thunderous Rage'
        }
    },
    [6] = {
        ultiType = 6,
        abilityNames = {'Shifting Standard'}
    },
    [7] = {
        ultiType = 7,
        abilityNames = {'Nova','Solar Prison','Solar Disturbance'}
    },
    [8] = {
        ultiType = 8,
        abilityNames = {'Glacial Colossus'}
    }
}

function handler:Send()
    -- if(not saveData.enabled or not IsUnitGrouped("player") or handler.callbacks == 0) then return end
    if(not saveData.enabled or handler._useStatusType ~= 'user' or handler.callbacks == 0) then return end
    local now = GetTimeStamp()
    local timeout = IsUnitInCombat("player") and MIN_COMBAT_SEND_TIMEOUT or MIN_SEND_TIMEOUT
    if(now - lastSendTime < timeout) then return end

    local unitResources = GetCachedUnitResources("player")
    local ultimate, ultimateCurrent, ultimateMaximum = GetPowerValues(unitResources, POWERTYPE_ULTIMATE)
	ultimateCurrent = zo_min(ultimateCurrent, ultimateMaximum)

    local ultiName = GetAbilityName(GetSlotBoundId(8))
    local ultiType = 0

    -- Loop manifest
    for i in pairs(UltiManifest) do

        -- Is this ultimate within our manifest ?
        if has_value(UltiManifest[i].abilityNames, ultiName) then
            ultimateCost = GetSlotAbilityCost(8,POWERTYPE_ULTIMATE)
            ultiType = UltiManifest[i].ultiType
        end
    end

    -- d('sending', ultiName)

    sendFullUpdate = sendFullUpdate or ultimate.cost ~= ultimateCost
    if(ultimate.current ~= ultimateCurrent or sendFullUpdate) then

        local data = {}
        local index, bitIndex = 1, 1
        index, bitIndex = LGS:WriteBit(data, index, bitIndex, sendFullUpdate)
        index, bitIndex = LGS:WriteBit(data, index, bitIndex, needFullUpdate)
        index = index + 1
        index = LGS:WriteUint8(data, index, ultimateCurrent)
        index = LGS:WriteUint8(data, index, ultiType)
        -- index = LGS:WriteChar(data, index, 'a')
		if sendFullUpdate then
            index = LGS:WriteUint8(data, index, ultimateCost)
			-- index = LGS:WriteChar(data, index, 'a')
		end

		--	Log("Send %d byte: is full: %s, needs full: %s, ultimate: %s, cost: %s", #data, tostring(sendFullUpdate), tostring(needFullUpdate), tostring(ultimateCurrent), tostring(ultimateCost))
        if(LGS:Send(type, data)) then
			--	Log("Send Complete")
            lastSendTime = now
            ultimate.current = ultimateCurrent
			if sendFullUpdate then
				ultimate.cost = ultimateCost
			end
            sendFullUpdate = false
            needFullUpdate = false
        end
    end
end

function handler:Refresh()
	sendFullUpdate = true
	needFullUpdate = true
end

local function OnUpdate()
    handler:Send()
end

local isActive = false

local function StartSending()
        -- handler:Send()
    if(not isActive and saveData.enabled and IsUnitGrouped("player")) then
        EVENT_MANAGER:RegisterForUpdate("LibGroupSocketUltimateHandler", 1000, OnUpdate)
        isActive = true
    end
end

local function StopSending()
    if(isActive) then
        EVENT_MANAGER:UnregisterForUpdate("LibGroupSocketUltimateHandler")
        isActive = false
    end
end

local function OnUnitCreated(_, unitTag)
    sendFullUpdate = true
    StartSending()
end

local function OnUnitDestroyed(_, unitTag)
    resources[GetUnitName(unitTag)] = nil
    if(isActive and not IsUnitGrouped("player")) then
        StopSending()
    end
end

function handler:InitializeSettings(optionsData, IsSendingDisabled) -- TODO: localization
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Ultimate Handler",
    }
optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = "Enable sending",
    tooltip = "Controls if the handler does send data. It will still receive and process incoming data.",
    getFunc = function() return saveData.enabled end,
    setFunc = function(value)
        saveData.enabled = value
        if(value) then StartSending() else StopSending() end
    end,
    disabled = IsSendingDisabled,
    default = defaultData.enabled
}
end

-- savedata becomes available twice in case the standalone lib is loaded
local function InitializeSaveData(data)
    saveData = data

    if(not saveData.version) then
        ZO_DeepTableCopy(defaultData, saveData)
    end

    --  if(saveData.version == 1) then
    --      -- update it
    --  end
end

local function Unload()
    LGS.cm:UnregisterCallback(type, handler.dataHandler)
    LGS.cm:UnregisterCallback("savedata-ready", InitializeSaveData)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketUltimateHandler", EVENT_UNIT_CREATED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketUltimateHandler", EVENT_UNIT_DESTROYED)
    StopSending()
end

local function Load()
    InitializeSaveData(saveData)
    LGS.cm:RegisterCallback("savedata-ready", function(data)
        InitializeSaveData(data.handlers[type])
    end)

    handler.dataHandler = OnData
    LGS.cm:RegisterCallback(type, OnData)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketUltimateHandler", EVENT_UNIT_CREATED, OnUnitCreated)
	EVENT_MANAGER:AddFilterForEvent("LibGroupSocketUltimateHandler",EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketUltimateHandler", EVENT_UNIT_DESTROYED, OnUnitDestroyed)
	EVENT_MANAGER:AddFilterForEvent("LibGroupSocketUltimateHandler",EVENT_UNIT_DESTROYED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    handler.Unload = Unload

    StartSending()
end

if(handler.Unload) then handler.Unload() end
Load()
