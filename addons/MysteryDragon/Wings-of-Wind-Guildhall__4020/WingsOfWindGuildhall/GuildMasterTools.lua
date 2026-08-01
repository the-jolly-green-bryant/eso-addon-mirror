local WindsGH = WingsOfWindGuildhall

local ZONE_VAULTS_OF_MADNESS = 11

local ZONE_FOR_JOINING = ZONE_VAULTS_OF_MADNESS

local GUILD_RANK_NAME_TO_PROMOTE = "Miracle of Wind"

local function promote()
    local allGroupMemberTags = WindsGH.Util.GetGroupUnitTags()

    local promotedCount = 0

    for _, unitTag in ipairs(allGroupMemberTags) do
        local unitZoneId = WindsGH.Util.GetUnitTagZoneId(unitTag)
        local groupMemberName = GetUnitDisplayName(unitTag)

        if unitZoneId == ZONE_FOR_JOINING and groupMemberName then
            local rankName = WindsGH.Util.GetRankNameInGuild(WindsGH.GUILD_ID, groupMemberName)

            if rankName == GUILD_RANK_NAME_TO_PROMOTE then
                if GetDisplayName() == "@Viralissa" then
                    GuildPromote(WindsGH.GUILD_ID, groupMemberName)

                    d(groupMemberName .. " promoted to " .. WindsGH.Util.GetRankNameInGuild(WindsGH.GUILD_ID, groupMemberName))
                else
                    d(groupMemberName .. " would be promoted")
                end

                promotedCount = promotedCount + 1
            end
        end
    end

    if promotedCount == 0 then
        d("No one to promote")
    end
end

local function onPlayerActivated()
    local zoneId = WindsGH.Util.GetPlayerZoneId()

    if zoneId == ZONE_FOR_JOINING then
        SLASH_COMMANDS["/promote"] = promote
    else
        SLASH_COMMANDS["/promote"] = nil
    end
end

local function initialize()
    WindsGH.callbackManager:UnregisterCallback(WindsGH.EVENTS.INITIALIZED, initialize);

    local playerName = GetDisplayName()

    if playerName ~= "@Viralissa" and playerName ~= "@Arrvis" then
        return
    end

    EVENT_MANAGER:RegisterForEvent(WindsGH.NAME .. "GuildMasterTools", EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.INITIALIZED, initialize);
