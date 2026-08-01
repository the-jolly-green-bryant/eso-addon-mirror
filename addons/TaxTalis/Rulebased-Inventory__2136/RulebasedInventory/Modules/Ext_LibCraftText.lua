-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Ext_LibCraftText.lua
-- File Description: Provider for DoesItemLinkFulfillJournalQuestConditionMasterWrit - function.
-- Load Order Requirements: early
--
-----------------------------------------------------------------------------------

-- Imports
local RbI = RulebasedInventory
local ext = RbI.Import(RbI.extensions)
local LCT = LibCraftText

local function LibCraftTextParse(questIdx, conditionText)
    local questName = GetJournalQuestInfo(questIdx)
    local craftingTypeList = LCT.MasterQuestNameToCraftingTypeList(questName)
    for _, craftType in pairs(craftingTypeList) do
        local parseResult = LCT.ParseMasterCondition(craftType, conditionText)
        if parseResult then
            return craftType, parseResult
        end
    end
end

---------------------------------------------------------------------------------------------------------------
-- Condition Text Perma Cache ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

local conditionTextCache = {} -- permanent
local parseResultCache = {}  -- transitive
-- @returns conditionText, craftType, parseResult
local function getParsedMasterWritCondition(questIdx, stepIdx, condIdx)
    local conditionText, _, _, _, _, _, _, conditionType = GetJournalQuestConditionInfo(questIdx, stepIdx, condIdx)
    if(conditionType == 48) then
        local text = conditionTextCache[questIdx]
        local parseResult = parseResultCache[questIdx]
        if (text == nil or text == '') then
            text = conditionText
            parseResult = nil -- force parse
        elseif(conditionText ~= "") then -- perhaps a language change, so save it always when there is a text
            text = conditionText
        end
        if(LCT ~= nil and parseResult == nil and text ~= '') then
            parseResult = { LibCraftTextParse(questIdx, text) }
            parseResultCache[questIdx] = parseResult
        end
        conditionTextCache[questIdx] = text
        return text, unpack(parseResult or {})
    end
end
local function updateQuestConditionCache(questIdx, reset)
    if(reset) then conditionTextCache[questIdx] = nil end
    if (GetJournalQuestType(questIdx) == QUEST_TYPE_CRAFTING) then
        for stepIdx=1, GetJournalQuestNumSteps(questIdx) do
            for condIdx=1, GetJournalQuestNumConditions(questIdx, stepIdx) do
                local result, craftType, parseResult = getParsedMasterWritCondition(questIdx, stepIdx, condIdx)
                if(parseResult) then return end
            end
        end
    end
    conditionTextCache[questIdx] = nil
end

function ext.InitializeMasterWritHandling()
    if(RbI.character.conditionsTexts) then
        conditionTextCache = RbI.character.conditionsTexts
    else
        RbI.character.conditionsTexts = conditionTextCache
    end
    for questIdx=1, MAX_JOURNAL_QUESTS do
        updateQuestConditionCache(questIdx)
    end
    EVENT_MANAGER:RegisterForEvent(RbI.name.."_MasterWritHandling", EVENT_QUEST_ADDED, function(event, questIdx, name) updateQuestConditionCache(questIdx, true) end)
    EVENT_MANAGER:RegisterForEvent(RbI.name.."_MasterWritHandling", EVENT_QUEST_CONDITION_COUNTER_CHANGED, function(event, questIdx, name) updateQuestConditionCache(questIdx) end)
end

---------------------------------------------------------------------------------------------------------------
-- Item-ParseResult Validation --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

-- Returns an item link from the given itemId.
local function getItemLinkFromItemId(itemId)
    return string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, 0, ITEMSTYLE_NONE, 0, 10000)
end

-- thx@LibLazyCrafting
local function IsItemLinkRobe(link)
    local itemId = GetItemLinkItemId(link)
    local baseLink = getItemLinkFromItemId(itemId)
    local textureFileName = GetItemLinkIcon(baseLink)
    return textureFileName == "/esoui/art/icons/gear_breton_light_robe_d.dds"
end

-- patternIndex => equipType, armorType, weaponType, isRobe
-- can be created via dumpPatternIndex
local patternCatalog = {
    [1] = {
        [1] = { 5, 0, 1 },
        [2] = { 5, 0, 2 },
        [3] = { 5, 0, 3 },
        [4] = { 6, 0, 5 },
        [5] = { 6, 0, 6 },
        [6] = { 6, 0, 4 },
        [7] = { 5, 0, 11 },
        [8] = { 3, 3, 0 },
        [9] = { 10, 3, 0 },
        [10] = { 13, 3, 0 },
        [11] = { 1, 3, 0 },
        [12] = { 9, 3, 0 },
        [13] = { 4, 3, 0 },
        [14] = { 8, 3, 0 },
    },
    [2] = {
        [1] = { 3, 1, 0, true },
        [2] = { 3, 1, 0 },
        [3] = { 10, 1, 0 },
        [4] = { 13, 1, 0 },
        [5] = { 1, 1, 0 },
        [6] = { 9, 1, 0 },
        [7] = { 4, 1, 0 },
        [8] = { 8, 1, 0 },
        [9] = { 3, 2, 0 },
        [10] = { 10, 2, 0 },
        [11] = { 13, 2, 0 },
        [12] = { 1, 2, 0 },
        [13] = { 9, 2, 0 },
        [14] = { 4, 2, 0 },
        [15] = { 8, 2, 0 },
    },
    [6] = {
        [1] = { 6, 0, 8 },
        [2] = { 7, 0, 14 },
        [3] = { 6, 0, 12 },
        [4] = { 6, 0, 13 },
        [5] = { 6, 0, 15 },
        [6] = { 6, 0, 9 },
    },
    [7] = {
        [1] = { 12, 0, 0 },
        [2] = { 2, 0, 0 },
    },
}

local craftHandlerSmithing = function(itemLink, craftType, parseResult, conditionText)
    local patternIndex = parseResult.item.pattern_index
    local equipType, armorType, weaponType, isRobe = unpack(patternCatalog[craftType][patternIndex])
    isRobe = isRobe or false
    local quality = parseResult.quality.index
    local trait = parseResult.trait.trait_type_id
    local setId = parseResult.set.set_id
    local motif = parseResult.motif.motif_id

    local equipType2 = GetItemLinkEquipType(itemLink)
    local armorType2 = GetItemLinkArmorType(itemLink)
    local weaponType2 = GetItemLinkWeaponType(itemLink)
    local isRobe2 = IsItemLinkRobe(itemLink)
    local quality2 = GetItemLinkQuality(itemLink)
    local trait2 = GetItemLinkTraitType(itemLink)
    local setId2 = select(6, GetItemLinkSetInfo(itemLink))
    local motif2 = GetItemLinkItemStyle(itemLink)

    return equipType == equipType2
            and armorType == armorType2
            and weaponType == weaponType2
            and isRobe == isRobe2
            and quality == quality2
            and trait == trait2
            and setId == setId2
            and motif == motif2
end
-- thx@LibAlchemy
local function GetAlchemyTraitsFromItemLink(itemLink)
    local id = select(24,ZO_LinkHandler_ParseLink(itemLink)) or 0
    local effect1,effect2,effect3,effect4
    local calculation = math.floor(id / 65536) % 256
    if calculation > 32 then
        effect1 = calculation - 128
        effect4 = effect1
    else
        effect1 = calculation
    end
    if (math.floor(id / 256) % 256) > 32 then
        effect2 = (math.floor(id / 256) % 256)-128
        effect4 = effect2
    else
        effect2 = math.floor(id / 256) % 256
    end
    if (id % 256) > 32 then
        effect3 = (id % 256)-128
        effect4 = effect3
    else
        effect3 = id % 256
    end
    return effect1,effect2,effect3,effect4
end

local craftHandler = {
    [CRAFTING_TYPE_BLACKSMITHING] = craftHandlerSmithing,
    [CRAFTING_TYPE_CLOTHIER] = craftHandlerSmithing,
    [CRAFTING_TYPE_WOODWORKING] = craftHandlerSmithing,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = craftHandlerSmithing,
    [CRAFTING_TYPE_ALCHEMY] = function(itemLink, craftType, parseResult, conditionText)
        local traitList = {}
        for _, traitIdx in ipairs({GetAlchemyTraitsFromItemLink(itemLink) }) do
            traitList[traitIdx] = true
        end
        for _, trait in ipairs(parseResult.trait_list) do
            if(not traitList[trait.trait_index]) then
                return false
            end
        end
        return true
    end,
    [CRAFTING_TYPE_ENCHANTING] = function(itemLink, craftType, parseResult, conditionText)
        local quality
        if(parseResult.aspect.item_id == 45853) then
            quality = 4 -- rekuta: epic
        else
            quality = 5 -- kuta: legendary
        end
        if(quality ~= GetItemLinkQuality(itemLink)) then return false end
        local itemLinkName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
        return conditionText:lower():find(itemLinkName:lower())
    end,
    [CRAFTING_TYPE_PROVISIONING] = function(itemLink, craftType, parseResult, conditionText)
        return GetItemLinkItemId(itemLink) == parseResult.item.food_item_id
    end,
}

---------------------------------------------------------------------------------------------------------------
-- Public API -------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function ext.DoesItemLinkFulfillJournalQuestConditionMasterWrit(itemLink, questIdx, stepIdx, condIdx)
    local conditionText, craftType, parseResult = getParsedMasterWritCondition(questIdx, stepIdx, condIdx) -- potencially cached text
    if(not parseResult) then return false end
    return craftHandler[craftType](itemLink, craftType, parseResult, conditionText)
end

---------------------------------------------------------------------------------------------------------------
-- Dumping helper functions -----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

if(false) then
    local function dumpPatternIndex()
        local result = {}
        local lastId
        local craftType = GetCraftingInteractionType()
        result[#result + 1] = "[" .. craftType .. "]= {"
        for j = 1, GetNumSmithingPatterns() do
            local _, _, n = GetSmithingPatternMaterialItemInfo(j, 1)
            local curLink = GetSmithingPatternResultLink(j, 1, n, 1, 1, 1)
            local equipType = GetItemLinkEquipType(curLink)
            local armorType = GetItemLinkArmorType(curLink)
            local weaponType = GetItemLinkWeaponType(curLink)
            local isRobe = IsItemLinkRobe(curLink)
            if(isRobe) then
                result[#result + 1] = "[" .. j .. "] = {" .. equipType .. ", " .. armorType .. ", " .. weaponType .. ", " .. "true" .. "},"
            else
                result[#result + 1] = "[" .. j .. "] = {" .. equipType .. ", " .. armorType .. ", " .. weaponType .. "},"
            end
        end
        result[#result + 1] = "}"
        RbI.PrintToClipBoard(table.concat(result, "\n"))
        return result
    end
    EVENT_MANAGER:RegisterForEvent(RbI.name .. "dumpPatternIndex", EVENT_CRAFTING_STATION_INTERACT, dumpPatternIndex)
end