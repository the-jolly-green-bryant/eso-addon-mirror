if GetCVar("language.2") ~= "zh" then
    return
end

SafeAddString(
    SI_RELOADUITIMER_MESSAGE,
    "[ReloadUITimer] ReloadUI 耗时 %.3f 秒",
    1
)
