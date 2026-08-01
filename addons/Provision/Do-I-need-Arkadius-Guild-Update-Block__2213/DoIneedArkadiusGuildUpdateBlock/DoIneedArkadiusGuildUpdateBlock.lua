local function DoIneedAGUB_OnPlayerActivated(eventCode, initial)
    local eventList = { "OnGuildMemberCharacterUpdated", "OnGuildMemberCharacterZoneChanged", "OnGuildMemberCharacterLevelChanged",
    "OnGuildMemberCharacterChampionPointsChanged", "OnGuildMemberRankChanged", "OnGuildMemberPlayerStatusChanged",
    "OnGuildMemberNoteChanged", "OnGuildRanksChanged", "OnUpdate" }

    local function createMyFunction(event)
        local original = GUILD_ROSTER_MANAGER[event]
        GUILD_ROSTER_MANAGER[event] = function(self, ...)
            local a = GetGameTimeMilliseconds()
            original(self, ...)
            local out = ""

            for _, arg in ipairs({...}) do
                out = out .. " " .. arg
            end
            d(("%s %s ms"):format(event, GetGameTimeMilliseconds() - a) .. "   : " .. out)
        end
    end

    for _, event in ipairs(eventList) do
        createMyFunction(event)
    end

    d("DoIneedAGUB enabled.")
end

EVENT_MANAGER:RegisterForEvent("DoIneedAGUB", EVENT_PLAYER_ACTIVATED, DoIneedAGUB_OnPlayerActivated)
