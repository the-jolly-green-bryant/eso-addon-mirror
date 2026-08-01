-- Registering libraries
local LAM = LibAddonMenu2
local LMP = LibMediaProvider
local SF = LibSFUtils
local RAM = rChat.AutoMsg

local L = GetString
local GetInterfaceColor = GetInterfaceColor
local GetControl = GetControl
local t_insert = table.insert
local str_sub = string.sub
local str_len = string.len

local CACHE = rChatData

local HRS_TO_SEC = 3600

-- Init
local isAddonLoaded = false -- OnAddonLoaded() done
rChat.lastwhisp = nil
local lastwhisp = rChat.lastwhisp

-- ---- Mention specific options
local defmention = {
	mentionEnabled = false,
	emoteEnabled = false,
    mentiontbl = {},
	soundEnabled = false,
	sound = SOUNDS.NEW_NOTIFICATION,
	colorEnabled = false,
	color = "|cFFFFFF",
}

-- ---- Anti Spam specific options
local defspam = {
    spamGracePeriod = 5,
    floodProtect = true,
    floodGracePeriod = 30,
    lookingForProtect = false,
    wantToProtect = false,
    guildProtect = false,
	priceCheckProtect = false,
}

local defwhisper = {
    soundEnabled = false,
    incomingsound = SOUNDS.NEW_NOTIFICATION,
    notifyIM = false,
}

local deftabs = {
    -- ---- Chat Tab Settings
    enableChatTabChannel = true,
    defaultchannel = CHAT_CHANNEL_ZONE,
    defaultTab = 1,
    defaultTabName = "",
    -- ---- Chat Tab Settings - End
}

-- Default variables to push in SavedVars
local defaults = {
	mention = defmention,
    spam = defspam,
    whisper = defwhisper,
	tabs = deftabs,

    -- ---- Message Settings
    allZonesSameColour = true,
    allNPCSameColour = true,
    nozonetags = true,
    carriageReturn = false,
    useESOcolors = true,
    diffforESOcolors = 40,
    showTagInEntry = true,
    geoChannelsFormat = 2,
    disableBrackets = true,
    addChannelAndTargetToHistory = true,
    urlHandling = true,
    nicknames = "",
	enableFriendStatus = true,
    -- ---- Message Settings - End

    -- ---- Timestamp Settings
    showTimestamp = true,
    timestampcolorislcol = false,
    timestampFormat = "HH:m",
    -- colors["timestamp"],
    -- ---- Timestamp Settings - End

    -- ---- Guild Settings
    showGuildNumbers = false,
    allGuildsSameColour = false,
    guildTags = {},
    officertag = {},
    switchFor = {},
    officerSwitchFor = {},
    formatguild = {},
    -- color[] stuff here too
    -- ---- Guild Settings - End

    -- ---- Group Settings
    enablepartyswitch = true,
    groupLeader = false,
    -- colours["groupleader"]
    -- colours["groupleader1"]
    groupNames = 1,
    -- ---- Group Settings - End

    -- ---- Chat Window Settings specific options
    windowDarkness = 6,
    alwaysShowChat = false,
    augmentHistoryBuffer = true,
    oneColour = false,
    chatMinimizedAtLaunch = false,
    chatMinimizedInMenus = false,
    chatMaximizedAfterMenus = false,
    fonts = "ESO Standard Font",
    enablecopy = true,
    -- colours["tabwarning"],
    --disableDebugLoggerBlocking = true,
	announce_zone = false,
    -- ---- Chat Window Settings specific options - End

    -- ---- Restore Options
    restoreOnReloadUI = true,
    restoreOnLogOut = true,
    restoreOnAFK = true,        -- kicked
    timeBeforeRestore = 2,
    restoreOnQuit = false,
    restoreSystem = true,
    restoreSystemOnly = false,
    restoreWhisps = true,
    restoreTextEntryHistoryAtLogOutQuit = false,
    -- ---- Restore Options - End

    -- ---- Sync Settings
    chatSyncConfig = true,
    -- localPlayer
    chatConfSync = {},  -- not LAM
    -- ---- Sync Settings - End

    -- ----
    newcolors = {
        -- player colors
        [CHAT_CHANNEL_SAY] = {"|cFFFFFF", "|cFFFFFF",},  -- say
        [CHAT_CHANNEL_YELL] = {"|cE974D8", "|cFFB5F4",},  -- yell
        [CHAT_CHANNEL_WHISPER] = {"|cB27BFF", "|cB27BFF",},  -- whisper
        [CHAT_CHANNEL_WHISPER_SENT] = {"|c7E57B5", "|c7E57B5",},  -- whisper out
        [CHAT_CHANNEL_PARTY] = {"|c6EABCA", "|cA1DAF7",},  -- group
        [CHAT_CHANNEL_EMOTE] = {"|cA5A5A5", "|cA5A5A5",},  -- emote

        -- npc colors
        [CHAT_CHANNEL_MONSTER_SAY] = {"|c879B7D", "|c879B7D",},  -- npc say
        [CHAT_CHANNEL_MONSTER_YELL] = {"|c879B7D", "|c879B7D",},  -- npc yell
        [CHAT_CHANNEL_MONSTER_WHISPER] = {"|c879B7D", "|c879B7D",},  -- npc whisper
        [CHAT_CHANNEL_MONSTER_EMOTE] = {"|c879B7D", "|c879B7D",},  -- npc emote

        -- guild colors
        [CHAT_CHANNEL_GUILD_1] = {"|c94E193", "|cC3F0C2",},  -- guild
        [CHAT_CHANNEL_GUILD_2] = {"|c94E193", "|cC3F0C2",},
        [CHAT_CHANNEL_GUILD_3] = {"|c94E193", "|cC3F0C2",},
        [CHAT_CHANNEL_GUILD_4] = {"|c94E193", "|cC3F0C2",},
        [CHAT_CHANNEL_GUILD_5] = {"|c94E193", "|cC3F0C2",},
        [CHAT_CHANNEL_OFFICER_1] = {"|cC3F0C2", "|cC3F0C2",},  -- guild officers
        [CHAT_CHANNEL_OFFICER_2] = {"|cC3F0C2", "|cC3F0C2",},
        [CHAT_CHANNEL_OFFICER_3] = {"|cC3F0C2", "|cC3F0C2",},
        [CHAT_CHANNEL_OFFICER_4] = {"|cC3F0C2", "|cC3F0C2",},
        [CHAT_CHANNEL_OFFICER_5] = {"|cC3F0C2", "|cC3F0C2",},

        -- other colors (zone)
        [CHAT_CHANNEL_ZONE] = {"|cCEB36F", "|cB0A074",},
        [CHAT_CHANNEL_ZONE_LANGUAGE_1] = {"|cCEB36F", "|cB0A074",},  -- EN zone
        [CHAT_CHANNEL_ZONE_LANGUAGE_2] = {"|cCEB36F", "|cB0A074",},  -- FR zone
        [CHAT_CHANNEL_ZONE_LANGUAGE_3] = {"|cCEB36F", "|cB0A074",},  -- DE zone
        [CHAT_CHANNEL_ZONE_LANGUAGE_4] = {"|cCEB36F", "|cB0A074",},  -- JP zone
        [CHAT_CHANNEL_ZONE_LANGUAGE_5] = {"|cCEB36F", "|cB0A074",},  -- RU zone
        [CHAT_CHANNEL_ZONE_LANGUAGE_6] = {"|cCEB36F", "|cB0A074",},  -- SP zone
        [CHAT_CHANNEL_ZONE_LANGUAGE_7] = {"|cCEB36F", "|cB0A074",},  -- ZH_Han zone
    },
    colours = {
        -- misc
        ["timestamp"] = "|c8F8F8F", -- timestamp
        ["tabwarning"] = "|c76BCC3", -- tab Warning ~ "Azure" (ZOS default)
        ["groupleader"] = "|cC35582", --
        ["groupleader1"] = "|c76BCC3", --
    },
}
rChat.defaults = defaults   -- make accessible

-- used by convertSavedColors() for saved variable color conversion 
-- between addon versions
local coloredChannels  = {
    CHAT_CATEGORY_SAY,
    CHAT_CATEGORY_YELL,
    CHAT_CATEGORY_WHISPER,
    CHAT_CATEGORY_WHISPER_SENT,
    CHAT_CATEGORY_ZONE,
    CHAT_CATEGORY_PARTY,
    CHAT_CATEGORY_EMOTE,
    CHAT_CATEGORY_SYSTEM,
    CHAT_CATEGORY_GUILD_1,
    CHAT_CATEGORY_GUILD_2,
    CHAT_CATEGORY_GUILD_3,
    CHAT_CATEGORY_GUILD_4,
    CHAT_CATEGORY_GUILD_5,
    CHAT_CATEGORY_OFFICER_1,
    CHAT_CATEGORY_OFFICER_2,
    CHAT_CATEGORY_OFFICER_3,
    CHAT_CATEGORY_OFFICER_4,
    CHAT_CATEGORY_OFFICER_5,
    CHAT_CATEGORY_ZONE_ENGLISH,     -- LANGUAGE_1
    CHAT_CATEGORY_ZONE_FRENCH,     -- LANGUAGE_2
    CHAT_CATEGORY_ZONE_GERMAN,     -- LANGUAGE_3
    CHAT_CATEGORY_ZONE_JAPANESE,     -- LANGUAGE_4
    CHAT_CATEGORY_ZONE_RUSSIAN,     -- LANGUAGE_5
    CHAT_CATEGORY_ZONE_SPANISH,     -- LANGUAGE_6
    CHAT_CATEGORY_MONSTER_SAY,
    CHAT_CATEGORY_MONSTER_YELL,
    CHAT_CATEGORY_MONSTER_WHISPER,
    CHAT_CATEGORY_MONSTER_EMOTE,
}
-- SV
local db
local targetToWhisp


-- rData will receive variables and objects.
local rData = rChat.data

-- Used for rChat LinkHandling
local RCHAT_LINK = "p"
local RCHAT_URL_CHAN = 97
local RCHAT_CHANNEL_NONE = 99

-- Save AddMessage for internal debug - AVOID DOING A CHAT_SYSTEM:AddMessage()/CHAT_ROUTER:AddSystemMessage() 
-- in rChat, it can cause recursive calls
CHAT_SYSTEM.Zo_AddMessage = CHAT_SYSTEM.AddMessage

-- used only by save and sync chat config
rData.chatCategories = {
    CHAT_CATEGORY_SAY,
    CHAT_CATEGORY_YELL,
    CHAT_CATEGORY_WHISPER_INCOMING,
    CHAT_CATEGORY_WHISPER_OUTGOING,
    CHAT_CATEGORY_ZONE,
    CHAT_CATEGORY_PARTY,
    CHAT_CATEGORY_EMOTE,
    CHAT_CATEGORY_SYSTEM,
    CHAT_CATEGORY_GUILD_1,
    CHAT_CATEGORY_GUILD_2,
    CHAT_CATEGORY_GUILD_3,
    CHAT_CATEGORY_GUILD_4,
    CHAT_CATEGORY_GUILD_5,
    CHAT_CATEGORY_OFFICER_1,
    CHAT_CATEGORY_OFFICER_2,
    CHAT_CATEGORY_OFFICER_3,
    CHAT_CATEGORY_OFFICER_4,
    CHAT_CATEGORY_OFFICER_5,
    CHAT_CATEGORY_ZONE_ENGLISH,
    CHAT_CATEGORY_ZONE_FRENCH,
    CHAT_CATEGORY_ZONE_GERMAN,
    CHAT_CATEGORY_ZONE_JAPANESE,
    CHAT_CATEGORY_ZONE_RUSSIAN,
    CHAT_CATEGORY_ZONE_SPANISH,
    CHAT_CATEGORY_MONSTER_SAY,
    CHAT_CATEGORY_MONSTER_YELL,
    CHAT_CATEGORY_MONSTER_WHISPER,
    CHAT_CATEGORY_MONSTER_EMOTE,
}

-- used only in savetabcategories
rData.guildCategories = {
    CHAT_CATEGORY_GUILD_1,
    CHAT_CATEGORY_GUILD_2,
    CHAT_CATEGORY_GUILD_3,
    CHAT_CATEGORY_GUILD_4,
    CHAT_CATEGORY_GUILD_5,
    CHAT_CATEGORY_OFFICER_1,
    CHAT_CATEGORY_OFFICER_2,
    CHAT_CATEGORY_OFFICER_3,
    CHAT_CATEGORY_OFFICER_4,
    CHAT_CATEGORY_OFFICER_5,
}

------------------------------------------------------
-- bring in/alias rChat_Internals functions
local formatLanguageTag = rChat_Internals.formatLanguageTag
local formatName        = rChat_Internals.formatName
local formatSeparator   = rChat_Internals.formatSeparator
local formatTag         = rChat_Internals.formatTag
local formatText        = rChat_Internals.formatText
local formatTimestamp   = rChat_Internals.formatTimestamp
local formatWhisperTag  = rChat_Internals.formatWhisperTag
local formatZoneTag     = rChat_Internals.formatZoneTag
local produceDisplayString = rChat_Internals.produceDisplayString
local GetChannelColors  = rChat_Internals.GetChannelColors
local GetGuildIndex     = rChat_Internals.GetGuildIndex
local initColorTable    = rChat_Internals.initColorTable
local produceCopyFrom   = rChat_Internals.produceCopyFrom
local produceRawString  = rChat_Internals.produceRawString
local reduceString      = rChat_Internals.reduceString
local UseNameFormat     = rChat_Internals.UseNameFormat
------------------------------------------------------

local MENU_CATEGORY_RCHAT = nil

-- get a color (hex) pair from the chat colors table (indexed by channel id)
function rChat.getColors(channelId)
    local colorsEntry = db.newcolors[channelId]
    if not colorsEntry then
        colorsEntry = db.newcolors[1]
    end
    return colorsEntry[1], colorsEntry[2]    -- left, right
end

function rChat.setLeftColor(channelId, r, g, b)
    local colorsEntry = db.newcolors[channelId]
    colorsEntry[1] = SF.ConvertRGBToHex(r, g, b)
    return colorsEntry[2]
end

function rChat.setRightColor(channelId, r, g, b)
    local colorsEntry = db.newcolors[channelId]
    colorsEntry[2] = SF.ConvertRGBToHex(r, g, b)
    return colorsEntry[2]
end

-- return the guild channel and guild officer channel for
-- a particular guild index
function rChat.GetGuildChannel(index)
    local mem = CHAT_CHANNEL_GUILD_1 - 1 + index
    local ofc = CHAT_CHANNEL_OFFICER_1 - 1 + index
    return mem, ofc
end

-- Strip all of the color markers out of the
-- provided text, returning what is left.
--
local function stripColours(text)
        -- get positions of all of the desired delimiters
    local t1 = SF.getAllColorDelim(text)

    if #t1 == 0 then
        -- no delimiters in string
        return text
    end

    -- remove color markers
    return SF.stripColors(t1, text)
end

-- format ESO text to raw text
-- IE : Transforms LinkHandlers into their displayed value
function rChat.FormatRawText(text)

    -- Strip colors from chat
    local newtext = stripColours(text)

    -- Transforms a LinkHandler into its localized displayed value
    -- "|H(.-):(.-)|h(.-)|h" = pattern for Linkhandlers
    -- Item : |H1:item:33753:25:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h = [Battaglir] in french -> Link to item 33753, etc
    -- Achievement |H1:achievement:33753|h|h etc (not searched a lot, was easy)
    -- DisplayName = |H1:display:Ayantir|h[@Ayantir]|h = [@Ayantir] -> link to DisplayName @Ayantir
    -- Book = |H1:book:186|h|h = [Climat de guerre] in french -> Link to book 186 .. GetLoreBookTitleFromLink()
    -- rChat = |H1:RCHAT_LINK:124:11|h[06:18]|h = [06:18] (here 124 is the line number reference and 11 is the chanCode) - URL handling : if chanCode = 97, it will popup a dialog to open internet browser
    -- Character = |H1:character:salhamandhil^Mx|h[salhamandhil]|h = text(here salhamandhil is with brackets voluntary)
    -- Quest_items = |H1:quest_item:4275|h|h

    newtext = string.gsub(newtext, "|H(.-):(.-)|h(.-)|h", function (linkStyle, data, text)
        -- linkStyle = style (0 = no brackets or 1 = brackets)
        -- data = data separated by ":"
        -- text = text displayed, used for Channels, DisplayName, Character, and some fake itemlinks (used by addons)

        -- linktype is : item, achievement, character, channel, book, display, rchatlink
        -- DOES NOT HANDLE ADDONS LINKTYPES

        -- for all types, only param1 is important
        local linkType, param1 = zo_strsplit(':', data)

        -- param1 : itemID
        -- Need to get
        if linkType == ITEM_LINK_TYPE or linkType == COLLECTIBLE_LINK_TYPE  then
            -- Fakelink and GetItemLinkName
            return "[" .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H" .. linkStyle ..":" .. data .. "|h|h")) .. "]"

        -- param1 : achievementID
        elseif linkType == ACHIEVEMENT_LINK_TYPE then
            -- zo_strformat to avoid masculine/feminine problems
            return "[" .. zo_strformat(GetAchievementInfo(param1)) .. "]"

        -- SysMessages Links CharacterNames
        elseif linkType == CHARACTER_LINK_TYPE then
            return text

        elseif linkType == CHANNEL_LINK_TYPE then
            return text

        elseif linkType == BOOK_LINK_TYPE then
            return "[" .. GetLoreBookTitleFromLink(newtext) .. "]"

        -- SysMessages Links DisplayNames
        elseif linkType == DISPLAY_NAME_LINK_TYPE then
            -- No formatting here
            return "[@" .. param1 .. "]"

        -- Used for Sysmessages
        elseif linkType == "quest_item" then
            -- No formatting here
            return "[" .. zo_strformat(SI_TOOLTIP_ITEM_NAME, GetQuestItemNameFromLink(newtext)) .. "]"

        elseif linkType == RCHAT_LINK then
            -- No formatting here .. maybe yes ?..
            return text
        end
    end)

    return newtext

end

-- ------------------------------------------------------
-- Automated Messages

-- Also called by bindings
function rChat.ShowAutoMsg()
    if RAM then
        RAM.ShowAutoMsg()

    else
        CHAT_SYSTEM.Zo_AddMessage("[rChat] Automated Message System is not enabled")
    end
end

-- Register Slash commands
SLASH_COMMANDS["/rchat.msg"] = rChat.ShowAutoMsg

local automatedMessagesList = ZO_SortFilterList:Subclass()

-- Init Automated Messages
function automatedMessagesList:Init(control)

	ZO_SortFilterList.InitializeSortFilterList(self, control)
    local SortKeys = {
        ["name"] = {},
        ["message"] = {tiebreaker = "name"}
    }

    self.masterList = {}
    ZO_ScrollList_AddDataType(self.list, 1, "rChatXMLAutoMsgRowTemplate", 
			32, function(control, data) self:SetupEntry(control, data) end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, SortKeys, self.currentSortOrder) end

    return self
end

function automatedMessagesList:SetupEntry(control, data)

    control.data = data
    control.name = GetControl(control, "Name")
    control.message = GetControl(control, "Message")

    local messageTrunc = rChat.FormatRawText(data.message)
    if str_len(messageTrunc) > 53 then
        messageTrunc = str_sub(messageTrunc, 1, 53) .. " .."
    end

    control.name:SetText(data.name)
    control.message:SetText(messageTrunc)

    ZO_SortFilterList.SetupRow(self, control, data)

end

function automatedMessagesList:BuildMasterList()
    self.masterList = {}
    local messages = db.automatedMessages
    if messages then
        for k, v in ipairs(messages) do
            local data = v
            t_insert(self.masterList, data)
        end
    end

end

function automatedMessagesList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function automatedMessagesList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for i = 1, #self.masterList do
        local data = self.masterList[i]
        t_insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end
end

function rChat.SaveAutomatedMessage(name, message, isNew)

    if db then

        local alreadyFav = false

        if isNew then
            for k, v in pairs(db.automatedMessages) do
                if "!" .. name == v.name then
                    alreadyFav = true
                end
            end
        end

        if not alreadyFav then

            rChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(true)
            rChatXMLAutoMsg:GetNamedChild("Warning"):SetText("")

            if str_len(name) > 12 then
                name = str_sub(name, 1, 12)
            end

            if str_len(message) > 350 then
                message = str_sub(message, 1, 350)
            end

            local entryList = ZO_ScrollList_GetDataList(rData.automatedMessagesList.list)

            if isNew then
                local data = {name = "!" .. name, message = message}
                local entry = ZO_ScrollList_CreateDataEntry(1, data)
                t_insert(entryList, entry)
                t_insert(db.automatedMessages, {name = "!" .. name, message = message}) -- "data" variable is modified by ZO_ScrollList_CreateDataEntry and will crash eso if saved to savedvars
            else

                local data = RAM.FindAutomatedMsg(name)
                local _, index = RAM.FindSavedAutomatedMsg(name)

                data.message = message
                db.automatedMessages[index].message = message
            end

            ZO_ScrollList_Commit(rData.automatedMessagesList.list)

        else
            rChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(false)
            rChatXMLAutoMsg:GetNamedChild("Warning"):SetText(L(RCHAT_SAVMSGERRALREADYEXISTS))
            rChatXMLAutoMsg:GetNamedChild("Warning"):SetColor(1, 0, 0)

            zo_callLater(function() rChatXMLAutoMsg:GetNamedChild("Warning"):SetHidden(true) end, 5000)

        end

    end

end

-- Init Automated messages, build the scene and handle array of automated strings
function rChat.InitAutomatedMessages()

    -- Create Scene
    RCHAT_AUTOMSG_SCENE = ZO_Scene:New("rChatAutomatedMessagesScene", SCENE_MANAGER)

    -- Mouse standard position and background
    RCHAT_AUTOMSG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    RCHAT_AUTOMSG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

    -- Background Right, it will set ZO_RightPanelFootPrint and its stuff.
    RCHAT_AUTOMSG_SCENE:AddFragment(RIGHT_BG_FRAGMENT)

    -- The title fragment
    RCHAT_AUTOMSG_SCENE:AddFragment(TITLE_FRAGMENT)

    -- Set Title
    ZO_CreateStringId("SI_RCHAT_AUTOMSG_TITLE",  rChat.name)
    RCHAT_AUTOMSG_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_RCHAT_AUTOMSG_TITLE)
    RCHAT_AUTOMSG_SCENE:AddFragment(RCHAT_AUTOMSG_TITLE_FRAGMENT)

    -- Add the XML to our scene
    RCHAT_AUTOMSG_SCENE_WINDOW = ZO_FadeSceneFragment:New(rChatXMLAutoMsg)
    RCHAT_AUTOMSG_SCENE:AddFragment(RCHAT_AUTOMSG_SCENE_WINDOW)

    -- Register Scenes and the group name
    SCENE_MANAGER:AddSceneGroup("rChatSceneGroup", ZO_SceneGroup:New("rChatAutomatedMessagesScene"))

    local autoMsgDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = L(RCHAT_AUTOMSG_ADD_AUTO_MSG),
            keybind = "UI_SHORTCUT_PRIMARY",
            control = self,
            callback = function(descriptor) ZO_Dialogs_ShowDialog("RCHAT_AUTOMSG_SAVE_MSG", nil, {mainTextParams = {functionName}}) end,
            visible = function(descriptor) return true end
        },
        {
            name = L(RCHAT_AUTOMSG_EDIT_AUTO_MSG),
            keybind = "UI_SHORTCUT_SECONDARY",
            control = self,
            callback = function(descriptor)
                    ZO_Dialogs_ShowDialog("RCHAT_AUTOMSG_EDIT_MSG", nil, {mainTextParams = {functionName}})
                end,
            visible = function(descriptor)
                if rData.autoMessagesShowKeybind then
                    return true
                else
                    return false
                end
            end
        },
        {
            name = L(RCHAT_AUTOMSG_REMOVE_AUTO_MSG),
            keybind = "UI_SHORTCUT_NEGATIVE",
            control = self,
            callback = function(descriptor) RAM.RemoveAutomatedMessage(db) end,
            visible = function(descriptor)
                if rData.autoMessagesShowKeybind then
                    return true
                else
                    return false
                end
            end
        },
    }

    local autoMessagesScene = SCENE_MANAGER:GetScene("rChatAutomatedMessagesScene")
    autoMessagesScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            KEYBIND_STRIP:AddKeybindButtonGroup(autoMsgDescriptor)
        elseif newState == SCENE_HIDDEN then
            if KEYBIND_STRIP:HasKeybindButtonGroup(autoMsgDescriptor) then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(autoMsgDescriptor)
            end
        end
    end)

    if not db.automatedMessages then
        db.automatedMessages = {}
    end

    rData.automatedMessagesList = automatedMessagesList:Init(rChatXMLAutoMsg)
    rData.automatedMessagesList:RefreshData()
    RAM.CleanAutomatedMessageList(db)


    rData.automatedMessagesList.keybindStripDescriptor = autoMsgDescriptor

end

-- Called by XML
function rChat_BuildAutomatedMessagesDialog(control, saveFunc)
    RAM.BuildAutomatedMessagesDialog(control, saveFunc)
end
-- end Automated Messages code section
-- ------------------------------------------------------

-- Change ChatWindow Darkness by modifying its <Center> & <Edge>.
-- Originally defined in virtual object ZO_ChatContainerTemplate 
-- in sharedchatsystem.xml
function rChat.ChangeChatWindowDarkness(changeSetting)

    if dbWindowDarkness == 0 then
        ZO_ChatWindowBg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
        ZO_ChatWindowBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)

    else
        ZO_ChatWindowBg:SetCenterColor(0, 0, 0, 1)
        ZO_ChatWindowBg:SetEdgeColor(0, 0, 0, 1)
        if db.windowDarkness == 11 and changeSetting then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_100.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_100.dds", 256, 256, 32)

        elseif db.windowDarkness == 10 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_90.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_90.dds", 256, 256, 32)

        elseif db.windowDarkness == 9 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_80.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_80.dds", 256, 256, 32)

        elseif db.windowDarkness == 8 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_70.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_70.dds", 256, 256, 32)

        elseif db.windowDarkness == 7 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_60.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_60.dds", 256, 256, 32)

        elseif db.windowDarkness == 6 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_50.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_50.dds", 256, 256, 32)

        elseif db.windowDarkness == 5 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_40.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_40.dds", 256, 256, 32)

        elseif db.windowDarkness == 4 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_30.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_30.dds", 256, 256, 32)

        elseif db.windowDarkness == 3 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_20.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_20.dds", 256, 256, 32)

        elseif db.windowDarkness == 2 then
            ZO_ChatWindowBg:SetCenterTexture("rChat/dds/chat_bg_center_10.dds")
            ZO_ChatWindowBg:SetEdgeTexture("rChat/dds/chat_bg_edge_10.dds", 256, 256, 32)

        elseif db.windowDarkness == 1 then
            ZO_ChatWindowBg:SetCenterColor(0, 0, 0, 0)
            ZO_ChatWindowBg:SetEdgeColor(0, 0, 0, 0)
        end
    end
end

-- ----------------------------------------------------------------
-- Whisper functions

-- Add IM label on XML Initialization, set anchor and set it hidden
function rChat_AddIMLabel(control)

    control:SetParent(CHAT_SYSTEM.control)
    control:ClearAnchors()
    control:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, -5, 32)
    CHAT_SYSTEM.IMLabel = control

end

-- Add IM label on XML Initialization, set anchor and set it hidden. Used for Chat Minibar
function rChat_AddIMLabelMin(control)

    control:SetParent(CHAT_SYSTEM.control)
    control:ClearAnchors()
    control:SetAnchor(BOTTOM, CHAT_SYSTEM.minBar.maxButton, TOP, 2, 0)
    CHAT_SYSTEM.IMLabelMin = control

end

-- Add IM close button on XML Initialization, set anchor and set it hidden
function rChat_AddIMButton(control)

    control:SetParent(CHAT_SYSTEM.control)
    control:ClearAnchors()
    control:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, 2, 35)
    CHAT_SYSTEM.IMbutton = control

end

-- Hide it
local function HideIMTooltip()
    ClearTooltip(InformationTooltip)
end

-- Show IM notification tooltip
local function ShowIMTooltip(self, lineNumber)

    local chatline = CACHE.getCacheEntry(lineNumber)
    if not chatline then return end

    local sender = chatline.rawT.from
    local text = chatline.rawT.text   --chatline.rawMessage

    if (not IsDecoratedDisplayName(sender)) then
        sender = zo_strformat(SI_UNIT_NAME, sender)
    end

    InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 0, TOPRIGHT)
    InformationTooltip:AddLine(sender, "ZoFontGame", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

    local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
    InformationTooltip:AddLine(text, "ZoFontGame", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)


end

-- When an incoming Whisper is received
local function OnIMReceived(from, lineNumber)

	if not CHAT_SYSTEM.primaryContainer then return end

    if not db.whisper.notifyIM then return end

    -- Display visual notification
    -- If chat minimized, show the minified button
    if (CHAT_SYSTEM:IsMinimized()) then
        CHAT_SYSTEM.IMLabelMin:SetHandler("OnMouseEnter", function(self) ShowIMTooltip(self, lineNumber) end)
        CHAT_SYSTEM.IMLabelMin:SetHandler("OnMouseExit", HideIMTooltip)
        CHAT_SYSTEM.IMLabelMin:SetHidden(false)
    else
        -- Chat maximized
        local _, scrollMax = CHAT_SYSTEM.primaryContainer.scrollbar:GetMinMax()

        -- If whispers not show in the tab or we don't scroll at bottom
        if ((not IsChatContainerTabCategoryEnabled(1, rData.activeTab, CHAT_CATEGORY_WHISPER_INCOMING)) or (IsChatContainerTabCategoryEnabled(1, rData.activeTab, CHAT_CATEGORY_WHISPER_INCOMING) and CHAT_SYSTEM.primaryContainer.scrollbar:GetValue() < scrollMax)) then

            -- Undecorate (^F / ^M)
            if (not IsDecoratedDisplayName(from)) then
                from = zo_strformat(SI_UNIT_NAME, from)
            end

            -- Split if name too long
            local displayedFrom = from
            if str_len(displayedFrom) > 8 then
                displayedFrom = str_sub(from, 1, 7) .. ".."
            end

            -- Show
            CHAT_SYSTEM.IMLabel:SetText(displayedFrom)
            CHAT_SYSTEM.IMLabel:SetHidden(false)
            CHAT_SYSTEM.IMbutton:SetHidden(false)

            -- Add handler
            CHAT_SYSTEM.IMLabel:SetHandler("OnMouseEnter", function(self) ShowIMTooltip(self, lineNumber) end)
            CHAT_SYSTEM.IMLabel:SetHandler("OnMouseExit", function(self) HideIMTooltip() end)
        end
    end

end

-- Hide IM notification when click on it. Can be Called by XML
function rChat_RemoveIMNotification()
    CHAT_SYSTEM.IMLabel:SetHidden(true)
    CHAT_SYSTEM.IMLabelMin:SetHidden(true)
    CHAT_SYSTEM.IMbutton:SetHidden(true)
end

-- Will try to display the notified IM. Called by XML
function rChat_TryToJumpToIm(isMinimized)

	if not CHAT_SYSTEM.primaryContainer then return end

    -- Show chat first
    if isMinimized then
        CHAT_SYSTEM:Maximize()
        CHAT_SYSTEM.IMLabelMin:SetHidden(true)
    end

    -- Tab get IM, scroll
    if IsChatContainerTabCategoryEnabled(1, rData.activeTab, CHAT_CATEGORY_WHISPER_INCOMING) then
        ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)
        rChat_RemoveIMNotification()
    else

        -- Tab don't have IM's, switch to next
        local numTabs = #CHAT_SYSTEM.primaryContainer.windows
        local actualTab = rData.activeTab + 1
        local oldActiveTab = rData.activeTab
        local PRESSED = 1
        local UNPRESSED = 2
        local hasSwitched = false
        local maxt = 1

		if not CHAT_SYSTEM.primaryContainer.HandleTabClick then return end
        while actualTab <= numTabs and (not hasSwitched) do
            if IsChatContainerTabCategoryEnabled(1, actualTab, CHAT_CATEGORY_WHISPER_INCOMING) then

                CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[actualTab].tab)

                local tabText = GetControl("ZO_ChatWindowTabTemplate" .. actualTab .. "Text")
                tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                tabText:GetParent().state = PRESSED
                local oldTabText = GetControl("ZO_ChatWindowTabTemplate" .. oldActiveTab .. "Text")
                oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                oldTabText:GetParent().state = UNPRESSED
                ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)

                hasSwitched = true

            else
                actualTab = actualTab + 1
            end
        end

        actualTab = 1

        -- If we were on tab #3 and IM are show on tab #2, need to restart from 1
        while actualTab < oldActiveTab and (not hasSwitched) do
            if IsChatContainerTabCategoryEnabled(1, actualTab, CHAT_CATEGORY_WHISPER_INCOMING) then

                CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[actualTab].tab)

                local tabText = GetControl("ZO_ChatWindowTabTemplate" .. actualTab .. "Text")
                tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                tabText:GetParent().state = PRESSED
                local oldTabText = GetControl("ZO_ChatWindowTabTemplate" .. oldActiveTab .. "Text")
                oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                oldTabText:GetParent().state = UNPRESSED
                ZO_ChatSystem_ScrollToBottom(CHAT_SYSTEM.control)

                hasSwitched = true
            else
                actualTab = actualTab + 1
            end
        end

    end

end
-- end IM section
-- ----------------------------------------------------------------

-- ------------------------------------------------------
-- Copy functions

-- Set copied text into chatbox text entry, if possible
local function CopyToTextEntry(message)

    if not message then return end
    -- Max of inputbox is 351 chars
    if #message < 351 then
        if CHAT_SYSTEM.textEntry:GetText() == "" then
            CHAT_SYSTEM.textEntry:Open(message)
            ZO_ChatWindowTextEntryEditBox:SelectAll()
        end
    end

end

-- Copy message (only message)
local function CopyMessage(numLine)
    -- Args are passed as string through LinkHandlerSystem
    local entry = CACHE.getCacheEntry(numLine)
    if entry and entry.rawT and entry.rawT.text then
        CopyToTextEntry(entry.rawT.text)
    end
end

--Copy line (including timestamp, from, channel, message, etc)
local function CopyLine(numLine)
    -- Args are passed as string through LinkHandlerSystem
    local entry = CACHE.getCacheEntry(numLine)
    if entry and entry.rawLine then
        CopyToTextEntry(entry.rawLine)
    end
end

-- Popup a dialog message with text to copy
local function ShowCopyDialog(message)

    local maxChars      = 20000

    -- editbox is 20000 chars max
    if str_len(message) < maxChars then
        rChatCopyDialogTLCTitle:SetText(L(RCHAT_COPYXMLTITLE))
        rChatCopyDialogTLCLabel:SetText(L(RCHAT_COPYXMLLABEL))
        rChatCopyDialogTLCNoteEdit:SetText(message)
        rChatCopyDialogTLCNoteNext:SetHidden(true)
        rChatCopyDialogTLC:SetHidden(false)
        rChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
        rChatCopyDialogTLCNoteEdit:SelectAll()
    else

        rChatCopyDialogTLCTitle:SetText(L(RCHAT_COPYXMLTITLE))
        rChatCopyDialogTLCLabel:SetText(L(RCHAT_COPYXMLTOOLONG))

        rData.messageTableId = 1
        rData.messageTable = rChat.strSplitMB(message, maxChars)
        rChatCopyDialogTLCNoteNext:SetText(L(RCHAT_COPYXMLNEXT) .. " ( " .. rData.messageTableId .. " / " .. #rData.messageTable .. " )")
        rChatCopyDialogTLCNoteEdit:SetText(rData.messageTable[rData.messageTableId])
        rChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
        rChatCopyDialogTLCNoteEdit:SelectAll()

        rChatCopyDialogTLC:SetHidden(false)
        rChatCopyDialogTLCNoteNext:SetHidden(false)

        rChatCopyDialogTLCNoteEdit:TakeFocus()

    end

end

-- Copy discussion
-- It will copy all text mark with the same chanCode
-- Todo : Whisps by person
local function CopyDiscussion(chanNumber, numLine)
    local entry = CACHE.getCacheEntry(numLine)
    if not entry then return end

    -- Args are passed as string through LinkHandlerSystem
    local numChanCode = tonumber(chanNumber)
    -- Whispers sent and received together
    if numChanCode == CHAT_CHANNEL_WHISPER_SENT then
        numChanCode = CHAT_CHANNEL_WHISPER
    elseif numChanCode == RCHAT_URL_CHAN then
        numChanCode = entry.channel
    end

    local stringToCopy = ""
    for k, data in CACHE.iterCache() do
        if numChanCode == CHAT_CHANNEL_WHISPER or numChanCode == CHAT_CHANNEL_WHISPER_SENT then
            if data.channel == CHAT_CHANNEL_WHISPER or data.channel == CHAT_CHANNEL_WHISPER_SENT then
                if stringToCopy == "" then
                    stringToCopy = data.rawLine
                else
                    stringToCopy = stringToCopy .. "\r\n" .. data.rawLine
                end
            end
        elseif data.channel == numChanCode then
            if stringToCopy == "" then
                stringToCopy = data.rawLine
            else
                stringToCopy = stringToCopy .. "\r\n" .. data.rawLine
            end
        end
    end
    ShowCopyDialog(stringToCopy)

end

-- Copy Whole chat (not tab)
local function CopyWholeChat()

    local stringToCopy = ""
    for k, data in CACHE.iterCache() do
        if stringToCopy == "" then
            stringToCopy = data.rawLine
        else
            stringToCopy = stringToCopy .. "\r\n" .. data.rawLine
        end
    end

    ShowCopyDialog(stringToCopy)

end

--[[
local function CopyToTextEntryText()
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnLinkClicked)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)
end
--]]

-- Called by XML
function rChat_ShowCopyDialogNext()

    rData.messageTableId = rData.messageTableId + 1

    -- Security
    if rData.messageTable[rData.messageTableId] then

        -- Build button
        rChatCopyDialogTLCNoteNext:SetText(L(RCHAT_COPYXMLNEXT) .. " ( " .. rData.messageTableId .. " / " .. #rData.messageTable .. " )")
        rChatCopyDialogTLCNoteEdit:SetText(rData.messageTable[rData.messageTableId])
        rChatCopyDialogTLCNoteEdit:SetEditEnabled(false)
        rChatCopyDialogTLCNoteEdit:SelectAll()

        -- Don't show next button if its the last
        if not rData.messageTable[rData.messageTableId + 1] then
            rChatCopyDialogTLCNoteNext:SetHidden(true)
        end

        rChatCopyDialogTLCNoteEdit:TakeFocus()

    end

end

-- ------------------------------------------------------


-- ------------------------------------------------------
-- RCHAT_LINK Context Menu

-- Show contextualMenu when clicking on a rChatLink
local function ShowContextMenuOnHandlers(numLine, chanNumber)

    ClearMenu()

    if not ZO_Dialogs_IsShowingDialog() then
        AddMenuItem(L(RCHAT_COPYMESSAGECT), function() CopyMessage(numLine) end)
        AddMenuItem(L(RCHAT_COPYLINECT), function() CopyLine(numLine) end)
        AddMenuItem(L(RCHAT_COPYDISCUSSIONCT), function() CopyDiscussion(chanNumber, numLine) end)
        AddMenuItem(L(RCHAT_ALLCT), CopyWholeChat)
    end

    ShowMenu()

end

-- Triggers when right clicking on a LinkHandler
local function OnLinkClicked(rawLink, mouseButton, linkText, color, linkType, lineNumber, chanCode)

    if linkType ~= RCHAT_LINK then return end
    if db.enablecopy then

        -- Only executed on LinkType = RCHAT_LINK
        local chanNumber = tonumber(chanCode)
        local numLine = tonumber(lineNumber)
        local entry = CACHE.getCacheEntry(numLine)

        if not entry then return end
        -- RCHAT_LINK also handle a linkable channel feature for linkable channels

        -- Context Menu
        if chanCode and mouseButton == MOUSE_BUTTON_INDEX_LEFT then

            if chanNumber == CHAT_CHANNEL_WHISPER then
                local target = zo_strformat(SI_UNIT_NAME, entry.rawT.from)
                IgnoreMouseDownEditFocusLoss()
                CHAT_SYSTEM:StartTextEntry(nil, chanNumber, target)

            elseif chanNumber == RCHAT_URL_CHAN then
                RequestOpenUnsafeURL(linkText)

            else
                local channelInfo = ZO_ChatSystem_GetChannelInfo()[chanNumber]
                if channelInfo and channelInfo.playerLinkable then
                    IgnoreMouseDownEditFocusLoss()
                    CHAT_SYSTEM:StartTextEntry(nil, chanNumber)
                end
            end


        elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            -- Right click, copy System
            ShowContextMenuOnHandlers(numLine, chanNumber)
        end

        -- Don't execute LinkHandler code
        return true
    end
end


-- ------------------------------------------------------
-- Tab functions

-- Needed to bind Shift+Tab in SetSwitchToNextBinding
function KEYBINDINGS_MANAGER:IsChordingAlwaysEnabled()
    return true
end

local function SetSwitchToNextBinding()

    ZO_CreateStringId("SI_BINDING_NAME_RCHAT_SWITCH_TAB", L(RCHAT_SWITCHTONEXTTABBINDING))

    -- get SwitchTab Keybind params
    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("RCHAT_SWITCH_TAB")

    --If exists
    if layerIndex and categoryIndex and actionIndex then

        local key = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, 1)

        if key == KEY_INVALID then
            -- Unbind it
            if IsProtectedFunction("UnbindAllKeysFromAction") then
                CallSecureProtected("UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex)
            else
                UnbindAllKeysFromAction(layerIndex, categoryIndex, actionIndex)
            end

            -- Set it to its default value
            if IsProtectedFunction("BindKeyToAction") then
                CallSecureProtected("BindKeyToAction", layerIndex, categoryIndex, actionIndex, 1, KEY_TAB, 0, 0, KEY_SHIFT, 0)
            else
                BindKeyToAction(layerIndex, categoryIndex, actionIndex, 1, KEY_TAB , 0, 0, KEY_SHIFT, 0)
            end
        end

    end

end

-- Can be called by Bindings
function rChat.SwitchToNextTab()

	if not CHAT_SYSTEM.primaryContainer then return end
    local primaryContainer = CHAT_SYSTEM.primaryContainer

    local hasSwitched

    local PRESSED = 1
    local UNPRESSED = 2
    local numTabs = #primaryContainer.windows

    if numTabs > 1 then
        for numTab, container in ipairs (primaryContainer.windows) do

            if (not hasSwitched) then
                if rData.activeTab + 1 == numTab then
                    primaryContainer:HandleTabClick(container.tab)

                    local tabText = GetControl("ZO_ChatWindowTabTemplate" .. numTab .. "Text")
                    tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                    tabText:GetParent().state = PRESSED
                    local oldTabText = GetControl("ZO_ChatWindowTabTemplate" .. numTab - 1 .. "Text")
                    oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                    oldTabText:GetParent().state = UNPRESSED

                    hasSwitched = true
                end
            end

        end

        if (not hasSwitched) then
            primaryContainer:HandleTabClick(primaryContainer.windows[1].tab)
            local tabText = GetControl("ZO_ChatWindowTabTemplate1Text")
            tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
									INTERFACE_TEXT_COLOR_SELECTED))
            tabText:GetParent().state = PRESSED
            local oldTabText = GetControl("ZO_ChatWindowTabTemplate" .. #primaryContainer.windows .. "Text")
            oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
									INTERFACE_TEXT_COLOR_CONTRAST))
            oldTabText:GetParent().state = UNPRESSED
        end
    end

end

local function SetDefaultTab(tabToSet)

    if not tabToSet then return end
	if not CHAT_SYSTEM.primaryContainer then return end

    for numTab in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
        -- Not this one, try the next one, if tab is not found (newly added, removed),
        -- rChat_SwitchToNextTab() will go back to tab 1
        if tonumber(tabToSet) ~= numTab then
            rChat.SwitchToNextTab()
        else
            -- Found it, stop
            return
        end
    end
end

local function CreateNewChatTab_PostHook()

    local container=CHAT_SYSTEM.primaryContainer
    if not container then return end
	
	local NEVER_FADE = 0
	
    for tabIndex, tabObject in ipairs(container.windows) do
        if db.augmentHistoryBuffer then
            tabObject.buffer:SetMaxHistoryLines(1000) -- 1000 = max of control
        end
        if db.alwaysShowChat then
            tabObject.buffer:SetLineFade(NEVER_FADE, NEVER_FADE)
        end
    end
	rChat.tabNames:Refresh()

end
-- ------------------------------------------------------


-- Prune lines from saved cache
-- Lines must be no older than our threshold,
-- and we keep no more than 5000
--
-- Still need the channel filtering part of this
local function StripLinesFromLineStrings(typeOfExit)
    
    rChatData.filterSize(5000,4000)
    rChatData.filterAged(db.timeBeforeRestore * HRS_TO_SEC)
    local excludeChannels = {
        -- always exclude
        [CHAT_CHANNEL_MONSTER_SAY] = true,
        [CHAT_CHANNEL_MONSTER_YELL] = true,
        [CHAT_CHANNEL_MONSTER_EMOTE] = true,
        [CHAT_CHANNEL_MONSTER_WHISPER] = true,
    }
    if db.restoreSystemOnly then
		local ci = ZO_ChatSystem_GetChannelInfo()
		for k,_ in pairs(ci) do
			if k ~= CHAT_CHANNEL_SYSTEM then
				excludeChannels[k] = true
			end
		end
    else
        if not db.restoreWhisps then
            excludeChannels[CHAT_CHANNEL_WHISPER] = true
            excludeChannels[CHAT_CHANNEL_WHISPER] = true
        end
    end
    if not db.restoreSystem then
        excludeChannels[CHAT_CHANNEL_SYSTEM] = true
    end
    rChatData.filterChannels(excludeChannels)

end

-- save a flag in saved variables so that when we are reloaded
-- by whatever means, we can decide what to restore to chat.
local function SaveChatHistory(typeOf)

    local function ClearLasts()
        db.lastWasReloadUI = false
        db.lastWasLogOut = false
        db.lastWasQuit = false
        db.lastWasAFK = false
    end

    local function ShouldReload(exitType)
        if (db.restoreOnReloadUI == true and exitType == 1)             -- reloadui
                or (db.restoreOnLogOut == true and exitType == 2)       -- logged out
                or (db.restoreOnAFK == true)                            -- timed out of game
                or (db.restoreOnQuit == true and exitType == 3) then    -- quit game
            return true
        else
            return false
        end
    end

    db.history = {}

    if ShouldReload(typeOf) then

        if typeOf == 1 then     -- reloadui
            ClearLasts()
            db.lastWasReloadUI = true

            --Save actual channel
            db.history.currentChannel = CHAT_SYSTEM.currentChannel
            db.history.currentTarget = CHAT_SYSTEM.currentTarget

        elseif typeOf == 2 then     -- logout
            ClearLasts()
            db.lastWasLogOut = true

        elseif typeOf == 3 then     -- quit
            ClearLasts()
            db.lastWasQuit = true
        end

        db.history.currentTab = rData.activeTab

        -- strip some lines from the array to avoid big dumps
        StripLinesFromLineStrings(typeOf)

        --Save TextEntry history
        db.history.textEntry = {}
        if CHAT_SYSTEM.textEntry.commandHistory.entries then
            db.history.textEntry.entries = CHAT_SYSTEM.textEntry.commandHistory.entries
            db.history.textEntry.numEntries = CHAT_SYSTEM.textEntry.commandHistory.index
			
        else
            db.history.textEntry.entries = {}
            db.history.textEntry.numEntries = 0
        end
		
    else
        CACHE.clearCache()
    end

end

local function ShowFadedLines()

	rChat.hookmgr:SecurePostHook(CHAT_SYSTEM, "CreateNewChatTab", function()
		CreateNewChatTab_PostHook()
	end)
end

local function OnReticleTargetChanged()
    if IsUnitPlayer("reticleover") then
        targetToWhisp = GetUnitName("reticleover")
    end
end

function rChat.BuildNicknames(lamCall)

    local function Explode(div, str)
        if (div=='') then return false end
        local pos,arr = 0,{}
        for st,sp in function() return string.find(str,div,pos,true) end do
            t_insert(arr,str_sub(str,pos,st-1))
            pos = sp + 1
        end
        t_insert(arr,str_sub(str,pos))
        return arr
    end

    rData.nicknames = {}

    if db.nicknames ~= "" then
        local lines = Explode("\n", db.nicknames)

        for lineIndex=#lines, 1, -1 do
            local oldName, newName = string.match(lines[lineIndex], "(@?[%w_-]+) ?= ?([%w- ]+)")
            if not (oldName and newName) then
                table.remove(lines, lineIndex)
            else
                rData.nicknames[oldName] = newName
            end
        end

        db.nicknames = table.concat(lines, "\n")

        if lamCall then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", rData.LAMPanel)
        end

    end

end

-- Change font of chat
function rChat.ChangeChatFont(change)

    local fontSize = GetChatFontSize()
    if db.fonts == "ESO Standard Font" or db.fonts == "Univers 57" then
        return
    else
        local fontPath = LMP:Fetch("font", db.fonts)
        -- Entry Box
        ZoFontEditChat:SetFont(fontPath .. "|".. fontSize .. "|shadow")
        -- Chat window
        ZoFontChat:SetFont(fontPath .. "|" .. fontSize .. "|soft-shadow-thin")
    end
end

-- Change guild channel names in entry box
function rChat.UpdateGuildChannelNames()

    -- Each guild
    local ChanInfoArray = ZO_ChatSystem_GetChannelInfo()
    for i = 1, GetNumGuilds() do
        local gname = SF.SafeGetGuildName(i)
        local guild_channel, officer_channel = rChat.GetGuildChannel(i)
        if db.showTagInEntry then

            -- Get saved string
            local tag = db.guildTags[gname]
            if not tag or tag == ""then
                tag = gname
            end

            -- Get saved string
            local officertag = db.officertag[gname]
            if not officertag or officertag == "" then
                officertag = tag
            end

            -- /g1 is 12 /g5 is 16, /o1=17, etc
            ChanInfoArray[guild_channel].name = tag
            ChanInfoArray[officer_channel].name = officertag
            --Activating
            ChanInfoArray[guild_channel].dynamicName = false
            ChanInfoArray[officer_channel].dynamicName = false

        else
            -- /g1 is 12 /g5 is 16, /o1=17, etc
            ChanInfoArray[guild_channel].name = gname
            ChanInfoArray[officer_channel].name = gname
            --Deactivating
            ChanInfoArray[guild_channel].dynamicName = true
            ChanInfoArray[officer_channel].dynamicName = true
        end
    end

    return

end

-- Sub function of addLinkHandlerToString
-- Get a string without |cXXXXXX and without |t as parameter
local function AddLinkHandlerToStringWithoutDDS(textToCheck, numLine, chanCode)

    if not textToCheck or textToCheck == "" then return "" end
    local stillToParse = true
    local noColorlen = textToCheck:len()

    local startNoColor = 1
    local textLinked = ""
    local preventLoopsCol = 0
    local handledText = ""

    while stillToParse do
        -- Prevent infinite loops while its still in beta
        if preventLoopsCol > 10 then
            stillToParse = false
            CHAT_SYSTEM:Zo_AddMessage("rChat triggered an infinite LinkHandling loop in its copy system with last message : " .. textToCheck .. " -- rChat")
        else
            preventLoopsCol = preventLoopsCol + 1
        end

        noColorlen = textToCheck:len()

        local startpos, endpos = string.find(textToCheck, "|[hH](.-)|[hH](.-)|[hH]", 1)
        -- LinkHandler not found
        if not startpos then
            -- If nil, then we won't have new link after startposition = startNoColor , so add ours util the end

            -- Some addons use t_insert() and chat convert to a CRLF
            -- First, drop the final CRLF if we are at the end of the text
            if str_sub(textToCheck, -2) == "\r\n" then
                textToCheck = str_sub(textToCheck, 1, -2)
            end
            -- MultiCRLF is handled in .addLinkHandler()

            textLinked = rChat.SplitTextForLinkHandler(textToCheck, numLine, chanCode)
            handledText = handledText .. textLinked

            -- No need to parse after
            stillToParse = false

        else

            -- Link is at the beginning of the string
            if startpos == 1 then
                -- New text is (only handler because its at the pos 1)
                handledText = handledText .. textToCheck:sub(startpos, endpos)

                -- Do we need to continue ?
                if endpos == noColorlen then
                    -- We're at the end
                    stillToParse = false
                else
                    -- Still to parse
                    startNoColor = endpos
                    -- textToCheck is next to our string
                    textToCheck = textToCheck:sub(startNoColor + 1)
                end

            else

                -- We Handle string from startNoColor of the message up to the Handle link
                local textToHandle = textToCheck:sub(1, startpos - 1)

                -- Add ours
                -- Maybe we need a split due to 106 chars restriction
                textLinked = rChat.SplitTextForLinkHandler(textToHandle, numLine, chanCode)

                -- New text is handledText + (textLinked .. LinkHandler)
                handledText = handledText .. textLinked
                handledText = handledText .. textToCheck:sub(startpos, endpos)

                -- Do we need to continue ?
                if endpos == noColorlen then
                    -- We're at the end
                    stillToParse = false
                else
                    -- Still to parse
                    startNoColor = endpos
                    -- textToCheck is next to our string
                    textToCheck = textToCheck:sub(startNoColor + 1)
                end

            end
        end
    end
    return handledText

end

-- Sub function of addLinkHandlerToLine, Handling DDS textures in chat
-- Get a string without |cXXXXXX as parameter
local function AddLinkHandlerToString(textToCheck, numLine, chanCode)

    local stillToParseDDS = true
    local noDDSlen = textToCheck:len()

    -- this var seems to get some rework
    local startNoDDS = 1
    local textLinked = ""
    local preventLoopsDDS = 0
    local textTReformated = ""

    -- Seems the "|" are truncated from the link when send to chatsystem (they're needed for build link, but the output does not include them)

    while stillToParseDDS do

        -- Prevent infinite loops while its still in beta
        if preventLoopsDDS > 20 then
            stillToParseDDS = false
            CHAT_SYSTEM:Zo_AddMessage("rChat triggered an infinite DDS loop in its copy system with last message : " .. textToCheck .. " -- rChat")
        else
            preventLoopsDDS = preventLoopsDDS + 1
        end

        noDDSlen = textToCheck:len()

        local startpos, endpos = string.find(textToCheck, "|t%-?%d+%%?:%-?%d+%%?:.-|t", 1)
        -- DDS not found
        if startpos == nil then
            -- If nil, then we won't have new link after startposition = startNoDDS , so add ours until the end

            textLinked = AddLinkHandlerToStringWithoutDDS(textToCheck, numLine, chanCode)
            textTReformated = textTReformated .. textLinked

            -- No need to parse after
            stillToParseDDS = false

        else
            -- DDS is at the beginning of the string
            if startpos == 1 then
                -- New text is (only DDS because its at the pos 1)
                textTReformated = textTReformated .. textToCheck:sub(startpos, endpos)

                -- Do we need to continue ?
                if endpos == noDDSlen then
                    -- We're at the end
                    stillToParseDDS = false
                else
                    -- Still to parse
                    startNoDDS = endpos
                    -- textToCheck is next to our string
                    textToCheck = textToCheck:sub(startNoDDS + 1)
                end

            else

                -- We Handle string from startNoDDS of the message up to the Handle link
                local textToHandle = textToCheck:sub(1, startpos - 1)

                -- Add ours
                textLinked = AddLinkHandlerToStringWithoutDDS(textToHandle, numLine, chanCode)

                -- New text is formattedText + (textLinked .. DDS)
                textTReformated = textTReformated .. textLinked

                textTReformated = textTReformated .. textToCheck:sub(startpos, endpos)

                -- Do we need to continue ?
                if endpos == noDDSlen then
                    -- We're at the end
                    stillToParseDDS = false
                else
                    -- Still to parse
                    startNoDDS = endpos
                    -- textToCheck is next to our string
                    textToCheck = textToCheck:sub(startNoDDS + 1)
                end

            end
        end
    end
    return textTReformated

end

-- Reformat Colored Sysmessages to the correct format
-- Bad format = |[cC]XXXXXXblablabla[,|[cC]XXXXXXblablabla,(...)] with optional |r
-- Good format : "|c%x%x%x%x%x%x(.-)|r"
local function ReformatSysMessages(text)
     if not text then return "",{} end

    -- get positions of all of the desired delimiters
    local t1 = SF.getAllColorDelim(text)

    if #t1 == 0 then
        -- no delimiters in string
        return text,{text}
    end

    -- balance and correct color markers
    SF.regularizeColors(t1, text)
    local splitcolors = SF.colorsplit(t1, text)
    rawSys = table.concat(splitcolors)

    -- |u search (strip out hard padding)
    rawSys = string.gsub(rawSys,"|u%-?%d+%%?:%-?%d+%%?:(.-):|u","%1")

    return rawSys, splitcolors

end

-- Add rChatLinks Handlers on the whole text except LinkHandlers already here
local function AddLinkHandlerToLine(text, chanCode, numLine)

    local rawText, colorsplit = ReformatSysMessages(text)
    for k,v in ipairs(colorsplit) do
        if v:sub(1,1) ~= "|" then
            colorsplit[k] = AddLinkHandlerToString(v, numLine, chanCode)
        end
    end
    local newtext = table.concat(colorsplit)
    return newtext

end

-- Split lines using CRLF for function addLinkHandlerToLine
local function AddLinkHandler(text, chanCode, numLine)
    if not text then return end

    -- Some Addons output multiple lines into a message
    -- Split the entire string with CRLF, cause LinkHandler don't support CRLF

    -- Init
    local formattedText = text
    -- Recheck setting if copy is disabled for chat dump
    if db.enablecopy then

        -- No CRLF
        -- ESO LUA Messages output \n instead of \r\n
        local crtext = string.gsub(text, "\r\n", "\n")
        -- Find multilines
        local cr = string.find(crtext, "\n")

        if not cr then
            formattedText = AddLinkHandlerToLine(text, chanCode, numLine)
        else
            local lines = {zo_strsplit("\n", crtext)}
            local first = true
            local strippedLine
            local numRows = 0

            for _, line in pairs(lines) do

                -- Only if there something to display
                if str_len(line) > 0 then

                    if first then
                        formattedText = AddLinkHandlerToLine(line, chanCode, numLine)
                        first = false
                    else
                        formattedText = formattedText .. "\n" .. AddLinkHandlerToLine(line, chanCode, numLine)
                    end

                    if numRows > 10 then
                        CHAT_SYSTEM:Zo_AddMessage("rChat has triggered 10 packed lines with text=" .. text .. "-- rChat - Message truncated")
                        return
                    else
                        numRows = numRows + 1
                    end

                end

            end

        end
    else
        formattedText = text
    end

    return formattedText

end

local function RestoreChatMessagesFromHistory(wasReloadUI)
	if not CHAT_SYSTEM.primaryContainer then return end
    local function shouldRestore(channel)
        if channel~= CHAT_CHANNEL_SYSTEM and channel ~= CHAT_CHANNEL_WHISPER and channel ~= CHAT_CHANNEL_WHISPER_SENT then
            return true
        end
        if channel == CHAT_CHANNEL_SYSTEM and (db.restoreSystem or db.restoreSystemOnly)then
            return true
        end
        if (channel == CHAT_CHANNEL_WHISPER or channel == CHAT_CHANNEL_WHISPER_SENT) and db.restoreWhisps then
            return true
        end
        return false
    end

    local categories = ZO_ChatSystem_GetEventCategoryMappings()
    local cattab = categories[EVENT_CHAT_MESSAGE_CHANNEL]

    local lastInsertionWas = 0
    for k,v in CACHE.iterCache() do
        if shouldRestore() and v.displayed then
            -- the only branch where we restore a line
            local category = cattab[v.channel]

            if type(v.timestamp) == "number" then
                lastInsertionWas = math.max(lastInsertionWas, v.timestamp)
                local localPlayer = GetUnitName("player")
                for containerIndex, container in ipairs(CHAT_SYSTEM.containers) do
                    for tabIndex, window in ipairs(container.windows) do
                        if IsChatContainerTabCategoryEnabled(container.id, tabIndex, category) then
                            if not db.chatConfSync[localPlayer].tabs[tabIndex].notBefore 
                                    or v.timestamp > db.chatConfSync[localPlayer].tabs[tabIndex].notBefore then
                                container:AddEventMessageToWindow(window, v.displayed, category)
                            end
                        end
                    end
                end
            end

        end     -- end shouldRestore()

        local PRESSED = 1
        local UNPRESSED = 2
        for numTab, container in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
            if numTab > 1 then
                CHAT_SYSTEM.primaryContainer:HandleTabClick(container.tab)
                local tabText = GetControl("ZO_ChatWindowTabTemplate" .. numTab .. "Text")
                tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
                tabText:GetParent().state = PRESSED
                local oldTabText = GetControl("ZO_ChatWindowTabTemplate" .. numTab - 1 .. "Text")
                oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
                oldTabText:GetParent().state = UNPRESSED
            end
        end

        local numTabs = #CHAT_SYSTEM.primaryContainer.windows
        if numTabs > 1 then
            CHAT_SYSTEM.primaryContainer:HandleTabClick(CHAT_SYSTEM.primaryContainer.windows[1].tab)
            local tabText = GetControl("ZO_ChatWindowTabTemplate1Text")
            tabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
            tabText:GetParent().state = PRESSED
            local oldTabText = GetControl("ZO_ChatWindowTabTemplate" .. #CHAT_SYSTEM.primaryContainer.windows .. "Text")
            oldTabText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTRAST))
            oldTabText:GetParent().state = UNPRESSED
        end

    end

    -- Restore TextEntry History
    if (wasReloadUI or db.restoreTextEntryHistoryAtLogOutQuit) and db.history.textEntry then

        if db.history.textEntry.entries then

            if lastInsertionWas and ((GetTimeStamp() - lastInsertionWas) < (db.timeBeforeRestore * HRS_TO_SEC)) then
                for _, text in pairs(db.history.textEntry.entries) do
                    CHAT_SYSTEM.textEntry:AddCommandHistory(text)
                end

                CHAT_SYSTEM.textEntry.commandHistory.index = db.history.textEntry.numEntries
            end

        end

    end

end

-- Restore History from SavedVars
local function RestoreChatHistory()

    -- Set default tab at login
    SetDefaultTab(db.tabs.defaultTab)
    -- Restore History
    if not db.history then
        rChat_ZOS.messagesWereRestored = true
        return
    end

    if db.lastWasReloadUI and db.restoreOnReloadUI then

        -- RestoreChannel
        if db.tabs.defaultchannel ~= RCHAT_CHANNEL_NONE then
            CHAT_SYSTEM:SetChannel(db.history.currentChannel, db.history.currentTarget)
        end

        -- restore TextEntry and Chat
        RestoreChatMessagesFromHistory(true)

    elseif (db.lastWasLogOut and db.restoreOnLogOut) or (db.lastWasAFK and db.restoreOnAFK) or (db.lastWasQuit and db.restoreOnQuit) then
        -- restore TextEntry and Chat
        RestoreChatMessagesFromHistory(false)
    end

    rChat_ZOS.messagesWereRestored = true

    local indexMessages = #rData.cachedMessages
    if indexMessages > 0 then
        local rmsg
        for index=1, indexMessages do
            rmsg = rData.cachedMessages[index]
            if rmsg and rmsg ~= "" then
                CHAT_SYSTEM:Zo_AddMessage(rData.cachedMessages[index])
            end
        end
    end

    db.lastWasReloadUI = false
    db.lastWasLogOut = false
    db.lastWasQuit = false
    db.lastWasAFK = true

end

-- Store line number
-- Create an array for the copy functions, spam functions and revert history functions
local function StorelineNumber(epochtime, rawFrom, text, chanCode, originalFrom, lineNum)

    -- Strip DDS tag from Copy text
    local function StripDDStags(text)
        return text:gsub("|t(.-)|t", "")
    end

    local msgPrefix = " "
    local rawText = text

    local entry,lineno = CACHE.getCacheEntry(lineNum)

    -- SysMessages does not have a from
    if chanCode ~= CHAT_CHANNEL_SYSTEM then

        -- Timestamp cannot be nil anymore with SpamFilter, so use the option itself
        if db.showTimestamp then
            -- Format for Copy
            msgPrefix = string.format("[%s] ",rChat.CreateTimestamp(db.timestampFormat))
        end

        -- Strip DDS tags for GM
        rawFrom = StripDDStags(rawFrom)

        -- Needed for SpamFilter
        entry.rawT.from = rawFrom

        -- msgPrefix
        msgPrefix = msgPrefix .. entry.rawT.from .. entry.rawT.separator

    end

    -- Needed for SpamFilter & Restoration, UNIX timestamp
    entry.timestamp = epochtime

    -- Store CopyMessage / Used for SpamFiltering.
    entry.channel = chanCode

    -- Strip DDS tags
    rawText = StripDDStags(rawText)

    -- Store CopyLine
    entry.rawLine = msgPrefix .. text
end

-- WARNING : Since AddMessage is bypassed, this function and all its subfunctions DOES NOT CALL d() / Emitmessage() / AddMessage() or it will result an infinite loop and crash the game
-- Debug must call CHAT_SYSTEM:Zo_AddMessage() which is backed up copy of CHAT_SYSTEM.AddMessage
local function FormatSysMessage(statusMessage)

    if not statusMessage or str_len(statusMessage) == 0 then return end

    -- Display Timestamp if needed
    local function ShowTimestamp(timevalue)
        local timestr = ""

        -- Add timestamp
        if db.showTimestamp then
            -- Timestamp formatted
            timestr = rChat.CreateTimestamp(db.timestampFormat,timevalue)

            local timecol
            -- Timestamp color is chanCode so no coloring
            if db.timestampcolorislcol then
                timestr = string.format("[%s] ", timestr)
            else
                -- Timestamp color is our setting color
                timecol = db.colours.timestamp
                timestr = string.format("%s[%s] |r", timecol, timestr)
            end
        end
        return timestr
    end -- ShowTimestamp()


    -- Some addons are quicker than rChat
    if not db then return statusMessage end

    local entry, ndx = CACHE.getNewCacheEntry(CHAT_CHANNEL_SYSTEM)
    entry.timestamp = GetTimeStamp()
    entry.rawTimeString = ShowTimestamp(GetTimeString())

    -- Make it Linkable
    local sysMessage
    if db.enablecopy then
        sysMessage = entry.rawTimeString..AddLinkHandler(statusMessage, CHAT_CHANNEL_SYSTEM, ndx)
    else
        sysMessage = entry.rawTimeString..statusMessage
    end
    entry.displayed = sysMessage


    -- No From, rawTimeString is in statusMessage, sent as arg for SpamFiltering even if SysMessages are not filtered
    StorelineNumber(entry.timestamp, nil, statusMessage, CHAT_CHANNEL_SYSTEM, nil, ndx)

    return sysMessage
end

local function InitializeURLHandling()

    -- cTLD + most used (> 0.1%)
    local domains =
    [[
    .ac.ad.ae.af.ag.ai.al.am.an.ao.aq.ar.as.at.au.aw.ax.az
    .ba.bb.bd.be.bf.bg.bh.bi.bj.bl.bm.bn.bo.bq.br.bs.bt.bv.bw.by.bz
    .ca.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.cr.cu.cv.cw.cx.cy.cz
    .de.dj.dk.dm.do.dz
    .ec.ee.eg.eh.er.es.et.eu.fi.fj.fk.fm.fo.fr
    .ga.gb.gd.ge.gf.gg.gh.gi.gl.gm.gn.gp.gq.gr.gs.gt.gu.gw.gy
    .hk.hm.hn.hr.ht.hu.id.ie.il.im.in.io.iq.ir.is.it
    .je.jm.jo.jp.ke.kg.kh.ki.km.kn.kp.kr.kw.ky.kz
    .la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly
    .ma.mc.md.me.mf.mg.mh.mk.ml.mm.mn.mo.mp.mq.mr.ms.mt.mu.mv.mw.mx.my.mz
    .na.nc.ne.nf.ng.ni.nl.no.np.nr.nu.nz.om
    .pa.pe.pf.pg.ph.pk.pl.pm.pn.pr.ps.pt.pw.py.qa
    .re.ro.rs.ru.rw
    .sa.sb.sc.sd.se.sg.sh.si.sj.sk.sl.sm.sn.so.sr.ss.st.su.sv.sx.sy.sz
    .tc.td.tf.tg.th.tj.tk.tl.tm.tn.to.tp.tr.tt.tv.tw.tz
    .ua.ug.uk.um.us.uy.uz.va.vc.ve.vg.vi.vn.vu.wf.ws.ye.yt.za.zm.zw
    .biz.com.coop.edu.gov.int.mil.mobi.info.net.org.xyz.top.club.pro.asia
    ]]

    -- wxx.yy.zz
    rData.tlds = {}
    for tld in domains:gmatch('%w+') do
        rData.tlds[tld] = true
    end

    -- protos : only http/https
    rData.protocols = {['http://'] = 0, ['https://'] = 0}

end

local function presentMessage(entry)

end

-- Executed when EVENT_CHAT_MESSAGE_CHANNEL triggers
-- Formats the message
local function FormatMessage(chanCode, from, text, isCS, fromDisplayName)

    if not text or text == "nil" then return end
    local db = rChat.save
    
    if chanCode == nil or type(chanCode) ~= "number" then chanCode = CHAT_CHANNEL_SAY end
    isCS = isCS or false
	
	if chanCode == CHAT_CATEGORY_WHISPER and fromDisplayName ~= nil then
		lastwhisp = fromDisplayName
	end
	
    -- Will calculate if this message is a spam
    local isSpam = rChat.SpamFilter(chanCode, from, text, isCS)
    if isSpam then return end

    local original = {
        from = from,
        text = text,
        fromDisplayName = fromDisplayName,
        isCS = isCS,
    }

	--if str_len(text) > 240 then
	--	text = str_sub(text,1,240)
	--end
    
    local newtext = text

    local entry, ndx = CACHE.getNewCacheEntry(chanCode) -- initializes channel and timestamp
	entry.original = original
	
    local display = {}      -- info to build a display message
    local raw = {}          -- info to build a raw message
    entry.rawT = raw
    entry.displayT = display
    
    entry.rawLine = newtext         -- copy line (prefix + message)
    entry.displayed = newtext    -- restored to chat (has link handler markers)
    
    -- prepare from name
    display.from, raw.from = formatName(chanCode, from, isCS, fromDisplayName)

    -- Guild tag
    display.tag, raw.tag = formatTag(entry,ndx)
    
    -- Whisper tag
    display.whisper, raw.whisper = formatWhisperTag(entry,ndx)
	if raw.whisper == "->" then
		rChat.lastwhisp = original.from
	end
	
	-- Zone tags
	display.zonetag, raw.zonetag, display.partytag, raw.partytag = formatZoneTag(entry,ndx)

    -- Initialise colours
    local colorT = initColorTable(chanCode, from)

    -- Init message
    local message = ""

    -- format timestamp
    display.timestamp, raw.timestamp = formatTimestamp(entry, ndx)
    message = message .. display.timestamp

    -- format message text
    display.text, raw.text = formatText(entry, ndx, colorT)

    display.separator, raw.separator = formatSeparator(entry,ndx)
    local carriageReturn = display.separator
    
    local notHandled = false
    
    entry.rawLine = produceRawString(entry, ndx, raw)
    entry.displayed = produceDisplayString(entry, ndx, display, colorT)
	local lvl = 0
	while ( lvl < 3 and str_len(entry.displayed) > 350) do
		entry.displayed = reduceString(entry,ndx, lvl)
		lvl = lvl + 1
	end
    
    --PlaySound for whisper
    if chanCode == CHAT_CHANNEL_WHISPER and db.whisper.incomingsound then
        SF.PlaySound(db.whisper.incomingsound)
    end

    -- Only if not handled by rChat
    if not notHandled then
        -- Store message and params into an array for copy system and SpamFiltering
        StorelineNumber(entry.timestamp, raw.from, original.text, chanCode, fromDisplayName, ndx)
    end

    if chanCode == CHAT_CHANNEL_WHISPER then
        lastwhisp = raw.from
        OnIMReceived(raw.from, ndx)
    end
    entry.rawT = raw
    --entry.displayT = display
	entry.displayT =  nil
    return entry.displayed --message

end

-- Save chat configuration
local function SaveChatConfig()

    if not rData.tabNotBefore then
        rData.tabNotBefore = {} -- Init here or in SyncChatConfig depending if the "Clear Tab" has been used
    end

    if isAddonLoaded and CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then -- Some addons calls SetCVar before
        local primaryContainer = CHAT_SYSTEM.primaryContainer
        local primeSettings = primaryContainer.settings
        local saveChar = {}

        -- Save Chat positions
        saveChar.relPoint = primeSettings.relPoint
        saveChar.x = primeSettings.x
        saveChar.y = primeSettings.y
        saveChar.height = primeSettings.height
        saveChar.width = primeSettings.width
        saveChar.point = primeSettings.point

        -- Don't overflow screen, remove 10px.
        if primeSettings.height >= ( CHAT_SYSTEM.maxContainerHeight - 15 ) then
            saveChar.height = ( CHAT_SYSTEM.maxContainerHeight - 15 )
        else
            saveChar.height = primeSettings.height
        end

        -- Same
        if primeSettings.width >= ( CHAT_SYSTEM.maxContainerWidth - 15 ) then
            saveChar.width = ( CHAT_SYSTEM.maxContainerWidth - 15 )
        else
            saveChar.width = primeSettings.width
        end

        -- Save Colors
        saveChar.colors = {}

        for _, category in ipairs (rData.chatCategories) do
            local r, g, b = GetChatCategoryColor(category)
            saveChar.colors[category] = { red = r, green = g, blue = b }
        end

        -- Save Font Size
        saveChar.fontSize = GetChatFontSize()

        -- Save Tabs
        saveChar.tabs = {}

        -- GetNumChatContainerTabs(1) don't refresh its number before a ReloadUI
        -- for numTab = 1, GetNumChatContainerTabs(1) do
        for numTab in ipairs (primaryContainer.windows) do

            local newtab = {
                isLocked = false,
                isInteractable = false,
                isCombatLog = false,
                areTimestampsEnabled = false,
                enabledCategories = {},
            }

            -- Save "Clear Tab" flag
            if rData.tabNotBefore[numTab] then
                newtab.notBefore = rData.tabNotBefore[numTab]
            end

            -- IsLocked
            if primaryContainer:IsLocked(numTab) then
                newtab.isLocked = true
            end

            -- IsInteractive
            if primaryContainer:IsInteractive(numTab) then
                newtab.isInteractable = true
            end

            -- IsCombatLog
            if primaryContainer:IsCombatLog(numTab) then
                newtab.isCombatLog = true
                -- AreTimestampsEnabled
                if primaryContainer:AreTimestampsEnabled(numTab) then
                    newtab.areTimestampsEnabled = true
                end
            end

            -- GetTabName
            newtab.name = primaryContainer:GetTabName(numTab)

            -- Enabled categories
            for _, category in ipairs (rData.chatCategories) do
                local isEnabled = IsChatContainerTabCategoryEnabled(1, numTab, category)
                newtab.enabledCategories[category] = isEnabled
            end
            -- save tab config
            saveChar.tabs[numTab] = newtab
        end

        -- Rewrite the whole char tab
        db.chatConfSync[GetUnitName("player")] = saveChar
        db.chatConfSync.lastChar = saveChar

    end

end

-- Save Chat Tabs config when user changes it
local function SaveTabsCategories()
	if not CHAT_SYSTEM.primaryContainer then return end
    local primaryContainer = CHAT_SYSTEM.primaryContainer

    local localPlayer = GetUnitName("player")
	if not db.chatConfSync[localPlayer] then
		return
	end
    local playerInfo = db.chatConfSync[localPlayer]
    for numTab in ipairs (primaryContainer.windows) do
        for _, category in ipairs (rData.guildCategories) do
            local isEnabled = IsChatContainerTabCategoryEnabled(1, numTab, category)
			if not playerInfo.tabs then playerInfo.tabs = {} end
            if playerInfo.tabs[numTab] then
                playerInfo.tabs[numTab].enabledCategories[category] = isEnabled
            else
                SaveChatConfig()
            end
        end

    end

end

-- Function for Minimizing chat at launch
local function MinimizeChatAtLaunch()
    if db.chatMinimizedAtLaunch then
        CHAT_SYSTEM:Minimize()
    end
end

local function MinimizeChatInMenus()

    -- RegisterCallback for Maximize/Minimize chat when entering/leaving scenes
    -- "hud" is base scene (with "hudui")
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)
        if db.chatMinimizedInMenus then
            if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
                CHAT_SYSTEM:Minimize()
            end
        end

        if db.chatMaximizedAfterMenus then
            if newState == SCENE_SHOWING then
                CHAT_SYSTEM:Maximize()
            end
        end

    end)


end

-- Import the chat config from rChat settings
local function SyncChatConfig(shouldSync, whichChar)

    if not shouldSync then return end   -- why call this if you don't want to import stuff?
    if not db.chatConfSync then return end
    if not db.chatConfSync[whichChar] then return end   -- no character config to use
	if not CHAT_SYSTEM.primaryContainer then return end
    local primaryContainer = CHAT_SYSTEM.primaryContainer

    local newcfg = db.chatConfSync[whichChar]

    -- Position and width/height
    CHAT_SYSTEM.control:SetAnchor(newcfg.point, GuiRoot, newcfg.relPoint, newcfg.x, newcfg.y)
    -- Height / Width
    CHAT_SYSTEM.control:SetDimensions(newcfg.width, newcfg.height)

    -- Save settings immediately (to check, maybe call function which do this)
    local primeSettings = primaryContainer.settings
    primeSettings.height = newcfg.height
    primeSettings.point = newcfg.point
    primeSettings.relPoint = newcfg.relPoint
    primeSettings.width = newcfg.width
    primeSettings.x = newcfg.x
    primeSettings.y = newcfg.y

    -- Colors
    for _, category in ipairs (rData.chatCategories) do
        if not newcfg.colors[category] then
            local r, g, b = GetChatCategoryColor(category)
            newcfg.colors[category] = { red = r, green = g, blue = b }
        end
        SetChatCategoryColor(category, newcfg.colors[category].red, newcfg.colors[category].green, newcfg.colors[category].blue)
    end

    -- Font Size
    local fontSize = newcfg.fontSize
    CHAT_SYSTEM:SetFontSize(fontSize)
    SetChatFontSize(fontSize)
    local chatSyncNumTab = 1

    for numTab in ipairs(newcfg.tabs) do

        --Create a Tab if nessesary
        if (GetNumChatContainerTabs(1) < numTab) then
            -- AddChatContainerTab() -- Requires a ReloadUI
            primaryContainer:AddWindow(newcfg.tabs[numTab].name)
        end

        if newcfg.tabs[numTab] and newcfg.tabs[numTab].notBefore then
            if not rData.tabNotBefore then
                rData.tabNotBefore = {} -- Used for tab restoration, init here.
            end
            rData.tabNotBefore[numTab] = newcfg.tabs[numTab].notBefore
        end

        primaryContainer:SetTabName(numTab, newcfg.tabs[numTab].name)
        primaryContainer:SetLocked(numTab, newcfg.tabs[numTab].isLocked)
        primaryContainer:SetInteractivity(numTab, newcfg.tabs[numTab].isInteractable)
        primaryContainer:SetTimestampsEnabled(numTab, newcfg.tabs[numTab].areTimestampsEnabled)

        -- Set Channel per tab configuration
        for _, category in ipairs (rData.chatCategories) do
            if newcfg.tabs[numTab].enabledCategories[category] == nil then -- Can be false
                newcfg.tabs[numTab].enabledCategories[category] = IsChatContainerTabCategoryEnabled(1, numTab, category)
            end
            SetChatContainerTabCategoryEnabled(1, numTab, category, newcfg.tabs[numTab].enabledCategories[category])
        end

        chatSyncNumTab = numTab

    end

    -- If there were too many tabs before, drop them
    local removeTabs = true
    while removeTabs do
        -- Too many tabs, deleting one
        if GetNumChatContainerTabs(1) > chatSyncNumTab then
            -- Not in realtime : RemoveChatContainerTab(1, chatSyncNumTab + 1)
            primaryContainer:RemoveWindow(chatSyncNumTab + 1, nil)
        else
            removeTabs = false
        end
    end
end

-- When creating a char, try to import settings
local function AutoSyncSettingsForNewPlayer()

    -- New chars get automaticaly last char config
    if GetIsNewCharacter() then
        SyncChatConfig(true, "lastChar")
    end

end

-- Set channel to the default one
function rChat.SetToDefaultChannel()
    rChat_Logger():Debug("Default channel == ".. db.tabs.defaultchannel)
    if db.tabs.defaultchannel ~= RCHAT_CHANNEL_NONE then
        CHAT_SYSTEM:SetChannel(db.tabs.defaultchannel)
    end
end

-- Create guildname to guild index table
local function SaveGuildIndexes()

    rData.guildIndexes = {}
    for guild = 1, GetNumGuilds() do
        local guildName = SF.SafeGetGuildName(guild)
        rData.guildIndexes[guildName] = guild
    end

end

-- Executed when EVENT_IGNORE_ADDED triggers
local function OnIgnoreAdded(displayName)

    -- DisplayName is linkable
    local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
    local statusMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_ADDED, displayNameLink)

    -- Only if statusMessage is set
    if statusMessage then
        -- added to ignore list
        return FormatSysMessage(statusMessage)
    end

end

-- Executed when EVENT_IGNORE_REMOVED triggers
local function OnIgnoreRemoved(displayName)

    -- DisplayName is linkable
    local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
    local statusMessage = zo_strformat(SI_FRIENDS_LIST_IGNORE_REMOVED, displayNameLink)

    -- Only if statusMessage is set
    if statusMessage then
        -- removed from ignore list
        return FormatSysMessage(statusMessage)
    end

end

-- triggers when EVENT_FRIEND_PLAYER_STATUS_CHANGED
local function OnFriendPlayerStatusChanged(displayName, characterName, oldStatus, newStatus)

	if not db.enableFriendStatus then return end
    local statusMessage

    -- DisplayName is linkable
    local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
    -- CharacterName is linkable
    local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)

    local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
    local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

    -- Not connected before and Connected now (no messages for Away/Busy)
    if not wasOnline and isOnline then
        -- Return
        -- friend has logged on with toon
        statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
    -- Connected before and Offline now
    elseif wasOnline and not isOnline then
        -- friend has logged off with toon
        statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
    end

    -- Only if statusMessage is set
    if statusMessage then
        return FormatSysMessage(statusMessage)
    end

end

-- Executed when EVENT_GROUP_TYPE_CHANGED triggers
local function OnGroupTypeChanged(largeGroup)

    if largeGroup then
        -- Your group is now a large group
        return FormatSysMessage(L(SI_CHAT_ANNOUNCEMENT_IN_LARGE_GROUP))
    else
        -- Your group is no longer a large group
        return FormatSysMessage(L(SI_CHAT_ANNOUNCEMENT_IN_SMALL_GROUP))
    end

end

local function OnGroupMemberLeftLC(_, reason, isLocalPlayer, _, _, actionRequiredVote)
    if reason == GROUP_LEAVE_REASON_KICKED and isLocalPlayer and actionRequiredVote then
        -- Your group members voted to kick you from the group
        return L(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
    end
end

function rChat.UpdateGuildSwitches()

    -- Each guild
    local ChanInfoArray = ZO_ChatSystem_GetChannelInfo()
    local guildName, guildId
    for i = 1, GetNumGuilds() do

        guildName, guildId = SF.SafeGetGuildName(i)
        if guildId then
            local mem, ofc = rChat.GetGuildChannel(i)
            -- Get saved string
            local switch = db.switchFor[guildName]
            if switch and switch ~= "" then
                switch = switch .. " " .. L(SI_CHANNEL_SWITCH_GUILD_1 - 1 + i)
            else
                switch = L(SI_CHANNEL_SWITCH_GUILD_1 - 1 + i)
            end
            ChanInfoArray[mem].switches = switch

            -- Get saved string
            local officerSwitch = db.officerSwitchFor[guildName]
            if officerSwitch and officerSwitch ~= "" then
                officerSwitch = officerSwitch .. " " .. L(SI_CHANNEL_SWITCH_OFFICER_1 - 1 + i)  
            else
                officerSwitch = L(SI_CHANNEL_SWITCH_OFFICER_1 - 1 + i)
            end
            ChanInfoArray[ofc].switches = officerSwitch
        end

    end

end

-- ---------------------------------------------------------------
-- Mention functions
--   functions manipulating a mention table is a list of tables (one per entry) containing
--   [1] = the entry to search for, [2] = the colorized version of the entry


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

-- split a mention string (one entry per line) into appropriate entries
-- in the mention table
-- returns the mention table
local function mention_split(newValue, col) 
    lines = {}
	newValue = newValue.."\r\n"
	local dv = newValue:gsub("[\r\n]",";")
	for s in dv:gmatch("(.-);+") do
		t_insert(lines, s)
    end
    --for s in newValue:gmatch("(.-)[\r\n]-") do
	--	d("match line: "..s)
    --   t_insert(lines, s)
    --end
    newtbl = {}
    for _,v in pairs(lines) do
        -- require minimum length
        if str_len(v) >= 4 then
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


-- Character Sync Option
local function SyncCharacterSelectChoices()
    local localPlayer = GetUnitName("player")
	local localId = GetCurrentCharacterId()
	
    -- Sync Character Select
    rData.chatConfSyncChoices = {}
    if db.chatConfSync then
        for names, tagada in pairs (db.chatConfSync) do
            if names ~= "lastChar" then
                t_insert(rData.chatConfSyncChoices, names)
            end
        end
    else
        t_insert(rData.chatConfSyncChoices, localPlayer)
    end
end

local function UpdateChoices(name, data)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(name)
    if dropdownCtrl == nil then
        return
    end
	dropdownCtrl:UpdateChoices(data.choices, data.choicesValues, data.choicesTooltips)  
end
rChat.UpdateChoices = UpdateChoices

-- ---------------------------------------------------------------------------

-- Triggered by EVENT_GUILD_SELF_JOINED_GUILD
local function OnSelfJoinedGuild(_, _, guildName)

    -- It will rebuild optionsTable and recreate tables if user didn't look in this section before
    rChat.BuildLAMPanel()

    -- Set db.formatguild[guildName] to default value if missing
    if not db.formatguild[guildName] then
        -- 2 is default value
        db.formatguild[guildName] = 2
    end

    -- Save Guild indexes for guild reorganization
    SaveGuildIndexes()

end

-- Revert category settings for a guild
local function RevertCategories(guildName)

    local localPlayer = GetUnitName("player")
    local playerInfo = db.chatConfSync[localPlayer]
    -- Old GuildId
    local oldIndex = rData.guildIndexes[guildName]
    -- old Total Guilds
    local totGuilds = GetNumGuilds() + 1

    if oldIndex and oldIndex < totGuilds then

        -- If our guild was not the last one, need to revert colors
        -- Does not need to reset chat settings for first guild if the 2nd has been left, same for 1-2/3 and 1-2-3/4
        for iGuilds=oldIndex, (totGuilds - 1) do

            -- If default channel was g1, keep it g1
            if not (db.tabs.defaultchannel == CHAT_CATEGORY_GUILD_1 or db.tabs.defaultchannel == CHAT_CATEGORY_OFFICER_1) then

                if db.tabs.defaultchannel == (CHAT_CATEGORY_GUILD_1 + iGuilds) then
                    db.tabs.defaultchannel = (CHAT_CATEGORY_GUILD_1 + iGuilds - 1)
                elseif db.tabs.defaultchannel == (CHAT_CATEGORY_OFFICER_1 + iGuilds) then
                    db.tabs.defaultchannel = (CHAT_CATEGORY_OFFICER_1 + iGuilds - 1)
                end

            end

            -- New Guild color for Guild #X is the old #X+1
            local gcolor = playerInfo.colors[CHAT_CATEGORY_GUILD_1 + iGuilds]
            SetChatCategoryColor(CHAT_CATEGORY_GUILD_1 + iGuilds - 1,
                gcolor.red, gcolor.green, gcolor.blue)

            -- New Officer color for Guild #X is the old #X+1
            gcolor = playerInfo.colors[CHAT_CATEGORY_OFFICER_1 + iGuilds]
            SetChatCategoryColor(CHAT_CATEGORY_OFFICER_1 + iGuilds - 1,
                gcolor.red, gcolor.green, gcolor.blue)

            -- Restore tab config previously set.
            local tabs = playerInfo.tabs
			if not CHAT_SYSTEM.primaryContainer then return end
            for numTab in ipairs (CHAT_SYSTEM.primaryContainer.windows) do
                if tabs[numTab] then
                    SetChatContainerTabCategoryEnabled(1, numTab, (CHAT_CATEGORY_GUILD_1 + iGuilds - 1),
                        tabs[numTab].enabledCategories[CHAT_CATEGORY_GUILD_1 + iGuilds])
                    SetChatContainerTabCategoryEnabled(1, numTab, (CHAT_CATEGORY_OFFICER_1 + iGuilds - 1),
                        tabs[numTab].enabledCategories[CHAT_CATEGORY_OFFICER_1 + iGuilds])
                end
            end

        end
    end

end

local function RegisterChatEvents()
    local evthdlrs = {
        [EVENT_CHAT_MESSAGE_CHANNEL] = FormatMessage,
        [EVENT_GROUP_TYPE_CHANGED] = OnGroupTypeChanged,
        [EVENT_IGNORE_ADDED] = OnIgnoreAdded,
        [EVENT_IGNORE_REMOVED] = OnIgnoreRemoved,
        [EVENT_GROUP_MEMBER_LEFT] = OnGroupMemberLeftLC
    }
	if db.enableFriendStatus then
		evthdlrs[EVENT_FRIEND_PLAYER_STATUS_CHANGED] = OnFriendPlayerStatusChanged
	end


    if CHAT_ROUTER and CHAT_ROUTER.RegisterMessageFormatter then
        for evtId, evthdlr in pairs(evthdlrs) do
            if evtId and evthdlr and type(evthdlr) == "function" then
                CHAT_ROUTER:RegisterMessageFormatter(evtId, evthdlr)
            end
        end
    end
end

local function LoadCommands(strargs)
	for switchArg in strargs:gmatch("%S+") do
		switchArg = switchArg:lower()
		SLASH_COMMANDS[switchArg] = WhisperLast
	end
end
rChat.LoadCommands = LoadCommands

local function OnPlayerActivated_ZoneLoad()
	if db.announce_zone == false then 
		return 
	end
	local zoneName = ZO_CachedStrFormat("<<C:1>>", GetZoneNameByIndex(GetCurrentMapZoneIndex()))
	d("Arrived in Zone: " ..zoneName)
end

-- Registers the formatMessage function with the libChat to handle chat formatting.
-- only executes once
local function OnPlayerActivated_Initialize()

    local hookmgr = rChat.hookmgr
    local evtmgr = rChat.evtmgr

    evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)
 
    rData.sceneFirst = false
    rData.activeTab = 1

	OnPlayerActivated_ZoneLoad()
    hookmgr:PreHook(CHAT_SYSTEM, "ValidateChatChannel", function(self)
            if self.currentChannel == CHAT_CHANNEL_WHISPER then
                return
            end
            if (db.tabs.enableChatTabChannel  == true) then
                local tabIndex = self.primaryContainer.currentBuffer:GetParent().tab.index
                db.chatTabChannel[tabIndex] = db.chatTabChannel[tabIndex] or {}
                local chattab = db.chatTabChannel[tabIndex]
                chattab.channel = self.currentChannel
                chattab.target  = self.currentTarget
            end
        end)

	if CHAT_SYSTEM.primaryContainer and CHAT_SYSTEM.primaryContainer.HandleTabClick then
		CHAT_SYSTEM.primaryContainer:AddFadeInReference()
		hookmgr:PreHook(CHAT_SYSTEM.primaryContainer, "HandleTabClick", function(self, tab)
            rData.activeTab = tab.index
            if (db.tabs.enableChatTabChannel == true) then
                local tabIndex = tab.index
                if db.chatTabChannel[tabIndex] then
                    CHAT_SYSTEM:SetChannel(db.chatTabChannel[tabIndex].channel, db.chatTabChannel[tabIndex].target)
                end
            end
        end)
	else
		rChat_Logger():Error("The CHAT_SYSTEM.primaryContainer is nil and was likely caused by accidental deletion of the primary chat tab.")
	end


    hookmgr:SecurePostHook("ZO_ChatSystem_ScrollToBottom", function(ctrl)
        rChat_RemoveIMNotification()
    end)

    -- Visual Notification PreHook
    hookmgr:PreHook(CHAT_SYSTEM, "Maximize", function(self)
        CHAT_SYSTEM.IMLabelMin:SetHidden(true)
    end)

    	local evtmgr = rChat.evtmgr

	-- make sure we are only called once
	evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)

    --LAM
    rChat.BuildLAM()
    UpdateChoices("RCHAT_TABNAMES_DD",{choices=rChat.tabNames:GetNames()})

    -- Set Window opaqueness
	rChat.ChangeChatWindowDarkness(true)

    -- Will set Keybind for "switch to next tab" if needed
    SetSwitchToNextBinding()

    -- Will change font if needed
    rChat.ChangeChatFont()

    -- Minimize Chat in Menus
    MinimizeChatInMenus()

    rChat.BuildNicknames()
    rChat.BuildFilterButtons()

    InitializeURLHandling()


    -- AntiSpam
    rData.spamLookingForEnabled = true
    rData.spamWantToEnabled = true
    rData.spamPriceCheckEnabled = true
    rData.spamGuildRecruitEnabled = true

    -- Show 1000 lines instead of 200 & Change fade delay
    ShowFadedLines()
    -- Load Chat Tab Names stored in chatTabNames {}
    rChat.tabNames:GetNames()
    -- Rebuild Lam Panel
    rChat.BuildLAMPanel()
    --
    CreateNewChatTab_PostHook()

    -- Should we minimize ?
    MinimizeChatAtLaunch()

    -- Message for new chars
    AutoSyncSettingsForNewPlayer()

    -- Chat Config synchronization
    SyncChatConfig(db.chatSyncConfig, "lastChar")
    SaveChatConfig()

	-- Guild stuff
    rChat.UpdateGuildChannelNames()
    rChat.UpdateGuildSwitches()
    SaveGuildIndexes()

	rChat.ZOS_CreateChannelData()
	rChat.LoadCommands(GetString(SI_CHANNEL_SWITCH_WHISPER_REPLY))

    -- Set up chat window(s)
    rChat.ChangeChatWindowDarkness()

    -- Restore History if needed
    RestoreChatHistory()

    -- Handle Copy text
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, OnLinkClicked)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)

    RegisterChatEvents()
    evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, OnPlayerActivated_ZoneLoad)
    SetDefaultTab(db.tabs.defaultTab)
    rChat.SetToDefaultChannel()
end


-- Runs whenever "me" left a guild (or gets kicked)
local function OnSelfLeftGuild(_, _, guildName)

    -- It will rebuild optionsTable and recreate tables if user didn't go in this section before
    rChat.BuildLAMPanel()

    -- Revert category colors & options
    RevertCategories(guildName)
end

local function SwitchToParty(characterName)

    zo_callLater( function(characterName)     -- characterName = avoid ZOS bug
            if not db.enablepartyswitch then return end
            -- Switch to party channel when joining a group
            if GetRawUnitName("player") == characterName then
                -- If "me" join group
                CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)

            elseif GetGroupSize() == 2 then
                -- Someone else joined group
                -- If GetGroupSize() == 2 : Means "me" just created a group and "someone" just joining
                CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY)
            end
        end,
        200
    )
    

end

-- Triggers when EVENT_GROUP_MEMBER_JOINED
local function OnGroupMemberJoined(_, characterName)
    SwitchToParty(characterName)
end

-- triggers when EVENT_GROUP_MEMBER_LEFT
local function OnGroupMemberLeft(_, characterName, reason, wasMeWhoLeft)

    if db.enablepartyswitch then
        -- Go back to default channel when leaving a group
        if GetGroupSize() <= 1 then
            -- Only if we was on party
            if CHAT_SYSTEM.currentChannel == CHAT_CHANNEL_PARTY and db.tabs.defaultchannel ~= RCHAT_CHANNEL_NONE then
                rChat.SetToDefaultChannel()
            end
        end
    end

end

-- Save a category color for guild chat, set by ChatSystem at launch + when user change manually
local function SaveChatCategoryColors(category, r, g, b)
    local confsync = db.chatConfSync[GetUnitName("player")]
    if confsync and confsync.colors then
        if confsync.colors[category] == nil then
            confsync.colors[category] = {}
        end
        confsync.colors[category] = { red = r, green = g, blue = b }
    end
end

function rChat.ClearChat()
	if not CHAT_SYSTEM.primaryContainer then return end
    local self = CHAT_SYSTEM.primaryContainer
    local tabIndex = (self.currentBuffer and self.currentBuffer:GetParent()
                            and self.currentBuffer:GetParent().tab
                            and self.currentBuffer:GetParent().tab.index)
	rData.tabNotBefore[tabIndex] = GetTimeStamp()
	self.windows[tabIndex].buffer:Clear()
	self:SyncScrollToBuffer()
end

-- PreHook of ZO_ChatSystem_ShowOptions() and ZO_ChatWindow_OpenContextMenu(control.index)
-- always returns true
local function ChatSystemShowOptions(tabIndex)
	if not CHAT_SYSTEM.primaryContainer then return end
    local self = CHAT_SYSTEM.primaryContainer
    tabIndex = tabIndex or (self.currentBuffer and self.currentBuffer:GetParent()
                            and self.currentBuffer:GetParent().tab
                            and self.currentBuffer:GetParent().tab.index)
    local window = self.windows[tabIndex]
    if not window then return true end

    ClearMenu()

    if not ZO_Dialogs_IsShowingDialog() then
        AddMenuItem(L(SI_CHAT_CONFIG_CREATE_NEW), function() 
			self.system:CreateNewChatTab(self)
		end)

        if not window.combatLog and (not self:IsPrimary() or tabIndex ~= 1) then
            AddMenuItem(L(SI_CHAT_CONFIG_REMOVE), function()
                self:ShowRemoveTabDialog(tabIndex)
            end)
        end

        AddMenuItem(L(SI_CHAT_CONFIG_OPTIONS), function()
            self:ShowOptions(tabIndex)
        end)
        AddMenuItem(L(RCHAT_CLEARBUFFER), function()
            rData.tabNotBefore[tabIndex] = GetTimeStamp()
            self.windows[tabIndex].buffer:Clear()
            self:SyncScrollToBuffer()
        end)
    end

    if self:IsPrimary() and tabIndex == 1 then
        if self:IsLocked(tabIndex) then
            AddMenuItem(L(SI_CHAT_CONFIG_UNLOCK), function() self:SetLocked(tabIndex, false) end)
        else
            AddMenuItem(L(SI_CHAT_CONFIG_LOCK), function() self:SetLocked(tabIndex, true) end)
        end
    end

    if window.combatLog then
        -- invert value
        local timestampFlag = (not self:AreTimestampsEnabled(tabIndex)) or false
        AddMenuItem(L(SI_CHAT_CONFIG_HIDE_TIMESTAMP), function()
            self:SetTimestampsEnabled(tabIndex, timestampFlag)
        end)
    end

    ShowMenu(window.tab)

    return true

end

-- Transfer values from old saved vars configurations to
-- new saved vars configurations.
local function SVvers(sv)

    -- conversion for saved variables from version 1.5.4 to 1.6
    local function convertWhisper()
        -- whisper.variables already provided by SF.defaultMissing
        -- just transfer values
        if sv.whispsoundEnabled ~= nil then
            sv.whisper.soundEnabled = sv.whispsoundEnabled
            sv.whispsoundEnabled = nil
        end
        if sv.soundforincwhisps ~= nil then
            sv.whisper.incomingsound = sv.soundforincwhisps
            sv.soundforincwhisps = nil
        end
        if sv.notifyIM ~= nil then
            sv.whisper.notifyIM = sv.notifyIM
            sv.notifyIM = nil
        end
    end
    
    convertWhisper()  -- v 1.6
	
	-- v 1.8
	if sv.delzonetags then
		sv.nozonetags = sv.delzonetags
		sv.delzonetags = nil
	end
	
	-- v 1.24
	if sv.tabs == nil then sv.tabs = {} end
	if sv.enableChatTabChannel then
		sv.tabs.enableChatTabChannel = sv.enableChatTabChannel
		sv.enableChatTabChannel = nil
	end
	if sv.defaultchannel then
		sv.tabs.defaultchannel = sv.defaultchannel
		sv.defaultchannel = nil
	end
	if sv.defaultTab then
		sv.tabs.defaultTab = sv.defaultTab
		sv.defaultTab = nil
	end
	if sv.defaultTabName then
		sv.tabs.defaultTabName = sv.defaultTabName
		sv.defaultTabName = nil
	end
end

local function clearSV(savedVars)
    for key, value in pairs(savedVars) do
        if key ~= "version" and type(value) ~= "function" then
            savedVars[key] = nil
        end
    end
end

-- loads saved variables for the account, returns the current
-- applicable settings
local function loadSavedVars(savedvar, sv_version, defaults)

    local save = ZO_SavedVars:NewAccountWide(savedvar, sv_version, nil, defaults)
	SF.defaultMissing(save.mention, defmention)
	SF.defaultMissing(save.spam, defspam)
	SF.defaultMissing(save.whisper, defwhisper)

    -- Transfer old saved vars to new
    SVvers(save)

    save.AddonEpoch = rChat.epoch

    return save
end

-- Please note that some things are delayed in OnPlayerActivated() 
-- because Chat isn't ready when this function triggers
local function OnAddonLoaded(_, addonName)

    --Protect
    if addonName ~= rChat.name then return end

    local evtmgr = rChat.evtmgr
    local hookmgr = rChat.hookmgr

    -- Unregisters
    evtmgr:unregEvt(EVENT_ADD_ON_LOADED)
    evtmgr:registerEvt(EVENT_ADD_ON_LOADED, OnAddonLoaded)

    rChat_ZOS.FormatSysMessage = FormatSysMessage
    rChat_ZOS.FormatMessage = FormatMessage
    rChat_ZOS.FindAutomatedMsg = RAM.FindAutomatedMsg
    rChat_ZOS.cachedMessages = rData.cachedMessages
    rChat_ZOS.saveMsg = function(text) end

    -- Load saved variables
    rChat.save = loadSavedVars(rChat.savedvar, rChat.sv_version, defaults)
    db = rChat.save
    -- new setting (provided in defaults)
    --db.mention.mentiontbl = SF.safeTable(db.mention.mentiontbl)
    --if not db.mention.emoteEnabled then db.mention.emoteEnabled = false end
    --if db.enableFriendStatus == nil then db.enableFriendStatus = true end
	
    
    -- init vars for antispam
    rChat.setSpamConfig(db.spam)

    -- init vars/funcs for ZOS rewritten functions
    rChat_ZOS.tabwarning_color = ZO_ColorDef:New(str_sub(db.colours["tabwarning"],3,8))
    -- add control for LibDebugLogger
    --rChat_ZOS.disableDebugLoggerBlocking = db.disableDebugLoggerBlocking
    
    if rChat.tabNames == nil then
        rChat.tabNames = rChat_TabNames:New()
    end
	
    local HRS_TO_SEC = 3600
    local maxage = GetTimeStamp() - (db.timeBeforeRestore * HRS_TO_SEC) - 1
    rChatData.initCache(maxage)

    if not db.chatTabChannel then
        db.chatTabChannel = {}
    end

    -- Automated messages
    rChat.InitAutomatedMessages()

    -- Resize, must be loaded before CHAT_SYSTEM is set
    CHAT_SYSTEM.maxContainerWidth, CHAT_SYSTEM.maxContainerHeight = GuiRoot:GetDimensions()

    -- PreHook ReloadUI, SetCVar, LogOut & Quit to handle Chat Import/Export
    local function saveHistandConf(tp)
        SaveChatHistory(tp)
        SaveChatConfig()
    end

    hookmgr:PreHook("ReloadUI", function()
        saveHistandConf(1)
    end)
    --ZO_PreHook("ReloadUI", function() saveHistandConf(1) end)

    hookmgr:PreHook("SetCVar", function()
        saveHistandConf(1)
    end)

    hookmgr:PreHook("Logout", function()
        saveHistandConf(2)
    end)

    hookmgr:PreHook("Quit", function()
        saveHistandConf(3)
    end)

    -- Social option change color
    hookmgr:PreHook("SetChatCategoryColor", SaveChatCategoryColors)

    -- Chat option change categories filters, add a callLater because 
    -- settings are set after this function triggers.
    
    hookmgr:PreHook("ZO_ChatOptions_ToggleChannel", function() 
            zo_callLater(function() SaveTabsCategories() end, 100) 
        end)
    

    -- Right click on a tab name
    hookmgr:PreHook("ZO_ChatSystem_ShowOptions", function(control) return ChatSystemShowOptions() end)
    hookmgr:PreHook("ZO_ChatWindow_OpenContextMenu", function(control) return ChatSystemShowOptions(control.index) end)
    
    -- handlers
    evtmgr:registerEvt(EVENT_GUILD_SELF_JOINED_GUILD, OnSelfJoinedGuild)
    evtmgr:registerEvt(EVENT_GUILD_SELF_LEFT_GUILD, OnSelfLeftGuild)
    evtmgr:registerEvt(EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
    evtmgr:registerEvt(EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    evtmgr:registerEvt(EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)

    isAddonLoaded = true
    evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, OnPlayerActivated_Initialize)
end



--Handled by keybind
function rChat.ToggleChat()

    if CHAT_SYSTEM:IsMinimized() then
        CHAT_SYSTEM:Maximize()
    else
        CHAT_SYSTEM:Minimize()
    end

end

-- Called by bindings
function rChat.WhispMyTarget()
    if targetToWhisp then
        CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, targetToWhisp)
    end
end

-- reimplement the reply to whisper slash command
local function WhisperLast()
    if lastwhisp ~= nil then
	    CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, lastwhisp)
	end
end

SLASH_COMMANDS["/clrwhs"] = function () lastwhisp = nil end

-- --------------------------------------------------
-- Addon compatibility functions
function rChat.formatSysMessage(statusMessage)
    return FormatSysMessage(statusMessage)
end

function rChat_FormatSysMessage(statusMessage)
    return FormatSysMessage(statusMessage)
end

function rChat_GetChannelColors(channel, from)
    return GetChannelColors(channel, from)
end
-- --------------------------------------------------

rChat.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, OnAddonLoaded)
