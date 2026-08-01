TOMGuildsAddon = TOMGuildsAddon or {}
local TGAAddon = TOMGuildsAddon
TGAAddon.name = "TOMGuildsAddon"
TGAAddon.variableVersion = 1
TGAAddon.author    = "Splat"
--TGAAddon.campaignIdCyr = 101
--TGAAddon.campaignIdIC  = 95
TGAAddon.col_grn   = ZO_ColorDef:New("66ff66")
TGAAddon.col_red   = ZO_ColorDef:New("ff6666")
TGAAddon.col_pur   = ZO_ColorDef:New("9b30ff")
TGAAddon.myAlly    = GetUnitAlliance("player")
TGAAddon.myAllyCol = GetAllianceColor(TGAAddon.myAlly)
TGAAddon.myAllyIco = TGAAddon.myAllyCol:Colorize(zo_iconFormatInheritColor(GetAllianceSymbolIcon(TGAAddon.myAlly),24,24))

TGAAddon.svChar    = {}
TGAAddon.svCharDef = {
	autoAcceptPvpQ = true,
	autoAcceptChat = true,
  	gdmarkers = true,
  	hrcmarkers = true,
  	ghmarkers = true,
  	icmarkers = true,
  	tbagmarkers = true,
  	presmarkers = true,
        iccampaignid = 95,
        cyrocampaignid = 101,
        secretmode = true,
        enclogtrial = false,
        enclogdungeon = false,
        enclogarena = false,
        enclogcyro = false,
        enclogic = false,
  	semarkers = true,
  	magesguildmarkers = false,
	xui = 350,
	yui = 350
}

--/script OSI.PrintMyPosition()

local TOM_TEXTURES = {
    ["@M1yuk1"]    = "TOMGuildsAddon/players/Miyuki.dds",
    ["@Splatadude"] = "TOMGuildsAddon/players/Splat" .. math.random(1,4) .. ".dds",
    ["@DarthIra"] = "TOMGuildsAddon/players/DarthIra.dds",
    ["@Karashiin"] = "TOMGuildsAddon/players/Karashiin.dds",
    ["@Zaembylae"] = "TOMGuildsAddon/players/Zaembylae.dds",
    ["@Aurandel"] = "TOMGuildsAddon/players/Aurandel.dds",
    ["@Airingil"] = "TOMGuildsAddon/players/Airingil.dds",
    ["@Nemesis180"] = "TOMGuildsAddon/players/Nemesis180.dds",
    ["@RealBlue"] = "TOMGuildsAddon/players/RealBlue.dds",
    ["@OutworldDestroyer's"] = "TOMGuildsAddon/players/OutworldDestroyers.dds",
    ["@ZebaLive"] = "TOMGuildsAddon/players/ZebaLive.dds",
    ["@Razersblade"] = "TOMGuildsAddon/players/Razersblade.dds",
    ["@ZakkDV"] = "TOMGuildsAddon/players/ZakkDV.dds",
    ["@Silmos"] = "TOMGuildsAddon/players/Silmos.dds",
    ["@Varana312"] = "TOMGuildsAddon/players/Varana.dds",
    ["@Celestial_Cat97"] = "TOMGuildsAddon/players/Celestial.dds",
    ["@Manitaropitas"] = "TOMGuildsAddon/players/Manitaropitas.dds",
    ["@VoiKKari"] = "TOMGuildsAddon/players/VoiKKari.dds",
    ["@StormDancer46"] = "TOMGuildsAddon/players/Stormdancer.dds",
    ["@DeMonBuNneH"] = "TOMGuildsAddon/players/DeMonBuNneH.dds",
    ["@Alienoutlaw226"] = "TOMGuildsAddon/players/Alienoutlaw.dds",
    ["@m3inii"] = "TOMGuildsAddon/players/TritanArtz.dds",
    ["@Linsia1"] = "TOMGuildsAddon/players/Linsia.dds",
    ["@Treuce"] = "TOMGuildsAddon/players/Treuce.dds",
    ["@Lord_Dusty"] = "TOMGuildsAddon/players/LordDusty.dds",
}

TGAt = {}
fchecker = false
xsizer = 1.2

local ICON_APPRENTICE = nil
local ICON_ATRONACH = nil
local ICON_LADY = nil
local ICON_LORD = nil
local ICON_LOVER = nil
local ICON_MAGE = nil
local ICON_RITUAL = nil
local ICON_SERPENT = nil
local ICON_SHADOW = nil
local ICON_STEED = nil
local ICON_THIEF = nil
local ICON_TOWER = nil
local ICON_WARRIOR = nil

local ICON_TRIALDUMMYONE = nil
local ICON_TRIALDUMMYTWO = nil

local RESOURCERESTORE = nil
local BANKER = nil
local MERCHANT = nil
local ARMORYASSISTANT = nil
local RAGPICKER = nil
local REDUCEVAMPIRESTAGE = nil
local TRANSMUTESTATION = nil
local FORMERGUILDMEMBERS = nil
local COOKINGFIRE = nil
local OUTFITSTATION = nil
local ARMORYSTATION = nil
local ENCHANTINGSTATION = nil
local ALCHEMYSTATION = nil
local ICON_WELCOME = nil

local ICON_ARBORETUM_DC = nil
local ICON_TEMPLE_DC = nil
local ICON_NOBLES_DC = nil
local ICON_ELVEN_DC = nil
local ICON_MEMORIAL_DC = nil
local ICON_ARENA_DC = nil
local ICON_BANK_DC = nil
local ICON_EXIT_DC = nil

local ICON_ARBORETUM_EP = nil
local ICON_TEMPLE_EP = nil
local ICON_NOBLES_EP = nil
local ICON_ELVEN_EP = nil
local ICON_MEMORIAL_EP = nil
local ICON_ARENA_EP = nil
local ICON_BANK_EP = nil
local ICON_EXIT_EP = nil

local ICON_ARBORETUM_AD = nil
local ICON_TEMPLE_AD = nil
local ICON_NOBLES_AD = nil
local ICON_ELVEN_AD = nil
local ICON_MEMORIAL_AD = nil
local ICON_ARENA_AD = nil
local ICON_BANK_AD = nil
local ICON_EXIT_AD = nil

local ICON_HRC_A = nil
local ICON_HRC_B = nil
local ICON_HRC_C = nil
local ICON_HRC_D = nil
local ICON_HRC_E = nil
local ICON_HRC_F = nil

local ICON_SE_WAMASU = nil
local ICON_SE_GRYPHON = nil
local ICON_SE_WAMASU = nil

local MARKER_NUMBER_ONE = nil
local MARKER_NUMBER_TWO = nil
local MARKER_NUMBER_THREE = nil
local MARKER_NUMBER_FOUR = nil
local MARKER_NUMBER_FIVE = nil
local MARKER_NUMBER_SIX = nil
local MARKER_NUMBER_SEVEN = nil
local MARKER_NUMBER_EIGHT = nil
local MARKER_NUMBER_NINE = nil
local MARKER_NUMBER_TEN = nil
local MARKER_NUMBER_ELEVEN = nil
local MARKER_NUMBER_TWELVE = nil
local MARKER_NUMBER_CLEAR = nil

local VSEMARKER_LION_A
local VSEMARKER_LION_B
local VSEMARKER_LION_C
local VSEMARKER_LION_D
local VSEMARKER_LION_E

local VSEMARKER_GRYPHON_A
local VSEMARKER_GRYPHON_B
local VSEMARKER_GRYPHON_C
local VSEMARKER_GRYPHON_D
local VSEMARKER_GRYPHON_E

local VSEMARKER_WAMASU_A
local VSEMARKER_WAMASU_B
local VSEMARKER_WAMASU_C
local VSEMARKER_WAMASU_D
local VSEMARKER_WAMASU_E

local ICON_MAGES_GUILD_1 = nil
local ICON_MAGES_GUILD_2 = nil
local ICON_MAGES_GUILD_3 = nil
local ICON_MAGES_GUILD_4 = nil
local ICON_MAGES_GUILD_5 = nil
local ICON_MAGES_GUILD_6 = nil
local ICON_MAGES_GUILD_7 = nil
local ICON_MAGES_GUILD_8 = nil
local ICON_MAGES_GUILD_9 = nil

local currentBoss = nil

local deathiconstank = { 'TOMGuildsAddon/other/TBag.dds', 'TOMGuildsAddon/other/Gravestone.dds', 'TOMGuildsAddon/other/Blamethehealer.dds', 'TOMGuildsAddon/other/Sleep.dds', 'TOMGuildsAddon/other/Crime.dds', 'TOMGuildsAddon/other/Floor.dds', 'TOMGuildsAddon/other/Dodo.dds', 'TOMGuildsAddon/other/Cooldeath.dds', 'TOMGuildsAddon/other/Doingscience.dds', 'TOMGuildsAddon/other/Soulgems.dds' }

local deathiconsheal = { 'TOMGuildsAddon/other/TBag.dds', 'TOMGuildsAddon/other/Gravestone.dds', 'TOMGuildsAddon/other/Sleep.dds', 'TOMGuildsAddon/other/Crime.dds', 'TOMGuildsAddon/other/Floor.dds', 'TOMGuildsAddon/other/Dodo.dds', 'TOMGuildsAddon/other/Cooldeath.dds', 'TOMGuildsAddon/other/Doingscience.dds', 'TOMGuildsAddon/other/Soulgems.dds' }

local deathiconsdps = { 'TOMGuildsAddon/other/TBag.dds', 'TOMGuildsAddon/other/Donotres.dds', 'TOMGuildsAddon/other/Gravestone.dds', 'TOMGuildsAddon/other/Blamethehealer.dds', 'TOMGuildsAddon/other/Sleep.dds', 'TOMGuildsAddon/other/Crime.dds', 'TOMGuildsAddon/other/Floor.dds', 'TOMGuildsAddon/other/Dodo.dds', 'TOMGuildsAddon/other/Cooldeath.dds', 'TOMGuildsAddon/other/Doingscience.dds', 'TOMGuildsAddon/other/Soulgems.dds', 'TOMGuildsAddon/other/Parsemonkey.dds' }

--- SETTINGS MENU ---

function TGAAddon.initMenu()
  local LAM2 = LibAddonMenu2
  local panelData = {
    type        = "panel",
    name        = "TOM Guild's Addon",
    author      = "Splat",
    version	    = "2.70",
    registerForRefresh = true,	-- will refresh all options controls when a setting is changed and when the panel is shown
    registerForDefaults = true	-- will set all options controls back to default values
  }
  LAM2:RegisterAddonPanel("TOMGuildsAddon", panelData)
    local optionsData = {
    {  type = "description",
       Title = "Settings options for the TOM Guild's Addon",
       text = "A number of the features and functions of this addon are activated and deactivated by the use of keybinds. Please use 'Controls > Addon Keybinds > Tom Guild's Addon' to assign keybinds for each toon you wish to use them on.",
       width = "full",
    }, 
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "PVP Options",
       text = "Allows you to enable or disable the auto acceptance of PVP queuing, along with selecting which is your preferred Cyro and IC version to port to when you use the CYRO/IC toggle keybind.",
       width = "full",
    },
    {  type = "checkbox",
       name    = "Auto accept Cyro & IC queues",
       tooltip = "Allows the automatic acceptance of PVP queues",
       getFunc = function() return TGAAddon.svChar.autoAcceptPvpQ end,
       setFunc = function(value) TGAAddon.svChar.autoAcceptPvpQ=value end,
       default = TGAAddon.svCharDef.autoAcceptPvpQ,
       width   = "full",
       requiresReload = true,
    }, 
    {  type    = "checkbox",
       name    = "Queue confirmation in chat",
       tooltip = "Shows which campaign you are joining when the auto queue is activated",
       getFunc = function() return TGAAddon.svChar.autoAcceptChat end,
       setFunc = function(value) TGAAddon.svChar.autoAcceptChat=value end,
       default = TGAAddon.svCharDef.autoAcceptChat,
       width   = "full",
       requiresReload = false,
    },
    {
       type = "dropdown",
       name = "Choose Cyrodiil Campaign",
       tooltip = "Lets you pick which Cyrodiil campaign you will be auto ported to when using the toogle keybind",
       default = TGAAddon.svCharDef.cyrocampaignid,
       choices = {"Gray Host", "Ravenwatch", "Blackreach", "Icereach"},
---    choices = {"Gray Host", "Ravenwatch", "Blackreach", "Icereach", "Ashpit", "Evergloam", "Quagmire", "Fields of Regret"},
       choicesValues = {102, 103, 101, 104},
---    choicesValues = {102, 103, 101, 104, 106, 105, 111, 112},
       scrollable = "true",
       getFunc = function() return TGAAddon.svChar.cyrocampaignid end,
       setFunc = function(value) TGAAddon.svChar.cyrocampaignid=value end,
       requiresReload = true,
     },
    {
       type = "dropdown",
       name = "Choose Imperial City Version",
       tooltip = "Lets you pick which Imperial City campaign you will be auto ported to when using the toogle keybind",
       default = TGAAddon.svCharDef.iccampaignid,
       choices = {"CP Imperial City", "No-CP Imperial City"},
---    choices = {"CP Imperial City", "No-CP Imperial City", "Dragonfire CP", "Legion Zero No-CP"},
       choicesValues = {95, 96},
---    choicesValues = {95, 96, 119, 116},
       scrollable = "true",
       getFunc = function() return TGAAddon.svChar.iccampaignid end,
       setFunc = function(value) TGAAddon.svChar.iccampaignid=value end,
       requiresReload = true,
     },
    {  type = "divider",
       alpha = 0.4,
    }, 
    {  type = "description",
       title = "Graven Deep Marker Options",
       text = "Allows you to enable or disable numeric markers for the sea orb positions on the last boss.",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Graven Deep Markers",
       getFunc = function() return TGAAddon.svChar.gdmarkers end,
       setFunc = function(value) TGAAddon.svChar.gdmarkers=value end,
       default = TGAAddon.svCharDef.gdmarkers,
       width   = "full",
       requiresReload = true,
    },
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "Hel Ra Citadel Marker Options",
       text = "Allows you to enable or disable the group stack positions for the gargoyle destruction method on the last boss of HRC in hard mode.",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Hel ra Citadel HM Markers",
       getFunc = function() return TGAAddon.svChar.hrcmarkers end,
       setFunc = function(value) TGAAddon.svChar.hrcmarkers=value end,
       default = TGAAddon.svCharDef.hrcmarkers,
       width   = "full",
       requiresReload = true,
    },
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "Sanitys Edge HM 2nd Boss Crystal Room Marker Options",
       text = "Allows you to enable or disable the Lion, Gryphon & Wamasu markers inside the crystal rooms. Typing 'g' 'w' or 'l' followed by the correct numeric crystal sequence (from Sanity's Edge Assist Addons numbers) into group chat will display A to E markers on the crystals in the order they need to be destroyed for any group members running this addon, so W53241 for example will add the A to E markers to the Wamasu run. Markers are auto cleared between room phases but you can also clear existing markers manually anytime by typing 'vcse' into group chat.",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Sanitys Edge Crystal Room Markers",
       getFunc = function() return TGAAddon.svChar.semarkers end,
       setFunc = function(value) TGAAddon.svChar.semarkers=value end,
       default = TGAAddon.svCharDef.semarkers,
       width   = "full",
       requiresReload = true,
    },

    {  type = "divider",
       alpha = 0.4,
    }, 
    {  type = "description",
       title = "Guild Hall Marker Options",
       text = "Allows you to enable or disable all of the additional guild hall markers.",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Guild Hall Markers",
       getFunc = function() return TGAAddon.svChar.ghmarkers end,
       setFunc = function(value) TGAAddon.svChar.ghmarkers=value end,
       default = TGAAddon.svCharDef.ghmarkers,
       width   = "full",
       requiresReload = true,
    },
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "Imperial City Marker Options",
       text = "Allows you to enable or disable the markers added to the ladder rooms, bankers & exits in Imperial City",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Imperial City Markers",
       getFunc = function() return TGAAddon.svChar.icmarkers end,
       setFunc = function(value) TGAAddon.svChar.icmarkers=value end,
       default = TGAAddon.svCharDef.icmarkers,
       width   = "full",
       requiresReload = true,
    },
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "T-Bag Death Mode",
       text = "Allows you to enable or disable random T-Bagging markers in group content",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display T-Bag Markers",
       getFunc = function() return TGAAddon.svChar.tbagmarkers end,
       setFunc = function(value) TGAAddon.svChar.tbagmarkers=value end,
       default = TGAAddon.svCharDef.tbagmarkers,
       width   = "full",
       requiresReload = true,
    },
    {  type = "description",
       title = "Priority Res Mode",
       text = "Allows you to enable or disable priority res markers on tanks and healers in group content",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Priority Res Markers",
       getFunc = function() return TGAAddon.svChar.presmarkers end,
       setFunc = function(value) TGAAddon.svChar.presmarkers=value end,
       default = TGAAddon.svCharDef.presmarkers,
       width   = "full",
       requiresReload = true,
    },
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "Scribing - Mages Guild Markers",
       text = "Add markers to the free scribing scripts found in mages guilds in Auridon, Grahtwood, Reaper's March, Glenumbra, Stormhaven, Bangkorai, Stonefalls, Deshaan & The Rift. Visit the Mages Guild in the main town of each of these zones and the markers will appear at the script.",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Enable/Disable Mages Guild Markers",
       getFunc = function() return TGAAddon.svChar.magesguildmarkers end,
       setFunc = function(value) TGAAddon.svChar.magesguildmarkers=value end,
       default = TGAAddon.svCharDef.magesguildmarkers,
       width   = "full",
       requiresReload = true,
    },
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "Secret Mode",
       text = "Allows you to enable or disable secret mode ... helpful I know",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Enable/Disable Secret Mode",
       getFunc = function() return TGAAddon.svChar.secretmode end,
       setFunc = function(value) TGAAddon.svChar.secretmode=value end,
       default = TGAAddon.svCharDef.secretmode,
       width   = "full",
       requiresReload = true,
    },
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "Encounter Log Status",
       text = "Show Encounter Log Status in Trials, Dungeons, Arenas, Cyrodiil or Imperial City",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Trials",
       getFunc = function() return TGAAddon.svChar.enclogtrial end,
       setFunc = function(value) TGAAddon.svChar.enclogtrial=value end,
       default = TGAAddon.svCharDef.enclogtrial,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Dungeons",
       getFunc = function() return TGAAddon.svChar.enclogdungeon end,
       setFunc = function(value) TGAAddon.svChar.enclogdungeon=value end,
       default = TGAAddon.svCharDef.enclogdungeon,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Arenas",
       getFunc = function() return TGAAddon.svChar.enclogarena end,
       setFunc = function(value) TGAAddon.svChar.enclogarena=value end,
       default = TGAAddon.svCharDef.enclogarena,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Cyrodiil",
       getFunc = function() return TGAAddon.svChar.enclogcyro end,
       setFunc = function(value) TGAAddon.svChar.enclogcyro=value end,
       default = TGAAddon.svCharDef.enclogcyro,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Imperial City",
       getFunc = function() return TGAAddon.svChar.enclogic end,
       setFunc = function(value) TGAAddon.svChar.enclogic=value end,
       default = TGAAddon.svCharDef.enclogic,
       width   = "full",
       requiresReload = true,
    },
  }
  LAM2:RegisterOptionControls("TOMGuildsAddon", optionsData)
end


-- ALLOW MULTI KEYBINDING
function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
return true
end

-- BOSS DATA CHECKER
function BossChange()
local bossName = string.lower(GetUnitName("boss1"))
local bossName2 = string.lower(GetUnitName("boss2"))
local currentBoss = bossName
local getcurrentTargetHP, getmaxTargetHP, geteffmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
local getcurrentTargetHP2, getmaxTargetHP2, geteffmaxTargetHP2 = GetUnitPower("boss2", POWERTYPE_HEALTH)
showMarkers(currentBoss, getmaxTargetHP)
 if (bossName2 == "archwizard twelvane" and getcurrentTargetHP2 < 35000000 and getcurrentTargetHP2 > 25000000) then -- CLEAR VSE HM MARKERS AFTER A WIPE
  ClearSEMarkersNow()
 end
end

function showMarkers(currentBossy, getmaxTargetHPHRC)
local zoneId = GetZoneId(GetUnitZoneIndex("player")) -- GET CURRENT PLAYER ZONE ID
local houseowner = GetCurrentHouseOwner() -- GET CURRENT HOUSE OWNER

-- GUILD HALL MARKERS
 if (zoneId == 1008 and houseowner == "@EggsOnLegs" and TGAAddon.svChar.ghmarkers) then -- IF IN GUILD HALL
  ICON_APPRENTICE = OSI.CreatePositionIcon(
    80835, 37031, 96248,         -- world coordinates
    "TOMGuildsAddon/mundus/theapprentice.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_ATRONACH = OSI.CreatePositionIcon(
    81291, 37008, 96630,         -- world coordinates
    "TOMGuildsAddon/mundus/theatronach.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_LADY = OSI.CreatePositionIcon(
    81865, 36989, 96989,         -- world coordinates
    "TOMGuildsAddon/mundus/thelady.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_LORD = OSI.CreatePositionIcon(
    82456, 36966, 97234,         -- world coordinates
    "TOMGuildsAddon/mundus/thelord.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_LOVER = OSI.CreatePositionIcon(
    83036, 36939, 97418,         -- world coordinates
    "TOMGuildsAddon/mundus/thelover.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_MAGE = OSI.CreatePositionIcon(
    83645, 36940, 97541,         -- world coordinates
    "TOMGuildsAddon/mundus/themage.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_RITUAL = OSI.CreatePositionIcon(
    84245, 36936, 97570,         -- world coordinates
    "TOMGuildsAddon/mundus/theritual.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_SERPENT = OSI.CreatePositionIcon(
    84828, 36939, 97568,         -- world coordinates
    "TOMGuildsAddon/mundus/theserpent.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_SHADOW = OSI.CreatePositionIcon(
    85425, 36942, 97397,         -- world coordinates
    "TOMGuildsAddon/mundus/theshadow.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_STEED = OSI.CreatePositionIcon(
    85980, 36934, 97162,         -- world coordinates
    "TOMGuildsAddon/mundus/thesteed.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_THIEF = OSI.CreatePositionIcon(
    86517, 36913, 96860,         -- world coordinates
    "TOMGuildsAddon/mundus/thethief.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_TOWER = OSI.CreatePositionIcon(
    87037, 36914, 96533,         -- world coordinates
    "TOMGuildsAddon/mundus/thetower.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_WARRIOR = OSI.CreatePositionIcon(
    87494, 36910, 96148,         -- world coordinates
    "TOMGuildsAddon/mundus/thewarrior.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_TRIALDUMMYONE = OSI.CreatePositionIcon(
    78807, 36964, 95962,         -- world coordinates
    "TOMGuildsAddon/guildhall/trialdummy.dds",  -- icon texture path
    OSI.GetIconSize() * 5,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    6                              -- optional icon offset in meters
    )
  ICON_TRIALDUMMYTWO = OSI.CreatePositionIcon(
--    91163, 36925, 94426,         -- world coordinates
    84970, 36926, 93374,         -- world coordinates
    "TOMGuildsAddon/guildhall/trialdummy.dds",  -- icon texture path
    OSI.GetIconSize() * 6,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    8                              -- optional icon offset in meters
    )
  ICON_RESOURCERESTORE = OSI.CreatePositionIcon(
    84962, 37070, 94579,         -- world coordinates
    "TOMGuildsAddon/guildhall/resourcerestore.dds",  -- icon texture path
    OSI.GetIconSize() * 3,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  ICON_BANKER = OSI.CreatePositionIcon(
    85191, 36873, 83996,         -- world coordinates
    "TOMGuildsAddon/guildhall/banker.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  ICON_MERCHANT = OSI.CreatePositionIcon(
    84935, 36866, 83827,         -- world coordinates
    "TOMGuildsAddon/guildhall/merchant.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  ICON_ARMORYASSISTANT = OSI.CreatePositionIcon(
    85494, 36852, 84188,         -- world coordinates
    "TOMGuildsAddon/guildhall/armoryassistant.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  ICON_RAGPICKER = OSI.CreatePositionIcon(
    85803, 36850, 84428,         -- world coordinates
    "TOMGuildsAddon/guildhall/ragpicker.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  ICON_REDUCEVAMPIRESTAGE = OSI.CreatePositionIcon(
    82311, 36812, 85823,         -- world coordinates
    "TOMGuildsAddon/guildhall/reducevampirestage.dds",  -- icon texture path
    OSI.GetIconSize() * 3,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_TRANSMUTESTATION = OSI.CreatePositionIcon(
    84047, 36925, 88831,         -- world coordinates
    "TOMGuildsAddon/guildhall/transmutestation.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    3.5                              -- optional icon offset in meters
    )
  ICON_FORMERGUILDMEMBERS = OSI.CreatePositionIcon(
    77222, 36838, 90718,         -- world coordinates
    "TOMGuildsAddon/guildhall/formerguildmembers.dds",  -- icon texture path
    OSI.GetIconSize() * 4,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    6                              -- optional icon offset in meters
    )
  ICON_COOKINGFIRE = OSI.CreatePositionIcon(
    86187, 37100, 87559,         -- world coordinates
    "TOMGuildsAddon/guildhall/cookingfire.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_OUTFITSTATION = OSI.CreatePositionIcon(
    85297, 37100, 87559,         -- world coordinates
    "TOMGuildsAddon/guildhall/outfitstation.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_ARMORYSTATION = OSI.CreatePositionIcon(
    84954, 37100, 87559,         -- world coordinates
    "TOMGuildsAddon/guildhall/armorystation.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_ENCHANTINGSTATION = OSI.CreatePositionIcon(
    85876, 37100, 87559,         -- world coordinates
    "TOMGuildsAddon/guildhall/enchantingstation.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_ALCHEMYSTATION = OSI.CreatePositionIcon(
    85599, 37100, 87559,         -- world coordinates
    "TOMGuildsAddon/guildhall/alchemystation.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1.2                              -- optional icon offset in meters
    )
  ICON_WELCOME = OSI.CreatePositionIcon(
    81721, 36888, 84536,         -- world coordinates
    "TOMGuildsAddon/guildhall/ghnotice.dds",  -- icon texture path
    OSI.GetIconSize() * 6,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    0.2                              -- optional icon offset in meters
    )
 end
-- IF WE ARE NOT IN THE GUILD HALL THEN UNSET ANY GUILD HALL ICONS THAT MAY HAVE BEEN PREVIOUSLY SET
 if (zoneId ~= 1008) then -- IF NOT IN GUILD HALL
  if ICON_APPRENTICE ~= nil then
  OSI.DiscardPositionIcon( ICON_APPRENTICE )
  ICON_APPRENTICE = nil
  end
  if ICON_ATRONACH ~= nil then
  OSI.DiscardPositionIcon( ICON_ATRONACH )
  ICON_ATRONACH = nil
  end
  if ICON_LADY ~= nil then
  OSI.DiscardPositionIcon( ICON_LADY )
  ICON_LADY = nil
  end
  if ICON_LORD ~= nil then
  OSI.DiscardPositionIcon( ICON_LORD )
  ICON_LORD = nil
  end
  if ICON_LOVER ~= nil then
  OSI.DiscardPositionIcon( ICON_LOVER )
  ICON_LOVER = nil
  end
  if ICON_MAGE ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGE )
  ICON_MAGE = nil
  end
  if ICON_RITUAL ~= nil then
  OSI.DiscardPositionIcon( ICON_RITUAL )
  ICON_RITUAL = nil
  end
  if ICON_SERPENT ~= nil then
  OSI.DiscardPositionIcon( ICON_SERPENT )
  ICON_SERPENT = nil
  end
  if ICON_SHADOW ~= nil then
  OSI.DiscardPositionIcon( ICON_SHADOW )
  ICON_SHADOW = nil
  end
  if ICON_STEED ~= nil then
  OSI.DiscardPositionIcon( ICON_STEED )
  ICON_STEED = nil
  end
  if ICON_THIEF ~= nil then
  OSI.DiscardPositionIcon( ICON_THIEF )
  ICON_THIEF = nil
  end
  if ICON_TOWER ~= nil then
  OSI.DiscardPositionIcon( ICON_TOWER )
  ICON_TOWER = nil
  end
  if ICON_WARRIOR ~= nil then
  OSI.DiscardPositionIcon( ICON_WARRIOR )
  ICON_WARRIOR = nil
  end
  if ICON_TRIALDUMMYONE ~= nil then
  OSI.DiscardPositionIcon( ICON_TRIALDUMMYONE )
  ICON_TRIALDUMMYONE = nil
  end
  if ICON_TRIALDUMMYTWO ~= nil then
  OSI.DiscardPositionIcon( ICON_TRIALDUMMYTWO )
  ICON_TRIALDUMMYTWO = nil
  end
  if ICON_RESOURCERESTORE ~= nil then
  OSI.DiscardPositionIcon( ICON_RESOURCERESTORE )
  ICON_RESOURCERESTORE = nil
  end
  if ICON_BANKER ~= nil then
  OSI.DiscardPositionIcon( ICON_BANKER )
  ICON_BANKER = nil
  end
  if ICON_MERCHANT ~= nil then
  OSI.DiscardPositionIcon( ICON_MERCHANT )
  ICON_MERCHANT = nil
  end
  if ICON_ARMORYASSISTANT ~= nil then
  OSI.DiscardPositionIcon( ICON_ARMORYASSISTANT )
  ICON_ARMORYASSISTANT = nil
  end
  if ICON_RAGPICKER ~= nil then
  OSI.DiscardPositionIcon( ICON_RAGPICKER )
  ICON_RAGPICKER = nil
  end
  if ICON_REDUCEVAMPIRESTAGE ~= nil then
  OSI.DiscardPositionIcon( ICON_REDUCEVAMPIRESTAGE )
  ICON_REDUCEVAMPIRESTAGE = nil
  end
  if ICON_TRANSMUTESTATION ~= nil then
  OSI.DiscardPositionIcon( ICON_TRANSMUTESTATION )
  ICON_TRANSMUTESTATION = nil
  end
  if ICON_FORMERGUILDMEMBERS ~= nil then
  OSI.DiscardPositionIcon( ICON_FORMERGUILDMEMBERS )
  ICON_FORMERGUILDMEMBERS = nil
  end
  if ICON_COOKINGFIRE ~= nil then
  OSI.DiscardPositionIcon( ICON_COOKINGFIRE )
  ICON_COOKINGFIRE = nil
  end
  if ICON_OUTFITSTATION ~= nil then
  OSI.DiscardPositionIcon( ICON_OUTFITSTATION )
  ICON_OUTFITSTATION = nil
  end
  if ICON_ARMORYSTATION ~= nil then
  OSI.DiscardPositionIcon( ICON_ARMORYSTATION )
  ICON_ARMORYSTATION = nil
  end
  if ICON_ENCHANTINGSTATION ~= nil then
  OSI.DiscardPositionIcon( ICON_ENCHANTINGSTATION )
  ICON_ENCHANTINGSTATION = nil
  end
  if ICON_ALCHEMYSTATION ~= nil then
  OSI.DiscardPositionIcon( ICON_ALCHEMYSTATION )
  ICON_ALCHEMYSTATION = nil
  end
  if ICON_WELCOME ~= nil then
  OSI.DiscardPositionIcon( ICON_WELCOME )
  ICON_WELCOME = nil
  end
 end -- CLOSE IF NOT IN GUILD HALL ZONE CHECK


-- IMPERIAL CITY MARKERS

 if (zoneId == 643 and TGAAddon.svChar.icmarkers) then -- IF IN IMPERIAL CITY
 -- DC AREA
 -- Arboretum
  ICON_ARBORETUM_DC = OSI.CreatePositionIcon(
    4460, 13352, 155935,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Arboretum.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Temple
  ICON_TEMPLE_DC = OSI.CreatePositionIcon(
    4439, 13352, 154315,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Temple.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Nobles
  ICON_NOBLES_DC = OSI.CreatePositionIcon(
    5918, 13352, 154209,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Nobles.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Elven
  ICON_ELVEN_DC = OSI.CreatePositionIcon(
    6159, 13352, 154699,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Elven.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Memorial
  ICON_MEMORIAL_DC = OSI.CreatePositionIcon(
    6182, 13352, 155517,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Memorial.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Arena
  ICON_ARENA_DC = OSI.CreatePositionIcon(
    5812, 13352, 156015,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Arena.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    3                              -- optional icon offset in meters
    )
 -- Banker
  ICON_BANK_DC = OSI.CreatePositionIcon(
    5275, 13167, 153383,         -- world coordinates
    "TOMGuildsAddon/imperialcity/banker.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
 -- Exit
  ICON_EXIT_DC = OSI.CreatePositionIcon(
    1480, 13275, 160831,         -- world coordinates
    "TOMGuildsAddon/imperialcity/exit.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )

 -- AD AREA
 -- Arboretum
  ICON_ARBORETUM_AD = OSI.CreatePositionIcon(
    273611, 12850, 180026,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Arboretum.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Temple
  ICON_TEMPLE_AD = OSI.CreatePositionIcon(
    275228, 12850, 179983,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Temple.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Nobles
  ICON_NOBLES_AD = OSI.CreatePositionIcon(
    275415, 12850, 181486,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Nobles.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Elven
  ICON_ELVEN_AD = OSI.CreatePositionIcon(
    274859, 12850, 181734,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Elven.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Memorial
  ICON_MEMORIAL_AD = OSI.CreatePositionIcon(
    274037, 12850, 181758,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Memorial.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Arena
  ICON_ARENA_AD = OSI.CreatePositionIcon(
    273505, 12850, 181387,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Arena.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Banker
  ICON_BANK_AD = OSI.CreatePositionIcon(
    270701, 12694, 178046,         -- world coordinates
    "TOMGuildsAddon/imperialcity/banker.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
 -- Exit
  ICON_EXIT_AD = OSI.CreatePositionIcon(
    268153, 12737, 182178,         -- world coordinates
    "TOMGuildsAddon/imperialcity/exit.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )

 -- EP AREA
 -- Arboretum
  ICON_ARBORETUM_EP = OSI.CreatePositionIcon(
    166321, 11204, 21402,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Arboretum.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Temple
  ICON_TEMPLE_EP = OSI.CreatePositionIcon(
    166832, 11204, 20909,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Temple.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Nobles
  ICON_NOBLE_EP = OSI.CreatePositionIcon(
    167741, 11204, 21010,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Nobles.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Elven
  ICON_ELVEN_EP = OSI.CreatePositionIcon(
    167736, 11204, 22763,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Elven.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Memorial
  ICON_MEMORIAL_EP = OSI.CreatePositionIcon(
    166847, 11204, 22731,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Memorial.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Arena
  ICON_ARENA_EP = OSI.CreatePositionIcon(
    166367, 11204, 22341,         -- world coordinates
    "TOMGuildsAddon/imperialcity/Arena.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Banker
  ICON_BANK_EP = OSI.CreatePositionIcon(
    167273, 11035, 24470,         -- world coordinates
    "TOMGuildsAddon/imperialcity/banker.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
 -- Exit
  ICON_EXIT_EP = OSI.CreatePositionIcon(
    173049, 11074, 20414,         -- world coordinates
    "TOMGuildsAddon/imperialcity/exit.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
 end -- CLOSE OF IF ON IMPERIAL CITY CHECK

 if (zoneId ~= 643) then -- IF WE ARE NOT IN THE IMPERIAL CITY THEN UNSET ANY IMPERIAL CITY ICONS THAT MAY HAVE BEEN PREVIOUSLY SET
  if ICON_ARBORETUM_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_ARBORETUM_DC )
  ICON_ARBORETUM_DC = nil
  end
  if ICON_TEMPLE_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_TEMPLE_DC )
  ICON_TEMPLE_DC = nil
  end
  if ICON_NOBLE_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_NOBLE_DC )
  ICON_NOBLE_DC = nil
  end
  if ICON_ELVEN_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_ELVEN_DC )
  ICON_ELVEN_DC = nil
  end
  if ICON_MEMORIAL_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_MEMORIAL_DC )
  ICON_MEMORIAL_DC = nil
  end
  if ICON_ARENA_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_ARENA_DC )
  ICON_ARENA_DC = nil
  end
  if ICON_BANK_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_BANK_DC )
  ICON_BANK_DC = nil
  end
  if ICON_EXIT_DC ~= nil then
  OSI.DiscardPositionIcon( ICON_EXIT_DC )
  ICON_EXIT_DC = nil
  end
  if ICON_ARBORETUM_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_ARBORETUM_EP )
  ICON_ARBORETUM_EP = nil
  end
  if ICON_TEMPLE_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_TEMPLE_EP )
  ICON_TEMPLE_EP = nil
  end
  if ICON_NOBLE_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_NOBLE_EP )
  ICON_NOBLE_EP = nil
  end
  if ICON_ELVEN_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_ELVEN_EP )
  ICON_ELVEN_EP = nil
  end
  if ICON_MEMORIAL_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_MEMORIAL_EP )
  ICON_MEMORIAL_EP = nil
  end
  if ICON_ARENA_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_ARENA_EP )
  ICON_ARENA_EP = nil
  end
  if ICON_BANK_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_BANK_EP )
  ICON_BANK_EP = nil
  end
  if ICON_EXIT_EP ~= nil then
  OSI.DiscardPositionIcon( ICON_EXIT_EP )
  ICON_EXIT_EP = nil
  end
  if ICON_ARBORETUM_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_ARBORETUM_AD )
  ICON_ARBORETUM_AD = nil
  end
  if ICON_TEMPLE_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_TEMPLE_AD )
  ICON_TEMPLE_AD = nil
  end
  if ICON_NOBLE_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_NOBLE_AD )
  ICON_NOBLE_AD = nil
  end
  if ICON_ELVEN_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_ELVEN_AD )
  ICON_ELVEN_AD = nil
  end
  if ICON_MEMORIAL_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_MEMORIAL_AD )
  ICON_MEMORIAL_AD = nil
  end
  if ICON_ARENA_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_ARENA_AD )
  ICON_ARENA_AD = nil
  end
  if ICON_BANK_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_BANK_AD )
  ICON_BANK_AD = nil
  end
  if ICON_EXIT_AD ~= nil then
  OSI.DiscardPositionIcon( ICON_EXIT_AD )
  ICON_EXIT_AD = nil
  end
 end -- CLOSE OF IF ON NOT IN IMPERIAL CITY CHECK


-- GRAVEN DEEP MARKERS

 if (zoneId == 1361 and currentBossy == "zelvraak the unbreathing" and TGAAddon.svChar.gdmarkers) then -- IF IN GRAVEN DEEP
 -- 1
  ICON_GRAVENDEEP_1 = OSI.CreatePositionIcon(
    60039, 11533, 52800,         -- world coordinates
    "TOMGuildsAddon/numbers/1.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- 2
  ICON_GRAVENDEEP_2 = OSI.CreatePositionIcon(
    57187, 11533, 49943,         -- world coordinates
    "TOMGuildsAddon/numbers/2.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- 3
  ICON_GRAVENDEEP_3 = OSI.CreatePositionIcon(
    60038, 11533, 47048,         -- world coordinates
    "TOMGuildsAddon/numbers/3.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- 4
  ICON_GRAVENDEEP_4 = OSI.CreatePositionIcon(
    62902, 11533, 49926,         -- world coordinates
    "TOMGuildsAddon/numbers/4.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 end -- CLOSE OF IF ON GRAVEN DEEP CHECK

 if (zoneId ~= 1361) then -- IF WE ARE NOT IN GRAVEN DEEP THEN UNSET ANY GRAVEN DEEP ICONS THAT MAY HAVE BEEN PREVIOUSLY SET
  if ICON_GRAVENDEEP_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_GRAVENDEEP_1 )
  ICON_GRAVENDEEP_1 = nil
  end
  if ICON_GRAVENDEEP_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_GRAVENDEEP_2 )
  ICON_GRAVENDEEP_2 = nil
  end
  if ICON_GRAVENDEEP_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_GRAVENDEEP_3 )
  ICON_GRAVENDEEP_3 = nil
  end
  if ICON_GRAVENDEEP_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_GRAVENDEEP_4 )
  ICON_GRAVENDEEP_4 = nil
  end
 end -- CLOSE OF IF ON NOT IN GRAVEN DEEP CHECK

-- SCRIBING MAGES GUILD MARKERS

 if (zoneId == 381 and TGAAddon.svChar.magesguildmarkers) then -- IF IN AURIDON
 -- 1
  ICON_MAGES_GUILD_1 = OSI.CreatePositionIcon(
    214319, 5460, 404334,         -- world coordinates
    "TOMGuildsAddon/numbers/1.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN AURIDON CHECK
 if (zoneId == 383 and TGAAddon.svChar.magesguildmarkers) then -- IF IN GRAHTWOOD
 -- 2
  ICON_MAGES_GUILD_2 = OSI.CreatePositionIcon(
    236559, 3242, 205602,         -- world coordinates
    "TOMGuildsAddon/numbers/2.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN GRAHTWOOD CHECK
 if (zoneId == 382 and TGAAddon.svChar.magesguildmarkers) then -- IF IN REAPERS MARCH
 -- 3
  ICON_MAGES_GUILD_3 = OSI.CreatePositionIcon(
    140841, 16413, 189113,         -- world coordinates
    "TOMGuildsAddon/numbers/3.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN REAPERS MARCH CHECK
 if (zoneId == 3 and TGAAddon.svChar.magesguildmarkers) then -- IF IN GLENUMBRA
 -- 4
  ICON_MAGES_GUILD_4 = OSI.CreatePositionIcon(
    101678, 8592, 311789,         -- world coordinates
    "TOMGuildsAddon/numbers/4.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN GLENUMBRA CHECK
 if (zoneId == 19 and TGAAddon.svChar.magesguildmarkers) then -- IF IN STORMHAVEN
 -- 5
  ICON_MAGES_GUILD_5 = OSI.CreatePositionIcon(
    262340, 1278, 242530,         -- world coordinates
    "TOMGuildsAddon/numbers/5.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN STORMHAVEN CHECK
 if (zoneId == 92 and TGAAddon.svChar.magesguildmarkers) then -- IF IN BANKGORAI
 -- 6
  ICON_MAGES_GUILD_6 = OSI.CreatePositionIcon(
    169266, 2106, 186649,         -- world coordinates
    "TOMGuildsAddon/numbers/6.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN BANKGORAI CHECK
 if (zoneId == 41 and TGAAddon.svChar.magesguildmarkers) then -- IF IN STONEFALLS
 -- 7
  ICON_MAGES_GUILD_7 = OSI.CreatePositionIcon(
    359722, 4845, 168163,         -- world coordinates
    "TOMGuildsAddon/numbers/7.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN STONEFALLS CHECK
 if (zoneId == 57 and TGAAddon.svChar.magesguildmarkers) then -- IF IN DESHAAN
 -- 8
  ICON_MAGES_GUILD_8 = OSI.CreatePositionIcon(
    201753, 11381, 233932,         -- world coordinates
    "TOMGuildsAddon/numbers/8.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    2                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF IN DESHAAN CHECK
 if (zoneId == 103 and TGAAddon.svChar.magesguildmarkers) then -- IF IN THE RIFT
 -- 9
  ICON_MAGES_GUILD_9 = OSI.CreatePositionIcon(
    372631, 20709, 203620,         -- world coordinates
    "TOMGuildsAddon/numbers/9.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
 end -- CLOSE OF IF IN THE RIFT CHECK


 if (zoneId ~= 381 and zoneId ~= 383 and zoneId ~= 382 and zoneId ~= 3 and zoneId ~= 19 and zoneId ~= 92 and zoneId ~= 41 and zoneId ~= 57 and zoneId ~= 103) then -- IF WE ARE NOT IN ANY OF THE MAGES GUILD MARKERS THEN UNSET ALL MARKERS
  if ICON_MAGES_GUILD_1 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_1 )
  ICON_MAGES_GUILD_1 = nil
  end
  if ICON_MAGES_GUILD_2 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_2 )
  ICON_MAGES_GUILD_2 = nil
  end
  if ICON_MAGES_GUILD_3 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_3 )
  ICON_MAGES_GUILD_3 = nil
  end
  if ICON_MAGES_GUILD_4 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_4 )
  ICON_MAGES_GUILD_4 = nil
  end
  if ICON_MAGES_GUILD_5 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_5 )
  ICON_MAGES_GUILD_5 = nil
  end
  if ICON_MAGES_GUILD_6 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_6 )
  ICON_MAGES_GUILD_6 = nil
  end
  if ICON_MAGES_GUILD_7 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_7 )
  ICON_MAGES_GUILD_7 = nil
  end
  if ICON_MAGES_GUILD_8 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_8 )
  ICON_MAGES_GUILD_8 = nil
  end
  if ICON_MAGES_GUILD_9 ~= nil then
  OSI.DiscardPositionIcon( ICON_MAGES_GUILD_9 )
  ICON_MAGES_GUILD_9 = nil
  end
 end -- CLOSE OF IF ON NOT IN ANY OF THE MAGES GUILDS CHECK

-- SANITYS EDGE MARKERS

 if (zoneId == 1427 and TGAAddon.svChar.semarkers) then -- IF IN SE AND ON 2ND BOSS
 -- Lion
  ICON_SE_LION = OSI.CreatePositionIcon(
    179948,40350,242203,         -- world coordinates
    "TOMGuildsAddon/sanitysedge/lion.dds",  -- icon texture path
    OSI.GetIconSize() * 6,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Gryphon
  ICON_SE_GRYPHON = OSI.CreatePositionIcon(
    170048,40350,242200,         -- world coordinates
    "TOMGuildsAddon/sanitysedge/gryphon.dds",  -- icon texture path
    OSI.GetIconSize() * 6,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- Wamasu
  ICON_SE_WAMASU = OSI.CreatePositionIcon(
    189859,40350,242154,         -- world coordinates
    "TOMGuildsAddon/sanitysedge/wamasu.dds",  -- icon texture path
    OSI.GetIconSize() * 6,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 end -- CLOSE OF IF ON SE CHECK

 if (zoneId ~= 1427) then -- IF WE ARE NOT IN SE THEN UNSET ANY se ICONS THAT MAY HAVE BEEN PREVIOUSLY SET
  if ICON_SE_LION ~= nil then
  OSI.DiscardPositionIcon( ICON_SE_LION )
  ICON_SE_LION = nil
  end
  if ICON_SE_GRYPHON ~= nil then
  OSI.DiscardPositionIcon( ICON_SE_GRYPHON )
  ICON_SE_GRYPHON = nil
  end
  if ICON_SE_WAMASU  ~= nil then
  OSI.DiscardPositionIcon( ICON_SE_WAMASU )
  ICON_SE_WAMASU = nil
  end
  if VSEMARKER_LION_A  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_A )
  VSEMARKER_LION_A = nil
  end
  if VSEMARKER_LION_B  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_B )
  VSEMARKER_LION_B = nil
  end
  if VSEMARKER_LION_C  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_C )
  VSEMARKER_LION_C = nil
  end
  if VSEMARKER_LION_D  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_D )
  VSEMARKER_LION_D = nil
  end
  if VSEMARKER_LION_E  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_E )
  VSEMARKER_LION_E = nil
  end
  if VSEMARKER_GRYPHON_A  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_A )
  VSEMARKER_GRYPHON_A = nil
  end
  if VSEMARKER_GRYPHON_B  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_B )
  VSEMARKER_GRYPHON_B = nil
  end
  if VSEMARKER_GRYPHON_C  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_C )
  VSEMARKER_GRYPHON_C = nil
  end
  if VSEMARKER_GRYPHON_D  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_D )
  VSEMARKER_GRYPHON_D = nil
  end
  if VSEMARKER_GRYPHON_E  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_E )
  VSEMARKER_GRYPHON_E = nil
  end
  if VSEMARKER_WAMASU_A  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_A )
  VSEMARKER_WAMASU_A = nil
  end
  if VSEMARKER_WAMASU_B  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_B )
  VSEMARKER_WAMASU_B = nil
  end
  if VSEMARKER_WAMASU_C  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_C )
  VSEMARKER_WAMASU_C = nil
  end
  if VSEMARKER_WAMASU_D  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_D )
  VSEMARKER_WAMASU_D = nil
  end
  if VSEMARKER_WAMASU_E  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_E )
  VSEMARKER_WAMASU_E = nil
  end
 end -- CLOSE OF IF ON NOT IN SANITYS EDGE



-- HEL RA CITADEL MARKERS -- IF IN HEL RA CITADEL

 if (zoneId == 636 and currentBossy == "the warrior" and getmaxTargetHPHRC > 65000000 and TGAAddon.svChar.hrcmarkers) then
 -- A
  ICON_HRC_A = OSI.CreatePositionIcon(
    96133, 37107, 89730,         -- world coordinates
    "TOMGuildsAddon/letters/A.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- B
  ICON_HRC_B = OSI.CreatePositionIcon(
   97375, 37107, 92004,         -- world coordinates
    "TOMGuildsAddon/letters/B.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- C
  ICON_HRC_C = OSI.CreatePositionIcon(
    96714, 37107, 94012,         -- world coordinates
    "TOMGuildsAddon/letters/C.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- D
  ICON_HRC_D = OSI.CreatePositionIcon(
    94606, 37107, 95256,         -- world coordinates
    "TOMGuildsAddon/letters/D.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- E
  ICON_HRC_E = OSI.CreatePositionIcon(
    94291, 37107, 92546,         -- world coordinates
    "TOMGuildsAddon/letters/E.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
 -- F
  ICON_HRC_F = OSI.CreatePositionIcon(
    92155, 37107, 91729,         -- world coordinates
    "TOMGuildsAddon/letters/F.dds",  -- icon texture path
    OSI.GetIconSize() * 2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    4                              -- optional icon offset in meters
    )
   end -- CLOSE OF IF ON IN HRC CHECK

  if (zoneId ~= 636) then -- IF WE ARE NOT IN HEL RA CITADEL THEN UNSET ANY HEL RA CITADEL ICONS THAT MAY HAVE BEEN PREVIOUSLY SET
  if ICON_HRC_A ~= nil then
  OSI.DiscardPositionIcon( ICON_HRC_A )
  ICON_HRC_A = nil
  end
  if ICON_HRC_B ~= nil then
  OSI.DiscardPositionIcon( ICON_HRC_B )
  ICON_HRC_B = nil
  end
  if ICON_HRC_C ~= nil then
  OSI.DiscardPositionIcon( ICON_HRC_C )
  ICON_HRC_C = nil
  end
  if ICON_HRC_D ~= nil then
  OSI.DiscardPositionIcon( ICON_HRC_D )
  ICON_HRC_D = nil
  end
  if ICON_HRC_E ~= nil then
  OSI.DiscardPositionIcon( ICON_HRC_E )
  ICON_HRC_E = nil
  end
  if ICON_HRC_F ~= nil then
  OSI.DiscardPositionIcon( ICON_HRC_F )
  ICON_HRC_F = nil
  end
 end -- CLOSE OF IF ON NOT IN HRC CHECK

fchecker = false

-- ENCOUNTER LOG TRIAL SECTION
 if (TGAAddon.svChar.enclogtrial == true) then
  if ((zoneId == 636) or (zoneId == 638) or (zoneId == 639) or (zoneId == 725) or (zoneId == 975) or (zoneId == 1000) or (zoneId == 1051) or (zoneId == 1021) or (zoneId == 1196) or (zoneId == 1344) or (zoneId == 1427) or (zoneId == 1263) or (zoneId == 1478) or (zoneId == 1548)) then
   fchecker = true
   encounterlogcheck()
   TGAAddon.svChar.hiddenUI = false
   TGAAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG DUNGEON SECTION
if (TGAAddon.svChar.enclogdungeon == true) then
 if ((zoneId == 11) or (zoneId == 22) or (zoneId == 31) or (zoneId == 38) or (zoneId == 63) or (zoneId == 64) or (zoneId == 126) or (zoneId == 130) or (zoneId == 131) or (zoneId == 144) or (zoneId == 146) or (zoneId == 148) or (zoneId == 176) or (zoneId == 283) or (zoneId == 380) or (zoneId == 449) or (zoneId == 678) or (zoneId == 681) or (zoneId == 688) or (zoneId == 843) or (zoneId == 848) or (zoneId == 930) or (zoneId == 931) or (zoneId == 932) or (zoneId == 933) or (zoneId == 934) or (zoneId == 935) or (zoneId == 936) or (zoneId == 973) or (zoneId == 974) or (zoneId == 1009) or (zoneId == 1010) or (zoneId == 1052) or (zoneId == 1055) or (zoneId == 1080) or (zoneId == 1081) or (zoneId == 1122) or (zoneId == 1123) or (zoneId == 1152) or (zoneId == 1153) or (zoneId == 1197) or (zoneId == 1201) or (zoneId == 1228) or (zoneId == 1229) or (zoneId == 1267) or (zoneId == 1268) or (zoneId == 1301) or (zoneId == 1302) or (zoneId == 1360) or (zoneId == 1361) or (zoneId == 1389) or (zoneId == 1390) or (zoneId == 1471) or (zoneId == 1470) or (zoneId == 1496) or (zoneId == 1497)) then
   fchecker = true
   encounterlogcheck()
   TGAAddon.svChar.hiddenUI = false
   TGAAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG ARENA SECTION
if (TGAAddon.svChar.enclogarena == true) then
 if ((zoneId == 677) or (zoneId == 635) or (zoneId == 1082) or (zoneId == 1227) or (zoneId == 1436)) then
   fchecker = true
   encounterlogcheck()
   TGAAddon.svChar.hiddenUI = false
   TGAAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG CYRO SECTION
 if (TGAAddon.svChar.enclogcyro == true) then
  if (zoneId == 181) then
   fchecker = true
   encounterlogcheck()
   TGAAddon.svChar.hiddenUI = false
   TGAAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG IC SECTION
 if (TGAAddon.svChar.enclogic == true) then
  if (zoneId == 643) then
   fchecker = true
   encounterlogcheck()
   TGAAddon.svChar.hiddenUI = false
   TGAAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

if (fchecker == false) then
  TGAAddonENCUI:SetHidden(true) -- MAKE LOGGER INVISIBLE
  TGAAddon.svChar.hiddenUI = true
end


end -- CLOSE OF SHOWMARKERS FUNCTION

-- SANITYS EDGE PUZZLE SOLVER

function TGAAddon.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  if result == ACTION_RESULT_EFFECT_FADED and abilityId == 186000 then -- IF THE CHIMERA HAS JUST SPAWNED OR DESTONED ITSELF
  ClearSEMarkersNow()
  end
end

function ClearSEMarkers(event, channelType, fromName, messageText, isCustomerService, fromDisplayName)
local patternc = "^[Cc][Vv][Ss][Ee]$"
  if string.len(messageText) == 4 and string.match(messageText, patternc) then
   ClearSEMarkersNow()
  end -- CLOSE STRING MATCH
end -- CLOSE CLEAR FUNCTION

function ClearSEMarkersNow()
  if VSEMARKER_LION_A  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_A )
  VSEMARKER_LION_A = nil
  end
  if VSEMARKER_LION_B  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_B )
  VSEMARKER_LION_B = nil
  end
  if VSEMARKER_LION_C  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_C )
  VSEMARKER_LION_C = nil
  end
  if VSEMARKER_LION_D  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_D )
  VSEMARKER_LION_D = nil
  end
  if VSEMARKER_LION_E  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_LION_E )
  VSEMARKER_LION_E = nil
  end
  if VSEMARKER_GRYPHON_A  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_A )
  VSEMARKER_GRYPHON_A = nil
  end
  if VSEMARKER_GRYPHON_B  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_B )
  VSEMARKER_GRYPHON_B = nil
  end
  if VSEMARKER_GRYPHON_C  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_C )
  VSEMARKER_GRYPHON_C = nil
  end
  if VSEMARKER_GRYPHON_D  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_D )
  VSEMARKER_GRYPHON_D = nil
  end
  if VSEMARKER_GRYPHON_E  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_GRYPHON_E )
  VSEMARKER_GRYPHON_E = nil
  end
  if VSEMARKER_WAMASU_A  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_A )
  VSEMARKER_WAMASU_A = nil
  end
  if VSEMARKER_WAMASU_B  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_B )
  VSEMARKER_WAMASU_B = nil
  end
  if VSEMARKER_WAMASU_C  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_C )
  VSEMARKER_WAMASU_C = nil
  end
  if VSEMARKER_WAMASU_D  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_D )
  VSEMARKER_WAMASU_D = nil
  end
  if VSEMARKER_WAMASU_E  ~= nil then
  OSI.DiscardPositionIcon( VSEMARKER_WAMASU_E )
  VSEMARKER_WAMASU_E = nil
  end
end -- CLOSE CLEAR FUNCTION

function SanitySolver(event, channelType, fromName, messageText, isCustomerService, fromDisplayName)
local zoneId2 = GetZoneId(GetUnitZoneIndex("player")) -- GET CURRENT PLAYER ZONE ID
 if (zoneId2 == 1427 and TGAAddon.svChar.semarkers) then -- IF IN SE AND ON 2ND BOSS
  vse_chimera1 = {
    [1] = {171984,40350,238116}, --gryphon
    [2] = {181899,40350,238230}, --lion
    [3] = {191735,40350,238150}, --wamasu
  }
  vse_chimera2 = {
    [1] = {172026,40350,242013}, --gryphon
    [2] = {181903,40350,242085}, --lion
    [3] = {191874,40350,242064}, --wamasu
  }
  vse_chimera3 = {
    [1] = {170048,40350,242200}, --gryphon
    [2] = {179948,40350,242203}, --lion
    [3] = {189859,40350,242154}, --wamasu
  }
  vse_chimera4 = {
    [1] = {168148,40350,242050}, --gryphon
    [2] = {178072,40350,242011}, --lion
    [3] = {187935,40350,242088}, --wamasu
  }
  vse_chimera5 = {
    [1] = {168147,40350,238168}, --gryphon
    [2] = {178065,40350,238175}, --lion
    [3] = {187954,40350,238224}, --wamasu
  }
local pattern = "^[LlWwGg][12345][12345][12345][12345][12345]$"
local pattern2 = "^[12345][12345][12345][12345][12345][LlWwGg]$"
messageText = messageText:gsub("%s+", "")
  if string.len(messageText) == 6 and (string.match(messageText, pattern) or string.match(messageText, pattern2)) then
   local firstChar = string.sub(messageText, 1, 1)
   local lastChar = string.sub(messageText, -1)
   local LionString
    if firstChar == "L" or firstChar == "l" or lastChar == "L" or lastChar == "l" then -- IN LION ROOM
     if firstChar == "L" or firstChar == "l" then
      LionString = string.sub(messageText, 2) -- extract the numbers after the letter
     end
     if lastChar == "L" or lastChar == "l" then
      LionString = string.sub(messageText, 1, 5) -- extract the numbers before the letter
     end
     local vseLion1 = tonumber(string.sub(LionString, 1, 1))
     if vseLion1 ~= nil then
      if VSEMARKER_LION_A ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_LION_A)
      VSEMARKER_LION_A = nil
      end
      makevselionmarkerA = "vse_chimera" .. vseLion1
      vselionmarkerA1 = _G[makevselionmarkerA][2][1]
      vselionmarkerA2 = _G[makevselionmarkerA][2][2]
      vselionmarkerA3 = _G[makevselionmarkerA][2][3]
      VSEMARKER_LION_A = OSI.CreatePositionIcon(
      vselionmarkerA1, vselionmarkerA2, vselionmarkerA3,         -- world coordinates
      "TOMGuildsAddon/letters/A.dds",  -- icon texture pathf
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
      end
     local vseLion2 = tonumber(string.sub(LionString, 2, 2))
    if vseLion2 ~= nil then
      if VSEMARKER_LION_B ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_LION_B)
      VSEMARKER_LION_B = nil
      end
      makevselionmarkerB = "vse_chimera" .. vseLion2
      vselionmarkerB1 = _G[makevselionmarkerB][2][1]
      vselionmarkerB2 = _G[makevselionmarkerB][2][2]
      vselionmarkerB3 = _G[makevselionmarkerB][2][3]
      VSEMARKER_LION_B = OSI.CreatePositionIcon(
      vselionmarkerB1, vselionmarkerB2, vselionmarkerB3,         -- world coordinates
      "TOMGuildsAddon/letters/B.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
      end
     local vseLion3 = tonumber(string.sub(LionString, 3, 3))
    if vseLion3 ~= nil then
      if VSEMARKER_LION_C ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_LION_C)
      VSEMARKER_LION_C = nil
      end
      makevselionmarkerC = "vse_chimera" .. vseLion3
      vselionmarkerC1 = _G[makevselionmarkerC][2][1]
      vselionmarkerC2 = _G[makevselionmarkerC][2][2]
      vselionmarkerC3 = _G[makevselionmarkerC][2][3]
      VSEMARKER_LION_C = OSI.CreatePositionIcon(
      vselionmarkerC1, vselionmarkerC2, vselionmarkerC3,         -- world coordinates
      "TOMGuildsAddon/letters/C.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
      end
     local vseLion4 = tonumber(string.sub(LionString, 4, 4))
    if vseLion4 ~= nil then
      if VSEMARKER_LION_D ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_LION_D)
      VSEMARKER_LION_D = nil
      end
      makevselionmarkerD = "vse_chimera" .. vseLion4
      vselionmarkerD1 = _G[makevselionmarkerD][2][1]
      vselionmarkerD2 = _G[makevselionmarkerD][2][2]
      vselionmarkerD3 = _G[makevselionmarkerD][2][3]
      VSEMARKER_LION_D = OSI.CreatePositionIcon(
      vselionmarkerD1, vselionmarkerD2, vselionmarkerD3,         -- world coordinates
      "TOMGuildsAddon/letters/D.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
      end
     local vseLion5 = tonumber(string.sub(LionString, 5, 5))
    if vseLion5 ~= nil then
      if VSEMARKER_LION_E ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_LION_E)
      VSEMARKER_LION_E = nil
      end
      makevselionmarkerE = "vse_chimera" .. vseLion5
      vselionmarkerE1 = _G[makevselionmarkerE][2][1]
      vselionmarkerE2 = _G[makevselionmarkerE][2][2]
      vselionmarkerE3 = _G[makevselionmarkerE][2][3]
      VSEMARKER_LION_E = OSI.CreatePositionIcon(
      vselionmarkerE1, vselionmarkerE2, vselionmarkerE3,         -- world coordinates
      "TOMGuildsAddon/letters/E.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
      end
    end -- CLOSE OF LION ROOM
if firstChar == "G" or firstChar == "g" or lastChar == "G" or lastChar == "g" then -- IN GRYPHON ROOM
   local GryphonString
     if firstChar == "G" or firstChar == "g" then
      GryphonString = string.sub(messageText, 2) -- extract the numbers after the letter
     end
     if lastChar == "G" or lastChar == "g" then
      GryphonString = string.sub(messageText, 1, 5) -- extract the numbers before the letter
     end
     local vseGryphon1 = tonumber(string.sub(GryphonString, 1, 1))
    if vseGryphon1 ~= nil then
      if VSEMARKER_GRYPHON_A ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_GRYPHON_A)
      VSEMARKER_GRYPHON_A = nil
      end
      makevsegryphonmarkerA = "vse_chimera" .. vseGryphon1
      vsegryphonmarkerA1 = _G[makevsegryphonmarkerA][1][1]
      vsegryphonmarkerA2 = _G[makevsegryphonmarkerA][1][2]
      vsegryphonmarkerA3 = _G[makevsegryphonmarkerA][1][3]
      VSEMARKER_GRYPHON_A = OSI.CreatePositionIcon(
      vsegryphonmarkerA1, vsegryphonmarkerA2, vsegryphonmarkerA3,         -- world coordinates
      "TOMGuildsAddon/letters/A.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
      end
     local vseGryphon2 = tonumber(string.sub(GryphonString, 2, 2))
     if vseGryphon2 ~= nil then
      if VSEMARKER_GRYPHON_B ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_GRYPHON_B)
      VSEMARKER_GRYPHON_B = nil
      end
      makevsegryphonmarkerB = "vse_chimera" .. vseGryphon2
      vsegryphonmarkerB1 = _G[makevsegryphonmarkerB][1][1]
      vsegryphonmarkerB2 = _G[makevsegryphonmarkerB][1][2]
      vsegryphonmarkerB3 = _G[makevsegryphonmarkerB][1][3]
      VSEMARKER_GRYPHON_B = OSI.CreatePositionIcon(
      vsegryphonmarkerB1, vsegryphonmarkerB2, vsegryphonmarkerB3,         -- world coordinates
      "TOMGuildsAddon/letters/B.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
    end
     local vseGryphon3 = tonumber(string.sub(GryphonString, 3, 3))
     if vseGryphon3 ~= nil then
      if VSEMARKER_GRYPHON_C ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_GRYPHON_C)
      VSEMARKER_GRYPHON_C = nil
      end
      makevsegryphonmarkerC = "vse_chimera" .. vseGryphon3
      vsegryphonmarkerC1 = _G[makevsegryphonmarkerC][1][1]
      vsegryphonmarkerC2 = _G[makevsegryphonmarkerC][1][2]
      vsegryphonmarkerC3 = _G[makevsegryphonmarkerC][1][3]
      VSEMARKER_GRYPHON_C = OSI.CreatePositionIcon(
      vsegryphonmarkerC1, vsegryphonmarkerC2, vsegryphonmarkerC3,         -- world coordinates
      "TOMGuildsAddon/letters/C.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
    end
     local vseGryphon4 = tonumber(string.sub(GryphonString, 4, 4))
     if vseGryphon4 ~= nil then
      if VSEMARKER_GRYPHON_D ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_GRYPHON_D)
      VSEMARKER_GRYPHON_D = nil
      end
      makevsegryphonmarkerD = "vse_chimera" .. vseGryphon4
      vsegryphonmarkerD1 = _G[makevsegryphonmarkerD][1][1]
      vsegryphonmarkerD2 = _G[makevsegryphonmarkerD][1][2]
      vsegryphonmarkerD3 = _G[makevsegryphonmarkerD][1][3]
      VSEMARKER_GRYPHON_D = OSI.CreatePositionIcon(
      vsegryphonmarkerD1, vsegryphonmarkerD2, vsegryphonmarkerD3,         -- world coordinates
      "TOMGuildsAddon/letters/D.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
    end
     local vseGryphon5 = tonumber(string.sub(GryphonString, 5, 5))
     if vseGryphon5 ~= nil then
      if VSEMARKER_GRYPHON_E ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_GRYPHON_E)
      VSEMARKER_GRYPHON_E = nil
      end
      makevsegryphonmarkerE = "vse_chimera" .. vseGryphon5
      vsegryphonmarkerE1 = _G[makevsegryphonmarkerE][1][1]
      vsegryphonmarkerE2 = _G[makevsegryphonmarkerE][1][2]
      vsegryphonmarkerE3 = _G[makevsegryphonmarkerE][1][3]
      VSEMARKER_GRYPHON_E = OSI.CreatePositionIcon(
      vsegryphonmarkerE1, vsegryphonmarkerE2, vsegryphonmarkerE3,         -- world coordinates
      "TOMGuildsAddon/letters/E.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
     end
    end -- CLOSE OF GRYPHON ROOM
if firstChar == "W" or firstChar == "w" or lastChar == "W" or lastChar == "w" then -- in Wamasu Room
   local WamasuString
     if firstChar == "W" or firstChar == "w" then
      WamasuString = string.sub(messageText, 2) -- extract the numbers after the letter
     end
     if lastChar == "W" or lastChar == "w" then
      WamasuString = string.sub(messageText, 1, 5) -- extract the numbers before the letter
     end
     local vseWamasu1 = tonumber(string.sub(WamasuString, 1, 1))
     if vseWamasu1 ~= nil then
      if VSEMARKER_WAMASU_A ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_WAMASU_A)
      VSEMARKER_WAMASU_A = nil
      end
      makevsewamasumarkerA = "vse_chimera" .. vseWamasu1
      vsewamasumarkerA1 = _G[makevsewamasumarkerA][3][1]
      vsewamasumarkerA2 = _G[makevsewamasumarkerA][3][2]
      vsewamasumarkerA3 = _G[makevsewamasumarkerA][3][3]
      VSEMARKER_WAMASU_A = OSI.CreatePositionIcon(
      vsewamasumarkerA1, vsewamasumarkerA2, vsewamasumarkerA3,         -- world coordinates
      "TOMGuildsAddon/letters/A.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
     end
     local vseWamasu2 = tonumber(string.sub(WamasuString, 2, 2))
     if vseWamasu2 ~= nil then
      if VSEMARKER_WAMASU_B ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_WAMASU_B)
      VSEMARKER_WAMASU_B = nil
      end
      makevsewamasumarkerB = "vse_chimera" .. vseWamasu2
      vsewamasumarkerB1 = _G[makevsewamasumarkerB][3][1]
      vsewamasumarkerB2 = _G[makevsewamasumarkerB][3][2]
      vsewamasumarkerB3 = _G[makevsewamasumarkerB][3][3]
      VSEMARKER_WAMASU_B = OSI.CreatePositionIcon(
      vsewamasumarkerB1, vsewamasumarkerB2, vsewamasumarkerB3,         -- world coordinates
      "TOMGuildsAddon/letters/B.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
     end
     local vseWamasu3 = tonumber(string.sub(WamasuString, 3, 3))
     if vseWamasu3 ~= nil then
      if VSEMARKER_WAMASU_C ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_WAMASU_C)
      VSEMARKER_WAMASU_C = nil
      end
      makevsewamasumarkerC = "vse_chimera" .. vseWamasu3
      vsewamasumarkerC1 = _G[makevsewamasumarkerC][3][1]
      vsewamasumarkerC2 = _G[makevsewamasumarkerC][3][2]
      vsewamasumarkerC3 = _G[makevsewamasumarkerC][3][3]
      VSEMARKER_WAMASU_C = OSI.CreatePositionIcon(
      vsewamasumarkerC1, vsewamasumarkerC2, vsewamasumarkerC3,         -- world coordinates
      "TOMGuildsAddon/letters/C.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
     end
     local vseWamasu4 = tonumber(string.sub(WamasuString, 4, 4))
     if vseWamasu4 ~= nil then
      if VSEMARKER_WAMASU_D ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_WAMASU_D)
      VSEMARKER_WAMASU_D = nil
      end
      makevsewamasumarkerD = "vse_chimera" .. vseWamasu4
      vsewamasumarkerD1 = _G[makevsewamasumarkerD][3][1]
      vsewamasumarkerD2 = _G[makevsewamasumarkerD][3][2]
      vsewamasumarkerD3 = _G[makevsewamasumarkerD][3][3]
      VSEMARKER_WAMASU_D = OSI.CreatePositionIcon(
      vsewamasumarkerD1, vsewamasumarkerD2, vsewamasumarkerD3,         -- world coordinates
      "TOMGuildsAddon/letters/D.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
     end
     local vseWamasu5 = tonumber(string.sub(WamasuString, 5, 5))
     if vseWamasu5 ~= nil then
      if VSEMARKER_WAMASU_E ~= nil then
      OSI.DiscardPositionIcon(VSEMARKER_WAMASU_E)
      VSEMARKER_WAMASU_E = nil
      end
      makevsewamasumarkerE = "vse_chimera" .. vseWamasu5
      vsewamasumarkerE1 = _G[makevsewamasumarkerE][3][1]
      vsewamasumarkerE2 = _G[makevsewamasumarkerE][3][2]
      vsewamasumarkerE3 = _G[makevsewamasumarkerE][3][3]
      VSEMARKER_WAMASU_E = OSI.CreatePositionIcon(
      vsewamasumarkerE1, vsewamasumarkerE2, vsewamasumarkerE3,         -- world coordinates
      "TOMGuildsAddon/letters/E.dds",  -- icon texture path
      OSI.GetIconSize() * 1.2,       -- optional icon size
      { 1, 1, 1 },                   -- optional icon color {r,g,b}
      3                              -- optional icon offset in meters.
      )
     end
    end -- CLOSE OF WAMASU ROOM
 end -- CLOSE OF IF ON INTIAL STRING CHECK
end -- CLOSE OF IN IN SANITYS EDGE
end -- CLOSE OF FUNCTION

function PositionChatMessage(event, channelType, fromName, messageText, isCustomerService, fromDisplayName)
 SanitySolver(event, channelType, fromName, messageText, isCustomerService, fromDisplayName)
 ClearSEMarkers(event, channelType, fromName, messageText, isCustomerService, fromDisplayName)
  if string.len(messageText) > 5 then
    if (string.find(messageText, "TGA")) then
      for k in pairs(TGAt) do TGAt[k]=nil end
      for TGAstr in string.gmatch(messageText, "%S+") do
      i = 1
      table.insert(TGAt, i, TGAstr)
      i = i+1
      end
      i = 1
      TGAc = tonumber(TGAt[4])
      TGAx = tonumber(TGAt[3])
      TGAy = tonumber(TGAt[2])
      TGAz = tonumber(TGAt[1])
    AddaMarker(TGAx, TGAy, TGAz, TGAc)
    end
  end
-- SECRET MODE
 if (string.len(messageText) > 2 and TGAAddon.svChar.secretmode) then
    if (string.find(messageText, "sp1")) then
	SetGamepadVibration(500, 1, 1, 1, 1, "Level1")
    end
    if (string.find(messageText, "sp2")) then
	SetGamepadVibration(1000, 1, 1, 1, 1, "Level2")
    end
    if (string.find(messageText, "sp3")) then
	SetGamepadVibration(2000, 1, 1, 1, 1, "Level3")
    end
    if (string.find(messageText, "sp4")) then
	SetGamepadVibration(3000, 1, 1, 1, 1, "Level4")
    end
    if (string.find(messageText, "sp5")) then
	SetGamepadVibration(5000, 1, 1, 1, 1, "Level5")
     end
    if (string.find(messageText, "sp6")) then
	SetGamepadVibration(500, 0.2, 0.2, 0.2, 0.2, "Level6")
	zo_callLater(function() SetGamepadVibration(500, 0.4, 0.4, 0.4, 0.4, "Level6") end, 500)
	zo_callLater(function() SetGamepadVibration(500, 0.6, 0.6, 0.6, 0.6, "Level6") end, 1000)
	zo_callLater(function() SetGamepadVibration(500, 0.8, 0.8, 0.8, 0.8, "Level6") end, 1500)
	zo_callLater(function() SetGamepadVibration(500, 1, 1, 1, 1, "Level6") end, 2000)
	zo_callLater(function() SetGamepadVibration(500, 0.2, 0.2, 0.2, 0.2, "Level6") end, 2500)
	zo_callLater(function() SetGamepadVibration(500, 0.4, 0.4, 0.4, 0.4, "Level6") end, 3000)
	zo_callLater(function() SetGamepadVibration(500, 0.6, 0.6, 0.6, 0.6, "Level6") end, 3500)
	zo_callLater(function() SetGamepadVibration(500, 0.8, 0.8, 0.8, 0.8, "Level6") end, 4000)
	zo_callLater(function() SetGamepadVibration(1000, 1, 1, 1, 1, "Level6") end, 4500)
    end
    if (string.find(messageText, "sp7")) then
	SetGamepadVibration(1000, 1, 0, 0, 0, "Level7")
	zo_callLater(function() SetGamepadVibration(1000, 0, 1, 0, 0, "Level7") end, 1000)
	zo_callLater(function() SetGamepadVibration(1000, 1, 0, 0, 0, "Level7") end, 2000)
	zo_callLater(function() SetGamepadVibration(1000, 0, 1, 0, 0, "Level7") end, 3000)
	zo_callLater(function() SetGamepadVibration(1000, 1, 0, 0, 0, "Level7") end, 4000)
	zo_callLater(function() SetGamepadVibration(2000, 1, 1, 1, 1, "Level7") end, 5000)
    end
    if (string.find(messageText, "sp8")) then
	SetGamepadVibration(200, 1, 0, 0, 0, "Level8")
	zo_callLater(function() SetGamepadVibration(200, 0, 1, 0, 0, "Level8") end, 200)
	zo_callLater(function() SetGamepadVibration(200, 1, 0, 0, 0, "Level8") end, 400)
	zo_callLater(function() SetGamepadVibration(200, 0, 1, 0, 0, "Level8") end, 600)
	zo_callLater(function() SetGamepadVibration(200, 1, 0, 0, 0, "Level8") end, 800)
	zo_callLater(function() SetGamepadVibration(200, 0, 1, 0, 0, "Level8") end, 1000)
	zo_callLater(function() SetGamepadVibration(200, 1, 0, 0, 0, "Level8") end, 1200)
	zo_callLater(function() SetGamepadVibration(200, 0, 1, 0, 0, "Level8") end, 1400)
	zo_callLater(function() SetGamepadVibration(200, 1, 0, 0, 0, "Level8") end, 1600)
	zo_callLater(function() SetGamepadVibration(2000, 1, 1, 1, 1, "Level8") end, 1800)
    end
    if (string.find(messageText, "sp9")) then
	SetGamepadVibration(200, 1, 1, 1, 1, "Level8")
	zo_callLater(function() SetGamepadVibration(200, 0, 0, 0, 0, "Level9") end, 200)
	zo_callLater(function() SetGamepadVibration(200, 1, 1, 1, 1, "Level9") end, 400)
	zo_callLater(function() SetGamepadVibration(200, 0, 0, 0, 0, "Level9") end, 600)
	zo_callLater(function() SetGamepadVibration(200, 1, 1, 1, 1, "Level9") end, 800)
	zo_callLater(function() SetGamepadVibration(200, 0, 0, 0, 0, "Level9") end, 1000)
	zo_callLater(function() SetGamepadVibration(200, 1, 1, 1, 1, "Level9") end, 1200)
	zo_callLater(function() SetGamepadVibration(200, 0, 0, 0, 0, "Level9") end, 1400)
	zo_callLater(function() SetGamepadVibration(200, 1, 1, 1, 1, "Level9") end, 1600)
	zo_callLater(function() SetGamepadVibration(200, 0, 0, 0, 0, "Level9") end, 1800)
	zo_callLater(function() SetGamepadVibration(2000, 1, 1, 1, 1, "Level9") end, 2000)
    end
    if (string.find(messageText, "sp10")) then
	SetGamepadVibration(300, 0.2, 0.2, 0.2, 0.2, "Level6")
	zo_callLater(function() SetGamepadVibration(300, 0.4, 0.4, 0.4, 0.4, "Level10") end, 300)
	zo_callLater(function() SetGamepadVibration(300, 0.6, 0.6, 0.6, 0.6, "Level10") end, 600)
	zo_callLater(function() SetGamepadVibration(300, 0.8, 0.8, 0.8, 0.8, "Level10") end, 900)
	zo_callLater(function() SetGamepadVibration(300, 1, 1, 1, 1, "Level10") end, 1200)
	zo_callLater(function() SetGamepadVibration(300, 0.8, 0.8, 0.8, 0.8, "Level10") end, 1500)
	zo_callLater(function() SetGamepadVibration(300, 0.6, 0.6, 0.6, 0.6, "Level10") end, 1800)
	zo_callLater(function() SetGamepadVibration(300, 0.4, 0.4, 0.4, 0.4, "Level10") end, 2100)
	zo_callLater(function() SetGamepadVibration(300, 0.2, 0.2, 0.2, 0.2, "Level10") end, 2400)
	zo_callLater(function() SetGamepadVibration(500, 0, 0, 0, 0, "Level10") end, 2700)
	zo_callLater(function() SetGamepadVibration(1000, 1, 1, 1, 1, "Level10") end, 3200)
    end
  end -- CLOSE OF IF ON SECRET MODE CHECK
end -- CLOSE OF CHAT MSG POSITION FUNCTION

function WhereAmI(ChosenMarker)
    local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )
    local loctext = "/group TGA " .. ChosenMarker .. " " .. wX .. " " .. wY .. " " .. wZ
    ZO_ChatWindowTextEntryEditBox:SetText(loctext)
    AddaMarker(wX, wY, wZ, ChosenMarker)
end

function MoveMarker(WhichDirection)
 if (LastMarkerNo ~= nil) then
   if(WhichDirection == "xf") then
    LastXCoor = tonumber(LastXCoor)+100
   end
   if(WhichDirection == "xb") then
    LastXCoor = tonumber(LastXCoor)-100
   end
   if(WhichDirection == "yu") then
    LastYCoor = tonumber(LastYCoor)+100
   end
   if(WhichDirection == "yd") then
    LastYCoor = tonumber(LastYCoor)-100
   end
   if(WhichDirection == "zf") then
    LastZCoor = tonumber(LastZCoor)+100
   end
   if(WhichDirection == "zb") then
    LastZCoor = tonumber(LastZCoor)-100
   end
  local loctext = "/group TGA " .. LastMarkerNo .. " " .. LastXCoor .. " " .. LastYCoor .. " " .. LastZCoor
  ZO_ChatWindowTextEntryEditBox:SetText(loctext)
  AddaMarker(LastXCoor, LastYCoor, LastZCoor, LastMarkerNo)
 end
end

function AddaMarker(MarX, MarY, MarZ, ChosenMarker)
LastXCoor = MarX
LastYCoor = MarY
LastZCoor = MarZ
LastMarkerNo = ChosenMarker
local icontexturepath = "TOMGuildsAddon/numbers/" .. ChosenMarker .. ".dds"
 if (ChosenMarker == 1) then
     if MARKER_NUMBER_ONE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_ONE)
     MARKER_NUMBER_ONE = nil
     end
 MARKER_NUMBER_ONE = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 2) then
     if MARKER_NUMBER_TWO ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_TWO)
     MARKER_NUMBER_TWO = nil
     end
 MARKER_NUMBER_TWO = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 3) then
     if MARKER_NUMBER_THREE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_THREE)
     MARKER_NUMBER_THREE = nil
     end
 MARKER_NUMBER_THREE = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 4) then
     if MARKER_NUMBER_FOUR ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_FOUR)
     MARKER_NUMBER_FOUR = nil
     end
 MARKER_NUMBER_FOUR = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 5) then
     if MARKER_NUMBER_FIVE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_FIVE)
     MARKER_NUMBER_FIVE = nil
     end
 MARKER_NUMBER_FIVE = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 6) then
     if MARKER_NUMBER_SIX ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_SIX)
     MARKER_NUMBER_SIX = nil
     end
 MARKER_NUMBER_SIX = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 7) then
     if MARKER_NUMBER_SEVEN ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_SEVEN)
     MARKER_NUMBER_SEVEN = nil
     end
 MARKER_NUMBER_SEVEN = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 8) then
     if MARKER_NUMBER_EIGHT ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_EIGHT)
     MARKER_NUMBER_EIGHT = nil
     end
 MARKER_NUMBER_EIGHT = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 9) then
     if MARKER_NUMBER_NINE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_NINE)
     MARKER_NUMBER_NINE = nil
     end
 MARKER_NUMBER_NINE = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 10) then
     if MARKER_NUMBER_TEN ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_TEN)
     MARKER_NUMBER_TEN = nil
     end
 MARKER_NUMBER_TEN = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 11) then
     if MARKER_NUMBER_ELEVEN ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_ELEVEN)
     MARKER_NUMBER_ELEVEN = nil
     end
 MARKER_NUMBER_ELEVEN = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 12) then
     if MARKER_NUMBER_TWELVE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_TWELVE)
     MARKER_NUMBER_TWELVE = nil
     end
 MARKER_NUMBER_TWELVE = OSI.CreatePositionIcon(
    MarX, MarY, MarZ,         -- world coordinates
    icontexturepath,  -- icon texture path
    OSI.GetIconSize() * 1.2,       -- optional icon size
    { 1, 1, 1 },                   -- optional icon color {r,g,b}
    1                              -- optional icon offset in meters.
    )
 end
 if (ChosenMarker == 13) then
     if MARKER_NUMBER_ONE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_ONE)
     MARKER_NUMBER_ONE = nil
     end
     if MARKER_NUMBER_TWO ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_TWO)
     MARKER_NUMBER_TWO = nil
     end
     if MARKER_NUMBER_THREE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_THREE)
     MARKER_NUMBER_THREE = nil
     end
     if MARKER_NUMBER_FOUR ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_FOUR)
     MARKER_NUMBER_FOUR = nil
     end
     if MARKER_NUMBER_FIVE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_FIVE)
     MARKER_NUMBER_FIVE = nil
     end
     if MARKER_NUMBER_SIX ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_SIX)
     MARKER_NUMBER_SIX = nil
     end
     if MARKER_NUMBER_SEVEN ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_SEVEN)
     MARKER_NUMBER_SEVEN = nil
     end
     if MARKER_NUMBER_EIGHT ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_EIGHT)
     MARKER_NUMBER_EIGHT = nil
     end
     if MARKER_NUMBER_NINE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_NINE)
     MARKER_NUMBER_NINE = nil
     end
     if MARKER_NUMBER_TEN ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_TEN)
     MARKER_NUMBER_TEN = nil
     end
     if MARKER_NUMBER_ELEVEN ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_ELEVEN)
     MARKER_NUMBER_ELEVEN = nil
     end
     if MARKER_NUMBER_TWELVE ~= nil then
     OSI.DiscardPositionIcon(MARKER_NUMBER_TWELVE)
     MARKER_NUMBER_TWELVE = nil
     end
 end
end

-- PVP SECTION

function ICCYROToggle(Grouped)
  if Grouped == "group" then
    queueAsGroup = true
  end
  if Grouped == "single" then
    queueAsGroup = false
  end
  if IsPlayerInAvAWorld() and not IsInImperialCity() and not IsActiveWorldBattleground() then -- MUST BE IN CYRODIIL
   local cIdIc = TGAAddon.svChar.iccampaignid
    if cIdIc == 0 or cIdIc == nil then cIdIc = TGAAddon.svCharDef.iccampaignid end -- IF VARIABLES NOT SELECTED YET THEN USE DEFAULTS
      if not IsQueuedForCampaign(cIdIc, queueAsGroup) then
      CHAT_SYSTEM:AddMessage(zo_strformat("<<1>> Joining <<2>><<3>>", GetTimeString(), TGAAddon.myAllyIco, TGAAddon.col_pur:Colorize(GetCampaignName(cIdIc))))
      QueueForCampaign(cIdIc, queueAsGroup)
      else
      CHAT_SYSTEM:AddMessage(string.format("%s already queued", GetTimeString()))
      end
  else -- MUST BE IN IC
   local cIdCyro = TGAAddon.svChar.cyrocampaignid
    if cIdCyro == 0 or cIdCyro == nil then cIdCyro = TGAAddon.svCharDef.cyrocampaignid end
      if not IsQueuedForCampaign(cIdCyro, queueAsGroup) then
      CHAT_SYSTEM:AddMessage(zo_strformat("<<1>> Joining <<2>><<3>>", GetTimeString(), TGAAddon.myAllyIco, TGAAddon.myAllyCol:Colorize(GetCampaignName(cIdCyro))))
      QueueForCampaign(cIdCyro, queueAsGroup)
    else
      CHAT_SYSTEM:AddMessage(string.format("%s already queued", GetTimeString()))
    end
  end
end

local function OnQueueStateChange(eventCode, id, isGroup, state)
  if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then 
    if TGAAddon.svChar.autoAcceptChat then
      CHAT_SYSTEM:AddMessage(string.format("%s %s accepted", GetTimeString(), GetCampaignName(id)))
    end
  ConfirmCampaignEntry(id, isGroup, true)
  end
end

-- TBAG DEATH SECTION

local function tbagmode(eventCode, unitTag, isDead)
 if (isDead == true and unitTag == string.match(unitTag, "^group.*$") and (TGAAddon.svChar.tbagmarkers or TGAAddon.svChar.presmarkers)) then
   playerusername1 = GetUnitDisplayName(unitTag)
   local whichrole = GetGroupMemberSelectedRole(unitTag)
     if whichrole == LFG_ROLE_TANK then --- SHOW TANK TAGS
      if TGAAddon.svChar.presmarkers == true then
	icontouse = 'TOMGuildsAddon/other/Priorityrestank.dds' -- pick a random icon from the table of tank death icons
	xsizer = 3 -- optional icon size
      else
	icontouse = deathiconstank[ math.random( #deathiconstank ) ] -- pick a random icon from the table of tank death icons
	xsizer = 1.2 -- optional icon size
      end
	OSI.SetMechanicIconForUnit(
	playerusername1, -- display name of the affected player
	icontouse, -- icon texture path
	OSI.GetIconSize() * xsizer, -- optional icon size
	{ 1, 1, 1 }, -- optional icon color {r,g,b}
	0, -- optional icon offset in meters
	function( data )
	data.offset = 0.5 + 0.5 * math.sin( GetGameTimeMilliseconds() / 500 * 2 )
	end
	)
     elseif whichrole == LFG_ROLE_HEAL then --- SHOW HEAL TAGS
      if TGAAddon.svChar.presmarkers == true then
	icontouse = 'TOMGuildsAddon/other/Priorityresheal.dds' -- pick a random icon from the table of tank death icons
	xsizer = 3 -- optional icon size
      else
	icontouse = deathiconsheal[ math.random( #deathiconsheal ) ] -- pick a random icon from the table of heal death icons
	xsizer = 1.2 -- optional icon size
      end
	OSI.SetMechanicIconForUnit(
	playerusername1, -- display name of the affected player
	icontouse, -- icon texture path
	OSI.GetIconSize() * xsizer, -- optional icon size
	{ 1, 1, 1 }, -- optional icon color {r,g,b}
	0, -- optional icon offset in meters
	function( data )
	data.offset = 0.5 + 0.5 * math.sin( GetGameTimeMilliseconds() / 500 * 2 )
	end
	)
     elseif whichrole == LFG_ROLE_DPS and TGAAddon.svChar.tbagmarkers then --- SHOW DPS TAGS
	icontouse = deathiconsdps[ math.random( #deathiconsdps ) ] -- pick a random icon from the table of dps death icons
	OSI.SetMechanicIconForUnit(
	playerusername1, -- display name of the affected player
	icontouse, -- icon texture path
	OSI.GetIconSize() * 1.2, -- optional icon size
	{ 1, 1, 1 }, -- optional icon color {r,g,b}
	0, -- optional icon offset in meters
	function( data )
	data.offset = 0.5 + 0.5 * math.sin( GetGameTimeMilliseconds() / 500 * 2 )
	end
	)
     end
 end
 if isDead == false and unitTag == string.match(unitTag, "^group.*$") and (TGAAddon.svChar.tbagmarkers or TGAAddon.svChar.presmarkers) then
   playerusername1 = GetUnitDisplayName(unitTag)
   -- remove your icon from the formerly affected player
   OSI.RemoveMechanicIconForUnit( playerusername1 )
 end
end

--- ENCOUNTER LOG SECTION

function ToggleLogging()
 if IsEncounterLogEnabled() then
    SetEncounterLogEnabled(false)
 encounterlogprint()
 else
    SetEncounterLogEnabled(true)
 encounterlogprint()
 end
end

function encounterlogprint()
 if IsEncounterLogEnabled() then
   CHAT_ROUTER:AddSystemMessage("Encounter logging enabled.")
    local colour = {0.39, 0.82, 0.24, 0.8}
    TGAAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND GREEN
    TGAAddonENCUILabel:SetText("Logging On")
 else
   CHAT_ROUTER:AddSystemMessage("Encounter logging disabled.")
    local colour = {0.69, 0, 0, 0.8}
    TGAAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND RED
    TGAAddonENCUILabel:SetText("Logging Off")
 end
end

function encounterlogcheck()
 if IsEncounterLogEnabled() then
    local colour = {0.39, 0.82, 0.24, 0.8}
    TGAAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND GREEN
    TGAAddonENCUILabel:SetText("Logging On")
 else
    local colour = {0.69, 0, 0, 0.8}
    TGAAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND RED
    TGAAddonENCUILabel:SetText("Logging Off")
 end
end

function EncounterLogUIOnMoveStop()
 TGAAddon.svChar.xui = TGAAddonENCUI:GetLeft()
 TGAAddon.svChar.yui = TGAAddonENCUI:GetTop()
end

function TGAAddon:RestorePosition()
    TGAAddonENCUI:ClearAnchors()
    TGAAddonENCUI:SetHidden(TGAAddon.svChar.hiddenUI)
    TGAAddonENCUI:SetTopmost(true)
    TGAAddonENCUI:BringWindowToTop(true)
    TGAAddonENCUI:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        TGAAddon.svChar.xui,
        TGAAddon.svChar.yui
    )
end

--- Hide the window if visible and screen state changed to some dialogue/menu interface.
local function HideIfVisible()
    if TGAAddon.svChar.hiddenUI == false then
        TGAAddonENCUI:SetHidden(true)
    end
end
 
--- Show the window if visible and screen state returned to normal.
local function ShowIfVisible()
    if TGAAddon.svChar.hiddenUI == false then
        TGAAddonENCUI:SetHidden(false)
    end
end

---------------------

--- INITIALIZE ADDON ---

function TGAAddon:Initialize()
  TGAAddon.svChar = ZO_SavedVars:NewAccountWide("TomGuildsAddon", TGAAddon.variableVersion, nil, TGAAddon.svCharDef, GetWorldName())
  EVENT_MANAGER:RegisterForEvent( TGAAddon.name, EVENT_PLAYER_ACTIVATED, showMarkers)
    -- check if OdySupportIcons is active and supports unique icon packs
    if OSI and OSI.AddUniqueIconPack then
        OSI.AddUniqueIconPack( TOM_TEXTURES ) -- ADD CUSTOM PLAYER ICONS
    end
    -- check if OdySupportIcons is active and supports world posiiton icons
    if OSI and OSI.CreatePositionIcon then
        showMarkers() -- ADD CUSTOM ZONE MARKERS
    end
  TGAAddon.initMenu()
  --auto accept campaign
  if TGAAddon.svChar.autoAcceptPvpQ then
    EVENT_MANAGER:RegisterForEvent(TGAAddon.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnQueueStateChange)
  end
--  EVENT_MANAGER:RegisterForEvent(TGAAddon.name, EVENT_CHAT_MESSAGE_CHANNEL, PositionChatMessage, SanitySolver)
  EVENT_MANAGER:RegisterForEvent(TGAAddon.name, EVENT_CHAT_MESSAGE_CHANNEL, PositionChatMessage)
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(TGAAddon.name, EVENT_BOSSES_CHANGED, BossChange)
  EVENT_MANAGER:RegisterForEvent(TGAAddon.name, EVENT_BOSSES_CHANGED, BossChange)
  -- DEATH STAT
  EVENT_MANAGER:RegisterForEvent(TGAAddon.name, EVENT_UNIT_DEATH_STATE_CHANGED, tbagmode)
  --
  EVENT_MANAGER:UnregisterForEvent(TGAAddon.name, EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(TGAAddon.name, EVENT_COMBAT_EVENT, TGAAddon.CombatEvent)


 -- Hotkeys
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_CLEAR", "Marker Placement Clear")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_ONE", "Marker Placement One")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_TWO", "Marker Placement Two")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_THREE", "Marker Placement Three")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_FOUR", "Marker Placement Four")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_FIVE", "Marker Placement Five")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_SIX", "Marker Placement Six")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_SEVEN", "Marker Placement Seven")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_EIGHT", "Marker Placement Eight")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_NINE", "Marker Placement Nine")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_TEN", "Marker Placement Ten")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_ELEVEN", "Marker Placement Eleven")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_TWELVE", "Marker Placement Twelve")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_XF", "Move Marker East")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_XB", "Move Marker West")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_ZF", "Move Marker South")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_ZB", "Move Marker North")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_YU", "Move Marker Up")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_MARKER_PLACEMENT_YD", "Move Marker Down")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_TOGGLE_CYRO_SINGLE","Toggle IC & Cyrodiil Single Mode")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_TOGGLE_CYRO_GROUP","Toggle IC & Cyrodiil Group Mode")
  ZO_CreateStringId("SI_BINDING_NAME_TOM_GUILD_ADDON_TOGGLE_ENCOUNTER_LOG", "Toggle Encounter Log")
  TGAAddon:RestorePosition()
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        ShowIfVisible()
    end)
  EVENT_MANAGER:UnregisterForEvent( TGAAddon.name, EVENT_ADD_ON_LOADED )
end -- close Main Initilze function


function TGAAddon.OnAddOnLoaded(event, addonName)
  if addonName == TGAAddon.name then
    TGAAddon:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(TGAAddon.name, EVENT_ADD_ON_LOADED, TGAAddon.OnAddOnLoaded)