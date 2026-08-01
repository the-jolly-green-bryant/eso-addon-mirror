--
-- Calamath's BookFont Stylist [CBFS]
--
-- Copyright (c) 2020 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CBookFontStylist then return end
local CBFS = CBookFontStylist:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString
local LMP = LibMediaProvider
local LHAS = LibHarvensAddonSettings

local function GetFontStyleName(fontStyle)
	local fontStyleStr = GetFontStyleString(fontStyle)
	if fontStyleStr == "" then
		fontStyleStr = "normal"
	end
	return fontStyleStr
end
-- ---------------------------------------------------------------------------------------
-- CBookFontStylist LHAS SettingPanel Class
-- ---------------------------------------------------------------------------------------
local CBFS_LHASSettingPanel = CT_LHASSettingPanelController:Subclass()
function CBFS_LHASSettingPanel:Initialize(panelId, currentSavedVars, accountWideSavedVars, defaults)
	CT_LHASSettingPanelController.Initialize(self, panelId)	-- Note: Inherit template class but not use as an initializing object.
	self.db = accountWideSavedVars or {}

	self.fontManager = GetFontManager()
	self.uiLang = GetCVar("Language.2")
	self.uiIsGamepad = IsInGamepadPreferredMode()
	self.uiMediumId = BOOK_MEDIUM_YELLOWED_PAPER
end

function CBFS_LHASSettingPanel:CreateSettingPanel()
	local panelData = {
		author = CBFS.author, 
		version = CBFS.version, 
		website = "https://www.esoui.com/downloads/info2505-CalamathsBookFontStylist.html", 
		allowRefresh = true, 
		allowDefaults = true, 
		defaultsFunction = function() self:OnPanelDefaultButtonClicked() end, 
	}

	local optionsData = {}
--[[
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_CHECKBOX,
		label = "Advanced Mode", 
		default = true, 
		setFunction = function() end,
		getFunction = function() return true end,
		disable = true, 
	}
]]
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_LABEL, 
		label = L(SI_CBFS_UI_PANEL_HEADER_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_SECTION, 
		label = L(SI_CBFS_UI_BMID_SELECT_MENU), 
		tooltip = L(SI_CBFS_UI_BMID_SELECT_MENU_TIPS), 
	}
	for mediumId in ExtendedBookMediumIdIterator() do
		optionsData[#optionsData + 1] = {
			type = LHAS.ST_BUTTON, 
			label = L("SI_CBFS_BOOK_MEDIUM", mediumId), 
			buttonText = L(SI_GAME_MENU_SETTINGS), 
			clickHandler = function(control, button)
				self:SetSelectedBookMedium(mediumId)
			end, 
		}
	end
	return CT_LHASSettingPanelController.CreateSettingPanel(self, panelData, optionsData)
end

function CBFS_LHASSettingPanel:OnPanelControlsCreated(panel)
	-- sub menu dialog
	self.subMenu = LibConsoleDialogs:Create(self.panel.name)
	local optionsData = {}
	local fontKeyItems = {}
	for _, fontKey in ipairs(LMP:List("font")) do
		table.insert(fontKeyItems, {
			name = fontKey, 
			data = fontKey, 
		})
	end
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_DROPDOWN, 
		label = L(SI_CBFS_UI_TITLE_FONT_FACE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_FACE_MENU_TIPS), 
		items = fontKeyItems, 
		getFunction = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_KEY] end, 
		setFunction = function(_, _, item)
			local fontKey = item.data
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_KEY] = fontKey
		end, 
	}
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_SLIDER, 
		label = L(SI_CBFS_UI_TITLE_FONT_SIZE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_SIZE_MENU_TIPS), 
		min = 8,
		max = 50,
		step = 1, 
		format = "%d", 
		getFunction = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_SIZE] end, 
		setFunction = function(fontSize)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_SIZE] = fontSize
		end, 
	}
	local fontStyleItems = {}
	for fontStyle = FONT_STYLE_ITERATION_BEGIN, FONT_STYLE_ITERATION_END do
		table.insert(fontStyleItems, {
			name = GetFontStyleName(fontStyle), 
			data = fontStyle, 
		})
	end
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_DROPDOWN, 
		label = L(SI_CBFS_UI_TITLE_FONT_STYLE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_STYLE_MENU_TIPS), 
		items = fontStyleItems, 
		getFunction = function()
			local titleFontStyle = self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_STYLE]
			return GetFontStyleName(titleFontStyle)
		end, 
		setFunction = function(_, _, item)
			local fontStyle = item.data
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_STYLE] = fontStyle
		end, 
	}
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_DROPDOWN, 
		label = L(SI_CBFS_UI_BODYFONT_FACE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_FACE_MENU_TIPS), 
		items = fontKeyItems, 
		getFunction = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_KEY] end, 
		setFunction = function(_, _, item)
			local fontKey = item.data
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_KEY] = fontKey
		end, 
	}
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_SLIDER, 
		label = L(SI_CBFS_UI_BODYFONT_SIZE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_SIZE_MENU_TIPS), 
		min = 8,
		max = 40,
		step = 1, 
		format = "%d", 
		getFunction = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_SIZE] end, 
		setFunction = function(fontSize)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_SIZE] = fontSize
		end, 
	}
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_DROPDOWN, 
		label = L(SI_CBFS_UI_BODYFONT_STYLE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_STYLE_MENU_TIPS), 
		items = fontStyleItems, 
		getFunction = function()
			local bodyFontStyle = self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_STYLE]
			return GetFontStyleName(bodyFontStyle)
		end, 
		setFunction = function(_, _, item)
			local fontStyle = item.data
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_STYLE] = fontStyle
		end, 
	}
	optionsData[#optionsData + 1] = {
		type = LHAS.ST_BUTTON, 
		label = L(SI_CBFS_UI_LOAD_DEFAULT_FONT_NAME), 
		tooltip = L(SI_CBFS_UI_LOAD_DEFAULT_FONT_TIPS), 
		clickHandler = function()
			self:OnPanelDefaultFontButtonClicked()
		end, 
	}
	self.subMenu:AddSettings(optionsData)
end

function CBFS_LHASSettingPanel:OnPanelOpened(panel)
	-- Trick LHAS into forcibly enabling the default keybind button.
	self.panel.hasDefaults = true
	self.panel:RefreshSelection()
end

function CBFS_LHASSettingPanel:OnPanelClosed(panel)
end

function CBFS_LHASSettingPanel:SetSelectedBookMedium(mediumId)
	self.uiMediumId = mediumId
	-- Override the header of the submenu dialog
	self.subMenu.headerData = {
		titleText = self.panel.name, 
		subtitleText = L("SI_CBFS_BOOK_MEDIUM", mediumId), 
	}
	self:PushConsoleDialog(self.subMenu)
end

function CBFS_LHASSettingPanel:OnPanelDefaultButtonClicked()
	-- By clicking the Default button in the Settings panel, we reset all book medium font settings in the current language mode to the default font.
	for mediumId in ExtendedBookMediumIdIterator() do
		local titleFontFace, titleFontSize, titleFontStyle, bodyFontFace, bodyFontSize, bodyFontStyle = GetExtendedBookMediumFontInfo(mediumId, self.uiIsGamepad)
		local t = {
			[TITLE_FONT_KEY] = self.fontManager:GetFontKeyByFontFace(titleFontFace), 
			[TITLE_FONT_SIZE] = titleFontSize, 
			[TITLE_FONT_STYLE] = titleFontStyle, 
			[BODY_FONT_KEY] = self.fontManager:GetFontKeyByFontFace(bodyFontFace), 
			[BODY_FONT_SIZE] = bodyFontSize, 
			[BODY_FONT_STYLE] =bodyFontStyle, 
		}
		self.db.config[self.uiLang][FORMAT_V2][mediumId] = t
	end
end

function CBFS_LHASSettingPanel:OnPanelDefaultFontButtonClicked()
	-- By clicking the Default Font button in the Settings panel, we reset only current book medium settings in the current language mode to the default.
	local titleFontFace, titleFontSize, titleFontStyle, bodyFontFace, bodyFontSize, bodyFontStyle = GetExtendedBookMediumFontInfo(self.uiMediumId, self.uiIsGamepad)
	local t = {
		[TITLE_FONT_KEY] = self.fontManager:GetFontKeyByFontFace(titleFontFace), 
		[TITLE_FONT_SIZE] = titleFontSize, 
		[TITLE_FONT_STYLE] = titleFontStyle, 
		[BODY_FONT_KEY] = self.fontManager:GetFontKeyByFontFace(bodyFontFace), 
		[BODY_FONT_SIZE] = bodyFontSize, 
		[BODY_FONT_STYLE] =bodyFontStyle, 
	}
	self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId] = t
end

CBookFontStylist:RegisterClassObject("CBFS_LHASSettingPanel", CBFS_LHASSettingPanel)
