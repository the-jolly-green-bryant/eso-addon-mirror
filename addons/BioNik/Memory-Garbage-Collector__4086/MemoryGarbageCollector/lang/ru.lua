local strings = {
    SI_MGC_ADDON_DESCRIPTION = "Включённый аддон будет выполнять сбор мусора LUA (garbage collect) при превышения текущего потребления памяти выше заданной планки.",
    SI_MGC_AUTO_CLEAR = "Включить очистку",
    SI_MGC_AUTO_CLEAR_TOOLTIP = "Включить автоматическую очистку памяти от неиспользуемыых переменных.",
    SI_MGC_REFRESH_RATE = "Время между попытками, мин",
    SI_MGC_REFRESH_RATE_TOOLTIP = "Раз в N минут, будет проводиться очистка памяти, если обнаружено нарушение заданных пределов.",
    SI_MGC_COMPARISON_METHOD = "Сравнение затраченной памяти",
    SI_MGC_COMPARISON_METHOD_TOOLTIP = "Превышение потребления памяти, в относительном значении (%%) или в абсолютном (Мб).",
    SI_MGC_OVERFLOW_RELATIVE = "Относительное значение (%%)",
    SI_MGC_OVERFLOW_RELATIVE_TOOLTIP = "При превышении потребления памяти на N %%, относительно стартового значения, будет произведена очистка.",
    SI_MGC_OVERFLOW_ABSOLUTE = "Абсолютное значение (Мб)",
    SI_MGC_OVERFLOW_ABSOLUTE_TOOLTIP = "При превышении потребления памяти на N Мб, относительно стартового значения, будет произведена очистка.",
    SI_MGC_SHOW_DEBUG_MESSAGES = "Показывать отладочные сообщения",
    SI_MGC_SILENT_MODE = "Тихий режим (отключить ВСЕ сообщения чата)",
    SI_MGC_MEMORY_INIT_MAX = "|ceeeeeeУстановлен лимит потребления памяти: |cAFD3FF%d Мб.",
    SI_MGC_MEMORY_OVERFLOW_DEBUG = "|ceeeeeeСейчас: |c77ff7a%d Мб; |ceeeeeeЛимит: |cAFD3FF%d Мб.",
    SI_MGC_MEMORY_OVERFLOW_REACHED = "|ceeeeeeДо: |cff7d77%d Мб; |ceeeeeeПосле: |c77ff7a%d Мб; |ceeeeeeОсвобождено: |cAFD3FF%d Мб.",
}

for id, val in pairs(strings) do
    SafeAddString(_G[id], val, 1)
end
