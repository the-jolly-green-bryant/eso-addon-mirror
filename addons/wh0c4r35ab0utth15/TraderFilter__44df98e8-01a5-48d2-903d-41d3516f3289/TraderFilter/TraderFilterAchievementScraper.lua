local ADDON_NAME = 'TraderFilter'
local TraderFilter = TraderFilter or {}

TraderFilter.achievementScraper = {
    show = {},
    hide = {},
}

-- We can't turn item names into valid items in the system, so we don't know if an item has a valid name or not
-- if we don't do this (along with everything else), then we end up with like 7k results; this drops it down to like 30.
local function IsAnItem(item_or_description)
    local starts_with = {
        'Acquire ',
        'Alliance War ',
        'Aid an ',
        'Attain ',
        'Capture ',
        'Complete ',
        'Completed ',
        'Deconstruct ',
        'Defeat ',
        'Defender of ',
        'Drink at ',
        'Drink within',
        'Dungeon ',
        'Frolic ',
        'Give a coin',
        'Harvest ',
        'Help a ',
        'Improve ',
        'Learn ',
        'Make ',
        'Master ',
        'Rescue a',
        'Research ',
        'Retrieve the ',
        'Reveal Trait ',
        'Sieze ',
        'The Fragment of ',
        'The Fragmment of ',
        'The Fragments of ',
        'The Fragmments of ',
        'The Wing of the ',
        'Trials ',
    }

    for _, word in ipairs(starts_with) do
        if item_or_description:match("^" .. word) then return false end
    end

    local equals = {
    }

    for _, word in ipairs(equals) do
        if item_or_description == word then return false end
    end

    local in_the_middle = {
        ' Ancestral Tomb',
        ' Assassin',
        ' Challenge',
        ' Delver',
        ' Difficult Mode ',
        ' Explorer',
        ' Isle',
        ' Master',
        ' Pathfinder',
        ' Skyshard Hunter',
        ' Slayer',
        ' Survivor',
        ' Tapestry Piece',
    }

    for _, words in ipairs(in_the_middle) do
        if item_or_description:lower():match(words:lower()) then return false end
    end

    return true
end

-- Achievements to skip
local function doWeKeepThisAchievement(hasReward, categoryIndex, categoryName, subCategoryIndex, subCategoryName, achievementId, achievementName, description, progressDisplay, reward)
    if not hasReward then return false end
    local to_keep_starting_with = {
        'Acquire and use',
        'Collect',
        'Consume',
        'Gather',
    }

    if 1==2 then
        for _, word in ipairs(to_keep_starting_with) do
            if description:match("^" .. word) then return false end
        end
    end

    local starts_with = {
        'A series',
        'Assist',
        'Avert',
        'Become a',
        'Become certified',
        'Bring Glory',
        'Bring',
        'Capture',
        'Celebrate',
        'Collect and restore',
        'Collect trophies',
        'Come visit',
        'Complete',
        'Conquer',
        'Deconstruct',
        'Defeat',
        'Defy',
        'Destroy',
        'Discover',
        'Disrupt',
        'Dominate',
        'Drive',
        'Earn the rank',
        'Earn',
        'End the',
        'Enter',
        'Engage',
        'Excavate',
        'Execute all',
        'Explore',
        'Find all the Skyshards',
        'Find and defeat',
        'Find and open',
        'Find the adventurous',
        'Finish',
        'Follow the',
        'Free',
        'Gain',
        'Harvest',
        'Have a character',
        'Help',
        'Improve',
        'Imprison',
        'Investigate',
        'Join',
        'Journey',
        'Kill',
        'Learn every',
        'Locate and',
        'Make an offering',
        'Make a',
        'Obtain and enter',
        'Pay',
        'Perform acts',
        'Pet and interact',
        'Play a',
        'Prevent',
        'Prove your',
        'Put the dead',
        'Rally',
        'Reach',
        'Refine',
        'Release',
        'Research',
        'Restore',
        'Revive',
        'Seal the',
        'Seek the wisdom',
        'Speak',
        'Spend',
        'Steal every treasure',
        'Stop the',
        'Stop an',
        'Stop a',
        'Successfully',
        'Take',
        'Throw a',
        'Topple the',
        'Translate',
        'Track',
        'Travel to',
        'Use',
        'Visit the',
        'Walk the',
        'Wear',
        'While in a group',
        'Win',
        'You defeated',
        'You thwarted',
    }

    for _, word in ipairs(starts_with) do
        if description:match("^" .. word) then return false end
    end

    local in_the_middle = {
        ' capture points ',
        ' mundus stones ',
        ' perform a ritual ',
        ' points of damage ',
        ' provisioning recipes.',
        ' quality item.',
        ' racial style.',
        ' racial styles.',
        ' rank of ',
        ' rare fish ',
        ' seek out and purchase ',
        ' tales of tribute deck.',
        ' they can be purchased ',
        ' verses in the infinite ',
        ' visions in the infinite ',
    }

    for _, words in ipairs(in_the_middle) do
        if description:lower():match(words:lower()) then return false end
    end

    return true
end

local function GetAchievementData(data, categoryIndex, categoryName, subCategoryIndex, subCategoryName, achievementIds)
    for achievementIndex = 1, #achievementIds do
        local achievementId = achievementIds[achievementIndex]

        local achievementName, description, points, icon, completed, date, time = GetAchievementInfo(achievementId)
        local progressText = {}

        local numCriteria = GetAchievementNumCriteria(achievementId)

        -- Build progress text from all criteria
        for i = 1, numCriteria do
            local item_or_description, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
            table.insert(progressText, string.format("%s: %s/%s", item_or_description, numCompleted, numRequired))
        end

        local reward = ''

        local hasRewardItem, itemName, iconTextureName, displayQuality = GetAchievementRewardItem(achievementId)
        local hasRewardTitle, titleName = GetAchievementRewardTitle(achievementId)
        local hasRewardDye, dyeId = GetAchievementRewardDye(achievementId)
        local hasRewardCollectible, collectibleId = GetAchievementRewardCollectible(achievementId)
        local hasRewardTributeCardUpgrade, tributePatronId, tributeCardIndex = GetAchievementRewardTributeCardUpgradeInfo(achievementId)
        local hasReward = hasRewardItem or hasRewardTitle or hasRewardDye or hasRewardCollectible or hasRewardTributeCardUpgrade

        if hasReward then
            -- Item
            if hasRewardItem then
                reward = string.format("%s: %s", GetString(SI_GAMEPAD_ACHIEVEMENTS_ITEM_LABEL), zo_strformat(SI_GAMEPAD_ACHIEVEMENTS_ITEM_ICON_AND_DESCRIPTION, iconTextureName, itemName))
            end

            -- Title
            if hasRewardTitle then
                reward = string.format("%s: %s", GetString(SI_GAMEPAD_ACHIEVEMENTS_TITLE), titleName)
            end

            -- Dye
            if hasRewardDye then
                local dyeName, known, rarity, hueCategory, dyeAchievementId, r, g, b = GetDyeInfoById(dyeId)
                reward = string.format("%s: %s", GetString(SI_GAMEPAD_ACHIEVEMENTS_DYE), dyeName)
            end

            --Collectible
            if hasRewardCollectible then
                local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
                reward = string.format("%s: %s", ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleData:GetCategoryTypeDisplayName()), collectibleData:GetFormattedName())
            end

            --Tribute Card Upgrade
            if hasRewardTributeCardUpgrade then
                local patronData = TRIBUTE_DATA_MANAGER:GetTributePatronData(tributePatronId)
                local baseCardId, upgradeCardId = patronData:GetDockCardInfoByIndex(tributeCardIndex)
                local upgradeCardData = ZO_TributeCardData:New(tributePatronId, upgradeCardId)
                reward = string.format("%s: %s", GetString(SI_GAMEPAD_ACHIEVEMENTS_TRIBUTE_CARD_UPGRADE), upgradeCardData:GetColorizedFormattedName())
            end
        end

        -- Format progress - show "Complete" if done, otherwise show criteria progress
        local progressDisplay
        if completed then
            progressDisplay = "Completed"
        elseif #progressText > 0 then
            progressDisplay = table.concat(progressText, ", ")
        else
            progressDisplay = ""
        end

        -- First step, we only care about things that have a reward.
        if doWeKeepThisAchievement(hasReward, categoryIndex, categoryName, subCategoryIndex, subCategoryName, achievementId, achievementName, description, progressDisplay, reward) then
            for i = 1, numCriteria do
                local item_or_description, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
                local function swapOuts(str)
                    if type(str) ~= "string" then return str, false end -- Safety for non-strings
                    local swap_outs = {
                        ['Wormwrithe Haj Mota Scales'] = 'Writhing Haj Mota Scales',
                        ['Fragments of Customization'] = 'Mosaic Skill Shred',
                        ['Mosaic Style Shreds'] = 'Mosaic Skill Shred'
                    }

                    if swap_outs[str] then
                        return swap_outs[str]
                    end

                    return str
                end

                item_or_description = swapOuts(item_or_description)
                item_or_description = item_or_description:gsub("^Consume%s+", "")
                item_or_description_non_plural = item_or_description:gsub("s$", "")
                if IsAnItem(item_or_description) then
                    if numCompleted == numRequired then
                        if not TraderFilter.achievementScraper.hide[item_or_description] then
                            TraderFilter.achievementScraper.hide[item_or_description] = true
                            if item_or_description ~= item_or_description_non_plural then
                                TraderFilter.achievementScraper.hide[item_or_description_non_plural] = true
                            end
                        elseif 1==2 then
                            table.insert(TraderFilter.achievementScraper.hide, item_or_description)
                            if item_or_description ~= item_or_description_non_plural then
                                table.insert(TraderFilter.achievementScraper.hide, item_or_description_non_plural)
                            end
                        end
                    else
                        if not TraderFilter.achievementScraper.show[item_or_description] then
                            TraderFilter.achievementScraper.show[item_or_description] = true
                            if item_or_description ~= item_or_description_non_plural then
                                TraderFilter.achievementScraper.show[item_or_description_non_plural] = true
                            end
                        elseif 1==2 then
                            table.insert(TraderFilter.achievementScraper.show, item_or_description)
                            if item_or_description ~= item_or_description_non_plural then
                                table.insert(TraderFilter.achievementScraper.show, item_or_description_non_plural)
                            end
                        end
                    end
                end
            end

            --table.insert(data, {
            --    categoryId = categoryIndex,
            --    category = categoryName,
            --    subCategoryId = subCategoryIndex or 0,
            --    subCategory = subCategoryName,
            --    achievementId = achievementId,
            --    name = achievementName,
            --    description = description,
            --    progress = progressDisplay,
            --    reward = reward,
            --})
        end
    end
end

local function GetAllAchievements()
    local data = {}

    -- Populate actual categories.
    for categoryIndex = 1, GetNumAchievementCategories() do
        local categoryName, numSubCategories, numAchievements, earnedPoints, totalPoints = GetAchievementCategoryInfo(
            categoryIndex)

        -- Handle "General"
        local achievementIds = ZO_GetAchievementIds(categoryIndex, nil, numAchievements)
        GetAchievementData(data, categoryIndex, categoryName, nil, GetString(SI_JOURNAL_PROGRESS_CATEGORY_GENERAL),
            achievementIds)

        -- Handle categories
        for subCategoryIndex = 1, numSubCategories do
            local subCategoryName, subNumAchievements = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
            local achievementIds = ZO_GetAchievementIds(categoryIndex, subCategoryIndex, subNumAchievements)
            GetAchievementData(data, categoryIndex, categoryName, subCategoryIndex, subCategoryName, achievementIds)
        end
    end

    --d(string.format("Found %s entries", #data))
    return data
end

function TraderFilter.scrapeAchievements()
    -- reset between scrapes
    TraderFilter.achievementScraper.hide = {}
    TraderFilter.achievementScraper.show = {}

    GetAllAchievements()
end

_G[ADDON_NAME] = TraderFilter