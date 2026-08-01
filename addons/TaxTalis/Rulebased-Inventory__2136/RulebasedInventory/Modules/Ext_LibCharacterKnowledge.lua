-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Ext_LibCharacterKnowledge.lua
-- File Description: Knowledge provider for Functions_MultiCharacters.
-- Load Order Requirements: early
--
-----------------------------------------------------------------------------------

-- Imports
local RbI = RulebasedInventory
local ext = RbI.extensions
local LCK = LibCharacterKnowledge

local function getKnowledge(charName, link)
    local charId = ext.GetCharId(charName)
    return LCK.GetItemKnowledgeForCharacter(link, nil, charId)
end

-- @return whether the given character-data is available
local function IsAvailable(charName)
    local known = getKnowledge(charName, ext.GetARecipeLink())
    return known == LCK.KNOWLEDGE_KNOWN or known == LCK.KNOWLEDGE_UNKNOWN
end

-- @returns whether the recipe (cook, furnishing) or motif-style is learnable.
local function IsLearnable(charName, link)
    local lckKnowledge = getKnowledge(charName, link)
    if lckKnowledge == LCK.KNOWLEDGE_UNKNOWN then
        return true
    end
    return false
end

function ext.GetLibCharacterKnowledge()
    if (LCK ~= nil) then
        return {
            IsAvailable = IsAvailable,
            IsLearnable = IsLearnable,
        }
    end
end


