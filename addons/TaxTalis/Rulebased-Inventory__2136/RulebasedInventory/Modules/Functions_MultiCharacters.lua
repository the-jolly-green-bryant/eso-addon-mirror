-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Ext_CraftApi.lua
-- File Description: Basic character-based knowledge functions. Needs a knowledge
--                   provider like CraftStore addon and a adapter implementation
--                   like Ext_CraftStore.lua
-- Load Order Requirements: early
--
-----------------------------------------------------------------------------------

-- Imports
local RbI = RulebasedInventory
local ext = RbI.extensions
local utils = RbI.utils
local ruleEnv = RbI.ruleEnvironment
local ctx = RbI.executionEnv.ctx
local knowledgeProvider

local descriptions = {
    IsLearnable="IsLearnable(charName, itemLink) returns whether the recipe (cook, furnishing) or motif-style is learnable by a given character.\n\nWill be used for following functions: needLearn, needLearnInOrder",
    IsResearchable="IsResearchable(charName, itemLink) returns whether the trait on the item can be researched by a given character\n\nWill be used for following functions: needTrait, needTraitInOrder",
    GetCharacterLevel="GetCharacterLevel(charName) returns the character level (0-50) of the given character\n\nWill be used for following functions: characterLevelMin, characterLevelMax",
    GetCraftingLevel="GetCraftingLevel(charName, craftingSkill) returns the crafting level (0-10) of the given craftingSkill and character\n\nWill be used for following functions: craftingLevelMin, craftingLevelMax, needCraftingLevelInOrder",
    GetCraftingRank="GetCraftingLevel(charName, craftingSkill) returns the crafting rank (0-10) of the given craftingSkill and character\n\nWill be used for following functions: craftingRankMin, craftingRankMax, craftingRankCount",
    GetMountLevel="GetMountLevel(charName, mountSkill) returns the mount level (0-60) of the given mountSkill and character\n\nWill be used for following functions: mountLevelMin, mountLevelMax, needMountLevelInOrder",
}

-- @return array of missing character names
local function checkCraftChars(retrievalMethod, charNames)
    -- check if all characters are available
    local missingCharacters = {}
    for _, charName in pairs(charNames) do
        if(not knowledgeProvider[retrievalMethod.."IsAvailable"](charName)) then
            missingCharacters[#missingCharacters + 1] = charName
        end
    end
    return missingCharacters
end

local requestedCharsCache = {}
local ensureEverythingLoaded = function(retrievalMethod, charNames)
    if(not knowledgeProvider[retrievalMethod]) then
        ruleEnv.errorNeedRequirement("The requested method '"..retrievalMethod.."' isn't provided by any knowledge-provider!")
    end

    local cache = requestedCharsCache[retrievalMethod]
    local cacheId = utils.ArrayValuesToString(charNames)
    local missingCharacters = cache[cacheId]
    if (missingCharacters == nil) then
        missingCharacters = checkCraftChars(retrievalMethod, charNames)
        cache[cacheId] = missingCharacters
    end
    if (#missingCharacters > 0) then
        local providerName = ext.WhoProvides(retrievalMethod)
        ruleEnv.error("'"..retrievalMethod.."'-knowledge-provider: ".."Not all character data is loaded via '"..providerName.."' addon. Please login with the following characters, so that the addon can fill the needed data or exclude them in your rules: " .. utils.ArrayValuesToString(missingCharacters))
    end
end

local me = RbI.GetUnitName('player')
-- @param needFn must return a boolean. Will be called with the charName as first argument.
local function checkNeed(retrievalMethod, inOrder, charNames, needFn, ...)
    ensureEverythingLoaded(retrievalMethod, charNames)
    if(inOrder) then
        for _, charName in pairs(charNames) do
            if(charName == me) then
                return needFn(charName, ...)
            elseif(needFn(charName, ...)) then
                return false
            end
        end
        return false
    else
        for _, charName in pairs(charNames) do
            if(charName == me) then
                if(needFn(charName, ...)) then
                    return true
                end
            elseif(needFn(charName, ...)) then
                return true
            end
        end
        return false
    end
end

-- @param numberFn must return a number. Will be called with the charName as first argument.
local function getMin(retrievalMethod, charNames, default, numberFn, ...)
    ensureEverythingLoaded(retrievalMethod, charNames)
    local result = default
    for _, charName in pairs(charNames) do
        local value = numberFn(charName, ...)
        result = math.min(result, value)
    end
    return result
end
-- @param numberFn must return a number. Will be called with the charName as first argument.
local function getMax(retrievalMethod, charNames, default, numberFn, ...)
    ensureEverythingLoaded(retrievalMethod, charNames)
    local result = default
    for _, charName in pairs(charNames) do
        local value = numberFn(charName, ...)
        result = math.max(result, value)
    end
    return result
end
-- @param getFn will be called with the charName as first argument.
local function getCount(retrievalMethod, charNames, valueToCount, getFn, ...)
    ensureEverythingLoaded(retrievalMethod, charNames)
    local result = 0
    for _, charName in pairs(charNames) do
        local value = getFn(charName, ...)
        if(value == valueToCount) then
            result = result + 1
        end
    end
    return result
end


-- direct need check, so we don't need to wait that knowledge provider updates its values after usage
local function getLearnNeed(charName, itemLink)
    if(charName == me) then
        local itemType, itemSubType = GetItemLinkItemType(itemLink)
        if(itemType == ITEMTYPE_RECIPE) then
            return not IsItemLinkRecipeKnown(itemLink)
        elseif(itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) then
            return not IsItemLinkBookKnown(itemLink)
        end
        return false
    else
        return knowledgeProvider.IsLearnable(charName, itemLink)
    end
end
local function InOrderLearn(inOrder, charNames)
    local itemLink = ctx.itemLink
    local itemType, itemSubType = GetItemLinkItemType(itemLink)
    if(itemType ~= ITEMTYPE_RECIPE and itemType ~= ITEMTYPE_RACIAL_STYLE_MOTIF) then
        return false
    end
    return checkNeed("IsLearnable", inOrder, charNames, getLearnNeed, itemLink)
end

local function getResearchNeed(charName, itemLink)
    if(charName == me) then
        return CanItemLinkBeTraitResearched(itemLink)
    else
        return knowledgeProvider.IsResearchable(charName, itemLink)
    end
end
local function InOrderResearch(inOrder, charNames)
    return checkNeed("IsResearchable", inOrder, charNames, getResearchNeed, ctx.itemLink)
end

-- direct need check, so we don't need to wait that knowledge provider updates its values after usage
local function getCharacterLevel(charName)
    if(charName == me) then
        return GetUnitLevel("player")
    else
        return knowledgeProvider.GetCharacterLevel(charName) or 0
    end
end
local function GetCharacterLevelMin(default, charNames)
    return getMin("GetCharacterLevel", charNames, default, getCharacterLevel)
end
local function GetCharacterLevelMax(default, charNames)
    return getMax("GetCharacterLevel", charNames, default, getCharacterLevel)
end

-- direct need check, so we don't need to wait that knowledge provider updates its values after usage
local function getCraftingLevel(charName, craftingSkill)
    if(charName == me) then
        local skillType, skillId = GetCraftingSkillLineIndices(craftingSkill)
        local _, level = GetSkillLineInfo(skillType, skillId)
        return (level or 0)
    else
        return knowledgeProvider.GetCraftingLevel(charName, craftingSkill) or 0
    end
end
local function getCraftingLevelNeed(charName, craftingSkill)
    return getCraftingLevel(charName, craftingSkill) < 50
end
local function InOrderCraftingLevel(inOrder, craftingSkill, charNames)
    return checkNeed("GetCraftingLevel", inOrder, charNames, getCraftingLevelNeed, craftingSkill)
end
local function GetCraftingLevelMin(craftingSkill, default, charNames)
    return getMin("GetCraftingLevel", charNames, default, getCraftingLevel, craftingSkill)
end
local function GetCraftingLevelMax(craftingSkill, default, charNames)
    return getMax("GetCraftingLevel", charNames, default, getCraftingLevel, craftingSkill)
end

local function getCraftingRank(charName, craftingSkill)
    -- TODO: charName==me should directly retrieved via ESO-API
    return knowledgeProvider.GetCraftingRank(charName, craftingSkill) or 0
end
local function GetCraftingRankMin(craftingSkill, default, charNames)
    return getMin("GetCraftingRank", charNames, default, getCraftingRank, craftingSkill)
end
local function GetCraftingRankMax(craftingSkill, default, charNames)
    return getMax("GetCraftingRank", charNames, default, getCraftingRank, craftingSkill)
end
local function GetCraftingRankCount(craftingSkill, rank, charNames)
    return getCount("GetCraftingRank", charNames, rank, getCraftingRank, craftingSkill)
end

local mountSkillMap = {
    [RIDING_TRAIN_CARRYING_CAPACITY] = 1,
    [RIDING_TRAIN_STAMINA] = 3,
    [RIDING_TRAIN_SPEED] = 5,
}
local function getMountLevel(charName, mountSkill)
    if(charName == me) then
        return select(mountSkillMap[mountSkill], GetRidingStats())
    else
        return knowledgeProvider.GetMountLevel(charName, mountSkill) or 0
    end
end
local function getMountLevelNeed(charName, mountSkill)
    return getMountLevel(charName, mountSkill) < 60
end
local function GetMountLevelMin(mountSkill, default, charNames)
    return getMin("GetMountLevel", charNames, default, getMountLevel, mountSkill)
end
local function GetMountLevelMax(mountSkill, default, charNames)
    return getMax("GetMountLevel", charNames, default, getMountLevel, mountSkill)
end
local function InOrderMountLevel(inOrder, mountSkill, charNames)
    return checkNeed("GetMountLevel", inOrder, charNames, getMountLevelNeed, mountSkill)
end

local MultiCharacterApi = {
    InOrderLearn = InOrderLearn, -- recipe (cook, furnishing), motif-style
    InOrderResearch = InOrderResearch, -- analyze trait

    GetCharacterLevel = getCharacterLevel,
    GetCharacterLevelMin = GetCharacterLevelMin,
    GetCharacterLevelMax = GetCharacterLevelMax,

    GetCraftingLevelMin = GetCraftingLevelMin,
    GetCraftingLevelMax = GetCraftingLevelMax,
    InOrderCraftingLevel = InOrderCraftingLevel,

    GetCraftingRankMin = GetCraftingRankMin,
    GetCraftingRankMax = GetCraftingRankMax,
    GetCraftingRankCount = GetCraftingRankCount,

    GetMountLevelMin = GetMountLevelMin,
    GetMountLevelMax = GetMountLevelMax,
    InOrderMountLevel = InOrderMountLevel,
}
function ext.RequireMultiCharactersApi()
    return MultiCharacterApi
end

local charNameIdMapping = {}
for i = 1, GetNumCharacters() do
    local characterName, _, _, _, _, _, characterId = GetCharacterInfo(i)
    charNameIdMapping[zo_strformat("<<C:1>>", characterName)] = characterId
end
function ext.GetCharId(charName)
    return charNameIdMapping[charName]
end

local function toRecipeLink(recipeId)
    return string.format("|H1:item:%s:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", tostring(recipeId))
end
function ext.GetARecipeLink()
    return toRecipeLink(45888)
end

--------- PROVIDER MANAGEMENT --------------------------
local registeredProvider = {} -- name -> providerImpl
local selectedProvider = {} -- retrievalMethod -> providerName
function ext.GetRetrievalMethods()
    return selectedProvider
end
function ext.GetAllRetrievalMethods()
    local result = {}
    for name in pairs(descriptions) do
        result[name] = true
    end
    for name in pairs(selectedProvider) do
        result[name] = true
    end
    return result
end
function ext.WhoCanProvide(retrievalMethod)
    local result = {}
    for name, provider in pairs(registeredProvider) do
        if(provider[retrievalMethod]) then
            result[#result+1] = name
        end
    end
    return result
end
function ext.WhoProvides(retrievalMethod)
    return selectedProvider[retrievalMethod]
end
function ext.GetDescription(retrievalMethod)
    return descriptions[retrievalMethod]
end
function ext.GetAllProvider()
    return registeredProvider
end
function ext.SetProvider(providerName, retrievalMethod)
    local provider = registeredProvider[providerName]
    selectedProvider[retrievalMethod] = providerName
    knowledgeProvider[retrievalMethod] = provider[retrievalMethod]
    knowledgeProvider[retrievalMethod.."IsAvailable"] = provider.IsAvailable
    requestedCharsCache[retrievalMethod] = {}
end
local function addProvider(providerName, provider, prio)
    if(provider == nil) then return end
    if(not provider.IsAvailable) then error("Multichar knowledge-provider has to implement .IsAvailable(charName)") end
    registeredProvider[providerName] = provider
    for fnName, fn in pairs(provider) do
        if(fnName ~= "IsAvailable" and not selectedProvider[fnName]) then
            ext.SetProvider(providerName, fnName)
        end
    end
end

function ext.LoadProvider()
    knowledgeProvider = {}
    addProvider("CraftStore", ext.GetCraftStore(), true)
    --addProvider("LibCharacterKnowledge", ext.GetLibCharacterKnowledge()) -- TODO: we can provider more, when we can save the user's choice
end