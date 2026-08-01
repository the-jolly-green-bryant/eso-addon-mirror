-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    --Main Window
    --Labels
    SI_SGL_MW_CURRECTGOLD = "Current Gold: %s", -- Текущее золото: %s
    SI_SGL_MW_SESSIONGOLD = "Session Gold: %s",
    SI_SGL_MW_DAYGOLD = "Day Gold: %s",
    SI_SGL_MW_LASTUPDTIME = "Last update: %s", -- Последнее обновление
    SI_SGL_MW_SWITCH_TLOG = "Logs",
    SI_SGL_MW_SWITCH_DAYS = "Days",
    SI_SGL_MW_BUTTON_BANK = "Bank",
    -- Settings
    SI_SGL_SETTINGS_CATEGORY_GENERAL = "GENERAL",
    SI_SGL_SETTINGS_CATEGORY_LIMITS = "Transaction Limits",
    SI_SGL_SETTINGS_CATEGORY_LIMITS_TP = "Set transaction log limits",
    SI_SGL_SETTINGS_WARNING_UNSTABLE = "This function is unstable!", --Данная функция нестабильна!


    SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG = "Notify about unknown reasons in the chat.",
    SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG_TP = "Recommended! \nReports to chat if the reason for the transaction is unknown to the addon. We recommend enabling this option. This will help to find unknown causes and improve the addon. If you find such a reason, then inform the author of the reason number and what caused the reason.", -- Сообщает в чат если причина транзакции неизвестна аддону. Рекомендуем включить данную опцию. Это поможет найти неизвестные причины и улучшить аддон. Если вы нашли такую причину, то сообщите автору номер причины и чем вызвана причина.

    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION = "Stack last transaction",
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TP = "Stack the transaction with the latter if the reason is the same.", -- Объединяет транзакцию с последней если причина такая же.
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK = "Create a new record in time below", --Создавать новую запись через время ниже
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_TP = "The record does not stack if the time indicated below has passed.", --Не стакает запись если прошло время указанное ниже.
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME = "Record Aging Time (in seconds)", --Время устаревания записи (в секундах)
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME_TP = "The time after which the recording becomes outdated and a new one is created instead of the stack of the old recording.", --Время через которое запись устареет и вместо стака старой записи будет создана новая.
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME = "Count time only from the moment of creation", --Считать время только с момента создания
    SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME_TP = "From what moment to count the time the record expired: \nON - Only from the moment the record was created \nOFF - After each record update", --С какого момента считать время устаревание записи: \nON - Только с момента создания записи \nOFF - После каждого обновления записи

    SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD = "Hide Current Gold",
    SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD_TP = "Hides the amount of gold from the addon window.",

    SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON = "Hide Bank Button",
    SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON_TP = "Hide the bank button from the addon window.\nNote: Activate this option if you do not use statistics by the day at the bank.\nKeep in mind that bank statistics by day will still work!",
    
    SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK = "Automatically open the addon window in the bank", -- Автоматически открывать окно аддона в банке
    SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK_TP = "Automatically opens a window in the bank on the bank statistics page by day.", -- Автоматически открывает окно в банке на странице статистики банка по дням.

    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS = "Save Transactions",
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_TP = "Unstable! \nSaves a log of your transactions after reboot.", --Сохраняет лог ваших транзакций после перезагрузки.
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME = "Save Recent Transactions", --Сохранить последних транзакций
    SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME_TP = "Indicates how many recent transactions to keep. It is not recommended to save more than 20 transactions.", --Указывает сколько последних транзакций сохранить. Не рекомендуется сохранять больше 20 транзакций.

    SI_SGL_SETTINGS_OPTIONS_TLIMITS_ENABLE = "Enable Transaction Limits",
    SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME = "Minimum amount for the log", --Минимальная сумма для лога
    SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME_TP = "If the transaction value is lower than the specified amount, then the transaction will not be logged. \n(Only for profitable transactions. Losses will also be taken into account)", -- Если стоимость транзакии ниже указанной суммы, то транзакция не будет занесена в лог. \n(Только для доходных транзакций. Убытки также будут учитываться)

    SI_SGL_SETTINGS_CATEGORY_DEBUG = "DEBUG",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_TP = "Various settings that the user does not need.", --Разные настройки которые не нужны пользователю.

    -- Settings - DEBUG
    SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES = "Enable Debug Messages",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES_TP = "Includes Debug addon messages in chat",
    SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING = "Welcome message to chat on startup", -- Приветствие в чат при запуске
    SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING_TP = "Should I send a message about the successful upload of the addon to chat?", -- Отправлять ли сообщение об успешной загрузки аддона в чат?
    SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI = "Opening the addon window at startup", -- Открытие окна аддона при запуске
    SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI_TP = "Automatically opens the addon window when loading the interface", -- Автоматически открывает окно аддона при загрузке интерфейса
    --Legacy
    SI_SGL_SETTINGS_CATEGORY_DEBUG_LEGACY_OLDBUTTONS = "Old type of navigation", --Старый вид навигации
    SI_SGL_SETTINGS_CATEGORY_DEBUG_LEGACY_OLDBUTTONS_TP = "Enable the old type of button display (Not stable!)\n\nWill need to reload the UI!", --Включить старый вид отображения кнопок (Не стабильно!)\nТребуется перезагрузка интерфейса!
    -- Keybindings.
    SI_BINDING_NAME_SteelswordGoldLogger_DISPLAY = "Display Steelsword Gold Logger",

    --Warning Messages
    SI_SGL_WARNINGMESSAGE_BANKUPD = "Deposit/withdraw of gold to the bank for update",
    
    -- DEBUG
    SI_SGL_DEBUG_MESSAGE = "Active DEBUG messages addon Steelsword Gold Logger. You can turn them off in the addon settings.", -- Активны DEBUG сообщения аддона Steelsword Gold Logger. Выключить вы их можете в настройках аддона.
    SI_SGL_DEBUG_MESSAGE_GREETING = "Steelsword Gold Logger v%s by FAR747", 


    -- GOLD REASON
    SI_SGL_GUPD_REASON_UNDEFINED = "Undefined reason",
    SI_SGL_GUPD_REASON_UNDEFINED_MSG = "Reason %s undefined. Please inform the author!",
    SI_SGL_GUPD_REASON_0 = "Looted from chest",
    SI_SGL_GUPD_REASON_1 = "Merchant",
    SI_SGL_GUPD_REASON_2 = "Mail",
    SI_SGL_GUPD_REASON_3 = "Trade",
    SI_SGL_GUPD_REASON_4 = "Quest reward",
    SI_SGL_GUPD_REASON_5 = "Paid NPC",
    SI_SGL_GUPD_REASON_8 = "Upgrade backpack",
    SI_SGL_GUPD_REASON_9 = "Upgrade Bank",
    SI_SGL_GUPD_REASON_11 = "Looted from excavation",
    SI_SGL_GUPD_REASON_13 = "Looted from enemies",
    SI_SGL_GUPD_REASON_19 = "Wayshrine travel",
    SI_SGL_GUPD_REASON_21 = "Battlegrounds",
    SI_SGL_GUPD_REASON_24 = "Outfit Station",
    SI_SGL_GUPD_REASON_27 = "Level Reward",
    SI_SGL_GUPD_REASON_28 = "Mount upgrade",
    SI_SGL_GUPD_REASON_29 = "Items repair",
    SI_SGL_GUPD_REASON_31 = "Buy in guild store",
    SI_SGL_GUPD_REASON_32 = "Buy in guild store (refund)",
    SI_SGL_GUPD_REASON_33 = "Guild Store Contribution",
    SI_SGL_GUPD_REASON_42 = "Deposited to bank",
    SI_SGL_GUPD_REASON_43 = "Withdrawn from bank",
    SI_SGL_GUPD_REASON_44 = "Skills reset",
    SI_SGL_GUPD_REASON_45 = "Characteristic Points Reset",
    SI_SGL_GUPD_REASON_47 = "Payment of the penalty", -- Оплата штрафа стражнику
    SI_SGL_GUPD_REASON_50 = "Buying guild tabard",
    SI_SGL_GUPD_REASON_51 = "Deposited to guild bank",
    SI_SGL_GUPD_REASON_52 = "Withdrawn from guild bank",
    SI_SGL_GUPD_REASON_55 = "Skills Respec",
    SI_SGL_GUPD_REASON_56 = "Payment of the penalty (Refuge)",
    SI_SGL_GUPD_REASON_57 = "Payment of the penalty (Dead)",
    SI_SGL_GUPD_REASON_60 = "Item laundering", -- Отмыв
    SI_SGL_GUPD_REASON_61 = "Reset CP",
    SI_SGL_GUPD_REASON_62 = "Looted from thieves chest",
    SI_SGL_GUPD_REASON_63 = "Sale of stolen", --Продажа краденого
    SI_SGL_GUPD_REASON_64 = "Buyout in Merchant", --Выкуп у торговца

    --Other
    SI_SGL_INFO_WEBSITE = "https://www.esoui.com/downloads/info2668-SteelswordGoldLogger.html",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end