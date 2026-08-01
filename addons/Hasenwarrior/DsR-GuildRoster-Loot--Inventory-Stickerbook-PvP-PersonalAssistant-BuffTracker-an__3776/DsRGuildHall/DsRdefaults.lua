-- Create namespace
DsRdefaults = {}
local DsRdefaults = DsRdefaults  or {}

DsRdefaults.name = "DsRdefaults"

DSRLH_WORLD_LEGERDEMAIN    = 1
DSRLH_WORLD_EXCAVATION     = 2
DSRLH_WORLD_WEREWOLF       = 3
DSRLH_WORLD_SOUL           = 4
DSRLH_WORLD_SCRYING        = 5
DSRLH_WORLD_VAMPIRE        = 6

-------------------------------------------------------------------------------------------------------------------------------------------------
function copyDeep(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[copyDeep(orig_key)] = copyDeep(orig_value)
        end
        setmetatable(copy, copyDeep(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function DsRdefaults:Defaults()

    local defAutoInvite = {
        maxSize        = 12,
        restart        = true,
        cyrCheck       = false,
        autoKick       = true,
        kickDelay      = 400,
        watchStr       = "",
        showPanel      = true,
        ShowGroupJoin  = true,
        HideGroupLeave = true,
        ResetTable     = true,
        ColorTitle     = {0.6196078658, 0.7098039389, 0.8039215803, 1},
        ColorPlayer    = {1, 1, 1, 1},
        ColorCount     = {1, 0.1921568662, 0.1960784346, 1},
        TableLenght    = 10,
        TableOffsetX   = 20,
        TableOffsetY   = 75,
        TablehiddenUI  = true,
        DeathbgAlpha   = 50,

        welcomeOnOff   = false,
        welcome = {false, false, false, false, false},
	    message = {
	    	"Welcome %1 to guild 1",
	    	"Welcome %1 to guild 2",
	    	"Welcome %1 to guild 3",
	    	"Welcome %1 to guild 4",
	    	"Welcome %1 to guild 5"
	    },
        GuildInfRosterOnOff   = false,
        GuildInfRankOnOff     = true,
        GuildInfRecrutOnOff   = true,
        GuildInfNoGuildMem    = true,
        GuildMasterJoin       = true,
        GuildMasterJoinSound  = true,
        FriendsOnOff          = false,
        ExtraNamesLogin       = "",
        FriendsColor          = true,
    }

    local defLootManager = {
        ChatTradePrice    = true,
        ScreenTradePrice  = true,
        HistoryTradePrice = true,
        TakeOneOnOff      = true,
        DeveloperMode     = false,
        DefaultChat       = 7,
        DefaultChatONOFF  = true,

        LootContainer_FM          = true,
        LootContainer_BGR         = true,
        LootContainer_BVS         = true,
        LootContainer_hAR         = true,
        LootContainer_ICversorger = true,
        LootContainer_ICschmied   = true,
        LootContainer_ICschneider = true,
        LootContainer_ICalchemi   = true,
        LootContainer_ICrunen     = true,
        LootContainer_ICholz      = true,
        LootContainer_EAschmuck   = true,
        LootContainer_EAversorger = true,
        LootContainer_EAschneider = true,
        LootContainer_EAschmied   = true,
        LootContainer_EAalchemi   = true,
        LootContainer_EArunen     = true,
        LootContainer_EAholz      = true,

        ScreenfNirn       = true,
        ScreensNirn       = true,
        ScreenKuta        = true,
        ScreenHakeijo     = true,
        ScreenLuminousInk = true,
        ScreenRubyblossom = true,
        ScreenMourningdew = true,
        ScreenPerfectRoe  = true,
        ScreenAetherialDust  = true,
        ScreenAethericCipher = true,
        ScreenOnOff      = false,
        ScreenQualiloot  = "3 - |c259EFAÜberragend|r",
        ScreenBestrebung = true,

        ChatfNirn             = true,
        ChatsNirn             = true,
        ChatKuta              = true,
        ChatHakeijo           = true,
        ChatLuminousInk       = true,
        ChatRubyblossom       = true,
        ChatMourningdew       = true,
        ChatPerfectRoe        = true,
        ChatAetherialDust     = true,
        ChatAethericCipher    = true,
        ChatOnOff             = false,
		ChatTrait			  = true,
        ChatQualiloot         = "3 - |c259EFAÜberragend|r",
        ChatGroupLoot         = true,
        ChatQualiGroupLoot    = "3 - |c259EFAÜberragend|r",
        ChatArchivments       = true,
        ChatArchivmentsStatus = true,
        ChatXP                = false,
        ChatXPtxt             = "1150",
        ChatGold              = true,
        ChatGoldtxt           = "500",
        ChatUnerschrocken     = true,
        Chatetickets          = true,
        ChatTransmut          = true,
        ChatBestrebung        = true,
        ChatEndless           = true,
        ChatIMPfragments      = true,
        ChatTomeChallenge     = true,
        ChatTomePoints        = true,
        ChatTomePointCach     = true,
        ChatTomeToken         = true,
        ChatTradeBars         = true,
        ChatBookLoot          = true,
        ChatXPskills          = true,
        ChatXPweapon          = true,
        ChatXParmor           = true,
        ChatXPguild           = true,
        ChatXPava             = true,
        ChatXPexcavation      = true,
        ChatXPscrying         = true,
        ChatXPlegerdemain     = true,
        ChatXPsoulmagic       = true,
        ChatXPvampire         = true,
        ChatXPwerewolf        = true,
        ChatXPcrafting        = true,
        ChatXPblacksmithing   = true,
        ChatXPclothier        = true,
        ChatXPenchanting      = true,
        ChatXPalchemy         = true,
        ChatXPprovisioner     = true,
        ChatXPwoodworking     = true,
        ChatXPjewelrymaking   = true,

        HistoryOnOff                       = false,
        HistoryContainerShowTime           = 6,
        HistoryPersistantContainerShowTime = 12,
        HistoryMaxItems                    = 10,
        HistoryShowInMenus                 = true,
        HistoryShowType = {
            [DSRLH_WORLD_LEGERDEMAIN]  = true,
            [DSRLH_WORLD_EXCAVATION]   = true,
            [DSRLH_WORLD_VAMPIRE]      = true,
            [DSRLH_WORLD_SOUL]         = true,
            [DSRLH_WORLD_SCRYING]      = true,
            [DSRLH_WORLD_WEREWOLF]     = true,
        },

        ChestFoundOnOff        = false,
        ChestFoundOnlyEN       = true,
        en_chestDifficultyName = {[1] = "Simple",  [2] = "Intermediate",     [3] = "Advanced",  [4] = "Master"},
        de_chestDifficultyName = {[1] = "Einfach", [2] = "Durchschnittlich", [3] = "Schwierig", [4] = "Meisterhaft"},
    
        DsRReminderfoodOnOff  = true,
        DsRReminderfoodfalse  = true,
        DsRReminderBuffFoodMinTime = "5",
        DsRReminderxpOnOff     = true,
        DsRReminderxpfalse     = false,
        DsRReminderxpMinTime   = "2",
        DsRReminderapOnOff     = true,
        DsRReminderapfalse     = false,
        DsRReminderapMinTime   = "2",

        DsRDailyCraftAlchemy   = true,
        DsRDailyCraftProvision = true,

        PreCraftProfessions = {
            [CRAFTING_TYPE_BLACKSMITHING]   = true,
            [CRAFTING_TYPE_CLOTHIER]        = true,
            [CRAFTING_TYPE_WOODWORKING]     = true,
            [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
            [CRAFTING_TYPE_ENCHANTING]      = true,
        },
        characters = {},
        charplayed = {},

        DsRBuffEnable     = true,
        DsRBuffTxTonoff   = false,
        DsRBuffTXTsize    = 20,
        DsRBuffTXTcol     = {1, 1, 1, 1},
        DsRBuffDDSsize    = 36,
        DsRBuffBarColor   = {0, 1, 0, 0.4},
        DsRBuffTimercol   = {0.604, 0.804, 0.196, 1},
        DsRBuffCountcol   = {0.2980392277, 0.8823529482, 1, 1},
        DsRBuffCountsize  = 24,
        DsRBuffWindowxOff = -350,
        DsRBuffWindowyOff = -100,
        DsRBuff_CurrentKey = "",
        DsRBuff_CurrentRow = 15,
        DsRBuff_CurrentChar = "",
        DsRBuffSettingXoff = -350,
        DsRBuffSettingYoff = -100,
        DsRBuffMultiColor  = true,
        DsRBuffMultiBuffColors = {
            DamageShield    = {1, 0.8, 0.2, 0.4},   -- Gold
            Default         = {0.4, 0.26, 0.13, 0.4},   -- Lila
            Heal            = {0, 1, 0, 0.4},       -- grün
            Damage          = {0.3, 1, 0.8, 0.4},   -- Türkis
            Ulti            = {1, 1, 0.4, 1},       -- Gelb
            SelfBuff        = {0.4, 0.7, 1, 0.4},   -- Hellblau
            OtherBuff       = {1, 0.3, 0.3, 0.4},   -- Rot
            GroupBuff       = {0.5, 0.0, 0.5, 0.4}, -- Lila
            OneColor        = {0, 1, 0, 0.4},
        },
    }

    local defstickerbook = {
        autoBind         = false,
        show = {
            bag        = true,
            bank       = true,
            housebank  = true,
            guild      = true,
            guildstore = true,
            crafting   = true,
            transmute  = true,
            trading    = true,
        },
        chatSystemShow   = true,
        chatMessageShow  = true,
        iconOffset       = 0,
        iconStoreOffset  = 0,
        showRequestLink  = true,
        requestInWhisper = true,
        requestPrefix    = GetString(DsRGuildBind_req_requestPrefixdefault),
        Chatuncollect    = false,
    }
    
    local defpvpDeep = {
        kills 		   = 0,		-- Total number of kills in which player has been involved
        killingBlows   = 0,		-- Total number of killing blows in Battleground
        killingBlowsAD = 0, 	-- Aldmeri    - number of killing blows player has dealt
        killingBlowsEP = 0, 	-- Ebenerz    - number of killing blows player has dealt
        killingBlowsDC = 0, 	-- Dolchsturz - number of killing blows player has dealt
        deaths 		   = 0,		-- Total number of times player has died in PvP
        alliancePoints = 0,		-- AP gained
    }

    local defpvp = {
        PvPportImpOnOff        = true,
        PvPportImpGroup        = true,
        PvPAP                  = true,
        PvPAPvalue             = "150",
        PvPAPrep               = true,
        PvPAPdeath             = true,
        PvPAPoffenschat        = true,
        PvPAPoffensscreen      = true,
        PvPAPdeffenschat       = true,
        PvPAPdeffensscreen     = true,
        PvPAPressurect         = true,
        PvPAPmedal             = true,
        PvPAPmatch             = true,
        PvPAPquest             = true,
        PvPTelVar              = true,
        PvPTelVartxt           = 50,
        PvPTelVarSaver         = 0,
        PvPTelVarSaverQAsGroup = false,
        PvPCakeRem             = true,
        PvPKillenableFrame     = true,
        PvPKillframeColor      = {0.51764708757041, 1, 0.24705882370472, 1},
        PvPKillBlowChat        = true,
        PvPKillScreen          = true,
        PvPKillChat            = true,
        enableQueueBar         = true,
        statsBarLocked         = false,
        hideInPvE 		       = true,
        sessionStats 	       = copyDeep(defpvpDeep),
        scoreWindowScale       = -20,
        scoreWindowanchorPoint = 9,
        scoreWindowxOff        = -350,
        scoreWindowyOff        = -100,
        PvPdoorOnOff           = true,
        PvPdoorPinRGB = {
            r = 0.5176470876,
            g = 1,
            b = 0.5803921819
        },
        PvPdoorPinSize   = 20,
        PvPdoorPinLevel  = 100,
        PvPdoorImperial  = true,
        PvPScampImperial = true,

        PvPtimetable                 = true,
        PvPtimetableTop              = 0,
        PvPtimetableLeft             = 0,
        PvPeventtimers               = false,
        PvPmaptimers                 = true,
        PvPsaved_timers              = {},

        PvPstatusenabled            = true,
        PvPstatuspositionLocked     = false,
        PvPstatusshowKeeps          = true,
        PvPstatusshowResources      = true,
        PvPstatusshowOutposts       = true,
        PvPstatusshowVillages       = true,
        PvPstatusshowTemples        = true,
        PvPstatusshowDestructibles  = true,
        PvPstatusdefaultColor = {
            r = 1,
            g = 1,
            b = 1
        },
        PvPstatuscooldownColor = {
            r = 0,
            g = 1,
            b = 0
        },
        PvPstatusflipsAtPositiveColor = {
            r = 0,
            g = 1,
            b = 0
        },
        PvPstatusflipsAtNegativeColor = {
            r = 1,
            g = 0,
            b = 0
        },
        PvPstatushideOnWorldMap   = true,
        PvPstatusshowFlags        = true,
        PvPstatusshowSieges       = true,
        PvPstatusshowOwnerChanges = true,
        PvPstatusshowActionTimers = true,
        PvPstatusshowBackground   = false,

        PvPKeepInfoOnOff   = false,
        PvPKeepInfoUpdate  = 1,
        PvPKeepInfoBGtrans = false,
        PvPKeepInfoUI      = {
            ["X"] = 0,
            ["Y"] = 0,
        },
        PvPkillFeedCyro = false,
        PvPkillFeedImp  = true,
        PvPICsewers     = true,

        PvPCrownEnabled        = true,
        PvPCrownArrowSize      = 64,
        PvPCrownArrowPos       = -100,
        PvPCrownDebug          = false,
        PvPCrownList           = true,

        PvPCrownTableOffsetX   = 200,
        PvPCrownTableOffsetY   = 200,

        PvPGroupAttackTime     = 5,
    }
    
    local defAllianceColor = {
        DsRColorad = {
            r = 0.734375,
            g = 0.64453125,
            b = 0.27734375
        },
        DsRColorep = {
            r = 0.8671875,
            g = 0.35546875,
            b = 0.3046875
        },
        DsRColordc = {
            r = 0.30859375,
            g = 0.50390625,
            b = 0.73828125
        },
        DsRColornoAlliance = {
            r = 1,
            g = 1,
            b = 1
        },
    }
    
    DsRAutoINV.cfg               = ZO_SavedVars:NewAccountWide("DsRGuildRosterSettings", 1, "AutoInvite", defAutoInvite)
    DsRGuildLoot.sV              = ZO_SavedVars:NewAccountWide("DsRGuildRosterSettings", 1, "LootManager", defLootManager)
    DsRGuildPvP.pvp              = ZO_SavedVars:NewAccountWide("DsRGuildRosterSettings", 1, "PvP", defpvp)
    DsRGuildPvP.Acol             = ZO_SavedVars:NewAccountWide("DsRGuildRosterSettings", 1, "AllianceColor", defAllianceColor)
    DsRGuildBind.bind            = ZO_SavedVars:NewAccountWide("DsRGuildRosterSettings", 1, "CollectionBind", defstickerbook)
end
