local strings =
{
    SI_ADDONLOADOUTS_LOADOUTS = "Пресет",
    SI_ADDONLOADOUTS_SAVE_CURRENT = "Сохранить текущий пресет",
    SI_ADDONLOADOUTS_APPLY_LOADOUT = "Применить пресет",
    SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP = "Выберите сохранённый пресет и перезагрузите интерфейс.",
    SI_ADDONLOADOUTS_LOAD = "Загрузить",
    SI_ADDONLOADOUTS_DELETE = "Удалить",
    SI_ADDONLOADOUTS_NEW_LOADOUT_NAME = "Имя нового пресета",
    SI_ADDONLOADOUTS_APPLY = "Применить",
    SI_ADDONLOADOUTS_RELOADING = "Пресет применён. Перезагрузка интерфейса...",
    SI_ADDONLOADOUTS_NO_LOADOUTS = "Нет сохранённых пресетов. Сохраните текущее состояние аддонов как новый пресет в Настройках.",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE = "Обновить активный пресет",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED = "Перезаписать \"%s\" текущими включёнными аддонами (последний применённый пресет).",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE = "Сначала примените пресет — затем можно обновить его текущим набором аддонов.",
    SI_ADDONLOADOUTS_MOVE_UP = "Выше",
    SI_ADDONLOADOUTS_MOVE_DOWN = "Ниже",
    SI_ADDONLOADOUTS_ORGANIZE = "Управление пресетами",
    SI_ADDONLOADOUTS_ORGANIZE_TITLE = "Управление пресетами",
    SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY = "(В этом пресете нет включённых аддонов.)",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
