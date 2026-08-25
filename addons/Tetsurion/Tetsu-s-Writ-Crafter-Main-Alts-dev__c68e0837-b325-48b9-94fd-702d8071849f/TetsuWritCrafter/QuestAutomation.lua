TetsuWritCrafter = TetsuWritCrafter or {}
local Quests = {}
TetsuWritCrafter.Quests = Quests

local isHandlingBoard = false

local function IsWritChatterOption(optionType)
    return optionType == CHATTER_START_TALK 
        or optionType == CHATTER_TALK_CHOICE 
        or optionType == CHATTER_START_QUEST
end

local function HandleNextBoardOption()
    local numOptions = GetChatterOptionCount()
    if not numOptions or numOptions == 0 then
        if isHandlingBoard then
            isHandlingBoard = false
            EndInteraction(INTERACTION_CONVERSATION)
        end
        return
    end

    for index = 1, numOptions do
        local _, optionType = GetChatterOption(index)
        if IsWritChatterOption(optionType) then
            isHandlingBoard = true
            SelectChatterOption(index)
            return
        end
    end

    if isHandlingBoard then
        isHandlingBoard = false
        EndInteraction(INTERACTION_CONVERSATION)
    end
end

local function OnConversationUpdated()
    zo_callLater(HandleNextBoardOption, 80)
end

local function OnQuestOffered()
    if isHandlingBoard or GetOfferedQuestShareInfo() then
        AcceptOfferedQuest()
    end
end

local function OnQuestCompleteDialog()
    CompleteQuest()
end

local function OnSingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem)
    if bagId ~= BAG_BACKPACK or not isNewItem then return end

    local itemType, specializedItemType = GetItemType(bagId, slotIndex)
    if itemType == ITEMTYPE_CONTAINER and specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_WRIT_REWARD then
        zo_callLater(function()
            if IsProtectedFunction("UseItem") then
                CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex)
            else
                UseItem(BAG_BACKPACK, slotIndex)
            end
        end, 250)
    end
end

function Quests.Initialize()
    EVENT_MANAGER:RegisterForEvent("TWC_QuestOffer", EVENT_QUEST_OFFERED, OnQuestOffered)
    EVENT_MANAGER:RegisterForEvent("TWC_QuestComplete", EVENT_QUEST_COMPLETE_DIALOG, OnQuestCompleteDialog)
    EVENT_MANAGER:RegisterForEvent("TWC_ChatterBegin", EVENT_CHATTER_BEGIN, OnConversationUpdated)
    EVENT_MANAGER:RegisterForEvent("TWC_ChatterUpdate", EVENT_CONVERSATION_UPDATED, OnConversationUpdated)
    EVENT_MANAGER:RegisterForEvent("TWC_BoxesOpen", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSingleSlotUpdate)
end