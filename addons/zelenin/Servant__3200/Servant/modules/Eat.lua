local class = ZO_InitializingObject:Subclass()
servantEat = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sEat", self.owner.name)

    self.foodDrink = servantFoodDrinkLibrary:New()
    self.condition = false

    self.EatHandler = LibHandler:Limiter(function()
        self:Check()
    end, 1000, true)
    self.playerAliveHandler = function()
        self.EatHandler:Trigger()
    end

    self:Start(self.owner.settings.data.eat)
end

function class:Start(turnOn)
    if turnOn then
        self:start()
    else
        self:stop()
    end
end

function class:start()
    self:Check()

    EVENT_MANAGER:RegisterForUpdate(self.name, 1 * ZO_ONE_MINUTE_IN_MILLISECONDS, function()
        self.EatHandler:Trigger()
    end)

    self.owner.eventHandler:RegisterCallback("PLAYER_ALIVE", self.playerAliveHandler)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
        self.EatHandler:Trigger()
    end)
end

function class:stop()
    EVENT_MANAGER:UnregisterForUpdate(self.name)
    self.owner.eventHandler:UnregisterCallback("PLAYER_ALIVE", self.playerAliveHandler)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE)
end

function class:Check()
    local foodDrinkRemaining = nil
    local apBoosterRemaining = nil
    local expBoosterRemaining = nil

    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
        if self.foodDrink:IsFoodDrinkAbility(abilityId) then
            foodDrinkRemaining = (timeEnding - GetFrameTimeSeconds()) / 60
        end
        if self.foodDrink:IsApBoosterAbility(abilityId) then
            apBoosterRemaining = (timeEnding - GetFrameTimeSeconds()) / 60
        end
        if self.foodDrink:IsExpBoosterAbility(abilityId) then
            expBoosterRemaining = (timeEnding - GetFrameTimeSeconds()) / 60
        end
    end

    if foodDrinkRemaining == nil or foodDrinkRemaining < self.owner.settings.data.minEat then
        if self.owner.eventHandler:InPvpZone() then
            local itemLink = self.owner.settings.data.foodPvp[self.owner.settings.currentCharacterId]
            if itemLink == "" or itemLink == nil then
                self.owner:Log(string.format("Set your PVP food."))
            else
                local bagId, slotIndex, amount = self:getByItemLink(itemLink)
                self:checkCondition(bagId, slotIndex, amount)
            end
        else
            if (self.owner.settings.data.instanceOnly and IsUnitInDungeon("player")) or not self.owner.settings.data.instanceOnly then
                local itemLink = self.owner.settings.data.foodPve[self.owner.settings.currentCharacterId]
                if itemLink == "" or itemLink == nil then
                    self.owner:Log(string.format("Set your PVE food."))
                else
                    local bagId, slotIndex, amount = self:getByItemLink(itemLink)
                    self:checkCondition(bagId, slotIndex, amount)
                end
            end
        end
    end
    if apBoosterRemaining == nil then
        if self.owner.eventHandler:InPvpZone() then
            local itemLink = self.owner.settings.data.foodAp[self.owner.settings.currentCharacterId]
            if itemLink == "" or itemLink == nil then
                --self.owner:Log(string.format("Set your AP food."))
            else
                local bagId, slotIndex, amount = self:getByItemLink(itemLink)
                self:checkCondition(bagId, slotIndex, amount)
            end
        end
    end
    if expBoosterRemaining == nil then
        local itemLink = self.owner.settings.data.foodExp[self.owner.settings.currentCharacterId]
        if itemLink == "" or itemLink == nil then
            --self.owner:Log(string.format("Set your exp food."))
        else
            local bagId, slotIndex, amount = self:getByItemLink(itemLink)
            self:checkCondition(bagId, slotIndex, amount)
        end
    end
end

function class:getByItemLink(itemLink)
    if itemLink == "" or itemLink == nil then
        return nil, nil
    end

    local bagId = BAG_BACKPACK
    local bagSlotIndex = nil
    local amount = 0
    for slotIndex in ZO_IterateBagSlots(bagId) do
        if itemLink == GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS) then
            local stack, maxStack = GetSlotStackSize(BAG_BACKPACK, slotIndex)
            bagSlotIndex = slotIndex
            amount = amount + stack
        end
    end

    if amount > 0 then
        return bagId, bagSlotIndex, amount
    end

    return nil, nil, amount
end

function class:checkCondition(bagId, slotIndex, amount)
    if not self:isValid(bagId, slotIndex) or self.condition == true then
        return
    end

    self.condition = true

    LibHandler:Condition(
        function()
            return self:readyToUse(bagId, slotIndex)
        end,
        function()
            local result = self:use(bagId, slotIndex, amount)
            self.condition = false
            return result
        end,
        200
    )
end

function class:isValid(bagId, slotIndex)
    if bagId == nil or slotIndex == nil then
        self.owner:Error(string.format("No food in inventory."))
        return false
    end

    return true
end

function class:use(bagId, slotIndex, amount)
    self.owner:Log(string.format("Using %s (left: %d)…", GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS), amount-1))

    if IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", bagId, slotIndex)
    else
        UseItem(bagId, slotIndex)
    end
end

function class:readyToUse(bagId, slotIndex)
    local playerState = self.owner.eventHandler:IsAlive() and
        not self.owner.eventHandler:IsBlocking() and
        not self.owner.eventHandler:IsRunning() and
        not self.owner.eventHandler:IsStunned() and
        not self.owner.eventHandler:InCombat() and
        not self.owner.eventHandler:IsMounted()

    if not playerState then
        return false
    end

    local remain, duration = GetItemCooldownInfo(bagId, slotIndex)
    if remain > 0 and duration > 0 then
        return false
    end

    return true
end
