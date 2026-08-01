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
AGW.ConsoleMenu = {}
AGW.Defaults = {
	welcome = {false, false, false, false, false},
	message = {
		"Welcome %1 to guild 1",
		"Welcome %1 to guild 2",
		"Welcome %1 to guild 3",
		"Welcome %1 to guild 4",
		"Welcome %1 to guild 5"
	}
}

local GuildCount = GetNumGuilds()
local GuildNames = {}
local GuildNumbers = {}

-- LHAS for console only
if not IsConsoleUI() then return end
local LHAS = LibHarvensAddonSettings

AGW.ConsoleMenu = LHAS:AddAddon(ADDON_TITLE_DISPLAY,{
	allowDefaults = false,
	allowRefresh = false,
})

if not AGW.ConsoleMenu then
    return
end

-- ===============================================================================1
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
-- Build LHAS options menu
-- ===============================================================================		
local function buildMenu()
	-- Not in any guilds? JOIN SOME! Also for debug since I keep forgetting how my own addon works
	if GuildCount < 1 then
		AGW.ConsoleMenu:AddSetting({
			type = LibHarvensAddonSettings.ST_SECTION,
			label = "YOU ARE NOT IN ANY GUILDS! Use Guild Finder to join some guilds!",
		})
	else -- if you ARE in at least 1 guild
		for i = 1, GuildCount do
		
			AGW.ConsoleMenu:AddSetting({
				type = LHAS.ST_CHECKBOX,
				label = GuildNames[GetGuildId(i)],
				tooltip = "Enable welcome message for this guild",
				default = AGW.Defaults.welcome[i],
				setFunction = function(choice) AGW.Settings.welcome[i] = choice end,
				getFunction = function() return AGW.Settings.welcome[i] end,
			})
			
			AGW.ConsoleMenu:AddSetting({
				type = LHAS.ST_EDIT,
				label = "",
				tooltip = "Text to place in guild chat",
				maxChars = 300,
				default = AGW.Defaults.message[i],
				setFunction = function(text) AGW.Settings.message[i] = text end,
				getFunction = function() return AGW.Settings.message[i] end,
			})
		end
	end
end
-- ===============================================================================
-- Addon Init
-- ===============================================================================
function OnAddonLoaded(event, addon)
	if addon ~= ADDON_NAME then return end
	
	GatherGuildInfo()
		
	AGW.Settings = ZO_SavedVars:NewAccountWide(ADDON_SAVEDVARS, SAVED_VARS_VERSION, "Settings", AGW.Defaults)

	buildMenu()
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GUILD_MEMBER_ADDED, addWelcomeToChat)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)