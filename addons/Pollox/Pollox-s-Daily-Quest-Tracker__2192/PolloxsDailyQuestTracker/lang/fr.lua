-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.DQT_TOGGLE_DISPLAY                 = "Basculer l'affichage"
L.DQT_TIME_UNTIL_RESET               = "Temps avant réinitialisation"
L.DQT_CHARACTERS_HEADER              = "Personnages à afficher"
L.DQT_SECTION_HEADER                 = "Sections à afficher"

-- Bindings
L.SI_BINDING_NAME_DTQ_TOGGLE_DISPLAY = "Basculer l'affichage"

-- Section Names
-- L.DQT_OTHER_TIMERS                   = "Other Timers"
-- L.DQT_CYRODILIC_COLLECTIONS          = "Cyrodilic Collections"
-- L.DQT_ELSWEYR_PROLOGUE               = "Elsweyr Prologue"
-- L.DQT_LOWER_CRAGLORN                 = "Lower Craglorn"
-- L.DQT_UPPER_CRAGLORN                 = "Upper Craglorn"
-- L.DQT_CYRODIIL_PVE                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " Settlements"
-- L.DQT_CYRODIIL_PVP                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " " .. GetString(SI_GUILDFOCUSATTRIBUTEVALUE5)

-- Quest Type Names
-- L.DQT_GEYSERS                        = "Geysers"
-- L.DQT_ASHLANDER_HUNT                 = "Ashlander Hunt"
-- L.DQT_ASHLANDER_RELIC                = "Ashlander Relic"
-- L.DQT_UNDAUNTED_DELVE                = GetString(SI_VISUALARMORTYPE4) .. " " .. GetString(SI_ZONECOMPLETIONTYPE5)
-- L.DQT_TARNISHED                      = "Tarnished"
-- L.DQT_BLACKFEATHER_COURT             = "Blackfeather Court"
-- L.DQT_RYES_REACQUISITIONS            = "Rye's Reacquisitions"
L.DQT_HEIST                          = "Casse"
L.DQT_SACRAMENT                      = "Sacrement"
-- L.DQT_ROOT_WHISPER                   = "Root-Whisper"
-- L.DQT_NEW_MOON                       = "New Moon"
-- L.DQT_DRAGONHUNT                     = "Dragon Hunts"
L.DQT_HARROWSTORM                    = "Tempêtes"
-- L.DQT_RESISTANCE                     = "Wayward Guardian"
L.DQT_VOLCANIC_VENTS                 = "Jet volcanique"
L.DQT_CHORROL                        = "Chorrol et Weynon Priory"
L.DQT_CROPSFORD                      = "Gué-les-Champs"
-- L.DQT_CYRODIIL_FIGHTERS_GUILD        = zo_strformat("<<C:1>>", GetSkillLineName(5,2)) .. " " .. GetString(SI_STATS_BOUNTY_LABEL)
L.DQT_CYRODIIL_BATTLE_MISSIONS       = "Missions de bataille"
L.DQT_CYRODIIL_BOUNTY_MISSIONS       = "Missions à primes"
L.DQT_CYRODIIL_SCOUTING_MISSIONS     = "Missions de reconnaissance"
L.DQT_CYRODIIL_WARFRONT_MISSION      = "Missions du front"
L.DQT_CYRODIIL_ELDER_SCROLL          = "Missions du Parchemin des Anciens"
L.DQT_CYRODIIL_CONQUEST_MISSION      = "Missions de conquête"

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.DQT_PLEDGE_PREFIX = "Serment : "

-- Vvardenfell Relics Quests
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1 = "Reliques d'"
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_2 = "Reliques de "

-- Fighters Guild Quests
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = "Ancres noires au  "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_2 = "Ancres noires à "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_3 = "Ancres noires aux "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_4 = "Ancres noires en "

-- Mages Guild Quests
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = "Folie au "
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_2 = "Folie à "
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_3 = "Folie en "
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_4 = "Folie aux "

-- Thieves Guild Heist Quests
L.DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = "Casse : "

-- Dark Brotherhood Sacrament Quests
L.DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX = "Sacrement : "

-- Elsweyr Prologue Quests
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_1 = "Connaissance des dragons : "

-- Fighters Guild Bounty Quests
L.DQT_CYRODIIL_FIGHTERS_GUILD_BOUNTY_QUESTS_PREFIX = "Prime : "

-- Necrom Bastion Nymic Quests
L.DQT_NECROM_QUESTS_BASTION_NYMIC_PREFIX = "Le Bastion nymique – "

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)
--[[L.DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "L'Alchimiste abyssal"
L.DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "Du même plumage"
L.DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "Inoubliable"
L.DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "Naufragé"
L.DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "La mer maladive"
L.DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "Dompter la nature"--]]

-- Vvardenfell Bounty Quests (World Boss)
--[[L.DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "L'Apprenti anxieux"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "Une faim dévorante"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "Réduire le troupeau"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "Garanti sans bœuf"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "Malédiction de Salothan"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "Chant de la sirène"--]]

-- Wrothgar Group Boss Quests
--[[L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "Hérésie par l'ignorance"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "Nourrir les foules"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "Abondance de la nature"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "L'odeur du crime"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "Sauvetage académique"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "Neige et vapeur"--]]

-- Dark Brotherhood Bounty Quests
--[[L.DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Mal enfoui"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "Le bien commun"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "Ombres menaçantes"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "Le hurlement des foules"--]]

-- Clockwork City Bounty Quests
--[[L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "Un si beau plumage"
L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "Attirer l'Imparfait"--]]

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end
