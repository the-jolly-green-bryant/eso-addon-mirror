-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.DQT_TOGGLE_DISPLAY                 = "Toggle Display"
L.DQT_TIME_UNTIL_RESET               = "Time until reset"
L.DQT_CHARACTERS_HEADER              = "Characters to Show"
L.DQT_SECTION_HEADER                 = "Sections to Show"
L.DQT_SETTINGS_HEADER                = "Settings"
L.DQT_SCALE_NAME                     = "Window scale"
L.DQT_SCALE_TOOLTIP                  = "Redefines the quest tracker window scale, requires reload"
L.DQT_COLOR_TOGGLE_NAME              = "Use custom checkbox color"
L.DQT_COLOR_CHECKED_NAME             = "Color for \"Checked\""
L.DQT_COLOR_UNCHECKED_NAME           = "Color for \"Unchecked\""
L.DQT_COLOR_DISABLED_NAME            = "Color for \"Disabled\""
L.DQT_CURSOR_TOGGLE_NAME             = "Show cursor"
L.DQT_CURSOR_TOGGLE_TOOLTIP          = "Toggle cursor on window show/hide"

-- Bindings
L.SI_BINDING_NAME_DTQ_TOGGLE_DISPLAY = "Toggle Display"

-- Section Names
L.DQT_OTHER_TIMERS                   = "Other Timers"
L.DQT_RANDOM_DUNGEON                 = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT)
L.DQT_RANDOM_BATTLEGROUNDS           = GetString(SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT)
L.DQT_MOUNT_TRAINING                 = GetString(SI_STAT_GAMEPAD_RIDING_HEADER_TRAINING)
L.DQT_BEQUEATHER                     = zo_strformat("<<C:1>>", GetAbilityName(77396))
L.DQT_CRAFTING                       = GetString(SI_QUESTTYPE4)
L.DQT_GUILD                          = GetString(SI_QUESTTYPE3)
L.DQT_UNDAUNTED_PLEDGE               = GetString(SI_QUESTTYPE15)
-- L.DQT_CYRODILIC_COLLECTIONS          = "Cyrodilic Collections"
L.DQT_IMPERIAL_CITY                  = zo_strformat("<<1>>", GetZoneNameById(584))                  -- Added by DarkPhalanx
L.DQT_WROTHGAR                       = zo_strformat("<<1>>", GetZoneNameById(684))
L.DQT_THIEVES_GUILD                  = zo_strformat("<<1>>", GetZoneNameById(816))
L.DQT_DARK_BROTHERHOOD               = zo_strformat("<<1>>", GetZoneNameById(823))
L.DQT_VVARDENFELL                    = zo_strformat("<<1>>", GetZoneNameById(849))
L.DQT_CLOCKWORK_CITY                 = zo_strformat("<<1>>", GetZoneNameById(980))
L.DQT_SUMMERSET                      = zo_strformat("<<1>>", GetZoneNameById(1011))
L.DQT_MURKMIRE                       = zo_strformat("<<1>>", GetZoneNameById(726))
-- L.DQT_ELSWEYR_PROLOGUE               = "Elsweyr Prologue"
L.DQT_ELSWEYR                        = zo_strformat("<<1>>", GetZoneNameById(1086))
L.DQT_DRAGONHOLD                     = zo_strformat("<<1>>", GetZoneNameById(1133))                  -- Added by DarkPhalanx
L.DQT_WESTERN_SKYRIM                 = zo_strformat("<<1>>", GetZoneNameById(1160))                  -- Added by DarkPhalanx
L.DQT_THE_REACH                      = zo_strformat("<<1>>", GetZoneNameById(1207))                  -- Added by DarkPhalanx
-- L.DQT_LOWER_CRAGLORN                 = "Lower Craglorn"                                              -- Added by DarkPhalanx
-- L.DQT_UPPER_CRAGLORN                 = "Upper Craglorn"                                              -- Added by DarkPhalanx
L.DQT_CRAGLORN                       = zo_strformat("<<1>>", GetZoneNameById(888))                   -- Added by g4m3r7ag
L.DQT_BLACKWOOD                      = zo_strformat("<<1>>", GetZoneNameById(1261))                  -- Added by DarkPhalanx
L.DQT_DEADLANDS                      = zo_strformat("<<1>>", GetZoneNameById(1286))                  -- Added by g4m3r7ag
L.DQT_HIGH_ISLE                      = zo_strformat("<<1>>", GetZoneNameById(1318))                  -- Added by g4m3r7ag
L.DQT_GALEN                          = zo_strformat("<<1>>", GetZoneNameById(1383))                  -- Added by g4m3r7ag
L.DQT_CYRODIIL_PVE                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " Settlements"                                                                                       -- Added by g4m3r7ag
L.DQT_CYRODIIL_PVP                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " " .. GetString(SI_GUILDFOCUSATTRIBUTEVALUE5)                                                          -- Added by g4m3r7ag
L.DQT_NECROM                         = zo_strformat("<<C:1>>", GetZoneNameById(1414))                -- Added by notnear
L.DQT_ENDLESSARCHIVE                 = zo_strformat("<<1>>", GetZoneNameById(1436))                  -- Added by notnear
L.DQT_WEST_WEALD                     = zo_strformat("<<C:1>>", GetZoneNameById(1443))                -- Added by notnear
L.DQT_SOLSTICE                       = zo_strformat("<<C:1>>", GetZoneNameById(1502))                -- Added by notnear

-- Quest Type Names
L.DQT_GROUP_BOSS                     = GetString(SI_ZONECOMPLETIONTYPE9)
L.DQT_DELVE                          = GetString(SI_ZONECOMPLETIONTYPE5) -- Updated from GetString(SI_INSTANCEDISPLAYTYPE7) - 101040, notnear
L.DQT_GEYSERS                        = "Geysers"
L.DQT_ASHLANDER_HUNT                 = "Ashlander Hunt"
L.DQT_ASHLANDER_RELIC                = "Ashlander Relic"
L.DQT_FIGHTERS_GUILD                 = zo_strformat("<<C:1>>", GetSkillLineName(5, 2))
L.DQT_MAGES_GUILD                    = zo_strformat("<<C:1>>", GetSkillLineName(5, 3))
L.DQT_UNDAUNTED_DELVE                = GetString(SI_VISUALARMORTYPE4) .. " " .. GetString(SI_ZONECOMPLETIONTYPE5) -- Updated from GetString(SI_INSTANCEDISPLAYTYPE7) - 101040, notnear
L.DQT_TARNISHED                      = "Tarnished"
L.DQT_BLACKFEATHER_COURT             = "Blackfeather Court"
L.DQT_RYES_REACQUISITIONS            = "Rye's Reacquisitions"
L.DQT_HEIST                          = "Heist"
L.DQT_GOLD_COAST_BOUNTY              = GetString(SI_STATS_BOUNTY_LABEL)
L.DQT_SACRAMENT                      = "Sacrament"
L.DQT_ROOT_WHISPER                   = "Root-Whisper"
L.DQT_NEW_MOON                       = "New Moon"                                                                               -- Added by DarkPhalanx
L.DQT_DRAGONHUNT                     = "Dragon Hunts"                                                                           -- Added by DarkPhalanx
L.DQT_HARROWSTORM                    = "Harrowstorms"                                                                           -- Added by DarkPhalanx
L.DQT_PVP                            = GetString(SI_GUILDFOCUSATTRIBUTEVALUE5)                                                  -- Added by DarkPhalanx
L.DQT_RESISTANCE                     = "Wayward Guardian" -- Updated by g4m3r7ag to match https://en.uesp.net/wiki/Online:Repeatable_Quests
L.DQT_PROLOGUE                       = GetString(SI_QUESTTYPE14)                                                                -- Added by g4m3r7ag
L.DQT_GROUP_PVE                      = GetString(SI_GUILDFOCUSATTRIBUTEVALUE2)                                                  -- Added by g4m3r7ag
L.DQT_VOLCANIC_VENTS                 = "Volcanic Vents"                                                                         -- Added by g4m3r7ag
L.DQT_TALES_OF_TRIBUTE               = GetString(SI_ACTIVITY_FINDER_CATEGORY_TRIBUTE)                                           -- Added by g4m3r7ag
L.DQT_BRUMA                          = "Bruma"                                                                                  -- Added by g4m3r7ag
L.DQT_CHEYDINHAL                     = "Cheydinhal"                                                                             -- Added by g4m3r7ag
L.DQT_CHORROL                        = "Chorrol and Weynon Priory"                                                              -- Added by g4m3r7ag
L.DQT_CROPSFORD                      = "Cropsford"                                                                              -- Added by g4m3r7ag
L.DQT_VLASTARUS                      = "Vlastarus"                                                                              -- Added by g4m3r7ag
L.DQT_CYRODIIL_FIGHTERS_GUILD        = zo_strformat("<<1>>", GetSkillLineName(5, 2)) .. " " .. GetString(SI_STATS_BOUNTY_LABEL) -- Added by g4m3r7ag
L.DQT_CYRODIIL_BATTLE_MISSIONS       = "Battle Missions"                                                                        -- Added by g4m3r7ag
L.DQT_CYRODIIL_BOUNTY_MISSIONS       = GetString(SI_STATS_BOUNTY_LABEL) .. " " .. "Missions"                                    -- Added by g4m3r7ag
L.DQT_CYRODIIL_SCOUTING_MISSIONS     = "Scouting Missions"                                                                      -- Added by g4m3r7ag
L.DQT_CYRODIIL_WARFRONT_MISSION      = "Warfront Missions"                                                                      -- Added by g4m3r7ag
L.DQT_CYRODIIL_ELDER_SCROLL          = "Elder Scrolls Missions"                                                                 -- Added by g4m3r7ag
L.DQT_CYRODIIL_CONQUEST_MISSION      = "Conquest Missions"                                                                      -- Added by g4m3r7ag
L.DQT_BASTION_NYMIC                  = zo_strformat("<<C:1>>", GetZoneNameById(1420))                                           -- Added by notnear
L.DQT_MIRRORMOOR_INCURSION           = "Mirrormoor Incursions"                                                                  -- Added by notnear
L.DQT_SIEGE_CAMPS = "Siege Camp"                                                                                                -- Added by calculoso

L.DQT_CLOTHING      = GetString(SI_ITEMFILTERTYPE14)
L.DQT_BLACKSMITHING = GetString(SI_ITEMFILTERTYPE13)
L.DQT_WOODWORKING   = GetString(SI_ITEMFILTERTYPE15)
L.DQT_JEWELRY       = GetString(SI_ITEMFILTERTYPE25)
L.DQT_ALCHEMY       = GetString(SI_ITEMFILTERTYPE16)
L.DQT_ENCHANTING    = GetString(SI_ITEMFILTERTYPE17)
L.DQT_PROVISIONING  = GetString(SI_ITEMFILTERTYPE18)

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.DQT_PLEDGE_PREFIX = "Pledge: "

-- Vvardenfell Relics Quests
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1 = "Relics of "
L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_2 = "" -- placeholder for other languages

-- Fighters Guild Quests
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = "Dark Anchors in "
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_2 = "" -- placeholder for other languages
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_3 = "" -- placeholder for other languages
L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_4 = "" -- placeholder for other languages

-- Mages Guild Quests
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = "Madness in "
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_2 = "" -- placeholder for other languages
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_3 = "" -- placeholder for other languages
L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_4 = "" -- placeholder for other languages

-- Thieves Guild Heist Quests
L.DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = "Heist: "
L.DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_2 = "" -- placeholder for other languages

-- Dark Brotherhood Sacrament Quests
L.DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX = "Sacrament: "

-- Elsweyr Prologue Quests
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_1 = "Dragon Lore: "
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_2 = "" -- placeholder for other languages
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_3 = "" -- placeholder for other languages
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_4 = "" -- placeholder for other languages

-- Fighters Guild Bounty Quests
L.DQT_CYRODIIL_FIGHTERS_GUILD_BOUNTY_QUESTS_PREFIX = "Bounty: "

-- Necrom Bastion Nymic Quests
L.DQT_NECROM_QUESTS_BASTION_NYMIC_PREFIX = "Bastion Nymic - "

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
	-- In other language files, use SafeAddString instead, e.g. SafeAddString(_G[stringId], translation, 0)
	ZO_CreateStringId(stringId, translation)
end
