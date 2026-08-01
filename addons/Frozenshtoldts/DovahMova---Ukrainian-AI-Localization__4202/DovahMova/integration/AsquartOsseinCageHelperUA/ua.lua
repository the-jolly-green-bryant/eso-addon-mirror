-- AsquartOsseinCageHelper Ukrainian Localization
-- Українська локалізація для AsquartOsseinCageHelper
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Визначаємо українські рядки для AsquartOsseinCageHelper
local strings = {
    AOCH_LANG = "ua",
    
    AOCH_InitMSG                = "[AOCH] Дякуємо за використання Asquart's Ossein Cage Helper. Будь ласка, повідомляйте про проблеми в Discord користувачу asquart",
    AOCH_OsiMSG                 = "Будь ласка, встановіть останню версію |cff0000OdySupportIcons|r (опціональна залежність), щоб побачити всі функції аддону, включно з маркерами.",

    AOCH_Tri1                   = "Трифекта! Вражає!",
    AOCH_Tri2                   = "А як щодо...",
    AOCH_Tri3                   = "... вийти на вулицю?",

    AOCH_CarrionShield          = "Щит падальників", -- A749908 
    AOCH_SpectralRevenant       = "Неспокійний привид Кістяка", -- A117765 
    AOCH_Abductor               = "Жахливий Викрадач", -- A117260

    AOCH_GednaRelvel            = "Руда відьма Ґедна Релвел", -- A117896
    AOCH_TorturedRanyu          = "Ранью-Мученик", -- A117738
    AOCH_BloodDrkinerThisa      = "Кровопивця Тіза", -- A117733

    AOCH_ShaperOfFlesh          = "Формувач Плоті", -- A117215
    AOCH_Fleshspawn             = "Породження Плоті", -- A118330
    AOCH_Channeler              = "Провідник", -- A117220
    AOCH_Harvester              = "Жнець", -- A117354
    AOCH_Daedroth               = "Даедрот", -- A117348

    AOCH_Jynorah                = "Джинора", -- A117683
    AOCH_Skorknif               = "Скорхіф", -- A117684
    AOCH_Valneer                = "Вогнекований Валнір", -- A117108
    AOCH_Myrinax                = "Іскробуря Мірінакс", -- A117107

    AOCH_Kazpian                = "Наддемон Каспіан", -- A117085
    AOCH_AgonizerBomb           = "Бомба Мучителя", -- A118272
}

-- Експортуємо рядки для використання інтеграцією
_G["AsquartOsseinCageHelperUA_Strings"] = strings

-- ЗАВЖДИ застосовуємо українські рядки
-- Це перезапише англійські рядки які AOCH завантажив з Lang/en.lua
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end

