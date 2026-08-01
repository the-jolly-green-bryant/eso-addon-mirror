GamepadUITweaks = GamepadUITweaks or {}


local SETTING_PATTERN = "<<1>>Control<<2>>"

local LANGUAGES = {
	{ id = "en", name = SI_OFFICIALLANGUAGE0 },
	{ id = "fr", name = SI_OFFICIALLANGUAGE1 },
	{ id = "de", name = SI_OFFICIALLANGUAGE2 },
	{ id = "ru", name = SI_OFFICIALLANGUAGE4 },
	{ id = "es", name = SI_OFFICIALLANGUAGE5 },
	{ id = "jp", name = SI_OFFICIALLANGUAGE3 },
	{ id = "zh", name = SI_OFFICIALLANGUAGE6 },
}

local MAIN_MENU_SETTING_DEFINITIONS = {
	{ svKey = "ShowMainMenuCrownStore", textId = SI_GAMEPAD_MAIN_MENU_CROWN_STORE_CATEGORY, headerId = SI_GAMEPADUITWEAKS_MAINMENU_LABEL },
	{ svKey = "ShowMainMenuTamrielTomes", textId = SI_MAIN_MENU_TAMRIEL_TOMES },
	{ svKey = "ShowMainMenuAnnouncements", textId = SI_MAIN_MENU_ANNOUNCEMENTS },
	{ svKey = "ShowMainMenuCollections", textId = SI_MAIN_MENU_COLLECTIONS },
	{ svKey = "ShowMainMenuCampaign", textId = SI_PLAYER_MENU_CAMPAIGNS },
	{ svKey = "ShowMainMenuJournal", textId = SI_MAIN_MENU_JOURNAL },
	{ svKey = "ShowMainMenuSocial", textId = SI_MAIN_MENU_SOCIAL },
	{ svKey = "ShowMainMenuActivityFinder", textId = SI_MAIN_MENU_ACTIVITY_FINDER },
	{ svKey = "ShowMainMenuHelp", textId = SI_MAIN_MENU_HELP },
}

local SHORTCUT_SETTING_DEFINITIONS = {
	{ svKey = "ShowMainMenuQuestJournal", textId = SI_GAMEPAD_MAIN_MENU_JOURNAL_QUESTS, headerId = SI_GAMEPADUITWEAKS_SHORTCUT_LABEL },
	{ svKey = "ShowMainMenuAntiquitiesJournal", textId = SI_JOURNAL_MENU_ANTIQUITIES },
	{ svKey = "ShowMainMenuMail", textId = SI_MAIN_MENU_MAIL },
}

local function SafeCall(context, fnName, ...)
	if context and type(context[fnName]) == "function" then
		return context[fnName](...)
	end
end

local function ResolveSetFuncValue(valueOrControl, value)
	if value ~= nil then
		return value
	end

	return valueOrControl
end

local function GetLanguageChoices()
	local choices = {}
	local choicesValues = {}
	for _, lang in ipairs(LANGUAGES) do
		table.insert(choices, GetString(lang.name))
		table.insert(choicesValues, lang.id)
	end
	return choices, choicesValues
end

local function ResolveToggleTexts()
	local showText = GetString(SI_GAMEPADUITWEAKS_SHOW_STATE)
	local hideText = GetString(SI_GAMEPADUITWEAKS_HIDE_STATE)

	if not showText or showText == "" then
		showText = "SHOW"
	end
	if not hideText or hideText == "" then
		hideText = "HIDE"
	end

	return showText, hideText
end

local function CreateNestedSubmenuEntryCompat(label, optionsTable, tooltipText)
	if LibGamepad and type(LibGamepad.CreateNestedSubmenuEntry) == "function" then
		return LibGamepad.CreateNestedSubmenuEntry(label, optionsTable, tooltipText)
	end

	if not (LibGamepad and optionsTable and #optionsTable > 0) then
		return nil
	end

	local nestedPanelId = LibGamepad.VirtualSubmenuPanelId or 3000
	LibGamepad.VirtualSubmenuPanelId = nestedPanelId + 1
	ZO_CreateStringId("SI_SETTINGSYSTEMPANEL" .. tostring(nestedPanelId), label)

	GAMEPAD_SETTINGS_DATA = GAMEPAD_SETTINGS_DATA or {}
	GAMEPAD_SETTINGS_DATA[nestedPanelId] = GAMEPAD_SETTINGS_DATA[nestedPanelId] or {}

	local fallbackSystemId = 9999
	local optionTable = { [fallbackSystemId] = {} }
	local settingIdCounter = 1

	for _, optionData in ipairs(optionsTable) do
		local optionCopy = ZO_ShallowTableCopy(optionData)
		optionCopy.panel = nestedPanelId
		optionCopy.system = fallbackSystemId
		if not optionCopy.settingId then
			optionCopy.settingId = settingIdCounter
			settingIdCounter = settingIdCounter + 1
		end

		table.insert(GAMEPAD_SETTINGS_DATA[nestedPanelId], optionCopy)
		optionTable[fallbackSystemId][optionCopy.settingId] = ZO_ShallowTableCopy(optionCopy)
	end

	if ZO_SharedOptions and ZO_SharedOptions.AddTableToPanel then
		ZO_SharedOptions.AddTableToPanel(nestedPanelId, optionTable)
	end

	local entry = {
		controlType = OPTIONS_INVOKE_CALLBACK,
		text = label,
		gamepadTextOverride = label,
		customTemplate = "LibGamepad_OptionsSubmenuRow",
		callback = function()
			if GAMEPAD_OPTIONS and LibGamepad.PushMenu then
				LibGamepad.PushMenu(nestedPanelId)
			end
		end,
	}

	if tooltipText and tooltipText ~= "" then
		entry.gamepadCustomTooltipFunction = function(tooltipControl)
			GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, tooltipText)
		end
	end

	return entry
end

local function InstallCheckboxStateLabelHook()
	if GamepadUITweaks.OptionsCheckboxStateLabelHookInstalled then
		return
	end

	SecurePostHook("ZO_Options_UpdateOption", function(control)
		if not (control and control.data and control.data.controlType == OPTIONS_CHECKBOX) then
			return
		end

		local checkedText = control.data.gamepadCheckedTextOverride
		local uncheckedText = control.data.gamepadUncheckedTextOverride
		if not (checkedText and uncheckedText) then
			return
		end

		local checkBoxControl = control:GetNamedChild("Checkbox")
		if checkBoxControl then
			checkBoxControl.checkedText = checkedText
			checkBoxControl.uncheckedText = uncheckedText

			local currentChoice = control.data.currentChoice
			if currentChoice == nil and type(ZO_Options_GetSettingFromControl) == "function" then
				currentChoice = ZO_Options_GetSettingFromControl(control)
			end

			if currentChoice ~= nil then
				checkBoxControl:SetText(currentChoice and checkedText or uncheckedText)
			end
		end

		local onLabel = control:GetNamedChild("On")
		local offLabel = control:GetNamedChild("Off")
		if onLabel then onLabel:SetText(checkedText) end
		if offLabel then offLabel:SetText(uncheckedText) end
	end)

	GamepadUITweaks.OptionsCheckboxStateLabelHookInstalled = true
end

local function MakeBooleanCheckbox(def, context, showText, hideText)
	local text = GetString(def.textId)
	local option = {
		controlType = OPTIONS_CHECKBOX,
		text = text,
		gamepadTextOverride = text,
		gamepadCheckedTextOverride = showText,
		gamepadUncheckedTextOverride = hideText,
		GetSettingOverride = function()
			return GamepadUITweaks.SV and GamepadUITweaks.SV[def.svKey]
		end,
		SetSettingOverride = function(_, value)
			if GamepadUITweaks.SV then
				GamepadUITweaks.SV[def.svKey] = value
			end
			SafeCall(context, "ApplyMainMenuTweaks")
		end,
	}

	if def.headerId then
		option.header = function()
			return GetString(def.headerId)
		end
	end

	return option
end

local function EnsureConfirmReloadDialog()
	if not ESO_Dialogs["GAMEPADUITWEAKS_CONFIRM_RELOAD"] then
		ESO_Dialogs["GAMEPADUITWEAKS_CONFIRM_RELOAD"] = {
			gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
			title = { text = SI_GAMEPADUITWEAKS_LANG_RELOAD_TITLE },
			mainText = { text = SI_GAMEPADUITWEAKS_LANG_RELOAD_PROMPT },
			buttons = {
				{
					text = SI_DIALOG_CONFIRM,
					callback = function(dialog)
						SetCVar("Language.2", dialog.data.lang)
					end,
				},
				{
					text = SI_DIALOG_CANCEL,
					callback = function(dialog)
						-- Dialog dismissed without action
					end,
				},
			},
		}
	end
end

local function EnsureGlossReloadDialog(context)
	if not ESO_Dialogs["GAMEPADUITWEAKS_GLOSS_RELOAD"] then
		ESO_Dialogs["GAMEPADUITWEAKS_GLOSS_RELOAD"] = {
			gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
			title = { text = SI_GAMEPADUITWEAKS_LANG_RELOAD_TITLE },
			mainText = { text = SI_GAMEPADUITWEAKS_GLOSS_RELOAD_PROMPT },
			buttons = {
				{
					text = SI_DIALOG_CONFIRM,
					callback = function()
						SafeCall(context, "ApplyGlossBarSetting")
						ReloadUI()
					end,
				},
				{
					text = SI_DIALOG_CANCEL,
					callback = function(dialog)
						if GamepadUITweaks.SV then
							GamepadUITweaks.SV.DisableGlossBar = true
						end
						if dialog.data and dialog.data.control then
							ZO_Options_UpdateOption(dialog.data.control)
						end
					end,
				},
			},
		}
	end
end

local function EnsureGlossReloadDialogForLAM(context)
	if not ESO_Dialogs["GAMEPADUITWEAKS_GLOSS_RELOAD"] then
		ESO_Dialogs["GAMEPADUITWEAKS_GLOSS_RELOAD"] = {
			gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
			title = { text = SI_GAMEPADUITWEAKS_LANG_RELOAD_TITLE },
			mainText = { text = SI_GAMEPADUITWEAKS_GLOSS_RELOAD_PROMPT },
			buttons = {
				{
					text = SI_DIALOG_CONFIRM,
					callback = function()
						SafeCall(context, "ApplyGlossBarSetting")
						ReloadUI()
					end,
				},
				{
					text = SI_DIALOG_CANCEL,
					callback = function(dialog)
						if GamepadUITweaks.SV then
							GamepadUITweaks.SV.DisableGlossBar = true
						end
					end,
				},
			},
		}
	end
end

local function EnsureDialogs(context)
	EnsureConfirmReloadDialog()
	EnsureGlossReloadDialog(context)
end

function GamepadUITweaks.CreateSettingsMenu(context)
	EnsureConfirmReloadDialog()
	EnsureGlossReloadDialogForLAM(context)

	local choices, choicesValues = GetLanguageChoices()

	local panelData = {
		type = "panel",
		name = GamepadUITweaks.AddonName,
		displayName = GamepadUITweaks.DisplayName,
		author = GamepadUITweaks.Author,
		version = GamepadUITweaks.Version,
		website = GamepadUITweaks.Website,
		feedback = GamepadUITweaks.Feedback,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsTable = {}
	optionsTable[#optionsTable + 1] = {
		type = "header",
		customTemplate = "LibGamepad_OptionsSectionHeaderRow",
		name = GetString(SI_GAMEPADUITWEAKS_GAMEPAD_MENU_LABEL),
		reference = zo_strformat(SETTING_PATTERN, GamepadUITweaks.AddonName, #optionsTable),
	}

	local mainMenuOptionsTable = {}
	mainMenuOptionsTable[#mainMenuOptionsTable + 1] = {
		type = "header",
		customTemplate = "LibGamepad_OptionsSectionHeaderRow",
		name = GetString(SI_GAMEPADUITWEAKS_MAIN_MENU_LABEL),
		reference = zo_strformat(SETTING_PATTERN, GamepadUITweaks.AddonName .. GetString(SI_GAMEPADUITWEAKS_SHORTCUT_LABEL), #mainMenuOptionsTable),
	}
	for _, def in ipairs(MAIN_MENU_SETTING_DEFINITIONS) do
		mainMenuOptionsTable[#mainMenuOptionsTable + 1] = {
			type = "checkbox",
			name = GetString(def.textId),
			--- tooltip = GetString(SI_GAMEPADUITWEAKS_GLOSS_BAR_TT),
			getFunc = function() return GamepadUITweaks.SV and GamepadUITweaks.SV[def.svKey] end,
			setFunc = function(valueOrControl, value)
				local resolvedValue = ResolveSetFuncValue(valueOrControl, value)
				if resolvedValue == nil then
					return
				end

				if GamepadUITweaks.SV then
					GamepadUITweaks.SV[def.svKey] = resolvedValue
				end
				SafeCall(context, "ApplyMainMenuTweaks")
			end,
			width = "full",	--"half" or "full" (optional)
		}
	end
	mainMenuOptionsTable[#mainMenuOptionsTable + 1] = {
	type = "header",
	customTemplate = "LibGamepad_OptionsSectionHeaderRow",
	name = GetString(SI_GAMEPADUITWEAKS_SHORTCUT_LABEL),
	reference = zo_strformat(SETTING_PATTERN, GamepadUITweaks.AddonName .. GetString(SI_GAMEPADUITWEAKS_SHORTCUT_LABEL), #mainMenuOptionsTable),
	}
	for _, def in ipairs(SHORTCUT_SETTING_DEFINITIONS) do
		mainMenuOptionsTable[#mainMenuOptionsTable + 1] = {
			type = "checkbox",
			name = GetString(def.textId),
			--- tooltip = GetString(SI_GAMEPADUITWEAKS_GLOSS_BAR_TT),
			getFunc = function() return GamepadUITweaks.SV and GamepadUITweaks.SV[def.svKey] end,
			setFunc = function(valueOrControl, value)
				local resolvedValue = ResolveSetFuncValue(valueOrControl, value)
				if resolvedValue == nil then
					return
				end

				if GamepadUITweaks.SV then
					GamepadUITweaks.SV[def.svKey] = resolvedValue
				end
				SafeCall(context, "ApplyMainMenuTweaks")
			end,
			width = "full",	--"half" or "full" (optional)
		}
	end

	optionsTable[#optionsTable + 1] = {
		type = "submenu",
		name = GetString(SI_GAMEPADUITWEAKS_MAINMENU_LABEL),
		tooltip = GetString(SI_GAMEPADUITWEAKS_MAINMENU_TT),
		controls = mainMenuOptionsTable,
	}
	optionsTable[#optionsTable + 1] = {
		type = "dropdown",
		name = GetString(SI_GAMEPADUITWEAKS_CONTROLLER_STYLE),
		tooltip = GetString(SI_GAMEPADUITWEAKS_CONTROLLER_STYLE_TT),
		choices = {
			GetString(SI_GAMEPADUITWEAKS_CONTROLLER_STYLE_AUTO),
			GetString(SI_GAMEPADUITWEAKS_CONTROLLER_STYLE_XBOX),
			GetString(SI_GAMEPADUITWEAKS_CONTROLLER_STYLE_PS4),
			GetString(SI_GAMEPADUITWEAKS_CONTROLLER_STYLE_PS5),
			GetString(SI_GAMEPADUITWEAKS_CONTROLLER_STYLE_SWITCHPRO),
		},
		choicesValues = { "auto", "xbox", "ps4", "ps5", "switchpro" },
		getFunc = function()
			if not GamepadUITweaks.SV then
				return "auto"
			end
			return GamepadUITweaks.SV.ControllerButtonStyle or "auto"
		end,
		setFunc = function(value)
			if GamepadUITweaks.SV then
				GamepadUITweaks.SV.ControllerButtonStyle = value
			end
			SafeCall(context, "ApplyControllerButtonStyle")
		end,
		width = "full",
	}

	optionsTable[#optionsTable + 1] = {
		type = "header",
		customTemplate = "LibGamepad_OptionsSectionHeaderRow",
		name = GetString(SI_GAMEPADUITWEAKS_HEADER),
		reference = zo_strformat(SETTING_PATTERN, GamepadUITweaks.AddonName, #optionsTable),
	}
	optionsTable[#optionsTable + 1] = {
		type = "slider",
		name = GetString(SI_GAMEPADUITWEAKS_WIDTH),
		tooltip = GetString(SI_GAMEPADUITWEAKS_WIDTH_TT),
		getFunc = function()
			return tonumber(GamepadUITweaks.SV.AttributeBarsWidth) or 280
		end,
		setFunc = function(value)
			GamepadUITweaks.SV.AttributeBarsWidth = tonumber(value) or value
			SafeCall(context, "UpdateUIBarSize")
			SafeCall(context, "PreviewAttributeBars")
			if widthOption and widthOption.gamepadCustomTooltipFunction then
				GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
				widthOption.gamepadCustomTooltipFunction(GAMEPAD_LEFT_TOOLTIP)
			end
		end,
		min = 100,
		max = 1000,
		default = DEFAULT_UPDATE_TIME,
		step = 20,
		decimals = 0,
	}
	optionsTable[#optionsTable + 1] = {
		type = "slider",
		name = GetString(SI_GAMEPADUITWEAKS_DISTANCE),
		tooltip = GetString(SI_GAMEPADUITWEAKS_DISTANCE_TT),
		getFunc = function()
			return tonumber(GamepadUITweaks.SV.AttributesOffset) or 180
		end,
		setFunc = function(value)
			GamepadUITweaks.SV.AttributesOffset = tonumber(value) or value
			SafeCall(context, "UpdateUIBarDistanceOffset")
			SafeCall(context, "PreviewAttributeBars")
			if distanceOption and distanceOption.gamepadCustomTooltipFunction then
				GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
				distanceOption.gamepadCustomTooltipFunction(GAMEPAD_LEFT_TOOLTIP)
			end
		end,
		min = 0,
		max = 600,
		default = DEFAULT_UPDATE_TIME,
		step = 20,
		decimals = 0,
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(SI_GAMEPADUITWEAKS_GLOSS_BAR),
		tooltip = GetString(SI_GAMEPADUITWEAKS_GLOSS_BAR_TT),
		getFunc = function() return not GamepadUITweaks.SV.DisableGlossBar end,
		setFunc = function(value)
			GamepadUITweaks.SV.DisableGlossBar = not value
			EVENT_MANAGER:UnregisterForUpdate("GamepadUITweaks_GlossDialog")
			if not value then
				SafeCall(context, "DisableGlossTextures")
			else
				EVENT_MANAGER:RegisterForUpdate("GamepadUITweaks_GlossDialog", 1500, function()
					EVENT_MANAGER:UnregisterForUpdate("GamepadUITweaks_GlossDialog")
					ZO_Dialogs_ShowGamepadDialog("GAMEPADUITWEAKS_GLOSS_RELOAD", {})
				end)
			end
		end,
		width = "full",	--"half" or "full" (optional)
		warning = "Will need to reload the UI.",	--(optional)
	}
	-- optionsTable[#optionsTable + 1] = {
	-- 	type = "divider",
	-- 	reference = zo_strformat(SETTING_PATTERN, GamepadUITweaks.AddonName, #optionsTable),
	-- }
	optionsTable[#optionsTable + 1] = {
		type = "header",
		customTemplate = "LibGamepad_OptionsSectionHeaderRow",
		name = GetString(SI_INTERFACE_OPTIONS_TEXT_LANGUAGE),
		reference = zo_strformat(SETTING_PATTERN, GamepadUITweaks.AddonName, #optionsTable),
	}
	optionsTable[#optionsTable + 1] = {
		type = "dropdown",
		name = GetString(SI_INTERFACE_OPTIONS_TEXT_LANGUAGE),
		tooltip = GetString(SI_GAMEPADUITWEAKS_LANG_SETTING_TT),
		choices = choices,
		choicesValues = choicesValues,
		getFunc = function()
			return GetCVar("Language.2")
		end,
		setFunc = function(value)
			local currentLang = GetCVar("Language.2")
			if value ~= currentLang then
				EVENT_MANAGER:UnregisterForUpdate("GamepadUITweaks_Dialog")
				EVENT_MANAGER:RegisterForUpdate("GamepadUITweaks_Dialog", 500, function()
					EVENT_MANAGER:UnregisterForUpdate("GamepadUITweaks_Dialog")
					ZO_Dialogs_ShowGamepadDialog("GAMEPADUITWEAKS_CONFIRM_RELOAD", { lang = value })
				end)
			end
		end,
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("GamepadUITweaksMenu", panelData)
	LAM:RegisterOptionControls("GamepadUITweaksMenu", optionsTable)
end
