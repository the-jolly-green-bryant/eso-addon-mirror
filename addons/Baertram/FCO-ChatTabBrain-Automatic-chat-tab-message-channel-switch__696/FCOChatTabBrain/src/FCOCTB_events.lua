FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

local chatSystem = FCOCTB.ChatSystem

--Check the incoming chat channel and save it so the next message you send via RETURN key will be written in THIS channel
local function FCOChatTabBrain_CheckLastChatChannel(messageType, overwrite)
--d("[FCOChatTabBrain_CheckLastChatChannel]messageType: " ..tostring(messageType) .. ", overwrite: " ..tostring(overwrite))
    if messageType == nil then return end
    overwrite = overwrite or false
    local chatVars = FCOCTB.chatVars
    local settings = FCOCTB.settingsVars.settings
    local mappingVars = FCOCTB.mappingVars
    FCOCTB.chatVars.lastIncomingChatChannelType = ""
    FCOCTB.chatVars.lastIncomingChatChannel = ""
    --Mapping array for the settings
    local chatTabs = {
        [CHAT_CHANNEL_WHISPER]          = settings.redirectWhisperChannelId,
        [CHAT_CHANNEL_SYSTEM]           = settings.autoOpenSystemChannelId,
        [CHAT_CHANNEL_GUILD_1]          = settings.autoOpenGuild1ChannelId,
        [CHAT_CHANNEL_GUILD_2]          = settings.autoOpenGuild2ChannelId,
        [CHAT_CHANNEL_GUILD_3]          = settings.autoOpenGuild3ChannelId,
        [CHAT_CHANNEL_GUILD_4]          = settings.autoOpenGuild4ChannelId,
        [CHAT_CHANNEL_GUILD_5]          = settings.autoOpenGuild5ChannelId,
        [CHAT_CHANNEL_OFFICER_1]        = settings.autoOpenOfficer1ChannelId,
        [CHAT_CHANNEL_OFFICER_2]        = settings.autoOpenOfficer2ChannelId,
        [CHAT_CHANNEL_OFFICER_3]        = settings.autoOpenOfficer3ChannelId,
        [CHAT_CHANNEL_OFFICER_4]        = settings.autoOpenOfficer4ChannelId,
        [CHAT_CHANNEL_OFFICER_5]        = settings.autoOpenOfficer5ChannelId,
        [CHAT_CHANNEL_SAY]              = settings.autoOpenSayChannelId,
        [CHAT_CHANNEL_PARTY]            = settings.autoOpenGroupChannelId,
        [CHAT_CHANNEL_YELL]             = settings.autoOpenYellChannelId,
        [CHAT_CHANNEL_ZONE]             = settings.autoOpenZoneChannelId,
        [CHAT_CHANNEL_ZONE_LANGUAGE_1]  = settings.autoOpenZoneENChannelId,
        [CHAT_CHANNEL_ZONE_LANGUAGE_2]  = settings.autoOpenZoneFRChannelId,
        [CHAT_CHANNEL_ZONE_LANGUAGE_3]  = settings.autoOpenZoneDEChannelId,
        [CHAT_CHANNEL_ZONE_LANGUAGE_4]  = settings.autoOpenZoneJPChannelId,
        [CHAT_CHANNEL_ZONE_LANGUAGE_5]  = settings.autoOpenZoneRUChannelId,
        [CHAT_CHANNEL_ZONE_LANGUAGE_6]  = settings.autoOpenZoneESChannelId,
        [CHAT_CHANNEL_ZONE_LANGUAGE_7]  = settings.autoOpenZoneZHChannelId,
        [CHAT_CHANNEL_MONSTER_SAY]      = settings.autoOpenNSCChannelId,
        [CHAT_CHANNEL_MONSTER_YELL]     = settings.autoOpenNSCChannelId,
        [CHAT_CHANNEL_MONSTER_WHISPER]  = settings.autoOpenNSCChannelId,
    }
    local chatChannelToAutoChangeTabSettings = {
        [CHAT_CHANNEL_WHISPER]          = settings.autoChangeToChannelWhisper,
        [CHAT_CHANNEL_SYSTEM]           = settings.autoChangeToChannelSystem,
        [CHAT_CHANNEL_GUILD_1]          = settings.autoChangeToChannelGuild1,
        [CHAT_CHANNEL_GUILD_2]          = settings.autoChangeToChannelGuild2,
        [CHAT_CHANNEL_GUILD_3]          = settings.autoChangeToChannelGuild3,
        [CHAT_CHANNEL_GUILD_4]          = settings.autoChangeToChannelGuild4,
        [CHAT_CHANNEL_GUILD_5]          = settings.autoChangeToChannelGuild5,
        [CHAT_CHANNEL_OFFICER_1]        = settings.autoChangeToChannelOfficer1,
        [CHAT_CHANNEL_OFFICER_2]        = settings.autoChangeToChannelOfficer2,
        [CHAT_CHANNEL_OFFICER_3]        = settings.autoChangeToChannelOfficer3,
        [CHAT_CHANNEL_OFFICER_4]        = settings.autoChangeToChannelOfficer4,
        [CHAT_CHANNEL_OFFICER_5]        = settings.autoChangeToChannelOfficer5,
        [CHAT_CHANNEL_SAY]              = settings.autoChangeToChannelSay,
        [CHAT_CHANNEL_PARTY]            = settings.autoChangeToChannelGroup,
        [CHAT_CHANNEL_YELL]             = settings.autoChangeToChannelYell,
        [CHAT_CHANNEL_ZONE]             = settings.autoChangeToChannelZone,
        [CHAT_CHANNEL_ZONE_LANGUAGE_1]  = settings.autoChangeToChannelZoneEN,
        [CHAT_CHANNEL_ZONE_LANGUAGE_2]  = settings.autoChangeToChannelZoneFR,
        [CHAT_CHANNEL_ZONE_LANGUAGE_3]  = settings.autoChangeToChannelZoneDE,
        [CHAT_CHANNEL_ZONE_LANGUAGE_4]  = settings.autoChangeToChannelZoneJP,
        [CHAT_CHANNEL_ZONE_LANGUAGE_5]  = settings.autoChangeToChannelZoneRU,
        [CHAT_CHANNEL_ZONE_LANGUAGE_6]  = settings.autoChangeToChannelZoneES,
        [CHAT_CHANNEL_ZONE_LANGUAGE_7]  = settings.autoChangeToChannelZoneZH,
        [CHAT_CHANNEL_MONSTER_SAY]      = settings.autoChangeToChannelNSC,
        [CHAT_CHANNEL_MONSTER_YELL]     = settings.autoChangeToChannelNSC,
        [CHAT_CHANNEL_MONSTER_WHISPER]  = settings.autoChangeToChannelNSC,
    }
    --Shall we set the last incoming chat channel for the next outgoing chat message now?
    if    (
            (overwrite or (chatChannelToAutoChangeTabSettings[messageType]))
            and (chatTabs[messageType] ~= nil and chatTabs[messageType] ~= 0)
    ) then
        FCOCTB.chatVars.lastIncomingChatChannelType = messageType
        local chatMessageTypeToChatChannel = mappingVars.chatMessageTypeToChatChannel
        FCOCTB.chatVars.lastIncomingChatChannel = chatMessageTypeToChatChannel[messageType] or nil
        if chatVars.lastIncomingChatChannel == nil then FCOCTB.chatVars.lastIncomingChatChannel = "" end
--d(">Last incoming chat channel: " .. chatVars.lastIncomingChatChannel)
    end
end

--Play a sound on incoming messages
local function FCOChatTabBrain_CheckPlaySound(messageType, isFriend, textFound, characterName, isGroupLeaderSound, isMessageFromGuildMaster, guildNr)
--d("[FCOChatTabBrain_CheckPlaySound] messageType: " ..tostring(messageType) .. ", isFriend: " .. tostring(isFriend) .. ", TextFound: " .. tostring(textFound) .. ", characterName found: " .. tostring(characterName) .. ", isGroupLeader: " .. tostring(isGroupLeaderSound) .. ", isGuildMaster: " .. tostring(isMessageFromGuildMaster) .. ", guildNr: " ..tostring(guildNr))
    local settings = FCOCTB.settingsVars.settings
    if messageType == nil or settings.disableChatSounds then return end
    isFriend = isFriend or false
    textFound = textFound or false
    characterName = characterName or false
    isGroupLeaderSound = isGroupLeaderSound or false
    isMessageFromGuildMaster = isMessageFromGuildMaster or false

    --The chat channles of the possible guilds
    local guildChatChannels = FCOCTB.mappingVars.guildChatChannels

    --Get the current active chat tab
    local currentChatTab = chatSystem.primaryContainer.currentBuffer:GetParent().tab.index
    local soundToPlayForChatChannel
    local soundToPlayForFriend
    local soundToPlayForTextFound
    local soundToPlayForCharacterName
    local soundToPlayForGroupLeader
    local soundToPlayForGuildMaster
    local onlyPlayGuildMasterSoundOnGuildTabs = settings.playSoundOnGuildMasterOnlyGuildTabs

    --Special check results
    local doNotPlayGuildMasterSound = true
    local doNotPlayGroupLeaderSound = true

    --Get the sounds for friend, text found in message, characterName, group leader and guild master messages
    if isFriend and settings.playSoundOnMessageFriend ~= 1 then
        soundToPlayForFriend = settings.playSoundOnMessageFriend
    end
    if textFound and settings.playSoundOnMessageTextFound ~= 1 then
        soundToPlayForTextFound = settings.playSoundOnMessageTextFound
    end
    if characterName and settings.playSoundOnMyCharacterName ~= 1 then
        soundToPlayForCharacterName = settings.playSoundOnMyCharacterName
    end
    local playSoundWithActiveTabGroupMaster = settings.playSoundWithActiveTabGroupLeader
    if isGroupLeaderSound == true and settings.playSoundOnGroupLeader ~= 1 then
        soundToPlayForGroupLeader = settings.playSoundOnGroupLeader
        doNotPlayGroupLeaderSound = false
    end
    local playSoundWithActiveTabGuildMaster = settings.playSoundWithActiveTabGuildMaster
    if isMessageFromGuildMaster == true and settings.playSoundOnGuildMaster ~= 1 then
        soundToPlayForGuildMaster = settings.playSoundOnGuildMaster
        doNotPlayGuildMasterSound = false
    end
--d(">>doNotPlayGuildMasterSound: " ..tostring(doNotPlayGuildMasterSound))


    --Mapping array for the chat channel to sound info & settings
    local chatChannelToSoundSettings = {
        [CHAT_CHANNEL_WHISPER]          = {
            ["sound"]           = settings.playSoundOnMessageWhisper,
            ["withActiveTab"]   = settings.playSoundWithActiveTabWhisper,
            ["switchToTab"]     = settings.redirectWhisperChannelId,
        },
        [CHAT_CHANNEL_SYSTEM]           =  {
            ["sound"]           = settings.playSoundOnMessageSystem,
            ["withActiveTab"]   = settings.playSoundWithActiveTabSystem,
            ["switchToTab"]     = settings.autoOpenSystemChannelId,
        },
        [CHAT_CHANNEL_GUILD_1]          = {
            ["sound"]           = settings.playSoundOnMessageGuild1,
            ["withActiveTab"]   = settings.playSoundWithActiveTabGuild1,
            ["switchToTab"]     = settings.autoOpenGuild1ChannelId,
            ["guildNr"]         = 1,
        },
        [CHAT_CHANNEL_GUILD_2]          = {
            ["sound"]           = settings.playSoundOnMessageGuild2,
            ["withActiveTab"]   = settings.playSoundWithActiveTabGuild2,
            ["switchToTab"]     = settings.autoOpenGuild2ChannelId,
            ["guildNr"]         = 2,
        },
        [CHAT_CHANNEL_GUILD_3]          = {
            ["sound"]           = settings.playSoundOnMessageGuild3,
            ["withActiveTab"]   = settings.playSoundWithActiveTabGuild3,
            ["switchToTab"]     = settings.autoOpenGuild3ChannelId,
            ["guildNr"]         = 3,
        },
        [CHAT_CHANNEL_GUILD_4]          = {
            ["sound"]           = settings.playSoundOnMessageGuild4,
            ["withActiveTab"]   = settings.playSoundWithActiveTabGuild4,
            ["switchToTab"]     = settings.autoOpenGuild4ChannelId,
            ["guildNr"]         = 4,
        },
        [CHAT_CHANNEL_GUILD_5]          = {
            ["sound"]           = settings.playSoundOnMessageGuild5,
            ["withActiveTab"]   = settings.playSoundWithActiveTabGuild5,
            ["switchToTab"]     = settings.autoOpenGuild5ChannelId,
            ["guildNr"]         = 5,
        },
        [CHAT_CHANNEL_OFFICER_1]        = {
            ["sound"]           = settings.playSoundOnMessageOfficer1,
            ["withActiveTab"]   = settings.playSoundWithActiveTabOfficer1,
            ["switchToTab"]     = settings.autoOpenOfficer1ChannelId,
            ["guildOfficerNr"]  = 1,
        },
        [CHAT_CHANNEL_OFFICER_2]        = {
            ["sound"]           = settings.playSoundOnMessageOfficer2,
            ["withActiveTab"]   = settings.playSoundWithActiveTabOfficer2,
            ["switchToTab"]     = settings.autoOpenOfficer2ChannelId,
            ["guildOfficerNr"]  = 2,
        },
        [CHAT_CHANNEL_OFFICER_3]        = {
            ["sound"]           = settings.playSoundOnMessageOfficer3,
            ["withActiveTab"]   = settings.playSoundWithActiveTabOfficer3,
            ["switchToTab"]     = settings.autoOpenOfficer3ChannelId,
            ["guildOfficerNr"]  = 3,
        },
        [CHAT_CHANNEL_OFFICER_4]        = {
            ["sound"]           = settings.playSoundOnMessageOfficer4,
            ["withActiveTab"]   = settings.playSoundWithActiveTabOfficer4,
            ["switchToTab"]     = settings.autoOpenOfficer4ChannelId,
            ["guildOfficerNr"]  = 4,
        },
        [CHAT_CHANNEL_OFFICER_5]        = {
            ["sound"]           = settings.playSoundOnMessageOfficer5,
            ["withActiveTab"]   = settings.playSoundWithActiveTabOfficer5,
            ["switchToTab"]     = settings.autoOpenOfficer5ChannelId,
            ["guildOfficerNr"]  = 5,
        },
        [CHAT_CHANNEL_SAY]              = {
            ["sound"]           = settings.playSoundOnMessageSay,
            ["withActiveTab"]   = settings.playSoundWithActiveTabSay,
            ["switchToTab"]     = settings.autoOpenSayChannelId,
        },
        [CHAT_CHANNEL_PARTY]            = {
            ["sound"]           = settings.playSoundOnMessageGroup,
            ["withActiveTab"]   = settings.playSoundWithActiveTabGroup,
            ["switchToTab"]     = settings.autoOpenGroupChannelId,
        },
        [CHAT_CHANNEL_YELL]             = {
            ["sound"]           = settings.playSoundOnMessageYell,
            ["withActiveTab"]   = settings.playSoundWithActiveTabYell,
            ["switchToTab"]     = settings.autoOpenYellChannelId,
        },
        [CHAT_CHANNEL_ZONE]             = {
            ["sound"]           = settings.playSoundOnMessageZone,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZone,
            ["switchToTab"]     = settings.autoOpenZoneChannelId,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_1]  = {
            ["sound"]           = settings.playSoundOnMessageZoneEN,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZoneEN,
            ["switchToTab"]     = settings.autoOpenZoneENChannelId,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_2]  = {
            ["sound"]           = settings.playSoundOnMessageZoneFR,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZoneFR,
            ["switchToTab"]     = settings.autoOpenZoneFRChannelId,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_3]  = {
            ["sound"]           = settings.playSoundOnMessageZoneDE,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZoneDE,
            ["switchToTab"]     = settings.autoOpenZoneDEChannelId,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_4]  = {
            ["sound"]           = settings.playSoundOnMessageZoneJP,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZoneJP,
            ["switchToTab"]     = settings.autoOpenZoneJPChannelId,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_5]  = {
            ["sound"]           = settings.playSoundOnMessageZoneRU,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZoneRU,
            ["switchToTab"]     = settings.autoOpenZoneRUChannelId,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_6]  = {
            ["sound"]           = settings.playSoundOnMessageZoneES,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZoneES,
            ["switchToTab"]     = settings.autoOpenZoneESChannelId,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_7]  = {
            ["sound"]           = settings.playSoundOnMessageZoneZH,
            ["withActiveTab"]   = settings.playSoundWithActiveTabZoneZH,
            ["switchToTab"]     = settings.autoOpenZoneZHChannelId,
        },
        [CHAT_CHANNEL_MONSTER_SAY]      = {
            ["sound"]           = settings.playSoundOnMessageNSC,
            ["withActiveTab"]   = settings.playSoundWithActiveTabNSC,
            ["switchToTab"]     = settings.autoOpenNSCChannelId,
        },
        [CHAT_CHANNEL_MONSTER_YELL]      = {
            ["sound"]           = settings.playSoundOnMessageNSC,
            ["withActiveTab"]   = settings.playSoundWithActiveTabNSC,
            ["switchToTab"]     = settings.autoOpenNSCChannelId,
        },
        [CHAT_CHANNEL_MONSTER_WHISPER]      = {
            ["sound"]           = settings.playSoundOnMessageNSC,
            ["withActiveTab"]   = settings.playSoundWithActiveTabNSC,
            ["switchToTab"]     = settings.autoOpenNSCChannelId,
        },
    }

    --Check the incoming chat message channel
    local playSoundSettings = chatChannelToSoundSettings[messageType]
    if playSoundSettings ~= nil then
        local soundToPlay = playSoundSettings["sound"]
        local withActiveTab = playSoundSettings["withActiveTab"]
        local switchToTab = playSoundSettings["switchToTab"]
        local guildNrOfMessageChannel = playSoundSettings["guildNr"]

        --Is the currentChatTab the chatTab assigned to the message's channel?
        local currentChatTabEqualsMessageChatTab = (currentChatTab and switchToTab and switchToTab ~= 0 and currentChatTab == switchToTab) or false

        --==================[[Special checks - BEGIN]]================================
        --  [Guild stuff]

        local checkIfNoGuildChannelMessageIsAllowed = false

        --Is the guildNr given? Check if it is valid
        if doNotPlayGuildMasterSound == false and guildNr ~= nil then
            if guildNr < 1 then guildNr = 1 end
            local maxGuilds = GetNumGuilds()
            if guildNr > maxGuilds then guildNr = maxGuilds end
        else
            doNotPlayGuildMasterSound = true
        end
        --Is it a guild master message and shall we play a sound for the guildmaster messages?
        if doNotPlayGuildMasterSound == false then
            --Is the message's channel a guild channel?
            if guildNrOfMessageChannel ~= nil then
                --Which guild's guildMaster wrote a message? Compare to the used message channel's assigned guildNr
                if guildNr ~= nil and guildNr == guildNrOfMessageChannel then
                    --GuildMaster sound should only be played if the current chat tab is NOT the same as the message's chat tab?
                    if not playSoundWithActiveTabGuildMaster == true then
                        --Check the current chat tab and the message's chat tab, and compare them.
                        if currentChatTabEqualsMessageChatTab == true then
                            --Chat tabs are the same: Don't play the sound of the GuildMaster
                            doNotPlayGuildMasterSound = true
                        end
                    end
                    checkIfNoGuildChannelMessageIsAllowed = true
                else
                    --Guild master of another guild is writing->Will be handled in it's own event callback
                    doNotPlayGuildMasterSound = true
                end
            else
                --No guild channel message
                checkIfNoGuildChannelMessageIsAllowed = true
            end
        end
        --Additional checks, if guild sound should still be played (until here)
        if doNotPlayGuildMasterSound == false and checkIfNoGuildChannelMessageIsAllowed == true then
            --Play the sound only if the message came in at a guild channel
            if onlyPlayGuildMasterSoundOnGuildTabs == true then
                local isGuildChatChannel = guildChatChannels[messageType] or false
                if not isGuildChatChannel then
                    doNotPlayGuildMasterSound = true
                end
            end
        end

        --  [Group stuff]
        --Group leader checks
        if doNotPlayGroupLeaderSound == false then
            --GroupLeader sound should only be played if the current chat tab is NOT the same as the message's chat tab?
            if not playSoundWithActiveTabGroupMaster == true then
                --Check the current chat tab and the message's chat tab, and compare them.
                if currentChatTabEqualsMessageChatTab == true then
                    --Chat tabs are the same: Don't play the sound of the GroupLeader
                    doNotPlayGroupLeaderSound = true
                end
            end
        end
        --==================[[Special checks - END]]================================


        --==================[[Normal checks - END]]================================
        --A sound to play was chosen for the chat channel of the message?
        if soundToPlay and soundToPlay > 1 then
            --[[Normal checks]]
            --Play the sound even with active chat tab = chat tab of the chat message?
            -->No further checks needed than
            if withActiveTab or (not withActiveTab and currentChatTabEqualsMessageChatTab == false) then
                soundToPlayForChatChannel = soundToPlay
            end
        end
        --==================[[Normal checks - END]]================================
    end

    --The sound to play later on (if it's NIL the chat channel sound will be played!)
    local soundToPlayNow
    --Is the chat channel the sound to play as priorization?
    if settings.preferedSoundForMultiple ~= 5 then
        --Special checks
        local doNotRunThisCode = false
        --GuildMaster sound but shouldn't be played?
        if (isMessageFromGuildMaster == true and doNotPlayGuildMasterSound == true)
        --GroupLeader sound but shouldn't be played?
         or (isGroupLeaderSound == true and doNotPlayGroupLeaderSound == true)
        then
            doNotRunThisCode = true
        end
--d("== doNotRunThisCode: " ..tostring(doNotRunThisCode))
        --Shall we run this code? Or only play the standard chat message sound?
        if not doNotRunThisCode then
            --Priorize the sound play order
            local preferedSoundForMultipleMapping = {}
            local enabledVal = false
            --From prio: 1 group leader, 2 guild master, 3 friend, 4 text was found, 5 chat channel sound to 6 my character name was found
            for i=1, FCOCTB_CHAT_SOUND_MAX do
                if settings.preferedSoundForMultiple == i then
                    enabledVal = true
                else
                    enabledVal = false
                end
                preferedSoundForMultipleMapping[i] = enabledVal
            end
            local soundToPlayMapping = {
                --Group Leader
                [FCOCTB_CHAT_SOUND_GROUP_LEADER] = {
                    ["enabled"] = preferedSoundForMultipleMapping[FCOCTB_CHAT_SOUND_GROUP_LEADER],
                    ["sound"]   = soundToPlayForGroupLeader,
                },
                --Guild master
                [FCOCTB_CHAT_SOUND_GUILD_MASTER] = {
                    ["enabled"] = preferedSoundForMultipleMapping[FCOCTB_CHAT_SOUND_GUILD_MASTER],
                    ["sound"]   = soundToPlayForGuildMaster,
                },
                --Friend
                [FCOCTB_CHAT_SOUND_FRIEND] = {
                    ["enabled"] = preferedSoundForMultipleMapping[FCOCTB_CHAT_SOUND_FRIEND],
                    ["sound"]   = soundToPlayForFriend,
                },
                --Text was found
                [FCOCTB_CHAT_SOUND_TEXT] = {
                    ["enabled"] = preferedSoundForMultipleMapping[FCOCTB_CHAT_SOUND_TEXT],
                    ["sound"]   = soundToPlayForTextFound,
                },
                --Chat channel
                [FCOCTB_CHAT_SOUND_CHANNEL] = {
                    ["enabled"] = preferedSoundForMultipleMapping[FCOCTB_CHAT_SOUND_CHANNEL],
                    ["sound"]   = soundToPlayForChatChannel,
                },
                --Character name was found
                [FCOCTB_CHAT_SOUND_CHARACTER] = {
                    ["enabled"] = preferedSoundForMultipleMapping[FCOCTB_CHAT_SOUND_CHARACTER],
                    ["sound"]   = soundToPlayForCharacterName,
                },
            }
            --Now check if the prefered sound to play is currently the correct one as
            --e.g. the group leader sound should be prefered but we aren't in any group
            --First check with the prefered settings
            if isGroupLeaderSound and IsUnitGrouped("player") and (settings.preferedSoundForMultiple == FCOCTB_CHAT_SOUND_GROUP_LEADER) then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_GROUP_LEADER]
            elseif isMessageFromGuildMaster and (settings.preferedSoundForMultiple == FCOCTB_CHAT_SOUND_GUILD_MASTER) then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_GUILD_MASTER]
            elseif isFriend and (settings.preferedSoundForMultiple == FCOCTB_CHAT_SOUND_FRIEND) then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_FRIEND]
            elseif textFound and (settings.preferedSoundForMultiple == FCOCTB_CHAT_SOUND_TEXT) then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_TEXT]
            elseif characterName and (settings.preferedSoundForMultiple == FCOCTB_CHAT_SOUND_CHARACTER) then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_CHARACTER]
            end
            --If no sound was set yet (because the priorized sound is group leader but we are not grouped):
            -- Check without the prefered settings then
            if soundToPlayNow == nil and isGroupLeaderSound and IsUnitGrouped("player") then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_GROUP_LEADER]
            elseif soundToPlayNow == nil and isMessageFromGuildMaster then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_GUILD_MASTER]
            elseif soundToPlayNow == nil and isFriend then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_FRIEND]
            elseif soundToPlayNow == nil and textFound then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_TEXT]
            elseif soundToPlayNow == nil and characterName then
                soundToPlayNow = soundToPlayMapping[FCOCTB_CHAT_SOUND_CHARACTER]
            end
        end
    end
--d(">soundToPlayNow: " ..tostring(soundToPlayNow) .. ", soundToPlayForChatChannel: " ..tostring(soundToPlayForChatChannel))
    --Play a special sound now?
    local soundsTab = FCOCTB.sounds
    if soundToPlayNow ~= nil and soundToPlayNow["sound"] ~= nil then
        PlaySound(SOUNDS[soundsTab[soundToPlayNow["sound"]]])
    --Play chat channel sound only
    elseif soundToPlayForChatChannel ~= nil then
        PlaySound(SOUNDS[soundsTab[soundToPlayForChatChannel]])
    end
end

--Save the last incoming message's chat channel to the currently active chat tab so we can cycle it later on.
--Only save it if it's not already in the list
local function FCOChatTabBrain_SaveLastIncomingChatChannels(currentIndex, currentChannel)
    --d("[FCOCTB] FCOChatTabBrain_SaveLastIncomingChatChannels - curentTab: " .. tostring(currentIndex) .. ", currentChannel: " .. tostring(currentChannel))
    local supportedChatChannels = FCOCTB.mappingVars.activeChatChannels
    --Is the chat channel given and supported to be saved?
    if currentChannel == nil then return nil end
    if not supportedChatChannels[currentChannel] then return nil end
    --Is the current active chat tab given?
    if currentIndex == nil or currentIndex == 0 then return nil end
    --d(">Chat tab with message: " .. tostring(currentIndex))
    --Check the settings for the chat tab and build them if not given yet
    local settings = FCOCTB.settingsVars.settings
    if settings and settings.lastUsedChatChannelsAtTab then
        local newBuild = false
        local doAddEntry = false
        if settings.lastUsedChatChannelsAtTab[currentIndex] == nil then
            settings.lastUsedChatChannelsAtTab[currentIndex] = {}
            newBuild = true
            doAddEntry = true
        end
        if not newBuild then
            --Loop over the last used chat channels at this tab:
            --If the current chat channel is already in the list, do not add it again
            local savedChatChannelEntries = settings.lastUsedChatChannelsAtTab[currentIndex]
            local foundDuplicate = false
            for _, messageChannelSaved in ipairs(savedChatChannelEntries) do
                if messageChannelSaved == currentChannel then
                    foundDuplicate = true
                    break -- exit the loop
                end
            end
            --No entry with the chat channel in there already, so add it new
            if not foundDuplicate then
                doAddEntry = true
            else
                doAddEntry = false
            end

        end
        --Add the entry now to the settings?
        if doAddEntry then
            --Set the chat channel to the settings table now, but with an integer index so ipairs can be used to loop it!
            table.insert(settings.lastUsedChatChannelsAtTab[currentIndex], currentChannel)
        end
    end
end

--GetGuildInfo(integer guildId)
--* Returns: integer numMembers, integer numOnline, string* leaderName
--GetGuildMemberIndexFromDisplayName(integer guildId, string displayName)
--* Returns: luaindex:nilable* memberIndex
--IsGuildRankGuildMaster(integer guildId, luaindex rankIndex)
--* Returns: bool* isGuildMaster
local function IsGuildMaster(guildId, displayName)
    local _, _, gmName = GetGuildInfo(guildId)
    return (gmName == displayName) or false
end

local function CheckForGuildMasterPost(displayName)
    --Check all guilds
    local numGuilds = GetNumGuilds()
    if numGuilds > 0 then
        for i = 1, numGuilds do
            local guildId = GetGuildId(i)
            local isGuildMaster = IsGuildMaster(guildId, displayName)
            if isGuildMaster then
                return true, i
            end
        end
    end
    return false, nil
end

--Each time a chat message comes in this function will be called
--EVENT_CHAT_MESSAGE_CHANNEL
local function FCOChatTabBrain_ChatMessageChannel(eventCode, messageType, fromName, text, isCustomerService, fromDisplayName)
--d("[FCOCTB]FCOChatTabBrain_ChatMessageChannel, messageType: " .. tostring(messageType) .. ", fromName: " ..tostring(fromName) .. "/" .. tostring(fromDisplayName) .. ", text: " ..tostring(text))
    --A chat tab change is already active? Abort here
    local supportedChatChannels = FCOCTB.mappingVars.activeChatChannels
    local supportedChatChannel = supportedChatChannels[messageType]
--d(">supportedChatChannel: " ..tostring(supportedChatChannel))
    if isCustomerService or FCOCTB.preventerVars.changingToNewChatTab or not supportedChatChannel or supportedChatChannel == nil then return end

    --Format message poster
    local postingPerson   = zo_strformat(SI_UNIT_NAME, fromName)
    --is the message send by myself? Abort here
    local myPlayerName    = GetUnitName("player")
    local myPlayerNameRaw = GetRawUnitName("player")
    local myAccountName   = GetDisplayName()
    local isMyFriend = false
    --Local settings for faster access to the sub tables
    local settings = FCOCTB.settingsVars.settings
    local prevVars = FCOCTB.preventerVars
    local chatVars = FCOCTB.chatVars

--d(">MyPlayerName: " .. myPlayerName .. " (" .. myPlayerNameRaw .. "), MyAccountName: " .. myAccountName .. " / fromName: " .. postingPerson .. " (" .. fromName .. ")")
    --Is the chat message sent by myself? Abort then
    if fromName == myAccountName or postingPerson == myAccountName or fromName == myPlayerNameRaw or postingPerson == myPlayerName then
        --Get the used chat channel so the next time we press RETURN will send another message to this chat channel, instead of the chat channel from last incoming message
--d(">>[Outgoing] chat message by myself!")
        if messageType ~= nil and settings.sendingMessageOverwritesChatChannel == true then
            --Overwrite the last incoming chat channel with your currently used chat channel
            FCOChatTabBrain_CheckLastChatChannel(messageType, true)
        end
        --Abort here as we do not check sounds for our own sent messages
        return
    end

    --Variable which is checked at the end of this function and will change the chat tab if true
    local changeChatTabNow = false

    --Current time
    local currentTime = GetTimeStamp()
--d(">Current time: " .. currentTime .. ", posted by: " .. postingPerson)
    --Update the time as the chat message comes in so we can compare it to the idle time for chat minimization
    if settings.autoMinimizeTimeout ~= 0 then
        chatVars.lastIncomingMessage = currentTime
    end

    --Mapping table for chat channel to chat tab index
    local chatChannelToTabs = {
        [CHAT_CHANNEL_WHISPER]          = {
            ["switchToTab"] = settings.redirectWhisperChannelId,
            ["idleTime"]    = settings.autoOpenWhisperIdleTime,
        },
        [CHAT_CHANNEL_SYSTEM]           = {
            ["switchToTab"]	= settings.autoOpenSystemChannelId,
            ["idleTime"]    = settings.autoOpenSystemIdleTime,
        },
        [CHAT_CHANNEL_GUILD_1]          = {
            ["switchToTab"]	= settings.autoOpenGuild1ChannelId,
            ["idleTime"]    = settings.autoOpenGuild1IdleTime,
        },
        [CHAT_CHANNEL_GUILD_2]          = {
            ["switchToTab"]	= settings.autoOpenGuild2ChannelId,
            ["idleTime"]    = settings.autoOpenGuild2IdleTime,
        },
        [CHAT_CHANNEL_GUILD_3]          = {
            ["switchToTab"]	= settings.autoOpenGuild3ChannelId,
            ["idleTime"]    = settings.autoOpenGuild3IdleTime,
        },
        [CHAT_CHANNEL_GUILD_4]          = {
            ["switchToTab"]	= settings.autoOpenGuild4ChannelId,
            ["idleTime"]    = settings.autoOpenGuild4IdleTime,
        },
        [CHAT_CHANNEL_GUILD_5]          = {
            ["switchToTab"]	= settings.autoOpenGuild5ChannelId,
            ["idleTime"]    = settings.autoOpenGuild5IdleTime,
        },
        [CHAT_CHANNEL_OFFICER_1]        = {
            ["switchToTab"]	= settings.autoOpenOfficer1ChannelId,
            ["idleTime"]    = settings.autoOpenOfficer1IdleTime,
        },
        [CHAT_CHANNEL_OFFICER_2]        = {
            ["switchToTab"]	= settings.autoOpenOfficer2ChannelId,
            ["idleTime"]    = settings.autoOpenOfficer2IdleTime,
        },
        [CHAT_CHANNEL_OFFICER_3]        = {
            ["switchToTab"]	= settings.autoOpenOfficer3ChannelId,
            ["idleTime"]    = settings.autoOpenOfficer3IdleTime,
        },
        [CHAT_CHANNEL_OFFICER_4]        = {
            ["switchToTab"]	= settings.autoOpenOfficer4ChannelId,
            ["idleTime"]    = settings.autoOpenOfficer4IdleTime,
        },
        [CHAT_CHANNEL_OFFICER_5]        = {
            ["switchToTab"]	= settings.autoOpenOfficer5ChannelId,
            ["idleTime"]    = settings.autoOpenOfficer5IdleTime,
        },
        [CHAT_CHANNEL_SAY]              = {
            ["switchToTab"]	= settings.autoOpenSayChannelId,
            ["idleTime"]    = settings.autoOpenSayIdleTime,
        },
        [CHAT_CHANNEL_PARTY]            = {
            ["switchToTab"]	= settings.autoOpenGroupChannelId,
            ["idleTime"]    = settings.autoOpenGroupIdleTime,
        },
        [CHAT_CHANNEL_YELL]             = {
            ["switchToTab"]	= settings.autoOpenYellChannelId,
            ["idleTime"]    = settings.autoOpenYellIdleTime,
        },
        [CHAT_CHANNEL_ZONE]             = {
            ["switchToTab"]	= settings.autoOpenZoneChannelId,
            ["idleTime"]    = settings.autoOpenZoneIdleTime,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_1]  = {
            ["switchToTab"]	= settings.autoOpenZoneDEChannelId,
            ["idleTime"]    = settings.autoOpenZoneDEIdleTime,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_2]  = {
            ["switchToTab"]	= settings.autoOpenZoneENChannelId,
            ["idleTime"]    = settings.autoOpenZoneENIdleTime,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_3]  = {
            ["switchToTab"]	= settings.autoOpenZoneFRChannelId,
            ["idleTime"]    = settings.autoOpenZoneFRIdleTime,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_4]  = {
            ["switchToTab"]	= settings.autoOpenZoneJPChannelId,
            ["idleTime"]    = settings.autoOpenZoneJPIdleTime,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_5]  = {
            ["switchToTab"]	= settings.autoOpenZoneRUChannelId,
            ["idleTime"]    = settings.autoOpenZoneRUIdleTime,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_6]  = {
            ["switchToTab"]	= settings.autoOpenZoneESChannelId,
            ["idleTime"]    = settings.autoOpenZoneESIdleTime,
        },
        [CHAT_CHANNEL_ZONE_LANGUAGE_7]  = {
            ["switchToTab"]	= settings.autoOpenZoneZHChannelId,
            ["idleTime"]    = settings.autoOpenZoneZHIdleTime,
        },
        [CHAT_CHANNEL_MONSTER_SAY]      = {
            ["switchToTab"]	= settings.autoOpenNSCChannelId,
            ["idleTime"]    = settings.autoOpenNSCIdleTime,
        },
        [CHAT_CHANNEL_MONSTER_YELL]      = {
            ["switchToTab"]	= settings.autoOpenNSCChannelId,
            ["idleTime"]    = settings.autoOpenNSCIdleTime,
        },
        [CHAT_CHANNEL_MONSTER_WHISPER]      = {
            ["switchToTab"]	= settings.autoOpenNSCChannelId,
            ["idleTime"]    = settings.autoOpenNSCIdleTime,
        },
    }
    --Check if the chat tab, where we will switch to, got the messageType's output channel still enabled in the options.
    --Otherwise we would switch to a chat tab where no text is shown :-)
    local switchToTabIndex = chatChannelToTabs[messageType]["switchToTab"]
    if switchToTabIndex == nil then return end
    local chatContainerId = chatSystem.primaryContainer.id
    local chatChannelOptionIsEnabled = FCOCTB.CheckChatTabOptionsForCategory(messageType, switchToTabIndex, chatContainerId)
--d(">switchToTabIndex: " .. tostring(switchToTabIndex) .. ", chatChannelOptionIsEnabled: " .. tostring(chatChannelOptionIsEnabled))
    --The chat channel could not be determined? Let's say the option is still enabled then...
    if chatChannelOptionIsEnabled == -1 then chatChannelOptionIsEnabled = true end

    --Is a searched text found in the received text message?
    local textFound = false
    local ignoreName = false
    local myCharacterNameWasUsed = false
    local isMessageFromGuildMaster = false
    local guildNr
    --Do not check for friend amd don't parse message text if a monster/NPC is speaking.
    --Will be changed as ZOs implements a monster friends list :-p
    if messageType ~= CHAT_CHANNEL_MONSTER_SAY and messageType ~= CHAT_CHANNEL_MONSTER_YELL and messageType ~= CHAT_CHANNEL_MONSTER_WHISPER then
--d(">checking messageText for keywords")
        local messageText = ""
        if not settings.disableChatSounds then
            --Play a sound if a text is found?
            if settings.playSoundOnMessageTextFound ~= nil and settings.playSoundOnMessageTextFound ~= 1 and settings.chatKeyWords ~= nil and settings.chatKeyWords ~= "" then
                messageText = string.gsub(text, '([%[%]%%%(%)%{%}%$%^%+])', '[%%%1]')
                local keyWords = { zo_strsplit("\n", settings.chatKeyWords) }
                for _,keyWord in ipairs(keyWords) do
                    keyWord = string.gsub(keyWord, '([%[%]%%%(%)%{%}%$%^%+])', '[%%%1]')
--d(">keyword: " ..tostring(keyWord))
                    if string.match(string.lower(messageText), string.lower(keyWord)) then
                        textFound = true
                        break
                    end
                end
            end
            --Is the text message send from an account/playername that we do not want to play a sound for?
            if settings.chatIgnoreNames ~= nil and settings.chatIgnoreNames ~= "" then
                local ignoredNames = { zo_strsplit("\n", settings.chatIgnoreNames) }
                for _,ignoredName in ipairs(ignoredNames) do
                    if string.match(string.lower(postingPerson), string.lower(ignoredName))
                            or string.match(string.lower(fromName), string.lower(ignoredName)) then
                        ignoreName = true
                        break
                    end
                end
            end
            --Variable for check if my character name was written
            if settings.playSoundOnMyCharacterName ~= nil and settings.playSoundOnMyCharacterName ~= 1 then
                --Parse chat mesage for my character name
                if messageText == "" then
                    messageText = string.gsub(text, '([%[%]%%%(%)%{%}%$%^%+])', '[%%%1]')
                end
                --d("Message: " .. messageText)
                local charnameFragments = { zo_strsplit(" ", myPlayerName) }
                for _,charnameFragment in ipairs(charnameFragments) do
                    charnameFragment = string.gsub(charnameFragment, '([%[%]%%%(%)%{%}%$%^%+])', '[%%%1]')
                    --d("Check part: " .. charnameFragment)
                    if string.match(string.lower(messageText), string.lower(charnameFragment)) then
                        --d(">> found!")
                        myCharacterNameWasUsed = true
                        break
                    end
                end
            end
            --Is the sender my friend?
            if settings.playSoundOnMessageFriend ~= 1 then
                isMyFriend = IsFriend(postingPerson)
            end
            --Is the setting enabled to inform if a guild master writes and the sender a guild master?
            if settings.playSoundOnGuildMaster then
                isMessageFromGuildMaster, guildNr = CheckForGuildMasterPost(fromDisplayName)
            end
        end

    end -- chat channel not equals MONSTER NPC

    --Only play sound if the sender's name is not ignored for sounds
    --and if the chat channel option is still enabled at the chat tab
    local isGrouped = false
    if not settings.disableChatSounds and not ignoreName and chatChannelOptionIsEnabled then
        --Check if the group leader sound should be played, and if it should only be played in AvA region
        local isGroupLeaderSound = false
        --Was the incoming message in the group chat?
        if messageType == CHAT_CHANNEL_PARTY then
            if settings.playSoundOnGroupLeader ~= nil and settings.playSoundOnGroupLeader ~= "" then
                --Are we grouped?
                isGrouped = (GetGroupSize() > 1) or false
                if isGrouped == true then
                    --Preset the check variable with true
                    isGroupLeaderSound = true
                    if settings.groupLeaderSoundInPvPOnly then
                        isGroupLeaderSound = IsPlayerInAvAWorld()
                    end
                    if isGroupLeaderSound == true then
                        local groupLeader = GetRawUnitName(GetGroupLeaderUnitTag())
                        if groupLeader == nil or groupLeader == "" then
                            isGroupLeaderSound = false
                        else
                            isGroupLeaderSound = (fromName == groupLeader or postingPerson == groupLeader)
                        end
                    end
                end
            end
        end
        --Check if a sound should be played
        FCOChatTabBrain_CheckPlaySound(messageType, isMyFriend, textFound, myCharacterNameWasUsed, isGroupLeaderSound, isMessageFromGuildMaster, guildNr)
    end

    --Get the used incoming chat channel so we can auto-set it for next outgoing message
    --> If settings enabled:
    --> Only check if the user is not currently using the chat's text edit control to write to another user.
    --> At this time the user should communicate with the current user and not the one who has written before/who has just send a new incoming message (at whispers e.g.)
    local dontChangeChatChannelIfTextEditActive = settings.dontChangeChatChannelIfTextEditActive
    local isChatTextEditUsed = FCOCTB.CheckIfChatTextEditIsUsed()
--d(">isChatTextEditActive: " ..tostring(isChatTextEditUsed) ..", dontChangeChatChannelIfTextEditActive: " ..tostring(dontChangeChatChannelIfTextEditActive))
    if not dontChangeChatChannelIfTextEditActive or (dontChangeChatChannelIfTextEditActive == true and not isChatTextEditUsed) then
        FCOChatTabBrain_CheckLastChatChannel(messageType, nil)
    end
    --Incoming message is a whisper but we are currently typing new text?
    if isChatTextEditUsed == true and messageType == CHAT_CHANNEL_WHISPER then
        FCOCTB.whisperVars.lastReceiver = ""
        --Compare the sender of the whisper with the receiver of our current message: If they differ store the current
        --receiver in the whisper variables -> See function "FCOChatTabBrain_SetNextChatChannel"
        local currentReceiver = chatSystem.currentReceiver
--d(">whispering, receiver: " ..tostring(currentReceiver))
        if (currentReceiver ~= nil and currentReceiver ~= "")
            and (fromName ~= nil and fromName ~= "" and fromName ~= currentReceiver)
            and (fromDisplayName ~= nil and fromDisplayName ~= "" and fromDisplayName ~= currentReceiver) then
--d(">>set whisper 'last receiver'")
            --Remember the current receiver of the whisper message
            FCOCTB.whisperVars.lastReceiver = currentReceiver
        end
    end

    --Kepp the chat hidden if we are in a menu? or
    --Don't change the chat tab if the chat is minimized and the setting is enabled
    local dontShowBecauseMinimized = false
    if settings.doNotAutoOpenIfMinimized and chatSystem:IsMinimized() then
        dontShowBecauseMinimized = true
    end

    --Check if we are grouped and if the chat tabs shouldn't switch then
    local isGroupedAndDontChangeTabThen = FCOCTB.isGroupedAndDontChangeTab(isGrouped)

--d(">Grouped and don't change chat tabs then?: " .. tostring(isGroupedAndDontChangeTabThen))

    --Save the last incoming chat channel to the list of last used chat channels, with the chat tab index of the chat tab where the message
    --came in
    FCOChatTabBrain_SaveLastIncomingChatChannels(switchToTabIndex, messageType)

    --Get the difference in MS between last user action and chat message incoming time
    local timeDifference = GetDiffBetweenTimeStamps(currentTime, chatVars.lastUserActiveTime)
    --Check incoming messageType + idle time of the user and switch to the relating chat tab if idle time was reached
    if     chatVars.lastUserActiveTime ~= nil and chatVars.lastUserActiveTime < currentTime
            and switchToTabIndex ~= nil and switchToTabIndex ~= 0
            and chatChannelToTabs[messageType]["idleTime"] ~= nil and chatChannelToTabs[messageType]["idleTime"] ~= -1
            and timeDifference > 0 and timeDifference >= chatChannelToTabs[messageType]["idleTime"] then
        FCOCTB.preventerVars.timeNotReached = false
        -- NON-Whisper messages
        if     messageType ~= CHAT_CHANNEL_WHISPER and settings.enableChatTabSwitch
                and chatChannelOptionIsEnabled and not dontShowBecauseMinimized then
            --Check the settings for the given messgeType now and compare the time difference with the needed idle time
            if not isGroupedAndDontChangeTabThen then
                --Time difference is bigger than the needed idle time and we are not in a group/allowed messages even if we are groupd -> Change the chat tab now
                changeChatTabNow = true
            end
            -- Whisper messages
        elseif  messageType == CHAT_CHANNEL_WHISPER and settings.autoOpenWhisperTab then
            --Show whispers also if we are grouped?
            if settings.doAutoOpenWhisperIfGrouped or not isGroupedAndDontChangeTabThen then
                changeChatTabNow = true
            end
        end
    elseif chatChannelToTabs[messageType]["idleTime"] ~= nil and timeDifference < chatChannelToTabs[messageType]["idleTime"] then
        --Time difference was not big enough -> Mark that the time was not reached yet so the chat tab text color can be changed upon next incoming chat message
        FCOCTB.preventerVars.timeNotReached = true
    end
--d("[FCOCTB]changeChatTabNow: " ..tostring(changeChatTabNow).. ", switchToTabIndex: " ..tostring(switchToTabIndex) .. ", timeNotReached: " ..tostring(prevVars.timeNotReached))
    --Change the chat tab now?
    if changeChatTabNow == true then
        --Is the setting enabled to change to a default chat tab after an general idle time?
        --FCOCTB.SetupDefaultTabIdleTimer()
        --Change the active chat tab now
        local wasTabChanged, _ = FCOCTB.ChangeChatTabNow(switchToTabIndex)
        if wasTabChanged == true and settings.autoScrollToChatBottomUponNewIncomingMsg == true then
            FCOCTB.ScrollChatTabToBottom()
        end
    else
        local numChatTabs = chatSystem.primaryContainer and chatSystem.primaryContainer.windows and #chatSystem.primaryContainer.windows
        --Change the chat tab text color if new message arrives?
        if (settings.showChatTabColor == true
                and (switchToTabIndex ~= nil and switchToTabIndex > 0 and (numChatTabs ~= nil and switchToTabIndex <= numChatTabs))
                and (
                    --Automatic chat tab switch is enabled and the idle time was not met? Or automatic chat tab switch was disabled.
                    (prevVars.timeNotReached == true or (not settings.enableChatTabSwitch and prevVars.timeNotReached == false))
                        or dontShowBecauseMinimized or isGroupedAndDontChangeTabThen
                )
        )
        then
            --Get the current chat tab
            local currentTab = chatSystem.primaryContainer.currentBuffer:GetParent().tab
            --The tab of the incoming chat message -> Must be mapped somehow by using the index from the set settings, e.g. settings.autoOpenSystemChannelId
            -- -> chatSystem.primaryContainer.windows[switchToTabIndex].tab
            local newTabParent = chatSystem.primaryContainer.windows[switchToTabIndex]
            local newTab
            if newTabParent == nil then return end
            newTab = newTabParent.tab
    --d("CurrentTab: " .. currentTab:GetName() .. ", NewTab - ID (" .. switchToTabIndex ..") " .. newTab:GetName())
            --If the option to change the color of the next chat tab text, where a message came in, but we were not inactive long enough, is enabled
            if    currentTab ~= nil and newTab ~= nil and currentTab ~= newTab then
                --Is the timeout time reached, the chat not minimized and we are not in a group and don't want the chat tabs to change or show?
                if ZO_TabButton_Text_SetTextColor and GetControl(newTab, "Text") ~= nil and ZO_SECOND_CONTRAST_TEXT ~= nil then
                    --Change the chat relating tab color to light blue to signalize a new message has arrived
                    ZO_TabButton_Text_SetTextColor(newTab, ZO_SECOND_CONTRAST_TEXT)
                    ZO_TabButton_Text_AllowColorChanges(newTab, false)
                end
                --Reset the preventer var again so the time difference will be checked new
                FCOCTB.preventerVars.timeNotReached = false
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--Callback function for event player activated
function FCOCTB.PlayerActivated(event)
    local addonVars = FCOCTB.addonVars
    EVENT_MANAGER:UnregisterForEvent(addonVars.gAddonName, event)

    FCOCTB.ChatSystem = CHAT_SYSTEM
    chatSystem = FCOCTB.ChatSystem
    FCOCTB.GetChatSystem()

    --Load the hooks
    FCOCTB.hookChat_functions()

    --Hook the other functions
    FCOCTB.hookOther_functions()

    --Register the event for new text messages to check, if whisper has come in, and change the tab then (if enabled in the settings)
    EVENT_MANAGER:RegisterForEvent(addonVars.gAddonName, EVENT_CHAT_MESSAGE_CHANNEL, FCOChatTabBrain_ChatMessageChannel)

    --Minimize the chat if wished
    local settings = FCOCTB.settingsVars.settings
    if settings.chatMinimizeOnLoad then
        if not chatSystem:IsMinimized() then
            chatSystem:Minimize()
        end
    end
    --Load the last saved chat tab and switch to it
    FCOCTB.LoadLastActiveChatTab()

    --Get the chat tab names/texts
    FCOCTB.GetChatTabNames()

    --Tell the settings that they were not called before
    FCOCTB.preventerVars.settingsFirstCall = true

    --Show the menu
    FCOCTB.BuildAddonMenu()

    --Update Last user active time was NOW
    FCOCTB.SetUserLastAction()

    --Enable the timer for the chat auto minimization, but only if it is not still active/only if not the chat should be minimized on load
    if settings.autoMinimizeTimeout ~= nil and settings.autoMinimizeTimeout > 0 and not settings.chatMinimizeOnLoad and not FCOCTB.chatVars.chatMinimizeTimerActive then
        FCOCTB.chatVars.chatMinimizeTimerActive = EVENT_MANAGER:RegisterForUpdate(addonVars.gAddonName.."ChatMinimizeCheck", 1000, FCOCTB.MinimizeChatCheck)
    end

    --Reset variables for the chat
    FCOCTB.chatVars.lastIncomingMessage            = GetTimeStamp() -- needed so the auto minimize feature starts to count the time difference from now
    FCOCTB.chatVars.lastIncomingChatChannel        = ""
    FCOCTB.chatVars.lastIncomingChatChannelType    = ""

    --Fix for the chat tabs moved into overflow container, introduced with patch 1.7
    --Rebuild the chat layout for the primary container
    if chatSystem.primaryContainer ~= nil then
        chatSystem.primaryContainer:PerformLayout()
    end

    --Mark the addon as fully loaded now
    addonVars.gAddonFullyLoaded = true
end

function FCOCTB.Loaded(eventCode, addOnName)
    local addonVars = FCOCTB.addonVars
    if(addOnName ~= addonVars.gAddonName) then
        return
    end

    FCOCTB.ChatSystem = CHAT_SYSTEM
    chatSystem = FCOCTB.ChatSystem
    FCOCTB.GetChatSystem()

    --LibAddonMenu-2.0
    FCOCTB.LAM = LibAddonMenu2
    if FCOCTB.LAM == nil then d("[FCOCTB]Library LibAddonMenu-2.0 is missing. Addon won't work!") return end

    FCOCTB.librariesLoadedProperly = true

    --d("[FCOCTB.Loaded]")
    --Load the user settings
    FCOCTB.LoadUserSettings()

    -- Set Localization
    FCOCTB.preventerVars.KeyBindingTexts = false
    FCOCTB.Localization()

    -- Register slash commands
    FCOCTB.RegisterSlashCommands()

    EVENT_MANAGER:UnregisterForEvent(addonVars.gAddonName, eventCode)
end

-- Register the event "addon loaded" for this addon
function FCOCTB.Initialized()
    FCOCTB.ChatSystem = CHAT_SYSTEM
    chatSystem = FCOCTB.ChatSystem
    FCOCTB.GetChatSystem()

    local addonVars = FCOCTB.addonVars
    EVENT_MANAGER:RegisterForEvent(addonVars.gAddonName, EVENT_ADD_ON_LOADED, FCOCTB.Loaded)
    -- Many thanks to Garkin for his code here !!!
    EVENT_MANAGER:RegisterForEvent(addonVars.gAddonName, EVENT_PLAYER_ACTIVATED, FCOCTB.PlayerActivated)
end



