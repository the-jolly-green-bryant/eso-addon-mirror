TetsuWritCrafter = TetsuWritCrafter or {}
local Banking = {}
TetsuWritCrafter.Banking = Banking

local isTransferring = false

local function IsMasterCrafter()
    local vars = TetsuWritCrafter.savedVars
    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    if vars.mainCrafterName then
        return vars.mainCrafterName == charName
    end
    local currentLevel, maxLevel = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 1, 1)
    return currentLevel and maxLevel and currentLevel == maxLevel
end

local function ProcessTransferQueue(titleText, itemsQueue, actionFn)
    if isTransferring or #itemsQueue == 0 then return end
    isTransferring = true

    local currentIndex = 0
    local total = #itemsQueue

    EVENT_MANAGER:RegisterForUpdate("TWC_BankQueueLoop", 180, function()
        currentIndex = currentIndex + 1
        if currentIndex <= total then
            TetsuWritCrafter.UI.UpdateProgress(titleText, currentIndex, total)
            actionFn(itemsQueue[currentIndex])
        else
            EVENT_MANAGER:UnregisterForUpdate("TWC_BankQueueLoop")
            isTransferring = false
            TetsuWritCrafter.UI.HideProgress()
        end
    end)
end

local function OnBankOpen()
    local L = TetsuWritCrafter.L

    if IsMasterCrafter() then
        local depositSlots = {}
        for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
            local itemType, specType = GetItemType(BAG_BACKPACK, slotIndex)
            if IsItemCrafted(BAG_BACKPACK, slotIndex) and GetItemFunctionalQuality(BAG_BACKPACK, slotIndex) == ITEM_FUNCTIONAL_QUALITY_NORMAL then
                table.insert(depositSlots, slotIndex)
            elseif itemType == ITEMTYPE_MASTER_WRIT or specType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
                table.insert(depositSlots, slotIndex)
            end
        end

        if #depositSlots == 0 then return end

        local freeBank = GetNumBagFreeSlots(BAG_BANK)
        if IsESOPlusSubscriber() then freeBank = freeBank + GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK) end

        if freeBank < #depositSlots then
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, zo_strformat(L.ERR_NOT_ENOUGH_BANK, #depositSlots, freeBank))
            return
        end

        ProcessTransferQueue(L.PROGRESS_BANK_DEPOSIT, depositSlots, function(slotIndex)
            PickupInventoryItem(BAG_BACKPACK, slotIndex)
            PlaceInTransfer()
        end)
        return
    end

    local activeWritDemands = {}
    for qIndex = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(qIndex) and GetJournalQuestType(qIndex) == QUEST_TYPE_CRAFTING then
            local numConditions = GetJournalNumQuestConditions(qIndex, 1)
            for cIndex = 1, numConditions do
                local cur, max, text = GetJournalQuestConditionValues(qIndex, 1, cIndex)
                if cur < max and text and text ~= "" then
                    table.insert(activeWritDemands, text)
                end
            end
        end
    end

    if #activeWritDemands == 0 then return end

    local withdrawSlots = {}
    local bankSize = GetBagSize(BAG_BANK)
    for slotIndex = 0, bankSize do
        if IsItemCrafted(BAG_BANK, slotIndex) and GetItemFunctionalQuality(BAG_BANK, slotIndex) == ITEM_FUNCTIONAL_QUALITY_NORMAL then
            table.insert(withdrawSlots, slotIndex)
            if #withdrawSlots >= #activeWritDemands then break end
        end
    end

    if #withdrawSlots > 0 then
        ProcessTransferQueue(L.PROGRESS_BANK_WITHDRAW, withdrawSlots, function(slotIndex)
            PickupInventoryItem(BAG_BANK, slotIndex)
            PlaceInTransfer()
        end)
    end
end

function Banking.Initialize()
    EVENT_MANAGER:RegisterForEvent("TWC_BankOpen", EVENT_OPEN_BANK, OnBankOpen)
end