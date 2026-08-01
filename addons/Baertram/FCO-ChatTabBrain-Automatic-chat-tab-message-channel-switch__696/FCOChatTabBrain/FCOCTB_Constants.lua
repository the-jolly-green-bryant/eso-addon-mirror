--Create global variable of the addon FCOChatTabBrain
FCOCTB = {}
local FCOCTB = FCOCTB

--AddOn info
FCOCTB.addonVars = {}
FCOCTB.addonVars.gAddonName				= "FCOChatTabBrain"
FCOCTB.addonVars.addonNameMenu			= "FCO Chat Tab Brain"
FCOCTB.addonVars.addonNameMenuDisplay	= "|c00FF00FCO |cFFFF00Chat Tab Brain|r"
FCOCTB.addonVars.addonAuthor 			= '|cFFFF00Baertram|r'
FCOCTB.addonVars.addonVersion		   	= 0.06 --Attention: SavedVariables version! Do not change or settings get NILed
FCOCTB.addonVars.addonVersionOptions 	= '0.4.7'
FCOCTB.addonVars.addonVersionOptionsNumber = 0.470
FCOCTB.addonVars.addonWebsite			= "http://www.esoui.com/downloads/info696-FCOChatTabBrain.html#info"
FCOCTB.addonVars.addonDonation			= "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
FCOCTB.addonVars.addonFeedback			= "https://www.esoui.com/downloads/info696-FCOChatTabBrain.html#comments"
FCOCTB.addonVars.gAddonFullyLoaded     	= false
FCOCTB.addonVars.gSettingsLoaded        = false

--Libraries
FCOCTB.librariesLoadedProperly = false

--Constants
FCOCTB_CHAT_SOUND_GROUP_LEADER  = 1
FCOCTB_CHAT_SOUND_GUILD_MASTER  = 2
FCOCTB_CHAT_SOUND_FRIEND        = 3
FCOCTB_CHAT_SOUND_TEXT          = 4
FCOCTB_CHAT_SOUND_CHANNEL       = 5
FCOCTB_CHAT_SOUND_CHARACTER     = 6
FCOCTB_CHAT_SOUND_MAX           = FCOCTB_CHAT_SOUND_CHARACTER

--[[Variables]]

--Preventers
FCOCTB.preventerVars = {}
FCOCTB.preventerVars.gLocalizationDone = false
FCOCTB.preventerVars.KeyBindingTexts	= false
FCOCTB.preventerVars.noEditUpdate      = false
FCOCTB.preventerVars.noChatTextEntryCheck = false
FCOCTB.preventerVars.changingToNewChatTab = false
FCOCTB.preventerVars.fadingOut			= false
FCOCTB.preventerVars.fadingIn			= false
FCOCTB.preventerVars.settingsFirstCall = true
FCOCTB.preventerVars.timeNotReached	= false
FCOCTB.preventerVars.chatMinimizeButtonClicked = false
FCOCTB.preventerVars.defaultTabIdleTime = 0
FCOCTB.preventerVars.doNotDoShiftClickCheck = false
FCOCTB.preventerVars.scrollingChatTab = false

--Localization
FCOCTB.localizationVars = {}

--Settings / SavedVars
FCOCTB.settingsVars = {}
FCOCTB.settingsVars.settings			= {}
FCOCTB.settingsVars.defaultSettings		= {}
FCOCTB.settingsVars.firstRunSettings   	= {}
FCOCTB.settingsVars.defaults			= {}

--Numbers
FCOCTB.numVars = {}

--Languages
--Available languages
FCOCTB.numVars.languageCount = 8 --English, German, French, Spanish, Italian, Japanese, Russian, Chinese
FCOCTB.langVars = {}
FCOCTB.langVars.languages = {}
--Build the languages array
for i=1, FCOCTB.numVars.languageCount do
	FCOCTB.langVars.languages[i] = true
end

--Mapping
FCOCTB.mappingVars = {}
FCOCTB.mappingVars.chatMessageTypeToChatChannel = {
    [CHAT_CHANNEL_WHISPER]          = "/w",
    [CHAT_CHANNEL_GUILD_1]          = "/g1",
    [CHAT_CHANNEL_GUILD_2]          = "/g2",
    [CHAT_CHANNEL_GUILD_3]          = "/g3",
    [CHAT_CHANNEL_GUILD_4]          = "/g4",
    [CHAT_CHANNEL_GUILD_5]          = "/g5",
    [CHAT_CHANNEL_OFFICER_1]        = "/o1",
    [CHAT_CHANNEL_OFFICER_2]        = "/o2",
    [CHAT_CHANNEL_OFFICER_3]        = "/o3",
    [CHAT_CHANNEL_OFFICER_4]        = "/o4",
    [CHAT_CHANNEL_OFFICER_5]        = "/o5",
    [CHAT_CHANNEL_SAY]              = "/s",
    [CHAT_CHANNEL_PARTY]            = "/p",
    [CHAT_CHANNEL_YELL]             = "/y",
    [CHAT_CHANNEL_ZONE]             = "/z",
    [CHAT_CHANNEL_ZONE_LANGUAGE_1]  = "/zen",
    [CHAT_CHANNEL_ZONE_LANGUAGE_2]  = "/zfr",
    [CHAT_CHANNEL_ZONE_LANGUAGE_3]  = "/zde",
    [CHAT_CHANNEL_ZONE_LANGUAGE_4]  = "/zjp",
    [CHAT_CHANNEL_ZONE_LANGUAGE_5]  = "/zru",
    [CHAT_CHANNEL_ZONE_LANGUAGE_6]  = "/zes",
    [CHAT_CHANNEL_ZONE_LANGUAGE_7]  = "/zzh",
}
FCOCTB.mappingVars.activeChatChannels = {
    [CHAT_CHANNEL_EMOTE]  = false,
    [CHAT_CHANNEL_GUILD_1]  = true,
    [CHAT_CHANNEL_GUILD_2]  = true,
    [CHAT_CHANNEL_GUILD_3]  = true,
    [CHAT_CHANNEL_GUILD_4]  = true,
    [CHAT_CHANNEL_GUILD_5]  = true,
    [CHAT_CHANNEL_MONSTER_EMOTE]  = false,
    [CHAT_CHANNEL_MONSTER_SAY]  = true,
    [CHAT_CHANNEL_MONSTER_WHISPER]  = true,
    [CHAT_CHANNEL_MONSTER_YELL]  = true,
    [CHAT_CHANNEL_OFFICER_1]  = true,
    [CHAT_CHANNEL_OFFICER_2]  = true,
    [CHAT_CHANNEL_OFFICER_3]  = true,
    [CHAT_CHANNEL_OFFICER_4]  = true,
    [CHAT_CHANNEL_OFFICER_5]  = true,
    [CHAT_CHANNEL_PARTY]  = true,
    [CHAT_CHANNEL_SAY]  = true,
    [CHAT_CHANNEL_SYSTEM]  = true,
    [CHAT_CHANNEL_UNUSED_1]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_1]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_2]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_3]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_4]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_5]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_6]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_7]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_8]  = false,
    [CHAT_CHANNEL_USER_CHANNEL_9]  = false,
    [CHAT_CHANNEL_WHISPER]  = true,
    [CHAT_CHANNEL_WHISPER_SENT]  = false,
    [CHAT_CHANNEL_YELL]  = true,
    [CHAT_CHANNEL_ZONE]  = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_1]  = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_2]  = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_3]  = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_4]  = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_5]  = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_6]  = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_7]  = true,
}
FCOCTB.mappingVars.activeChatChannelsCategories = {}
for chatChannelId, isEnabled in pairs(FCOCTB.mappingVars.activeChatChannels) do
    if isEnabled == true then
        local channelCategory = GetChannelCategoryFromChannel(chatChannelId)
        if channelCategory then
            FCOCTB.mappingVars.activeChatChannelsCategories[chatChannelId] = channelCategory
        end
    end
end
--The guild related chat channels
FCOCTB.mappingVars.guildChatChannels = {
    [CHAT_CHANNEL_GUILD_1]  = true,
    [CHAT_CHANNEL_GUILD_2]  = true,
    [CHAT_CHANNEL_GUILD_3]  = true,
    [CHAT_CHANNEL_GUILD_4]  = true,
    [CHAT_CHANNEL_GUILD_5]  = true,
    [CHAT_CHANNEL_OFFICER_1]  = true,
    [CHAT_CHANNEL_OFFICER_2]  = true,
    [CHAT_CHANNEL_OFFICER_3]  = true,
    [CHAT_CHANNEL_OFFICER_4]  = true,
    [CHAT_CHANNEL_OFFICER_5]  = true,
}

--Chat
FCOCTB.chatVars = {}
FCOCTB.chatVars.lastUserActiveTime = 0
FCOCTB.chatVars.chatTabNames       = {}
FCOCTB.chatVars.lastIncomingMessage = 0
FCOCTB.chatVars.chatMinimizeTimerActive = false
FCOCTB.chatVars.lastIncomingChatChannel = ""
FCOCTB.chatVars.lastIncomingChatChannelType = ""

--Chat options
FCOCTB.chatOptionsVars = {}
FCOCTB.chatOptionsVars.markToggleCheckbox       = nil
FCOCTB.chatOptionsVars.markToggleFilterCheckbox = nil
FCOCTB.chatOptionsVars.markToggleGuildCheckbox  = nil
FCOCTB.chatOptionsVars.hasAllMarked        = false
FCOCTB.chatOptionsVars.hasAllFilterMarked  = false
FCOCTB.chatOptionsVars.hasAllGuildMarked   = false

--Whisper
FCOCTB.whisperVars = {}
FCOCTB.whisperVars.currentText  = ""
FCOCTB.whisperVars.lastReceiver = ""
FCOCTB.whisperVars.whisperReply = false

--Sounds
FCOCTB.sounds = {}