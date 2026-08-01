DailyAlchemy = {
    displayName = "|c3CB371" .. "Daily Alchemy" .. "|r",
    shortName = "DA",
    name = "DailyAlchemy",
    version = "1.5.1",

    DA_PRIORITY_BY_STOCK = 1,
    DA_PRIORITY_BY_MM = 2,
    DA_PRIORITY_BY_MANUAL = 3,
    DA_PRIORITY_BY_TTC = 4,
    DA_PRIORITY_BY_ATT = 5,

    emptySlot = nil,        -- ※Don't Finalize

    infos = nil,
    checkedJournal = {},
    stackList = {},
    houseStackList =  {},
    lockedList = {},

    acquiredItemId = nil,
    acquiredItemCurrent = nil,
    isStationInteract = false,  -- need Debug!
    isAcquire = false,
}




function DailyAlchemy:CraftCompleted(eventCode, craftSkill)

    if craftSkill ~= CRAFTING_TYPE_ALCHEMY then
        return
    end
    self:Debug("[CraftCompleted]")


    local result = self:Crafting(eventCode, craftSkill)
    if (not result) then
        self:Debug("　　> return(not result)")
        return
    end


    local isEmpty = true
    for key, value in pairs(self.checkedJournal) do
        self:Debug("　　<<1>>=<<2>>", key, tostring(value))
        if (not value) then
           self:Debug("　　> return(not value)")
           return
        end
        isEmpty = false
    end
    if isEmpty then
        self:Debug("　　> return(isEmpty)")
        return
    end


    if self.savedVariables.isAutoExit then
        self:Debug("　　> EndInteraction")
        EndInteraction(INTERACTION_CRAFT)
    else
        self:Debug("　　> not AutoExit")
    end
end




function DailyAlchemy:Crafting(craftSkill)

    self:Debug("[Crafting]", self.checkColor)

    if self.isAcquire then
        zo_callLater(function()
            self:Crafting(craftSkill)
        end, 1000)
    end


    self.infos = self.infos or self:GetQuestInfos()
    if self.infos == nil or #self.infos == 0 then
        self:Debug("　　>No Quest")
        return true
    end


    local parameter
    for _, info in pairs(self.infos) do
        self:Debug("　　--------")
        if self:IsValidConditions(info) then
            parameter = self:CreateParameter(info)
            if parameter then
                self:SetStation(parameter)
                CraftAlchemyItem(parameter.solvent.bagId,   parameter.solvent.slotIndex,
                                 parameter.reagent1.bagId,  parameter.reagent1.slotIndex,
                                 parameter.reagent2.bagId,  parameter.reagent2.slotIndex,
                                 parameter.reagent3.bagId,  parameter.reagent3.slotIndex)

                local amount = self:GetAmountToMake(parameter.itemType)
                if self.savedVariables.bulkQuantity then
                    info.current = math.min(info.current + amount, info.max)
                    local msg = zo_strformat("<<1>><<2>> x <<3>>/<<4>> [<<5>>]", parameter.icon,
                                                                                 parameter.resultLink,
                                                                                 info.current,
                                                                                 info.max,
                                                                                 GetString(DA_BULK_HEADER))
                    self:Message(msg)
                else
                    local msg = zo_strformat("<<1>><<2>> x <<3>>", parameter.icon,
                                                                   parameter.resultLink,
                                                                   (info.max - info.current))
                    self:Message(msg)
                    info.current = math.min(info.current + amount, info.max)
                end
                self.checkedJournal[info.key] = true
                if info.uniqueId then
                    local reservation = self.savedVariables.reservations[info.uniqueId]
                    reservation.current = info.current
                end
                return false

            elseif GetInteractionType() == INTERACTION_CRAFT then
                self.checkedJournal[info.key] = true
            end

        elseif info.isAcquire and info.current < info.max then
            local msg, msg2 = self:Contains(info.convertedTxt, self:AcquireConditions())
            if msg then
                if self.checkedJournal[info.key] == nil then
                    local isLogTmp = self.savedVariables.isLog
                    self.savedVariables.isLog = true
                    msg = msg .. (msg2 or "")
                    self:Message(zo_strformat(GetString(DA_NOTHING_ITEM), msg))
                    self.savedVariables.isLog = isLogTmp
                end
                self.checkedJournal[info.key] = false
            end
        end

    end
    return true
end




function DailyAlchemy:CreateParameter(info)

    self:Debug("　　[CreateParameter]")
    self.stackList = self:GetStackList()
    self.houseStackList = self:GetHouseStackList()
    local parameterList = self:Advice(info.convertedTxt, info.current, info.max, info.isMaster, info)

    local result
    for _, parameter in ipairs(parameterList) do
        if parameter.resultLink then
            local solvent = parameter.solvent
            solvent.bagId, solvent.slotIndex = self:GetFirstStack(solvent.itemId)

            local reagent1 = parameter.reagent1
            reagent1.bagId, reagent1.slotIndex = self:GetFirstStack(reagent1.itemId)

            local reagent2 = parameter.reagent2
            reagent2.bagId, reagent2.slotIndex = self:GetFirstStack(reagent2.itemId)

            local reagent3 = parameter.reagent3
            reagent3.bagId, reagent3.slotIndex = self:GetFirstStack(reagent3.itemId)

            local resultTest = GetAlchemyResultingItemLink(solvent.bagId,  solvent.slotIndex,
                                                           reagent1.bagId, reagent1.slotIndex,
                                                           reagent2.bagId, reagent2.slotIndex,
                                                           reagent3.bagId, reagent3.slotIndex,
                                                           LINK_STYLE_DEFAULT)
            if resultTest and resultTest ~= "" then
                parameter.resultLink = resultTest
            end

            result = parameter
            break
        end
    end


    if result then
        self:Debug("　　　　>create!")
        if ConfirmMasterWrit and info.uniqueId then
            local reservation = self.savedVariables.reservations[info.uniqueId]
            local masterWrit = reservation.masterWrit
            local arg1, arg2, arg3, arg4
                = string.match(masterWrit, "|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:(%d+):(%d+):(%d+):(%d+):.*")
            local keyElements = {
                tonumber(arg1),
                tonumber(arg2),
                tonumber(arg3),
                tonumber(arg4),
            }
            table.sort(keyElements)
            local key = table.concat(keyElements, ":")
            if ConfirmMasterWrit.alchemyResultList[key] == nil then
                ConfirmMasterWrit.alchemyResultList[key] = result.resultLink
                ConfirmMasterWrit.savedVariables.alchemyResultList[key] = result.resultLink
                ConfirmMasterWrit.alchemyItemList = nil
            end
        end
    else
        self:Debug("　　　　>parameter is nil")
    end

    return result
end




function DailyAlchemy:Finalize()

    self:Debug("[Finalize]")
    self.infos = nil
    self.checkedJournal = {}

    self.acquiredItemId = nil
    self.acquiredItemCurrent = nil
    self.stackList = {}
    self.houseStackList = {}
    self.lockedList = {}
    self.isStationInteract = false
end




function DailyAlchemy:GetAmountToMake(itemType)

    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_ALCHEMY)
    local abilityIndex = 4
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end
    if itemType == ITEMTYPE_POTION then
        return 1 + rankIndex
    else
        return 4 + (rankIndex * 4)
    end
end




function DailyAlchemy:GetAvgPrice(itemLink)

    local saveVer = self.savedVariables
    if saveVer.priorityBy == self.DA_PRIORITY_BY_STOCK then
        return 0
    end


    if MasterMerchant then
        if (saveVer.priorityBy == self.DA_PRIORITY_BY_MM)
        or (saveVer.priorityBy == self.DA_PRIORITY_BY_MANUAL and saveVer.showPriceMM) then

            local tipStats = MasterMerchant:itemStats(itemLink)
            if tipStats and tipStats.avgPrice then
                return tipStats.avgPrice
            end
            return 0
        end
    end


    if TamrielTradeCentre then
        if (saveVer.priorityBy == self.DA_PRIORITY_BY_TTC)
        or (saveVer.priorityBy == self.DA_PRIORITY_BY_MANUAL and saveVer.showPriceTTC) then

            local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
            local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)
            if priceInfo and priceInfo.Avg then
                return priceInfo.Avg
            end
            return 0
        end
    end


    if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
        if (saveVer.priorityBy == self.DA_PRIORITY_BY_ATT)
        or (saveVer.priorityBy == self.DA_PRIORITY_BY_MANUAL and saveVer.showPriceATT) then

            -- Returns an average price for the last 3 days
            local days = GetTimeStamp() - (24 * 60 * 60 * 3)
            local avgPrice = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, days)
            if avgPrice then
                return avgPrice
            end
            return 0
        end
    end


    return 0
end




function DailyAlchemy:GetCraftingBagList()

    if GetInteractionType() == INTERACTION_BANK and IsOwnerOfCurrentHouse() then
        local _, name, _, _, additionalInfo, houseBankBagId = GetGameCameraInteractableActionInfo()
        if additionalInfo == ADDITIONAL_INTERACT_INFO_HOUSE_BANK then
            return {
                BAG_BANK,
                BAG_BACKPACK,
                BAG_VIRTUAL,
                houseBankBagId,
            }
        end
    end

    return {
        BAG_BANK,
        BAG_BACKPACK,
        BAG_VIRTUAL,
        BAG_SUBSCRIBER_BANK,
    }
end




function DailyAlchemy:GetFirstStack(itemId)
    if itemId == nil then
        return nil, nil
    end

    for i, bagId in ipairs(self:GetCraftingBagList()) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            local itemType = GetItemType(bagId, slotIndex)
            if self:ContainsNumber(itemType, ITEMTYPE_POTION_BASE,
                                             ITEMTYPE_POISON_BASE,
                                             ITEMTYPE_REAGENT) and self:IsUnLocked(bagId, slotIndex) then

                if GetItemId(bagId, slotIndex) == itemId then
                    return bagId, slotIndex
                end
            end
            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return nil, nil
end




function DailyAlchemy:GetPriority(itemId)

    if self.savedVariables.priorityBy ~= self.DA_PRIORITY_BY_MANUAL then
        return nil
    end
    if (not itemId) or (itemId == 0) then
        return #self.savedVariables.priorityByManual + 1
    end


    for key, value in ipairs(self.savedVariables.priorityByManual) do
        if value == itemId then
            return key
        end
    end
    return #self.savedVariables.priorityByManual + 1
end




function DailyAlchemy:GetQuestInfos()

    local toHide = self:IsDebug() and (not self.savedVariables.isDebugQuest)
    if toHide then
        self.savedVariables.isDebug = false
    end

    self:Debug("　　[GetQuestInfos]")

    self.acquiredItemId = nil
    self.acquiredItemCurrent = nil
    local list = {}
    for questIdx = 1, MAX_JOURNAL_QUESTS do
        local questName = GetJournalQuestName(questIdx)
        if self:IsValidQuest(questIdx, questName) then

            local isMaster = self:Contains(questName, GetString(DA_CRAFTING_MASTER), GetString(DA_CRAFTING_WITCH))
            for stepIdx = 1, GetJournalQuestNumSteps(questIdx) do
                for conditionIdx = 1, GetJournalQuestNumConditions(questIdx, stepIdx) do

                    local key = table.concat({questIdx, stepIdx, conditionIdx}, "_")
                    local txt, current, max, _, _, _, isVisible, conditionType = GetJournalQuestConditionInfo(questIdx,
                                                                                                              stepIdx,
                                                                                                              conditionIdx)
                    local info = {}
                    info.txt = txt
                    info.convertedTxt = self:ConvertedJournalCondition(txt)
                    info.current = current
                    info.max = max
                    info.isMaster = isMaster
                    info.key = key
                    info.questIdx = questIdx
                    info.stepIdx = stepIdx
                    info.conditionIdx = conditionIdx
                    info.bulkMark = ""
                    info.isCrafting, info.isAcquire = self:IsValidJournal(isVisible, info)
                    if info.isCrafting or info.isAcquire then
                        list[#list + 1] = info
                    end

                end
            end
        end
    end


    local reservations = self.savedVariables.reservations or {}
    local itemLink
    local uniqueId
    local reservation
    local txt
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if self:GetCraftingTypeByLink(itemLink) == CRAFTING_TYPE_ALCHEMY then
            uniqueId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
            reservation = reservations[uniqueId]
            if reservation and reservation.current < reservation.max then
                self:Debug("　　questName(O):--")
                txt = GenerateMasterWritBaseText(GetItemLink(BAG_BACKPACK, slotIndex))
                local info = {}
                info.uniqueId = uniqueId
                info.txt = txt
                info.convertedTxt = self:ConvertedJournalCondition(txt)
                info.current = reservation.current
                info.max = reservation.max
                info.isMaster = true
                info.key = uniqueId
                info.bulkMark = ""
                info.isCrafting, info.isAcquire = self:IsValidJournal(true, info)
                list[#list + 1] = info
            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end

    if toHide then
        self.savedVariables.isDebug = true
    end
    return list
end




function DailyAlchemy:IsUnLocked(bagId, slotIndex)

    if self.savedVariables.useItemLock and FCOIS and FCOIS.IsMarked(bagId, slotIndex, -1) then
        self.lockedList[GetItemLink(bagId, slotIndex)] = true
        return false
    end

    return true
end




function DailyAlchemy:IsValidConditions(info)

    if info.isCrafting then
        if info.current < info.max then
            self:Debug("　　journal(O):<<1>> (<<2>>/<<3>>)<<4>>)", info.convertedTxt,
                                                                   info.current,
                                                                   info.max,
                                                                   info.bulkMark)
            return true
        end
    end

    self:Debug("|c5c5c5c　　journal(X):<<1>> (<<2>>/<<3>>)|r", info.convertedTxt,
                                                               info.current,
                                                               info.max)
    return false
end




function DailyAlchemy:IsValidJournal(isVisible, info)

    if info.convertedTxt == nil or info.convertedTxt == "" then
        return false, false
    end


    if isVisible then
        if info.current < info.max and self:Contains(info.convertedTxt, self:CraftingConditions()) then
            if self.savedVariables.bulkQuantity then
                info.bulkMark = "※bulk"
                info.max = math.max(self.savedVariables.bulkQuantity, info.max)
            end
            self:Debug("　　　　journal(O):<<1>> (<<2>>/<<3>>)<<4>>", info.convertedTxt,
                                                                      info.current,
                                                                      info.max,
                                                                      info.bulkMark)
            return true, false
        end

        if self:Contains(info.convertedTxt, self:AcquireConditions()) then
            local itemId
            local stack
            local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
            while slotIndex do
                itemId = self:IsValidItem(info.convertedTxt, BAG_BACKPACK, slotIndex)
                stack = GetItemTotalCount(BAG_BACKPACK, slotIndex)
                if itemId and itemId ~= 0 then
                    self:Debug("　　　　※Acquired " .. GetItemLink(BAG_BACKPACK, slotIndex) .. "x" .. stack .. " in Backpack")
                    self.acquiredItemId = itemId
                    self.acquiredItemCurrent = info.current
                    break
                end
                slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
            end

            if info.current < info.max then
                self:Debug("　　　　journal(O):<<1>> (<<2>>/<<3>>)", info.convertedTxt,
                                                                     info.current,
                                                                     info.max)
                return false, true
            end
        end
    end
    self:Debug("　　　　journal(X):<<1>> (<<2>>/<<3>>)", info.convertedTxt,
                                                         info.current,
                                                         info.max,
                                                         self.disabledColor)
    return false, false
end




function DailyAlchemy:IsValidParameter(validKeyCache, reagent1, reagent2, reagent3)

    local traitMinCount
    local list
    local keyList
    if reagent3 then
        if reagent1.itemId == reagent2.itemId then
            return nil
        end
        if reagent1.itemId == reagent3.itemId then
            return nil
        end
        if reagent2.itemId == reagent3.itemId then
            return nil
        end
        list = {reagent1, reagent2, reagent3}
        keyList = {reagent1.itemId, reagent2.itemId, reagent3.itemId}
        traitMinCount = 3

    else
        if reagent2.itemId == reagent1.itemId then
            return nil
        end
        list = {reagent1, reagent2}
        keyList = {reagent1.itemId, reagent2.itemId}
        traitMinCount = 1
    end

    table.sort(keyList)
    local key = tonumber(table.concat(keyList, ""))
    if validKeyCache[key] then
        return nil
    end
    validKeyCache[key] = true


    local summary = {}
    for _, reagent in ipairs(list) do
        for i, trait in ipairs(reagent.traits) do
            if summary[trait] then
                summary[trait].total = summary[trait].total + 1
            else
                summary[trait] = {}
                summary[trait].trait = trait
                summary[trait].total = 1
                summary[trait].traitPriority = reagent.traitPrioritys[i]
            end
        end
    end


    local resultTraits = {}
    local traitCount = 0
    for _, value in pairs(summary) do
        if value.total >= 2 then
            traitCount = traitCount + 1
            resultTraits[#resultTraits + 1] = value
        end
    end
    if traitCount < traitMinCount then
        return nil
    end

    table.sort(resultTraits, function(a, b)
        return a.traitPriority < b.traitPriority
    end)


    local traits = {}
    for _, resultTrait in pairs(resultTraits) do
        traits[#traits + 1] = resultTrait.trait
    end
    return traits, resultTraits[1].traitPriority
end




function DailyAlchemy:IsValidQuest(questIdx, questName)

    if GetJournalQuestType(questIdx) == QUEST_TYPE_CRAFTING then
        if (not GetJournalQuestIsComplete(questIdx)) then
            if self:Contains(questName, GetString(DA_CRAFTING_QUEST), GetString(DA_CRAFTING_MASTER)) then
                self:Debug("　　questName(O):" .. tostring(questName))
                return true
            end

            if self:Contains(questName, GetString(DA_CRAFTING_WITCH)) then
                for stepIdx = 1, GetJournalQuestNumSteps(questIdx) do
                    for conditionIdx = 1, GetJournalQuestNumConditions(questIdx, stepIdx) do
                        local txt, _, _, _, _, _, isVisible = GetJournalQuestConditionInfo(questIdx,
                                                                                           stepIdx,
                                                                                           conditionIdx)
                        if isVisible and txt and txt ~="" and self:isAlchemy(txt) then
                            self:Debug("　　questName(O):<<1>>", questName)
                            return true
                        end
                    end
                end
                self:Debug("　　questName(X:WITCH):<<1>>", questName, self.disabledColor)
                return false
            end
        end
        self:Debug("　　questName(X):<<1>>", tostring(questName), self.disabledColor)
    end
    return false
end




function DailyAlchemy:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    setmetatable(DailyAlchemy, {__index = LibMarify})

    SLASH_COMMANDS["/langen"] = function() SetCVar("language.2", "en") end
    SLASH_COMMANDS["/langjp"] = function() SetCVar("language.2", "jp") end
    SLASH_COMMANDS["/langde"] = function() SetCVar("language.2", "de") end
    SLASH_COMMANDS["/langfr"] = function() SetCVar("language.2", "fr") end
    SLASH_COMMANDS["/langru"] = function() SetCVar("language.2", "ru") end
    if EsoPL then
        SLASH_COMMANDS["/langpl"] = function() SetCVar("language.2", "pl") end
    end
    self.savedVariables = ZO_SavedVars:NewAccountWide("DailyAlchemyVariables", 1, nil, {})
    self.savedCharVariables  = ZO_SavedVars:NewCharacterIdSettings("DailyAlchemyVariables", 1, nil, {})
    self:CreateMenu()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT,     function(...) self:StationInteract(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFT_COMPLETED,               function(...) self:CraftCompleted(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, function(...) self:Finalize(...) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,              function(...) self:Camehome() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK,                     function(...) self:OnOpenBank() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK,                    function(...) self:Finalize(...) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_ADDED,                   function(...) self:QuestReceived(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_COMPLETE,                function(...) self:QuestComplete(...) end)
    self:PostHook(ZO_PlayerInventoryBackpack.dataTypes[1], "setupCallback",        function(...) self:UpdateInventory(...) end)
    LibCustomMenu:RegisterContextMenu(function(...) self:ShowContextMenu(...) end, LibCustomMenu.CATEGORY_LATE)
end




function DailyAlchemy:QuestComplete()
    local oldReservations = self.savedVariables.reservations
    local newReservations = {}
    local itemLink
    local uniqueId
    local reservation
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if self:GetCraftingTypeByLink(itemLink) == CRAFTING_TYPE_ALCHEMY then
            uniqueId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
            reservation = oldReservations[uniqueId]
            if reservation then
                newReservations[uniqueId] = reservation
            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end
    self.savedVariables.reservations = newReservations
end




function DailyAlchemy:QuestReceived(eventCode, journalIndex, questName, objectiveName)

    if self:Contains(questName, {GetString(DA_CRAFTING_QUEST)}) then
        self.savedCharVariables.rankWhenReceived = self:GetSkillRank()
        self.savedVariables.debugLog = {}
    end
end




function DailyAlchemy:SetStation(parameter)

    self:Debug("　　[SetStation]")
    if ALCHEMY:HasSelections() then
        self:Debug("　　　　ClearSelections")
        ALCHEMY:ClearSelections()
    end


    self:Debug("　　　　SetSolventItem[<<1>>, <<2>>] <<3>>", parameter.solvent.bagId,
                                                         parameter.solvent.slotIndex,
                                                         GetItemLink(parameter.solvent.bagId, parameter.solvent.slotIndex))
    ALCHEMY:SetSolventItem(parameter.solvent.bagId, parameter.solvent.slotIndex) 


    self:Debug("　　　　SetReagentItem1[<<1>>, <<2>>] <<3>>", parameter.reagent1.bagId,
                                                          parameter.reagent1.slotIndex,
                                                          GetItemLink(parameter.reagent1.bagId, parameter.reagent1.slotIndex))
    ALCHEMY:SetReagentItem(1, parameter.reagent1.bagId, parameter.reagent1.slotIndex)


    self:Debug("　　　　SetReagentItem2[<<1>>, <<2>>] <<3>>", parameter.reagent2.bagId,
                                                          parameter.reagent2.slotIndex,
                                                          GetItemLink(parameter.reagent2.bagId, parameter.reagent2.slotIndex))
    ALCHEMY:SetReagentItem(2, parameter.reagent2.bagId, parameter.reagent2.slotIndex)


    if parameter.reagent3.bagId then
        self:Debug("　　　　SetReagentItem3[<<1>>, <<2>>] <<3>>", parameter.reagent3.bagId,
                                                              parameter.reagent3.slotIndex,
                                                              GetItemLink(parameter.reagent3.bagId, parameter.reagent3.slotIndex))
        ALCHEMY:SetReagentItem(3, parameter.reagent3.bagId, parameter.reagent3.slotIndex)
    end
end




function DailyAlchemy:ShowContextMenu(inventorySlot, slotActions)

    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    if slotType ~= SLOT_TYPE_ITEM then
        return
    end


    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if GetDisplayName() == "@Marify" and GetItemType(bagId, slotIndex) == ITEMTYPE_REAGENT then
        AddCustomMenuItem(GetString(SI_ITEMTYPE68), function()
            self:ShowReagentInfo(bagId, slotIndex)
        end, MENU_ADD_OPTION_LABEL)
        return
    end


    local itemLink = GetItemLink(bagId, slotIndex)
    local craftingType, max = self:GetCraftingTypeByLink(itemLink)
    if craftingType ~= CRAFTING_TYPE_ALCHEMY then
        return
    end


    local uniqueId = Id64ToString(GetItemUniqueId(bagId, slotIndex))
    local lang = GetCVar("language.2")
    local txt = GenerateMasterWritBaseText(itemLink)
    txt = self:ConvertedJournalCondition(txt)

    local reservations = self.savedVariables.reservations
    if (not reservations) then
        reservations = {}
        self.savedVariables.reservations = reservations
    end

    if reservations[uniqueId] then
        local label = (self.savedVariables.isDebug or self:Equal(GetDisplayName(), "@Marify", "@anego_J"))
                        and zo_strformat("|cE4007F<<1>>|r", GetString(DA_CANCEL_WRIT))
                        or GetString(DA_CANCEL_WRIT)
        AddCustomMenuItem(label, function()
            reservations[uniqueId] = nil
            self:Message(GetString(DA_CANCEL_WRIT_MSG))
            PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
        end, MENU_ADD_OPTION_LABEL)
    else
        local label = (self.savedVariables.isDebug or self:Equal(GetDisplayName(), "@Marify", "@anego_J"))
                        and zo_strformat("|c3CB371<<1>>|r", GetString(DA_CRAFT_WRIT))
                        or GetString(DA_CRAFT_WRIT)
        AddCustomMenuItem(label, function()
            local reservation = {}
            reservation.masterWrit = itemLink
            reservation.txt = txt
            reservation.current = 0
            reservation.max = max
            reservations[uniqueId] = reservation
            self:Message(zo_strformat(GetString(DA_CRAFT_WRIT_MSG), txt))
            PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
        end, MENU_ADD_OPTION_LABEL)
    end
end




function DailyAlchemy:StationInteract(eventCode, craftSkill, sameStation)

    if craftSkill ~= CRAFTING_TYPE_ALCHEMY then
        return
    end

    self.isStationInteract = true
    self.savedVariables.debugLog = {}
    self:Debug("[StationInteract]")
    if self:IsDebug() and self.savedVariables.isDebugSettings then
        self:Debug("　　savedVariables.bulkQuantity=" .. tostring(self.savedVariables.bulkQuantity))
        self:Debug("　　savedVariables.isAcquireItem=" .. tostring(self.savedVariables.isAcquireItem))
        self:Debug("　　savedVariables.acquireDelay=" .. tostring(self.savedVariables.acquireDelay))
        self:Debug("　　savedVariables.isAutoExit=" .. tostring(self.savedVariables.isAutoExit))
        self:Debug("　　savedVariables.isLog=" .. tostring(self.savedVariables.isLog))
        self:Debug("　　savedVariables.isDebug=" .. tostring(self.savedVariables.isDebug))
        self:Debug("　　savedVariables.isDebugSettings=" .. tostring(self.savedVariables.isDebugSettings))
        self:Debug("　　savedVariables.isDebugQuest=" .. tostring(self.savedVariables.isDebugQuest))
        self:Debug("　　savedVariables.isDebugSolvent=" .. tostring(self.savedVariables.isDebugSolvent))
        self:Debug("　　savedVariables.isDebugTrait=" .. tostring(self.savedVariables.isDebugTrait))
        self:Debug("　　savedVariables.isDebugReagent=" .. tostring(self.savedVariables.isDebugReagent))
        self:Debug("　　savedVariables.isDebugPriority=" .. tostring(self.savedVariables.isDebugPriority))
        self:Debug("　　FCOIS=" .. (FCOIS and "Exists") or "nil")
        self:Debug("　　self.savedVariables.useItemLock=" .. tostring(self.savedVariables.useItemLock))
    end
    self:Crafting(craftSkill)
end




function DailyAlchemy:UpdateInventory(control)

    local reservations = self.savedVariables.reservations
    if (not reservations) then
        reservations = {}
        self.savedVariables.reservations = reservations
        return
    end

    if ConfirmMasterWrit then
        return
    end

    if (not control) then
        return
    end

    local slot = control.dataEntry.data
    if (not slot) then
        return
    end

    local uniqueId = Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))
    if (not uniqueId) then
        return
    end


    local mark = control:GetNamedChild("DA_ItemMark")
    if (not mark) and reservations[uniqueId] then
        mark = WINDOW_MANAGER:CreateControl(control:GetName() .. "DA_ItemMark", control, CT_TEXTURE)
        mark:SetDrawLayer(3)
        mark:SetDimensions(20, 20)
        mark:ClearAnchors()
        mark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 80, 10)
        mark:SetTexture("esoui/art/journal/journal_quest_selected.dds")
    end
    if (not mark) then
        return
    end


    reservation = reservations[uniqueId]
    if reservation then
        if (reservation.current < reservation.max) then
            mark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_QUALITY_LEGENDARY))
        else
            mark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))
        end
        mark:SetHidden(false)
    else
        mark:SetHidden(true)
    end
end




EVENT_MANAGER:RegisterForEvent(DailyAlchemy.name, EVENT_ADD_ON_LOADED, function(...) DailyAlchemy:OnAddOnLoaded(...) end)

