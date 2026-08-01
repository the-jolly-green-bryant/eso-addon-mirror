-- ArcTech_Guild.lua
ArcTech = ArcTech

function IsGuildMember()
	local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do
		local guildId = GetGuildId(i)
		if guildId == ArcTech.guild_id then
			return true
		end
	end
	return false
end

function IsOfficer()
    local guildId = ArcTech.guild_id

    local DisplayName = GetDisplayName()

    local numMembers = GetNumGuildMembers(guildId)
    for i = 1, numMembers do
        local name, note, rankIndex = GetGuildMemberInfo(guildId, i)

        if name == DisplayName then
            local hasAdmin =
                DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_MANAGE_APPLICATIONS)
                or DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_INVITE)

            return hasAdmin
        end
    end

    return false
end

function CanApplyToGuild()
	return not IsGuildMember()
end

function ApplyToGuild(message)
    local res = SubmitGuildFinderApplication(ArcTech.guild_id, message)

    d(res)

    if GUILD_APPLICATION_RESPONSE_SUCCESS and res == GUILD_APPLICATION_RESPONSE_SUCCESS then
        d("|c00ff00Application submitted successfully.|r")
        return
    end

    if GUILD_APPLICATION_RESPONSE_ALREADY_APPLIED and res == GUILD_APPLICATION_RESPONSE_ALREADY_APPLIED then
        d("|cffff00You already have a pending application.|r")
        return
    end

    if GUILD_APPLICATION_RESPONSE_ALREADY_IN_GUILD and res == GUILD_APPLICATION_RESPONSE_ALREADY_IN_GUILD then
        d("|cffff00You are already in this guild.|r")
        return
    end

    if GUILD_APPLICATION_RESPONSE_GUILD_NOT_FOUND and res == GUILD_APPLICATION_RESPONSE_GUILD_NOT_FOUND then
        d("|cFF0000Guild not found in Guild Finder (may not be listed).|r")
        return
    end

    if res == 0 then
        d("|c00ff00Application submitted, a guild officer will review your application shortly!|r")
    else
        d("|cFF0000Application may have failed. Result code: " .. tostring(res) .. "|r")
    end
end

function GetMemberRankByName(guildId, displayName)

    local numMembers = GetNumGuildMembers(guildId)

    for i = 1, numMembers do
        local name = GetGuildMemberInfo(guildId, i)

        if name == displayName then

            local rankIndex = GetGuildMemberRankIndex(guildId, i)
            local rankName = GetGuildRankCustomName(guildId, rankIndex)

            return rankIndex, rankName
        end
    end

    return nil, nil
end