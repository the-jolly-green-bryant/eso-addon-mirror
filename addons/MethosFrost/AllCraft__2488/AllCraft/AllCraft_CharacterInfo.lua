AllCraft_CharacterInfo = {}
AllCraft_CharacterInfo.name = AllCraft_CharacterInfo

local function ExpertiseLevel(craftTableType)
    local characterExpertiseLevel = {}
    local craftTable = {}
    craftTable[1] = NON_COMBAT_BONUS_BLACKSMITHING_EXTRACT_LEVEL --CRAFTING_TYPE_BLACKSMITHING
    craftTable[2] = NON_COMBAT_BONUS_CLOTHIER_EXTRACT_LEVEL --CRAFTING_TYPE_CLOTHIER
    craftTable[7] = NON_COMBAT_BONUS_JEWELRYCRAFTING_EXTRACT_LEVEL --CRAFTING_TYPE_JEWELRYCRAFTING
    craftTable[6] = NON_COMBAT_BONUS_WOODWORKING_EXTRACT_LEVEL --CRAFTING_TYPE_WOODWORKING
    local skillCurrentLevel = GetNonCombatBonus(craftTable[craftTableType])
    characterExpertiseLevel = skillCurrentLevel
    return characterExpertiseLevel
end
AllCraft_CharacterInfo.ExpertiseLevel = ExpertiseLevel

local function CraftingSkillLevel(craftTableType)
    local skillType, skillIndex = GetCraftingSkillLineIndices(craftTableType)
    local _, rank = GetSkillLineInfo(skillType,skillIndex)
    return rank
end
AllCraft_CharacterInfo.CraftingSkillLevel = CraftingSkillLevel
