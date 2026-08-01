local strings = {
    POINAMES_TITLE          = "English POI and Keep Names",
    POINAMES_TITLE_SHORT    = "English POI Names",
    POINAMES_POI_COL        = "Text color for POI names",
    POINAMES_POI_COL_DESC   = "Color used for english point of interest names on the WorldMap.",
    POINAMES_KEEP_COL       = "Text color for keep names",
    POINAMES_KEEP_COL_DESC  = "Color used for english keep names on tooltips.",
    POINAMES_HIDE_ALLI      = "Hide alliance name from the keep tooltip",
    POINAMES_HIDE_ALLI_DESC = "If this option is enabled, addon will hide alliance owner from the keep tooltip.",
    POINAMES_NEW_LIN        = "Extra line for english keep name",
    POINAMES_NEW_LIN_DESC   = "If this option is enabled, keep tooltip will have extra line with english keep name.",
    POINAMES_UPDATE_DATA    = "Update POI and Keep names",
    POINAMES_UPDATE_DATA_DESC = "Get actual English point of interest and keep names from the game client."
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
