CLR = {
	cancer = {
		hex = 'ff009a',
		packed = {255, 0, 154, 1}
	},
	bright = {
		hex = 'd100d1',
		packed = {209, 0, 209, 1}
	},
	soft = {
		hex = 'ba00a9',
		packed = {186, 0, 169, 1}
	},
	default = {
		hex = '',
		packed = {0.46274510025978, 0.73725491762161, 0.76470589637756, 1}
	},
	off = {
		hex = '808080',
		packed = {128,128,128,0.5}
	},
	mag = {
		hex = '002D7F',
		packed = {0, 0, 255, 1}
	},
	stam = {
		hex = '009966',
		packed = {0, 128, 0, 1}
	},
	health = {
		hex = 'E72727',
		packed = {231, 39, 39, 1}
	},
	nodata = {
		hex = 'E72727',
		packed = {231, 39, 39, 0.3}
	},
	white = {
		hex = 'FFFFFF',
		packed = {255, 255, 255, 1}
	}
}

-- TODO: Update list when new trials drop
-- Craglorn | BaseGame
TRIAL_HEL_RA_CITADEL = 1
TRIAL_AETHERIAN_ARCHIVE = 2
TRIAL_SANCTUM_OPHIDIA = 3
TRIAL_DRAGONSTAR_ARENA = 4
-- Reapers March | DLC: Thiefsguild
TRIAL_MAW_OF_LORKHAJ = 5
-- Wrothgar | DLC: Orsinium
TRIAL_MAELSTROM_ARENA = 6
-- Vvardenfell | Addon: Morrowind
TRIAL_HALLS_OF_FABRICATION = 7
-- Clockwork City | DLC: Clockwork City
TRIAL_ASYLUM_SANCTORIUM = 8
-- Summerset | Addon: Summerset
TRIAL_CLOUDREST	= 9
-- Murkmire | DLC: Murkmire
TRIAL_BLACKROSE_PRISON = 11
-- Elsywr | Addon: Elsywr
TRIAL_SUNSPIRE = 12

RaidTools = {}
RaidTools.name = 'RaidTools'
RaidTools.color_name = '|cffffffRaid|r|c'.. CLR.cancer.hex ..'Tools|r'
RaidTools.version = '1.1'
RaidTools.author = '|c'.. CLR.cancer.hex ..'Apfelstrudel [EU: @apfelstrudellq]|r'

RaidTools.WM = WINDOW_MANAGER

RaidTools.storage_name = 'RaidToolsStorage'
RaidTools.storage_version = '16'
RaidTools.storage_defaults = {
	initialized = false,
	debug = false,
	weekly = {
		end_date = 0,
		new_weekly_info_displayed = false,
		trial = {
			raid_id = -1,
			characters = {}
		},
		challenge = {
			raid_id = -1,
			characters = {}
		}
	},
	alltime = {
		[TRIAL_HEL_RA_CITADEL] = {},
		[TRIAL_AETHERIAN_ARCHIVE] = {},
		[TRIAL_SANCTUM_OPHIDIA] = {},
		[TRIAL_DRAGONSTAR_ARENA] = {},
		[TRIAL_MAW_OF_LORKHAJ] = {},
		[TRIAL_MAELSTROM_ARENA] = {},
		[TRIAL_HALLS_OF_FABRICATION] = {},
		[TRIAL_ASYLUM_SANCTORIUM] = {},
		[TRIAL_CLOUDREST] = {},
		[TRIAL_BLACKROSE_PRISON] = {},
		[TRIAL_SUNSPIRE] = {}
	},
	modules = {
		weekly_info = true,
		leaderboard_info = true,
		status_bar = true,
		death_alert = true,
		death_recap = true,
		group_overlay = true,
		raid_history = true,
		as_helper = false,
		--convenience
		auto_polymorph = false,
		buff_food_checker = false,
		auto_recharge_weapons = false,
		auto_repair_armour = false,
		group_loot = false,
		group_notifications = false,
		auto_repair_at_merchant = false,
		reposition_attribute_bars = false
	},
	config = {
		ui = {
			x = 0,
			y = 0
		},
		asui = {
			x = 0,
			y = 0,
			border = true,
			notify = {
				teleport_strikes = false, -- felms teleport
				heaven_storm = false, -- kite
				bolts = false, -- interrupt
				sphere_spawn = false,
			},
		},
		spc = {
			active = false,
			x = 0,
			y = 0
		},
		powass = {
			active = false,
			x = 0,
			y = 0
		},
		cp = {
			active = false,
			x = 0,
			y = 0
		},
		groupbuffs = {
			only_dds = false,
			only_as_key_role = false
		},
		warhorn = {
			x = 0,
			y = 0,
			active = true,
			only_as_key_role = false
		},
		vote = {
			x = 0,
			y = 0,
			active = true
		},
		attributes = {
			health = {x = 100, y = 100},
			magicka = {x = 100, y = 100},
			stamina = {x = 100, y = 100}
		},
		userid_instead_of_name = false,
		random_ready_checks = false,
		coloured_ready_checks = false,
		status_bar_border = true,
		hide_dd_deaths = false,
		go_userid = false,
		jokes = false,
		libgroupsocket = true
	},
	raid_history = {},
	game_version_string = 'eso.live.3.3.11.1585543',
	addon_storage_version = 0.5
}

RaidTools.ready_check_messages = {
	'Ready to wipe?',
	'Kick the raid-lead',
	'LFG=Lets raid Fungal Grotto',
	'Why no normal ready checks?',
	'Is this normal-mode?',
	'Lets go bois',
	'Ready to smash that like button?',
	"I'm a pink fluffy unicorn"
}
-- /script CHAT_SYSTEM:AddMessage(GetZoneId(GetUnitZoneIndex('player'))) 
RaidTools.trial_zones = {
	[TRIAL_HEL_RA_CITADEL] = 636,
	[TRIAL_AETHERIAN_ARCHIVE] = 638,
	[TRIAL_SANCTUM_OPHIDIA] = 639,
	[TRIAL_DRAGONSTAR_ARENA] = 635,
	[TRIAL_MAW_OF_LORKHAJ] = 725,
	[TRIAL_MAELSTROM_ARENA] = 677,
	[TRIAL_HALLS_OF_FABRICATION] = 975,
	[TRIAL_ASYLUM_SANCTORIUM] = 1000,
	[TRIAL_CLOUDREST] = 1051,
	[TRIAL_BLACKROSE_PRISON] = 1082,
	[TRIAL_SUNSPIRE] = 1121
}

RaidTools.current_instance = false
RaidTools.trial = {
	_update_interval = 1000,
	_status_bar_live = false,
	in_progress = false,
	started = false,
	hard_mode = false,
	target_time_failed = false,
	raid_id = 0,
	target_time = 0
}
RaidTools.group = {} -- UserID based group data
RaidTools.deaths = {} -- External variable in case someone exits the group
RaidTools.resurrections = {} -- Keep those locally
RaidTools.notifications = {} -- Notifications for leaderboard thingies
RaidTools.characters = {} -- Account info
RaidTools._leaderboards = {
	weekly = {}, 
	alltime = {}, 
	class_conform_weekly = {}
}

RaidTools._tester = {
	--
	-- Dev
	--
	'@apfelstrudellq', 

	--
	-- Tester
	-- 
	'@Arishok33',
	'@Chrunch',
	'@Nemata6',
	'@Nemata7', 
	'@MrSmith118',

	--
	-- Etc
	--	
	'@LukeG92',
	'@sushiman573',
	'@Velarion',
	'@TheExkaliburg',
	'@AlphariusOmegon25'
}

RaidTools.tester_only_mode = false

RaidTools.leaderboard_info_update = 0

RaidTools.storage = nil

--
-- Globals
--

UID = GetDisplayName() 
NAME = GetUnitName('player')
UNAME = GetUniqueNameForCharacter(NAME)
ACTIVE_CHAR_ID = nil

for i = 1, GetNumCharacters() do
	local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)
	name = name:gsub('%^.+', '')
	if name == NAME then ACTIVE_CHAR_ID = i end
	RaidTools.characters[i] = {
		name = name,
		gender = gender,
		level = level,
		class = classId,
		race = raceId,
		alliance = alliance,
		id = id,
		location = locationId
	}
	RaidTools.characters[i].uname = GetUniqueNameForCharacter(RaidTools.characters[i].name)
end

CHAR = RaidTools.characters[ACTIVE_CHAR_ID]

RT_TX = {
	sushi 			= 'RaidTools/icons/raidtools_1.dds',
	yoda 			= 'RaidTools/icons/raidtools_2.dds',
	whisky 			= 'RaidTools/icons/raidtools_3.dds',
	unicorn 		= 'RaidTools/icons/raidtools_4.dds',
	ok 				= 'RaidTools/icons/raidtools_5.dds',
	eggplant 		= 'RaidTools/icons/raidtools_6.dds',
	beer 			= 'RaidTools/icons/raidtools_7.dds',
	b 				= 'RaidTools/icons/raidtools_8.dds',
	rainbow			= 'RaidTools/icons/raidtools_9.dds',
	lightsaber_green= 'RaidTools/icons/raidtools_10.dds',
	poop 			= 'RaidTools/icons/raidtools_11.dds',
}

function GetRTTexture(key)
	return RT_TX[key]
end