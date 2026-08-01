
function DailyProvisioning:Acquire()

    self:Debug("[Acquire]", self.checkColor)
    if self:IsDebug() and self.savedVariables.isDebugSettings then
        self:Debug("　　savedVariables.bulkQuantity=" .. tostring(self.savedVariables.bulkQuantity))
        self:Debug("　　savedVariables.isAcquireItem=" .. tostring(self.savedVariables.isAcquireItem))
        self:Debug("　　savedVariables.acquireDelay=" .. tostring(self.savedVariables.acquireDelay))
        self:Debug("　　savedVariables.isAutoExit=" .. tostring(self.savedVariables.isAutoExit))
        self:Debug("　　savedVariables.isDontKnow=" .. tostring(self.savedVariables.isDontKnow))
        self:Debug("　　savedVariables.isLog=" .. tostring(self.savedVariables.isLog))
        self:Debug("　　savedVariables.isDebug=" .. tostring(self.savedVariables.isDebug))
        self:Debug("　　savedVariables.isDebugSettings=" .. tostring(self.savedVariables.isDebugSettings))
        self:Debug("　　savedVariables.isDebugQuest=" .. tostring(self.savedVariables.isDebugQuest))
        self:Debug("　　savedVariables.isDebugRecipe=" .. tostring(self.savedVariables.isDebugRecipe))
    end


    local infos, hasMaster, hasDaily, hasEvent = self:GetQuestInfos()
    if (not infos) or #infos == 0 then
        self:Debug("　　>No Quest")
        return
    end
    if self.isStationInteract then
        self:Debug("　　break Case1", self.checkColor)
        return
    end


    self.emptySlot = nil
    if DailyAlchemy and DailyAlchemy.emptySlot ~= nil then
        self.emptySlot = DailyAlchemy.emptySlot
    end
    self.emptySlot = self:NextEmptySlot(BAG_BACKPACK, self.emptySlot)


    if (not self.recipeList) then
        self.recipeList = self:GetRecipeList(hasMaster, hasDaily, hasEvent)
    end
    self.stackList = self:GetStackList()
    self.houseStackList = self:GetHouseStackList()
    if self.isStationInteract then
        self:Debug("　　break Case2", self.checkColor)
        return
    end


    local toHide = self:IsDebug() and (not self.savedVariables.isDebugRecipe)
    local isItem
    local isMaterial
    local parameterList
    for _, info in pairs(infos) do

        if info.conditionType == nil or info.conditionType == 44 then
            self:DebugIfMarify("　　")
            self:Debug("　　txt=\"<<1>>\" (<<2>>/<<3>>)<<4>>", info.txt,
                                                               info.current,
                                                               info.max,
                                                               info.bulkMark)
            self:DebugIfMarify("　　convertedTxt=\"<<1>>\" (<<2>>/<<3>>)<<4>>", info.convertedTxt,
                                                                                info.current,
                                                                                info.max,
                                                                                info.bulkMark)
            --self:DebugIfMarify("　　questIdx=<<1>> stepIdx=<<2>> conditionIdx=<<3>> conditionType=<<4>>", info.questIdx,
            --                                                                          info.stepIdx,
            --                                                                          info.conditionIdx,
            --                                                                          tostring(info.conditionType))
        end

        isItem = self:IsValidAcquireItemConditions(info.current, info.max, info.isVisible, info.convertedTxt)
        isMaterial =  self:IsValidAcquireMaterialConditions(info.current, info.max, info.isVisible, info.convertedTxt)
        if self.isStationInteract then
            self:Debug("　　break Case3" .. tostring(tostring(info.convertedTxt)), self.checkColor)
            return
        end
        if isItem or isMaterial then
            if toHide then
                self.savedVariables.isDebug = false
            end
            parameterList = self:CreateParameter(info)
            if toHide then
                self.savedVariables.isDebug = true
            end
        end
        if self.isStationInteract then
            self:Debug("　　break Case4" .. tostring(tostring(info.convertedTxt)), self.checkColor)
            return
        end
        if isItem then
            self:AcquireItem(info, parameterList)
        end
        if isMaterial then
            self:AcquireMaterial(info, parameterList)
        end
    end
end




function DailyProvisioning:AcquireItem(info, parameterList)

    self:Debug("　　[AcquireItem]")
    if (info.current >= info.max) then
        self:Debug("　　　　>return (info.current >= info.max)")
        return
    end
    if #parameterList == 0 then
        self:Debug("　　　　>return (#parameterList == 0)")
        return
    end
    parameter = parameterList[1]
    if (not parameter.itemId) or parameter.itemId == 0 then
        self:Debug("　　　　>return (not parameter.itemId or parameter.itemId == 0)")
        return
    end


    local isWorkingByWritcreater = (not info.isMaster)
                                    and WritCreater
                                    and WritCreater:GetSettings().shouldGrab
                                    and WritCreater:GetSettings()[CRAFTING_TYPE_PROVISIONING]
                                    and (GetBankingBag() == BAG_BANK)
    local bagIdList = self:GetItemBagList()
    local moved = 0
    if isWorkingByWritcreater then
        moved = self:CountByItem(parameter.recipeLink, info.current, info.max, bagIdList)
    else
        moved = self:MoveByItem(parameter.recipeLink, info.current, info.max, bagIdList)
    end
    info.current = info.current + moved
    if info.uniqueId then
        self.savedVariables.reservations[info.uniqueId].current = info.current
    end
end




function DailyProvisioning:AcquireMaterial(info, parameterList)

    self:Debug("　　[AcquireMaterial]")
    if (info.current >= info.max) then
        return
    end
    if #parameterList == 0 then
        return
    end
    parameter = parameterList[1]
    if parameter.errorMsg and (not parameter.isKnown) then
        self:Debug("　　　　>return (<<1>>)", parameter.errorMsg)
        return
    end


    local comment = ""
    if self.savedVariables.bulkQuantity then
        info.max = math.max(info.max, self.savedVariables.bulkQuantity)
        comment = " [" .. GetString(DP_BULK_HEADER) .. "]"
    end
    local quantity = (info.max - info.current)
    self:Debug("　　　　<<1>> x <<2>> [<<3>>] <<4>>", parameter.recipeLink,
                                                      quantity,
                                                      table.concat(parameter.ingredientLinks, ", "),
                                                      comment)

    local bagIdList = self:GetHouseBankIdList()
    local amountToMake = self:GetAmountToMake(parameter.itemType)
    local totalMax = 4
    local total = 0
    for _, material in ipairs(parameter.ingredients) do
        local stack = self.stackList[material.itemId] or 0
        local houseStack = self.houseStackList[material.itemId] or 0
        local materialQuantity = math.ceil(material.quantity * quantity / amountToMake)
        local used = math.min(materialQuantity, stack)
        self.stackList[material.itemId] = stack - used

        --self:Debug("　　　　<<1>><<2>>", material.icon, material.itemLink)
        --self:Debug("　　　　　　material.quantity=<<1>>", material.quantity)
        --self:Debug("　　　　　　materialQuantity=<<1>>", materialQuantity)
        --self:Debug("　　　　　　stack=<<1>>", stack)
        --self:Debug("　　　　　　houseStack=<<1>>", houseStack)
        --self:Debug("　　　　　　UsedStack=<<1>>", used)
        local materialCurrent = (material.itemName and used) or materialQuantity
        self:Debug("　　　　<<1>>(<<2>>/<<3>>)  UsedStack x<<4>> HouseStack x<<5>>", material.itemLink,
                                                                                     stack,
                                                                                     materialQuantity,
                                                                                     used,
                                                                                     houseStack)
        local moved = self:MoveByItem(material.itemLink, materialCurrent, materialQuantity, bagIdList)
        if (moved + materialCurrent >= materialQuantity) then
            total = total + 1
        end
    end
    if (total >= totalMax) then
        info.current = info.max
    end
end




function DailyProvisioning:Camehome()

    if (not IsOwnerOfCurrentHouse()) then
        return
    end

    self:Debug("[Camehome]")
    self:OnOpenBank()
end




function DailyProvisioning:CountByItem(itemLink, current, max, bagIdList)

    if (not itemLink) then
        return 0
    end
    if current >= max then
        return 0
    end


    self:Debug("　　　　　　[CountByItem " .. itemLink .. " (" .. current .. " to " .. max .. ")]")
    local itemId = GetItemLinkItemId(itemLink)
    local counted = 0
    for _, bagId in ipairs(bagIdList) do
        if current >= max then
            return counted
        end

        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            if (current >= max) then
                return counted
            end
            if GetItemId(bagId, slotIndex) == itemId then
                itemLink = GetItemLink(bagId, slotIndex)    -- GetItemLink() ≠ GetRecipeResultItemLink()
                local _, stack = GetItemInfo(bagId, slotIndex)
                local quantity = math.min(max - current, stack)
                self:Debug(zo_iconFormat(GetItemLinkIcon(itemLink), 18, 18) .. itemLink .. " x " .. quantity)
                current = current + quantity
                counted = counted + quantity
            end
            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return counted
end




function DailyProvisioning:GetHouseBankIdList()

    local houseBankBagId = GetBankingBag()
    if GetInteractionType() == INTERACTION_BANK
        and IsOwnerOfCurrentHouse()
        and IsHouseBankBag(houseBankBagId) then
        return {houseBankBagId}

    elseif IsOwnerOfCurrentHouse() then
        return {BAG_HOUSE_BANK_ONE,
                BAG_HOUSE_BANK_TWO,
                BAG_HOUSE_BANK_THREE,
                BAG_HOUSE_BANK_FOUR,
                BAG_HOUSE_BANK_FIVE,
                BAG_HOUSE_BANK_SIX,
                BAG_HOUSE_BANK_SEVEN,
                BAG_HOUSE_BANK_EIGHT,
                BAG_HOUSE_BANK_NINE,
                BAG_HOUSE_BANK_TEN}
    end
    return {}
end




function DailyProvisioning:GetHouseStackList()

    if GetInteractionType() == INTERACTION_BANK then
        if (not IsOwnerOfCurrentHouse()) then
            return {}
        end
    end


    local list = {}
    for _, bagId in pairs(self:GetHouseBankIdList()) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            local itemType = GetItemType(bagId, slotIndex)
            if self:ContainsNumber(itemType, self.itemTypeFilter) then
                local itemId = GetItemId(bagId, slotIndex)
                local _, stack = GetItemInfo(bagId, slotIndex)
                local totalStack = list[itemId] or 0
                list[itemId] = totalStack + stack
            end

            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return list
end




function DailyProvisioning:IsValidAcquireItemConditions(current, max, isVisible, conditionText)

    if (not isVisible) then
        self:Debug("　　validAcquire=false", self.disabledColor)
        return false
    end
    if (not conditionText) or conditionText == "" then
        self:Debug("　　validAcquire=false", self.disabledColor)
        return false
    end


    if current < max then
        if self:Contains(conditionText, self:CraftingConditions()) then
            self:Debug("　　validAcquire=true")
            return true
        end
    end
    self:Debug("　　validAcquire=false", self.disabledColor)
    return false
end




function DailyProvisioning:IsValidAcquireMaterialConditions(current, max, isVisible, conditionText)

    if (not isVisible) then
        self:Debug("　　validMaterial=false", self.disabledColor)
        return false
    end
    if (not conditionText) or conditionText == "" then
        self:Debug("　　validMaterial=false", self.disabledColor)
        return false
    end


    if current < max then
        if self:Contains(conditionText, self:CraftingConditions()) then
            self:Debug("　　validMaterial=true")
            return true
        end
    end
    self:Debug("　　validMaterial=false", self.disabledColor)
    return false
end




function DailyProvisioning:MoveByItem(itemLink, current, max, bagIdList)

    if (not itemLink) then
        return 0
    end
    if current >= max then
        return 0
    end


    self:Debug("　　　　[MoveByItem " .. itemLink .. " (" .. current .. " to " .. max .. ")]")
    local itemId = GetItemLinkItemId(itemLink)
    local moved = 0
    for _, bagId in ipairs(bagIdList) do
        if current >= max then
            return moved
        end

        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            if (current >= max) then
                return moved
            end
            if GetItemId(bagId, slotIndex) == itemId then
                itemLink = GetItemLink(bagId, slotIndex)    -- GetItemLink() ≠ GetRecipeResultItemLink()
                local _, stack = GetItemInfo(bagId, slotIndex)
                local quantity = math.min(max - current, stack)

                if IsProtectedFunction("RequestMoveItem") then
                    CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BACKPACK, self.emptySlot, quantity)
                else
                    RequestMoveItem(bagId, slotIndex, BAG_BACKPACK, self.emptySlot, quantity)
                end
                local icon = zo_iconFormat(GetItemLinkIcon(itemLink), 18, 18)
                local comment = self.savedVariables.bulkQuantity and (" [" .. GetString(DP_BULK_HEADER) .. "]") or ""
                local msg = zo_strformat("<<1>><<2>> x <<3>><<4>>", icon, itemLink, quantity, comment)
                self:Message(msg)
                self.emptySlot = self:NextEmptySlot(BAG_BACKPACK, self.emptySlot)
                current = current + quantity
                moved = moved + quantity
            end
            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return moved
end




function DailyProvisioning:OnOpenBank()

    if (not self.savedVariables.isAcquireItem) then
        return
    end


    local acquireDelay = self.savedVariables.acquireDelay or 0
    zo_callLater(function()
        self:Debug("[OnOpenBank]")
        if DailyAlchemy and DailyAlchemy.isAcquire then
            zo_callLater(function()
                self:OnOpenBank()
            end, 1000)
        end
        if self.isStationInteract then
            self:Debug("[OnOpenBank] > No Call Acquire()")
            return
        end
        self.isAcquire = true
        self:Acquire()
        self.isAcquire = false
    end, acquireDelay * 1000)
end

