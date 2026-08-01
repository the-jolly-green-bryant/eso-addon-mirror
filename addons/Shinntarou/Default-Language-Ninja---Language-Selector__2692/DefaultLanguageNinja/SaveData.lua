local ADDON = DefaultLanguageNinja
local LAM = LibAddonMenu2

--------
-- in this file local use, private
--------

-- @see https://wiki.esoui.com/AddOn_Quick_Questions
local SAVE_DATA_VARIABLE_VERSION = 1
local SAVE_NAME_NAMESPACE = nil
local SAVE_DATA_SPECIFIC_PROFILE = nil

local function getSaveDataName()
	return ADDON.NAME .. "Variables"
end

--------
-- in this ADDON use, protected
--------

ADDON.SaveData = {}
ADDON.SaveDataLocal = {}
ADDON.SaveDataGlobal = {}

ADDON.GetDefaultSaveData = function()
	return {
		["AcrossAccounts"] = true,
		["ShowMessageOnInit"] = true,
		["LoadingAfterThisMinutes"] = 60,
		-- language(ALL lang codes + last lang code + user defined lang code + disabled )
		["DefaultLanguage"] = ADDON.DEFAULT_LANGUAGE.LAST.VALUE,
		["UserDefinedLangCode"] = {
			[0] = {
				["Char1"] = ADDON.USER_DEFINED_CHAR.GetValue("e"),
				["Char2"] = ADDON.USER_DEFINED_CHAR.GetValue("n")
			},
			[1] = {
				["Char1"] = ADDON.USER_DEFINED_CHAR.GetValue("j"),
				["Char2"] = ADDON.USER_DEFINED_CHAR.GetValue("p")
			},
			[2] = {
				["Char1"] = ADDON.USER_DEFINED_CHAR.GetValue("d"),
				["Char2"] = ADDON.USER_DEFINED_CHAR.GetValue("e")
			},
		},
		-- UI
		["Display"] ={
			["ShowUI"] = true,
			["HideWhenReticleShown"] = true,
			["Buttons"] = {
				["OpenSettings"] = true,
				["LoadEnglishNow"] = true,
				["LoadJapaneseNow"] = false,
				["LoadGermanNow"] = false,
				["LoadFrenchNow"] = false,
				["LoadRussianNow"] = false,
				["LoadUserDefined0Now"] = true,
				["LoadUserDefined1Now"] = false,
				["LoadUserDefined2Now"] = false,
			}
		},
		-- log, status
		["LastAccess"] = 0,
		["LastLangCode"] = {
			["Char1"] = 0,
			["Char2"] = 0
		},
		["DisabledOnceWhenNextReloading"] = false,
		["Position"] = {
			["Left"] = 0,
			["Top"] = 0,
		},
	}
end

ADDON.LoadSavedVariables = function()
	ADDON.develop("LoadSavedVariables")

	ADDON.SaveDataLocal =
		ZO_SavedVars:NewCharacterIdSettings(
		getSaveDataName(),
		SAVE_DATA_VARIABLE_VERSION,
		SAVE_NAME_NAMESPACE,
		ADDON.GetDefaultSaveData(),
		SAVE_DATA_SPECIFIC_PROFILE
	)
	ADDON.SaveDataGlobal =
		ZO_SavedVars:NewAccountWide(
		getSaveDataName(),
		SAVE_DATA_VARIABLE_VERSION,
		SAVE_NAME_NAMESPACE,
		ADDON.GetDefaultSaveData(),
		SAVE_DATA_SPECIFIC_PROFILE
	)
	if ADDON.SaveDataGlobal.AcrossAccounts then
		ADDON.SaveData = ADDON.SaveDataGlobal
	else
		ADDON.SaveData = ADDON.SaveDataLocal
	end
end

ADDON.GetDefaultLangCode = function()
	local defaultLanguage = ADDON.SaveData.DefaultLanguage

	if (defaultLanguage == ADDON.DEFAULT_LANGUAGE.DISABLED.VALUE) then
		return false
	end
	if (defaultLanguage == ADDON.DEFAULT_LANGUAGE.USER_DEFINED_0.VALUE) then
		return ADDON.GetUserDefinedLangCode(0)
	end
	if (defaultLanguage == ADDON.DEFAULT_LANGUAGE.USER_DEFINED_1.VALUE) then
		return ADDON.GetUserDefinedLangCode(1)
	end
	if (defaultLanguage == ADDON.DEFAULT_LANGUAGE.USER_DEFINED_2.VALUE) then
		return ADDON.GetUserDefinedLangCode(2)
	end
	if (defaultLanguage == ADDON.DEFAULT_LANGUAGE.LAST.VALUE) then
		return ADDON.GetLastLangCode()
	end

	local langCode = ADDON.DEFAULT_LANGUAGE.GetChoice(defaultLanguage)
	if langCode then
		return langCode
	end

	return false
end

ADDON.GetUserDefinedLangCode = function(key)
	if ADDON.SaveData.UserDefinedLangCode[0] == nil then
		return false
	end
	local userDefinedLangCode = ADDON.SaveData.UserDefinedLangCode[key]

	local char1 = ADDON.USER_DEFINED_CHAR.GetChoice(userDefinedLangCode.Char1)
	local char2 = ADDON.USER_DEFINED_CHAR.GetChoice(userDefinedLangCode.Char2)
	if char1 and char2 then
		return char1 .. char2
	end

	return false
end

ADDON.UpdateLastAccess = function()
	local timestamp = os.time()
	ADDON.SaveData.LastAccess = timestamp

	ADDON.develop(
		"UpdateLastAccess called at " ..
			os.date("%Y-%m-%d %H:%M:%S", ADDON.SaveData.LastAccess) .. " | " .. ADDON.SaveData.LastAccess
	)
end

ADDON.GetElapsedSecondsFromLastAccess = function()
	local timestamp = os.time()
	local elapsedSeconds = timestamp - ADDON.SaveData.LastAccess

	return elapsedSeconds
end

ADDON.UpdateLastLangCode = function()
	ADDON.develop("UpdateLastLangCode")

	local clientLangCode = string.lower(GetCVar("language.2"))
	local char1 = string.sub(clientLangCode, 1, 1)
	local char2 = string.sub(clientLangCode, 2, 2)
	local value1 = ADDON.USER_DEFINED_CHAR.GetValue(char1)
	local value2 = ADDON.USER_DEFINED_CHAR.GetValue(char2)

	ADDON.SaveData.LastLangCode.Char1 = value1
	ADDON.SaveData.LastLangCode.Char2 = value2

	ADDON.develop("LastLangCode = " .. char1 .. char2)
end

ADDON.GetLastLangCode = function()
	local char1 = ADDON.USER_DEFINED_CHAR.GetChoice(ADDON.SaveData.LastLangCode.Char1)
	local char2 = ADDON.USER_DEFINED_CHAR.GetChoice(ADDON.SaveData.LastLangCode.Char2)

	if (char1 and char2) then
		return char1 .. char2
	end

	return false
end
