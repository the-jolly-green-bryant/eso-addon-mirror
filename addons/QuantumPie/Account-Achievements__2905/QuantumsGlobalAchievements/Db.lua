if QUANTUMPIES_GA == nil then QUANTUMPIES_GA = {} end
local addon = QUANTUMPIES_GA

local GENERAL_NAME = QUANTUMPIES_GA_CONSTANTS.generalCategoryName

--  ========================================
--  |            LOCAL HELPERS             |
--  ========================================
local function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function TrackAchievementLine(achievementID, currentName, subCategoryTable)
    --  Check if an achievement is part of a line (such as Always Travel Separately -> Broken Wheel)
    local playerName = GetUnitName("player")
    local playerId = addon:GetCharacterIdFromName(playerName)
    local lineID = GetFirstAchievementInLine(achievementID)
    local wasInLine = lineID ~= 0

    local lineProgress = 0
    local lineCount = 0
    while (lineID ~= 0) do
        local name, _, points, _, completed, date, _ = GetAchievementInfo(lineID)
        lineCount = lineCount + 1
        --if (name ~= currentName) then
            if subCategoryTable[name] == nil then subCategoryTable[name] = {id = lineID, characters = {}, points = points} end
            if completed then
                local characterArray = subCategoryTable[name]["characters"]
                characterArray[playerId] = {id = playerId, date = date}
                lineProgress = lineProgress + 1
            end
        --end
        lineID = GetNextAchievementInLine(lineID)
    end

    -- Iterate again to update db with line progress
    lineID = GetFirstAchievementInLine(achievementID)
    while (lineID ~= 0) do
        local name, _, points, _, completed, date, _ = GetAchievementInfo(lineID)

        -- Update int variable with the maximum
        --if (name ~= currentName) then
            if (subCategoryTable[name].lineCount == nil) then subCategoryTable[name].lineCount = lineCount end
            if (subCategoryTable[name].lineProgress == nil or subCategoryTable[name].lineProgress < lineProgress) then
                subCategoryTable[name].lineProgress = lineProgress
            end

            local characterArray = subCategoryTable[name]["characters"]
            if (completed) then
                characterArray[playerId].progress = lineProgress .. "/" .. lineCount
            end
        --end
        lineID = GetNextAchievementInLine(lineID)
    end

    return wasInLine
end

--  ========================================
--  |     ACHIEVEMENT DB QUERY HELPERS     |
--  ========================================
function addon:QueryAchievementByNames(categoryName, subCategoryName, achievementName, achievementId)
    if(self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName] == nil) then
        self:CheckForNewSubCategories(categoryName)
    end
    local achievement = self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName][achievementName]
    if achievement == nil then -- a new achievement was added
        --self:InitializeDB()
        if (TrackAchievementLine(id, achievementName, self:QueryAchievementBySubcategory(categoryName, subCategoryName)) == false) then -- If the achievement is part of a line, handle it there. Otherwise:
            local points = select(3, GetAchievementInfo(achievementId))
            local completed = select(5, GetAchievementInfo(achievementId))

            self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName][achievementName] = { id = id, characters = {}, points = points} -- Add the achievement to the DB
            self.svAchievements.achievements[categoryName]["earnedPoints"] = self.svAchievements.achievements[categoryName]["earnedPoints"] + points
            if(self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName]["earnedPoints"] == nil) then
                self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName]["earnedPoints"] = 0
            end
            self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName]["earnedPoints"] = self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName]["earnedPoints"] + points

            achievement = self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName][achievementName]
            if completed then -- If its been completed on the current character, record the completion
                local playerName = GetUnitName("player")
                local playerId = self:GetCharacterIdFromName(playerName)
                local date = select(6, GetAchievementInfo(achievementId))
                self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName][achievementName]["characters"][playerId]  = {id = playerId, date = date}
            end
        end
    end

    return achievement
end

function addon:QueryAchievementBySubcategory(categoryName, subCategoryName)
    return self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName]
end

function addon:QueryAchievementByID(achievementId)
    local topLevelIndex, subCategoryIndex, _ = GetCategoryInfoFromAchievementId(achievementId)
    local categoryName = select(1, GetAchievementCategoryInfo(topLevelIndex))
    local subCategoryName = subCategoryIndex == nil
            and GENERAL_NAME
            or select(1, GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex))
    local name = select(1, GetAchievementInfo(achievementId))
    return self:QueryAchievementByNames(categoryName, subCategoryName, name, achievementId)
end

function addon:QueryFirstAchievementInLine(achievementId)
    local lineId = GetFirstAchievementInLine(achievementId)
    if (lineId == 0) then return nil end
    local categoryName = ""
    local subCategoryName = ""
    local success = false
    while (lineId ~= 0) do
        local topLevelIndex, subCategoryIndex, _ = GetCategoryInfoFromAchievementId(lineId)
        categoryName = select(1, GetAchievementCategoryInfo(topLevelIndex))
        subCategoryName = subCategoryIndex == nil
                and GENERAL_NAME
                or select(1, GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex))
        if (topLevelIndex ~= nil) then
            success = true
        end
        lineId = GetNextAchievementInLine(lineId)
    end

    if (success) then
        local name = select(1, GetAchievementInfo(GetFirstAchievementInLine(achievementId)))
        return self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName][name]
    end
    return nil
end

--  ===========================================
--  |     ACHIEVEMENT DB MANAGEMENT METHODS   |
--  ===========================================

function addon:InitializeDB()
    local function CalculateLinePoints(achievementID, currentName, subCategoryTable)
        local lineID = GetFirstAchievementInLine(achievementID)
        local earnedPoints = 0
        while (lineID ~= 0) do
            local name, _, points, _, completed, date, _ = GetAchievementInfo(lineID)
            if (name ~= currentName) then
                if (TableLength(subCategoryTable[name]["characters"]) > 0) then
                    earnedPoints = earnedPoints + points
                end
            end
            lineID = GetNextAchievementInLine(lineID)
        end

        return earnedPoints
    end

    local totalEarned = 0
    local playerName = GetUnitName("player")
    local playerId = self:GetCharacterIdFromName(playerName)
    for topLevelIndex = 1, GetNumAchievementCategories() do
        local categoryName, numSubCategories, numAchievements  = GetAchievementCategoryInfo(topLevelIndex)
        local categoryEarnedPoints = 0

        if self.svAchievements.achievements[categoryName] == nil then self.svAchievements.achievements[categoryName] = { earnedPoints = 0, categoryIndex = topLevelIndex, subCategories = {}} end

        --  Get achievements within subcategories
        for subCategoryIndex = 1, numSubCategories do
            local subCategoryName, numSubAchievements = GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)
            local subCategoryEarnedPoints = 0

            if self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName] == nil then self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName] = {} end
            for index = 1, numSubAchievements do
                local id = GetAchievementId(topLevelIndex, subCategoryIndex, index)
                local achievementName, _, points, _, completed, date, _ = GetAchievementInfo(id)
                if (TrackAchievementLine(id, achievementName, self:QueryAchievementBySubcategory(categoryName, subCategoryName)) == false) then
                    if self:QueryAchievementByNames(categoryName, subCategoryName, achievementName) == nil then self:QueryAchievementBySubcategory(categoryName, subCategoryName)[achievementName] = { id = id, characters = {}, points = points} end
                    -- Add character if achievement has been completed on them
                    if completed then
                        self:QueryAchievementByNames(categoryName, subCategoryName, achievementName)["characters"][playerId] = {id = playerId, date = date}
                    end
                end

                -- Calculate points
                local linePoints = CalculateLinePoints(id, name, self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName])
                if (linePoints > 0) then
                    categoryEarnedPoints = categoryEarnedPoints + linePoints
                    subCategoryEarnedPoints = subCategoryEarnedPoints + linePoints
                    -- # IS ONLY FOR INDICES WHICH ARE NUMERICAL VALUES
                elseif (TableLength(self:QueryAchievementByNames(categoryName, subCategoryName, achievementName)["characters"]) > 0) then
                    categoryEarnedPoints = categoryEarnedPoints + points
                    subCategoryEarnedPoints = subCategoryEarnedPoints + points
                end

                self:QueryAchievementBySubcategory(categoryName, subCategoryName)["earnedPoints"] = subCategoryEarnedPoints
            end
        end

        --  Get achievement directly under a category (General)
        if numAchievements > 0 then
            local subCategoryEarnedPoints = 0
            if self:QueryAchievementBySubcategory(categoryName, GENERAL_NAME) == nil then self.svAchievements.achievements[categoryName]["subCategories"][GENERAL_NAME] = {} end
            for index = 1, numAchievements do
                local id = GetAchievementId(topLevelIndex, nil, index)
                local achievementName, _, points, _, completed, date, _ = GetAchievementInfo(id)

                if (TrackAchievementLine(id, name, self.svAchievements.achievements[categoryName]["subCategories"][GENERAL_NAME]) == false) then
                    if self:QueryAchievementByNames(categoryName, GENERAL_NAME, achievementName) == nil then self:QueryAchievementBySubcategory(categoryName, GENERAL_NAME)[achievementName] = { id = id, characters = {}, points = points} end
                    -- Add character if achievement has been completed on them
                    if completed then
                        self:QueryAchievementByNames(categoryName, GENERAL_NAME, achievementName)["characters"][playerId]  = {id = playerId, date = date}
                    end
                end

                -- Calculate points
                local linePoints = CalculateLinePoints(id, name, self:QueryAchievementBySubcategory(categoryName, GENERAL_NAME))
                if (linePoints > 0) then
                    categoryEarnedPoints = categoryEarnedPoints + linePoints
                    subCategoryEarnedPoints = subCategoryEarnedPoints + linePoints
                elseif (TableLength(self:QueryAchievementByNames(categoryName, GENERAL_NAME, achievementName)["characters"]) > 0) then
                    categoryEarnedPoints = categoryEarnedPoints + points
                    subCategoryEarnedPoints = subCategoryEarnedPoints + points
                end
            end
            self:QueryAchievementBySubcategory(categoryName, GENERAL_NAME)["earnedPoints"] = subCategoryEarnedPoints
        end

        self.svAchievements.achievements[categoryName]["earnedPoints"] = categoryEarnedPoints
        totalEarned = totalEarned + categoryEarnedPoints
    end
    self.svSettings.totalPointsEarned = totalEarned
end

function addon:CheckForNewCategories()
    for topLevelIndex = 1, GetNumAchievementCategories() do
        local categoryName, numSubCatgories, numAchievements  = GetAchievementCategoryInfo(topLevelIndex)
        if self.svAchievements.achievements[categoryName] == nil then
            local playerName = GetUnitName("player")
            local playerId = self:GetCharacterIdFromName(playerName)
            self.svAchievements.achievements[categoryName] = { earnedPoints = 0, categoryIndex = topLevelIndex, subCategories = {}}
            for subCategoryIndex = 1, numSubCatgories do
                local subCategoryName, numSubAchievements = GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)
                if self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName] == nil then self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName] = {} end
                for index = 1, numSubAchievements do
                    local id = GetAchievementId(topLevelIndex, subCategoryIndex, index)
                    local achievementName, _, points, _, completed, date, _ = GetAchievementInfo(id)
                    TrackAchievementLine(id, name, self:QueryAchievementBySubcategory(categoryName, subCategoryName))
                    if self:QueryAchievementByNames(categoryName, subCategoryName, achievementName) == nil then
                        self:QueryAchievementBySubcategory(categoryName, subCategoryName)[achievementName] = { id = id, characters = {}, points = points}
                    end
                    if completed then
                        self:QueryAchievementByNames(categoryName, subCategoryName, achievementName)["characters"][playerId] = {id = playerId, date = date}
                    end
                end
            end

            if self:QueryAchievementBySubcategory(categoryName, GENERAL_NAME) == nil then self.svAchievements.achievements[categoryName]["subCategories"][GENERAL_NAME] = {} end
            for index = 1, numAchievements do
                local id = GetAchievementId(topLevelIndex, nil, index)
                local achievementName, _, points, _, completed, date, _ = GetAchievementInfo(id)
                TrackAchievementLine(id, name, self:QueryAchievementBySubcategory(categoryName, GENERAL_NAME))
                if self:QueryAchievementByNames(categoryName, GENERAL_NAME, achievementName) == nil then
                    self:QueryAchievementBySubcategory(categoryName, GENERAL_NAME)[achievementName] = { id = id, characters = {}, points = points}
                end
                if completed then
                    self:QueryAchievementByNames(categoryName, GENERAL_NAME, achievementName)["characters"][playerId]  = {id = playerId, date = date}
                end
            end
        end
    end
end

function addon:CheckForNewSubCategories(catName)
    for topLevelIndex = 1, GetNumAchievementCategories() do
        local categoryName, numSubCategories, numAchievements  = GetAchievementCategoryInfo(topLevelIndex)
        if categoryName == catName then
            local categoryEarnedPoints = 0
            for subCategoryIndex = 1, numSubCategories do
                local subCategoryName, numSubAchievements = GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)
                local subCategoryEarnedPoints = 0

                if self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName] == nil then
                    self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName] = {}
                    for index = 1, numSubAchievements do
                        local id = GetAchievementId(topLevelIndex, subCategoryIndex, index)
                        local achievementName, _, points, _, completed, date, _ = GetAchievementInfo(id)
                        if (TrackAchievementLine(id, achievementName, self:QueryAchievementBySubcategory(categoryName, subCategoryName)) == false) then
                            if self:QueryAchievementByNames(categoryName, subCategoryName, achievementName) == nil then self:QueryAchievementBySubcategory(categoryName, subCategoryName)[achievementName] = { id = id, characters = {}, points = points} end
                            -- Add character if achievement has been completed on them
                            if completed then
                                self:QueryAchievementByNames(categoryName, subCategoryName, achievementName)["characters"][playerId] = {id = playerId, date = date}
                            end
                        end

                        -- Calculate points
                        local linePoints = CalculateLinePoints(id, name, self.svAchievements.achievements[categoryName]["subCategories"][subCategoryName])
                        if (linePoints > 0) then
                            categoryEarnedPoints = categoryEarnedPoints + linePoints
                            subCategoryEarnedPoints = subCategoryEarnedPoints + linePoints
                            -- # IS ONLY FOR INDICES WHICH ARE NUMERICAL VALUES
                        elseif (TableLength(self:QueryAchievementByNames(categoryName, subCategoryName, achievementName)["characters"]) > 0) then
                            categoryEarnedPoints = categoryEarnedPoints + points
                            subCategoryEarnedPoints = subCategoryEarnedPoints + points
                        end

                        self:QueryAchievementBySubcategory(categoryName, subCategoryName)["earnedPoints"] = subCategoryEarnedPoints
                    end
                end
            end
        end
    end
end
