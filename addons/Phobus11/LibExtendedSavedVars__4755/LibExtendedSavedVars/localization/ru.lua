local strings = {
    ["SI_LEV_SETTINGS_SCOPE"] = "Область настроек",
    ["SI_LEV_SETTINGS_SCOPE_TT"] = "Только этот персонаж: настройки использует только этот персонаж. На весь аккаунт: общие настройки для всех персонажей этого аккаунта. На весь мегасервер: общие настройки для всех аккаунтов и персонажей, использовавших это дополнение в этом мире.",
    ["SI_LEV_SCOPE_CHARACTER"] = "Только этот персонаж",
    ["SI_LEV_SCOPE_ACCOUNT"] = "На весь аккаунт",
    ["SI_LEV_SCOPE_MEGASERVER"] = "На весь мегасервер",
}

for stringId, value in pairs(strings) do
    LIBEXTENDEDSAVEDVARS_STRINGS[stringId] = value
end
