FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

local function LoadSettingsWorkarounds()
    --React on variable name change from "choosen" to "chosen"
    local settings = FCOCTB.settingsVars.settings
    if settings.languageChosen == nil and settings.languageChoosen ~= nil then
        settings.languageChosen = settings.languageChoosen
        --Remove the old variable from the SavedVars
        settings.languageChoosen = nil
    end
    --System chat got no own chat channel so auto switiching to it won't work
    settings.autoChangeToChannelSystem = false
    --NSC chat got no own chat channel so auto switiching to it won't work
    settings.autoChangeToChannelNSC = false
end

local function NamesToIDSavedVars()
    --Are the character settings enabled? If not abort here
    if (FCOCTB.settingsVars.defaultSettings.saveMode ~= 1) then return nil end
    --Did we move the character name settings to character ID settings already?
    if not FCOCTB.settingsVars.settings.namesToIDSavedVars then
        local doMove
        local charName
        local displayName = GetDisplayName()
        --Check all the characters of the account
        for i = 1, GetNumCharacters() do
            local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
            charName = name
            charName = zo_strformat(SI_UNIT_NAME, charName)
            --If the current logged in character was found
            if GetUnitName("player") == name and FCOChatTabBrain_Settings.Default[displayName][charName] then
                doMove = true
                break -- exit the loop
            end
        end
        --Move the settings from the old character name ones to the new character ID settings now
        if doMove then
            FCOCTB.settingsVars.settings = FCOChatTabBrain_Settings.Default[displayName][charName]
            --Set a flag that the settings were moved
            FCOCTB.settingsVars.settings.namesToIDSavedVars = true -- should not be necessary because data don't exist anymore in FCOItemSaver_Settings.Default[displayName][name]
        end
    end
end

function FCOCTB.LoadUserSettings()
    --Only load the user settings once!
    if FCOCTB.addonVars.gSettingsLoaded then return end
    local addonVars = FCOCTB.addonVars

    --The default values for the language and save mode
    FCOCTB.settingsVars.firstRunSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    FCOCTB.settingsVars.defaults = {
        namesToIDSavedVars        = false,
        languageChosen			  = false,
        alwaysUseClientLanguage	  = true,
        chatBrainActive			  = true,
        brain					  = {},
        reOpenChatIfMinimized     = true,
        fadeOutChatButtons        = true,
        --fadeOutChatButtonsMailDelay = 5000,
        redirectWhisperChannelId  = 0,
        autoOpenWhisperIdleTime   = 5,
        autoOpenWhisperTab        = false,
        fadeInChatOnCycle         = false,
        chatMinimizeOnLoad        = false,
        autoOpenSayChannelId      = 0,
        autoOpenYellChannelId     = 0,
        autoOpenGuild1ChannelId   = 0,
        autoOpenGuild2ChannelId   = 0,
        autoOpenGuild3ChannelId   = 0,
        autoOpenGuild4ChannelId   = 0,
        autoOpenGuild5ChannelId   = 0,
        autoOpenOfficer1ChannelId = 0,
        autoOpenOfficer2ChannelId = 0,
        autoOpenOfficer3ChannelId = 0,
        autoOpenOfficer4ChannelId = 0,
        autoOpenOfficer5ChannelId = 0,
        autoOpenZoneChannelId     = 0,
        autoOpenZoneDEChannelId   = 0,
        autoOpenZoneENChannelId   = 0,
        autoOpenZoneFRChannelId   = 0,
        autoOpenZoneJPChannelId   = 0,
        autoOpenZoneRUChannelId   = 0,
        autoOpenZoneESChannelId   = 0,
        autoOpenZoneZHChannelId   = 0,
        autoOpenGroupChannelId    = 0,
        autoOpenSystemChannelId   = 0,
        autoOpenNSCChannelId      = 0,
        switchToDefaultChatTabAfterIdleTabId = 0,
        switchToDefaultChatTabAfterIdleTime = 10,
        autoOpenSayIdleTime       = 10,
        autoOpenYellIdleTime      = 10,
        autoOpenGuild1IdleTime    = 10,
        autoOpenGuild2IdleTime    = 10,
        autoOpenGuild3IdleTime    = 10,
        autoOpenGuild4IdleTime    = 10,
        autoOpenGuild5IdleTime    = 10,
        autoOpenOfficer1IdleTime  = 10,
        autoOpenOfficer2IdleTime  = 10,
        autoOpenOfficer3IdleTime  = 10,
        autoOpenOfficer4IdleTime  = 10,
        autoOpenOfficer5IdleTime  = 10,
        autoOpenZoneIdleTime      = 10,
        autoOpenZoneDEIdleTime    = 10,
        autoOpenZoneENIdleTime    = 10,
        autoOpenZoneFRIdleTime    = 10,
        autoOpenZoneJPIdleTime    = 10,
        autoOpenZoneRUIdleTime    = 10,
        autoOpenZoneESIdleTime    = 10,
        autoOpenZoneZHIdleTime    = 10,
        autoOpenGroupIdleTime     = 10,
        autoOpenSystemIdleTime    = 10,
        autoOpenNSCIdleTime       = 10,
        doNotAutoOpenIfGrouped      = true,
        doAutoOpenWhisperIfGrouped  = true,
        autoMinimizeTimeout         = 0,
        doNotAutoOpenIfMinimized    = false,
        preferedSoundForMultiple    = 1,
        playSoundOnMessageSay       = 1,
        playSoundWithActiveTabSay   = false,
        playSoundOnMessageYell      = 1,
        playSoundWithActiveTabYell  = false,
        playSoundOnMessageGuild1    = 1,
        playSoundWithActiveTabGuild1= false,
        playSoundOnMessageGuild2    = 1,
        playSoundWithActiveTabGuild2= false,
        playSoundOnMessageGuild3    = 1,
        playSoundWithActiveTabGuild3= false,
        playSoundOnMessageGuild4    = 1,
        playSoundWithActiveTabGuild4= false,
        playSoundOnMessageGuild5    = 1,
        playSoundWithActiveTabGuild5= false,
        playSoundOnMessageOfficer1    = 1,
        playSoundWithActiveTabOfficer1= false,
        playSoundOnMessageOfficer2    = 1,
        playSoundWithActiveTabOfficer2= false,
        playSoundOnMessageOfficer3    = 1,
        playSoundWithActiveTabOfficer3= false,
        playSoundOnMessageOfficer4    = 1,
        playSoundWithActiveTabOfficer4= false,
        playSoundOnMessageOfficer5    = 1,
        playSoundWithActiveTabOfficer5= false,
        playSoundOnMessageZone      = 1,
        playSoundWithActiveTabZone  = false,
        playSoundOnMessageZoneDE    = 1,
        playSoundWithActiveTabZoneDE= false,
        playSoundOnMessageZoneEN    = 1,
        playSoundWithActiveTabZoneEN= false,
        playSoundOnMessageZoneFR    = 1,
        playSoundWithActiveTabZoneFR= false,
        playSoundOnMessageZoneJP    = 1,
        playSoundWithActiveTabZoneJP= false,
        playSoundOnMessageZoneRU    = 1,
        playSoundWithActiveTabZoneRU= false,
        playSoundOnMessageZoneES    = 1,
        playSoundWithActiveTabZoneES= false,
        playSoundOnMessageZoneZH    = 1,
        playSoundWithActiveTabZoneZH= false,
        playSoundOnMessageGroup     = 1,
        playSoundWithActiveTabGroupLeader = false,
        playSoundWithActiveTabGroup = false,
        playSoundOnGroupLeader      = 1,
        playSoundOnGuildMaster      = 1,
        playSoundOnGuildMasterOnlyGuildTabs = false,
        playSoundWithActiveTabGuildMaster = false,
        groupLeaderSoundInPvPOnly   = false,
        playSoundOnMessageSystem    = 1,
        playSoundWithActiveTabSystem= false,
        playSoundOnMessageNSC       = 1,
        playSoundWithActiveTabNSC   = false,
        playSoundOnMessageFriend    = 1,
        playSoundOnMessageTextFound = 1,
        playSoundOnMessageWhisper   = 1,
        playSoundWithActiveTabWhisper  = false,
        playSoundOnMyCharacterName  = 1,
        chatKeyWords                = "",
        chatIgnoreNames             = "",
        autoChangeToChannelSay      = false,
        autoChangeToChannelYell     = false,
        autoChangeToChannelGuild1   = false,
        autoChangeToChannelGuild2   = false,
        autoChangeToChannelGuild3   = false,
        autoChangeToChannelGuild4   = false,
        autoChangeToChannelGuild5   = false,
        autoChangeToChannelOfficer1 = false,
        autoChangeToChannelOfficer2 = false,
        autoChangeToChannelOfficer3 = false,
        autoChangeToChannelOfficer4 = false,
        autoChangeToChannelOfficer5 = false,
        autoChangeToChannelZone     = false,
        autoChangeToChannelZoneDE   = false,
        autoChangeToChannelZoneEN   = false,
        autoChangeToChannelZoneFR   = false,
        autoChangeToChannelZoneJP   = false,
        autoChangeToChannelZoneRU   = false,
        autoChangeToChannelZoneES   = false,
        autoChangeToChannelZoneZH   = false,
        autoChangeToChannelGroup    = false,
        autoChangeToChannelSystem   = false,
        autoChangeToChannelNSC      = false,
        disableChatSounds           = false,
        showChatTabColor			= true,
        enableChatTabSwitch         = true,
        clearChatBufferOnShiftClick = false,
        maximizeChatOnMouseHoverOverMaximizeButton = false,
        fadeOutChatTime             = 3000,
        fadeOutChatButtonsTime      = 3000,
        dontChangeChatChannelIfTextEditActive = false,
        sendingMessageOverwritesChatChannel = false,
        rememberLastActiveChatTab = false,
        lastActiveChatTab = 1,
        hideIconsInMinimizedChatWindow = false,
        lastUsedChatChannelsAtTab = {},
        autoScrollToChatBottomUponNewIncomingMsg = false,
        autoScrollToChatBottomUponKeybindTabSwitch = false,
    }

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOCTB.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.gAddonName .. "_Settings", 999, "SettingsForAll", FCOCTB.settingsVars.firstRunSettings)
    --d("[Settings] From SavedVars: language" .. tostring(FCOCTB.settingsVars.defaultSettings.language) .. ", saveMode: " .. tostring(FCOCTB.settingsVars.defaultSettings.saveMode))
    --d("[Settings] From FirstRun : language" .. tostring(FCOCTB.settingsVars.firstRunSettings.language) .. ", saveMode: " .. tostring(FCOCTB.settingsVars.firstRunSettings.saveMode))
    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (FCOCTB.settingsVars.defaultSettings.saveMode == 1) then
        --d(">Settings, SaveMode: Each character")
        FCOCTB.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonVars.gAddonName .. "_Settings", addonVars.addonVersion , "Settings", FCOCTB.settingsVars.defaults)
        --Transfer the data from the name to the unique ID SavedVars now
        NamesToIDSavedVars()
    elseif (FCOCTB.settingsVars.defaultSettings.saveMode == 2) then
        --d(">Settings, SaveMode: Account wide")
        FCOCTB.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.gAddonName .. "_Settings", addonVars.addonVersion, "Settings", FCOCTB.settingsVars.defaults)
    else
        --d(">Settings, SaveMode: Not set! Using account wide")
        FCOCTB.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.gAddonName .. "_Settings", addonVars.addonVersion, "Settings", FCOCTB.settingsVars.defaults)
    end
    --=============================================================================================================

    --Load some needed workarounds for the settings
    LoadSettingsWorkarounds()
    --d(">> AlwaysUseClientLanguage: " .. tostring(FCOCTB.settingsVars.settings.alwaysUseClientLanguage) .. ", languageChosen: " .. tostring(FCOCTB.settingsVars.settings.languageChosen) .. ", language: " ..tostring(FCOCTB.settingsVars.defaultSettings.language))
    addonVars.gSettingsLoaded = true
end