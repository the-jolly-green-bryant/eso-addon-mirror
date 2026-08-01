-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    --Main Window
    --Labels
    SI_SGL_MW_CURRECTGOLD = "Текущее золото: %s", -- Текущее золото: %s
    SI_SGL_MW_SESSIONGOLD = "Сессия: %s",
    SI_SGL_MW_DAYGOLD = "День: %s",
    SI_SGL_MW_LASTUPDTIME = "Последнее обновление: %s", -- Последнее обновление
    SI_SGL_MW_SWITCH_TLOG = "Лог",
    SI_SGL_MW_SWITCH_DAYS = "Дни",
    SI_SGL_MW_BUTTON_BANK = "Банк",
    -- Settings
    SI_SGL_SETTINGS_CATEGORY_GENERAL = "GENERAL",
    SI_SGL_SETTINGS_CATEGORY_LIMITS = "Лимиты транзакций",
    SI_SGL_SETTINGS_CATEGORY_LIMITS_TP = "Устанавливает лимит лога транзакций",
    SI_SGL_SETTINGS_WARNING_UNSTABLE = "Данная функция нестабильна!", --Данная функция нестабильна!


    SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG = "Уведомлять о неизвестных причинах в чат",
    SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG_TP = "Рекомендуется!\nСообщает в чат если причина транзакции неизвестна аддону. Рекомендуем включить данную опцию. Это поможет найти неизвестные причины и улучшить аддон. Если вы нашли такую причину, то сообщите автору номер причины и чем вызвана причина.", -- Сообщает в чат если причина транзакции неизвестна аддону. Рекомендуем включить данную опцию. Это поможет найти неизвестные причины и улучшить аддон. Если вы нашли такую причину, то сообщите автору номер причины и чем вызвана причина.

    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION = "Стак последней транзакции",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TP = "Объединяет транзакцию с последней если причина такая же.", -- Объединяет транзакцию с последней если причина такая же.
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK = "Создавать новую запись через время ниже", --Создавать новую запись через время ниже
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_TP = "Не стакает запись если прошло время указанное ниже.", --Не стакает запись если прошло время указанное ниже.
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME = "Время устаревания записи (в секундах)", --Время устаревания записи (в секундах)
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME_TP = "Время через которое запись устареет и вместо стака старой записи будет создана новая.", --Время через которое запись устареет и вместо стака старой записи будет создана новая.
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME = "Считать время только с момента создания", --Считать время только с момента создания
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME_TP = "С какого момента считать время устаревание записи: \nON - Только с момента создания записи \nOFF - После каждого обновления записи", --С какого момента считать время устаревание записи: \nON - Только с момента создания записи \nOFF - После каждого обновления записи

    SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD = "Скрыть текущее золото",
    SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD_TP = "Скрывает текущее золото в главном окне аддона",

    SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON = "Скрыть кнопку банка",
    SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON_TP = "Скрыть кнопку банка из окна аддона.\nПримечание: Активируйте эту опцию если не используете статистику золота по дням в банке.\nУчтите, что статистика банка по дням всё равно будет работать!",
    
    SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK = "Автоматически открывать окно аддона в банке", -- Автоматически открывать окно аддона в банке
    SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK_TP = "Автоматически открывает окно в банке на странице статистики банка по дням.", -- Автоматически открывает окно в банке на странице статистики банка по дням.


    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS = "Сохранять транзакции",
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_TP = "Нестабильно! \nСохраняет лог ваших транзакций после перезагрузки.", --Сохраняет лог ваших транзакций после перезагрузки.
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME = "Сохранить последних транзакций", --Сохранить последних транзакций
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME_TP = "Указывает сколько последних транзакций сохранить. Не рекомендуется сохранять больше 20 транзакций.", --Указывает сколько последних транзакций сохранить. Не рекомендуется сохранять больше 20 транзакций.

    SI_SGL_SETTINGS_OPTIONS_TLIMITS_ENABLE = "Включить лимит транзакций",
    SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME = "Минимальная сумма для лога", --Минимальная сумма для лога
    SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME_TP = "Если стоимость транзакии ниже указанной суммы, то транзакция не будет занесена в лог. \n(Только для доходных транзакций. Убытки также будут учитываться)", -- Если стоимость транзакии ниже указанной суммы, то транзакция не будет занесена в лог. \n(Только для доходных транзакций. Убытки также будут учитываться)

    SI_SGL_SETTINGS_CATEGORY_DEBUG = "DEBUG",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_TP = "Разные настройки которые не нужны пользователю.", --Разные настройки которые не нужны пользователю.

    -- Settings - DEBUG
    SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES = "Enable Debug Messages",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES_TP = "Includes Debug addon messages in chat",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING = "Приветствие в чат при запуске", -- Приветствие в чат при запуске
    SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING_TP = "Отправлять ли сообщение об успешной загрузки аддона в чат?", -- Отправлять ли сообщение об успешной загрузки аддона в чат?
    SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI = "Открытие окна аддона при запуске", -- Открытие окна аддона при запуске
    SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI_TP = "Автоматически открывает окно аддона при загрузке интерфейса", -- Автоматически открывает окно аддона при загрузке интерфейса
    
    -- Keybindings.
    SI_BINDING_NAME_SteelswordGoldLogger_DISPLAY = "Display Steelsword Gold Logger",
    
    --Warning Messages
    SI_SGL_WARNINGMESSAGE_BANKUPD = "Внесите/Снимите золото из банка для обновления",

    -- DEBUG
    SI_SGL_DEBUG_MESSAGE = "Активны DEBUG сообщения аддона Steelsword Gold Logger. Выключить вы их можете в настройках аддона.", -- Активны DEBUG сообщения аддона Steelsword Gold Logger. Выключить вы их можете в настройках аддона.
    SI_SGL_DEBUG_MESSAGE_GREETING = "Steelsword Gold Logger v%s by FAR747", 


    -- GOLD REASON
    SI_SGL_GUPD_REASON_UNDEFINED = "Неизвестная причина",
    SI_SGL_GUPD_REASON_UNDEFINED_MSG = "Причина %s неизвестна. Пожалуйста сообщите автору!",
    SI_SGL_GUPD_REASON_0 = "Добыто из сундука",
    SI_SGL_GUPD_REASON_1 = "Торговец",
    SI_SGL_GUPD_REASON_2 = "Почта",
    SI_SGL_GUPD_REASON_3 = "Обмен",
    SI_SGL_GUPD_REASON_4 = "Награда за квест",
    SI_SGL_GUPD_REASON_5 = "Оплата NPC",
    SI_SGL_GUPD_REASON_8 = "Улучшение инвентаря",
    SI_SGL_GUPD_REASON_9 = "Улучшение банка",
    SI_SGL_GUPD_REASON_11 = "Раскопки",
    SI_SGL_GUPD_REASON_13 = "Добыто из моба",
    SI_SGL_GUPD_REASON_19 = "Быстрое перемещение",
    SI_SGL_GUPD_REASON_21 = "Поля сражений",
    SI_SGL_GUPD_REASON_24 = "Мастерская нарядов",
    SI_SGL_GUPD_REASON_27 = "Награда за уровень",
    SI_SGL_GUPD_REASON_28 = "Улучшение маунта",
    SI_SGL_GUPD_REASON_29 = "Починка предметов",
    SI_SGL_GUPD_REASON_31 = "Покупка в гильдсторе",
    SI_SGL_GUPD_REASON_32 = "Покупка в гильдсторе (возврат)",
    SI_SGL_GUPD_REASON_33 = "Взнос за размещение",
    SI_SGL_GUPD_REASON_42 = "Депозит в банк",
    SI_SGL_GUPD_REASON_43 = "Вывод из банка",
    SI_SGL_GUPD_REASON_44 = "Сброс навыков",
    SI_SGL_GUPD_REASON_45 = "Сброс характеристик",
    SI_SGL_GUPD_REASON_47 = "Оплата штрафа стражнику", -- Оплата штрафа стражнику
    SI_SGL_GUPD_REASON_50 = "Покупка гильдейского табарда",
    SI_SGL_GUPD_REASON_51 = "Депозит в гильдейский банк",
    SI_SGL_GUPD_REASON_52 = "Вывод из гильдейского банка",
    SI_SGL_GUPD_REASON_55 = "Преобразования навыков",
    SI_SGL_GUPD_REASON_56 = "Оплата штрафа (убежище)",
    SI_SGL_GUPD_REASON_57 = "Оплата штрафа (смерть)",
    SI_SGL_GUPD_REASON_60 = "Отмыв предмета", -- Отмыв
    SI_SGL_GUPD_REASON_61 = "Преобразование CP",
    SI_SGL_GUPD_REASON_62 = "Добыто из воровского тайника",
    SI_SGL_GUPD_REASON_63 = "Продажа краденого", --Продажа краденого
    SI_SGL_GUPD_REASON_64 = "Выкуп у торговца", --Выкуп у торговца


    --Other
    SI_SGL_INFO_WEBSITE = "https://steelsword.ru/",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end