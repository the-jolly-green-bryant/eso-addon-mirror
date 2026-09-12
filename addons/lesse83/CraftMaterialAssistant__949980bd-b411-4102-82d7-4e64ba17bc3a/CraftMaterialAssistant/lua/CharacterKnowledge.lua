local CMA = CraftMaterialAssistant

-- get all characters and check their knowlege
-- return a string containing all character names of characters who can learn the script as well as the number of those characters
function CMA:GetCharactersWithoutKnowledge(craftedAbilityScriptId)
    local LCK = LibCharacterKnowledge
    if not LCK then
        self:SendChatMessage("Missing dependency LibCharacterKnowledge")
        return nil, nil
    end
    -- table holding the characters whithout knowledge
    local learnableForCharacters = {}
    -- get characters
    local characterList = LCK.GetCharacterList()
    
    for i = 1, #characterList do
        -- Call the library function to get the knowledge status
        local status = LCK.IsCraftedAbilityScriptUnlockedByCharacter(craftedAbilityScriptId, nil, characterList[i].id)
        -- Evaluate the knowledge state
        if status == LCK.KNOWLEDGE_UNKNOWN then
            table.insert(learnableForCharacters, characterList[i].name)
        end
    end
    return table.concat(learnableForCharacters, ", "), #learnableForCharacters
end
