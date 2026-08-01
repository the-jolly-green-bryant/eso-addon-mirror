-- The RT Group Update Protocol
-- *bitArray* flags, [*uint8* 5p set_id | *uint16* 5p set_id]
-- flags:
--   1: is_max_magicka
--   2: is_max_stamina
--   3: is_max_health
--   4: put_on
--   5: is_long_set

local LGS = LibStub("LibGroupSocket")
local MESSAGE_TYPE_RAIDTOOLS = 30

local type, version = MESSAGE_TYPE_RAIDTOOLS, 1
local handler, saveData = LGS:RegisterHandler(type, version)
if(not handler) then return end
local ON_DATA_UPDATE = "OnDataUpdate"
local Log = LGS.Log

handler.info = {}
local info = handler.info
local defaultData = {
    version = 1,
    enabled = true
}
local last_send = 0

local equipment_slots = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_BACKUP_MAIN
}

local function has_value(table, _value)
    for index, value in ipairs(table) do
        if value == _value then
            return true
        end
    end

    return false
end

local function GetActive5PSets(full)
    local sets, result = {}, {}
    for _, slot in ipairs(equipment_slots) do
        local item_link = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
        local hasSet, name, bonus_count, equiped_count, max_equiped, set_id = GetItemLinkSetInfo(item_link, true)
        if max_equiped == 5 then
            if not sets[set_id] then
                sets[set_id] = {
                    id = set_id,
                    name = name,
                    count = 1
                }   
            else
                sets[set_id].count = sets[set_id].count + 1
            end
        end
    end
    for set_id, data in pairs(sets) do
        if data.count == 5 then
            table.insert(result, set_id)
        end
    end
    if full then return sets end
    return result
end

local function GetCachedUnitInfo(unitTag, skipCreate)
    local unitName = GetUnitName(unitTag)
    local unitResources = info[unitName]
    if(not unitResources and not skipCreate) then
        info[unitName] = {
            sets = {},
            is_max_magicka = false,
            is_max_stamina = false,
            is_max_health = false
        }
        unitInfo = info[unitName]
    end
    return unitInfo
end

local function OnData(unitTag, data, isSelf)
    local index, bitIndex = 1, 1
    local set_id_one, set_id_two = nil, nil
    local unitInfo = GetCachedUnitInfo(unitTag)
    local is_max_magicka, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_max_stamina, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_max_health, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local put_on, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_long_set, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    unitInfo.is_max_magicka = is_max_magicka
    unitInfo.is_max_stamina = is_max_stamina
    unitInfo.is_max_health = is_max_health
    index = index + 1

    local set_id
    if is_long_set then
        set_id, index = LGS:ReadUint16(data, index)
    else
        set_id, index = LGS:ReadUint8(data, index)
    end

    --d('OnData('..unitTag..', '.. set_id ..', '..tostring(put_on)..')')

    LGS.cm:FireCallbacks(ON_DATA_UPDATE, unitTag, is_max_magicka, is_max_stamina, is_max_health, put_on, set_id, isSelf)
end

function handler:RegisterForRTGroupInfo(callback)
    LGS.cm:RegisterCallback(ON_DATA_UPDATE, callback)
end

function handler:UnregisterForRTGroupInfo(callback)
    LGS.cm:UnregisterCallback(ON_DATA_UPDATE, callback)
end

function handler:SendUpdate(put_on, set_id)
    local data = {}
    local index, bitIndex = 1, 1
    local is_long_set = (set_id > 255)
    local is_max_magicka, is_max_stamina, is_max_health = false, false, false
    local mag, stam, health = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA), GetAttributeSpentPoints(ATTRIBUTE_STAMINA), GetAttributeSpentPoints(ATTRIBUTE_HEALTH)
    if mag >= stam and mag >= health then
        is_max_magicka = true
    elseif stam >= mag and stam >= health then
        is_max_stamina = true
    elseif health >= mag and health >= stam then
        is_max_health = true
    end
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_max_magicka)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_max_stamina)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_max_health)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, put_on)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_long_set)
    index = index + 1
    if is_long_set then
        index = LGS:WriteUint16(data, index, set_id)
    else
        index = LGS:WriteUint8(data, index, set_id)
    end
    last_send = GetTimeStamp()
    if(LGS:Send(type, data)) then
        unitInfo.is_max_magicka = is_max_magicka
        unitInfo.is_max_stamina = is_max_stamina
        unitInfo.is_max_health = is_max_health
        --d('LGS:Sent ('..tostring(put_on)..', '..set_id..')')
    else
        --d('LGS:Sending failed ('..tostring(put_on)..', '..set_id..')')
    end
end

local function OnItemUpdate(_, bag_id, _, _, _, _, _)
    if bag_id ~= BAG_WORN then return end
    local unitInfo = GetCachedUnitInfo("player")
    local sets = GetActive5PSets(true)
    for i, set_id in ipairs(unitInfo.sets) do
        if not sets[set_id] or sets[set_id].count < 5 then 
            unitInfo.sets[i] = nil
            handler:SendUpdate(false, set_id)
        end
    end
    for set_id, set in pairs(sets) do
        if not has_value(unitInfo.sets, set_id) and set.count >= 5 then
            handler:SendUpdate(true, set_id)
            table.insert(unitInfo.sets, set_id)
        end 
    end
end


local isActive = false

local function StartSending()
    if(not isActive and saveData.enabled and IsUnitGrouped("player")) then
        --d('StartSending')
        --EVENT_MANAGER:RegisterForUpdate("LibGroupSocketRTGroupUpdateHandler", 1000, OnUpdate)
        isActive = true
    end
end

local function StopSending()
    if(isActive) then
        --d('StopSending')
        --EVENT_MANAGER:UnregisterForUpdate("LibGroupSocketRTGroupUpdateHandler")
        isActive = false
    end
end

local function OnUnitCreated(_, unitTag)
    if GetTimeStamp() - last_send < 2 then return end
    StartSending()
    if IsPlayerActivated() then OnItemUpdate(false, BAG_WORN, false, false, false, false, false) end
end

local function Group_OnJoin(...)
    StartSending()
    if IsPlayerActivated() then OnItemUpdate(false, BAG_WORN, false, false, false, false, false) end
end

local function Group_OnStatusChanged(eventCode, unitTag, isOnline)
    if isOnline then
        if IsPlayerActivated() then OnItemUpdate(false, BAG_WORN, false, false, false, false, false) end
    end
end

local function OnUnitDestroyed(_, unitTag)
    if GetTimeStamp() - last_send < 2 then return end
    info[GetUnitName(unitTag)] = nil
    if(isActive and not IsUnitGrouped("player")) then
        StopSending()
    end
end

function handler:InitializeSettings(optionsData, IsSendingDisabled)
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "RaidTools group info handler",
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

local function Unload()
    LGS.cm:UnregisterCallback(type, handler.dataHandler)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_UNIT_CREATED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_UNIT_DESTROYED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_GROUP_MEMBER_CONNECTED_STATUS)
    StopSending()
end

local function Load()
    if(not saveData.version) then
        ZO_DeepTableCopy(defaultData, saveData)
    end

    handler.dataHandler = OnData
    LGS.cm:RegisterCallback(type, OnData)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_UNIT_CREATED, OnUnitCreated)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_UNIT_DESTROYED, OnUnitDestroyed)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnItemUpdate)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_GROUP_MEMBER_JOINED, Group_OnJoin)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGroupUpdateHandler", EVENT_GROUP_MEMBER_CONNECTED_STATUS, Group_OnStatusChanged)
    handler.Unload = Unload

    SLASH_COMMANDS['/rtforceupdate'] = function() 
        local unitInfo = GetCachedUnitInfo("player")
        unitInfo.sets = {}
        OnItemUpdate(false, BAG_WORN, false, false, false, false, false)
    end

    SLASH_COMMANDS['/rtupdate'] = function() 
        OnItemUpdate(false, BAG_WORN, false, false, false, false, false)
    end

    SLASH_COMMANDS['/rtresetsets'] = function() 
        local unitInfo = GetCachedUnitInfo("player")
        unitInfo.sets = {}
    end

    StartSending()
end

if(handler.Unload) then handler.Unload() end
Load()
