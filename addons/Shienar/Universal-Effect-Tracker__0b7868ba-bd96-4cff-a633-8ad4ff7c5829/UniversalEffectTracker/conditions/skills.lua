UniversalTracker = UniversalTracker or {}

--The callback below also runs on barswaps, so I'm adding an extra check to avoid unnecessary reinitialization.
local areSkillsEquipped = {
    account = {},
    character = {}
}


function UniversalTracker.hasSkillEquipped(queriedSkillID)
    for i = 3, 8 do
        if queriedSkillID == GetEffectiveAbilityIdForAbilityOnHotbar(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY), HOTBAR_CATEGORY_PRIMARY) or
            queriedSkillID == GetEffectiveAbilityIdForAbilityOnHotbar(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP), HOTBAR_CATEGORY_BACKUP) then
                return true
        end
    end
    return false
end



ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback("SlotUpdated", function(hotbarCategory, actionSlotIndex, isChangedByPlayer)
    --Callback can fire before initialization function when loading in a character.
    if not UniversalTracker.savedVariables or not UniversalTracker.characterSavedVariables then return end

    for k, v in pairs(UniversalTracker.savedVariables.trackerList) do
        if tonumber(v.requiredSkillID) then
            if UniversalTracker.hasSkillEquipped(tonumber(v.requiredSkillID)) then
                if not areSkillsEquipped.account[v.id] then
                    UniversalTracker.InitSingleDisplay(v)
                    areSkillsEquipped.account[v.id] = true
                end
            else
                UniversalTracker.ReleaseSingleDisplay(v)
                areSkillsEquipped.account[v.id] = nil
            end
        end
    end

    for k, v in pairs(UniversalTracker.characterSavedVariables.trackerList) do
        if tonumber(v.requiredSkillID) and areSkillsEquipped.character[v.id] then
            if UniversalTracker.hasSkillEquipped(tonumber(v.requiredSkillID)) then
                if not areSkillsEquipped.character[v.id] then
                    UniversalTracker.InitSingleDisplay(v)
                    areSkillsEquipped.character[v.id] = true
                end
            else
                UniversalTracker.ReleaseSingleDisplay(v)
                areSkillsEquipped.character[v.id] = nil
            end
        end
    end
end)