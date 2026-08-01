-- Українські переклади для LucentCitadelHelper
-- Ukrainian localization for LucentCitadelHelper
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Українські рядки для LucentCitadelHelper
local LCH_UA_Strings = {
    LCH_LANG = "ua",
    
    LCH_InitMSG = "|cBFBC99[|r|c02fcffLCH|r|cBFBC99]:|r|cb8dbdd Дякуємо за використання Lucent Citadel Helper. Будь ласка, повідомляйте про проблеми в Discord|r wondernuts",
    
    -- Назви босів (точно як в грі українською)
    LCH_Zilyesset = "Граф Райлаз",
    LCH_Orphic = "Орфічний Розбитий Осколок", 
    LCH_Xoryn = "Зорін",
}

-- Функція для застосування українських рядків
function ApplyLCHUkrainianStrings()
    -- Використовуємо ZO_CreateStringId як в CrutchAlerts - перезапише існуючі ID
    for stringId, ukrainianText in pairs(LCH_UA_Strings) do
        ZO_CreateStringId(stringId, ukrainianText)
    end
end

-- Експортуємо рядки для використання в integration.lua
_G["LCH_UA_Strings"] = LCH_UA_Strings
_G["ApplyLCHUkrainianStrings"] = ApplyLCHUkrainianStrings
