-- CharacterMarkdown - API Layer - Quests
-- Abstraction for quest journal and zone completion

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.quests = {}

local api = CM.api.quests

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

local function GetQuestTypeLabel(questType)
    if questType == nil then
        return "Side Quest"
    end

    if QUEST_TYPE_MAIN_STORY and questType == QUEST_TYPE_MAIN_STORY then
        return "Main Quest"
    elseif QUEST_TYPE_GUILD and questType == QUEST_TYPE_GUILD then
        return "Guild Quest"
    elseif QUEST_TYPE_DUNGEON and questType == QUEST_TYPE_DUNGEON then
        return "Dungeon Quest"
    elseif QUEST_TYPE_GROUP and questType == QUEST_TYPE_GROUP then
        return "Group Quest"
    elseif QUEST_TYPE_RAID and questType == QUEST_TYPE_RAID then
        return "Raid Quest"
    elseif QUEST_TYPE_AVA and questType == QUEST_TYPE_AVA then
        return "PvP Quest"
    elseif QUEST_TYPE_AVA_GROUP and questType == QUEST_TYPE_AVA_GROUP then
        return "PvP Quest"
    elseif QUEST_TYPE_AVA_GRAND and questType == QUEST_TYPE_AVA_GRAND then
        return "PvP Quest"
    elseif QUEST_TYPE_BATTLEGROUND and questType == QUEST_TYPE_BATTLEGROUND then
        return "PvP Quest"
    elseif QUEST_TYPE_CRAFTING and questType == QUEST_TYPE_CRAFTING then
        return "Crafting Quest"
    elseif QUEST_TYPE_COMPANION and questType == QUEST_TYPE_COMPANION then
        return "Companion Quest"
    elseif QUEST_TYPE_HOLIDAY_EVENT and questType == QUEST_TYPE_HOLIDAY_EVENT then
        return "Event Quest"
    elseif QUEST_TYPE_UNDAUNTED_PLEDGE and questType == QUEST_TYPE_UNDAUNTED_PLEDGE then
        return "Daily Quest"
    elseif QUEST_TYPE_CLASS and questType == QUEST_TYPE_CLASS then
        return "Class Quest"
    elseif QUEST_TYPE_PROLOGUE and questType == QUEST_TYPE_PROLOGUE then
        return "Main Quest"
    end

    return "Side Quest"
end

local function GetQuestZoneName(journalQuestIndex)
    local zoneName = ""

    if GetJournalQuestZoneStoryZoneId and GetZoneNameById then
        local zoneId = CM.SafeCall(GetJournalQuestZoneStoryZoneId, journalQuestIndex)
        if zoneId and zoneId > 0 then
            zoneName = CM.SafeCall(GetZoneNameById, zoneId) or ""
        end
    end

    if zoneName == "" and GetJournalQuestId and GetQuestZoneId and GetZoneNameById then
        local questId = CM.SafeCall(GetJournalQuestId, journalQuestIndex)
        if questId and questId > 0 then
            local questZoneId = CM.SafeCall(GetQuestZoneId, questId)
            if questZoneId and questZoneId > 0 then
                zoneName = CM.SafeCall(GetZoneNameById, questZoneId) or ""
            end
        end
    end

    return zoneName
end

function api.GetJournalInfo()
    local numQuests = CM.SafeCall(GetNumJournalQuests) or 0
    local quests = {}

    for i = 1, numQuests do
        local success, name, bgText, stepText, stepType, override, completed, tracked, level, pushed, questType =
            CM.SafeCallMulti(GetJournalQuestInfo, i)
        if success and name and type(name) == "string" then
            local typeLabel = GetQuestTypeLabel(questType)
            local zoneName = GetQuestZoneName(i)

            table.insert(quests, {
                index = i,
                name = name,
                level = level,
                stepText = stepText,
                activeStepText = stepText,
                type = typeLabel,
                zone = zoneName,
                isTracked = tracked,
                isCompleted = completed,
            })
        end
    end

    return quests
end

-- zoneIndex: Required parameter - must be passed from collector level
function api.GetZoneCompletion(zoneIndex)
    -- Basic Zone Guide / Map Completion data
    if not zoneIndex then
        return {
            zoneIndex = nil,
            percent = 0,
        }
    end

    local completionPercent = 0

    if zoneIndex then
        -- Some API versions support GetZoneCompletionStatus
        if GetZoneCompletionStatus then
            completionPercent = CM.SafeCall(GetZoneCompletionStatus, zoneIndex) or 0
        end
    end

    return {
        zoneIndex = zoneIndex,
        percent = completionPercent,
    }
end

-- Composition functions moved to collector level
