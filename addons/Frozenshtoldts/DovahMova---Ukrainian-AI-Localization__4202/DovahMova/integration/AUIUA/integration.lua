-- AUI Integration with DovahMova
-- Файл інтеграції для підключення української локалізації AUI (Advanced UI)
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції AUI
local AUIIntegration = {}
AUIIntegration.name = "AUIUA"
AUIIntegration.isInitialized = false
AUIIntegration.hasPatched = false
AUIIntegration.originalL10nStrings = {}

-- Функція ініціалізації інтеграції
function AUIIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи AUI завантажений
    if not AUI then
        -- Якщо AUI ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForAUI", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "AUI" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForAUI", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianLocalization()
                end, 500)
            end
        end)
        return false
    end
    
    -- Якщо AUI уже завантажений, застосовуємо локалізацію
    self:ApplyUkrainianLocalization()
    return true
end

-- Функція застосування української локалізації
function AUIIntegration:ApplyUkrainianLocalization()
    if not AUI then
        return false
    end
    
    -- Перевіряємо, чи доступна таблиця з українськими перекладами
    if not AUIUA_Strings then
        return false
    end
    
    -- Перевіряємо, чи AUI.L10n ініціалізований
    if not AUI.L10n then
        -- Спробуємо знову через короткий час
        zo_callLater(function()
            self:ApplyUkrainianLocalization()
        end, 1000)
        return false
    end
    
    -- Оскільки AUI завантажує локалізацію на основі мови, а ua.lua не існує,
    -- створюємо всі необхідні рядки програмно
    self:BackupOriginalStrings()
    
    local appliedCount = 0
    
    -- Застосовуємо всі українські переклади
    for key, ukrainianText in pairs(AUIUA_Strings) do
        -- Створюємо рядок, якщо його немає, або замінюємо існуючий
        AUI.L10n[key] = ukrainianText
        appliedCount = appliedCount + 1
    end
    
    self.hasPatched = true
    self.isInitialized = true
    
    return true
end

-- Функція резервного копіювання оригінальних рядків
function AUIIntegration:BackupOriginalStrings()
    if not AUI or not AUI.L10n then
        return
    end
    
    -- Зберігаємо оригінальні рядки тільки один раз
    if next(self.originalL10nStrings) == nil then
        for key, value in pairs(AUI.L10n) do
            if AUIUA_Strings[key] then
                self.originalL10nStrings[key] = value
            end
        end
    end
end

-- Функція відновлення оригінальних рядків
function AUIIntegration:RestoreOriginalStrings()
    if not AUI or not AUI.L10n then
        return
    end
    
    for key, originalValue in pairs(self.originalL10nStrings) do
        AUI.L10n[key] = originalValue
    end
    
    self.hasPatched = false
end

-- Функція перевірки сумісності
function AUIIntegration:CheckCompatibility()
    if not AUI then
        return false, "AUI не встановлений або не активний"
    end
    
    if not AUIUA_Strings then
        return false, "Українські переклади не завантажені"
    end
    
    if not AUI.L10n then
        return false, "AUI.L10n ще не ініціалізований (можливо, потрібен час для завантаження)"
    end
    
    -- Перевіряємо, чи є хоча б деякі рядки в AUI.L10n (більш м'яка перевірка)
    local foundStrings = 0
    local testKeys = {"general", "preview", "combat", "health", "width", "show", "color"}
    for _, key in ipairs(testKeys) do
        if AUI.L10n[key] then
            foundStrings = foundStrings + 1
        end
    end
    
    if foundStrings == 0 then
        return false, "AUI.L10n порожній або ще не завантажений"
    elseif foundStrings < 3 then
        return false, string.format("AUI.L10n частково завантажений (%d/%d базових рядків)", foundStrings, #testKeys)
    end
    
    return true, string.format("Сумісність підтверджена (%d/%d базових рядків знайдено)", foundStrings, #testKeys)
end

-- Функція отримання статистики перекладу
function AUIIntegration:GetTranslationStats()
    if not AUI or not AUI.L10n or not AUIUA_Strings then
        return {
            total_aui_strings = 0,
            translated_strings = 0,
            translation_coverage = 0
        }
    end
    
    local totalAUIStrings = 0
    local translatedStrings = 0
    
    for key, _ in pairs(AUI.L10n) do
        totalAUIStrings = totalAUIStrings + 1
        if AUIUA_Strings[key] then
            translatedStrings = translatedStrings + 1
        end
    end
    
    local coverage = totalAUIStrings > 0 and (translatedStrings / totalAUIStrings * 100) or 0
    
    return {
        total_aui_strings = totalAUIStrings,
        translated_strings = translatedStrings,
        translation_coverage = math.floor(coverage * 100) / 100 -- округлюємо до 2 знаків після коми
    }
end

-- Функція отримання інформації про інтеграцію
function AUIIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    local stats = self:GetTranslationStats()
    
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        auiVersion = AUI and AUI.version or "невідома",
        auiLoaded = AUI ~= nil,
        translationsLoaded = AUIUA_Strings ~= nil,
        hasPatched = self.hasPatched,
        currentLocale = GetCVar("language.2"),
        translationStats = stats
    }
end

-- Функція для динамічного додавання нових перекладів
function AUIIntegration:AddTranslation(key, ukrainianText)
    if not key or not ukrainianText then
        return false
    end
    
    -- Додаємо до таблиці перекладів
    if AUIUA_Strings then
        AUIUA_Strings[key] = ukrainianText
    end
    
    -- Якщо AUI доступний і інтеграція активна, застосовуємо переклад відразу
    if AUI and AUI.L10n and self.hasPatched then
        -- Зберігаємо оригінальний рядок якщо ще не збережено
        if AUI.L10n[key] and not self.originalL10nStrings[key] then
            self.originalL10nStrings[key] = AUI.L10n[key]
        end
        
        AUI.L10n[key] = ukrainianText
        return true
    end
    
    return false
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(AUIIntegration.name, AUIIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[AUIIntegration.name] = AUIIntegration
    end
end

-- Ініціалізуємо інтеграцію
AUIIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_AUIIntegration"] = AUIIntegration

-- Команди для тестування інтеграції
SLASH_COMMANDS["/auitest"] = function()
    local info = AUIIntegration:GetInfo()
    d("=== Тест інтеграції AUI ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("Версія AUI: " .. tostring(info.auiVersion))
    d("AUI завантажено: " .. tostring(info.auiLoaded))
    d("Переклади завантажено: " .. tostring(info.translationsLoaded))
    d("Патч застосовано: " .. tostring(info.hasPatched))
    d("Поточна локаль: " .. tostring(info.currentLocale))
    
    local stats = info.translationStats
    if stats then
        d("=== Статистика перекладів ===")
        d("Загальна кількість рядків AUI: " .. tostring(stats.total_aui_strings))
        d("Перекладених рядків: " .. tostring(stats.translated_strings))
        d("Покриття перекладу: " .. tostring(stats.translation_coverage) .. "%")
    end
    d("==========================")
end

SLASH_COMMANDS["/auirestore"] = function()
    AUIIntegration:RestoreOriginalStrings()
end

SLASH_COMMANDS["/auiapply"] = function()
    AUIIntegration:ApplyUkrainianLocalization()
end

-- Команда для тестування конкретних рядків
SLASH_COMMANDS["/auiteststring"] = function(args)
    if not args or args == "" then
        d("Використання: /auiteststring <ключ>")
        d("Приклад: /auiteststring general")
        return
    end
    
    d("=== Тест рядка AUI ===")
    d("Ключ: '" .. args .. "'")
    
    if AUI and AUI.L10n then
        local currentValue = AUI.L10n[args]
        d("Поточне значення: '" .. tostring(currentValue) .. "'")
        
        if AUIIntegration.originalL10nStrings[args] then
            d("Оригінальне значення: '" .. tostring(AUIIntegration.originalL10nStrings[args]) .. "'")
        else
            d("Оригінальне значення: не збережено")
        end
        
        if AUIUA_Strings and AUIUA_Strings[args] then
            d("Український переклад: '" .. tostring(AUIUA_Strings[args]) .. "'")
        else
            d("Український переклад: не знайдено")
        end
    else
        d("AUI.L10n недоступний")
    end
    d("====================")
end

-- Команда для додавання нового перекладу
SLASH_COMMANDS["/auiaddtranslation"] = function(args)
    if not args or args == "" then
        d("Використання: /auiaddtranslation <ключ> <переклад>")
        d("Приклад: /auiaddtranslation test_key Тестовий переклад")
        return
    end
    
    local key, translation = string.match(args, "^(%S+)%s+(.+)$")
    if not key or not translation then
        d("Неправильний формат. Використання: /auiaddtranslation <ключ> <переклад>")
        return
    end
    
    local success = AUIIntegration:AddTranslation(key, translation)
    if success then
        d(string.format("Переклад додано: '%s' = '%s'", key, translation))
    else
        d("Не вдалося додати переклад. Перевірте, чи AUI завантажений і інтеграція активна.")
    end
end

-- Команда для швидкої статистики
SLASH_COMMANDS["/auistats"] = function()
    local stats = AUIIntegration:GetTranslationStats()
    d("=== AUI Translation Statistics ===")
    d(string.format("📊 Переклади: %d/%d (%.1f%% покриття)", 
        stats.translated_strings, 
        stats.total_aui_strings, 
        stats.translation_coverage))
    
    if stats.translation_coverage >= 100 then
        d("✅ ПОВНА ЛОКАЛІЗАЦІЯ ДОСЯГНУТА!")
    elseif stats.translation_coverage >= 90 then
        d("🟢 Майже повна локалізація")
    elseif stats.translation_coverage >= 75 then
        d("🟡 Хороша локалізація")
    else
        d("🔴 Часткова локалізація")
    end
    d("================================")
end

-- Команда для діагностики проблем
SLASH_COMMANDS["/auidiagnose"] = function()
    d("=== AUI Integration Diagnostic ===")
    
    -- Перевіряємо базові компоненти
    d("🔍 Базові компоненти:")
    d("  AUI завантажений: " .. tostring(AUI ~= nil))
    d("  AUI.L10n існує: " .. tostring(AUI and AUI.L10n ~= nil))
    d("  AUIUA_Strings завантажені: " .. tostring(AUIUA_Strings ~= nil))
    
    if AUI and AUI.L10n then
        -- Перевіряємо кількість рядків в AUI.L10n
        local auiStringsCount = 0
        for _ in pairs(AUI.L10n) do
            auiStringsCount = auiStringsCount + 1
        end
        d("  Кількість рядків в AUI.L10n: " .. auiStringsCount)
        
        -- Перевіряємо наявність тестових ключів
        d("🧪 Тестові ключі в AUI.L10n:")
        local testKeys = {"general", "preview", "combat", "health", "width", "show", "color", "aui"}
        for _, key in ipairs(testKeys) do
            local exists = AUI.L10n[key] ~= nil
            local value = exists and ("'" .. tostring(AUI.L10n[key]) .. "'") or "відсутній"
            d(string.format("  '%s': %s %s", key, exists and "✅" or "❌", value))
        end
    end
    
    if AUIUA_Strings then
        local ukrainianStringsCount = 0
        for _ in pairs(AUIUA_Strings) do
            ukrainianStringsCount = ukrainianStringsCount + 1
        end
        d("  Кількість українських перекладів: " .. ukrainianStringsCount)
    end
    
    -- Статус інтеграції
    local info = AUIIntegration:GetInfo()
    d("🔧 Статус інтеграції:")
    d("  Ініціалізована: " .. tostring(info.initialized))
    d("  Патч застосовано: " .. tostring(info.hasPatched))
    d("  Сумісна: " .. tostring(info.compatible))
    d("  Повідомлення: " .. tostring(info.message))
    
    d("===============================")
    
    -- Рекомендації
    if not info.compatible then
        d("💡 Рекомендації:")
        if not AUI then
            d("  • Переконайтеся, що AUI встановлений і активований")
        elseif not AUI.L10n then
            d("  • AUI ще завантажується, спробуйте через кілька секунд")
            d("  • Використайте /auiapply для повторної спроби")
        else
            d("  • Спробуйте /auiapply для ручного застосування перекладів")
            d("  • Можливо, потрібен /reloadui для повного перезавантаження")
        end
    end
end

