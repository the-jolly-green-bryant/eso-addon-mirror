-- @Origami: WARNING! Some of the new translations here are done via Google Translate. Sorry!
local strings = {
    RM_OP_HEADING1 = "Настройки ездовых животных",
    RM_OP_HEADING2 = "Настройки небоевых питомцев",
    RM_OP_HEADING3 = "Ездовые животные",
    RM_OP_HEADING4 = "Небоевые питомцы",
    RM_OP_HEADING6 = "Варианты кожи",
    RM_OP_HEADING7 = "Скины",
    RM_OP_ACCOUNT = "Настройки на аккаунт",
    RM_OP_MOUNTS_ENABLE = "Разрешить изменение ездового животного",
    RM_OP_MOUNTS_ENABLE_PVP = "Активно в ПвП",
    RM_OP_MOUNTS_MULTI_GROUPED = "Предпочитать несколько пассажиров в группе",
    RM_OP_MOUNTS_MULTI_COMPANION = "Предпочитаю нескольких райдеров, пока компаньон",
    RM_OP_ACTIVATE_ZONE = "Изменять при смене зоны",
    RM_OP_ACTIVATE_DISMOUNT = "Изменять при спешивании",
    RM_OP_PETS_ENABLE = "Разрешить изменение небоевого питомца",
    RM_OP_SKINS_ENABLE = "Включить случайные скины",
    RM_OP_DELAY = "Задержка",
    RM_OP_DELAY_TT = "Задержка между случайными маунтами и питомцами и скины",
    RM_OP_ALLOW_DEFAULT = "Разрешить скин по умолчанию",
    RM_OP_PETS_UNSUMMON_PVP = "отзов в пвп зонах",
    RM_OP_PETS_UNSUMMON_DUNGEON = "отозвать в подземельях",
    RM_OP_PETS_UNSUMMON_GROUP = "отозвать в группе"
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end
