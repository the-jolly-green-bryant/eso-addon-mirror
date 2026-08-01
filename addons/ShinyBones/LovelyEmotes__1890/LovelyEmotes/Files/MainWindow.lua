local _mainWindowControl
local _contentControl
local _minimizedWindowControl

local _isMinimizedLocked = false

local _fragment
local _minimizedFragment
local _isFragmentAddedToScenes = false
local _isMinimizedFragmentAddedToScenes = false

local _modes = {}
local _modeButtons = {}
local _modeIndex = 0

local function IsMinimized()
	return _mainWindowControl:IsHidden()
end

function LovelyEmotes.MainWindow.IsMinimizedLocked()
	return _isMinimizedLocked
end

function LovelyEmotes.MainWindow.SetMinimizedLocked(value)
	_isMinimizedLocked = value
end

local function AddFragmentToScenes(fragment)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
end

local function RemoveFragmentFromScenes(fragment)
	HUD_SCENE:RemoveFragment(fragment)
	HUD_UI_SCENE:RemoveFragment(fragment)
end

local function TryAddFragmentToScenes()
	if _isFragmentAddedToScenes or _isMinimizedFragmentAddedToScenes then return end
	_isFragmentAddedToScenes = true

	AddFragmentToScenes(_fragment)
end

local function TryAddMinimizedFragmentToScenes()
	if _isMinimizedFragmentAddedToScenes or _isFragmentAddedToScenes then return end
	_isMinimizedFragmentAddedToScenes = true

	AddFragmentToScenes(_minimizedFragment)
end

local function TryRemoveFragmentFromScenes()
	if not _isFragmentAddedToScenes then return end
	_isFragmentAddedToScenes = false

	RemoveFragmentFromScenes(_fragment)
end

local function TryRemoveMinimizedFragmentFromScenes()
	if not _isMinimizedFragmentAddedToScenes then return end
	_isMinimizedFragmentAddedToScenes = false

	RemoveFragmentFromScenes(_minimizedFragment)
end

local function SetWindowHeight(height)
	local guiRootHeight = GuiRoot:GetHeight()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables
	height = height + LE_Const_MainWindowBaseHeight

	if _mainWindowControl:GetTop() + height > guiRootHeight then
		_mainWindowControl:ClearAnchors()
		_mainWindowControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedAccountVariables.MainWindowPositionX, guiRootHeight - height)
	else
		_mainWindowControl:ClearAnchors()
		_mainWindowControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedAccountVariables.MainWindowPositionX, savedAccountVariables.MainWindowPositionY)
	end

	_mainWindowControl:SetHeight(height)
end

local function Minimize()
	LovelyEmotes.PlayWindowCloseSound()

	_mainWindowControl:SetHidden(true)
	TryRemoveFragmentFromScenes()

	if LovelyEmotes_Settings.SavedAccountVariables.EnableMinimizedState == false then
		_minimizedWindowControl:SetHidden(true)
		TryRemoveMinimizedFragmentFromScenes()
		return
	end

	_minimizedWindowControl:SetHidden(false)
	TryAddMinimizedFragmentToScenes()
end

local function Expand()
	LovelyEmotes.PlayWindowOpenSound()

	_mainWindowControl:SetHidden(false)
	_minimizedWindowControl:SetHidden(true)

	TryRemoveMinimizedFragmentFromScenes()
	TryAddFragmentToScenes()
end

local function SetMinimized(value, setLocked)
	if IsMinimized() == value then return end

	if value then
		Minimize()
	else
		if LE_Invisible:IsHidden() or LE_RadialMenu.IsActive then return end
		Expand()
	end

	if (setLocked) then _isMinimizedLocked = value end

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_MinimizedStateChanged, value)
end

function LovelyEmotes.MainWindow.ToggleMinimized(toggleCursor)
	if LE_Invisible:IsHidden() then return end

	SetMinimized(not IsMinimized(), true)

	if toggleCursor and SCENE_MANAGER:IsInUIMode() == IsMinimized() then
		SCENE_MANAGER:OnToggleHUDUIBinding()
	end
end

function LovelyEmotes.MainWindow.UpdateContentHeight()
	SetWindowHeight(_modes[_modeIndex]:GetHeight())
end

local function SetWindowPositionsLocked(value)
	if _mainWindowControl:IsMouseEnabled() ~= value then return end
	LovelyEmotes_Settings.SavedAccountVariables.LockedWindowPositions = value

	_mainWindowControl:SetMouseEnabled(not value)
	_minimizedWindowControl:SetMouseEnabled(not value)

	local lockButton = _mainWindowControl:GetNamedChild("LockButton")

	if value then
		lockButton:SetNormalTexture("esoui/art/miscellaneous/locked_up.dds")
		lockButton:SetMouseOverTexture("esoui/art/miscellaneous/locked_over.dds")
		lockButton:SetPressedTexture("esoui/art/miscellaneous/locked_down.dds")
		lockButton:SetDisabledTexture("esoui/art/miscellaneous/locked_up.dds")
		return
	end

	lockButton:SetNormalTexture("esoui/art/miscellaneous/unlocked_up.dds")
	lockButton:SetMouseOverTexture("esoui/art/miscellaneous/unlocked_over.dds")
	lockButton:SetPressedTexture("esoui/art/miscellaneous/unlocked_down.dds")
	lockButton:SetDisabledTexture("esoui/art/miscellaneous/unlocked_up.dds")
end

local function OpenMode(index)
	if _modeIndex == index then
		if _modeIndex == 1 then return end

		index = 1
	end

	if _modeIndex > 0 then
		_modes[_modeIndex]:Deactivate()
	end

	_modeIndex = index

	local targetMode = _modes[index]
	SetWindowHeight(targetMode:GetHeight()) -- set height first because of scroll list bug
	targetMode:Activate()
end

local function SortModeButtons()
	table.sort(_modeButtons, function(first, second) return first:GetName() < second:GetName() end)

	for i, b in ipairs(_modeButtons) do
		b:ClearAnchors()
		b:SetAnchor(TOPRIGHT, _mainWindowControl, TOPRIGHT, -25 - (i - 1) * 30, -4)
	end
end

local function AddMode(mode, buttonSettings)
	table.insert(_modes, mode)
	mode:Setup(_contentControl)

	local modeIndex = #_modes

	if buttonSettings then
		local buttonControl = CreateControlFromVirtual(mode.Name, _mainWindowControl, "LE_ModeButtonTemplate", "_LeModeButton")

		buttonControl:SetNormalTexture(buttonSettings.Normal)
		buttonControl:SetMouseOverTexture(buttonSettings.MouseOver)
		buttonControl:SetPressedTexture(buttonSettings.Pressed)
		buttonControl:SetDisabledTexture(buttonSettings.Normal)

		if buttonSettings.WhiteSpaceCompensation then
			local compensation = buttonSettings.WhiteSpaceCompensation
			buttonControl:SetTextureCoords(compensation, 1 - compensation, compensation, 1 - compensation)
		end

		buttonControl:SetHandler("OnClicked", function(control, button)
			OpenMode(modeIndex)
		end)

		table.insert(_modeButtons, buttonControl)
		SortModeButtons()
	end

	return modeIndex
end

function LovelyEmotes.MainWindow.UpdateModeButtonClickSound(soundName)
	for i, b in ipairs(_modeButtons) do
		b:SetClickSound(soundName)
	end
end

function LovelyEmotes.MainWindow.UpdateAlpha()
	_mainWindowControl:SetAlpha(LovelyEmotes_Settings.SavedAccountVariables.Alpha / 100)
end

function LovelyEmotes.MainWindow.UpdateAlphaMinimized()
	_minimizedWindowControl:SetAlpha(LovelyEmotes_Settings.SavedAccountVariables.MinimizedAlpha / 100)
end

local function SavePosition()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables
	savedAccountVariables.MainWindowPositionX = _mainWindowControl:GetLeft()
	savedAccountVariables.MainWindowPositionY = _mainWindowControl:GetTop()
end

local function SaveMinimizedPosition()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables
	savedAccountVariables.MainWindowMinimizedPositionX = _minimizedWindowControl:GetLeft()
	savedAccountVariables.MainWindowMinimizedPositionY = _minimizedWindowControl:GetTop()
end

local function SetMinimizedWindowScale(newScale)
	_minimizedWindowControl:SetScale(newScale)
end

LovelyEmotes.MainWindow.IsMinimized = IsMinimized
LovelyEmotes.MainWindow.SetMinimized = SetMinimized
LovelyEmotes.MainWindow.TryAddMinimizedFragmentToScenes = TryAddMinimizedFragmentToScenes
LovelyEmotes.MainWindow.TryRemoveMinimizedFragmentFromScenes = TryRemoveMinimizedFragmentFromScenes
LovelyEmotes.MainWindow.SetMinimizedWindowScale = SetMinimizedWindowScale
LovelyEmotes.MainWindow.SetWindowPositionsLocked = SetWindowPositionsLocked

function LovelyEmotes.MainWindow.Initialize()
	_mainWindowControl = LE_MainWindowControl
	_contentControl = _mainWindowControl:GetNamedChild("Content")
	_minimizedWindowControl = LE_MinimizedWindowControl
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables

	_mainWindowControl:ClearAnchors()
	_mainWindowControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedAccountVariables.MainWindowPositionX, savedAccountVariables.MainWindowPositionY)
	_mainWindowControl:SetHandler("OnMoveStop", SavePosition)

	_minimizedWindowControl:ClearAnchors()
	_minimizedWindowControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedAccountVariables.MainWindowMinimizedPositionX, savedAccountVariables.MainWindowMinimizedPositionY)
	_minimizedWindowControl:SetHandler("OnMoveStop", SaveMinimizedPosition)

	_fragment = ZO_SimpleSceneFragment:New(_mainWindowControl)
	_minimizedFragment = ZO_SimpleSceneFragment:New(_minimizedWindowControl)

	SetMinimizedWindowScale(savedAccountVariables.MinimizedScale)
	SetWindowPositionsLocked(savedAccountVariables.LockedWindowPositions)

	LovelyEmotes.MainWindow.UpdateAlpha()
	LovelyEmotes.MainWindow.UpdateAlphaMinimized()

	if savedAccountVariables.StartMinimized or savedAccountVariables.MinimizeAutomatically then
		SetMinimized(true, true)
	else
		Expand()
	end

	AddMode(LE_FavoriteEmotesMode)
	OpenMode(1)

	AddMode(LE_EmoteListMode, {
		Normal = "esoui/art/icons/achievements_indexicon_summary_up.dds",
		MouseOver = "esoui/art/icons/achievements_indexicon_summary_over.dds",
		Pressed = "esoui/art/icons/achievements_indexicon_summary_down.dds",

		WhiteSpaceCompensation = 0.05,
	})

	AddMode(LE_PersonalityListMode, {
		Normal = "esoui/art/tutorial/tutorial_idexicon_emotes_up.dds",
		MouseOver = "esoui/art/tutorial/tutorial_idexicon_emotes_over.dds",
		Pressed = "esoui/art/help/help_tabicon_emotes_down.dds",

		WhiteSpaceCompensation = 0.05,
	})

	--[[
	LovelyEmotes.MainWindow.AddMode = function(mode, buttonSettings)
		if buttonSettings == nil then return end
		AddMode(mode, buttonSettings)
	end
	]]
end
