-- vAS Helper Ukrainian Strings
-- Українські переклади для vAS Helper
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо таблицю українських перекладів
vASHelperUA_Strings = {
    -- Основні рядки UI
    ["VAS_HELPER_POSITIONING"] = "Позиціонування",
    ["VAS_HELPER_SHOW_OLMS_JUMP_ZONES"] = "Показати зони стрибків Олмса",
    ["VAS_HELPER_OLMS_JUMP_ZONES_TOOLTIP"] = "Зона, де Олмс може стрибнути. Корисно для вивчення водіння стрибків посередині (на відміну від входу/виходу).",
    
    -- Лінії
    ["VAS_HELPER_SHOW_LANE_1"] = "Показати лінію 1",
    ["VAS_HELPER_SHOW_LANE_2"] = "Показати лінію 2",
    ["VAS_HELPER_SHOW_LANE_3"] = "Показати лінію 3",
    ["VAS_HELPER_SHOW_LANE_4"] = "Показати лінію 4",
    ["VAS_HELPER_SHOW_LANE_5"] = "Показати лінію 5",
    ["VAS_HELPER_SHOW_LANE_6"] = "Показати лінію 6",
    ["VAS_HELPER_SHOW_LANE_7"] = "Показати лінію 7",
    ["VAS_HELPER_SHOW_LANE_8"] = "Показати лінію 8",
    
    -- Підказки для ліній
    ["VAS_HELPER_LANE_1_TOOLTIP"] = "Відобразити розташування лінії 1",
    ["VAS_HELPER_LANE_2_TOOLTIP"] = "Відобразити розташування лінії 2",
    ["VAS_HELPER_LANE_3_TOOLTIP"] = "Відобразити розташування лінії 3",
    ["VAS_HELPER_LANE_4_TOOLTIP"] = "Відобразити розташування лінії 4",
    ["VAS_HELPER_LANE_5_TOOLTIP"] = "Відобразити розташування лінії 5",
    ["VAS_HELPER_LANE_6_TOOLTIP"] = "Відобразити розташування лінії 6",
    ["VAS_HELPER_LANE_7_TOOLTIP"] = "Відобразити розташування лінії 7",
    ["VAS_HELPER_LANE_8_TOOLTIP"] = "Відобразити розташування лінії 8",
    
    -- Зони хілера
    ["VAS_HELPER_SHOW_HEALER_ZONE"] = "Показати зону хілера",
    ["VAS_HELPER_HEALER_ZONE_TOOLTIP"] = "Зона, з якої можна дістатися до входу або виходу за допомогою славетних або пагонистих насінин - особливо корисно при соло хілінгу.",
    
    -- Позиції танка
    ["VAS_HELPER_SHOW_TANK_POSITIONS"] = "Показати позиції танка",
    ["VAS_HELPER_TANK_POSITIONS_TOOLTIP"] = "Відобразити місце, звідки ви танчите Олмса, і куда відступати під час водіння",
    
    -- Егоїстичне очищення
    ["VAS_HELPER_SHOW_SELFISH_PURGE"] = "Показати егоїстичне очищення",
    ["VAS_HELPER_SELFISH_PURGE_TOOLTIP"] = "Відобразити, коли потрібно очиститися від КРОВОТЕЧІ або ВИПРОБУВАННЯ ВОГНЕМ, корисно для TH та GH",
    
    -- Розмір іконок
    ["VAS_HELPER_ICON_SIZE"] = "Розмір іконок %",
    ["VAS_HELPER_ICON_SIZE_TOOLTIP"] = "(за замовчуванням 100) налаштуйте відсотковий розмір іконок - вам потрібно буде зайти в зал і повернутися в арену Олмса, щоб побачити нові розміри іконок.",
    
    -- Повідомлення
    ["VAS_HELPER_PURGE_TEXT"] = "ОЧИЩЕННЯ",
    
    -- Назва аддону
    ["VAS_HELPER_DISPLAY_NAME"] = "|cFFD700vAS Помічник|r",
    
    -- Повідомлення про статус
    ["VAS_HELPER_ADDON_NAME"] = "vAS Помічник",
    ["VAS_HELPER_AUTHOR"] = "Branddi",
}

-- Створюємо локалізовані string ID для прямого використання
local function CreateLocalizedStringIds()
    for stringId, text in pairs(vASHelperUA_Strings) do
        ZO_CreateStringId(stringId, text)
        SafeAddVersion(stringId, 1)
    end
end

-- Застосовуємо переклади після завантаження
zo_callLater(CreateLocalizedStringIds, 100)
