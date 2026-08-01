SynergyPriority = SynergyPriority or {}
SynergyPriority.name = "SynergyPriority"
function SynergyPriority:TrackSynergy() 
    if GetNumberOfAvailableSynergies() == 0 then
        return
    end
    for index, value in pairs(SynergyPriority.saved.synergies) do
        for i = 1, GetNumberOfAvailableSynergies() do
            local synName, textureName, prompt, priority, abilityId, canBeUsed = GetSynergyInfoAtIndex(i)
            if canBeUsed then
            if SynergyPriority.saved.synergies[index].name == synName then
                SynergyPriority:GetSynergy(abilityId, synName, priority, canBeUsed)
                return
            end
        end
        end
    end
end
function SynergyPriority:GetSynergy(abilityId, synName, priority, canBeUsed)
    SetSynergyPriorityOverride(abilityId, SynergyPriority.saved.synergies[synName].priority)
end