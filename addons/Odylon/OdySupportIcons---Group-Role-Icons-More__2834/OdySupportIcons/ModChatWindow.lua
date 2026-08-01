local displayNamesPrepared = false
local displayNameTable     = { }
local cwConfig             = {
    ["dead"]     = false,
    ["mechanic"] = false,
    ["raid"]     = false,
    ["leader"]   = false,
    ["tank"]     = false,
    ["healer"]   = false,
    ["dps"]      = false,
    ["bg"]       = false,
    ["custom"]   = false,
    ["unique"]   = false,
    ["anim"]     = false,
}

local function GuildDisplayNames()
    local guilds = GetNumGuilds()
    for i = 1, guilds do
        local id      = GetGuildId( i )
        local members = GetNumGuildMembers( id )
        for j = 1, members do
            local displayName   = GetGuildMemberInfo( id, j )
            local hasChar, name = GetGuildMemberCharacterInfo( id, j )
            if hasChar and name then
                displayNameTable[zo_strformat( SI_UNIT_NAME, name )] = displayName
            end
        end
    end
end

local function GuildDisplayNamesUpdate( _, id, displayName )
    local members = GetNumGuildMembers( id )
    for i = 1, members do
        if displayName == GetGuildMemberInfo( id, i ) then
            local hasChar, name = GetGuildMemberCharacterInfo( id, i )
            if hasChar and name then
                displayNameTable[zo_strformat( SI_UNIT_NAME, name )] = displayName
            end
        end
    end
end

local function FriendDisplayNames()
    local friends = GetNumFriends()
    for i = 1, friends do
        local displayName   = GetFriendInfo( i )
        local hasChar, name = GetFriendCharacterInfo( i )
        if hasChar and name then
            displayNameTable[zo_strformat( SI_UNIT_NAME, name )] = displayName
        end
    end
end

local function FriendDisplayNamesUpdate( _, displayName, name )
    displayNameTable[zo_strformat( SI_UNIT_NAME, name )] = displayName
end

local function GroupDisplayNames()
    for i = 1, GROUP_SIZE_MAX do
        local unit        = "group" .. i
        local name        = GetUnitName( unit )
        local displayName = GetUnitDisplayName( unit )
        if name and displayName then
            displayNameTable[zo_strformat( SI_UNIT_NAME, name )] = displayName
        end
    end
end

local function GroupDisplayNamesUpdate( _, name, displayName )
    if displayName == GetDisplayName() then
        -- player joined a group
        GroupDisplayNames()
    else
        displayNameTable[zo_strformat( SI_UNIT_NAME, name )] = displayName
    end
end

function OSI.ChatWindowHook()
    local addwin = SharedChatContainer.AddWindow
    SharedChatContainer.AddWindow = function( ... )
        local window = addwin( ... )
        local buffer = window.buffer
        local addmsg = buffer.AddMessage
        buffer.AddMessage = function( self, message, ... )
            local cwuse    = OSI.GetOption( "cwuse" )
            local cwunique = OSI.GetOption( "cwunique" )
            local cwsize   = OSI.GetOption( "cwsize" )

            if ( cwuse or cwunique ) and message and #message > 0 then
                local tag  = nil
                local i, j = message:find( "|H%d:display:.-|h", 1 )
                if i then
                    tag = message:sub( i + 12, j - 2 )
                    if not tag:find( "@" ) then
                        tag = "@" .. tag
                    end
                else
                    i, j = message:find( "|H%d:character:.-|h", 1 )
                    if i then
                        tag = zo_strformat( SI_UNIT_NAME, message:sub( i + 14, j - 2 ) )
                        tag = displayNameTable[tag]
                    end
                end
                if tag then 
                    cwConfig.custom = cwuse
                    cwConfig.unique = cwunique

                    local icon = OSI.GetIconDataForPlayer( tag, cwConfig, nil )
                    if icon then
                        -- reliably inserting space before texture is not possible since sometimes messages start with eg. color tags
                        -- |cFFFFFF |t20:20:odysupporticons/icons/twp/exoy94.dds|t |H1:display:@ExoY94|h[@ExoY94]|h|r has logged off with |cFFFFFF|H1:character:Exoy^Mx|h[Exoy]|h|r.
                        -- local space = ""
                        -- if i > 1 then
                        --     space = message:sub( i - 1, i - 1 )
                        --     space = space ~= " " and " " or ""
                        -- end
                        -- message = message:sub( 1, i - 1 ) .. space .. "|t20:20:" .. icon .. "|t " .. message:sub( i )
                        message = message:sub( 1, i - 1 ) .. "|t" .. cwsize .. ":" .. cwsize .. ":" .. icon .. "|t" .. message:sub( i )
                    end
                end
            end
            addmsg( self, message, ... )
        end
        return window
    end    
end

function OSI.PrepareDisplayNameTable()
    -- only do this once after first activation
    if displayNamesPrepared then return end
    displayNamesPrepared = true

    -- store the players character name
    displayNameTable[zo_strformat( SI_UNIT_NAME, GetUnitName( "player" ) )] = GetDisplayName()
    -- store guild, friends and group character names
    GuildDisplayNames()
    FriendDisplayNames()
    GroupDisplayNames()

    -- register callbacks to update guild, friends and group character names
    OSI.events:RegisterForEvent( OSI.name .. "GuildDisplayName", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, GuildDisplayNamesUpdate )
    OSI.events:RegisterForEvent( OSI.name .. "FriendDisplayName", EVENT_FRIEND_PLAYER_STATUS_CHANGED, FriendDisplayNamesUpdate )
    OSI.events:RegisterForEvent( OSI.name .. "GroupDisplayName", EVENT_GROUP_MEMBER_JOINED, GroupDisplayNamesUpdate )
end
