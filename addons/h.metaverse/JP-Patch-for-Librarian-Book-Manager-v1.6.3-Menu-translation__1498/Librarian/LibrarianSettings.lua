LibrarianSettings = ZO_Object:Subclass()

local timeFormats = {
	{ name = GetString(SI_SETTING_LABEL_TIME_FORMAT_PRECISION_TWELVE_HOUR_LIBRARIAN), value = TIME_FORMAT_PRECISION_TWELVE_HOUR },
	{ name = GetString(SI_SETTING_LABEL_TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR_LIBRARIAN), value = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR }
}

local alertStyles = {
	{ name = GetString(SI_SETTING_LABEL_ALERT_STYLE_NONE_LIBRARIAN), value = "None", chat = false, alert = false },
	{ name = GetString(SI_SETTING_LABEL_ALERT_STYLE_CHAT_ONLY_LIBRARIAN), value = "Chat", chat = true, alert = false },
	{ name = GetString(SI_SETTING_LABEL_ALERT_STYLE_ALERT_ONLY_LIBRARIAN), value = "Alert", chat = false, alert = true },
	{ name = GetString(SI_SETTING_LABEL_ALERT_STYLE_BOTH_LIBRARIAN), value = "Both", chat = true, alert = true },
}

local reloadReminders = {
	{ name = GetString(SI_SETTING_LABEL_RELOAD_REMINDER_NEVER_LIBRARIAN), value = 0 },
	{ name = GetString(SI_SETTING_LABEL_RELOAD_REMINDER_ONE_NEW_BOOK_LIBRARIAN), value = 1 },
	{ name = GetString(SI_SETTING_LABEL_RELOAD_REMINDER_FIVE_NEW_BOOKS_LIBRARIAN), value = 5 },
	{ name = GetString(SI_SETTING_LABEL_RELOAD_REMINDER_TEN_NEW_BOOKS_LIBRARIAN), value = 10 }
}

function LibrarianSettings:New( ... )
    local result = ZO_Object.New( self )
    result:Initialise( ... )
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

function LibrarianSettings:Initialise(settings)
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

	if self.settings.showUnreadIndicatorInReader == nil then
		self.settings.showUnreadIndicatorInReader = true
	end

	if self.settings.reloadReminderBookCount == nil then
		self.settings.reloadReminderBookCount = 5
	end

  if self.settings.enableCharacterSpin == nil then
    self.settings.enableCharacterSpin = true
  end
  
  local panelData = {
    type = "panel",
    name = "Librarian",
    displayName = "Librarian Book Manager",
    author = "|c4EFFF6Calia1120|r, Flamage",
    version = "1.6.2",
    slashCommand = "/librarianOptions"
  }

  local optionsTable = {
    [1] = {
      type = "dropdown",
      name = GetString(SI_SETTING_OPTION_NAME_TIME_FORMAT_LIBRARIAN),
      tooltip = GetString(SI_SETTING_OPTION_TOOLTIP_TIME_FORMAT_LIBRARIAN),
      choices = map(timeFormats, function(item) return item.name end),
      getFunc = function() return getSettingByValue(timeFormats, self.settings.timeFormat).name end,
      setFunc = function(name) 
        self.settings.timeFormat = getSettingByName(timeFormats, name).value
        LIBRARIAN:CommitScrollList()
      end
    },
    [2] = {
      type = "dropdown",
      name = GetString(SI_SETTING_OPTION_NAME_ALERT_SETTINGS_LIBRARIAN),
      tooltip = GetString(SI_SETTING_OPTION_TOOLTIP_ALERT_SETTINGS_LIBRARIAN),
      choices = map(alertStyles, function(item) return item.name end),
      getFunc = function() return getSettingByValue(alertStyles, self.settings.alertStyle).name end,
      setFunc = function(name) 
        local setting = getSettingByName(alertStyles, name)
        self.settings.alertStyle = setting.value
        self.settings.chatEnabled = setting.chat
        self.settings.alertEnabled = setting.alert
      end
    },
    [3] = {
      type = "dropdown",
      name = GetString(SI_SETTING_OPTION_NAME_RELOAD_UI_REMINDER_LIBRARIAN),
      tooltip = GetString(SI_SETTING_OPTION_TOOLTIP_RELOAD_UI_REMINDER_LIBRARIAN),
      choices = map(reloadReminders, function(item) return item.name end),
      getFunc = function() return getSettingByValue(reloadReminders, self.settings.reloadReminderBookCount).name end,
      setFunc = function(name) 
        local setting = getSettingByName(reloadReminders, name)
        self.settings.reloadReminderBookCount = setting.value
      end
    },
    [4] = {
      type = "checkbox",
      name = GetString(SI_SETTING_OPTION_NAME_UNREAD_INDICATOR_LIBRARIAN),
      tooltip = GetString(SI_SETTING_OPTION_TOOLTIP_UNREAD_INDICATOR_LIBRARIAN),
      getFunc = function() return self.settings.showUnreadIndicatorInReader end,
      setFunc = function(value) self.settings.showUnreadIndicatorInReader = value end
    },
    [5] = {
      type = "checkbox",
      name = GetString(SI_SETTING_OPTION_NAME_CHARACTER_SPIN_LIBRARIAN),
      tooltip = GetString(SI_SETTING_OPTION_TOOLTIP_CHARACTER_SPIN_LIBRARIAN),
      getFunc = function() return self.settings.enableCharacterSpin end,
      setFunc = function(value) 
        self.settings.enableCharacterSpin = value 
        SLASH_COMMANDS["/reloadui"]()
      end,
      warning = GetString(SI_SETTING_OPTION_WARNING_CHARACTER_SPIN_LIBRARIAN)
    },
    [6] = {
      type = "button",
      name = GetString(SI_SETTING_OPTION_NAME_IMPORT_LORE_LIBRARY_LIBRARIAN),
      tooltip = GetString(SI_SETTING_OPTION_TOOLTIP_IMPORT_LORE_LIBRARY_LIBRARIAN),
      func = function() LIBRARIAN:ImportFromLoreLibrary() end
    }
  }

  if Librarian_SavedVariables["Default"][""] ~= nil then
    optionsTable[6] = {
      type = "button",
      name = GetString(SI_SETTING_OPTION_NAME_IMPORT_FROM_BEFORE_PATCH_LIBRARIAN),
      tooltip = GetString(SI_SETTING_OPTION_TOOLTIP_IMPORT_FROM_BEFORE_PATCH_LIBRARIAN),
      func = function() LIBRARIAN:ImportFromEmptyAccount() end
    }
  end
  
  local LAM = LibStub("LibAddonMenu-2.0")
  LAM:RegisterAddonPanel("LibrarianOptions", panelData)
  LAM:RegisterOptionControls("LibrarianOptions", optionsTable)
end