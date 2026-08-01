-- QcellRockgroveHelper Integration with DovahMova
-- Файл інтеграції для забезпечення роботи QcellRockgroveHelper з українською локалізацією
-- Додає підтримку українських імен босів Rockgrove без глобального патчингу
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції QcellRockgroveHelper
local QcellRockgroveHelperIntegration = {}
QcellRockgroveHelperIntegration.name = "QcellRockgroveHelperUA"
QcellRockgroveHelperIntegration.isInitialized = false
QcellRockgroveHelperIntegration.originalBossesChanged = nil
QcellRockgroveHelperIntegration.debugLogging = false

-- Функція ініціалізації інтеграції
function QcellRockgroveHelperIntegration:Initialize()
    if self.isInitialized then
        return true
    end
    
    -- Перевіряємо, чи QcellRockgroveHelper завантажений
    if not QRH then
        -- Якщо QcellRockgroveHelper ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForQRH", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "QcellRockgroveHelper" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForQRH", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianSupport()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо QcellRockgroveHelper уже завантажений, застосовуємо підтримку
    self:ApplyUkrainianSupport()
    return true
end

-- Функція застосування підтримки української мови
function QcellRockgroveHelperIntegration:ApplyUkrainianSupport()
    if not QRH then
        return
    end
    
    -- Додаємо українські константи для імен босів у QRH.data
    if QRH.data then
        QRH.data.oaxiltso_name_ua = string.lower("Оаксілтсо")
        QRH.data.bahsei_name_ua = string.lower("Вісниця Полум'я Бахсей") 
        QRH.data.xalvakka_name_ua = string.lower("Ксалвакка")
        QRH.data.xalvakka_volatile_shell_name_ua = string.lower("Нестабільна Оболонка")
        
        -- Альтернативні варіанти на випадок різних перекладів
        QRH.data.bahsei_name_ua_alt = string.lower("Вісниця Полум'я Бахсей")
        QRH.data.xalvakka_name_ua_alt = string.lower("Ксалвакк'а")
    end
    
    -- Зберігаємо оригінальну функцію BossesChanged
    self.originalBossesChanged = QRH.BossesChanged
    
    -- Створюємо покращену версію функції BossesChanged
    QRH.BossesChanged = function()
        local bossName = string.lower(GetUnitName("boss1"))
        QRH.status.currentBoss = bossName
        
        QRH.status.is_oaxiltso = false
        QRH.status.is_bahsei = false
        QRH.status.is_xalvakka = false
        QRH.status.is_hm_boss = false
        
        -- Перевіряємо Oaxiltso (англійська та українська назви)
        if string.match(bossName, QRH.data.oaxiltso_name) or 
           (QRH.data.oaxiltso_name_ua and string.match(bossName, QRH.data.oaxiltso_name_ua)) then
            QRH.status.is_oaxiltso = true
        end
        
        -- Перевіряємо Bahsei (англійська та українська назви)
        if string.match(bossName, QRH.data.bahsei_name) or 
           (QRH.data.bahsei_name_ua and string.match(bossName, QRH.data.bahsei_name_ua)) or
           (QRH.data.bahsei_name_ua_alt and string.match(bossName, QRH.data.bahsei_name_ua_alt)) then
            QRH.status.is_bahsei = true
        end
        
        -- Перевіряємо Xalvakka (англійська та українська назви)
        if string.match(bossName, QRH.data.xalvakka_name) or 
           (QRH.data.xalvakka_name_ua and string.match(bossName, QRH.data.xalvakka_name_ua)) or
           (QRH.data.xalvakka_name_ua_alt and string.match(bossName, QRH.data.xalvakka_name_ua_alt)) then
            QRH.status.is_xalvakka = true
        end
        
        -- Визначаємо чи це HM на основі HP боса
        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
        if maxTargetHP > 100000000 then
            QRH.status.is_hm_boss = true
        else
            QRH.status.is_hm_boss = false
        end
        
        -- Логування для дебагу
        if self.debugLogging then
            d(string.format("[QRH UA] 🔍 Бос: '%s'", bossName))
            d(string.format("  Oaxiltso: %s", tostring(QRH.status.is_oaxiltso)))
            d(string.format("  Bahsei: %s", tostring(QRH.status.is_bahsei)))
            d(string.format("  Xalvakka: %s", tostring(QRH.status.is_xalvakka)))
            d(string.format("  HM: %s", tostring(QRH.status.is_hm_boss)))
        end
    end
    
    -- Також потрібно модифікувати функцію UpdateShield для Volatile Shell
    if QRH.UpdateShield then
        local originalUpdateShield = QRH.UpdateShield
        QRH.UpdateShield = function(unitTag, value, maxValue)
            -- Спочатку викликаємо оригінальну функцію для забезпечення коректної роботи
            originalUpdateShield(unitTag, value, maxValue)
            
            -- Додаємо підтримку української назви Volatile Shell
            if unitTag == "reticleover" then
                local unitName = string.lower(GetUnitName(unitTag))
                
                -- Перевіряємо як англійську так і українську назву Volatile Shell
                if string.match(unitName, QRH.data.xalvakka_volatile_shell_name) or
                   (QRH.data.xalvakka_volatile_shell_name_ua and string.match(unitName, QRH.data.xalvakka_volatile_shell_name_ua)) then
                    QRH.status.shellShield = value
                end
            end
        end
    end
    
    self.isInitialized = true
    d("[QcellRockgroveHelper UA] ✅ Інтеграція активована - підтримка українських імен босів")
end

-- Функція відновлення оригінальних функцій
function QcellRockgroveHelperIntegration:RestoreOriginalFunctions()
    if self.originalBossesChanged and QRH then
        QRH.BossesChanged = self.originalBossesChanged
        self.isInitialized = false
        d("[QcellRockgroveHelper UA] Інтеграція відключена")
    end
end

-- Функція перевірки сумісності
function QcellRockgroveHelperIntegration:CheckCompatibility()
    if not QRH then
        return false, "QcellRockgroveHelper не встановлений або не активний"
    end
    
    if not QRH.data then
        return false, "QRH.data не ініціалізований"
    end
    
    if not QRH.BossesChanged then
        return false, "QRH.BossesChanged функція не знайдена"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function QcellRockgroveHelperIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        qrhVersion = QRH and QRH.version or "unknown",
        qrhLoaded = QRH ~= nil,
        currentLocale = GetCVar("language.2"),
        supportedBosses = 3 -- Oaxiltso, Bahsei, Xalvakka
    }
end

-- Функція для включення/відключення детального логування
function QcellRockgroveHelperIntegration:SetDebugLogging(enabled)
    self.debugLogging = enabled
    local status = enabled and "увімкнено" or "вимкнено"
    d(string.format("[QcellRockgroveHelper UA] Детальне логування %s", status))
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(QcellRockgroveHelperIntegration.name, QcellRockgroveHelperIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[QcellRockgroveHelperIntegration.name] = QcellRockgroveHelperIntegration
    end
end

-- Ініціалізуємо інтеграцію
QcellRockgroveHelperIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_QcellRockgroveHelperIntegration"] = QcellRockgroveHelperIntegration

-- ===============================
-- Тестові команди
-- ===============================

-- Команда для тестування інтеграції
SLASH_COMMANDS["/qrhtest"] = function()
    local info = QcellRockgroveHelperIntegration:GetInfo()
    d("=== Тест інтеграції QcellRockgroveHelper ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("QRH завантажено: " .. tostring(info.qrhLoaded))
    d("Версія QRH: " .. tostring(info.qrhVersion))
    d("Поточна локалізація: " .. tostring(info.currentLocale))
    d("Підтримувані боси: " .. tostring(info.supportedBosses))
    d("==========================================")
end

-- Команда для відновлення оригінальних функцій
SLASH_COMMANDS["/qrhrestore"] = function()
    QcellRockgroveHelperIntegration:RestoreOriginalFunctions()
end

-- Команда для тестування імен босів
SLASH_COMMANDS["/qrhbosstest"] = function()
    d("=== Тест імен босів (QRH) ===")
    for i = 1, 12 do
        local bossTag = "boss" .. i
        local bossName = GetUnitName(bossTag)
        if bossName and bossName ~= "" then
            local lowerName = string.lower(bossName)
            d(string.format("%s: '%s'", bossTag, bossName))
            
            if QRH and QRH.data then
                -- Перевіряємо всі можливі співпадіння
                local matches = {}
                if string.match(lowerName, QRH.data.oaxiltso_name) then table.insert(matches, "Oaxiltso (EN)") end
                if QRH.data.oaxiltso_name_ua and string.match(lowerName, QRH.data.oaxiltso_name_ua) then table.insert(matches, "Oaxiltso (UA)") end
                if string.match(lowerName, QRH.data.bahsei_name) then table.insert(matches, "Bahsei (EN)") end
                if QRH.data.bahsei_name_ua and string.match(lowerName, QRH.data.bahsei_name_ua) then table.insert(matches, "Bahsei (UA)") end
                if string.match(lowerName, QRH.data.xalvakka_name) then table.insert(matches, "Xalvakka (EN)") end
                if QRH.data.xalvakka_name_ua and string.match(lowerName, QRH.data.xalvakka_name_ua) then table.insert(matches, "Xalvakka (UA)") end
                
                if #matches > 0 then
                    d("  Співпадіння: " .. table.concat(matches, ", "))
                end
            end
        end
    end
    d("============================")
end

-- Команда для включення детального логування
SLASH_COMMANDS["/qrhdebug"] = function(args)
    if args == "on" then
        QcellRockgroveHelperIntegration:SetDebugLogging(true)
    elseif args == "off" then
        QcellRockgroveHelperIntegration:SetDebugLogging(false)
    else
        local current = QcellRockgroveHelperIntegration.debugLogging
        QcellRockgroveHelperIntegration:SetDebugLogging(not current)
    end
end

-- Команда для перевірки поточного стану QRH
SLASH_COMMANDS["/qrhstatus"] = function()
    if not QRH then
        d("❌ QcellRockgroveHelper не завантажений!")
        return
    end
    
    d("=== Статус QcellRockgroveHelper ===")
    d("Активний: " .. tostring(QRH.active))
    d("В бою: " .. tostring(QRH.status.inCombat))
    d("Поточний бос: " .. tostring(QRH.status.currentBoss))
    d("Oaxiltso: " .. tostring(QRH.status.is_oaxiltso))
    d("Bahsei: " .. tostring(QRH.status.is_bahsei))
    d("Xalvakka: " .. tostring(QRH.status.is_xalvakka))
    d("HM бос: " .. tostring(QRH.status.is_hm_boss))
    
    -- Показуємо доступні константи
    if QRH.data then
        d("")
        d("Константи імен босів:")
        d("  oaxiltso_name: " .. tostring(QRH.data.oaxiltso_name))
        d("  oaxiltso_name_ua: " .. tostring(QRH.data.oaxiltso_name_ua))
        d("  bahsei_name: " .. tostring(QRH.data.bahsei_name))
        d("  bahsei_name_ua: " .. tostring(QRH.data.bahsei_name_ua))
        d("  xalvakka_name: " .. tostring(QRH.data.xalvakka_name))
        d("  xalvakka_name_ua: " .. tostring(QRH.data.xalvakka_name_ua))
    end
    
    d("==================================")
end

-- Команда для примусового виклику BossesChanged (для тестування)
SLASH_COMMANDS["/qrhforce"] = function()
    if not QRH or not QRH.BossesChanged then
        d("❌ QRH.BossesChanged недоступний!")
        return
    end
    
    d("🔄 Викликаю QRH.BossesChanged()...")
    QRH.BossesChanged()
    d("✅ Виконано")
end