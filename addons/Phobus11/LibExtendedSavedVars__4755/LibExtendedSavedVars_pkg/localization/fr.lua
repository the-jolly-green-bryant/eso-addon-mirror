local strings = {
    ["SI_LEV_SETTINGS_SCOPE"] = "Portée des réglages",
    ["SI_LEV_SETTINGS_SCOPE_TT"] = "Spécifique au personnage : seul ce personnage utilise ces réglages. Tout le compte : partagé par tous les personnages de ce compte. Tout le méga-serveur : partagé par tous les comptes et personnages ayant utilisé cet addon sur ce monde.",
    ["SI_LEV_SCOPE_CHARACTER"] = "Ce personnage uniquement",
    ["SI_LEV_SCOPE_ACCOUNT"] = "Tout le compte",
    ["SI_LEV_SCOPE_MEGASERVER"] = "Tout le méga-serveur",
}

for stringId, value in pairs(strings) do
    LIBEXTENDEDSAVEDVARS_STRINGS[stringId] = value
end
