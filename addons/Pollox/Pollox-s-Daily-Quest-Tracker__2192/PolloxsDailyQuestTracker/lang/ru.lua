-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.DQT_TOGGLE_DISPLAY                 = "Переключить отображение"
L.DQT_TIME_UNTIL_RESET               = "Времени до сброса"
L.DQT_CHARACTERS_HEADER              = "Персонажи"
L.DQT_SECTION_HEADER                 = "Разделы"

-- Bindings
L.SI_BINDING_NAME_DTQ_TOGGLE_DISPLAY = "Переключить отображение"

-- Section Names
-- L.DQT_OTHER_TIMERS                   = "Other Timers"
-- L.DQT_CYRODILIC_COLLECTIONS          = "Коллекции Сиродила"
-- L.DQT_ELSWEYR_PROLOGUE               = "Elsweyr Prologue"
-- L.DQT_LOWER_CRAGLORN                 = "Lower Craglorn"
-- L.DQT_UPPER_CRAGLORN                 = "Upper Craglorn"
-- L.DQT_CYRODIIL_PVE                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " Settlements"
-- L.DQT_CYRODIIL_PVP                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " " .. GetString(SI_GUILDFOCUSATTRIBUTEVALUE5)

-- Quest Type Names
L.DQT_GEYSERS                        = "Гейзеры"
L.DQT_ASHLANDER_HUNT                 = "Охотник Эшленда"
L.DQT_ASHLANDER_RELIC                = "Реликвии из Эшленда"
L.DQT_FIGHTERS_GUILD                 = zo_strformat("<<1>>", GetSkillLineName(5, 1))
L.DQT_MAGES_GUILD                    = zo_strformat("<<1>>", GetSkillLineName(5, 3))
-- L.DQT_UNDAUNTED_DELVE                = GetString(SI_VISUALARMORTYPE4) .. " " .. GetString(SI_ZONECOMPLETIONTYPE5)
-- L.DQT_TARNISHED                      = "Tarnished"
L.DQT_BLACKFEATHER_COURT             = "Черноперый двор"
L.DQT_RYES_REACQUISITIONS            = "Возвращение вещей Рая"
L.DQT_HEIST                          = "Ограбление"
L.DQT_SACRAMENT                      = "Таинство"
-- L.DQT_ROOT_WHISPER                   = "Root-Whisper"
-- L.DQT_NEW_MOON                       = "New Moon"
-- L.DQT_DRAGONHUNT                     = "Dragon Hunts"
-- L.DQT_HARROWSTORM                    = "Harrowstorms"
-- L.DQT_RESISTANCE                     = "Wayward Guardian"
-- L.DQT_VOLCANIC_VENTS                 = "Volcanic Vents"
-- L.DQT_BRUMA                          = "Bruma"
-- L.DQT_CHEYDINHAL                     = "Cheydinhal"
-- L.DQT_CHORROL                        = "Chorrol and Weynon Priory"
-- L.DQT_CROPSFORD                      = "Cropsford"
-- L.DQT_VLASTARUS                      = "Vlastarus"
L.DQT_CYRODIIL_FIGHTERS_GUILD        = zo_strformat("<<1>>", GetSkillLineName(5, 1)) .. " " .. GetString(SI_STATS_BOUNTY_LABEL)
-- L.DQT_CYRODIIL_BATTLE_MISSIONS       = "Battle Missions"
-- L.DQT_CYRODIIL_BOUNTY_MISSIONS       = GetString(SI_STATS_BOUNTY_LABEL) .. " " .. "Missions"
-- L.DQT_CYRODIIL_SCOUTING_MISSIONS     = "Scouting Missions"
-- L.DQT_CYRODIIL_WARFRONT_MISSION      = "Warfront Missions"
-- L.DQT_CYRODIIL_ELDER_SCROLL          = "Elder Scrolls Missions"
-- L.DQT_CYRODIIL_CONQUEST_MISSION      = "Conquest Missions"

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.DQT_PLEDGE_PREFIX = "Обет: "

-- Vvardenfell Relics Quests
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1 = "Реликвии из "

-- Fighters Guild Quests
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = "Темные якоря в "

-- Mages Guild Quests
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = "Безумие в "

-- Thieves Guild Heist Quests
L.DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = "Ограбление: "

-- Dark Brotherhood Sacrament Quests
L.DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX = "Таинство: "

-- Elsweyr Prologue Quests
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_1 = "Знания о драконах: "

-- Fighters Guild Bounty Quests
L.DQT_CYRODIIL_FIGHTERS_GUILD_BOUNTY_QUESTS_PREFIX = "Контракт: "

-- Necrom Bastion Nymic Quests
L.DQT_NECROM_QUESTS_BASTION_NYMIC_PREFIX = "Оплот Нимик: "

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)
--[[L.DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "Глубинный алхимик"
L.DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "Одного поля ягода"
L.DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "Вечная память"
L.DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "На мели"
L.DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "Болезнь моря"
L.DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "Укрощение дикой природы"--]]

-- Vvardenfell Bounty Quests (World Boss)
--[[L.DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "Обеспокоенная ученица"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "Затаившийся алчущий"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "Отбраковка колонии"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "Волам здесь не место"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "Проклятье Салотанов"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "Песня сирены"--]]

-- Wrothgar Group Boss Quests
--[[L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "Ересь невежества"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "Мясо в массы"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "Щедрость природы"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "Запах нечестной игры"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "Спасение во имя знаний"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "Снег и пар"--]]

-- Dark Brotherhood Bounty Quests
--[[L.DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Exulus the Wispmother"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Захороненное зло"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "Всеобщее благо"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "Надвигающиеся тени"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "Рев толпы"--]]

-- Clockwork City Bounty Quests
--[[L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "Враг в прекрасном оперении"
L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "Пробуждение Несовершенства"--]]

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end
