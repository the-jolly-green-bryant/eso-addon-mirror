local Constants = {
    ADDON = {
        NAME = "NMGuildHall",
        DISPLAY_NAME = (GetString and GetString(NMGH_DISPLAY_NAME)) or "|cea4e49Neli's Misfits Guild Hub|r",
        VERSION = "9",
        SAVED_VARS_NAME = "NeliMisfitsSavedVars",
        SETTINGS_VERSION = 6,
        DEFAULT_GUILD_ID = 716827,
        INIT_DEFER_MS = 200
    },
    
    SLASH = {
        MAIN = "/nmgh",
        ALT = "/misfit",
        ZONE_ID_SHORT = "/zid",
        ZONE_ID_FULL = "/zoneID",
        COLLECTIBLE_ID_SHORT = "/cid",
        COLLECTIBLE_ID_FULL = "/collectionID",
        API_VERSION_SHORT = "/apiver",
        API_VERSION_FULL = "/apiversion",
        DEBUG_ICONS = "/nmghicons",
        IMPORT = "/nmgh_import",
        EXPORT = "/nmgh_export",
        RESET = "/nmgh_reset",
        CAMPAIGNS_SHORT = "/caid",
        CAMPAIGNS_FULL = "/campaignID",
        HELP = "/nmgh_help"
    },
    
    TELEPORT = {
        DEFAULT_CACHE_DURATION_SECONDS = 30,
        DEFAULT_REFRESH_COOLDOWN_SECONDS = 5,
        DEFAULT_REBUILD_MODE = "stale_async",
        DEFAULT_MAX_MEMBERS_TO_CHECK = 100,
        MINIMUM_CACHE_REBUILD_INTERVAL_MS = 5000,
        GUILD_HUB = {
            ["PC-EU"] = { owner = "@PhnxZ", houseId = 80 },
            ["PC-NA"] = { owner = "@neli.serendipity", houseId = 41 }
        }
    },
    
    CHAT_ICON = {
        DEFAULT_SIZE = 36,
        DEFAULT_SHOW = true,
        DEFAULT_MONOCHROME = false,
        DEFAULT_LOCKED = false,
        DRAG_THRESHOLD = 4,
        TEXTURES = {
            NORMAL = "NMGuildHall/Icons/new/misfit_logo.dds",
            NORMAL_PRESSED = "NMGuildHall/Icons/new/misfit_logo_pressed.dds",
            NORMAL_OVER = "NMGuildHall/Icons/new/misfit_logo_hover.dds",
            MONO = "NMGuildHall/Icons/new/mono_misfit_logo.dds",
            MONO_PRESSED = "NMGuildHall/Icons/new/mono_misfit_logo_pressed.dds",
            MONO_OVER = "NMGuildHall/Icons/new/mono_misfit_logo_hover.dds"
        },
        SETS = {
            new = {
                NORMAL = "NMGuildHall/Icons/new/misfit_logo.dds",
                NORMAL_PRESSED = "NMGuildHall/Icons/new/misfit_logo_pressed.dds",
                NORMAL_OVER = "NMGuildHall/Icons/new/misfit_logo_hover.dds",
                MONO = "NMGuildHall/Icons/new/mono_misfit_logo.dds",
                MONO_PRESSED = "NMGuildHall/Icons/new/mono_misfit_logo_pressed.dds",
                MONO_OVER = "NMGuildHall/Icons/new/mono_misfit_logo_hover.dds"
            },
            legacy = {
                NORMAL = "NMGuildHall/Icons/legacy/NMGUILD_legacy.dds",
                NORMAL_PRESSED = "NMGuildHall/Icons/legacy/NMGUILD_pressed_legacy.dds",
                NORMAL_OVER = "NMGuildHall/Icons/legacy/NMGUILD_over_legacy.dds",
                MONO = "NMGuildHall/Icons/legacy/NMGUILD_mono_legacy.dds",
                MONO_PRESSED = "NMGuildHall/Icons/legacy/NMGUILD_mono_pressed_legacy.dds",
                MONO_OVER = "NMGuildHall/Icons/legacy/NMGUILD_over_legacy.dds"
            }
        }
    },
    
    MESSAGE = {
        DEFAULT_RATE_LIMIT = 5,
        DEFAULT_RATE_WINDOW_MS = 1000,
        COLORS = {
            INFO = "ea4e49",
            WARNING = "ffcc33",
            ERROR = "ff3333",
            DEBUG = "9aa0a6"
        }
    },

    COMPATIBILITY = {
        REQUIRED_API_VERSION = 101049,
        DEPENDENCIES = {
            {name = "LibAddonMenu2", global = "LibAddonMenu2", required = true},
        },
        CONFLICTING_ADDONS = { }
    },

    UI = {
        BUTTON_WIDTH = 300,
        BUTTON_HEIGHT = 42,
        
        WINDOW = {
            DEFAULT_WIDTH = 700,
            DEFAULT_HEIGHT = 550,
            DEFAULT_X = 0,
            DEFAULT_Y = 0,
            MIN_WIDTH = 500,
            MIN_HEIGHT = 400,
            MAX_WIDTH = 1200,
            MAX_HEIGHT = 900,
            RESOURCE_TIMEOUT_MS = 10000,
            RESIZE_HANDLE_SIZE = 16
        },

        ICONS = {
            SETTINGS = {
                NORMAL = "esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds",
                PRESSED = "esoui/art/skillsadvisor/advisor_tabicon_settings_down.dds",
                OVER = "esoui/art/skillsadvisor/advisor_tabicon_settings_over.dds"
            },
            CLOSE = {
                NORMAL = "EsoUI/Art/Buttons/closebutton_up.dds",
                PRESSED = "EsoUI/Art/Buttons/closebutton_down.dds",
                OVER = "EsoUI/Art/Buttons/closebutton_over.dds"
            }
        },

        COLORS = {
            CRIMSON = {0.8, 0.2, 0.3, 1},
            CRIMSON_TEXT = "|cCC334C",
            TAB_ACTIVE_CENTER = {0.8, 0.2, 0.3, 0.9},
            TAB_ACTIVE_EDGE = {0.9, 0.3, 0.4, 0.8},
            TAB_INACTIVE_CENTER = {0.10, 0.10, 0.12, 0.8},
            TAB_INACTIVE_EDGE = {0.3, 0.3, 0.35, 0.6},
            TAB_HOVER_CENTER = {0.14, 0.14, 0.16, 0.9},
            TAB_HOVER_EDGE = {0.5, 0.5, 0.55, 0.8},
            TEXT_NORMAL = {0.7, 0.7, 0.7, 1},
            TEXT_HIGHLIGHT = {0.9, 0.9, 0.9, 1},
            TEXT_ACTIVE = {1, 1, 1, 1}
        },

        CAMPAIGN = {
            POP_TEXTURES = {
                [0] = "EsoUI/Art/Campaign/campaignbrowser_lowpop.dds",
                [1] = "EsoUI/Art/Campaign/campaignbrowser_medpop.dds",
                [2] = "EsoUI/Art/Campaign/campaignbrowser_hipop.dds",
                [3] = "EsoUI/Art/Campaign/campaignbrowser_fullpop.dds"
            },
            ALLIANCE_COLORS = {
                [1] = {1, 0.9, 0, 1},
                [2] = {1, 0, 0, 1},
                [3] = {0, 0.44, 1, 1}
            },
            CATEGORY_MAP = {
                ["Gray Host"] = "Alliance Locked",
                ["Ravenwatch"] = "Standard No-CP",
                ["Blackreach"] = "Standard",
                ["Icereach"] = "Below Level 50",
                ["CP Imperial City"] = "Imperial City",
                ["No-CP Imperial City"] = "No-CP Imperial City"
            }
        }
    },

    QUESTS = {
        ZONE_ALIASES = {
            ["Fargrave"] = "The Deadlands",
            ["Blackreach: Greymoor Caverns"] = "Western Skyrim",
            ["Blackreach: Arkthzand Cavern"] = "The Reach",
        },
        TYPES = {
            DAILY = QUEST_REPEAT_DAILY,
            WEEKLY = QUEST_REPEAT_WEEKLY,
            MONTHLY = QUEST_REPEAT_MONTHLY
        },
        PLEDGE_ORIGIN_TIMESTAMP = 1615168800, -- March 8, 2021
        SECONDS_PER_DAY = 86400
    },

    -- AvA zone IDs are used to avoid localized string comparisons where the API provides a zoneId.
    -- These are stable game zone IDs in the current API; callers should still fall back gracefully.
    AVA = {
        CYRODIIL_ZONE_ID = 181,
        IMPERIAL_CITY_ZONE_ID = 584,
    },

    MEDIA = {
        ICONS = {
            NM = "|t20:20:NMGuildHall/Icons/new/misfit_logo.dds|t",
            GOLD = "|t20:20:esoui/art/loot/icon_goldcoin_pressed.dds|t",
            CROWN = "|t25:25:esoui/art/currency/currency_crown.dds|t",
            GHouse = "|t25:25:esoui/art/mainmenu/menubar_guilds_up.dds|t",
            GMHouse = "|t25:25:esoui/art/lfg/lfg_indexicon_homeshow_up.dds|t",
            GrpTool = "|t25:25:esoui/art/mainmenu/menubar_group_up.dds|t",
            GrpLead = "|t25:25:esoui/art/compass/groupleader.dds|t",
            GrpShare = "|t25:25:esoui/art/compass/quest_icon_assisted.dds|t",
            GrpLeave = "|t25:25:esoui/art/contacts/gamepad/gp_social_status_dnd.dds|t",
            Web = "|t25:25:esoui/art/tutorial/help_tabicon_tutorial_up.dds|t",
            Opt = "|t25:25:esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds|t",
            RldUI = "|t25:25:esoui/art/ava/ava_keepstatus_icon_collectionrate.dds|t",
            Way = "|t25:25:esoui/art/icons/poi/poi_wayshrine_complete.dds|t",
            Ald = "|t25:25:esoui/art/compass/ava_flagaldmeri.dds|t",
            Ebon = "|t25:25:esoui/art/compass/ava_flagebonheart.dds|t",
            Dag = "|t25:25:esoui/art/compass/ava_flagdaggerfall.dds|t",
            Neu = "|t25:25:esoui/art/compass/ava_flagneutral.dds|t",
            Trv = "|t25:25:esoui/art/icons/achievements_indexicon_exploration_up.dds|t",
            Pld = "|t25:25:esoui/art/treeicons/achievements_indexicon_veterandungeons_up.dds|t",
        }
    }
}

-- Backward compatibility alias; UI.WINDOW is the canonical source.
Constants.WINDOW = Constants.UI.WINDOW
NMGuildHall = NMGuildHall or {}
NMGuildHall.Constants = Constants

return Constants
