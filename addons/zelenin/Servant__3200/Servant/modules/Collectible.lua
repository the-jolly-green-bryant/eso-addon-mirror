local class = ZO_InitializingObject:Subclass()
servantCollectible = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sCollectible", self.owner.name)

    self.collectible = servantScrollCollectible:New()
    self.condition = false

    self.CollectibleHandler = LibHandler:Limiter(function()
        self:Check()
    end, 1000, true)
    self.playerAliveHandler = function()
        self.CollectibleHandler:Trigger()
    end

    self:Start(self.owner.settings.data.collectible)
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
        self.CollectibleHandler:Trigger()
    end)

    self.owner.eventHandler:RegisterCallback("PLAYER_ALIVE", self.playerAliveHandler)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
        self.CollectibleHandler:Trigger()
    end)
end

function class:stop()
    EVENT_MANAGER:UnregisterForUpdate(self.name)
    self.owner.eventHandler:UnregisterCallback("PLAYER_ALIVE", self.playerAliveHandler)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE)
end

function class:Check()
    local abilities = {}
    local collectibles = {}
    for collectibleId, abilityId in pairs(self.collectible.items) do
        if self.owner.settings.data.collectibles[collectibleId] == true then
            abilities[abilityId] = collectibleId
            collectibles[collectibleId] = abilityId
        end
    end

    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
        if abilities[abilityId] ~= nil then
            collectibles[abilities[abilityId]] = nil
            abilities[abilityId] = nil
        end
    end

    for collectibleId, _ in pairs(collectibles) do
        self:checkCondition(collectibleId)
    end
end

function class:checkCondition(id)
    if not self:isValid(id) or self.condition == true then
        return
    end

    self.condition = true

    LibHandler:Condition(
        function()
            return self:readyToUse(id)
        end,
        function()
            local result = self:use(id)
            self.condition = false
            return result
        end,
        200
    )
end

function class:isValid(id)
    if not IsCollectibleUnlocked(id) then
        self.owner:Error(string.format("%s is not unlocked.", GetCollectibleLink(id, LINK_STYLE_BRACKETS)))
        return false
    end

    if IsCollectibleBlacklisted(id) then
        self.owner:Error(string.format("%s is blacklisted.", GetCollectibleLink(id, LINK_STYLE_BRACKETS)))
        return false
    end

    if IsCollectibleBlocked(id) then
        self.owner:Error(string.format("Can not use %s. %s", GetCollectibleLink(id, LINK_STYLE_BRACKETS), GetString("SI_COLLECTIBLEUSAGEBLOCKREASON", GetCollectibleBlockReason(id))))
        return false
    end

    if not IsCollectibleUsable(id) then
        self.owner:Error(string.format("%s is not usable.", GetCollectibleLink(id, LINK_STYLE_BRACKETS)))
        return false
    end

    return true
end

function class:use(id)
    self.owner:Log(string.format("Using %s…", GetCollectibleLink(id, LINK_STYLE_BRACKETS)))
    UseCollectible(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

function class:readyToUse(id)
    local playerState = self.owner.eventHandler:IsAlive() and
        not self.owner.eventHandler:IsBlocking() and
        not self.owner.eventHandler:IsRunning() and
        not self.owner.eventHandler:IsStunned() and
        not self.owner.eventHandler:InCombat() and
        not self.owner.eventHandler:IsMounted() and
        SCENE_MANAGER:GetCurrentSceneName() ~= "tribute"

    if not playerState then
        return false
    end

    local cooldownRemaining, cooldownDuration = GetCollectibleCooldownAndDuration(id)
    if cooldownRemaining > 0 and cooldownDuration > 0 then
        return false
    end

    return true
end
