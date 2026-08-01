FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

local tos = tostring
local strfor = string.format

local addonName = FCOCTB.addonVars.gAddonName
local chatSystem = FCOCTB.ChatSystem

--If the chat options dialog gets hidden
local function FCOChatTabBrain_ChatOptionsDialogOnHide(chatContainer)
    --Activate the minimization timer again if auto minimize is activated in the settings
    if FCOCTB.settingsVars.settings.autoMinimizeTimeout ~= nil and FCOCTB.settingsVars.settings.autoMinimizeTimeout > 0 and not FCOCTB.chatVars.chatMinimizeTimerActive then
        FCOCTB.chatVars.chatMinimizeTimerActive = EVENT_MANAGER:RegisterForUpdate(addonName.."ChatMinimizeCheck", 1000, FCOCTB.MinimizeChatCheck)
        FCOCTB.chatVars.lastIncomingMessage = GetTimeStamp() -- needed so the auto minimize feature starts to count the time difference from now
    end
    --Update the chat tabs from now in half a second
    zo_callLater(function()
        --Update the chat tabs
        FCOCTB.GetChatTabNames()
    end, 500)
end

--Mark/Unmark all checkboxes inside the chat options dialog container
local function ToggleMarkAll(chatContainer, hasAllMarked, cbTypes)
    if (   chatContainer == nil
            or cbTypes == nil or cbTypes == "" or (cbTypes ~= "guild" and cbTypes ~= "filter" and cbTypes ~= "all")) then return end
    hasAllMarked = hasAllMarked or false

    --Get all relevant checkboxes
    local CBs = chatContainer.owner.filterButtons
    if CBs == nil or #CBs == 0 then return end

    local filterButtons     = { filter = {}, guild = {} }

    local filtersPattern = "%sCheck"
    local parentFilter = ZO_ChatOptionsDialogFilterSection
    for i=1, parentFilter:GetNumChildren(), 1 do
        local filterChild = parentFilter:GetChild(i)
        if filterChild ~= nil and filterChild.GetName ~= nil then
            filterButtons.filter[strfor(filtersPattern, filterChild:GetName())] = true
        end
    end
--[[
    filterButtons.filter    = {
        ["ZO_ChatOptionsFilterEntry1Check"] = true,         -- Say
        ["ZO_ChatOptionsFilterEntry2Check"] = true,         -- Yell
        ["ZO_ChatOptionsFilterEntry3Check"] = true,         -- Whisper
        ["ZO_ChatOptionsFilterEntry4Check"] = true,         -- Group
        ["ZO_ChatOptionsFilterEntry5Check"] = true,         -- Actions
        ["ZO_ChatOptionsFilterEntry6Check"] = true,         -- NSCs
        ["ZO_ChatOptionsFilterEntry7Check"] = true,         -- Zone
        ["ZO_ChatOptionsFilterEntry8Check"] = true,         -- Zone EN
        ["ZO_ChatOptionsFilterEntry9Check"] = true,         -- Zone FR
        ["ZO_ChatOptionsFilterEntry10Check"] = true,        -- Zone DE
        ["ZO_ChatOptionsFilterEntry11Check"] = true,        --!!!Custom!!! From addon pChat: System
    }
]]
    local guildFiltersPattern = "ZO_ChatOptionsGuildFilters%sGuildCheck"
    local guildOfficerFiltersPattern = "ZO_ChatOptionsGuildFilters%sOfficerCheck"
    for guildIndex=1, GetNumGuilds(), 1 do
        filterButtons.guild[strfor(guildFiltersPattern, tos(guildIndex))] = true
        filterButtons.guild[strfor(guildOfficerFiltersPattern, tos(guildIndex))] = true
    end
--[[
    filterButtons.guild      = {
        ["ZO_ChatOptionsGuildFilters1GuildCheck"] = true,   -- Guild 1
        ["ZO_ChatOptionsGuildFilters1OfficerCheck"] = true, -- Guild 1 officer
        ["ZO_ChatOptionsGuildFilters2GuildCheck"] = true,   -- Guild 2
        ["ZO_ChatOptionsGuildFilters2OfficerCheck"] = true, -- Guild 2 officer
        ["ZO_ChatOptionsGuildFilters3GuildCheck"] = true,   -- Guild 3
        ["ZO_ChatOptionsGuildFilters3OfficerCheck"] = true, -- Guild 3 officer
        ["ZO_ChatOptionsGuildFilters4GuildCheck"] = true,   -- Guild 4
        ["ZO_ChatOptionsGuildFilters4OfficerCheck"] = true, -- Guild 4 officer
        ["ZO_ChatOptionsGuildFilters5GuildCheck"] = true,   -- Guild 5
        ["ZO_ChatOptionsGuildFilters5OfficerCheck"] = true, -- Guild 5 officer
    }
]]

    local filterButtonFilter = filterButtons.filter
    local filterButtonGuildFilter = filterButtons.guild

    local checkMe
    local filterButtonName
    for index, filterButton in ipairs(CBs) do
        filterButtonName = filterButton:GetName()
        checkMe = false
        if cbTypes == "all" then
            if filterButtonFilter[filterButtonName] or filterButtonGuildFilter[filterButtonName] then checkMe = true end
        elseif cbTypes == "filter" then
            if filterButtonFilter[filterButtonName] then checkMe = true end
        elseif cbTypes == "guild" then
            if filterButtonGuildFilter[filterButtonName] then checkMe = true end
        end
        if checkMe then
            if hasAllMarked then
                --Mark all checkboxes, where needed
                if filterButton:GetState() == 0 then
                    local mouseClickedHandler = filterButton:GetHandler("OnClicked")
                    if mouseClickedHandler ~= nil then
                        mouseClickedHandler(filterButton)
                    end
                end
            else
                --Unmark all checkboxes, where needed
                if filterButton:GetState() == 1 then
                    local mouseClickedHandler = filterButton:GetHandler("OnClicked")
                    if mouseClickedHandler ~= nil then
                        mouseClickedHandler(filterButton)
                    end
                end
            end
        end
    end
end

--Enhance the chat options dialog
local function FCOChatTabBrain_ChatOptionsDialogOnShow(chatContainer, chatTabIndex)
    local chatOptionsVars = FCOCTB.chatOptionsVars
    local chatVars = FCOCTB.chatVars
    local localizationVarsCTB = FCOCTB.localizationVars.fco_ctb_loc

    --Check if the timer is active and disable it then
    if chatVars.chatMinimizeTimerActive and EVENT_MANAGER:UnregisterForUpdate(addonName.."ChatMinimizeCheck") then
        chatVars.chatMinimizeTimerActive = false
    end
    --Add a checkbox to mark/unmark all options now
    if chatOptionsVars.markToggleCheckbox == nil then
        chatOptionsVars.markToggleCheckbox = WINDOW_MANAGER:CreateControlFromVirtual("FCOChatTabBrain_MarkAllChatOptions", ZO_ChatOptionsDialog, "ZO_CheckButton")
    end
    --Add a checkbox to mark/unmark all filter options now
    if chatOptionsVars.markToggleFilterCheckbox == nil then
        chatOptionsVars.markToggleFilterCheckbox = WINDOW_MANAGER:CreateControlFromVirtual("FCOChatTabBrain_MarkAllFilterChatOptions", ZO_ChatOptionsDialog, "ZO_CheckButton")
    end
    --Add a checkbox to mark/unmark all guild options now
    if chatOptionsVars.markToggleGuildCheckbox == nil then
        chatOptionsVars.markToggleGuildCheckbox = WINDOW_MANAGER:CreateControlFromVirtual("FCOChatTabBrain_MarkAllGuildChatOptions", ZO_ChatOptionsDialog, "ZO_CheckButton")
    end
    if chatOptionsVars.markToggleCheckbox == nil then return end
    if chatOptionsVars.markToggleFilterCheckbox == nil then return end
    if chatOptionsVars.markToggleGuildCheckbox == nil then return end
    ZO_CheckButton_SetLabelText(chatOptionsVars.markToggleCheckbox, localizationVarsCTB["chat_options_dialog_mark_all"])
    ZO_CheckButton_SetLabelText(chatOptionsVars.markToggleFilterCheckbox, localizationVarsCTB["chat_options_dialog_mark_all_filters"])
    ZO_CheckButton_SetLabelText(chatOptionsVars.markToggleGuildCheckbox, localizationVarsCTB["chat_options_dialog_mark_all_guilds"])
    --Reset the mark/unmark variable
    chatOptionsVars.hasAllMarked        = true
    chatOptionsVars.hasAllFilterMarked  = true
    chatOptionsVars.hasAllGuildMarked   = true
    --Set the checkbox to "checked" as default
    chatOptionsVars.markToggleCheckbox:SetState(1)
    chatOptionsVars.markToggleFilterCheckbox:SetState(1)
    chatOptionsVars.markToggleGuildCheckbox:SetState(1)
    --local cbAllWidth = chatOptionsVars.markToggleCheckbox:GetWidth() + chatOptionsVars.markToggleCheckbox:GetNamedChild("Label"):GetWidth()
    --local cbAllFilterWidth = chatOptionsVars.markToggleFilterCheckbox:GetWidth() + chatOptionsVars.markToggleFilterCheckbox:GetNamedChild("Label"):GetWidth()
    --local cbAllGuildWidth = chatOptionsVars.markToggleGuildCheckbox:GetWidth() + chatOptionsVars.markToggleGuildCheckbox:GetNamedChild("Label"):GetWidth()
    chatOptionsVars.markToggleCheckbox:SetAnchor(TOPLEFT, ZO_ChatOptionsDialogNameLabel, TOPRIGHT, 180, 2)
    chatOptionsVars.markToggleFilterCheckbox:SetAnchor(TOPLEFT, ZO_ChatOptionsDialogFilterLabel, TOPRIGHT, 130, 2)
    local guildChannelLabel = ZO_ChatOptionsDialogGuilChannelLabel
    if guildChannelLabel == nil then guildChannelLabel = ZO_ChatOptionsDialogGuildChannelLabel end
    chatOptionsVars.markToggleGuildCheckbox:SetAnchor(TOPLEFT, guildChannelLabel, TOPRIGHT, 50, 2)

    --Callback function for the OnMouseDown event handler
    local function MouseDownHandler(ctrl, type)
        local switchVar
        if type == "all" then
            chatOptionsVars.hasAllMarked = not chatOptionsVars.hasAllMarked
            switchVar = chatOptionsVars.hasAllMarked
            chatOptionsVars.hasAllFilterMarked = switchVar
            chatOptionsVars.hasAllGuildMarked  = switchVar
            if switchVar then
                chatOptionsVars.markToggleCheckbox:SetState(1)
                chatOptionsVars.markToggleFilterCheckbox:SetState(1)
                chatOptionsVars.markToggleGuildCheckbox:SetState(1)
            else
                chatOptionsVars.markToggleCheckbox:SetState(0)
                chatOptionsVars.markToggleFilterCheckbox:SetState(0)
                chatOptionsVars.markToggleGuildCheckbox:SetState(0)
            end
        elseif type == "filter" then
            chatOptionsVars.hasAllFilterMarked = not chatOptionsVars.hasAllFilterMarked
            switchVar = chatOptionsVars.hasAllFilterMarked
            if switchVar then
                chatOptionsVars.markToggleFilterCheckbox:SetState(1)
            else
                chatOptionsVars.markToggleFilterCheckbox:SetState(0)
            end
        elseif type == "guild" then
            chatOptionsVars.hasAllGuildMarked = not chatOptionsVars.hasAllGuildMarked
            switchVar = chatOptionsVars.hasAllGuildMarked
            if switchVar then
                chatOptionsVars.markToggleGuildCheckbox:SetState(1)
            else
                chatOptionsVars.markToggleGuildCheckbox:SetState(0)
            end
        end
        --Toggle the mark/unmark all checkboxes function now
        ToggleMarkAll(ctrl, switchVar, type)
    end
    --All
    ZO_PreHookHandler(chatOptionsVars.markToggleCheckbox, "OnClicked", function(ctrl, button)
        if button == 1 then
            MouseDownHandler(chatContainer, "all")
        end
        return true
    end)
    ZO_PreHookHandler(chatOptionsVars.markToggleCheckbox:GetNamedChild("Label"), "OnMouseUp", function(ctrl, button, upInside)
        if button == 1 and upInside then
            MouseDownHandler(chatContainer, "all")
        end
        return true
    end)
    --Filter
    ZO_PreHookHandler(chatOptionsVars.markToggleFilterCheckbox, "OnClicked", function(ctrl, button)
        if button == 1 then
            MouseDownHandler(chatContainer, "filter")
        end
        return true
    end)
    ZO_PreHookHandler(chatOptionsVars.markToggleFilterCheckbox:GetNamedChild("Label"), "OnMouseUp", function(ctrl, button, upInside)
        if button == 1 and upInside then
            MouseDownHandler(chatContainer, "filter")
        end
        return true
    end)
    --Guild
    ZO_PreHookHandler(chatOptionsVars.markToggleGuildCheckbox, "OnClicked", function(ctrl, button)
        if button == 1 then
            MouseDownHandler(chatContainer, "guild")
        end
        return true
    end)
    ZO_PreHookHandler(chatOptionsVars.markToggleGuildCheckbox:GetNamedChild("Label"), "OnMouseUp", function(ctrl, button, upInside)
        if button == 1 and upInside then
            MouseDownHandler(chatContainer, "guild")
        end
        return true
    end)

end

--if the ZO_DIALOG1 gets hidden
local function FCOChatTabBrain_OnDialog1IsShown(name, data, textParams, isGamepad)
    FCOCTB.preventerVars.gIsRemoveChatTabDialogActive = false
    if name == "CHAT_TAB_REMOVE" then
        FCOCTB.preventerVars.gIsRemoveChatTabDialogActive = true
    end
    return false
end

--if the ZO_DIALOG1 gets hidden
local function FCOChatTabBrain_OnDialog1IsHidden(dialogCtrl)
    if FCOCTB.preventerVars.gIsRemoveChatTabDialogActive then
        if dialogCtrl == nil then return false end
        if dialogCtrl:GetName() == "ZO_Dialog1" then
            FCOCTB.preventerVars.gIsRemoveChatTabDialogActive = false
            --Update the chat tabs from now in half a second second
            zo_callLater(function()
                FCOCTB.GetChatTabNames()
            end, 500)
        end
        return false
    end
end

--Redirect the chat input to a specific tab, e.g. whispers to a special chat tab where the whisper chat channel category was enabled to show
--> In the settings of FCOCTB you choose the chat tab to switch to for "whisper messages"
local function FCOChatTabBrain_RedirectToChannel(chatChannelId, recipientName, commandHistoryIndex)
    local redirectWhisperChannelId = FCOCTB.settingsVars.settings.redirectWhisperChannelId
    if redirectWhisperChannelId == nil or redirectWhisperChannelId == 0 then return end
    local maxChatChannels = #chatSystem.primaryContainer.windows or 1
    --Change the channel to the selected whisper redirect channel
    if chatChannelId ~= 0 and chatChannelId <= maxChatChannels then
        FCOCTB.CycleChatTab(chatChannelId)
    end
    local chatTextEntry = chatSystem.textEntry
    --Update the recipient name and the whisper message at the whisper tab edit field?
    local currentWhisperText = FCOCTB.whisperVars.currentText
    if recipientName ~= nil and commandHistoryIndex ~= nil and commandHistoryIndex >= 1 then
        local commandHistoryText = chatTextEntry.commandHistory.entries[commandHistoryIndex]
        if commandHistoryText ~= nil and commandHistoryText ~= "" then
            --d("Recipient name: " .. recipientName .. ", Chat text: " .. commandHistoryText)
            --IMportant to avoid deadloop!
            FCOCTB.preventerVars.noChatTextEntryCheck = true
            --chatSystem.textEntry.system:StartTextEntry("/w " .. recipientName .. " ")
            chatSystem:SetChannel(CHAT_CHANNEL_WHISPER, recipientName)
            --Auto complete the selected whisper name
            --chatSystem.textEntry.targetAutoComplete:OnCommit(COMMIT_BEHAVIOR_KEEP_FOCUS, AUTO_COMPLETION_SELECTED_BY_TAB)
            --Fill in the text that you typed before at another tab, the whisper message
            if currentWhisperText ~= "" then
                --chatTextEntry.system:StartTextEntry(FCOCTB.whisperVars.currentText)
                StartChatInput(currentWhisperText)
            else
                --chatTextEntry.system:StartTextEntry(commandHistoryText)
                StartChatInput(commandHistoryText)
            end
--d(">FCOChatTabBrain_RedirectToChannel. Whisper to, chat entry.")
            FCOCTB.preventerVars.noChatTextEntryCheck = false
        end

    --Only update the recipient name and the whisper chat tab
    --Coming here by pressing tab key upon auto complete of the whisper to name
    --or by entering /w /t /f and the recipient name and a text
    elseif recipientName ~= nil and commandHistoryIndex == nil then
        --d("Recipient name: " .. recipientName)
        FCOCTB.preventerVars.noChatTextEntryCheck = true
        --chatSystem.textEntry.system:StartTextEntry("/w " .. recipientName .. " ")
        chatSystem:SetChannel(CHAT_CHANNEL_WHISPER, recipientName)
        --Auto complete the selected whisper name
        --chatSystem.textEntry.targetAutoComplete:OnCommit(COMMIT_BEHAVIOR_KEEP_FOCUS, AUTO_COMPLETION_SELECTED_BY_TAB)
        FCOCTB.preventerVars.noChatTextEntryCheck = false
        if currentWhisperText ~= "" then
            zo_callLater(function()
                --chatTextEntry.editControl:SetText(FCOCTB.whisperVars.currentText)
                --chatTextEntry.editControl:TakeFocus()
                StartChatInput(currentWhisperText)
--d(">FCOChatTabBrain_RedirectToChannel. Whisper to, chat entry: Took focus")
            end, 50)
        end
    end
end

--Check if starting of chat message should be redirected to be used in another channel
local function FCOChatTabBrain_CheckChatChannelRedirect(text, channel, recipientName, doReplyWhisper, commandHistoryIndex)
    --A chat tab change is already active? Abort here
    if FCOCTB.preventerVars.changingToNewChatTab then return end
    local redirectWhisperChannelId = FCOCTB.settingsVars.settings.redirectWhisperChannelId
    if redirectWhisperChannelId == nil or redirectWhisperChannelId == 0 then return end
    doReplyWhisper = doReplyWhisper or false
    recipientName = recipientName or nil
    commandHistoryIndex = commandHistoryIndex or nil
    if channel == nil and not doReplyWhisper then return end
    if channel == nil and doReplyWhisper then
        --Add chat channel whisper, so only the chat tab will be switched
        channel = CHAT_CHANNEL_WHISPER
    end
    local currentIndex = chatSystem.primaryContainer.currentBuffer:GetParent().tab.index
    --d("[FCOChatTabBrain_CheckChatChannelRedirect] CHAT_CHANNEL_WHISPER=" .. CHAT_CHANNEL_WHISPER .. ", channel="..channel .. ", currentIndex: " .. currentIndex .. ", RecipientName: " .. recipientName .. ", currentWhisperText: " ..tos(FCOCTB.whisperVars.currentText))
    if currentIndex ~= redirectWhisperChannelId and channel == CHAT_CHANNEL_WHISPER then
        if FCOCTB.whisperVars.currentText == " " then FCOCTB.whisperVars.currentText = "" end
        --Change chat tab and fill in whispered target name + execute it so it is selected + send the text message then
        FCOChatTabBrain_RedirectToChannel(redirectWhisperChannelId, recipientName, commandHistoryIndex)
    end
    --Reset the whisper reply boolean variable
    FCOCTB.whisperVars.whisperReply = false
    --Reset the last saved whisper text/recipient name
    FCOCTB.whisperVars.currentText = ""
end

--Set the chat channel in the chat to this currentChannel so you answer in this channel if you press the "start chat" key
local function FCOChatTabBrain_SetNextChatChannel(currentChannel)
    local chatVars = FCOCTB.chatVars
    --Only go on if we received a message before, and we are not in the same channel already
    --Exception: Last incoming message was a whisper. We need to add the recipient then
    local settings = FCOCTB.settingsVars.settings
    local lastIncomingChatChannel = chatVars.lastIncomingChatChannel
    local lastIncomingChatChannelType = chatVars.lastIncomingChatChannelType
--d("[FCOChatTabBrain_SetNextChatChannel] lastIncomingChannel: " .. lastIncomingChatChannel .. " (".. lastIncomingChatChannelType .."), currentChannel:" .. currentChannel)
    if lastIncomingChatChannel == nil or lastIncomingChatChannel == ""
            or lastIncomingChatChannelType == nil or lastIncomingChatChannelType == ""
            or (currentChannel == lastIncomingChatChannelType and currentChannel ~= CHAT_CHANNEL_WHISPER) then return end
    --Get the current active chat tab
    local currentIndex = chatSystem.primaryContainer.currentBuffer:GetParent().tab.index
    --Only go on if the active chat tab equals the chat tab where we got the last message
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
    --Are we at the same chat tab, where the message came in?
    if currentIndex ~= chatTabs[lastIncomingChatChannelType] then return end
    --Important to avoid dead loop
    FCOCTB.preventerVars.noChatTextEntryCheck = true
    --Write the channel of the last received chat message to the chat so you can directly answer
    --chatSystem.textEntry.system:StartTextEntry(chatVars.lastIncomingChatChannel .. " ")
    --If last incoming message was a whsiper message, we need to answer
    if lastIncomingChatChannelType == CHAT_CHANNEL_WHISPER then
        --20201-10-03 FCOCTB v0.4.5
        --Answer last whisper, but if we were currently typing new text as the last whisper was incoming:
        --Keep the receiver of the whisper we were typing to! And do not answer the last incoming whisper message.
        local lastWhisperReceiver = FCOCTB.whisperVars.lastReceiver
        local currentReceiver = chatSystem.currentReceiver
--d(">currentReceiver: " ..tos(currentReceiver) .. ", lastWhisperReceiver: " ..tos(lastWhisperReceiver))
        if (lastWhisperReceiver ~= nil and lastWhisperReceiver ~= "") and (currentReceiver ~= nil and currentReceiver ~= "")
            and currentReceiver ~= lastWhisperReceiver then
            chatSystem:SetChannel(CHAT_CHANNEL_WHISPER, lastWhisperReceiver)
            FCOCTB.whisperVars.lastReceiver = ""
        else
            --We were not typing to someone else as the last incoming whisper appeared and thus we just need to answer the last incoming
            --whisper message now
            FCOCTB.whisperVars.lastReceiver = ""
            ChatReplyToLastWhisper() --ESO standard function
        end
    else
        --No whisper message
        chatSystem:SetChannel(lastIncomingChatChannelType, nil)
    end
    FCOCTB.preventerVars.noChatTextEntryCheck = false
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--Other hooks
function FCOCTB.hookOther_functions()
    -- PreHook ReloadUI, LogOut & Quit to save last active chat tab
    ZO_PreHook("ReloadUI", function()
        FCOCTB.SaveLastActiveChatTab()
    end)

    ZO_PreHook("Logout", function()
        FCOCTB.SaveLastActiveChatTab()
    end)

    ZO_PreHook("SetCVar", function()
        FCOCTB.SaveLastActiveChatTab()
    end)

    ZO_PreHook("Quit", function()
        FCOCTB.SaveLastActiveChatTab()
    end)
end

--Chat hooks
function FCOCTB.hookChat_functions()
    chatSystem = FCOCTB.ChatSystem
    --Chat hooks

    --Run this code once as the buttons might be shown and will be only updated as you mouse hover the chat and leave it again
    chatSystem.mailButton:SetInheritAlpha(true)
    chatSystem.mailLabel:SetInheritAlpha(true)
    chatSystem.friendsButton:SetInheritAlpha(true)
    chatSystem.friendsLabel:SetInheritAlpha(true)
    chatSystem.notificationsButton:SetInheritAlpha(true)
    chatSystem.notificationsLabel:SetInheritAlpha(true)
    chatSystem.agentChatButton:SetInheritAlpha(true)

    --FadeIn
    ZO_PreHook(chatSystem.primaryContainer, "FadeIn", function(delay)
        if FCOCTB.settingsVars.settings.fadeOutChatButtons and not FCOCTB.preventerVars.fadingIn then
            FCOCTB.preventerVars.fadingIn = true
            FCOCTB.preventerVars.fadingOut	= false
            chatSystem.mailButton:SetInheritAlpha(true)
            chatSystem.mailLabel:SetInheritAlpha(true)
            chatSystem.friendsButton:SetInheritAlpha(true)
            chatSystem.friendsLabel:SetInheritAlpha(true)
            chatSystem.notificationsButton:SetInheritAlpha(true)
            chatSystem.notificationsLabel:SetInheritAlpha(true)
            chatSystem.agentChatButton:SetInheritAlpha(true)
        end
    end) -- ZO_PreHook(FadeIn)

    --FadeOut
    local function FCOChatTabBrain_Chat_FadeOut_Hook(container, delay)
        if FCOCTB.settingsVars.settings.fadeOutChatButtons and not FCOCTB.preventerVars.fadingOut then
            FCOCTB.preventerVars.fadingIn = false
            FCOCTB.preventerVars.fadingOut = true
            chatSystem.mailButton:SetInheritAlpha(true)
            chatSystem.mailLabel:SetInheritAlpha(true)
            chatSystem.friendsButton:SetInheritAlpha(true)
            chatSystem.friendsLabel:SetInheritAlpha(true)
            chatSystem.notificationsButton:SetInheritAlpha(true)
            chatSystem.notificationsLabel:SetInheritAlpha(true)
            chatSystem.agentChatButton:SetInheritAlpha(true)
        end
        if container == nil then return false end
        if container.fadeInReferences > 0 then return end

        if not container.fadeAnim then
            container.fadeAnim = ZO_AlphaAnimation:New(container.control)
        end
        container.fadeAnim:SetMinMaxAlpha(container.minAlpha, container.maxAlpha)
        local FADE_ANIMATION_DURATION = 350
        local FADE_ANIMATION_DELAY = 3000
        local fadeOutDelay = delay or FCOCTB.settingsVars.settings.fadeOutChatTime
        if fadeOutDelay == nil or fadeOutDelay < 0 then
            fadeOutDelay = FADE_ANIMATION_DELAY
        end
        container.fadeAnim:FadeOut(fadeOutDelay, FADE_ANIMATION_DURATION)
        --Prevent normal chat's FadeOut() function
        return true
    end
    ZO_PreHook(chatSystem.primaryContainer, "FadeOut", FCOChatTabBrain_Chat_FadeOut_Hook)

    local function showMinimizedChatCtrlsAgain(ctrlTable)
        for i, ctrl in pairs(ctrlTable) do
            if ctrl ~= nil and ctrl:IsHidden() then
                ctrl:SetHidden(false)
            end
        end
    end

    --Chat button: Unread notifications
    ZO_PreHook(SharedChatSystem, "OnNumNotificationsChanged", function(self, numNotifications)
        local settings = FCOCTB.settingsVars.settings
        if settings.fadeOutChatButtons then
            if numNotifications > 0 then
                zo_callLater(function()
                    chatSystem.notificationsButton:SetInheritAlpha(true)
                    chatSystem.notificationsLabel:SetInheritAlpha(true)
                end, settings.fadeOutChatButtonsTime)
                --If the setting is enabled to hide the minimzed chat bar + icons if no new messages, friends, etc. change
                if settings.hideIconsInMinimizedChatWindow and chatSystem:IsMinimized() then
                    --Show the hidden chat buttons, if chat is minimized, again
                    local ctrlTable = {}
                    table.insert(ctrlTable, chatSystem.notificationsButton)
                    table.insert(ctrlTable, chatSystem.notificationsLabel)
                    showMinimizedChatCtrlsAgain(ctrlTable)
                end
            end
        end
    end)

    --Chat button: Unread mails
    ZO_PreHook(SharedChatSystem, "OnNumUnreadMailChanged", function(self, numUnread)
        local settings = FCOCTB.settingsVars.settings
        if settings.fadeOutChatButtons then
            if numUnread > 0 then
                zo_callLater(function()
                    chatSystem.mailButton:SetInheritAlpha(true)
                    chatSystem.mailLabel:SetInheritAlpha(true)
                end, settings.fadeOutChatButtonsTime)
                --If the setting is enabled to hide the minimzed chat bar + icons if no new messages, friends, etc. change
                if settings.hideIconsInMinimizedChatWindow and chatSystem:IsMinimized() then
                    --Show the hidden chat buttons, if chat is minimized, again
                    local ctrlTable = {}
                    table.insert(ctrlTable, chatSystem.mailButton)
                    table.insert(ctrlTable, chatSystem.mailLabel)
                    showMinimizedChatCtrlsAgain(ctrlTable)
                end
            end
        end
    end)

    --Chat button: chat with support agent
    ZO_PreHook(SharedChatSystem, "OnAgentChatActiveChanged", function(self)
        local settings = FCOCTB.settingsVars.settings
        if settings.fadeOutChatButtons then
            zo_callLater(function()
                chatSystem.agentChatButton:SetInheritAlpha(true)
            end, settings.fadeOutChatButtonsTime)
            --If the setting is enabled to hide the minimzed chat bar + icons if no new messages, friends, etc. change
            if settings.hideIconsInMinimizedChatWindow and chatSystem:IsMinimized() then
                --Show the hidden chat buttons, if chat is minimized, again
                local ctrlTable = {}
                table.insert(ctrlTable, chatSystem.agentChatButton)
                showMinimizedChatCtrlsAgain(ctrlTable)
            end
        end
    end)

    --Chat button: online friends
    ZO_PreHook(SharedChatSystem, "OnNumOnlineFriendsChanged", function(self)
        local settings = FCOCTB.settingsVars.settings
        if settings.fadeOutChatButtons then
            zo_callLater(function()
                chatSystem.friendsButton:SetInheritAlpha(true)
                chatSystem.friendsLabel:SetInheritAlpha(true)
            end, settings.fadeOutChatButtonsTime)
            --If the setting is enabled to hide the minimzed chat bar + icons if no new messages, friends, etc. change
            if settings.hideIconsInMinimizedChatWindow and chatSystem:IsMinimized() then
                --Show the hidden chat buttons, if chat is minimized, again
                local ctrlTable = {}
                table.insert(ctrlTable, chatSystem.friendsButton)
                table.insert(ctrlTable, chatSystem.friendsLabel)
                showMinimizedChatCtrlsAgain(ctrlTable)
            end
        end
    end)

    --Change the chat options dialog and add new checkboxes to mark/unmark several checkboxes at once
    ZO_PreHookHandler(ZO_ChatOptionsDialog, "OnShow", FCOChatTabBrain_ChatOptionsDialogOnShow)
    --Change the chat options dialog and add new checkboxes to mark/unmark several checkboxes at once
    ZO_PreHookHandler(ZO_ChatOptionsDialog, "OnHide", FCOChatTabBrain_ChatOptionsDialogOnHide)

    --Change the chat delete tab ZO_Dialog1 control
    ZO_PreHook("ZO_Dialogs_ShowDialog", FCOChatTabBrain_OnDialog1IsShown)
    ZO_PreHookHandler(ZO_Dialog1, "OnHide", FCOChatTabBrain_OnDialog1IsHidden)

    --save current settings
    ZO_PreHook(chatSystem, "ValidateChatChannel", function(self)
        --d("[ValidateChatChannel]")
        local settings = FCOCTB.settingsVars.settings
        if (settings.chatBrainActive == true) then
            local tabIndex = self.primaryContainer.currentBuffer:GetParent().tab.index
            settings.brain[tabIndex] = settings.brain[tabIndex] or {}
            --d("ValidateChatChannel, channel: " .. tos(self.currentChannel) .. ", target: " .. tos(self.currentTarget))
            --Redirect of whispers is deactivated
            if settings.redirectWhisperChannelId == 0 or settings.redirectWhisperChannelId == nil then
                settings.brain[tabIndex].channel = self.currentChannel
                settings.brain[tabIndex].target  = self.currentTarget
            else
                --Redirect of whispers is activated
                --No whispering!
                if self.currentChannel ~= CHAT_CHANNEL_WHISPER and tabIndex ~= settings.redirectWhisperChannelId then
                    --Outside of the whisper chat channel (e.g. /guild1, or /say) and not at the whisper chat tab
                    settings.brain[tabIndex].channel = self.currentChannel
                    settings.brain[tabIndex].target  = self.currentTarget
                    --Whispering
                elseif self.currentChannel == CHAT_CHANNEL_WHISPER and tabIndex ~= settings.redirectWhisperChannelId then
                    --Inside the whisper chat channel and not at the whisper chat tab
                    --so don't change the "tab brain" to current tab, but to the whisper tab
                    settings.brain[settings.redirectWhisperChannelId] = settings.brain[settings.redirectWhisperChannelId] or {}
                    settings.brain[settings.redirectWhisperChannelId].channel = self.currentChannel
                    settings.brain[settings.redirectWhisperChannelId].target  = self.currentTarget
                else
                    --Inside the whisper chat channel and at the whisper chat tab
                    settings.brain[tabIndex].channel = self.currentChannel
                    settings.brain[tabIndex].target  = self.currentTarget
                end
            end
        end
    end)

    --OnMouseUp of tabs: Clear chat on current tab by clicking left mouse + SHIFT
    -->Carefull: Using SHIFT key for sprinting (by feet or mounted) will clear teh chat buffer if useing keybind to switch chat tabs :-(
    ZO_PreHook(chatSystem.primaryContainer.tabGroup, "HandleMouseDown", function(self, tab, button, downInside)
        FCOCTB.SetUserLastAction()
        if button == MOUSE_BUTTON_INDEX_LEFT and IsShiftKeyDown() and FCOCTB.settingsVars.settings.clearChatBufferOnShiftClick then
            if FCOCTB.preventerVars.doNotDoShiftClickCheck == true then
                FCOCTB.preventerVars.doNotDoShiftClickCheck = false
                return
            end
            FCOCTB.ClearChatBuffer(tab)
        end
    end)

    --load chat brain settings
    ZO_PreHook(chatSystem.primaryContainer, "HandleTabClick", function(self, tab)
        local settings = FCOCTB.settingsVars.settings
        if (settings.chatBrainActive == true) then
            local tabIndex = tab.index
            --d("Clicked on chat tab, index: " .. tos(tabIndex))
            if settings.brain[tabIndex] then
                chatSystem:SetChannel(settings.brain[tabIndex].channel, settings.brain[tabIndex].target)
            end
            --Clear the chatBuffer if the tab was clicked with the SHIFT key active?
        end
        --Reset the color of the chat tab, if it was set to blue
        ZO_TabButton_Text_RestoreDefaultColors(tab)
    end)

    --PreHook the chat "reply to whisper" keybind function
    ZO_PreHook("ChatReplyToLastWhisper", function()
--d("[FCOCTB]ChatReplyToLastWhisper")
        local redirectWhisperChannelId = FCOCTB.settingsVars.settings.redirectWhisperChannelId
        if  redirectWhisperChannelId ~= nil and redirectWhisperChannelId ~= 0 then
            --Set whisper reply boolean value to true.
            -- Will be reset to false again at end of function: FCOChatTabBrain_CheckChatChannelRedirect()
            FCOCTB.whisperVars.whisperReply = true
        end
    end)

    --PreHook the chat input method to check whispers etc. (inside chat context menu etc.)
    ZO_PreHook(chatSystem, "StartTextEntry", function(ctrl, text, channel, target, showVirtualKeyboard)
        FCOCTB.SetUserLastAction()
        --No check allowed? Abort here as else an endless loop would happen between StartTextEntry->FCOChatTabBrain_SetNextChatChannel->StartTextEntry->...
        if FCOCTB.preventerVars.noChatTextEntryCheck then return end

        --Get the current chat channel
        local currentChannel = FCOCTB.GetActiveChatChannelAtTab()
--d("[StartTextEntry]currentChannel: " ..tos(currentChannel))
        --If we are not whispering
        if currentChannel ~= nil then
            --Set the next outgoing chat channel to the last incoming chat message channel.
            --If the message is a whisper message do some special checks
            FCOChatTabBrain_SetNextChatChannel(currentChannel)
        end
        if currentChannel == CHAT_CHANNEL_WHISPER then
            local redirectWhisperChannelId = FCOCTB.settingsVars.settings.redirectWhisperChannelId
            local whisperReply = FCOCTB.whisperVars.whisperReply
--d(">whispering, redirect to chatTab: " ..tos(redirectWhisperChannelId) .. ", target: " ..tos(target) ..", whisperReply: " ..tos(whisperReply))
            if redirectWhisperChannelId ~= nil and redirectWhisperChannelId ~= 0 then
                if text == nil or text == "" and channel == "" or channel == nil and target == nil then return end
                --d("StartTextEntry: text=" .. text .. ", channel=" .. tos(channel) .. ", target=" .. target)
                --call slightly delayed as otherwise the commandHistory is not updated yet
                zo_callLater(function()
                    FCOChatTabBrain_CheckChatChannelRedirect(text, channel, target, whisperReply, nil)
                end, 50)
            end
        end
    end)

    --PreHook the chat system's return key/chat text was sent
    ZO_PreHook("ZO_ChatTextEntry_Execute", function(control)
        --d("[ZO_ChatTextEntry_Execute]")
        FCOCTB.SetUserLastAction()
        --Do not check? then abort here
        if FCOCTB.preventerVars.noChatTextEntryCheck then return end
        --If whisper redirect is enabled
        local redirectWhisperChannelId = FCOCTB.settingsVars.settings.redirectWhisperChannelId
        if redirectWhisperChannelId ~= nil and redirectWhisperChannelId ~= 0 then
            local currentChannel = FCOCTB.GetActiveChatChannelAtTab()
            --d("Chat text sent, currentChannel: " .. currentChannel)
            local currentIndex = chatSystem.primaryContainer.currentBuffer:GetParent().tab.index
            if currentChannel == CHAT_CHANNEL_WHISPER and currentIndex ~= redirectWhisperChannelId then
                --save the currently entered text
                FCOCTB.whisperVars.currentText = chatSystem.textEntry.editControl:GetText()
                --d("ZO_ChatTextEntry_Execute: " .. FCOCTB.whisperVars.currentText)
                --call slightly delayed as otherwie commandHistory is not updated yet
                zo_callLater(function()
                    --The commandHistory stores the written text/command
                    --local commandHistoryIndex = chatSystem.textEntry.commandHistory.index
                    --if commandHistoryIndex < 1 then commandHistoryIndex = 1 end
                    --d("CommandHistoryText: " .. chatSystem.textEntry.commandHistory.entries[commandHistoryIndex])
                    --Last recipient is stored in chatSystem.currentTarget
                    local lastRecipient = chatSystem.currentTarget
                    FCOChatTabBrain_CheckChatChannelRedirect(nil, CHAT_CHANNEL_WHISPER, lastRecipient, false, nil) --last parameter was before: commandHistoryIndex)
                end, 50)
            end
            --Not whispering
        end
    end)

    --PreHook the chat system's tabulator key in the text edit (for auto complete) by pre hooking the ZO_AutoComplete OnCommit function
    ZO_PreHook(chatSystem.textEntry.targetAutoComplete, "OnCommit", function(commitBehavior, commitMethod)
        --d("Auto complete entry OnCommit, commitBehavior: " .. tos(commitBehavior) .. ", commitMethod: " .. tos(commitMethod))
        FCOCTB.SetUserLastAction()
        local redirectWhisperChannelId = FCOCTB.settingsVars.settings.redirectWhisperChannelId
        if redirectWhisperChannelId ~= nil and redirectWhisperChannelId ~= 0 then
            --commitMethod can be AUTO_COMPLETION_SELECTED_BY_TAB, AUTO_COMPLETION_SELECTED_BY_ENTER
            zo_callLater(function()
                local currentChannel = FCOCTB.GetActiveChatChannelAtTab()
                if currentChannel ~= "" and currentChannel == CHAT_CHANNEL_WHISPER then
                    --d("Auto complete commit. Channel: " .. currentChannel .. ", Target: " .. chatSystem.currentTarget)
                    --Last recipient is stored in chatSystem.currentTarget
                    local lastRecipient = chatSystem.currentTarget
                    FCOChatTabBrain_CheckChatChannelRedirect(nil, CHAT_CHANNEL_WHISPER, lastRecipient, false, nil)
                end
            end, 50)
        end
    end)

    --PreHook the function when you select an entry of the autocomplete
    ZO_PreHook(chatSystem.textEntry.targetAutoComplete, "FireCallbacks", function(control, eventName, name, autoCompleteType)
        --d("Auto complete entry FireCallbacks - eventName: " .. tos(eventName) .. ", name: " .. tos(name) .. ", autoCompleteType: " .. tos(autoCompleteType))
        if FCOCTB.settingsVars.settings.redirectWhisperChannelId ~= 0 and FCOCTB.settingsVars.settings.redirectWhisperChannelId ~= nil then
            if autoCompleteType == AUTO_COMPLETION_SELECTED_BY_CLICK then
                zo_callLater(function()
                    local currentChannel = FCOCTB.GetActiveChatChannelAtTab()
                    if currentChannel ~= "" and currentChannel == CHAT_CHANNEL_WHISPER then
                        local lastRecipient = name or chatSystem.currentTarget
                        FCOChatTabBrain_CheckChatChannelRedirect(nil, CHAT_CHANNEL_WHISPER, lastRecipient, false, nil)
                    end
                end, 50)
            end
        end
    end)

    --Chat minimize button mouse up callback function
    ZO_PreHookHandler(ZO_ChatWindowMinimize, "OnMouseUp", function(control, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
            --Prevent that the chat automatically maximizes again as the mouse is still above the same button which
            --will become the ZO_ChatWindowMinBarMaximize button now
            --Preventer variable will be reset upon hovering the mouse away from the button the first time
            FCOCTB.preventerVars.chatMinimizeButtonClicked = true
        end
        FCOCTB.SetUserLastAction()
    end)
    ZO_PreHookHandler(ZO_ChatWindowMinBarMaximize, "OnMouseExit", function(control)
        --Preventer variable will be reset upon hovering the mouse away from the button the first time
        FCOCTB.preventerVars.chatMinimizeButtonClicked = false
    end)
    --Chat maximize button mouse enter callback function
    ZO_PostHookHandler(ZO_ChatWindowMinBarMaximize, "OnMouseEnter", function(control)
        local chatMinimizeButtonClicked = FCOCTB.preventerVars.chatMinimizeButtonClicked
        if not chatMinimizeButtonClicked and FCOCTB.settingsVars.settings.maximizeChatOnMouseHoverOverMaximizeButton and chatSystem:IsMinimized() then
            chatSystem:Maximize()
            FCOCTB.SetUserLastAction()
        end
    end)

    --Chat mouse wheel callback function
    ZO_PreHook("ZO_ChatSystem_OnMouseWheel", function(control, delta, ctrl, alt, shift)
        FCOCTB.SetUserLastAction()
    end)

    --Chat mouse enter callback function
    ZO_PreHook("ZO_ChatSystem_OnMouseEnter", function(control)
        FCOCTB.SetUserLastAction()
    end)

    --Prehook the Min-/Maximize chat button OnClicked function
    ZO_PreHook("ZO_ChatSystem_OnMinMaxClicked", function()
        FCOCTB.preventerVars.clickedMinMaxChatButton = true
    end)

    --Prehook the chat Minimize method
    ZO_PreHook(chatSystem, "Minimize", function(...)
--d("[FCOCTB]ChatMinimize")
        local prevVars = FCOCTB.preventerVars
        local settings = FCOCTB.settingsVars.settings
        local chatVars = FCOCTB.chatVars
        if prevVars.clickedMinMaxChatButton then
            FCOCTB.preventerVars.chatMinimizeButtonClicked = true
            FCOCTB.SetUserLastAction()
        end
        FCOCTB.preventerVars.clickedMinMaxChatButton = false
        --Disable the timer for the chat auto minimization
        --d("Timer active: " .. tos(chatVars.chatMinimizeTimerActive))
        --Only go on with further checks if the chat is not minimized on load of the addon
        if settings.chatMinimizeOnLoad and not FCOCTB.addonVars.gAddonFullyLoaded then return false end
        --Check if the timer is active and disable it then
        if chatVars.chatMinimizeTimerActive and EVENT_MANAGER:UnregisterForUpdate(addonName.."ChatMinimizeCheck") then
            chatVars.chatMinimizeTimerActive = false
        end

        --If the setting is enabled to hide the minimzed chat bar + icons if no new messages, friends, etc. change
        if settings.hideIconsInMinimizedChatWindow then
            zo_callLater(function()
                --Get the minimized chat bar
                local minBar = ZO_ChatWindowMinBar
                if minBar ~= nil then
                    --Clear the remembered control names table
                    FCOCTB.onChatMinimizedControls = {}
                    --Get all children of the bar except the "maximaize" button and hide them
                    for i=1, minBar:GetNumChildren() do
                        local child = minBar:GetChild(i)
                        if child ~= nil and child ~= ZO_ChatWindowMinBarMaximize and not child:IsHidden() then
                            child:SetHidden(true)
                            table.insert(FCOCTB.onChatMinimizedControls, child)
                        end
                    end
                end
            end, 100)
        end
    end)

    --Prehook the chat tab OnClicked method
    ZO_PreHook(chatSystem, "Maximize", function(...)
--d("[FCOCTB]ChatMaximize")
        local prevVars = FCOCTB.preventerVars
        local settings = FCOCTB.settingsVars.settings
        local chatVars = FCOCTB.chatVars
        if prevVars.clickedMinMaxChatButton then
            FCOCTB.preventerVars.chatMinimizeButtonClicked = false
            FCOCTB.SetUserLastAction()
        end
        FCOCTB.preventerVars.clickedMinMaxChatButton = false
        --Enable the timer for the chat auto minimization again
        local autoMinimizeTimeout = settings.autoMinimizeTimeout
--d("Timer active: " .. tos(chatVars.chatMinimizeTimerActive) .. ", autoMinimizeTimeout: " ..tos(autoMinimizeTimeout))
        if autoMinimizeTimeout ~= nil and autoMinimizeTimeout > 0 and not chatVars.chatMinimizeTimerActive then
            chatVars.chatMinimizeTimerActive = EVENT_MANAGER:RegisterForUpdate(addonName.."ChatMinimizeCheck", 1000, FCOCTB.MinimizeChatCheck)
            chatVars.lastIncomingMessage = GetTimeStamp() -- needed so the auto minimize feature starts to count the time difference from now
        end
        --If the setting is enabled to hide the minimzed chat bar + icons if no new messages, friends, etc. change
        FCOCTB.showMinimizedChatButtonsAgain()
        --[[
                --Workaround for FTC (Foundry Tactical Combat) addon - Combat log won't hide properly
                --FTC Combat Log is activated?
                if FTC and FTC.Vars.EnableLog then
        d("1")
                    --FTC combat log will hide/show if chat is maximized/minimized?
                    if FTC.Vars.AlternateChat then
                        --Is the FTC combat log control visible?
                        if FTC_CombatLog and not FTC_CombatLog:IsHidden() then
        d("3")
                            --Hide the combat log now
                            FTC_CombatLog:SetHidden(true)
                        end
                    end
                end
        ]]
    end)
end
