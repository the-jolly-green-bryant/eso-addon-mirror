-- lang/ru.lua
-- Russian string overrides.
-- Returns immediately for non-Russian clients — SafeAddString is never called,
-- so the English defaults set by ZO_CreateStringId remain in effect.
-- Version 1 ensures these override those defaults for Russian clients.

if GetCVar("language.2") ~= "ru" then return end

local SAS = SafeAddString
SAS(SI_OSF_SHOW_FAVORITES,  "Избранное",              1)
SAS(SI_OSF_ADD_FAVORITE,    "Добавить в избранное",   1)
SAS(SI_OSF_REMOVE_FAVORITE, "Убрать из избранного",   1)
