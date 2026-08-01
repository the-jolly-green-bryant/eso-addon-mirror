-- /script SetCVar("language.2", "ua")
-- ===============================================================================
-- CrutchAlerts Ukrainian Language File
-- Український мовний файл для CrutchAlerts
-- ===============================================================================
--
-- Автоматично генерує ZO_CreateStringId() на основі ua_boss_names.lua
-- НЕ РЕДАГУЙТЕ ЦЕЙ ФАЙЛ! Редагуйте ua_boss_names.lua
--
-- ===============================================================================

if GetCVar("language.2") ~= "ua" then
    return
end

local function ApplyUkrainianTranslations()
    local bossNames = _G["CrutchAlertsUABossNames"]
    if not bossNames then
        zo_callLater(ApplyUkrainianTranslations, 100)
        return
    end
    
    if not CrutchAlerts then
        EVENT_MANAGER:RegisterForEvent("CrutchAlertsUA_WaitForCrutchAlerts", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "CrutchAlerts" then
                EVENT_MANAGER:UnregisterForEvent("CrutchAlertsUA_WaitForCrutchAlerts", EVENT_ADD_ON_LOADED)
                zo_callLater(ApplyUkrainianTranslations, 100)
            end
        end)
        return
    end
    
    d("[CrutchAlerts UA] Застосовуємо українські переклади...")
    
    local count = 0
    for constName, data in pairs(bossNames) do
        ZO_CreateStringId(constName, data.ua)
        count = count + 1
    end
    
    d(string.format("[CrutchAlerts UA] ✅ Застосовано %d українських перекладів", count))
    
    -- Тест
    local testConst = _G["CRUTCH_BHB_SAINT_OLMS_THE_JUST"]
    if testConst then
        local testTranslation = GetString(testConst)
        if testTranslation == "Святий Олмс Справедливий" then
            d("[CrutchAlerts UA] ✅ Переклади працюють!")
        end
    end
end

ApplyUkrainianTranslations()

d("[CrutchAlerts UA] Мовний файл завантажено")
