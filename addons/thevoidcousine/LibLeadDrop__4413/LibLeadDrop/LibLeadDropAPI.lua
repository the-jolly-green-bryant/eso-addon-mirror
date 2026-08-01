function LibLeadDrop.GetLeadDropZones(antiquityId) --> Array[int]
    -- WIP: Incomplete Data
    return LibLeadDrop.data.leads[antiquityId] and LibLeadDrop.data.leads[antiquityId][4]
end

function LibLeadDrop.getLeadDropHint(antiquityId) --> String
    return LibLeadDrop.data.leads[antiquityId] and LibLeadDrop.data.leads[antiquityId][2]
end

function LibLeadDrop.getLeadDropHintLink(antiquityId) --> String
    return LibLeadDrop.data.leads[antiquityId] and LibLeadDrop.data.leads[antiquityId][3]
end

function LibLeadDrop.getAntiquityIdsForSet(setId) --> Array[int]
    return LibLeadDrop.data.setIdsToAntiquityIdLists[setId] and LibLeadDrop.data.setIdsToAntiquityIdLists[setId] or {}
end
