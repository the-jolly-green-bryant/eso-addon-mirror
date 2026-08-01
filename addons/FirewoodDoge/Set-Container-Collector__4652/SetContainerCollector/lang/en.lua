local strings = {
  SI_SCC_TOOLTIP_PROGRESS = "Collected: <<1>>/<<2>>",
  SI_SCC_TOOLTIP_AUTO_RESOLVED = "Auto-detected: <<1>>",
  SI_SCC_TOOLTIP_AUTO_RESOLVED_WITH_SLOT = "Auto-detected: <<1>> (<<2>>)",
  SI_SCC_TOOLTIP_AUTO_RESOLVED_SLOT_HEAD = "head only",
  SI_SCC_TOOLTIP_AUTO_RESOLVED_SLOT_SHOULDERS = "shoulders only",
  SI_SCC_TOOLTIP_NO_DATA = "Container data not configured yet.",
  SI_SCC_SLASH_POOL_USAGE = "Usage: /scc pool <poolKey>  (e.g. maj_mystery, ap_elite, battleground_merchant)",
  SI_SCC_SLASH_POOL_UNKNOWN = "Unknown pool: <<1>>",
  SI_SCC_SLASH_POOL_RESULT = "<<1>>: <<2>>/<<3>> collected",
  SI_SCC_SETTINGS_DESCRIPTION = "Shows account-wide set collection progress on equipment container tooltips.",
  SI_SCC_SETTINGS_AUTO_RESOLVE = "Auto-detect unregistered containers",
  SI_SCC_SETTINGS_AUTO_RESOLVE_TT = "When enabled, unidentified set boxes not listed in the addon database are resolved via the game's container set info API.",
  SI_SCC_SETTINGS_TOOLTIP_FONT_SIZE = "Tooltip font size",
  SI_SCC_SETTINGS_TOOLTIP_FONT_SIZE_TT = "Font size for the collection progress line in container tooltips.",
  SI_SCC_SETTINGS_SLASH_HELP = "/scc pool <key> — print pool progress. /scc debuglink <itemLink> — inspect a container link.",
}

for stringId, stringValue in pairs(strings) do
  ZO_CreateStringId(stringId, stringValue)
  SafeAddVersion(stringId, 1)
end
