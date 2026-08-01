-- Sanity's Edge Helper Ukrainian Language File
-- Український мовний файл для Sanity's Edge Helper
-- Автор: DovahMova Team

-- Перевіряємо чи поточна мова українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Українські переклади для Sanity's Edge Helper
local strings = {
    SEH_LANG = "ua",
    
    -- Повідомлення при ініціалізації
    SEH_InitMSG = "|cBFBC99[|r|c02fcffSEH|r|cBFBC99]:|r|cb8dbdd Дякуємо за використання Sanity Edge Helper. Про проблеми повідомляйте в discord|r wondernuts",
    
    -- Імена босів
    SEH_Yaseyla = "Екзарханічна Ясейла",
    SEH_Twelvane = "Архімаг Твелвейн",
    SEH_Chimera = "Химера",
    SEH_Ansuul = "Ансуул Мучителька",
}

-- Застосовуємо переклади
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end

d("[SanitysEdgeHelper UA] Український мовний файл завантажено")
