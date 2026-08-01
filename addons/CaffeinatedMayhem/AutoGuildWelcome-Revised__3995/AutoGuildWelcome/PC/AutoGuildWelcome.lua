local ADDON_NAME = "AutoGuildWelcome"
local ADDON_AUTHOR = "CaffeinatedMayhem,Phobus11"
local ADDON_VERSION = "1.21"
local SAVED_VARS_VERSION = "2"
local ADDON_TITLE = "Auto Welcome Guild Members"
local ADDON_TITLE_DISPLAY = "Auto Welcome Guild Members"
local ADDON_SAVEDVARS = "AutoGuildWelcome_Settings"

AGW = {}
local AGW = AGW

AGW.Settings = {}
AGW.Defaults = {
	init = true,
	welcome = {false, false, false, false, false},
	message = {
		"Welcome %1 to guild 1",
		"Welcome %1 to guild 2",
		"Welcome %1 to guild 3",
		"Welcome %1 to guild 4",
		"Welcome %1 to guild 5",
	}
}

local GuildCount = GetNumGuilds()
local GuildNames = {}
local GuildNumbers = {}

-- LAM not for use on console
if IsConsoleUI() then return end

local LAM = LibAddonMenu2

-- ===============================================================================
-- Load guild names and IDs into tables
-- ===============================================================================
local function GatherGuildInfo()
	if GuildCount < 1 then return end
	for i = 1, GuildCount do
		local guildID = GetGuildId(i)
		GuildNames[guildID] = GetGuildName(guildID)
		GuildNumbers[guildID] = i
		d(GuildNumbers[guildID] .. ": " ..guildID .. " " .. GuildNames[guildID])
	end
end

-- ===============================================================================
-- Welcome our newest member
-- ===============================================================================
function addWelcomeToChat(_, gId, pName)
	local gNum = GuildNumbers[gId]
	local msg = AGW.Settings.message[gNum]

	if AGW.Settings.welcome[gNum] == true then
		--d("Welcoming for this guild")
		local welcome = "/g" .. gNum .. " " .. string.gsub(msg, "%%1", pName)
		ZO_ChatWindowTextEntryEditBox:SetText(welcome)
	--else
		--d("No guild match")
	end
end

-- ===============================================================================
-- Build LAM options menu
-- ===============================================================================
 local function buildMenu()

	local bval = 1
	local msg = 1
	
	local panelName = ADDON_NAME.."Options"
	local panelData = {
		type = "panel",
		name = ADDON_TITLE,
		displayName = ADDON_TITLE_DISPLAY,
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsTable = {}
	-- Not in any guilds? JOIN SOME! Also for debug since I keep forgetting how my own addon works
	if GuildCount < 1 then
		optionsTable[1] = {
			type = "header",
			name = "You are not in any guilds! ",
			width = "full",
		}
		optionsTable[2] = {
			type = "description",
			text = "Use Guild Finder to join some guilds!",
			width = "full",	
		}	
	else
		for i = 1, GuildCount do
			local gId = GetGuildId(i)
			optionsTable[#optionsTable+1] = {
				type = "checkbox",
				name = GuildNames[gId],
				tooltip = "Enable welcome message for this guild",
				getFunc = function() return AGW.Settings.welcome[i] end,
				setFunc = function(choice) AGW.Settings.welcome[i] = choice end,
				width = "half",
				default = AGW.Defaults.welcome[i],
			}
			optionsTable[#optionsTable+1] = {
				type = "editbox",
				name = "",
				tooltip = "Text to place in guild chat",
				isMultiline = true,
				isExtraWide = true,
				getFunc = function() return AGW.Settings.message[i] end,
				setFunc = function(text) AGW.Settings.message[i] = text end,
				width = "half",
				default = AGW.Defaults.message[i],
			}
		end
	end

	LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsTable)
end

-- ===============================================================================
-- Load addon into memory
-- ===============================================================================
function OnAddonLoaded(event, addon)

	if addon ~= ADDON_NAME then return end
	
	GatherGuildInfo()

	AGW.Settings = ZO_SavedVars:NewAccountWide(ADDON_SAVEDVARS, ADDON_VERSION, "Settings", AGW.Defaults)

	buildMenu()
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_MEMBER_ADDED, addWelcomeToChat)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
