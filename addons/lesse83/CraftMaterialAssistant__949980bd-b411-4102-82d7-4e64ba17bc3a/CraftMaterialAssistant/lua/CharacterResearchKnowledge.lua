local CMA = CraftMaterialAssistant

function CMA:HandleTraitItem(bag, slotIndex)
    -- in order to be able to use that feature we need LibCharacterKnowledge
    local LCK = LibCharacterKnowledge
    if not LCK then
        self:SendChatMessage("Missing dependency LibCharacterKnowledge")
        return nil
    end
    -- now that we know its available, get the item / trait info
    local itemLink = GetItemLink(bag, slotIndex)
    local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
    local craftingSkillType = GetItemLinkCraftingSkillType(itemLink)
    -- Validate that the item actually possesses a valid researchable trait
    if not traitType ~= ITEM_TRAIT_TYPE_NONE then
        -- gather the trait information needed for LibCharacterKnowledge
        local traitIndex, researchLineIndex = self:GetTraitInfos(itemLink, traitType)
        if not traitIndex or not researchLineIndex then
            -- failed to acquire necessary trait information for LibCharacterKnowledge
            return nil
        end
        -- can be researched
        local names, count = self:GetCharactersWithoutTraitKnowledge(craftingSkillType, researchLineIndex, traitIndex)
        if names == nil or count == nil then
            -- libs not available -> ignore
            return nil
        else
            -- got some value: print the script and missing persons
            if count > 0 then
                self:SendChatMessage("Trait of " .. itemLink .. " learnable by " .. count .. " Characters: " .. names .. ". Banking it." )
                return "bank"
            else
                -- known by everyone
                self:SendChatMessage("Trait of " .. itemLink .. " already learned by all characters.")
                return "learned"
            end
        end
    end
    -- either not researchable or other reason it wont work
    return nil
end

-- get all characters and check their knowlege
-- return a string containing all character names of characters who can learn the trait as well as the number of those characters
function CMA:GetCharactersWithoutTraitKnowledge(craftingSkillType, researchLineIndex, traitIndex)
    local LCK = LibCharacterKnowledge
    if not LCK then
        self:SendChatMessage("Missing dependency LibCharacterKnowledge")
        return nil, nil
    end
    -- table holding the characters whithout knowledge
    local researchableForCharacters = {}
    -- get characters
    local characterList = LCK.GetCharacterList()
    
    for i = 1, #characterList do
        -- Call the library function to get the knowledge status
        local status = LCK.CanTraitBeImmediatelyResearchedByCharacter( craftingSkillType, researchLineIndex, traitIndex, nil, characterList[i].id)
        -- Evaluate the knowledge state
        if status ~= false then
            table.insert(researchableForCharacters, characterList[i].name)
        end
    end
    return table.concat(researchableForCharacters, ", "), #researchableForCharacters
end

function CMA:GetTraitInfos(itemLink, traitType)
    -- look up the trait index based on the trait type
    local traitIndex = CMA.traitTypeIndexMap[traitType] or nil
    -- now get the researchLineIndex
    local researchLineIndex = nil
    local weaponType = GetItemLinkWeaponType(itemLink)
    if weaponType == WEAPONTYPE_NONE then
        -- no weapon ... check if its armor or jewelry
        local equipType = GetItemLinkEquipType(itemLink)
        if equipType ~= EQUIP_TYPE_INVALID then
            -- is a valid equipType
            researchLineIndex = self.researchLineIndexEquipTypeMap[equipType] or nil
            -- get armor type (if its medium we need to modify the index)
            local armorType = GetItemLinkArmorType(itemLink)
            if researchLineIndex and (armorType == ARMORTYPE_LIGHT) then
                researchLineIndex = researchLineIndex - 7
            end
        end
    else
        -- its a weapon, set the index based on the lookup map
        researchLineIndex = self.researchLineIndexWeaponTypeMap[weaponType]
    end
    return traitIndex, researchLineIndex
end