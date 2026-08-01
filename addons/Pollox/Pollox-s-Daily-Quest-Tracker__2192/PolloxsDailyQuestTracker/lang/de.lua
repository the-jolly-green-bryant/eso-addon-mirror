-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.DQT_TOGGLE_DISPLAY                 = "Verändere Anzeige"
L.DQT_TIME_UNTIL_RESET               = "Zeit bis zum Zurücksetzen"
L.DQT_CHARACTERS_HEADER              = "Ausgewählte Charaktere"
L.DQT_SECTION_HEADER                 = "Ausgewählte Sektionen"

-- Bindings
L.SI_BINDING_NAME_DTQ_TOGGLE_DISPLAY = "Verändere Anzeige"

-- Section Names
L.DQT_OTHER_TIMERS                   = "Verschiedenes"
L.DQT_RANDOM_DUNGEON                 = "Zufällige Verliese"
L.DQT_RANDOM_BATTLEGROUNDS           = "Zufällige Schlachtfelder"
-- L.DQT_CYRODILIC_COLLECTIONS          = "Cyrodiilische Sammlungen"
L.DQT_IMPERIAL_CITY                  = "Kaiserstadt"
L.DQT_DARK_BROTHERHOOD               = "Goldküste"
L.DQT_CLOCKWORK_CITY                 = "Stadt der Uhrwerke"
-- L.DQT_ELSWEYR_PROLOGUE               = "Elsweyr Prologue"
L.DQT_ELSWEYR                        = "Nördliches Elsweyr"
L.DQT_DRAGONHOLD                     = "Südliches Elsweyr"
L.DQT_WESTERN_SKYRIM                 = "Westliches Himmelsrand"
L.DQT_THE_REACH                      = "Reik"
-- L.DQT_LOWER_CRAGLORN                 = "Lower Craglorn"
-- L.DQT_UPPER_CRAGLORN                 = "Upper Craglorn"
L.DQT_DEADLANDS                      = "Totenländer"
L.DQT_CYRODIIL_PVE                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " Siedlungen"
-- L.DQT_CYRODIIL_PVP                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " " .. GetString(SI_GUILDFOCUSATTRIBUTEVALUE5)

-- Quest Type Names
L.DQT_GEYSERS                        = "Kluftgeysir"
L.DQT_ASHLANDER_HUNT                 = "Aschländer Jagd"
L.DQT_ASHLANDER_RELIC                = "Aschländer Relikte"
L.DQT_FIGHTERS_GUILD                 = "Kriegergilde"
L.DQT_MAGES_GUILD                    = "Magiergilde"
-- L.DQT_UNDAUNTED_DELVE                = GetString(SI_VISUALARMORTYPE4) .. " " .. GetString(SI_ZONECOMPLETIONTYPE5)
L.DQT_TARNISHED                      = "Die Befleckten"
L.DQT_BLACKFEATHER_COURT             = "Schwarzfederhof"
L.DQT_RYES_REACQUISITIONS            = "Ryes Rückbeschaffungen"
L.DQT_HEIST                          = "Beutezug"
L.DQT_SACRAMENT                      = "Sakrament"
L.DQT_ROOT_WHISPER                   = "Wurzelflüstern"
L.DQT_NEW_MOON                       = "Neuer Mond"
L.DQT_DRAGONHUNT                     = "Drachenjagd"
L.DQT_HARROWSTORM                    = "Gramstürme"
L.DQT_RESISTANCE                     = "Unbezähmbare Hüter"
L.DQT_VOLCANIC_VENTS                 = "Vulkanschlot"
L.DQT_CHORROL                        = "Chorrol und Weynon Priory"
L.DQT_CROPSFORD                      = "Erntefurt"
L.DQT_CYRODIIL_FIGHTERS_GUILD        = "Kopfgeldtafel der Kriegergilde"
L.DQT_CYRODIIL_BATTLE_MISSIONS       = "Schlachttafel"
L.DQT_CYRODIIL_BOUNTY_MISSIONS       = "Kopfgeldtafel"
L.DQT_CYRODIIL_SCOUTING_MISSIONS     = "Kundschaftertafel"
L.DQT_CYRODIIL_WARFRONT_MISSION      = "Kriegsfronttafel"
L.DQT_CYRODIIL_ELDER_SCROLL          = "Schriftrolle der Alten"
L.DQT_CYRODIIL_CONQUEST_MISSION      = "Missionstafel für Eroberungen"

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.DQT_PLEDGE_PREFIX = "Gelöbnis: "

-- Vvardenfell Relics Quests
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1 = "Die Relikte von "
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_2 = "Relikte von "

-- Fighters Guild Quests
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = "Dunkle Anker in der "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_2 = "Dunkle Anker in "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_3 = "Dunkle Anker auf "

-- Mages Guild Quests
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = "Verrückte "
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_2 = "Verrücktes "

-- Thieves Guild Heist Quests
L.DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = "Beutezug der "

-- Dark Brotherhood Sacrament Quests
L.DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX = "Sakrament: "

-- Elsweyr Prologue Quests
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_1 = "Drachenkunde: "

-- Fighters Guild Bounty Quests
L.DQT_CYRODIIL_FIGHTERS_GUILD_BOUNTY_QUESTS_PREFIX = "Kopfgeld: "

-- Necrom Bastion Nymic Quests
L.DQT_NECROM_QUESTS_BASTION_NYMIC_PREFIX = "Bastion Nymon: "

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)
--[[L.DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "Der Kluftalchemist"
L.DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "Vom gleichen Schlag"
L.DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "Nie vergessen"
L.DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "Auf Grund gelaufen"
L.DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "Die Seuchensee"
L.DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "Die Zähmung der Wildnis"--]]

-- Vvardenfell Bounty Quests (World Boss)
--[[L.DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "Der besorgte Lehrling"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "Ein schleichender Hunger"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "Das Ausdünnen des Schwarms"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "Frei laufende Ochsen"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "Salothans Fluch"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "Sirenensang"--]]

-- Wrothgar Group Boss Quests
--[[L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "Der Frevel des Unwissens"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "Fleisch für die Massen"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "Die Gabe der Natur"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "So riecht ein falsches Spiel"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "Gelehrtes Bergungsgut"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "Schnee und Dampf"--]]

-- Dark Brotherhood Bounty Quests
--[[L.DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Das Übel unter der Erde"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "Das Gemeinwohl"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "Drohende Schatten"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "Das Jubeln der Menge"--]]

-- Clockwork City Bounty Quests
--[[L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "Ein feingefiederter Feind"
L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "Das Reizen des Unvollendeten"--]]

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end
