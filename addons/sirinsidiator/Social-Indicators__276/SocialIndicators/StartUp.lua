local ADDON_NAME = "SocialIndicators"
local PLAYER_UNIT_TAG = "player"
local RANK_ICON = {}
RANK_ICON[1] = "SocialIndicators/images/adominion/guildleader.dds"
RANK_ICON[2] = "SocialIndicators/images/adominion/guildofficer.dds"
RANK_ICON[3] = "SocialIndicators/images/adominion/guildmember.dds"
RANK_ICON[4] = "SocialIndicators/images/adominion/guildrecruit.dds"
for i = 1, 12 do
	table.insert(RANK_ICON, string.format("SocialIndicators/images/adominion/misc%s%d.dds", (i < 10 and "0" or ""), i))
end

local nextEventHandleIndex = 1
local accountName = GetDisplayName()
local playerName = GetUnitName(PLAYER_UNIT_TAG)
local rawPlayerName = GetRawUnitName(PLAYER_UNIT_TAG)

SocialIndicators = {}

local function RegisterForEvent(event, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
	nextEventHandleIndex = nextEventHandleIndex + 1
	return eventHandleName
end

local function UnregisterForEvent(event, name)
	EVENT_MANAGER:UnregisterForEvent(name, event)
end

local messages = {}
local function LogDebug(message, ...)
	if CHAT_SYSTEM.primaryContainer then
		df("[%s] " .. message, ADDON_NAME, ...)
	else
		messages[#messages + 1] = {message, ...}
	end
end

local function FlushMessages()
	for i = 1, #messages do
		LogDebug(messages[i])
	end
	messages = {}
end

local function WrapFunction(object, functionName, wrapper)
	if(type(object) == "string") then
		wrapper = functionName
		functionName = object
		object = _G
	end
	local originalFunction = object[functionName]
	object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
	local eventHandle = ""
	eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
		if(name ~= ADDON_NAME) then return end
		FlushMessages()
		callback()
		UnregisterForEvent(event, name)
	end)
end

local function IsSelf(name)
	return (name == accountName or name == playerName or name == rawPlayerName)
end

-- IsFriend only recognizes display names and raw character names
-- because we might not know the real raw character name we just try all possible versions
local function SafeIsFriend(name)
	return IsFriend(name) or IsFriend(name .. "^Mx") or IsFriend(name .. "^Fx")
end

local function GetFinalGuildRankTextureCropped(guildId, rankIndex)
	local iconIndex = GetGuildRankIconIndex(guildId, rankIndex)
	return RANK_ICON[iconIndex]
end

local ICON_SIZE = 12
local FRIEND_ICON_TEXTURE = "SocialIndicators/images/adominion/friendicon.dds"
local ALLIANCE_FOLDER = {
	[ALLIANCE_DAGGERFALL_COVENANT] = "dcovenant",
	[ALLIANCE_EBONHEART_PACT] = "epact",
	[ALLIANCE_ALDMERI_DOMINION] = "adominion"
}

OnAddonLoaded(function()
	SocialIndicators.InitSettings()
	SocialIndicators.InitGuildMemberIndex()
	SocialIndicators.InitTargetIndicators()
	SocialIndicators.InitGroupIndicators()

	local oldGetRaidScoreNotificationMemberInfo = GetRaidScoreNotificationMemberInfo
	GetRaidScoreNotificationMemberInfo = function(notificationId, memberIndex)
		local displayName, characterName, isFriend, isGuildMember = oldGetRaidScoreNotificationMemberInfo(notificationId, memberIndex)

		local friendIcon = SafeIsFriend(displayName) and zo_iconFormat(FRIEND_ICON_TEXTURE, ICON_SIZE, ICON_SIZE) or ""

		local guildIcon, guildName = "", ""
		local guildId, memberIndex = SocialIndicators.GetPreferredGuildMemberIndexFromCharacterOrDisplayName(displayName)
		if(guildId) then
			local _, _, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
			local _, _, _, _, alliance = GetGuildMemberCharacterInfo(guildId, memberIndex)
			local texture = GetFinalGuildRankTextureCropped(guildId, rankIndex):gsub("adominion", ALLIANCE_FOLDER[alliance])
			guildIcon = zo_iconFormat(texture, ICON_SIZE, ICON_SIZE)
			guildName = " (" .. GetGuildName(guildId) .. ")"
		end

		displayName = friendIcon .. guildIcon .. displayName .. guildName
		return displayName, characterName, isFriend, isGuildMember
	end

	SocialIndicators_Data = SocialIndicators_Data or {}
	local saveData = SocialIndicators_Data[GetDisplayName()] or {}
	SocialIndicators_Data[GetDisplayName()] = saveData
	local db = SocialIndicators.PlayerDatabase:New({})
	local friendlistCollector = SocialIndicators.FriendlistCollector:New(db)
	local guildRosterCollector = SocialIndicators.GuildRosterCollector:New(db)
	local UnitCollector = SocialIndicators.UnitCollector:New(db)

	SocialIndicators.db = db
	SocialIndicators.flc = friendlistCollector -- TODO: clean up
	SocialIndicators.glc = guildRosterCollector
	SocialIndicators.uc = UnitCollector

	SocialIndicators.InitNameIndicators()
	SocialIndicators.InitPlayerDetailPopup()

    if(SocialIndicators_Settings.showSocialListFilterForIngameLists) then
        local filter = SocialIndicators.SocialListFilterFragment:New(saveData)
        --    filter:InitializeSocialListFiltering(SOCIAL_LIST_SCENE, socialListFragment)
        filter:InitializeFriendListFiltering()
        filter:InitializeGuildRosterFiltering()
    end

	-- the following code is not yet stable and has been disabled for 1.10
--	SocialIndicators.InitSocialList(db, saveData)
--	SocialIndicators.InitPlayerDetailScreen(db)

--	SLASH_COMMANDS["/siupdate"] = function()
--		local count = 0
--		d("[SocialIndicators] Updating all characters")
--		local char = SocialIndicators.CharacterData:New(db)
--		for characterName, data in pairs(db.characters) do
--			if(characterName and #characterName > 0) then
--				count = count + 1
--				if(db.characterDataCache[characterName]) then
--					db.characterDataCache[characterName]:Save()
--				else
--					char:Reset()
--					char:SetCharacterName(characterName)
--					char:Load(data)
--					char:Save()
--				end
--			end
--		end
--		df("[SocialIndicators] Updated %d characters", count)
--		count = 0
--		d("[SocialIndicators] Updating all players")
--		local player = SocialIndicators.PlayerData:New(db)
--		for displayName, data in pairs(db.players) do
--			if(displayName and #displayName > 0) then
--				count = count + 1
--				if(db.playerDataCache[displayName]) then
--					db.playerDataCache[displayName]:Save()
--				else
--					player:Reset()
--					player:SetDisplayName(displayName)
--					player:Load(data)
--					player:Save()
--				end
--			end
--		end
--		df("[SocialIndicators] Updated %d players", count)
--	end
--
--	SLASH_COMMANDS["/sistats"] = function()
--		df("[SocialIndicators] Tracking %d characters on %d players", NonContiguousCount(db.characters), NonContiguousCount(db.players))
--	end

--	SocialIndicators.InitStatsHelper(saveData, db, resurrectionHelper)
end)

SocialIndicators.RegisterForEvent = RegisterForEvent
SocialIndicators.IsSelf = IsSelf
SocialIndicators.SafeIsFriend = SafeIsFriend
SocialIndicators.GetFinalGuildRankTextureCropped = GetFinalGuildRankTextureCropped
SocialIndicators.LogDebug = LogDebug
SocialIndicators.WrapFunction = WrapFunction
