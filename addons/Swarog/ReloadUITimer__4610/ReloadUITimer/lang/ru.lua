if GetCVar("language.2") ~= "ru" then
    return
end

SafeAddString(
    SI_RELOADUITIMER_MESSAGE,
    "[ReloadUITimer] ReloadUI занял %.3f с",
    1
)
