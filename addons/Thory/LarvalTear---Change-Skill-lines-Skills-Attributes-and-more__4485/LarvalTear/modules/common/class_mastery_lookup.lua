local Addon = LarvalTearMod
local M = Addon.Modules.ClassMasteryLookup
local Util = Addon.Common.Util

local function RequireBooleanArgument(value, name)
    if type(value) ~= "boolean" then
        error(name .. " must be explicitly provided as a boolean", 3)
    end
end

function M:ResolveRankOneAbilityId(skillData)
    local rankData = Util:SafeCallMethod(skillData, "GetRankData", 1)
    local abilityId = tonumber(Util:SafeCallMethod(rankData, "GetAbilityId"))
    return abilityId ~= nil and abilityId > 0 and math.floor(abilityId) or nil
end

function M:ResolveLineData(skillLineId, requireActive, validateId)
    RequireBooleanArgument(requireActive, "requireActive")
    RequireBooleanArgument(validateId, "validateId")

    if validateId and (type(skillLineId) ~= "number" or skillLineId <= 0) then
        return nil, "invalid_skill_line_id"
    end

    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetSkillLineDataById) ~= "function" then
        return nil, "skills_data_manager_unavailable"
    end

    local skillLineData = Util:SafeCallMethod(SKILLS_DATA_MANAGER, "GetSkillLineDataById", skillLineId)
    if type(skillLineData) ~= "table" then
        return nil, "skill_line_data_missing"
    end

    Util:SafeCallMethod(skillLineData, "RefreshDynamicData", true)

    if Util:SafeCallMethod(skillLineData, "IsClassMastery") ~= true then
        return nil, "not_class_mastery_line"
    end

    if requireActive and Util:SafeCallMethod(skillLineData, "IsActive") ~= true then
        return nil, "mastery_line_inactive"
    end

    return skillLineData, nil
end

function M:IteratePassives(skillLineData)
    local passives = {}
    local numSkills = Util:SafeCallMethod(skillLineData, "GetNumSkills") or 0
    if type(numSkills) ~= "number" or numSkills <= 0 then
        return passives
    end

    for skillIndex = 1, numSkills do
        local skillData = Util:SafeCallMethod(skillLineData, "GetSkillDataByIndex", skillIndex)
        if type(skillData) == "table" and Util:SafeCallMethod(skillData, "IsPassive") == true then
            passives[#passives + 1] = skillData
        end
    end

    return passives
end

function M:FindPassiveByAbilityId(skillLineData, abilityId)
    local numSkills = Util:SafeCallMethod(skillLineData, "GetNumSkills") or 0
    if type(numSkills) ~= "number" or numSkills <= 0 then
        return nil, "skill_line_empty"
    end

    for _, skillData in ipairs(self:IteratePassives(skillLineData)) do
        if self:ResolveRankOneAbilityId(skillData) == abilityId then
            return skillData, nil
        end
    end

    return nil, "saved_ability_not_found"
end

function M:GetCommittedRank(skillData)
    local purchased = Util:SafeCallMethod(skillData, "IsPurchased") == true
    if not purchased then
        return 0, false
    end

    local rank = tonumber(Util:SafeCallMethod(skillData, "GetCurrentRank"))
    return rank ~= nil and math.floor(rank) or 0, true
end

function M:CaptureCommittedRanks(skillLineData)
    local ranks = {}
    local purchasedCount = 0
    local passives = self:IteratePassives(skillLineData)

    for _, skillData in ipairs(passives) do
        local rank, purchased = self:GetCommittedRank(skillData)
        if purchased and rank > 0 then
            local abilityId = self:ResolveRankOneAbilityId(skillData)
            if abilityId ~= nil then
                ranks[abilityId] = rank
                purchasedCount = purchasedCount + 1
            end
        end
    end

    return ranks, purchasedCount, #passives
end
