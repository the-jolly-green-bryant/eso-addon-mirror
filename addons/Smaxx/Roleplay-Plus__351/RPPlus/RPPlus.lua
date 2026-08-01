local defaults = {
	replaceUserId = false,
	colorOOC = false
}

local gdefaults = {}

local storage
local tstorage = {chars = {}}
local gstorage = {nicks = {}}

tstorage.chars = tstorage.chars or {}
gstorage.nicks = gstorage.nicks or {}

local function T(v, t, f)
	if v then return t else return f end
end

local function readFriends()
	for i = 1, GetNumFriends() do
		local name = GetFriendInfo(i)
		local char, cname = GetFriendCharacterInfo(i)
		if char and cname then
			tstorage.chars[name] = {
				["name"] = cname:match("[^%^]+"),
				["gender"] = T(cname:match("%^.") == "^M", 0, 1)
			}
		end
	end
end

local function updateFriendZone(id, player, char, zone)
	tstorage.chars[player] = {
		["name"] = char:match("[^%^]+"),
		["gender"] = T(char:match("%^.") == "^M", 0, 1)
	}
end

local function updateFriendStatus(id, player, prev, curr)
	if curr == PLAYER_STATUS_OFFLINE then
		tstorage.chars[player] = nil
	else
		for i = 1, GetNumFriends() do
			local name = GetFriendInfo(i)
			if name == player then
				local char, cname = GetFriendCharacterInfo(i)
				if char and cname then
					tstorage.chars[name] = {
						["name"] = cname:match("[^%^]+"),
						["gender"] = T(cname:match("%^.") == "^M", 0, 1)
					}
				end
			end
		end
	end
end

local function readGuilds()
	for i = 1, GetNumGuilds() do
		local gid = GetGuildId(i)
		for j = 1, GetNumGuildMembers(gid) do
			local name = GetGuildMemberInfo(gid, j)
			local char, cname = GetGuildMemberCharacterInfo(gid, j)
			if char and cname then
				tstorage.chars[name] = {
					["name"] = cname:match("[^%^]+"),
					["gender"] = T(cname:match("%^.") == "^M", 0, 1)
				}
			end
		end
	end
end

local function updateMemberZone(id, gid, player, char, zone)
	tstorage.chars[player] = {
		["name"] = char:match("[^%^]+"),
		["gender"] = T(char:match("%^.") == "^M", 0, 1)
	}
end

local function updateMemberStatus(id, gid, player, prev, curr)
	if curr == PLAYER_STATUS_OFFLINE then
		tstorage.chars[player] = nil
	else
		for j = 1, GetNumGuildMembers(gid) do
			local name = GetGuildMemberInfo(gid, j)
			if name == player then
				local char, cname = GetGuildMemberCharacterInfo(gid, j)
				if char and cname then
					tstorage.chars[name] = {
						["name"] = cname:match("[^%^]+"),
						["gender"] = T(cname:match("%^.") == "^M", 0, 1)
					}
				end
			end
		end
	end
end

local function processName(channel, name)
	local char = tstorage.chars[name]
	if storage.replaceUserId and name:sub(1, 1) == "@" and char and char.name then
		return char.name
	end
	return name
end

local function nickCommand(params)
	local search, replace = params:match("^(@%w+)%s+(.+)")
	if not search then
		d("Syntax: /nick @UserID [new nickname]")
		return
	end
	
	gstorage.nicks[search] = replace
	if replace then
		d(string.format('"!%s" is the new nickname of %s.', replace, search))
	else
		d(string.format("%s's nickname has been cleared.", search))
	end
end

local function setup(id, name)
	if name ~= "RPPlus" then return end
	EVENT_MANAGER:UnregisterForEvent("RPP", EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("RPP", EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, updateMemberZone)
	EVENT_MANAGER:RegisterForEvent("RPP", EVENT_FRIEND_CHARACTER_ZONE_CHANGED, updateFriendZone)
	EVENT_MANAGER:RegisterForEvent("RPP", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, updateMemberStatus)
	EVENT_MANAGER:RegisterForEvent("RPP", EVENT_FRIEND_PLAYER_STATUS_CHANGED, updateFriendStatus)

	storage = ZO_SavedVars:New("RPPlus", 1, nil, defaults)
	gstorage = ZO_SavedVars:NewAccountWide("RPPlus", 1, nil, gdefaults)

	-- delete old leftovers
	if storage.chars then storage.chars = nil end

	readGuilds()
	readFriends()

	local LAM = LibStub:GetLibrary("LibAddonMenu-1.0")
	local RPPpanel = LAM:CreateControlPanel("RPP_OptionsPanel", "Roleplay Plus")
		LAM:AddHeader(RPPpanel, "RPP_ChatHeader", "Chat Configuration")
		LAM:AddCheckbox(RPPpanel, "RPP_ChatReplaceUserId", "Replace @UserIDs", "Replace the @UserIDs where a character name is known (guild members and friends)", function() return storage.replaceUserId end, function(value) storage.replaceUserId = value end)
		--LAM:AddCheckbox(RPPpanel, "RPP_ChatColorOOC", "Colorice OOC lines", "Try to colorize all OOC lines.", function() return storage.colorOOC end, function(value) storage.colorOOC = value end, hasSpamFilter, "This function is incompatible with the SpamFilter addon. This will be fixed in a future version.")
	
	local LC = LibStub('libChat-1.0')
	LC:registerName(processName)
	
	-- Still unfinished
	--SLASH_COMMANDS["/nick"] = nickCommand
end

EVENT_MANAGER:RegisterForEvent("RPP", EVENT_ADD_ON_LOADED, setup)