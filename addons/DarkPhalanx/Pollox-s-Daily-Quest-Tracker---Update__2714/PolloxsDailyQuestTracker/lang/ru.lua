-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.SI_DQT_TOGGLE_DISPLAY				= "Переключить отображение"
L.SI_DQT_TIME_UNTIL_RESET			= "Времени до сброса"
L.SI_DQT_CHARACTERS_HEADER			= "Персонажи"
L.SI_DQT_SECTION_HEADER				= "Разделы"

-- Section Names
L.SI_DQT_CRAFTING					= "Ремесла"
L.SI_DQT_SUMMERSET					= "Саммерсет"
L.SI_DQT_VVARDENFELL				= "Вварденфел"
L.SI_DQT_GUILD						= "Гильдия"
L.SI_DQT_CYRODILIC_COLLECTIONS		= "Коллекции Сиродила"
L.SI_DQT_CLOCKWORK_CITY				= "Заводной город"
L.SI_DQT_WROTHGAR					= "Ротгар"
L.SI_DQT_THIEVES_GUILD				= "Гильдия воров"
L.SI_DQT_DARK_BROTHERHOOD			= "Темное Братство"
L.SI_DQT_MURKMIRE					= "Murkmire"
L.SI_DQT_OTHER_TIMERS				= "Other Timers"
L.SI_DQT_RANDOM_DUNGEON				= "Random Dungeon"
L.SI_DQT_RANDOM_BATTLEGROUNDS		= "Random Battlegrounds"
L.SI_DQT_MOUNT_TRAINING				= "Mount Training"
L.SI_DQT_ELSWEYR_PROLOGUE			= "Elsweyr Prologue"
L.SI_DQT_ELSWEYR					= "Elsweyr"
L.SI_DQT_DRAGONHOLD					= "Dragonhold" -- Added by DarkPhalanx
L.SI_DQT_WESTERN_SKYRIM				= "Western Skyrim" -- Added by DarkPhalanx
L.SI_DQT_IMPERIAL_CITY				= "Imperial City" -- Added by DarkPhalanx
L.SI_DQT_THE_REACH					= "The Reach" -- Added by DarkPhalanx
L.SI_DQT_LOWER_CRAGLORN				= "Lower Craglorn" -- Added by DarkPhalanx
L.SI_DQT_UPPER_CRAGLORN				= "Upper Craglorn" -- Added by DarkPhalanx
L.SI_DQT_BLACKWOOD					= "Blackwood" -- Added by DarkPhalanx

-- Quest Type Names
L.SI_DQT_GROUP_BOSS					= "Групповой босс"
L.SI_DQT_DELVE						= "Вылазка"
L.SI_DQT_GEYSERS					= "Гейзеры"
L.SI_DQT_ASHLANDER_HUNT				= "Охотник Эшленда"
L.SI_DQT_ASHLANDER_RELIC			= "Хранитель реликвий Эшленда"
L.SI_DQT_FIGHTERS_GUILD				= "Гильдия Бойцов"
L.SI_DQT_MAGES_GUILD				= "Гильдия Магов"
L.SI_DQT_UNDAUNTED_DELVE			= "Вылазка Неустрашимых"
L.SI_DQT_TARNISHED					= "Tarnished"
L.SI_DQT_BLACKFEATHER_COURT			= "Черноперый двор"
L.SI_DQT_RYES_REACQUISITIONS		= "Возвращение вещей Рая"
L.SI_DQT_HEIST						= "Ограбление"
L.SI_DQT_GOLD_COAST_BOUNTY			= "Объявления"
L.SI_DQT_SACRAMENT					= "Таинство"
L.SI_DQT_ROOT_WHISPER				= "Root-Whisper"
L.SI_DQT_NEW_MOON					= "New Moon" -- Added by DarkPhalanx
L.SI_DQT_DRAGONHUNT					= "Dragon Hunts" -- Added by DarkPhalanx
L.SI_DQT_HARROWSTORM				= "Harrowstorms" -- Added by DarkPhalanx
L.SI_DQT_PVP						= "PVP" -- Added by DarkPhalanx
L.SI_DQT_RESISTANCE					= "Resistance" -- Added by DarkPhalanx

L.SI_DQT_CLOTHING					= "Портняжное дело"
L.SI_DQT_BLACKSMITHING				= "Кузнечное дело"
L.SI_DQT_WOODWORKING				= "Столярное дело"
L.SI_DQT_JEWELRY					= "Ювелирное дело"
L.SI_DQT_ALCHEMY					= "Алхимия"
L.SI_DQT_ENCHANTING					= "Зачарование"
L.SI_DQT_PROVISIONING				= "Снабжение"

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.SI_DQT_PLEDGE_PREFIX					= "Обет: "

-- Vvardenfell Relics Quests
L.SI_DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1	= ""
L.SI_DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_2	= "" -- placeholder for other languages

-- Fighters Guild Quests
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = ""
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_2 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_3 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_4 = "" -- placeholder for other languages

-- Mages Guild Quests
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = ""
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_2 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_3 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_4 = "" -- placeholder for other languages

-- Thieves Guild Heist Quests
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1					= "Ограбление: "
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_2					= "" -- placeholder for other languages

-- Dark Brotherhood Sacrament Quests
L.SI_DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX				= "Таинство: "

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)	
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "Глубинный алхимик"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "Одного поля ягода"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "Вечная память"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "На мели"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "Болезнь моря"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "Укрощение дикой природы"

-- Vvardenfell Bounty Quests (World Boss)	
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "Обеспокоенная ученица"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "Затаившийся алчущий"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "Отбраковка колонии"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "Волам здесь не место"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "Проклятье Салотанов"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "Песня сирены"

-- Wrothgar Group Boss Quests
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "Ересь невежества"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "Мясо в массы"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "Щедрость природы"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "Запах нечестной игры"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "Спасение во имя знаний"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "Снег и пар"

-- Dark Brotherhood Bounty Quests
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Exulus the Wispmother"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Захороненное зло"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "Всеобщее благо"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "Надвигающиеся тени"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "Рев толпы"

-- Clockwork City Bounty Quests
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "Враг в прекрасном оперении"
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "Пробуждение Несовершенства"

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end