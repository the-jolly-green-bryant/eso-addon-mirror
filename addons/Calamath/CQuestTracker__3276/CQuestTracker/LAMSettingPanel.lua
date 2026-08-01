--
-- Calamath's Quest Tracker [CQT]
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CQuestTracker then return end
local CQT = CQuestTracker:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString
local LMP = LibMediaProvider
local LAM = LibAddonMenu2
local LibCInteraction = LibCInteraction

-- ---------------------------------------------------------------------------------------
-- CQuestTracker LAMSettingPanel Class
-- ---------------------------------------------------------------------------------------
local CQT_LAMSettingPanel = CT_LAMSettingPanelController:Subclass()
function CQT_LAMSettingPanel:Initialize(panelId, currentSavedVars, accountWideSavedVars, defaults)
	CT_LAMSettingPanelController.Initialize(self, panelId)	-- Note: Inherit template class but not use as an initializing object.
	self.svCurrent = currentSavedVars or {}
	self.svAccount = accountWideSavedVars or {}
	self.SV_DEFAULT = defaults or {}
end

function CQT_LAMSettingPanel:FireCallbacks(...)
	return CQT and CQT.FireCallbacks and CQT:FireCallbacks(...)
end

function CQT_LAMSettingPanel:CreateSettingPanel()
	local panelData = {
		type = "panel", 
		name = "CQuestTracker", 
		displayName = "Calamath's Quest Tracker", 
		author = CQT.author, 
		version = CQT.version, 
		website = "https://www.esoui.com/downloads/info3276-CalamathsQuestTracker.html", 
		feedback = "https://www.esoui.com/downloads/info3276-CalamathsQuestTracker.html#comments", 
		donation = "https://www.esoui.com/downloads/info3276-CalamathsQuestTracker.html#donate", 
		slashCommand = "/cqt.settings", 
		registerForRefresh = true, 
		registerForDefaults = true, 
	}
	LAM:RegisterAddonPanel(self.panelId, panelData)

	local optionsData = {}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_PANEL_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_ACCOUNT_WIDE_OP_NAME), 
		getFunc = function() return self.svAccount.accountWide end, 
		setFunc = function(newValue) self.svAccount.accountWide = newValue end, 
		tooltip = L(SI_CQT_UI_ACCOUNT_WIDE_OP_TIPS), 
		width = "full", 
		requiresReload = true, 
		default = self.SV_DEFAULT.accountWide, 
	}
	optionsData[#optionsData + 1] = {
		type = "header", 
		name = L(SI_CQT_UI_BEHAVIOR_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_HIDE_DEFAULT_TRACKER_OP_NAME), 
		getFunc = function() return self.svCurrent.hideFocusedQuestTracker end, 
		setFunc = function(newValue)
			self.svCurrent.hideFocusedQuestTracker = newValue
			SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER, newValue and "false" or "true")
		end, 
--		tooltip = L(SI_CQT_UI_HIDE_DEFAULT_TRACKER_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.hideFocusedQuestTracker, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_HIDE_QUEST_TRACKER_OP_NAME), 
		getFunc = function() return self:GetTrackerPanelHideSetting() end, 
		setFunc = function(newValue)
			self:SetTrackerPanelHideSetting(newValue)
		end, 
--		tooltip = L(SI_CQT_UI_HIDE_QUEST_TRACKER_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.hideCQuestTracker, 
		reference = "CQT_UI_OptionsPanel_HideQuestTrackerCheckBox", 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_SHOW_IN_COMBAT_OP_NAME), 
		getFunc = function() return self.svCurrent.panelBehavior.showInCombat end, 
		setFunc = function(newValue)
			self.svCurrent.panelBehavior.showInCombat = newValue
			self:FireCallbacks("TrackerPanelVisibilitySettingsChanged")
		end, 
		tooltip = L(SI_CQT_UI_SHOW_IN_COMBAT_OP_TIPS), 
		width = "full", 
		disabled = function() return self:GetTrackerPanelHideSetting() end, 
		default = self.SV_DEFAULT.panelBehavior.showInCombat, 
		reference = "CQT_UI_OptionsPanel_ShowInCombatCheckBox", 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_SHOW_IN_GAMEMENU_SCENE_OP_NAME), 
		getFunc = function() return self.svCurrent.panelBehavior.showInGameMenuScene end, 
		setFunc = function(newValue)
			self.svCurrent.panelBehavior.showInGameMenuScene = newValue
			self:FireCallbacks("TrackerPanelVisibilitySettingsChanged")
		end, 
		tooltip = L(SI_CQT_UI_SHOW_IN_GAMEMENU_SCENE_OP_TIPS), 
		width = "full", 
		disabled = function() return self:GetTrackerPanelHideSetting() end, 
		default = self.SV_DEFAULT.panelBehavior.showInGameMenuScene, 
		reference = "CQT_UI_OptionsPanel_ShowInGameMenuSceneCheckBox", 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_HIDE_IN_BATTLEGROUNDS_OP_NAME), 
		getFunc = function() return not self.svCurrent.panelBehavior.showInBattleground end, 
		setFunc = function(newValue)
			self.svCurrent.panelBehavior.showInBattleground = not newValue
			self:FireCallbacks("TrackerPanelVisibilitySettingsChanged")
		end, 
		tooltip = L(SI_CQT_UI_HIDE_IN_BATTLEGROUNDS_OP_TIPS), 
		width = "full", 
		disabled = function() return self:GetTrackerPanelHideSetting() end, 
		default = not self.SV_DEFAULT.panelBehavior.showInBattleground, 
		reference = "CQT_UI_OptionsPanel_HideInBattlegroundCheckBox", 
	}
	optionsData[#optionsData + 1] = {
		type = "header", 
		name = L(SI_CQT_UI_PANEL_OPTION_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CQT_UI_MAX_NUM_QUEST_DISPLAYED_OP_NAME), 
		tooltip = L(SI_CQT_UI_MAX_NUM_QUEST_DISPLAYED_OP_TIPS), 
		min = 1, 
		max = 15, 
		step = 1, 
		getFunc = function() return self.svCurrent.maxNumDisplay end, 
		setFunc = function(newValue)
			self.svCurrent.maxNumDisplay = newValue
			self.svCurrent.maxNumPinnedQuest = newValue
			self:FireCallbacks("AddOnSettingsChanged", "maxNumDisplay")
		end, 
		clampInput = true, 
		default = self.SV_DEFAULT.maxNumDisplay, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_COMPACT_MODE_OP_NAME), 
		getFunc = function() return self.svCurrent.panelAttributes.compactMode end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("compactMode", newValue)
			self:FireCallbacks("AddOnSettingsChanged", "compactMode")
		end, 
		tooltip = L(SI_CQT_UI_COMPACT_MODE_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.panelAttributes.compactMode, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_LOCK_POSITION_AND_SIZE_OP_NAME), 
		getFunc = function() return not self.svCurrent.panelAttributes.movable end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("movable", not newValue)
		end, 
		tooltip = L(SI_CQT_UI_LOCK_POSITION_AND_SIZE_OP_TIPS), 
		width = "full", 
		default = not self.SV_DEFAULT.panelAttributes.movable, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_CLAMPED_TO_SCREEN_OP_NAME), 
		getFunc = function() return self.svCurrent.panelAttributes.clampedToScreen end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("clampedToScreen", newValue)
		end, 
		tooltip = L(SI_CQT_UI_CLAMPED_TO_SCREEN_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.panelAttributes.clampedToScreen, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_HIDE_QUEST_HINT_STEP_OP_NAME), 
		getFunc = function() return not self.svCurrent.panelAttributes.showHintStep end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("showHintStep", not newValue)
		end, 
		tooltip = L(SI_CQT_UI_HIDE_QUEST_HINT_STEP_OP_TIPS), 
		width = "full", 
		default = not self.SV_DEFAULT.panelAttributes.showHintStep, 
	}
	optionsData[#optionsData + 1] = {
		type = "header", 
		name = L(SI_CQT_UI_TRACKER_VISUAL_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_QUEST_HEADER_ICON_SUBHEADER_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_SHOW_FOCUSED_QUEST_ICON_OP_NAME), 
		getFunc = function() return self.svCurrent.panelAttributes.showFocusIcon end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("showFocusIcon", newValue)
		end, 
		tooltip = L(SI_CQT_UI_SHOW_FOCUSED_QUEST_ICON_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.panelAttributes.showFocusIcon, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_UNDERLINE_FOCUSED_QUEST_OP_NAME), 
		getFunc = function() return self.svCurrent.panelAttributes.underlineHeaderOnFocused end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("underlineHeaderOnFocused", newValue)
		end, 
		tooltip = L(SI_CQT_UI_UNDERLINE_FOCUSED_QUEST_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.panelAttributes.underlineHeaderOnFocused, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_SHOW_QUEST_TYPE_ICON_OP_NAME), 
		getFunc = function() return self.svCurrent.panelAttributes.showTypeIcon end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("showTypeIcon", newValue)
		end, 
		tooltip = L(SI_CQT_UI_SHOW_QUEST_TYPE_ICON_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.panelAttributes.showTypeIcon, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_QUEST_TYPE_ICON_COLOR_OP_NAME), 
		getFunc = function() return self.svCurrent.panelAttributes.enableTypeIconColoring end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("enableTypeIconColoring", newValue)
		end, 
		tooltip = L(SI_CQT_UI_QUEST_TYPE_ICON_COLOR_OP_TIPS), 
		width = "full", 
		disabled = function() return not self.svCurrent.panelAttributes.showTypeIcon end, 
		default = self.SV_DEFAULT.panelAttributes.enableTypeIconColoring, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_SHOW_REPEATABLE_QUEST_ICON_OP_NAME), 
		getFunc = function() return self.svCurrent.panelAttributes.showRepeatableQuestIcon end, 
		setFunc = function(newValue)
			self:SetTrackerPanelAttribute("showRepeatableQuestIcon", newValue)
		end, 
		tooltip = L(SI_CQT_UI_SHOW_REPEATABLE_QUEST_ICON_OP_TIPS), 
		width = "full", 
		disabled = function() return not self.svCurrent.panelAttributes.showTypeIcon end, 
		default = self.SV_DEFAULT.panelAttributes.showRepeatableQuestIcon, 
	}

	local fontTypeChoices = {
		"Bold Font", 
		"Chat Font", 
		"Custom", 
	}
	local fontTypeChoicesValues = {
		"$(BOLD_FONT)", 
		"$(CHAT_FONT)", 
		"custom", 
	}
	local fontStyleChoices = LMP:List("font")
	local fontWeightChoices = {
		"normal", 
		"shadow", 
		"outline", 
		"thick-outline", 
		"soft-shadow-thin", 
		"soft-shadow-thick", 
	}
	local function GetFontDescriptor(font)
		local fontPath = font[FONT_TYPE] == "custom" and LMP:Fetch("font", font[FONT_STYLE]) or font[FONT_TYPE]
		if font[FONT_WEIGHT] and font[FONT_WEIGHT] ~= "normal" then
			return string.format("%s|%u|%s", fontPath, font[FONT_SIZE], font[FONT_WEIGHT])
		else
			return string.format("%s|%u", fontPath, font[FONT_SIZE])
		end
	end
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_QUEST_NAME_FONT_SUBHEADER_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTTYPE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_NAME_FONTTYPE_MENU_TIPS), 
		choices = fontTypeChoices, 
		choicesValues = fontTypeChoicesValues, 
		getFunc = function() return self.svCurrent.qhFont[FONT_TYPE] end, 
		setFunc = function(typeStr)
			self.svCurrent.qhFont[FONT_TYPE] = typeStr
			self:SetTrackerPanelAttribute("headerFont", GetFontDescriptor(self.svCurrent.qhFont))
		end, 
		scrollable = 15, 
		default = self.SV_DEFAULT.qhFont[FONT_TYPE], 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTSTYLE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_NAME_FONTSTYLE_MENU_TIPS), 
		choices = fontStyleChoices, 
		getFunc = function() return self.svCurrent.qhFont[FONT_STYLE] end, 
		setFunc = function(styleStr)
			self.svCurrent.qhFont[FONT_STYLE] = styleStr
			self:SetTrackerPanelAttribute("headerFont", GetFontDescriptor(self.svCurrent.qhFont))
		end, 
		scrollable = 15, 
		disabled = function() return self.svCurrent.qhFont[FONT_TYPE] ~= "custom" end, 
		default = self.SV_DEFAULT.qhFont[FONT_STYLE], 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CQT_UI_COMMON_FONTSIZE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_NAME_FONTSIZE_MENU_TIPS), 
		min = 8,
		max = 64,
		getFunc = function() return self.svCurrent.qhFont[FONT_SIZE] end, 
		setFunc = function(fontSize)
			self.svCurrent.qhFont[FONT_SIZE] = fontSize
			self:SetTrackerPanelAttribute("headerFont", GetFontDescriptor(self.svCurrent.qhFont))
		end, 
		clampInput = false, 
		default = self.SV_DEFAULT.qhFont[FONT_SIZE], 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTWEIGHT_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_NAME_FONTWEIGHT_MENU_TIPS), 
		choices = fontWeightChoices, 
		getFunc = function() return self.svCurrent.qhFont[FONT_WEIGHT] end, 
		setFunc = function(weightStr)
			self.svCurrent.qhFont[FONT_WEIGHT] = weightStr
			self:SetTrackerPanelAttribute("headerFont", GetFontDescriptor(self.svCurrent.qhFont))
		end, 
		scrollable = 15, 
		default = self.SV_DEFAULT.qhFont[FONT_WEIGHT], 
	}
	optionsData[#optionsData + 1] = {
		type = "colorpicker", 
		name = L(SI_CQT_UI_QUEST_NAME_NORMAL_COLOR_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_NAME_NORMAL_COLOR_MENU_TIPS), 
		getFunc = function()
			local r, g, b = unpack(self.svCurrent.panelAttributes.headerColor)
			return r, g, b
		end, 
		setFunc = function(r, g, b)
			local a = self.svCurrent.panelAttributes.headerColor[4]
			self:SetTrackerPanelAttribute("headerColor", { r, g, b, a, })
		end, 
		default = {
			r = self.SV_DEFAULT.panelAttributes.headerColor[1], 
			g = self.SV_DEFAULT.panelAttributes.headerColor[2], 
			b = self.SV_DEFAULT.panelAttributes.headerColor[3], 
		}, 
	}
	optionsData[#optionsData + 1] = {
		type = "colorpicker", 
		name = L(SI_CQT_UI_QUEST_NAME_FOCUSED_COLOR_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_NAME_FOCUSED_COLOR_MENU_TIPS), 
		getFunc = function()
			local r, g, b = unpack(self.svCurrent.panelAttributes.headerColorSelected)
			return r, g, b
		end, 
		setFunc = function(r, g, b)
			local a = self.svCurrent.panelAttributes.headerColorSelected[4]
			self:SetTrackerPanelAttribute("headerColorSelected", { r, g, b, a, })
		end, 
		default = {
			r = self.SV_DEFAULT.panelAttributes.headerColorSelected[1], 
			g = self.SV_DEFAULT.panelAttributes.headerColorSelected[2], 
			b = self.SV_DEFAULT.panelAttributes.headerColorSelected[3], 
		}, 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_QUEST_CONDITION_FONT_SUBHEADER_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTTYPE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_CONDITION_FONTTYPE_MENU_TIPS), 
		choices = fontTypeChoices, 
		choicesValues = fontTypeChoicesValues, 
		getFunc = function() return self.svCurrent.qcFont[FONT_TYPE] end, 
		setFunc = function(typeStr)
			self.svCurrent.qcFont[FONT_TYPE] = typeStr
			self:SetTrackerPanelAttribute("conditionFont", GetFontDescriptor(self.svCurrent.qcFont))
		end, 
		scrollable = 15, 
		default = self.SV_DEFAULT.qcFont[FONT_TYPE], 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTSTYLE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_CONDITION_FONTSTYLE_MENU_TIPS), 
		choices = fontStyleChoices, 
		getFunc = function() return self.svCurrent.qcFont[FONT_STYLE] end, 
		setFunc = function(styleStr)
			self.svCurrent.qcFont[FONT_STYLE] = styleStr
			self:SetTrackerPanelAttribute("conditionFont", GetFontDescriptor(self.svCurrent.qcFont))
		end, 
		scrollable = 15, 
		disabled = function() return self.svCurrent.qcFont[FONT_TYPE] ~= "custom" end, 
		default = self.SV_DEFAULT.qcFont[FONT_STYLE], 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CQT_UI_COMMON_FONTSIZE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_CONDITION_FONTSIZE_MENU_TIPS), 
		min = 8,
		max = 64,
		getFunc = function() return self.svCurrent.qcFont[FONT_SIZE] end, 
		setFunc = function(fontSize)
			self.svCurrent.qcFont[FONT_SIZE] = fontSize
			self:SetTrackerPanelAttribute("conditionFont", GetFontDescriptor(self.svCurrent.qcFont))
		end, 
		clampInput = false, 
		default = self.SV_DEFAULT.qcFont[FONT_SIZE], 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTWEIGHT_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_CONDITION_FONTWEIGHT_MENU_TIPS), 
		choices = fontWeightChoices, 
		getFunc = function() return self.svCurrent.qcFont[FONT_WEIGHT] end, 
		setFunc = function(weightStr)
			self.svCurrent.qcFont[FONT_WEIGHT] = weightStr
			self:SetTrackerPanelAttribute("conditionFont", GetFontDescriptor(self.svCurrent.qcFont))
		end, 
		scrollable = 15, 
		default = self.SV_DEFAULT.qcFont[FONT_WEIGHT], 
	}
	optionsData[#optionsData + 1] = {
		type = "colorpicker", 
		name = L(SI_CQT_UI_QUEST_CONDITION_COLOR_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_CONDITION_COLOR_MENU_TIPS), 
		getFunc = function()
			local r, g, b = unpack(self.svCurrent.panelAttributes.conditionColor)
			return r, g, b
		end, 
		setFunc = function(r, g, b)
			local a = self.svCurrent.panelAttributes.conditionColor[4]
			self:SetTrackerPanelAttribute("conditionColor", { r, g, b, a, })
		end, 
		default = {
			r = self.SV_DEFAULT.panelAttributes.conditionColor[1], 
			g = self.SV_DEFAULT.panelAttributes.conditionColor[2], 
			b = self.SV_DEFAULT.panelAttributes.conditionColor[3], 
		}, 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_QUEST_HINT_FONT_SUBHEADER_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTTYPE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_HINT_FONTTYPE_MENU_TIPS), 
		choices = fontTypeChoices, 
		choicesValues = fontTypeChoicesValues, 
		getFunc = function() return self.svCurrent.qkFont[FONT_TYPE] end, 
		setFunc = function(typeStr)
			self.svCurrent.qkFont[FONT_TYPE] = typeStr
			self:SetTrackerPanelAttribute("hintFont", GetFontDescriptor(self.svCurrent.qkFont))
		end, 
		scrollable = 15, 
		default = self.SV_DEFAULT.qkFont[FONT_TYPE], 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTSTYLE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_HINT_FONTSTYLE_MENU_TIPS), 
		choices = fontStyleChoices, 
		getFunc = function() return self.svCurrent.qkFont[FONT_STYLE] end, 
		setFunc = function(styleStr)
			self.svCurrent.qkFont[FONT_STYLE] = styleStr
			self:SetTrackerPanelAttribute("hintFont", GetFontDescriptor(self.svCurrent.qkFont))
		end, 
		scrollable = 15, 
		disabled = function() return self.svCurrent.qkFont[FONT_TYPE] ~= "custom" end, 
		default = self.SV_DEFAULT.qkFont[FONT_STYLE], 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CQT_UI_COMMON_FONTSIZE_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_HINT_FONTSIZE_MENU_TIPS), 
		min = 8,
		max = 64,
		getFunc = function() return self.svCurrent.qkFont[FONT_SIZE] end, 
		setFunc = function(fontSize)
			self.svCurrent.qkFont[FONT_SIZE] = fontSize
			self:SetTrackerPanelAttribute("hintFont", GetFontDescriptor(self.svCurrent.qkFont))
		end, 
		clampInput = false, 
		default = self.SV_DEFAULT.qkFont[FONT_SIZE], 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_COMMON_FONTWEIGHT_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_HINT_FONTWEIGHT_MENU_TIPS), 
		choices = fontWeightChoices, 
		getFunc = function() return self.svCurrent.qkFont[FONT_WEIGHT] end, 
		setFunc = function(weightStr)
			self.svCurrent.qkFont[FONT_WEIGHT] = weightStr
			self:SetTrackerPanelAttribute("hintFont", GetFontDescriptor(self.svCurrent.qkFont))
		end, 
		scrollable = 15, 
		default = self.SV_DEFAULT.qkFont[FONT_WEIGHT], 
	}
	optionsData[#optionsData + 1] = {
		type = "colorpicker", 
		name = L(SI_CQT_UI_QUEST_HINT_COLOR_MENU_NAME), 
		tooltip = L(SI_CQT_UI_QUEST_HINT_COLOR_MENU_TIPS), 
		getFunc = function()
			local r, g, b = unpack(self.svCurrent.panelAttributes.hintColor)
			return r, g, b
		end, 
		setFunc = function(r, g, b)
			local a = self.svCurrent.panelAttributes.hintColor[4]
			self:SetTrackerPanelAttribute("hintColor", { r, g, b, a, })
		end, 
		default = {
			r = self.SV_DEFAULT.panelAttributes.hintColor[1], 
			g = self.SV_DEFAULT.panelAttributes.hintColor[2], 
			b = self.SV_DEFAULT.panelAttributes.hintColor[3], 
		}, 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_TITLEBAR_SUBHEADER_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "colorpicker", 
		name = L(SI_CQT_UI_TITLEBAR_COLOR_MENU_NAME), 
		tooltip = L(SI_CQT_UI_TITLEBAR_COLOR_MENU_TIPS), 
		getFunc = function()
			local r, g, b = unpack(self.svCurrent.panelAttributes.titlebarColor)
			return r, g, b
		end, 
		setFunc = function(r, g, b)
			local a = self.svCurrent.panelAttributes.titlebarColor[4]
			self:SetTrackerPanelAttribute("titlebarColor", { r, g, b, a, })
		end, 
		default = {
			r = self.SV_DEFAULT.panelAttributes.titlebarColor[1], 
			g = self.SV_DEFAULT.panelAttributes.titlebarColor[2], 
			b = self.SV_DEFAULT.panelAttributes.titlebarColor[3], 
		}, 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CQT_UI_COMMON_OPACITY_MENU_NAME), 
		tooltip = L(SI_CQT_UI_TITLEBAR_OPACITY_MENU_TIPS), 
		getFunc = function() return zo_round(self.svCurrent.panelAttributes.titlebarColor[4] * 100) end, 
		setFunc = function(newValue)
			local r, g, b = unpack(self.svCurrent.panelAttributes.titlebarColor)
			self:SetTrackerPanelAttribute("titlebarColor", { r, g, b, newValue / 100, })
		end, 
		min = 0.0, 
		max = 100.0, 
		step = 1, 
		default = zo_round(self.SV_DEFAULT.panelAttributes.titlebarColor[4] * 100), 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_BACKGROUND_SUBHEADER_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "colorpicker", 
		name = L(SI_CQT_UI_COMMON_BACKGROUND_COLOR_MENU_NAME), 
		tooltip = L(SI_CQT_UI_BACKGROUND_COLOR_MENU_TIPS), 
		getFunc = function()
			local r, g, b = unpack(self.svCurrent.panelAttributes.bgColor)
			return r, g, b
		end, 
		setFunc = function(r, g, b)
			local a = self.svCurrent.panelAttributes.bgColor[4]
			self:SetTrackerPanelAttribute("bgColor", { r, g, b, a, })
		end, 
		default = {
			r = self.SV_DEFAULT.panelAttributes.bgColor[1], 
			g = self.SV_DEFAULT.panelAttributes.bgColor[2], 
			b = self.SV_DEFAULT.panelAttributes.bgColor[3], 
		}, 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CQT_UI_COMMON_OPACITY_MENU_NAME), 
		tooltip = L(SI_CQT_UI_BACKGROUND_OPACITY_MENU_TIPS), 
		getFunc = function() return zo_round(self.svCurrent.panelAttributes.bgColor[4] * 100) end, 
		setFunc = function(newValue)
			local r, g, b = unpack(self.svCurrent.panelAttributes.bgColor)
			self:SetTrackerPanelAttribute("bgColor", { r, g, b, newValue / 100, })
		end, 
		min = 0.0, 
		max = 100.0, 
		step = 1, 
		default = zo_round(self.SV_DEFAULT.panelAttributes.bgColor[4] * 100), 
	}
	optionsData[#optionsData + 1] = {
		type = "header", 
		name = L(SI_CQT_UI_ADVANCED_OPTION_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_KEYBINDS_INTERACTION_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_KEYBINDS_IMPROVEMENT_MENU_NAME), 
		getFunc = function() return self.svCurrent.improveKeybinds end, 
		setFunc = function(newValue)
			self.svCurrent.improveKeybinds = newValue
			self:FireCallbacks("AddOnSettingsChanged", "improveKeybinds")
		end, 
		tooltip = L(SI_CQT_UI_KEYBINDS_IMPROVEMENT_MENU_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.improveKeybinds, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_CYCLE_DISPLAYED_QUESTS_MENU_NAME), 
		getFunc = function() return not self.svCurrent.cycleAllQuests end, 
		setFunc = function(newValue)
			self.svCurrent.cycleAllQuests = not newValue
		end, 
		tooltip = L(SI_CQT_UI_CYCLE_DISPLAYED_QUESTS_MENU_TIPS), 
		width = "full", 
		disabled = function() return not self.svCurrent.improveKeybinds end, 
		default = not self.SV_DEFAULT.cycleAllQuests, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_CYCLE_ZONE_GUIDE_MENU_NAME), 
		getFunc = function() return self.svCurrent.cycleZoneGuide end, 
		setFunc = function(newValue)
			self.svCurrent.cycleZoneGuide = newValue
		end, 
		tooltip = L(SI_CQT_UI_CYCLE_ZONE_GUIDE_MENU_TIPS), 
		width = "full", 
		disabled = function() return not self.svCurrent.improveKeybinds end, 
		default = not self.SV_DEFAULT.cycleZoneGuide, 
	}

	local modifierKeyChoices = {}
	local modifierKeyChoicesValues = LibCInteraction:GetSupportedModifierKeys()
	for k, v in pairs(modifierKeyChoicesValues) do
		table.insert(modifierKeyChoices, GetKeyName(v) .. " " .. ZO_Keybindings_GenerateIconKeyMarkup(v, 125))
	end
	table.insert(modifierKeyChoices, GetKeyName(KEY_INVALID))
	table.insert(modifierKeyChoicesValues, KEY_INVALID)
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_CYCLE_BACKWARDS_MOD_KEY1_MENU_NAME), 
		tooltip = L(SI_CQT_UI_CYCLE_BACKWARDS_MOD_KEY_MENU_TIPS), 
		choices = modifierKeyChoices, 
		choicesValues = modifierKeyChoicesValues, 
		sort = "value-up", 
		getFunc = function() return self.svCurrent.cycleBackwardsMod1 end, 
		setFunc = function(keyCode)
			self.svCurrent.cycleBackwardsMod1 = keyCode
		end, 
		scrollable = 15, 
		disabled = function() return not self.svCurrent.improveKeybinds end, 
		default = self.SV_DEFAULT.cycleBackwardsMod1, 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CQT_UI_CYCLE_BACKWARDS_MOD_KEY2_MENU_NAME), 
		tooltip = L(SI_CQT_UI_CYCLE_BACKWARDS_MOD_KEY_MENU_TIPS), 
		choices = modifierKeyChoices, 
		choicesValues = modifierKeyChoicesValues, 
		sort = "value-up", 
		getFunc = function() return self.svCurrent.cycleBackwardsMod2 end, 
		setFunc = function(keyCode)
			self.svCurrent.cycleBackwardsMod2 = keyCode
		end, 
		scrollable = 15, 
		disabled = function() return not self.svCurrent.improveKeybinds end, 
		default = self.SV_DEFAULT.cycleBackwardsMod2, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_HOLD_TO_DISPLAY_QUEST_TOOLTIP_NAME), 
		getFunc = function() return self.svCurrent.holdToShowQuestTooltip end, 
		setFunc = function(newValue)
			self.svCurrent.holdToShowQuestTooltip = newValue
		end, 
		tooltip = L(SI_CQT_UI_HOLD_TO_DISPLAY_QUEST_TOOLTIP_TIPS), 
		width = "full", 
		disabled = function() return not self.svCurrent.improveKeybinds end, 
		default = self.SV_DEFAULT.holdToShowQuestTooltip, 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_FOCUSED_QUEST_CONTROL_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_AUTO_TRACK_ADDED_QUEST_OP_NAME), 
		getFunc = function() return self.svCurrent.autoTrackToAddedQuest end, 
		setFunc = function(newValue)
			self.svCurrent.autoTrackToAddedQuest = newValue
			SetSetting(SETTING_TYPE_UI, UI_SETTING_AUTOMATIC_QUEST_TRACKING, newValue and "true" or "false")
			self:FireCallbacks("AddOnSettingsChanged", "focusedQuestControl")
		end, 
		tooltip = L(SI_CQT_UI_AUTO_TRACK_ADDED_QUEST_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.autoTrackToAddedQuest, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_AUTO_TRACK_PROGRESSED_QUEST_OP_NAME), 
		getFunc = function() return self.svCurrent.autoTrackToProgressedQuest end, 
		setFunc = function(newValue)
			self.svCurrent.autoTrackToProgressedQuest = newValue
			self:FireCallbacks("AddOnSettingsChanged", "focusedQuestControl")
		end, 
		tooltip = L(SI_CQT_UI_AUTO_TRACK_PROGRESSED_QUEST_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.autoTrackToProgressedQuest, 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CQT_UI_QUEST_PING_NAVIGATION_HEADER1_TEXT), 
		tooltip = L(SI_CQT_UI_QUEST_PING_NAVIGATION_HEADER1_TIPS), 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_ENABLE_QUEST_PING_OP_NAME), 
		getFunc = function() return self.svCurrent.qPingAttributes.pingingEnabled end, 
		setFunc = function(newValue)
			self.svCurrent.qPingAttributes.pingingEnabled = newValue
			self:FireCallbacks("AddOnSettingsChanged", "questPing")
		end, 
		tooltip = L(SI_CQT_UI_ENABLE_QUEST_PING_OP_TIPS), 
		width = "full", 
		default = self.SV_DEFAULT.qPingAttributes.pingingEnabled, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_QUEST_PING_ON_FOCUS_CHANGE_OP_NAME), 
		getFunc = function() return self.svCurrent.qPingAttributes.pingingOnFocusChange end, 
		setFunc = function(newValue)
			self.svCurrent.qPingAttributes.pingingOnFocusChange = newValue
			self:FireCallbacks("AddOnSettingsChanged", "questPing")
		end, 
		tooltip = L(SI_CQT_UI_QUEST_PING_ON_FOCUS_CHANGE_OP_TIPS), 
		width = "full", 
		disabled = function() return not self.svCurrent.qPingAttributes.pingingEnabled end, 
		default = self.SV_DEFAULT.qPingAttributes.pingingOnFocusChange, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CQT_UI_STOP_QUEST_PING_ON_MINIMAP_OP_NAME), 
		getFunc = function() return self.svCurrent.qPingAttributes.stopPingingOnHidingMapScene end, 
		setFunc = function(newValue)
			self.svCurrent.qPingAttributes.stopPingingOnHidingMapScene = newValue
			self:FireCallbacks("AddOnSettingsChanged", "questPing")
		end, 
		tooltip = L(SI_CQT_UI_STOP_QUEST_PING_ON_MINIMAP_OP_TIPS), 
		width = "full", 
		disabled = function() return not self.svCurrent.qPingAttributes.pingingEnabled end, 
		default = self.SV_DEFAULT.qPingAttributes.stopPingingOnHidingMapScene, 
	}
	LAM:RegisterOptionControls(self.panelId, optionsData)
end

function CQT_LAMSettingPanel:UpdateSettingPanel()
	if self:IsPanelShown() then
		if CQT_UI_OptionsPanel_HideQuestTrackerCheckBox then
			CQT_UI_OptionsPanel_HideQuestTrackerCheckBox:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.
		end
		if CQT_UI_OptionsPanel_ShowInCombatCheckBox and CQT_UI_OptionsPanel_ShowInCombatCheckBox.UpdateDisabled then
			CQT_UI_OptionsPanel_ShowInCombatCheckBox:UpdateDisabled()
		end
		if CQT_UI_OptionsPanel_ShowInGameMenuSceneCheckBox and CQT_UI_OptionsPanel_ShowInGameMenuSceneCheckBox.UpdateDisabled then
			CQT_UI_OptionsPanel_ShowInGameMenuSceneCheckBox:UpdateDisabled()
		end
		if CQT_UI_OptionsPanel_HideInBattlegroundCheckBox and CQT_UI_OptionsPanel_HideInBattlegroundCheckBox.UpdateDisabled then
			CQT_UI_OptionsPanel_HideInBattlegroundCheckBox:UpdateDisabled()
		end
	end
end

function CQT_LAMSettingPanel:SetTrackerPanelAttribute(key, value)
	if self.svCurrent.panelAttributes[key] ~= nil then
		self.svCurrent.panelAttributes[key] = value
		self:FireCallbacks("TrackerPanelAttributeSettingsChanged", key)
	end
end

function CQT_LAMSettingPanel:GetTrackerPanelHideSetting()
	return self.svCurrent.hideCQuestTracker
end

function CQT_LAMSettingPanel:SetTrackerPanelHideSetting(newValue)
	self.svCurrent.hideCQuestTracker = newValue
	self:UpdateSettingPanel()
	self:FireCallbacks("TrackerPanelVisibilitySettingsChanged")
end

function CQT_LAMSettingPanel:ToggleTrackerPanelHideSetting()
	self:SetTrackerPanelHideSetting(not self:GetTrackerPanelHideSetting())
end

CQuestTracker:RegisterClassObject("CQT_LAMSettingPanel", CQT_LAMSettingPanel)

