-- vAS Helper Ukrainian Support Utilities
-- Утиліти підтримки української мови для vAS Helper  
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Модуль утиліт для vAS Helper UA
local vASHelperUA = {}
vASHelperUA.name = "vASHelperUA_Utils"

-- Функція для патчингу текстових елементів UI
function vASHelperUA.PatchUIText()
    -- Патч для XML елементів з текстом "PURGE"
    local purgeElements = {
        "vASHelperFrameLeftTop",
        "vASHelperFrameLeftBottom",
        "vASHelperFrameRightTop", 
        "vASHelperFrameRightBottom"
    }
    
    for _, elementName in ipairs(purgeElements) do
        local element = _G[elementName]
        if element and element.SetText then
            element:SetText("ОЧИЩЕННЯ")
        end
    end
end

-- Функція для додавання українських імен босів
function vASHelperUA.AddUkrainianBossNames()
    if not vASHelper or not vASHelper.bossNames then
        return
    end
    
    -- Додаємо українські назви босів
    vASHelper.bossNames["святий олмс справедливий"] = true
    
    -- Можливо, додамо інші варіанти написання
    vASHelper.bossNames["олмс справедливий"] = true
    vASHelper.bossNames["св. олмс справедливий"] = true
end

-- Функція для додаткової ініціалізації
function vASHelperUA.Initialize()
    -- Додаємо українські імена босів
    vASHelperUA.AddUkrainianBossNames()
    
    -- Затримка для патчингу UI після завантаження
    zo_callLater(function()
        vASHelperUA.PatchUIText()
    end, 1000)
    
    -- Додаткова затримка на випадок пізнього завантаження UI
    zo_callLater(function()
        vASHelperUA.PatchUIText()
    end, 3000)
end

-- Функція для перевірки стану локалізації
function vASHelperUA.CheckLocalizationStatus()
    local status = {
        bossNamesPatched = false,
        uiElementsPatched = false,
        stringsLoaded = vASHelperUA_Strings ~= nil
    }
    
    -- Перевіряємо імена босів
    if vASHelper and vASHelper.bossNames and vASHelper.bossNames["святий олмс справедливий"] then
        status.bossNamesPatched = true
    end
    
    -- Перевіряємо UI елементи
    local element = _G["vASHelperFrameLeftTop"]
    if element and element:GetText() == "ОЧИЩЕННЯ" then
        status.uiElementsPatched = true
    end
    
    return status
end

-- Команда для перевірки статусу локалізації
SLASH_COMMANDS["/vashelperua"] = function()
    local status = vASHelperUA.CheckLocalizationStatus()
    
    d("=== Статус локалізації vAS Helper ===")
    d("Українські імена босів: " .. (status.bossNamesPatched and "✓" or "✗"))
    d("UI елементи патчені: " .. (status.uiElementsPatched and "✓" or "✗"))
    d("Рядки завантажені: " .. (status.stringsLoaded and "✓" or "✗"))
    d("====================================")
    
    if not status.bossNamesPatched or not status.uiElementsPatched then
        d("Спробуйте команду /vashelperua_fix для виправлення")
    end
end

-- Команда для примусового виправлення локалізації
SLASH_COMMANDS["/vashelperua_fix"] = function()
    d("Застосування виправлень локалізації vAS Helper...")
    
    vASHelperUA.AddUkrainianBossNames()
    vASHelperUA.PatchUIText()
    
    d("Виправлення застосовані. Використайте /vashelperua для перевірки.")
end

-- Ініціалізуємо утиліти
if vASHelper then
    vASHelperUA.Initialize()
else
    -- Чекаємо завантаження vASHelper
    EVENT_MANAGER:RegisterForEvent("vASHelperUA_Init", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
        if addonName == "vASHelper" then
            EVENT_MANAGER:UnregisterForEvent("vASHelperUA_Init", EVENT_ADD_ON_LOADED)
            zo_callLater(function()
                vASHelperUA.Initialize()
            end, 200)
        end
    end)
end

-- Експортуємо модуль
_G["vASHelperUA_Utils"] = vASHelperUA
