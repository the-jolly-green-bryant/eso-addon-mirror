-- * _ANDY_VERSION: 1.0.0 ** Please do not modify this line.
--[[----------------------------------------------------------
	AddonAnalyzer (ANDY)
  ----------------------------------------------------------
  *
	* Authors:
	* - Lent (IGN @CallMeLent, Github @adefee)
  *
  * Contents:
  * - Base/Default ANDY vars
  *
]]--
Andy = {
  name = "Andy",
  version = "1.1.1",
  versionESO = 101100,
  author = "Lent (IGN @CallMeLent, Github @adefee)",
  color = "D66E4A",
  attribution = {
    author = "Lent",
    authorIGN = "@CallMeLent",
    authorDiscord = "Lent",
    authorGit = "@adefee"
  },
  utility = {},
  data = {},
  saved = {},
  defaults = {
    count = {
      loaded = 0,
      affected = 0,
    },
    enable = {
      autoScan = 1, -- Automatically scan on UI reload
      playSound = 1, -- Play warning sound when flagged addons detected
      showBanner = 1, -- Show center screen banner when flagged addons detected
      quietMode = 0, -- If enabled, only show messages when scan finds flagged addons
    },
    internal = {
      lastUpdate = 0,
      firstLoad = 1,
      showDebug = 0
    },
    ignore = {
      enabled = false, -- If true, suppress warnings until new addon found or version updated
      versionWhenIgnored = nil, -- Andy version when suppress was set
      flaggedAddons = {} -- List of addon names that were flagged when suppress was set
    },
    seenWatchlistAddons = { -- ANDY History: User's installed addons that have been flagged in the past
    }
  }
}
