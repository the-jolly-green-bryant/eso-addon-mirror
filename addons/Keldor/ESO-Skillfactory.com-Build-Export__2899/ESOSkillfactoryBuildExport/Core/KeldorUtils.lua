--- ESO-Skillfactory.com Build Export AddOn for http://www.eso-skillfactory.com
--- written by Keldor

KeldorUtils = {
 base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
}

function KeldorUtils:split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end

function KeldorUtils:GetInternalSkillId(abilityId)

    local skillId = nil
    if type(ESOSkillfactoryBuildExportDB.Skills[abilityId]) ~= "nil" then
        skillId = ESOSkillfactoryBuildExportDB.Skills[abilityId]
    end

    return skillId
end

function KeldorUtils:GetInternalCPSkillId(abilityId)

    local skillId = nil
    if type(ESOSkillfactoryBuildExportDB.CP[abilityId]) ~= "nil" then
        skillId = ESOSkillfactoryBuildExportDB.CP[abilityId]
    end

    return skillId
end

function KeldorUtils:GetInternalMundusId(abilityId)

    local skillId = nil
    if type(ESOSkillfactoryBuildExportDB.Mundus[abilityId]) ~= "nil" then
        skillId = ESOSkillfactoryBuildExportDB.Mundus[abilityId]
    end

    return skillId
end

function KeldorUtils:GetInternalSetId(setId)

    local setInternalId = nil
    if type(ESOSkillfactoryBuildExportDB.Sets[setId]) ~= "nil" then
        setInternalId = ESOSkillfactoryBuildExportDB.Sets[setId]
    end

    return setInternalId
end

function KeldorUtils:GetSkillPlanerSetSlotIndex(gearSlot)

    local index = nil
    if type(ESOSkillfactoryBuildExportDB.SetSlotIndex[gearSlot]) ~= "nil" then
        index = ESOSkillfactoryBuildExportDB.SetSlotIndex[gearSlot]
    end

    return index
end

function KeldorUtils:GetInternalEnchantmentId(enchantId)

    local internalId = nil
    if type(ESOSkillfactoryBuildExportDB.Enchantments[enchantId]) ~= "nil" then
        internalId = ESOSkillfactoryBuildExportDB.Enchantments[enchantId]
    end

    return internalId
end

function KeldorUtils:GetInternalTraitId(traitId)

    local internalId = nil
    if type(ESOSkillfactoryBuildExportDB.Traits[traitId]) ~= "nil" then
        internalId = ESOSkillfactoryBuildExportDB.Traits[traitId]
    end

    return internalId
end

function KeldorUtils:GetInternalPoisonId(poisonId)

    local internalId = nil
    if type(ESOSkillfactoryBuildExportDB.Poisons[poisonId]) ~= "nil" then
        internalId = ESOSkillfactoryBuildExportDB.Poisons[poisonId]
    end

    return internalId
end

function KeldorUtils:removeLastChar(str)

    if str ~= "" then
        str = str:sub(1, #str - 1)
    end

    return str
end

function KeldorUtils:inTable(e, t)
    local exists = false
    for _, v in pairs(t) do
        if (v == e) then
            exists = true
        end
    end
    return exists
end
