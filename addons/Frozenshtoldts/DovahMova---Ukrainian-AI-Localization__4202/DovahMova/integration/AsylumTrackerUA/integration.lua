-- AsylumTracker Integration with DovahMova
-- Файл інтеграції для вирішення конфлікту з українською локалізацією AsylumTracker
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції AsylumTracker
local AsylumTrackerIntegration = {}
AsylumTrackerIntegration.name = "AsylumTrackerUA"
AsylumTrackerIntegration.isInitialized = false
AsylumTrackerIntegration.hasPatched = false

-- Функція ініціалізації інтеграції
function AsylumTrackerIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи AsylumTracker завантажений
    if not AsylumTracker then
        -- Якщо AsylumTracker ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForAsylum", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "AsylumTracker" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForAsylum", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:PatchAsylumTracker()
                end, 50)
            end
        end)
        return false
    end
    
    -- Якщо AsylumTracker уже завантажений, застосовуємо патч
    self:PatchAsylumTracker()
    return true
end

-- Функція патчингу AsylumTracker для підтримки української мови
function AsylumTrackerIntegration:PatchAsylumTracker()
    if not AsylumTracker or self.hasPatched then
        return
    end
    
    local AST = AsylumTracker
    
    -- Створюємо фіктивний український модуль локалізації
    if not AST.lang.ua then
        AST.lang.ua = {}
        AST.lang.ua.LoadStrings = function()
            -- Порожня функція - використовуємо англійські рядки за замовчуванням
            return
        end
    end
    
    -- Простіший підхід: тільки перевизначаємо Initialize з мінімальними змінами
    if AST.Initialize then
        self.originalInitialize = AST.Initialize
        
        AST.Initialize = function()
            -- Викликаємо оригінальну функцію в захищеному режимі
            local success, error = pcall(function()
                -- Спочатку ініціалізуємо saved variables
                AST.savedVars = ZO_SavedVars:NewCharacterIdSettings("AsylumTrackerVars", AST.variableVersion, nil, AST.defaults)
                AST.sv = AsylumTrackerVars["Default"][GetDisplayName()][GetCurrentCharacterId()]
                
                -- Завжди завантажуємо англійські рядки
                if AST.lang.en and AST.lang.en.LoadStrings then
                    AST.lang.en.LoadStrings()
                end
                
                -- Обробляємо інші мови безпечно
                if AST.sv then
                    if not AST.sv.languageOverride then
                        local locale = GetCVar("language.2")
                        if locale ~= "en" and AST.lang[locale] and AST.lang[locale].LoadStrings then
                            pcall(AST.lang[locale].LoadStrings)
                        end
                    else
                        local chosenLocale = AST.sv.chosenLocale
                        if chosenLocale and chosenLocale ~= "en" and AST.lang[chosenLocale] and AST.lang[chosenLocale].LoadStrings then
                            pcall(AST.lang[chosenLocale].LoadStrings)
                        end
                    end
                end
                
                -- Решта ініціалізації з додатковим захистом
                if AST.CreateSettingsWindow then 
                    local settingsSuccess, settingsError = pcall(AST.CreateSettingsWindow)
                    if not settingsSuccess then
                        if d then
                            d("AsylumTracker: Settings window creation failed, but addon continues working: " .. tostring(settingsError))
                        end
                    end
                end
                if AST.RegisterUnitIndexing then AST.RegisterUnitIndexing() end
                if AST.ResetAnchors then AST.ResetAnchors() end
                
                -- Безпечне налаштування UI елементів
                if AST.sv then
                    if AsylumTrackerOlmsHP and AsylumTrackerOlmsHPLabel and AST.SetFontSize then
                        AST.SetFontSize(AsylumTrackerOlmsHP, AsylumTrackerOlmsHPLabel, AST.sv.font_size_olms_hp or 38)
                    end
                    if AsylumTrackerStorm and AsylumTrackerStormLabel and AST.SetFontSize then
                        AST.SetFontSize(AsylumTrackerStorm, AsylumTrackerStormLabel, AST.sv.font_size_storm or 38)
                    end
                    -- Інші UI елементи аналогічно...
                    if AST.sv.sphere_message_toggle then
                        ZO_CreateStringId("AST_NOTIF_PROTECTOR", AST.sv.sphere_message)
                    end
                end
                
                if AST.IndexGroupMembers then AST.IndexGroupMembers() end
                SLASH_COMMANDS["/astracker"] = AST.SlashCommand
            end)
            
            if not success then
                -- Якщо виникла помилка, показуємо повідомлення але не крешимо
                if d then
                    d("AsylumTracker: Initialization error handled by DovahMova: " .. tostring(error))
                end
            end
        end
    end
    
    self.hasPatched = true
    self.isInitialized = true
end

-- Функція перевірки сумісності
function AsylumTrackerIntegration:CheckCompatibility()
    if not AsylumTracker then
        return false, "AsylumTracker не встановлений або не активний"
    end
    
    local AST = AsylumTracker
    if not AST.lang then
        return false, "AsylumTracker.lang не ініціалізований"
    end
    
    if not AST.lang.en then
        return false, "Англійська локалізація AsylumTracker не знайдена"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function AsylumTrackerIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        asylumTrackerLoaded = AsylumTracker ~= nil,
        hasPatched = self.hasPatched,
        currentLocale = GetCVar("language.2")
    }
end

-- Функція відновлення оригінальної функції
function AsylumTrackerIntegration:RestoreOriginalFunction()
    if self.originalInitialize and AsylumTracker then
        AsylumTracker.Initialize = self.originalInitialize
        self.hasPatched = false
    end
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(AsylumTrackerIntegration.name, AsylumTrackerIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[AsylumTrackerIntegration.name] = AsylumTrackerIntegration
    end
    
    -- Логуємо успішну реєстрацію
    if d then
        d("DovahMova: AsylumTracker integration registered successfully")
    end
end

-- Ініціалізуємо інтеграцію
AsylumTrackerIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_AsylumTrackerIntegration"] = AsylumTrackerIntegration

-- Команди для тестування
SLASH_COMMANDS["/asylumtest"] = function()
    local info = AsylumTrackerIntegration:GetInfo()
    d("=== Тест інтеграції AsylumTracker ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("AsylumTracker завантажено: " .. tostring(info.asylumTrackerLoaded))
    d("Патч застосовано: " .. tostring(info.hasPatched))
    d("Поточна локаль: " .. tostring(info.currentLocale))
    d("=====================================")
end

SLASH_COMMANDS["/asylumrestore"] = function()
    AsylumTrackerIntegration:RestoreOriginalFunction()
    d("AsylumTracker integration: Original function restored")
end
