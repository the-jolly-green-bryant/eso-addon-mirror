--[[
-- RaidTools GroupUtilityProtocol
-- *bitArray* flags, [*uint8* value | *uint16* value] ([*uint16* value_two])
-- flags:
--   1: is_max_magicka
--   2: is_max_stamina
--   3: is_value_assigning_dataset
--   4: is_long
--   5: is_set_update   | is_vote_update
--   6: is_dps_update   | <unused>
--   7: is_ult_update   | <unused>
--   8: ex_update_types
]]--

local LGS = LibStub("LibGroupSocket")
local MESSAGE_TYPE_RAIDTOOLS = 30

local type, version = MESSAGE_TYPE_RAIDTOOLS, 2
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
            dps = 0,
            ultimate_ability = 0,
            ultimate_cost = 255,
            ultimate = 0
        }
        unitInfo = info[unitName]
    end
    return unitInfo
end

local function CompressDPS(dps)
    local result = 0
    result = math.floor(dps/10)
    if result >= 65536 then result = 65535 end
    return result
end

local function DecompressDPS(source)
    return source*10
end

local function OnData(unitTag, data, isSelf)
    local index, bitIndex = 1, 1
    local unitInfo = GetCachedUnitInfo(unitTag)

    local is_max_magicka, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_max_stamina, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_value_assigning_dataset, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_long, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_set_update, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_dps_update, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local is_ult_update, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    local ex_update_types, index, bitIndex = LGS:ReadBit(data, index, bitIndex)

    unitInfo.is_max_magicka = is_max_magicka
    unitInfo.is_max_stamina = is_max_stamina
    --index = index + 1

    local value, v2
    if is_long then
        value, index = LGS:ReadUint16(data, index)
    else
        value, index = LGS:ReadUint8(data, index)
    end

    if is_dps_update then
        value = DecompressDPS(value)
    end

    --d(string.format('RECEIVED: unit: %s sent: %s (islong: %s) (update_type [set: %s; dps: %s; ult: %s, EX: %s])', unitTag, value, tostring(is_long), tostring(is_set_update), tostring(is_dps_update), tostring(is_ult_update), tostring(ex_update_types)))
    local update_type = 'none'
    if is_ult_update then if not ex_update_types then update_type = 'ult' else update_type = '' end
    elseif is_dps_update then if not ex_update_types then update_type = 'dps' else update_type = '' end
    elseif is_set_update then if not ex_update_types then update_type = 'set' else update_type = 'vote' end
    end
    LGS.cm:FireCallbacks(ON_DATA_UPDATE, unitTag, is_max_magicka, is_max_stamina, is_value_assigning_dataset, update_type, value, isSelf)
end

function handler:RegisterForRTGroupInfo(callback)
    LGS.cm:RegisterCallback(ON_DATA_UPDATE, callback)
end

function handler:UnregisterForRTGroupInfo(callback)
    LGS.cm:UnregisterCallback(ON_DATA_UPDATE, callback)
end

function handler:SendUpdate(assigning, update_type, value)
    local data, index, bitIndex = {}, 1, 1
    local is_long = (value > 255)
    local is_max_magicka, is_max_stamina, is_max_health = false, false, false
    local mag, stam, health = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA), GetAttributeSpentPoints(ATTRIBUTE_STAMINA), GetAttributeSpentPoints(ATTRIBUTE_HEALTH)
    if mag >= stam and mag >= health then
        is_max_magicka = true
    elseif stam >= mag and stam >= health then
        is_max_stamina = true
    elseif health >= mag and health >= stam then
        is_max_health = true
    end
    local is_set_update, is_dps_update, is_ult_update, ex_update_types = (update_type == 'set' or update_type == 'vote'), (update_type == 'dps'), (update_type == 'ult'), (update_type == 'vote' or update_type == '' or update_type == '')
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_max_magicka)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_max_stamina)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, assigning)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_long)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_set_update)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_dps_update)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, is_ult_update)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, ex_update_types)
    --index = index + 1
    if is_long then
        if is_dps_update then
            index = LGS:WriteUint16(data, index, CompressDPS(value))
        else
            index = LGS:WriteUint16(data, index, value)
        end
    else
        index = LGS:WriteUint8(data, index, value)
    end
    last_send = GetTimeStamp()
    if LGS:Send(type, data) then
        --d('Successfully sent')
        --d(string.format('sent: %s (islong: %s) (update_type [set: %s; dps: %s; ult: %s, EX: %s])', value, tostring(is_long), tostring(is_set_update), tostring(is_dps_update), tostring(is_ult_update), tostring(ex_update_types)))
    else
        --d(string.format('!!!SendingFailed!!! sent: %s (islong: %s) (update_type [set: %s; dps: %s; ult: %s, EX: %s])', value, tostring(is_long), tostring(is_set_update), tostring(is_dps_update), tostring(is_ult_update), tostring(ex_update_types)))
    end
end

local function OnItemUpdate(_, bag_id, _, _, _, _, _)
    if bag_id ~= BAG_WORN then return end
    local unitInfo = GetCachedUnitInfo("player")
    local sets = GetActive5PSets(true)
    for i, set_id in ipairs(unitInfo.sets) do
        if not sets[set_id] or sets[set_id].count < 5 then 
            unitInfo.sets[i] = nil
            handler:SendUpdate(false, 'set', set_id)
        end
    end
    for set_id, set in pairs(sets) do
        if not has_value(unitInfo.sets, set_id) and set.count >= 5 then
            handler:SendUpdate(true, 'set', set_id)
            table.insert(unitInfo.sets, set_id)
        end 
    end
end


local isActive = false

function RaidToolsLGSStatus()
    return isActive
end

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
    info[GetUnitName(unitTag)] = nil
    if(isActive and not IsUnitGrouped("player")) then
        StopSending()
    end
end

local oCastGroupVote = CastGroupVote
function CastGroupVote(choice)
    local int = -1
    if choice == GROUP_VOTE_CHOICE_ABSTAIN then int = 0
    elseif choice == GROUP_VOTE_CHOICE_AGAINST then int = 1
    elseif choice == GROUP_VOTE_CHOICE_FOR then int = 2 end
    handler:SendUpdate(false, 'vote', int)
    oCastGroupVote(choice)
end

local oBeginGroupElection = BeginGroupElection
function BeginGroupElection(...)
    handler:SendUpdate(false, 'vote', 3)
    oBeginGroupElection(...)
end

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local unitInfo = GetCachedUnitInfo(unitTag)
    unitInfo.ultimate = powerValue
    --d(string.format('unitTag: %s, powerValue: %s', unitTag, powerValue))
end

local warhorn_cost_sent = false
local warhorn_cost = 255
local function OnSlotUpdate(_, slot) -- Unused for now
    -- WarHorn base texture: ability_ava_003_a
    -- Identify ultimate
    local texture = GetSlotTexture(8) -- 8=ultimate slot
    if string.match(texture, 'ability_ava_003_a') then
        if not warhorn_cost_sent then
            local required = GetSlotAbilityCost(8)
            warhorn_cost = required
            --handler:SendUpdate(true, 'ult', required)
            --warhorn_cost_sent = true
        end
    end
end

local function IsAnyGroupMemberInFight()
    for i = 1, GetGroupSize() do
        local unit_tag = 'group'..i
        if IsUnitInGroupSupportRange(unit_tag) and IsUnitInCombat(unit_tag) then
            return true
        end
    end
    return false
end

local damage_caused = 0
local combat_start = 0
local last_combat_event = 0
local is_in_combat
local function OnCombatStateChange( _, inCombat )
    --d(string.format('inCombat: %s, IsUnitInCombat(player): %s, IsUnitDead(player): %s', tostring(inCombat), tostring(IsUnitInCombat('player')), tostring(IsUnitDead('player'))))
    if is_in_combat ~= inCombat then
        is_in_combat = inCombat
        if inCombat then
            if GetTimeStamp() - last_combat_event > 5 then
                combat_start = GetTimeStamp()
                damage_caused = 0
            end
        end
    end
end

local function OnCombatEvent(_, actionResult, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, shouldLog, sourceUnitId, targetUnitId, abilityId)
    local isFromMe = sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
    local isDPSEvent = hitValue > 0 and powerType > POWERTYPE_INVALID
    if isDPSEvent then
        last_combat_event = GetTimeStamp()
    end
    if isFromMe and isDPSEvent then
        local unitInfo = GetCachedUnitInfo(unitTag)
        damage_caused = damage_caused + hitValue
        local time = (GetTimeStamp() - combat_start)
        if time == 0 then time = 1 end
        --d(string.format('HitValue: %s (DMGCaused: %s), CombatStart: %s (time: %s), DPS: %s', hitValue, damage_caused, combat_start, time, (damage_caused/time)))
        unitInfo.dps = math.floor(damage_caused / time)
    end
end

local function GetDPS()
    local time = (GetTimeStamp() - combat_start)
    if time == 0 then time = 1 end
    return math.floor(damage_caused / time)
end

local last_data = 'dps'
local cost_update = 0
function handler:SendPeriodicUpdate()
    --d(string.format('%s - %s = %s < 1000?', GetTimeStamp(), last_send, (GetTimeStamp()-last_send)))
    local unitInfo = GetCachedUnitInfo(unitTag)

    if cost_update ~= 0 then
        local ultimate, _, _ = GetUnitPower('player', POWERTYPE_ULTIMATE)
        handler:SendUpdate(false, 'ult', ultimate)
        cost_update = cost_update - 1
    else
        cost_update = 10
        handler:SendUpdate(true, 'ult', warhorn_cost)
    end

    --if last_data == 'dps' then
    --    last_data = 'ult'
    --    local ultimate, _, _ = GetUnitPower('player', POWERTYPE_ULTIMATE)
    --    handler:SendUpdate(false, last_data, ultimate)
    --elseif last_data == 'ult' then
    --    last_data = 'dps'
    --    handler:SendUpdate(false, last_data, GetDPS())
    --end
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
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGUP", EVENT_UNIT_CREATED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGUP", EVENT_UNIT_DESTROYED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGUP", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGUP", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGUP", EVENT_GROUP_MEMBER_CONNECTED_STATUS)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGUP", EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent("LibGroupSocketRTGUP", EVENT_ACTION_SLOT_UPDATED)
    StopSending()
end

local function Load()
    if(not saveData.version) then
        ZO_DeepTableCopy(defaultData, saveData)
    end

    handler.dataHandler = OnData
    LGS.cm:RegisterCallback(type, OnData)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_UNIT_CREATED, OnUnitCreated)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_UNIT_DESTROYED, OnUnitDestroyed)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnItemUpdate)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_GROUP_MEMBER_JOINED, Group_OnJoin)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_GROUP_MEMBER_CONNECTED_STATUS, Group_OnStatusChanged)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("LibGroupSocketRTGUP",  EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_ACTION_SLOTS_FULL_UPDATE, OnSlotUpdate)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent("LibGroupSocketRTGUP",   EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)
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
    OnSlotUpdate()
end

if(handler.Unload) then handler.Unload() end
Load()
