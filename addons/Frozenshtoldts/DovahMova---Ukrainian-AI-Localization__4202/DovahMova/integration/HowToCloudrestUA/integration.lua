-- HowToCloudrest Integration with DovahMova
-- Файл інтеграції для забезпечення роботи HowToCloudrest з українською локалізацією  
-- Додає підтримку українських імен босів Cloudrest
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції HowToCloudrest
local HowToCloudrestIntegration = {}
HowToCloudrestIntegration.name = "HowToCloudrestUA"
HowToCloudrestIntegration.isInitialized = false
HowToCloudrestIntegration.originalRegisterForAllMiniDeaths = nil
HowToCloudrestIntegration.debugLogging = false

-- Маппінг українських назв босів Cloudrest до англійських
local ukrainianToEnglish = {
    -- Мейн-боси Cloudrest (ВАЖЛИВО: потрібно замінити на правильні українські назви)
    ["сірорія"] = "Siroria",
    ["релеквен"] = "Relequen", 
    ["ґаленве"] = "Galenwe",
    
    -- Сайд-боси (ВАЖЛИВО: потрібно замінити на правильні українські назви)
    ["сілаеда"] = "Silaeda",
    ["беланаріл"] = "Belanaril",
    ["фаларіель"] = "Falarielle",
    
    -- Альтернативні можливі варіанти
    ["сірорія"] = "Siroria",
    ["релеквен"] = "Relequen",
    ["галенве"] = "Galenwe",
    ["сіледа"] = "Silaeda",
    ["беланаріль"] = "Belanaril", 
    ["фалларіель"] = "Falarielle",
}

-- Функція ініціалізації інтеграції
function HowToCloudrestIntegration:Initialize()
    if self.isInitialized then
        return true
    end
    
    -- Перевіряємо, чи HowToCloudrest завантажений
    if not HowToCloudrest then
        -- Якщо HowToCloudrest ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForHTC", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "HowToCloudrest" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForHTC", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianSupport()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо HowToCloudrest уже завантажений, застосовуємо підтримку
    self:ApplyUkrainianSupport()
    return true
end

-- Функція застосування підтримки української мови
function HowToCloudrestIntegration:ApplyUkrainianSupport()
    if not HowToCloudrest then
        return
    end
    
    -- Зберігаємо оригінальну функцію RegisterForAllMiniDeaths
    self.originalRegisterForAllMiniDeaths = HowToCloudrest.RegisterForAllMiniDeaths
    
    -- Створюємо покращену версію функції RegisterForAllMiniDeaths
    HowToCloudrest.RegisterForAllMiniDeaths = function()
        local HTC = HowToCloudrest -- shorthand
        local EM = EVENT_MANAGER
        
        for i = 1, MAX_BOSSES do
            local unitTag = "boss" .. tostring(i)
            if DoesUnitExist(unitTag) then
                local unitName = GetUnitName(unitTag)
                local lowerUnitName = string.lower(unitName)
                
                -- Перевіряємо мейн-боси (англійські та українські назви)
                local isMainBoss = unitName:find("Siroria") or unitName:find("Relequen") or unitName:find("Galenwe")
                
                -- Додаткова перевірка для українських назв
                if not isMainBoss then
                    for ukrainianName, englishName in pairs(ukrainianToEnglish) do
                        if (englishName == "Siroria" or englishName == "Relequen" or englishName == "Galenwe") and
                           string.find(lowerUnitName, ukrainianName) then
                            isMainBoss = true
                            if HowToCloudrestIntegration.debugLogging then
                                d(string.format("[HTC UA] 🔄 Мейн-бос: '%s' → '%s'", unitName, englishName))
                            end
                            break
                        end
                    end
                end
                
                if isMainBoss then
                    if HowToCloudrestIntegration.debugLogging then
                        d("HTC_Debug: Tracking death of " .. unitName)
                    end
                    EM:UnregisterForEvent(HowToCloudrest.name .. "BossDeath" .. i)
                    EM:RegisterForEvent(HowToCloudrest.name .. "BossDeath" .. i, EVENT_UNIT_DEATH_STATE_CHANGED, HowToCloudrest.OnBossDeath)
                    EM:AddFilterForEvent(HowToCloudrest.name .. "BossDeath" .. i, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
                end
                
                -- Перевіряємо сайд-боси (англійські та українські назви)
                local isSideBoss = unitName:find("Silaeda") or unitName:find("Belanaril") or unitName:find("Falarielle")
                
                -- Додаткова перевірка для українських назв
                if not isSideBoss then
                    for ukrainianName, englishName in pairs(ukrainianToEnglish) do
                        if (englishName == "Silaeda" or englishName == "Belanaril" or englishName == "Falarielle") and
                           string.find(lowerUnitName, ukrainianName) then
                            isSideBoss = true
                            if HowToCloudrestIntegration.debugLogging then
                                d(string.format("[HTC UA] 🔄 Сайд-бос: '%s' → '%s'", unitName, englishName))
                            end
                            break
                        end
                    end
                end
                
                if isSideBoss then
                    HTC.isSideBoss = true
                end
            end
        end
        
        if HowToCloudrestIntegration.debugLogging then
            d("HTC_Debug: Fight is sideboss = " .. tostring(HTC.isSideBoss))
        end
    end
    
    self.isInitialized = true
    d("[HowToCloudrest UA] ✅ Інтеграція активована - підтримка українських імен босів Cloudrest")
end

-- Функція відновлення оригінальної функції
function HowToCloudrestIntegration:RestoreOriginalFunction()
    if self.originalRegisterForAllMiniDeaths and HowToCloudrest then
        HowToCloudrest.RegisterForAllMiniDeaths = self.originalRegisterForAllMiniDeaths
        self.isInitialized = false
        d("[HowToCloudrest UA] Інтеграція відключена")
    end
end

-- Функція перевірки сумісності
function HowToCloudrestIntegration:CheckCompatibility()
    if not HowToCloudrest then
        return false, "HowToCloudrest не встановлений або не активний"
    end
    
    if not HowToCloudrest.RegisterForAllMiniDeaths then
        return false, "HowToCloudrest.RegisterForAllMiniDeaths функція не знайдена"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function HowToCloudrestIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        htcVersion = HowToCloudrest and HowToCloudrest.version or "unknown",
        htcLoaded = HowToCloudrest ~= nil,
        currentLocale = GetCVar("language.2"),
        supportedBosses = 6, -- Siroria, Relequen, Galenwe, Silaeda, Belanaril, Falarielle
        integrationType = "Patch RegisterForAllMiniDeaths"
    }
end

-- Функція для включення/відключення детального логування
function HowToCloudrestIntegration:SetDebugLogging(enabled)
    self.debugLogging = enabled
    local status = enabled and "увімкнено" or "вимкнено"
    d(string.format("[HowToCloudrest UA] Детальне логування %s", status))
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(HowToCloudrestIntegration.name, HowToCloudrestIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[HowToCloudrestIntegration.name] = HowToCloudrestIntegration
    end
end

-- Ініціалізуємо інтеграцію
HowToCloudrestIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_HowToCloudrestIntegration"] = HowToCloudrestIntegration

-- ===============================
-- Тестові команди
-- ===============================

-- Команда для тестування інтеграції
SLASH_COMMANDS["/htctest"] = function()
    local info = HowToCloudrestIntegration:GetInfo()
    d("=== Тест інтеграції HowToCloudrest ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("HTC завантажено: " .. tostring(info.htcLoaded))
    d("Версія HTC: " .. tostring(info.htcVersion))
    d("Поточна локалізація: " .. tostring(info.currentLocale))
    d("Підтримувані боси: " .. tostring(info.supportedBosses))
    d("Тип інтеграції: " .. tostring(info.integrationType))
    d("========================================")
end

-- Команда для відновлення оригінальної функції
SLASH_COMMANDS["/htcrestore"] = function()
    HowToCloudrestIntegration:RestoreOriginalFunction()
end

-- Команда для тестування імен босів
SLASH_COMMANDS["/htcbosstest"] = function()
    d("=== Тест імен босів (HTC) ===")
    for i = 1, MAX_BOSSES do
        local unitTag = "boss" .. i
        if DoesUnitExist(unitTag) then
            local unitName = GetUnitName(unitTag)
            local lowerName = string.lower(unitName)
            d(string.format("%s: '%s'", unitTag, unitName))
            
            -- Перевіряємо всі можливі співпадіння
            local matches = {}
            
            -- Англійські назви
            if unitName:find("Siroria") then table.insert(matches, "Siroria (EN)") end
            if unitName:find("Relequen") then table.insert(matches, "Relequen (EN)") end
            if unitName:find("Galenwe") then table.insert(matches, "Galenwe (EN)") end
            if unitName:find("Silaeda") then table.insert(matches, "Silaeda (EN)") end
            if unitName:find("Belanaril") then table.insert(matches, "Belanaril (EN)") end
            if unitName:find("Falarielle") then table.insert(matches, "Falarielle (EN)") end
            
            -- Українські назви
            for ukrainianName, englishName in pairs(ukrainianToEnglish) do
                if string.find(lowerName, ukrainianName) then
                    table.insert(matches, englishName .. " (UA: " .. ukrainianName .. ")")
                end
            end
            
            if #matches > 0 then
                d("  Співпадіння: " .. table.concat(matches, ", "))
            end
        end
    end
    d("============================")
end

-- Команда для включення детального логування
SLASH_COMMANDS["/htcdebug"] = function(args)
    if args == "on" then
        HowToCloudrestIntegration:SetDebugLogging(true)
    elseif args == "off" then
        HowToCloudrestIntegration:SetDebugLogging(false)
    else
        local current = HowToCloudrestIntegration.debugLogging
        HowToCloudrestIntegration:SetDebugLogging(not current)
    end
end

-- Команда для перевірки поточного стану HTC
SLASH_COMMANDS["/htcstatus"] = function()
    if not HowToCloudrest then
        d("❌ HowToCloudrest не завантажений!")
        return
    end
    
    d("=== Статус HowToCloudrest ===")
    d("Назва: " .. tostring(HowToCloudrest.name))
    d("Версія: " .. tostring(HowToCloudrest.version))
    
    if HTC then
        d("isSideBoss: " .. tostring(HTC.isSideBoss))
    end
    
    d("=============================")
end

-- Команда для примусового виклику RegisterForAllMiniDeaths (для тестування)
SLASH_COMMANDS["/htcforce"] = function()
    if not HowToCloudrest or not HowToCloudrest.RegisterForAllMiniDeaths then
        d("❌ HowToCloudrest.RegisterForAllMiniDeaths недоступний!")
        return
    end
    
    d("🔄 Викликаю HowToCloudrest.RegisterForAllMiniDeaths()...")
    HowToCloudrest.RegisterForAllMiniDeaths()
    d("✅ Виконано")
end
