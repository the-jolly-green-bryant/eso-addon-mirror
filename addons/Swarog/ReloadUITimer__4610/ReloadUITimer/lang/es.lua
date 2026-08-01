if GetCVar("language.2") ~= "es" then
    return
end

SafeAddString(
    SI_RELOADUITIMER_MESSAGE,
    "[ReloadUITimer] ReloadUI tardó %.3f s",
    1
)
