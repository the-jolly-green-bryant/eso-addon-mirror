CountessTravel = {
    name            = "CountessTravel",
    author          = "Redeven",
    color           = "FF0000",
    menuName        = "Red's Countess Travel",
}
CountessTravel.savedVars = {
    firstLoad = true,
    accountWide = false,
}

function CountessTravel.Colorize(text, color)
    if not color then color = CountessTravel.color end
    text = string.format('|c%s%s|r', color, text)
    return text
end

function CountessTravel.FindQuestWayshrine(questText)
    if questText == nil then return end
    local wayshrines = {
        [28] = 'Mournhold',
        [33] = 'Evermore',
        [43] = 'Sentinel',
        [48] = 'Stormhold',
        [55] = 'Shornhelm',
        [56] = 'Wayrest',
        [62] = 'Daggerfall',
        [65] = 'Davon\'s Watch',
        [87] = 'Windhelm',
        [106] = 'Baandari Trading Post',
        [109] = 'Riften',
        [143] = 'Marbruk',
        [162] = 'Rawl\'kha',
        [177] = 'Vulkhel Guard',
        [214] = 'Elden Root',
        [255] = 'Thieves Den'
    }
    for key, value in pairs(wayshrines) do
        if string.match(questText, value) then
            return key
        end
    end
    return nil
end

function CountessTravel.GetQuestText()
    local count = GetNumJournalQuests()
    for i = 1, count do
        local name = GetJournalQuestName(i)
        if name == 'The Covetous Countess' then
            local count = GetJournalQuestNumSteps(i)
            for j = 1, count do
                local function isEmpty(s)
                    return s == nil or s == ''
                end
                local journalText, _, _, hudText, _ = GetJournalQuestStepInfo(i, j)
                if isEmpty(hudText) then
                    return journalText
                else
                    return hudText
                end
            end
        end
    end
    return nil
end

function CountessTravel.TravelToWayshrine()
    local questText = CountessTravel.GetQuestText()
    local wayshrineId = CountessTravel.FindQuestWayshrine(questText)
    if wayshrineId then
        local discovered, name = GetFastTravelNodeInfo(wayshrineId)
        if not discovered then
            d(name .. ' not discovered.')
            return
        else
            if CountessTravel.savedVars.chatOutput == true then
                d('Teleporting to ' .. name)
            end
            FastTravelToNode(wayshrineId)
        end
    end
end

function CountessTravel.OnFastTravelInteraction()
    if CountessTravel.savedVars.automaticTraveling == true then
        CountessTravel.TravelToWayshrine()
    end
end
EVENT_MANAGER:RegisterForEvent(CountessTravel.name, EVENT_START_FAST_TRAVEL_INTERACTION, function(eventId, ...) CountessTravel.OnFastTravelInteraction(...) end)

local LastItemClicked
ZO_PreHook(RETICLE, "TryHandlingInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	LastItemClicked = name
end)
function CountessTravel.FindCountessQuest(interaction)
    if CountessTravel.savedVars.questFiltering == true then        
        if GetZoneId(GetUnitZoneIndex("player")) ~= 821 then
            return
        end
        if LastItemClicked == "Tip Board" or LastItemClicked == "Brett für Aufträge" then
            local offeredText = string.sub(GetOfferedQuestInfo(), 2, 17)
            local matchFound = false
            local textBlocks = { "Esteemed thieves", "„Hochgeschätzt", "Some new faces a", "„Es gibt ein pa" }
            for text = 1, 4 do
                if string.find(textBlocks[text], offeredText) then
                    matchFound = true
                    break
                end
            end
            if not matchFound then
                interaction:CloseChatter()
            end
            LastItemClicked = nil
        end
	end
end
EVENT_MANAGER:RegisterForEvent(CountessTravel.name, EVENT_QUEST_OFFERED, function() CountessTravel.FindCountessQuest(INTERACTION) end)

function CountessTravel.OnAddOnLoaded(event, addonName)
    if addonName ~= CountessTravel.name then return end
    EVENT_MANAGER:UnregisterForEvent(CountessTravel.name, EVENT_ADD_ON_LOADED)
    CountessTravel.savedVars = ZO_SavedVars:New("CountessTravelSavedVariables", 1, nil, CountessTravel.savedVars)
    CountessTravel.LoadSettings()
end
EVENT_MANAGER:RegisterForEvent(CountessTravel.name, EVENT_ADD_ON_LOADED, CountessTravel.OnAddOnLoaded)