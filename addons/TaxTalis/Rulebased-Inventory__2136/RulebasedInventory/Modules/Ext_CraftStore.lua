-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Ext_CraftStore.lua
-- File Description: Knowledge provider for Functions_MultiCharacters.
-- Load Order Requirements: early
--
-----------------------------------------------------------------------------------

-- Imports
local RbI = RulebasedInventory
local ext = RbI.extensions
local CraftStore = CraftStoreFixedAndImprovedLongClassName

-- @return whether the given character-data is available
local function IsAvailable(charName)
    for _, csCharName in pairs(CraftStore.GetCharacters()) do
        if (charName == csCharName) then
            return true
        end
    end
    return false
end

-- @returns whether the recipe (cook, furnishing) or motif-style is learnable.
local function IsLearnable(charName, link)
    local id = CraftStore.SplitLink(link, 3)
    local chars = {}
    for key in pairs(CraftStore.Data.cook.knowledge) do
        chars[#chars+1] = key
    end
    return not (CraftStore.Data.cook.knowledge[charName][id] or CraftStore.Data.furnisher.knowledge[charName][id] or CraftStore.Data.style.knowledge[charName][id])
end

-- @returns whether the trait on the item can be researched by the given character
local function IsResearchable(charName, link)
    local craft, line, trait = CraftStore.GetTrait(link)
    --d(link..": ", craft, line, trait)
    if(not craft) then return false end
    local result = CraftStore.Data.crafting.researched[charName][craft][line][trait]
    --d(charName..": "..link.." "..tostring(result))
    return not result
end

-- @returns the character level (1-50)
local function GetCharacterLevel(charName)
    local level = CraftStore.Account.player[charName].level
    return (level == 0 and 50 or level) or 0
end

-- @returns the crafting rank (0-10)
local function GetCraftingRank(charName, craftingSkill)
    return CraftStore.Account.crafting.skill[charName][craftingSkill]["level"] or 0
end

-- @returns the crafting level (0-50)
local function GetCraftingLevel(charName, craftingSkill)
    return CraftStore.Account.crafting.skill[charName][craftingSkill]["rank"] or 0
end

local mountTrainMap = {
    [RIDING_TRAIN_CARRYING_CAPACITY] = "space",
    [RIDING_TRAIN_SPEED] = "speed",
    [RIDING_TRAIN_STAMINA] = "stamina",
}
-- @returns the mount level (0-60)
local function GetMountLevel(charName, mountSkill)
    local result = CraftStore.Account.player[charName].mount[mountTrainMap[mountSkill]]
    if(not result) then return 0 end
    result = result:sub(1, result:find("/")-1)
    return tonumber(result)
end

function ext.GetCraftStore()
    if (CraftStore ~= nil) then
        return {
            IsAvailable = IsAvailable,
            IsLearnable = IsLearnable,
            IsResearchable = IsResearchable,
            GetCharacterLevel = GetCharacterLevel,
            GetCraftingRank = GetCraftingRank,
            GetCraftingLevel = GetCraftingLevel,
            GetMountLevel = GetMountLevel,
        }
    end
end