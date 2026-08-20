NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Debug = {}

local FEATURE_NAME = "Debug"
local MEMORY_HUD_UPDATE_NAMESPACE = "NQOL_DebugMemoryHud"
local MEMORY_HUD_UPDATE_INTERVAL_MS = 1000
local MEMORY_HUD_WIDTH = 700
local MEMORY_HUD_HEIGHT = 72
local MEMORY_HUD_FONT_SIZE = 48
local MEMORY_HUD_DRAW_LEVEL = 200
local MEMORY_HUD_DEFAULT_INSET = 24
local MEMORY_HUD_BOTTOM_OFFSET = 72
local MEMORY_HUD_FONT = "EsoUI/Common/Fonts/FTN87.slug"
local OLD_EXPORT_KEYS = {
    "baseGameDungeonAchievements",
    "dungeonAchievements",
}

local EXPORT_CATEGORIES = {
    {
        savedKey = "dungeons",
        categoryName = "Dungeons",
        sectionName = "Dungeons",
        activityTypeName = "LFG_ACTIVITY_DUNGEON",
    },
    {
        savedKey = "dlcDungeons",
        categoryName = "DLC Dungeons",
        sectionName = "DLC Dungeons",
        activityTypeName = "LFG_ACTIVITY_DUNGEON",
    },
    {
        savedKey = "soloDungeons",
        categoryName = "Solo Dungeons",
        sectionName = "Solo Dungeons",
        parentCategoryName = "Recent Seasons",
        subCategoryName = "Solo Dungeons",
        zoneDisplayTypeName = "ZONE_DISPLAY_TYPE_SOLO_DUNGEON",
        groupAchievementsByZoneName = true,
    },
    {
        savedKey = "trials",
        categoryName = "Trials",
        sectionName = "Trials",
        activityTypeName = "LFG_ACTIVITY_TRIAL",
    },
    {
        savedKey = "arenas",
        categoryName = "Arenas",
        sectionName = "Arenas",
        activityTypeName = "LFG_ACTIVITY_ARENA",
    },
}

local defaults = {
    debug = {
        exports = {},
    },
}

local savedVariables
local memoryHud
local initialized = false
local memoryHudUpdateRegistered = false
local memoryHudDisplayInitialized = false
local memoryHudUsedTenths
local memoryHudCapacity

local function IsDebugMode()
    return NQOL.IsDevMode and NQOL.IsDevMode() == true
end

local function GetMemoryDisplayValues()
    if type(GetTotalUserAddOnMemoryPoolUsageMB) ~= "function" then
        return nil, nil
    end

    local usedMemory = GetTotalUserAddOnMemoryPoolUsageMB() or 0
    local usedTenths = math.floor(usedMemory * 10 + 0.5)
    if type(GetTotalUserAddOnMemoryPoolCapacityMB) ~= "function" then
        return usedTenths, nil
    end

    local capacity = GetTotalUserAddOnMemoryPoolCapacityMB() or 0
    return usedTenths, math.floor(capacity + 0.5)
end

local function RefreshMemoryHud()
    if not memoryHud then
        return
    end

    if not IsDebugMode() then
        memoryHud:SetHidden(true)
        if EVENT_MANAGER then
            EVENT_MANAGER:UnregisterForUpdate(MEMORY_HUD_UPDATE_NAMESPACE)
        end
        memoryHudUpdateRegistered = false
        return
    end

    local usedTenths, capacity = GetMemoryDisplayValues()
    if memoryHudDisplayInitialized and memoryHudUsedTenths == usedTenths and memoryHudCapacity == capacity then
        return
    end

    memoryHudDisplayInitialized = true
    memoryHudUsedTenths = usedTenths
    memoryHudCapacity = capacity

    if usedTenths == nil then
        memoryHud.label:SetText("MEMORY unavailable")
    elseif capacity == nil then
        memoryHud.label:SetText(string.format("MEMORY %.1f MB", usedTenths * 0.1))
    else
        memoryHud.label:SetText(string.format("MEMORY %.1f/%d MB", usedTenths * 0.1, capacity))
    end
    memoryHud:SetHidden(false)
end

local function CreateMemoryHud()
    if memoryHud or not WINDOW_MANAGER or not GuiRoot then
        return
    end

    memoryHud = WINDOW_MANAGER:CreateTopLevelWindow("NQOLDebugMemoryHud")
    memoryHud:SetDimensions(MEMORY_HUD_WIDTH, MEMORY_HUD_HEIGHT)

    local insetX = tonumber(ZO_GAMEPAD_SAFE_ZONE_INSET_X) or MEMORY_HUD_DEFAULT_INSET
    local insetY = tonumber(ZO_GAMEPAD_SAFE_ZONE_INSET_Y) or MEMORY_HUD_DEFAULT_INSET
    memoryHud:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -insetX, -(insetY + MEMORY_HUD_BOTTOM_OFFSET))

    if memoryHud.SetDrawTier and DT_HIGH then
        memoryHud:SetDrawTier(DT_HIGH)
    end
    if memoryHud.SetDrawLayer and DL_OVERLAY then
        memoryHud:SetDrawLayer(DL_OVERLAY)
    end
    memoryHud:SetDrawLevel(MEMORY_HUD_DRAW_LEVEL)

    local label = WINDOW_MANAGER:CreateControl(nil, memoryHud, CT_LABEL)
    label:SetAnchorFill(memoryHud)
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont(NQOL.Util.CreateFontString(MEMORY_HUD_FONT, MEMORY_HUD_FONT_SIZE, "ZoFontGamepad42"))
    label:SetColor(1.00, 0.42, 0.30, 1)
    if label.SetDrawTier and DT_HIGH then
        label:SetDrawTier(DT_HIGH)
    end
    if label.SetDrawLayer and DL_OVERLAY then
        label:SetDrawLayer(DL_OVERLAY)
    end
    label:SetDrawLevel(MEMORY_HUD_DRAW_LEVEL + 1)
    memoryHud.label = label
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "debug")
    NQOL.Settings.EnsureTable(settings, "exports")
    return settings
end

local function NormalizeText(value)
    value = string.lower(tostring(value or ""))
    value = string.gsub(value, "[^%w]+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    value = string.gsub(value, "^the%s+", "")
    return value
end

local function GetGlobalNumber(globalName)
    local value = _G and _G[globalName]
    if type(value) == "number" then
        return value
    end
    return nil
end

local function IsCategoryMatch(categoryName, targetName)
    return NormalizeText(categoryName) == NormalizeText(targetName)
end

local function BuildActivityLookup(categoryConfig)
    if not categoryConfig.activityTypeName then
        return nil
    end
    if type(GetNumActivitiesByType) ~= "function" or type(GetActivityIdByTypeAndIndex) ~= "function" or type(GetActivityName) ~= "function" then
        return nil
    end

    local activityType = GetGlobalNumber(categoryConfig.activityTypeName)
    if not activityType then
        return nil
    end

    local lookup = {}
    for activityIndex = 1, GetNumActivitiesByType(activityType) do
        local activityId = GetActivityIdByTypeAndIndex(activityType, activityIndex)
        local activityName = GetActivityName(activityId)
        local normalizedName = NormalizeText(activityName)
        if activityId and activityId > 0 and normalizedName ~= "" then
            local zoneId = type(GetActivityZoneId) == "function" and GetActivityZoneId(activityId) or 0
            lookup[normalizedName] = {
                activityId = activityId,
                activityName = activityName or "",
                activityType = activityType,
                activityTypeName = categoryConfig.activityTypeName,
                zoneId = zoneId,
            }
        end
    end

    return lookup
end

local function BuildAllZoneLookup()
    if type(GetNumZones) ~= "function" or type(GetZoneId) ~= "function" or type(GetZoneNameById) ~= "function" then
        return nil
    end

    local lookup = {}
    for zoneIndex = 1, GetNumZones() do
        local zoneId = GetZoneId(zoneIndex)
        local zoneName = GetZoneNameById(zoneId)
        local normalizedName = NormalizeText(zoneName)
        if zoneId and zoneId > 0 and normalizedName ~= "" then
            lookup[normalizedName] = {
                entryId = zoneId,
                zoneId = zoneId,
                zoneName = zoneName or "",
                zoneIndex = zoneIndex,
            }
        end
    end

    return lookup
end

local function FindZoneByNodeName(allZones, nodeName)
    local normalizedNodeName = NormalizeText(nodeName)
    local zone = allZones[normalizedNodeName]
    if zone then
        return zone, normalizedNodeName
    end

    local longestMatchLength = 0
    for normalizedZoneName, candidate in pairs(allZones) do
        if #normalizedZoneName > longestMatchLength
            and string.find(normalizedNodeName, normalizedZoneName, 1, true)
        then
            zone = candidate
            longestMatchLength = #normalizedZoneName
        end
    end
    return zone, normalizedNodeName
end

local function BuildZoneLookup(categoryConfig)
    if not categoryConfig.zoneDisplayTypeName then
        return BuildAllZoneLookup()
    end

    if type(GetNumFastTravelNodes) ~= "function"
        or type(GetFastTravelNodeInfo) ~= "function"
        or type(GetFastTravelNodeZoneDisplayType) ~= "function"
    then
        return nil
    end

    local targetZoneDisplayType = GetGlobalNumber(categoryConfig.zoneDisplayTypeName)
    local allZones = BuildAllZoneLookup()
    if not targetZoneDisplayType or not allZones then
        return nil
    end

    local lookup = {}
    for nodeIndex = 1, GetNumFastTravelNodes() do
        if GetFastTravelNodeZoneDisplayType(nodeIndex) == targetZoneDisplayType then
            local nodeName = select(2, GetFastTravelNodeInfo(nodeIndex)) or ""
            local zone, normalizedNodeName = FindZoneByNodeName(allZones, nodeName)
            if zone and normalizedNodeName ~= "" then
                lookup[normalizedNodeName] = zone
            end
        end
    end
    return lookup
end

local function ApplyEntryInfoToSubCategory(subCategory, activityLookup, zoneLookup)
    local normalizedName = NormalizeText(subCategory.subCategoryName)
    local activity = activityLookup and activityLookup[normalizedName]
    local zone = zoneLookup and zoneLookup[normalizedName]

    if activity then
        subCategory.activityId = activity.activityId
        subCategory.activityName = activity.activityName
        subCategory.activityType = activity.activityType
        subCategory.activityTypeName = activity.activityTypeName
        if activity.zoneId and activity.zoneId > 0 then
            subCategory.entryId = activity.zoneId
            subCategory.zoneId = activity.zoneId
            subCategory.zoneName = activity.activityName
        end
    end

    local hasActivityZone = activity and activity.zoneId and activity.zoneId > 0
    if zone and not hasActivityZone then
        subCategory.entryId = zone.entryId
        subCategory.zoneId = zone.zoneId
        subCategory.zoneName = zone.zoneName
        subCategory.zoneIndex = zone.zoneIndex
    elseif zone and activity and zone.zoneId == activity.zoneId then
        subCategory.zoneIndex = zone.zoneIndex
    end
end

local function BuildUniqueZoneEntries(zoneLookup)
    local entriesById = {}
    for _, zone in pairs(zoneLookup or {}) do
        if zone.zoneId and zone.zoneId > 0 and not entriesById[zone.zoneId] then
            entriesById[zone.zoneId] = zone
        end
    end

    local entries = {}
    for _, zone in pairs(entriesById) do
        entries[#entries + 1] = zone
    end
    table.sort(entries, function(left, right)
        return NormalizeText(left.zoneName) < NormalizeText(right.zoneName)
    end)
    return entries
end

local function FindAchievementZone(achievement, zoneEntries)
    local searchableText = NormalizeText((achievement.name or "") .. " " .. (achievement.description or ""))
    local matchedZone
    for _, zone in ipairs(zoneEntries) do
        local zoneName = NormalizeText(zone.zoneName)
        if zoneName ~= "" and string.find(searchableText, zoneName, 1, true) then
            if matchedZone then
                return nil
            end
            matchedZone = zone
        end
    end
    return matchedZone
end

local function GroupAchievementsByZoneName(export, zoneLookup)
    local zoneEntries = BuildUniqueZoneEntries(zoneLookup)
    local exportEntriesById = {}
    export.matchedSubCategories = {}
    export.achievementRefsByEntry = {}

    for _, zone in ipairs(zoneEntries) do
        local exportEntry = {
            categoryName = export.categoryName,
            subCategoryName = zone.zoneName,
            numAchievements = 0,
            entryId = zone.entryId,
            zoneId = zone.zoneId,
            zoneName = zone.zoneName,
            zoneIndex = zone.zoneIndex,
        }
        exportEntriesById[zone.zoneId] = exportEntry
        export.matchedSubCategories[#export.matchedSubCategories + 1] = exportEntry
    end

    for exportIndex, achievement in ipairs(export.achievements or {}) do
        local zone = FindAchievementZone(achievement, zoneEntries)
        local entryName = zone and zone.zoneName or "General"
        achievement.sectionEntryName = entryName
        export.achievementRefsByEntry[entryName] = export.achievementRefsByEntry[entryName] or {}
        export.achievementRefsByEntry[entryName][#export.achievementRefsByEntry[entryName] + 1] = {
            id = achievement.id,
            exportIndex = exportIndex,
            name = achievement.name,
        }

        if zone then
            local exportEntry = exportEntriesById[zone.zoneId]
            exportEntry.numAchievements = exportEntry.numAchievements + 1
        end
    end
end

local function ApplyEntryInfo(export, categoryConfig)
    local activityLookup = BuildActivityLookup(categoryConfig)
    local zoneLookup = BuildZoneLookup(categoryConfig)
    if not activityLookup and not zoneLookup then
        return
    end

    if categoryConfig.groupAchievementsByZoneName and zoneLookup then
        GroupAchievementsByZoneName(export, zoneLookup)
        return
    end

    for _, subCategory in ipairs(export.matchedSubCategories or {}) do
        ApplyEntryInfoToSubCategory(subCategory, activityLookup, zoneLookup)
    end

    for _, category in ipairs(export.categories or {}) do
        for _, subCategory in ipairs(category.subCategories or {}) do
            ApplyEntryInfoToSubCategory(subCategory, activityLookup, zoneLookup)
        end
    end
end

local function GetAchievementLinkText(achievementId)
    if not GetAchievementLink then
        return ""
    end

    local linkStyle = LINK_STYLE_BRACKETS or 0
    return GetAchievementLink(achievementId, linkStyle) or ""
end

local function GetAchievementCriteria(achievementId)
    local criteria = {}
    if not GetAchievementNumCriteria or not GetAchievementCriterion then
        return criteria
    end

    for criterionIndex = 1, GetAchievementNumCriteria(achievementId) do
        local description, _, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
        criteria[#criteria + 1] = {
            index = criterionIndex,
            description = description or "",
            required = numRequired or 0,
        }
    end

    return criteria
end

local function GetAchievementRewards(achievementId)
    local rewards = {
        item = nil,
        title = nil,
        dye = nil,
        collectible = nil,
        tributeCardUpgrade = nil,
    }

    if GetAchievementRewardItem then
        local hasReward, itemName, iconTextureName, displayQuality = GetAchievementRewardItem(achievementId)
        if hasReward then
            rewards.item = {
                name = itemName or "",
                icon = iconTextureName or "",
                displayQuality = displayQuality or 0,
            }
        end
    end

    if GetAchievementRewardTitle then
        local hasReward, titleName = GetAchievementRewardTitle(achievementId)
        if hasReward then
            rewards.title = {
                name = titleName or "",
            }
        end
    end

    if GetAchievementRewardDye then
        local hasReward, dyeId = GetAchievementRewardDye(achievementId)
        if hasReward then
            rewards.dye = {
                id = dyeId or 0,
            }
            if GetDyeInfoById and dyeId and dyeId > 0 then
                local dyeName, _, rarity, hueCategory, linkedAchievementId = GetDyeInfoById(dyeId)
                rewards.dye.name = dyeName or ""
                rewards.dye.rarity = rarity or 0
                rewards.dye.hueCategory = hueCategory or 0
                rewards.dye.achievementId = linkedAchievementId or 0
            end
        end
    end

    if GetAchievementRewardCollectible then
        local hasReward, collectibleId = GetAchievementRewardCollectible(achievementId)
        if hasReward then
            rewards.collectible = {
                id = collectibleId or 0,
            }
            if GetCollectibleInfo and collectibleId and collectibleId > 0 then
                local name, description, icon, lockedIcon, _, _, _, categoryType = GetCollectibleInfo(collectibleId)
                rewards.collectible.name = name or ""
                rewards.collectible.description = description or ""
                rewards.collectible.icon = icon or ""
                rewards.collectible.lockedIcon = lockedIcon or ""
                rewards.collectible.categoryType = categoryType or 0
            end
        end
    end

    if GetAchievementRewardTributeCardUpgradeInfo then
        local hasReward, tributePatronId, tributeCardIndex = GetAchievementRewardTributeCardUpgradeInfo(achievementId)
        if hasReward then
            rewards.tributeCardUpgrade = {
                patronId = tributePatronId or 0,
                cardIndex = tributeCardIndex or 0,
            }
        end
    end

    return rewards
end

local function GetAchievementExportData(categoryIndex, categoryName, subCategoryIndex, subCategoryName, achievementIndex)
    local achievementId = GetAchievementId(categoryIndex, subCategoryIndex, achievementIndex)
    if not achievementId or achievementId <= 0 then
        return nil
    end

    local name, description, points, icon = GetAchievementInfo(achievementId)
    local firstAchievementId = GetFirstAchievementInLine and GetFirstAchievementInLine(achievementId) or 0
    local previousAchievementId = GetPreviousAchievementInLine and GetPreviousAchievementInLine(achievementId) or 0
    local nextAchievementId = GetNextAchievementInLine and GetNextAchievementInLine(achievementId) or 0
    local numRewards = GetAchievementNumRewards and GetAchievementNumRewards(achievementId) or 0
    local persistenceLevel = GetAchievementPersistenceLevel and GetAchievementPersistenceLevel(achievementId) or 0

    return {
        id = achievementId,
        name = name or "",
        title = name or "",
        description = description or "",
        points = points or 0,
        icon = icon or "",
        link = GetAchievementLinkText(achievementId),
        criteria = GetAchievementCriteria(achievementId),
        rewards = GetAchievementRewards(achievementId),
        numRewards = numRewards or 0,
        persistenceLevel = persistenceLevel or 0,
        firstAchievementId = firstAchievementId or 0,
        previousAchievementId = previousAchievementId or 0,
        nextAchievementId = nextAchievementId or 0,
        isAchievementLine = (firstAchievementId and firstAchievementId > 0 and firstAchievementId ~= achievementId)
            or (nextAchievementId and nextAchievementId > 0)
            or (previousAchievementId and previousAchievementId > 0),
        categoryIndex = categoryIndex,
        categoryName = categoryName or "",
        subCategoryIndex = subCategoryIndex,
        subCategoryName = subCategoryName or "",
        sectionEntryName = subCategoryName or "",
        achievementIndex = achievementIndex,
    }
end

local function BuildCategoryExport(categoryConfig)
    local parentCategoryName = categoryConfig.parentCategoryName or categoryConfig.categoryName
    local filter = parentCategoryName .. " achievement category"
    if categoryConfig.subCategoryName then
        filter = filter .. " / " .. categoryConfig.subCategoryName .. " subcategory"
    end

    local export = {
        exportedAt = GetTimeStamp and GetTimeStamp() or 0,
        source = "Journal / Achievements",
        filter = filter,
        sectionName = categoryConfig.sectionName,
        categoryName = categoryConfig.categoryName,
        achievements = {},
        achievementRefsByEntry = {},
        categories = {},
        matchedSubCategories = {},
    }

    for categoryIndex = 1, GetNumAchievementCategories() do
        local categoryName, numSubCategories = GetAchievementCategoryInfo(categoryIndex)
        if IsCategoryMatch(categoryName, parentCategoryName) then
            local _, _, numAchievements = GetAchievementCategoryInfo(categoryIndex)
            numAchievements = tonumber(numAchievements) or 0
            numSubCategories = tonumber(numSubCategories) or 0
            local categoryExport = {
                categoryIndex = categoryIndex,
                categoryName = categoryName or "",
                numAchievements = numAchievements,
                subCategories = {},
            }
            export.categories[#export.categories + 1] = categoryExport

            if not categoryConfig.subCategoryName and numAchievements > 0 then
                export.matchedSubCategories[#export.matchedSubCategories + 1] = {
                    categoryIndex = categoryIndex,
                    categoryName = categoryName or "",
                    subCategoryIndex = nil,
                    subCategoryName = "General",
                    numAchievements = numAchievements,
                }

                for achievementIndex = 1, numAchievements do
                    local achievement = GetAchievementExportData(categoryIndex, categoryName, nil, "General", achievementIndex)
                    if achievement then
                        export.achievements[#export.achievements + 1] = achievement
                        export.achievementRefsByEntry.General = export.achievementRefsByEntry.General or {}
                        export.achievementRefsByEntry.General[#export.achievementRefsByEntry.General + 1] = {
                            id = achievement.id,
                            exportIndex = #export.achievements,
                            name = achievement.name,
                        }
                    end
                end
            end

            for subCategoryIndex = 1, numSubCategories do
                local subCategoryName, numAchievements = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
                numAchievements = tonumber(numAchievements) or 0
                if not categoryConfig.subCategoryName or IsCategoryMatch(subCategoryName, categoryConfig.subCategoryName) then
                    categoryExport.subCategories[#categoryExport.subCategories + 1] = {
                        subCategoryIndex = subCategoryIndex,
                        subCategoryName = subCategoryName or "",
                        numAchievements = numAchievements or 0,
                    }

                    export.matchedSubCategories[#export.matchedSubCategories + 1] = {
                        categoryIndex = categoryIndex,
                        categoryName = categoryName or "",
                        subCategoryIndex = subCategoryIndex,
                        subCategoryName = subCategoryName or "",
                        numAchievements = numAchievements or 0,
                    }

                    for achievementIndex = 1, numAchievements do
                        local achievement = GetAchievementExportData(categoryIndex, categoryName, subCategoryIndex, subCategoryName, achievementIndex)
                        if achievement then
                            export.achievements[#export.achievements + 1] = achievement
                            local entryName = subCategoryName or "Unknown"
                            export.achievementRefsByEntry[entryName] = export.achievementRefsByEntry[entryName] or {}
                            export.achievementRefsByEntry[entryName][#export.achievementRefsByEntry[entryName] + 1] = {
                                id = achievement.id,
                                exportIndex = #export.achievements,
                                name = achievement.name,
                            }
                        end
                    end
                end
            end
        end
    end

    ApplyEntryInfo(export, categoryConfig)
    export.count = #export.achievements
    return export
end

local function ExportAchievementSections()
    if not GetNumAchievementCategories or not GetAchievementCategoryInfo or not GetAchievementSubCategoryInfo or not GetAchievementId or not GetAchievementInfo then
        NQOL.Chat.Message("Achievement API is not available.", FEATURE_NAME)
        return
    end

    local exports = GetSettings().exports
    for _, oldKey in ipairs(OLD_EXPORT_KEYS) do
        exports[oldKey] = nil
    end

    local totalCount = 0
    for _, categoryConfig in ipairs(EXPORT_CATEGORIES) do
        local export = BuildCategoryExport(categoryConfig)
        exports[categoryConfig.savedKey] = export
        totalCount = totalCount + export.count
    end

    if RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave(NQOL.name or "NQOL")
    end

    NQOL.Chat.Message("Exported " .. tostring(totalCount) .. " achievement records to saved variables.", FEATURE_NAME)
end

local function GetItemLinkFromItemId(itemId)
    return string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

local ANNOTATION_TEST_ITEMS = {
    45913,
    132187,
    51688,
    215055,
    212199,
    97332,
    97338,
    97218,
}
local ANNOTATION_TEST_ICON_TEXTURE = "EsoUI/Art/Inventory/inventory_sell_forbidden_icon.dds"

local function GetAnnotationTestItems()
    local testItems = {}
    for index, itemId in ipairs(ANNOTATION_TEST_ITEMS) do
        testItems[index] = GetItemLinkFromItemId(itemId)
    end
    return testItems
end

local function GetAnnotationTestIcon()
    local chatFontSize = GetChatFontSize and tonumber(GetChatFontSize()) or 22
    local iconSize = math.max(1, math.floor((chatFontSize * 32 / 22) + 0.5))
    return string.format("|t%d:%d:%s|t", iconSize, iconSize, ANNOTATION_TEST_ICON_TEXTURE)
end

local function EmulateIncomingPlayerChatMessage(message)
    if not CHAT_ROUTER
        or not CHAT_ROUTER.FormatAndAddChatMessage
        or not EVENT_CHAT_MESSAGE_CHANNEL
        or not CHAT_CHANNEL_SAY
    then
        return false
    end

    local fromName = "NQOL Debugger"
    local fromDisplayName = "@NQOLDebug"

    CHAT_ROUTER:FormatAndAddChatMessage(
        EVENT_CHAT_MESSAGE_CHANNEL,
        CHAT_CHANNEL_SAY,
        fromName,
        message,
        false,
        fromDisplayName
    )
    return true
end

function Debug.InitializeSavedVariables()
    if not IsDebugMode() then
        return
    end

    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Debug.Initialize()
    if initialized or not IsDebugMode() then
        return
    end

    initialized = true
    CreateMemoryHud()
    memoryHudDisplayInitialized = false
    RefreshMemoryHud()

    if EVENT_MANAGER and memoryHud and not memoryHudUpdateRegistered then
        EVENT_MANAGER:RegisterForUpdate(MEMORY_HUD_UPDATE_NAMESPACE, MEMORY_HUD_UPDATE_INTERVAL_MS, RefreshMemoryHud)
        memoryHudUpdateRegistered = true
    end
end

function Debug.ExportAchievementSections()
    ExportAchievementSections()
end

function Debug.PrintAnnotationTestItemLinks()
    local testItems = GetAnnotationTestItems()
    local numTestItems = #testItems
    local testIcon = GetAnnotationTestIcon()

    for index, itemLink in ipairs(testItems) do
        local message = "Annotation test " .. tostring(index) .. "/" .. tostring(numTestItems) .. ": " .. itemLink .. " " .. testIcon

        if not EmulateIncomingPlayerChatMessage(message) then
            NQOL.Chat.Message("The player chat formatter is not available.", FEATURE_NAME)
            return
        end
    end
end

function Debug.GetExportAchievementSectionsLabel()
    return "Export dungeon/trial/arena achievements"
end

function Debug.GetExportAchievementSectionsTooltip()
    return "Stores Dungeons, DLC Dungeons, Solo Dungeons, Trials, and Arenas achievement details in separate NQOL saved-variable sections."
end

function Debug.GetPrintAnnotationTestItemLinksLabel()
    return "Print annotation test item links"
end

function Debug.GetPrintAnnotationTestItemLinksTooltip()
    return "Emulates separate Say messages containing recipes, plans, motifs, collectibles, weapons, armor, and jewelry, with the missing-item icon beside each link."
end

NQOL.Features.Debug = Debug
