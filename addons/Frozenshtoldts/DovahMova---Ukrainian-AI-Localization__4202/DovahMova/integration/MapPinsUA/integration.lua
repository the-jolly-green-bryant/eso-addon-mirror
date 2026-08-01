-- MapPins Integration with DovahMova
-- Інтеграція MapPins з DovahMova
-- Автор: DovahMova Team
-- 
-- Ця інтеграція забезпечує переклад невідомих точок інтересу (Unknown POI)
-- на карті, включаючи крафтові станції та інші POI

if GetCVar("language.2") ~= "ua" then
    return
end

local MapPinsIntegration = {}
MapPinsIntegration.name = "MapPinsUA"
MapPinsIntegration.isInitialized = false

-- Список досягнень рибалки (ID)
local FishingAchievements = {
    [471]=true,[472]=true,[473]=true,[474]=true,[475]=true,[477]=true,[478]=true,[479]=true,
    [480]=true,[481]=true,[483]=true,[484]=true,[485]=true,[486]=true,[487]=true,[489]=true,
    [490]=true,[491]=true,[492]=true,[493]=true,[916]=true,[1186]=true,[1339]=true,[1340]=true,
    [1351]=true,[1431]=true,[1882]=true,[2191]=true,[2240]=true,[2295]=true,[2412]=true,
    [2566]=true,[2655]=true,[2861]=true,[2981]=true,[3144]=true,[3269]=true,[3500]=true,
    [3636]=true,[3948]=true,[4404]=true,[4460]=true
}

-- Переклад типів води (впорядкований список для детермінованої перевірки)
-- Кожен елемент: {pattern, englishName}
-- Порядок важливий: більш специфічні патерни першими
local WaterTranslations = {
    {"озерн", "Lake"},     -- озерна вода
    {"озер", "Lake"},      -- озеро, озерів
    {"смерд", "Foul"},     -- смердючий, смердюча
    {"тухл", "Foul"},      -- тухлий
    {"гниль", "Foul"},     -- гниль
    {"стічн", "Foul"},     -- стічна вода
    {"бруд", "Foul"},      -- брудна вода
    {"річк", "River"},     -- річкова вода
    {"морськ", "Salt"},    -- морська вода
    {"солон", "Salt"},     -- солона вода
    {"сіль", "Salt"},      -- сіль (повне слово)
    {"сол", "Salt"},       -- солоного, соленої
    {"масл", "Oily"},      -- масляниста
    {"олій", "Oily"},      -- олійна (альтернативний переклад)
    {"міст", "Mystic"},    -- містична
    {"прот", "Running"},   -- проточна
}

-- Переклад для тултіпа рибалки
local FishingTooltipTranslations = {
    ["Lake"] = "Озеро",
    ["Foul"] = "Стічні води",
    ["River"] = "Річка",
    ["Salt"] = "Морська вода",
    ["Oily"] = "Масляниста",
    ["Mystic"] = "Містична",
    ["Running"] = "Проточна"
}

-- ===============================================
-- ХУКИ ВСТАНОВЛЮЮТЬСЯ ОДРАЗУ (до Initialize)
-- ===============================================

-- Зберігаємо оригінальні функції
local originalGetSetDescription = GetSetDescription
local originalGetAchievementCriterion = GetAchievementCriterion
local originalShowTooltip = ZO_Tooltips_ShowTextTooltip

-- Функція для встановлення хука GetAchievementCriterion
local function InstallGetAchievementCriterionHook()
    -- Хук GetAchievementCriterion для додавання англійських назв типів води
    GetAchievementCriterion = function(achievementId, criterionIndex)
        local description, numCompleted, numRequired = originalGetAchievementCriterion(achievementId, criterionIndex)
        
        -- Якщо це досягнення рибалки
        if FishingAchievements[achievementId] and description then
            local lowerDesc = zo_strlower(description)
            local matchedTypes = {}
            
            -- Перевіряємо ВСІ патерни і збираємо всі знайдені типи води
            -- Використовуємо ipairs для гарантованого порядку перевірки
            for _, pair in ipairs(WaterTranslations) do
                local pattern, englishName = pair[1], pair[2]
                if string.find(lowerDesc, pattern) and not matchedTypes[englishName] then
                    matchedTypes[englishName] = true
                end
            end
            
            -- Додаємо всі знайдені англійські назви БЕЗ пробілу перед дужкою
            -- MapPins шукає: string.match(AchName,"("..Loc(water)..")")
            -- Тобто шукає "(Lake)", "(River)" і т.д. БЕЗ пробілу
            for waterType in pairs(matchedTypes) do
                if not string.find(description, "%(" .. waterType .. "%)") then
                    description = description .. "(" .. waterType .. ")"
                end
            end
            
            return description, numCompleted, numRequired
        end
        
        return description, numCompleted, numRequired
    end
end

-- Хук тултіпів для перекладу "на льоту"
ZO_Tooltips_ShowTextTooltip = function(control, side, text, ...)
    if text and type(text) == "string" then
        -- Перевіряємо чи це тултіп рибалки (містить англійські назви води)
        if string.find(text, "Lake") and string.find(text, "Foul") and string.find(text, "River") then
            -- Замінюємо англійські назви на українські
            text = string.gsub(text, "Lake", FishingTooltipTranslations["Lake"])
            text = string.gsub(text, "Foul", FishingTooltipTranslations["Foul"])
            text = string.gsub(text, "River", FishingTooltipTranslations["River"])
            text = string.gsub(text, "Salt", FishingTooltipTranslations["Salt"])
        end
    end
    
    originalShowTooltip(control, side, text, ...)
end

-- ===============================================
-- МЕТОДИ ІНТЕГРАЦІЇ
-- ===============================================

-- Функція для отримання українського перекладу назви сету
function MapPinsIntegration:GetUkrainianSetName(setId)
    if not setId then
        return nil
    end
    
    if not DovahMova or not DovahMova.Settings or not DovahMova.Settings.Data then
        return nil
    end
    
    local rsv = DovahMova.Settings.Data
    
    -- Спробуємо знайти переклад в Sets (за setId)
    if rsv.Sets and rsv.Sets[setId] then
        return rsv.Sets[setId]
    end
    
    -- Якщо не знайдено, повертаємо nil
    return nil
end

-- Перевизначаємо GetSetDescription для підтримки української мови
function MapPinsIntegration:HookGetSetDescription()
    GetSetDescription = function(setId)
        -- Отримуємо оригінальну англійську назву та опис
        local englishName, description = originalGetSetDescription(setId)
        
        -- Перевіряємо базові умови
        if not englishName or englishName == "" then
            return englishName, description
        end
        
        -- Якщо режим показу - тільки українська
        if DovahMova and DovahMova.Settings and DovahMova.Settings.ShowLocations == "ua" then
            -- Шукаємо український переклад
            local ukrainianName = MapPinsIntegration:GetUkrainianSetName(setId)
            
            if ukrainianName and ukrainianName ~= "" then
                return ukrainianName, description
            end
        -- Якщо режим - українська + англійська
        elseif DovahMova and DovahMova.Settings and DovahMova.Settings.ShowLocations == "uaen" then
            local ukrainianName = MapPinsIntegration:GetUkrainianSetName(setId)
            
            if ukrainianName and ukrainianName ~= "" then
                -- Повертаємо обидві мови
                return ukrainianName .. " (" .. englishName .. ")", description
            end
        end
        
        -- За замовчуванням повертаємо оригінальну назву
        return englishName, description
    end
end

-- Додатково хукаємо GetPOIInfo для перекладу назв POI
function MapPinsIntegration:HookGetPOIInfo()
    local originalGetPOIInfo = GetPOIInfo
    
    GetPOIInfo = function(zoneIndex, poiIndex)
        local poiName = originalGetPOIInfo(zoneIndex, poiIndex)
        
        -- Базові перевірки
        if not poiName or poiName == "" then
            return poiName
        end
        
        if not DovahMova or not DovahMova.Settings or not DovahMova.Settings.Data then
            return poiName
        end
        
        -- Перевіряємо чи є переклад в базі локацій
        local rsv = DovahMova.Settings.Data
        if not rsv.Locations then
            return poiName
        end
        
        local formattedName = ZO_CachedStrFormat("<<z:1>>", poiName)
        
        if rsv.Locations[formattedName] then
            -- Якщо є український переклад, використовуємо його
            if DovahMova.Settings.ShowLocations == "ua" then
                return formattedName
            elseif DovahMova.Settings.ShowLocations == "uaen" then
                return formattedName .. " (" .. poiName .. ")"
            end
        end
        
        return poiName
    end
end

-- Функція ініціалізації
function MapPinsIntegration:Initialize()
    -- Хуки вже встановлені на рівні файлу
    
    -- Перевіряємо чи DovahMova вже завантажений
    if not DovahMova then
        -- Якщо DovahMova ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForDovahMova", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "DovahMova" then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForDovahMova", EVENT_ADD_ON_LOADED)
                -- Чекаємо EVENT_PLAYER_ACTIVATED для гарантії що Settings ініціалізовані
                EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForPlayer", EVENT_PLAYER_ACTIVATED, function()
                    EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForPlayer", EVENT_PLAYER_ACTIVATED)
                    zo_callLater(function()
                        self:ApplyTranslations()
                    end, 100)
                end)
            end
        end)
        return
    end
    
    -- Якщо DovahMova вже завантажений, чекаємо EVENT_PLAYER_ACTIVATED
    EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForPlayer", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForPlayer", EVENT_PLAYER_ACTIVATED)
        zo_callLater(function()
            self:ApplyTranslations()
        end, 100)
    end)
end

-- Застосовуємо переклади
function MapPinsIntegration:ApplyTranslations()
    -- Перевіряємо базові умови
    if not DovahMova then
        if d then
            d("DovahMova: MapPins інтеграція - DovahMova не знайдено")
        end
        return
    end
    
    -- Хукаємо функції для перекладу
    InstallGetAchievementCriterionHook()  -- Встановлюємо хук для рибалки
    self:HookGetSetDescription()
    self:HookGetPOIInfo()
    
    -- Примусово оновлюємо піни рибалки, оскільки MapPins міг вже їх перевірити
    if _G["pinType_Fishing_Nodes"] then
        ZO_WorldMap_RefreshCustomPinsOfType(_G["pinType_Fishing_Nodes"])
        if COMPASS_PINS and COMPASS_PINS.RefreshPins then
            COMPASS_PINS:RefreshPins("pinType_Fishing_Nodes")
        end
    end
    
    self.isInitialized = true
end

-- Функція отримання інформації про інтеграцію
function MapPinsIntegration:GetInfo()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = true,
        message = "Переклад невідомих точок інтересу (POI) на карті"
    }
end

-- Реєструємо інтеграцію в DovahMova
if DovahMova and DovahMova.integrations then
    DovahMova.integrations[MapPinsIntegration.name] = MapPinsIntegration
end

-- Ініціалізуємо
MapPinsIntegration:Initialize()

-- Експортуємо глобально для доступу ззовні
_G["DovahMova_MapPinsIntegration"] = MapPinsIntegration

