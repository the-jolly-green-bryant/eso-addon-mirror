local ADDON = DefaultLanguageNinja
local LAM = LibAddonMenu2

ADDON.UI = ADDON.UI or {}

ADDON.UI.RootName = ADDON.NAME .. "_UI"

--------
-- local
--------

local buttonWidth = 32
local buttonHeight = 32

local reticleHidden = false

local function load()
	ADDON.UI.TopLevelControl = ADDON.UI.TopLevelControl or DefaultLanguageNinja_UI or {}
	-- TODO
	ADDON.UI.ButtonBase = ADDON.UI.ButtonBase or DefaultLanguageNinja_UI_ButtonBase or {}
end

local function getButtonName(name)
	return ADDON.UI.RootName .. "_" .. name
end


--------
-- in this ADDON use, protected
--------

ADDON.UI.Restore = function()
	ADDON.develop("UI.Restore")
	load()

	if (ADDON.SaveData.Display.ShowUI == nil or not ADDON.SaveData.Display.ShowUI) then
		ADDON.UI.TopLevelControl:SetHidden(true)
		return
	end

	ADDON.UI.TopLevelControl:ClearAnchors()
	ADDON.UI.TopLevelControl:SetAnchor(
		TOPLEFT,
		GuiRoot,
		TOPLEFT,
		ADDON.SaveData.Position.Left,
		ADDON.SaveData.Position.Top
	)

	local iconNum = 0

	local clientLangCode = string.lower(GetCVar("language.2"))
	local commandButtons = {
		"OpenSettings",
	}
	local presetlanguageButtons = {
		"LoadEnglishNow",
		"LoadJapaneseNow",
		"LoadGermanNow",
		"LoadFrenchNow",
		"LoadRussianNow",
	}
	local userDefinedlanguageButtons = {
		"LoadUserDefined0Now",
		"LoadUserDefined1Now",
		"LoadUserDefined2Now",
	}

	for key, button in ipairs(commandButtons) do
		local flagControl = GetControl(getButtonName(button))
		if (ADDON.SaveData.Display.Buttons[button]) then
			flagControl:SetAnchor(LEFT, ADDON.UI.TopLevelControl, LEFT, iconNum * buttonWidth, 0)
			iconNum = iconNum + 1
		end
		flagControl:SetHidden(not ADDON.SaveData.Display.Buttons[button])
	end
	for key, button in ipairs(presetlanguageButtons) do
		local flagControl = GetControl(getButtonName(button))
		if (ADDON.SaveData.Display.Buttons[button]) then
			flagControl:SetAnchor(LEFT, ADDON.UI.TopLevelControl, LEFT, iconNum * buttonWidth, 0)
			iconNum = iconNum + 1
		end
		flagControl:SetHidden(not ADDON.SaveData.Display.Buttons[button])

		-- TODO
	end
	for key, button in ipairs(userDefinedlanguageButtons) do
		local flagControl = GetControl(getButtonName(button))
		if (ADDON.SaveData.Display.Buttons[button]) then
			flagControl:SetAnchor(LEFT, ADDON.UI.TopLevelControl, LEFT, iconNum * buttonWidth, 0)
			iconNum = iconNum + 1
		end
		flagControl:SetHidden(not ADDON.SaveData.Display.Buttons[button])
	end

	ADDON.UI.TopLevelControl:SetDimensions(16 + iconNum * buttonWidth, 10 + buttonHeight)

	local isDisplay = true

	if (iconNum == 0) then
		isDisplay = false -- no buttons
	elseif (not reticleHidden and ADDON.SaveData.Display.HideWhenReticleShown) then
		isDisplay = false -- reticle shown
	end

	ADDON.UI.TopLevelControl:SetHidden(not isDisplay)
end

ADDON.UI.ReticleUpdate = function(hidden)
	reticleHidden = hidden
	ADDON.UI.Restore()
end

--------
-- UI, defined without namespace
--------

DefaultLanguageNinja_UI_SavePosition = function()
	ADDON.develop("UI_SavePosition")
	load()

	local defaultSaveData = ADDON.GetDefaultSaveData()

	local left = ADDON.UI.TopLevelControl:GetLeft() or defaultSaveData.Position.Left
	local top = ADDON.UI.TopLevelControl:GetTop() or defaultSaveData.Position.Top
	ADDON.SaveData.Position = {
		["Left"] = left,
		["Top"] = top,
	}
end

DefaultLanguageNinja_UI_OnClickOpenSettings = function()
	ADDON.develop("UI_OnClickOpenSettings")

	LAM:OpenToPanel(ADDON.SettingsPanel)
end

DefaultLanguageNinja_UI_OnClickPresetLanguage = function(langCode)
	ADDON.develop("UI_OnClickPresetLanguage")

	ADDON.LoadLangCodeAndReload(langCode)
end

DefaultLanguageNinja_UI_OnClickUserDefinedLanguage = function(key)
	ADDON.develop("UI_OnClickUserDefinedLanguage")

	local userDefinedLangCode = ADDON.GetUserDefinedLangCode(key)
	if (userDefinedLangCode) then
		ADDON.LoadLangCodeAndReload(userDefinedLangCode)
	else
		ADDON.d("not defined yet.")
	end
end
