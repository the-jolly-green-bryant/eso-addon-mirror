ZO_CreateStringId("SI_BINDING_NAME_LOVELYEMOTES_TOGGLE_MAIN_WINDOW", GetString(SI_LOVELYEMOTES_BINDING_TOGGLE_MAIN_WINDOW))
ZO_CreateStringId("SI_BINDING_NAME_LOVELYEMOTES_RADIAL_MENU", GetString(SI_LOVELYEMOTES_BINDING_RADIAL_QUICK_MENU))

ZO_CreateStringId("SI_BINDING_NAME_LOVELYEMOTES_NEXT_TAB", GetString(SI_LOVELYEMOTES_BINDING_NEXT_TAB))
ZO_CreateStringId("SI_BINDING_NAME_LOVELYEMOTES_PREVIOUS_TAB", GetString(SI_LOVELYEMOTES_BINDING_PREVIOUS_TAB))

ZO_CreateStringId("SI_KEYBINDINGS_LAYER_LOVELYEMOTES_RADIAL_MENU", GetString(SI_LOVELYEMOTES_BINDING_LAYER_RADIAL_MENU))
ZO_CreateStringId("SI_BINDING_NAME_LOVELYEMOTES_RADIAL_MENU_NEXT_TAB", GetString(SI_LOVELYEMOTES_BINDING_NEXT_TAB))
ZO_CreateStringId("SI_BINDING_NAME_LOVELYEMOTES_RADIAL_MENU_PREVIOUS_TAB", GetString(SI_LOVELYEMOTES_BINDING_PREVIOUS_TAB))

local _showTabString = GetString(SI_LOVELYEMOTES_BINDING_TAB)

for i = 1, LE_Const_FavoriteEmotesTabIndexMax do
	ZO_CreateStringId(zo_strformat("SI_BINDING_NAME_LOVELYEMOTES_TAB_<<1>>", i), zo_strformat("<<1>> <<2>>", _showTabString, i))
end

local _playFavoriteString = GetString(SI_LOVELYEMOTES_BINDING_PLAY_FAVORITE)

for i = 1, LE_Const_FavoriteEmotesIndexMax do
	ZO_CreateStringId(zo_strformat("SI_BINDING_NAME_LOVELYEMOTES_FAVORITE_EMOTE_<<1>>", i), zo_strformat("<<1>> <<2>>", _playFavoriteString, i))
end

LovelyEmotes.BindingFunctions = {}

function LovelyEmotes.BindingFunctions.ToggleMainWindow()
	LovelyEmotes.MainWindow.ToggleMinimized(LovelyEmotes_Settings.SavedAccountVariables.ToggleCursorWidthKeyBinding)
end

function LovelyEmotes.BindingFunctions.NextTab()
	if LE_RadialMenu.IsActive then
		LE_RadialMenu:ShowNextTab()
	else
		LE_FavoriteEmotesMode.ShowNextTab()
	end
end

function LovelyEmotes.BindingFunctions.PreviousTab()
	if LE_RadialMenu.IsActive then
		LE_RadialMenu:ShowPreviousTab()
	else
		LE_FavoriteEmotesMode.ShowPreviousTab()
	end
end

function LovelyEmotes.BindingFunctions.TryShowTab(tabIndex)
	if tabIndex > LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs() then return end

	if LE_RadialMenu.IsActive then
		LE_RadialMenu:TryShowTab(tabIndex, true)
	else
		LE_FavoriteEmotesMode.TryShowTab(tabIndex, true)
	end
end
