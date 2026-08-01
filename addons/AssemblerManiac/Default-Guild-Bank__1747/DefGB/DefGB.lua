-- AssemblerManiac Default Guild Bank selector

local GuildBanks = {}

DefGB = DefGB or {}
DefGB.version = "1.07"

local LAM2 = LibAddonMenu2
if LAM2 == nil then return end

function DefGB:GetSettings()
	if DefGB.global.saveSettingsGlobally then
		return DefGB.global
	else
		return DefGB.settings
	end
end

local function DefGB_OnPlayerLoaded()
	if not DefGB.DefGBSet then
		zo_callLater(function()
			PLAYER_INVENTORY.lastSuccessfulGuildBankId = DefGB.defaultGuildBankID
			DefGB.DefGBSet = true
			if DefGB:GetSettings().showReminder then
				d("Default guild bank set to " .. DefGB:GetSettings().defaultGuildBank)
			end
		end, 2000)
	end
end


function DefGB:GetGuildBanks()
	local i
	local GBList = {}
	for i = 1, GetNumGuilds() do
		local id = GetGuildId(i)
		local guildName = GetGuildName(id)
		GuildBanks[guildName] = id
		table.insert(GBList, guildName)
	end

	return GBList
end

function DefGB:CreateOptionsMenu()
	local panelData = {
		type = "panel",
		name = "Default Guild Bank",
		displayName = "Default Guild Bank",
		author = "Assembler Maniac",
		version = self.version,
		slashCommand = "/defgb",	--(optional) will register a keybind to open to this panel
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true	--boolean (optional) (will set all options controls back to default values)
	}

	LAM2:RegisterAddonPanel("DefGB_OptionsPanel", panelData)

	local optionsData =
		{
			{
			type = "header",
			name = "Settings",
			},
			{
			type = "checkbox",
			name = "Use same settings for all characters?",
			getFunc = function() return DefGB.global.saveSettingsGlobally end,
			setFunc = function(value)
				DefGB.global.saveSettingsGlobally = value
			end
			},
			{ -- dropdown begin
			type = "dropdown",
			name = 'Default Guild Bank',
			tooltip = 'Select Guild Bank to be Default when logging on',

			choices = DefGB:GetGuildBanks(),
			getFunc = function() return DefGB:GetSettings().defaultGuildBank end,
			setFunc = function(choice) DefGB:GetSettings().defaultGuildBank = choice end
			}, -- dropdown end
			{
			type = "checkbox",
			name = "Show reminder at logon?",
			getFunc = function() return DefGB.global.showReminder end,
			setFunc = function(value)
				DefGB.global.showReminder = value
			end
			},
		}

	LAM2:RegisterOptionControls("DefGB_OptionsPanel", optionsData)

end


local function DefGB_OnLoad(eventCode, addOnName)
	if (addOnName ~= "DefGB") then
		return
	end

	local defaultGlobal = {
		saveSettingsGlobally = true,
		defaultGuildBank = "",
		showReminder = true
		}

	local defaultSettings = {
		defaultGuildBank = "",
		showReminder = true
		}

	local worldName = GetWorldName():gsub(" Megaserver", "")

	DefGB.oldGlobal = ZO_SavedVars:NewAccountWide("DefGB_Globals", 1, "global",  nil)
	DefGB.global = ZO_SavedVars:NewAccountWide("DefGB_Globals", 1, "global_" .. worldName,  defaultGlobal)
	if DefGB.oldGlobal and DefGB.oldGlobal.showReminder ~= nil then
		DefGB.global.saveSettingsGlobally = DefGB.oldGlobal.saveSettingsGlobally
		DefGB.global.defaultGuildBank = DefGB.oldGlobal.defaultGuildBank
		DefGB.global.showReminder = DefGB.oldGlobal.showReminder

		DefGB.oldGlobal.saveSettingsGlobally = nil
		DefGB.oldGlobal.defaultGuildBank = nil
		DefGB.oldGlobal.showReminder = nil
	else

		DefGB.oldGlobal = nil
	end

	DefGB.settings = ZO_SavedVars:NewCharacterIdSettings("DefGB_Settings", 1, "settings", defaultSettings)

	if DefGB.global.showReminder == nil then
		DefGB.global.showReminder = true
		DefGB.settings.showReminder = true
	end

	DefGB:CreateOptionsMenu()

	local i, id, found = false
	for i = 1, GetNumGuilds() do
		id = GetGuildId(i)
		if GetGuildName(id) == DefGB:GetSettings().defaultGuildBank then
			DefGB.defaultGuildBankID = id
			found = true
		end
	end

	if not found then
		DefGB.defaultGuildBankID = GetGuildId(1)
		DefGB:GetSettings().defaultGuildBank = GetGuildName(GetGuildId(1))
	end

	DefGB.DefGBSet = false

	EVENT_MANAGER:UnregisterForEvent("DefGB_Load", EVENT_ADD_ON_LOADED)

end

EVENT_MANAGER:RegisterForEvent("DefGB_PLAYER_LOADED", EVENT_PLAYER_ACTIVATED, DefGB_OnPlayerLoaded)
EVENT_MANAGER:RegisterForEvent("DefGB_Load", EVENT_ADD_ON_LOADED, DefGB_OnLoad)


--[[
guild bank functions
GetSelectedGuildBankId()
GetNumGuilds
GetGuildName
GetGuildId
--]]
