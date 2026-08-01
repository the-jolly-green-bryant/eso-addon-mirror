local ADDON_NAME = "CleanLeadsUI"

local function IsRepeatableGreenLead(antiquityData)
    return antiquityData.isRepeatable and antiquityData.quality == 2 -- 2 = green
end

local function MatchAllAntiquitiesWithLeads(antiquityData)
    -- Hide repeatable green leads, show others if in progress or has lead
    if IsRepeatableGreenLead(antiquityData) then
        return false
    end
    return antiquityData:IsInProgress() or antiquityData:HasLead()
end

local function OnAntiquitySceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING then
        if ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA and ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA.SetAntiquityFilterFunction then
            ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA:SetAntiquityFilterFunction(MatchAllAntiquitiesWithLeads)
        end
    end
end


-- Try setting the filter directly at load
if ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA and ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA.SetAntiquityFilterFunction then
    ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA:SetAntiquityFilterFunction(MatchAllAntiquitiesWithLeads)
end
