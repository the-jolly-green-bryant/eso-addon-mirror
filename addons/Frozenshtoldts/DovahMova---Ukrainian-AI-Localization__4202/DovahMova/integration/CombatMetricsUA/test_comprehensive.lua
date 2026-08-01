-- Test command for comprehensive CombatMetrics integration

SLASH_COMMANDS["/cmxfull"] = function()
    d("=== CombatMetrics Comprehensive Integration Test ===")
    
    -- Check addon presence
    if CMX then
        d("CombatMetrics присутній: ТАК (версія " .. tostring(CMX.version or "невідомо") .. ")")
    else
        d("CombatMetrics присутній: НІ")
    end
    
    if DovahMova then
        d("DovahMova присутній: ТАК")
        if DovahMova.integrations and DovahMova.integrations["CombatMetrics"] then
            local integration = DovahMova.integrations["CombatMetrics"]
            d("CombatMetrics інтеграція: ЗАРЕЄСТРОВАНА")
            d("  - Завантажено: " .. tostring(integration.loaded))
            d("  - Рядки завантажені: " .. tostring(integration.strings_loaded))
            d("  - Загальна кількість рядків: " .. tostring(integration.total_strings or "невідомо"))
        else
            d("CombatMetrics інтеграція: НЕ ЗАРЕЄСТРОВАНА")
        end
    else
        d("DovahMova присутній: НІ")
    end
    
    -- Check language
    d("Поточна мова: " .. tostring(GetCVar("language.2")))
    
    -- Test comprehensive strings
    d("--- Тестування перекладених рядків ---")
    local testStrings = {
        -- Core UI
        {SI_COMBAT_METRICS_DAMAGE, "Шкода"},
        {SI_COMBAT_METRICS_HEALING, "Лікування"},
        {SI_COMBAT_METRICS_DPS, "ШВС"},
        {SI_COMBAT_METRICS_HPS, "ЛВС"},
        {SI_COMBAT_METRICS_GROUP, "Група"},
        {SI_COMBAT_METRICS_SELECTION, "Вибір"},
        {SI_COMBAT_METRICS_CALC, "Обчислення..."},
        {SI_COMBAT_METRICS_LOADING, "Завантаження..."},
        
        -- UI Tabs
        {SI_COMBAT_METRICS_TOGGLE_FIGHTSTATS, "Статистика бою"},
        {SI_COMBAT_METRICS_TOGGLE_COMBAT_LOG, "Журнал бою"},
        {SI_COMBAT_METRICS_TOGGLE_GRAPH, "Графік"},
        {SI_COMBAT_METRICS_TOGGLE_INFO, "Інформація"},
        {SI_COMBAT_METRICS_TOGGLE_SETTINGS, "Налаштування"},
        
        -- Settings
        {SI_COMBAT_METRICS_SETTINGS, "Налаштування аддона"},
        {SI_COMBAT_METRICS_MENU_PROFILES, "Профілі"},
        {SI_COMBAT_METRICS_MENU_GS_NAME, "Загальні налаштування"},
        {SI_COMBAT_METRICS_MENU_LR_NAME, "Вікно живого звіту"},
        
        -- Fight Management
        {SI_COMBAT_METRICS_DURATION, "Тривалість"},
        {SI_COMBAT_METRICS_CHARACTER, "Персонаж"},
        {SI_COMBAT_METRICS_ZONE, "Зона"},
        {SI_COMBAT_METRICS_RECENT_FIGHT, "Останні бої"},
        {SI_COMBAT_METRICS_SAVED_FIGHTS, "Збережені бої"},
        
        -- Combat Log
        {SI_COMBAT_METRICS_COMBAT_LOG, "Журнал бою"},
        {SI_COMBAT_METRICS_ABILITY, "Здібність"},
        {SI_COMBAT_METRICS_TARGET, "Ціль"},
        {SI_COMBAT_METRICS_PLAYER, "Гравець"},
        
        -- Stats
        {SI_COMBAT_METRICS_STATS, "Статистика"},
        {SI_COMBAT_METRICS_AVERAGE, "Середнє"},
        {SI_COMBAT_METRICS_MAX, "Макс"},
        {SI_COMBAT_METRICS_MIN, "Мін"},
        {SI_COMBAT_METRICS_TOTAL, "Загалом"},
        
        -- Performance
        {SI_COMBAT_METRICS_PERFORMANCE, "Продуктивність"},
        {SI_COMBAT_METRICS_PERFORMANCE_FPSAVG, "Середній FPS"},
        
        -- Resources
        {SI_COMBAT_METRICS_RESOURCES, "Ресурси"},
        {SI_COMBAT_METRICS_REGENERATION, "Регенерація"},
        {SI_COMBAT_METRICS_CONSUMPTION, "Споживання"},
        
        -- Buffs
        {SI_COMBAT_METRICS_BUFF, "Баф"},
        {SI_COMBAT_METRICS_BUFFS, "Бафи"},
        {SI_COMBAT_METRICS_DEBUFFS, "Дебафи"},
        {SI_COMBAT_METRICS_UPTIME, "Час дії %"},
        
        -- Keybindings
        {SI_BINDING_NAME_CMX_REPORT_TOGGLE, "Перемкнути звіт бою"},
        {SI_BINDING_NAME_CMX_LIVEREPORT_TOGGLE, "Перемкнути живий звіт"}
    }
    
    local translated = 0
    local total = #testStrings
    
    for i, stringData in ipairs(testStrings) do
        local stringId, expectedUkrainian = stringData[1], stringData[2]
        local actualValue = GetString(stringId)
        local isTranslated = actualValue == expectedUkrainian
        
        if isTranslated then
            translated = translated + 1
            d("✓ " .. actualValue)
        else
            d("✗ " .. actualValue .. " (очікувалось: " .. expectedUkrainian .. ")")
        end
    end
    
    d("--- Результат ---")
    d("Перекладено: " .. translated .. "/" .. total .. " (" .. math.floor(translated/total*100) .. "%)")
    
    if translated == total then
        d("🎉 ВСІ РЯДКИ УСПІШНО ПЕРЕКЛАДЕНІ!")
    elseif translated > total * 0.8 then
        d("✅ Більшість рядків перекладена успішно")
    else
        d("⚠️ Потребує уваги - багато рядків не перекладено")
    end
    
    d("=== Тест завершено ===")
end
