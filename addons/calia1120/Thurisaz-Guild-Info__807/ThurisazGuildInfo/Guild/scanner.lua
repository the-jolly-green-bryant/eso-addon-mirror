-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use parts of my AddOns for your own work, please contact me first!

--Scans all guild members and stores information about them
TI.SCANNER = {}

---Save character Info
local function insertMemberInfo(guildName, accName, characterName, class, alliance, level, vRank)
	level = level or 0
	vRank = vRank or 0
	characterName = TI:clearName(characterName)

	if(not TI.vars.guildMembers[guildName]) then
		TI.vars.guildMembers[guildName] = {}
	end

	if(not TI.vars.guildMembers[guildName][accName]) then
		TI.vars.guildMembers[guildName][accName] = {}
	end

	local charInfo = { charName = characterName, class = class, level = level, veteranRank = vRank}


	if(not TI.vars.guildMembers[guildName][accName][alliance]) then
		TI.vars.guildMembers[guildName][accName][alliance] = charInfo
	else -- else for better reading! don't make a mess here ;-)
		if(         TI.vars.guildMembers[guildName][accName][alliance].level          <= level
				and TI.vars.guildMembers[guildName][accName][alliance].veteranRank    <= vRank) then
			TI.vars.guildMembers[guildName][accName][alliance] = charInfo
		end
	end

end

local function scanGuild(guildId, OnlyThisAccount)
	local guildName = GetGuildName(guildId)

	for memberId = 1, GetNumGuildMembers(guildId) do
		local accName = GetGuildMemberInfo(guildId, memberId)
		if( OnlyThisAccount == nil or accName == OnlyThisAccount) then
			local hasCharacter, characterName, _, classType, alliance, level, championPoints = GetGuildMemberCharacterInfo(guildId, memberId)
			if(hasCharacter == true) then
				insertMemberInfo(guildName, accName, characterName, classType, alliance, level, championPoints)
			end
		end
	end
end

local function scanAllGuilds()
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		scanGuild(guildId)
	end
end

---Remove all data of a guild from Saved Vars
local function removeGuildData(guildId)
	local guildName = GetGuildName(guildId)
	TI.vars.guildMembers[guildName] = nil
end

---Remove all data of Account in specific guild
local function removeAccountData(guildId, AccName)
	local guildName = GetGuildName(guildId)
	if(TI.vars.guildMembers[guildName] and TI.vars.guildMembers[guildName][AccName]) then
		TI.vars.guildMembers[guildName][AccName] = nil
	end

end

---Event Handler for Status Change of Guild Member!
local function OnGuildMemberStatusChange(eventid, guildId, AccName, oldStatus, newStatus)
	if(oldStatus == PLAYER_STATUS_OFFLINE) then
		scanGuild(guildId,AccName)
	end
end
---Event Handler for Member Added to guild
local function OnMemberAdded(eventid, guildId, AccName)
	scanGuild(guildId,AccName)
end

---Event handler for Member Removed form guild
local function OnMemberRemoved(eventid, guildId, AccName)
	removeAccountData(guildId, AccName)
end

---Event handler for Member level or champion points changed
local function OnMemberLevelChanged(eventid, guildId, AccName )
	scanGuild(guildId,AccName)
end

local function GetMainChar(guildId, accName)
	local guildName = GetGuildName(guildId)
	if(TI.vars.guildMembers[guildName] and TI.vars.guildMembers[guildName][accName]) then
		return  TI.vars.guildMembers[guildName][accName]
	end
	return {}
end

function TI.SCANNER.GetTooltipString(guildId, accName)
	local tooltiptext = ""
	for allianceId, value in pairs(GetMainChar(guildId, accName)) do

		tooltiptext = tooltiptext .. "\r\n" -- newline

		local levelString
		if(value.veteranRank > 0) then
			levelString = value.veteranRank.." CP"
		else
			levelString = value.level
		end

		tooltiptext = tooltiptext .. ("%s: %s (%s)"):format( TI:clearName(GetAllianceName(allianceId)), value.charName, levelString)
	end
	return tooltiptext
end

--Initialize the Scanner, do first run and register event
function TI.SCANNER.Initialize()
	scanAllGuilds()

	EVENT_MANAGER:RegisterForEvent("TGI_Scanner", EVENT_GUILD_SELF_JOINED_GUILD, function(_, guildId) scanGuild(guildId) end)
	EVENT_MANAGER:RegisterForEvent("TGI_Scanner", EVENT_GUILD_SELF_LEFT_GUILD, function(_, guildId) removeGuildData(guildId) end)

	EVENT_MANAGER:RegisterForEvent("TGI_Scanner", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildMemberStatusChange) --EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED
	EVENT_MANAGER:RegisterForEvent("TGI_Scanner", EVENT_GUILD_MEMBER_ADDED, OnMemberAdded) --EVENT_GUILD_MEMBER_ADDED
	EVENT_MANAGER:RegisterForEvent("TGI_Scanner", EVENT_GUILD_MEMBER_REMOVED, OnMemberRemoved) --EVENT_GUILD_MEMBER_ADDED

	EVENT_MANAGER:RegisterForEvent("TGI_Scanner", EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED, OnMemberLevelChanged) --EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED
	EVENT_MANAGER:RegisterForEvent("TGI_Scanner", EVENT_GUILD_MEMBER_CHARACTER_CHAMPION_POINTS_CHANGED, OnMemberLevelChanged) 
end
