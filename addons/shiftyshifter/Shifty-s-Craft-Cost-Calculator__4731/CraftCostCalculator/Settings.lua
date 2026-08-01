-- LibAddonMenu-2.0 settings panel.

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.SettingsMenu = CCC.SettingsMenu or {}
local S = CCC.SettingsMenu

function S:Init(addon)
	S.addon = addon

	local LAM = LibAddonMenu2
	if not LAM then
		return
	end

	local panelData = {
		type = "panel",
		name = CCC.DisplayName,
		displayName = CCC.DisplayName,
		author = CCC.Author,
		version = CCC.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options = {
		{
			type = "dropdown",
			name = GetString(CCC_SETTING_PRICE_MODE),
			tooltip = GetString(CCC_SETTING_PRICE_MODE_TOOLTIP),
			choices = {"Suggested", "Avg", "SaleAvg", "Min"},
			getFunc = function()
				return addon.Settings.priceMode
			end,
			setFunc = function(value)
				addon.Settings.priceMode = value
			end,
			default = addon:GetDefaults().priceMode,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_MAX_EXPERTISE),
			tooltip = GetString(CCC_SETTING_MAX_EXPERTISE_TOOLTIP),
			getFunc = function()
				return addon.Settings.assumeMaxImprovementExpertise
			end,
			setFunc = function(value)
				addon.Settings.assumeMaxImprovementExpertise = value
			end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_PRINT_CHAT),
			getFunc = function()
				return addon.Settings.printToChat
			end,
			setFunc = function(value)
				addon.Settings.printToChat = value
			end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_SHOW_WINDOW),
			getFunc = function()
				return addon.Settings.showWindow
			end,
			setFunc = function(value)
				addon.Settings.showWindow = value
			end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_CONTEXT_MENU),
			getFunc = function()
				return addon.Settings.contextMenu
			end,
			setFunc = function(value)
				addon.Settings.contextMenu = value
			end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_USE_OWNED),
			tooltip = GetString(CCC_SETTING_USE_OWNED_TOOLTIP),
			getFunc = function()
				return addon.Settings.useOwnedMaterials
			end,
			setFunc = function(value)
				addon.Settings.useOwnedMaterials = value
				if addon.OwnedMaterials then
					addon.OwnedMaterials:InvalidateCache()
				end
				if addon.RefreshDisplayedResult then
					addon:RefreshDisplayedResult()
				end
			end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_SHOW_MISSING),
			tooltip = GetString(CCC_SETTING_SHOW_MISSING_TOOLTIP),
			getFunc = function()
				return addon.Settings.showMissingPrices
			end,
			setFunc = function(value)
				addon.Settings.showMissingPrices = value
			end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_CHECK_KNOWLEDGE),
			tooltip = GetString(CCC_SETTING_CHECK_KNOWLEDGE_TOOLTIP),
			getFunc = function()
				return addon.Settings.checkWritKnowledge ~= false
			end,
			setFunc = function(value)
				addon.Settings.checkWritKnowledge = value
				if addon.RefreshDisplayedResult then
					addon:RefreshDisplayedResult()
				end
			end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(CCC_SETTING_INCLUDE_GLYPHS),
			tooltip = GetString(CCC_SETTING_INCLUDE_GLYPHS_TOOLTIP),
			getFunc = function()
				return addon.Settings.includeGlyphCosts ~= false
			end,
			setFunc = function(value)
				addon.Settings.includeGlyphCosts = value
				if addon.RefreshDisplayedResult then
					addon:RefreshDisplayedResult()
				end
			end,
			default = true,
		},
	}

	LAM:RegisterAddonPanel(CCC.Name .. "Panel", panelData)
	LAM:RegisterOptionControls(CCC.Name .. "Panel", options)
end
