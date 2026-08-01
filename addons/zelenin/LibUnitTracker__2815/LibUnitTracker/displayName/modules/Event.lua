local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolverEvent = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolverEvent", self.owner.name)

    self:eventHandlers()
end

function class:eventHandlers()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_AVENGE_KILL, function(eventCode, avengedCharacterName, killedCharacterName, avengedDisplayName, killedDisplayName)
        self.owner:AddDisplayName(avengedCharacterName, avengedDisplayName)
        self.owner:AddDisplayName(killedCharacterName, killedDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_REVENGE_KILL, function(eventCode, killedCharacterName, killedDisplayName)
        self.owner:AddDisplayName(killedCharacterName, killedDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAT_MESSAGE_CHANNEL, function(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
        self.owner:AddDisplayName(fromName, fromDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_FINISHED, function(eventCode, duelResult, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
        self.owner:AddDisplayName(opponentCharacterName, opponentDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_INVITE_FAILED, function(eventCode, reason, targetCharacterName, targetDisplayName)
        self.owner:AddDisplayName(targetCharacterName, targetDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_INVITE_RECEIVED, function(eventCode, inviterCharacterName, inviterDisplayName)
        self.owner:AddDisplayName(inviterCharacterName, inviterDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_INVITE_SENT, function(eventCode, inviteeCharacterName, inviteeDisplayName)
        self.owner:AddDisplayName(inviteeCharacterName, inviteeDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLEDGE_OF_MARA_OFFER, function(eventCode, targetCharacterName, isSender, targetDisplayName)
        self.owner:AddDisplayName(targetCharacterName, targetDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLEDGE_OF_MARA_RESULT, function(eventCode, reason, targetCharacterName, targetDisplayName)
        self.owner:AddDisplayName(targetCharacterName, targetDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RESURRECT_REQUEST, function(eventCode, requesterCharacterName, timeLeftToAccept, requesterDisplayName)
        self.owner:AddDisplayName(requesterCharacterName, requesterDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RESURRECT_RESULT, function(eventCode, targetCharacterName, result, targetDisplayName)
        self.owner:AddDisplayName(targetCharacterName, targetDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADE_INVITE_CONSIDERING, function(eventCode, inviterCharacterName, inviterDisplayName)
        self.owner:AddDisplayName(inviterCharacterName, inviterDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADE_INVITE_FAILED, function(eventCode, reason_, inviteeCharacterName, inviteeDisplayName)
        self.owner:AddDisplayName(inviteeCharacterName, inviteeDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADE_INVITE_WAITING, function(eventCode, inviteeCharacterName, inviteeDisplayName)
        self.owner:AddDisplayName(inviteeCharacterName, inviteeDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, function(eventCode)
        local characterName = GetUnitName("reticleover")
        local displayName = GetUnitDisplayName("reticleover")

        self.owner:AddDisplayName(characterName, displayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED, function(eventCode)
        local characterName = GetUnitName("reticleoverplayer")
        local displayName = GetUnitDisplayName("reticleoverplayer")

        self.owner:AddDisplayName(characterName, displayName)
    end)
end
