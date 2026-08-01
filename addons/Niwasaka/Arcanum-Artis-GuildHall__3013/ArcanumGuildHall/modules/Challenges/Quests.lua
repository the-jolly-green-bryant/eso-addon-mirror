local ArcanumGuildHall = _G["ArcanumGuildHall"]

local pled = ArcanumGuildHallPledges
local res = ArcanumGuildHallMediaRes

function ArcanumGuildHall:ShareAllDailies()
    local quest_count = 0

    for i = 1, GetNumJournalQuests() do
        if GetJournalQuestRepeatType(i) == QUEST_REPEAT_DAILY and GetIsQuestSharable(i) then
            ShareQuest(i)
            CHAT_ROUTER:AddSystemMessage(
                    res.IconAA .. res.Ccolor2 .. " " .. '"' .. GetJournalQuestName(i) .. '"' .. "|r"
            )
            quest_count = quest_count + 1
        end
    end

    if quest_count == 0 then
        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. res.Ccolor3 .. " " .. ArcanumGuildHall.GetDefaultLocaleString("CHAT_NO_DAILIES_TO_SHARE") .. "|r"
        )
    else
        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. res.Ccolor1 .. " "
                        .. zo_strformat(ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHARING_ALL"), quest_count)
                        .. "|r"
        )

        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. res.Ccolor1 .. " "
                        .. zo_strformat(ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHARED"), quest_count)
                        .. "|r"
        )
    end
end

function ArcanumGuildHall:ShareZoneDailies()
    local pZone = GetPlayerActiveZoneName()
    local quest_count = 0

    for i = 1, GetNumJournalQuests() do
        if GetJournalQuestRepeatType(i) == QUEST_REPEAT_DAILY and GetIsQuestSharable(i) then
            local location = GetJournalQuestLocationInfo(i)

            if location and string.find(location, pZone, 1, true) then
                ShareQuest(i)
                CHAT_ROUTER:AddSystemMessage(
                        res.IconAA .. res.Ccolor2 .. " " .. '"' .. GetJournalQuestName(i) .. '"' .. "|r"
                )
                quest_count = quest_count + 1
            end
        end
    end

    if quest_count == 0 then
        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. res.Ccolor3 .. " " .. ArcanumGuildHall.GetDefaultLocaleString("CHAT_NO_DAILIES_TO_SHARE") .. "|r"
        )
    else
        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. res.Ccolor1 .. " "
                        .. zo_strformat(ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHARING"), pZone)
                        .. "|r"
        )

        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. res.Ccolor1 .. " "
                        .. zo_strformat(ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHARED"), quest_count)
                        .. "|r"
        )
    end
end

function ArcanumGuildHall:ListPledges(sendToChat)
    local text = ""

    if not sendToChat then
        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. res.Ccolor1 .. " "
                        .. ArcanumGuildHall.GetDefaultLocaleString("PLEDGES_CHAT_DATE")
                        .. (pled.date or "") .. ": "
        )
    end

    local elapsedDays = math.floor((os.time() - 1615168800) / 86400)
    local npcCount = #pled.dailies

    for i = 1, npcCount do
        local row = pled.dailies[i]
        local maxIds = row and #row or 0

        if maxIds > 0 then
            local actualId = (elapsedDays % maxIds) + 1
            local pledgeName = row[actualId][1]
            local line = res.Ccolor2 .. pledgeName .. " - " .. pled.npcNames[i]

            if not sendToChat then
                CHAT_ROUTER:AddSystemMessage(line)
            else
                if text ~= "" then
                    text = text .. " - "
                end

                text = text .. pledgeName
            end
        end
    end

    return text
end

function ArcanumGuildHall:SendPledgesToChat()
    local pledgeText = self:ListPledges(true)

    if pledgeText and pledgeText ~= "" then
        StartChatInput(pledgeText)
    end
end

function ArcanumGuildHall:ListTrialAndChallengeWeeklies(sendToChat)
    local text = ""

    local _, trialRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_TRIAL)
    local trialName = trialRaidId and GetRaidLeaderboardName(trialRaidId) or ""

    local _, soloRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_CHALLENGE)
    local challengeName = soloRaidId and GetRaidLeaderboardName(soloRaidId) or ""

    if not sendToChat then
        CHAT_ROUTER:AddSystemMessage(
                res.IconAA .. " " .. res.Ccolor1 .. ArcanumGuildHall.GetDefaultLocaleString("WEEKLY_CHALLENGES_TITLE")
        )
    end

    if trialName and trialName ~= "" then
        local line = res.Ccolor8 .. ArcanumGuildHall.GetDefaultLocaleString("WEEKLY_CHALLENGES_TRIAL") .. res.Ccolor2 .. trialName

        if not sendToChat then
            CHAT_ROUTER:AddSystemMessage(line)
        else
            text = line
        end
    end

    if challengeName and challengeName ~= "" then
        local line = res.Ccolor8 .. ArcanumGuildHall.GetDefaultLocaleString("WEEKLY_CHALLENGES_SOLO") .. res.Ccolor2 .. challengeName

        if not sendToChat then
            CHAT_ROUTER:AddSystemMessage(line)
        else
            if text ~= "" then
                text = text .. " - "
            end

            text = text .. line
        end
    end

    return text
end