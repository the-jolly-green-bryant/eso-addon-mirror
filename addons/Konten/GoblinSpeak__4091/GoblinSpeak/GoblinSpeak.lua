local GoblinSpeak = {}

GoblinSpeak.name = "GoblinSpeak"
GoblinSpeak.enabled = false

local PERSONALITY_ID = 5218
local GOBLIN_ITEM_ID = 54994
local SAYING_COOLDOWN_MS = 1000
local suppressNext = false
local lastSayTime = 0

local goblinOnMessages = {
    "Shinies on! Tongue go wibbly now!",
    "Let’s scream 'em! You goblin-talkin', nowz!",
    "Goblin mode: ON. Hope mouth ready.",
}

local goblinOffMessages = {
    "Bah! Goblin tongue go poof... Goblin no like!",
    "No more shiny! Mouth boring again!",
    "Goblin gone... Smoothskin voice return. Ew.",
}

local greetings = {
    ["heya"] = true, ["hi"] = true, ["hey"] = true,
    ["yo"] = true, ["sup"] = true, ["hello"] = true
}

local function printGoblinOn()
    d("[GoblinSpeak] " .. goblinOnMessages[math.random(#goblinOnMessages)])
end

local function printGoblinOff()
    d("[GoblinSpeak] " .. goblinOffMessages[math.random(#goblinOffMessages)])
end

local function canSayNow()
    local now = GetGameTimeMilliseconds()
    if now - lastSayTime > SAYING_COOLDOWN_MS then
        lastSayTime = now
        return true
    end
    return false
end

local function CheckIfGoblinItemEquipped()
    for slotId = 0, 14 do
        local itemLink = GetItemLink(BAG_WORN, slotId)
        if itemLink ~= "" and GetItemLinkItemId(itemLink) == GOBLIN_ITEM_ID then
            return true
        end
    end
    return false
end

local function getRoleSpecificSaying(role)
    if role == "tank" and GoblinTankSayings then
        return getSayingWithFillers(GoblinTankSayings)
    elseif role == "healer" and GoblinHealerSayings then
        return getSayingWithFillers(GoblinHealerSayings)
    elseif role == "dps" and GoblinDpsSayings then
        return getSayingWithFillers(GoblinDpsSayings)
    end
    return nil
end

local function splitWords(str)
    local words = {}
    for word in str:gmatch("%S+") do
        table.insert(words, word)
    end
    return words
end

local function fillWordsWithRandoms(words)
    if not GoblinRandomFillers then return end
    if math.random() < 0.4 then table.insert(words, 1, GoblinRandomFillers[math.random(#GoblinRandomFillers)]) end
    if math.random() < 0.4 then table.insert(words, GoblinRandomFillers[math.random(#GoblinRandomFillers)]) end
end

local function getSayingWithFillers(list)
    if not list or #list == 0 then return nil end
    local saying = list[math.random(#list)]
    local words = splitWords(saying)
    fillWordsWithRandoms(words)
    return table.concat(words, " ")
end

local function getSayingWithNameAndFillers(list, name)
    name = name or "someone"
    if not list or #list == 0 then return nil end
    local saying = list[math.random(#list)]:gsub("{{name}}", name)
    local words = splitWords(saying)
    fillWordsWithRandoms(words)
    return table.concat(words, " ")
end

local function CheckBosses()
    for i = 1, 6 do
        local tag = "boss" .. i
        if DoesUnitExist(tag) then
            return GetUnitName(tag)
        end
    end
    return nil
end

local function GetPlayerRole()
    local role = GetGroupMemberAssignedRole("player")
    if role == LFG_ROLE_TANK then return "tank"
    elseif role == LFG_ROLE_HEAL then return "healer"
    elseif role == LFG_ROLE_DPS then return "dps"
    else return nil end
end

local function GetPlayerRoleName(unitTag)
    local role = GetGroupMemberAssignedRole(unitTag)
    if role == LFG_ROLE_TANK then return "Tank"
    elseif role == LFG_ROLE_HEAL then return "Healer"
    elseif role == LFG_ROLE_DPS then return "DPS"
    else return "Unknown" end
end

local function getZoneGoblinSaying()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local stealthState = GetUnitStealthState("player")
    local isDead = IsUnitDead("player")
    local isInCombat = IsUnitInCombat("player")
    local trialSayings = GoblinTrialSayings and GoblinTrialSayings[zoneId]
    local role = GetPlayerRole()

    if isDead then
        return getSayingWithFillers(GoblinDeathSayings)
    end

    for i = 1, GetGroupSize() do
        local unitTag = "group" .. i
        if unitTag ~= "player" and DoesUnitExist(unitTag) and IsUnitDead(unitTag) then
            local name = GetUnitName(unitTag)
            if name then
                local roleName = GetPlayerRoleName(unitTag)
                if roleName == "Unknown" then break end
                return getSayingWithNameAndFillers(GoblinOthersDeathSayings, name)
            end
        end
    end

    local bossName = CheckBosses()
    if bossName and GoblinBossSayings and #GoblinBossSayings > 0 then
        if math.random(1, 2) == 1 then
            local roleLine = getRoleSpecificSaying(role)
            if roleLine then return roleLine end
        end
        local saying = GoblinBossSayings[math.random(#GoblinBossSayings)]:gsub("{{bossName}}", bossName)
        local words = splitWords(saying)
        fillWordsWithRandoms(words)
        return table.concat(words, " ")
    elseif bossName then
        return getSayingWithFillers({ "Big boss! No good! urk!" })
    end

    if stealthState == STEALTH_STATE_HIDDEN then
        return getSayingWithFillers(GoblinStealthSayings)
    elseif stealthState == STEALTH_STATE_DETECTED then
        return getSayingWithFillers(GoblinDetectedSayings)
    end

    if trialSayings then
        local roleLine = getRoleSpecificSaying(role)
        if math.random(1, 2) == 1 and roleLine then return roleLine end
        return getSayingWithFillers(trialSayings)
    end

    if isInCombat then
        local roleLine = getRoleSpecificSaying(role)
        if math.random(1, 2) == 1 and roleLine then return roleLine end
        return getSayingWithFillers(GoblinCombatSayings)
    end

    return getSayingWithFillers(GoblinSayings)
end

local function TranslateToGoblin(text)
    local lowerText = text:lower():gsub("%p", "")
    if greetings[lowerText] then
        return GoblinDictionary["greetings"][math.random(#GoblinDictionary["greetings"])]
    end

    local output = {}
    for word in text:gmatch("%S+") do
        if word:sub(1, 1) == "@" then
            table.insert(output, word)
        else
            local body = word:match("^(%a+)")
            local punctuation = word:match("(%p+)$") or ""
            local cleaned = (body or word):lower()
            local replacement = GoblinDictionary and GoblinDictionary[cleaned]

            if replacement then
                table.insert(output, replacement .. punctuation)
            else
                table.insert(output, word)
                if math.random(1, 3) == 1 then
                    table.insert(output, GoblinRandomFillers[math.random(#GoblinRandomFillers)])
                end
            end
        end
    end

    fillWordsWithRandoms(output)
    return table.concat(output, " ")
end

local function sendGoblinMessage(text)
    StartChatInput(text)
end

local function HookChatEntry()
    if not ZO_ChatTextEntry_Execute then
        d("[GoblinSpeak] Error: Chat entry hook unavailable.")
        return
    end

    ZO_PreHook("ZO_ChatTextEntry_Execute", function()
        if suppressNext then
            suppressNext = false
            return false
        end

        if not GoblinSpeak.enabled then return false end

        local editBox = CHAT_SYSTEM.textEntry.editControl
        local text = editBox:GetText()

        if text == "" and canSayNow() then
            suppressNext = true
            zo_callLater(function()
                sendGoblinMessage(getZoneGoblinSaying())
            end, 10)
            return true
        end

        if text:sub(1, 1):match("^[/%%|]") then return false end

        local goblinText = TranslateToGoblin(text)
        if goblinText ~= text then
            suppressNext = true
            zo_callLater(function()
                sendGoblinMessage(goblinText)
            end, 10)
            return true
        end

        return false
    end)
end

local function OnInventoryChange(_, bagId, slotId)
    zo_callLater(function()
        local equipped = CheckIfGoblinItemEquipped()

        if equipped and not GoblinSpeak.enabled then
            GoblinSpeak.enabled = true
            GoblinSpeak.savedVars.goblinEnabled = true

            local currentPersonality = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)
			GoblinSpeak.savedVars.previousPersonalityId = currentPersonality

            printGoblinOn()
            if IsCollectibleUnlocked(PERSONALITY_ID) then
                if currentPersonality ~= PERSONALITY_ID then
                    UseCollectible(PERSONALITY_ID)
                end
            end

        elseif not equipped and GoblinSpeak.enabled then
            GoblinSpeak.enabled = false
            GoblinSpeak.savedVars.goblinEnabled = false
            printGoblinOff()

            local current = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)
            if current == PERSONALITY_ID then
				local previousId = GoblinSpeak.savedVars.previousPersonalityId
				if previousId and previousId ~= PERSONALITY_ID and IsCollectibleUnlocked(previousId) then
					UseCollectible(previousId)
				end
				GoblinSpeak.savedVars.previousPersonalityId = nil
			end
        end
    end, 100)
end

EVENT_MANAGER:RegisterForEvent(GoblinSpeak.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == GoblinSpeak.name then
        GoblinSpeak.savedVars = ZO_SavedVars:NewCharacterIdSettings("GoblinSpeakSaved", 1, nil, {
			goblinEnabled = false,
			previousPersonalityId = nil
		})

        EVENT_MANAGER:RegisterForEvent(GoblinSpeak.name, EVENT_PLAYER_ACTIVATED, function()
            HookChatEntry()

            local equipped = CheckIfGoblinItemEquipped()
            if equipped then
                if not GoblinSpeak.enabled then
                    GoblinSpeak.enabled = true
                    printGoblinOn()
                    if IsCollectibleUnlocked(PERSONALITY_ID) then
                        if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY) ~= PERSONALITY_ID then
                            UseCollectible(PERSONALITY_ID)
                        end
                    end
                end
                GoblinSpeak.savedVars.goblinEnabled = true
            else
                GoblinSpeak.savedVars.goblinEnabled = false
            end

            EVENT_MANAGER:UnregisterForEvent(GoblinSpeak.name, EVENT_PLAYER_ACTIVATED)
        end)

        EVENT_MANAGER:RegisterForEvent(GoblinSpeak.name .. "_ItemCheck", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChange)
    end
end)
