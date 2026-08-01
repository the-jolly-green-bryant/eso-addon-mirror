if GetCVar("language.2") ~= "fr" then
    return
end

SafeAddString(
    SI_RELOADUITIMER_MESSAGE,
    "[ReloadUITimer] ReloadUI a pris %.3f s",
    1
)
