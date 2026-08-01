if GetCVar("language.2") ~= "ja" then
    return
end

SafeAddString(
    SI_RELOADUITIMER_MESSAGE,
    "[ReloadUITimer] ReloadUI に %.3f 秒かかりました",
    1
)
