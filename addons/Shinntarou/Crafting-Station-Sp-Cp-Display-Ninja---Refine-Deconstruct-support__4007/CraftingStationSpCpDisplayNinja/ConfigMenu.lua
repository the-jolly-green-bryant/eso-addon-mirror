local ADDON = CraftingStationSpCpDisplayNinja
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


local function getCheckTargetOption(Crafting, ability, warning)
	local defaultSaveData = ADDON.GetDefaultSaveData()
	return
	{
		type = "checkbox",
		name = ability,
		tooltip = "",
		width = "half",
		getFunc = function()
			return ADDON.SaveData.CheckTarget[Crafting][ability]
		end,
		setFunc = function(state)
			ADDON.SaveData.CheckTarget[Crafting][ability] = state
		end,
		warning = warning,
		default = defaultSaveData.CheckTarget[Crafting][ability]
	}
end

local function getShowSkillInfoOnWarningOption(Crafting, name, warning)
	local defaultSaveData = ADDON.GetDefaultSaveData()
	return
	{
		type = "checkbox",
		name = name,
		tooltip = "",
		width = "half",
		getFunc = function()
			return ADDON.SaveData.ShowSkillInfoOnWarning[Crafting]
		end,
		setFunc = function(state)
			ADDON.SaveData.ShowSkillInfoOnWarning[Crafting] = state
		end,
		warning = warning,
		default = defaultSaveData.ShowSkillInfoOnWarning[Crafting]
	}
end

local function getCheckTargetOptions(Crafting, title, EnchantMeticulousDisassemblyWarning)

	local MeticulousDisassemblyWarning = false
	if Crafting == CRAFTING_TYPE_ENCHANTING then
		MeticulousDisassemblyWarning = EnchantMeticulousDisassemblyWarning
	end
	return {
		{
			type = "header",
			name = title
		},
		getCheckTargetOption(Crafting, "BasicSkillLevel", false),
		getCheckTargetOption(Crafting, "ExtractingSkillLevel", false),
		getCheckTargetOption(Crafting, "MeticulousDisassemblyLevel", MeticulousDisassemblyWarning),
		getCheckTargetOption(Crafting, "ImprovingSkillLevel", false),
	}
end


local function getOptionTable()
	local defaultSaveData = ADDON.GetDefaultSaveData()
	local panels = {
		{
			type = "header",
			name = "Global"
		},
		{
			type = "checkbox",
			name = "Accountwide",
			tooltip = "",
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
			name = "Panel UI"
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
			name = "Setting Button",
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
			type = "checkbox",
			name = "BasicSkillLevel",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.BasicSkillLevel
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.BasicSkillLevel = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.BasicSkillLevel
		},
		{
			type = "checkbox",
			name = "ExtractingSkillLevel",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.ExtractingSkillLevel
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.ExtractingSkillLevel = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.ExtractingSkillLevel
		},
		{
			type = "checkbox",
			name = "MeticulousDisassemblyLevel",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.MeticulousDisassemblyLevel
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.MeticulousDisassemblyLevel = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.MeticulousDisassemblyLevel
		},
		{
			type = "checkbox",
			name = "ImprovingSkillLevel",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Display.Buttons.ImprovingSkillLevel
			end,
			setFunc = function(state)
				ADDON.SaveData.Display.Buttons.ImprovingSkillLevel = state
				ADDON.UI.Restore()
			end,
			warning = false,
			default = defaultSaveData.Display.Buttons.ImprovingSkillLevel
		}
	}

	local k, v

	for k,value in pairs(getCheckTargetOptions(CRAFTING_TYPE_BLACKSMITHING, "BLACKSMITHING Check", false)) do 
		panels[#panels + 1] = value
	end
	for k,value in pairs(getCheckTargetOptions(CRAFTING_TYPE_CLOTHIER, "CLOTHIER Check", false)) do 
		panels[#panels + 1] = value
	end
	for k,value in pairs(getCheckTargetOptions(CRAFTING_TYPE_WOODWORKING, "WOODWORKING Check", false)) do 
		panels[#panels + 1] = value
	end
	for k,value in pairs(getCheckTargetOptions(CRAFTING_TYPE_ENCHANTING, "ENCHANTING Check", "NOT NEED TO CHECK.\n because Extracting glyphs doesn't require CP skills.")) do 
		panels[#panels + 1] = value
	end
	for k,value in pairs(getCheckTargetOptions(CRAFTING_TYPE_JEWELRYCRAFTING, "JEWELRYCRAFTING Check", false)) do 
		panels[#panels + 1] = value
	end
	for k,value in pairs(getCheckTargetOptions(CRAFTING_TYPE_INVALID, "Assistant Check", false)) do 
		panels[#panels + 1] = value
	end
	

	panels[#panels + 1] = {
		type = "header",
		name = "User Defined Text"
	}

	panels[#panels + 1] = {
		type = "editbox",
		name = "CheckResultIsGood",
		tooltip = "This text will be shown if the checks are passed.",
		getFunc = function()
			return ADDON.SaveData.Messages.CheckResultIsGood
		end,
		setFunc = function(state)
			ADDON.SaveData.Messages.CheckResultIsGood = state
		end,
		width = "full",
		default = defaultSaveData.Messages.CheckResultIsGood
	}
	panels[#panels + 1] = {
		type = "editbox",
		name = "CheckResultIsBad",
		tooltip = "This text will be shown if the checks were not passed.",
		getFunc = function()
			return ADDON.SaveData.Messages.CheckResultIsBad
		end,
		setFunc = function(state)
			ADDON.SaveData.Messages.CheckResultIsBad = state
		end,
		width = "full",
		default = defaultSaveData.Messages.CheckResultIsBad
	}

	
	panels[#panels + 1] = {
		type = "header",
		name = "Show Skill Info On Warning"
	}
	panels[#panels + 1] = getShowSkillInfoOnWarningOption(CRAFTING_TYPE_BLACKSMITHING, "BLACKSMITHING", nil)
	panels[#panels + 1] = getShowSkillInfoOnWarningOption(CRAFTING_TYPE_CLOTHIER, "CLOTHIER", nil)
	panels[#panels + 1] = getShowSkillInfoOnWarningOption(CRAFTING_TYPE_WOODWORKING, "WOODWORKING", nil)
	panels[#panels + 1] = getShowSkillInfoOnWarningOption(CRAFTING_TYPE_ENCHANTING, "ENCHANTING", nil)
	panels[#panels + 1] = getShowSkillInfoOnWarningOption(CRAFTING_TYPE_JEWELRYCRAFTING, "JEWELRYCRAFTING", nil)
	panels[#panels + 1] = getShowSkillInfoOnWarningOption(CRAFTING_TYPE_INVALID, "Assistant", nil)
	

	panels[#panels + 1] = {
		type = "header",
		name = "Command"
	}

	panels[#panels + 1] = {
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
	
	panels[#panels + 1] = {
		type = "button",
		name = "Reset All Settings",
		width = "half",
		tooltip = "",
		func = function()
			ADDON.d("Reset All Settings")
			local defaultSaveData = ADDON.GetDefaultSaveData()
			ADDON.SaveData = defaultSaveData
			ADDON.UI.Restore()
		end
	}

	panels[#panels + 1] = {
		type = "checkbox",
		name = "DebugMode",
		tooltip = "",
		width = "half",
		getFunc = function()
			return ADDON.SaveDataGlobal.DebugMode
		end,
		setFunc = function(state)
			ADDON.SaveDataGlobal.DebugMode = state
			ADDON.LoadSavedVariables()
		end,
		warning = false,
		default = defaultSaveData.DebugMode
	}
	if ADDON.IS_DEBUG() then
		panels[#panels + 1] = {
			type = "button",
			name = "[DEBUG]",
			width = "half",
			tooltip = "",
			func = function()
				-- TODO
			end
		}
	end

	return panels
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
