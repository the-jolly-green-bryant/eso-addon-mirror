GuildPlannerPro_Achievements = {}

function GuildPlannerPro_Achievements:CollectAllAchievementsTaxonomy()
    local achievements = {}
    local numCategories = GetNumAchievementCategories()
    for topLevelIndex = 1, numCategories do
        self:AddAchievementToTaxonomy(achievements, topLevelIndex, nil)

        local _, numSubCategories = GetAchievementCategoryInfo(topLevelIndex)
        if numSubCategories > 0 then
            for subCategoryIndex = 1, numSubCategories do
                local _, subNumAchievements = GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)
                if subNumAchievements > 0 then
                    self:AddAchievementToTaxonomy(achievements, topLevelIndex, subCategoryIndex)
                end
            end
        end
    end

    return achievements
end

function GuildPlannerPro_Achievements:AddAchievementToTaxonomy(achievements, topLevelIndex, subCategoryIndex)
    local effectiveSubcategoryIndex = subCategoryIndex or nil
    -- Thanks @code65536 for this elegant tip!
    local numAchievements = subCategoryIndex
            and select(2, GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex))
            or select(3, GetAchievementCategoryInfo(topLevelIndex))
    for achievementIndex = 1, numAchievements do
        local achievementId = GetAchievementId(topLevelIndex, effectiveSubcategoryIndex, achievementIndex)
        if achievementId ~= 0 then
            local lineAchievementId = GetFirstAchievementInLine(achievementId)
            table.insert(achievements, {
                Id = achievementId,
                Index = achievementIndex,
                TopLevelIndex = topLevelIndex,
                SubCategoryIndex = effectiveSubcategoryIndex or 0,
                IsInLine = lineAchievementId ~= 0,
                PersistenceLevel = GetAchievementPersistenceLevel(achievementId),
            })
            while lineAchievementId ~= 0 do
                table.insert(achievements, {
                    Id = lineAchievementId,
                    Index = achievementIndex,
                    TopLevelIndex = topLevelIndex,
                    SubCategoryIndex = effectiveSubcategoryIndex or 0,
                    IsInLine = true,
                    PersistenceLevel = GetAchievementPersistenceLevel(lineAchievementId),
                })
                lineAchievementId = GetNextAchievementInLine(lineAchievementId)
            end
        end
    end
end

function GuildPlannerPro_Achievements:ExportAchievementsCompletionData(filterPersistenceLevel)
    local achievements = self:CollectAllAchievementsTaxonomy()
    local achievementCompletion = {}
    for _, achievement in ipairs(achievements) do
        if (achievement["PersistenceLevel"] == filterPersistenceLevel) then
            local completionData = GuildPlannerPro_Achievements:ParseAchievementCompletionData(achievement["Id"])
            if completionData then
                achievementCompletion[achievement["Id"]] = completionData -- achievementId-based key'ing is needed for OnEventAchievementAwarded() handler.
            end
        end
    end

    return achievementCompletion
end

function GuildPlannerPro_Achievements:ParseAchievementCompletionData(achievementId)
    local _, _, _, _, completed, _, _ = GetAchievementInfo(achievementId)

    -- Calculate criteria completion
    local criteria, numCriteria = {}, GetAchievementNumCriteria(achievementId)
    if numCriteria then
        for criterionIndex = 1, numCriteria do
            local _, numCompleted, _ = GetAchievementCriterion(achievementId, criterionIndex)
            if numCompleted > 0 then
                table.insert(criteria, {
                    Index = criterionIndex,
                    NumCompleted = numCompleted,
                })
            end
        end
    end

    -- Record it if there is total or partial completion of the achievement
    if completed or #criteria > 0 then
        local characterIdForCompletedAchievement = GetCharIdForCompletedAchievement(achievementId)

        return {
            AchievementId = achievementId,
            AttributedCharacterId = Id64ToString(characterIdForCompletedAchievement),
            CompletedAt = GetAchievementTimestamp(achievementId),
            Criteria = criteria,
            LineIds = lineIds,
        }
    end

    return nil
end

function GuildPlannerPro_Achievements:MapAllAchievements()
    local achievements = GuildPlannerPro_Achievements:CollectAllAchievementsTaxonomy()
    for _, achievement in ipairs(achievements) do
        local topLevelName = GetAchievementCategoryInfo(achievement["TopLevelIndex"])
        local subCategoryName = GetAchievementSubCategoryInfo(achievement["TopLevelIndex"], achievement["SubCategoryIndex"])
        if not subCategoryName or subCategoryName == "" then
            subCategoryName = "General"
        end
        local ctgNormalIcon, ctgPressedIcon, ctgMouseoverIcon = GetAchievementCategoryKeyboardIcons(achievement["TopLevelIndex"])
        local achievementName, achievementDescription, achievementPoints, achievementIcon = GetAchievementInfo(achievement["Id"])
        achievement["TopLevelName"] = topLevelName
        achievement["SubCategoryName"] = subCategoryName
        achievement["TopLevelIcons"] = {
            Normal = ctgNormalIcon,
            Pressed = ctgPressedIcon,
            Mouseover = ctgMouseoverIcon,
        }
        achievement["Name"] = achievementName
        achievement["Description"] = achievementDescription
        achievement["Points"] = achievementPoints
        achievement["Icon"] = achievementIcon
        achievement["FullPath"] = zo_strformat("<<1>>/<<2>>/<<3>>", topLevelName, subCategoryName, achievementName)

        if achievement["IsInLine"] then
            achievement["LineIds"] = {}
            local lineAchievementId = GetFirstAchievementInLine(achievement["Id"])
            while lineAchievementId ~= 0 do
                table.insert(achievement["LineIds"], lineAchievementId)
                lineAchievementId = GetNextAchievementInLine(lineAchievementId)
            end
            achievement["IsLineTerminator"] = achievement["LineIds"][#achievement["LineIds"]] == achievement["Id"]
        end

        achievement["DifficultyTier"] = "casual"
        if GuildPlannerPro_Utils:InTable(topLevelName, GuildPlannerPro_Const.PveMidgameContent) then
            achievement["DifficultyTier"] = "mid_game"
            if topLevelName == "Arenas" then
                achievement["ActivityType"] = LFG_ACTIVITY_ARENA
            elseif topLevelName == "DLC Dungeons" then
                achievement["ActivityType"] = LFG_ACTIVITY_MASTER_DUNGEON
            elseif topLevelName == "Infinite Archive" then
                achievement["ActivityType"] = LFG_ACTIVITY_ENDLESS_DUNGEON
            end
        elseif topLevelName == "Dungeons" then
            achievement["ActivityType"] = LFG_ACTIVITY_DUNGEON
        elseif topLevelName == "Trials" then
            achievement["DifficultyTier"] = "end_game"
            achievement["ActivityType"] = LFG_ACTIVITY_TRIAL
        elseif topLevelName == "Player VS Player" then
            achievement["DifficultyTier"] = ""
            if subCategoryName == "Alliance War" then
                achievement["ActivityType"] = LFG_ACTIVITY_AVA
            elseif subCategoryName == "Battlegrounds" then
                achievement["ActivityType"] = LFG_ACTIVITY_BATTLE_GROUND_CHAMPION
            end
        end

        achievement["Type"] = "pve"
        if topLevelName == "Crafting" then
            achievement["Type"] = "crafting"
        elseif subCategoryName == "Fishing" then
            achievement["Type"] = "gathering"
        elseif topLevelName == "Player VS Player" or subCategoryName == "Whitestrake's Mayhem" then
            achievement["Type"] = "pvp"
        elseif topLevelName == "Housing" then
            achievement["Type"] = "housing"
        elseif subCategoryName == "Tales of Tribute" then
            achievement["Type"] = "meta-game"
        end

        achievement["Criteria"] = {}
        local numCriteria = GetAchievementNumCriteria(achievement["Id"])
        if numCriteria then
            for criterionIndex = 1, numCriteria do
                local description, _, numRequired = GetAchievementCriterion(achievement["Id"], criterionIndex)
                achievement["Criteria"][criterionIndex] = {
                    Index = criterionIndex,
                    Description = description,
                    NumRequired = numRequired,
                }
            end
        end

        achievement["Rewards"] = {}
        local hasRewardItem, itemName, itemIcon, displayQuality = GetAchievementRewardItem(achievement["Id"])
        if hasRewardItem then
            table.insert(achievement["Rewards"], {
                Type = "Item",
                Name = itemName,
                Icon = itemIcon,
                DisplayQuality = displayQuality,
            })
        end
        local hasRewardTitle, title = GetAchievementRewardTitle(achievement["Id"])
        if hasRewardTitle then
            table.insert(achievement["Rewards"], {
                Type = "Title",
                Title = title,
            })
        end
        local hasRewardDye, dyeId = GetAchievementRewardDye(achievement["Id"])
        if hasRewardDye then
            local dyeName, _, dyeRarity, _, _, r, g, b = GetDyeInfoById(dyeId)
            table.insert(achievement["Rewards"], {
                Type = "Dye",
                DyeInfo = {
                    Name = dyeName,
                    Rarity = dyeRarity,
                    Red = r,
                    Green = g,
                    Blue = b,
                }
            })
        end
        local hasRewardCollectible, collectibleId = GetAchievementRewardCollectible(achievement["Id"])
        if hasRewardCollectible then
            local name, description, icon, _, _, _, _, categoryType, hint = GetCollectibleInfo(collectibleId)
            table.insert(achievement["Rewards"], {
                Type = "Collectible",
                Collectible = {
                    Id = collectibleId,
                    Name = name,
                    Description = description,
                    Icon = icon,
                    CategoryType = categoryType,
                    IconHint = hint,
                },
            })
        end
        local hasRewardCardUpg, tributePatronId, tributeCardIndex = GetAchievementRewardTributeCardUpgradeInfo(achievement["Id"])
        if hasRewardCardUpg then
            table.insert(achievement["Rewards"], {
                Type = "TributeCardUpgrade",
                TributePatron = {
                    Id = tributePatronId,
                    Icon = {
                        Small = GetTributePatronSmallIcon(tributePatronId),
                        Large = GetTributePatronLargeIcon(tributePatronId),
                        LargeRing = GetTributePatronLargeRingIcon(tributePatronId),
                        Suit = GetTributePatronSuitIcon(tributePatronId),
                    }
                },
                TributeCard = {
                    Index = tributeCardIndex,
                },
            })
        end
    end

    return achievements
end
