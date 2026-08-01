-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuGuildHome"] = {
  TITLE =           "Guild: " .. GetString(SI_WINDOW_TITLE_GUILD_HOME),
  KIOSK =           "Time to next guild trader bid",
  KIOSK_TT =        "Shows the time until the NPC dealer is changed in the guild overview. In the last 15 minutes of the dealer allocation process, an additional window with the following information will also appear: Last time for bidding, end of bids, time for replacement dealer.",

  LEFTTIME =        "Remaining time",
  
  TRADER =          "Guild NPC",
  NEWKIOSK =        "New trader in",
  BIDEND =          "Bid end",
  REPLACE =         "Replacement",        
  
  TEXT =            "YOURTEXT",
  
  COLOR =           GetString(SI_GUILD_HERALDRY_COLOR),       -- Farbe
  COLOR_INFO =      "Displays additional buttons for inserting HTML color codes.",
  COLOR_MOTD =      "Message of the Day",
  COLOR_DESC =      "Background Information",
}