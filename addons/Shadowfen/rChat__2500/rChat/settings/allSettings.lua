local SF = LibSFUtils
local LAM = LibAddonMenu2
local LMP = LibMediaProvider

local rData = rChat.data
local L = GetString

-- Character Sync Option
local function SyncCharacterSelectChoices()
    local localPlayer = GetUnitName("player")
	local localId = GetCurrentCharacterId()
    local db = rChat.save

    -- Sync Character Select
    rData.chatConfSyncChoices = {}
    if db.chatConfSync then
        for names, tagada in pairs (db.chatConfSync) do
            if names ~= "lastChar" then
                table.insert(rData.chatConfSyncChoices, names)
            end
        end
    else
        table.insert(rData.chatConfSyncChoices, localPlayer)
    end
end

-- split a mention string (one entry per line) into appropriate entries
-- in the mention table
-- returns the mention table
local function mention_split(newValue, col)
    lines = {}
	newValue = newValue.."\r\n"
	local dv = newValue:gsub("[\r\n]",";")
	for s in dv:gmatch("(.-);+") do
		table.insert(lines, s)
    end
    newtbl = {}
    for _,v in pairs(lines) do
        -- require minimum length
        if string.len(v) >= 4 then
            if nil == string.find(v, "[%%%*%-%.%+%(%)%[%]%^%$%?]") then
                -- have no regex pattern characters
                local c = v -- in case we don't have a color passed in
                if col then
                    c = string.format("%s%s|r", col,v)
                end
                newtbl[#newtbl+1]={v,c}
            end
        end
    end
    return newtbl
end

-- changes the colorized versions of mention to use the
-- new color
local function mention_recolor(mentiontbl, newcolor)
    if mentiontbl then
        for _,v in ipairs(mentiontbl) do
            if not newcolor then 
                v[2] = v[1]     -- should I nil this?
            else
                v[2] = string.format("%s%s|r", newcolor,v[1])
            end
        end
    end
    return mentiontbl
end



-- combine entries of a mention table into a string for an editbox
local function mention_combine(tbl)
    local str
    if tbl then
        for _,v in ipairs(tbl) do
            if not str then
                str = v[1]
            else
                str = string.format("%s\r\n%s",str, v[1])
            end
        end
    else
        str = ""
    end
    return str
end

local function UpdateChoices(name, data)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(name)
    if dropdownCtrl == nil then
        return
    end
	dropdownCtrl:UpdateChoices(data.choices, data.choicesValues, data.choicesTooltips)
end

local function getLeftColorRGB(channelId)
    local colorsEntry = rChat.getColors(channelId)
    return SF.ConvertHexToRGBA(colorsEntry[1])
end

local function getRightColorRGB(channelId)
    local colorsEntry = rChat.getColors(channelId)
    return SF.ConvertHexToRGBA(colorsEntry[2])
end

local function messageSettings()
    local db = rChat.save
    return {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_OPTIONSH),
        controls = {
			{ -- Enable Friend Status Messages
                type = "checkbox",
                name = L(RCHAT_FRIENDSTATUS),
                --tooltip = L(RCHAT_FRIENDSTATUSTT),
                getFunc = function() return db.enableFriendStatus end,
                setFunc = function(newValue) db.enableFriendStatus = newValue end,
                width = "full",
                default = rChat.defaults.enableFriendStatus,
			},
			{
				type = "divider",
				width = "full", --or "half" (optional)
				height = 10,
				alpha = 0.5,
			},
			{-- LAM Option Remove Zone Tags
                type = "checkbox",
                name = L(RCHAT_DELZONETAGS),
                tooltip = L(RCHAT_DELZONETAGSTT),
                getFunc = function() return db.nozonetags end,
                setFunc = function(newValue) db.nozonetags = newValue end,
                width = "full",
                default = rChat.defaults.nozonetags,
            },
            {
                type = "header",
                name = SF.colors.superior:Colorize(RCHAT_GEOCHANNELSFORMAT),
                width = "full",
            },
            {
                type = "description",
                text = "",
            },
            {-- LAM Option Newline between name and message
                type = "checkbox",
                name = L(RCHAT_CARRIAGERETURN),
                tooltip = L(RCHAT_CARRIAGERETURNTT),
                getFunc = function() return db.carriageReturn end,
                setFunc = function(newValue) db.carriageReturn = newValue end,
                width = "full",
                default = rChat.defaults.carriageReturn,
            },
            {-- LAM Option Names Format
                type = "dropdown",
                name = L(RCHAT_GEOCHANNELSFORMAT),
                tooltip = L(RCHAT_GEOCHANNELSFORMATTT),
                choices = {L("RCHAT_GROUPNAMESCHOICE", 1), 
                          L("RCHAT_GROUPNAMESCHOICE", 2), 
                          L("RCHAT_GROUPNAMESCHOICE", 3),
                          L("RCHAT_GROUPNAMESCHOICE", 4),
                          L("RCHAT_GROUPNAMESCHOICE", 5)}, -- Same as group.
                width = "half",
                default = rChat.defaults.geoChannelsFormat,
                getFunc = function() return L("RCHAT_GROUPNAMESCHOICE", db.geoChannelsFormat) end,
                setFunc = function(choice)
                    if choice == L("RCHAT_GROUPNAMESCHOICE", 1) then
                        db.geoChannelsFormat = 1
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 2) then
                        db.geoChannelsFormat = 2
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 3) then
                        db.geoChannelsFormat = 3
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 4) then
                        db.geoChannelsFormat = 4
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 5) then
                        db.geoChannelsFormat = 5
                    else
                        -- When clicking on LAM default button
                        db.geoChannelsFormat = rChat.defaults.geoChannelsFormat
                    end

                end,
            },
            {-- Disable Brackets
                type = "checkbox",
                name = L(RCHAT_DISABLEBRACKETS),
                tooltip = L(RCHAT_DISABLEBRACKETSTT),
                getFunc = function() return db.disableBrackets end,
                setFunc = function(newValue) 
                    db.disableBrackets = newValue 
                end,
                width = "half",
                default = rChat.defaults.disableBrackets,
            },
            {-- Nicknames
                type = "editbox",
                name = L(RCHAT_NICKNAMES),
                tooltip = L(RCHAT_NICKNAMESTT),
                isMultiline = true,
                isExtraWide = true,
                getFunc = function() return db.nicknames end,
                setFunc = function(newValue)
                    db.nicknames = newValue
                    rChat.BuildNicknames(true) -- Rebuild the control if data is invalid
                end,
                width = "full",
                default = rChat.defaults.nicknames,
            },
            {-- Timestamp
                type = "header",
                name = SF.colors.superior:Colorize(RCHAT_TIMESTAMPH),
                width = "full",
            },
            {
                type = "description",
                text = "",
            },
            {-- Enable Timestamp
                type = "checkbox",
                name = L(RCHAT_ENABLETIMESTAMP),
                tooltip = L(RCHAT_ENABLETIMESTAMPTT),
                getFunc = function() return db.showTimestamp end,
                setFunc = function(newValue) db.showTimestamp = newValue end,
                width = "full",
                default = rChat.defaults.showTimestamp,
            },
            {-- Timestamp format
                type = "editbox",
                name = L(RCHAT_TIMESTAMPFORMAT),
                tooltip = L(RCHAT_TIMESTAMPFORMATTT),
                getFunc = function() return db.timestampFormat end,
                setFunc = function(newValue) db.timestampFormat = newValue end,
                width = "full",
                default = rChat.defaults.timestampFormat,
                disabled = function() return not db.showTimestamp end,
            },
            {-- Timestamp color is left column color
                type = "checkbox",
                name = L(RCHAT_TIMESTAMPCOLORISLCOL),
                tooltip = L(RCHAT_TIMESTAMPCOLORISLCOLTT),
                getFunc = function() return db.timestampcolorislcol end,
                setFunc = function(newValue) db.timestampcolorislcol = newValue end,
                width = "full",
                default = rChat.defaults.timestampcolorislcol,
                disabled = function() return not db.showTimestamp end,
            },
            {-- timestamp color
                type = "colorpicker",
                name = L(RCHAT_TIMESTAMP),
                tooltip = L(RCHAT_TIMESTAMPTT),
                getFunc = function() return SF.ConvertHexToRGBA(db.colours.timestamp) end,
                setFunc = function(r, g, b) db.colours.timestamp = SF.ConvertRGBToHex(r, g, b) end,
                default = SF.ConvertHexToRGBAPacked(rChat.defaults.colours["timestamp"]),
                disabled = function()
                    if not db.showTimestamp then return true end
                    if db.timestampcolorislcol then return true end
                    return false end,
            },
            -- mention Section
			{
				type = "header",
				name = SF.colors.superior:Colorize(RCHAT_MENTION_NM), -- or string id or function returning a string
				width = "full", --or "half" (optional)
			},
			{-- mention is enabled
				type = "checkbox",
				name = L(RCHAT_MENTION_ENABLED),
				getFunc = function() return db.mention.mentionEnabled end,
				setFunc = function(value) db.mention.mentionEnabled = value end,
				width = "full",
			},
			{-- mention emote is enabled
				type = "checkbox",
				name = RCHAT_MENTION_EMOTE_ENABLED,
				tooltip = RCHAT_MENTION_EMOTE_ENABLED_TT,
				getFunc = function() return db.mention.emoteEnabled end,
				setFunc = function(value) db.mention.emoteEnabled = value end,
				width = "full",
				default=false,
			},
            {-- mention strings textbox
                type = "editbox",
                name = L(RCHAT_MENTIONSTR),
                --tooltip = L(RCHAT_MENTIONSTRTT),
                isMultiline = true,
                getFunc = function() 
                    -- return mention.mentionStr
                    if not db.mention.mentiontbl then db.mention.mentiontbl = {} end
					return mention_combine(db.mention.mentiontbl)
                end,
                setFunc = function(newValue)
					if db.mention.colorEnabled then
                        db.mention.mentiontbl = mention_split(newValue,db.mention.color)
                    else
                        db.mention.mentiontbl = mention_split(newValue)
                    end
				end,
                width = "full",
                default = rChat.defaults.mention.mentionStr,
                disabled = function() return not db.mention.mentionEnabled end,
            },
			{-- mention sound enabled
				type = "checkbox",
				name = GetString(RCHAT_SOUND_ENABLED),
				getFunc = function() return db.mention.soundEnabled end,
				setFunc = function(value) db.mention.soundEnabled = value end,
				disabled = function() return not db.mention.mentionEnabled end,
				width = "half",
			},
            {-- Mentions: Sound
                type = "slider",
                name = GetString(RCHAT_SOUND_INDEX),
                min = 1, max = SF.numSounds(), step = 1,
                getFunc = function()
                    if type(db.mention.sound) == "string" then
                        return SF.getSoundIndex(db.mention.sound)
                    end
                    return SF.getSoundIndex(rChat.defaults.mention.sound)
                end,
                setFunc = function(value)
                    db.mention.sound = SF.getSound(value)
                    local ctrl = WINDOW_MANAGER:GetControlByName("RCHAT_MENTION_SOUND")
                    if ctrl ~= nil then
                        ctrl.data.text = SF.colors.normal:Colorize(db.mention.sound)
                    end
                    SF.PlaySound(db.mention.sound)
                end,
                width = "half",
                disabled = function() return not db.mention.mentionEnabled end,
                default = rChat.defaults.mention.sound,
            },
            {-- Name of current Sound
                type = "description",
                title = L(RCHAT_SOUND_NAME),
                --text = SF.colors.normal:Colorize(db.mention.sound),
                text = db.mention.sound or "",
                disable = false,
                reference = "RCHAT_MENTION_SOUND",
            },
			{ -- Mention color enabled
				type = "checkbox",
				name = GetString(RCHAT_COLOR_ENABLED),
				getFunc = function() return db.mention.colorEnabled end,
				setFunc = function(value) 
                    db.mention.colorEnabled = value 
                    if value then
                        mention_recolor(db.mention.mentiontbl,db.mention.color)
                    else
                        mention_recolor(db.mention.mentiontbl)
                    end
                end,
				disabled = function() return not db.mention.mentionEnabled end,
				width = "half",
			},
            {-- Mention Color
                type = "colorpicker",
                name = L(RCHAT_MENTIONCOLOR),
                --tooltip = L(RCHAT_MENTIONCOLORTT),
                getFunc = function() return SF.ConvertHexToRGBA(db.mention.color) end,
                setFunc = function(r, g, b)
                    db.mention.color = SF.ConvertRGBToHex(r, g, b)
                    if db.mention.colorEnabled then
                        mention_recolor(db.mention.mentiontbl,db.mention.color)
                    end
                end,
                width = "half",
                default = SF.ConvertHexToRGBAPacked(rChat.defaults.mention.color),
                disabled = function() return not db.mention.colorEnabled end,
            },
            { -- Misc
                type = "header",
                name = SF.colors.superior:Colorize("Misc"),
                width = "full",
            },
            {
                type = "description",
                text = "",
            },
            {-- LAM Option Guild Tags next to entry box
                type = "checkbox",
                name = L(RCHAT_GUILDTAGSNEXTTOENTRYBOX),
                tooltip = L(RCHAT_GUILDTAGSNEXTTOENTRYBOXTT),
                width = "full",
                default = rChat.defaults.showTagInEntry,
                getFunc = function() return db.showTagInEntry end,
                setFunc = function(newValue)
                            db.showTagInEntry = newValue
                            rChat.UpdateGuildChannelNames()
                        end
            },
            {--Target History
                type = "checkbox",
                name = L(RCHAT_ADDCHANNELANDTARGETTOHISTORY),
                tooltip = L(RCHAT_ADDCHANNELANDTARGETTOHISTORYTT),
                getFunc = function() return db.addChannelAndTargetToHistory end,
                setFunc = function(newValue) db.addChannelAndTargetToHistory = newValue end,
                width = "full",
                default = rChat.defaults.addChannelAndTargetToHistory,
            },
            {-- URL is clickable
                type = "checkbox",
                name = L(RCHAT_URLHANDLING),
                tooltip = L(RCHAT_URLHANDLINGTT),
                getFunc = function() return db.urlHandling end,
                setFunc = function(newValue) db.urlHandling = newValue end,
                width = "full",
                default = rChat.defaults.urlHandling,
            },

        },
    }
end

local function chatTabSettings()
    local db = rChat.save
    return {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_CHATTABH),
        controls = {
            {-- Enable chat channel memory
                type = "checkbox",
                name = L(RCHAT_enableChatTabChannel),
                tooltip = L(RCHAT_enableChatTabChannelT),
                getFunc = function() return db.tabs.enableChatTabChannel end,
                setFunc = function(newValue) db.tabs.enableChatTabChannel = newValue end,
                width = "full",
                default = rChat.defaults.tabs.enableChatTabChannel,
            },
            {-- Default channel
                type = "dropdown",
                name = L(RCHAT_DEFAULTCHANNEL),
                tooltip = L(RCHAT_DEFAULTCHANNELTT),
                choices = {
                    --L("RCHAT_DEFAULTCHANNELCHOICE", RCHAT_CHANNEL_NONE),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_ZONE),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_SAY),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_1),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_2),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_3),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_4),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_5),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_1),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_2),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_3),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_4),
                    L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_5)
                },
                width = "full",
                default = rChat.defaults.tabs.defaultchannel,
                getFunc = function() return L("RCHAT_DEFAULTCHANNELCHOICE", db.tabs.defaultchannel) end,
                setFunc = function(choice)
                    if choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_ZONE) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_ZONE
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_SAY) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_SAY
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_1) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_GUILD_1
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_2) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_GUILD_2
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_3) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_GUILD_3
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_4) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_GUILD_4
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_GUILD_5) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_GUILD_5
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_1) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_OFFICER_1
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_2) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_OFFICER_2
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_3) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_OFFICER_3
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_4) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_OFFICER_4
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", CHAT_CHANNEL_OFFICER_5) then
                        db.tabs.defaultchannel = CHAT_CHANNEL_OFFICER_5
                    elseif choice == L("RCHAT_DEFAULTCHANNELCHOICE", RCHAT_CHANNEL_NONE) then
                        db.tabs.defaultchannel = RCHAT_CHANNEL_NONE
                    else
                        -- When user click on LAM reinit button
                        db.tabs.defaultchannel = rChat.defaults.tabs.defaultchannel
                    end
                    rChat.SetToDefaultChannel()

                end,
            },
            {-- CHAT_SYSTEM.primaryContainer.windows doesn't exist yet at OnAddonLoaded. So using the rChat reference.
                type = "dropdown",
                name = L(RCHAT_DEFAULTTAB),
                tooltip = L(RCHAT_DEFAULTTABTT),
                choices = rChat.tabNames:GetNames(),
                width = "full",
                getFunc = function() 
					return db.tabs.defaultTabName end,
                setFunc = function(choice)
                        db.tabs.defaultTabName = choice
                        db.tabs.defaultTab = rChat.tabNames:GetIndex(choice) or 1
                    end,
				reference = "RCHAT_TABNAMES_DD",
            },
            {-- New Message Color
                type = "colorpicker",
                name = L(RCHAT_TABWARNING),
                tooltip = L(RCHAT_TABWARNINGTT),
                getFunc = function() return SF.ConvertHexToRGBA(db.colours["tabwarning"]) end,
                setFunc = function(r, g, b)
                        db.colours["tabwarning"] = SF.ConvertRGBToHex(r, g, b)
                    end,
                default = SF.ConvertHexToRGBAPacked(rChat.defaults.colours["tabwarning"]),
            },
        },
    }
end

local function groupChannelTweaks()
    local db = rChat.save
    return {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_GROUPH),
        controls = {
            {-- Enable Party Switch
                type = "checkbox",
                name = L(RCHAT_ENABLEPARTYSWITCH),
                tooltip = L(RCHAT_ENABLEPARTYSWITCHTT),
                getFunc = function() return db.enablepartyswitch end,
                setFunc = function(newValue) db.enablepartyswitch = newValue end,
                width = "full",
                default = rChat.defaults.enablepartyswitch,
            },
            {-- Group Names
                type = "dropdown",
                name = L(RCHAT_GROUPNAMES),
                tooltip = L(RCHAT_GROUPNAMESTT),
                choices = {L("RCHAT_GROUPNAMESCHOICE", 1), 
                           L("RCHAT_GROUPNAMESCHOICE", 2), 
                           L("RCHAT_GROUPNAMESCHOICE", 3), 
                           L("RCHAT_GROUPNAMESCHOICE", 4), 
                           L("RCHAT_GROUPNAMESCHOICE", 5)},
                width = "full",
                default = rChat.defaults.groupNames,
                getFunc = function() return L("RCHAT_GROUPNAMESCHOICE", db.groupNames) end,
                setFunc = function(choice)
                    if choice == L("RCHAT_GROUPNAMESCHOICE", 1) then
                        db.groupNames = 1
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 2) then
                        db.groupNames = 2
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 3) then
                        db.groupNames = 3
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 4) then
                        db.groupNames = 4
                    elseif choice == L("RCHAT_GROUPNAMESCHOICE", 5) then
                        db.groupNames = 5
                    else
                        -- When clicking on LAM default button
                        db.groupNames = rChat.defaults.groupNames
                    end

                end,
            },
            {-- Group Leader
                type = "checkbox",
                name = L(RCHAT_GROUPLEADER),
                tooltip = L(RCHAT_GROUPLEADERTT),
                getFunc = function() return db.groupLeader end,
                setFunc = function(newValue) db.groupLeader = newValue end,
                width = "full",
                default = rChat.defaults.groupLeader,
            },
            {-- Group Leader Color
                type = "colorpicker",
                name = L(RCHAT_GROUPLEADERCOLOR),
                tooltip = L(RCHAT_GROUPLEADERCOLORTT),
                getFunc = function() return SF.ConvertHexToRGBA(db.colours["groupleader"]) end,
                setFunc = function(r, g, b) db.colours["groupleader"] = SF.ConvertRGBToHex(r, g, b) end,
                width = "half",
                default = SF.ConvertHexToRGBAPacked(rChat.defaults.colours["groupleader"]),
                disabled = function() return not db.groupLeader end,
            },
            {-- Group Leader Color 2
                type = "colorpicker",
                name = L(RCHAT_GROUPLEADERCOLOR1),
                tooltip = L(RCHAT_GROUPLEADERCOLOR1TT),
                getFunc = function()
                        return SF.ConvertHexToRGBA(db.colours["groupleader1"])
                    end,
                setFunc = function(r, g, b)
                        db.colours["groupleader1"] = SF.ConvertRGBToHex(r, g, b)
                    end,
                width = "half",
                default = SF.ConvertHexToRGBAPacked(rChat.defaults.colours["groupleader1"]),
                disabled = function()
                        if not db.groupLeader then
                            return true
                        elseif db.useESOcolors then
                            return true
                        else
                            return false
                        end
                    end,
            },
        },
    }
end

local function syncingSettings()
    local db = rChat.save
    return     {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_SYNCH),
        controls = {
            {-- Sync ON
                type = "checkbox",
                name = L(RCHAT_CHATSYNCCONFIG),
                tooltip = L(RCHAT_CHATSYNCCONFIGTT),
                getFunc = function() return db.chatSyncConfig end,
                setFunc = function(newValue) db.chatSyncConfig = newValue end,
                width = "full",
                default = rChat.defaults.chatSyncConfig,
            },
            {-- Config Import From
                type = "dropdown",
                name = L(RCHAT_CHATSYNCCONFIGIMPORTFROM),
                tooltip = L(RCHAT_CHATSYNCCONFIGIMPORTFROMTT),
                choices = rChat.getPlayerNames(),
                --choicesValues = rData.chatConfSyncChoices,
                width = "full",
                getFunc = function() return GetUnitName("player") end,
                setFunc = function(choice)
                    SyncChatConfig(true, choice)
					--db.chatConfSync[GetUnitName("player")] = GetUnitName("player")
                end,
            },
        },
    }
end

local function chatWindowSettings()
    local db = rChat.save
    return {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_APPEARANCEMH),
        controls = {
            {-- Chat Window Transparency
                type = "slider",
                name = L(RCHAT_WINDOWDARKNESS),
                tooltip = L(RCHAT_WINDOWDARKNESSTT),
                min = 1,
                max = 11,
                step = 1,
                getFunc = function() return db.windowDarkness end,
                setFunc = function(newValue)
                    db.windowDarkness = newValue
                    rChat.ChangeChatWindowDarkness(true)
                    CHAT_SYSTEM:Maximize()
                end,
                width = "full",
                default = rChat.defaults.windowDarkness,
            },
            {-- Prevent Chat Fading
                type = "checkbox",
                name = L(RCHAT_PREVENTCHATTEXTFADING),
                tooltip = L(RCHAT_PREVENTCHATTEXTFADINGTT),
                getFunc = function() return db.alwaysShowChat end,
                setFunc = function(newValue) db.alwaysShowChat = newValue end,
                width = "full",
                default = rChat.defaults.alwaysShowChat,
            },
            {-- Augment lines of chat
                type = "checkbox",
                name = L(RCHAT_AUGMENTHISTORYBUFFER),
                tooltip = L(RCHAT_AUGMENTHISTORYBUFFERTT),
                getFunc = function() return db.augmentHistoryBuffer end,
                setFunc = function(newValue) db.augmentHistoryBuffer = newValue end,
                width = "full",
                default = rChat.defaults.augmentHistoryBuffer,
            },
            {-- Use one color for lines
                type = "checkbox",
                name = L(RCHAT_USEONECOLORFORLINES),
                tooltip = L(RCHAT_USEONECOLORFORLINESTT),
                getFunc = function() return db.oneColour end,
                setFunc = function(newValue) db.oneColour = newValue end,
                width = "full",
                default = rChat.defaults.oneColour,
            },
            {-- Minimize at launch
                type = "checkbox",
                name = L(RCHAT_CHATMINIMIZEDATLAUNCH),
                tooltip = L(RCHAT_CHATMINIMIZEDATLAUNCHTT),
                getFunc = function() return db.chatMinimizedAtLaunch end,
                setFunc = function(newValue) db.chatMinimizedAtLaunch = newValue end,
                width = "full",
                default = rChat.defaults.chatMinimizedAtLaunch,
            },
            {-- Minimize Menus
                type = "checkbox",
                name = L(RCHAT_CHATMINIMIZEDINMENUS),
                tooltip = L(RCHAT_CHATMINIMIZEDINMENUSTT),
                getFunc = function() return db.chatMinimizedInMenus end,
                setFunc = function(newValue) db.chatMinimizedInMenus = newValue end,
                width = "full",
                default = rChat.defaults.chatMinimizedInMenus,
            },
            { -- Maximize After Menus
                type = "checkbox",
                name = L(RCHAT_CHATMAXIMIZEDAFTERMENUS),
                tooltip = L(RCHAT_CHATMAXIMIZEDAFTERMENUSTT),
                getFunc = function() return db.chatMaximizedAfterMenus end,
                setFunc = function(newValue) db.chatMaximizedAfterMenus = newValue end,
                width = "full",
                default = rChat.defaults.chatMaximizedAfterMenus,
            },
            { -- Fonts
                type = "dropdown",
                name = L(RCHAT_FONTCHANGE),
                tooltip = L(RCHAT_FONTCHANGETT),
                choices = LMP:List("font"),
                width = "full",
                getFunc = function() return db.fonts end,
                setFunc = function(choice)
                    db.fonts = choice
                    rChat.ChangeChatFont(true)
                    ReloadUI()
                end,
                default = rChat.defaults.fontChange,
                warning = "ReloadUI",
            },
            {-- Copy Chat
                type = "checkbox",
                name = L(RCHAT_ENABLECOPY),
                tooltip = L(RCHAT_ENABLECOPYTT),
                getFunc = function() return db.enablecopy end,
                setFunc = function(newValue) db.enablecopy = newValue end,
                width = "full",
                default = rChat.defaults.enablecopy,
            },--
            {-- Announce Zone
                type = "checkbox",
                name = L(RCHAT_ANNOUNCE_ZONE),
                tooltip = L(RCHAT_ANNOUNCE_ZONETT),
                getFunc = function() return db.announce_zone end,
                setFunc = function(newValue) db.announce_zone = newValue end,
                width = "full",
                default = rChat.defaults.announce_zone,
            },--
            --[[
            {-- LibDebugLogger
                type = "checkbox",
                name = L(RCHAT_DISABLELOGGER),
                tooltip = L(RCHAT_DISABLELOGGERTT),
                requiresReload = true,
                warning = "ReloadUI",
                getFunc = function() return db.disableDebugLoggerBlocking end,
                setFunc = function(newValue) 
                    db.disableDebugLoggerBlocking = newValue 
                    if LibDebugLogger then
                        LibDebugLogger:SetBlockChatOutputEnabled(newValue)
                    end
                    ReloadUI()
                end,
                width = "full",
                default = rChat.defaults.disableDebugLoggerBlocking,
                disable = (not LibDebugLogger),
            },--]]
        },
    }
end

local function whispers()
    local db = rChat.save
    return {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_IMH),
        controls = {
			{
				type = "checkbox",
				name = GetString(RCHAT_WHISPSOUND_ENABLED),
				getFunc = function() return db.whisper.soundEnabled end,
				setFunc = function(value) db.whisper.soundEnabled = value end,
				--disabled = function() return not db.whisper.soundEnabled end,
				width = "half",
			},
            {-- Whispers: Sound
                type = "slider",
                name = L(RCHAT_SOUNDFORINCWHISPS),
                tooltip = L(RCHAT_SOUNDFORINCWHISPSTT),
                min = 1, max = SF.numSounds(), step = 1,
                getFunc = function()
                    if type(db.whisper.incomingsound) == "string" then
                        return SF.getSoundIndex(db.whisper.incomingsound)
                    end
                    return SF.getSoundIndex(db.whisper.incomingsound)
                end,
                setFunc = function(value)
                    db.whisper.incomingsound = SF.getSound(value)
                    local descCtrl = WINDOW_MANAGER:GetControlByName("RCHAT_WHISP_SOUND")
                    if descCtrl ~= nil then
                        descCtrl.data.text = SF.colors.normal:Colorize(db.whisper.incomingsound)
                    end
                    SF.PlaySound(db.whisper.incomingsound)
                end,
                width = "half",
                default = rChat.defaults.whisper.incomingsound,
            },
            {
                type = "description",
                title = L(RCHAT_SOUND_NAME),
                reference = "RCHAT_WHISP_SOUND",
                --text = SF.colors.normal:Colorize(db.whisper.incomingsound),
                text = db.whisper.incomingsound,
            },
            {-- Whisper: Visual Notification
                type = "checkbox",
                name = L(RCHAT_NOTIFYIM),
                tooltip = L(RCHAT_NOTIFYIMTT),
                getFunc = function() return db.whisper.notifyIM end,
                setFunc = function(newValue) db.whisper.notifyIM = newValue end,
                width = "full",
                default = rChat.defaults.whisper.notifyIM,
            },
        },
    }

end

local function restoreChat()
    local db = rChat.save
    return     {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_RESTORECHATH),
        controls = {
            {-- Restore: After ReloadUI
                type = "checkbox",
                name = L(RCHAT_RESTOREONRELOADUI),
                tooltip = L(RCHAT_RESTOREONRELOADUITT),
                getFunc = function() return db.restoreOnReloadUI end,
                setFunc = function(newValue) db.restoreOnReloadUI = newValue end,
                width = "half",
                default = rChat.defaults.restoreOnReloadUI,
            },
            {-- Restore: Kicked
                type = "checkbox",
                name = L(RCHAT_RESTOREONAFK),
                tooltip = L(RCHAT_RESTOREONAFKTT),
                getFunc = function() return db.restoreOnAFK end,
                setFunc = function(newValue) db.restoreOnAFK = newValue end,
                width = "half",
                default = rChat.defaults.restoreOnAFK,
            },
            {-- Restore: Logout
                type = "checkbox",
                name = L(RCHAT_RESTOREONLOGOUT),
                tooltip = L(RCHAT_RESTOREONLOGOUTTT),
                getFunc = function() return db.restoreOnLogOut end,
                setFunc = function(newValue) db.restoreOnLogOut = newValue end,
                width = "half",
                default = rChat.defaults.restoreOnLogOut,
            },
            {-- Restore: Leave
                type = "checkbox",
                name = L(RCHAT_RESTOREONQUIT),
                tooltip = L(RCHAT_RESTOREONQUITTT),
                getFunc = function() return db.restoreOnQuit end,
                setFunc = function(newValue) db.restoreOnQuit = newValue end,
                width = "half",
                default = rChat.defaults.restoreOnQuit,
            },
            {-- Restore: Hours
                type = "slider",
                name = L(RCHAT_TIMEBEFORERESTORE),
                tooltip = L(RCHAT_TIMEBEFORERESTORETT),
                min = 1,
                max = 24,
                step = 1,
                getFunc = function() return db.timeBeforeRestore end,
                setFunc = function(newValue) db.timeBeforeRestore = newValue end,
                width = "full",
                default = rChat.defaults.timeBeforeRestore,
            },
            {-- Restore: System Messages
                type = "checkbox",
                name = L(RCHAT_RESTORESYSTEM),
                tooltip = L(RCHAT_RESTORESYSTEMTT),
                getFunc = function() return db.restoreSystem end,
                setFunc = function(newValue) db.restoreSystem = newValue end,
                width = "full",
                default = rChat.defaults.restoreSystem,
            },
            {-- Restore: System Only Messages
                type = "checkbox",
                name = L(RCHAT_RESTORESYSTEMONLY),
                tooltip = L(RCHAT_RESTORESYSTEMONLYTT),
                getFunc = function() return db.restoreSystemOnly end,
                setFunc = function(newValue) db.restoreSystemOnly = newValue end,
                width = "full",
                default = rChat.defaults.restoreSystemOnly,
            },
            {-- Restore: Whispers
                type = "checkbox",
                name = L(RCHAT_RESTOREWHISPS),
                tooltip = L(RCHAT_RESTOREWHISPSTT),
                getFunc = function() return db.restoreWhisps end,
                setFunc = function(newValue) db.restoreWhisps = newValue end,
                width = "full",
                default = rChat.defaults.restoreWhisps,
            },
            {-- Restore: Text entry history
                type = "checkbox",
                name = L(RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT),
                tooltip = L(RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT),
                getFunc = function() return db.restoreTextEntryHistoryAtLogOutQuit end,
                setFunc = function(newValue) db.restoreTextEntryHistoryAtLogOutQuit = newValue end,
                width = "full",
                default = rChat.defaults.restoreTextEntryHistoryAtLogOutQuit,
            },
			{-- Restore: Clear chat history Button
				type = "button",
				name = L(RCHAT_CLEARCACHE),
				tooltip = L(RCHAT_CLEARCACHE_TT),
				func = function()
					rChatData.clearCache()
					rChat.ClearChat()
				end,
				width = "half",
				isDangerous = true,
			}
        },
    }
end

local function antispam()
    local db = rChat.save
    local spam = db.spam

    return {
        type = "submenu",
        name = SF.colors.bronze:Colorize(RCHAT_ANTISPAMH),
        controls = {
            {-- flood protect
                type = "checkbox",
                name = L(RCHAT_FLOODPROTECT),
                tooltip = L(RCHAT_FLOODPROTECTTT),
                getFunc = function() return spam.floodProtect end,
                setFunc = function(newValue) spam.floodProtect = newValue end,
                width = "full",
                default = rChat.defaults.floodProtect,
            }, --Anti spam  grace period
            {
                type = "slider",
                name = L(RCHAT_FLOODGRACEPERIOD),
                tooltip = L(RCHAT_FLOODGRACEPERIODTT),
                min = 0,
                max = 180,
                step = 1,
                getFunc = function() return spam.floodGracePeriod end,
                setFunc = function(newValue) spam.floodGracePeriod = newValue end,
                width = "full",
                default = rChat.defaults.floodGracePeriod,
                disabled = function() return not spam.floodProtect end,
            },
            {
                type = "checkbox",
                name = L(RCHAT_LOOKINGFORPROTECT),
                tooltip = L(RCHAT_LOOKINGFORPROTECTTT),
                getFunc = function() return spam.lookingForProtect end,
                setFunc = function(newValue) spam.lookingForProtect = newValue end,
                width = "full",
                default = rChat.defaults.lookingForProtect,
            },
            {
				type = "checkbox",
                name = L(RCHAT_WANTTOPROTECT),
                tooltip = L(RCHAT_WANTTOPROTECTTT),
                getFunc = function() return spam.wantToProtect end,
                setFunc = function(newValue) spam.wantToProtect = newValue end,
                width = "full",
                default = rChat.defaults.wantToProtect,
            },
			{
				type = "checkbox",
                name = L(RCHAT_PRICEPROTECT),
                tooltip = L(RCHAT_PRICEPROTECTTT),
                getFunc = function() return spam.priceCheckProtect end,
                setFunc = function(newValue) spam.priceCheckProtect = newValue end,
                width = "full",
                default = rChat.defaults.priceCheckProtect,
            },
            {
				type = "checkbox",
                name = L(RCHAT_GUILDPROTECT),
                tooltip = L(RCHAT_GUILDPROTECTTT),
                getFunc = function() return spam.guildProtect end,
                setFunc = function(newValue) spam.guildProtect = newValue end,
                width = "full",
                default = rChat.defaults.guildProtect,
            },
            {
                type = "slider",
                name = L(RCHAT_SPAMGRACEPERIOD),
                tooltip = L(RCHAT_SPAMGRACEPERIODTT),
                min = 0,
                max = 10,
                step = 1,
                getFunc = function() return spam.spamGracePeriod end,
                setFunc = function(newValue) spam.spamGracePeriod = newValue end,
                width = "full",
                default = rChat.defaults.spam.spamGracePeriod,
            },
        },
    }
end

local function isDisabled_NPCColors()
    local db = rChat.save
    if db.useESOcolors then
        return true
    else
        return db.allNPCSameColour
    end
end

local function isDisabled_ZoneColors()
    local db = rChat.save
    if db.useESOcolors then
        return true
    else
        return db.allZonesSameColour
    end
end

local function chatColors()
    local db = rChat.save
    return     {
        type = "submenu",
        name = SF.GetIconized(RCHAT_COLORSH, SF.hex.bronze),
        controls = {
            {-- Use ESO Colors
                type = "checkbox",
                name = L(RCHAT_USEESOCOLORS),
                tooltip = L(RCHAT_USEESOCOLORSTT),
                getFunc = function() return db.useESOcolors end,
                setFunc = function(newValue) db.useESOcolors = newValue end,
                width = "half",
                default = rChat.defaults.useESOcolors,
            },
            {-- Difference Between ESO Colors
                type = "slider",
                name = L(RCHAT_DIFFFORESOCOLORS),
                tooltip = L(RCHAT_DIFFFORESOCOLORSTT),
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return db.diffforESOcolors end,
                setFunc = function(newValue) db.diffforESOcolors = newValue end,
                width = "half",
                default = rChat.defaults.diffforESOcolors,
                disabled = function() return not db.useESOcolors end,
            },
            {
                type = "header",
                name = SF.colors.superior:Colorize(RCHAT_CHATCOLORSH),
                width = "full",
            },
            {
                type = "description",
                text = RCHAT_CHATCOLORTT,
            },
            {-- Say players left
                type = "colorpicker",
                name = L(RCHAT_SAY),
                tooltip = L(RCHAT_SAYTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_SAY) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_SAY, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_SAY),
                disabled = function() return db.useESOcolors end,
            },
            {-- Say players right
                type = "colorpicker",
                name = L(RCHAT_SAYCHAT),
                tooltip = L(RCHAT_SAYCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_SAY) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_SAY, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_SAY),
                disabled = function() return db.useESOcolors end,
            },
            {-- Zone Player left
                type = "colorpicker",
                name = L(RCHAT_ZONE),
                tooltip = L(RCHAT_ZONETT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_ZONE),
                disabled = function() return db.useESOcolors end,
            },
            {-- Zone Player right
                type = "colorpicker",
                name = L(RCHAT_ZONECHAT),
                tooltip = L(RCHAT_ZONECHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_ZONE),
                disabled = function() return db.useESOcolors end,
            },
            {-- Yell Player left
                type = "colorpicker",
                name = L(RCHAT_YELL),
                tooltip = L(RCHAT_YELLTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_YELL) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_YELL, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_YELL),
                disabled = function() return db.useESOcolors end,
            },
            {-- Yell Player right
                type = "colorpicker",
                name = L(RCHAT_YELLCHAT),
                tooltip = L(RCHAT_YELLCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_YELL) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_YELL, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_YELL),
                disabled = function() return db.useESOcolors end,
            },
            {-- Whisper Incoming left
                type = "colorpicker",
                name = L(RCHAT_INCOMINGWHISPERS),
                tooltip = L(RCHAT_INCOMINGWHISPERSTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_WHISPER) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_WHISPER, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_WHISPER),
                disabled = function() return db.useESOcolors end,
            },
            {-- Whisper Incoming right
                type = "colorpicker",
                name = L(RCHAT_INCOMINGWHISPERSCHAT),
                tooltip = L(RCHAT_INCOMINGWHISPERSCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_WHISPER) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_WHISPER, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_WHISPER),
                disabled = function() return db.useESOcolors end,
            },
            {-- Whisper Outgoing left
                type = "colorpicker",
                name = L(RCHAT_OUTGOINGWHISPERS),
                tooltip = L(RCHAT_OUTGOINGWHISPERSTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_WHISPER_SENT) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_WHISPER_SENT, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_WHISPER_SENT),
                disabled = function() return db.useESOcolors end,
            },
            {-- Whisper Outgoing right
                type = "colorpicker",
                name = L(RCHAT_OUTGOINGWHISPERSCHAT),
                tooltip = L(RCHAT_OUTGOINGWHISPERSCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_WHISPER_SENT) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_WHISPER_SENT, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_WHISPER_SENT),
                disabled = function() return db.useESOcolors end,
            },
            {-- Group left
                type = "colorpicker",
                name = L(RCHAT_GROUP),
                tooltip = L(RCHAT_GROUPTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_PARTY) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_PARTY, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_PARTY),
                disabled = function() return db.useESOcolors end,
            },
            {-- Group right
                type = "colorpicker",
                name = L(RCHAT_GROURCHAT),
                tooltip = L(RCHAT_GROURCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_PARTY) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_PARTY, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_PARTY),
                disabled = function() return db.useESOcolors end,
            },
            {
                type = "header",
                name = SF.colors.superior:Colorize(RCHAT_OTHERCOLORSH),
                width = "full",
            },
            {
                type = "description",
                text = RCHAT_OTHERCOLORTT,
            },
            {-- Emote left
                type = "colorpicker",
                name = L(RCHAT_EMOTES),
                tooltip = L(RCHAT_EMOTESTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_EMOTE) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_EMOTE, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_EMOTE),
                disabled = function() return db.useESOcolors end,
            },
            {-- Emote right
                type = "colorpicker",
                name = L(RCHAT_EMOTESCHAT),
                tooltip = L(RCHAT_EMOTESCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_EMOTE) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_EMOTE, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_EMOTE),
                disabled = function() return db.useESOcolors end,
            },
            {
                type = "header",
                name = SF.colors.superior:Colorize(RCHAT_NPC),
                width = "full",
            },
            {-- NPC Say left
                type = "colorpicker",
                name = L(RCHAT_NPCSAY),
                tooltip = L(RCHAT_NPCSAYTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_MONSTER_SAY) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_MONSTER_SAY, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_MONSTER_SAY),
                disabled = function() return db.useESOcolors end,
            },
            {-- NPC Say right
                type = "colorpicker",
                name = L(RCHAT_NPCSAYCHAT),
                tooltip = L(RCHAT_NPCSAYCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_MONSTER_SAY) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_MONSTER_SAY, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_MONSTER_SAY),
                disabled = function() return db.useESOcolors end,
            },
            {-- Use same color for all NPC
                type = "checkbox",
                name = L(RCHAT_ALLNPCSAMECOLOUR),
                tooltip = L(RCHAT_ALLNPCSAMECOLOURTT),
                getFunc = function() return db.allNPCSameColour end,
                setFunc = function(newValue) db.allNPCSameColour = newValue end,
                width = "full",
                default = rChat.defaults.allNPCSameColour,
            },
            {-- NPC Yell left
                type = "colorpicker",
                name = L(RCHAT_NPCYELL),
                tooltip = L(RCHAT_NPCYELLTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_MONSTER_YELL) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_MONSTER_YELL, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_MONSTER_YELL),
                disabled = function() return isDisabled_NPCColors() end,
            },
            {-- NPC Yell right
                type = "colorpicker",
                name = L(RCHAT_NPCYELLCHAT),
                tooltip = L(RCHAT_NPCYELLCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_MONSTER_YELL) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_MONSTER_YELL, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_MONSTER_YELL),
                disabled = isDisabled_NPCColors,
            },
            {-- NPC Whisper left
                type = "colorpicker",
                name = L(RCHAT_NPCWHISPER),
                tooltip = L(RCHAT_NPCWHISPERTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_MONSTER_WHISPER) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_MONSTER_WHISPER, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_MONSTER_WHISPER),
                disabled = isDisabled_NPCColors,
            },
            {-- NPC Whisper right
                type = "colorpicker",
                name = L(RCHAT_NPCWHISPERCHAT),
                tooltip = L(RCHAT_NPCWHISPERCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_MONSTER_WHISPER) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_MONSTER_WHISPER, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_MONSTER_WHISPER),
                disabled = isDisabled_NPCColors,
            },
            {-- NPC Emote left
                type = "colorpicker",
                name = L(RCHAT_NPCEMOTES),
                tooltip = L(RCHAT_NPCEMOTESTT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_MONSTER_EMOTE) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_MONSTER_EMOTE, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_MONSTER_EMOTE),
                disabled = isDisabled_NPCColors,
            },
            {-- NPC Emote right
                type = "colorpicker",
                name = L(RCHAT_NPCEMOTESCHAT),
                tooltip = L(RCHAT_NPCEMOTESCHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_MONSTER_EMOTE) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_MONSTER_EMOTE, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_MONSTER_EMOTE),
                disabled = isDisabled_NPCColors,
            },
            {
                type = "header",
                name = SF.colors.superior:Colorize(RCHAT_LANGZONEH),
                width = "full",
            },
            {-- LAM Option Use same color for all zone chats
                type = "checkbox",
                name = L(RCHAT_ALLZONESSAMECOLOUR),
                tooltip = L(RCHAT_ALLZONESSAMECOLOURTT),
                getFunc = function() return db.allZonesSameColour end,
                setFunc = function(newValue) db.allZonesSameColour = newValue end,
                width = "full",
                default = rChat.defaults.allZonesSameColour,
            },
            {-- Zone English left
                type = "colorpicker",
                name = L(RCHAT_ENZONE),
                tooltip = L(RCHAT_ENZONETT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_1) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE_LANGUAGE_1, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_1),
                disabled = isDisabled_ZoneColors,
            },
            {-- Zone English right
                type = "colorpicker",
                name = L(RCHAT_ENZONECHAT),
                tooltip = L(RCHAT_ENZONECHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_1) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE_LANGUAGE_1, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_1),
                disabled = isDisabled_ZoneColors,
            },
            {-- Zone French left
                type = "colorpicker",
                name = L(RCHAT_FRZONE),
                tooltip = L(RCHAT_FRZONETT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_2) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE_LANGUAGE_2, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_2),
                disabled = isDisabled_ZoneColors,
            },
            {-- Zone French right
                type = "colorpicker",
                name = L(RCHAT_FRZONECHAT),
                tooltip = L(RCHAT_FRZONECHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_2) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE_LANGUAGE_2, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_2),
                disabled = isDisabled_ZoneColors,
            },
            {-- Zone German left
                type = "colorpicker",
                name = L(RCHAT_DEZONE),
                tooltip = L(RCHAT_DEZONETT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_3) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE_LANGUAGE_3, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_3),
                disabled = isDisabled_ZoneColors,
            },
            {-- Zone German right
                type = "colorpicker",
                name = L(RCHAT_DEZONECHAT),
                tooltip = L(RCHAT_DEZONECHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_3) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE_LANGUAGE_3, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_3),
                disabled = isDisabled_ZoneColors,
            },
            {-- Zone Japanese left
                type = "colorpicker",
                name = L(RCHAT_JPZONE),
                tooltip = L(RCHAT_JPZONETT),
                width = "half",
                getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_4) end,
                setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE_LANGUAGE_4, r, g, b) end,
                default = getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_4),
                disabled = isDisabled_ZoneColors,
            },
            {-- Zone Japanese right
                type = "colorpicker",
                name = L(RCHAT_JPZONECHAT),
                tooltip = L(RCHAT_JPZONECHATTT),
                width = "half",
                getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_4) end,
                setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE_LANGUAGE_4, r, g, b) end,
                default = getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_4),
                disabled = isDisabled_ZoneColors,
            },
    {-- Zone Russian left
            type = "colorpicker",
            name = L(RCHAT_RUZONE),
            tooltip = L(RCHAT_RUZONETT),
            width = "half",
            getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_5) end,
            setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE_LANGUAGE_5, r, g, b) end,
            default = getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_5),
            disabled = isDisabled_ZoneColors,
        },
        {-- Zone Russian right
            type = "colorpicker",
            name = L(RCHAT_RUZONECHAT),
            tooltip = L(RCHAT_RUZONECHATTT),
            width = "half",
            getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_5) end,
            setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE_LANGUAGE_5, r, g, b) end,
            default = getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_5),
            disabled = isDisabled_ZoneColors,
        },
    {-- Zone Spanish left
            type = "colorpicker",
            name = L(RCHAT_ESZONE),
            tooltip = L(RCHAT_ESZONETT),
            width = "half",
            getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_6) end,
            setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE_LANGUAGE_6, r, g, b) end,
            default = getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_6),
            disabled = isDisabled_ZoneColors,
        },
        {-- Zone Spanish right
            type = "colorpicker",
            name = L(RCHAT_ESZONECHAT),
            tooltip = L(RCHAT_ESZONECHATTT),
            width = "half",
            getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_6) end,
            setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE_LANGUAGE_6, r, g, b) end,
            default = getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_6),
            disabled = isDisabled_ZoneColors,
        },
    {-- Zone Simplified Chinese left
            type = "colorpicker",
            name = L(RCHAT_ZHZONE),
            tooltip = L(RCHAT_ZHZONETT),
            width = "half",
            getFunc = function() return getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_7) end,
            setFunc = function(r, g, b) rChat.setLeftColor(CHAT_CHANNEL_ZONE_LANGUAGE_7, r, g, b) end,
            default = getLeftColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_7),
            disabled = isDisabled_ZoneColors,
        },
        {-- Zone Simplified Chinese right
            type = "colorpicker",
            name = L(RCHAT_ZHZONECHAT),
            tooltip = L(RCHAT_ZHZONECHATTT),
            width = "half",
            getFunc = function() return getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_7) end,
            setFunc = function(r, g, b) rChat.setRightColor(CHAT_CHANNEL_ZONE_LANGUAGE_7, r, g, b) end,
            default = getRightColorRGB(CHAT_CHANNEL_ZONE_LANGUAGE_7),
            disabled = isDisabled_ZoneColors,
        },
    },
    }
end

local function guildSettings()
    local db = rChat.save
    return {
        type = "submenu",
        name = SF.GetIconized(RCHAT_GUILDOPT, SF.hex.bronze),
        controls = {
            {-- Show Guild Numbers
                type = "checkbox",
                name = L(RCHAT_GUILDNUMBERS),
                tooltip = L(RCHAT_GUILDNUMBERSTT),
                getFunc = function() return db.showGuildNumbers end,
                setFunc = function(newValue)
                    db.showGuildNumbers = newValue
                end,
                width = "half",
                default = rChat.defaults.showGuildNumbers,
            },
            {-- Use Same Color for all Guilds
                type = "checkbox",
                name = L(RCHAT_ALLGUILDSSAMECOLOUR),
                tooltip = L(RCHAT_ALLGUILDSSAMECOLOURTT),
                getFunc = function() return db.allGuildsSameColour end,
                setFunc = function(newValue)
                        db.allGuildsSameColour = newValue
                    end,
                width = "half",
                default = rChat.defaults.allGuildsSameColour,
            },
        }
    }
end

-- Build LAM Option Table, used when AddonLoads or when a player join/leave a guild
function rChat.BuildLAMPanel()

	-- aliases/derefs
	local db = rChat.save
	local spam = db.spam
	local mention = db.mention

    -- Used to reset colors to default value, lam need a formatted array
    -- LAM Message Settings
    local localPlayer = GetUnitName("player")
    local fontsDefined = LMP:List('font')

	-- Sync Character Select
	SyncCharacterSelectChoices()

    -- CHAT_SYSTEM.primaryContainer.windows doesn't exists yet at OnAddonLoaded. So using the rChat reference.
    local arrayTab = {}
    if db.chatConfSync and db.chatConfSync[localPlayer] and db.chatConfSync[localPlayer].tabs then
        for numTab, data in pairs (db.chatConfSync[localPlayer].tabs) do
            table.insert(arrayTab, numTab)
        end
    else
        table.insert(arrayTab, 1)
    end


    rChat.tabNames:Refresh()

    local optionsData = {}
    local defaults = rChat.defaults

    -- Messages Settings
    optionsData[#optionsData + 1] = messageSettings()  

    -- Chat Tabs
    optionsData[#optionsData + 1] = chatTabSettings()

    -- Group Submenu
    optionsData[#optionsData + 1] = groupChannelTweaks() 

    -- Sync Settings Header
    optionsData[#optionsData + 1] = syncingSettings()

    -- Window Appearance
    optionsData[#optionsData + 1] = chatWindowSettings()

    -- Whispers
    optionsData[#optionsData + 1] = whispers()

    -- Restore Chat
    optionsData[#optionsData + 1] = restoreChat()

    -- Anti Spam
    optionsData[#optionsData + 1] = antispam()

    -- Chat Colors
    optionsData[#optionsData + 1] = chatColors()

    -- Guilds

    --  Guild Stuff
    local function isDisabled_GuildColors(guild)
        if db.useESOcolors then return true end
        if guild ~= 1 then
            return db.allGuildsSameColour
        end
        return false
    end	
    --
    local guildOptionsData = guildSettings()

    for guild = 1, GetNumGuilds() do

        -- Guildname
        local guildName, guildId = SF.SafeGetGuildName(guild)

        -- If recently added to a new guild and never go in menu db.formatguild[guildName] won't exist
        if not (db.formatguild[guildName]) then
            -- 2 is default value
            db.formatguild[guildName] = 2
        end
        guildOptionsData.controls[#guildOptionsData.controls + 1] = {
        type = "submenu",
        name = guildName,
        controls = {
            {
                type = "editbox",
                name = L(RCHAT_NICKNAMEFOR),
                tooltip = L(RCHAT_NICKNAMEFORTT) .. " " .. guildName,
                getFunc = function() return db.guildTags[guildName] end,
                setFunc = function(newValue)
                    db.guildTags[guildName] = newValue
                    rChat.UpdateGuildChannelNames()
                end,
                width = "full",
                default = "",
            },
            {
                type = "editbox",
                name = L(RCHAT_OFFICERTAG),
                tooltip = L(RCHAT_OFFICERTAGTT),
                width = "full",
                default = "",
                getFunc = function() return db.officertag[guildName] end,
                setFunc = function(newValue)
                    db.officertag[guildName] = newValue
                    rChat.UpdateGuildChannelNames()
                end
            },
            {
                type = "editbox",
                name = L(RCHAT_SWITCHFOR),
                tooltip = L(RCHAT_SWITCHFORTT),
                getFunc = function() return db.switchFor[guildName] end,
                setFunc = function(newValue)
                    db.switchFor[guildName] = newValue
                    rChat.UpdateGuildSwitches()
                    ZOS_CreateChannelData()
                end,
                width = "full",
                default = "",
            },
            {
                type = "editbox",
                name = L(RCHAT_OFFICERSWITCHFOR),
                tooltip = L(RCHAT_OFFICERSWITCHFORTT),
                width = "full",
                default = "",
                getFunc = function() return db.officerSwitchFor[guildName] end,
                setFunc = function(newValue)
                    db.officerSwitchFor[guildName] = newValue
                    rChat.UpdateGuildSwitches()
                    ZOS_CreateChannelData()
                end
            },
            -- Name Format
            {
                type = "dropdown",
                name = L(RCHAT_NAMEFORMAT),
                tooltip = L(RCHAT_NAMEFORMATTT),
                choices = {L(RCHAT_FORMATCHOICE1), L(RCHAT_FORMATCHOICE2), L(RCHAT_FORMATCHOICE3), L(RCHAT_FORMATCHOICE4), L(RCHAT_FORMATCHOICE5)},
                getFunc = function()
                    -- Config per guild
                    if db.formatguild[guildName] == 1 then
                        return L(RCHAT_FORMATCHOICE1)
                    elseif db.formatguild[guildName] == 2 then
                        return L(RCHAT_FORMATCHOICE2)
                    elseif db.formatguild[guildName] == 3 then
                        return L(RCHAT_FORMATCHOICE3)
                    elseif db.formatguild[guildName] == 4 then
                        return L(RCHAT_FORMATCHOICE4)
                    elseif db.formatguild[guildName] == 5 then
                        return L(RCHAT_FORMATCHOICE5)
                    else
                        -- When user click on LAM reinit button
                        return L(RCHAT_FORMATCHOICE2)
                    end
                end,
                setFunc = function(choice)
                    if choice == L(RCHAT_FORMATCHOICE1) then
                        db.formatguild[guildName] = 1
                    elseif choice == L(RCHAT_FORMATCHOICE2) then
                        db.formatguild[guildName] = 2
                    elseif choice == L(RCHAT_FORMATCHOICE3) then
                        db.formatguild[guildName] = 3
                    elseif choice == L(RCHAT_FORMATCHOICE4) then
                        db.formatguild[guildName] = 4
                    elseif choice == L(RCHAT_FORMATCHOICE5) then
                        db.formatguild[guildName] = 5
                    else
                        -- When user click on LAM reinit button
                        db.formatguild[guildName] = 2
                    end
                end,
                width = "full",
                default = rChat.defaults.formatguild[0],
            },
            {-- guild left
                type = "colorpicker",
                name = zo_strformat(RCHAT_MEMBERS, guildName),
                tooltip = zo_strformat(RCHAT_SETCOLORSFORTT, guildName),
                getFunc = function() return getLeftColorRGB(rChat.GetGuildChannel(guild)) end,
                setFunc = function(r, g, b) rChat.setLeftColor(rChat.GetGuildChannel(guild), r, g, b) end,
                default = getLeftColorRGB(rChat.GetGuildChannel(guild)),
                disabled = function() return isDisabled_GuildColors(guild) end,
            },
            {-- guild right
                type = "colorpicker",
                name = zo_strformat(RCHAT_CHAT, guildName),
                tooltip = zo_strformat(RCHAT_SETCOLORSFORCHATTT, guildName),
                getFunc = function() return getRightColorRGB(rChat.GetGuildChannel(guild)) end,
                setFunc = function(r, g, b) rChat.setRightColor(rChat.GetGuildChannel(guild), r, g, b) end,
                default = getLeftColorRGB(rChat.GetGuildChannel(guild)),
                disabled = function() return isDisabled_GuildColors(guild) end,
            },
            {-- officer left
                type = "colorpicker",
                name = zo_strformat(RCHAT_MEMBERS, guildName..L(RCHAT_OFFICERSTT)),
                tooltip = zo_strformat(RCHAT_SETCOLORSFOROFFICIERSTT, guildName),
                getFunc = function()
                    local _, ofc_channel = rChat.GetGuildChannel(guild)
                    return getLeftColorRGB(ofc_channel)
                end,
                setFunc = function(r, g, b)
                    local _, ofc_channel = rChat.GetGuildChannel(guild)
                    rChat.setLeftColor(ofc_channel, r, g, b)
                end,
                default = function()
                    local _, ofc_channel = rChat.GetGuildChannel(guild)
                    return getLeftColorRGB(ofc_channel)
                end,
                disabled = function() return isDisabled_GuildColors(guild) end,
            },
            {-- officer right
                type = "colorpicker",
                name = zo_strformat(RCHAT_CHAT, guildName..L(RCHAT_OFFICERSTT)),
                tooltip = zo_strformat(RCHAT_SETCOLORSFOROFFICIERSCHATTT, guildName),
                getFunc = function()
                    local _, ofc_channel = rChat.GetGuildChannel(guild)
                    return getRightColorRGB(ofc_channel)
                end,
                setFunc = function(r, g, b)
                    local _, ofc_channel = rChat.GetGuildChannel(guild)
                    rChat.setRightColor(ofc_channel, r, g, b)
                end,
                default = function()
                    local _, ofc_channel = rChat.GetGuildChannel(guild)
                    return getRightColorRGB(ofc_channel)
                end,
                disabled = function() return isDisabled_GuildColors(guild) end,
            },
        },
    }
    end


    optionsData[#optionsData + 1] = guildOptionsData


    LAM:RegisterOptionControls("rChatOptions", optionsData)

end

-- Initialises the settings and settings menu
function rChat.BuildLAM()

    local panelData = {
        type = "panel",
        name = rChat.name,
        displayName = rChat.settingDisplayName,
        author = rChat.author,
        version = rChat.version,
        slashCommand = "/rchat",
        registerForRefresh = true,
        registerForDefaults = true,
    }


    -- Build OptionTable. In a separate func in order to rebuild it in case of Guild Reorg.
    SyncCharacterSelectChoices()
    rChat.BuildLAMPanel()
    rData.LAMPanel = LAM:RegisterAddonPanel("rChatOptions", panelData)

end
