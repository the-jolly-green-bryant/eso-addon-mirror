-- CharacterMarkdown - Quests Data Collector
-- Composition logic moved from API layer
-- Includes Undaunted Pledges (moved from separate collector)

local CM = CharacterMarkdown

-- =====================================================
-- QUEST JOURNAL
-- =====================================================

local function CollectQuestJournalData()
    -- Use API layer granular functions (composition at collector level)
    -- Get zoneIndex from Character API to pass to Quests API
    local locationInfo = CM.api.character.GetLocation()
    local zoneIndex = locationInfo.zoneIndex

    local journalInfo = CM.api.quests.GetJournalInfo()
    local zoneCompletion = CM.api.quests.GetZoneCompletion(zoneIndex)

    local quests = {}

    -- Transform API data to expected format (backward compatibility)
    quests.active = journalInfo or {}
    quests.zone = zoneCompletion or {}

    -- Add computed fields
    quests.summary = {
        activeCount = journalInfo and #journalInfo or 0,
        zoneCompletion = zoneCompletion and zoneCompletion.percent or 0,
        activeQuests = journalInfo and #journalInfo or 0,
    }

    return quests
end

CM.collectors.CollectQuestJournalData = CollectQuestJournalData

-- =====================================================
-- UNDAUNTED PLEDGES
-- =====================================================

local function CollectUndauntedPledgesData()
    -- Use API layer granular functions (composition at collector level)
    -- Active pledges are quests, so get them from quest journal API (cross-API composition)
    local journalInfo = CM.api.quests.GetJournalInfo()
    local active = {}

    -- Filter quest journal for pledges (cross-API composition)
    if journalInfo then
        for _, quest in ipairs(journalInfo) do
            -- Handle case where quest.name might be a boolean or other non-string type
            local questName = nil
            if quest.name and type(quest.name) == "string" then
                questName = quest.name
            end

            -- Only process if we have a valid string name
            if questName and questName:lower():find("pledge") then
                local stepText = ""
                if quest.stepText and type(quest.stepText) == "string" then
                    stepText = quest.stepText
                end

                table.insert(active, {
                    name = questName,
                    location = stepText,
                    index = quest.index,
                })
            end
        end
    end

    -- Get pledge-specific data from UndauntedPledges API
    local daily = CM.api.undauntedPledges.GetDailyPledges()
    local weekly = CM.api.undauntedPledges.GetWeeklyPledges()
    local keys = CM.api.undauntedPledges.GetPledgeKeys()
    local dungeonProgress = CM.api.undauntedPledges.GetDungeonProgress()
    local undauntedKeys = CM.api.undauntedPledges.GetUndauntedKeys()

    local data = {}

    -- Transform API data to expected format (backward compatibility)
    data.active = active

    data.daily = {
        normal = daily.normal or {},
        veteran = daily.veteran or {},
        keys = keys.daily or 0,
    }

    data.weekly = {
        normal = weekly.normal or {},
        veteran = weekly.veteran or {},
        keys = keys.weekly or 0,
    }

    -- Calculate progress
    local progress = {
        totalCompleted = 0,
        totalAvailable = 0,
    }

    for _, pledge in ipairs(data.daily.normal) do
        progress.totalAvailable = progress.totalAvailable + 1
        if pledge.completed then
            progress.totalCompleted = progress.totalCompleted + 1
        end
    end
    for _, pledge in ipairs(data.daily.veteran) do
        progress.totalAvailable = progress.totalAvailable + 1
        if pledge.completed then
            progress.totalCompleted = progress.totalCompleted + 1
        end
    end
    for _, pledge in ipairs(data.weekly.normal) do
        progress.totalAvailable = progress.totalAvailable + 1
        if pledge.completed then
            progress.totalCompleted = progress.totalCompleted + 1
        end
    end
    for _, pledge in ipairs(data.weekly.veteran) do
        progress.totalAvailable = progress.totalAvailable + 1
        if pledge.completed then
            progress.totalCompleted = progress.totalCompleted + 1
        end
    end

    data.progress = progress
    data.dungeonProgress = dungeonProgress or {}
    data.keys = undauntedKeys or {}

    return data
end

CM.collectors.CollectUndauntedPledgesData = CollectUndauntedPledgesData

CM.DebugPrint("COLLECTOR", "Quests collector module loaded")
