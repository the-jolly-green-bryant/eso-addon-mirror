-- vAS Helper Integration with DovahMova
-- Файл інтеграції для підключення української локалізації vAS Helper
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції vAS Helper
local vASHelperIntegration = {}
vASHelperIntegration.name = "vASHelperUA"
vASHelperIntegration.isInitialized = false
vASHelperIntegration.hasPatched = false
vASHelperIntegration.menuPatched = false

-- Функція ініціалізації інтеграції
function vASHelperIntegration:Initialize()
    if self.isInitialized then
        return
    end
    
    -- Перевіряємо, чи vASHelper завантажений
    if not vASHelper then
        -- Якщо vASHelper ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForvASHelper", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "vASHelper" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForvASHelper", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianLocalization()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо vASHelper уже завантажений, застосовуємо локалізацію
    self:ApplyUkrainianLocalization()
    return true
end

-- Функція застосування української локалізації
function vASHelperIntegration:ApplyUkrainianLocalization()
    if not vASHelper then
        return
    end
    
    -- Додаємо українське ім'я боса до списку
    if vASHelper.bossNames then
        vASHelper.bossNames["святий олмс справедливий"] = true  -- Ukrainian boss name
        vASHelper.bossNames["олмс справедливий"] = true          -- Alternative variant
        vASHelper.bossNames["св. олмс справедливий"] = true      -- Alternative variant
        
    end
    
    -- Застосовуємо українські переклади
    self:LocalizeMenuStrings()
    
    -- Патчимо функцію setup меню тільки якщо вона ще не була викликана
    if vASHelper.setupMenu and not self.menuPatched then
        self.originalSetupMenu = vASHelper.setupMenu
        vASHelper.setupMenu = function()
            -- Викликаємо оригінальну функцію
            self.originalSetupMenu()
            
            -- Застосовуємо українські переклади після створення меню
            zo_callLater(function()
                self:LocalizeMenuStrings()
            end, 100)
        end
        self.menuPatched = true
    end
    
    -- Локалізуємо UI елементи
    self:LocalizeUIElements()
    
    self.isInitialized = true
    self.hasPatched = true
end

-- Функція локалізації рядків меню
function vASHelperIntegration:LocalizeMenuStrings()
    -- Завантажуємо українські переклади
    if not vASHelperUA_Strings then
        return
    end
    
    -- Застосовуємо всі рядки через ZO_CreateStringId
    for stringId, ukrainianText in pairs(vASHelperUA_Strings) do
        ZO_CreateStringId(stringId, ukrainianText)
        SafeAddVersion(stringId, 1)
    end
end

-- Функція локалізації UI елементів
function vASHelperIntegration:LocalizeUIElements()
    -- Локалізуємо текст "PURGE" в XML елементах
    zo_callLater(function()
        if vASHelperFrame then
            if vASHelperFrameLeftTop then
                vASHelperFrameLeftTop:SetText("ОЧИЩЕННЯ")
            end
            if vASHelperFrameLeftBottom then
                vASHelperFrameLeftBottom:SetText("ОЧИЩЕННЯ")
            end
            if vASHelperFrameRightTop then
                vASHelperFrameRightTop:SetText("ОЧИЩЕННЯ")
            end
            if vASHelperFrameRightBottom then
                vASHelperFrameRightBottom:SetText("ОЧИЩЕННЯ")
            end
        end
    end, 500)
end

-- Функція перевірки сумісності
function vASHelperIntegration:CheckCompatibility()
    if not vASHelper then
        return false, "vAS Helper не встановлений або не активний"
    end
    
    if not vASHelper.bossNames then
        return false, "vASHelper.bossNames не ініціалізований"
    end
    
    if not vASHelper.setupMenu then
        return false, "vASHelper.setupMenu не знайдений"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function vASHelperIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        vASHelperVersion = vASHelper and vASHelper.version or "unknown",
        vASHelperLoaded = vASHelper ~= nil,
        translationsLoaded = vASHelperUA_Strings ~= nil,
        hasPatched = self.hasPatched,
        currentLocale = GetCVar("language.2")
    }
end

-- Функція відновлення оригінальних функцій
function vASHelperIntegration:RestoreOriginalFunctions()
    if self.originalSetupMenu and vASHelper then
        vASHelper.setupMenu = self.originalSetupMenu
        self.hasPatched = false
    end
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(vASHelperIntegration.name, vASHelperIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[vASHelperIntegration.name] = vASHelperIntegration
    end
    
end

-- Ініціалізуємо інтеграцію
vASHelperIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_vASHelperIntegration"] = vASHelperIntegration

-- Команди для тестування інтеграції
SLASH_COMMANDS["/vashelperdebug"] = function()
    if not vASHelper then
        d("vASHelper не завантажений!")
        return
    end
    
    d("=== vASHelper Debug Info ===")
    local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")
    d("Зона гравця: " .. tostring(playerWorldZone))
    d("Позиція: " .. tostring(playerWorldX) .. ", " .. tostring(playerWorldY) .. ", " .. tostring(playerWorldZ))
    
    if vASHelper.bossNames then
        d("Імена босів:")
        for name, enabled in pairs(vASHelper.bossNames) do
            d("  '" .. name .. "' = " .. tostring(enabled))
        end
    end
    
    local bossName = GetUnitName("boss1")
    if bossName and bossName ~= "" then
        d("Поточний бос: '" .. bossName .. "' (нижній регістр: '" .. string.lower(bossName) .. "')")
        d("Бос розпізнаний: " .. tostring(vASHelper.bossNames[string.lower(bossName)] or false))
    else
        d("Немає активного боса")
    end
    
    d("Налаштування іконок:")
    if vASHelper.savedVars then
        for setting, value in pairs(vASHelper.savedVars) do
            if string.find(setting, "display") then
                d("  " .. setting .. " = " .. tostring(value))
            end
        end
    end
    d("========================")
end

-- Команда для примусового показу іконок
SLASH_COMMANDS["/vashelperforce"] = function()
    if not vASHelper then
        d("vASHelper не завантажений!")
        return
    end
    
    d("Примусовий показ усіх іконок vASHelper...")
    
    -- Показуємо всі типи іконок
    if vASHelper.showLanes then vASHelper.showLanes() end
    if vASHelper.showHeals then vASHelper.showHeals() end
    if vASHelper.showMTIcons then vASHelper.showMTIcons() end
    if vASHelper.showOlmsJumpBorders then vASHelper.showOlmsJumpBorders() end
    
    d("Іконки показані (якщо функції доступні)")
end

-- Команда для приховання іконок
SLASH_COMMANDS["/vashelperhide"] = function()
    if not vASHelper then
        d("vASHelper не завантажений!")
        return
    end
    
    d("Приховання усіх іконок vASHelper...")
    if vASHelper.hideAllIcons then
        vASHelper.hideAllIcons()
    end
    d("Іконки приховані")
end
