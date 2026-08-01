local strings = {
    LIBWARCRY_ERROR_MISSING_COLLECTIBLE = "Dir fehlt |H1:collectible:<<1>>|h|h um diesen WarCry auszuführen",
    LIBWARCRY_ERROR_ID_MUST_BE_NUMBER = "id muss vom Typ 'number' sein!",
    LIBWARCRY_ERROR_IDS_MUST_BE_TABLE = "ids muss vom Typ 'table' sein!",
    LIBWARCRY_ERROR_NAME_MUST_NOT_BE_NIL = "name darf nicht nil sein!",
    LIBWARCRY_ERROR_NAME_NOT_FOUND = "WarCry nicht gefunden",

    LIBWARCRY_LIST_AVAILABLE = "Verfügbare WarCry's:",

    LIBWARCRY_CREATED = "<<1>> erfolgreich erstellt",

    LIBWARCRY_ENABLED = "Chat Listener aktiviert",
    LIBWARCRY_DISABLED = "Chat Listener deaktiviert",

    LIBWARCRY_MENU_GCS_NAME = "Gruppeneinstellungen",
    LIBWARCRY_MENU_GCS_SYNCED_WARCRY_TITLE = "Synchronisierter WarCry",
    LIBWARCRY_MENU_GCS_SYNCED_WARCRY_TOOLTIP = "Aktiviert/Deaktiviert das horchen auf Chatnachrichten um den WarCry mit der Gruppe zu synchronisieren"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end

-- the official way does not work somehow o.O
--[[ for stringId, stringValue in pairs(strings) do
	SafeAddString(stringId, stringValue, 1)
end ]]