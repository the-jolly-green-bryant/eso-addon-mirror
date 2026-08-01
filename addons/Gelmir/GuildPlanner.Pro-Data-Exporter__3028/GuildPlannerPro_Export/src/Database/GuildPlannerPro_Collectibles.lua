GuildPlannerPro_Collectibles = {}

function GuildPlannerPro_Collectibles:GetCategoryMap()
    local categories = {}
    local numCategories = GetNumCollectibleCategories()
    for categoryId = 1, numCategories do
        local ctgName, ctgNumSubCategories, ctgNumCollectibles, ctgUnlockedCollectibles, ctgTotalCollectibles, hidesLocked = GetCollectibleCategoryInfo(categoryId)
        categories[categoryId] = {
            Id = categoryId,
            Name = ctgName,
            NumSubCategories = ctgNumSubCategories,
            NumCollectibles = ctgNumCollectibles,
            UnlockedCollectibles = ctgUnlockedCollectibles,
            TotalCollectibles = ctgTotalCollectibles,
            HidesLocked = hidesLocked,
            SubCategories = {},
        }

        for subCategoryId = 1, ctgNumSubCategories do
            local subCtgName, subCtgNumCollectibles, subCtgUnlockedCollectibles, subCtgTotalCollectibles = GetCollectibleSubCategoryInfo(categoryId, subCategoryId)
            categories[categoryId].SubCategories[subCategoryId] = {
                Id = subCategoryId,
                Name = subCtgName,
                NumCollectibles = subCtgNumCollectibles,
                UnlockedCollectibles = subCtgUnlockedCollectibles,
                TotalCollectibles = subCtgTotalCollectibles,
            }
        end
    end

    return categories
end

function GuildPlannerPro_Collectibles:MapStoriesCollectibles()
    local collectibleMap = {}
    local categories = self:GetCategoryMap()
    local storiesCategory = categories[1]
    for subCategoryId = 1, storiesCategory.NumSubCategories do
        local subCtgName = storiesCategory.SubCategories[subCategoryId].Name
        collectibleMap[subCtgName] = {}
        for collectibleIndex = 1, storiesCategory.SubCategories[subCategoryId].NumCollectibles do
            local collectibleId = GetCollectibleId(1, subCategoryId, collectibleIndex)
            local name, description, icon, _, _, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleId)
            local questName, bgText = GetCollectibleQuestPreviewInfo(collectibleId)
            local questState = GetCollectibleAssociatedQuestState(collectibleId)
            collectibleMap[subCtgName][collectibleIndex] = {
                Id = collectibleId,
                Index = collectibleIndex,
                Name = name,
                Desc = description,
                DoesESOPlusUnlock = DoesESOPlusUnlockCollectible(collectibleId),
                IsPurchasable = purchasable,
                IsActive = isActive,
                CtgId = subCategoryId,
                CtgName = subCtgName,
                CtgType = categoryType,
                Icon = icon,
                KybdBgImg = GetCollectibleKeyboardBackgroundImage(collectibleId),
                GmpdBgImg = GetCollectibleGamepadBackgroundImage(collectibleId),
                Link = GetCollectibleLink(collectibleId, LINK_STYLE_BRACKETS),
                Quest = {
                    Name = questName,
                    Text = bgText,
                    State = questState,
                },
            }
            if hint and hint ~= "" then
                collectibleMap[subCtgName][collectibleIndex]["Hint"] = hint
            end
        end
    end

    return collectibleMap
end

function GuildPlannerPro_Collectibles:ExportStoriesCollectibles()
    local collectibleMap = {}
    local categories = self:GetCategoryMap()
    local storiesCategory = categories[1]
    for subCategoryId = 1, storiesCategory.NumSubCategories do
        for collectibleIndex = 1, storiesCategory.SubCategories[subCategoryId].NumCollectibles do
            local collectibleId = GetCollectibleId(1, subCategoryId, collectibleIndex)
            collectibleMap[subCategoryId .. '-' .. collectibleIndex] = {
                Id = collectibleId,
                UnlockState = GetCollectibleUnlockStateById(collectibleId),
            }
        end
    end

    return collectibleMap
end

function GuildPlannerPro_Collectibles:ExportActivities()
    local lfgActivities = {
        LFG_ACTIVITY_ARENA,
        LFG_ACTIVITY_MASTER_DUNGEON,
        LFG_ACTIVITY_TRIAL,
    }
    local activities = {}
    for _, activityType in ipairs(lfgActivities) do
        activities[activityType] = {}

        local activityCount = GetNumActivitiesByType(activityType)
        for activityIndex = 1, activityCount do
            local activityId = GetActivityIdByTypeAndIndex(activityType, activityIndex)
            local activity = {}

            local name, levelMin, levelMax, cpMin, cpMax, groupType, minGroupSize, description = GetActivityInfo(activityId)
            if levelMin == 50 and not name:find(" Template") then
                activity = {
                    id = activityId,
                    idx = activityIndex,
                    type = activityType,
                    name = name,
                    level_min = levelMin,
                    level_max = levelMax,
                    cp_min = cpMin,
                    cp_max = cpMax,
                    group_type = groupType,
                    min_group_size = minGroupSize,
                }
                if description and description ~= "" then
                    activity["desc"] = description
                end

                local desc_texture_gp = GetActivityGamepadDescriptionTexture(activityId)
                local desc_texture_keyb = GetActivityKeyboardDescriptionTextures(activityId)
                if not desc_texture_gp:find("icon_missing.dds") then
                    activity["desc_texture_gp"] = desc_texture_gp
                end
                if not desc_texture_keyb:find("icon_missing.dds") then
                    activity["desc_texture_keyb"] = desc_texture_keyb
                end

                local activitySetId = GetActivitySetIdByTypeAndIndex(activityType, activityIndex)
                local setName, setDescription = GetActivitySetInfo(activitySetId)
                if setName ~= nil and setName ~= "" then
                    local icon = GetActivitySetIcon(activitySetId)
                    local set_desc_texture_gp = GetActivitySetGamepadDescriptionTexture(activitySetId)
                    local set_desc_texture_keyb = GetActivitySetKeyboardDescriptionTextures(activitySetId)
                    activity["set"] = { name = setName }
                    if setDescription and setDescription ~= "" then
                        activity["set"]["desc"] = setDescription
                    end
                    if not icon:find("icon_missing.dds") then
                        activity["set"]["icon"] = icon
                    end
                    if not set_desc_texture_gp:find("icon_missing.dds") then
                        activity["set"]["desc_texture_gp"] = set_desc_texture_gp
                    end
                    if not set_desc_texture_keyb:find("icon_missing.dds") then
                        activity["set"]["desc_texture_keyb"] = set_desc_texture_keyb
                    end
                end

                local battlegroundId = GetActivityBattlegroundId(activityId)
                if battlegroundId ~= nil and battlegroundId ~= 0 then
                    activity["bg"] = {
                        id = battlegroundId,
                        name = GetBattlegroundName(battlegroundId),
                        description = GetBattlegroundDescription(battlegroundId),
                        info_texture = GetBattlegroundInfoTexture(battlegroundId),
                    }
                end

                local zoneId = GetActivityZoneId(activityId)
                if zoneId ~= nil and zoneId ~= 0 then
                    activity["zone"] = {
                        id = zoneId,
                        name = GetZoneNameById(zoneId),
                    }
                end

                table.insert(activities[activityType], activity)
            end
        end
    end

    return activities
end
