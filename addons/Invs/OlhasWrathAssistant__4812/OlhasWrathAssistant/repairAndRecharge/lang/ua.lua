local strings = {
    AUTO_REPAIR = "Автоматичний ремонт",
    AUTO_REPAIR_TOOLTIP = "Налаштування автоматичного ремонту спорядженої екіпіровки.",

    ENABLE_REPAIR = "Автоматично ремонтувати екіпіровку",
    ENABLE_REPAIR_TOOLTIP = "Сканує та ремонтує лише споряджені предмети.",

    REPAIR_THRESHOLD = "Ремонтувати на рівні або нижче",
    REPAIR_THRESHOLD_TOOLTIP = "Ремонтує споряджені предмети, коли їхній стан досягає вказаного відсотка або опускається нижче.",
    REPAIR_THRESHOLD_SET = "Екіпіровка буде ремонтуватись на %d%%.",

    USE_CROWN_REPAIR_KITS_FIRST = "Використовувати спочатку Crown Repair Kits",
    USE_CROWN_REPAIR_KITS_FIRST_TOOLTIP = "Якщо ввімкнено, спочатку використовуються Crown Repair Kits, а після їх завершення — звичайні Repair Kits. Якщо вимкнено, використовуються лише звичайні Repair Kits. Crown Repair Kits доступні лише поза боєм.",

    REPAIR_IN_COMBAT = "Ремонтувати під час бою",
    REPAIR_IN_COMBAT_TOOLTIP = "Дозволяє використовувати звичайні Repair Kits під час бою. Crown Repair Kits гра дозволяє використовувати лише поза боєм.",
    TRACK_REPAIR_KITS = "Відстежувати залишок Repair Kits",
    TRACK_REPAIR_KITS_TOOLTIP = "Вмикає окремі попередження про малу кількість звичайних Repair Kits. Crown Repair Kits не враховуються.",
    REPAIR_KIT_WARNING_THRESHOLD = "Показувати повідомлення про залишок Repair Kits",
    REPAIR_KIT_WARNING_THRESHOLD_TOOLTIP = "Після ремонту показує залишок Repair Kits, якщо їхня кількість дорівнює цьому значенню або є меншою.",
    REPAIR_CHAT_MESSAGES = "Повідомлення про ремонт у чаті",
    REPAIR_CHAT_MESSAGES_TOOLTIP = "Показує в чаті повідомлення про кожен автоматично відремонтований предмет.",

    ITEM_REPAIRED = "Поремонтовано %s на %d%%.",
    REPAIR_KITS_REMAINING = "Залишилось Repair Kits: %d.",

    AUTO_RECHARGE = "Автоматичний заряд зброї",
    AUTO_RECHARGE_TOOLTIP = "Налаштування автоматичного заряджання спорядженої зброї.",

    ENABLE_RECHARGE = "Автоматично заряджати зброю",
    ENABLE_RECHARGE_TOOLTIP = "Сканує та заряджає лише споряджену зброю.",

    RECHARGE_THRESHOLD = "Заряджати на рівні або нижче",
    RECHARGE_THRESHOLD_TOOLTIP = "Заряджає споряджену зброю, коли заряд її зачарування досягає вказаного відсотка або опускається нижче.",
    RECHARGE_THRESHOLD_SET = "Зброя буде заряджатись на %d%%.",

    USE_CROWN_SOUL_GEMS_FIRST = "Використовувати спочатку Crown Soul Gems",
    USE_CROWN_SOUL_GEMS_FIRST_TOOLTIP = "Якщо ввімкнено, спочатку використовуються Crown Soul Gems, а після їх завершення — звичайні заповнені Soul Gems. Якщо вимкнено, використовуються лише звичайні Soul Gems.",

    RECHARGE_IN_COMBAT = "Заряджати під час бою",
    RECHARGE_IN_COMBAT_TOOLTIP = "Дозволяє автоматично заряджати споряджену зброю під час бою.",
    TRACK_SOUL_GEMS = "Відстежувати залишок Soul Gems",
    TRACK_SOUL_GEMS_TOOLTIP = "Вмикає окремі попередження про малу кількість звичайних заповнених Soul Gems. Crown Soul Gems не враховуються.",
    SOUL_GEM_WARNING_THRESHOLD = "Показувати повідомлення про залишок Soul Gems",
    SOUL_GEM_WARNING_THRESHOLD_TOOLTIP = "Після заряджання показує залишок заповнених Soul Gems, якщо їхня кількість дорівнює цьому значенню або є меншою.",
    RECHARGE_CHAT_MESSAGES = "Повідомлення про заряд у чаті",
    RECHARGE_CHAT_MESSAGES_TOOLTIP = "Показує в чаті повідомлення про кожну автоматично заряджену зброю.",

    ITEM_RECHARGED = "Заряджено %s на %d%%.",
    SOUL_GEMS_REMAINING = "Залишилось заповнених Soul Gems: %d.",
}

local owa = OWAssistant
owa.AddLanguageStrings("ua", strings, "REPAIR")
