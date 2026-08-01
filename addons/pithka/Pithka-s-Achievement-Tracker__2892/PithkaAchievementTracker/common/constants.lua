-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.common = PITHKA.common or {}
PITHKA.common.constants = {}

-- convenient namespacing
local constants = PITHKA.common.constants

---------------------------------------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------------------------------------
constants.screenDimensions = {
    baseDungeons = {650, 550},
    trifectaDungeons = {950, 850},
    trials = {1150, 600},
    scoresAndTris = {950, 850},
}

constants.color = {
	-- rgb colors
	rgbClear		= {1,1,1,0},
	rgbWhite        = {1,1,1,.9},
	rgbGray         = {1,1,1,.45},
	rgbBlue   		= {128/255, 128/255, 1, 1},
	rgbGold			= {230/225, 230/225, 180/225, 1},
	rgbGreen        = {0.2, 1, 0.2, 1},

	-- hex colors
	hexBlue         = 'c8080ff',
	hexYellow       = 'cFFFF00',
	hexGold			= 'cc5c29e',
	
	-- alpha
	alphaWhite      = 1,
	allphaGray      =.45,
}

-- to do, update to "font" not "fonts"
constants.font = {
	-- fonts
	defaultFont     = "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin",
	boldFont        = 'ZoFontGameBold',
	smallFont       = "ZoFontGameSmall",
	smallThinFont   = "$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin",
    fixedWidthFont  = "$(PITHKA_CONSOLAS_FONT)|$(KB_15)|soft-shadow-thin",
	largeBoldFont   = "$(BOLD_FONT)|$(KB_20)|soft-shadow-thick",
}

constants.icon = {
	texture = "esoui/art/tutorial/ava_rankicon64_general.dds", -- star icon
	size = 23,
	color = constants.color.rgbWhite,
	tooltipAnchor = BOTTOM,
	tooltipColor = constants.color.hexGold,
	tooltipFont = constants.defaultFont,
}

constants.navIcon = {
	size = 45
}

constants.button = {
	size = 50
}

-- to do, update to "texture" not "textures"
constants.textures = {
		HM        = "esoui/art/campaign/gamepad/gp_bonusicon_scrolls.dds",
		SR        = "esoui/art/miscellaneous/gamepad/gp_icon_timer32.dds",
		ND        = "esoui/art/icons/mapkey/mapkey_groupboss.dds",
		TRI       = "esoui/art/icons/guildranks/guild_rankicon_misc11.dds",
		STAR      = "esoui/art/tutorial/ava_rankicon64_general.dds",
		LFG       = "esoui/art/lfg/lfg_tabicon_mygroup_over.dds",
		DUNGEON   = 'esoui/art/icons/poi/poi_dungeon_complete.dds',
		INSTANCE  = 'esoui/art/icons/poi/poi_groupinstance_complete.dds',
		TRIAL     = 'esoui/art/icons/mapkey/mapkey_solotrial.dds' ,
		CHECKOFF  = 'esoui/art/cadwell/checkboxicon_unchecked.dds',
		CHECKON   = 'esoui/art/cadwell/checkboxicon_checked.dds',
		PERSON    = 'esoui/art/tutorial/menubar_character_up.dds',
		TWOPEOPLE = 'esoui/art/tutorial/tutorial_idexicon_contacts_up.dds',
		GROUP     = 'esoui/art/treeicons/tutorial_idexicon_groups_up.dds',
		CHECK     = "esoui/art/buttons/accept_down.dds", 
		BOX       = "esoui/art/buttons/swatchframe_down.dds",
		X         = "esoui/art/buttons/decline_up.dds",
        LOCK      = "esoui/art/miscellaneous/locked_up.dds",

		HEALER    = "/esoui/art/lfg/lfg_icon_healer.dds",
		DPS       = "/esoui/art/lfg/lfg_icon_dps.dds",
		TANK      = "/esoui/art/lfg/lfg_icon_tank.dds",
		SUPPORT   = "/esoui/art/lfg/lfg_icon_support.dds",
		PVP       = "/esoui/art/lfg/lfg_icon_pvp.dds",
		CRAFTING  = "/esoui/art/lfg/lfg_icon_crafting.dds",
		GATHERING = "/esoui/art/lfg/lfg_icon_gathering.dds",
		EXPLORATION = "/esoui/art/lfg/lfg_icon_exploration.dds",
		SOCIAL    = "/esoui/art/lfg/lfg_icon_social.dds",
		OTHER     = "/esoui/art/lfg/lfg_icon_other.dds",
	}

-- Button textures with all states
constants.textureBundles = {
    HEALER = {
        up = "esoui/art/lfg/lfg_healer_up.dds",
        down = "esoui/art/lfg/lfg_healer_down.dds",
        over = "esoui/art/lfg/lfg_healer_over.dds",
        disabled = "esoui/art/lfg/lfg_healer_disabled.dds",
        pressed = "esoui/art/lfg/lfg_healer_pressed.dds"
    },
    TANK = {
        up = "esoui/art/lfg/lfg_tank_up.dds",
        down = "esoui/art/lfg/lfg_tank_down.dds",
        over = "esoui/art/lfg/lfg_tank_over.dds",
        disabled = "esoui/art/lfg/lfg_tank_disabled.dds",
        pressed = "esoui/art/lfg/lfg_tank_pressed.dds"
    },
    DPS = {
        up = "esoui/art/lfg/lfg_dps_up.dds",
        down = "esoui/art/lfg/lfg_dps_down.dds",
        over = "esoui/art/lfg/lfg_dps_over.dds",
        disabled = "esoui/art/lfg/lfg_dps_disabled.dds",
        pressed = "esoui/art/lfg/lfg_dps_pressed.dds"
    },
    SUPPORT = {
        up = "esoui/art/lfg/lfg_support_up.dds",
        down = "esoui/art/lfg/lfg_support_down.dds",
        over = "esoui/art/lfg/lfg_support_over.dds",
        disabled = "esoui/art/lfg/lfg_support_disabled.dds",
        pressed = "esoui/art/lfg/lfg_support_pressed.dds"
    },
    NORMAL = {
        up = "/esoui/art/lfg/lfg_normaldungeon_up.dds",
        down = "/esoui/art/lfg/lfg_normaldungeon_down.dds",
        over = "/esoui/art/lfg/lfg_normaldungeon_over.dds",
        disabled = "/esoui/art/lfg/lfg_normaldungeon_disabled.dds",
        pressed = "/esoui/art/lfg/lfg_normaldungeon_pressed.dds"
    },
    VETERAN = {
        up = "/esoui/art/lfg/lfg_veterandungeon_up.dds",
        down = "/esoui/art/lfg/lfg_veterandungeon_down.dds",
        over = "/esoui/art/lfg/lfg_veterandungeon_over.dds",
        disabled = "/esoui/art/lfg/lfg_veterandungeon_disabled.dds",
        pressed = "/esoui/art/lfg/lfg_veterandungeon_pressed.dds"
    },
    DUNGEON = {
        up = "/esoui/art/lfg/lfg_indexicon_dungeon_up.dds",
        down = "/esoui/art/lfg/lfg_indexicon_dungeon_down.dds",
        over = "/esoui/art/lfg/lfg_indexicon_dungeon_over.dds",
        disabled = "/esoui/art/lfg/lfg_indexicon_dungeon_disabled.dds",
        pressed = "/esoui/art/lfg/lfg_indexicon_dungeon_pressed.dds"
    },
    TRIAL = {
        up = "/esoui/art/lfg/lfg_indexicon_trial_up.dds",
        down = "/esoui/art/lfg/lfg_indexicon_trial_down.dds",
        over = "/esoui/art/lfg/lfg_indexicon_trial_over.dds",
        disabled = "/esoui/art/lfg/lfg_indexicon_trial_disabled.dds",
        pressed = "/esoui/art/lfg/lfg_indexicon_trial_pressed.dds"
    },
    GROUPFINDER = {
        up = "/esoui/art/mainmenu/menubar_group_up.dds",
        down = "/esoui/art/mainmenu/menubar_group_down.dds",
        over = "/esoui/art/mainmenu/menubar_group_over.dds",
        disabled = "/esoui/art/mainmenu/menubar_group_disabled.dds",
        pressed = "/esoui/art/mainmenu/menubar_group_pressed.dds"
    },
    COMPOSE = {
        up = "/esoui/art/mail/mail_tabicon_compose_up.dds",
        down = "/esoui/art/mail/mail_tabicon_compose_down.dds",
        over = "/esoui/art/mail/mail_tabicon_compose_over.dds",
        disabled = "/esoui/art/mail/mail_tabicon_compose_disabled.dds",
        pressed = "/esoui/art/mail/mail_tabicon_compose_pressed.dds"
    }
}

