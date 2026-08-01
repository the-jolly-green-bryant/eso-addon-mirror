-- LucentCitadelHelper Integration with DovahMova
-- Файл інтеграції для підключення української локалізації LucentCitadelHelper
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції LucentCitadelHelper
local LCHIntegration = {}
LCHIntegration.name = "LucentCitadelHelperUA"
LCHIntegration.isInitialized = false
LCHIntegration.hasPatched = false

-- Функція ініціалізації інтеграції
function LCHIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи LucentCitadelHelper завантажений
    if not LCH then
        -- Якщо LucentCitadelHelper ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForLCH", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "LucentCitadelHelper" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForLCH", EVENT_ADD_ON_LOADED)
                -- Збільшуємо затримку, щоб LCH повністю ініціалізувався
                zo_callLater(function()
                    self:ApplyUkrainianLocalization()
                    -- Повторне застосування через додатковий час
                    zo_callLater(function()
                        self:ApplyUkrainianLocalization()
                    end, 1000)
                end, 500)
            end
        end)
        return false
    end
    
    -- Якщо LucentCitadelHelper уже завантажений, застосовуємо локалізацію
    self:ApplyUkrainianLocalization()
    return true
end

-- Функція застосування української локалізації
function LCHIntegration:ApplyUkrainianLocalization()
    -- Перевіряємо, чи доступні українські рядки
    if not LCH_UA_Strings then
        return false
    end
    
    -- Застосовуємо українські переклади
    if ApplyLCHUkrainianStrings then
        ApplyLCHUkrainianStrings()
        self.hasPatched = true
        self.isInitialized = true
        
        -- КРИТИЧНО: Оновлюємо LCH.data після застосування перекладів
        self:UpdateLCHData()
        
        -- Виводимо повідомлення про успішну інтеграцію (тільки якщо LCH активний)
        if LCH and LCH.active then
            d("|cBFBC99[|r|c02fcffDovahMova|r|cBFBC99]:|r |cb8dbddзапущено українську інтеграцію для|r |ceaa514\"Lucent Citadel Helper\"|r|cb8dbdd!|r")
        end
        
        return true
    end
    
    return false
end

-- Функція для оновлення LCH.data з новими перекладами
function LCHIntegration:UpdateLCHData()
    if not LCH or not LCH.data then
        return false
    end
    
    -- Оновлюємо назви босів в LCH.data
    LCH.data.zilyessetName = string.lower(GetString(LCH_Zilyesset))
    LCH.data.orphicName = string.lower(GetString(LCH_Orphic))
    LCH.data.xorynName = string.lower(GetString(LCH_Xoryn))
    
    return true
end

-- Функція перевірки сумісності
function LCHIntegration:CheckCompatibility()
    if not LCH then
        return false, "LucentCitadelHelper не встановлений або не активний"
    end
    
    if not LCH_UA_Strings then
        return false, "Українські переклади не завантажені"
    end
    
    -- Перевіряємо базову функціональність LCH
    if not LCH.data then
        return false, "LCH.data не ініціалізований (можливо, потрібен час для завантаження)"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function LCHIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        lchVersion = LCH and LCH.version or "невідома",
        lchLoaded = LCH ~= nil,
        translationsLoaded = LCH_UA_Strings ~= nil,
        hasPatched = self.hasPatched,
        currentLocale = GetCVar("language.2"),
        lchActive = LCH and LCH.active or false
    }
end

-- Функція отримання статистики перекладу
function LCHIntegration:GetTranslationStats()
    if not LCH_UA_Strings then
        return {
            total_strings = 0,
            translated_strings = 0,
            translation_coverage = 0
        }
    end
    
    local translatedStrings = 0
    for _ in pairs(LCH_UA_Strings) do
        translatedStrings = translatedStrings + 1
    end
    
    return {
        total_strings = translatedStrings,
        translated_strings = translatedStrings,
        translation_coverage = 100.0 -- Всі наші рядки перекладені
    }
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(LCHIntegration.name, LCHIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[LCHIntegration.name] = LCHIntegration
    end
end

-- Ініціалізуємо інтеграцію
LCHIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_LCHIntegration"] = LCHIntegration

-- Команди для тестування інтеграції
SLASH_COMMANDS["/lchtest"] = function()
    local info = LCHIntegration:GetInfo()
    d("=== Тест інтеграції LucentCitadelHelper ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("Версія LCH: " .. tostring(info.lchVersion))
    d("LCH завантажено: " .. tostring(info.lchLoaded))
    d("LCH активний: " .. tostring(info.lchActive))
    d("Переклади завантажено: " .. tostring(info.translationsLoaded))
    d("Патч застосовано: " .. tostring(info.hasPatched))
    d("Поточна локаль: " .. tostring(info.currentLocale))
    
    local stats = LCHIntegration:GetTranslationStats()
    if stats then
        d("=== Статистика перекладів ===")
        d("Перекладених рядків: " .. tostring(stats.translated_strings))
        d("Покриття перекладу: " .. tostring(stats.translation_coverage) .. "%")
    end
    
    -- Тестуємо конкретні рядки
    if LCH and LCH.data then
        d("=== Тест назв босів ===")
        d("Zilyesset: '" .. tostring(LCH.data.zilyessetName) .. "'")
        d("Orphic: '" .. tostring(LCH.data.orphicName) .. "'") 
        d("Xoryn: '" .. tostring(LCH.data.xorynName) .. "'")
    end
    
    d("========================================")
end

SLASH_COMMANDS["/lchapply"] = function()
    d("Повторне застосування української локалізації для LCH...")
    LCHIntegration:ApplyUkrainianLocalization()
end

SLASH_COMMANDS["/lchforce"] = function()
    d("Примусове застосування перекладів LCH...")
    
    if LCH_UA_Strings then
        for stringId, ukrainianText in pairs(LCH_UA_Strings) do
            -- Використовуємо ZO_CreateStringId як в CrutchAlerts
            ZO_CreateStringId(stringId, ukrainianText)
        end
        
        d("Застосовано примусовий переклад через ZO_CreateStringId!")
        
        -- Тестуємо результат
        d("Тест GetString після перезапису:")
        d("LCH_Zilyesset: " .. GetString(LCH_Zilyesset))
        d("LCH_Orphic: " .. GetString(LCH_Orphic))  
        d("LCH_Xoryn: " .. GetString(LCH_Xoryn))
        
        -- Оновлюємо LCH.data
        LCHIntegration:UpdateLCHData()
        
        -- Тестуємо що відбулося з LCH.data
        if LCH and LCH.data then
            d("Оновлені значення в LCH.data:")
            d("zilyessetName: " .. tostring(LCH.data.zilyessetName))
            d("orphicName: " .. tostring(LCH.data.orphicName))  
            d("xorynName: " .. tostring(LCH.data.xorynName))
        end
    else
        d("Українські рядки недоступні!")
    end
end

SLASH_COMMANDS["/lchstrings"] = function()
    if LCH_UA_Strings then
        d("=== Українські рядки LCH ===")
        for key, value in pairs(LCH_UA_Strings) do
            d(string.format("'%s' = '%s'", key, value))
        end
        d("==========================")
    else
        d("Українські рядки не завантажені!")
    end
end

SLASH_COMMANDS["/lchupdatedata"] = function()
    if LCHIntegration:UpdateLCHData() then
        d("LCH.data оновлено!")
        if LCH and LCH.data then
            d("Нові значення:")
            d("zilyessetName: " .. tostring(LCH.data.zilyessetName))
            d("orphicName: " .. tostring(LCH.data.orphicName))  
            d("xorynName: " .. tostring(LCH.data.xorynName))
        end
    else
        d("Не вдалося оновити LCH.data!")
    end
end
