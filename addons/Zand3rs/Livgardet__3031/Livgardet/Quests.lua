local pled = LivgardetPledges
local res = LivgardetMediaRes

function Livgardet:ShareAllDailies()
    CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_CHAT_SHARING_ALL) .. "|r")
    local quest_count = 0
    for i = 1, GetNumJournalQuests() do
        if GetJournalQuestRepeatType(i) == QUEST_REPEAT_DAILY and GetIsQuestSharable(i) then
            ShareQuest(i)
            CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor2 .. " " .. '"' .. GetJournalQuestName(i) .. '"' .. "|r")
            quest_count = quest_count + 1
        end
    end
    if quest_count == 0 then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor3 .. " " .. GetString(LIVGARDET_NO_QUESTS_TO_SHARE) .. "|r")
    end
    if quest_count >= 1 then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_CHAT_SHARED) .. " " .. quest_count .. "|r")
    end
end

function Livgardet:ShareZoneDailies()
    local pZone = GetPlayerActiveZoneName()
    CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_CHAT_SHARING) .. '"' .. pZone .. '"' .. GetString(LIVGARDET_CHAT_DAILIES_GROUP) .. "|r")
    local quest_count = 0
    for i = 1, GetNumJournalQuests() do
        if GetJournalQuestRepeatType(i) == QUEST_REPEAT_DAILY and GetIsQuestSharable(i) then
            if string.find(GetJournalQuestLocationInfo(i), pZone) then
                ShareQuest(i)
                CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor2 .. " " .. '"' .. GetJournalQuestName(i) .. '"' .. "|r")
                quest_count = quest_count + 1
            end
        end
    end
    if quest_count == 0 then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor3 .. " " .. GetString(LIVGARDET_CHAT_NO_DAILIES_TO_SHARE) .. "|r")
    end
    if quest_count >= 1 then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_CHAT_SHARED) .. " " .. quest_count .. "|r")
    end
end

function Livgardet:ListPledges()
    CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_PLEDGES_CHAT_DATE) .. pled.date .. ": ")
    local daysSinceOrigin = (os.time() - 1615183200) / 60 / 60 / 24; -- 08.03.2021 7:00 UTC
    local npcCount = #pled.dailies

    for i = 1, npcCount, 1 do
        local row = pled.dailies[i]
        local maxIds = #row

        local actualIdF = 1 + daysSinceOrigin % maxIds
        --local followingIdF = 1 + (daysSinceOrigin + 1) % maxIds

        local actualId = math.floor(actualIdF)
        --local followingId = math.floor(followingIdF)

        CHAT_ROUTER:AddSystemMessage(res.Ccolor2 .. pled.dailies[i][actualId][1] .. " " .. "-" .. " " .. pled.npcNames[i])
        --d("Heute: " .. pled.dailies[i][actualId][1])
        --d("Morgen: " .. pled.dailies[i][followingId][1])

    end
end
