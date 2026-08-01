-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.SI_DQT_TOGGLE_DISPLAY				= "Basculer l'affichage"
L.SI_DQT_TIME_UNTIL_RESET			= "Temps avant réinitialisation"
L.SI_DQT_CHARACTERS_HEADER			= "Personnages à afficher"
L.SI_DQT_SECTION_HEADER				= "Sections à afficher"

-- Section Names
L.SI_DQT_CRAFTING					= "Artisanat"
L.SI_DQT_SUMMERSET					= "Summerset"
L.SI_DQT_VVARDENFELL				= "Vvardenfell"
L.SI_DQT_GUILD						= "Guilde"
L.SI_DQT_CYRODILIC_COLLECTIONS		= "Cyrodilic Collections"
L.SI_DQT_CLOCKWORK_CITY				= "Clockwork City"
L.SI_DQT_WROTHGAR					= "Wrothgar"
L.SI_DQT_THIEVES_GUILD				= "Thieves Guild"
L.SI_DQT_DARK_BROTHERHOOD			= "Dark Brotherhood"
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
L.SI_DQT_GROUP_BOSS					= "Group Boss"
L.SI_DQT_GEYSERS					= "Geysers"
L.SI_DQT_ASHLANDER_HUNT				= "Ashlander Hunt"
L.SI_DQT_ASHLANDER_RELIC			= "Ashlander Relic"
L.SI_DQT_FIGHTERS_GUILD				= "Guilde des guerriers"
L.SI_DQT_MAGES_GUILD				= "Guilde des mages"
L.SI_DQT_UNDAUNTED_DELVE			= "Guilde des voleurs"
L.SI_DQT_TARNISHED					= "Tarnished"
L.SI_DQT_BLACKFEATHER_COURT			= "Blackfeather Court"
L.SI_DQT_RYES_REACQUISITIONS		= "Rye's Reacquisitions"
L.SI_DQT_HEIST						= "Casse"
L.SI_DQT_SACRAMENT					= "Sacrement"
L.SI_DQT_ROOT_WHISPER				= "Root-Whisper"
L.SI_DQT_NEW_MOON					= "New Moon" -- Added by DarkPhalanx
L.SI_DQT_DRAGONHUNT					= "Dragon Hunts" -- Added by DarkPhalanx
L.SI_DQT_HARROWSTORM				= "Harrowstorms" -- Added by DarkPhalanx
L.SI_DQT_PVP						= "PVP" -- Added by DarkPhalanx
L.SI_DQT_RESISTANCE					= "Resistance" -- Added by DarkPhalanx

L.SI_DQT_CLOTHING					= "Couture"
L.SI_DQT_BLACKSMITHING				= "Forge"
L.SI_DQT_WOODWORKING				= "Travail du bois"
L.SI_DQT_JEWELRY					= "Joaillerie"
L.SI_DQT_ALCHEMY					= "Alchimie"
L.SI_DQT_ENCHANTING					= "Enchantement"
L.SI_DQT_PROVISIONING				= "Cuisine"

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.SI_DQT_PLEDGE_PREFIX					= "Serment : "

-- Vvardenfell Relics Quests
L.SI_DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1	= "Reliques d'"
L.SI_DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_2	= "Reliques de "

-- Fighters Guild Quests
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = "Ancres noires au  "
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_2 = "Ancres noires à "
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_3 = "Ancres noires aux "
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_4 = "Ancres noires en "

-- Mages Guild Quests
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = "Folie au "
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_2 = "Folie à "
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_3 = "Folie en "
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_4 = "Folie aux "

-- Thieves Guild Heist Quests
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1					= "Casse : "
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_2					= "" -- placeholder for other languages

-- Dark Brotherhood Sacrament Quests
L.SI_DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX				= "Sacrement : "

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)	
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "L'Alchimiste abyssal"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "Du même plumage"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "Inoubliable"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "Naufragé"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "La mer maladive"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "Dompter la nature"

-- Vvardenfell Bounty Quests (World Boss)	
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "L'Apprenti anxieux"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "Une faim dévorante"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "Réduire le troupeau"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "Garanti sans bœuf"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "Malédiction de Salothan"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "Chant de la sirène"

-- Wrothgar Group Boss Quests	
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "Hérésie par l'ignorance"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "Nourrir les foules"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "Abondance de la nature"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "L'odeur du crime"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "Sauvetage académique"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "Neige et vapeur"

-- Dark Brotherhood Bounty Quests
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "Mal enfoui"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "Le bien commun"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "Ombres menaçantes"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "Le hurlement des foules"

-- Clockwork City Bounty Quests
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "Un si beau plumage"
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "Attirer l'Imparfait"

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end