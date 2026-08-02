NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local CompanionDetails = {}
local RapportData = NCollections.Data and NCollections.Data.CompanionRapport or {}

local LIKE_COLOR = { 0.35, 0.95, 0.45 }
local DISLIKE_COLOR = { 1, 0.28, 0.28 }
local houseguestsByName

local function FormatCollectibleName(name)
    if zo_strformat and SI_COLLECTIBLE_NAME_FORMATTER then
        return zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name or "")
    end
    return tostring(name or "")
end

local function NormalizeName(name)
    local formattedName = FormatCollectibleName(name)
    return NCollections.Util.Lower(formattedName)
end

local function FormatNumber(value)
    value = tonumber(value) or 0
    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(value)
    end
    return tostring(value)
end

local function EnsureHouseguestLookup()
    if houseguestsByName then return end
    if not SPECIALIZED_COLLECTIBLE_TYPE_HOUSEGUEST or not ZO_COLLECTIBLE_DATA_MANAGER then return end

    houseguestsByName = {}
    NCollections.Util.ForEachCollectibleDataObject(ZO_COLLECTIBLE_DATA_MANAGER, nil, nil, function(collectibleData)
        local specializedType = collectibleData.GetSpecializedCategoryType and collectibleData:GetSpecializedCategoryType() or nil
        local isPlaceable = collectibleData.IsPlaceableFurniture and collectibleData:IsPlaceableFurniture() or false
        if specializedType == SPECIALIZED_COLLECTIBLE_TYPE_HOUSEGUEST and isPlaceable then
            houseguestsByName[NormalizeName(collectibleData:GetName())] = collectibleData:GetId()
        end
    end, 25)
end

local function GetCollectibleData(collectibleId)
    if not collectibleId or not ZO_COLLECTIBLE_DATA_MANAGER or not ZO_COLLECTIBLE_DATA_MANAGER.GetCollectibleDataById then return nil end
    return ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
end

local function GetHouseguestData(record)
    EnsureHouseguestLookup()
    if not houseguestsByName then return nil end

    local companionName = NormalizeName(record.name)
    local houseguestId = houseguestsByName[companionName]
    if not houseguestId then
        for houseguestName, collectibleId in pairs(houseguestsByName) do
            local nextCharacter = string.sub(companionName, #houseguestName + 1, #houseguestName + 1)
            if string.sub(companionName, 1, #houseguestName) == houseguestName and nextCharacter == " " then
                houseguestId = collectibleId
                break
            end
        end
    end
    return GetCollectibleData(houseguestId)
end

local function AddAchievementDetails(lines, AddDetailLine, achievementId)
    achievementId = tonumber(achievementId) or 0
    if achievementId <= 0 or not GetAchievementInfo then return end

    local name, _, _, _, completed = GetAchievementInfo(achievementId)
    AddDetailLine(lines, NCollections.L("features.collections_companions.houseguest_achievement"), NCollections.L("features.collections_companions.achievement_status", name or NCollections.L("common.unknown_value"), completed and NCollections.L("common.completed") or NCollections.L("common.in_progress")))

    if not GetAchievementNumCriteria or not GetAchievementCriterion then return end
    local numCriteria = tonumber(GetAchievementNumCriteria(achievementId)) or 0
    for criterionIndex = 1, numCriteria do
        local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
        if description and description ~= "" then
            lines[#lines + 1] = NCollections.L(
                "features.collections_companions.requirement",
                description,
                FormatNumber(numCompleted),
                FormatNumber(numRequired)
            )
        end
    end
end

function CompanionDetails.AppendDetailLines(record, lines, AddDetailLine)
    local companionData = GetCollectibleData(record.collectibleId)
    local houseguestData = GetHouseguestData(record)
    if not houseguestData then
        AddDetailLine(lines, NCollections.L("features.collections_companions.houseguest_placement"), NCollections.L("common.not_available"))
        return
    end

    local isUnlocked = houseguestData.IsUnlocked and houseguestData:IsUnlocked() or false
    AddDetailLine(lines, NCollections.L("features.collections_companions.personal_questline"), isUnlocked and NCollections.L("common.completed") or NCollections.L("common.not_completed"))
    AddDetailLine(lines, NCollections.L("features.collections_companions.houseguest_placement"), isUnlocked and NCollections.L("common.unlocked") or NCollections.L("common.locked"))

    local achievementId = houseguestData.GetLinkedAchievement and houseguestData:GetLinkedAchievement() or 0
    if (not achievementId or achievementId <= 0) and companionData and companionData.GetLinkedAchievement then
        achievementId = companionData:GetLinkedAchievement()
    end
    AddAchievementDetails(lines, AddDetailLine, achievementId)
end

local function BuildRapportText(entries)
    if not entries or #entries == 0 then return "" end
    local lines = {}
    for _, entry in ipairs(entries) do
        lines[#lines + 1] = "• " .. tostring(entry[1]) .. "  " .. NCollections.L(entry[2])
    end
    return table.concat(lines, "\n")
end

function CompanionDetails.BuildRapportColumns(record)
    local rapport = record and RapportData[record.collectibleId] or nil
    if not rapport then return nil end
    return {
        left = {
            heading = NCollections.L("features.collections_companions.likes"),
            text = BuildRapportText(rapport.likes),
            color = LIKE_COLOR,
        },
        right = {
            heading = NCollections.L("features.collections_companions.dislikes"),
            text = BuildRapportText(rapport.dislikes),
            color = DISLIKE_COLOR,
        },
    }
end

function CompanionDetails.ReleaseTransientData()
    houseguestsByName = nil
end

NCollections.Features.CollectionsCompanionDetails = CompanionDetails
