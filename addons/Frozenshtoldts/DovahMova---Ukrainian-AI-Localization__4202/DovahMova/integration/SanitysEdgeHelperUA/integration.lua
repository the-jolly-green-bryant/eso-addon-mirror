-- SanitysEdgeHelper Integration with DovahMova
-- Файл інтеграції для забезпечення роботи SanitysEdgeHelper з українською локалізацією
-- Додає підтримку українських імен босів Sanity's Edge
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції SanitysEdgeHelper
local SanitysEdgeHelperIntegration = {}
SanitysEdgeHelperIntegration.name = "SanitysEdgeHelperUA"
SanitysEdgeHelperIntegration.isInitialized = false
SanitysEdgeHelperIntegration.debugLogging = false

-- Функція ініціалізації інтеграції
function SanitysEdgeHelperIntegration:Initialize()
    if self.isInitialized then
        return true
    end
    
    -- Перевіряємо, чи SanitysEdgeHelper завантажений
    if not SEH then
        -- Якщо SanitysEdgeHelper ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForSEH", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "SanitysEdgeHelper" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForSEH", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianSupport()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо SanitysEdgeHelper уже завантажений, застосовуємо підтримку
    self:ApplyUkrainianSupport()
    return true
end

-- Функція застосування підтримки української мови
function SanitysEdgeHelperIntegration:ApplyUkrainianSupport()
    if not SEH then
        return
    end
    
    -- SanitysEdgeHelper використовує GetString() для імен босів, тому українські переклади
    -- автоматично застосовуються через ua.lua файл який завантажується до цього файлу
    
    -- Оновлюємо дані імен босів в SEH.data (якщо вони ще не оновлені)
    if SEH.data then
        -- Перезавантажуємо імена босів з оновленими українськими перекладами
        SEH.data.yaseylaName = string.lower(GetString(SEH_Yaseyla))
        SEH.data.chimeraName = string.lower(GetString(SEH_Chimera)) 
        SEH.data.ansuulName = string.lower(GetString(SEH_Ansuul))
        
        if self.debugLogging then
            d(string.format("[SEH UA] 🔄 Оновлені імена босів:"))
            d(string.format("  yaseylaName: '%s'", SEH.data.yaseylaName))
            d(string.format("  chimeraName: '%s'", SEH.data.chimeraName))
            d(string.format("  ansuulName: '%s'", SEH.data.ansuulName))
        end
    end
    
    self.isInitialized = true
    d("[SanitysEdgeHelper UA] ✅ Інтеграція активована - підтримка українських імен босів")
end

-- Функція перевірки сумісності
function SanitysEdgeHelperIntegration:CheckCompatibility()
    if not SEH then
        return false, "SanitysEdgeHelper не встановлений або не активний"
    end
    
    if not SEH.data then
        return false, "SEH.data не ініціалізований"
    end
    
    if not SEH.BossesChanged then
        return false, "SEH.BossesChanged функція не знайдена"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function SanitysEdgeHelperIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        sehVersion = SEH and SEH.version or "unknown",
        sehLoaded = SEH ~= nil,
        currentLocale = GetCVar("language.2"),
        supportedBosses = 3, -- Yaseyla, Chimera, Ansuul
        localizationMethod = "GetString() з мовних файлів"
    }
end

-- Функція для включення/відключення детального логування
function SanitysEdgeHelperIntegration:SetDebugLogging(enabled)
    self.debugLogging = enabled
    local status = enabled and "увімкнено" or "вимкнено"
    d(string.format("[SanitysEdgeHelper UA] Детальне логування %s", status))
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(SanitysEdgeHelperIntegration.name, SanitysEdgeHelperIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[SanitysEdgeHelperIntegration.name] = SanitysEdgeHelperIntegration
    end
end

-- Ініціалізуємо інтеграцію
SanitysEdgeHelperIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_SanitysEdgeHelperIntegration"] = SanitysEdgeHelperIntegration

-- ===============================
-- Тестові команди
-- ===============================

-- Команда для тестування інтеграції
SLASH_COMMANDS["/sehtest"] = function()
    local info = SanitysEdgeHelperIntegration:GetInfo()
    d("=== Тест інтеграції SanitysEdgeHelper ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("SEH завантажено: " .. tostring(info.sehLoaded))
    d("Версія SEH: " .. tostring(info.sehVersion))
    d("Поточна локалізація: " .. tostring(info.currentLocale))
    d("Підтримувані боси: " .. tostring(info.supportedBosses))
    d("Метод локалізації: " .. tostring(info.localizationMethod))
    d("==========================================")
end

-- Команда для тестування імен босів
SLASH_COMMANDS["/sehbosstest"] = function()
    d("=== Тест імен босів (SEH) ===")
    for i = 1, 12 do
        local bossTag = "boss" .. i
        local bossName = GetUnitName(bossTag)
        if bossName and bossName ~= "" then
            local lowerName = string.lower(bossName)
            d(string.format("%s: '%s'", bossTag, bossName))
            
            if SEH and SEH.data then
                -- Перевіряємо всі можливі співпадіння
                local matches = {}
                if string.match(lowerName, SEH.data.yaseylaName) then table.insert(matches, "Yaseyla") end
                if string.match(lowerName, SEH.data.chimeraName) then table.insert(matches, "Chimera") end
                if string.match(lowerName, SEH.data.ansuulName) then table.insert(matches, "Ansuul") end
                
                if #matches > 0 then
                    d("  Співпадіння: " .. table.concat(matches, ", "))
                end
            end
        end
    end
    d("============================")
end

-- Команда для включення детального логування
SLASH_COMMANDS["/sehdebug"] = function(args)
    if args == "on" then
        SanitysEdgeHelperIntegration:SetDebugLogging(true)
    elseif args == "off" then
        SanitysEdgeHelperIntegration:SetDebugLogging(false)
    else
        local current = SanitysEdgeHelperIntegration.debugLogging
        SanitysEdgeHelperIntegration:SetDebugLogging(not current)
    end
end

-- Команда для перевірки поточного стану SEH
SLASH_COMMANDS["/sehstatus"] = function()
    if not SEH then
        d("❌ SanitysEdgeHelper не завантажений!")
        return
    end
    
    d("=== Статус SanitysEdgeHelper ===")
    d("Активний: " .. tostring(SEH.active))
    d("В бою: " .. tostring(SEH.status.inCombat))
    d("Поточний бос: " .. tostring(SEH.status.currentBoss))
    d("Yaseyla: " .. tostring(SEH.status.isYaseyla))
    d("Chimera: " .. tostring(SEH.status.isChimera))
    d("Ansuul: " .. tostring(SEH.status.isAnsuul))
    d("HM бос: " .. tostring(SEH.status.isHMBoss))
    
    -- Показуємо імена босів з GetString
    d("")
    d("Імена босів з GetString:")
    d("  SEH_Yaseyla: '" .. GetString(SEH_Yaseyla) .. "'")
    d("  SEH_Chimera: '" .. GetString(SEH_Chimera) .. "'") 
    d("  SEH_Ansuul: '" .. GetString(SEH_Ansuul) .. "'")
    
    -- Показуємо константи в SEH.data
    if SEH.data then
        d("")
        d("Константи імен босів в SEH.data:")
        d("  yaseylaName: " .. tostring(SEH.data.yaseylaName))
        d("  chimeraName: " .. tostring(SEH.data.chimeraName))
        d("  ansuulName: " .. tostring(SEH.data.ansuulName))
    end
    
    d("==================================")
end

-- Команда для примусового оновлення імен босів (для тестування)
SLASH_COMMANDS["/sehreload"] = function()
    if not SEH or not SEH.data then
        d("❌ SEH.data недоступний!")
        return
    end
    
    d("🔄 Оновлюю імена босів...")
    SEH.data.yaseylaName = string.lower(GetString(SEH_Yaseyla))
    SEH.data.chimeraName = string.lower(GetString(SEH_Chimera))
    SEH.data.ansuulName = string.lower(GetString(SEH_Ansuul))
    
    d("✅ Імена босів оновлені:")
    d("  yaseylaName: '" .. SEH.data.yaseylaName .. "'")
    d("  chimeraName: '" .. SEH.data.chimeraName .. "'")
    d("  ansuulName: '" .. SEH.data.ansuulName .. "'")
end
