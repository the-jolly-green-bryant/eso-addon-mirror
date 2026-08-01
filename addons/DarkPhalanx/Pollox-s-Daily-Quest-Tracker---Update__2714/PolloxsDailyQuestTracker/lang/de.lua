-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.SI_DQT_TOGGLE_DISPLAY = "Verändere Anzeige"
L.SI_DQT_TIME_UNTIL_RESET = "Zeit bis zum Zurücksetzen"
L.SI_DQT_CHARACTERS_HEADER = "Ausgewählte Charaktere"
L.SI_DQT_SECTION_HEADER = "Ausgewählte Sektionen"

-- Section Names
L.SI_DQT_UNDAUNTED_PLEDGE = "Unerschrockene Herausforderungen"
L.SI_DQT_SUMMERSET = "Sommersend"
L.SI_DQT_VVARDENFELL = "Vvardenfell"
L.SI_DQT_CYRODILIC_COLLECTIONS = "Cyrodilische Sammlungen"
L.SI_DQT_CLOCKWORK_CITY = "Stadt der Uhrwerke"
L.SI_DQT_WROTHGAR = "Wrothgar"
L.SI_DQT_THIEVES_GUILD = "Diebesgilde"
L.SI_DQT_DARK_BROTHERHOOD = "Dunkle Bruderschaft"
L.SI_DQT_MURKMIRE = "Murkmire"
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
L.SI_DQT_GROUP_BOSS = "Gruppen Boss"
L.SI_DQT_GEYSERS = "Geysir"
L.SI_DQT_ASHLANDER_HUNT = "Ashländer Jagd"
L.SI_DQT_ASHLANDER_RELIC = "Ashländer Relikte"
L.SI_DQT_FIGHTERS_GUILD = "Kriegergilde"
L.SI_DQT_MAGES_GUILD = "Magiergilde"
L.SI_DQT_UNDAUNTED_DELVE = "Unerschrockenen Höhle"
L.SI_DQT_TARNISHED					= "Tarnished"
L.SI_DQT_BLACKFEATHER_COURT			= "Blackfeather Court"
L.SI_DQT_RYES_REACQUISITIONS		= "Rye's Reacquisitions"
L.SI_DQT_HEIST						= "Heist"
L.SI_DQT_SACRAMENT					= "Sacrament"
L.SI_DQT_ROOT_WHISPER				= "Root-Whisper"
L.SI_DQT_NEW_MOON					= "New Moon" -- Added by DarkPhalanx
L.SI_DQT_DRAGONHUNT					= "Dragon Hunts" -- Added by DarkPhalanx
L.SI_DQT_HARROWSTORM				= "Harrowstorms" -- Added by DarkPhalanx
L.SI_DQT_PVP						= "PVP" -- Added by DarkPhalanx
L.SI_DQT_RESISTANCE					= "Resistance" -- Added by DarkPhalanx

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.SI_DQT_PLEDGE_PREFIX					= ""

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
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = ""
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_2 = "" -- placeholder for other languages

-- Dark Brotherhood Sacrament Quests
L.SI_DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX				= ""

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)	
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "Der Kluftalchemist"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "Vom gleichen Schlag"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "Nie vergessen"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "Auf Grund gelaufen"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "Die Seuchensee"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "Die Zähmung der Wildnis"

-- Vvardenfell Bounty Quests (World Boss)	
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "Der besorgte Lehrling"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "Ein schleichender Hunger"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "Das Ausdünnen des Schwarms"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "Frei laufende Ochsen"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "Salothans Fluch"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "Sirenensang"

-- Wrothgar Group Boss Quests	
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "Der Frevel des Unwissens"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "Fleisch für die Massen"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "Die Gabe der Natur"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "So riecht ein falsches Spiel"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "Gelehrtes Bergungsgut"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "Schnee und Dampf"

-- Dark Brotherhood Bounty Quests
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Das Übel unter der Erde"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "Das Gemeinwohl"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "Drohende Schatten"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "Das Jubeln der Menge"

-- Clockwork City Bounty Quests
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "Ein feingefiederter Feind"
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "Das Reizen des Unvollendeten"

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end