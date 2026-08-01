RajinesExpLeft = RajinesExpLeft  or {}
RajinesExpLeft.translations = RajinesExpLeft.translations or {}

RajinesExpLeft.translations["ru"] = {
    loaded = "загружен. Язык: |cffff66{language}|r. Используйте |cffff66/xptl help|r для списка команд.",

    xp_message = "|c88ff88+{gained} XP|r получено. Осталось |cffffff{remaining}|r XP до повышения уровня. Это примерно |cffff66{repeatCount}x|r такого количества.",
    cp_xp_message = "|c88ff88+{gained} CP-XP|r получено. Осталось |cffffff{remaining}|r CP-XP до следующего очка Чемпиона. Это примерно |cffff66{repeatCount}x|r такого количества.",

    enabled = "включен.",
    disabled = "отключен.",
    active = "|c88ff88активен|r",
    inactive = "|cff8888неактивен|r",

    status = "Статус: {status}, задержка: |cffff66{cooldown} сек.|r, язык: |cffff66{language}|r.",
    cooldown_missing = "Введите число, например |cffff66/xptl cooldown 5|r.",
    cooldown_disabled = "Задержка отключена. Будет показано каждое получение XP.",
    cooldown_set = "Задержка установлена на |cffff66{seconds} сек.|r.",
    reset_done = "Отслеживание XP сброшено.",
    unknown_command = "Неизвестная команда: |cffff66{command}|r",

    help_title = "Команды:",
    help_on = "включить addon",
    help_off = "отключить addon",
    help_status = "показать текущие настройки",
    help_cooldown = "ограничить вывод в чат до одного раза в 5 секунд",
    help_reset = "сбросить отслеживание XP",
    help_help = "показать помощь"
}