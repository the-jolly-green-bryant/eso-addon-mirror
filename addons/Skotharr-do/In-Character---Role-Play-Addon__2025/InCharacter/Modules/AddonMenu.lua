--[[
Title:   Addon Menu
Version: 1.1.3
Author:  @Skotharr-do [PC/EU]
--]]

IC.AddonMenu = {}

local addonMenu = {}

function IC.AddonMenu.Create()
	local LAM = LibStub:GetLibrary('LibAddonMenu-2.0')
	addonMenu.LAM = LAM
	
	local ADDON_MENU = 'InCharacterAddonMenu'
	
	local panelData = {
		 type = 'panel',
		 name = GetString(SI_INCHARACTER_UI_ADDON_MENU_NAME),
		 displayName = GetString(SI_INCHARACTER_UI_ADDON_MENU_TITLE),
		 author = '@Skotharr-do [PC/EU]',
		 version = '1.1.3',
		 website = 'https://www.esoui.com/downloads/info2025-In-Character-RolePlayAddon.html',
		 slashCommand = '/icmenu',
		 registerForRefresh = true
	}
	addonMenu.panel = LAM:RegisterAddonPanel(ADDON_MENU, panelData)
	
	local optionsData = {
		[1] = {
			type = 'description',
			title = GetString(SI_INCHARACTER_UI_ADDON_MENU_BINDINGS_TITLE),
			text = GetString(SI_INCHARACTER_UI_ADDON_MENU_BINDINGS_TEXT)
		},
		[2] = {
			type = 'header',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_TITLE)
		},
		[3] = {
			type = 'checkbox',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_AVAILABILITY),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_AVAILABILITY_TOOLTIP),
			getFunc = IC.ReticleWindow.IsEnabled,
			setFunc = IC.ReticleWindow.SetEnabled
		},
		[4] = {
			type = 'checkbox',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_VISIBILITY),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_VISIBILITY_TOOLTIP),
			getFunc = IC.ReticleWindow.IsAlwaysVisible,
			setFunc = IC.ReticleWindow.SetAlwaysVisible
		},
		[5] = {
			type = 'dropdown',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING_TOOLTIP),
			choices = {
				GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING_TOP),
				GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING_BOTTOM)
			},
			choicesValues = { TOP, BOTTOM },
			getFunc = IC.ReticleWindow.GetAnchor,
			setFunc = IC.ReticleWindow.SetAnchor
		},
		[6] = {
			type = 'slider',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_WIDTH),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_WIDTH_TOOLTIP),
			min = 200,
			max = 1000,
			step = 10,
			clampInput = true,
			getFunc = IC.ReticleWindow.GetWidth,
			setFunc = IC.ReticleWindow.SetWidth
		},
		[7] = {
			type = 'slider',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_ALPHA),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_ALPHA_TOOLTIP),
			min = 0,
			max = 100,
			step = 10,
			clampInput = true,
			getFunc = function() return IC.ReticleWindow.GetAlpha() * 100 end,
			setFunc = function(value) IC.ReticleWindow.SetAlpha(value / 100) end
		},
		[8] = {
			type = 'slider',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_BACKGROUND_ALPHA),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_BACKGROUND_ALPHA_TOOLTIP),
			min = 0,
			max = 100,
			step = 10,
			clampInput = true,
			getFunc = function() return IC.ReticleWindow.GetBackgroundAlpha() * 100 end,
			setFunc = function(value) IC.ReticleWindow.SetBackgroundAlpha(value / 100) end
		},
		[9] = {
			type = 'checkbox',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_TIMESTAMP_VISIBILITY),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_RETICLE_TIMESTAMP_VISIBILITY_TOOLTIP),
			getFunc = IC.ReticleWindow.IsTimestampVisible,
			setFunc = IC.ReticleWindow.SetTimestampVisible
		},
		[10] = {
			type = 'header',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_EDIT_TITLE)
		},
		[11] = {
			type = 'slider',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_EDIT_WIDTH),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_EDIT_WIDTH_TOOLTIP),
			min = 450,
			max = 1000,
			step = 10,
			clampInput = true,
			getFunc = IC.EditWindow.GetWidth,
			setFunc = IC.EditWindow.SetWidth
		},
		[12] = {
			type = 'slider',
			name = GetString(SI_INCHARACTER_UI_ADDON_MENU_EDIT_HEIGHT),
			tooltip = GetString(SI_INCHARACTER_UI_ADDON_MENU_EDIT_HEIGHT_TOOLTIP),
			min = 250,
			max = 1000,
			step = 10,
			clampInput = true,
			getFunc = IC.EditWindow.GetHeight,
			setFunc = IC.EditWindow.SetHeight
		}
	}
	LAM:RegisterOptionControls(ADDON_MENU, optionsData)
end

function IC.AddonMenu.Open()
	addonMenu.LAM:OpenToPanel(addonMenu.panel)
end