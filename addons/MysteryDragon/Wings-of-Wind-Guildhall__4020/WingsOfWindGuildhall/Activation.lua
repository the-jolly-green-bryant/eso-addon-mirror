local WindsGH = WingsOfWindGuildhall

WindsGH.GUILD_ID = 535822

local deactivated = false

function WindsGH.isDeactivated()
    return deactivated
end

local function shouldBeDeactivated()
    local rankName = WindsGH.Util.GetPlayerRankNameInGuild(WindsGH.GUILD_ID)

    return rankName == nil or rankName == "Invited" or rankName == "Miracle of Wind"
end

local function refreshActivationState()
    local isDeactivatedNow = shouldBeDeactivated()

    if isDeactivatedNow and not WindsGH.isDeactivated() then
        deactivated = true
        WindsGH.callbackManager:FireCallbacks(WindsGH.EVENTS.DEACTIVATED)
    elseif not isDeactivatedNow and WindsGH.isDeactivated() then
        deactivated = false
        WindsGH.callbackManager:FireCallbacks(WindsGH.EVENTS.ACTIVATED)
    end
end

local function initialize()
    WindsGH.callbackManager:UnregisterCallback(WindsGH.EVENTS.INITIALIZED, initialize)

    deactivated = shouldBeDeactivated()

    EVENT_MANAGER:RegisterForEvent(WindsGH.NAME, EVENT_GUILD_PLAYER_RANK_CHANGED, refreshActivationState)
end

WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.INITIALIZED, initialize)
