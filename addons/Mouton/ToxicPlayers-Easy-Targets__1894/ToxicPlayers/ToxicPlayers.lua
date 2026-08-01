TP_DISPLAY_NAME_ID, TP_DISPLAY_NAME_CHARACTER, TP_DISPLAY_NAME_BOTH = 1, 2, 3

ToxicPlayers = {
    name = "ToxicPlayers",
    options = {
        type = "panel",
        name = "Toxic Players",
        author = "|c0cccc0@mouton|r",
        recipient = "@mouton",
        version = "2.1.1",
        website = "https://www.esoui.com/downloads/info1894-ToxicPlayersEasyTargets.html"
    },
    command = "/toxicplayers",
    localSettings = {},
    accountSettings = {},
    defaultSettings = {
        useAccountWide = true,
        displayText = false,
        displayFriendMarker = false,
        displayFoeMarker = true,
        displayIcon = true,
        displayInGroups = false,
        displayOnIgnored = true,
        displayOnGuild = true,
        displayOnGuildBlacklist = true,
        displayOnFriends = true,
        displayOnUnknown = false,
        displayName = TP_DISPLAY_NAME_ID,
        automaticPlayerInfo = false,
        positionName = TOP,
        positionIcon = BOTTOM,
        variableVersion = 5,
        friendList = {}
    },
    STYLES = {
        DEFAULT = {
            color = ZO_ColorDef:New(1, 1, 1, 1),
            icon = '',
            marker = false
        },
        IGNORED = {
            color = ZO_ColorDef:New(1, 0.2, 0.2, .9),
            icon = '/esoui/art/contacts/tabicon_ignored_up.dds',
            marker = TARGET_MARKER_TYPE_SEVEN
        },
        -- MUTED =   { color = ZO_ColorDef:New(1, 0.6, 0.2, .9), icon = '/esoui/art/contacts/tabicon_ignored_up.dds', marker = TARGET_MARKER_TYPE_FOUR  },
        GUILD = {
            color = ZO_ColorDef:New(0.6, 0.7, 1, 1),
            icon = '/esoui/art/mainmenu/menubar_guilds_up.dds',
            marker = TARGET_MARKER_TYPE_ONE
        },
        FRIENDS = {
            color = ZO_ColorDef:New(0.2, 1, 0.2, .9),
            icon = '/esoui/art/mainmenu/menubar_social_up.dds',
            marker = TARGET_MARKER_TYPE_THREE
        },
        BLACKLIST = {
            color = ZO_ColorDef:New(1, 0.2, 0.2, .9),
            icon = 'esoui/art/guildfinder/keyboard/guildrecruitment_blacklist_up.dds',
            marker = TARGET_MARKER_TYPE_EIGHT
        }
    }
}

-- Local references to important objects
local TYPE_UNKNOWN, TYPE_IGNORED, TYPE_MUTED, TYPE_FRIENDS, TYPE_GUILD, TYPE_BLACKLIST = 1, 2, 3, 4, 5, 6
local SOCIAL_RATE_DELAY = 2000
local AUTOMATIC_DISPLAY_DELAY = 2000
local TP = ToxicPlayers
local TPStyles = TP.STYLES
local latestEvent = GetGameTimeMilliseconds()
local latestWisp = nil
local latestPlayer = nil
local latestAutoInfo = nil
local editNote = nil
local guildMates = {}
local guildBlacklist = {}

function TP.FixPositions()
    local settings = TP.getSettings()
    TP.SetPosition(ToxicPlayersUnitName, settings.positionName)
    TP.SetPosition(ToxicPlayersUnitIcon, settings.positionIcon)
    TP.SetReticleStyle(TPStyles.DEFAULT, "", true, false)
end

function TP.SetPosition(ctrl, position)
    ctrl:ClearAnchors()

    local whereOnMe, whereOnTarget, textAlign

    if position == BOTTOM then
        whereOnMe, whereOnTarget, textAlign = TOP, BOTTOM, TEXT_ALIGN_CENTER
    elseif position == RIGHT then
        whereOnMe, whereOnTarget, textAlign = LEFT, RIGHT, TEXT_ALIGN_LEFT
    elseif position == LEFT then
        whereOnMe, whereOnTarget, textAlign = RIGHT, LEFT, TEXT_ALIGN_RIGHT
    else
        -- Default position for TOP
        whereOnMe, whereOnTarget, textAlign = BOTTOM, TOP, TEXT_ALIGN_CENTER
    end

    ctrl:SetAnchor(whereOnMe, ctrl:GetParent(), whereOnTarget, 0, 0)
    if ctrl['SetHorizontalAlignment'] ~= nil then
        ctrl:SetHorizontalAlignment(textAlign)
    end
end

function TP.SetReticleStyle(style, text, hidden, marker)
    ZO_ReticleContainerReticle:SetColor(style.color:UnpackRGB())
    local settings = TP.getSettings()
    if marker and (settings.displayInGroups or not IsUnitGrouped("player")) then
        AssignTargetMarkerToReticleTarget(style.marker or GetUnitTargetMarkerType('reticleover'))
    end

    if settings.displayIcon then
        ToxicPlayersUnitIcon:SetColor(style.color:UnpackRGBA())
        ToxicPlayersUnitIcon:SetTexture(style.icon)
        ToxicPlayersUnitIcon:SetHidden(hidden)
    end

    if settings.displayText then
        ToxicPlayersUnitName:SetColor(style.color:UnpackRGBA())
        ToxicPlayersUnitName:SetText(text)
        ToxicPlayersUnitName:SetHidden(hidden)
        if settings.positionName == settings.positionIcon then
            -- Same position, right or left
            if settings.positionName == RIGHT or settings.positionName == LEFT then
                ToxicPlayersUnitName:SetHeight(90)
                ToxicPlayersUnitName:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
                -- Same position, top or bottom
            else
                ToxicPlayersUnitName:SetHeight(120)
                ToxicPlayersUnitName:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            end
        else
            -- Any other position
            ToxicPlayersUnitName:SetHeight(40)
            ToxicPlayersUnitName:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
    end
end

function TP.OnReticleHidden(eventcode)
    TP.SetReticleStyle(TPStyles.DEFAULT, "", true, false)
end

function TP.GetPlayerType(unitTag)
    local settings = TP.getSettings()

    if settings.displayOnIgnored and IsUnitIgnored(unitTag) then
        return TYPE_IGNORED
        -- Display friends
    elseif settings.displayOnFriends and IsUnitFriend(unitTag) then
        return TYPE_FRIENDS
        -- Display on guild mates
    elseif settings.displayOnGuild and TP.IsUnitGuildMate(unitTag) then
        return TYPE_GUILD
        -- Display on blacklisted users from a guild
    elseif settings.displayOnGuildBlacklist and TP.IsUnitGuildBlacklist(unitTag) then
        return TYPE_BLACKLIST
        -- No list, but save info
    elseif settings.displayOnUnknown then
        return TYPE_UNKNOWN
        -- No list, reset.
    else
        return nil
    end
end

function TP.OnTargetHasChanged(eventcode, invname)
    if IsUnitPlayer('reticleover') and not IsUnitGrouped('reticleover') then
        local settings = TP.getSettings()
        local playerType = TP.GetPlayerType('reticleover')

        if playerType then
            -- Avoid removing existing markers on targets
            local canDisplayMarker = GetUnitTargetMarkerType('reticleover') == 0
            TP.SetLastestPlayer(TP.GetPlayerInfos(playerType, 'reticleover'))

            if playerType == TYPE_IGNORED then
                TP.EncoutnerPlayer(TPStyles.IGNORED, GetString(TOXICPLAYERS_IGNORED), false, canDisplayMarker and settings.displayFoeMarker)
            elseif playerType == TYPE_FRIENDS then
                TP.EncoutnerPlayer(TPStyles.FRIENDS, GetString(TOXICPLAYERS_FRIEND), false, canDisplayMarker and settings.displayFriendMarker)
            elseif playerType == TYPE_GUILD then
                TP.EncoutnerPlayer(TPStyles.GUILD, guildMates[latestPlayer.playerName].guildName, false, canDisplayMarker and settings.displayFriendMarker)
            elseif playerType == TYPE_BLACKLIST then
                TP.EncoutnerPlayer(TPStyles.BLACKLIST, guildBlacklist[latestPlayer.playerName].guildName, false, canDisplayMarker and settings.displayFoeMarker)
            elseif playerType == TYPE_UNKNOWN then
                TP.EncoutnerPlayer(TPStyles.DEFAULT, "", true, false)
            end
            return
        end
    end
    TP.SetReticleStyle(TPStyles.DEFAULT, "", true, false)
end

function TP.OnFriendRemoved(eventCode, displayName, unknown)
    local settings = TP.getSettings()
    if settings.friendList[GetWorldName()] == nil then
        settings.friendList[GetWorldName()] = {}
    end
    local friends = settings.friendList[GetWorldName()]

    local playerLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
    local formatedNote = ""

    if unknown == true then
        formatedNote = zo_strformat(TOXICPLAYERS_SI_FRIEND_NOT_EXISTS, playerLink)
    else
        formatedNote = zo_strformat(TOXICPLAYERS_SI_FRIEND_REMOVED, playerLink)
    end

    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM:AddMessage(formatedNote)

    friends[displayName] = nil
end

function TP.OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    local settings = TP.getSettings()
    if settings.displayInGroups then
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)

            -- If the player join the group, then, it's his/hes own name there only, then we check all the group
            if GetUnitDisplayName('player') ~= GetUnitDisplayName(unitTag) and (isLocalPlayer or GetUnitDisplayName(unitTag) == memberDisplayName) then
                local playerType = TP.GetPlayerType(unitTag)

                if playerType then
                    local player = TP.GetPlayerInfos(playerType, unitTag)
                    TP.DisplayPlayerInfo(player)
                end
            end
        end
    end
end

function TP.EncoutnerPlayer(style, name, hidden, marker)
    local settings = TP.getSettings()

    TP.SetReticleStyle(style, name, hidden, marker)

    if settings.automaticPlayerInfo then
        local l = latestPlayer
        TP.DisplayAutomaticPlayerInfo()
        latestAutoInfo = l
    end
end

function TP.SetLastestPlayer(player)
    if player ~= nil then
        latestWisp = player
    end
    latestPlayer = player
end

function TP.GetPlayerInfos(type, unitTag)
    local settings = TP.getSettings()
    if settings.displayName == TP_DISPLAY_NAME_ID then
        return {
            playerType = type,
            playerName = GetUnitDisplayName(unitTag)
        }
    elseif settings.displayName == TP_DISPLAY_NAME_CHARACTER then
        return {
            playerType = type,
            characterName = GetUnitName(unitTag)
        }
    else
        return {
            playerType = type,
            playerName = GetUnitDisplayName(unitTag),
            characterName = GetUnitName(unitTag)
        }
    end
end

function TP.IsUnitGuildMate(unitTag)
    local playerName = GetUnitDisplayName(unitTag)
    return guildMates[playerName] ~= nil
end

function TP.IsUnitGuildBlacklist(unitTag)
    local playerName = GetUnitDisplayName(unitTag)
    return guildBlacklist[playerName] ~= nil
end

function TP.UpdatePlayerNote(eventcode, playerName)
    -- Note has to be updated once ignore is saved only. Save the latest note for that player.
    -- Social functions are subject to call limit rate (?)
    local callback = function()
        if editNote then
            for i = 1, GetNumIgnored() do
                local curDisplayName, curNote = GetIgnoredInfo(i)
                if (playerName == curDisplayName) then
                    SetIgnoreNote(i, editNote)
                    break
                end
            end
        end
        editNote = nil
    end

    zo_callLater(callback, SOCIAL_RATE_DELAY)
    latestEvent = GetGameTimeMilliseconds()
end

function TP.DisplayAutomaticPlayerInfo()
    if GetGameTimeMilliseconds() - latestEvent > SOCIAL_RATE_DELAY and latestPlayer.playerType ~= TYPE_UNKNOWN and (latestAutoInfo == nil or latestAutoInfo.playerName ~= latestPlayer.playerName) then
        TP.DisplayPlayerInfo()
    end
end

function TP.DisplayPlayerInfo(player)
    if (TP.IsSocialAllowed() and latestPlayer) or player then

        local formatedNote = nil
        local playerLink = ""
        local characterLink = ""
        local prefix = ""

        if not player then
            player = latestPlayer
        else
            -- If we have a specific player, we're in a group
            prefix = zo_strformat(TOXICPLAYERS_SI_GROUP_INFO)
        end

        if player.playerName then
            playerLink = ZO_LinkHandler_CreateDisplayNameLink(player.playerName)
            if player.characterName then
                characterLink = zo_strformat(TOXICPLAYERS_SI_WITH_CHAR, ZO_LinkHandler_CreateCharacterLink(player.characterName))
            end
        elseif player.characterName then
            playerLink = ZO_LinkHandler_CreateCharacterLink(player.characterName)
        end

        if player.playerType == TYPE_UNKNOWN then
            formatedNote = zo_strformat(TOXICPLAYERS_SI_UNKNOWN_PLAYER_INFO, playerLink, characterLink)
        elseif player.playerType == TYPE_FRIENDS then
            formatedNote = zo_strformat(TOXICPLAYERS_SI_FRIEND_PLAYER_INFO, playerLink, characterLink)
        elseif player.playerType == TYPE_GUILD then
            formatedNote = zo_strformat(TOXICPLAYERS_SI_GUILD_PLAYER_INFO, playerLink, characterLink, GetGuildRecruitmentLink(guildMates[player.playerName].guildId, LINK_STYLE_DEFAULT))
        elseif player.playerType == TYPE_IGNORED then
            local playerNote = TP.GetPlayerIgnoreNote(player.playerName)
            formatedNote = (playerNote == nil or playerNote == "") and zo_strformat(TOXICPLAYERS_SI_NO_IGNORE_NOTE, playerLink, characterLink) or zo_strformat(TOXICPLAYERS_SI_IGNORE_NOTE, playerLink, characterLink, playerNote)
        elseif player.playerType == TYPE_BLACKLIST then
            local playerNote = TP.GetPlayerBannedNote(player.playerName)
            formatedNote = (playerNote == nil or playerNote == "") and zo_strformat(TOXICPLAYERS_SI_NO_BANNED_NOTE, playerLink, characterLink) or zo_strformat(TOXICPLAYERS_SI_BANNED_NOTE, playerLink, characterLink, playerNote)
        end

        if formatedNote then
            -- Display the notes in the chat for now
            CHAT_SYSTEM:Maximize()
            CHAT_SYSTEM:AddMessage(prefix .. formatedNote)
        end

        -- Display info just once
        TP.SetLastestPlayer(nil)
        latestEvent = GetGameTimeMilliseconds()
    end
end

function TP.GetPlayerIgnoreNote(playerName)
    local playerNote = nil
    for i = 1, GetNumIgnored() do
        local curDisplayName, curNote = GetIgnoredInfo(i)
        if playerName == curDisplayName then
            if curNote then
                playerNote = curNote
            else
                playerNote = ""
            end
            break
        end
    end
    return playerNote
end

function TP.GetPlayerBannedNote(playerName)
    if guildBlacklist[playerName] ~= nil then
        return guildBlacklist[playerName].note
    end
end

function TP.ToggleTargetIgnore(addNote)
    if TP.CanUseIgnore() then
        local playerName = GetUnitDisplayName('reticleover')

        if IsUnitIgnored('reticleover') then
            RemoveIgnore(playerName)
            TP.SetReticleStyle(TPStyles.DEFAULT, "", true, true)
        else
            if addNote then
                -- We can change note only after EVENT_IGNORE_ADDED is fired, so we save the note for now.
                local function IgnoreSelectedPlayerWithNote(playerName, playerNote)
                    AddIgnore(playerName)
                    editNote = playerNote
                    -- Resetting social timer, so the note is sure to be linked to the correct player.
                    latestEvent = GetGameTimeMilliseconds()
                end
                local data = {
                    displayName = playerName,
                    note = nil,
                    changedCallback = IgnoreSelectedPlayerWithNote
                }

                if IsInGamepadPreferredMode() then
                    ZO_Dialogs_ShowGamepadDialog("GAMEPAD_SOCIAL_EDIT_NOTE_DIALOG", data)
                else
                    ZO_Dialogs_ShowDialog("EDIT_NOTE", data)
                end
            else
                -- else, we simply add the player to the ignore list
                AddIgnore(playerName)
            end
        end

        latestEvent = GetGameTimeMilliseconds()
    end
end

function TP.ShareTarget()
    if IsUnitAttackable('reticleover') then
        AssignTargetMarkerToReticleTarget(TARGET_MARKER_TYPE_EIGHT or GetUnitTargetMarkerType('reticleover'))
    end
end

function TP.ReportTarget()
    -- Adding player to ignore as Zenimax is doing to avoid abuses. Do not report players already ignored.
    if TP.CanUseIgnore() and not IsUnitIgnored('reticleover') then
        local playerName = GetUnitDisplayName('reticleover')

        local function IgnoreSelectedPlayer()
            AddIgnore(playerName)
        end

        ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(playerName, IgnoreSelectedPlayer)
        latestEvent = GetGameTimeMilliseconds()
    end
end

function TP.IsSocialAllowed()
    if GetGameTimeMilliseconds() - latestEvent < SOCIAL_RATE_DELAY then
        -- Still in social cooldown
        -- ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_SOCIAL_REQUEST_ON_COOLDOWN))
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return false
    end

    return true
end

function TP.CanUseIgnore()
    -- No, no no. Do not report friends, group members or already blocked members.
    -- Add timer so we're not spamming
    return TP.IsSocialAllowed() and IsUnitPlayer('reticleover') and not IsUnitFriend('reticleover') and not IsUnitGrouped('reticleover')
end

function TP.Whisper()
    if latestWisp ~= nil then
        StartChatInput("", CHAT_CHANNEL_WHISPER, latestWisp.playerName)
    end
end

function TP.InitGuildMates()
    guildMates = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local numMembers = GetNumGuildMembers(guildId)
        for memberIndex = 1, numMembers do
            local displayName, note, _, _ = GetGuildMemberInfo(guildId, memberIndex)
            -- Keep just the first guild
            if guildMates[displayName] == nil then
                guildMates[displayName] = {
                    note = note,
                    guildName = guildName,
                    guildId = guildId
                }
            end
        end
    end
end

function TP.InitGuildBlacklist()
    guildBlacklist = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local numMembers = GetNumGuildBlacklistEntries(guildId)
        for memberIndex = 1, numMembers do
            local displayName, note = GetGuildBlacklistInfoAt(guildId, memberIndex)
            -- Keep just the first guild
            if guildBlacklist[displayName] == nil then
                guildBlacklist[displayName] = {
                    note = note,
                    guildName = guildName,
                    guildId = guildId
                }
            end
        end
    end
end

function TP.InitFriends()
    local settings = TP.getSettings()
    if settings.friendList[GetWorldName()] == nil then
        settings.friendList[GetWorldName()] = {}
    end
    local friends = settings.friendList[GetWorldName()]

    -- Check for missing friends
    for displayName, _ in pairs(friends) do
        if not IsFriend(displayName) then
            TP.OnFriendRemoved(EVENT_FRIEND_REMOVED, displayName, true)
        end
    end

    -- Refresh the list
    for i = 1, GetNumFriends() do
        local displayName, note, _, _ = GetFriendInfo(i)
        if friends[displayName] == nil then
            friends[displayName] = true
        end
    end
end

function TP.SlashCommand(commandArgs)
    local options = {}
    -- Split words
    local searchResult = {string.match(commandArgs, "^((%S*)%s*)*$")}
    for w in commandArgs:gmatch("%S+") do
        options[#options + 1] = string.lower(w)
    end

    -- Templates commands
    if options[1] == "info" or options[1] == nil then
        TP.DisplayPlayerInfo()
    end
    if options[1] == "whisp" or options[1] == "whisper" then
        TP.Whisper()
    end
end

function TP.OnAddOnLoaded(event, addonName)
    if addonName ~= TP.name then
        return
    end

    TP:Initialize()
end

function TP.OnPlayerLoaded(event)
    TP:InitializePlayer()
end

function TP:Initialize()
    TP.accountSettings = ZO_SavedVars:NewAccountWide(TP.name .. "Variables", TP.defaultSettings.variableVersion, nil, TP.defaultSettings)
    TP.localSettings = ZO_SavedVars:NewCharacterIdSettings(TP.name .. "Variables", TP.defaultSettings.variableVersion, nil, TP.defaultSettings)

    -- Initial UI and variables
    TP:CreateAddonMenu()
    TP.InitGuildMates()
    TP.InitGuildBlacklist()
    TP.FixPositions()
    TP.SetReticleStyle(TPStyles.DEFAULT, "", true, false)

    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_RETICLE_TARGET_CHANGED, TP.OnTargetHasChanged)

    -- Update when updating the lists
    EVENT_MANAGER:RegisterForEvent(TP.name .. "Note", EVENT_IGNORE_ADDED, TP.UpdatePlayerNote)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_IGNORE_ADDED, TP.OnTargetHasChanged)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_IGNORE_REMOVED, TP.OnTargetHasChanged)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_FRIEND_ADDED, TP.OnTargetHasChanged)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_FRIEND_REMOVED, TP.OnTargetHasChanged)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_RETICLE_HIDDEN_UPDATE, TP.OnReticleHidden)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_GUILD_MEMBER_ADDED, TP.InitGuildMates)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_GUILD_MEMBER_REMOVED, TP.InitGuildMates)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_GUILD_FINDER_BLACKLIST_RESPONSE, TP.InitGuildBlacklist)
    EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_GROUP_MEMBER_JOINED, TP.OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(TP.name .. "Friend", EVENT_FRIEND_REMOVED, TP.OnFriendRemoved)
    EVENT_MANAGER:RegisterForEvent(TP.name .. "Friends", EVENT_FRIEND_ADDED, TP.InitFriends)
    EVENT_MANAGER:RegisterForEvent(TP.name .. "Friends", EVENT_FRIEND_REMOVED, TP.InitFriends)

    EVENT_MANAGER:UnregisterForEvent(TP.name, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS[TP.command] = TP.SlashCommand
end

function TP:InitializePlayer()
    TP.InitFriends()
    EVENT_MANAGER:UnregisterForEvent(TP.name, EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_ADD_ON_LOADED, TP.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_PLAYER_ACTIVATED, TP.OnPlayerLoaded)
