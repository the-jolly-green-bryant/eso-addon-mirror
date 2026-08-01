WellEater = WellEater or {}
local L = {
    generalSetupDescription = "После истечения времени эффектов, которые дает еда, позволяет автоматически съесть" ..
            " найденное в инвентаре блюдо. Автоподзарядка оружия и авторемонт брони",
    foodQualityHeader = "Качество искомой еды",
    foodQualityDescription = "Позволяет выбрать качество еды",
    foods = {
        [ITEM_QUALITY_MAGIC] = "|c00FB00Хорошее|r",
        [ITEM_QUALITY_ARCANE] = "|c0077FFПревосходное|r",
        [ITEM_QUALITY_ARTIFACT] = "|c9400D3Эпическое|r",
        [ITEM_QUALITY_LEGENDARY] = "|cFFFF00Легендарное|r",
    },
    timerSetupHeader = "Таймер опроса состояния персонажа",
    timerSetupLabel = "Период опроса, мс",
    timerSetupLabel_TT = "Как часто состояние персонаж сканируется на наличие усилений (баффов) еды." ..
            " Большее значение - меньше нагрузка но большая вероятность оказаться без еды на некоторое время" ..
            " в критической ситуации",

    youEat = "Вы съели <<1>>",
    youCharge = "Заряжено <<1>> при помощи <<2>>",
    youChargeScreen = "Заряжено <<1>>",
    youRepair = "Отремонтировано <<1>> при помощи <<2>>",
    youRepairScreen = "Отремонтировано <<1>>",
    allRepair = "Все отремонтировано при помощи <<1>>",
    allRepairScreen = "Все отремонтировано",
    outputSetupHeader = "Вывод сообщения",
    outputOnScreen = "На экран",
    outputSetupHeader_TT = "При включенной настройке сообщение о съеденном блюде или перезарядке оружия будет выведено на экран, а не только" ..
            " в лог отладки",

    mealSetupHeader = "Тип блюда",
    mealSetupDescription = "Что использовать: еду или питье. ВНИМАНИЕ Если отключить оба, " ..
            " выбора не будет, что равносильно отключению аддона. Включите хотя бы один.",

    mealSetupFood = "Еда",
    mealSetupDrink = "Напиток",

    weaponSetupHeader = "Оружие",
    weaponSetupDescription = "Автоматическое зачарование оружия произойдёт при уменьшении количества зарядов до" ..
            " минимального и наличии в инвентаре камня душ",
    weaponSetupEnchantMainHand = "Оружие в основной руке",
    weaponSetupEnchantOffHand = "Оружие в дополнительной руке",
    weaponSetupEnchantMainHandBack = "Оружие в основной руке, вторая панель",
    weaponSetupEnchantOffHandBack = "Оружие в дополнительной руке, вторая панель",

    minCharges = "Минимальное количество зарядов",
    useCrownGemsTitle = "Использовать кронные камни душ",
    useCrownGemsTitle_TT = "При поиске камня душ в инвентаре учитывать и кронные камни",

    useCrownFoodTitle = "Использовать кронную еду",
    useCrownFoodTitle_TT = "При поиске еды в инвентаре учитывать и кронную еду",

    repairSetupHeader = "Авторемонт",
    repairSetupDescription = "Настройки авторемонта",

    repairSetupCheck = "Автоматический ремонт снаряжения",
    repairSetupCheck_TT = "Для автоматического ремонта снаряжения необходим ремонтный набор в инвентаре",
    repairPercent = "Минимальный % повреждения",

    useCrownRepairTitle = "Использовать кронные ремнаборы",
    useCrownRepairTitle_TT = "Использовать кронные ремонтные наборы",

}

for k, v in pairs(L) do
    if type(v) ~= "table" then
        local string = "WELLEATER_" .. string.upper(k)
        ZO_CreateStringId(string, v)
    elseif k == "foods" then
        for ik, iv in pairs(v) do
            local string = "WELLEATER_FOODS_" .. ik
            ZO_CreateStringId(string, iv)
        end
    end
end

if (GetCVar('language.2') == 'ru') then
    local MissingL = {}
    for k, v in pairs(WellEater:getLocale()) do
        if (not L[k]) then
            table.insert(MissingL, k)
            L[k] = v
        end
    end
    function WellEater:getLocale()
        return L
    end
    -- for debugging
    function WellEater:MissingLocale()
        df("[WellEater] Missing strings for '%s'", GetCVar('language.2'))
        d(MissingL)
    end
end

