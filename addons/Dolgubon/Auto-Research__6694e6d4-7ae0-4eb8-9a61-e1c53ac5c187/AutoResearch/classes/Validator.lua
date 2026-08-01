--[[ Used to validate that a given slot conforms to the following rules:
        + Is a weapon or armor that has a valid trait and isn't intricate, ornate or otherwise special
        + Is not locked with the in-game or FCO Item Saver lock
        + Is marked for research with FCO Item Saver
        
          -OR-
          
          Is of a cheap style (base racial + primal, barbaric and ancient elf)
          Is white, green or blue quality
          Is not part of an item set
          
    Usage:
        local validator = AutoResearch.classes.Validator:New(bagId, slotIndex)
        local traitType = validator:Validate()
        if traitType then
            -- Valid
        else
            -- Invalid
        end
]]--

local ar   = AutoResearch
local class = ar.classes
class.Validator = ZO_Object:Subclass()

local name = ar.name .. "Validator"
local invalidTraits = {
    [ITEM_TRAIT_TYPE_NONE]              = true,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE]  = true,
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE]     = true,
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE]      = true,
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]   = true,
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]    = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = true,
}
local craftSkillsByItemSoundCategory = {
    [ITEM_SOUND_CATEGORY_BOW]             = CRAFTING_TYPE_WOODWORKING,
    [ITEM_SOUND_CATEGORY_DAGGER]          = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_HEAVY_ARMOR]     = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_LIGHT_ARMOR]     = CRAFTING_TYPE_CLOTHIER,
    [ITEM_SOUND_CATEGORY_MEDIUM_ARMOR]    = CRAFTING_TYPE_CLOTHIER,
    [ITEM_SOUND_CATEGORY_NECKLACE]        = CRAFTING_TYPE_JEWELRYCRAFTING,
    [ITEM_SOUND_CATEGORY_ONE_HAND_AX]     = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_ONE_HAND_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_ONE_HAND_SWORD]  = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_RING]            = CRAFTING_TYPE_JEWELRYCRAFTING,
    [ITEM_SOUND_CATEGORY_SHIELD]          = CRAFTING_TYPE_WOODWORKING,
    [ITEM_SOUND_CATEGORY_STAFF]           = CRAFTING_TYPE_WOODWORKING,
    [ITEM_SOUND_CATEGORY_TWO_HAND_AX]     = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_TWO_HAND_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_TWO_HAND_SWORD]  = CRAFTING_TYPE_BLACKSMITHING,
}

function class.Validator:New(...)
    local instance = ZO_Object.New(self)
    instance:Initialize(...)
    return instance
end

function class.Validator:Initialize(bagId, slotIndex)
    self.name = name
    self.bagId = bagId
    self.slotIndex = slotIndex
end

--[[ If FCOIS 1.0+ is installed, then returns true for slots that are marked with the research icon. 
     Otherwise, returns nil. ]]--
function class.Validator:IsFcoisResearchMarked()
    if not FCOIS or not FCOIS.IsMarked then
        return
    end
    if FCOIS.IsMarked(self.bagId, self.slotIndex, FCOIS_CON_ICON_RESEARCH) then
        return true
    end
end

--[[ If FCOIS 1.0+ is installed, then returns true for slots that are marked with the lock icon. 
     Otherwise, returns nil. ]]--
function class.Validator:IsFcoisLocked()
    if not FCOIS or not FCOIS.IsMarked then
        return
    end
    if FCOIS.IsMarked(self.bagId, self.slotIndex, FCOIS_CON_ICON_LOCK) then
        return true
    end
end

function class.Validator:GetItemLinkCraftSkill(itemLink)
    local itemSoundCategory = GetItemSoundCategoryFromLink(itemLink)
    return craftSkillsByItemSoundCategory[itemSoundCategory]
end

--[[ If the item slot for this instance is valid, returns the item type.  Otherwise, returns nil. ]]--
function class.Validator:Validate()
    local slotData = SHARED_INVENTORY:GenerateSingleSlotData(self.bagId, self.slotIndex)
    if not slotData
       or slotData.isPlayerLocked
       or slotData.traitInformation == ITEM_TRAIT_INFORMATION_RETRAITED
       or slotData.traitInformation == ITEM_TRAIT_INFORMATION_RECONSTRUCTED
    then 
        return
    end
    if self:IsFcoisLocked() then
        return
    end
    slotData.itemLink = slotData.itemLink or GetItemLink(self.bagId, self.slotIndex)
    slotData.itemTraitType = slotData.itemTraitType or GetItemTrait(self.bagId, self.slotIndex)
    if self:IsFcoisResearchMarked() then
        return slotData
    end
    slotData.itemTraitTypeCategory = slotData.itemTraitTypeCategory or GetItemTraitTypeCategory(slotData.itemTraitType)
    slotData.itemStyle = slotData.itemStyle or GetItemLinkItemStyle(slotData.itemLink)
    if ar.styledCategories[slotData.itemTraitTypeCategory] and slotData.itemStyle == ITEMSTYLE_NONE then 
        return
    end
    if invalidTraits[slotData.itemTraitType] then
        return
    end
    slotData.craftSkill = slotData.craftSkill or self:GetItemLinkCraftSkill(slotData.itemLink)
    if not slotData.craftSkill or not ar.craftSkills[slotData.craftSkill] then
        return
    end
    if slotData.quality > ar.settings.maxQuality[slotData.craftSkill] or (ar.stylesEnabled == AUTORESEARCH_ENABLE_SELECTED and ar.styledCategories[slotData.itemTraitTypeCategory] and not ar.settings.styles[slotData.itemStyle]) then
        return
    end
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(slotData.itemLink)
    slotData.hasSet = hasSet
    slotData.setId = setId
    if hasSet then
        if not LibSets or not ar.settings.sets then
            return
        end
        local libSetsSetType = LibSets.GetSetType(setId)
        local setType = libSetsSetType ~= nil and ar.setTypeMap[libSetsSetType]
        local setsEnabled = setType ~= nil and ar.settings.setsEnabled[setType] or AUTORESEARCH_ENABLE_NONE
        if setsEnabled == AUTORESEARCH_ENABLE_NONE then
            return
        end
        if setsEnabled == AUTORESEARCH_ENABLE_SELECTED and not ar.settings.sets[setId] then
            return
        end
    end
    
    return slotData
end