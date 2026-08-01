local L = GetString


-- contains insertion functions and data references to allow rChat to
-- affect the operation of the revised core ZOS functions below.
rChat_ZOS = {
    FormatSysMessage = function() end,     -- function
    FormatMessage = function() end,     -- function
    FindAutomatedMsg = function(txt) end,
    cachedMessages = {},        -- table of messages for chat restoring
    messagesWereRestored = false, -- bool  (was messagesHaveBeenRestorated)
    tabwarning_color = ZO_ColorDef:New("76BCC3"), -- tab Warning ~ "Azure" (ZOS default),
    --disableDebugLoggerBlocking = true,
}


function CHAT_ROUTER.AddSystemMessage(self,messageText)
    if not IsChatSystemAvailableForCurrentPlatform() then
        table.insert(rChat_ZOS.cachedMessages, messageText)
        return
    end

    self:FireCallbacks("FormattedChatMessage", messageText, CHAT_CATEGORY_SYSTEM)
end
--[[
-- Modification of core function from chathandlers.lua to save messages to table if chat system is not up yet
function CHAT_ROUTER:AddSystemMessage(messageText)
    if not IsChatSystemAvailableForCurrentPlatform() then
        table.insert(rChat_ZOS.cachedMessages, messageText)
        return
    end
    self:FormatAndAddChatMessage("AddSystemMessage", messageText)
end

function CHAT_ROUTER.AddDebugMessage(self,messageText)
    self:AddSystemMessage(messageText)
end
--]]


-- from libraries\utility\zo_tabbuttongroup.lua
-- Rewrite of core function to use saved var color instead of parameter
function ZO_TabButton_Text_SetTextColor(control, color)
    if control.allowLabelColorChanges then
        local label = control:GetNamedChild("Text")
        if rChat_ZOS.tabwarning_color then
            label:SetColor(rChat_ZOS.tabwarning_color:UnpackRGBA())
        else
            label:SetColor(color:UnpackRGBA())
        end
    end
end

--
--

-- from ingame\chatsystem\chatoptions.lua
-- Copy of a core data (nothing changed)
local FILTERS_PER_ROW = 2

-- from ingame\chatsystem\chatoptions.lua
-- Copy of a core data (SYSTEM added)
-- defines the ordering of the filter categories
local CHANNEL_ORDERING_WEIGHT = {
    [CHAT_CATEGORY_SAY] = 10,
    [CHAT_CATEGORY_YELL] = 20,

    [CHAT_CATEGORY_WHISPER_INCOMING] = 30,
    [CHAT_CATEGORY_PARTY] = 40,

    [CHAT_CATEGORY_EMOTE] = 50,
    [CHAT_CATEGORY_MONSTER_SAY] = 60,

    [CHAT_CATEGORY_ZONE] = 80,

    [CHAT_CATEGORY_ZONE_ENGLISH] = 90,
    [CHAT_CATEGORY_ZONE_FRENCH] = 100,
    [CHAT_CATEGORY_ZONE_GERMAN] = 110,
    [CHAT_CATEGORY_ZONE_JAPANESE] = 120,
    [CHAT_CATEGORY_ZONE_RUSSIAN] = 130,
    [CHAT_CATEGORY_ZONE_SPANISH] = 140,
    [CHAT_CATEGORY_ZONE_CHINESE_S] = 150,

    [CHAT_CATEGORY_SYSTEM] = 200,

}

-- Copy of a core function (from chatoptions.lua) (unchanged)
-- used by BuildFilterButtons
local function FilterComparator(left, right)
    local leftPrimaryCategory = left.channels[1]
    local rightPrimaryCategory = right.channels[1]

    local leftWeight = CHANNEL_ORDERING_WEIGHT[leftPrimaryCategory]
    local rightWeight = CHANNEL_ORDERING_WEIGHT[rightPrimaryCategory]

    if leftWeight and rightWeight then
        return leftWeight < rightWeight
    elseif not leftWeight and not rightWeight then
        return false
    elseif leftWeight then
        return true
    end

    return false
end

-- from ingame\chatsystem\chatoptions.lua
-- Copy of a core data
-- (CHAT_CATEGORY_SYSTEM is commented out from ZOS defaults so we can select/unselect
-- system messages in a chat tab)
local SKIP_CHANNELS = {
    -- [CHAT_CATEGORY_SYSTEM] = true,
    [CHAT_CATEGORY_GUILD_1] = true,
    [CHAT_CATEGORY_GUILD_2] = true,
    [CHAT_CATEGORY_GUILD_3] = true,
    [CHAT_CATEGORY_GUILD_4] = true,
    [CHAT_CATEGORY_GUILD_5] = true,
    [CHAT_CATEGORY_OFFICER_1] = true,
    [CHAT_CATEGORY_OFFICER_2] = true,
    [CHAT_CATEGORY_OFFICER_3] = true,
    [CHAT_CATEGORY_OFFICER_4] = true,
    [CHAT_CATEGORY_OFFICER_5] = true,
}

local FILTER_PAD_X = 90
local FILTER_PAD_Y = 0
local FILTER_WIDTH = 150
local FILTER_HEIGHT = 27
local INITIAL_XOFFS = 0
local INITIAL_YOFFS = 0

-- from ingame\chatsystem\chatoptions.lua
-- Copy of a core data
-- (Nothing is changed)
--defines channels to be combined under one button
local COMBINED_CHANNELS = {
    [CHAT_CATEGORY_WHISPER_INCOMING] = {
		parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, 
		name = SI_CHAT_CHANNEL_NAME_WHISPER},
    [CHAT_CATEGORY_WHISPER_OUTGOING] = {
		parentChannel = CHAT_CATEGORY_WHISPER_INCOMING, 
		name = SI_CHAT_CHANNEL_NAME_WHISPER},

    [CHAT_CATEGORY_MONSTER_SAY] = {
		parentChannel = CHAT_CATEGORY_MONSTER_SAY, 
		name = SI_CHAT_CHANNEL_NAME_NPC},
    [CHAT_CATEGORY_MONSTER_YELL] = {
		parentChannel = CHAT_CATEGORY_MONSTER_SAY, 
		name = SI_CHAT_CHANNEL_NAME_NPC},
    [CHAT_CATEGORY_MONSTER_WHISPER] = {
		parentChannel = CHAT_CATEGORY_MONSTER_SAY, 
		name = SI_CHAT_CHANNEL_NAME_NPC},
    [CHAT_CATEGORY_MONSTER_EMOTE] = {
		parentChannel = CHAT_CATEGORY_MONSTER_SAY, 
		name = SI_CHAT_CHANNEL_NAME_NPC},
}


-- Reimplementation of a core function based on ChatOptions:BuildFilterButtons from chatoptions.lua. 
-- Nothing is changed except in SKIP_CHANNELS set as above
--  (Allows us to be able to set if we want to filter system messages.)
-- Used to be an override, but the original is only called once before this addon loads.
-- So, created an rChat version to call on our own addon load to modify the tables/controls.
function rChat.BuildFilterButtons(dialogControl)
    --generate a table of entry data from the chat category header information
    local entryData = {}
    local lastEntry = CHAT_CATEGORY_HEADER_COMBAT - 1

    for i = CHAT_CATEGORY_HEADER_CHANNELS, lastEntry do
        if not IsChannelCategoryCommunicationRestricted(i) then
            if SKIP_CHANNELS[i] == nil and GetString("SI_CHATCHANNELCATEGORIES", i) ~= "" then
                if COMBINED_CHANNELS[i] == nil then
                    entryData[i] =
                    {
                        channels = { i },
                        name = GetString("SI_CHATCHANNELCATEGORIES", i),
                    }
                else
                    --create the entry for those with combined channels just once
                    local parentChannel = COMBINED_CHANNELS[i].parentChannel

                    if not entryData[parentChannel] then
                        entryData[parentChannel] =
                        {
                            channels = {},
                            name = GetString(COMBINED_CHANNELS[i].name),
                        }
                    end

                    table.insert(entryData[parentChannel].channels, i)
                end
            end
        end
    end
    --now generate and anchor buttons
    local filterAnchor = ZO_Anchor:New(TOPLEFT, CHAT_OPTIONS.filterSection, TOPLEFT, 0, 0)
    local count = 0

    local sortedEntries = {}
    for _, entry in pairs(entryData) do
        sortedEntries[#sortedEntries + 1] = entry
    end

    table.sort(sortedEntries, FilterComparator)

    for _, entry in ipairs(sortedEntries) do
        local filter = CHAT_OPTIONS.filterPool:AcquireObject()

        local button = filter:GetNamedChild("Check")
        ZO_CheckButton_SetLabelText(button, entry.name)
        button.channels = entry.channels
        table.insert(CHAT_OPTIONS.filterButtons, button)

        ZO_Anchor_BoxLayout(filterAnchor, filter, count, FILTERS_PER_ROW, FILTER_PAD_X, FILTER_PAD_Y, FILTER_WIDTH, FILTER_HEIGHT, INITIAL_XOFFS, INITIAL_YOFFS)
        count = count + 1
    end
end



-- from ingame\chatsystem\sharedchatsystem.lua
-- Rewrite of a core function
--  Insert processing for automated messages
function KEYBOARD_CHAT_SYSTEM.textEntry:GetText()
    local text = self.editControl:GetText() -- the original total content of this func

    --  Insert processing for automated messages below
    -- make sure we have something to work with
    if not text then return text end

    local st,en,nm = string.find(text,"%s*(!%a+)")
    if not st then return text end
    if string.len(nm) > 12 then return text end

    -- replace automated message indicator with message
    local v, k = rChat_ZOS.FindAutomatedMsg(nm)
    if not v then return text end   -- no such indicator

    text = v.message
    -- replace the automsg indicator with message
    local strln = string.len(v.message)
    if strln > 0 and strln < 352 then
        text = v.message
    end

    -- this is required to properly display the replaced message in chat
    KEYBOARD_CHAT_SYSTEM:OnTextEntryChanged(text)    -- in sharedchatsystem.lua

    -- adjustments required by automated messages
    self.ignoreTextEntryChangedEvent = true
    local spaceStart, spaceEnd = zo_strfind(text, " ", 1, true)
    if spaceStart and spaceStart > 1 then
        text = zo_strsub(text, spaceStart + 1)
        local oldCursorPos = KEYBOARD_CHAT_SYSTEM.textEntry:GetCursorPosition()

        spaceStart = spaceStartOverride or spaceStart
    end
    self.ignoreTextEntryChangedEvent = false
    return text
end

-- recreated from 5.2 ingame\chatsystem\sharedchatsystem.lua
-- initialization was moved to ingame\chatsystem\chatdata.lua, but
-- is no longer callable.
--
-- we need this function to rebuild the switchLookup after we make
-- modifications to guild switch settings
--
-- Build switch lookup table
-- A switch is a string, eg "/zone", which you can start your chat message with to make sure it goes to a specific channel.
-- This lookup table has two kinds of entries in it:
-- * switch string -> channel data.
--     This is used to pick a channel based on the player's message and switch string.
-- * channel ID -> switch string.
--     This is used to enumerate what kinds of channels are available and what switch string you can use to refer to them.
--     Each channel can have multiple switches, in which case only the first switch string is used.
--
function rChat.ZOS_CreateChannelData()
    local g_switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()
    local channelInfo = ZO_ChatSystem_GetChannelInfo()
    --
    for channelId, data in pairs(channelInfo) do
        data.id = channelId

        if data.switches then
            for switchArg in data.switches:gmatch("%S+") do
                switchArg = switchArg:lower()
                g_switchLookup[switchArg] = data
                if not g_switchLookup[channelId] then
                    g_switchLookup[channelId] = switchArg
                end
            end
        end

        if data.targetSwitches then
            local targetData = ZO_ShallowTableCopy(data)
            targetData.target = channelId
            for switchArg in data.targetSwitches:gmatch("%S+") do
                switchArg = switchArg:lower()
                g_switchLookup[switchArg] = targetData
                if not g_switchLookup[channelId] then
                    g_switchLookup[channelId] = switchArg
                end
            end
        end
    end
    CHAT_SYSTEM.switchLookup = g_switchLookup
    --
end
