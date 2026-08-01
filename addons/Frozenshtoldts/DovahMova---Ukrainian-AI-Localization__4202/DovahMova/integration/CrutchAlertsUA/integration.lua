-- CrutchAlerts Integration with DovahMova
-- Файл інтеграції для забезпечення роботи CrutchAlerts з українською локалізацією
-- Повертає англійські імена босів для CrutchAlerts щоб фази та підписи працювали коректно
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції CrutchAlerts
local CrutchAlertsIntegration = {}
CrutchAlertsIntegration.name = "CrutchAlertsUA"
CrutchAlertsIntegration.isInitialized = false
CrutchAlertsIntegration.originalGetUnitName = nil

-- Тепер CrutchAlerts отримає українські переклади через ua.lua файл
-- Ніякі маппінги більше не потрібні!

-- Функція ініціалізації інтеграції
function CrutchAlertsIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи CrutchAlerts завантажений
    if not CrutchAlerts then
        -- Якщо CrutchAlerts ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForCrutchAlerts", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "CrutchAlerts" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForCrutchAlerts", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyBossNameFix()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо CrutchAlerts уже завантажений, застосовуємо фікс
    self:ApplyBossNameFix()
    
    -- Більше не потрібно - ua.lua файл автоматично застосовується
    
    return true
end

-- Функція застосування фіксу імен босів
function CrutchAlertsIntegration:ApplyBossNameFix()
    if not CrutchAlerts then
        return
    end
    
    -- Зберігаємо оригінальні функції  
    self.originalGetUnitName = GetUnitName
    
    -- КРИТИЧНО: Перехоплюємо GetUnitName для внутрішньої логіки CrutchAlerts
    -- Потрібно повертати англійські імена для пошуку в thresholds таблиці!
    
    -- Отримуємо централізований маппінг з ua_boss_names.lua
    local bossNames = _G["CrutchAlertsUABossNames"]
    
    if not bossNames then
        d("[CrutchAlerts UA] ❌ ПОМИЛКА: Не знайдено ua_boss_names.lua!")
        d("[CrutchAlerts UA] Переконайтеся що ua_boss_names.lua завантажений.")
        return
    end
    
    -- Створюємо маппінг українська→англійська з централізованої таблиці
    local ukrainianToEnglish = {}
    local mappingCount = 0
    
    for constName, data in pairs(bossNames) do
        ukrainianToEnglish[data.ua] = data.en
        mappingCount = mappingCount + 1
    end
    
    d(string.format("[CrutchAlerts UA] ✅ Згенеровано маппінг для %d босів", mappingCount))
    
    -- Патчимо GetUnitName для CrutchAlerts
    local function PatchedGetUnitName(unitTag)
        local originalName = self.originalGetUnitName(unitTag)
        
        -- Перевіряємо чи це бос і чи викликає CrutchAlerts
        if unitTag and string.find(unitTag, "boss") and originalName and originalName ~= "" then
            local callStack = debug.traceback()
            local isCrutchAlertsCall = callStack and string.find(callStack, "CrutchAlerts")
            
            if isCrutchAlertsCall and ukrainianToEnglish[originalName] then
                -- Аналізуємо call stack детальніше
                local isThresholdLookup = callStack and (
                    string.find(callStack, "GetBossThresholds") or 
                    string.find(callStack, "thresholds%[") or
                    string.find(callStack, "BHB%.thresholds")
                )
                
                if isThresholdLookup then
                    -- Це пошук фаз - повертаємо англійську назву
                    local englishName = ukrainianToEnglish[originalName]
                    if self.bossLogging then
                        d(string.format("[CrutchAlerts UA] 📋 Фази: '%s' -> '%s'", originalName, englishName))
                    end
                    return englishName
                else
                    -- Це UI відображення - залишаємо українську назву
                    if self.bossLogging then
                        d(string.format("[CrutchAlerts UA] 🖼️ UI: '%s' (залишаємо українську)", originalName))
                    end
                    return originalName
                end
            end
            
            if self.bossLogging then
                d(string.format("[CrutchAlerts UA] 🔍 Бос: '%s' (%s) - %s", 
                    originalName, unitTag, isCrutchAlertsCall and "CrutchAlerts" or "інший addon"))
            end
        end
        
        return originalName  -- Повертаємо оригінальну назву для всіх інших
    end
    
    -- Замінюємо глобальну функцію
    _G["GetUnitName"] = PatchedGetUnitName
    
    self.isInitialized = true
    
    d("[CrutchAlerts UA] Інтеграція активована - англійські імена босів для правильної роботи")
end

-- Функція відновлення оригінальної функції
function CrutchAlertsIntegration:RestoreOriginalFunction()
    if self.originalGetUnitName then
        _G["GetUnitName"] = self.originalGetUnitName
        self.isInitialized = false
        d("[CrutchAlerts UA] Інтеграція відключена")
    end
end

-- Функція перевірки сумісності
function CrutchAlertsIntegration:CheckCompatibility()
    if not CrutchAlerts then
        return false, "CrutchAlerts не встановлений або не активний"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function CrutchAlertsIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        crutchAlertsVersion = CrutchAlerts and CrutchAlerts.version or "unknown",
        crutchAlertsLoaded = CrutchAlerts ~= nil,
        currentLocale = GetCVar("language.2"),
        mappedBosses = 0 -- Could count the mapping table
    }
end

-- Функція додавання нового маппінгу
-- ВАЖЛИВО: Всі маппінги керуються в ua_boss_names.lua!
function CrutchAlertsIntegration:AddBossMapping(ukrainianName, englishName)
    d("[CrutchAlerts UA] ⚠️ AddBossMapping застаріла!")
    d("Відредагуйте ua_boss_names.lua замість цього:")
    d(string.format("    CRUTCH_BHB_??? = { en = \"%s\", ua = \"%s\" },", englishName, ukrainianName))
end

-- Функція для логування всіх імен босів (щоб знайти правильні українські назви)
function CrutchAlertsIntegration:EnableBossLogging()
    self.bossLogging = true
    d("[CrutchAlerts UA] Логування імен босів увімкнено. Заходьте в підземелля щоб побачити назви.")
end

function CrutchAlertsIntegration:DisableBossLogging()
    self.bossLogging = false
    d("[CrutchAlerts UA] Логування імен босів вимкнено.")
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(CrutchAlertsIntegration.name, CrutchAlertsIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[CrutchAlertsIntegration.name] = CrutchAlertsIntegration
    end
end

-- Ініціалізуємо інтеграцію
CrutchAlertsIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_CrutchAlertsIntegration"] = CrutchAlertsIntegration

-- Функція для отримання поточного маппінгу (для тестування)
function CrutchAlertsIntegration:GetBossMapping()
    return _G["CrutchAlertsUABossNames"]
end

-- Команди для тестування інтеграції
SLASH_COMMANDS["/crutchtest"] = function()
    local info = CrutchAlertsIntegration:GetInfo()
    d("=== Тест інтеграції CrutchAlerts ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("CrutchAlerts завантажено: " .. tostring(info.crutchAlertsLoaded))
    d("Версія CrutchAlerts: " .. tostring(info.crutchAlertsVersion))
    d("Поточна локалізація: " .. tostring(info.currentLocale))
    d("====================================")
end

SLASH_COMMANDS["/crutchrestore"] = function()
    CrutchAlertsIntegration:RestoreOriginalFunction()
end

SLASH_COMMANDS["/crutchbosstest"] = function()
    d("=== Тест імен босів ===")
    for i = 1, 12 do
        local bossTag = "boss" .. i
        local bossName = GetUnitName(bossTag)
        if bossName and bossName ~= "" then
            d(string.format("%s: '%s'", bossTag, bossName))
        end
    end
    d("=====================")
end

-- Команда для тестування перекладів
SLASH_COMMANDS["/crutchtranslationtest"] = function()
    d("=== Тест українських перекладів CrutchAlerts ===")
    
    -- Перевіряємо чи мова українська
    local currentLang = GetCVar("language.2")
    d("Поточна мова: " .. tostring(currentLang))
    
    if currentLang ~= "ua" then
        d("❌ Мова не українська! Використайте /script SetCVar(\"language.2\", \"ua\")")
        return
    end
    
    -- Перевіряємо кілька ключових констант
    local testConstants = {
        {"CRUTCH_BHB_SAINT_OLMS_THE_JUST", "Святий Олмс Справедливий"},
        {"CRUTCH_BHB_SAINT_FELMS_THE_BOLD", "Святий Фелмс Сміливий"}, 
        {"CRUTCH_BHB_LOKKESTIIZ", "Локкестіїз"},
        {"CRUTCH_BHB_ASSEMBLY_GENERAL", "Генерал Асамблеї"}
    }
    
    for _, test in ipairs(testConstants) do
        local constName = test[1]
        local expectedTranslation = test[2]
        local constValue = _G[constName]
        
        if constValue and type(constValue) == "number" then
            local actualTranslation = GetString(constValue)
            local status = actualTranslation == expectedTranslation and "✅" or "❌"
            
            d(string.format("%s %s (ID:%d) = '%s' %s", 
                status, constName, constValue, actualTranslation,
                actualTranslation == expectedTranslation and "" or "(очікували: '" .. expectedTranslation .. "')")
            )
        else
            d(string.format("❌ %s - константа не знайдена або не є числом", constName))
        end
    end
    
    d("=========================================")
end

-- Тест маппінгу українських імен до англійських (для фаз)
SLASH_COMMANDS["/crutchmappingtest"] = function()
    if not CrutchAlertsIntegration.isInitialized then
        d("❌ CrutchAlerts UA інтеграція не ініціалізована!")
        return
    end
    
    d("=== Тест статичного маппінгу ===")
    
    -- Перевіряємо наш статичний маппінг напряму
    local ukrainianToEnglish = {
        ["Святий Олмс Справедливий"] = "Saint Olms the Just",
        ["Святий Фелмс Сміливий"] = "Saint Felms the Bold", 
        ["Локкестіїз"] = "Lokkestiiz",
        ["Генерал Асамблеї"] = "Assembly General"
    }
    
    for ukrainianName, expectedEnglish in pairs(ukrainianToEnglish) do
        local status = expectedEnglish and "✅" or "❌"
        d(string.format("%s '%s' -> '%s'", status, ukrainianName, expectedEnglish))
    end
    
    d("")
    d("💡 Реальний тест: зайдіть в vAS/vSS/vHoF і подивіться на фази!")
    d("=========================================")
end
