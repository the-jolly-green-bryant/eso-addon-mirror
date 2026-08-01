local ADDON = DefaultLanguageNinja
local LAM = LibAddonMenu2

--------
-- in this file local use, private
--------

local function getPanelInfo()
	return {
		type = "panel",
		name = ADDON.NAME,
		displayName = ADDON.DISPLAY_NAME,
		author = ADDON.AUTHOR,
		version = ADDON.VERSION,
		registerForRefresh = true
	}
end

local function getUserDefinedLangCode_Char1(key)
	local defaultSaveData = ADDON.GetDefaultSaveData()
	return {
		type = "dropdown",
		name = "Char1",
		tooltip = "",
		width = "half",
		choices = ADDON.USER_DEFINED_CHAR.CHOICES,
		choicesValues = ADDON.USER_DEFINED_CHAR.VALUES,
		getFunc = function()
			return ADDON.SaveData.UserDefinedLangCode[key].Char1
		end,
		setFunc = function(state)
			ADDON.SaveData.UserDefinedLangCode[key].Char1 = state
		end,
		default = defaultSaveData.UserDefinedLangCode[key].Char1
	}
end

local function getUserDefinedLangCode_Char2(key)
	local defaultSaveData = ADDON.GetDefaultSaveData()
	return {
		type = "dropdown",
		name = "Char2",
		tooltip = "",
		width = "half",
		choices = ADDON.USER_DEFINED_CHAR.CHOICES,
		choicesValues = ADDON.USER_DEFINED_CHAR.VALUES,
		getFunc = function()
			return ADDON.SaveData.UserDefinedLangCode[key].Char2
		end,
		setFunc = function(state)
			ADDON.SaveData.UserDefinedLangCode[key].Char2 = state
		end,
		default = defaultSaveData.UserDefinedLangCode[key].Char2
	}
end

local function getUserDefinedLangCode_LoadCommand(key)
	return {
		type = "button",
		name = "Load UserDefined" .. key .. " Now",
		width = "half",
		tooltip = "",
		func = function()
			local userDefinedLangCode = ADDON.GetUserDefinedLangCode(key)
			if (userDefinedLangCode) then
				ADDON.LoadLangCodeAndReload(userDefinedLangCode)
			else
				ADDON.d("not defined yet.")
			end
		end,
		warning = "reload ui"
	}
end

local function getUserDefinedLangCode_DiaplayButton(key)
	local defaultSaveData = ADDON.GetDefaultSaveData()
	return {
		type = "checkbox",
		name = "Display Button",
		tooltip = "",
		width = "half",
		getFunc = function()
			return ADDON.SaveData.Display.Buttons["LoadUserDefined" .. key .. "Now"]
		end,
		setFunc = function(state)
			ADDON.SaveData.Display.Buttons["LoadUserDefined" .. key .. "Now"] = state
			ADDON.UI.Restore()
		end,
		warning = false,
		default = defaultSaveData.Display.Buttons["LoadUserDefined" .. key .. "Now"]
	}
end

local function getOptionTable()
	local defaultSaveData = ADDON.GetDefaultSaveData()
	return {
		{
			type = "header",
			name = "Global"
		},
		{
			type = "checkbox",
			name = "Accountwide",
			tooltip = "[NOTICE] LastAccess timestamp and LastLangCode are also shared.",
			width = "half",
			getFunc = function()
				return ADDON.SaveDataGlobal.AcrossAccounts
			end,
			setFunc = function(state)
				ADDON.SaveDataGlobal.AcrossAccounts = state
				ADDON.LoadSavedVariables()
			end,
			warning = false,
			default = defaultSaveData.AcrossAccounts
		},
		{
			type = "checkbox",
			name = "ShowMessageOnInit",
			tooltip = "To show this addon's name at chat window when player are activated.\n" ..
				"If you have been installed so many addons, I think the setting will help you.",
			width = "half",
			getFunc = function()
				return ADDON.SaveDataGlobal.ShowMessageOnInit
			end,
			setFunc = function(state)
				ADDON.SaveDataGlobal.ShowMessageOnInit = state
			end,
			warning = false,
			default = defaultSaveData.ShowMessageOnInit
		},
		{
			type = "header",
			name = "Timer"
		},
		{
			type = "slider",
			name = "LoadingAfterThisMinutes",
			tooltip = "Your ReloadUI action within this time from LastAccess doesn't trigger to load default language.\n" ..
				"LastAccess timestamp is updated while you play. but it is kept to a minimum.\n" ..
					"\n[NOTICE] Conversely, If it isn't, All your ReloadUI action trigger to load default language you already defined.\n" ..
						"It's supposed that this sometimes prevents you from normal changing/keeping actions via another addon.",
			min = 0,
			max = 1440,
			getFunc = function()
				return ADDON.SaveData.LoadingAfterThisMinutes
			end,
			setFunc = function(state)
				ADDON.SaveData.LoadingAfterThisMinutes = state
			end,
			warning = false,
			default = defaultSaveData.LoadingAfterThisMinutes
		},
		{
			type = "header",
			name = "Language"
		},
		{
			type = "dropdown",
			name = "Default Language",
			tooltip = "",
			choices = ADDON.DEFAULT_LANGUAGE.GetChoices(),
			choicesValues = ADDON.DEFAULT_LANGUAGE.GetValues(),
			getFunc = function()
				return ADDON.SaveData.DefaultLanguage
			end,
			setFunc = function(state)
				ADDON.SaveData.DefaultLanguage = state
			end,
			default = defaultSaveData.DefaultLanguage
		},
		{
			type = "submenu",
			name = "User Defined Lang Code",
			tooltip = "e.g) Char1 is 'e' and Char2 is 'n' means your UserDefinedLangCode is 'en'.",
			controls = {
				getUserDefinedLangCode_Char1(0),
				getUserDefinedLangCode_Char2(0),
				getUserDefinedLangCode_Char1(1),
				getUserDefinedLangCode_Char2(1),
				getUserDefinedLangCode_Char1(2),
				getUserDefinedLangCode_Char2(2)
			}
		},
		{
			type = "header",
			name = "Language Selector UI"
		},
		{
			type = "checkbox",
			name = "ShowUI",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.ShowUI
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.ShowUI = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.ShowUI
		},
		{
			type = "checkbox",
			name = "HideWhenReticleShown",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.HideWhenReticleShown
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.HideWhenReticleShown = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.HideWhenReticleShown
		},
		{
			type = "button",
			name = "OpenSettings",
			width = "half",
			tooltip = "",
			func = function()
			end,
			warning = false
		},
		{
			type = "checkbox",
			name = "Display Button",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.OpenSettings
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.OpenSettings = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.OpenSettings
		},
		{
			type = "button",
			name = "Load ENGLISH Now",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.LoadLangCodeAndReload(ADDON.DEFAULT_LANGUAGE.ENGLISH.CHOICE)
			end,
			warning = "reload ui"
		},
		{
			type = "checkbox",
			name = "Display Button",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.LoadEnglishNow
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.LoadEnglishNow = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.LoadEnglishNow
		},
		{
			type = "button",
			name = "Load JAPANESE Now",
			width = "half",
			tooltip = "Japanese client can only be used by DMM players. \nif not, the command will be failed.",
			func = function()
				ADDON.LoadLangCodeAndReload(ADDON.DEFAULT_LANGUAGE.JAPANESE.CHOICE)
			end,
			warning = "reload ui"
		},
		{
			type = "checkbox",
			name = "Display Button",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.LoadJapaneseNow
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.LoadJapaneseNow = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.LoadJapaneseNow
		},
		{
			type = "button",
			name = "Load GERMAN Now",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.LoadLangCodeAndReload(ADDON.DEFAULT_LANGUAGE.GERMAN.CHOICE)
			end,
			warning = "reload ui"
		},
		{
			type = "checkbox",
			name = "Display Button",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.LoadGermanNow
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.LoadGermanNow = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.LoadGermanNow
		},
		{
			type = "button",
			name = "Load FRENCH Now",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.LoadLangCodeAndReload(ADDON.DEFAULT_LANGUAGE.FRENCH.CHOICE)
			end,
			warning = "reload ui"
		},
		{
			type = "checkbox",
			name = "Display Button",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.LoadFrenchNow
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.LoadFrenchNow = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.LoadFrenchNow
		},
		{
			type = "button",
			name = "Load RUSSIAN Now",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.LoadLangCodeAndReload(ADDON.DEFAULT_LANGUAGE.RUSSIAN.CHOICE)
			end,
			warning = "reload ui"
		},
		{
			type = "checkbox",
			name = "Display Button",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.LoadRussianNow
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.LoadRussianNow = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.LoadRussianNow
		},
		getUserDefinedLangCode_LoadCommand(0),
		getUserDefinedLangCode_DiaplayButton(0),
		getUserDefinedLangCode_LoadCommand(1),
		getUserDefinedLangCode_DiaplayButton(1),
		getUserDefinedLangCode_LoadCommand(2),
		getUserDefinedLangCode_DiaplayButton(2),
		{
			type = "description",
			title = "[NOTICE]",
			text = "These loading commands force to change current lang code, ignoring timer settings.",
			width = ""
		},
		{
			type = "header",
			name = "Command"
		},
		{
			type = "button",
			name = "Load Default Now",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.LoadDefaultLangCodeAndReload(true)
			end,
			warning = "reload ui"
		},
		{
			type = "button",
			name = "Output statuses to chat",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.d("status")
				if (ADDON.GetLastLangCode()) then
					ADDON.d("Current Lang Code: " .. ADDON.GetLastLangCode())
				else
					ADDON.d("there is no last Lang Code.")
				end
				ADDON.d("UserDefined Lang Code 0: " .. ADDON.GetUserDefinedLangCode(0))
				ADDON.d("UserDefined Lang Code 1: " .. ADDON.GetUserDefinedLangCode(1))
				ADDON.d("UserDefined Lang Code 2: " .. ADDON.GetUserDefinedLangCode(2))
				ADDON.d("position: (" .. ADDON.SaveData.Position.Left .. ", " .. ADDON.SaveData.Position.Top .. ")")
				ADDON.d("LastAccess: " .. os.date("%Y-%m-%d %H:%M:%S", ADDON.SaveData.LastAccess) .. " | " .. ADDON.SaveData.LastAccess)
				ADDON.d("ElapsedSecondsFromLastAccess: " .. ADDON.GetElapsedSecondsFromLastAccess())
			end
		},
		{
			type = "button",
			name = "Reset UI Position",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.d("Reset UI Position.")
				local defaultSaveData = ADDON.GetDefaultSaveData()
				ADDON.SaveData.Position.Left = defaultSaveData.Position.Left
				ADDON.SaveData.Position.Top = defaultSaveData.Position.Top
				ADDON.UI.Restore()
			end
		}
	}
end

--------
-- in this ADDON use, protected
--------

ADDON.SettingsPanel = nil

ADDON.RegisterPanel = function()
	ADDON.develop("RegisterPanel")
	ADDON.SettingsPanel = LAM:RegisterAddonPanel(ADDON.NAME, getPanelInfo())
	LAM:RegisterOptionControls(ADDON.NAME, getOptionTable())
end
