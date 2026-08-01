-----------------------------------------------------------------
--Author: Baertram
--[[
Write your own notes for friends, ignored players and guild mates]]
-----------------------------------------------------------------
FCONotes = {}
local FCON = FCONotes


local addonVars = { }
addonVars.addonName             = "FCONotes"
addonVars.addonNameMenu			= "FCO Notes"
addonVars.savedVariablesName	= "FCONotes_Settings"
addonVars.addonNameMenuDisplay	= "|c00FF00FCO |cFFFF00Notes|r"
addonVars.addonAuthor 			= '|cFFFF00Baertram|r'
addonVars.addonVersion		   	= 0.01 -- Version for the SavedVariables. Changing this will create TOTALY NEW SavedVariables!
addonVars.addonVersionOptions 	= '0.2.0'
addonVars.addonVersionOptionsNumber = 0.20
FCON.addonVars = addonVars

--Global list types where the note icons can be added
FCONOTES_LIST_TYPE_GUILDS_ROSTER =  1
FCONOTES_LIST_TYPE_FRIENDS_LIST =   2
FCONOTES_LIST_TYPE_IGNORE_LIST =    3

--Versions
FCON.version = addonVars.addonVersionOptions
FCON.svLoaded = false

--The textures for the notes icon
FCON.textureVars = {}

--Variables for the addon
local preventerVars = {}
preventerVars.gLocalizationDone     		= false
preventerVars.KeyBindingTexts	    		= false
preventerVars.lastGuildId           		= -1
preventerVars.doBackupGuildNotes    		= false
preventerVars.addonLoaded           		= false
preventerVars.guildHomeSceneFirstRun		= true
preventerVars.dontChangeSceneVar			= false
preventerVars.sceneButtonsPreHook   		= false
preventerVars.sceneButtonsHeraldricPreHook	= false
preventerVars.buttonPressed					= false
FCON.preventerVars = preventerVars


local guildRosterVars = {}
guildRosterVars.lastRowControl = nil
guildRosterVars.firstCall      = true
guildRosterVars.scene          = nil
FCON.guildRosterVars = guildRosterVars

local friendsListVars = {}
friendsListVars.lastRowControl = nil
friendsListVars.firstCall      = true
friendsListVars.scene          = nil
FCON.friendsListVars = friendsListVars

local ignoreListVars = {}
ignoreListVars.lastRowControl = nil
ignoreListVars.firstCall      = true
ignoreListVars.scene          = nil
FCON.ignoreListVars = ignoreListVars

local keystripVars = {}
keystripVars.GuildRosterAddPersonalNote = {}
FCON.keystripVars = keystripVars


local settingsVars				= {}
settingsVars.settings 			= {}
settingsVars.defaultSettings	= {}
settingsVars.defaultSettingsDefaults = {
    language = 1, --Standard: English
    saveMode = 2, --Standard: Account wide settingsVars.settings
}
settingsVars.defaults	= {
    languageChoosen			            = false,
    useKeybind                          = true,
    icon		 		                = {
        --Preset the default icon color and textures
        [FCONOTES_LIST_TYPE_GUILDS_ROSTER] = {
            color = {},
            color   = {["r"] = 1,["g"] = 0.7137255073,["b"] = 0.2274509817,["a"] = 1}, -- orange
            texture = 12, -- (i) symbol
            size    = 32,
            position = { x = 800, y = 0 },
        },
        [FCONOTES_LIST_TYPE_FRIENDS_LIST] = {
            color = {},
            color   = {["r"] = 1,["g"] = 0.7137255073,["b"] = 0.2274509817,["a"] = 1}, -- orange
            texture = 12, -- (i) symbol
            size    = 32,
            position = { x = 800, y = 0 },
        },
        [FCONOTES_LIST_TYPE_IGNORE_LIST] = {
            color = {},
            color   = {["r"] = 1,["g"] = 0.7137255073,["b"] = 0.2274509817,["a"] = 1}, -- orange
            texture = 12, -- (i) symbol
            size    = 32,
            position = { x = 800, y = 0 },
        }
    },

    enableNotes = {
        [FCONOTES_LIST_TYPE_GUILDS_ROSTER] =    true,
        [FCONOTES_LIST_TYPE_FRIENDS_LIST] =     false,
        [FCONOTES_LIST_TYPE_IGNORE_LIST] =      false,
    },

    saveGuildPersonalNotesAccountWide   = false,
    personalGuildNotes                  = {},
    personalGuildNotesBackup            = {},
    showAlwaysGuildRoster               = false,

    personalFriendsListNotes            = {},
    personalFriendsListNotesBackup      = {},

    personalIgnoreListNotes             = {},
    personalIgnoreListNotesBackup       = {},
}


FCON.settingsVars = settingsVars

local localizationVars = {}
FCON.localizationVars = localizationVars


local zosVars = {}
zosVars.guildRosterList     = ZO_GuildRosterList        --GUILD_ROSTER_MANAGER
zosVars.friendsList         = ZO_KeyboardFriendsListList    --FRIENDS_LIST -> SecurePostHook(FRIENDS_LIST, "SetupRow", function(control, data) end)
zosVars.ignoreList          = ZO_KeyboardIgnoreListList     --IGNORE_LIST -> SecurePostHook(IGNORE_LIST, "SetupRow", function(control, data) end)
FCON.zosVars = zosVars


--Libraries
FCON.LAM = LibAddonMenu2
