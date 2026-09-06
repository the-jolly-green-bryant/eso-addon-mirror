local BA = BMGAdventures
BA.MasteryAdapter = BA.MasteryAdapter or {}

function BA.MasteryAdapter:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name.."Craft", EVENT_CRAFT_COMPLETED, function(_, craftSkill)
        BA.ActivityRouter:Publish({activityType="CRAFT_COMPLETE", subject={activityId=tostring(craftSkill)}, result={quantity=1}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_CRAFT_COMPLETED"}})
    end)
    EVENT_MANAGER:RegisterForEvent(BA.name.."Research", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, function(_, craftingSkillType, researchLineIndex, traitIndex)
        BA.ActivityRouter:Publish({activityType="TRAIT_RESEARCH_COMPLETE", subject={activityId=tostring(craftingSkillType)..":"..tostring(researchLineIndex)..":"..tostring(traitIndex)}, result={quantity=1}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED"}})
    end)
    EVENT_MANAGER:RegisterForEvent(BA.name.."Lore", EVENT_LORE_BOOK_LEARNED, function(_, categoryIndex, collectionIndex, bookIndex, guildIndex, isMaxRank)
        BA.ActivityRouter:Publish({activityType="LORE_BOOK_LEARNED", subject={activityId=tostring(categoryIndex)..":"..tostring(collectionIndex)..":"..tostring(bookIndex)}, result={quantity=1}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_LORE_BOOK_LEARNED"}})
    end)
    EVENT_MANAGER:RegisterForEvent(BA.name.."LoreCollection", EVENT_LORE_COLLECTION_COMPLETED, function(_, categoryIndex, collectionIndex, guildIndex, isMaxRank)
        BA.ActivityRouter:Publish({activityType="LORE_COLLECTION_COMPLETE", subject={activityId=tostring(categoryIndex)..":"..tostring(collectionIndex)}, result={quantity=1}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_LORE_COLLECTION_COMPLETED"}})
    end)
end
