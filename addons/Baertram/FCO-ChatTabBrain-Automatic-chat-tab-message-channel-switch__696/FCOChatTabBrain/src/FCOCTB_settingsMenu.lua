FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

local chatSystem = FCOCTB.ChatSystem

local function updateGuildNames()
    --Get the guild names
    FCOCTB.guildNames = {}
    FCOCTB.guildNames = FCOCTB.GetGuildNames()
end

local function areGuildsEnabled(numberOfGuilds)
    if not numberOfGuilds then return true end
    local numGuilds = GetNumGuilds()
    if not numGuilds or numGuilds >= numberOfGuilds then return true end
    return false
end

-- Build the menu
function FCOCTB.BuildAddonMenu()
    local LAM = FCOCTB.LAM
    if LAM == nil then return end

    chatSystem = FCOCTB.ChatSystem

    local FCOCTBaddonVars = FCOCTB.addonVars
    local addonName = FCOCTBaddonVars.gAddonName
    local FCOCTBsetVars = FCOCTB.settingsVars
    local FCOCTBdefSettings = FCOCTBsetVars.defaults
    local FCOCTBsettings = FCOCTBsetVars.settings
    local FCOCTBlocVars = FCOCTB.localizationVars
    local FCOCTBlocVarsCTB = FCOCTBlocVars.fco_ctb_loc
    local chatVars = FCOCTB.chatVars

    local panelData = {
        type 				= 'panel',
        name   				= FCOCTBaddonVars.addonNameMenu,
        displayName 		= FCOCTBaddonVars.addonNameMenuDisplay,
        author 				= FCOCTBaddonVars.addonAuthor,
        version 			= FCOCTBaddonVars.addonVersionOptions,
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand 		= "/fcoctbs",
        website             = FCOCTBaddonVars.addonWebsite,
        feedback            = FCOCTBaddonVars.addonFeedback,
        donation            = FCOCTBaddonVars.addonDonation,
    }

    --Get the guild names for the LAM settings panel submenus
    updateGuildNames()

    -- !!! RU Patch Section START
    --  Add english language description behind language descriptions in other languages
    local function nvl(val) if val == nil then return "..." end return val end
    local LV_Cur = FCOCTBlocVarsCTB
    local LV_Eng = FCOCTBlocVars.localizationAll[1]
    local languageOptions = {}
    for i=1, FCOCTB.numVars.languageCount do
        local s="options_language_dropdown_selection"..i
        if LV_Cur==LV_Eng then
            languageOptions[i] = nvl(LV_Cur[s])
        else
            languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
        end
    end
    FCOCTB.lo = languageOptions
    -- !!! RU Patch Section END

    local savedVariablesOptions = {
        [1] = FCOCTBlocVarsCTB["options_savedVariables_dropdown_selection1"],
        [2] = FCOCTBlocVarsCTB["options_savedVariables_dropdown_selection2"],
    }
    local preferedForMultipleSelections = {
        [FCOCTB_CHAT_SOUND_GROUP_LEADER]    = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_groupleader"],
        [FCOCTB_CHAT_SOUND_GUILD_MASTER]    = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_guildmaster"],
        [FCOCTB_CHAT_SOUND_FRIEND]          = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_friend"],
        [FCOCTB_CHAT_SOUND_TEXT]            = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_text_found"],
        [FCOCTB_CHAT_SOUND_CHANNEL]         = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_chat_channel"],
        [FCOCTB_CHAT_SOUND_CHARACTER]       = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_character_name"],
    }
    local FCOCTBSettingsPanel = LAM:RegisterAddonPanel(addonName .. "_LAM", panelData)
    --The comboxboes with the chat tab control names
    local chatTabLAMControls = {
        ["FCOChatTabBrainTabAfterIdle"] = FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId,
        ["FCOChatTabBrainTabWhisper"] = FCOCTBsettings.redirectWhisperChannelId,
        ["FCOChatTabBrainTabSay"] = FCOCTBsettings.autoOpenSayChannelId,
        ["FCOChatTabBrainTabYell"] = FCOCTBsettings.autoOpenYellChannelId,
        ["FCOChatTabBrainTabGuild1"] = FCOCTBsettings.autoOpenGuild1ChannelId,
        ["FCOChatTabBrainTabGuild2"] = FCOCTBsettings.autoOpenGuild2ChannelId,
        ["FCOChatTabBrainTabGuild3"] = FCOCTBsettings.autoOpenGuild3ChannelId,
        ["FCOChatTabBrainTabGuild4"] = FCOCTBsettings.autoOpenGuild4ChannelId,
        ["FCOChatTabBrainTabGuild5"] = FCOCTBsettings.autoOpenGuild5ChannelId,
        ["FCOChatTabBrainTabOfficer1"] = FCOCTBsettings.autoOpenOfficer1ChannelId,
        ["FCOChatTabBrainTabOfficer2"] = FCOCTBsettings.autoOpenOfficer2ChannelId,
        ["FCOChatTabBrainTabOfficer3"] = FCOCTBsettings.autoOpenOfficer3ChannelId,
        ["FCOChatTabBrainTabOfficer4"] = FCOCTBsettings.autoOpenOfficer4ChannelId,
        ["FCOChatTabBrainTabOfficer5"] = FCOCTBsettings.autoOpenOfficer5ChannelId,
        ["FCOChatTabBrainTabZone"] = FCOCTBsettings.autoOpenZoneChannelId,
        ["FCOChatTabBrainTabZoneDE"] = FCOCTBsettings.autoOpenZoneDEChannelId,
        ["FCOChatTabBrainTabZoneEN"] = FCOCTBsettings.autoOpenZoneENChannelId,
        ["FCOChatTabBrainTabZoneFR"] = FCOCTBsettings.autoOpenZoneFRChannelId,
        ["FCOChatTabBrainTabZoneJP"] = FCOCTBsettings.autoOpenZoneJPChannelId,
        ["FCOChatTabBrainTabZoneRU"] = FCOCTBsettings.autoOpenZoneRUChannelId,
        ["FCOChatTabBrainTabZoneES"] = FCOCTBsettings.autoOpenZoneESChannelId,
        ["FCOChatTabBrainTabZoneZH"] = FCOCTBsettings.autoOpenZoneZHChannelId,
        ["FCOChatTabBrainTabGroup"] = FCOCTBsettings.autoOpenGroupChannelId,
        ["FCOChatTabBrainTabSystem"] = FCOCTBsettings.autoOpenSystemChannelId,
        ["FCOChatTabBrainTabNSC"] = FCOCTBsettings.autoOpenNSCChannelId,
    }

    local function checkChatTabForChatCategory(switchToTabIndex, chatChannels)
        local chatContainerId = chatSystem.primaryContainer.id
        for _, chatChannel in pairs(chatChannels) do
            local chatChannelOptionIsEnabled = FCOCTB.CheckChatTabOptionsForCategory(chatChannel, switchToTabIndex, chatContainerId)
            if chatChannelOptionIsEnabled == true then return true end
        end
        --We got here? Than the chat category is not enabled in the chat options of the chat tab!
        --Warn the user
        d(FCOCTBlocVarsCTB["warning_selected_chattab_category_is_not_enabled"])
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
        params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
        params:SetText(FCOCTBlocVarsCTB["warning_please_read_chat"])
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end

    local function addonMenuOnRefreshCallback(panel)
        if panel == FCOCTBSettingsPanel and FCOCTB.preventerVars.settingsFirstCall == true then
            FCOCTB.preventerVars.settingsFirstCall = false
            --d("Callback settings panel refresh")
            --Get the chat tab names/texts -> Will be stored in array chatVars.chatTabNames
            FCOCTB.GetChatTabNames()
            --Exchange the chat tabs in the dropdown boxes
            for ctrlName, selectedTabIndex in pairs (chatTabLAMControls) do
                --d("Name: " .. ctrlName .. ", active: " .. tostring(active))
                local lamControl = WINDOW_MANAGER:GetControlByName(ctrlName, "")
                if lamControl ~= nil and lamControl.dropdown ~= nil then
                    lamControl.dropdown:ClearItems()

                    local function DropdownCallback(control, choiceText, choice)
                        choice.control:UpdateValue(false, choiceText)
                    end
                    local lastIndex = 0
                    --build new list of choices
                    for index, chatTab in pairs(chatVars.chatTabNames) do
                        local entry = lamControl.dropdown:CreateItemEntry(chatTab, DropdownCallback)
                        entry.control = lamControl
                        lamControl.dropdown:AddItem(entry, not lamControl.data.sort and ZO_COMBOBOX_SUPRESS_UPDATE)	--if sort type/order isn't specified, then don't sort
                        lastIndex = index
                    end
                    --Select the tab again now which was saved in the SavedVariables
                    if selectedTabIndex ~=0 then
                        --Setting was activated
                        lamControl.dropdown:SetSelectedItem(chatVars.chatTabNames[selectedTabIndex])
                    else
                        --Setting is deactivated so select the last index in the tabs list
                        if lastIndex ~= 0 then
                            lamControl.dropdown:SetSelectedItem(chatVars.chatTabNames[lastIndex])
                        end
                    end
                end
            end
            CALLBACK_MANAGER:UnregisterCallback("LAM-RefreshPanel", addonMenuOnRefreshCallback)
        end
    end

    --Addon panels were loaded
    local function addonMenuOnLoadCallback(panel)
        if panel == FCOCTBSettingsPanel then
            FCOChatTabBrain_Settings_PlaySoundTabSay.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_say_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageSay])
            FCOChatTabBrain_Settings_PlaySoundTabWhisper.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_whisper"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageWhisper])
            FCOChatTabBrain_Settings_PlaySoundTabYell.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_yell_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageYell])
            FCOChatTabBrain_Settings_PlaySoundTabGuild1.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild1_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageGuild1])
            FCOChatTabBrain_Settings_PlaySoundTabGuild2.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild2_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageGuild2])
            FCOChatTabBrain_Settings_PlaySoundTabGuild3.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild3_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageGuild3])
            FCOChatTabBrain_Settings_PlaySoundTabGuild4.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild4_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageGuild4])
            FCOChatTabBrain_Settings_PlaySoundTabGuild5.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild5_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageGuild5])
            FCOChatTabBrain_Settings_PlaySoundTabOfficer1.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer1_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageOfficer1])
            FCOChatTabBrain_Settings_PlaySoundTabOfficer2.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer2_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageOfficer2])
            FCOChatTabBrain_Settings_PlaySoundTabOfficer3.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer3_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageOfficer3])
            FCOChatTabBrain_Settings_PlaySoundTabOfficer4.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer4_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageOfficer4])
            FCOChatTabBrain_Settings_PlaySoundTabOfficer5.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer5_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageOfficer5])
            FCOChatTabBrain_Settings_PlaySoundTabZone.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zone_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZone])
            FCOChatTabBrain_Settings_PlaySoundTabZoneDE.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonede_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZoneDE])
            FCOChatTabBrain_Settings_PlaySoundTabZoneEN.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zoneen_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZoneEN])
            FCOChatTabBrain_Settings_PlaySoundTabZoneFR.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonefr_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZoneFR])
            FCOChatTabBrain_Settings_PlaySoundTabZoneJP.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonejp_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZoneJP])
            FCOChatTabBrain_Settings_PlaySoundTabZoneRU.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zoneru_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZoneRU])
            FCOChatTabBrain_Settings_PlaySoundTabZoneES.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonees_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZoneES])
            FCOChatTabBrain_Settings_PlaySoundTabZoneZH.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonezh_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageZoneZH])
            FCOChatTabBrain_Settings_PlaySoundTabGroup.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_group_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageGroup])
            FCOChatTabBrain_Settings_PlaySoundGroupleader.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_groupleader"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnGroupLeader])
            FCOChatTabBrain_Settings_PlaySoundGuildMaster.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guildmaster"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnGuildMaster])
            FCOChatTabBrain_Settings_PlaySoundTabSystem.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_system_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageSystem])
            FCOChatTabBrain_Settings_PlaySoundTabNSC.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_nsc_tab"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageNSC])
            FCOChatTabBrain_Settings_PlaySoundOnFriend.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_friend"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageFriend])
            FCOChatTabBrain_Settings_PlaySoundOnTextFound.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_text_found"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMessageTextFound])
            FCOChatTabBrain_Settings_PlaySoundOnMyCharacterName.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_when_charactername"] .. ": " .. FCOCTB.sounds[FCOCTBsettings.playSoundOnMyCharacterName])

            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
        end
    end

        --Get the guild names for the LAM settings panel submenus
    local function addonMenuOnOpenCallback(panel)
        if panel == FCOCTBSettingsPanel then
            updateGuildNames()
        end
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", addonMenuOnRefreshCallback)
    CALLBACK_MANAGER:RegisterCallback("LAM-OpenPanel", addonMenuOnOpenCallback)

    local guildNames = FCOCTB.guildNames

    local optionsTable =
    {
        {
            type = 'description',
            text = FCOCTBlocVarsCTB["options_description"],
        },
        --==============================================================================
        {
            type = 'submenu',
            name = FCOCTBlocVarsCTB["options_header1"],
            controls = {
                {
                    type = 'dropdown',
                    name = FCOCTBlocVarsCTB["options_language"],
                    tooltip = FCOCTBlocVarsCTB["options_language_tooltip"],
                    choices = languageOptions,
                    getFunc = function() return languageOptions[FCOCTBsetVars.defaultSettings.language] end,
                    setFunc = function(value)
                        for i,v in pairs(languageOptions) do
                            if v == value then
                                FCOCTBsetVars.defaultSettings.language = i
                                --Tell the settings that you have manually chosen the language and want to keep it
                                --Read in function Localization() after ReloadUI()
                                FCOCTBsettings.languageChosen = true

                                --d(">>>> Language chosen: " .. tostring(FCOCTBsettings.languageChosen) .. ", language: " .. tostring(languageOptions[FCOCTBsetVars.defaultSettings.language]))

                                --FCOCTBlocVarsCTB = FCOCTBlocVarsCTB[i]
                                --ReloadUI()
                                break
                            end
                        end
                    end,
                    disabled = function() return FCOCTBsettings.alwaysUseClientLanguage end,
                    warning = FCOCTBlocVarsCTB["options_language_description1"],
                    requiresReload = true,
                },
                {
                    type = "checkbox",
                    name = FCOCTBlocVarsCTB["options_language_use_client"],
                    tooltip = FCOCTBlocVarsCTB["options_language_use_client_tooltip"],
                    getFunc = function() return FCOCTBsettings.alwaysUseClientLanguage end,
                    setFunc = function(value)
                        FCOCTBsettings.alwaysUseClientLanguage = value
                        --ReloadUI()
                    end,
                    default = FCOCTBdefSettings.alwaysUseClientLanguage,
                    warning = FCOCTBlocVarsCTB["options_language_description1"],
                    requiresReload = true,
                },
                {
                    type = 'dropdown',
                    name = FCOCTBlocVarsCTB["options_savedvariables"],
                    tooltip = FCOCTBlocVarsCTB["options_savedvariables_tooltip"],
                    choices = savedVariablesOptions,
                    getFunc = function() return savedVariablesOptions[FCOCTBsetVars.defaultSettings.saveMode] end,
                    setFunc = function(value)
                        for i,v in pairs(savedVariablesOptions) do
                            if v == value then
                                FCOCTBsetVars.defaultSettings.saveMode = i
                                ReloadUI()
                                --break
                            end
                        end
                    end,
                    warning = FCOCTBlocVarsCTB["options_language_description1"],
                },
                {
                    type = 'description',
                    text = FCOCTBlocVarsCTB["options_language_description1"],
                },
            }, -- controls general

        }, -- submenu general

        --==============================================================================
        {
            type = "submenu",
            name = FCOCTBlocVarsCTB["options_header_chat_options"],
            controls = {
                --==============================================================================
                {
                    type = "submenu",
                    name = FCOCTBlocVarsCTB["options_header_chat_minmax"],
                    controls = {
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_minimize_onload"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_minimize_onload_tooltip"],
                            getFunc = function() return FCOCTBsettings.chatMinimizeOnLoad end,
                            setFunc = function(value) FCOCTBsettings.chatMinimizeOnLoad = value end,
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_minimize_after_seconds"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_minimize_after_seconds_tooltip"],
                            min = 0,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoMinimizeTimeout end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoMinimizeTimeout = idleSeconds

                                if idleSeconds == 0 then
                                    --Disable the timer for the chat auto minimization
                                    if chatVars.chatMinimizeTimerActive and EVENT_MANAGER:UnregisterForUpdate(addonName.."ChatMinimizeCheck") then
                                        chatVars.chatMinimizeTimerActive = false
                                    end
                                else
                                    --Enable the timer for the chat auto minimization
                                    if not chatVars.chatMinimizeTimerActive then
                                        chatVars.chatMinimizeTimerActive = EVENT_MANAGER:RegisterForUpdate(addonName.."ChatMinimizeCheck", 1000, FCOCTB.MinimizeChatCheck)
                                        chatVars.lastIncomingMessage = GetTimeStamp() -- needed so the auto minimize feature starts to count the time difference from now
                                    end
                                end
                            end,
                            default = FCOCTBdefSettings.autoMinimizeTimeout,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_minimize_hide_icons"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_minimize_hide_icons_tooltip"],
                            getFunc = function() return FCOCTBsettings.hideIconsInMinimizedChatWindow end,
                            setFunc = function(value)
                                FCOCTBsettings.hideIconsInMinimizedChatWindow = value
                                --if we disable this setting we need to be sure there are no hidden chat icons anymore
                                if value == false then
                                    FCOCTB.showMinimizedChatButtonsAgain(true)
                                end
                            end,
                            default = FCOCTBdefSettings.hideIconsInMinimizedChatWindow,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_on_minimized"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_on_minimized_tooltip"],
                            getFunc = function() return FCOCTBsettings.doNotAutoOpenIfMinimized end,
                            setFunc = function(value) FCOCTBsettings.doNotAutoOpenIfMinimized = value
                            end,
                            default = FCOCTBdefSettings.doNotAutoOpenIfMinimized,
                            disabled = function() return FCOCTBsettings.autoMinimizeTimeout ~= 0 end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_checkbox_reopenchatifminimized"],
                            tooltip = FCOCTBlocVarsCTB["options_checkbox_reopenchatifminimized_tooltip"],
                            getFunc = function() return FCOCTBsettings.reOpenChatIfMinimized end,
                            setFunc = function(value) FCOCTBsettings.reOpenChatIfMinimized = value end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_maximize_on_mouse_hover_over_maximize_button"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_maximize_on_mouse_hover_over_maximize_button_tooltip"],
                            getFunc = function() return FCOCTBsettings.maximizeChatOnMouseHoverOverMaximizeButton end,
                            setFunc = function(value) FCOCTBsettings.maximizeChatOnMouseHoverOverMaximizeButton = value
                            end,
                            default = FCOCTBdefSettings.maximizeChatOnMouseHoverOverMaximizeButton,
                        },
                    }, -- chat minimize & maximize
                }, -- submenu chat minimize & maximize
                --==============================================================================
                {
                    type = "submenu",
                    name = FCOCTBlocVarsCTB["options_header_chat_fadeout"],
                    controls = {
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_fadeout_seconds"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_fadeout_seconds_tooltip"],
                            min = 0,
                            max = 600,
                            step = 0.5,
                            getFunc = function()
                                if FCOCTBsettings.fadeOutChatTime > 0 then
                                    return FCOCTBsettings.fadeOutChatTime / 1000
                                else
                                    return 0
                                end
                            end,
                            setFunc = function(seconds)
                                FCOCTBsettings.fadeOutChatTime = seconds * 1000
                            end,
                            default = function()
                                if FCOCTBsettings.fadeOutChatTime > 0 then
                                    return FCOCTBsettings.fadeOutChatTime / 1000
                                else
                                    return 0
                                end
                            end,
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_fadeout_buttons_seconds"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_fadeout_buttons_seconds_tooltip"],
                            min = 0,
                            max = 600,
                            step = 0.5,
                            getFunc = function()
                                if FCOCTBsettings.fadeOutChatButtonsTime > 0 then
                                    return FCOCTBsettings.fadeOutChatButtonsTime / 1000
                                else
                                    return 0
                                end
                            end,
                            setFunc = function(seconds)
                                FCOCTBsettings.fadeOutChatButtonsTime = seconds * 1000
                            end,
                            default = function()
                                if FCOCTBsettings.fadeOutChatButtonsTime > 0 then
                                    return FCOCTBsettings.fadeOutChatButtonsTime / 1000
                                else
                                    return 0
                                end
                            end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_fade_out_chat_button"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_fade_out_chat_button_tooltip"],
                            getFunc = function() return FCOCTBsettings.fadeOutChatButtons end,
                            setFunc = function(value) FCOCTBsettings.fadeOutChatButtons = value
                                ReloadUI()
                            end,
                            warning = FCOCTBlocVarsCTB["options_reloadui"]
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_checkbox_fadein_chat_on_cycle"],
                            tooltip = FCOCTBlocVarsCTB["options_checkbox_fadein_chat_on_cycle_tooltip"],
                            getFunc = function() return FCOCTBsettings.fadeInChatOnCycle end,
                            setFunc = function(value) FCOCTBsettings.fadeInChatOnCycle = value end,
                        },
                    }, -- controls chat fadeout
                }, --submenu chat fadeout
                --==============================================================================
                {
                    type = "submenu",
                    name = FCOCTBlocVarsCTB["options_header_chat_tabs"],
                    controls = {
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_tab_all_on"] ,
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_tab_all_on_tooltip"] ,
                            getFunc = function() return FCOCTBsettings.enableChatTabSwitch end,
                            setFunc = function(value) FCOCTBsettings.enableChatTabSwitch = value
                            end,
                            default = FCOCTBdefSettings.enableChatTabSwitch,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_remember_last_active_chat_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_remember_last_active_chat_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.rememberLastActiveChatTab end,
                            setFunc = function(value) FCOCTBsettings.rememberLastActiveChatTab = value end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_clear_chat_buffer_on_shift_click"],
                            tooltip = FCOCTBlocVarsCTB["options_clear_chat_buffer_on_shift_click_tooltip"],
                            getFunc = function() return FCOCTBsettings.clearChatBufferOnShiftClick end,
                            setFunc = function(value) FCOCTBsettings.clearChatBufferOnShiftClick = value end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_change_tab_color"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_change_tab_color_tooltip"],
                            getFunc = function() return FCOCTBsettings.showChatTabColor end,
                            setFunc = function(value) FCOCTBsettings.showChatTabColor = value
                            end,
                            default = FCOCTBdefSettings.showChatTabColor,
                        },

                    },
                },
                --==============================================================================
                {
                    type = "submenu",
                    name = FCOCTBlocVarsCTB["options_header_chat_channels"],
                    controls = {
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_dont_change_channel_if_text_edit_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_dont_change_channel_if_text_edit_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.dontChangeChatChannelIfTextEditActive end,
                            setFunc = function(value) FCOCTBsettings.dontChangeChatChannelIfTextEditActive = value
                            end,
                            default = FCOCTBdefSettings.dontChangeChatChannelIfTextEditActive,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_sending_message_overwrites_chat_channel"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_sending_message_overwrites_chat_channel_tooltip"],
                            getFunc = function() return FCOCTBsettings.sendingMessageOverwritesChatChannel end,
                            setFunc = function(value) FCOCTBsettings.sendingMessageOverwritesChatChannel = value
                            end,
                            default = FCOCTBdefSettings.sendingMessageOverwritesChatChannel,
                        },
                    }, -- controls chat channels
                }, -- submenu chat channels

                --==============================================================================
                {
                    type = "checkbox",
                    name = FCOCTBlocVarsCTB["options_checkbox_enable"],
                    tooltip = FCOCTBlocVarsCTB["options_checkbox_enable_tooltip"],
                    getFunc = function() return FCOCTBsettings.chatBrainActive end,
                    setFunc = function(value) FCOCTB.toggleChatBrain() end,
                    default = FCOCTBdefSettings.chatBrainActive,
                },

                {
                    type = "checkbox",
                    name = FCOCTBlocVarsCTB["options_checkbox_autoscrollToBottom"],
                    tooltip = FCOCTBlocVarsCTB["options_checkbox_autoscrollToBottom_TT"],
                    getFunc = function() return FCOCTBsettings.autoScrollToChatBottomUponNewIncomingMsg end,
                    setFunc = function(value) FCOCTBsettings.autoScrollToChatBottomUponNewIncomingMsg = value end,
                    default = FCOCTBdefSettings.autoScrollToChatBottomUponNewIncomingMsg,
                },
                {
                    type = "checkbox",
                    name = FCOCTBlocVarsCTB["options_chat_tab_switch_by_keybind_scroll_to_bottom"],
                    tooltip = FCOCTBlocVarsCTB["options_chat_tab_switch_by_keybind_scroll_to_bottom_TT"],
                    getFunc = function() return FCOCTBsettings.autoScrollToChatBottomUponKeybindTabSwitch end,
                    setFunc = function(value) FCOCTBsettings.autoScrollToChatBottomUponKeybindTabSwitch = value end,
                    default = FCOCTBdefSettings.autoScrollToChatBottomUponKeybindTabSwitch,
                },

            }, -- controls options
        }, -- submenu options

        ----------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------------------------------------
        --==============================================================================
        {
            type = "submenu",
            name = FCOCTBlocVarsCTB["options_header_chat_redirect_options"],
            controls = {

                ----- Idle -----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = FCOCTBlocVarsCTB["options_header_chat_redirect_idle"],
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId]
                                else
                                    if FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId = 0
                                            break
                                        end
                                        FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId = i
                                        break
                                    end
                                end
                                if FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId == nil or FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId == 0 then
                                    FCOCTB.SetupDefaultTabIdleTimer(false)
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabAfterIdle",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_default_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.switchToDefaultChatTabAfterIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.switchToDefaultChatTabAfterIdleTime = idleSeconds
                                if FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId == nil or FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId == 0 then
                                    FCOCTB.SetupDefaultTabIdleTimer(false)
                                end
                            end,
                            width="half",
                            default = FCOCTBdefSettings.switchToDefaultChatTabAfterIdleTime,
                            disabled = function() return (FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId == nil or FCOCTBsettings.switchToDefaultChatTabAfterIdleTabId == 0) end,
                        },
                    }, -- controls idle
                }, -- submenu idle

                ----- Whisper---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat"],
                            tooltip = FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if   chatVars.chatTabNames[FCOCTBsettings.redirectWhisperChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.redirectWhisperChannelId]
                                else
                                    if FCOCTBsettings.redirectWhisperChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.redirectWhisperChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.redirectWhisperChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_WHISPER})
                                        break
                                    end
                                end
                            end,
                            width = "half",
                            reference = "FCOChatTabBrainTabWhisper",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_whisper_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenWhisperIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenWhisperIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenWhisperIdleTime,
                            disabled = function() return FCOCTBsettings.redirectWhisperChannelId == nil or FCOCTBsettings.redirectWhisperChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_whisper_auto_open_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_whisper_auto_open_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoOpenWhisperTab end,
                            setFunc = function(value) FCOCTBsettings.autoOpenWhisperTab = value
                            end,
                            width="half",
                            disabled = function()
                                if FCOCTBsettings.redirectWhisperChannelId == nil or FCOCTBsettings.redirectWhisperChannelId <= 0 then
                                    return true
                                else
                                    return false
                                end
                            end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_whisper_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_whisper_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelWhisper end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelWhisper = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelWhisper,
                            disabled = function() return FCOCTBsettings.redirectWhisperChannelId == nil or FCOCTBsettings.redirectWhisperChannelId == 0  end,
                        },
                    }, -- controls whisper
                }, -- submenu whisper

                ----- Say---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES1),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_say_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_say_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenSayChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenSayChannelId]
                                else
                                    if FCOCTBsettings.autoOpenSayChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenSayChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenSayChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_SAY})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabSay",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_say_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenSayIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenSayIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenSayIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenSayChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_say_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_say_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelSay end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelSay = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelSay,
                            disabled = function() return FCOCTBsettings.autoOpenSayChannelId == 0  end,
                        },
                    }, -- controls say
                }, -- submenu say

                ----- Yell---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES2),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_yell_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_yell_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenYellChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenYellChannelId]
                                else
                                    if FCOCTBsettings.autoOpenYellChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenYellChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenYellChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_YELL})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabYell",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_yell_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenYellIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenYellIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenYellIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenYellChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_yell_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_yell_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelYell end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChanneYell = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelYell,
                            disabled = function() return FCOCTBsettings.autoOpenYellChannelId == 0  end,
                        },
                    }, -- controls yell
                }, -- submenu yell

                ----- Guild 1---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES10) .. " - " .. tostring(guildNames[1]),
                    disabled = function() return not areGuildsEnabled(1) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_guild1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_guild1_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild1ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild1ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenGuild1ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenGuild1ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenGuild1ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_GUILD_1})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabGuild1",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_guild1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenGuild1IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenGuild1IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenGuild1IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenGuild1ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild1_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelGuild1 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelGuild1 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelGuild1,
                            disabled = function() return FCOCTBsettings.autoOpenGuild1ChannelId == 0  end,
                        },
                    }, -- controls Guild 1
                }, -- submenu Guild 1

                ----- Guild 2---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES11) .. " - " .. tostring(guildNames[2]),
                    disabled = function() return not areGuildsEnabled(2) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_guild2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_guild2_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild2ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild2ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenGuild2ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenGuild2ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenGuild2ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_GUILD_2})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabGuild2",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_guild2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenGuild2IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenGuild2IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenGuild2IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenGuild2ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild2_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelGuild2 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelGuild2 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelGuild2,
                            disabled = function() return FCOCTBsettings.autoOpenGuild2ChannelId == 0  end,
                        },
                    }, -- controls Guild 2
                }, -- submenu Guild 2

                ----- Guild 3---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES12) .. " - " .. tostring(guildNames[3]),
                    disabled = function() return not areGuildsEnabled(3) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_guild3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_guild3_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild3ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild3ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenGuild3ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenGuild3ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenGuild3ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_GUILD_3})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabGuild3",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_guild3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenGuild3IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenGuild3IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenGuild3IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenGuild3ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild3_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelGuild3 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelGuild3 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelGuild3,
                            disabled = function() return FCOCTBsettings.autoOpenGuild3ChannelId == 0  end,
                        },
                    }, -- controls Guild 3
                }, -- submenu Guild

                ----- Guild 4---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES13) .. " - " .. tostring(guildNames[4]),
                    disabled = function() return not areGuildsEnabled(4) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_guild4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_guild4_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild4ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild4ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenGuild4ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenGuild4ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenGuild4ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_GUILD_4})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabGuild4",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_guild4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenGuild4IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenGuild4IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenGuild4IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenGuild4ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild4_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelGuild4 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelGuild4 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelGuild4,
                            disabled = function() return FCOCTBsettings.autoOpenGuild4ChannelId == 0  end,
                        },
                    }, -- controls Guild 4
                }, -- submenu Guild 4

                ----- Guild 5---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES14) .. " - " .. tostring(guildNames[5]),
                    disabled = function() return not areGuildsEnabled(5) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_guild5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_guild5_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild5ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenGuild5ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenGuild5ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenGuild5ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenGuild5ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_GUILD_5})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabGuild5",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_guild5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenGuild5IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenGuild5IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenGuild5IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenGuild5ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_guild5_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelGuild5 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelGuild5 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelGuild5,
                            disabled = function() return FCOCTBsettings.autoOpenGuild5ChannelId == 0  end,
                        },
                    }, -- controls Guild 5
                }, -- submenu Guild 5

                ----- Officer 1---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES15) .. " - " .. tostring(guildNames[1]),
                    disabled = function() return not areGuildsEnabled(1) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_officer1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_officer1_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer1ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer1ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenOfficer1ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenOfficer1ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenOfficer1ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_OFFICER_1})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabOfficer1",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_officer1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenOfficer1IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenOfficer1IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenOfficer1IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer1ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer1_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelOfficer1 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelOfficer1 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelOfficer1,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer1ChannelId == 0  end,
                        },
                    }, -- controls Officer 1
                }, -- submenu Officer 1

                ----- Officer 2---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES16) .. " - " .. tostring(guildNames[2]),
                    disabled = function() return not areGuildsEnabled(2) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_officer2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_officer2_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer2ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer2ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenOfficer2ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenOfficer2ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenOfficer2ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_OFFICER_2})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabOfficer2",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_officer2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenOfficer2IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenOfficer2IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenOfficer2IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer2ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer2_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelOfficer2 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelOfficer2 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelOfficer2,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer2ChannelId == 0  end,
                        },
                    }, -- controls Officer 2
                }, -- submenu Officer 2

                ----- Officer 3---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES17) .. " - " .. tostring(guildNames[3]),
                    disabled = function() return not areGuildsEnabled(3) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_officer3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_officer3_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer3ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer3ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenOfficer3ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenOfficer3ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenOfficer3ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_OFFICER_3})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabOfficer3",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_officer3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenOfficer3IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenOfficer3IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenOfficer3IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer3ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer3_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelOfficer3 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelOfficer3 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelOfficer3,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer3ChannelId == 0  end,
                        },
                    }, -- controls Officer 3
                }, -- submenu Officer 3

                ----- Officer 4---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES18) .. " - " .. tostring(guildNames[4]),
                    disabled = function() return not areGuildsEnabled(4) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_officer4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_officer4_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer4ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer4ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenOfficer4ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenOfficer4ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenOfficer4ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_OFFICER_4})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabOfficer4",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_officer4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenOfficer4IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenOfficer4IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenOfficer4IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer4ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer4_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelOfficer4 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelOfficer4 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelOfficer4,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer4ChannelId == 0  end,
                        },
                    }, -- controls Officer 4
                }, -- submenu Officer 4

                ----- Officer 5---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES19) .. " - " .. tostring(guildNames[5]),
                    disabled = function() return not areGuildsEnabled(5) end,
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_officer5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_officer5_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer5ChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenOfficer5ChannelId]
                                else
                                    if FCOCTBsettings.autoOpenOfficer5ChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenOfficer5ChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenOfficer5ChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_OFFICER_5})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabOfficer5",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_officer5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenOfficer5IdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenOfficer5IdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenOfficer5IdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer5ChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_officer5_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelOfficer5 end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelOfficer5 = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelOfficer5,
                            disabled = function() return FCOCTBsettings.autoOpenOfficer5ChannelId == 0  end,
                        },
                    }, -- controls Officer Officer
                }, -- submenu Officer 5

                ----- Zone---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES6),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zone_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zone_tooltip_tab"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneChannelId]
                                else
                                    if FCOCTBsettings.autoOpenZoneChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZone",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zone_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zone_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zone_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZone end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZone = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZone,
                            disabled = function() return FCOCTBsettings.autoOpenZoneChannelId == 0  end,
                        },
                    }, -- controls Zone
                }, -- submenu Zone

                ----- Zone DE---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES22),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zonede_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zonede_tooltip_tab"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneDEChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneDEChannelId]
                                else
                                    if FCOCTBsettings.autoOpenZoneDEChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneDEChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneDEChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE_LANGUAGE_1})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZoneDE",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zonede_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneDEIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneDEIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneDEIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneDEChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonede_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonede_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZoneDE end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZoneDE = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZoneDE,
                            disabled = function() return FCOCTBsettings.autoOpenZoneDEChannelId == 0  end,
                        },
                    }, -- controls Zone DE
                }, -- submenu Zone DE

                ----- Zone EN---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES20),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zoneen_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zoneen_tab"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneENChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneENChannelId]
                                else
                                    if FCOCTBsettings.autoOpenZoneENChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneENChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneENChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE_LANGUAGE_2})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZoneEN",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zoneen_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneENIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneENIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneENIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneENChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zoneen_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zoneen_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZoneEN end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZoneEN = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZoneEN,
                            disabled = function() return FCOCTBsettings.autoOpenZoneENChannelId == 0  end,
                        },
                    }, -- controls Zone EN
                }, -- submenu Zone EN

                ----- Zone FR---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES21),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zonefr_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zonefr_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneFRChannelId] ~= nil then
                                    if FCOCTBsettings.autoOpenZoneFRChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneFRChannelId]
                                else
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneFRChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneFRChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE_LANGUAGE_3})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZoneFR",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zonefr_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneFRIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneFRIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneFRIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneFRChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonefr_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonefr_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZoneFR end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZoneFR = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZoneFR,
                            disabled = function() return FCOCTBsettings.autoOpenZoneFRChannelId == 0  end,
                        },
                    }, -- controls Zone FR
                }, -- submenu Zone FR

                ----- Zone JP---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES23),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zonejp_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zonejp_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneJPChannelId] ~= nil then
                                    if FCOCTBsettings.autoOpenZoneJPChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneJPChannelId]
                                else
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneJPChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneJPChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE_LANGUAGE_4})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZoneJP",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zonejp_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneJPIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneJPIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneJPIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneJPChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonejp_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonejp_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZoneJP end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZoneJP = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZoneJP,
                            disabled = function() return FCOCTBsettings.autoOpenZoneJPChannelId == 0  end,
                        },
                    }, -- controls Zone JP
                }, -- submenu Zone JP

                ----- Zone RU ---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES24),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zoneru_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zoneru_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneRUChannelId] ~= nil then
                                    if FCOCTBsettings.autoOpenZoneRUChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneRUChannelId]
                                else
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneRUChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneRUChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE_LANGUAGE_5})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZoneRU",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zoneru_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneRUIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneRUIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneRUIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneRUChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zoneru_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zoneru_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZoneRU end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZoneRU = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZoneRU,
                            disabled = function() return FCOCTBsettings.autoOpenZoneRUChannelId == 0  end,
                        },
                    }, -- controls Zone RU
                }, -- submenu Zone RU

                ----- Zone ES ---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES25),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zonees_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zonees_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneESChannelId] ~= nil then
                                    if FCOCTBsettings.autoOpenZoneESChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneESChannelId]
                                else
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneESChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneESChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE_LANGUAGE_6})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZoneES",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zonees_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneESIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneESIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneESIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneESChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonees_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonees_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZoneES end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZoneES = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZoneES,
                            disabled = function() return FCOCTBsettings.autoOpenZoneESChannelId == 0  end,
                        },
                    }, -- controls Zone ES
                }, -- submenu Zone ES

                ----- Zone ZH ---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES26),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_zonezh_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_zonezh_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneZHChannelId] ~= nil then
                                    if FCOCTBsettings.autoOpenZoneZHChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenZoneZHChannelId]
                                else
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenZoneZHChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenZoneZHChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_ZONE_LANGUAGE_7})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabZoneZH",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_zonezh_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenZoneZHIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenZoneZHIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenZoneZHIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenZoneZHChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonezh_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_zonezh_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelZoneZH end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelZoneZH = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelZoneZH,
                            disabled = function() return FCOCTBsettings.autoOpenZoneZHChannelId == 0  end,
                        },
                    }, -- controls Zone ZH
                }, -- submenu Zone ZH

                ----- Group---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES7),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_group_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_group_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenGroupChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenGroupChannelId]
                                else
                                    if FCOCTBsettings.autoOpenGroupChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenGroupChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenGroupChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_PARTY})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabGroup",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_group_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenGroupIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenGroupIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenGroupIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenGroupChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_group_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_group_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelGroup end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelGroup = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelGroup,
                            disabled = function() return FCOCTBsettings.autoOpenGroupChannelId == 0  end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_not_if_in_group"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_not_if_in_group_tooltip"],
                            getFunc = function() return FCOCTBsettings.doNotAutoOpenIfGrouped end,
                            setFunc = function(value) FCOCTBsettings.doNotAutoOpenIfGrouped = value end,
                            disabled = function()
                                if (FCOCTBsettings.autoOpenSayChannelId == 0 and
                                        FCOCTBsettings.autoOpenYellChannelId == 0 and
                                        FCOCTBsettings.autoOpenGuild1ChannelId == 0 and
                                        FCOCTBsettings.autoOpenGuild2ChannelId == 0 and
                                        FCOCTBsettings.autoOpenGuild3ChannelId == 0 and
                                        FCOCTBsettings.autoOpenGuild4ChannelId == 0 and
                                        FCOCTBsettings.autoOpenGuild5ChannelId == 0 and
                                        FCOCTBsettings.autoOpenOfficer1ChannelId == 0 and
                                        FCOCTBsettings.autoOpenOfficer2ChannelId == 0 and
                                        FCOCTBsettings.autoOpenOfficer3ChannelId == 0 and
                                        FCOCTBsettings.autoOpenOfficer4ChannelId == 0 and
                                        FCOCTBsettings.autoOpenOfficer5ChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneDEChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneENChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneFRChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneJPChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneRUChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneESChannelId == 0 and
                                        FCOCTBsettings.autoOpenZoneZHChannelId == 0 and
                                        FCOCTBsettings.autoOpenGroupChannelId == 0 and
                                        FCOCTBsettings.autoOpenSystemChannelId == 0 and
                                        FCOCTBsettings.autoOpenNSCChannelId == 0
                                ) then
                                    return true
                                else
                                    return false
                                end
                            end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_not_if_in_group_exception_whisper"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_not_if_in_group_exception_whisper_tooltip"],
                            getFunc = function() return FCOCTBsettings.doAutoOpenWhisperIfGrouped end,
                            setFunc = function(value) FCOCTBsettings.doAutoOpenWhisperIfGrouped = value end,
                            disabled = function() return not FCOCTBsettings.doNotAutoOpenIfGrouped  end,
                        },
                    }, -- controls Group
                }, -- submenu Group

                ----- System---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES9),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_system_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_system_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenSystemChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenSystemChannelId]
                                else
                                    if FCOCTBsettings.autoOpenSystemChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenSystemChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenSystemChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_SYSTEM})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabSystem",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_system_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenSystemIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenSystemIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenSystemIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenSystemChannelId == 0  end,
                        },
                --[[
                        --There is no system channel we could manually use to write in!
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_system_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_system_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelSystem end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelSystem = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelSystem,
                            disabled = function() return FCOCTBsettings.autoOpenSystemChannelId == 0  end,
                        },
                ]]
                    }, -- controls system
                }, -- submenu system

                ----- NPCs---------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES41),
                    controls = {
                        {
                            type = 'dropdown',
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_nsc_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_nsc_tab_tooltip"],
                            choices = chatVars.chatTabNames,
                            getFunc = function()
                                if chatVars.chatTabNames[FCOCTBsettings.autoOpenNSCChannelId] ~= nil then
                                    return chatVars.chatTabNames[FCOCTBsettings.autoOpenNSCChannelId]
                                else
                                    if FCOCTBsettings.autoOpenNSCChannelId == 0 then
                                        return FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
                                    end
                                    return ""
                                end
                            end,
                            setFunc = function(value)
                                for i,v in pairs(chatVars.chatTabNames) do
                                    if v == value then
                                        if value == FCOCTBlocVarsCTB["options_checkbox_redirect_whisper_chat_disable"] then
                                            FCOCTBsettings.autoOpenNSCChannelId = 0
                                            break
                                        end
                                        FCOCTBsettings.autoOpenNSCChannelId = i
                                        checkChatTabForChatCategory(i, {CHAT_CHANNEL_MONSTER_SAY, CHAT_CHANNEL_MONSTER_YELL, CHAT_CHANNEL_MONSTER_WHISPER})
                                        break
                                    end
                                end
                            end,
                            width="half",
                            reference = "FCOChatTabBrainTabNSC",
                        },
                        {
                            type = "slider",
                            name = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_nsc_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_open_idle_time_tooltip"],
                            min = 1,
                            max = 1800,
                            getFunc = function() return FCOCTBsettings.autoOpenNSCIdleTime end,
                            setFunc = function(idleSeconds)
                                FCOCTBsettings.autoOpenNSCIdleTime = idleSeconds
                            end,
                            width="half",
                            default = FCOCTBdefSettings.autoOpenNSCIdleTime,
                            disabled = function() return FCOCTBsettings.autoOpenNSCChannelId == 0  end,
                        },
                --[[
                        --There is no NPCs channel we could manually use to write in!
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_auto_change_channel_nsc_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_auto_change_channel_nsc_tab_tooltip"],
                            getFunc = function() return FCOCTBsettings.autoChangeToChannelNSC end,
                            setFunc = function(value) FCOCTBsettings.autoChangeToChannelNSC = value
                            end,
                            default = FCOCTBdefSettings.autoChangeToChannelNSC,
                            disabled = function() return FCOCTBsettings.autoOpenNSCChannelId == 0  end,
                        },
                ]]
                    }, -- controls NPCs
                }, -- submenu NPCs

            } -- controls chat redirect
        }, -- submenu chat redirect

        --==============================================================================
        {
            type = "submenu",
            name = FCOCTBlocVarsCTB["options_header_chat_sounds"],
            controls = {
                {
                    type = "checkbox",
                    name = FCOCTBlocVarsCTB["options_chat_play_sound_disabled"],
                    tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_disabled_tooltip"],
                    getFunc = function() return FCOCTBsettings.disableChatSounds end,
                    setFunc = function(value) FCOCTBsettings.disableChatSounds = value
                    end,
                },

                --------------------------------------------------------------------------------------------------------
                {
                    type = 'dropdown',
                    name = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_choose"],
                    tooltip = FCOCTBlocVarsCTB["options_chat_prefer_play_sound_on_choose_tooltip"],
                    choices = preferedForMultipleSelections,
                    getFunc = function()
                        return preferedForMultipleSelections[FCOCTBsettings.preferedSoundForMultiple]
                    end,
                    setFunc = function(value)
                        for i,v in pairs(preferedForMultipleSelections) do
                            if v == value then
                                FCOCTBsettings.preferedSoundForMultiple = i
                                break
                            end
                        end
                    end,
                    default = FCOCTBdefSettings.preferedSoundForMultiple,
                    width="full",
                    disabled = function() return FCOCTBsettings.disableChatSounds end
                },

                ----- Whisper-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_whisper"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_whisper_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageWhisper
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageWhisper = idx
                                FCOChatTabBrain_Settings_PlaySoundTabWhisper.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_whisper"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageWhisper,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabWhisper",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabWhisper end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabWhisper = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageWhisper == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabWhisper",
                        },
                    }, -- controls sounds whisper

                }, -- submenu sounds whisper

                ----- Say-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES1),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_say_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_say_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageSay
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageSay = idx
                                FCOChatTabBrain_Settings_PlaySoundTabSay.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_say_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageSay,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabSay",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabSay end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabSay = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageSay == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabSay",
                        },
                    }, -- controls sounds say
                }, -- submenu sounds say

                ----- Yell-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES2),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_yell_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_yell_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageYell
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageYell = idx
                                FCOChatTabBrain_Settings_PlaySoundTabYell.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_yell_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageYell,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabYell",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabYell end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabYell = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageYell == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabYell",
                        },
                    }, -- controls sounds yell
                }, -- submenu sounds yell

                ----- Guilds-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_GAMEPAD_GUILD_HEADER_GUILDS_TITLE),
                    disabled = function()
                        local numGuilds = GetNumGuilds()
                        if numGuilds == nil or numGuilds < 1 then return true end
                        return false
                    end,
                    controls = {

                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_guildmaster"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_guildmaster_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnGuildMaster
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnGuildMaster = idx
                                FCOChatTabBrain_Settings_PlaySoundGuildMaster.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guildmaster"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnGuildMaster,
                            reference = "FCOChatTabBrain_Settings_PlaySoundGuildMaster",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_guildmaster_only_guilds"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_guildmaster_only_guilds_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundOnGuildMasterOnlyGuildTabs end,
                            setFunc = function(value) FCOCTBsettings.playSoundOnGuildMasterOnlyGuildTabs = value end,
                            default = FCOCTBdefSettings.playSoundOnGuildMasterOnlyGuildTabs,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnGuildMaster == 1 end,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGuildMaster end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGuildMaster = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnGuildMaster == 1 end,
                            default = FCOCTBdefSettings.playSoundWithActiveTabGuildMaster,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabGuildMaster",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_guild1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_guild1_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageGuild1
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageGuild1 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabGuild1.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild1_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageGuild1,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabGuild1",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGuild1 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGuild1 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageGuild1 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabGuild1",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_guild2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_guild2_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageGuild2
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageGuild2 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabGuild2.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild2_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageGuild2,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabGuild2",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGuild2 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGuild2 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageGuild2 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabGuild2",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_guild3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_guild3_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageGuild3
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageGuild3 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabGuild3.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild3_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageGuild3,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabGuild3",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGuild3 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGuild3 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageGuild3 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabGuild3",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_guild4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_guild4_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageGuild4
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageGuild4 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabGuild4.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild4_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageGuild4,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabGuild4",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGuild4 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGuild4 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageGuild4 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabGuild4",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_guild5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_guild5_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageGuild5
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageGuild5 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabGuild5.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_guild5_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageGuild5,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabGuild5",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGuild5 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGuild5 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageGuild5 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabGuild5",
                        },

                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_officer1_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_officer1_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageOfficer1
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageOfficer1 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabOfficer1.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer1_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageOfficer1,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabOfficer1",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabOfficer1 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabOfficer1 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageOfficer1 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabOfficer1",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_officer2_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_officer2_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageOfficer2
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageOfficer2 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabOfficer2.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer2_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageOfficer2,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabOfficer2",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabOfficer2 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabOfficer2 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageOfficer2 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabOfficer2",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_officer3_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_officer3_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageOfficer3
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageOfficer3 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabOfficer3.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer3_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageOfficer3,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabOfficer3",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabOfficer3 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabOfficer3 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageOfficer3 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabOfficer3",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_officer4_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_officer4_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageOfficer4
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageOfficer4 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabOfficer4.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer4_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageOfficer4,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabOfficer4",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabOfficer4 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabOfficer4 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageOfficer4 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabOfficer4",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_officer5_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_officer5_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageOfficer5
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageOfficer5 = idx
                                FCOChatTabBrain_Settings_PlaySoundTabOfficer5.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_officer5_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageOfficer5,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabOfficer5",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabOfficer5 end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabOfficer5 = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageOfficer5 == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabOfficer5",
                        },

                    }, --controls sounds guilds
                },  --submenu sounds guilds

                ----- Zones-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES6),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zone_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zone_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZone
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZone = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZone.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zone_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZone,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZone",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZone end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZone = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZone == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZone",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zonede_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zonede_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZoneDE
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZoneDE = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZoneDE.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonede_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZoneDE,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZoneDE",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZoneDE end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZoneDE = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZoneDE == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZoneDE",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zoneen_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zoneen_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZoneEN
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZoneEN = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZoneEN.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zoneen_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZoneEN,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZoneEN",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZoneEN end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZoneEN = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZoneEN == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZoneEN",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zonefr_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zonefr_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZoneFR
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZoneFR = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZoneFR.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonefr_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZoneFR,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZoneFR",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZoneFR end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZoneFR = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZoneFR == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZoneFR",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zonejp_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zonejp_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZoneJP
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZoneJP = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZoneJP.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonejp_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZoneJP,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZoneJP",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZoneJP end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZoneJP = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZoneJP == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZoneJP",
                        },

                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zoneru_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zoneru_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZoneRU
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZoneRU = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZoneRU.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zoneru_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZoneRU,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZoneRU",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZoneRU end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZoneRU = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZoneRU == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZoneRU",
                        },

                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zonees_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zonees_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZoneES
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZoneES = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZoneES.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonees_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZoneES,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZoneES",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZoneES end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZoneES = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZoneES == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZoneES",
                        },

                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_zonezh_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_zonezh_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageZoneZH
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageZoneZH = idx
                                FCOChatTabBrain_Settings_PlaySoundTabZoneZH.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_zonezh_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageZoneZH,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabZoneZH",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabZoneZH end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabZoneZH = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageZoneZH == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabZoneZH",
                        },
                    }, -- controls sounds zone

                }, -- submenu sounds zoness

                ----- Group-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES7),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_groupleader"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_groupleader_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnGroupLeader
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnGroupLeader = idx
                                FCOChatTabBrain_Settings_PlaySoundGroupleader.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_groupleader"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnGroupLeader,
                            reference = "FCOChatTabBrain_Settings_PlaySoundGroupleader",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGroupLeader end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGroupLeader = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnGroupLeader == 1 end,
                            default = FCOCTBdefSettings.playSoundWithActiveTabGroupLeader,
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_only_in_pvp"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_only_in_pvp_tooltip"],
                            getFunc = function() return FCOCTBsettings.groupLeaderSoundInPvPOnly end,
                            setFunc = function(value) FCOCTBsettings.groupLeaderSoundInPvPOnly = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnGroupLeader == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundGroupLeaderInPvPOnly",
                        },
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_group_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_group_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageGroup
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageGroup = idx
                                FCOChatTabBrain_Settings_PlaySoundTabGroup.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_group_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageGroup,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabGroup",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabGroup end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabGroup = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageGroup == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabGroup",
                        },
                    }, -- controls sounds group

                }, -- submenu sounds group

                ----- System-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES9),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_system_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_system_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageSystem
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageSystem = idx
                                FCOChatTabBrain_Settings_PlaySoundTabSystem.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_system_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageSystem,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabSystem",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabSystem end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabSystem = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageSystem == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabSystem",
                        },
                    }, -- controls sounds system
                }, -- submenu sounds system

                ----- NSCs-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHATCHANNELCATEGORIES41),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_nsc_tab"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_nsc_tab_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageNSC
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageNSC = idx
                                FCOChatTabBrain_Settings_PlaySoundTabNSC.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_nsc_tab"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageNSC,
                            reference = "FCOChatTabBrain_Settings_PlaySoundTabNSC",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "checkbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_with_tab_active_tooltip"],
                            getFunc = function() return FCOCTBsettings.playSoundWithActiveTabNSC end,
                            setFunc = function(value) FCOCTBsettings.playSoundWithActiveTabNSC = value end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageNSC == 1 end,
                            reference = "FCOChatTabBrain_Settings_PlaySoundWithActiveTabNSC",
                        },
                    }, -- controls sounds NSCs
                }, -- submenu sounds NSCs

                ----- Friends-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_WINDOW_TITLE_FRIENDS_LIST),
                    controls = {
                        {
                            type      = 'slider',
                            name      = FCOCTBlocVarsCTB["options_chat_play_sound_friend"],
                            tooltip   = FCOCTBlocVarsCTB["options_chat_play_sound_friend_tooltip"],
                            min       = 1,
                            max       = #FCOCTB.sounds,
                            getFunc   = function()
                                return FCOCTBsettings.playSoundOnMessageFriend
                            end,
                            setFunc   = function(idx)
                                FCOCTBsettings.playSoundOnMessageFriend = idx
                                FCOChatTabBrain_Settings_PlaySoundOnFriend.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_friend"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default   = FCOCTBdefSettings.playSoundOnMessageFriend,
                            reference = "FCOChatTabBrain_Settings_PlaySoundOnFriend",
                            disabled  = function()
                                return FCOCTBsettings.disableChatSounds
                            end
                        },
                    }, --controls sounds friends
                }, --submenu sounds friends

                ----- Text in messages-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = "Text in messages",
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_text_found"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_text_found_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMessageTextFound
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMessageTextFound = idx
                                FCOChatTabBrain_Settings_PlaySoundOnTextFound.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_text_found"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMessageTextFound,
                            reference = "FCOChatTabBrain_Settings_PlaySoundOnTextFound",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                        {
                            type = "editbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_text_found_textbox"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_text_found_textbox_tooltip"],
                            isMultiline = true,
                            getFunc = function()
                                return FCOCTBsettings.chatKeyWords
                            end,
                            setFunc = function(value)
                                FCOCTBsettings.chatKeyWords = value
                            end,
                            disabled = function() return FCOCTBsettings.disableChatSounds or FCOCTBsettings.playSoundOnMessageTextFound == 1 end,
                        },
                    }, --controls sounds text in messages
                }, --submenu sounds text in messages

                ----- Character-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_BUGCATEGORY0),
                    controls = {
                        {
                            type = 'slider',
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_when_charactername"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_when_charactername_tooltip"],
                            min = 1,
                            max = #FCOCTB.sounds,
                            getFunc = function()
                                return FCOCTBsettings.playSoundOnMyCharacterName
                            end,
                            setFunc = function(idx)
                                FCOCTBsettings.playSoundOnMyCharacterName = idx
                                FCOChatTabBrain_Settings_PlaySoundOnMyCharacterName.label:SetText(FCOCTBlocVarsCTB["options_chat_play_sound_when_charactername"] .. ": " .. FCOCTB.sounds[idx])
                                if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOCTB.sounds[idx]] ~= nil then
                                    PlaySound(SOUNDS[FCOCTB.sounds[idx]])
                                end
                            end,
                            default = FCOCTBdefSettings.playSoundOnMyCharacterName,
                            reference = "FCOChatTabBrain_Settings_PlaySoundOnMyCharacterName",
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                    }, --controls sounds on characterName
                }, --submenu sounds on characterName


                ----- Ignore-----------------------------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE),
                    controls = {
                        {
                            type = "editbox",
                            name = FCOCTBlocVarsCTB["options_chat_play_sound_ignore_accounts_textbox"],
                            tooltip = FCOCTBlocVarsCTB["options_chat_play_sound_ignore_accounts_textbox_tooltip"],
                            isMultiline = true,
                            getFunc = function()
                                return FCOCTBsettings.chatIgnoreNames
                            end,
                            setFunc = function(value)
                                FCOCTBsettings.chatIgnoreNames = value
                            end,
                            disabled = function() return FCOCTBsettings.disableChatSounds end
                        },
                    }, --controls sounds ignore
                }, --submenu sounds ignore

            }, -- controls chat sounds

        }, -- submenu chat sounds

    } -- closing LAM optionsTable
    LAM:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end

