LibrarianSettings = ZO_Object:Subclass()

local timeFormats = {
	{ name = GetString(LIBRARIAN_SETTINGS_TIME_12), value = TIME_FORMAT_PRECISION_TWELVE_HOUR },
	{ name = GetString(LIBRARIAN_SETTINGS_TIME_24), value = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR }
}

local alertStyles = {
	{ name = GetString(LIBRARIAN_SETTINGS_ALERT_NONE), value = "None", chat = false, alert = false },
	{ name = GetString(LIBRARIAN_SETTINGS_ALERT_CHAT), value = "Chat", chat = true, alert = false },
	{ name = GetString(LIBRARIAN_SETTINGS_ALERT_NOTIFICATION), value = "Alert", chat = false, alert = true },
	{ name = GetString(LIBRARIAN_SETTINGS_ALERT_BOTH), value = "Both", chat = true, alert = true },
}

local reloadReminders = {
	{ name = GetString(LIBRARIAN_SETTINGS_RELOAD_REMNDER_NEVER), value = 0 },
	{ name = GetString(LIBRARIAN_SETTINGS_RELOAD_REMNDER_1), value = 1 },
	{ name = GetString(LIBRARIAN_SETTINGS_RELOAD_REMNDER_5), value = 5 },
	{ name = GetString(LIBRARIAN_SETTINGS_RELOAD_REMNDER_10), value = 10 }
}

function LibrarianSettings:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

local function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

local function getSettingByName(tbl, name)
	for _,p in pairs(tbl) do
		if p.name == name then return p end
	end
end

local function getSettingByValue(tbl, value)
	for _,p in pairs(tbl) do
		if p.value == value then return p end
	end
end

function LibrarianSettings:Initialize(settings, menuSettings)
	self.settings = settings

	if self.settings.timeFormat == nil then
		self.settings.timeFormat = (GetCVar("Language.2") == "en") and TIME_FORMAT_PRECISION_TWELVE_HOUR or TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
	end

	if self.settings.showAllBooks == nil then
		self.settings.showAllBooks = true
	end

	if self.settings.alertStyle == nil then
		self.settings.alertStyle = 'Both'
		self.settings.chatEnabled = true
		self.settings.alertEnabled = true
	end

    if self.settings.showHiddenBook == nil then
        self.settings.showHiddenBook = true
    end

	if self.settings.showUnreadIndicatorInReader == nil then
		self.settings.showUnreadIndicatorInReader = true
	end

	if self.settings.showUnreadIndicatorInLoreLibrary == nil then
		self.settings.showUnreadIndicatorInLoreLibrary = true
	end

	if self.settings.reloadReminderBookCount == nil then
		self.settings.reloadReminderBookCount = 5
	end

  if self.settings.enableCharacterSpin == nil then
    self.settings.enableCharacterSpin = true
  end

  if self.settings.unreadIndicatorTransparency == nil then
    self.settings.unreadIndicatorTransparency = 1
  end

  local panelData = {
    type = "panel",
    name = GetString(LIBRARIAN_WINDOW_TITLE_LIBRARIAN),
    displayName = GetString(LIBRARIAN_SETTINGS_DISPLAY_NAME),
    author = menuSettings.authors,
    version = menuSettings.version,
    slashCommand = menuSettings.optionSlashCommandText
  }

  local optionsTable = {
    {
      type = "dropdown",
      name = LIBRARIAN_SETTINGS_TIME,
      tooltip = LIBRARIAN_SETTINGS_TIME_TOOLTIP,
      choices = map(timeFormats, function(item) return item.name end),
      getFunc = function() return getSettingByValue(timeFormats, self.settings.timeFormat).name end,
      setFunc = function(name)
        self.settings.timeFormat = getSettingByName(timeFormats, name).value
        LIBRARIAN:CommitScrollList()
      end
    },
    {
      type = "dropdown",
      name = LIBRARIAN_SETTINGS_ALERT,
      tooltip = LIBRARIAN_SETTINGS_ALERT_TOOLTIP,
      choices = map(alertStyles, function(item) return item.name end),
      getFunc = function() return getSettingByValue(alertStyles, self.settings.alertStyle).name end,
      setFunc = function(name)
        local setting = getSettingByName(alertStyles, name)
        self.settings.alertStyle = setting.value
        self.settings.chatEnabled = setting.chat
        self.settings.alertEnabled = setting.alert
      end
    },
    {
      type = "dropdown",
      name = LIBRARIAN_SETTINGS_RELOADUI_REMINDER,
      tooltip = LIBRARIAN_SETTINGS_RELOADUI_REMINDER_TOOLTIP,
      choices = map(reloadReminders, function(item) return item.name end),
      getFunc = function() return getSettingByValue(reloadReminders, self.settings.reloadReminderBookCount).name end,
      setFunc = function(name)
        local setting = getSettingByName(reloadReminders, name)
        self.settings.reloadReminderBookCount = setting.value
      end
    },
    {
      type = "checkbox",
      name = LIBRARIAN_SETTINGS_SHOW_HIDDEN_BOOK,
      tooltip = LIBRARIAN_SETTINGS_SHOW_HIDDEN_BOOK_TOOLTIP,
      getFunc = function() return self.settings.showHiddenBook end,
      setFunc = function(value)
        self.settings.showHiddenBook = value
        LIBRARIAN:RefreshData()
      end
    },
    {
      type = "checkbox",
      name = LIBRARIAN_SETTINGS_UNREAD_INDICATOR_READER,
      tooltip = LIBRARIAN_SETTINGS_UNREAD_INDICATOR_READER_TOOLTIP,
      getFunc = function() return self.settings.showUnreadIndicatorInReader end,
      setFunc = function(value) self.settings.showUnreadIndicatorInReader = value end
    },
    {
      type = "slider",
      name = LIBRARIAN_SETTINGS_ICON_TRANSPARENCY,
      tooltip = LIBRARIAN_SETTINGS_ICON_TRANSPARENCY_TOOLTIP,
      getFunc = function() return self.settings.unreadIndicatorTransparency * 100 end,
      setFunc = function(value)
        self.settings.unreadIndicatorTransparency = value / 100
        LIBRARIAN.loreReaderUnreadIndicator:SetAlpha(self.settings.unreadIndicatorTransparency)
      end,
      min = 0,
      max = 100,
      step = 1
    },
    {
      type = "checkbox",
      name = LIBRARIAN_SETTINGS_UNREAD_INDICATOR_LIBRARY,
      tooltip = LIBRARIAN_SETTINGS_UNREAD_INDICATOR_LIBRARY_TOOLTIP,
      getFunc = function() return self.settings.showUnreadIndicatorInLoreLibrary end,
      setFunc = function(value) self.settings.showUnreadIndicatorInLoreLibrary = value end,
      requiresReload = true
    },
    {
      type = "checkbox",
      name = LIBRARIAN_SETTINGS_CHARACTER_SPIN,
      tooltip = LIBRARIAN_SETTINGS_CHARACTER_SPIN_TOOLTIP,
      getFunc = function() return self.settings.enableCharacterSpin end,
      setFunc = function(value) self.settings.enableCharacterSpin = value end,
      requiresReload = true
    },
    {
      type = "button",
      name = GetString(LIBRARIAN_SETTINGS_IMPORT),
      tooltip = GetString(LIBRARIAN_SETTINGS_IMPORT_TOOLTIP),
      func = function() LIBRARIAN:ImportFromLoreLibrary() end
    }
  }

  local LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(menuSettings.name, panelData)
  LAM:RegisterOptionControls(menuSettings.name, optionsTable)
end