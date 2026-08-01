-- QuestMap Integration with DovahMova
-- Автор: DovahMova Team

if GetCVar("language.2") ~= "ua" then
    return
end

local QuestMapIntegration = {}
QuestMapIntegration.name = "QuestMapUA"
QuestMapIntegration.isInitialized = false
QuestMapIntegration.debugLog = {} -- Лог для відладки

-- Показуємо що файл завантажився
EVENT_MANAGER:RegisterForEvent("QuestMapUA_LoadCheck", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent("QuestMapUA_LoadCheck", EVENT_PLAYER_ACTIVATED)
end)

function QuestMapIntegration:Initialize()
    self.initCalled = true
    
    -- Чекаємо поки QuestMap завантажиться
    if not QuestMap then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "QuestMap" then
                EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
                self:ApplyTranslations()
                self:PatchLibQuestData() -- FIXED: Added missing call!
            end
        end)
        return
    end
    
    self:ApplyTranslations()
    self:PatchLibQuestData()
end

function QuestMapIntegration:ApplyTranslations()
    -- Застосовуємо українські переклади для фільтрів на мапі
    if not QuestMapUA_Strings then 
        return 
    end
    
    for stringId, text in pairs(QuestMapUA_Strings) do
        ZO_CreateStringId(stringId, text)
        SafeAddVersion(stringId, 1)
    end
    
    self.isInitialized = true
end

-- ПАТЧ для LibQuestData щоб підтримувати українську мову
function QuestMapIntegration:PatchLibQuestData()
    zo_callLater(function()
        if not LibQuestData then 
            return 
        end
        
        local LQD = LibQuestData
        
        -- Функція для оновлення started_quests зворотним пошуком
        local function UpdateStartedQuestsUA()
            if not LQD.started_quests then
                LQD.started_quests = {}
            end
            
            LQD.started_quests = {}
            local count = 0
            
            -- Спочатку збираємо всі назви квестів з журналу
            local journalQuestNames = {}
            for i = 1, GetNumJournalQuests() do
                if IsValidQuestIndex(i) then
                    local questName = GetJournalQuestName(i)
                    if questName and questName ~= "" then
                        journalQuestNames[questName] = true
                    end
                end
            end
            local journalCount = 0
            for _ in pairs(journalQuestNames) do journalCount = journalCount + 1 end
            
            -- Тепер ітеруємо по всім квестам з бази LibQuestData
            if not LQD.quest_names then
                return 0
            end
            
            for lang, _ in pairs(LQD.quest_names) do
            end
            
            if not LQD.quest_names[LQD.effective_lang] then
                return 0
            end
            
            local checked = 0
            for questId, _ in pairs(LQD.quest_names[LQD.effective_lang]) do
                checked = checked + 1
                -- GetQuestName(questId) повертає назву квесту мовою клієнта
                local questName = GetQuestName(questId)
                if questName and questName ~= "" and journalQuestNames[questName] then
                    LQD.started_quests[questId] = true
                    count = count + 1
                end
                
            end
            
            return count
        end
        
        -- Реєструємось на події квестів щоб оновлювати список
        EVENT_MANAGER:RegisterForEvent(self.name .. "_QuestPatch", EVENT_QUEST_ADDED, function(eventCode, journalIndex, questName, objectiveName)
            zo_callLater(function()
                UpdateStartedQuestsUA()
            end, 100)
        end)
        
        EVENT_MANAGER:RegisterForEvent(self.name .. "_QuestPatchRemove", EVENT_QUEST_REMOVED, function(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
            zo_callLater(function()
                UpdateStartedQuestsUA()
            end, 100)
        end)
        
        -- Оновлюємо при відкритті мапи
        EVENT_MANAGER:RegisterForEvent(self.name .. "_MapOpen", EVENT_PLAYER_ACTIVATED, function()
            UpdateStartedQuestsUA()
        end)
        
        -- Ініціалізуємо через 3 секунди після завантаження
        zo_callLater(function()
            local count = UpdateStartedQuestsUA()
        end, 3000)
        
    end, 1500)
end

-- Реєструємо інтеграцію в DovahMova
if DovahMova and DovahMova.integrations then
    DovahMova.integrations[QuestMapIntegration.name] = QuestMapIntegration
end

-- Ініціалізуємо
QuestMapIntegration:Initialize()

-- Глобальний доступ для перевірки стану
_G["DovahMova_QuestMapIntegration"] = QuestMapIntegration
