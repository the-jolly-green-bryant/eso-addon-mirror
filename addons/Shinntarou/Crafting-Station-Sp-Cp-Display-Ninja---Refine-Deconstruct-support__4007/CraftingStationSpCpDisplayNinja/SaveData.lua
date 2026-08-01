local ADDON = CraftingStationSpCpDisplayNinja
local LAM = LibAddonMenu2

-- @see https://wiki.esoui.com/AddOn_Quick_Questions
local SAVE_DATA_VARIABLE_VERSION = 1
local SAVE_NAME_NAMESPACE = nil
local SAVE_DATA_SPECIFIC_PROFILE = nil

ADDON.getSaveDataName = function()
	return ADDON.NAME  .. "Variables"
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
		["DebugMode"] = false,
		-- UI
		["Display"] ={
			["ShowUI"] = true,
			["Buttons"] = {
				["OpenSettings"] = true,
				["BasicSkillLevel"] = true,
				["ExtractingSkillLevel"] = true,
				["MeticulousDisassemblyLevel"] = true,
				["ImprovingSkillLevel"] = true,
			}
		},
		-- CheckTarget
		["CheckTarget"] ={
			[CRAFTING_TYPE_INVALID] = {
				["BasicSkillLevel"] = true,
				["ExtractingSkillLevel"] = true,
				["MeticulousDisassemblyLevel"] = true,
				["ImprovingSkillLevel"] = false,
			},
			[CRAFTING_TYPE_BLACKSMITHING] = {
				["BasicSkillLevel"] = true,
				["ExtractingSkillLevel"] = true,
				["MeticulousDisassemblyLevel"] = true,
				["ImprovingSkillLevel"] = false,
			},
			[CRAFTING_TYPE_CLOTHIER] = {
				["BasicSkillLevel"] = true,
				["ExtractingSkillLevel"] = true,
				["MeticulousDisassemblyLevel"] = true,
				["ImprovingSkillLevel"] = false,
			},
			[CRAFTING_TYPE_WOODWORKING] = {
				["BasicSkillLevel"] = true,
				["ExtractingSkillLevel"] = true,
				["MeticulousDisassemblyLevel"] = true,
				["ImprovingSkillLevel"] = false,
			},
			[CRAFTING_TYPE_JEWELRYCRAFTING] = {
				["BasicSkillLevel"] = true,
				["ExtractingSkillLevel"] = true,
				["MeticulousDisassemblyLevel"] = true,
				["ImprovingSkillLevel"] = false,
			},
			[CRAFTING_TYPE_ENCHANTING] = {
				["BasicSkillLevel"] = true,
				["ExtractingSkillLevel"] = true,
				["MeticulousDisassemblyLevel"] = false,
				["ImprovingSkillLevel"] = false,
			}
		},
		["ShowSkillInfoOnWarning"] = {
			[CRAFTING_TYPE_INVALID] = true,
			[CRAFTING_TYPE_BLACKSMITHING] = false,
			[CRAFTING_TYPE_CLOTHIER] = false,
			[CRAFTING_TYPE_WOODWORKING] = false,
			[CRAFTING_TYPE_JEWELRYCRAFTING] = false,
			[CRAFTING_TYPE_ENCHANTING] = false,
		},
		--Messages
		["Messages"] ={
			["CheckResultIsGood"] = "OK!",
			["CheckResultIsBad"] = "Why don't you get skills?",
		},

		-- log, status
		["Position"] = {
			["Left"] = 200,
			["Top"] = 100,
		},
	}
end

ADDON.LoadSavedVariables = function()
	ADDON.develop("LoadSavedVariables")

	ADDON.SaveDataLocal =
		ZO_SavedVars:NewCharacterIdSettings(
		ADDON.getSaveDataName(),
		SAVE_DATA_VARIABLE_VERSION,
		SAVE_NAME_NAMESPACE,
		ADDON.GetDefaultSaveData(),
		SAVE_DATA_SPECIFIC_PROFILE
	)
	ADDON.SaveDataGlobal =
		ZO_SavedVars:NewAccountWide(
		ADDON.getSaveDataName(),
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
