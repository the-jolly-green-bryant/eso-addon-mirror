local BA = BMGAdventures
BA.LegacyImport = BA.LegacyImport or {}

local function now()
    return GetTimeStamp and GetTimeStamp() or 0
end

local function normalizedText(value)
    if not value then return "" end
    return string.lower(tostring(value))
end

local function scanAchievements()
    local completed = {}
    local byName = {}
    local stats = {
        scanned = 0,
        completed = 0,
        raid = 0,
        dungeon = 0,
        points = 0,
    }

    local function scanBucket(categoryIndex, subCategoryIndex, count, categoryName, subCategoryName)
        for achievementIndex = 1, count do
            local achievementId = GetAchievementId(categoryIndex, subCategoryIndex, achievementIndex)
            if achievementId and achievementId ~= 0 then
                stats.scanned = stats.scanned + 1
                local name, description, points, icon, isComplete, date, time = GetAchievementInfo(achievementId)
                if isComplete then
                    stats.completed = stats.completed + 1
                    stats.points = stats.points + (tonumber(points) or 0)
                    local record = {
                        id = achievementId,
                        name = name or "",
                        points = points or 0,
                        date = date,
                        time = time,
                        category = categoryName or "",
                        subCategory = subCategoryName or "",
                    }
                    completed[achievementId] = record
                    if name and name ~= "" then byName[normalizedText(name)] = record end

                    -- These counts are for dev2 diagnostics and generic BMG achievement
                    -- milestones only. They are not leaderboard evidence classifications.
                    local categoryLower = normalizedText(categoryName)
                    if string.find(categoryLower, "trial", 1, true) then
                        stats.raid = stats.raid + 1
                    elseif string.find(categoryLower, "dungeon", 1, true) then
                        stats.dungeon = stats.dungeon + 1
                    end
                end
            end
        end
    end

    local numCategories = GetNumAchievementCategories()
    for categoryIndex = 1, numCategories do
        local categoryName, numSubCategories, numAchievements = GetAchievementCategoryInfo(categoryIndex)
        scanBucket(categoryIndex, nil, numAchievements or 0, categoryName, "")
        for subCategoryIndex = 1, (numSubCategories or 0) do
            local subCategoryName, numSubAchievements = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
            scanBucket(categoryIndex, subCategoryIndex, numSubAchievements or 0, categoryName, subCategoryName)
        end
    end

    return completed, byName, stats
end

function BA.LegacyImport:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name .. "LegacyImport", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(BA.name .. "LegacyImport", EVENT_PLAYER_ACTIVATED)
        if BA.settings.autoLegacyImport ~= false and not BA.account.legacyImport.completed then
            self:Run(false)
        end
    end)
end

function BA.LegacyImport:Run(force)
    if BA.account.legacyImport.completed and not force then return false end

    local completed, byName, stats = scanAchievements()
    BA.account.legacyImport.achievements = completed
    BA.account.legacyImport.stats = stats
    BA.account.legacyImport.lastScan = now()
    BA.account.legacyImport.version = 2

    -- Set generic legacy achievement milestone progress from ESO's authoritative
    -- completed catalog. This is idempotent: rescans can only move progress forward.
    for _, def in ipairs(BA.Challenges or {}) do
        if def.activityType == "RAID_ACHIEVEMENT" then
            BA.Transaction:SetProgressAtLeast(def, stats.raid, "LEGACY_ESO_ACHIEVEMENT")
        elseif def.activityType == "DUNGEON_ACHIEVEMENT" then
            BA.Transaction:SetProgressAtLeast(def, stats.dungeon, "LEGACY_ESO_ACHIEVEMENT")
        end
    end

    local mapped = 0
    for _, mapping in ipairs(BA.LegacyAchievements or {}) do
        local record = nil
        if mapping.achievementId then record = completed[mapping.achievementId] end
        if not record and mapping.canonicalName then record = byName[normalizedText(mapping.canonicalName)] end
        if record then
            mapped = mapped + 1
            local def = BA.ChallengeIndex.byId and BA.ChallengeIndex.byId[mapping.challengeId]
            if def then BA.Transaction:CompleteChallenge(def, "LEGACY_ESO_ACHIEVEMENT", false) end
            BA.account.legacyImport.mappedIds = BA.account.legacyImport.mappedIds or {}
            BA.account.legacyImport.mappedIds[mapping.challengeId] = record.id
        end
    end

    BA.account.legacyImport.completed = true
    BA.account.legacyImport.mapped = mapped
    BA.account.profileRevision = (BA.account.profileRevision or 0) + 1
    BA.Diagnostics:Record("LEGACY_IMPORT", string.format("completed=%d mapped=%d", stats.completed, mapped))
    BA.EventBus:Publish("PROFILE_CHANGED", { revision = BA.account.profileRevision })

    d(string.format("|cFFD700[BMG Adventures]|r Legacy import: %d ESO achievements found, %d BMG prestige mappings applied.", stats.completed, mapped))
    return true
end

function BA.LegacyImport:GetSummary()
    local li = BA.account.legacyImport or {}
    local s = li.stats or {}
    return string.format("Legacy ESO achievements: %d | Trial achievements: %d | Dungeon achievements: %d | Prestige mappings: %d",
        s.completed or 0, s.raid or 0, s.dungeon or 0, li.mapped or 0)
end
