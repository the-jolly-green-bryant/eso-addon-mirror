local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolverBattleground = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolverBattleground", self.owner.name)

    self.scanHandler = LibHandler:Limiter(function()
        self:scan()
    end, 50, true)

    self:eventHandlers()
    self:scan()
end

function class:eventHandlers()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_KILL, function(eventCode, killedPlayerCharacterName, killedPlayerDisplayName, killedPlayerBattlegroundAlliance, killingPlayerCharacterName, killingPlayerDisplayName, killingPlayerBattlegroundAlliance, battlegroundKillType, killingAbilityId)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, function(eventCode)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_STATE_CHANGED, function(eventCode, previousState, currentState)
        self.scanHandler:Trigger()
    end)
end

function class:scan()
    for index = 1, GetNumScoreboardEntries() do
        local characterName, displayName, _, _ = GetScoreboardEntryInfo(index)
        self.owner:AddDisplayName(characterName, displayName)
    end
end
