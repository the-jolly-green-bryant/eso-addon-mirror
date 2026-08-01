GuildNotificator = GuildNotificator or {}

local ADDON_NAME = "GuildNotificator"
local ADDON_VERSION = "1.0.1"
local ADDON_AUTHOR = "@Llether"

local gn = GuildNotificator
local lcm = LibChatMessage('GNotif', "gn")
local lam2 = LibAddonMenu2

-- isOnlineManager table
local isOnlineManager = {}
local db

-- Defaults SV values
local defaults = {
	friendorguild = 2,
	notifintab = 2,
}

-- Display Message in system tab or where chat category is displayed
local function DisplayInTab(guildId, displayedMessage)

	local category
	-- to match categories
	if guildId >= 1 and guildId <= 5 then
		category = guildId + 9
		-- can be > 5 if reorganized, so use CHAT_CATEGORY_SYSTEM
	else
		category = CHAT_CATEGORY_SYSTEM
	end

	-- Can occur if event is before EVENT_PLAYER_ACTIVATED
	if CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then
		-- TODO Should display in the right tab
		lcm:Print(displayedMessage)
	end

end

-- Will notify a friend login/logout if needed
local function NotifyFriend(displayName, message, newStatus)

	-- Per default, showMessage is displayed
	local showMessage = true

	-- if friendorguild = 1, friend is always displayed
	if db.friendorguild == 2 then

		-- Do we need to display message?
		for guild = 1, GetNumGuilds() do

			-- Avoid some loops
			if showMessage then

				-- Guildname
				local guildId = GetGuildId(guild)
				local guildName = GetGuildName(guildId)

				-- Occurs sometimes
				if(not guildName or (guildName):len() < 1) then
					guildName = "Guild " .. guildId
				end

				-- Only if notification activated for guild X
				if db[guildName].notify then
					-- Get account name and character name
					local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
					if memberIndex then
						showMessage = false
					end
				end
			end
		end
	end
end

-- Executed when EVENT_FRIEND_PLAYER_STATUS_CHANGED triggers
local function FormatFriendPlayerStatus(displayName, characterName, oldStatus, newStatus)

	local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
	local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

	-- DisplayName is linkable
	local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
	-- CharacterName is linkable
	local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)

	-- Not connected before and Connected now (no messages for Away/Busy)
	if not wasOnline and isOnline then
		NotifyFriend(displayName, zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink), true)
	-- Connected before and Offline now
	elseif wasOnline and not isOnline then
		NotifyFriend(displayName, zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink), false)
	end

end

-- Format Message in tabs
local function DisplayNotif(message, guildId, guildName, account, displayNameLink, characterNameLink, newStatus)
	local displayedMessage = db[guildName].customcolor .. zo_strformat(message, displayNameLink, characterNameLink) .. "|r"

	if db.notifintab == 1 then
		lcm:Print(displayedMessage)
	elseif db.notifintab == 2 then
		DisplayInTab(guildId, displayedMessage)
	else
		DisplayInTab(guildId, displayedMessage)
	end

end

-- Runs whenever a guild member changes status
-- Display guild notification if needed
-- Strip my notification and multiGuilds too
local function OnGuildMemberPlayerStatusChanged(_, guildId, account, prevStatus, currStatus)

	-- Not for me
	if account ~= GetDisplayName() then

		-- Get GuildName
		local guildName = GetGuildName(guildId)

		-- Occurs sometimes (still exists in One Tamriel)
		if guildName and (guildName):len() > 0 then
			-- If IsFriend and friendorguild, do not show
			if IsFriend(account) and db.friendorguild == 1 then
				return
			elseif db[guildName].notify then

				local wasOnline = prevStatus ~= PLAYER_STATUS_OFFLINE
				local isOnline = currStatus ~= PLAYER_STATUS_OFFLINE

				local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, account)
				local _, characterName = GetGuildMemberCharacterInfo(guildId, memberIndex)

				-- DisplayName is linkable
				local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(account)
				-- CharacterName is linkable
				local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)

				-- Not connected before and Connected now (no messages for Away/Busy)
				if(not wasOnline and isOnline and (isOnlineManager[account] == nil or isOnlineManager[account] == false)) then
					DisplayNotif(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, guildId, guildName, account, displayNameLink, characterNameLink, true)
				elseif(wasOnline and not isOnline and (isOnlineManager[account] == nil or isOnlineManager[account])) then
					DisplayNotif(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, guildId, guildName, account, displayNameLink, characterNameLink, false)
				end

				-- Update isOnlineManager to avoid multiguild message.
				isOnlineManager[account] = isOnline

			end
		end
	end
end

local function OnPlayerActivated()

	-- TODO maybe rework all this thing
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_FRIEND_PLAYER_STATUS_CHANGED, FormatFriendPlayerStatus)

	-- Unregisters
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)

end

-- Build LAM Menu
local function BuildMenu()

	-- Convert a colour from "|cABCDEF" form to [0,1] RGB form.
	local function getColour(colourString)
		local r=tonumber(string.sub(colourString, 3, 4), 16)
		local g=tonumber(string.sub(colourString, 5, 6), 16)
		local b=tonumber(string.sub(colourString, 7, 8), 16)
		return r/255, g/255, b/255, 1
	end

	-- Used to reset colors to default value, lam need a formatted array
	local function defaultColour(chanCode)
		local r, g, b = GetChatCategoryColor(chanCode)
		return {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = 1}
	end

	-- Convert a decimal number in [0,255] to a hexadecimal number.
	local function d2h(n)
		local str = "0123456789abcdef"
		local l = string.sub(str, math.floor(n/16)+1, math.floor(n/16)+1)
		local r = string.sub(str, n%16 + 1, n%16 + 1)
		return l..r
	end

	-- Turn a ([0,1])^3 RGB colour to "|cABCDEF" form.
	local function makeColour(r, g, b)
		r = math.floor(255*r)
		g = math.floor(255*g)
		b = math.floor(255*b)
		return "|c"..d2h(r)..d2h(g)..d2h(b)
	end

	-- Start adding elements to control panel
	local optionsTable = {}

	-- Config per guild now
	local guildindex = 0

	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "header",
		name = GetString(GNOTIF_OPTIONS_H),
		width = "full",
	}

	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "dropdown",
		name = GetString(GNOTIF_NOTIFINTAB),
		tooltip = GetString(GNOTIF_NOTIFINTAB_TT),
		choices = {GetString(GNOTIF_NOTIFINTAB1), GetString(GNOTIF_NOTIFINTAB2)},
		getFunc = function()
			if db.notifintab == 1 then
				return GetString(GNOTIF_NOTIFINTAB1)
			elseif db.notifintab == 2 then
				return GetString(GNOTIF_NOTIFINTAB2)
			else
				return GetString(GNOTIF_NOTIFINTAB2)
			end
		end,
		setFunc = function(choice)
			if choice == GetString(GNOTIF_NOTIFINTAB1) then
				db.notifintab = 1
			elseif choice == GetString(GNOTIF_NOTIFINTAB2) then
				db.notifintab = 2
			else
				db.notifintab = 2
			end
		end,
		width = "full",
		default = defaults.notifintab,
	}

	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "dropdown",
		name = GetString(GNOTIF_FRIENDORGUILD),
		tooltip = GetString(GNOTIF_FRIENDORGUILD_TT),
		choices = {GetString(GNOTIF_FRIENDORGUILD1), GetString(GNOTIF_FRIENDORGUILD2)},
		getFunc = function()
			if db.friendorguild == 1 then
				return GetString(GNOTIF_FRIENDORGUILD1)
			elseif db.friendorguild == 2 then
				return GetString(GNOTIF_FRIENDORGUILD2)
			else
				return GetString(GNOTIF_FRIENDORGUILD2)
			end
		end,
		setFunc = function(choice)
			if choice == GetString(GNOTIF_FRIENDORGUILD1) then
				db.friendorguild = 1
			elseif choice == GetString(GNOTIF_FRIENDORGUILD2) then
				db.friendorguild = 2
			else
				db.friendorguild = 2
			end
		end,
		width = "full",
		default = defaults.friendorguild,
	}

	for guild = 1, GetNumGuilds() do

		-- Guildname
		local guildId = GetGuildId(guild)
		local guildName = GetGuildName(guildId)

		-- Occurs sometimes
		if(not guildName or (guildName):len() < 1) then
			guildName = "Guild " .. guild
		end

		local defaultcolor = defaultColour(guild+9)

		-- 1st launch & New Guild
		if not db[guildName] then
			db[guildName] = {}
			db[guildName].notify = true
			local r, g, b = GetChatCategoryColor(guild+9)
			db[guildName].customcolor = makeColour(r, g, b)
		end

		-- One submenu / guild
		guildindex = guildindex + 1
		optionsTable[guildindex] = {
			type = "header",
			name = guildName,
			width = "full",
		}

		guildindex = guildindex + 1
		optionsTable[guildindex] = {
			type = "checkbox",
			name = GetString(GNOTIF_NOTIFY),
			tooltip = GetString(GNOTIF_NOTIFY_TT),
			getFunc = function() return db[guildName].notify end,
			setFunc = function(newValue) db[guildName].notify = newValue end,
			width = "full",
			default = true,
		}

		guildindex = guildindex + 1
		optionsTable[guildindex] = {
			type = "colorpicker",
			name = GetString(GNOTIF_CUSTOMCOLOR),
			tooltip = GetString(GNOTIF_CUSTOMCOLOR_TT),
			getFunc = function() return getColour(db[guildName].customcolor) end,
			setFunc = function(r, g, b) db[guildName].customcolor = makeColour(r, g, b) end,
			default = defaultcolor,
			disabled = function()
				if not db[guildName].notify then
					return true
				else
					return false
				end
			end,
		}

	end

	lam2:RegisterOptionControls("GuildNotificatorNewOptions", optionsTable)

end

-- Runs whenever "me" join a new guild
local function NewGuild()
	-- It will rebuild optionsTable and recreate tables
	BuildMenu()
end

function gn.Initialize()
	-- Create control panel
	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = ZO_HIGHLIGHT_TEXT:Colorize(ADDON_NAME),
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	lam2:RegisterAddonPanel("GuildNotificatorNewOptions", panelData)

	-- Build Menu, if reorganization trigger, it can display corrects values if LAM wasn't loaded before
	BuildMenu()

	-- TODO make this work again
	-- Because ChatSystem is loaded after EVENT_ADD_ON_LOADED, we use EVENT_PLAYER_ACTIVATED
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

	-- Register OnGuildMemberPlayerStatusChanged with EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildMemberPlayerStatusChanged)

	-- To Rebuild LAM
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_JOINED_GUILD, NewGuild)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_SELF_LEFT_GUILD, NewGuild)
end

-------------------------------------------------------------------------------------------------
--  Initialize  --
-------------------------------------------------------------------------------------------------
function gn.OnAddOnLoaded(event, addonName)
	-- Fetch the saved variables
	db = ZO_SavedVars:NewAccountWide('GNOTIFICATOR', 1, nil, defaults)

	if addonName == ADDON_NAME then
		gn.Initialize()
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, gn.OnAddOnLoaded)
