ChatSkipper = ChatSkipper or {}
ChatSkipper.Name = "ChatSkipper"
ChatSkipper.Version = "1.0"

ChatSkipper.OptionsWhitelist = {
    [CHATTER_START_TALK] = true,
    [CHATTER_TALK_CHOICE] = true,
    [CHATTER_START_NEW_QUEST_BESTOWAL] = true,
    [CHATTER_START_COMPLETE_QUEST] = true
}

function ChatSkipper:ToggleDialogues()
    ChatSkipper.SavedVariables.SkipDialogues = not ChatSkipper.SavedVariables.SkipDialogues
    d('Dialogue skip is now ' .. (ChatSkipper.SavedVariables.SkipDialogues and 'enabled' or 'disabled') .. '.')
end

function ChatSkipper.ShowBook()
    if ChatSkipper.SavedVariables.SkipBooks then
        EndInteraction(INTERACTION_BOOK)
    end
end

function ChatSkipper.ConversationUpdated(eventCode, bodyText, optionCount)
    ChatSkipper.ChatterBegin(eventCode, optionCount)
end

function ChatSkipper.ChatterBegin(eventCode, optionCount)
    if (ChatSkipper.SavedVariables.SkipDialogues and (optionCount == 0)) then
        EndInteraction(INTERACTION_CONVERSATION)
    end
    
    local allOptionsAreChosenBefore = true
    
    for i = 1, optionCount do
        local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(i)
        allOptionsAreChosenBefore = allOptionsAreChosenBefore and chosenBefore
        --d(optionCount .. ' ' .. optionString .. ' ' .. optionType .. ' ' .. optionalArgument .. ' ' .. tostring(isImportant) .. ' ' .. tostring(chosenBefore))

        
        if
        ChatSkipper.SavedVariables.SkipDialogues and
        (not chosenBefore) and
        ((not isImportant) or ChatSkipper.SavedVariables.SkipImportantChoices) and
        (ChatSkipper.OptionsWhitelist[optionType] ~= nil)
        then
            SelectChatterOption(i)
            return
        end
    end
   
    if ChatSkipper.SavedVariables.SkipDialogues and allOptionsAreChosenBefore then
        EndInteraction(INTERACTION_CONVERSATION)
    end
end

function ChatSkipper.QuestComplete(eventCode)
    if (ChatSkipper.SavedVariables.SkipDialogues) then
        CompleteQuest()
    end
end

function ChatSkipper.QuestOffered(eventCode)
    if (ChatSkipper.SavedVariables.SkipDialogues) then
        AcceptOfferedQuest()
        EndInteraction(INTERACTION_CONVERSATION)
    end
end

function ChatSkipper.OnAddOnLoaded(event, addonName)
    if addonName ~= ChatSkipper.Name then return end

    ChatSkipper.InitSavedVariables()
    ChatSkipper.InitSettings()
    EVENT_MANAGER:RegisterForEvent(ChatSkipper.Name, EVENT_QUEST_OFFERED, ChatSkipper.QuestOffered)
    EVENT_MANAGER:RegisterForEvent(ChatSkipper.Name, EVENT_QUEST_COMPLETE_DIALOG, ChatSkipper.QuestComplete)
    EVENT_MANAGER:RegisterForEvent(ChatSkipper.Name, EVENT_CHATTER_BEGIN, ChatSkipper.ChatterBegin)
    EVENT_MANAGER:RegisterForEvent(ChatSkipper.Name, EVENT_CONVERSATION_UPDATED, ChatSkipper.ConversationUpdated)
    EVENT_MANAGER:RegisterForEvent(ChatSkipper.Name, EVENT_SHOW_BOOK, ChatSkipper.ShowBook)
    EVENT_MANAGER:UnregisterForEvent(ChatSkipper.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ChatSkipper.Name, EVENT_ADD_ON_LOADED, ChatSkipper.OnAddOnLoaded)
