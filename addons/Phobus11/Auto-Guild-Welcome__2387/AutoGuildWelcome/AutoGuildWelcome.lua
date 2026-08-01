local ADDON_NAME = "AutoGuildWelcome"
local ADDON_AUTHOR = "|c990000Phobus11|r"
local ADDON_VERSION = "0.2.0"
local ADDON_TITLE = "Auto Welcome Guild Members"
local ADDON_TITLE_DISPLAY = "|c00FF20Auto Welcome Guild Members|r"
local ADDON_SAVEDVARS = "AutoGuildWelcome_Settings"

AGW = {}
local AGW = AGW

AGW.Settings = {}

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

local LAM = LibAddonMenu2
if LAM == nil and LibStub then LAM = LibStub('LibAddonMenu-2.0') end


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
	else
		d("No guild match")
	end
end
			
-- ===============================================================================
-- Build options menu
-- ===============================================================================
local function buildMenu()

	local bval = 1
	local msg = 1
	
	local panelData = {
		type = "panel",
		name = ADDON_TITLE,
		displayName = ADDON_TITLE_DISPLAY,
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel(ADDON_NAME .. "Options", panelData)

	local optionsTable = {}

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

	LAM:RegisterOptionControls(ADDON_NAME .. "Options", optionsTable)
	
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
