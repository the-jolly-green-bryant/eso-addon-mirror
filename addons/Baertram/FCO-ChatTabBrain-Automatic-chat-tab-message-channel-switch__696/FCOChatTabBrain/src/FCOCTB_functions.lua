FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

local chatSystem = FCOCTB.ChatSystem

--================= GLOBAL FUNCTIONS ===========================================

function FCOCTB.GetChatSystem()
    chatSystem = FCOCTB.ChatSystem
end

--Function to cycle through the last chat channels at the given chat tab
function FCOCTB.CycleChatChannel()
    FCOCTB.SetUserLastAction()
    --Get the actual chat tab (index)
    local container = chatSystem.primaryContainer
    if not container then return nil end
    local index = container.currentBuffer:GetParent().tab.index
    --d("[FCOCTB]CycleChatChannel, tab: " .. tostring(index))
    --Does the tab exist?
    if container.windows[index].tab then
        --Get the last used & saved chat channels at this tab now
        local settings = FCOCTB.settingsVars.settings
        if settings ~= nil and settings.lastUsedChatChannelsAtTab and settings.lastUsedChatChannelsAtTab[index] ~= nil then
            local lastChatChannelsAtTab = settings.lastUsedChatChannelsAtTab[index]
            if lastChatChannelsAtTab ~= nil and #lastChatChannelsAtTab > 1 then
                --Got the last used chat channels. Get the active chat channel at the tab now.
                local activeChatChannelAtTab = FCOCTB.GetActiveChatChannelAtTab()
                if activeChatChannelAtTab ~= nil and activeChatChannelAtTab ~= 0 then
                    local nextChatChannelAtTab = 0
                    --And then cycle through the last used chat channels at this tab
                    for _, chatChannel in ipairs(lastChatChannelsAtTab) do
                        if nextChatChannelAtTab == 0 and chatChannel ~= nil and activeChatChannelAtTab ~= chatChannel then
                            nextChatChannelAtTab = chatChannel
                            break --Leave the loop
                        end
                    end
                    --d(">nextChatChannelAtTab: " ..tostring(nextChatChannelAtTab))
                    --Set the new chat channel at the tab now
                    if nextChatChannelAtTab ~= nil and nextChatChannelAtTab ~= 0 then
                        --Important to avoid dead loop
                        FCOCTB.preventerVars.noChatTextEntryCheck = true
                        --Set chat channel
                        chatSystem:SetChannel(nextChatChannelAtTab, nil)
                        FCOCTB.preventerVars.noChatTextEntryCheck = false
                    end
                end
            end
        end
    end
end

--function to cycle the chat tab to left/right or given index
--chatTabIndex can be 1 to N (where N is the current maximum chat tab)
--or "-" to cycle left or "+" to cycle right
function FCOCTB.CycleChatTab(chatTabIndex, doOverride, byKeybind)
    doOverride = doOverride or false
    byKeybind = byKeybind or false
    if not doOverride then FCOCTB.SetUserLastAction() end
    local container = chatSystem.primaryContainer
    if not container then return nil end
    local index = container.currentBuffer:GetParent().tab.index
    if type(chatTabIndex) ~= "number" then
        --Cycle left
        if     chatTabIndex == "-" then
            index = (index == 1) and (container.hiddenTabStartIndex - 1) or (index - 1)
            --Cycle right
        elseif chatTabIndex == "+" then
            index = (index == container.hiddenTabStartIndex - 1) and 1 or (index + 1)
        else
            return nil
        end
    else
        --Choose chatTab by index
        --Abort here if new index is the same as current, new index is smaller then minimum index or new index is higher then # of maximum chat tabs
        if index == chatTabIndex or chatTabIndex < 1 or chatTabIndex > #container.windows then return nil end
        index = chatTabIndex
    end
    --Set the new chatTab now
    if container.windows[index].tab then
        FCOCTB.preventerVars.doNotDoShiftClickCheck = true
        container.tabGroup:SetClickedButton(container.windows[index].tab)
        --Reopen the chat if wished
        local chatIsMinimized = chatSystem:IsMinimized()
        local settings = FCOCTB.settingsVars.settings
        if settings.reOpenChatIfMinimized and chatIsMinimized then
            chatSystem:Maximize()
        end
        --Fade-In the chat if wished
        if settings.fadeInChatOnCycle and not chatIsMinimized then
            container:FadeIn()
        end
        FCOCTB.preventerVars.doNotDoShiftClickCheck = false

        if byKeybind == true and settings.autoScrollToChatBottomUponKeybindTabSwitch == true then
            FCOCTB.ScrollChatTabToBottom()
        end

        return true
    else
        return nil
    end
end

--Load the last saved chat tab
function FCOCTB.LoadLastActiveChatTab()
    --d("[FCOChatTabBrain] Last active chat tab: " .. tostring(FCOCTB.settingsVars.settings.lastActiveChatTab))
    local settings = FCOCTB.settingsVars.settings
    local rememberLastActiveChatTab = settings.rememberLastActiveChatTab
    local lastActiveChatTab = settings.lastActiveChatTab
    if rememberLastActiveChatTab and lastActiveChatTab ~= nil and lastActiveChatTab ~= 1 then
        FCOCTB.CycleChatTab(lastActiveChatTab)
    end
end

--Update the last user action + time
function FCOCTB.SetUserLastAction()
    local currentTime = GetTimeStamp()
    --Save the last user action as timestamp
    local chatVars = FCOCTB.chatVars
    chatVars.lastUserActiveTime = currentTime
    FCOCTB.preventerVars.timeNotReached = true
    chatVars.lastIncomingMessage = currentTime -- needed so the auto minimize feature starts to count the time difference from now
    --Reset/Enable the timer for the default chat tab idle change
    FCOCTB.SetupDefaultTabIdleTimer(true)
end

--Function to get the active chat channel at a chattab
function FCOCTB.GetActiveChatChannelAtTab()
    local activeChannelAtTab = 0
    if chatSystem and chatSystem.currentChannel then
        activeChannelAtTab = chatSystem.currentChannel
    end
    return activeChannelAtTab
end

--Save the last active chat tab
function FCOCTB.SaveLastActiveChatTab()
    local settings = FCOCTB.settingsVars.settings
    if settings.rememberLastActiveChatTab then
        local container = chatSystem.primaryContainer
        if not container then return nil end
        local chatTabIndex = container.currentBuffer:GetParent().tab.index
        if chatTabIndex == nil then return false end
        settings.lastActiveChatTab = chatTabIndex
    end
end

--Check if the user is currently using the chat edit field
function FCOCTB.CheckIfChatTextEditIsUsed()
    local textEntry = chatSystem.textEntry
    local chatEditText = textEntry and textEntry:GetText()
    if (chatEditText ~= nil and chatEditText ~= "" and chatEditText ~= " ")
       or (textEntry:IsOpen() or textEntry:IsAutoCompleteOpen()) then
        return true
    else
        return false
    end
end

--Check if the chat window is used in any way
function FCOCTB.CheckIfChatWindowUsed()
    if chatSystem == nil or chatSystem.primaryContainer == nil then return false end
    local retVal = chatSystem.primaryContainer:IsMouseInside()
    --If the mouse is inside the chat window container & if the chat minimization timer is currently active -> Reset the timer for the automatic minimization
    if retVal and FCOCTB.chatVars.chatMinimizeTimerActive then
        FCOCTB.chatVars.lastIncomingMessage = GetTimeStamp() -- needed so the auto minimize feature starts to count the time difference from now
    end
    return retVal
end

--Global function to clear the chat buffer
function FCOCTB.ClearChatBuffer(tab)
    local currentChatBuffer
    if tab == nil then
        currentChatBuffer = chatSystem.primaryContainer.currentBuffer
    else
        currentChatBuffer = tab:GetParent().container.currentBuffer
    end
    if currentChatBuffer ~= nil then
        currentChatBuffer:Clear()
    end
end

function FCOCTB.setChatBrain(onOff)
    -- Enable/Disable the ChatBrain
    FCOCTB.settingsVars.settings.chatBrainActive = onOff
end

function FCOCTB.toggleChatBrain()
    -- Toggle the ChatBrain
    local chatBrainActive = FCOCTB.settingsVars.settings.chatBrainActive
    FCOCTB.settingsVars.settings.chatBrainActive = not chatBrainActive
end

--Get the shown text on the chat tabs
function FCOCTB.GetChatTabNames()
    local chatTabs = chatSystem.tabPool.m_Active
    if chatTabs ~= nil and #chatTabs >= 1 then
        local chatVars = FCOCTB.chatVars
        local localizationVarsCTB = FCOCTB.localizationVars.fco_ctb_loc
        chatVars.chatTabNames = {}
        local lastIndex = 0
        --Add the active chat tab names/texts now
        for index, chatTab in pairs(chatTabs) do
            local chatTabTextLabel = chatTab:GetNamedChild("Text")
            if chatTabTextLabel ~= nil then
                local chatTabName = chatTabTextLabel:GetText()
                if chatTabName ~= nil and chatTabName ~= "" and chatTabName ~= " " then
                    chatVars.chatTabNames[index] = chatTabName
                    lastIndex = index
                end
            end
        end
        --Add the "Disabled" entry at the end
        chatVars.chatTabNames[lastIndex+1] = localizationVarsCTB["options_checkbox_redirect_whisper_chat_disable"]
    end
end

--If the setting is enabled to hide the minimzed chat bar + icons if no new messages, friends, etc. change
function FCOCTB.showMinimizedChatButtonsAgain(override)
    override = override or false
--d("[FCOCTB]showMinimizedChatButtonsAgain, override: " ..tostring(override) .. ", hideIconsInMinimizedChatWindow: " .. tostring(FCOCTB.settingsVars.settings.hideIconsInMinimizedChatWindow))
    if override or FCOCTB.settingsVars.settings.hideIconsInMinimizedChatWindow then
        --Get the minimized chat bar
        local minBar = ZO_ChatWindowMinBar
        if minBar ~= nil then
            --[[
            for i=1, minBar:GetNumChildren() do
                local child = minBar:GetChild(i)
                if child ~= nil and child ~= ZO_ChatWindowMinBarMaximize then
                    child:SetHidden(false)
                end
            end
            ]]
            --Show the before hidden controls again now
            if FCOCTB.onChatMinimizedControls ~= nil then
                local minimizedCtrlsTable = FCOCTB.onChatMinimizedControls
                for index, ctrl in pairs(minimizedCtrlsTable) do
                    if ctrl ~= nil or (nil ~= ctrl and nil ~= FCOChatWindowGuildInfoLabel and ctrl == FCOChatWindowGuildInfoLabel) then
                        ctrl:SetHidden(false)
                    end
                end
                FCOCTB.onChatMinimizedControls = {}
            end
        end
    end
end

--Check if the chat is not minimzed, the settings to minimize it automatically after a timeout is set and compare
--last incoming chat message time with current time + set timeout, then minimize the chat if applicable
function FCOCTB.MinimizeChatCheck()
    --Compare the current timestamp with last chat message timestamp and minimize chat if we reached the user defined timeout
    --and if the chat window is currently not used (mouse is above it) and no text is typed into the chat editbox
    local autoMinimizeTimeout = FCOCTB.settingsVars.settings.autoMinimizeTimeout
    local lastIncomingMessage = FCOCTB.chatVars.lastIncomingMessage
    if autoMinimizeTimeout ~= nil and autoMinimizeTimeout > 0
            and lastIncomingMessage ~= nil and lastIncomingMessage ~= 0
            and chatSystem ~= nil and not chatSystem:IsMinimized()
            and not FCOCTB.CheckIfChatWindowUsed() and not FCOCTB.CheckIfChatTextEditIsUsed() then
        local currentTime = GetTimeStamp()
        if currentTime <= lastIncomingMessage then return end
        local difference = currentTime -lastIncomingMessage
        if difference > 0 and difference >= autoMinimizeTimeout then
            chatSystem:Minimize()
        end
    end
end

--Wrapper function to change the chat tab now
function FCOCTB.ChangeChatTabNow(chatTabIndex, doOverride)
    doOverride = doOverride or false
    local settings = FCOCTB.settingsVars.settings
    -- Chat tab switch setting is not activated?
    -- Or we are receiving a whisper message and the autoswitch for whispers is off?
    --> Override to do the chat tab switch is not activated?
    ---> Abort here
    if not settings.enableChatTabSwitch
       or (chatTabIndex == settings.redirectWhisperChannelId and not settings.autoOpenWhisperTab) then
        if not doOverride then return false end
    end
    --Current active chat tab?
    local primaryContainer = chatSystem.primaryContainer
    local currentTab 	= primaryContainer.currentBuffer:GetParent().tab
    local currentIndex 	= currentTab.index
    --Abort if no valid chatTabIndex is given, the given index is the same as the currently selected chat tab, or a message is currently written
    if  chatTabIndex == nil or chatTabIndex == 0 or currentIndex == chatTabIndex
        or primaryContainer.windows[chatTabIndex].tab == nil
        or FCOCTB.CheckIfChatTextEditIsUsed() then
        return nil
    end
    FCOCTB.preventerVars.changingToNewChatTab = true
    --Change the chat tab now to new chat tab
    local wasTabChanged = FCOCTB.CycleChatTab(chatTabIndex)
    FCOCTB.preventerVars.changingToNewChatTab = false
    return wasTabChanged
end

local function isChatContainerScrollbarEnabled()
    local primaryContainer = chatSystem.primaryContainer
    if not primaryContainer or not primaryContainer.scrollbar then return false end
    return primaryContainer:GetCurrentMaxScroll() > 1
end

local function FCOCTB_ScrollChat(scrollWhere)
    --d("[FCOCTB]ScrollChat: " ..tostring(scrollWhere))
    local primaryContainer = chatSystem.primaryContainer
    --primaryContainer.scrollbar
    --primaryContainer.scrollUpButton
    --primaryContainer.scrollDownButton
    --primaryContainer.scrollEndButton

    if scrollWhere == "bottom" then
--d(">scrolling to bottom")
        FCOCTB.preventerVars.scrollingChatTab = true
        primaryContainer:ScrollToBottom()
        FCOCTB.preventerVars.scrollingChatTab = false
        return true
    elseif scrollWhere == "top" then
--d(">scrolling to top")
        FCOCTB.preventerVars.scrollingChatTab = true
        primaryContainer:SetScroll(0)
        FCOCTB.preventerVars.scrollingChatTab = false
        return true
    end
    FCOCTB.preventerVars.scrollingChatTab = false
    return false
end

local function getChatScrollPos()
    local primaryContainer = chatSystem.primaryContainer
    --if primaryContainer.system:IsMinimized() then return end
    local scrollMin, scrollMax = primaryContainer.scrollbar:GetMinMax()
    local scrollCurrent = primaryContainer.scrollbar:GetValue()
    return scrollMin, scrollMax, scrollCurrent
end

function FCOCTB.ScrollChatTabToTop()
    if not isChatContainerScrollbarEnabled() then return end
    local scrollMin, scrollMax, scrollCurrent = getChatScrollPos()
--d("[FCOCTB]scrollTop-current: " ..tostring(scrollCurrent) .. ", max: " ..tostring(scrollMax) .. ", min: " ..tostring(scrollMin))
    if scrollCurrent <= scrollMin then
        return false
    end
    --Change the chat tab now to new chat tab
    return FCOCTB_ScrollChat("top")
end

function FCOCTB.ScrollChatTabToBottom()
    if not isChatContainerScrollbarEnabled() then return end
    local scrollMin, scrollMax, scrollCurrent = getChatScrollPos()

--d("[FCOCTB]scrollBottom-current: " ..tostring(scrollCurrent) .. ", max: " ..tostring(scrollMax) .. ", min: " ..tostring(scrollMin))
    if scrollCurrent >= scrollMax then
        return
    end

    --Change the chat tab now to new chat tab
    return FCOCTB_ScrollChat("bottom")
end


--Reset the general idle timer now so it will start to count from the beginning
function FCOCTB.SetupDefaultTabIdleTimer(startOrStop)
    --If no parameter was set: Start the timer
    if startOrStop == nil then startOrStop = true end
--d("[FCOCTB.SetupDefaultTabIdleTimer]startOrStop: " ..tostring(startOrStop))
    local addonVars = FCOCTB.addonVars
    local settings = FCOCTB.settingsVars.settings
    local switchToDefaultChatTabAfterIdleTabId = settings.switchToDefaultChatTabAfterIdleTabId
    local switchToDefaultChatTabAfterIdleTime = settings.switchToDefaultChatTabAfterIdleTime

    --Unregister the default chat tab idle timer now
    local function unregisterIdleTimerNow()
--d(">Stoping timer")
        --Reset the current idle timer seconds
        FCOCTB.preventerVars.defaultTabIdleTime = 0
        if FCOCTB.DefaultTabIdleTimerActive == true then
            EVENT_MANAGER:UnregisterForUpdate(addonVars.gAddonName.."_DefaultChatTabIdleTimer")
            FCOCTB.DefaultTabIdleTimerActive = false
        end
    end

    --Increase the default chat tab idle timer by 1
    local function increaseDefaultChatTabIdleTimer()
        local currentIdleTimer = FCOCTB.preventerVars.defaultTabIdleTime
        local newIdleTimer = currentIdleTimer + 1
        FCOCTB.preventerVars.defaultTabIdleTime = newIdleTimer
--d(">Default chat tab idle timer: " .. tostring(newIdleTimer))

        --Did we reach the default chat tab idle timer?
        if newIdleTimer >= settings.switchToDefaultChatTabAfterIdleTime then
            --Change the chat tab to the chosen default chat tab
--d("<Default chat tab idle timer met!")
            --Unregister the idle timer again now
            unregisterIdleTimerNow()
            --Change the active chat tab now to the default idle time chat tab
            FCOCTB.ChangeChatTabNow(switchToDefaultChatTabAfterIdleTabId, true)
        end
    end

    local isGroupedAndShouldNotChangeChatTabThen = FCOCTB.isGroupedAndDontChangeTab()

    --Is the setting enabled to switch to a default chat tab after some idle time?
    if not isGroupedAndShouldNotChangeChatTabThen
            and switchToDefaultChatTabAfterIdleTabId ~= nil and switchToDefaultChatTabAfterIdleTabId ~= 0 and switchToDefaultChatTabAfterIdleTime > 0 then
        --Start or stop the idle timer?
        if startOrStop == true then
--d(">(Re)starting timer")
            --Stop the timer now
            unregisterIdleTimerNow()
            --(Re)Start the timer now
            FCOCTB.DefaultTabIdleTimerActive = EVENT_MANAGER:RegisterForUpdate(addonVars.gAddonName.."_DefaultChatTabIdleTimer", 1000, increaseDefaultChatTabIdleTimer)
        elseif startOrStop == false then
            --Stop the timer now
            unregisterIdleTimerNow()
        end
    else
        --Stop the timer now
        unregisterIdleTimerNow()
    end
end

function FCOCTB.isGroupedAndDontChangeTab(isGroupedCheckWasAlreadyDone)
    isGroupedCheckWasAlreadyDone = isGroupedCheckWasAlreadyDone or false
    --Check if we are grouped and if the chat tabs shouldn't switch then
    local isGroupedAndDontChangeTabThen = false
    if FCOCTB.settingsVars.settings.doNotAutoOpenIfGrouped then
        --Are we in a group?
        isGroupedAndDontChangeTabThen = (isGroupedCheckWasAlreadyDone or (GetGroupSize() > 1)) or false
    end
    return isGroupedAndDontChangeTabThen
end

--Check a chat channel option, if it is still registered at total and at a specific chat tab
function FCOCTB.CheckChatTabOptionsForCategory(chatChannel, chatTab, chatContainerId)
    --d("[FCOChatTabBrain_CheckChatTabOptions] - chatChannel: " .. chatChannel .. ", chatTab: " .. chatTab)
    if chatChannel == nil then return -1 end
    chatTab = chatTab or -1
    --The chat options chat channel categories
    local messageTypeToChannelCode = FCOCTB.mappingVars.activeChatChannelsCategories
    local chatChannelCode = messageTypeToChannelCode[chatChannel]
    if chatContainerId == nil or chatChannelCode == nil then return true end

    --d("> Code: " .. chatChannelCode .. ", Container ID: " .. chatContainerId)
    local retVal = IsChatContainerTabCategoryEnabled(chatContainerId, chatTab, chatChannelCode)
    if retVal == nil then retVal = false end
    return retVal
end

--Get the guild names as a table ({[number guildNumber] = String guildName, ...}
function FCOCTB.GetGuildNames()
    local guildNamesTable = {}
    local numGuilds = GetNumGuilds()
    if numGuilds > 0 then
        for i = 1, numGuilds do
            local guildId = GetGuildId(i)
            if guildId ~= nil then
                local guildName = GetGuildName(guildId)
                if guildName and guildName ~= "" then
                    table.insert(guildNamesTable, i, guildName)
                end
            end
        end
    end
    return guildNamesTable
end