-- Dustman Integration with DovahMova
-- Файл інтеграції для підключення української локалізації Dustman
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська (як у інших інтеграціях)
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції Dustman
local DustmanIntegration = {}
DustmanIntegration.name = "DustmanUA"
DustmanIntegration.isInitialized = false
DustmanIntegration.originalGetString = nil

-- Функція ініціалізації інтеграції
function DustmanIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи Dustman завантажений
    if not Dustman then
        -- Якщо Dustman ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForDustman", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "Dustman" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForDustman", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianLocalization()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо Dustman уже завантажений, застосовуємо локалізацію
    self:ApplyUkrainianLocalization()
    return true
end

-- Функція застосування української локалізації
function DustmanIntegration:ApplyUkrainianLocalization()
    if not Dustman then
        return
    end
    
    -- Завантажуємо українські переклади
    if not DustmanUA_Strings then
        return
    end
    
    -- Застосовуємо всі рядки Dustman використовуючи той же підхід, що і оригінальна локалізація
    for stringId, ukrainianText in pairs(DustmanUA_Strings) do
        ZO_CreateStringId(stringId, ukrainianText)
        SafeAddVersion(stringId, 1)
    end
    
    -- Позначаємо, що інтеграція ініціалізована
    self.isInitialized = true
    
    -- Переклади будуть застосовані автоматично через ZO_CreateStringId
    -- Немає потреби в ручному оновленні панелі LAM
end

-- Функція перевірки сумісності
function DustmanIntegration:CheckCompatibility()
    if not Dustman then
        return false, "Dustman не встановлений або не активний"
    end
    
    if not DustmanUA_Strings then
        return false, "Українські переклади для Dustman не завантажені"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function DustmanIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        dustmanVersion = "10.9.1",
        dustmanLoaded = Dustman ~= nil,
        translationsLoaded = DustmanUA_Strings ~= nil
    }
end

-- Функція відновлення оригінальних рядків (для відлагодження)
function DustmanIntegration:RestoreOriginalStrings()
    -- Неможливо відновити рядки, встановлені через ZO_CreateStringId
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.integrations then
        DovahMova.integrations[DustmanIntegration.name] = DustmanIntegration
    else
        DovahMova.integrations = {
            [DustmanIntegration.name] = DustmanIntegration
        }
    end
end

-- Ініціалізуємо інтеграцію
DustmanIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_DustmanIntegration"] = DustmanIntegration

-- Команди для тестування
SLASH_COMMANDS["/dustmantest"] = function()
    local info = DustmanIntegration:GetInfo()
    d("=== Тест інтеграції Dustman ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("Dustman завантажено: " .. tostring(info.dustmanLoaded))
    d("Переклади завантажено: " .. tostring(info.translationsLoaded))
    d("===============================")
end

SLASH_COMMANDS["/dustmanrestore"] = function()
    DustmanIntegration:RestoreOriginalStrings()
end
