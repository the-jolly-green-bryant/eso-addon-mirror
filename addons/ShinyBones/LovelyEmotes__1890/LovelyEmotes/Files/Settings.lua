local _defaultPositionY = GuiRoot:GetHeight() * 0.4

local function GetNewFavoriteEmotesTabList()
	local tabList = {}

	for i = LE_Const_FavoriteEmotesTabIndexMax, 1, -1 do
		table.insert(tabList, {
			ButtonCount = 5,
			Name = "",
			EmoteIDs = {},
		})
	end

	return tabList
end

local _savedAccountVariables
local _savedLocalVariables

LovelyEmotes_Settings = {
	DefaultAccountVariables = {
		MainWindowPositionX = 10,
		MainWindowPositionY = _defaultPositionY,
		MainWindowMinimizedPositionX = 0,
		MainWindowMinimizedPositionY = _defaultPositionY,
		EmoteListPositionX = 300,
		EmoteListPositionY = _defaultPositionY,
		LockedWindowPositions = false,
		Alpha = 100,
		EnableMinimizedState = true,
		MinimizedAlpha = 50,
		MinimizedScale = 1,
		EnableChatWindowButton = false,
		ChatWindowButtonPositionX = 0,
		StartMinimized = false,
		ShowLockedEmotes = true,
		ShowSlashNames = false,
		ShowEndlessLoopIcons = true,
		EnablePersonalitiesAsFavorites = false,
		HighlightLockedEmotes = true,
		MinimizeInCombat = true,
		MinimizeAutomatically = false,
		ToggleCursorWidthKeyBinding = true,
		EnableAlternativeSounds = true,
		FavoritesButtonDesign = 1,
		EmoteListButtonDesign = 1,
		RadialMenuScale = 1,
		RadialMenuTargetTabIndex = 0,
		EnableSayChatSync = true,
		EnablePartyChatSync = true,
		EnableWhisperChatSync = true,
		EnableZoneChatSync = false,

		FavoriteCommandsData = {},
		FavoriteCommandsShowDisplayName = true,

		NumberOfFavoriteEmotesTabs = 4,
		FavoriteEmotesTabIndex = 1,
		FavoriteEmotesTabs = GetNewFavoriteEmotesTabList(),
	},

	DefaultLocalVariables = {
		IsUsingSharedFavorites = true,
		RadialMenuTargetTabIndex = 0,

		NumberOfFavoriteEmotesTabs = 4,
		FavoriteEmotesTabIndex = 1,
		FavoriteEmotesTabs = GetNewFavoriteEmotesTabList(),
	},
}

function LovelyEmotes_Settings.Initialize()
	_savedAccountVariables = ZO_SavedVars:NewAccountWide("LovelyEmotesVariables", 1, nil, LovelyEmotes_Settings.DefaultAccountVariables)
	_savedLocalVariables = ZO_SavedVars:NewCharacterIdSettings("LovelyEmotesVariables", 2, nil, LovelyEmotes_Settings.DefaultLocalVariables)

	LovelyEmotes_Settings.SavedAccountVariables = _savedAccountVariables
	LovelyEmotes_Settings.SavedLocalVariables = _savedLocalVariables

	LovelyEmotes_Settings.Initialize = nil
end

local function GetActiveFavoriteEmotesTabIndex()
	if _savedLocalVariables.IsUsingSharedFavorites then
		return _savedAccountVariables.FavoriteEmotesTabIndex
	end

	return _savedLocalVariables.FavoriteEmotesTabIndex
end
LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex = GetActiveFavoriteEmotesTabIndex

local function SetActiveFavoriteEmotesTabIndex(index)
	if _savedLocalVariables.IsUsingSharedFavorites then
		_savedAccountVariables.FavoriteEmotesTabIndex = index
	else
		_savedLocalVariables.FavoriteEmotesTabIndex = index
	end

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_ActiveFavoriteEmotesTabIndexChanged, index)
end
LovelyEmotes_Settings.SetActiveFavoriteEmotesTabIndex = SetActiveFavoriteEmotesTabIndex

local function GetSavedFavoriteTab(index)
	if _savedLocalVariables.IsUsingSharedFavorites then
		return _savedAccountVariables.FavoriteEmotesTabs[index]
	end

	return _savedLocalVariables.FavoriteEmotesTabs[index]
end
LovelyEmotes_Settings.GetSavedFavoriteTab = GetSavedFavoriteTab

function LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs()
	if _savedLocalVariables.IsUsingSharedFavorites then
		return _savedAccountVariables.NumberOfFavoriteEmotesTabs
	end

	return _savedLocalVariables.NumberOfFavoriteEmotesTabs
end

function LovelyEmotes_Settings.SetNumberOfVisibleFavoriteEmotesTabs(value)
	if _savedLocalVariables.IsUsingSharedFavorites then
		_savedAccountVariables.NumberOfFavoriteEmotesTabs = value
	else
		_savedLocalVariables.NumberOfFavoriteEmotesTabs = value
	end

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_NumberOfVisibleFavoriteEmotesTabsChanged, value)

	if GetActiveFavoriteEmotesTabIndex() > value then
		SetActiveFavoriteEmotesTabIndex(value)
	end
end

function LovelyEmotes_Settings.GetFavoriteButtonCount(tabIndex)
	if tabIndex == nil then tabIndex = GetActiveFavoriteEmotesTabIndex() end
	return GetSavedFavoriteTab(tabIndex).ButtonCount
end

function LovelyEmotes_Settings.SetFavoriteButtonCount(value, tabIndex)
	if tabIndex == nil then tabIndex = GetActiveFavoriteEmotesTabIndex() end
	GetSavedFavoriteTab(tabIndex).ButtonCount = value

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_FavoriteButtonCountChanged, tabIndex, value)
end

function LovelyEmotes_Settings.GetSavedFavoriteID(emoteIndex, tabIndex)
	if tabIndex == nil then tabIndex = GetActiveFavoriteEmotesTabIndex() end
	return GetSavedFavoriteTab(tabIndex).EmoteIDs[emoteIndex]
end

function LovelyEmotes_Settings.SaveEmote(slotIndex, emoteID, tabIndex)
	if tabIndex == nil then tabIndex = GetActiveFavoriteEmotesTabIndex() end
	GetSavedFavoriteTab(tabIndex).EmoteIDs[slotIndex] = emoteID

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_EmoteSaved, tabIndex, slotIndex)
end

function LovelyEmotes_Settings.GetRadialMenuTargetTabIndex()
	if _savedLocalVariables.IsUsingSharedFavorites then
		return _savedAccountVariables.RadialMenuTargetTabIndex
	end

	return _savedLocalVariables.RadialMenuTargetTabIndex
end

function LovelyEmotes_Settings.SetRadialMenuTargetTabIndex(value)
	if _savedLocalVariables.IsUsingSharedFavorites then
		_savedAccountVariables.RadialMenuTargetTabIndex = value
	else
		_savedLocalVariables.RadialMenuTargetTabIndex = value
	end
end

function LovelyEmotes_Settings.SetAccountWideFavoritesActive(isActive)
	if _savedLocalVariables.IsUsingSharedFavorites == isActive then return end
	_savedLocalVariables.IsUsingSharedFavorites = isActive

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_AccountWideFavoritesActiveChanged, isActive)
end

function LovelyEmotes_Settings.SetShowSlashNames(value)
	_savedAccountVariables.ShowSlashNames = value
	LovelyEmotes_EventSystem.Invoke(LE_EVENT_ShowSlashNamesChanged, value)
end

function LovelyEmotes_Settings.SetShowEndlessLoopIcons(isShown)
	_savedAccountVariables.ShowEndlessLoopIcons = isShown
	LovelyEmotes_EventSystem.Invoke(LE_EVENT_ShowEndlessLoopIconsChanged, isShown)
end

function LovelyEmotes_Settings.EnableEmoteSync(chatChannel, isEnabled)
	if chatChannel == CHAT_CHANNEL_SAY then
		_savedAccountVariables.EnableSayChatSync = isEnabled
	elseif chatChannel == CHAT_CHANNEL_PARTY then
		_savedAccountVariables.EnablePartyChatSync = isEnabled
	elseif chatChannel == CHAT_CHANNEL_WHISPER then
		_savedAccountVariables.EnableWhisperChatSync = isEnabled
	elseif chatChannel == CHAT_CHANNEL_ZONE then
		_savedAccountVariables.EnableZoneChatSync = isEnabled
	end

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_EmoteSyncChatChannelChanged, chatChannel, isEnabled)
end
