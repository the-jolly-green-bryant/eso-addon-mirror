-- Quests Module
-- Handles quest sharing functionality including daily quests, pledges, and zone-specific quests
-- Dependencies: Message
-- Data Dependencies: NMGuildHallPledges

-- Data captured at load time (safe-by-load-order per NMGuildHall.txt)
local pled = NMGuildHallPledges

local Addon = NMGuildHall
local Constants = Addon and Addon.Constants

-- Immediate validation of data dependencies
if not pled then
    if Addon and Addon.Err then
        Addon:Err(GetString(NMGH_ERR_QUESTS_DATA_MISSING))
    end
end

-- Quests Module
local Quests = {
    initialized = false,
    -- Cache for pledge calculations
    pledgeCache = {
        lastCalculation = 0,
        results = {}
    }
}

-- Initialize the quests module
function Quests:Initialize()
    if self.initialized then
        return
    end
    
    self.initialized = true
    
    if Addon and Addon.Message then
        Addon.Message:For("Quests"):Debug(GetString(NMGH_DEBUG_QUESTS_INIT))
    end
end

-- Helper function for quest count messages with proper singular/plural
function Quests:GetQuestCountMessage(count, questType)
    questType = questType or "daily"
    if count == 0 then
        return GetString(NMGH_CHAT_NO_DAILIES_TO_SHARE)
    elseif count == 1 then
        -- Use Message system interpolation for consistency
        if Addon and Addon.Message then
            return Addon.Message:_FormatPlain(GetString(NMGH_CHAT_SHARED_SINGULAR), {
                count = count,
                questType = questType
            })
        else
            -- Fallback with proper singular/plural logic
            return "Shared 1 " .. questType .. " quest"
        end
    else
        -- Use Message system interpolation for consistency
        if Addon and Addon.Message then
            return Addon.Message:_FormatPlain(GetString(NMGH_CHAT_SHARED), {
                count = count,
                questType = questType
            })
        else
            -- Fallback with proper singular/plural logic
            return "Shared " .. count .. " " .. questType .. " quests"
        end
    end
end

-- Share all daily quests (excluding Cyrodiil and Imperial City)
function Quests:ShareAllDailies(questType)
    local questTypes = Constants and Constants.QUESTS and Constants.QUESTS.TYPES
    local targetQuestType = questType or (questTypes and questTypes.DAILY) or QUEST_REPEAT_DAILY
    local questTypeName = "daily"
    if questTypes and targetQuestType == questTypes.WEEKLY then
        questTypeName = "weekly"
    elseif questTypes and targetQuestType == questTypes.MONTHLY then
        questTypeName = "monthly"
    end
    
    if Addon then
        Addon:Msg(GetString(NMGH_CHAT_SHARING_ALL))
    end
    
    local quest_count = 0

    local function GetZoneNameByIdSafe(zoneId)
        if not (GetZoneNameById and zoneId and zoneId > 0) then
            return nil
        end
        local ok, result = pcall(GetZoneNameById, zoneId)
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
        return nil
    end

    local function IsExcludedAvAZoneName(zoneName)
        if type(zoneName) ~= "string" or zoneName == "" then
            return false
        end

        local ava = Constants and Constants.AVA
        local cyroName = ava and GetZoneNameByIdSafe(ava.CYRODIIL_ZONE_ID) or nil
        local icName = ava and GetZoneNameByIdSafe(ava.IMPERIAL_CITY_ZONE_ID) or nil

        if (cyroName and zoneName == cyroName) or (icName and zoneName == icName) then
            return true
        end

        -- Fallback for environments where the zone IDs are not available/accurate.
        return (zoneName == "Cyrodiil") or (zoneName == "Imperial City")
    end
    
    for i = 1, GetNumJournalQuests() do
        -- variables for collecting data from ESO API GetJournalQuestLocationInfo(i)
        local tZoneName = GetJournalQuestLocationInfo(i)
        
        if GetJournalQuestRepeatType(i) == targetQuestType and GetIsQuestSharable(i) then
            -- Skips sharing dailies from Cyro & IC.  
            -- Both can still be specifically shared via the zone dailies share option.
            if not IsExcludedAvAZoneName(tZoneName) then
                ShareQuest(i)
                if Addon and Addon.Message then
                    Addon:Msg(Addon.Message:_FormatPlain(GetString(NMGH_CHAT_SHARED_QUEST_ENTRY), {
                        quest = GetJournalQuestName(i)
                    }))
                elseif Addon then
                    Addon:Msg(GetString(NMGH_CHAT_SHARED_QUEST_ENTRY), {quest = GetJournalQuestName(i)})
                end
                quest_count = quest_count + 1
            end
        end
    end
    
    -- Use proper quest count message with singular/plural handling
    if Addon then
        Addon:Msg(self:GetQuestCountMessage(quest_count, questTypeName))
    end
end

-- Share daily quests for current zone
function Quests:ShareZoneDailies()
    local pZone = GetPlayerActiveZoneName()
    local zoneAliases = Constants and Constants.QUESTS and Constants.QUESTS.ZONE_ALIASES or {}
    pZone = zoneAliases[pZone] or pZone
    
    if Addon then
        Addon:Msg(GetString(NMGH_CHAT_SHARING), {zone = pZone})
        Addon:Msg(GetString(NMGH_CHAT_DAILIES_GROUP))
    end
    
    local quest_count = 0
    
    local questTypes = Constants and Constants.QUESTS and Constants.QUESTS.TYPES
    local dailyType = (questTypes and questTypes.DAILY) or QUEST_REPEAT_DAILY
    for i = 1, GetNumJournalQuests() do
        if GetJournalQuestRepeatType(i) == dailyType and GetIsQuestSharable(i) then
            local questLocation = GetJournalQuestLocationInfo(i)
            -- Use exact match instead of substring match to avoid false positives
            if questLocation == pZone then
                ShareQuest(i)
                if Addon and Addon.Message then
                    Addon:Msg(Addon.Message:_FormatPlain(GetString(NMGH_CHAT_SHARED_QUEST_ENTRY), {
                        quest = GetJournalQuestName(i)
                    }))
                elseif Addon then
                    Addon:Msg(GetString(NMGH_CHAT_SHARED_QUEST_ENTRY), {quest = GetJournalQuestName(i)})
                end
                quest_count = quest_count + 1
            end
        end
    end
    
    -- Use proper quest count message with singular/plural handling
    if Addon then
        Addon:Msg(self:GetQuestCountMessage(quest_count, "daily"))
    end
end

-- List today's pledges
function Quests:ListPledges()
    local currentTime = GetTimeStamp()
    
    -- Check cache validity (cache for 1 hour)
    if currentTime - self.pledgeCache.lastCalculation < 3600 and self.pledgeCache.results and #self.pledgeCache.results > 0 then
        -- Use cached results
        for _, result in ipairs(self.pledgeCache.results) do
            if Addon and Addon.Message then
                Addon:Msg(Addon.Message:_FormatPlain(GetString(NMGH_PLEDGES_CHAT_ENTRY), {
                    pledge = result.pledge,
                    npc = result.npc
                }))
            elseif Addon then
                Addon:Msg(GetString(NMGH_PLEDGES_CHAT_ENTRY), result)
            end
        end
        return
    end
    
    -- Calculate pledges and cache results
    if Addon then
        Addon:Msg(GetString(NMGH_PLEDGES_CHAT_DATE), {date = pled.date})
    end
    
    local pledgeConfig = Constants and Constants.QUESTS
    local originTimestamp = (pledgeConfig and pledgeConfig.PLEDGE_ORIGIN_TIMESTAMP) or 1615168800
    local secondsPerDay = (pledgeConfig and pledgeConfig.SECONDS_PER_DAY) or 86400
    local daysSinceOrigin = math.floor((currentTime - originTimestamp) / secondsPerDay)
    local npcCount = #pled.dailies
    local results = {}

    for i = 1, npcCount, 1 do
        local row = pled.dailies[i]
        local maxIds = #row

        local actualId = 1 + (daysSinceOrigin % maxIds)
        
        if pled.dailies[i] and pled.dailies[i][actualId] and pled.npcNames[i] then
            local entry = pled.dailies[i][actualId]
            local pledgeName = entry
            if type(entry) == "table" then
                pledgeName = entry[1]
            end
            
            local result = {pledge = pledgeName, npc = pled.npcNames[i]}
            table.insert(results, result)
            if Addon and Addon.Message then
                Addon:Msg(Addon.Message:_FormatPlain(GetString(NMGH_PLEDGES_CHAT_ENTRY), result))
            elseif Addon then
                Addon:Msg(GetString(NMGH_PLEDGES_CHAT_ENTRY), result)
            end
        end
    end
    
    -- Update cache
    self.pledgeCache.lastCalculation = currentTime
    self.pledgeCache.results = results
end

-- Clear all quest caches
function Quests:ClearCaches()
    self.pledgeCache = {
        lastCalculation = 0,
        results = {}
    }
    if Addon and Addon.Message then
        Addon.Message:For("Quests"):Debug(GetString(NMGH_DEBUG_ZONE_CACHE_INVALID))
    end
end

-- Cleanup for module shutdown
function Quests:Cleanup()
    self:ClearCaches()
    self.initialized = false
    if Addon and Addon.Message then
        Addon.Message:For("Quests"):Debug(GetString(NMGH_DEBUG_CLEANUP_DONE))
    end
end

-- Export quests module
NMGuildHall = NMGuildHall or {}
NMGuildHall.Quests = Quests

return Quests
