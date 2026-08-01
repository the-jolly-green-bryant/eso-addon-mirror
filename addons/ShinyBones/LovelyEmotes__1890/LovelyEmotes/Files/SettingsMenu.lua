local _accountWideCopyTabIndex = 1
local _localCopyTabIndex = 1
local _panel

local function UpdateTabSettingsValue()
	for i = LE_Const_FavoriteEmotesTabIndexMax, 1, -1 do
		GetControl("LE_SettingsControl_TabNumberOfFavoriteEmotesSlider", i):UpdateValue()
		GetControl("LE_SettingsControl_TabNameEditBox", i):UpdateValue()
	end
end

local function UpdateTabSettingsActive()
	for i = LE_Const_FavoriteEmotesTabIndexMax, 1, -1 do
		GetControl("LE_SettingsControl_TabNameEditBox", i):UpdateDisabled()
		GetControl("LE_SettingsControl_TabNumberOfFavoriteEmotesSlider", i):UpdateDisabled()
	end
end

local function CopyFavoriteEmotesTab(fromTab, toTab)
	if #fromTab.EmoteIDs < 1 then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_LOVELYEMOTES_ALERT_COPY_FAILED))
		return
	end

	ZO_DeepTableCopy(fromTab, toTab)
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_LOVELYEMOTES_ALERT_COPY_SUCCESS))

	if LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex() == toTab then
		LovelyEmotes_Settings.SetActiveFavoriteEmotesTabIndex(toTab) -- refresh
	end

	UpdateTabSettingsValue()
end

local function GetCopyDropdownWarningString(entries)
	if #entries > 0 then
		local list = {}
		local showSlashNames = LovelyEmotes_Settings.SavedAccountVariables.ShowSlashNames

		for i,v in ipairs(entries) do
			local emote = LovelyEmotes.GetEmoteByID(v)

			if emote then
				if showSlashNames then
					table.insert(list, emote.SlashName)
				else
					table.insert(list, emote.DisplayName)
				end
			else
				if emote == false then
					table.insert(list, LE_Const_EmoteEmptyDisplayName)
				else
					table.insert(list, LE_Const_EmoteUnknownDisplayName)
				end
			end
		end

		return table.concat(list, "\n")
	end

	return GetString(SI_LOVELYEMOTES_SETTINGS_COPY_EMPTY_TAB)
end

local function RefreshCopyPreview()
	LE_SettingsControl_OverwriteLocalButton:UpdateDisabled()
	LE_SettingsControl_OverwriteAccountWideButton:UpdateDisabled()

	LE_SettingsControl_CopyLocalTabDropdown:UpdateWarning()
	LE_SettingsControl_CopyAccountWideTabDropdown:UpdateWarning()
end

local function SetGeneralAlpha(alpha)
	LovelyEmotes_Settings.SavedAccountVariables.Alpha = alpha

	LovelyEmotes.MainWindow.UpdateAlpha()
	LE_EmoteSelectionWindow.UpdateMaxAlpha()
end

local function DisableMinimizedWindow(value)
	LovelyEmotes_Settings.SavedAccountVariables.EnableMinimizedState = not value
	LE_SettingsControl_VisibilityMinimizedSlider:UpdateDisabled()
	LE_SettingsControl_ScaleMinimizedSlider:UpdateDisabled()

	local mainWindow = LovelyEmotes.MainWindow
	if not mainWindow.IsMinimized() then return end

	if value then
		mainWindow.TryRemoveMinimizedFragmentFromScenes()
	else
		mainWindow.TryAddMinimizedFragmentToScenes()
	end
end

local function UpdateRadialMenuTabSetting()
	local visibleTabCount = LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs()
	local choices = { GetString(SI_LOVELYEMOTES_SETTINGS_CURRENTLY_ACTIVE_TAB), }
	local choicesValues = { 0, }

	local tabText = GetString(SI_LOVELYEMOTES_SETTINGS_TAB)

	for i = 1, visibleTabCount do
		table.insert(choices, zo_strformat("<<1>> <<2>>", tabText, i))
		table.insert(choicesValues, i)
	end

	if LovelyEmotes_Settings.GetRadialMenuTargetTabIndex() > visibleTabCount then
		LovelyEmotes_Settings.SetRadialMenuTargetTabIndex(0)
	end

	LE_RadialMenuTargetTabDropdownControl:UpdateChoices(choices, choicesValues)
	LE_RadialMenuTargetTabDropdownControl:UpdateValue()
end

local function GetNumericList(fromNumber, toNumber)
	local list = {}

	for i = fromNumber, toNumber do
		table.insert(list, i)
	end

	return list
end

function LovelyEmotes.InitializeSettingsMenu()
	local defaultAccountVariables = LovelyEmotes_Settings.DefaultAccountVariables
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables
	local defaultLocalVariables = LovelyEmotes_Settings.DefaultLocalVariables
	local savedLocalVariables = LovelyEmotes_Settings.SavedLocalVariables

	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		title = nil,
		text = function() return zo_strformat("<<1>> <<2>>", GetString(SI_LOVELYEMOTES_SETTINGS_EMOTES_COUNT_TEXT), LovelyEmotes.GetNumberOfAvailableEmotes()) end,
		width = "full",
		reference = "LE_SettingsControl_NumberOfAvailableEmotesDescription",
	} )

	local copyEmotesSubmenuControls = {}

	table.insert(copyEmotesSubmenuControls, {
		type = "description",
		title = nil,
		text = GetString(SI_LOVELYEMOTES_SETTINGS_COPY_EMOTES_DESCRIPTION),
	} )

	local copyTabsChoices = GetNumericList(1, LE_Const_FavoriteEmotesTabIndexMax)

	table.insert(copyEmotesSubmenuControls, {
		type = "dropdown",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_ACCOUNT_WIDE_TAB_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_ACCOUNT_WIDE_TAB_TOOLTIP),
		choices = copyTabsChoices,
		getFunc = function() return _accountWideCopyTabIndex end,
		setFunc = function(var)
			_accountWideCopyTabIndex = var
			RefreshCopyPreview()
		end,
		warning = function() return GetCopyDropdownWarningString(savedAccountVariables.FavoriteEmotesTabs[_accountWideCopyTabIndex].EmoteIDs) end,
		reference = "LE_SettingsControl_CopyAccountWideTabDropdown",
	} )

	table.insert(copyEmotesSubmenuControls, {
		type = "dropdown",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_LOCAL_TAB_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_LOCAL_TAB_TOOLTIP),
		choices = copyTabsChoices,
		getFunc = function() return _localCopyTabIndex end,
		setFunc = function(var)
			_localCopyTabIndex = var
			RefreshCopyPreview()
		end,
		warning = function() return GetCopyDropdownWarningString(savedLocalVariables.FavoriteEmotesTabs[_localCopyTabIndex].EmoteIDs) end,
		reference = "LE_SettingsControl_CopyLocalTabDropdown",
	} )

	table.insert(copyEmotesSubmenuControls, {
		type = "description",
		title = nil,
		text = GetString(SI_LOVELYEMOTES_SETTINGS_OVERWRITE_DESCRIPTION),
	} )

	table.insert(copyEmotesSubmenuControls, {
		type = "button",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_OVERWRITE_CHARACTER_SPECIFIC_BUTTON_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_OVERWRITE_CHARACTER_SPECIFIC_BUTTON_TOOLTIP),
		func = function()
			CopyFavoriteEmotesTab(savedAccountVariables.FavoriteEmotesTabs[_accountWideCopyTabIndex], savedLocalVariables.FavoriteEmotesTabs[_localCopyTabIndex])
			RefreshCopyPreview()
		end,
		width = "half",
		disabled = function() return #savedAccountVariables.FavoriteEmotesTabs[_accountWideCopyTabIndex].EmoteIDs < 1 end,
		reference = "LE_SettingsControl_OverwriteLocalButton",
	} )

	table.insert(copyEmotesSubmenuControls, {
		type = "button",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_OVERWRITE_ACCOUNT_WIDE_BUTTON_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_OVERWRITE_ACCOUNT_WIDE_BUTTON_TOOLTIP),
		func = function()
			CopyFavoriteEmotesTab(savedLocalVariables.FavoriteEmotesTabs[_localCopyTabIndex], savedAccountVariables.FavoriteEmotesTabs[_accountWideCopyTabIndex])
			RefreshCopyPreview()
		end,
		width = "half",
		disabled = function() return #savedLocalVariables.FavoriteEmotesTabs[_localCopyTabIndex].EmoteIDs < 1 end,
		reference = "LE_SettingsControl_OverwriteAccountWideButton",
	} )

	table.insert(optionsData, {
		type = "submenu",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_COPY_EMOTES_HEADER),
		controls = copyEmotesSubmenuControls,
	} )

	local synchronizationControls = {}

	table.insert(synchronizationControls, {
		type = "description",
		title = nil,
		text = GetString(SI_LOVELYEMOTES_SYNC_DESCRIPTION),
	} )

	table.insert(synchronizationControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SYNC_ENABLE_SAY_CHAT),
		getFunc = function() return savedAccountVariables.EnableSayChatSync end,
		setFunc = function(value) LovelyEmotes_Settings.EnableEmoteSync(CHAT_CHANNEL_SAY, value) end,
		default = defaultAccountVariables.EnableSayChatSync,
	} )

	table.insert(synchronizationControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SYNC_ENABLE_PARTY_CHAT),
		getFunc = function() return savedAccountVariables.EnablePartyChatSync end,
		setFunc = function(value) LovelyEmotes_Settings.EnableEmoteSync(CHAT_CHANNEL_PARTY, value) end,
		default = defaultAccountVariables.EnablePartyChatSync,
	} )

	table.insert(synchronizationControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SYNC_ENABLE_WHISPER_CHAT),
		getFunc = function() return savedAccountVariables.EnableWhisperChatSync end,
		setFunc = function(value) LovelyEmotes_Settings.EnableEmoteSync(CHAT_CHANNEL_WHISPER, value) end,
		default = defaultAccountVariables.EnableWhisperChatSync,
	} )

	table.insert(synchronizationControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SYNC_ENABLE_ZONE_CHAT),
		getFunc = function() return savedAccountVariables.EnableZoneChatSync end,
		setFunc = function(value) LovelyEmotes_Settings.EnableEmoteSync(CHAT_CHANNEL_ZONE, value) end,
		default = defaultAccountVariables.EnableZoneChatSync,
	} )

	table.insert(optionsData, {
		type = "submenu",
		name = GetString(SI_LOVELYEMOTES_SYNC_EMOTE_SYNCHRONIZATION),
		controls = synchronizationControls,
	} )

	local favoriteEmotesSettingsControls = {}

	table.insert(favoriteEmotesSettingsControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_ENABLE_ACCOUNT_WIDE_EMOTES_NAME),
		getFunc = function() return savedLocalVariables.IsUsingSharedFavorites end,
		setFunc = function(value)
			LovelyEmotes_Settings.SetAccountWideFavoritesActive(value)

			LE_SettingsControl_NumberOfFavoriteEmotesTabsSlider:UpdateValue()
			UpdateTabSettingsActive()
			UpdateTabSettingsValue()
			RefreshCopyPreview()
		end,
		default = defaultLocalVariables.IsUsingSharedFavorites,
	} )

	table.insert(favoriteEmotesSettingsControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_SHOW_LOCKED_EMOTES_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_SHOW_LOCKED_EMOTES_TOOLTIP),
		getFunc = function() return savedAccountVariables.ShowLockedEmotes end,
		setFunc = function(value)
			savedAccountVariables.ShowLockedEmotes = value
			LovelyEmotes.ReinitializeAvailableEmotes()

			LE_SettingsControl_NumberOfAvailableEmotesDescription:UpdateValue()
			LE_SettingsControl_HighlightLockedEmotesCheckbox:UpdateDisabled()
		end,
		default = defaultAccountVariables.ShowLockedEmotes,
	} )

	table.insert(favoriteEmotesSettingsControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_HIGHLIGHT_LOCKED_EMOTES_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_HIGHLIGHT_LOCKED_EMOTES_TOOLTIP),
		getFunc = function() return savedAccountVariables.HighlightLockedEmotes end,
		setFunc = function(value)
			savedAccountVariables.HighlightLockedEmotes = value
			LovelyEmotes.EmoteList:RefreshVisible()
		end,
		disabled = function() return not savedAccountVariables.ShowLockedEmotes end,
		reference = "LE_SettingsControl_HighlightLockedEmotesCheckbox",
		default = defaultAccountVariables.HighlightLockedEmotes,
	} )

	table.insert(favoriteEmotesSettingsControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_SHOW_SLASH_NAMES_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_SHOW_SLASH_NAMES_TOOLTIP),
		getFunc = function() return savedAccountVariables.ShowSlashNames end,
		setFunc = function(value)
			LovelyEmotes_Settings.SetShowSlashNames(value)

			LovelyEmotes.SortAvailableEmotes()
			LovelyEmotes.EmoteList:RefreshVisible()
			LE_FavoriteCommandsMenu:TryRefreshList()

			RefreshCopyPreview()
		end,
		default = defaultAccountVariables.ShowSlashNames,
	} )

	table.insert(favoriteEmotesSettingsControls, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_SHOW_ENDLESS_LOOP_ICONS_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_SHOW_ENDLESS_LOOP_ICONS_TOOLTIP),
		getFunc = function() return savedAccountVariables.ShowEndlessLoopIcons end,
		setFunc = function(value)
			LovelyEmotes_Settings.SetShowEndlessLoopIcons(value)
			LovelyEmotes.EmoteList:RefreshVisible()
		end,
		default = defaultAccountVariables.ShowEndlessLoopIcons,
	} )

	table.insert(favoriteEmotesSettingsControls, {
		type = "slider",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_NUMBER_OF_TABS_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_NUMBER_OF_TABS_TOOLTIP),
		min = 1,
		max = LE_Const_FavoriteEmotesTabIndexMax,
		step = 1,
		getFunc = function() return LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs() end,
		setFunc = function(value)
			LovelyEmotes_Settings.SetNumberOfVisibleFavoriteEmotesTabs(value)

			UpdateTabSettingsActive()
			UpdateRadialMenuTabSetting()
		end,
		reference = "LE_SettingsControl_NumberOfFavoriteEmotesTabsSlider",
	} )

	for i = 1, LE_Const_FavoriteEmotesTabIndexMax do
		table.insert(favoriteEmotesSettingsControls, {
			type = "slider",
			name = zo_strformat("<<1>> <<2>> - <<3>>", GetString(SI_LOVELYEMOTES_SETTINGS_TAB), i, GetString(SI_LOVELYEMOTES_SETTINGS_NUMBER_OF_EMOTES_NAME)),
			min = 1,
			max = LE_Const_FavoriteEmotesIndexMax,
			step = 1,
			getFunc = function() return LovelyEmotes_Settings.GetFavoriteButtonCount(i) end,
			setFunc = function(value)
				LovelyEmotes_Settings.SetFavoriteButtonCount(value, i)
				RefreshCopyPreview()
			end,
			disabled = function() return i > LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs() end,
			reference = "LE_SettingsControl_TabNumberOfFavoriteEmotesSlider" .. i,
		} )

		table.insert(favoriteEmotesSettingsControls, {
			type = "editbox",
			name = zo_strformat("<<1>> <<2>> - <<3>>", GetString(SI_LOVELYEMOTES_SETTINGS_TAB), i, GetString(SI_LOVELYEMOTES_SETTINGS_NAME)),
			getFunc = function() return LovelyEmotes_Settings.GetSavedFavoriteTab(i).Name end,
			setFunc = function(text) LovelyEmotes_Settings.GetSavedFavoriteTab(i).Name = text end,
			isMultiline = false,
			disabled = function() return i > LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs() end,
			reference = "LE_SettingsControl_TabNameEditBox" .. i,
		} )
	end

	table.insert(optionsData, {
		type = "submenu",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_EMOTES_SETTINGS_HEADER),
		controls = favoriteEmotesSettingsControls,
	} )

	table.insert(optionsData, {
		type = "header",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_GENERAL_SETTINGS_HEADER),
	} )

	table.insert(optionsData, {
		type = "slider",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_VISIBILITY_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_VISIBILITY_TOOLTIP),
		min = 25,
		max = 100,
		getFunc = function() return savedAccountVariables.Alpha end,
		setFunc = SetGeneralAlpha,
		default = defaultAccountVariables.Alpha,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_HIDE_MINIMIZED_WINDOW_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_HIDE_MINIMIZED_WINDOW_TOOLTIP),
		getFunc = function() return not savedAccountVariables.EnableMinimizedState end,
		setFunc = DisableMinimizedWindow,
		default = defaultAccountVariables.EnableMinimizedState,
	} )

	table.insert(optionsData, {
		type = "slider",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZED_VISIBILITY_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZED_VISIBILITY_TOOLTIP),
		min = 20,
		max = 100,
		getFunc = function() return savedAccountVariables.MinimizedAlpha end,
		setFunc = function(value)
			savedAccountVariables.MinimizedAlpha = value
			LovelyEmotes.MainWindow.UpdateAlphaMinimized()
		end,
		disabled = function() return not savedAccountVariables.EnableMinimizedState end,
		reference = "LE_SettingsControl_VisibilityMinimizedSlider",
		default = defaultAccountVariables.MinimizedAlpha,
	} )

	table.insert(optionsData, {
		type = "slider",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZED_SCALE_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZED_SCALE_TOOLTIP),
		min = 0.5,
		max = 1.5,
		step = 0.1,
		decimals = 1,
		getFunc = function() return savedAccountVariables.MinimizedScale end,
		setFunc = function(value)
			savedAccountVariables.MinimizedScale = value
			LovelyEmotes.MainWindow.SetMinimizedWindowScale(value)
		end,
		disabled = function() return not savedAccountVariables.EnableMinimizedState end,
		reference = "LE_SettingsControl_ScaleMinimizedSlider",
		default = defaultAccountVariables.MinimizedScale,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_ENABLE_CHAT_BUTTON_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_ENABLE_CHAT_BUTTON_TOOLTIP),
		getFunc = function() return savedAccountVariables.EnableChatWindowButton end,
		setFunc = function(value)
			LE_ChatWindowButton:SetHidden(not value)
			LE_SettingsControl_ChatButtonOffsetXSlider:UpdateDisabled()
		end,
		default = defaultAccountVariables.EnableChatWindowButton,
	} )

	table.insert(optionsData, {
		type = "slider",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_CHAT_BUTTON_OFFSET_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_CHAT_BUTTON_OFFSET_TOOLTIP),
		min = 0,
		max = 300,
		getFunc = function() return savedAccountVariables.ChatWindowButtonPositionX end,
		setFunc = function(value) LE_ChatWindowButton:SetPosition(value) end,
		disabled = function() return not savedAccountVariables.EnableChatWindowButton end,
		reference = "LE_SettingsControl_ChatButtonOffsetXSlider",
		default = defaultAccountVariables.ChatWindowButtonPositionX,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_START_MINIMIZED_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_START_MINIMIZED_TOOLTIP),
		getFunc = function() return savedAccountVariables.StartMinimized end,
		setFunc = function(value) savedAccountVariables.StartMinimized = value end,
		default = defaultAccountVariables.StartMinimized,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZE_AUTOMATICALLY_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZE_AUTOMATICALLY_TOOLTIP),
		getFunc = function() return savedAccountVariables.MinimizeAutomatically end,
		setFunc = function(value) savedAccountVariables.MinimizeAutomatically = value end,
		default = defaultAccountVariables.MinimizeAutomatically,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZE_IN_COMBAT_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_MINIMIZE_IN_COMBAT_TOOLTIP),
		getFunc = function() return savedAccountVariables.MinimizeInCombat end,
		setFunc = LovelyEmotes.SetCombatStateEventActive,
		default = defaultAccountVariables.MinimizeInCombat,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_TOGGLE_CURSOR_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_TOGGLE_CURSOR_TOOLTIP),
		getFunc = function() return savedAccountVariables.ToggleCursorWidthKeyBinding end,
		setFunc = function(value) savedAccountVariables.ToggleCursorWidthKeyBinding = value end,
		default = defaultAccountVariables.ToggleCursorWidthKeyBinding,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_ENABLE_PERSONALITIES_AS_FAVORITES_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_ENABLE_PERSONALITIES_AS_FAVORITES_TOOLTIP),
		getFunc = function() return savedAccountVariables.EnablePersonalitiesAsFavorites end,
		setFunc = function(value)
			savedAccountVariables.EnablePersonalitiesAsFavorites = value
			LovelyEmotes.ReinitializeAvailableEmotes()
		end,
		default = defaultAccountVariables.EnablePersonalitiesAsFavorites,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_ENABLE_ALTERNATIVE_SOUNDS_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_ENABLE_ALTERNATIVE_SOUNDS_TOOLTIP),
		getFunc = function() return savedAccountVariables.EnableAlternativeSounds end,
		setFunc = function(value)
			savedAccountVariables.EnableAlternativeSounds = value
			LovelyEmotes.UpdateButtonClickSounds(value)
		end,
		default = defaultAccountVariables.EnableAlternativeSounds,
	} )

	table.insert(optionsData, {
		type = "slider",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_RADIAL_MENU_SCALE_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_RADIAL_MENU_SCALE_TOOLTIP),
		min = 0.6,
		max = 1,
		step = 0.01,
		decimals = 2,
		getFunc = function() return savedAccountVariables.RadialMenuScale end,
		setFunc = function(value)
			savedAccountVariables.RadialMenuScale = value
			LE_RadialMenu:UpdateScale()
		end,
		default = defaultAccountVariables.RadialMenuScale,
	} )

	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_RADIAL_MENU_SHOWN_TAB_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_RADIAL_MENU_SHOWN_TAB_TOOLTIP),
		choices = {},
		choicesValues = {},
		getFunc = function() return LovelyEmotes_Settings.GetRadialMenuTargetTabIndex() end,
		setFunc = function(value) LovelyEmotes_Settings.SetRadialMenuTargetTabIndex(value) end,
		default = defaultAccountVariables.RadialMenuTargetTabIndex,
		reference = "LE_RadialMenuTargetTabDropdownControl",
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_BUTTONDESIGN_FAVORITES_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_BUTTONDESIGN_FAVORITES_TOOLTIP),
		getFunc = function()
			if savedAccountVariables.FavoritesButtonDesign == 1 then
				return true
			end
			return false
		end,
		setFunc = function(value)
			if value then
				savedAccountVariables.FavoritesButtonDesign = 1
			else
				savedAccountVariables.FavoritesButtonDesign = 2
			end
		end,
		default = true,
		requiresReload = true,
	} )

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_LOVELYEMOTES_SETTINGS_BUTTONDESIGN_EMOTELIST_NAME),
		tooltip = GetString(SI_LOVELYEMOTES_SETTINGS_BUTTONDESIGN_EMOTELIST_TOOLTIP),
		getFunc = function()
			if savedAccountVariables.EmoteListButtonDesign == 1 then
				return true
			end
			return false
		end,
		setFunc = function(value)
			if value then
				savedAccountVariables.EmoteListButtonDesign = 1
			else
				savedAccountVariables.EmoteListButtonDesign = 2
			end
		end,
		default = true,
		requiresReload = true,
	} )

	local panelData = {
		type = "panel",
		name = LovelyEmotes.Name,
		displayName = "Lovely Emotes",
		author = "ShinyBones",
		version = LovelyEmotes.Version,
		slashCommand = "/lesettings",
		website = "https://www.esoui.com/downloads/info1890-LovelyEmotes.html",
		registerForRefresh = false,
		registerForDefaults = true,
	}

	_panel = LibAddonMenu2:RegisterAddonPanel("LovelyEmotesSettings", panelData)
	LibAddonMenu2:RegisterOptionControls("LovelyEmotesSettings", optionsData)
end

CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
	if panel ~= _panel then return end

	UpdateRadialMenuTabSetting()
end)

CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
	if panel ~= _panel then return end

	RefreshCopyPreview()
end)
