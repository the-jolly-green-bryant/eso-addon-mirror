-- HarvestMap Integration with DovahMova
-- Файл інтеграції для підключення української локалізації HarvestMap
-- Автор: DovahMova Team

-- Перевіряємо, чи DovahMova завантажений
if not DovahMova then
    return
end

-- Перевіряємо, чи поточна мова - українська
if DovahMova:GetLanguage() ~= "ua" then
    return
end

-- Не перевіряємо IsAddonRunning тут, бо HarvestMap може завантажуватися пізніше

-- Створюємо модуль інтеграції HarvestMap
local HarvestMapIntegration = {}
HarvestMapIntegration.name = "HarvestMapUA"
HarvestMapIntegration.isInitialized = false

-- Функція ініціалізації інтеграції
function HarvestMapIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи HarvestMap завантажений
    if not Harvest then
        -- Якщо HarvestMap ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForHarvest", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "HarvestMap" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForHarvest", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianLocalization()
                end, 100)
            end
        end)
        return
    end
    
    -- Якщо HarvestMap уже завантажений, застосовуємо локалізацію
    self:ApplyUkrainianLocalization()
end

-- Функція застосування української локалізації
function HarvestMapIntegration:ApplyUkrainianLocalization()
    if not Harvest then
        return
    end
    
    -- Форсовано застосовуємо українську локалізацію
    if Harvest.localizedStrings then
        -- Перезаписуємо функцію GetLocalization для форсованого використання української локалізації
        local originalGetLocalization = Harvest.GetLocalization
        Harvest.GetLocalization = function(tag)
            if Harvest.localizedStrings and Harvest.localizedStrings[tag] then
                return Harvest.localizedStrings[tag]
            end
            return originalGetLocalization(tag)
        end
        
        -- Оновлюємо UI рядки
        local UIStrings = {
            "SI_BINDING_NAME_HARVEST_SHOW_FILTER", 
            "SI_BINDING_NAME_SKIP_TARGET", 
            "SI_BINDING_NAME_TOGGLE_WORLDPINS", 
            "SI_BINDING_NAME_TOGGLE_MAPPINS", 
            "SI_BINDING_NAME_TOGGLE_MINIMAPPINS", 
            "SI_BINDING_NAME_HARVEST_SHOW_PANEL",
            "HARVESTFARM_GENERATOR",
            "HARVESTFARM_EDITOR",
            "HARVESTFARM_SAVE"
        }
        
        for _, str in pairs(UIStrings) do
            if Harvest.localizedStrings[str] then
                ZO_CreateStringId(str, Harvest.localizedStrings[str])
            end
        end
    end
    
    -- Позначаємо, що інтеграція ініціалізована
    self.isInitialized = true
    
    -- Повідомляємо про успішну інтеграцію
    if d then
        d("DovahMova: Інтеграція з HarvestMap успішно активована!")
    end
    
    -- Якщо HarvestMap має панель налаштувань LAM, оновлюємо її
    if Harvest.optionsPanel and CALLBACK_MANAGER then
        zo_callLater(function()
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", Harvest.optionsPanel)
        end, 500)
    end
end

-- Функція перевірки сумісності
function HarvestMapIntegration:CheckCompatibility()
    if not Harvest then
        return false, "HarvestMap не встановлений або не активний"
    end
    
    if not Harvest.GetLocalization then
        return false, "Версія HarvestMap не підтримує локалізацію"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function HarvestMapIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        harvestMapVersion = Harvest and Harvest.displayVersion or "Невідома",
        harvestMapLoaded = Harvest ~= nil
    }
end

-- Реєструємо інтеграцію в DovahMova
if DovahMova.integrations then
    DovahMova.integrations[HarvestMapIntegration.name] = HarvestMapIntegration
else
    DovahMova.integrations = {
        [HarvestMapIntegration.name] = HarvestMapIntegration
    }
end

-- Ініціалізуємо інтеграцію
HarvestMapIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_HarvestMapIntegration"] = HarvestMapIntegration
