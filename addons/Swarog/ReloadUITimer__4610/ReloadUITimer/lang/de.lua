if GetCVar("language.2") ~= "de" then
    return
end

SafeAddString(
    SI_RELOADUITIMER_MESSAGE,
    "[ReloadUITimer] ReloadUI dauerte %.3f s",
    1
)
