LibSlashCommander:AddFile("descriptions/ru.lua", 2, function(lib)
    lib.descriptions = {
        [GetString(SI_SLASH_SCRIPT)] = "Выполняет указанный текст как код Lua",
        [GetString(SI_SLASH_CHATLOG)] = "Переключает журнал чата",
        [GetString(SI_SLASH_GROUP_INVITE)] = "Приглашает указанное имя в группу",
        [GetString(SI_SLASH_JUMP_TO_LEADER)] = "Перемещает к лидеру группы",
        [GetString(SI_SLASH_JUMP_TO_GROUP_MEMBER)] = "Перемещает к указанному члену группы",
        [GetString(SI_SLASH_JUMP_TO_FRIEND)] = "Перемещает к указанному другу",
        [GetString(SI_SLASH_JUMP_TO_GUILD_MEMBER)] = "Перемещает к указанному члену гильдии",
        [GetString(SI_SLASH_RELOADUI)] = "Перезагружает пользовательский интерфейс",
        [GetString(SI_SLASH_PLAYED_TIME)] = "Показывает время, проведенное этим персонажем",
        [GetString(SI_SLASH_READY_CHECK)] = "Инициирует проверку готовности в группе",
        [GetString(SI_SLASH_DUEL_INVITE)] = "Бросает вызов указанному игроку на дуэль",
        [GetString(SI_SLASH_LOGOUT)] = "Возвращает к выбору персонажей",
        [GetString(SI_SLASH_CAMP)] = "Возвращает к выбору персонажей",
        [GetString(SI_SLASH_QUIT)] = "Закрывает игру",
        [GetString(SI_SLASH_FPS)] = "Переключает отображение FPS",
        [GetString(SI_SLASH_LATENCY)] = "Переключает отображение задержки",
        [GetString(SI_SLASH_STUCK)] = "Открывает экран помощи для застрявших персонажей",
        [GetString(SI_SLASH_REPORT_BUG)] = "Открывает экран сообщения об ошибке",
        [GetString(SI_SLASH_REPORT_FEEDBACK)] = "Открывает экран обратной связи",
        [GetString(SI_SLASH_REPORT_HELP)] = "Открывает экран помощи",
        [GetString(SI_SLASH_REPORT_CHAT)] = "Открывает экран жалобы на игрока",
        [GetString(SI_SLASH_ENCOUNTER_LOG)] = "Переключает журнал событий. '?' показывает опции",
    }

    -- Описания эмоций и переключения чата назначаются в types.lua
end)
