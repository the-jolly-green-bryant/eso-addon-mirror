-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.DQT_TOGGLE_DISPLAY                 = "Alternar visualización"
L.DQT_TIME_UNTIL_RESET               = "Tiempo hasta el reinicio"
L.DQT_CHARACTERS_HEADER              = "Personajes a mostrar"
L.DQT_SECTION_HEADER                 = "Secciones a mostrar"

-- Bindings
L.SI_BINDING_NAME_DTQ_TOGGLE_DISPLAY = "Alternar visualización"

-- Section Names
-- L.DQT_CYRODILIC_COLLECTIONS          = "Cyrodilic Collections"
L.DQT_OTHER_TIMERS                   = "Otros Temporizadores"
-- L.DQT_ELSWEYR_PROLOGUE               = "Elsweyr Prologue"
-- L.DQT_LOWER_CRAGLORN                 = "Lower Craglorn"
-- L.DQT_UPPER_CRAGLORN                 = "Upper Craglorn"
-- L.DQT_CYRODIIL_PVE                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " Settlements"
-- L.DQT_CYRODIIL_PVP                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " " .. GetString(SI_GUILDFOCUSATTRIBUTEVALUE5)

-- Quest Type Names
L.DQT_GEYSERS                        = "Géisers"
-- L.DQT_ASHLANDER_HUNT                 = "Ashlander Hunt"
-- L.DQT_ASHLANDER_RELIC                = "Ashlander Relic"
-- L.DQT_UNDAUNTED_DELVE                = GetString(SI_VISUALARMORTYPE4) .. " " .. GetString(SI_ZONECOMPLETIONTYPE5)
-- L.DQT_TARNISHED                      = "Tarnished"
-- L.DQT_BLACKFEATHER_COURT             = "Blackfeather Court"
-- L.DQT_RYES_REACQUISITIONS            = "Rye's Reacquisitions"
L.DQT_HEIST                          = "Atraco"
L.DQT_SACRAMENT                      = "Sacramento"
-- L.DQT_ROOT_WHISPER                   = "Root-Whisper"
-- L.DQT_NEW_MOON                       = "New Moon"
-- L.DQT_DRAGONHUNT                     = "Dragon Hunts"
L.DQT_HARROWSTORM                    = "Tormentas"
-- L.DQT_RESISTANCE                     = "Wayward Guardian"
L.DQT_VOLCANIC_VENTS                 = "Respiradero volcánico"
L.DQT_CHORROL                        = "Chorrol y Weynon Priory"
L.DQT_CROPSFORD                      = "Vado de la Brizna"
L.DQT_CYRODIIL_FIGHTERS_GUILD        = zo_strformat("<<C:1>>", GetSkillLineName(5, 2)) .. " " .. "cazarrecompensas"
L.DQT_CYRODIIL_BATTLE_MISSIONS       = "Batalla"
L.DQT_CYRODIIL_BOUNTY_MISSIONS       = "Cazarrecompensas"
L.DQT_CYRODIIL_SCOUTING_MISSIONS     = "Exploración"
L.DQT_CYRODIIL_WARFRONT_MISSION      = "Frente de batalla"
L.DQT_CYRODIIL_ELDER_SCROLL          = "Pergamino antiguo"
L.DQT_CYRODIIL_CONQUEST_MISSION      = "Conquista"

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.DQT_PLEDGE_PREFIX = "Compromiso: "

-- Vvardenfell Relics Quests
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1 = "Reliquias de "

-- Fighters Guild Quests
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = "Áncoras oscuras en el "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_2 = "Áncoras oscuras en la "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_3 = "Áncoras oscuras en "

-- Mages Guild Quests
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = "Locura en el "
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_2 = "Locura en la "
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_3 = "Locura en "

-- Thieves Guild Heist Quests
L.DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = "Atraco: "

-- Dark Brotherhood Sacrament Quests
L.DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX = "Sacramento: "

-- Elsweyr Prologue Quests
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_1 = "Sabiduría sobre dragones: "

-- Fighters Guild Bounty Quests
L.DQT_CYRODIIL_FIGHTERS_GUILD_BOUNTY_QUESTS_PREFIX = "Recompensa: "

-- Necrom Bastion Nymic Quests
L.DQT_NECROM_QUESTS_BASTION_NYMIC_PREFIX = "Bastión Nímico: "

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)
--[[L.DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY		= "B'Korgen"
L.DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY		= "Gryphons"
L.DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY		= "Graveld"
L.DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY		= "Keelsplitter"
L.DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY		= "Queen of the Reef"
L.DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY		= "Caanerin"--]]

-- Vvardenfell Bounty Quests (World Boss)
--[[L.DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY	= "Dubdil Alar"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY	= "Wuyuvus"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY	= "Queen's Consort"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY	= "Nilthog the Unbroken"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY	= "Orator Salothan"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY	= "Kimbrudhil the Songbird"--]]

-- Wrothgar Group Boss Quests
--[[L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY	= "Zandadunoz the Reborn"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY	= "Snagara"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY	= "Corintthac the Abomination"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY	= "King-Chief Edu"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY	= "Mad Urkazbur"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY	= "Nyzchaleft"--]]

-- Dark Brotherhood Bounty Quests
--[[L.DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY	= "Exulus the Wispmother"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY	= "Ironfang"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY	= "Limenauruus"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY	= "The Roar of the Crowds"--]]

-- Clockwork City Bounty Quests
--[[L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "Wraith-of-Crows"
L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "Imperfect"--]]

-- Northern Elsweyr Defense Force (quest names are a bit too long for the gui)
--[[L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_01_DISPLAY = "Dark Souls"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_02_DISPLAY = "Icehammer's Vault"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_03_DISPLAY = "Shroud Hearth"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_04_DISPLAY = "Stormcrag Crypt"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_05_DISPLAY = "Goblin"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_06_DISPLAY = "Lamia"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_07_DISPLAY = "Lurcher"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_08_DISPLAY = "Skeleton"
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_09_DISPLAY = "Spider"--]]

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end
