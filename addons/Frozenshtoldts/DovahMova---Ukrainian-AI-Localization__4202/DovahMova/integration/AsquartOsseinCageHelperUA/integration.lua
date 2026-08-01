-- AsquartOsseinCageHelper Integration with DovahMova
-- Файл інтеграції для забезпечення роботи AsquartOsseinCageHelper з українською локалізацією
-- Додає підтримку українських імен босів та NPC для Ossein Cage (Кістяка Клітка)
-- Автор: DovahMova Team

-- Перевіряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо модуль інтеграції AsquartOsseinCageHelper
local AsquartOsseinCageHelperIntegration = {}
AsquartOsseinCageHelperIntegration.name = "AsquartOsseinCageHelperUA"
AsquartOsseinCageHelperIntegration.isInitialized = false
AsquartOsseinCageHelperIntegration.debugLogging = false
AsquartOsseinCageHelperIntegration.hasPatched = false

-- Функція ініціалізації інтеграції
function AsquartOsseinCageHelperIntegration:Initialize()
    if self.isInitialized then
        return true
    end
    
    -- Реєструємо EVENT_PLAYER_ACTIVATED щоб застосувати переклади після ініціалізації AOCH.data
    EVENT_MANAGER:RegisterForEvent(self.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        -- Застосовуємо переклади після активації гравця (коли AOCH.data вже ініціалізований)
        zo_callLater(function()
            if AOCH then
                self:ApplyUkrainianSupport()
            end
        end, 500)
        
        -- Відписуємося після першого виклику
        EVENT_MANAGER:UnregisterForEvent(self.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    end)
    
    -- Перевіряємо, чи AsquartOsseinCageHelper завантажений
    if not AOCH then
        -- Якщо AOCH ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForAOCH", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "AsquartOsseinCageHelper" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForAOCH", EVENT_ADD_ON_LOADED)
                zo_callLater(function()
                    self:ApplyUkrainianSupport()
                end, 100)
            end
        end)
        return false
    end
    
    -- Якщо AOCH уже завантажений, застосовуємо підтримку зараз
    self:ApplyUkrainianSupport()
    return true
end

-- Функція застосування підтримки української мови
function AsquartOsseinCageHelperIntegration:ApplyUkrainianSupport()
    if not AOCH then
        return
    end
    
    -- AOCH використовує GetString() для імен босів та NPC, тому українські переклади
    -- автоматично застосовуються через ua.lua файл який завантажується до цього файлу
    
    -- Примусово перезавантажуємо українські рядки (на випадок якщо вони не застосувалися)
    if AsquartOsseinCageHelperUA_Strings then
        for stringId, stringValue in pairs(AsquartOsseinCageHelperUA_Strings) do
            ZO_CreateStringId(stringId, stringValue)
            SafeAddVersion(stringId, 1)
        end
    end
    
    -- Оновлюємо дані імен в AOCH.data з українськими перекладами
    if AOCH.data then
        -- Оновлюємо імена босів та NPC
        AOCH.data.carrion_shield_synergy_name = GetString(AOCH_CarrionShield)
        AOCH.data.spectral_revenant_name = GetString(AOCH_SpectralRevenant)
        AOCH.data.dreadful_abductor_name = GetString(AOCH_Abductor)
        
        -- Міні-боси
        AOCH.data.gedna_relvel_name = GetString(AOCH_GednaRelvel)
        AOCH.data.tortured_ranyu_name = GetString(AOCH_TorturedRanyu)
        AOCH.data.blood_drinker_thisa_name = GetString(AOCH_BloodDrkinerThisa)
        
        -- Hall of Fleshcraft (Зал Плототворення)
        AOCH.data.hall_of_fleshcraft_name = GetString(AOCH_ShaperOfFlesh)
        AOCH.data.fleshspawn_name = GetString(AOCH_Fleshspawn)
        AOCH.data.channeler_name = GetString(AOCH_Channeler)
        AOCH.data.harvester_name = GetString(AOCH_Harvester)
        AOCH.data.daedroth_name = GetString(AOCH_Daedroth)
        
        -- Jynorah and Skorkhif (Джинора та Скоркіф)
        AOCH.data.jynorah_name = GetString(AOCH_Jynorah)
        AOCH.data.skorknif_name = GetString(AOCH_Skorknif)
        AOCH.data.valneer_name = GetString(AOCH_Valneer)
        AOCH.data.myrinax_name = GetString(AOCH_Myrinax)
        
        -- Overfiend Kazpian (Надчудовисько Казпіан)
        AOCH.data.overfiend_kazpian_name = GetString(AOCH_Kazpian)
        AOCH.data.agonizer_bomb_name = GetString(AOCH_AgonizerBomb)
        
        if self.debugLogging then
            d(string.format("[AOCH UA] 🔄 Оновлені українські імена NPC:"))
            d(string.format("  Щит падальників: '%s'", AOCH.data.carrion_shield_synergy_name))
            d(string.format("  Привид Кістяка: '%s'", AOCH.data.spectral_revenant_name))
            d(string.format("  Жахливий викрадач: '%s'", AOCH.data.dreadful_abductor_name))
            d(string.format("  Гедна Релвел: '%s'", AOCH.data.gedna_relvel_name))
            d(string.format("  Джинора: '%s'", AOCH.data.jynorah_name))
            d(string.format("  Скоркіф: '%s'", AOCH.data.skorknif_name))
            d(string.format("  Казпіан: '%s'", AOCH.data.overfiend_kazpian_name))
        end
    end
    
    self.isInitialized = true
    self.hasPatched = true
end

-- Функція перевірки сумісності
function AsquartOsseinCageHelperIntegration:CheckCompatibility()
    if not AOCH then
        return false, "AsquartOsseinCageHelper не встановлений або не активний"
    end
    
    if not AOCH.data then
        return false, "AOCH.data не ініціалізований"
    end
    
    if not AOCH.BossesChanged then
        return false, "AOCH.BossesChanged функція не знайдена"
    end
    
    return true, "Сумісність підтверджена"
end

-- Функція отримання інформації про інтеграцію
function AsquartOsseinCageHelperIntegration:GetInfo()
    local compatible, message = self:CheckCompatibility()
    
    local supportedBosses = {
        "Red Witch Gedna Relvel (Руда відьма Ґедна Релвел)",
        "Tortured Ranyu (Катований Раню)",
        "Blood Drinker Thisa (Кровопивця Тіза)",
        "Shaper of Flesh (Формувач плоті)",
        "Jynorah & Skorkhif (Джинора & Скоркіф)",
        "Overfiend Kazpian (Надчудовисько Казпіан)"
    }
    
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = compatible,
        message = message,
        aochVersion = AOCH and AOCH.version or "unknown",
        aochLoaded = AOCH ~= nil,
        translationsLoaded = AsquartOsseinCageHelperUA_Strings ~= nil,
        hasPatched = self.hasPatched,
        currentLocale = GetCVar("language.2"),
        supportedBosses = supportedBosses,
        supportedBossCount = #supportedBosses,
        localizationMethod = "GetString() з мовних файлів"
    }
end

-- Функція для включення/відключення детального логування
function AsquartOsseinCageHelperIntegration:SetDebugLogging(enabled)
    self.debugLogging = enabled
    local status = enabled and "увімкнено" or "вимкнено"
    d(string.format("[AsquartOsseinCageHelper UA] Детальне логування %s", status))
end

-- Реєструємо інтеграцію в DovahMova (якщо доступно)
if DovahMova then
    if DovahMova.RegisterIntegration then
        DovahMova:RegisterIntegration(AsquartOsseinCageHelperIntegration.name, AsquartOsseinCageHelperIntegration)
    else
        -- Створюємо систему інтеграцій якщо її ще немає
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        DovahMova.integrations[AsquartOsseinCageHelperIntegration.name] = AsquartOsseinCageHelperIntegration
    end
end

-- Ініціалізуємо інтеграцію
AsquartOsseinCageHelperIntegration:Initialize()

-- Експортуємо модуль для можливого використання іншими частинами коду
_G["DovahMova_AsquartOsseinCageHelperIntegration"] = AsquartOsseinCageHelperIntegration

-- ===============================
-- Тестові команди
-- ===============================

-- Команда для тестування інтеграції
SLASH_COMMANDS["/aochtest"] = function()
    local info = AsquartOsseinCageHelperIntegration:GetInfo()
    d("=== Тест інтеграції AsquartOsseinCageHelper ===")
    d("Ім'я: " .. tostring(info.name))
    d("Ініціалізовано: " .. tostring(info.initialized))
    d("Сумісність: " .. tostring(info.compatible))
    d("Повідомлення: " .. tostring(info.message))
    d("AOCH завантажено: " .. tostring(info.aochLoaded))
    d("Версія AOCH: " .. tostring(info.aochVersion))
    d("Поточна локалізація: " .. tostring(info.currentLocale))
    d("Підтримувані боси: " .. tostring(info.supportedBossCount))
    for i, boss in ipairs(info.supportedBosses) do
        d("  " .. i .. ". " .. boss)
    end
    d("Метод локалізації: " .. tostring(info.localizationMethod))
    d("================================================")
end

-- Команда для тестування імен босів
SLASH_COMMANDS["/aochbosstest"] = function()
    d("=== Тест імен босів (AOCH) ===")
    
    if not AOCH then
        d("❌ AOCH не завантажений!")
        return
    end
    
    -- Перевіряємо поточних босів
    for i = 1, 12 do
        local bossTag = "boss" .. i
        local bossName = GetUnitName(bossTag)
        if bossName and bossName ~= "" then
            local lowerName = string.lower(bossName)
            d(string.format("%s: '%s'", bossTag, bossName))
            
            if AOCH.data then
                -- Перевіряємо всі можливі співпадіння
                local matches = {}
                
                if string.match(lowerName, string.lower(AOCH.data.gedna_relvel_name or "")) then 
                    table.insert(matches, "Gedna Relvel") 
                end
                if string.match(lowerName, string.lower(AOCH.data.tortured_ranyu_name or "")) then 
                    table.insert(matches, "Tortured Ranyu") 
                end
                if string.match(lowerName, string.lower(AOCH.data.blood_drinker_thisa_name or "")) then 
                    table.insert(matches, "Blood Drinker Thisa") 
                end
                if string.match(lowerName, string.lower(AOCH.data.hall_of_fleshcraft_name or "")) then 
                    table.insert(matches, "Shaper of Flesh") 
                end
                if string.match(lowerName, string.lower(AOCH.data.jynorah_name or "")) then 
                    table.insert(matches, "Jynorah") 
                end
                if string.match(lowerName, string.lower(AOCH.data.skorknif_name or "")) then 
                    table.insert(matches, "Skorkhif") 
                end
                if string.match(lowerName, string.lower(AOCH.data.overfiend_kazpian_name or "")) then 
                    table.insert(matches, "Overfiend Kazpian") 
                end
                
                if #matches > 0 then
                    d("  Співпадіння: " .. table.concat(matches, ", "))
                end
            end
        end
    end
    d("===============================")
end

-- Команда для перевірки поточного стану AOCH
SLASH_COMMANDS["/aochstatus"] = function()
    if not AOCH then
        d("❌ AsquartOsseinCageHelper не завантажений!")
        return
    end
    
    d("=== Статус AsquartOsseinCageHelper ===")
    d("Версія: " .. tostring(AOCH.version))
    d("Активний: " .. tostring(AOCH.active))
    
    if AOCH.status then
        d("В бою: " .. tostring(AOCH.status.inCombat))
        d("Поточний бос: " .. tostring(AOCH.status.currentBoss))
        d("Gedna Relvel: " .. tostring(AOCH.status.is_Gedna_Relvel))
        d("Hall of Fleshcraft: " .. tostring(AOCH.status.is_Hall_of_Fleshcraft))
        d("Tortured Ranyu: " .. tostring(AOCH.status.is_Tortured_Ranyu))
        d("Jynorah & Skorkhif: " .. tostring(AOCH.status.is_jynorah_and_skorkhif))
        d("Blood Drinker Thisa: " .. tostring(AOCH.status.is_Blood_Drinker_Thisa))
        d("Overfiend Kazpian: " .. tostring(AOCH.status.is_kazpian))
        d("HM бос: " .. tostring(AOCH.status.is_hm_boss))
        d("Нормал бос: " .. tostring(AOCH.status.is_normal_boss))
        d("Trash: " .. tostring(AOCH.status.is_trash))
    end
    
    -- Показуємо імена з GetString
    d("")
    d("Імена NPC з GetString:")
    d("  Щит падальників: '" .. GetString(AOCH_CarrionShield) .. "'")
    d("  Привид: '" .. GetString(AOCH_SpectralRevenant) .. "'")
    d("  Викрадач: '" .. GetString(AOCH_Abductor) .. "'")
    d("  Гедна Релвел: '" .. GetString(AOCH_GednaRelvel) .. "'")
    d("  Джинора: '" .. GetString(AOCH_Jynorah) .. "'")
    d("  Скоркіф: '" .. GetString(AOCH_Skorknif) .. "'")
    d("  Казпіан: '" .. GetString(AOCH_Kazpian) .. "'")
    
    -- Показуємо константи в AOCH.data
    if AOCH.data then
        d("")
        d("Константи імен в AOCH.data:")
        d("  carrion_shield_synergy_name: " .. tostring(AOCH.data.carrion_shield_synergy_name))
        d("  dreadful_abductor_name: " .. tostring(AOCH.data.dreadful_abductor_name))
        d("  gedna_relvel_name: " .. tostring(AOCH.data.gedna_relvel_name))
        d("  hall_of_fleshcraft_name: " .. tostring(AOCH.data.hall_of_fleshcraft_name))
        d("  jynorah_name: " .. tostring(AOCH.data.jynorah_name))
        d("  skorknif_name: " .. tostring(AOCH.data.skorknif_name))
        d("  overfiend_kazpian_name: " .. tostring(AOCH.data.overfiend_kazpian_name))
    end
    
    d("======================================")
end

-- Команда для примусового оновлення імен (для тестування)
SLASH_COMMANDS["/aochreload"] = function()
    if not AOCH or not AOCH.data then
        d("❌ AOCH.data недоступний!")
        return
    end
    
    d("🔄 Оновлюю імена NPC...")
    AsquartOsseinCageHelperIntegration:ApplyUkrainianSupport()
    d("✅ Імена NPC оновлені. Використайте /aochstatus для перевірки.")
end

-- Команда для включення детального логування
SLASH_COMMANDS["/aochdebug"] = function(args)
    if args == "on" then
        AsquartOsseinCageHelperIntegration:SetDebugLogging(true)
    elseif args == "off" then
        AsquartOsseinCageHelperIntegration:SetDebugLogging(false)
    else
        local current = AsquartOsseinCageHelperIntegration.debugLogging
        AsquartOsseinCageHelperIntegration:SetDebugLogging(not current)
    end
end

-- Команда для перевірки імен у поточній зоні
SLASH_COMMANDS["/aochzone"] = function()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local zoneName = GetZoneNameById(zoneId)
    
    d("=== Інформація про зону ===")
    d("Zone ID: " .. tostring(zoneId))
    d("Zone Name: " .. tostring(zoneName))
    
    if AOCH and AOCH.data then
        local isOsseinCage = (zoneId == AOCH.data.ossein_cage_id)
        d("Ossein Cage ID: " .. tostring(AOCH.data.ossein_cage_id))
        d("В Ossein Cage: " .. tostring(isOsseinCage))
    end
    
    d("===========================")
end

