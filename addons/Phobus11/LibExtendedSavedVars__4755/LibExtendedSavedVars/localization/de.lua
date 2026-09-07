local strings = {
    ["SI_LEV_SETTINGS_SCOPE"] = "Einstellungsbereich",
    ["SI_LEV_SETTINGS_SCOPE_TT"] = "Charakterspezifisch: Nur dieser Charakter verwendet diese Einstellungen. Accountweit: Wird von allen Charakteren dieses Accounts geteilt. Serverweit: Wird von jedem Account und Charakter geteilt, der dieses Addon auf dieser Welt verwendet hat.",
    ["SI_LEV_SCOPE_CHARACTER"] = "Charakterspezifisch",
    ["SI_LEV_SCOPE_ACCOUNT"] = "Accountweit",
    ["SI_LEV_SCOPE_MEGASERVER"] = "Serverweit",
}

for stringId, value in pairs(strings) do
    LIBEXTENDEDSAVEDVARS_STRINGS[stringId] = value
end
