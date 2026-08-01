-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: DataCollected.lua
-- File Description: This file contains data which is needed for rule evaluation
-- Load Order Requirements: after Data, before Item
--
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory

-- get data for functions collected from game variables
local collected = {}
RbI.collectedData = collected

-- imports
local utils = RbI.Import(RbI.utils)
local dataTypeHandler = RbI.Import(RbI.dataTypeHandler)

local function addCollectedData(dataTableKey, key, value)
    key = key:lower()
    dataTypeHandler.addData(RbI.dataType[dataTableKey], key, value)
    dataTypeHandler.addData(RbI.collectedData[dataTableKey], key, value)
end
local function removeCollectedData(dataTableKey, key, value) -- only for collected
    key = key:lower()
    dataTypeHandler.removeData(RbI.dataType[dataTableKey], key, value)
    dataTypeHandler.removeData(RbI.collectedData[dataTableKey], key, value)
end

-- dynamic values for names collected from ingame functions
local function CollectByIterator()
    local collector = {
        armorType = {ARMORTYPE_ITERATION_BEGIN, ARMORTYPE_ITERATION_END, "SI_ARMORTYPE"},
        bindType = {BIND_TYPE_ITERATION_BEGIN, BIND_TYPE_ITERATION_END, "SI_BINDTYPE"},
        equipType = {EQUIP_TYPE_ITERATION_BEGIN, EQUIP_TYPE_ITERATION_END, "SI_EQUIPTYPE"},
        quality = {ITEM_QUALITY_ITERATION_BEGIN, ITEM_QUALITY_ITERATION_END, "SI_ITEMQUALITY"},
        traitInfo = {ITEM_TRAIT_INFORMATION_ITERATION_BEGIN, ITEM_TRAIT_INFORMATION_ITERATION_END, "SI_ITEMTRAITINFORMATION"},
        trait = {ITEM_TRAIT_TYPE_ITERATION_BEGIN, ITEM_TRAIT_TYPE_ITERATION_END, "SI_ITEMTRAITTYPE"},
        type = {ITEMTYPE_ITERATION_BEGIN, ITEMTYPE_ITERATION_END, "SI_ITEMTYPE"},
        sType = {SPECIALIZED_ITEMTYPE_ITERATION_BEGIN, SPECIALIZED_ITEMTYPE_ITERATION_END, "SI_SPECIALIZEDITEMTYPE"},
        weaponType = {WEAPONTYPE_ITERATION_BEGIN, WEAPONTYPE_ITERATION_END, "SI_WEAPONTYPE" },
    }

    for enumName, collectorData in pairs(collector) do
        local newData = {}
        for enumIndex = collectorData[1], collectorData[2] do
            local name = GetString(collectorData[3], enumIndex)
            if(name ~= nil and name ~= "" and name:lower() ~= 'do not translate') then
                dataTypeHandler.addData(newData, name, enumIndex)
            end
        end
        collected[enumName] = newData
    end
end
CollectByIterator()

local function CollectSpecials()
    collected.style = {}
    -- collect styles
    for enumIndex = 1, GetNumValidItemStyles() do
        local styleId = GetValidItemStyleId(enumIndex)
        local name = zo_strformat("<<1>>", GetItemStyleName(styleId))
        if(name ~= nil and name ~= "") then
            collected.style[name] = styleId
        end
    end
end
CollectSpecials()

collected.cSkill= {}
local dataType = RbI.dataType
for _, skillId in pairs(dataType.cSkill) do
    local skillName = zo_strformat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(skillId))
    if(type(skillName) == 'string') then -- could be a new value from test-server
        collected.cSkill[skillName] = skillId
    end
end

local function getHomebankNickName(bagId)
    local collectibleId = GetCollectibleForHouseBankBag(bagId)
    if collectibleId ~= 0 then
        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
        if collectibleData then
            local nickname = collectibleData:GetNickname()
            if(nickname ~= "") then
                return nickname
            end
        end
    end
end
local bankCollectibles = {}
collected["bank"] = (function()
    local result = {}
    for _, bagId in pairs(RbI.data.getHomeBanks()) do
        local collectibleId = GetCollectibleForHouseBankBag(bagId)
        local nickname = getHomebankNickName(bagId)
        bankCollectibles[collectibleId] = {bagId, nickname}
        if(nickname ~= nil) then
            dataTypeHandler.addData(result, nickname, bagId)
        end
    end
    return result
end)()
EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_COLLECTIBLE_UPDATED, function(eventId, collectibleId)
    local packedBankCollectible = bankCollectibles[collectibleId]
    if(packedBankCollectible) then
        local bagId, oldNickname = unpack(packedBankCollectible)
        local newNickname = getHomebankNickName(bagId)
        if(oldNickname) then removeCollectedData("bank", oldNickname, bagId) end
        if(newNickname) then addCollectedData("bank", newNickname, bagId) end
        bankCollectibles[collectibleId] = {bagId, newNickname}
    end
end)

-- merge collected data into RbI.dataType
for enumName, enum in pairs(collected) do
    local targetEnum = dataType[enumName]
    for key, value in pairs(enum) do
        dataTypeHandler.addData(targetEnum, string.lower(key), value)
    end
end

-- only for test-environment: check data type validity
if(RbI.class.DataDumper ~= nil) then
    for name, data in pairs(RbI.dataType) do
        if(utils.isArray(data)) then
            for _, value in pairs(data) do
                if(value ~= value:lower()) then error('Not lowercased value: '..name..' '..value)  end
            end
        else
            for key, _ in pairs(data) do
                if(type(key) ~= 'string') then
                    error("not a string "..name..' => '..tostring(key))
                end
                if(key ~= key:lower()) then error('Not lowercased key: '..name..' '..key)  end
            end
        end
    end
end