FishBreaker = {
    displayName = "|c3CB371" .. "Fish Breaker" .. "|r",
    shortName = "FB",
    name = "FishBreaker",
    version = "1.0.0",

    boxList = {
        [43757]  = "|H0:item:43757:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",    -- Wet Gunny Sack
        [140443] = "|H0:item:140443:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",   -- Waterlogged Psijic Satchel
        [139011] = "|H0:item:139011:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",   -- Pyandonean Bottle
    },

    callList = {},
    callTask = nil,
}




function FishBreaker:GetItemSlotIndex(uniqueId)

    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        if Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex)) == uniqueId then
            return slotIndex
        end

        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end
    return nil
end




function FishBreaker:Call(uniqueId, delay)

    self:Debug("[Call(<<1>>)]", tostring(uniqueId), self.checkColor)
    if uniqueId == nil and #self.callList == 0 then
        return
    end


    self:Indent()
    if uniqueId then
        self:Debug("Add callList <<1>>", uniqueId)
        table.insert(self.callList, uniqueId)
    end


    if IsUnitInCombat("player") then
        self:Debug(">ReCall:inCombat")
        self:Outdent()
        return
    end
    if self.callTask then
        self:Debug(">isCalld")
        self:Outdent()
        return
    end


    if delay == nil then
        delay = 2000
    end
    self:Debug("Call Start")
    self.callTask = LibAsync:Create("Check DefTable")
    self.callTask:Delay(delay, function(task)

        local slotIndex
        task:Call(function(task)
            --self:DebugIfMarify("#self.callList=" .. tostring(#self.callList))
            if #self.callList > 0 then
                self:Debug("--- callList ---")
                for i, nextUniqueId in pairs(self.callList) do
                    slotIndex = self:GetItemSlotIndex(nextUniqueId)
                    if slotIndex then
                        self:Debug("<<1>>:<<2>>", i, tostring(nextUniqueId))
                    else
                        self:Debug("<<1>>:<<2>>", i, tostring(nextUniqueId), self.disabledColor)
                        table.remove(self.callList, i)
                    end
                end
            end

        end):Then(function(task)
            --self:Debug("---------------", self.checkColor)
            task:For(pairs(self.callList)):Do(function(i, nextUniqueId)
                slotIndex = self:GetItemSlotIndex(nextUniqueId)
                if slotIndex then
                    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                    if itemLink and itemLink ~= "" then
                        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ITEM_ON_COOLDOWN, function(...)
                            zo_callLater(function()
                                self:Debug("COOLDOWN > ReCall")
                                self:Indent()
                                self:Call()
                                self:Outdent()
                            end, 1000 * 2)
                        end)

                        FishBreaker:Debug(">Open <<1>>:<<2>>:<<3>>", i, nextUniqueId, itemLink, self.checkColor)
                        if IsProtectedFunction("UseItem") then
                            CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex)
                        else
                            UseItem(BAG_BACKPACK, slotIndex) 
                        end
                        LibAsync:GetCurrent():Cancel()
                        self.callTask = nil
                        self:Outdent()
                        return
                    end
                end
            end)

        end):Then(function()
            EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ITEM_ON_COOLDOWN)
            self:Debug("Call End", self.checkColor)
            self.callTask = nil
            self:Outdent()
        end)
    end)

end




function FishBreaker:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    setmetatable(FishBreaker, {__index = LibMarify})
    self:IndentClear()


    self.savedVariables = ZO_SavedVars:NewAccountWide("FishBreakerVariables", 1, nil, {})
    self.savedVariables.debugLog = {}


    EVENT_MANAGER:RegisterForEvent(self.name,  EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  function(...) self:SlotUpdate(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:RegisterForEvent(self.name,  EVENT_LOOT_UPDATED,                  function(...) self:LootWindowUpdate(...) end)


    -- ItemLink to ItemName
    for itemId, itemLink_ in pairs(self.boxList) do
        self.boxList[itemId] = GetItemLinkName(itemLink_)
    end
    zo_callLater(function()
        for itemId, itemName in pairs(self.boxList) do
            self:Debug("<<1>>:<<2>>", itemId, itemName)
        end
    end, 3000)

end
EVENT_MANAGER:RegisterForEvent(FishBreaker.name, EVENT_ADD_ON_LOADED, function(...) FishBreaker:OnAddOnLoaded(...) end)




function FishBreaker:SlotUpdate(eventCode, bagId, slotIndex, isNew)

    if bagId ~= BAG_BACKPACK then
        return
    end

    if (not isNew) then
        return
    end

    local itemId = GetItemId(bagId, slotIndex)
    if itemId == 0 then
        return
    end


    local itemLink = GetItemLink(bagId, slotIndex)
    self:Debug("[SlotUpdate]" .. tostring(itemLink))
    self:Indent()

    if itemId == 64222 then
        local txt = zo_strformat("<<1>>!", itemLink)
        self:Message(txt)
        self:Outdent()
        return
    end


    local itemType = GetItemType(bagId, slotIndex)
    if itemType == ITEMTYPE_FISH then
        local uniqueId = Id64ToString(GetItemUniqueId(bagId, slotIndex))
        self:Call(uniqueId, 0)
        self:Outdent()
        return
    end

    if itemType == ITEMTYPE_CONTAINER and self.boxList[itemId] then
        local uniqueId = Id64ToString(GetItemUniqueId(bagId, slotIndex))
        self:Debug("箱(釣り):" .. tostring(itemLink))
        self:Call(uniqueId, 0)
        self:Outdent()
        return
    end
    self:Outdent()
end




function FishBreaker:LootWindowUpdate()

    local lootName, targetType, actionName, isOwned = GetLootTargetInfo()
    if targetType ~= INTERACT_TARGET_TYPE_ITEM then
        return
    end

    self:Debug("[UpdateLootWindow]")
    self:Indent()

    self:Debug("lootName=\"<<1>>\"",    tostring(lootName))
    --self:Debug("actionName=<<1>>",  tostring(actionName))
    --self:Debug("isOwned=<<1>>",     tostring(isOwned))
    local targetTypeLabel = {
        [INTERACT_TARGET_TYPE_ITEM]         = INTERACT_TARGET_TYPE_ITEM .. ":ITEM",
        [INTERACT_TARGET_TYPE_NONE]         = INTERACT_TARGET_TYPE_NONE .. ":NONE",
        [INTERACT_TARGET_TYPE_QUEST_ITEM]   = INTERACT_TARGET_TYPE_QUEST_ITEM .. ":QUEST_ITEM",
        [INTERACT_TARGET_TYPE_COLLECTIBLE]  = INTERACT_TARGET_TYPE_COLLECTIBLE .. ":COLLECTIBLE",
    }
    if targetType and targetTypeLabel[targetType] then
        self:Debug("targetType=<<1>>",  targetTypeLabel[targetType])
    else
        self:Debug("targetType=<<1>>",  tostring(targetType))
    end


    for key, value in pairs(self.boxList) do
        --self:Debug("value=\"<<1>>\"", value)
        if value == lootName then
            self:Debug("> LootAll()")
            LootAll()
            EndLooting()
            zo_callLater(function()
                LootAll()
                EndLooting()
            end, 2000)
            self:Outdent()
            return
        end
    end
    self:Outdent()
end

