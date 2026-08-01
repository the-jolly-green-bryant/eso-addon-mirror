local GW                         =
    ITTsGhostwriter or
    {
        name = "ITTsGhostwriter",

    }
ITTsGhostwriter                  = GW

local chat                       = LibChatMessage( "ITTsGhostwriter", "GW" )
local logger                     = GWLogger:New( "Utils" )
-----------
--CONSTANTS
-----------

local NOTE_PATTERN               = "|cGWnote|r"
local MAIL_PATTERN               = "|cGWmail|r"
local CHAT_PATTERN               = "|cGWchat|r"
local NOTE_AND_MAIL_PATTERN      = "|cGWnoma|r"
local NOTE_AND_CHAT_PATTERN      = "|cGWnoch|r"
local MAIL_AND_CHAT_PATTERN      = "|cGWmach|r"
local NOTE_MAIL_AND_CHAT_PATTERN = "|cGWxxxx|r"
--* LibGuildRoster needs one guildId to filter, if its nil it will show in all guilds, so the dummy guildId is added with a number that will most likely never be used by an actual guild
GW.GuildsWithPermisson           = { 999999999999999 }
GW.shouldHideFor                 = {}
--------------------
--helper functions--
--------------------
function GW.PrintChatMessage( message, ... )
    if ... then
        chat:Printf( message, ... )
    else
        chat:Print( message )
    end
end

------------------
--CutomGuildLink--
------------------
function GW.GetGuildColor( i )
    local r, g, b = GetChatCategoryColor( _G
        [ "CHAT_CATEGORY_GUILD_" .. tostring( i ) ] )
    local colorObject = ZO_ColorDef:New( r, g, b )

    return {
        rgb = { r, g, b },
        hex = colorObject:ToHex()
    }
end

function GW.CreateGuildLink( guildId )
    local gIndex = GW.GetGuildIndex( guildId )
    local name = GetGuildName( guildId )
    local color = GW.GetGuildColor( gIndex )
    local guildLink = string.format( "|c%s[|H1:gwguild::%s|h %s ]|h|r",
                                     color.hex, guildId, name )
    return guildLink
end

local function handleMouseButton(
    guildId,
    gIndex,
    mouseButton,
    scene,
    callback )
    if mouseButton then
        GUILD_SELECTOR:SelectGuildByIndex( gIndex )
        MAIN_MENU_KEYBOARD:ShowScene( scene )

        if callback then
            zo_callLater( callback, 250 )
        end

        return true
    end
end

function GW.HandleClickEvent(
    rawLink,
    mouseButton,
    linkText,
    linkStyle,
    linkType,
    guildId, ... )
    local gIndex = GW.GetGuildIndex( guildId )
    if linkType == "gwguild" then
        if handleMouseButton( guildId, gIndex, mouseButton == MOUSE_BUTTON_INDEX_LEFT, "guildHome" ) then return true end

        if handleMouseButton( guildId, gIndex, mouseButton == MOUSE_BUTTON_INDEX_MIDDLE, "guildRecruitmentKeyboard", function()
                GUILD_RECRUITMENT_KEYBOARD:ShowApplicationsList()
                ClearGuildHasNewApplicationsNotification( guildId )
            end ) then
            return true
        end

        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()

            local menuItems = {
                { "Show Guild Roster",  "guildRoster" },
                { "Show Guild Ranks",   "guildRanks" },
                { "Show Guild History", "guildHistory" }
            }

            if DoesPlayerHaveGuildPermission( guildId, GUILD_PERMISSION_MANAGE_APPLICATIONS ) then
                table.insert( menuItems,
                              {
                                  "Show Guild Recruitment",
                                  "guildRecruitmentKeyboard"
                              } )
            end

            if DoesPlayerHaveGuildPermission( guildId, GUILD_PERMISSION_EDIT_HERALDRY ) then
                table.insert( menuItems,
                              {
                                  "Show Guild Heraldry",
                                  "guildHeraldry"
                              } )
            end

            for _, item in ipairs( menuItems ) do
                AddCustomMenuItem( item[ 1 ], function()
                    GUILD_SELECTOR:SelectGuildByIndex( gIndex )
                    MAIN_MENU_KEYBOARD:ShowScene( item[ 2 ] )
                end )
            end

            ShowMenu()
            return true
        end
    end
end

LINK_HANDLER:RegisterCallback( LINK_HANDLER.LINK_MOUSE_UP_EVENT,
                               GW.HandleClickEvent )
-------------------------
----Format message-------
-------------------------
function GW.FormatMessage( template, playerName, guildName, date )
    if not template or template == "" then return end
    local formattedMessage = string.gsub( template, "%%PLAYER%%", playerName )
    formattedMessage = string.gsub( formattedMessage, "%%GUILD%%", guildName )
    return string.gsub( formattedMessage, "%%DATE%%", date )
end

-------------------------
--CheckCustomPermission--
-------------------------

local GetNumGuildMembers = GetNumGuildMembers
local GetGuildMemberInfo = GetGuildMemberInfo
local PlainStringFind = PlainStringFind
local GetDisplayName = GetDisplayName

local function checkPermission( guildId, patterns )
    local playerName = GetDisplayName()
    local numMembers = GetNumGuildMembers( guildId )

    for i = 1, numMembers do
        local name, memberNote = GetGuildMemberInfo( guildId, i )
        if playerName == name then
            for _, pattern in ipairs( patterns ) do
                if PlainStringFind( memberNote, pattern ) then
                    return true
                end
            end
            break
        end
    end

    return false
end

function GW.GetPermission_Note( guildId )
    return checkPermission( guildId,
                            {
                                NOTE_PATTERN,
                                NOTE_AND_MAIL_PATTERN,
                                NOTE_AND_CHAT_PATTERN,
                                NOTE_MAIL_AND_CHAT_PATTERN
                            } )
end

function GW.GetPermission_Chat( guildId )
    return checkPermission( guildId,
                            {
                                CHAT_PATTERN,
                                MAIL_AND_CHAT_PATTERN,
                                NOTE_AND_CHAT_PATTERN,
                                NOTE_MAIL_AND_CHAT_PATTERN
                            } )
end

function GW.GetPermission_Mail( guildId )
    return checkPermission( guildId,
                            {
                                MAIL_PATTERN,
                                NOTE_AND_MAIL_PATTERN,
                                MAIL_AND_CHAT_PATTERN,
                                NOTE_MAIL_AND_CHAT_PATTERN
                            } )
end

--------------
--Automation--
--------------
local pendingMailCount = 0
local mailboxOpen = false
--We added the delay to the player join event. we dont actually need this async nonsense here but it doesnt hurt either
function GW.writeMail( recipientName, subject, body )
    pendingMailCount = pendingMailCount + 1
    logger:Log( "trying to write mail to %s", recipientName )
    logger:Log( 2, "subject: %s \n body: %s", subject, body )
    zo_callLater(
        function()
            if not mailboxOpen then
                RequestOpenMailbox()
                mailboxOpen = true
            end

            SendMail( recipientName, subject, body )

            zo_callLater(
                function()
                    pendingMailCount = pendingMailCount - 1

                    if pendingMailCount == 0 and mailboxOpen then
                        CloseMailbox()
                        mailboxOpen = false
                    end
                end,
                1000
            )
        end,
        (10000 * pendingMailCount) - 10000
    )
    logger:Log( "writeMail: pendingMailCount: %d", pendingMailCount )
end

local noteCount = 0

function GW.writeNote( guildId, memberIndex, note )
    noteCount = noteCount + 1
    zo_callLater(
        function()
            SetGuildMemberNote( guildId, memberIndex, note )
        end,
        (10000 * noteCount) - 10000
    )
    zo_callLater(
        function()
            noteCount = noteCount - 1
        end,
        10000 * noteCount
    )
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function GW.GetGuildIndex( guildId )
    local idNum = tonumber( guildId )

    for gi = 1, GetNumGuilds() do
        local gcheck = GetGuildId( gi )
        if idNum == gcheck then
            return gi
        end
    end
end
