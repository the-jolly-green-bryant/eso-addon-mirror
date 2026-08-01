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
local LAM = LibAddonMenu2

-- ---------------------------------------------------------------------------------------
-- CBookFontStylist LAMSettingPanel Class
-- ---------------------------------------------------------------------------------------
local CBFS_LAMSettingPanel = CT_LAMSettingPanelController:Subclass()
function CBFS_LAMSettingPanel:Initialize(panelId, currentSavedVars, accountWideSavedVars, defaults)
	CT_LAMSettingPanelController.Initialize(self, panelId)	-- Note: Inherit template class but not use as an initializing object.
	self.db = accountWideSavedVars or {}
	self.SV_DEFAULT = defaults or {}

	self.fontManager = GetFontManager()
	self.uiLang = GetCVar("Language.2")
	self.uiIsGamepad = IsInGamepadPreferredMode()
	EVENT_MANAGER:RegisterForEvent(self.panelId, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(_, gamepadPreferred)
		self.uiIsGamepad = gamepadPreferred
	end)
	self.uiMediumId = BOOK_MEDIUM_YELLOWED_PAPER
end

function CBFS_LAMSettingPanel:CreateSettingPanel()
	local panelData = {
		type = "panel", 
		name = "CBookFontStylist", 
		displayName = "Calamath's BookFont Stylist", 
		author = CBFS.author, 
		version = CBFS.version, 
		website = "https://www.esoui.com/downloads/info2505-CalamathsBookFontStylist.html", 
		slashCommand = "/cbfs.settings", 
		registerForRefresh = true, 
		registerForDefaults = true, 
		resetFunc = function() self:OnPanelDefaultButtonClicked() end, 
	}
	LAM:RegisterAddonPanel(self.panelId, panelData)

	local optionsData = {}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CBFS_UI_PANEL_HEADER_TEXT), 
	}
	local bookMediumChoices = {}
	local bookMediumChoicesValues = {}
	for mediumId in ExtendedBookMediumIdIterator() do
		table.insert(bookMediumChoices, L("SI_CBFS_BOOK_MEDIUM", mediumId))
		table.insert(bookMediumChoicesValues, mediumId)
	end
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CBFS_UI_BMID_SELECT_MENU), 
		tooltip = L(SI_CBFS_UI_BMID_SELECT_MENU_TIPS), 
		choices = bookMediumChoices, 	-- If choicesValue is defined, choices table is only used for UI display!
		choicesValues = bookMediumChoicesValues, 
		getFunc = function() return self.uiMediumId end, 
		setFunc = function(mediumId) self:SetSelectedBookMedium(mediumId) end, 
		width = "half", 
		scrollable = 15, 
		default = BOOK_MEDIUM_YELLOWED_PAPER, 
	}
	optionsData[#optionsData + 1] = {
		type = "header", 
		name = function()
			return zo_strformat(L(SI_CBFS_UI_TAB_HEADER_FORMATTER), L("SI_CBFS_BOOK_MEDIUM", self.uiMediumId))
		end, 
		reference = "CBFS_UI_OptionsPanel_TabHeader", 
	}
	local fontChoices = LMP:List("font")
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CBFS_UI_TITLE_FONT_FACE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_FACE_MENU_TIPS), 
		choices = fontChoices, 
		getFunc = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_KEY] end, 
		setFunc = function(fontKey)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_KEY] = fontKey
			self:RefreshFontPreviewWindow()
		end, 
		scrollable = 15, 
		default = function()
			local titleFontFace = select(TITLE_FONT_FACE, GetExtendedBookMediumFontInfo(self.uiMediumId, self.uiIsGamepad))
			return self.fontManager:GetFontKeyByFontFace(titleFontFace)
		end, 
		reference = "CBFS_UI_OptionsPanel_TitleFontMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CBFS_UI_TITLE_FONT_SIZE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_SIZE_MENU_TIPS), 
		min = 8,
		max = 50,
		step = 1, 
		getFunc = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_SIZE] end, 
		setFunc = function(fontSize)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_SIZE] = fontSize
			self:RefreshFontPreviewWindow()
		end, 
		clampInput = false, 
		default = function()
			local titleFontSize = select(TITLE_FONT_SIZE, GetExtendedBookMediumFontInfo(self.uiMediumId, self.uiIsGamepad))
			return titleFontSize
		end, 
		reference = "CBFS_UI_OptionsPanel_TitleSizeMenu", 
	}
	local fontStyleChoices = {}
	local fontStyleChoicesValues = {}
	local fontStyleChoicesTooltips = {}
	for fontStyle = FONT_STYLE_ITERATION_BEGIN, FONT_STYLE_ITERATION_END do
		table.insert(fontStyleChoices, GetFontStyleString(fontStyle))
		table.insert(fontStyleChoicesValues, fontStyle)
		table.insert(fontStyleChoicesTooltips, L("SI_CBFS_FONT_STYLE", fontStyle))
	end
	for k, v in ipairs(fontStyleChoices) do
		if v == "" then
			fontStyleChoices[k] = "normal"	-- The value of FONT_STYLE_NORMAL is the empty string, making it unsuitable as a menu item.
			break
		end
	end
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CBFS_UI_TITLE_FONT_STYLE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_STYLE_MENU_TIPS), 
		choices = fontStyleChoices, 
		choicesValues = fontStyleChoicesValues, 
		choicesTooltips = fontStyleChoicesTooltips, 
		getFunc = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_STYLE] end, 
		setFunc = function(fontStyle)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][TITLE_FONT_STYLE] = fontStyle
			self:RefreshFontPreviewWindow()
		end, 
		default = function()
			local titleFontStyle = select(TITLE_FONT_STYLE, GetExtendedBookMediumFontInfo(self.uiMediumId, self.uiIsGamepad))
			return titleFontStyle
		end, 
		reference = "CBFS_UI_OptionsPanel_TitleWeightMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CBFS_UI_BODYFONT_FACE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_FACE_MENU_TIPS), 
		choices = fontChoices, 
		getFunc = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_KEY] end, 
		setFunc = function(fontKey)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_KEY] = fontKey
			self:RefreshFontPreviewWindow()
		end, 
		scrollable = 15, 
		default = function()
			local bodyFontFace = select(BODY_FONT_FACE, GetExtendedBookMediumFontInfo(self.uiMediumId, self.uiIsGamepad))
			return self.fontManager:GetFontKeyByFontFace(bodyFontFace)
		end, 
		reference = "CBFS_UI_OptionsPanel_BodyFontMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CBFS_UI_BODYFONT_SIZE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_SIZE_MENU_TIPS), 
		min = 8,
		max = 40,
		step = 1, 
		getFunc = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_SIZE] end, 
		setFunc = function(fontSize)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_SIZE] = fontSize
			self:RefreshFontPreviewWindow()
		end, 
		clampInput = false, 
		default = function()
			local bodyFontSize = select(BODY_FONT_SIZE, GetExtendedBookMediumFontInfo(self.uiMediumId, self.uiIsGamepad))
			return bodyFontSize
		end, 
		reference = "CBFS_UI_OptionsPanel_BodySizeMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CBFS_UI_BODYFONT_STYLE_MENU), 
		tooltip = L(SI_CBFS_UI_FONT_STYLE_MENU_TIPS), 
		choices = fontStyleChoices, 
		choicesValues = fontStyleChoicesValues, 
		choicesTooltips = fontStyleChoicesTooltips, 
		getFunc = function() return self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_STYLE] end, 
		setFunc = function(fontStyle)
			self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId][BODY_FONT_STYLE] = fontStyle
			self:RefreshFontPreviewWindow()
		end, 
		default = function()
			local bodyFontStyle = select(BODY_FONT_STYLE, GetExtendedBookMediumFontInfo(self.uiMediumId, self.uiIsGamepad))
			return bodyFontStyle
		end, 
		reference = "CBFS_UI_OptionsPanel_BodyWeightMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "button", 
		name = L(SI_CBFS_UI_LOAD_DEFAULT_FONT_NAME), 
		tooltip = L(SI_CBFS_UI_LOAD_DEFAULT_FONT_TIPS), 
		func = function() self:OnPanelDefaultFontButtonClicked() end, 
		width = "half", 
	}
	optionsData[#optionsData + 1] = {
		type = "button", 
		name = L(SI_CBFS_UI_SHOW_READER_WND_NAME), 
		tooltip = L(SI_CBFS_UI_SHOW_READER_WND_TIPS), 
		func = function() self:OnPanelPreviewButtonClicked() end, 
		width = "half", 
		disabled = function()
			return self.uiMediumId == BOOK_MEDIUM_ANTIQUITY_CODEX and self.antiquityIdForPreview == 0
		end, 
	}
	LAM:RegisterOptionControls(self.panelId, optionsData)
--	CBFS.LDL:Debug("Initalize LAM panel")
end

function CBFS_LAMSettingPanel:OnPanelControlsCreated(panel)
	if self.fontPreviewWindow then
		self.fontPreviewWindow:SetAnchor(LEFT, self.panel, RIGHT, 20, 0)	-- forcibly reset
		self.fontPreviewWindow:SetDimensions(400, 600)	-- forcibly reset
	end
	self:RefreshFontPreviewWindow()

	self:InitializePreviewMode()
end

function CBFS_LAMSettingPanel:OnPanelOpened(panel)
--	CBFS.LDL:Debug("LAM-Panel Opened")
	if self.fontPreviewWindow then
		self.fontPreviewWindow:Show()
	end
end

function CBFS_LAMSettingPanel:OnPanelClosed(panel)
--	CBFS.LDL:Debug("LAM-Panel Closed")
	if self.fontPreviewWindow then
		self.fontPreviewWindow:Hide()
	end
end

-- ----------------------------------------------------------------------------------------
function CBFS_LAMSettingPanel:RegisterFontPreviewWindow(fontPreviewWindowClassObject)
	self.fontPreviewWindow = fontPreviewWindowClassObject
end

function CBFS_LAMSettingPanel:RefreshFontPreviewWindow()
	if self.fontPreviewWindow then
		local t = self.db.config[self.uiLang][FORMAT_V2][self.uiMediumId]
		local bodyFont = self.fontManager:MakeFontDescriptorByLMP(t[BODY_FONT_KEY], t[BODY_FONT_SIZE], t[BODY_FONT_STYLE])
		local titleFont = self.fontManager:MakeFontDescriptorByLMP(t[TITLE_FONT_KEY], t[TITLE_FONT_SIZE], t[TITLE_FONT_STYLE])
		self.fontPreviewWindow:SetTitleFont(titleFont)
		self.fontPreviewWindow:SetBodyFont(bodyFont)
		self.fontPreviewWindow:SetMediumBgTexture(GetExtendedBookMediumTexture(self.uiMediumId))
	end
end

function CBFS_LAMSettingPanel:RefreshCurrentBookMediumTab(forceDefault)
-- Setting the argument forceDefault to true means resetting the current book medium tab to its default value.
	if self:IsPanelInitialized() then
		CBFS_UI_OptionsPanel_TabHeader:UpdateValue(forceDefault)
		CBFS_UI_OptionsPanel_BodyFontMenu:UpdateValue(forceDefault)
		CBFS_UI_OptionsPanel_BodySizeMenu:UpdateValue(forceDefault)
		CBFS_UI_OptionsPanel_BodyWeightMenu:UpdateValue(forceDefault)
		CBFS_UI_OptionsPanel_TitleFontMenu:UpdateValue(forceDefault)
		CBFS_UI_OptionsPanel_TitleSizeMenu:UpdateValue(forceDefault)
		CBFS_UI_OptionsPanel_TitleWeightMenu:UpdateValue(forceDefault)
		self:RefreshFontPreviewWindow()
	end
end

function CBFS_LAMSettingPanel:SetSelectedBookMedium(mediumId)
	self.uiMediumId = mediumId
	self:RefreshCurrentBookMediumTab(false)
end

function CBFS_LAMSettingPanel:OnPanelDefaultButtonClicked()
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
	self:SetSelectedBookMedium(BOOK_MEDIUM_YELLOWED_PAPER)
end

function CBFS_LAMSettingPanel:OnPanelDefaultFontButtonClicked()
	-- By clicking the Default Font button in the Settings panel, we reset only current book medium settings in the current language mode to the default.
	local RESET_TO_DEFAULT = true
	self:RefreshCurrentBookMediumTab(RESET_TO_DEFAULT)
end

function CBFS_LAMSettingPanel:InitializePreviewMode()
	-- obtain the id number of antiquity unlocked by the player.
	self.antiquityIdForPreview = 0
	for antiquityId = 1000, 1, -1 do
		if GetNumAntiquityLoreEntriesAcquired(antiquityId) > 0 then
			self.antiquityIdForPreview = antiquityId
			break
		end
	end
--	CBFS.LDL:Debug("self.antiquityIdForPreview = ", self.antiquityIdForPreview)
end

function CBFS_LAMSettingPanel:OnPanelPreviewButtonClicked()
	if self.uiMediumId == BOOK_MEDIUM_ANTIQUITY_CODEX then
		if self.antiquityIdForPreview ~= 0 then
			if ANTIQUITY_DATA_MANAGER.OnAntiquityShowCodexEntry then
				local antiquityLoreScene = IsInGamepadPreferredMode() and ANTIQUITY_LORE_SCENE_GAMEPAD or ANTIQUITY_LORE_KEYBOARD_SCENE
				if antiquityLoreScene then
					-- When the antiquity lore reader scene would be hidden in CBFS preview mode, we are forced to open the CBFS settings panel.
					SCENE_MANAGER:CallWhen(antiquityLoreScene:GetName(), SCENE_HIDDEN, function() self:OpenSettingPanel() end)
				end
				ANTIQUITY_DATA_MANAGER:OnAntiquityShowCodexEntry(self.antiquityIdForPreview)
				-- When you execute ANTIQUITY_DATA_MANAGER:OnAntiquityShowCodexEntry from the game menu scenes, you will be taken to either the "antiquityLoreKeyboard" or "gamepad_antiquity_lore" scene.
			end
		end
	else
		local loreReaderDefaultScene = IsInGamepadPreferredMode() and GAMEPAD_LORE_READER_DEFAULT_SCENE or LORE_READER_DEFAULT_SCENE
		if loreReaderDefaultScene then
			-- When the default lore reader scene would be hidden in CBFS preview mode, we are forced to open the CBFS settings panel.
			SCENE_MANAGER:CallWhen(loreReaderDefaultScene:GetName(), SCENE_HIDDEN, function() self:OpenSettingPanel() end)
		end
		LORE_READER:Show(L(SI_CBFS_UI_PREVIEW_BOOK_TITLE), L(SI_CBFS_UI_PREVIEW_BOOK_BODY), self.uiMediumId, true)
		-- When you execute LORE_READER:Show from the game menu scenes, you will be taken to either the "loreReaderDefault" or "gamepad_loreReaderDefault" scene, not to the lore reader custom scenes.
	end
end

CBookFontStylist:RegisterClassObject("CBFS_LAMSettingPanel", CBFS_LAMSettingPanel)
