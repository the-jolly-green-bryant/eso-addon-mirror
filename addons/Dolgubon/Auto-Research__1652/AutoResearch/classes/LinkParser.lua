--[[ Used to get the research line index for a given craft skill type from any item link by 
     comparing its equip type and armor/weapon type.  
     Create a new instance with AutoResearch.classes.LinkParser:New(craftSkill) and then use it to 
     get research line index with instance:GetItemLinkResearchLineIndex(itemLink). 
]]--

local ar   = AutoResearch
local class = ar.classes
class.LinkParser = ZO_Object:Subclass()

local name = ar.name .. "LinkParser"

function class.LinkParser:New(...)
    local instance = ZO_Object.New(self)
    instance:Initialize(...)
    return instance
end

function class.LinkParser:Initialize(craftSkill)
    self.name = name
    self.data = {}
    -- Lookup table for mapping research line names to crafting pattern indexes
    self.namesToPatternIndexes = {}
    for patternIndex = 1, GetNumSmithingPatterns() do
        local _, name = GetSmithingPatternInfo(patternIndex)
        self.namesToPatternIndexes[name] = patternIndex
    end
    
    -- Get number of research lines
    local researchLineCount = GetNumSmithingResearchLines(craftSkill)
    
    -- Populate research line lookup table for each research line
    for researchLineIndex = 1, researchLineCount do
        local researchLineName = GetSmithingResearchLineInfo(craftSkill, researchLineIndex)
        local patternIndex = self.namesToPatternIndexes[researchLineName]
        local itemLink = GetSmithingPatternResultLink(patternIndex, 1, (craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING and 5) or 7, 1, 1)
        local equipType = GetItemLinkEquipType(itemLink)
        local armorType = GetItemLinkArmorType(itemLink)
        local weaponType = GetItemLinkWeaponType(itemLink)
        if not self.data[equipType] then
            self.data[equipType] = {}
        end
        if not self.data[equipType][armorType] then
            self.data[equipType][armorType] = {}
        end
        self.data[equipType][armorType][weaponType] = researchLineIndex
    end
end

--[[ Get the research line index for the given item by matching on equip type and armor/weapon type. ]]--
function class.LinkParser:GetItemLinkResearchLineIndex(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    if not self.data[equipType] then
        return
    end
    local armorType = GetItemLinkArmorType(itemLink)
    if not self.data[equipType][armorType] then
        return
    end
    local weaponType = GetItemLinkWeaponType(itemLink)
    return self.data[equipType][armorType][weaponType]
end
