TetsuCombatTools = TetsuCombatTools or {}

TetsuCombatTools.L = {
    TITLE = "|cFFD700Tetsu's|r Combat Tools",

    INFO_LABEL = "Справка",
    INFO_TT = "Боевой HUD для геймпада. История скиллов, GCD и лампа боя.\nПочта: @Tetsurion.",

    SKILL_ENABLE = "Skill Tracking",
    SKILL_ENABLE_TT = "Последние нажатые скиллы бара и полоска GCD. Ульт всегда в ленте.",

    SKILL_SECTION = "Skill Tracking",
    SKILL_SECTION_TT = "Лента, размер, позиция, видимость.",

    SKILL_SLOTS = "Слотов истории",
    SKILL_SLOTS_TT = "Сколько последних скиллов держать. 4–8. По умолчанию 6.",

    SKILL_SCALE = "Масштаб иконок %",
    SKILL_SCALE_TT = "Размер иконок в ленте.",

    SKILL_X = "Сдвиг X",
    SKILL_X_TT = "0 = центр экрана. Минус влево, плюс вправо.",

    SKILL_Y = "Сдвиг Y",
    SKILL_Y_TT = "0 = прицел / центр экрана. По умолчанию 330 — над скиллбаром. Минус вверх, плюс вниз.",

    SKILL_SHOW = "Когда показывать",
    SKILL_SHOW_TT = "В бою = в бою, потом скрыть по таймеру. Всегда = не прятать. После нажатия = скрыть через N сек после последнего скилла.",

    SHOW_COMBAT = "Только в бою",
    SHOW_ALWAYS = "Всегда",
    SHOW_IDLE = "После последнего нажатия",

    SKILL_HIDE = "Скрыть через (сек)",
    SKILL_HIDE_TT = "После выхода из боя (режим «в бою») и после последнего нажатия (режим «после нажатия»). По умолчанию 8.",

    SKILL_GCD = "Полоска GCD",
    SKILL_GCD_TT = "Жёлто-красная полоска под иконками. Выкл = только иконки, цветные рамки остаются.",

    SKILL_LA = "Лёгкие атаки",
    SKILL_LA_TT = "Выкл по умолчанию. Если вкл — лёгкие атаки ещё и отдельной иконкой в ленте. Зелёная/красная рамка работает и при выкл. Тяжёлые, блок, додж и синергии не пишутся.",

    STATUS_ENABLE = "Combat Status",
    STATUS_ENABLE_TT = "Красный в бою, зелёный вне боя. Иконка, текст и звук входа — отдельно.",
    STATUS_SECTION = "Combat Status",
    STATUS_SECTION_TT = "Иконка, текст и звук только на вход в бой.",
    STATUS_ICON = "Иконка",
    STATUS_ICON_TT = "Вкл по умолчанию. Цветной круг на прицеле. Позиция и размер свои, не общие с текстом.",
    STATUS_ICON_X = "Иконка X",
    STATUS_ICON_X_TT = "0 = центр экрана. Минус влево, плюс вправо.",
    STATUS_ICON_Y = "Иконка Y",
    STATUS_ICON_Y_TT = "0 = прицел. Минус вверх, плюс вниз.",
    STATUS_ICON_SCALE = "Иконка масштаб %",
    STATUS_ICON_SCALE_TT = "Размер лампы.",
    STATUS_TEXT = "Текст",
    STATUS_TEXT_TT = "Выкл по умолчанию. Пишет В БОЮ / ВНЕ БОЯ теми же красным и зелёным.",
    STATUS_TEXT_X = "Текст X",
    STATUS_TEXT_X_TT = "0 = центр экрана.",
    STATUS_TEXT_Y = "Текст Y",
    STATUS_TEXT_Y_TT = "По умолчанию 250 — ниже прицела. Минус вверх, плюс вниз.",
    STATUS_TEXT_SCALE = "Текст масштаб %",
    STATUS_TEXT_SCALE_TT = "Размер надписи.",
    STATUS_IN = "В БОЮ",
    STATUS_OUT = "ВНЕ БОЯ",
    STATUS_SOUND = "Звук входа в бой",
    STATUS_SOUND_TT = "Вкл по умолчанию. Играет только когда бой начинается, не когда заканчивается.",
    STATUS_SOUND_PICK = "Звук старта",
    STATUS_SOUND_PICK_TT = "Штатный звук игры. Своих файлов нет.",
    SOUND_DUEL = "Старт дуэли",
    SOUND_ALERT = "Алерт",
    SOUND_QUEST = "Квест",
    SOUND_NOTIFY = "Уведомление",
    SOUND_DISCOVER = "Цель найдена",
}
