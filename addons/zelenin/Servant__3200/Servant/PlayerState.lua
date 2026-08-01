local class = ZO_InitializingCallbackObject:Subclass()
servantEventHandler = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sEventHandler", self.owner.name)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(eventCode)
        if self:IsAlive() then
            self:FireCallbacks("PLAYER_ALIVE")
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ALIVE, function(eventCode)
        if self:IsAlive() then
            self:FireCallbacks("PLAYER_ALIVE")
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_REINCARNATED, function(eventCode)
        if self:IsAlive() then
            self:FireCallbacks("PLAYER_ALIVE")
        end
    end)
end

function class:IsAlive()
    return not IsUnitDead("player") and not IsUnitReincarnating("player")
end

function class:IsBlocking()
    return IsBlockActive()
end

function class:IsRunning()
    return IsShiftKeyDown() and IsPlayerMoving()
end

function class:IsStunned()
    return IsPlayerStunned()
end

function class:InPvpZone()
    return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
end

function class:InCombat()
    return IsUnitInCombat("player")
end

function class:IsMounted()
    return IsMounted()
end
