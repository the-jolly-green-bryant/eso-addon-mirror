local function MatchAllAntiquitiesWithLeads(antiquityData)
    return antiquityData:IsInProgress() or antiquityData:HasLead()
end

ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA:SetAntiquityFilterFunction(MatchAllAntiquitiesWithLeads)