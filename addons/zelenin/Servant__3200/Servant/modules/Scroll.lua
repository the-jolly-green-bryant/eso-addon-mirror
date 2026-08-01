local class = ZO_InitializingObject:Subclass()
servantScroll = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sScroll", self.owner.name)

    self.scroll = servantScrollLibrary:New()

    self.ScrollHandler = LibHandler:Limiter(function()
        self:Check()
    end, 1000, true)
    self.playerAliveHandler = function()
        self.ScrollHandler:Trigger()
    end

    self:Start(self.owner.settings.data.scroll)
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
        self.ScrollHandler:Trigger()
    end)

    self.owner.eventHandler:RegisterCallback("PLAYER_ALIVE", self.playerAliveHandler)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
        if not inCombat then
            self:Check()
        end
    end)
end

function class:stop()
    EVENT_MANAGER:UnregisterForUpdate(self.name)
    self.owner.eventHandler:UnregisterCallback("PLAYER_ALIVE", self.playerAliveHandler)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE)
end

function class:Check()
    if IsUnitInCombat("player") or SCENE_MANAGER:GetCurrentSceneName() == "tribute" then
        return
    end

    local isApAbilityExists = false
    local isExpAbilityExists = false
    local isPelinalAbilityExists = false

    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
        if self.scroll:IsApAbility(abilityId) then
            isApAbilityExists = true
        end
        if self.scroll:IsExpAbility(abilityId) then
            isExpAbilityExists = true
        end
        if self.scroll:IsPelinalAbility(abilityId) then
            isPelinalAbilityExists = true
        end
    end

    if not isApAbilityExists then
        self:use(self.owner.settings.data.scrollAp[self.owner.settings.currentCharacterId], false)
    end
    if not isExpAbilityExists then
        self:use(self.owner.settings.data.scrollExp[self.owner.settings.currentCharacterId], false)
    end
    if self.owner.settings.data.scrollPelinal and not isPelinalAbilityExists then
        self:use(self.scroll.pelinalScroll.itemLink, true)
    end
end

function class:getByItemLink(itemLink)
    for slotIndex in ZO_IterateBagSlots(BAG_BACKPACK) do
        if itemLink == GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_BRACKETS) then
            return slotIndex
        end
    end

    return nil
end

function class:use(itemLink, notify)
    if itemLink == "" or itemLink == nil then
        if notify then
            self.owner:Log(string.format("Set your scrolls."))
        end
        return
    end

    local bagId = BAG_BACKPACK

    local slotIndex = self:getByItemLink(itemLink)
    if slotIndex == nil then
        self.owner:Error(string.format("No scroll in inventory: %s.", itemLink))
        return
    end

    self.owner:TryUseItem(bagId, slotIndex)
end
