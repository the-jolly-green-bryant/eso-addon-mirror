local ADDON = NameLanguageNinja
local LMN = LibMultilingualName
local LAM = LibAddonMenu2

--------
-- in this file local use, private
--------

-- @see https://wiki.esoui.com/AddOn_Quick_Questions
local SAVE_DATA_VARIABLE_VERSION = 6
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
		-- global
		["AcrossAccounts"] = true,
		["ShowMessageOnInit"] = true,
		["DebugMode"] = false,
		-- behaviour
		["OutputSetItemName"] = true,
		["OutputItemId"] = false,
		["DontShowClientLanguage"] = true,
		["DontShowDivider"] = false,
		["ItemBrowserIntegration"] = true,
		-- language
		["Languages"] = LMN.createTableOfLangCodeToYourValue(false, {
			[LMN.CODE_ENGLISH] = true
		}),
		-- language color
		["LanguageColors"] = LMN.createTableOfLangCodeToYourValue({r = 1.0, g = 1.0, b = 1.0}),
		["To"] = {
			["Item"] = {
				["Tooltip"] = {
					["Title"] = false,
					["Body"] = true
				}
			},
			["Skill"] = {
				["Tooltip"] = {
					["Title"] = false,
					["Body"] = true
				}
			}
		},
		-- Description
		["Description"] = {
			["OutputSetBonus"] = true,
			["OutputSkill"] = true,
			["Languages"] = LMN.createTableOfLangCodeToYourValue(false, {
				[LMN.CODE_ENGLISH] = true
			})
		},
		-- LinkInChat
		["LinkInChat"] = {
			["Replace"] = true,
			["IncludeDesignatedTitle"] = true,
			["LinkTitle"] = "LINK",
			["NotReplaceIfLengthGreaterThan"] = 1000,
			["Languages"] = LMN.createTableOfLangCodeToYourValue(false, {
				[LMN.CODE_ENGLISH] = true
			}),
			["ShortenMode"] = {
				["IfNumOfLinkInChatGreaterThan"] = 2,
				["OmitNameIfLengthGreaterThan"] = 18,
				["Language"] = 1,
				-- 1 mean first item. may be LMN.CODE_ENGLISH
				["UseSetName"] = true,
				["IconSize"] = 30,
				["IconPositionRight"] = true,
				["OmitItemPrefix"] = true
			}
		}
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
