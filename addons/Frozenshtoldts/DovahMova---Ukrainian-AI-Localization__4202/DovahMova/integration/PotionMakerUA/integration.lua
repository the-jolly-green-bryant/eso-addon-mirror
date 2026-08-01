-- PotionMaker Integration with DovahMova
-- Файл інтеграції для підключення української локалізації PotionMaker
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції PotionMaker
local PotionMakerIntegration = {}
PotionMakerIntegration.name = "PotionMakerUA"
PotionMakerIntegration.isInitialized = false

-- Функція ініціалізації інтеграції
function PotionMakerIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи PotionMaker завантажений
    if not PotMaker then
        -- Якщо PotionMaker ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForPotionMaker", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "PotionMaker" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForPotionMaker", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianLocalization()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо PotionMaker уже завантажений, застосовуємо локалізацію
    self:ApplyUkrainianLocalization()
    return true
end

-- Функція застосування української локалізації
function PotionMakerIntegration:ApplyUkrainianLocalization()
    if not PotMaker then
        return
    end
    
    -- Українська локалізація завантажується автоматично через ua.lua файл
    -- який викликає PotMaker:LoadLanguage з українськими перекладами
    
    -- Перевіряємо, чи мова підтримується
    if PotMaker.language and PotMaker.language.name == "ua" then
        PotMaker.languageSupported = true
        
        -- Застосовуємо мовні специфічні налаштування
        if PotMaker.ApplyLanguageSpecific then
            PotMaker:ApplyLanguageSpecific()
        end
        
        self.isInitialized = true
        
        if d then
            d("DovahMova: PotionMaker українізовано успішно")
        end
    else
        if d then
            d("DovahMova: Помилка завантаження української мови для PotionMaker")
        end
    end
end

-- Функція перевірки сумісності
function PotionMakerIntegration:CheckCompatibility()
    if not PotMaker then
        return false, "PotionMaker не встановлений або не активний"
    end
    
    if not PotMaker.language or PotMaker.language.name ~= "ua" then
        return false, "Українська локалізація для PotionMaker не завантажена"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function PotionMakerIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        potionMakerVersion = PotMaker and PotMaker.version or "невідома",
        potionMakerLoaded = PotMaker ~= nil,
        languageSupported = PotMaker and PotMaker.languageSupported or false,
        currentLanguage = PotMaker and PotMaker.language and PotMaker.language.name or "невідома"
    }
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.integrations then
        DovahMova.integrations[PotionMakerIntegration.name] = PotionMakerIntegration
    else
        DovahMova.integrations = {
            [PotionMakerIntegration.name] = PotionMakerIntegration
        }
    end
end

-- Ініціалізуємо інтеграцію
PotionMakerIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_PotionMakerIntegration"] = PotionMakerIntegration

-- Команди для тестування
SLASH_COMMANDS["/potionmakertest"] = function()
    local info = PotionMakerIntegration:GetInfo()
    d("=== Тест інтеграції PotionMaker ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("PotionMaker завантажено: " .. tostring(info.potionMakerLoaded))
    d("Версія PotionMaker: " .. tostring(info.potionMakerVersion))
    d("Мова підтримується: " .. tostring(info.languageSupported))
    d("Поточна мова: " .. tostring(info.currentLanguage))
    d("====================================")
end

SLASH_COMMANDS["/pmtest"] = function()
    SLASH_COMMANDS["/potionmakertest"]()
end

