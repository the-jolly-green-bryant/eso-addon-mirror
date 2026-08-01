local events = {}
local GW = ITTsGhostwriter
ITTsGhostwriter.events = events
local async = LibAsync
local worldName = GetWorldName()
local userDisplayName = GetDisplayName()
local currentWorldName = GetWorldName()
local db
GW.combat = IsUnitInCombat( "player" )
GW.gameFocus = DoesGameHaveFocus()
GW.playerDead = IsUnitDeadOrReincarnating( "player" )
GW.InTributeMatch = false
GW.isNormalGameScene = true
local function chat( message, ... )
    GW.PrintChatMessage( message, ... )
end

local function sceneChange( scene, oldState, newState )
    local sceneName = scene:GetName()
    if newState == SCENE_SHOWING then
        GW.isNormalGameScene = sceneName == "hudui" or sceneName == "hud" or sceneName == "guildRoster"
    end
end
local function readyToWelcome()
    return
        not GW.combat
        -- and GW.gameFocus
        and not GW.playerDead
        and not GW.InTributeMatch
    --and GW.isNormalGameScene
    --or false
end

local function firstLoad()
    if db.firstload then
        chat(
            "|cffffffThank you for downloading |c%sITTsGhostwriter|r|cffffff Please visit the Website for setup help! You will need to setup first to make the addon useable",
            GW.COLOR )

        db.firstload = false
    end
end


local function getJoinDate( guildId, playerName )
    local format = db.guilds[ guildId ].settings.dateFormat
    local timeStamp = GetTimeStamp()
    if ITTsRosterBot then
        local eventTime = ITTsRosterBot.Utils:GetJoinDate( guildId, playerName )
        return os.date( format, eventTime )
    end

    local guildEvents = GetNumGuildHistoryEvents( guildId, GUILD_HISTORY_EVENT_CATEGORY_ROSTER )

    if not timeStamp then
        for i = 1, guildEvents do
            local eventId, eventTimeStamp, eventType, displayName =
                GetGuildHistoryRosterEventInfo( guildId, i )
            local secsSinceEvent = GetDiffBetweenTimeStamps( eventTimeStamp, timeStamp )

            if eventType == GUILD_EVENT_GUILD_JOIN and displayName == playerName and secsSinceEvent > 0 then
                timeStamp = eventTimeStamp
                return os.date( format, timeStamp )
            end
        end
    end
end

local task = async:Create( "ITTsGhostwriter/WelcomeTask" )
local chatTask = async:Create( "ITTsGhostwriter/ChatTask" )

local isProcessing = false
local function writeChatMessage(
    playerName,
    guildId,
    guildName,
    formattedDate,
    memberIndex,
    memberStatus,
    hasChatPermission,
    guildSettings )
    if hasChatPermission and guildSettings.messageEnabled then
        local guildIndex = GW.GetGuildIndex( guildId )
        local chatFormat = GW.FormatMessage( guildSettings.messageBody, playerName, guildName, formattedDate )

        if chatFormat and IsChatSystemAvailableForCurrentPlatform() and GW.ChatReady and memberIndex then
            if db.generalSettings.offlinecheck == (memberStatus ~= PLAYER_STATUS_OFFLINE) and CanWriteGuildChannel( _G[ "CHAT_CHANNEL_GUILD_" .. guildIndex ] ) then
                StartChatInput( chatFormat, _G[ "CHAT_CHANNEL_GUILD_" .. guildIndex ] )
            elseif memberStatus == PLAYER_STATUS_OFFLINE then
                chat( "|c%s %s|r |cffffffis offline", GW.COLOR, ZO_LinkHandler_CreateDisplayNameLink( playerName ) )
            end
        end
    end
end

local function writeNote(
    playerName,
    guildId,
    guildName,
    formattedDate,
    memberIndex,
    offlineTime,
    memberName,
    hasNotePermission,
    guildSettings )
    if hasNotePermission and guildSettings.noteEnabled then
        local savedNote = GWData[ worldName ].guilds.savedNotes[ guildId ][ playerName ]
        if not savedNote or savedNote == "" then
            local noteFormat = GW.FormatMessage( guildSettings.noteBody, playerName, guildName, formattedDate )
            if noteFormat and db.generalSettings.offlinemodecheck and offlineTime > 1209600 then -- 2 weeks
                noteFormat = noteFormat .. "\n|cffffffOfflinemode|r"
            end
            if memberName == playerName then
                GW.writeNote( guildId, memberIndex, noteFormat )
            end
        elseif memberName == playerName then
            GW.writeNote( guildId, memberIndex, savedNote )
        end
    end
end

local function writeMail(
    playerName,
    guildId,
    guildName,
    formattedDate,
    memberName,
    hasMailPermission,
    guildSettings )
    if hasMailPermission and guildSettings.mailEnabled then
        local mailBody = GW.FormatMessage( guildSettings.mailBody, playerName, guildName, formattedDate )
        local mailSubject = GW.FormatMessage( guildSettings.mailSubject, playerName, guildName, formattedDate )
        if mailBody and memberName == playerName then
            GW.writeMail( playerName, mailSubject, mailBody )
        end
    end
end

local numberOfTasks = 0
local function onMemberJoin( _, guildId, playerName )
    local guildSettings = db.guilds[ guildId ].settings
    local guildName = GetGuildName( guildId )
    local formattedDate = getJoinDate( guildId, playerName )
    local memberIndex = GetGuildMemberIndexFromDisplayName( guildId,
        playerName )
    local memberName, _, _, memberStatus, offlineTime = GetGuildMemberInfo(
        guildId, memberIndex )
    local guildIndex = GW.GetGuildIndex( guildId )

    local hasChatPermission = GW.GetPermission_Chat( guildId )
    local hasNotePermission = GW.GetPermission_Note( guildId )
    local hasMailPermission = GW.GetPermission_Mail( guildId )
    if not GW.combat then GW.Combat = IsUnitInCombat( "player" ) == false end
    if not GW.gameFocus then GW.gameFocus = DoesGameHaveFocus() end
    if not GW.playerDead then GW.playerDead = IsUnitDeadOrReincarnating( "player" ) end

    if not (hasChatPermission or hasNotePermission or hasMailPermission) then
        return
    elseif IsUnitInCombat( "player" ) then
        chat(
            "|cffffffWelcome sequence queued, waiting for combat to end..." )
    elseif IsUnitDeadOrReincarnating( "player" ) then
        chat(
            "|cffffffWelcome sequence queued, waiting for reincarnation..." )
    elseif GW.InTributeMatch then
        chat(
            "|cffffffWelcome sequence queued, waiting for Tribute match to end..." )
    elseif not DoesGameHaveFocus() then
        chat(
            "|cffffffWelcome sequence queued, waiting for game to gain focus..." )
    end
    numberOfTasks = numberOfTasks + 1
    chatTask:WaitUntil( function()
        return GW.gameFocus
    end ):Then( function()
        writeChatMessage( playerName, guildId, guildName, formattedDate,
            memberIndex, memberStatus, hasChatPermission,
            guildSettings )
    end )

    task:WaitUntil( function()
        return readyToWelcome() and not isProcessing
    end )
        :Then( function()
            isProcessing = true
            writeNote( playerName, guildId, guildName, formattedDate,
                memberIndex, offlineTime, memberName,
                hasNotePermission, guildSettings )

            writeMail( playerName, guildId, guildName, formattedDate, memberName,
                hasMailPermission, guildSettings )

            zo_callLater( function()
                isProcessing = false
                numberOfTasks = numberOfTasks - 1
            end, 10000 )
        end )
end

events.OnMemberJoin = onMemberJoin


local function noteAlert( _, guildId, playerName, note )
    if not DoesPlayerHaveGuildPermission( guildId, GUILD_PERMISSION_NOTE_EDIT ) or not db.guilds[ guildId ].settings.noteAlert then
        return
    end
    LibGuildRoster:Refresh()
    GW.GetPermission_Note( guildId )
    GW.GetPermission_Mail( guildId )
    GW.GetPermission_Chat( guildId )
    local guildSettings = db.guilds[ guildId ].settings


    chat( "|cffffffMember note updated for |c%s%s|r |cffffffin %s",
        GW.COLOR,
        ZO_LinkHandler_CreateDisplayNameLink( playerName ),
        GW.CreateGuildLink( guildId ) )

    if guildSettings.autobackup then
        GWData[ currentWorldName ].guilds.savedNotes[ guildId ][ playerName ] =
            note
        LibGuildRoster:Refresh()
    end
end
local function applicationMessage(
    numApplications,
    numEmptyApplications,
    numAchievementThreshold,
    numOverThreshold,
    guildName,
    achievementThreshold,
    applicationThreshold )
    local baseMessage =
    "|cffffffYou have |c%s%d|r |cffffffopen Application(s) in %s \n|cffffff(|c%s%d|r |cffffffempty"
    local message = string.format( baseMessage, GW.COLOR, numApplications,
        guildName, GW.COLOR, numEmptyApplications )

    if achievementThreshold > 1 then
        local achievementMessage =
        ", |c%s%d|r |cffffffover |c%s%s|r |cffffff Achievement Points"
        message = message ..
            string.format( achievementMessage, GW.COLOR,
                numAchievementThreshold, GW.COLOR,
                ZO_CommaDelimitNumber( achievementThreshold ) )
    end

    if applicationThreshold > 1 then
        local thresHoldmessage =
        ", |c%s%d|r |cffffffover |c%s%d|r |cffffffCP"
        message = message ..
            string.format( thresHoldmessage, GW.COLOR, numOverThreshold,
                GW.COLOR, applicationThreshold )
    end

    message = message .. ")"
    return message
end

local function applicationAlert( _, guildId, numApplications )
    if not DoesPlayerHaveGuildPermission( guildId, GUILD_PERMISSION_MANAGE_APPLICATIONS ) then
        return
    end
    LibGuildRoster:Refresh()
    if not db.guilds[ guildId ] then
        return
    end
    local guildName = GW.CreateGuildLink( guildId )
    if not numApplications then
        numApplications = GetGuildFinderNumGuildApplications( guildId )
    end
    local numEmptyApplications = 0
    local applicationThreshold = 300
    if db.guilds[ guildId ] then
        applicationThreshold = db.guilds[ guildId ].settings
            .applicationThreshold
    end
    local achievementThreshold = 5000
    if db.guilds[ guildId ] then
        achievementThreshold = db.guilds[ guildId ].settings
            .achievementThreshold
    end
    local numOverThreshold = 0
    local numAchievementThreshold = 0

    for i = 1, numApplications do
        local level, championPoints, _, _, playerName, _, achievementPoints, message =
            GetGuildFinderGuildApplicationInfoAt( guildId, i )

        if message == "" then
            numEmptyApplications = numEmptyApplications + 1
        end

        if level == 50 and championPoints >= applicationThreshold then
            numOverThreshold = numOverThreshold + 1
        end

        if achievementPoints >= achievementThreshold then
            numAchievementThreshold = numAchievementThreshold + 1
        end
    end
    if db.guilds[ guildId ].settings.applicationAlert and numApplications ~= 0 then
        local message = applicationMessage( numApplications,
            numEmptyApplications,
            numAchievementThreshold,
            numOverThreshold,
            guildName, achievementThreshold,
            applicationThreshold )
        chat( message )
    end
end
local function loginAlert()
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId( guildIndex )
        applicationAlert( _, guildId )
    end
end
LoginTest = loginAlert
----------------
---MailChecks---
----------------

-- Some things prevent people from sending mails, or straight up stop what the user is doing. So we will need to put in some checks if the person is doing one of those things.
-- make an event with a flag variable. then add it to the readyToWelcome function. every time we send a mail or set the note we wait until all those conditions return the value we want
--TODO: add more things which immediately break or are just annoying when sending mail
--revisit: we could maybe just check for the current scene to prevent things like guildbank or crafting?
local function combatCheck( eventCode, inCombat )
    GW.combat = inCombat
end

local function onPlayerDeath( eventCode )
    GW.playerDead = true
end

local function onPlayerReincarnated( eventCode )
    GW.playerDead = false
end

local function tributeMatchCheck( eventCode, flowState )
    --Whoever reads this, do not change this. If a member joins while in a tribute match it will immediately exit the match thereby forfeiting
    GW.inTributeMatch = flowState ~= TRIBUTE_GAME_FLOW_STATE_INACTIVE
end
local function onGameFocusChanged( eventCode, hasFocus )
    -- this shouldnt be needed but ZOS bugged the chat window so it will be unuseable if we put in a message while not focused on the game
    GW.gameFocus = hasFocus
end
---
local function misc()
    firstLoad()
    zo_callLater( loginAlert, 1500 )
end
-----------
--EVENTS---
-----------
function events.Register()
    db = ITTsGhostwriter.Vars

    EVENT_MANAGER:RegisterForEvent( GW.name, EVENT_GUILD_MEMBER_NOTE_CHANGED,
        noteAlert )
    EVENT_MANAGER:RegisterForEvent( GW.name,
        EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS, applicationAlert )
    EVENT_MANAGER:RegisterForEvent( GW.name, EVENT_GUILD_MEMBER_ADDED,
        onMemberJoin )
    EVENT_MANAGER:RegisterForEvent( GW.name,
        EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, tributeMatchCheck )
    EVENT_MANAGER:RegisterForEvent( GW.Name, EVENT_PLAYER_COMBAT_STATE,
        combatCheck )
    EVENT_MANAGER:RegisterForEvent( GW.Name, EVENT_PLAYER_DEAD,
        onPlayerDeath )
    EVENT_MANAGER:RegisterForEvent( GW.Name, EVENT_PLAYER_REINCARNATED,
        onPlayerReincarnated )
    EVENT_MANAGER:RegisterForEvent( GW.Name, EVENT_GAME_FOCUS_CHANGED,
        onGameFocusChanged )

    local logger = GWLogger:New( "Events" )
    SCENE_MANAGER:RegisterCallback( "SceneStateChanged", sceneChange )

    misc()
    readyToWelcome()
end
