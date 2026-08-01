GamepadInventoryTweaks = GamepadInventoryTweaks or {}
local SETTING_PATTERN = "<<1>>Control<<2>>"

local function InstallCheckboxStateLabelHook()
	if GamepadInventoryTweaks.OptionsCheckboxStateLabelHookInstalled then
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
		if onLabel then
			onLabel:SetText(checkedText)
		end
		if offLabel then
			offLabel:SetText(uncheckedText)
		end
	end)

	GamepadInventoryTweaks.OptionsCheckboxStateLabelHookInstalled = true
end

function GamepadInventoryTweaks.RegisterOptions(optionsContext)
	if not (LibGamepad and LibGamepad.RegisterSubmenu) then
		return
	end

	InstallCheckboxStateLabelHook()

	local function WithTooltip(stringId)
		return function(tooltipControl)
			GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, GetString(stringId))
		end
	end

	local optionsTable =
	{
		{
			controlType = OPTIONS_CHECKBOX,
			header = function()
				return GetString(SI_GAMEPADINVENTORYTWEAKS_HEADER)
			end,
			text = GetString(SI_GAMEPADINVENTORYTWEAKS_ENABLE_CATEGORY_ONLY),
			gamepadTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_ENABLE_CATEGORY_ONLY),
			tooltipText = GetString(SI_GAMEPADINVENTORYTWEAKS_ENABLE_CATEGORY_ONLY_TT),
			gamepadCheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_SHOW_STATE),
			gamepadUncheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_STATE),
			gamepadCustomTooltipFunction = WithTooltip(SI_GAMEPADINVENTORYTWEAKS_ENABLE_CATEGORY_ONLY_TT),
			GetSettingOverride = function()
				return GamepadInventoryTweaks.SV.EnableActiveCategoryOnly
			end,
			SetSettingOverride = function(_, value)
				GamepadInventoryTweaks.SV.EnableActiveCategoryOnly = value
				if GAMEPAD_INVENTORY then
					if not value then
						GAMEPAD_INVENTORY.gitActiveCategoryName = nil
					end
					if optionsContext and optionsContext.UpdateInventoryVisualFilterBar then
						optionsContext.UpdateInventoryVisualFilterBar(GAMEPAD_INVENTORY)
					end
					if optionsContext and optionsContext.ApplyActiveCategoryFocus then
						optionsContext.ApplyActiveCategoryFocus(GAMEPAD_INVENTORY)
					end
				end
				if GAMEPAD_BANKING then
					if not value then
						GAMEPAD_BANKING.gbtActiveCategoryName = nil
					end
					if optionsContext and optionsContext.UpdateBankVisualFilterBar then
						optionsContext.UpdateBankVisualFilterBar(GAMEPAD_BANKING)
					end
					if optionsContext and optionsContext.ApplyBankActiveCategoryFocus then
						optionsContext.ApplyBankActiveCategoryFocus(GAMEPAD_BANKING)
					end
				end
				if GAMEPAD_GUILD_BANK then
					if not value then
						GAMEPAD_GUILD_BANK.gbtGuildActiveCategoryName = nil
					end
					if optionsContext and optionsContext.UpdateGuildBankVisualFilterBar then
						optionsContext.UpdateGuildBankVisualFilterBar(GAMEPAD_GUILD_BANK)
					end
					if optionsContext and optionsContext.ApplyGuildBankActiveCategoryFocus then
						optionsContext.ApplyGuildBankActiveCategoryFocus(GAMEPAD_GUILD_BANK)
					end
				end
			end,
		},
		{
			controlType = OPTIONS_CHECKBOX,
			text = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_MUNDUS),
			gamepadTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_MUNDUS),
			tooltipText = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_MUNDUS_TT),
			gamepadCheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_SHOW_STATE),
			gamepadUncheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_STATE),
			gamepadCustomTooltipFunction = WithTooltip(SI_GAMEPADINVENTORYTWEAKS_HIDE_MUNDUS_TT),
			GetSettingOverride = function()
				return not GamepadInventoryTweaks.SV.HideMundusInInventoryMenu
			end,
			SetSettingOverride = function(_, value)
				GamepadInventoryTweaks.SV.HideMundusInInventoryMenu = not value
				if GAMEPAD_INVENTORY and type(GAMEPAD_INVENTORY.RefreshActiveCategoryList) == "function" then
					GAMEPAD_INVENTORY:RefreshActiveCategoryList()
				end
			end,
		},
		{
			controlType = OPTIONS_CHECKBOX,
			header = function()
				return GetString(SI_GAMEPADINVENTORYTWEAKS_SEARCHHEADER)
			end,
			text = GetString(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
			gamepadTextOverride = GetString(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
			gamepadCheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_SHOW_STATE),
			gamepadUncheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_STATE),
			tooltipText = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_ALL_TT),
			gamepadCustomTooltipFunction = WithTooltip(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_ALL_TT),
			GetSettingOverride = function()
				return not GamepadInventoryTweaks.SV.HideSearchOnAllInventoryPages
			end,
			SetSettingOverride = function(_, value)
				GamepadInventoryTweaks.SV.HideSearchOnAllInventoryPages = not value
				if GAMEPAD_INVENTORY then
					if optionsContext and optionsContext.ApplyInventorySearchVisibility then
						optionsContext.ApplyInventorySearchVisibility(GAMEPAD_INVENTORY)
					end
					if optionsContext and optionsContext.UpdateInventoryVisualFilterBar then
						optionsContext.UpdateInventoryVisualFilterBar(GAMEPAD_INVENTORY)
					end
				end
			end,
		},
		{
			controlType = OPTIONS_CHECKBOX,
			text = GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER),
			gamepadTextOverride = GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER),
			gamepadCheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_SHOW_STATE),
			gamepadUncheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_STATE),
			tooltipText = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_CRAFTBAG_TT),
			gamepadCustomTooltipFunction = WithTooltip(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_CRAFTBAG_TT),
			GetSettingOverride = function()
				return not GamepadInventoryTweaks.SV.HideSearchOnCraftBagPage
			end,
			SetSettingOverride = function(_, value)
				GamepadInventoryTweaks.SV.HideSearchOnCraftBagPage = not value
				if GAMEPAD_INVENTORY then
					if optionsContext and optionsContext.ApplyInventorySearchVisibility then
						optionsContext.ApplyInventorySearchVisibility(GAMEPAD_INVENTORY)
					end
					if optionsContext and optionsContext.UpdateInventoryVisualFilterBar then
						optionsContext.UpdateInventoryVisualFilterBar(GAMEPAD_INVENTORY)
					end
				end
			end,
		},
		{
			controlType = OPTIONS_CHECKBOX,
			text = GetString(SI_GAMEPAD_BANK_CATEGORY_HEADER),
			gamepadTextOverride = GetString(SI_GAMEPAD_BANK_CATEGORY_HEADER),
			gamepadCheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_SHOW_STATE),
			gamepadUncheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_STATE),
			tooltipText = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_BANK_TT),
			gamepadCustomTooltipFunction = WithTooltip(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_BANK_TT),
			GetSettingOverride = function()
				return not GamepadInventoryTweaks.SV.HideSearchOnBankPage
			end,
			SetSettingOverride = function(_, value)
				GamepadInventoryTweaks.SV.HideSearchOnBankPage = not value
				if GAMEPAD_BANKING then
					if optionsContext and optionsContext.ApplyBankSearchVisibility then
						optionsContext.ApplyBankSearchVisibility(GAMEPAD_BANKING)
					end
					if optionsContext and optionsContext.UpdateBankVisualFilterBar then
						optionsContext.UpdateBankVisualFilterBar(GAMEPAD_BANKING)
					end
				end
			end,
		},
		{
			controlType = OPTIONS_CHECKBOX,
			text = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER),
			gamepadTextOverride = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER),
			gamepadCheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_SHOW_STATE),
			gamepadUncheckedTextOverride = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_STATE),
			tooltipText = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_GUILDBANK_TT),
			gamepadCustomTooltipFunction = WithTooltip(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_GUILDBANK_TT),
			GetSettingOverride = function()
				return not GamepadInventoryTweaks.SV.HideSearchOnGuildBankPage
			end,
			SetSettingOverride = function(_, value)
				GamepadInventoryTweaks.SV.HideSearchOnGuildBankPage = not value
				if GAMEPAD_GUILD_BANK then
					if optionsContext and optionsContext.ApplyGuildBankSearchVisibility then
						optionsContext.ApplyGuildBankSearchVisibility(GAMEPAD_GUILD_BANK)
					end
					if optionsContext and optionsContext.UpdateGuildBankVisualFilterBar then
						optionsContext.UpdateGuildBankVisualFilterBar(GAMEPAD_GUILD_BANK)
					end
				end
			end,
		},
	}

	LibGamepad.RegisterSubmenu(
		GamepadInventoryTweaks.AddonName,
		optionsTable,
		GetString(SI_GAMEPADINVENTORYTWEAKS_TT),
		GetString(SI_LIBGAMEPAD_ADDONS_HEADER)
	)
end

function GamepadInventoryTweaks.CreateSettingsMenu(optionsContext)
	InstallCheckboxStateLabelHook()

	local function WithTooltip(stringId)
		return function(tooltipControl)
			GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, GetString(stringId))
		end
	end

	local panelData = {
		type = "panel",
		name = GamepadInventoryTweaks.AddonName,
		displayName = GamepadInventoryTweaks.DisplayName,
		author = GamepadInventoryTweaks.Author,
		version = GamepadInventoryTweaks.Version,
		website = GamepadInventoryTweaks.Website,
		feedback = GamepadInventoryTweaks.FeedBack,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {}

	optionsTable[#optionsTable + 1] = {
		type = "divider",
		reference = zo_strformat(SETTING_PATTERN, GamepadInventoryTweaks.AddonName, #optionsTable),
	}
	optionsTable[#optionsTable + 1] = {
		type = "header",
		customTemplate = "LibGamepad_OptionsSectionHeaderRow",
		name = GetString(SI_GAMEPADINVENTORYTWEAKS_HEADER),
		reference = zo_strformat(SETTING_PATTERN, GamepadInventoryTweaks.AddonName, #optionsTable),
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(SI_GAMEPADINVENTORYTWEAKS_ENABLE_CATEGORY_ONLY),
		tooltip = GetString(SI_GAMEPADINVENTORYTWEAKS_ENABLE_CATEGORY_ONLY_TT),
		getFunc = function() return GamepadInventoryTweaks.SV.EnableActiveCategoryOnly end,
		setFunc = function(value)
				GamepadInventoryTweaks.SV.EnableActiveCategoryOnly = value
				if GAMEPAD_INVENTORY then
					if not value then
						GAMEPAD_INVENTORY.gitActiveCategoryName = nil
					end
					if optionsContext and optionsContext.UpdateInventoryVisualFilterBar then
						optionsContext.UpdateInventoryVisualFilterBar(GAMEPAD_INVENTORY)
					end
					if optionsContext and optionsContext.ApplyActiveCategoryFocus then
						optionsContext.ApplyActiveCategoryFocus(GAMEPAD_INVENTORY)
					end
				end
				if GAMEPAD_BANKING then
					if not value then
						GAMEPAD_BANKING.gbtActiveCategoryName = nil
					end
					if optionsContext and optionsContext.UpdateBankVisualFilterBar then
						optionsContext.UpdateBankVisualFilterBar(GAMEPAD_BANKING)
					end
					if optionsContext and optionsContext.ApplyBankActiveCategoryFocus then
						optionsContext.ApplyBankActiveCategoryFocus(GAMEPAD_BANKING)
					end
				end
				if GAMEPAD_GUILD_BANK then
					if not value then
						GAMEPAD_GUILD_BANK.gbtGuildActiveCategoryName = nil
					end
					if optionsContext and optionsContext.UpdateGuildBankVisualFilterBar then
						optionsContext.UpdateGuildBankVisualFilterBar(GAMEPAD_GUILD_BANK)
					end
					if optionsContext and optionsContext.ApplyGuildBankActiveCategoryFocus then
						optionsContext.ApplyGuildBankActiveCategoryFocus(GAMEPAD_GUILD_BANK)
					end
				end
			end,
		width = "full",
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_MUNDUS),
		tooltip = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_MUNDUS_TT),
		getFunc = function() return not GamepadInventoryTweaks.SV.HideMundusInInventoryMenu end,
		setFunc = function(value)
				GamepadInventoryTweaks.SV.HideMundusInInventoryMenu = not value
				if GAMEPAD_INVENTORY and type(GAMEPAD_INVENTORY.RefreshActiveCategoryList) == "function" then
					GAMEPAD_INVENTORY:RefreshActiveCategoryList()
				end
			end,
		width = "full",
	}
	optionsTable[#optionsTable + 1] = {
		type = "divider",
		reference = zo_strformat(SETTING_PATTERN, GamepadInventoryTweaks.AddonName, #optionsTable),
	}
	optionsTable[#optionsTable + 1] = {
		type = "header",
		customTemplate = "LibGamepad_OptionsSectionHeaderRow",
		name = GetString(SI_GAMEPADINVENTORYTWEAKS_SEARCHHEADER),
		reference = zo_strformat(SETTING_PATTERN, GamepadInventoryTweaks.AddonName, #optionsTable),
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
		tooltip = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_ALL_TT),
		getFunc = function() return not GamepadInventoryTweaks.SV.HideSearchOnAllInventoryPages end,
		setFunc = function(value)
				GamepadInventoryTweaks.SV.HideSearchOnAllInventoryPages = not value
				if GAMEPAD_INVENTORY then
					if optionsContext and optionsContext.ApplyInventorySearchVisibility then
						optionsContext.ApplyInventorySearchVisibility(GAMEPAD_INVENTORY)
					end
					if optionsContext and optionsContext.UpdateInventoryVisualFilterBar then
						optionsContext.UpdateInventoryVisualFilterBar(GAMEPAD_INVENTORY)
					end
				end
			end,
		width = "full",
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER),
		tooltip = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_CRAFTBAG_TT),
		getFunc = function() return not GamepadInventoryTweaks.SV.HideSearchOnCraftBagPage end,
		setFunc = function(value)
				GamepadInventoryTweaks.SV.HideSearchOnCraftBagPage = not value
				if GAMEPAD_INVENTORY then
					if optionsContext and optionsContext.ApplyInventorySearchVisibility then
						optionsContext.ApplyInventorySearchVisibility(GAMEPAD_INVENTORY)
					end
					if optionsContext and optionsContext.UpdateInventoryVisualFilterBar then
						optionsContext.UpdateInventoryVisualFilterBar(GAMEPAD_INVENTORY)
					end
				end
			end,
		width = "full",
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(SI_GAMEPAD_BANK_CATEGORY_HEADER),
		tooltip = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_BANK_TT),
		getFunc = function() return not GamepadInventoryTweaks.SV.HideSearchOnBankPage end,
		setFunc = function(value)
				GamepadInventoryTweaks.SV.HideSearchOnBankPage = not value
				if GAMEPAD_BANKING then
					if optionsContext and optionsContext.ApplyBankSearchVisibility then
						optionsContext.ApplyBankSearchVisibility(GAMEPAD_BANKING)
					end
					if optionsContext and optionsContext.UpdateBankVisualFilterBar then
						optionsContext.UpdateBankVisualFilterBar(GAMEPAD_BANKING)
					end
				end
			end,
		width = "full",
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER),
		tooltip = GetString(SI_GAMEPADINVENTORYTWEAKS_HIDE_SEARCH_GUILDBANK_TT),
		getFunc = function() return not GamepadInventoryTweaks.SV.HideSearchOnGuildBankPage end,
		setFunc = function(value)
				GamepadInventoryTweaks.SV.HideSearchOnGuildBankPage = not value
				if GAMEPAD_GUILD_BANK then
					if optionsContext and optionsContext.ApplyGuildBankSearchVisibility then
						optionsContext.ApplyGuildBankSearchVisibility(GAMEPAD_GUILD_BANK)
					end
					if optionsContext and optionsContext.UpdateGuildBankVisualFilterBar then
						optionsContext.UpdateGuildBankVisualFilterBar(GAMEPAD_GUILD_BANK)
					end
				end
			end,
		width = "full",
	}


	local LAM = LibAddonMenu2
	if not (LAM and type(LAM.RegisterAddonPanel) == "function" and type(LAM.RegisterOptionControls) == "function") then
		return false
	end

	LAM:RegisterAddonPanel("GamepadInventoryTweaksMenu", panelData)
	LAM:RegisterOptionControls("GamepadInventoryTweaksMenu", optionsTable)
	return true
end
