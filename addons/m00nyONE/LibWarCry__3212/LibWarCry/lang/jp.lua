local strings = {
    LIBWARCRY_ERROR_MISSING_COLLECTIBLE = "You are missing |H1:collectible:<<1>>|h|h",
    LIBWARCRY_ERROR_ID_MUST_BE_NUMBER = "id must be a number!",
    LIBWARCRY_ERROR_IDS_MUST_BE_TABLE = "ids must be a table!",
    LIBWARCRY_ERROR_NAME_MUST_NOT_BE_NIL = "name must not be nil!",
    LIBWARCRY_ERROR_NAME_NOT_FOUND = "WarCry not found",

    LIBWARCRY_LIST_AVAILABLE = "Available WarCry's:",

    LIBWARCRY_CREATED = "<<1>> has been created",

    LIBWARCRY_ENABLED = "group listener enabled",
    LIBWARCRY_DISABLED = "group listener disabled",

    LIBWARCRY_MENU_GCS_NAME = "group control settings",
    LIBWARCRY_MENU_GCS_SYNCED_WARCRY_TITLE = "synced WarCry",
    LIBWARCRY_MENU_GCS_SYNCED_WARCRY_TOOLTIP = "enables/disables listening for chat events to sync warcry in the group"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end