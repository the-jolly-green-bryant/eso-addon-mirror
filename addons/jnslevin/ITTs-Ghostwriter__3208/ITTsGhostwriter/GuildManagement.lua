local GuildRoster = {}
local GW = ITTsGhostwriter
ITTsGhostwriter.GuildRoster = GuildRoster
local logger = GWLogger:New( "GuildManagement" )
local worldName = GetWorldName()
local function chat( message, ... )
    GW.PrintChatMessage( message, ... )
end
------------
----Libs----
------------
local libCM = LibCustomMenu
function GW.BackupNotes( guildId )
    local numMembers = GetNumGuildMembers( guildId )
    local link = GW.CreateGuildLink( guildId )
    if GW.GetPermission_Note( guildId ) == false then
        chat:Print( "|cffffffYou currently do not have |c" ..
            GW.COLOR ..
            "Ghostwriter |cffffffnoting permissions for " .. link )
    else
        if not GWData[ worldName ].guilds then
            GWData[ worldName ].guilds = {}
        end
        if not GWData[ worldName ].guilds.savedNotes then
            GWData[ worldName ].guilds.savedNotes = {}
        end

        if not GWData[ worldName ].guilds.savedNotes[ guildId ] then
            GWData[ worldName ].guilds.savedNotes[ guildId ] = {}
        end
        for l = 1, numMembers do
            local playerName, note, rankIndex, _, _ = GetGuildMemberInfo(
                guildId, l )


            GWData[ worldName ].guilds.savedNotes[ guildId ][ playerName ] =
                note
        end
        chat:Print( "|cffffffNote backup for " ..
            link .. " |cffffffsuccessful!" )
    end
    LibGuildRoster:Refresh()
end

function GuildRoster.BackupNotes( guildId )
    local link = GW.CreateGuildLink( guildId )
    local numMembers = GetNumGuildMembers( guildId )
    if not GW.GetPermission_Note( guildId ) then
        return chat(
            "|cffffffYou currently do not have |c%sGhostwriter |cffffffnoting permissions for %s",
            GW.COLOR, link )
    else
        local hasNotes = false

        if not GWData[ worldName ].guilds then
            GWData[ worldName ].guilds = {}
        end
        if not GWData[ worldName ].guilds.savedNotes then
            GWData[ worldName ].guilds.savedNotes = {}
        end


        for memberIndex = 1, numMembers do
            local playerName, note, rankIndex, _, _ = GetGuildMemberInfo(
                guildId, memberIndex )
            if note and note ~= "" then
                if not GWData[ worldName ].guilds.savedNotes[ guildId ] then
                    GWData[ worldName ].guilds.savedNotes[ guildId ] = {}
                end
                hasNotes = true
                if GWData[ worldName ].guilds.savedNotes[ guildId ][ playerName ] ~= note then
                    GWData[ worldName ].guilds.savedNotes[ guildId ][ playerName ] =
                        note
                end
            end
        end

        if hasNotes then
            chat( "|cffffffNote backup for %s |cffffffsuccessful!", link )
        end
    end
    LibGuildRoster:Refresh()
end

------------------
---LibCustomMenu--
------------------
local function BackupSpecificNote( guildId, playerName )
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink( playerName )
    local memberIndex = GetGuildMemberIndexFromDisplayName( guildId,
                                                            playerName )
    local _, note, _ = GetGuildMemberInfo( guildId, memberIndex )
    local savedNote = GWData[ worldName ].guilds.savedNotes[ guildId ]
        [ playerName ]

    if note == savedNote then
        chat(
            "|cffffffNote for |c%s%s|r |cffffffin %s |cffffffis already saved!",
            GW.COLOR, playerLink,
            GW.CreateGuildLink( guildId ) )
    elseif savedNote ~= note or savedNote == nil then
        GWData[ worldName ].guilds.savedNotes[ guildId ][ playerName ] =
            note
        chat( "|cffffffSaved note for |c%s%s|r |cffffffin %s|cffffff!",
              GW.COLOR, playerLink, GW.CreateGuildLink( guildId ) )
    end
    LibGuildRoster:Refresh()
end

local function RetrieveSpecificNote( guildId, playerName )
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink( playerName )
    local memberIndex = GetGuildMemberIndexFromDisplayName( guildId,
                                                            playerName )
    local _, note, _ = GetGuildMemberInfo( guildId, memberIndex )
    local savedNote = GWData[ worldName ].guilds.savedNotes[ guildId ]
        [ playerName ]

    if note == savedNote then
        chat(
            "|cffffffMember note in backup for: |c%s%s|r |cffffffin %s|cffffffis the same as the current note",
            GW.COLOR,
            playerLink, GW.CreateGuildLink( guildId ) )
    else
        SetGuildMemberNote( guildId, memberIndex, savedNote )
    end
end
local function openNoteInNotepad( guildId, playerName )
    local memberIndex = GetGuildMemberIndexFromDisplayName(
        guildId, playerName )
    local _, note, _ = GetGuildMemberInfo( guildId, memberIndex )
    logger:Log( "Note: %s", note )
    if GW_NotePad:IsHidden() then
        GW_NotePad:SetHidden( false )
    end
    GW_NotePad_NoteTitle_Box:SetText( playerName )
    GW_NotePad_ComposeScrollContainer_Box:SetText( note )
end

local function openSavedNoteInNotePad( guildId, playerName )
    local savedNote = ""
    if GWData[ worldName ].guilds.savedNotes[ guildId ][ playerName ] then
        savedNote = GWData[ worldName ].guilds.savedNotes[ guildId ]
            [ playerName ]
    end
    if GW_NotePad:IsHidden() then
        GW_NotePad:SetHidden( false )
    end
    GW_NotePad_NoteTitle_Box:SetText( playerName )
    GW_NotePad_ComposeScrollContainer_Box:SetText( savedNote )
end
local function AddPlayerContextMenuEntry( playerName, _ )
    local numGuilds = GetNumGuilds()
    local contextEntries = {}

    for i = 1, numGuilds do
        local guildId = GetGuildId( i )
        local link = GW.CreateGuildLink( guildId )

        contextEntries[ i ] = {
            label = link,
            callback = function()
                GuildInvite( guildId, playerName )
            end,
            visible = DoesPlayerHaveGuildPermission( guildId,
                                                     GUILD_PERMISSION_INVITE )
        }
    end
    AddCustomSubMenuItem(
        "|cffffffITTs |c" .. GW.COLOR .. "Ghostwriter|r |cffffffInvite to:",
        contextEntries )
end

libCM:RegisterPlayerContextMenu( AddPlayerContextMenuEntry,
                                 libCM.CATEGORY_LATE )

local function AddGuildRosterMenuEntry( control, _, _ )
    local data = ZO_ScrollList_GetData( control )
    local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildSettings = ITTsGhostwriter.Vars.guilds[ guildId ].settings
    local hasNotePermission = GW.GetPermission_Note( guildId )
    local hasMailPermission = GW.GetPermission_Mail( guildId )
    local hasChatPermission = GW.GetPermission_Chat( guildId )

    local entries = {
        {
            label = "Backup Note",
            callback = function()
                BackupSpecificNote( guildId, data.displayName )
            end,
            visible = hasNotePermission
        },
        {
            label = "Retrieve Note",
            callback = function()
                RetrieveSpecificNote( guildId, data.displayName )
            end,
            visible = hasNotePermission
        },

        {
            label = "Open guild note in Notepad",
            callback = function() openNoteInNotepad( guildId, data.displayName ) end,
            visible = hasNotePermission,
            disabled = not guildSettings.noteEnabled
        },
        {
            label = "Open saved note in Notepad",
            callback = function() openSavedNoteInNotePad( guildId, data.displayName ) end,
            visible = hasNotePermission,
            disabled = not guildSettings.noteEnabled
        },
        {
            label = "Initiate welcome sequence",
            callback = function()
                chat( "Welcome sequence initiated for %s in %s",
                      data.displayName, GetGuildName( guildId ) )
                GW.events.OnMemberJoin( _, guildId, data.displayName )
            end,
            visible = hasNotePermission or hasMailPermission or
                hasChatPermission,
            disabled = not (guildSettings.noteEnabled or guildSettings.mailEnabled or guildSettings.chatEnabled)
        },

    }

    AddCustomMenuItem( "-", function() end ) --This only exists to add a separator

    if hasNotePermission or hasMailPermission or hasChatPermission then
        AddCustomSubMenuItem(
            "|cffffffITTs |c" .. GW.COLOR .. "Ghostwriter|r", entries )
    end
end

libCM:RegisterGuildRosterContextMenu( AddGuildRosterMenuEntry,
                                      libCM.CATEGORY_LATE )
------------------
--LibGuildRoster--
------------------
local function getIconColor( savedNote, currentNote )
    local iconTemplate =
    "|c%s|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"

    if savedNote == currentNote and currentNote ~= "" then
        return string.format( iconTemplate, "00ff00" ) -- Green icon
    elseif (savedNote == nil or savedNote == "") and currentNote ~= "" then
        return string.format( iconTemplate, "585858" ) -- Grey icon
    elseif (savedNote ~= nil and savedNote ~= "") and currentNote == "" then
        return string.format( iconTemplate, "FF0000" ) -- Red icon
    elseif savedNote ~= currentNote and currentNote ~= "" then
        return string.format( iconTemplate, "FFBF00" ) -- Yellow icon
    else
        return ""                                      -- No icon
    end
end
function GW.RosterRow()
    GW.myGuildColumn =
        LibGuildRoster:AddColumn(
            {
                key = "GW_Notes",
                disabled = false,
                width = 24,
                -- guildFilter = {525912}, needs to be in player activated
                header = {
                    title = "",
                    align = TEXT_ALIGN_CENTER,
                    tooltip = "Notebackups"
                },
                row = {
                    align = TEXT_ALIGN_CENTER,
                    data = function( guildId, data, index )
                        local _, note, _ = GetGuildMemberInfo( guildId,
                                                               index )
                        local savedNotes = GWData[ worldName ].guilds
                            .savedNotes[ guildId ]
                        local savedNoteForMember = savedNotes
                            [ data.displayName ]
                        local savedNote = savedNoteForMember
                        local currentNote = note

                        return getIconColor( savedNote, currentNote )
                    end,
                    mouseEnabled = function() return true end,
                    OnMouseEnter = function( guildId, data, control )
                        local index = GetGuildMemberIndexFromDisplayName(
                            guildId, data.displayName )
                        local _, note, _ = GetGuildMemberInfo( guildId,
                                                               index )
                        local savedNote = ""
                        if GWData[ worldName ].guilds.savedNotes[ guildId ][ data.displayName ] and savedNote ~= note then
                            savedNote = GWData[ worldName ].guilds
                                .savedNotes[ guildId ][ data.displayName ]
                        else
                            return
                        end
                        local text = ""
                        if savedNote == note then
                            return
                        else
                            text = GWData[ worldName ].guilds.savedNotes
                                [ guildId ][ data.displayName ]
                            InitializeTooltip( InformationTooltip, self,
                                               TOPLEFT, 0, 0, BOTTOMRIGHT )
                            SetTooltipText( InformationTooltip, text )
                        end
                    end,

                    OnMouseExit = function( guildId, data, control )
                        ClearTooltip( InformationTooltip )
                    end

                }
            }
        )
end
