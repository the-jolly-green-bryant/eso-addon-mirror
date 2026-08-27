TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local Quests = {}
TetsuDailyWritPrecrafter.Quests = Quests

local writOfferPending = false
local writLootUntil = 0
local chatterQueued = false
local acceptChainActive = false

local function AutoQuestEnabled()
    if TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat() then
        return false
    end
    local vars = TetsuDailyWritPrecrafter.savedVars
    return not (vars and vars.autoQuest == false)
end

local function AutoBoxEnabled()
    if TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat() then
        return false
    end
    local vars = TetsuDailyWritPrecrafter.savedVars
    return not (vars and vars.autoBox == false)
end

local function HasCraftingWrit()
    local maxQuests = MAX_JOURNAL_QUESTS or 25
    for i = 1, maxQuests do
        if IsValidQuestIndex(i) and GetJournalQuestType(i) == QUEST_TYPE_CRAFTING then
            return true, i
        end
    end
    return false, nil
end

local function SafeUseItem(bag, slot)
    if IsProtectedFunction and IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", bag, slot)
    else
        UseItem(bag, slot)
    end
end

local function IsWritRewardBox(bag, slot)
    local itemType, specType = GetItemType(bag, slot)
    if itemType ~= ITEMTYPE_CONTAINER then return false end
    if SPECIALIZED_ITEMTYPE_CONTAINER_WRIT_REWARD and specType == SPECIALIZED_ITEMTYPE_CONTAINER_WRIT_REWARD then
        return true
    end
    local name = GetItemName(bag, slot) or ""
    return TetsuDailyWritPrecrafter.Data.TextLooksLikeWrit(name)
end

-- Pick the first chatter option that looks like a daily crafting writ.
-- Boards expose multiple profession lines; we accept one, then the
-- EVENT_CONVERSATION_UPDATED / QUEST_OFFERED cycle re-enters ProcessChatter
-- for the next remaining option until none are left.
local function ProcessChatter()
    if not AutoQuestEnabled() then
        return
    end

    local numOptions = GetChatterOptionCount()
    if not numOptions or numOptions == 0 then
        acceptChainActive = false
        return
    end

    local Data = TetsuDailyWritPrecrafter.Data

    -- 1) New writ bestowals (board / NPC offering a crafting writ)
    for index = 1, numOptions do
        local optionString, optionType = GetChatterOption(index)
        local isBestowal = (optionType == CHATTER_START_NEW_QUEST_BESTOWAL)
            or (optionType == CHATTER_TALK_CHOICE)
            or (CHATTER_ACCEPT_QUEST_BESTOWAL and optionType == CHATTER_ACCEPT_QUEST_BESTOWAL)

        if isBestowal and Data.TextLooksLikeWrit(optionString or "") then
            writOfferPending = true
            acceptChainActive = true
            SelectChatterOption(index)
            return
        end
    end

    -- 2) Advance / complete already-held crafting writs (drop-off crates or board follow-ups)
    local hasWrit = HasCraftingWrit()
    if hasWrit then
        for index = 1, numOptions do
            local optionString, optionType = GetChatterOption(index)
            if optionType == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS
                or optionType == CHATTER_START_COMPLETE_QUEST
                or (CHATTER_COMPLETE_QUEST_CONFIRM and optionType == CHATTER_COMPLETE_QUEST_CONFIRM)
                or (CHATTER_COMPLETE_QUEST_DIALOG and optionType == CHATTER_COMPLETE_QUEST_DIALOG)
            then
                SelectChatterOption(index)
                return
            end
            -- Fallback: option text itself mentions a writ while we already hold one
            if Data.TextLooksLikeWrit(optionString or "") then
                SelectChatterOption(index)
                return
            end
        end
    end

    acceptChainActive = false
end

local function ConflictBlocked()
    return TetsuDailyWritPrecrafter.HasWritConflict and select(1, TetsuDailyWritPrecrafter.HasWritConflict())
end

local function OnQuestOffered()
    if ConflictBlocked() then return end
    if not AutoQuestEnabled() then return end
    -- Accept even if the pending flag was cleared by a fast conversation update
    if not writOfferPending and not acceptChainActive then return end
    writOfferPending = false
    zo_callLater(function()
        if AcceptOfferedQuest then
            AcceptOfferedQuest()
        end
        -- After accept the board usually refreshes options → EVENT_CONVERSATION_UPDATED
        -- will fire ProcessChatter again for the next profession.
    end, 40)
end

local function OnQuestCompleteDialog(eventCode, journalIndex)
    if ConflictBlocked() then return end
    if not AutoQuestEnabled() then return end
    if journalIndex and GetJournalQuestType(journalIndex) ~= QUEST_TYPE_CRAFTING then
        return
    end
    if not journalIndex and not HasCraftingWrit() then
        return
    end
    zo_callLater(function()
        CompleteQuest()
        writLootUntil = GetTimeStamp() + 20
    end, 50)
end

local function OnChatter()
    if chatterQueued then return end
    chatterQueued = true
    zo_callLater(function()
        chatterQueued = false
        ProcessChatter()
    end, 50)
end

local function TryOpenWritBoxes()
    if not AutoBoxEnabled() then return end
    local size = GetBagSize(BAG_BACKPACK) or 0
    for slot = 1, size do
        if IsWritRewardBox(BAG_BACKPACK, slot) then
            SafeUseItem(BAG_BACKPACK, slot)
            return
        end
    end
end

local function OnSingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem)
    if bagId ~= BAG_BACKPACK or not isNewItem then return end
    if not AutoBoxEnabled() then return end
    if not IsWritRewardBox(bagId, slotIndex) then return end
    zo_callLater(function()
        SafeUseItem(bagId, slotIndex)
    end, 200)
end

local function OnQuestComplete(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType)
    if questType == QUEST_TYPE_CRAFTING then
        writLootUntil = GetTimeStamp() + 20
        zo_callLater(TryOpenWritBoxes, 400)
    end
end

local function TryLootAll()
    if GetTimeStamp() > writLootUntil then return end
    if not IsLooting or not IsLooting() then return end
    -- Prefer LOOT_SHARED when present (gamepad + keyboard)
    if LOOT_SHARED and LOOT_SHARED.LootAllItems then
        LOOT_SHARED:LootAllItems()
    elseif LootAll then
        LootAll(true) -- ignoreStolen
    end
end

local function OnLootUpdated()
    if GetTimeStamp() > writLootUntil then return end
    zo_callLater(TryLootAll, 50)
    zo_callLater(TryLootAll, 200)
end

function Quests.Initialize()
    EVENT_MANAGER:RegisterForEvent("TWC_QuestOffer", EVENT_QUEST_OFFERED, OnQuestOffered)
    EVENT_MANAGER:RegisterForEvent("TWC_QuestCompleteDlg", EVENT_QUEST_COMPLETE_DIALOG, OnQuestCompleteDialog)
    EVENT_MANAGER:RegisterForEvent("TWC_ChatterBegin", EVENT_CHATTER_BEGIN, OnChatter)
    EVENT_MANAGER:RegisterForEvent("TWC_ChatterUpdate", EVENT_CONVERSATION_UPDATED, OnChatter)
    EVENT_MANAGER:RegisterForEvent("TWC_BoxesOpen", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSingleSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent("TWC_BoxesOpen", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:RegisterForEvent("TWC_QuestComplete", EVENT_QUEST_COMPLETE, OnQuestComplete)
    EVENT_MANAGER:RegisterForEvent("TWC_LootUpdated", EVENT_LOOT_UPDATED, OnLootUpdated)
    EVENT_MANAGER:RegisterForEvent("TWC_LootClosed", EVENT_LOOT_CLOSED, function()
        -- after loot window closes, try opening next writ box
        zo_callLater(TryOpenWritBoxes, 300)
    end)
end
