-- QuestMap Ukrainian Localization - Map Filters Only
-- Українська локалізація фільтрів QuestMap на мапі
-- Автор: DovahMova Team

if GetCVar("language.2") ~= "ua" then
    return
end

-- Тільки переклади для фільтрів на мапі
local strings = {
  QUESTMAP_COMPLETED = "Завершені",
  QUESTMAP_UNCOMPLETED = "Не завершені",
  QUESTMAP_HIDDEN = "Приховані",
  QUESTMAP_STARTED = "Розпочаті",
  QUESTMAP_GUILD = "Гільдія",
  QUESTMAP_DAILY = "Щоденні",
  QUESTMAP_SKILL = "Навички",
  QUESTMAP_CADWELL = "Кедвелл",
  QUESTMAP_COMPANION = "Супутник",
  QUESTMAP_DUNGEON = "Підземелля",
  QUESTMAP_HOLIDAY = "Свято",
  QUESTMAP_TRIAL = "Тижневі",
  QUESTMAP_ZONESTORY = "Історія зони",
  QUESTMAP_PROLOGUE = "Пролог",
  QUESTMAP_PLEDGES = "Обіцянки",
  QUESTMAP_QUESTS = "Завдання",
  QUESTMAP_QUEST_SUBFILTER = "Підфільтр",
}

_G["QuestMapUA_Strings"] = strings

for stringId, ukrainianText in pairs(strings) do
    ZO_CreateStringId(stringId, ukrainianText)
    SafeAddVersion(stringId, 1)
end

