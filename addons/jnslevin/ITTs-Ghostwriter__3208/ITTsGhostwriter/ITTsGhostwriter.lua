local GW =
    ITTsGhostwriter or
    {
        name = "ITTsGhostwriter",
        version = "2.2.2",
        variableVersion = 194,
        COLOR = "1590B2"
    }
ITTsGhostwriter = GW
-------------------
--Saved Variables--
-------------------
local defaults = {
    generalSettings = {
        offlinecheck = true,
        offlinemodecheck = true,
        backupButton = false,
        chatWindowButtonOffsetX = -40,
    },
    guilds = {},
    debugMode = false,
    firstload = true,

    selectedGuild = GetGuildId( 1 ),
    lastOpenedCategory = "",
    mailComboBoxLastSelectedItemIndex = 1,
    noteWindow = {
        x = 0,
        y = 0,
        previewHidden = true
    },
    notes = {
        [ "Uncategorized" ] = {
            iconIndex = 70,
            priority = 0
        }
    }
}
-------------------
--Local Variables--
-------------------

local db
local worldName = GetWorldName()
GW.guildTable = {}
GW.guildTableValues = {}
GW.ChatReady = false
local GWadvertisement = ("\n\n\nSent via |cffffffITT's|c" .. GW.COLOR .. "Ghostwriter|r")
---------
--Setup--
---------

local function setupGuildData()
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId( i )
        local name = GetGuildName( guildId )
        local numMembers = GetNumGuildMembers( guildId )
        local link = GW.CreateGuildLink( guildId )
        if GW.GetPermission_Note( guildId ) == true then
            table.insert( GW.GuildsWithPermisson, guildId )
            GW.shouldHideFor[ guildId ] = false
        else
            GW.shouldHideFor[ guildId ] = true
        end
        local guildDefaults = {
            messageBody = "Welcome %PLAYER% to %GUILD% do we get cake?",
            mailBody =
            "I am very happy to welcome you to my guild %PLAYER%\ncakes are to be deposited in our guildbank <3",
            mailEnabled = false,
            mailSubject = "Welcome to %GUILD%",
            messageEnabled = true,
            noteEnabled = false,
            noteBody = "%DATE%\n%PLAYER%\nhas brought cake",
            autobackup = false,
            dateFormat = "%d.%m.%y",
            applicationThreshold = 300,
            noteAlert = true,
            applicationAlert = true
        }

        local guildTable = db.guilds[ guildId ]

        if not guildTable then
            guildTable = {}
            db.guilds[ guildId ] = guildTable
        end

        guildTable.settings = guildTable.settings or
            ZO_DeepTableCopy( guildDefaults )
        guildTable.name = guildTable.name or name
        guildTable.id = guildId

        GW.guildTable[ i ] = link
        GW.guildTableValues[ i ] = guildId

        GWData[ worldName ] = GWData[ worldName ] or {}
        GWData[ worldName ].guilds = GWData[ worldName ].guilds or {}
        GWData[ worldName ].guilds.savedNotes = GWData[ worldName ].guilds
            .savedNotes or {
            }
        GWData[ worldName ].guilds.savedNotes[ guildId ] = GWData
            [ worldName ].guilds.savedNotes[ guildId ] or {
            }

        if guildTable.settings.autobackup then
            for memberIndex = 1, numMembers do
                local playerName, note, rankIndex, _, _ = GetGuildMemberInfo(
                    guildId, memberIndex )
                GWData[ worldName ].guilds.savedNotes[ guildId ][ playerName ] =
                    note
            end
        end

        guildTable.settings.achievementThreshold = guildTable.settings.achievementThreshold or 5000
    end
end
function GW.HideBackupButton()
    GW_button:SetHidden( not ITTsGhostwriter.Vars.generalSettings.backupButton )
end

function GW.EnableBackupButton()
    ZO_PreHook(
        GUILD_ROSTER_MANAGER,
        "OnGuildIdChanged",
        function( self )
            GW_button:SetEnabled( not GW.shouldHideFor[ self.guildId ] )
        end
    )
end

function ITTsGhostwriter.ToggleDebugMode()
    local chat = LibChatMessage( "ITTsGhostwriter", "ITTsGW" )
    ITTsGhostwriter.Vars.debugMode = not ITTsGhostwriter.Vars.debugMode
    if ITTsGhostwriter.Vars.debugMode then
        chat:Print( "Debug mode enabled" )
    else
        chat:Print( "Debug mode disabled" )
    end
    -- Update the enabled state of all logger instances
    for _, instance in ipairs( GWLogger.instances ) do
        instance:UpdateEnabledState()
    end
end

SLASH_COMMANDS[ "/itt-debugmode" ] = ITTsGhostwriter.ToggleDebugMode

--------------------
--OnAddOnLoaded-----
--------------------
function GW.OnAddOnLoaded( event, addonName )
    if addonName ~= GW.name then
        return
    end
    GW.Initialize()
end

----------------------
---OnPlayerActivated--
----------------------
local function OnPlayerActivated()
    setupGuildData()
    GW.myGuildColumn:SetGuildFilter( GW.GuildsWithPermisson )
    GW.ChatReady = true
    ITTsGhostwriter.Vars.debugMode = false
end

-------------------------
---Initialize Functions--
-------------------------

function GW.Initialize()
    GW.InitializeVariables()
    GW.InitializeUI()
    GW.RegisterEvents()
end

function GW.InitializeVariables()
    ITTsGhostwriter.Vars = ZO_SavedVars:NewAccountWide( "GWSettings",
        GW.variableVersion,
        nil, defaults,
        GetWorldName() )
    ITTsGhostwriter.Vars.debugMode = false
    for _, instance in ipairs( GWLogger.instances ) do
        instance:UpdateEnabledState()
    end
    db = ITTsGhostwriter.Vars
    if not GWData then
        GWData = {}
    end
    ITTsGhostwriter.CM = {}

    ITTsGhostwriter.CM = ITTsGhostwriter.CategoryManager:New()
end

function GW.InitializeUI()
    ZO_CreateStringId( "SI_BINDING_NAME_ITT_SHOW_NOTEPAD", "Show Notepad" )
    GW.UI:Initialize()
    GW.RosterRow()
    GW.HideBackupButton()
    GW.EnableBackupButton()
    -- GW.tree.Initialize()
end

function GW.RegisterEvents()
    GW.events.Register()
    GW.InitializeSettings()
    EVENT_MANAGER:UnregisterForEvent( GW.name, EVENT_ADD_ON_LOADED )
    GW.CategoryManager.Initialize()
end

----------
--Events--
----------

EVENT_MANAGER:RegisterForEvent( GW.name, EVENT_ADD_ON_LOADED,
    ITTsGhostwriter.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( GW.name, EVENT_PLAYER_ACTIVATED,
    OnPlayerActivated )
