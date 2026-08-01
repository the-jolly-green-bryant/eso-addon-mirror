QuestSkipper = QuestSkipper or {}
QuestSkipper.Name = "QuestSkipper"
QuestSkipper.Version = "1.4.0"
QuestSkipper.HorseSkillsMap = {
    ["Speed"] = RIDING_TRAIN_SPEED,
    ["Stamina"] = RIDING_TRAIN_STAMINA,
    ["Capacity"] = RIDING_TRAIN_CARRYING_CAPACITY
}
--making it a dict so that lookup is faster
QuestSkipper.OptionsWhitelist = {
    --usually the first dialogue options when a conversation has started
    [CHATTER_START_TALK] = true,
    --just a common phrase
    [CHATTER_TALK_CHOICE] = true,
    --accepting quest
    [CHATTER_START_NEW_QUEST_BESTOWAL] = true,
    --completing quest
    [CHATTER_START_COMPLETE_QUEST] = true
}

function QuestSkipper:ToggleDialogues()
    QuestSkipper.SavedVariables.SkipDialogues = not QuestSkipper.SavedVariables.SkipDialogues
    d('Dialogue skip is now ' .. (QuestSkipper.SavedVariables.SkipDialogues and 'enabled' or 'disabled') .. '.')
end

function QuestSkipper.ShowBook()
    if QuestSkipper.SavedVariables.SkipBooks then
        EndInteraction(INTERACTION_BOOK)
    end
end

function QuestSkipper.ConversationUpdated(eventCode, bodyText, optionCount)
    QuestSkipper.ChatterBegin(eventCode, optionCount)
end

function QuestSkipper.ChatterBegin(eventCode, optionCount)
    if (QuestSkipper.SavedVariables.SkipDialogues and (optionCount == 0)) then
        --end dialogue if we have nothing to say to an NPC
        EndInteraction(INTERACTION_CONVERSATION)
    end
    
    local allOptionsAreChosenBefore = true
    
    for i = 1, optionCount do
        local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(i)
        allOptionsAreChosenBefore = allOptionsAreChosenBefore and chosenBefore
        --d(optionCount .. ' ' .. optionString .. ' ' .. optionType .. ' ' .. optionalArgument .. ' ' .. tostring(isImportant) .. ' ' .. tostring(chosenBefore))

        if ((optionType == CHATTER_START_STABLE) and (QuestSkipper.SavedVariables.SkipStableTraining)) then
            SelectChatterOption(i)
            --Will train skills in order
            --TrainRiding will not work for a skill that's already at max, thus it's possible to simply bruteforce the "next" skill
            for skill in string.gmatch(QuestSkipper.SavedVariables.HorseSkillsOrder, "[^\n]+") do
                TrainRiding(QuestSkipper.HorseSkillsMap[skill])
            end
            EndInteraction(INTERACTION_CONVERSATION)
            break
        end
        
        if
        QuestSkipper.SavedVariables.SkipDialogues and
        (not chosenBefore) and
        --the choice isn't in red text (important)
        ((not isImportant) or QuestSkipper.SavedVariables.SkipImportantChoices) and
        --this option type is in a whitelist
        (QuestSkipper.OptionsWhitelist[optionType] ~= nil)
        then
            SelectChatterOption(i)
            return
        end
    end
   
    if QuestSkipper.SavedVariables.SkipDialogues and allOptionsAreChosenBefore then
        --end dialogue if we exhausted all the options
        EndInteraction(INTERACTION_CONVERSATION)
    end
end

function QuestSkipper.QuestComplete(eventCode)
    if (QuestSkipper.SavedVariables.SkipDialogues) then
        CompleteQuest()
    end
end

function QuestSkipper.QuestOffered(eventCode)
    if (QuestSkipper.SavedVariables.SkipDialogues) then
        AcceptOfferedQuest()
        EndInteraction(INTERACTION_CONVERSATION)
    end
end

function QuestSkipper.OnAddOnLoaded(event, addonName)
    if addonName ~= QuestSkipper.Name then return end

    QuestSkipper.InitSavedVariables()
    QuestSkipper.InitSettings()
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_QUEST_OFFERED, QuestSkipper.QuestOffered)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_QUEST_COMPLETE_DIALOG, QuestSkipper.QuestComplete)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_CHATTER_BEGIN, QuestSkipper.ChatterBegin)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_CONVERSATION_UPDATED, QuestSkipper.ConversationUpdated)
    EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_SHOW_BOOK, QuestSkipper.ShowBook)
    EVENT_MANAGER:UnregisterForEvent(QuestSkipper.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(QuestSkipper.Name, EVENT_ADD_ON_LOADED, QuestSkipper.OnAddOnLoaded)
