NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local DynamicData = {}

local function GetEnumString(prefix, value, fallback)
    if GetString and value ~= nil then
        local text = GetString(prefix, value)
        if text and text ~= "" then return text end
    end
    return fallback or NCollections.L("common.unknown_value")
end

local function FormatName(formatter, value)
    if zo_strformat and formatter then
        return zo_strformat(formatter, value or "")
    end
    return tostring(value or NCollections.L("common.unknown_value"))
end

local function FormatZoneName(zoneId)
    if not zoneId or zoneId == 0 or not GetZoneNameById then
        return NCollections.L("common.unknown_value")
    end
    return FormatName(SI_ZONE_NAME, GetZoneNameById(zoneId))
end

local function Detail(labelKey, value)
    return { label = NCollections.L(labelKey), value = value }
end

local function BooleanText(value)
    return value and NCollections.L("common.yes") or NCollections.L("common.no")
end

function DynamicData.GetSkillStyleCategoryName(collectibleData, fallback)
    if not collectibleData or not collectibleData.GetSkillStyleProgressionId then return fallback end
    if not GetProgressionSkillMorphSlotAbilityId or not GetSpecificSkillAbilityKeysByAbilityId then return fallback end
    if not GetSkillLineId or not GetSkillLineNameById or not GetString then return fallback end

    local progressionId = collectibleData:GetSkillStyleProgressionId()
    if not progressionId or progressionId == 0 then return fallback end
    local abilityId = GetProgressionSkillMorphSlotAbilityId(progressionId, MORPH_SLOT_BASE)
    if not abilityId or abilityId == 0 then return fallback end
    local skillType, skillLineIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    if not skillType or skillType == 0 or not skillLineIndex then return fallback end
    local skillLineId = GetSkillLineId(skillType, skillLineIndex)
    if not skillLineId or skillLineId == 0 then return fallback end

    local skillTypeName = GetString("SI_SKILLTYPE", skillType)
    local skillLineName = GetSkillLineNameById(skillLineId)
    if not skillTypeName or skillTypeName == "" or not skillLineName or skillLineName == "" then return fallback end
    return NCollections.L("collections.skill_style_category_format", skillTypeName, skillLineName)
end

function DynamicData.EnumerateDyeKeys()
    local keys = {}
    if not GetNumDyes or not GetDyeInfo then return keys end
    for dyeIndex = 1, GetNumDyes() do keys[dyeIndex] = dyeIndex end
    return keys
end

function DynamicData.IsDyeAcquired(dyeIndex)
    if not GetDyeInfo then return false end
    local _, known = GetDyeInfo(dyeIndex)
    return known == true
end

function DynamicData.BuildDyeRecord(dyeIndex, includeDetails)
    if not GetDyeInfo then return nil end
    local dyeName, known, rarity, hueCategory, achievementId, r, g, b, sortKey, dyeId = GetDyeInfo(dyeIndex)
    local achievementName = ""
    local achievementDescription = ""
    if achievementId and achievementId ~= 0 and GetAchievementInfo then
        achievementName, achievementDescription = GetAchievementInfo(achievementId)
    end
    local hueName = GetEnumString("SI_DYEHUECATEGORY", hueCategory)
    local rarityName = GetEnumString("SI_DYERARITY", rarity)
    local record = {
        collectibleId = dyeId and dyeId ~= 0 and dyeId or dyeIndex,
        name = tostring(dyeName or NCollections.L("common.unknown_value")),
        categoryName = hueName,
        isAcquired = known,
        searchExtra = table.concat({ rarityName, achievementName or "" }, " "),
        sortKey = sortKey,
    }
    if includeDetails then
        record.portraitPath = "EsoUI/Art/Miscellaneous/listItem_backdrop_white.dds"
        record.portraitAspect = 1
        record.portraitTextureLeft = 0.125
        record.portraitTextureRight = 0.875
        record.portraitTextureBottom = 0.78125
        record.portraitColor = { r or 1, g or 1, b or 1, 1 }
        record.description = achievementDescription or ""
        record.hint = not known and achievementName or ""
        record.extraDetails = {
            Detail("collections.dynamic.hue", hueName),
            Detail("collections.dynamic.rarity", rarityName),
            Detail("collections.dynamic.achievement", achievementName),
        }
    end
    return record
end

function DynamicData.BuildDyeRecords()
    local records = {}
    for _, key in ipairs(DynamicData.EnumerateDyeKeys()) do
        records[#records + 1] = DynamicData.BuildDyeRecord(key, true)
    end
    return records
end

local function FormatLeadTime(seconds)
    if not seconds or seconds <= 0 then return "" end
    if ZO_FormatTimeLargestTwo and TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_HIDE_ZEROES then
        return ZO_FormatTimeLargestTwo(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_HIDE_ZEROES)
    end
    return tostring(math.floor(seconds))
end

local function FormatAntiquityQuality(quality)
    if quality ~= nil and GetAntiquityQualityColor then
        local color = GetAntiquityQualityColor(quality)
        if color and color.Colorize then
            return color:Colorize("■")
        end
    end
    return tostring(quality or NCollections.L("common.unknown_value"))
end

function DynamicData.EnumerateAntiquityKeys()
    local keys = {}
    if not GetNextAntiquityId then return keys end
    local antiquityId = GetNextAntiquityId()
    local processed = 0
    while antiquityId do
        processed = processed + 1
        local visible = true
        if DoesAntiquityPassVisibilityRequirements then
            visible = DoesAntiquityPassVisibilityRequirements(antiquityId)
        end
        if visible then keys[#keys + 1] = antiquityId end
        NCollections.Util.FrameTaskCheckpoint(processed, 1)
        antiquityId = GetNextAntiquityId(antiquityId)
    end
    return keys
end

function DynamicData.IsAntiquityAcquired(antiquityId)
    return GetNumAntiquitiesRecovered and (GetNumAntiquitiesRecovered(antiquityId) or 0) > 0 or false
end

function DynamicData.BuildAntiquityRecord(antiquityId, includeDetails)
    if not GetAntiquityName then return nil end
    local categoryId = GetAntiquityCategoryId and GetAntiquityCategoryId(antiquityId) or 0
    local categoryName = categoryId ~= 0 and GetAntiquityCategoryName and GetAntiquityCategoryName(categoryId) or ""
    if not categoryName or categoryName == "" then categoryName = NCollections.L("collections.antiquities") end
    local zoneName = FormatZoneName(GetAntiquityZoneId and GetAntiquityZoneId(antiquityId) or 0)
    local difficultyName = GetEnumString("SI_ANTIQUITYDIFFICULTY", GetAntiquityDifficulty and GetAntiquityDifficulty(antiquityId) or nil)
    local qualityName = FormatAntiquityQuality(GetAntiquityQuality and GetAntiquityQuality(antiquityId) or nil)
    local recovered = GetNumAntiquitiesRecovered and GetNumAntiquitiesRecovered(antiquityId) or 0
    local antiquityName = FormatName(SI_ANTIQUITY_NAME_FORMATTER, GetAntiquityName(antiquityId))
    local record = {
        collectibleId = antiquityId,
        name = antiquityName,
        categoryName = categoryName,
        sortKey = NCollections.Util.Lower(antiquityName),
        isAcquired = recovered > 0,
        searchExtra = table.concat({ zoneName, difficultyName, qualityName }, " "),
    }
    if includeDetails then
        local loreTotal = GetNumAntiquityLoreEntries and GetNumAntiquityLoreEntries(antiquityId) or 0
        local loreAcquired = GetNumAntiquityLoreEntriesAcquired and GetNumAntiquityLoreEntriesAcquired(antiquityId) or 0
        local hasLead = DoesAntiquityHaveLead and DoesAntiquityHaveLead(antiquityId) or false
        local leadTime = hasLead and GetAntiquityLeadTimeRemainingSeconds and GetAntiquityLeadTimeRemainingSeconds(antiquityId) or 0
        record.extraDetails = {
            Detail("collections.dynamic.zone", zoneName),
            Detail("collections.dynamic.difficulty", difficultyName),
            Detail("collections.dynamic.quality", qualityName),
            Detail("collections.dynamic.lead_available", BooleanText(hasLead)),
            Detail("collections.dynamic.lead_expires", FormatLeadTime(leadTime)),
            Detail("collections.dynamic.recovered", tostring(recovered)),
            Detail("collections.dynamic.lore", string.format("%d / %d", loreAcquired, loreTotal)),
            Detail("collections.dynamic.repeatable", BooleanText(IsAntiquityRepeatable and IsAntiquityRepeatable(antiquityId) or false)),
        }
    end
    return record
end

function DynamicData.BuildAntiquityRecords()
    local records = {}
    for _, key in ipairs(DynamicData.EnumerateAntiquityKeys()) do
        records[#records + 1] = DynamicData.BuildAntiquityRecord(key, true)
    end
    return records
end

local function GetCraftedAbilitySkillLineName(craftedAbilityId)
    if not GetSkillAbilityIndicesFromCraftedAbilityId or not GetSkillLineId or not GetSkillLineNameById then return "" end
    local skillType, skillLineIndex = GetSkillAbilityIndicesFromCraftedAbilityId(craftedAbilityId)
    if skillType == nil or not skillLineIndex then return "" end
    local skillLineId = GetSkillLineId(skillType, skillLineIndex)
    if not skillLineId or skillLineId == 0 then return "" end
    return tostring(GetSkillLineNameById(skillLineId) or "")
end

local function AddGrimoireRecord(records, craftedAbilityId)
    local name = GetCraftedAbilityDisplayName(craftedAbilityId)
    local skillLineName = GetCraftedAbilitySkillLineName(craftedAbilityId)
    local categoryName = skillLineName ~= "" and skillLineName or NCollections.L("collections.dynamic.grimoires")
    records[#records + 1] = {
        collectibleId = -craftedAbilityId,
        name = FormatName(SI_CRAFTED_ABILITY_NAME_FORMATTER, name),
        categoryName = categoryName,
        isAcquired = IsCraftedAbilityUnlocked and IsCraftedAbilityUnlocked(craftedAbilityId) or false,
        portraitPath = GetCraftedAbilityIcon and GetCraftedAbilityIcon(craftedAbilityId) or "",
        description = GetCraftedAbilityDescription and GetCraftedAbilityDescription(craftedAbilityId) or "",
        hint = GetCraftedAbilityAcquireHint and GetCraftedAbilityAcquireHint(craftedAbilityId) or "",
        searchExtra = skillLineName,
        extraDetails = {
            Detail("collections.dynamic.entry_type", NCollections.L("collections.dynamic.grimoire")),
        },
    }
end

local function AddScriptRecord(records, seenScripts, scriptId, slotType)
    if not scriptId or scriptId == 0 or seenScripts[scriptId] then return end
    seenScripts[scriptId] = true
    local slotName = GetEnumString("SI_SCRIBINGSLOT", slotType)
    records[#records + 1] = {
        collectibleId = scriptId,
        name = FormatName(SI_CRAFTED_ABILITY_SCRIPT_NAME_FORMATTER, GetCraftedAbilityScriptDisplayName(scriptId)),
        categoryName = slotName,
        isAcquired = IsCraftedAbilityScriptUnlocked and IsCraftedAbilityScriptUnlocked(scriptId) or false,
        portraitPath = GetCraftedAbilityScriptIcon and GetCraftedAbilityScriptIcon(scriptId) or "",
        description = GetCraftedAbilityScriptGeneralDescription and GetCraftedAbilityScriptGeneralDescription(scriptId) or "",
        hint = GetCraftedAbilityScriptAcquireHint and GetCraftedAbilityScriptAcquireHint(scriptId) or "",
        extraDetails = {
            Detail("collections.dynamic.entry_type", NCollections.L("collections.dynamic.script")),
            Detail("collections.dynamic.script_slot", slotName),
        },
    }
end

function DynamicData.EnumerateScribingKeys()
    local keys = {}
    if not GetNumCraftedAbilities or not GetCraftedAbilityIdAtIndex then return keys end
    local seenScripts = {}
    for abilityIndex = 1, GetNumCraftedAbilities() do
        local craftedAbilityId = GetCraftedAbilityIdAtIndex(abilityIndex)
        if craftedAbilityId and craftedAbilityId ~= 0 then
            keys[#keys + 1] = -craftedAbilityId
            if GetNumScriptsInSlotForCraftedAbility and GetScriptIdAtSlotIndexForCraftedAbility then
                for slotType = SCRIBING_SLOT_ITERATION_BEGIN or 1, SCRIBING_SLOT_ITERATION_END or 3 do
                    local numScripts = GetNumScriptsInSlotForCraftedAbility(craftedAbilityId, slotType)
                    for scriptIndex = 1, numScripts do
                        local scriptId = GetScriptIdAtSlotIndexForCraftedAbility(craftedAbilityId, slotType, scriptIndex)
                        if scriptId and scriptId ~= 0 and not seenScripts[scriptId] then
                            seenScripts[scriptId] = true
                            keys[#keys + 1] = (scriptId * 10) + slotType
                        end
                        NCollections.Util.FrameTaskCheckpoint(scriptIndex, 1)
                    end
                end
            end
        end
        NCollections.Util.FrameTaskCheckpoint(abilityIndex, 1)
    end
    return keys
end

local function DecodeScribingKey(key)
    if key < 0 then return -key, nil end
    return math.floor(key / 10), key % 10
end

function DynamicData.IsScribingAcquired(key)
    local id, slotType = DecodeScribingKey(key)
    if slotType == nil then
        return IsCraftedAbilityUnlocked and IsCraftedAbilityUnlocked(id) or false
    end
    return IsCraftedAbilityScriptUnlocked and IsCraftedAbilityScriptUnlocked(id) or false
end

function DynamicData.BuildScribingRecord(key, includeDetails)
    local id, slotType = DecodeScribingKey(key)
    local records = {}
    if slotType == nil then
        AddGrimoireRecord(records, id)
    else
        AddScriptRecord(records, {}, id, slotType)
    end
    local record = records[1]
    if record then
        record.collectibleId = id
        if not includeDetails then
            record.description = nil
            record.hint = nil
            record.extraDetails = nil
        end
    end
    return record
end

function DynamicData.BuildScribingRecords()
    local records = {}
    for _, key in ipairs(DynamicData.EnumerateScribingKeys()) do
        records[#records + 1] = DynamicData.BuildScribingRecord(key, true)
    end
    return records
end

NCollections.Features.CollectionsDynamicData = DynamicData
