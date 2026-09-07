local strings = {
    ["SI_LEV_SETTINGS_SCOPE"] = "設定の範囲",
    ["SI_LEV_SETTINGS_SCOPE_TT"] = "キャラクター専用: このキャラクターのみがこの設定を使用します。アカウント全体: このアカウントの全キャラクターで共有されます。メガサーバー全体: このワールドでこのアドオンを使用したすべてのアカウントとキャラクターで共有されます。",
    ["SI_LEV_SCOPE_CHARACTER"] = "キャラクター専用",
    ["SI_LEV_SCOPE_ACCOUNT"] = "アカウント全体",
    ["SI_LEV_SCOPE_MEGASERVER"] = "メガサーバー全体",
}

for stringId, value in pairs(strings) do
    LIBEXTENDEDSAVEDVARS_STRINGS[stringId] = value
end
