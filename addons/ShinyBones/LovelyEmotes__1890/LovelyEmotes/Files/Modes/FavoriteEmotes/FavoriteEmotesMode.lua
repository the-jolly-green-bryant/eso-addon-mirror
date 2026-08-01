LE_FavoriteEmotesMode = LE_ModeBase:New("FavoriteEmotes")

local _favoriteButtonHeight = 30
local _tabButtons = {}
local _favoriteListItems = {}
local _selectedFavoriteIndex = 0

local _selectedTabIndex = 1
local _tabButtonAlphaSelected = 1
local _tabButtonAlphaDeselected = 0.33

local _tabColorR, _tabColorG, _tabColorB = ZO_NORMAL_TEXT:UnpackRGB()

local _buttonTemplates = {
	"LE_FavoriteEmoteTextButtonTemplate",
	"LE_FavoriteEmoteDefaultButtonTemplate",
}

local function DeselectFavoriteButton()
	if _selectedFavoriteIndex < 1 then return end

	_favoriteListItems[_selectedFavoriteIndex]:Deselect()
	_selectedFavoriteIndex = 0
end

local function SelectFavoriteButton(index)
	if _selectedFavoriteIndex == index then return end
	if _selectedFavoriteIndex > 0 then DeselectFavoriteButton() end

	_favoriteListItems[index]:Select()
	_selectedFavoriteIndex = index
end

local function SetTabButtonAlpha(index, alpha)
	_tabButtons[index]:SetNormalFontColor(_tabColorR, _tabColorG, _tabColorB, alpha)
end

local function RefreshFavoriteButton(index)
	_favoriteListItems[index]:Refresh()
end

local function RefreshAllFavoriteButtons()
	for i = LovelyEmotes_Settings.GetFavoriteButtonCount(), 1, -1 do
		RefreshFavoriteButton(i)
	end
end

local function UpdateTabButtonsHidden(visibleTabsCount)
	if visibleTabsCount < 2 then
		visibleTabsCount = 0
	end

	for i, b in ipairs(_tabButtons) do
		if i > visibleTabsCount then
			if b:IsControlHidden() then return end
			b:SetHidden(true)
		else
			b:SetHidden(false)
		end
	end
end

local function UpdateFavoriteButtonsHidden(visibleButtonsCount)
	for i, listItem in ipairs(_favoriteListItems) do
		if i > visibleButtonsCount then
			if listItem:IsControlHidden() then return end
			listItem:SetHidden(true)
		else
			-- Creates a random favorite-emote if required.
			if LovelyEmotes_Settings.GetSavedFavoriteID(i) == nil then
				LovelyEmotes.SaveRandomEmote(i)
			end

			listItem:SetHidden(false)
		end
	end
end

local function ShowFavoriteEmotesTab(tabIndex)
	LE_EmoteSelectionWindow.HideWindow()

	SetTabButtonAlpha(_selectedTabIndex, _tabButtonAlphaDeselected)
	SetTabButtonAlpha(tabIndex, _tabButtonAlphaSelected)
	_selectedTabIndex = tabIndex

	LovelyEmotes.MainWindow.UpdateContentHeight()

	UpdateFavoriteButtonsHidden(LovelyEmotes_Settings.GetFavoriteButtonCount())
	RefreshAllFavoriteButtons()
end

local function CreateTabs(parentControl)
	local firstRowItemsCount = LE_Const_FirstTabRowItemsCount

	for i = 1, LE_Const_FavoriteEmotesTabIndexMax do
		local button = CreateControlFromVirtual("LE_TabButton", parentControl, "LE_TabButtonTemplate", i)
		table.insert(_tabButtons, button)

		local positionOffsetY = 0
		local positionXIndex = i - 1

		if i > firstRowItemsCount then
			positionOffsetY = button:GetHeight()
			positionXIndex = positionXIndex - firstRowItemsCount
		end

		button:ClearAnchors()
		button:SetAnchor(TOPLEFT, LE_MainWindowControl, TOPLEFT, 44 + button:GetWidth() * positionXIndex, positionOffsetY)

		button:SetText(i)

		button:SetHandler("OnClicked", function()
			if LE_FavoriteEmotesMode.TryShowTab(i, true) == false then
				PlaySound("Click")
			end
		end)

		button:SetHandler("OnMouseEnter", function()
			local tab = LovelyEmotes_Settings.GetSavedFavoriteTab(i)

			if tab.Name ~= "" then
				ZO_Tooltips_ShowTextTooltip(LE_MainWindowControl, TOP, tab.Name)
			end
		end)

		button:SetHandler("OnMouseExit", function()
			ZO_Tooltips_HideTextTooltip()
		end)

		SetTabButtonAlpha(i, _tabButtonAlphaDeselected)
	end

	UpdateTabButtonsHidden(LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs())
end

local function CreateFavoriteButtons(parentControl)
	local buttonTemplate = _buttonTemplates[LovelyEmotes_Settings.SavedAccountVariables.FavoritesButtonDesign]

	for i = 1, LE_Const_FavoriteEmotesIndexMax do
		local offsetY = _favoriteButtonHeight * (i - 1)
		local listItemControl = CreateControlFromVirtual("LE_FavoriteEmoteButton", parentControl, buttonTemplate, i)
		local listItem = LE_FavoriteEmoteListItem:New(i, listItemControl)

		listItemControl:SetHeight(_favoriteButtonHeight)
		listItemControl:ClearAnchors()
		listItemControl:SetAnchor(TOPLEFT, nil, nil, 0, offsetY)
		listItemControl:SetAnchor(TOPRIGHT, nil, nil, 0, offsetY)

		table.insert(_favoriteListItems, listItem)

		listItem.ConfigButton:SetHandler("OnClicked", function()
			SelectFavoriteButton(listItem.Index)
			LE_EmoteSelectionWindow.ShowWindow(listItem.Index)
		end)

		listItem.EmoteButton:SetHandler("OnClicked", function(control, button)
			local targetEmote = LovelyEmotes.GetSavedEmote(listItem.Index)

			if not LovelyEmotes.IsEmoteSynchronizationActive() or button == 1 or targetEmote.ID < 0 then
				targetEmote.Play()
				return
			end

			LovelyEmotes.CreateSyncMessage(targetEmote)
		end)
	end
end

function LE_FavoriteEmotesMode:Setup(parentControl)
	LE_ModeBase.Setup(self, parentControl)

	CreateTabs(self.ContentControl)
	CreateFavoriteButtons(self.ContentControl)

	LE_EmoteSelectionWindow.Initialize()
	LE_EmoteSelectionWindow.SetHideCallback(DeselectFavoriteButton)

	LovelyEmotes_EventSystem.AddListener(LE_EVENT_NumberOfVisibleFavoriteEmotesTabsChanged, UpdateTabButtonsHidden)
end

function LE_FavoriteEmotesMode:GetHeight()
	return _favoriteButtonHeight * LovelyEmotes_Settings.GetFavoriteButtonCount()
end

local function Callback_EmoteSaved(tabIndex, slotIndex)
	if LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex() ~= tabIndex then return end
	RefreshFavoriteButton(slotIndex)
end

local function Callback_FavoriteButtonCountChanged(tabIndex, buttonCount)
	if LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex() ~= tabIndex then return end

	ShowFavoriteEmotesTab(LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex())
end

local function Callback_AccountWideFavoritesActiveChanged(isActive)
	UpdateTabButtonsHidden(LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs())
	ShowFavoriteEmotesTab(LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex())
end

local function Callback_ShowEndlessLoopIconsChanged(isShown)
	RefreshAllFavoriteButtons()
end

function LE_FavoriteEmotesMode:Activate()
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_EmoteSaved, Callback_EmoteSaved)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_EmotesOverriddenUpdated, RefreshAllFavoriteButtons)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_AvailableEmotesUpdated, RefreshAllFavoriteButtons)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_ActiveFavoriteEmotesTabIndexChanged, ShowFavoriteEmotesTab)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_FavoriteButtonCountChanged, Callback_FavoriteButtonCountChanged)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_AccountWideFavoritesActiveChanged, Callback_AccountWideFavoritesActiveChanged)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_ShowEndlessLoopIconsChanged, Callback_ShowEndlessLoopIconsChanged)

	ShowFavoriteEmotesTab(LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex())

	LE_ModeBase.Activate(self)
end

function LE_FavoriteEmotesMode:Deactivate()
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_EmoteSaved, Callback_EmoteSaved)
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_EmotesOverriddenUpdated, RefreshAllFavoriteButtons)
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_AvailableEmotesUpdated, RefreshAllFavoriteButtons)
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_ActiveFavoriteEmotesTabIndexChanged, ShowFavoriteEmotesTab)
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_FavoriteButtonCountChanged, Callback_FavoriteButtonCountChanged)
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_AccountWideFavoritesActiveChanged, Callback_AccountWideFavoritesActiveChanged)
	LovelyEmotes_EventSystem.RemoveListener(LE_EVENT_ShowEndlessLoopIconsChanged, Callback_ShowEndlessLoopIconsChanged)

	LE_ModeBase.Deactivate(self)
end

function LE_FavoriteEmotesMode:Disable()
	LE_EmoteSelectionWindow.HideWindow(true)
end

function LE_FavoriteEmotesMode.TryShowTab(tabIndex, playSound)
	if tabIndex == LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex() then
		return false
	end

	LovelyEmotes_Settings.SetActiveFavoriteEmotesTabIndex(tabIndex)
	if playSound then LovelyEmotes.PlayTabSound() end

	return true
end

function LE_FavoriteEmotesMode.ShowNextTab()
	local tabIndex = LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex() + 1

	if tabIndex > LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs() then
		tabIndex = 1
	end

	LovelyEmotes_Settings.SetActiveFavoriteEmotesTabIndex(tabIndex)
	LovelyEmotes.PlayTabSound()
end

function LE_FavoriteEmotesMode.ShowPreviousTab()
	local tabIndex = LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex() - 1

	if tabIndex < 1 then
		tabIndex = LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs()
	end

	LovelyEmotes_Settings.SetActiveFavoriteEmotesTabIndex(tabIndex)
	LovelyEmotes.PlayTabSound()
end
