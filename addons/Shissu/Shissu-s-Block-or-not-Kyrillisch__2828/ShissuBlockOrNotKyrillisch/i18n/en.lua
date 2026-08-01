ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuBlockOrNotKyrillisch"] = {       
  TITLE       = "Block or not Kyrillisch",

  GENERAL     = "General chat filters",
  CMD         = "Hidden messages due to the filters can be shown and searched with /chatfilter.",
  GUILD       = "Hide Guild Advertising",
  ITEMS       = "Hide sales, item search requests",
  ACHIEVMENT  = "Hide Achievements Sales",
  
  CYRILLIC    = "Cyrillic",
  DESC        = "Removes messages with Cyrillic characters in the chat. The function can be switched on and off via a key combination. Alternatively, only the Cyrillic script can be displayed.",
  SET         = "Blocking Cyrillic characters",
  SET2        = "Show only chat messages with Cyrillic script",
  ON          = "Cyrillic characters are blocked.",
  OFF         = "Cyrillic characters are no longer blocked.",

  USER        = "Custom Chat Filter",
  USERHELP    = "To filter multiple strings, separate the individual words/strings with a semicolon.",
  USEREXAMPLE = "Example: Hallo;WTB;Kuta;Maus;Accountname",
  USER_TT     = "Hides all chat messages that contain the custom strings.",
  USER_2      = "Custom",

  PROTOCOL    = "Protocol",
  SAVE        = "Save log",
  SAVE_TT     = "Saves the log, the filtered chat messages",
  COUNT       = "Number of entries",
  COUNT_TT    = "Sets the maximum number of chat messages to be saved/displayed.",

  FILTER_TT   = "Search for XYZ in the filtered chat messages. e.g. guild for guild promotion, items for items.",
}

ZO_CreateStringId("SI_BINDING_NAME_SBK_Toogle", "Blocking Cyrillic characters")