local strings = {
    UNDAUNTED_PLEDGES = "Звершення Безстрашних",
    UNDAUNTED_PLEDGES_TOOLTIP = "Додає вибір ветеранських підземель за квестами Безстрашних. Потрібна LibUndauntedPledges.",
    PLEDGES_SELECT_TOOLTIP = "Вибрати ветеранські підземелля за твоїми звершеннями. Зняття позначки очищає вибір.",
    PLEDGES_NO_QUESTS = "Спочатку прийми квест звершення Безстрашних.",
    PLEDGES_UNAVAILABLE = "Ветеранські підземелля за твоїми звершеннями зараз недоступні.",
    PLEDGES_IN_QUEUE = "Під час черги чи перевірки готовності вибір недоступний.",
    PLEDGES_MISSING_LIBRARY = "Установи й увімкни LibUndauntedPledges та виконай /reloadui.",
}

local ua = UAssistant
ua.AddLanguageStrings("ua", strings)
