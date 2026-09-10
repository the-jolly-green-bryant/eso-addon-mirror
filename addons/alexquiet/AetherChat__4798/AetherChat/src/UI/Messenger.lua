-- ============================================================================
-- AetherChat : Messenger UI Controller (Edge Resizing, Full Chat Area & L10n)
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.Messenger = {}
local Messenger = AetherChat.Messenger
local Theme = AetherChat.Theme
local History = AetherChat.History
local Settings = AetherChat.Settings

local channelButtons = {}
local activeChannelKey = 'zone'
local currentZoneLang = 'all'
local knownWhispers = {}
local unreadCounts = {}
local hideHooksInitialized = false
local currentItems = {}
local dragState = nil
local isGuildsExpanded = false

-- Dynamic Edge Resizing state & Layout Modes
local resizeState = nil
local compactTabs = {}
local compactSelectedGuild = 'guild1'
local function GetMinDimensions()
    if Settings and Settings.Get and Settings.Get('interfaceMode', 'standard') == 'compact' then
        return 320, 180
    end
    return 560, 320
end
local MAX_WIDTH = 1920
local MAX_HEIGHT = 1200

local function L(key, ...)
    return AetherChat.L(key, ...)
end

local function GetFixedChannels()
    return {
        { id = 'loot',    name = L('CH_LOOT'),    prefix = '/p',    icon = '/esoui/art/inventory/inventory_tabicon_misc_up.dds' },
        { id = 'zone',    name = L('CH_ZONE'),    prefix = '/zone', icon = '/esoui/art/chatwindow/chat_notification_echo.dds' },
        { id = 'general', name = L('CH_GENERAL'), prefix = '/say',  icon = '/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds' },
        { id = 'party',   name = L('CH_PARTY'),   prefix = '/party',icon = '/esoui/art/compass/groupleader.dds' },
        { id = 'system',  name = L('CH_SYSTEM'),  prefix = '/zone', icon = '/esoui/art/chatwindow/chat_options_up.dds' },
    }
end

local function FormatItemLinksInText(text)
    if not text or text == '' then return '' end
    if not text:find("|H") or not text:find(":item:") then return text end

    if text:find("|t%d+:%d+:[^|]+|t") then return text end

    return text:gsub("(|H.-:item:.-|h.-|h)", function(link)
        local icon = GetItemLinkInfo(link) or GetItemLinkIcon(link)
        local iconTag = ""
        if icon and icon ~= "" and icon ~= "/esoui/art/icons/icon_missing.dds" then
            iconTag = string.format("|t22:22:%s:inheritcolor|t ", icon)
        end

        local traitType = GetItemLinkTraitType(link)
        local traitTag = ""
        if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
            local tStr = GetString("SI_ITEMTRAITTYPE", traitType)
            if tStr and tStr ~= "" then
                traitTag = string.format(" |cC5C29E(%s)|r", zo_strformat("<<1>>", tStr))
            end
        end

        local notableTag = GetItemLinkSetInfo(link) and " |cFFCC00!!!|r" or ""

        return string.format("%s%s%s%s", iconTag, link, traitTag, notableTag)
    end)
end

function Messenger.Initialize()
    Messenger.minBar = AetherChat_MinBar
    Messenger.window = AetherChat_MessengerWindow
    Messenger.donationWindow = AetherChat_DonationWindow

    if not Messenger.window then return end

    -- Safety cleanup: ensure notifications windows are never mistakenly displayed
    if ZO_Notifications and not (SCENE_MANAGER and SCENE_MANAGER:IsShowing('notifications')) then
        ZO_Notifications:SetHidden(true)
    end
    if ZO_GamepadNotifications and not (SCENE_MANAGER and (SCENE_MANAGER:IsShowing('gamepad_notifications_root') or SCENE_MANAGER:IsShowing('notifications'))) then
        ZO_GamepadNotifications:SetHidden(true)
    end

    -- 1. MinBar Moveable HUD Widget (Hover-Only Tooltip & Tri-Color Notification Badges)
    if Messenger.minBar then
        Messenger.minBar:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine("|cE5B558AETHER|r|cFFFFFFCHAT|r", "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)

            -- 1. Unread chat messages
            local totalUnread = Messenger.GetTotalUnreadCount and Messenger.GetTotalUnreadCount() or 0
            if totalUnread > 0 then
                InformationTooltip:AddLine(string.format("|cF23F43• %s|r", L('TT_UNREAD_COUNT', totalUnread)), "ZoFontGame", 1, 0.4, 0.4, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            else
                InformationTooltip:AddLine("|c888888• " .. L('TT_MAIL_NONE') .. "|r", "ZoFontGameSmall", 0.7, 0.7, 0.7, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end

            -- 2. Friends online
            local numFriendsOnline = 0
            local numFriends = GetNumFriends() or 0
            for i = 1, numFriends do
                local _, _, status = GetFriendInfo(i)
                if status ~= PLAYER_STATUS_OFFLINE then
                    numFriendsOnline = numFriendsOnline + 1
                end
            end
            if numFriendsOnline > 0 then
                InformationTooltip:AddLine(string.format("|c57F287• " .. L('TT_FRIENDS_ONLINE') .. "|r", numFriendsOnline), "ZoFontGame", 0.3, 1, 0.5, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            else
                InformationTooltip:AddLine("|c888888• " .. L('TT_FRIENDS_NONE') .. "|r", "ZoFontGameSmall", 0.7, 0.7, 0.7, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end

            -- 3. Unread Mails
            local numUnreadMail = GetNumUnreadMail() or 0
            if numUnreadMail > 0 then
                InformationTooltip:AddLine(string.format("|c38BDF8• " .. L('TT_MAIL_UNREAD') .. "|r", numUnreadMail), "ZoFontGame", 0.2, 0.7, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end

            InformationTooltip:AddLine(string.format("|c888888%s : %s|r", L('BINDING_NAME'), L('TT_MINBAR_TOGGLE_HINT')), "ZoFontGameSmall", 0.6, 0.6, 0.6, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)

        Messenger.minBar:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)

        -- MinBar toggles AetherChat cleanly on left-click
        Messenger.minBar:SetHandler('OnMouseUp', function(self, button, upInside)
            if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                Messenger.Toggle()
                return true
            end
        end)

        -- Save MinBar position on drag stop with re-anchoring
        Messenger.minBar:SetHandler('OnMoveStop', function(self)
            local left = self:GetLeft()
            local top = self:GetTop()
            if left and top then
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                Settings.Set('floatingIconPos', { x = left, y = top })
            end
        end)

        -- Register MinBar as official HUD Fragment
        if SCENE_MANAGER then
            local minBarFragment = ZO_HUDFadeSceneFragment:New(Messenger.minBar)
            SCENE_MANAGER:GetScene("hud"):AddFragment(minBarFragment)
            SCENE_MANAGER:GetScene("hudui"):AddFragment(minBarFragment)
        end

        Messenger.UpdateTotalBadge()
        Messenger.UpdateFriendsBadge()
        Messenger.UpdateMailBadge()
    end

    -- Window Header Close Button
    local closeBtn = Messenger.window:GetNamedChild('CloseBtn')
    if closeBtn then
        closeBtn:SetHandler('OnClicked', function()
            Messenger.Hide()
        end)
    end

    -- 2. Restore Saved Window & MinBar Positions
    Messenger.RestoreSavedPositions()

    Messenger.window:SetHandler('OnMoveStop', function(self)
        local left = self:GetLeft()
        local top = self:GetTop()
        if left and top then
            self:ClearAnchors()
            self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            local mode = Settings.Get('interfaceMode', 'standard')
            if mode == 'compact' then
                Settings.Set('compactPos', { x = left, y = top })
            else
                Settings.Set('windowPos', { x = left, y = top })
            end
        end
    end)

    -- Allow dragging standard window directly from Skyrim Title
    local title = Messenger.window:GetNamedChild('Title')
    if title then
        title:SetMouseEnabled(true)
        title:SetHandler('OnMouseDown', function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and Messenger.window then
                Messenger.window:StartMoving()
            end
        end)
        title:SetHandler('OnMouseUp', function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and Messenger.window then
                Messenger.window:StopMovingOrResizing()
                local left = Messenger.window:GetLeft()
                local top = Messenger.window:GetTop()
                if left and top then
                    Messenger.window:ClearAnchors()
                    Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                    Settings.Set('windowPos', { x = left, y = top })
                end
            end
        end)
    end

    -- Setup Edge Resizing with Visual Glow Affordance
    Messenger.SetupEdgeResizing()

    -- Collapse Sidebar Toggle Button
    local collapseSidebarBtn = Messenger.window:GetNamedChild('CollapseSidebarBtn')
    if collapseSidebarBtn then
        collapseSidebarBtn:SetHandler('OnClicked', function()
            Messenger.ToggleSidebarCollapse()
        end)
        collapseSidebarBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('TT_COLLAPSE_SIDEBAR'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|c888888" .. L('TT_COLLAPSE_SIDEBAR_SUB') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        collapseSidebarBtn:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)
    end

    -- Apply Saved Sidebar Collapsed State
    Messenger.SetSidebarCollapsed(Settings.Get('sidebarCollapsed', false))

    -- Apply Saved Backdrop Transparency
    Messenger.ApplyBackdropAlpha(Settings.Get('backdropAlpha', 95))

    -- Register Main Messenger Window as an official HUD Scene Fragment with Conditional Visibility
    Messenger.isOpen = false
    if SCENE_MANAGER then
        Messenger.fragment = ZO_HUDFadeSceneFragment:New(Messenger.window)
        Messenger.fragment:SetConditional(function()
            return Messenger.isOpen == true
        end)

        SCENE_MANAGER:GetScene("hud"):AddFragment(Messenger.fragment)
        SCENE_MANAGER:GetScene("hudui"):AddFragment(Messenger.fragment)

        Messenger.fragment:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_FRAGMENT_SHOWING then
                Messenger.OnFragmentShowing()
            elseif newState == SCENE_FRAGMENT_HIDING or newState == SCENE_FRAGMENT_HIDDEN then
                Messenger.OnFragmentHidden()
            end
        end)
    end

    -- Settings Gear Button (Opens AetherChat LAM Panel Directly)
    local settingsBtn = Messenger.window:GetNamedChild('SettingsBtn')
    if settingsBtn then
        settingsBtn:SetHandler('OnClicked', function()
            Settings.OpenSettingsPanel()
        end)
        settingsBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('TT_SETTINGS_BTN'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|c888888" .. L('TT_SETTINGS_BTN_SUB') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        settingsBtn:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)
    end

    -- Friends List Quick Button (Online Friends Only + Live Count Badge + 1-Click Whisper)
    local friendsBtn = Messenger.window:GetNamedChild('FriendsBtn')
    if friendsBtn then
        friendsBtn:SetHandler('OnMouseEnter', function(self)
            local numFriends = GetNumFriends() or 0
            local onlineCount = 0
            for i = 1, numFriends do
                local _, _, status = GetFriendInfo(i)
                if status ~= PLAYER_STATUS_OFFLINE then
                    onlineCount = onlineCount + 1
                end
            end

            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('TT_FRIENDS_BTN'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            if onlineCount > 0 then
                InformationTooltip:AddLine(string.format("|c57F287" .. L('TT_FRIENDS_ONLINE') .. "|r", onlineCount), "ZoFontGameSmall", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            else
                InformationTooltip:AddLine("|c888888" .. L('TT_FRIENDS_NONE') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end
            InformationTooltip:AddLine("|c888888" .. L('TT_FRIENDS_BTN_SUB') .. "|r", "ZoFontGameSmall", 0.6, 0.6, 0.6, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        friendsBtn:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)
        friendsBtn:SetHandler('OnClicked', function(self)
            Messenger.ShowOnlineFriendsMenu(self)
        end)
    end

    -- Mailbox Button (Opens ESO Mailbox & Displays Live Unread Count)
    local mailBtn = Messenger.window:GetNamedChild('MailBtn')
    if mailBtn then
        mailBtn:SetHandler('OnMouseEnter', function(self)
            local unread = GetNumUnreadMail() or 0
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('TT_MAIL_BTN'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            if unread > 0 then
                InformationTooltip:AddLine(string.format("|c57F287" .. L('TT_MAIL_UNREAD') .. "|r", unread), "ZoFontGameSmall", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            else
                InformationTooltip:AddLine("|c888888" .. L('TT_MAIL_NONE') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end
            InformationTooltip:AddLine("|c888888" .. L('TT_MAIL_BTN_SUB') .. "|r", "ZoFontGameSmall", 0.6, 0.6, 0.6, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        mailBtn:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)
        mailBtn:SetHandler('OnClicked', function()
            if SCENE_MANAGER then
                SCENE_MANAGER:Toggle('mailInbox')
            elseif MAIN_MENU_KEYBOARD then
                MAIN_MENU_KEYBOARD:ToggleSceneGroup('mailSceneGroup')
            end
        end)
    end

    -- Dedicated Donation Button (Opens Beautiful Donation Modal Window directly!)
    local donateBtn = Messenger.window:GetNamedChild('DonateBtn')
    if donateBtn then
        donateBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine("|cFFD700" .. L('TT_DONATE_BTN') .. "|r", "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|cFFFFFF" .. L('TT_DONATE_BTN_DESC') .. "|r", "ZoFontGameSmall", 0.9, 0.9, 0.9, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|c888888" .. L('TT_DONATE_BTN_SUB') .. "|r", "ZoFontGameSmall", 0.6, 0.6, 0.6, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        donateBtn:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)
        donateBtn:SetHandler('OnClicked', function(self)
            Messenger.OpenDonationWindow()
        end)
    end

    -- Setup Donation Modal Window Handlers
    Messenger.SetupDonationWindow()

    -- Setup Live Search Box
    Messenger.SetupSearchBox()

    -- Setup Copy Modal Handlers
    Messenger.SetupCopyModal()

    -- Apply Saved Chat Font Size
    Messenger.ApplyChatFontSize(Settings.Get('chatFontSize', 16))

    -- Clear History Button
    local clearBtn = Messenger.window:GetNamedChild('ClearBtn')
    if clearBtn then
        clearBtn:SetHandler('OnClicked', function()
            if activeChannelKey then
                if AetherChat.savedVars and AetherChat.savedVars.history then
                    AetherChat.savedVars.history[activeChannelKey] = nil
                end
                Messenger.LoadMessages(activeChannelKey)
            end
        end)
    end

    -- Dedicated Set Filter Toggle Button (Loot tab)
    local setFilterBtn = Messenger.window:GetNamedChild('SetFilterBtn')
    if setFilterBtn then
        local function UpdateSetFilterUI()
            local filterOn = Settings.Get('filterSetsOnly', false)
            local label = setFilterBtn:GetNamedChild('Label')
            local bg = setFilterBtn:GetNamedChild('BG')
            if label then
                label:SetText(filterOn and L('BTN_FILTER_SETS_ON') or L('BTN_FILTER_SETS_OFF'))
                if filterOn then
                    label:SetColor(0.34, 0.95, 0.53, 1)
                else
                    label:SetColor(0.9, 0.71, 0.35, 1)
                end
            end
            if bg then
                if filterOn then
                    bg:SetEdgeColor(0.34, 0.95, 0.53, 0.9)
                else
                    bg:SetEdgeColor(0.9, 0.71, 0.35, 0.6)
                end
            end
        end

        Messenger.UpdateSetFilterUI = UpdateSetFilterUI

        setFilterBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine("|cE5B558" .. L('TT_FILTER_SETS') .. "|r", "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|cFFFFFF" .. L('TT_FILTER_SETS_DESC') .. "|r", "ZoFontGameSmall", 0.9, 0.9, 0.9, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        setFilterBtn:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)
        setFilterBtn:SetHandler('OnClicked', function()
            local cur = Settings.Get('filterSetsOnly', false)
            Settings.Set('filterSetsOnly', not cur)
            UpdateSetFilterUI()
            if activeChannelKey == 'loot' then
                Messenger.LoadMessages('loot')
            end
        end)

        UpdateSetFilterUI()
    end

    -- Zone Multi-Language Selector Pills Handlers
    local zoneLangBar = Messenger.window:GetNamedChild('ZoneLangBar')
    if zoneLangBar then
        local langButtons = {
            all    = zoneLangBar:GetNamedChild('All'),
            fr     = zoneLangBar:GetNamedChild('FR'),
            en     = zoneLangBar:GetNamedChild('EN'),
            de     = zoneLangBar:GetNamedChild('DE'),
            es     = zoneLangBar:GetNamedChild('ES'),
            global = zoneLangBar:GetNamedChild('Global'),
        }

        local function UpdateZoneLangPills()
            local theme = Theme.GetCurrentTheme()
            for langKey, btn in pairs(langButtons) do
                if btn then
                    local label = btn:GetNamedChild('Label')
                    local bg = btn:GetNamedChild('BG')
                    local isSelected = (currentZoneLang == langKey)
                    if label then
                        if isSelected then
                            label:SetColor(0.9, 0.71, 0.35, 1)
                        else
                            label:SetColor(0.55, 0.55, 0.55, 1)
                        end
                    end
                    if bg then
                        if isSelected then
                            if theme and theme.accentR then
                                bg:SetEdgeColor(theme.accentR, theme.accentG, theme.accentB, 0.95)
                            else
                                bg:SetEdgeColor(0.9, 0.71, 0.35, 0.95)
                            end
                        else
                            bg:SetEdgeColor(0.25, 0.25, 0.25, 0.6)
                        end
                    end
                end
            end
        end

        Messenger.UpdateZoneLangPills = UpdateZoneLangPills

        for langKey, btn in pairs(langButtons) do
            if btn then
                btn:SetHandler('OnClicked', function()
                    currentZoneLang = langKey
                    UpdateZoneLangPills()
                    if activeChannelKey == 'zone' then
                        Messenger.SelectChannel('zone', true, false)
                    end
                end)
                btn:SetHandler('OnMouseEnter', function(self)
                    InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
                    InformationTooltip:AddLine(string.format(L('TT_ZONE_LANG'), langKey:upper()), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
                    InformationTooltip:AddLine("|c888888" .. L('TT_ZONE_LANG_DESC') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
                end)
                btn:SetHandler('OnMouseExit', function(self)
                    ClearTooltip(InformationTooltip)
                end)
            end
        end

        UpdateZoneLangPills()
    end

    -- TextBuffer Handlers (Scrolling, 1-Click Toggle & Loot Tab Context Menu)
    local buffer = Messenger.window:GetNamedChild('Messages')
    if buffer then
        buffer:SetHandler('OnMouseWheel', function(self, delta)
            local cur = self:GetScrollPosition() or 0
            self:SetScrollPosition(math.max(0, cur + (delta * 3)))
        end)

        buffer:SetHandler('OnLinkMouseUp', function(self, linkData, linkText, button)
            local targetLink = (linkText and linkText ~= '') and linkText or linkData
            if not targetLink then return end

            local linkType = GetLinkType(targetLink)

            if button == MOUSE_BUTTON_INDEX_LEFT and linkType == LINK_TYPE_ITEM then
                if PopupTooltip and not PopupTooltip:IsHidden() and PopupTooltip.lastLink == targetLink then
                    ZO_PopupTooltip_Hide()
                    PopupTooltip.lastLink = nil
                    return true
                end

                ZO_PopupTooltip_SetLink(targetLink)
                PopupTooltip.lastLink = targetLink

                if PopupTooltip and Messenger.window and not Messenger.window:IsHidden() then
                    PopupTooltip:ClearAnchors()
                    local winRight = Messenger.window:GetRight() or 0
                    local screenWidth = GuiRoot:GetWidth() or 1920

                    if winRight + 380 <= screenWidth then
                        PopupTooltip:SetAnchor(TOPLEFT, Messenger.window, TOPRIGHT, 12, 0)
                    else
                        PopupTooltip:SetAnchor(TOPRIGHT, Messenger.window, TOPLEFT, -12, 0)
                    end
                end
                return true
            end

            if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == LINK_TYPE_ITEM then
                ClearMenu()

                if activeChannelKey == 'loot' then
                    local template = Settings.Get('needTemplate', 'LF <<item>> please :)')
                    local msg = template:gsub("<<item>>", targetLink):gsub("<<1>>", targetLink)
                    local looter = AetherChat.GetLooterForItem and AetherChat.GetLooterForItem(targetLink)

                    AddCustomMenuItem(L('MENU_NEED_GROUP'), function()
                        if IsUnitGrouped("player") then
                            CHAT_SYSTEM:StartTextEntry(msg, CHAT_CHANNEL_PARTY)
                        else
                            CHAT_SYSTEM:StartTextEntry(msg, CHAT_CHANNEL_ZONE)
                        end
                        if ZO_ChatWindowTextEntryEditBox then
                            ZO_ChatWindowTextEntryEditBox:TakeFocus()
                        end
                    end)

                    local whisperLabel = L('MENU_NEED_WHISPER')
                    if looter then
                        whisperLabel = L('MENU_NEED_WHISPER_AT', looter)
                    end

                    AddCustomMenuItem(whisperLabel, function()
                        if looter then
                            CHAT_SYSTEM:StartTextEntry(msg, CHAT_CHANNEL_WHISPER, looter)
                        else
                            CHAT_SYSTEM:StartTextEntry(msg, CHAT_CHANNEL_WHISPER)
                        end
                        if ZO_ChatWindowTextEntryEditBox then
                            ZO_ChatWindowTextEntryEditBox:TakeFocus()
                        end
                    end)

                    AddCustomMenuItem(L('MENU_LINK_CHAT'), function()
                        if ZO_ChatWindowTextEntryEditBox then
                            ZO_ChatWindowTextEntryEditBox:TakeFocus()
                            local currentText = ZO_ChatWindowTextEntryEditBox:GetText()
                            ZO_ChatWindowTextEntryEditBox:SetText(currentText .. targetLink)
                        end
                    end)
                else
                    AddCustomMenuItem(L('MENU_LINK_CHAT'), function()
                        if ZO_ChatWindowTextEntryEditBox then
                            ZO_ChatWindowTextEntryEditBox:TakeFocus()
                            local currentText = ZO_ChatWindowTextEntryEditBox:GetText()
                            ZO_ChatWindowTextEntryEditBox:SetText(currentText .. targetLink)
                        end
                    end)
                end

                ShowMenu(self)
                return true
            end

            return ZO_LinkHandler_OnLinkMouseUp(targetLink, button, self)
        end)
    end

    -- Auto-Close on combat start
    EVENT_MANAGER:RegisterForEvent('AetherChat_CombatClose', EVENT_PLAYER_COMBAT_STATE_CHANGED, function(_, inCombat)
        if inCombat then
            if Messenger.isOpen then
                Messenger.Hide()
            end
            if Messenger.donationWindow and not Messenger.donationWindow:IsHidden() then
                Messenger.donationWindow:SetHidden(true)
            end
        end
    end)

    -- Mailbox Events
    EVENT_MANAGER:RegisterForEvent('AetherChat_MailUnread', EVENT_MAIL_NUM_UNREAD_CHANGED, Messenger.UpdateMailBadge)
    EVENT_MANAGER:RegisterForEvent('AetherChat_MailRead', EVENT_MAIL_READ, Messenger.UpdateMailBadge)
    EVENT_MANAGER:RegisterForEvent('AetherChat_MailRemoved', EVENT_MAIL_REMOVED, Messenger.UpdateMailBadge)
    EVENT_MANAGER:RegisterForEvent('AetherChat_MailInbox', EVENT_MAIL_INBOX_UPDATE, Messenger.UpdateMailBadge)
    EVENT_MANAGER:RegisterForEvent('AetherChat_MailAct', EVENT_PLAYER_ACTIVATED, Messenger.UpdateMailBadge)

    -- Friends List Events (Live Online Friends Count Badge & Login/Logout Notifications)
    EVENT_MANAGER:RegisterForEvent('AetherChat_FriendStatus', EVENT_FRIEND_PLAYER_STATUS_CHANGED, Messenger.OnFriendPlayerStatusChanged)
    EVENT_MANAGER:RegisterForEvent('AetherChat_FriendAdded', EVENT_FRIEND_ADDED, Messenger.UpdateFriendsBadge)
    EVENT_MANAGER:RegisterForEvent('AetherChat_FriendRemoved', EVENT_FRIEND_REMOVED, Messenger.UpdateFriendsBadge)
    EVENT_MANAGER:RegisterForEvent('AetherChat_FriendAct', EVENT_PLAYER_ACTIVATED, Messenger.UpdateFriendsBadge)

    -- Guild Member Status Events (Login/Logout for Selected Guilds)
    EVENT_MANAGER:RegisterForEvent('AetherChat_GuildStatus', EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, Messenger.OnGuildMemberPlayerStatusChanged)

    -- Refresh Whispers, Channel list and Positions upon Zone Transitions & Loading Screen completion
    EVENT_MANAGER:RegisterForEvent('AetherChat_Messenger_PlayerAct', EVENT_PLAYER_ACTIVATED, function()
        local currentMode = Settings.Get('interfaceMode', 'standard')
        Messenger.SetInterfaceMode(currentMode, true)
        Messenger.RestoreSavedPositions()
        zo_callLater(Messenger.RestoreSavedPositions, 150)
        zo_callLater(Messenger.RestoreSavedPositions, 500)
        Messenger.ApplyBackdropAlpha(Settings.Get('backdropAlpha', 95))
        Messenger.ApplyChatFontSize(Settings.Get('chatFontSize', 16))
        Messenger.LoadWhispersFromHistory()
        Messenger.RefreshChannelList()
        if activeChannelKey then
            Messenger.LoadMessages(activeChannelKey)
        end
        if GAMEPAD_SETTING_USE_KEYBOARD_CHAT and SetSetting and GetSetting then
            if Settings.Get('gamepadUseKeyboardChat', true) then
                local cur = GetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_USE_KEYBOARD_CHAT)
                if cur ~= "1" and cur ~= "true" and cur ~= 1 and cur ~= true then
                    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_USE_KEYBOARD_CHAT, "1")
                end
            end
        end
        if Messenger.ApplyNativeGamepadChatHidden then
            Messenger.ApplyNativeGamepadChatHidden()
        end
    end)

    -- Global mouse up for drag-and-drop channel order and edge resizing finalization
    EVENT_MANAGER:RegisterForEvent('AetherChat_GlobalMouseUp', EVENT_GLOBAL_MOUSE_UP, function()
        if dragState then
            dragState = nil
            Messenger.SaveCurrentChannelOrder()
            Messenger.RefreshChannelList()
        end
        if resizeState then
            resizeState = nil
            Messenger.FinalizeResize()
        end
    end)

    -- Gamepad / Console Mode Dynamic Switch
    EVENT_MANAGER:RegisterForEvent('AetherChat_GamepadMode', EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(eventCode, isGamepadPreferred)
        zo_callLater(function()
            if GAMEPAD_SETTING_USE_KEYBOARD_CHAT and SetSetting then
                if Settings.Get('gamepadUseKeyboardChat', true) then
                    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_USE_KEYBOARD_CHAT, "1")
                end
            end
            if Messenger.DockNativeChatEntry then
                Messenger.DockNativeChatEntry()
            end
            if Messenger.ApplyNativeGamepadChatHidden then
                Messenger.ApplyNativeGamepadChatHidden()
            end
            if Messenger.isOpen then
                local mode = Settings.Get('interfaceMode', 'standard')
                if mode == 'compact' then
                    Messenger.RefreshCompactTabs()
                else
                    Messenger.RefreshChannelList()
                end
            end
        end, 200)
    end)

    -- Auto-release chat focus upon entering combat (if enabled in settings)
    EVENT_MANAGER:RegisterForEvent('AetherChat_CombatRelease', EVENT_PLAYER_COMBAT_STATE_CHANGED, function(eventCode, inCombat)
        if inCombat and Settings.Get('gamepadCancelOnCombat', true) then
            if ZO_ChatWindowTextEntryEditBox and ZO_ChatWindowTextEntryEditBox:HasFocus() then
                Messenger.ReleaseChatFocus()
            end
        end
    end)

    Messenger.SetupStandardModeButton()
    Messenger.SetupCompactTabBar()

    local currentMode = Settings.Get('interfaceMode', 'standard')
    Messenger.SetInterfaceMode(currentMode, true)

    Messenger.RestoreSavedPositions()
    Messenger.ApplyBackdropAlpha(Settings.Get('backdropAlpha', 95))
    Messenger.ApplyChatFontSize(Settings.Get('chatFontSize', 16))
    Messenger.LoadWhispersFromHistory()
    Messenger.RefreshChannelList()
    Messenger.UpdateMailBadge()
    Messenger.UpdateFriendsBadge()

    Theme.ApplyTheme(Settings.Get('activeTheme', 'skyrim_nordic'))

    Messenger.SetupHideHooks()
    if Settings.Get('hideOfficialChat', false) then
        Messenger.SetHideOfficialChat(true)
    end
end

function Messenger.RestoreSavedPositions()
    -- 1. Restore Main Messenger Window Position & Dimensions
    if Messenger.window then
        local mode = Settings.Get('interfaceMode', 'standard')
        if mode == 'compact' then
            local cPos = Settings.Get('compactPos')
            if cPos and cPos.x and cPos.y then
                Messenger.window:ClearAnchors()
                Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cPos.x, cPos.y)
            else
                Messenger.window:ClearAnchors()
                Messenger.window:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 30, -100)
            end

            local cDims = Settings.Get('compactDimensions')
            if cDims and cDims.width and cDims.height then
                Messenger.window:SetDimensions(cDims.width, cDims.height)
            else
                Messenger.window:SetDimensions(450, 270)
            end
        else
            local winPos = Settings.Get('windowPos')
            if winPos and winPos.x and winPos.y then
                Messenger.window:ClearAnchors()
                Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, winPos.x, winPos.y)
            else
                Messenger.window:ClearAnchors()
                Messenger.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            end

            local winDims = Settings.Get('windowDimensions')
            if winDims and winDims.width and winDims.height then
                Messenger.window:SetDimensions(winDims.width, winDims.height)
            else
                Messenger.window:SetDimensions(940, 520)
            end
        end
    end

    -- 2. Restore Floating HUD Icon Position (MinBar)
    if Messenger.minBar then
        local iconPos = Settings.Get('floatingIconPos') or Settings.Get('minBarPos')
        if iconPos and iconPos.x and iconPos.y then
            Messenger.minBar:ClearAnchors()
            Messenger.minBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, iconPos.x, iconPos.y)
        end
    end
end

function Messenger.SetupEdgeResizing()
    if not Messenger.window then return end

    local function HookEdge(controlName, mode, tooltipTitle, tooltipDesc)
        local ctrl = Messenger.window:GetNamedChild(controlName)
        if not ctrl then return end

        local glow = ctrl:GetNamedChild('Glow')

        ctrl:SetHandler('OnMouseEnter', function(self)
            if glow then glow:SetHidden(false) end
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(tooltipTitle, "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|c888888" .. tooltipDesc .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)

        ctrl:SetHandler('OnMouseExit', function(self)
            if not resizeState or resizeState.mode ~= mode then
                if glow then glow:SetHidden(true) end
            end
            ClearTooltip(InformationTooltip)
        end)

        ctrl:SetHandler('OnMouseDown', function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                local mouseX, mouseY = GetUIMousePosition()
                local w, h = Messenger.window:GetDimensions()
                local l, t = Messenger.window:GetLeft(), Messenger.window:GetTop()

                resizeState = {
                    mode = mode,
                    startX = mouseX,
                    startY = mouseY,
                    startWidth = w,
                    startHeight = h,
                    startLeft = l,
                    startTop = t,
                    glowControl = glow,
                }
                if glow then glow:SetHidden(false) end
            end
        end)

        ctrl:SetHandler('OnUpdate', function(self)
            if resizeState and resizeState.mode == mode then
                local mouseX, mouseY = GetUIMousePosition()
                local deltaX = mouseX - resizeState.startX
                local deltaY = mouseY - resizeState.startY

                local minW, minH = GetMinDimensions()
                if mode == 'right' then
                    local newWidth = math.max(minW, math.min(MAX_WIDTH, resizeState.startWidth + deltaX))
                    Messenger.window:SetDimensions(newWidth, resizeState.startHeight)
                elseif mode == 'bottom' then
                    local newHeight = math.max(minH, math.min(MAX_HEIGHT, resizeState.startHeight + deltaY))
                    Messenger.window:SetDimensions(resizeState.startWidth, newHeight)
                elseif mode == 'top' then
                    local newHeight = math.max(minH, math.min(MAX_HEIGHT, resizeState.startHeight - deltaY))
                    local actualDeltaH = newHeight - resizeState.startHeight
                    local newTop = resizeState.startTop - actualDeltaH

                    Messenger.window:ClearAnchors()
                    Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, resizeState.startLeft, newTop)
                    Messenger.window:SetDimensions(resizeState.startWidth, newHeight)
                end
            end
        end)

        ctrl:SetHandler('OnMouseUp', function(self, button)
            if resizeState and resizeState.mode == mode then
                Messenger.FinalizeResize()
            end
        end)
    end

    -- Hook Right Edge (Width)
    HookEdge('ResizeRight', 'right', L('TT_RESIZE_RIGHT_TITLE'), L('TT_RESIZE_RIGHT_DESC'))

    -- Hook Top Edge (Height Upwards)
    HookEdge('ResizeTop', 'top', L('TT_RESIZE_TOP_TITLE'), L('TT_RESIZE_TOP_DESC'))

    -- Hook Bottom Edge (Height Downwards)
    HookEdge('ResizeBottom', 'bottom', L('TT_RESIZE_BOTTOM_TITLE'), L('TT_RESIZE_BOTTOM_DESC'))
end

function Messenger.FinalizeResize()
    if not resizeState then return end

    if resizeState.glowControl then
        resizeState.glowControl:SetHidden(true)
    end
    resizeState = nil

    local finalW, finalH = Messenger.window:GetDimensions()
    local finalPos = { x = Messenger.window:GetLeft(), y = Messenger.window:GetTop() }
    local mode = Settings.Get('interfaceMode', 'standard')

    if mode == 'compact' then
        Settings.Set('compactDimensions', { width = math.floor(finalW + 0.5), height = math.floor(finalH + 0.5) })
        Settings.Set('compactPos', finalPos)
    else
        Settings.Set('windowDimensions', { width = math.floor(finalW + 0.5), height = math.floor(finalH + 0.5) })
        Settings.Set('windowPos', finalPos)
    end
end

function Messenger.SetupDonationWindow()
    local win = Messenger.donationWindow or AetherChat_DonationWindow
    if not win then return end

    local title = win:GetNamedChild('Title')
    if title then title:SetText(L('MODAL_DONATE_TITLE')) end

    local desc = win:GetNamedChild('Desc')
    if desc then desc:SetText(L('MODAL_DONATE_DESC')) end

    local closeBtn = win:GetNamedChild('CloseBtn')
    if closeBtn then
        closeBtn:SetHandler('OnClicked', function() win:SetHidden(true) end)
    end

    local btmCloseBtn = win:GetNamedChild('BottomCloseBtn')
    if btmCloseBtn then
        btmCloseBtn:SetText(L('MODAL_CLOSE_BTN'))
        btmCloseBtn:SetHandler('OnClicked', function() win:SetHidden(true) end)
    end

    -- Section 1: In-Game Gold
    local secGold = win:GetNamedChild('SectionGold')
    if secGold then
        local label = secGold:GetNamedChild('Label')
        if label then label:SetText(L('MODAL_GOLD_TITLE')) end

        local sub = secGold:GetNamedChild('Sub')
        if sub then sub:SetText(L('MODAL_GOLD_SUB')) end

        local btn = secGold:GetNamedChild('Btn')
        if btn then
            btn:SetText(L('MODAL_GOLD_BTN'))
            btn:SetHandler('OnClicked', function()
                AetherChat.SendInGameDonation()
                win:SetHidden(true)
            end)
        end
    end

    -- Section 2: PayPal
    local secPayPal = win:GetNamedChild('SectionPayPal')
    if secPayPal then
        local label = secPayPal:GetNamedChild('Label')
        if label then label:SetText(L('MODAL_PAYPAL_TITLE')) end

        local edit = secPayPal:GetNamedChild('Edit')
        local btn = secPayPal:GetNamedChild('Btn')
        if edit then edit:SetText('alexjonsnow25@gmail.com') end
        if btn and edit then
            btn:SetText(L('MODAL_PAYPAL_BTN'))
            btn:SetHandler('OnClicked', function()
                edit:TakeFocus()
                edit:SelectAll()
                d(L('MODAL_PAYPAL_CHAT', 'alexjonsnow25@gmail.com'))
            end)
        end
    end

    -- Section 3: USDT
    local secUSDT = win:GetNamedChild('SectionUSDT')
    if secUSDT then
        local label = secUSDT:GetNamedChild('Label')
        if label then label:SetText(L('MODAL_USDT_TITLE')) end

        local edit = secUSDT:GetNamedChild('Edit')
        local btn = secUSDT:GetNamedChild('Btn')
        if edit then edit:SetText('0xad6d30189f61ace3b9c806d486a8547bb751e0bd') end
        if btn and edit then
            btn:SetText(L('MODAL_USDT_BTN'))
            btn:SetHandler('OnClicked', function()
                edit:TakeFocus()
                edit:SelectAll()
                d(L('MODAL_USDT_CHAT', '0xad6d30189f61ace3b9c806d486a8547bb751e0bd'))
            end)
        end
    end
end

function Messenger.OpenDonationWindow()
    local win = Messenger.donationWindow or AetherChat_DonationWindow
    if not win then return end

    Messenger.SetupDonationWindow()
    win:SetHidden(false)
end


function Messenger.GetTotalUnreadCount()
    local total = 0
    local notifyWhispers = Settings.Get('notifyWhispers', true)
    local notifyGuilds = Settings.Get('notifyGuilds', true)
    local notifyParty = Settings.Get('notifyParty', true)

    for key, count in pairs(unreadCounts) do
        if count > 0 then
            if notifyWhispers and key:sub(1, 3) == 'dm:' then
                total = total + count
            elseif notifyGuilds and key:find('^guild') then
                total = total + count
            elseif notifyParty and key == 'party' then
                total = total + count
            end
        end
    end
    return total
end

function Messenger.UpdateMailBadge()
    local numUnread = GetNumUnreadMail() or 0
    local showBadge = Settings.Get('showBadgeMail', true)

    -- 1. Window Header Button Badge (Celestial Blue)
    if Messenger.window then
        local mailBtn = Messenger.window:GetNamedChild('MailBtn')
        if mailBtn then
            local badge = mailBtn:GetNamedChild('Badge')
            if badge then
                if numUnread > 0 then
                    badge:SetHidden(false)
                    local countLabel = badge:GetNamedChild('Count')
                    if countLabel then countLabel:SetText(tostring(numUnread)) end
                else
                    badge:SetHidden(true)
                end
            end
        end
    end

    -- 2. HUD MinBar Badge (Celestial Blue, Bottom-Right)
    if Messenger.minBar then
        local minMailBadge = Messenger.minBar:GetNamedChild('_MailBadge')
        if minMailBadge then
            if showBadge and numUnread > 0 then
                minMailBadge:SetHidden(false)
                local countLabel = minMailBadge:GetNamedChild('Count')
                if countLabel then countLabel:SetText(tostring(numUnread)) end
            else
                minMailBadge:SetHidden(true)
            end
        end
    end
end

function Messenger.UpdateFriendsBadge()
    local numFriends = GetNumFriends() or 0
    local showBadge = Settings.Get('showBadgeFriends', true)
    local onlineCount = 0
    for i = 1, numFriends do
        local _, _, status = GetFriendInfo(i)
        if status ~= PLAYER_STATUS_OFFLINE then
            onlineCount = onlineCount + 1
        end
    end

    -- 1. Window Header Button Badge (Emerald Green)
    if Messenger.window then
        local friendsBtn = Messenger.window:GetNamedChild('FriendsBtn')
        if friendsBtn then
            local badge = friendsBtn:GetNamedChild('Badge')
            if badge then
                if onlineCount > 0 then
                    badge:SetHidden(false)
                    local countLabel = badge:GetNamedChild('Count')
                    if countLabel then countLabel:SetText(tostring(onlineCount)) end
                else
                    badge:SetHidden(true)
                end
            end
        end
    end

    -- 2. HUD MinBar Badge (Emerald Green, Top-Left)
    if Messenger.minBar then
        local minFriendsBadge = Messenger.minBar:GetNamedChild('_FriendsBadge')
        if minFriendsBadge then
            if showBadge and onlineCount > 0 then
                minFriendsBadge:SetHidden(false)
                local countLabel = minFriendsBadge:GetNamedChild('Count')
                if countLabel then countLabel:SetText(tostring(onlineCount)) end
            else
                minFriendsBadge:SetHidden(true)
            end
        end
    end
end

function Messenger.ShowFriendToastNotification(notifText, theme)
    local toast = AetherChat_FriendNotification
    if not toast then return end

    local textLabel = toast:GetNamedChild('Text')
    local bg = toast:GetNamedChild('BG')

    if textLabel then
        textLabel:SetText(notifText)
    end

    if bg and theme and theme.accentR and theme.accentG and theme.accentB then
        bg:SetEdgeColor(theme.accentR, theme.accentG, theme.accentB, 0.95)
    end

    toast:SetHidden(false)
    toast:SetAlpha(1.0)

    -- Auto fade out smoothly after ~4 seconds
    EVENT_MANAGER:UnregisterForUpdate('AetherChat_FriendToastTimer')
    local startTime = GetGameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate('AetherChat_FriendToastTimer', 50, function()
        local elapsed = GetGameTimeMilliseconds() - startTime
        if elapsed > 4500 then
            EVENT_MANAGER:UnregisterForUpdate('AetherChat_FriendToastTimer')
            toast:SetHidden(true)
        elseif elapsed > 3500 then
            local alpha = 1.0 - ((elapsed - 3500) / 1000)
            toast:SetAlpha(math.max(0, alpha))
        end
    end)
end

function Messenger.OnFriendPlayerStatusChanged(eventCode, displayName, characterName, oldStatus, newStatus)
    -- 1. Update the live friends count badge
    Messenger.UpdateFriendsBadge()

    -- 2. Check if notification is enabled in Settings
    if not Settings.Get('notifyFriendStatus', true) then
        return
    end

    if not displayName or displayName == "" then return end

    local wasOnline = (oldStatus ~= nil and oldStatus ~= PLAYER_STATUS_OFFLINE)
    local isOnline = (newStatus ~= nil and newStatus ~= PLAYER_STATUS_OFFLINE)

    if wasOnline == isOnline then
        return
    end

    local theme = Theme.GetCurrentTheme()
    local accentColor = (theme and (theme.selfHex or theme.accentHex)) or "38BDF8"

    local disp = displayName
    if disp:sub(1, 1) ~= '@' then disp = '@' .. disp end
    local linkedDisplay = ZO_LinkHandler_CreateDisplayNameLink(disp)

    local charSuffix = ""
    if characterName and characterName ~= "" then
        local cName = zo_strformat("<<1>>", characterName)
        charSuffix = string.format(" (%s)", ZO_LinkHandler_CreateCharacterLink(cName))
    end

    local playerFormatted = string.format("|c%s%s%s|r", accentColor, linkedDisplay, charSuffix)
    local notifText = ""

    if not wasOnline and isOnline then
        notifText = string.format(L('NOTIF_FRIEND_LOGIN'), playerFormatted)
    elseif wasOnline and not isOnline then
        notifText = string.format(L('NOTIF_FRIEND_LOGOUT'), playerFormatted)
    end

    if notifText ~= "" then
        local timeStr = GetTimeString():sub(1, 5)

        -- 1. On-Screen In-Game HUD Toast Banner (~6cm / 220px from top)
        Messenger.ShowFriendToastNotification(notifText, theme)

        -- 2. Save to general channel history
        History.AddMessage('general', 'Amis', notifText, timeStr, 0, false, false)

        -- 3. Active AetherChat buffer if window is open and viewing general
        if Messenger.window and not Messenger.window:IsHidden() and activeChannelKey == 'general' then
            local buffer = Messenger.window:GetNamedChild('Messages')
            if buffer then
                local timeTag = string.format('|c%s[%s]|r', Theme.Hex.MUTED, timeStr)
                buffer:AddMessage(string.format('%s %s', timeTag, notifText))
                buffer:SetScrollPosition(0)
            end
        end

        -- 4. Native chat fallback
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage(notifText)
        end
    end
end

function Messenger.OnGuildMemberPlayerStatusChanged(eventCode, guildId, displayName, oldStatus, newStatus)
    if not Settings.Get('notifyGuildStatus', false) then
        return
    end

    if not displayName or displayName == "" then return end

    -- Determine which guild slot (1..5) corresponds to this guildId
    local guildSlot = nil
    for g = 1, GetNumGuilds() do
        if GetGuildId(g) == guildId then
            guildSlot = g
            break
        end
    end

    if not guildSlot then return end
    if not Settings.Get('notifyGuild_' .. guildSlot, true) then return end

    local wasOnline = (oldStatus ~= nil and oldStatus ~= PLAYER_STATUS_OFFLINE)
    local isOnline = (newStatus ~= nil and newStatus ~= PLAYER_STATUS_OFFLINE)

    if wasOnline == isOnline then
        return
    end

    local guildPrefix = L('CH_GUILD_PREFIX') or "Guilde"
    local guildName = GetGuildName(guildId) or (guildPrefix .. " " .. tostring(guildSlot))
    local theme = Theme.GetCurrentTheme()
    local accentColor = (theme and (theme.selfHex or theme.accentHex)) or "38BDF8"

    local disp = displayName
    if disp:sub(1, 1) ~= '@' then disp = '@' .. disp end
    local linkedDisplay = ZO_LinkHandler_CreateDisplayNameLink(disp)

    local toastText = ""
    local guildChatText = ""
    local generalChatText = ""

    if not wasOnline and isOnline then
        -- Connected: Green / Bright Accent Color
        local greenPlayer = string.format("|c57F287%s|r", linkedDisplay)
        toastText = string.format("[%s] %s", guildName, string.format(L('NOTIF_LOGGED_ON'), disp))
        guildChatText = string.format(L('NOTIF_LOGGED_ON'), greenPlayer)
        generalChatText = string.format(L('NOTIF_GUILD_LOGIN'), guildName, greenPlayer)
    elseif wasOnline and not isOnline then
        -- Disconnected: Clean Grey Color
        local greyPlayer = string.format("|c888888%s|r", linkedDisplay)
        toastText = string.format("[%s] %s", guildName, string.format(L('NOTIF_LOGGED_OFF'), disp))
        guildChatText = string.format(L('NOTIF_LOGGED_OFF'), greyPlayer)
        generalChatText = string.format(L('NOTIF_GUILD_LOGOUT'), guildName, greyPlayer)
    end

    if guildChatText ~= "" then
        local timeStr = GetTimeString():sub(1, 5)

        -- 1. On-Screen In-Game HUD Toast Banner
        Messenger.ShowFriendToastNotification(toastText, theme)

        -- 2. Save to guild channel (clean, no guild prefix) and general channel (subtle tag)
        local guildChannelKey = 'guild' .. tostring(guildSlot)
        History.AddMessage(guildChannelKey, guildPrefix, guildChatText, timeStr, 0, false, false)
        History.AddMessage('general', guildPrefix, generalChatText, timeStr, 0, false, false)

        -- 3. Live buffer update if currently viewing this guild or general
        if Messenger.window and not Messenger.window:IsHidden() then
            local textToDisplay = (activeChannelKey == guildChannelKey) and guildChatText or generalChatText
            if activeChannelKey == guildChannelKey or activeChannelKey == 'general' then
                local buffer = Messenger.window:GetNamedChild('Messages')
                if buffer then
                    local timeTag = string.format('|c%s[%s]|r', Theme.Hex.MUTED, timeStr)
                    buffer:AddMessage(string.format('%s %s', timeTag, textToDisplay))
                    buffer:SetScrollPosition(0)
                end
            end
        end

        -- 4. Native chat fallback
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage(toastText)
        end
    end
end

function Messenger.ShowOnlineFriendsMenu(anchorControl)
    ClearMenu()

    local numFriends = GetNumFriends() or 0
    local onlineFriends = {}

    for i = 1, numFriends do
        local displayName, note, status, secsSinceLogoff = GetFriendInfo(i)
        if status ~= PLAYER_STATUS_OFFLINE then
            local hasChar, charName, zoneName, classType, alliance, level, cp = GetFriendCharacterInfo(i)
            table.insert(onlineFriends, {
                displayName = displayName,
                charName = (charName and charName ~= '') and zo_strformat("<<1>>", charName) or "",
                zoneName = (zoneName and zoneName ~= '') and zo_strformat("<<1>>", zoneName) or "",
                status = status,
            })
        end
    end

    if #onlineFriends == 0 then
        AddCustomMenuItem("|c888888" .. L('MENU_NO_FRIENDS') .. "|r", function() end)
    else
        for _, friend in ipairs(onlineFriends) do
            local label = friend.displayName
            if friend.charName ~= "" then
                label = string.format("%s |c888888(%s - %s)|r", friend.displayName, friend.charName, friend.zoneName)
            end

            AddCustomMenuItem(label, function()
                Messenger.RegisterWhisperContact(friend.displayName)
                Messenger.SelectChannel('dm:' .. friend.displayName, true, true)
            end)
        end
    end

    ShowMenu(anchorControl)
end

function Messenger.SetupHideHooks()
    if hideHooksInitialized then return end
    hideHooksInitialized = true

    if ZO_ChatWindow then
        ZO_PreHook(ZO_ChatWindow, "SetHidden", function(self, hidden)
            if not hidden and Settings.Get('hideOfficialChat', false) then
                return true
            end
        end)
    end

    if ZO_ChatWindowMinBar then
        ZO_PreHook(ZO_ChatWindowMinBar, "SetHidden", function(self, hidden)
            if not hidden and Settings.Get('hideOfficialChat', false) then
                return true
            end
        end)
    end

    if CHAT_SYSTEM then
        if CHAT_SYSTEM.primaryContainer then
            ZO_PreHook(CHAT_SYSTEM.primaryContainer, "FadeIn", function()
                if Settings.Get('hideOfficialChat', false) then
                    return true
                end
            end)
        end

        ZO_PreHook(CHAT_SYSTEM, "Maximize", function()
            if Settings.Get('hideOfficialChat', false) then
                return true
            end
        end)
    end
end

function Messenger.SetHideOfficialChat(hide)
    Messenger.SetupHideHooks()

    if hide then
        if ZO_ChatWindow then ZO_ChatWindow:SetHidden(true) end
        if ZO_ChatWindowMinBar then ZO_ChatWindowMinBar:SetHidden(true) end
        if CHAT_SYSTEM then
            if CHAT_SYSTEM.primaryContainer then CHAT_SYSTEM.primaryContainer:FadeOut() end
            CHAT_SYSTEM:Minimize()
        end
    else
        if CHAT_SYSTEM then
            CHAT_SYSTEM:Maximize()
            if CHAT_SYSTEM.primaryContainer then CHAT_SYSTEM.primaryContainer:FadeIn() end
        end
        if ZO_ChatWindow then ZO_ChatWindow:SetHidden(false) end
    end
end

function Messenger.DockNativeChatEntry()
    if not ZO_ChatWindowTextEntry or not Messenger.window then return end

    local mode = Settings.Get('interfaceMode', 'standard')
    local leftOffset = 230
    local rightOffset = -10
    local bottomOffset = -8

    if mode == 'compact' then
        leftOffset = 6
        rightOffset = -6
        bottomOffset = -6
    else
        local isCollapsed = Settings.Get('sidebarCollapsed', false)
        leftOffset = isCollapsed and 72 or 230
        rightOffset = -10
        bottomOffset = -8
    end

    ZO_ChatWindowTextEntry:SetParent(Messenger.window)
    ZO_ChatWindowTextEntry:ClearAnchors()
    ZO_ChatWindowTextEntry:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, leftOffset, bottomOffset)
    ZO_ChatWindowTextEntry:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, rightOffset, bottomOffset)
    ZO_ChatWindowTextEntry:SetMovable(false)
    ZO_ChatWindowTextEntry:SetHidden(Messenger.window:IsHidden())
end

function Messenger.UndockNativeChatEntry()
    if not ZO_ChatWindowTextEntry then return end
    if ZO_ChatWindow then
        ZO_ChatWindowTextEntry:SetParent(ZO_ChatWindow)
        ZO_ChatWindowTextEntry:ClearAnchors()
        ZO_ChatWindowTextEntry:SetAnchor(BOTTOMLEFT, ZO_ChatWindow, BOTTOMLEFT, 0, 0)
        ZO_ChatWindowTextEntry:SetAnchor(BOTTOMRIGHT, ZO_ChatWindow, BOTTOMRIGHT, 0, 0)
        ZO_ChatWindowTextEntry:SetMovable(false)
        local hideOfficial = Settings.Get('hideOfficialChat', false)
        if not hideOfficial then
            ZO_ChatWindowTextEntry:SetHidden(false)
        else
            ZO_ChatWindowTextEntry:SetHidden(true)
        end
    end
end

function Messenger.ApplyBackdropAlpha(alphaPercent)
    local pct = alphaPercent or Settings.Get('backdropAlpha', 95)
    local alpha = math.max(0.2, math.min(1.0, pct / 100))
    if Messenger.window then
        local bg = Messenger.window:GetNamedChild('_BG')
        if bg then
            bg:SetAlpha(alpha)
        end
    end
end

function Messenger.SetSidebarCollapsed(collapsed)
    Settings.Set('sidebarCollapsed', collapsed)
    if not Messenger.window then return end
    if Settings.Get('interfaceMode', 'standard') == 'compact' then return end

    local scrollContainer = Messenger.window:GetNamedChild('ChannelsScroll')
    local sidebarBg = Messenger.window:GetNamedChild('SidebarBG')
    local divider = Messenger.window:GetNamedChild('VerticalDivider')
    local title = Messenger.window:GetNamedChild('ActiveChannelLabel')
    local midDiv = Messenger.window:GetNamedChild('MidDivider')
    local messages = Messenger.window:GetNamedChild('Messages')
    local bottomDiv = Messenger.window:GetNamedChild('BottomDivider')
    local collapseSidebarBtn = Messenger.window:GetNamedChild('CollapseSidebarBtn')
    local scrollBar = scrollContainer and scrollContainer:GetNamedChild('ScrollBar')

    if collapsed then
        if sidebarBg then
            sidebarBg:ClearAnchors()
            sidebarBg:SetDimensions(60)
            sidebarBg:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 6, 46)
            sidebarBg:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 6, -8)
        end
        if scrollContainer then
            scrollContainer:ClearAnchors()
            scrollContainer:SetDimensions(60)
            scrollContainer:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 6, 46)
            scrollContainer:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 6, -8)
        end
        if scrollBar then
            scrollBar:SetWidth(8)
            scrollBar:SetAlpha(0.55)
        end
        if divider then
            divider:ClearAnchors()
            divider:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 68, 44)
            divider:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 68, -6)
        end
        if title then
            title:ClearAnchors()
            title:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 78, 48)
        end
        if midDiv then
            midDiv:ClearAnchors()
            midDiv:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 72, 76)
            midDiv:SetAnchor(TOPRIGHT, Messenger.window, TOPRIGHT, -8, 76)
        end
        if messages then
            messages:ClearAnchors()
            messages:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 76, 82)
            messages:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, -10, -48)
        end
        if bottomDiv then
            bottomDiv:ClearAnchors()
            bottomDiv:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 72, -44)
            bottomDiv:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, -8, -44)
        end
        if collapseSidebarBtn then
            collapseSidebarBtn:ClearAnchors()
            collapseSidebarBtn:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 25, 12)
            collapseSidebarBtn:SetNormalTexture("/esoui/art/buttons/tree_closed_up.dds")
            collapseSidebarBtn:SetPressedTexture("/esoui/art/buttons/tree_closed_down.dds")
            collapseSidebarBtn:SetMouseOverTexture("/esoui/art/buttons/tree_closed_over.dds")
        end
    else
        if sidebarBg then
            sidebarBg:ClearAnchors()
            sidebarBg:SetDimensions(216)
            sidebarBg:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 6, 46)
            sidebarBg:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 6, -8)
        end
        if scrollContainer then
            scrollContainer:ClearAnchors()
            scrollContainer:SetDimensions(216)
            scrollContainer:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 6, 46)
            scrollContainer:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 6, -8)
        end
        if scrollBar then
            scrollBar:SetWidth(14)
            scrollBar:SetAlpha(1.0)
        end
        if divider then
            divider:ClearAnchors()
            divider:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 226, 44)
            divider:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 226, -6)
        end
        if title then
            title:ClearAnchors()
            title:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 236, 48)
        end
        if midDiv then
            midDiv:ClearAnchors()
            midDiv:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 230, 76)
            midDiv:SetAnchor(TOPRIGHT, Messenger.window, TOPRIGHT, -8, 76)
        end
        if messages then
            messages:ClearAnchors()
            messages:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 234, 82)
            messages:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, -10, -48)
        end
        if bottomDiv then
            bottomDiv:ClearAnchors()
            bottomDiv:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 230, -44)
            bottomDiv:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, -8, -44)
        end
        if collapseSidebarBtn then
            collapseSidebarBtn:ClearAnchors()
            collapseSidebarBtn:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 8, 12)
            collapseSidebarBtn:SetNormalTexture("/esoui/art/buttons/tree_open_up.dds")
            collapseSidebarBtn:SetPressedTexture("/esoui/art/buttons/tree_open_down.dds")
            collapseSidebarBtn:SetMouseOverTexture("/esoui/art/buttons/tree_open_over.dds")
        end
    end

    Messenger.DockNativeChatEntry()
    Messenger.RefreshChannelList()
end

function Messenger.ToggleSidebarCollapse()
    local isCollapsed = Settings.Get('sidebarCollapsed', false)
    Messenger.SetSidebarCollapsed(not isCollapsed)
end

function Messenger.SetZoneLang(langKey)
    currentZoneLang = langKey or 'all'
    if Messenger.UpdateZoneLangPills then
        Messenger.UpdateZoneLangPills()
    end
    if activeChannelKey == 'zone' then
        Messenger.SelectChannel('zone', true, false)
    end
end

function Messenger.SetupStandardModeButton()
    if Messenger.standardModeBtn then return end
    if not Messenger.window then return end

    local modeBtn = Messenger.window:GetNamedChild('ModeBtn')
    if not modeBtn then return end
    Messenger.standardModeBtn = modeBtn

    modeBtn:SetHandler('OnMouseEnter', function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        InformationTooltip:AddLine(L('TT_MODE_TOGGLE_TO_COMPACT'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        InformationTooltip:AddLine("|c888888" .. L('SET_MODE_TT') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
    end)
    modeBtn:SetHandler('OnMouseExit', function(self)
        ClearTooltip(InformationTooltip)
    end)
    modeBtn:SetHandler('OnClicked', function()
        Messenger.ToggleInterfaceMode()
    end)
end

function Messenger.SetupCompactTabBar()
    if Messenger.compactHeader then return end
    if not Messenger.window then return end

    local header = Messenger.window:GetNamedChild('CompactHeader')
    if not header then return end
    Messenger.compactHeader = header

    -- Allow dragging compact window directly from header or background; right-click creates custom tab
    local function HandleHeaderMouseDown(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and Messenger.window then
            Messenger.window:StartMoving()
        end
    end
    local function HandleHeaderMouseUp(self, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT and Messenger.window then
            Messenger.window:StopMovingOrResizing()
            local left = Messenger.window:GetLeft()
            local top = Messenger.window:GetTop()
            if left and top then
                Messenger.window:ClearAnchors()
                Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                Settings.Set('compactPos', { x = left, y = top })
            end
        elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            ClearMenu()
            AddCustomMenuItem(L('TAB_MENU_NEW'), function()
                if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                    AetherChat.CustomTabs.OpenTabOptions(nil)
                end
            end)
            ShowMenu(self)
        end
    end

    header:SetMouseEnabled(true)
    header:SetHandler('OnMouseDown', HandleHeaderMouseDown)
    header:SetHandler('OnMouseUp', HandleHeaderMouseUp)

    local headerBG = header:GetNamedChild('BG')
    if headerBG then
        headerBG:SetMouseEnabled(true)
        headerBG:SetHandler('OnMouseDown', HandleHeaderMouseDown)
        headerBG:SetHandler('OnMouseUp', HandleHeaderMouseUp)
    end

    local closeBtn = header:GetNamedChild('CloseBtn')
    if closeBtn then
        closeBtn:SetHandler('OnClicked', function()
            Messenger.Toggle()
        end)
    end

    local settingsBtn = header:GetNamedChild('SettingsBtn')
    if settingsBtn then
        settingsBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('TT_SETTINGS_BTN'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|c888888" .. L('TT_SETTINGS_BTN_SUB') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        settingsBtn:SetHandler('OnMouseExit', function(self) ClearTooltip(InformationTooltip) end)
        settingsBtn:SetHandler('OnClicked', function()
            Settings.OpenSettingsPanel()
        end)
    end

    local modeBtn = header:GetNamedChild('ModeBtn')
    if modeBtn then
        modeBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('TT_MODE_TOGGLE_TO_STANDARD'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|c888888" .. L('MODE_STANDARD_NAME') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        modeBtn:SetHandler('OnMouseExit', function(self)
            ClearTooltip(InformationTooltip)
        end)
        modeBtn:SetHandler('OnClicked', function()
            Messenger.ToggleInterfaceMode()
        end)
    end

    local searchBtn = header:GetNamedChild('SearchBtn')
    if searchBtn then
        searchBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('COMPACT_SEARCH_TT'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
        end)
        searchBtn:SetHandler('OnMouseExit', function(self) ClearTooltip(InformationTooltip) end)
        searchBtn:SetHandler('OnClicked', function()
            local searchBox = Messenger.window:GetNamedChild('SearchBox')
            if searchBox then
                if searchBox:IsHidden() then
                    searchBox:ClearAnchors()
                    searchBox:SetAnchor(RIGHT, searchBtn, LEFT, -6, 0)
                    searchBox:SetDimensions(135, 22)
                    searchBox:SetHidden(false)
                    local edit = searchBox:GetNamedChild('Edit')
                    if edit then edit:TakeFocus() end
                else
                    searchBox:SetHidden(true)
                    local edit = searchBox:GetNamedChild('Edit')
                    if edit then edit:SetText('') end
                    if activeChannelKey then Messenger.LoadMessages(activeChannelKey) end
                end
            end
        end)
    end

    Messenger.compactTabsStrip = header:GetNamedChild('TabsStrip')
end

function Messenger.RefreshCompactTabs()
    if not Messenger.compactTabsStrip then
        Messenger.SetupCompactTabBar()
    end
    local tabsStrip = Messenger.compactTabsStrip
    if not tabsStrip then return end

    for _, tabBtn in pairs(compactTabs) do
        tabBtn:SetHidden(true)
    end

    local theme = Theme.GetCurrentTheme()
    local tabIdx = 0

    local function GetOrCreateTab(i)
        if compactTabs[i] then return compactTabs[i] end
        local tabName = "AetherChat_CompactTab_" .. i
        local btn = CreateControlFromVirtual(tabName, tabsStrip, 'AetherChat_CompactTabTemplate')
        btn.bg = btn:GetNamedChild('BG')
        btn.selBg = btn:GetNamedChild('SelBG')
        btn.icon = btn:GetNamedChild('Icon')
        btn.label = btn:GetNamedChild('Label')
        btn.closeBtn = btn:GetNamedChild('CloseBtn')
        btn.badge = btn:GetNamedChild('Badge')
        btn.badgeCount = btn.badge and btn.badge:GetNamedChild('Count')

        compactTabs[i] = btn
        return btn
    end

    local curX = 2

    local tabsData = {
        { id = 'zone', name = L('TAB_ZONE_SHORT'), icon = '/esoui/art/chatwindow/chat_notification_echo.dds', width = 50, tooltip = L('TT_TAB_ZONE') },
        { id = 'general', name = L('TAB_GENERAL_SHORT'), icon = '/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds', width = 48, tooltip = L('TT_TAB_GENERAL') },
        { id = 'party', name = L('TAB_PARTY_SHORT'), icon = '/esoui/art/compass/groupleader.dds', width = 46, tooltip = L('TT_TAB_PARTY') },
        { id = 'system', name = L('TAB_SYSTEM_SHORT'), icon = '/esoui/art/chatwindow/chat_options_up.dds', width = 46, tooltip = L('TT_TAB_SYSTEM') },
        { id = 'loot', name = L('TAB_LOOT_SHORT'), icon = '/esoui/art/inventory/inventory_tabicon_misc_up.dds', width = 48, tooltip = L('TT_TAB_LOOT') },
    }

    local numGuilds = GetNumGuilds() or 0
    if numGuilds > 0 then
        local gLabel = L('CH_GUILDS_DROPDOWN')
        local gSelected = false
        if activeChannelKey and activeChannelKey:find('^guild') then
            local gIdx = activeChannelKey:sub(6)
            gLabel = 'G' .. gIdx .. ' ▾'
            gSelected = true
        end

        local totalGuildUnread = 0
        for i = 1, numGuilds do
            totalGuildUnread = totalGuildUnread + (unreadCounts['guild' .. i] or 0)
        end

        table.insert(tabsData, {
            id = 'guilds_dropdown',
            name = gLabel,
            icon = '/esoui/art/guild/tabicon_roster_up.dds',
            width = 58,
            isSelected = gSelected,
            unread = totalGuildUnread,
            tooltip = L('TT_TAB_GUILDS'),
            isGuilds = true,
        })
    end

    -- Custom Tabs configured by player
    if AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabs then
        local customTabs = AetherChat.CustomTabs.GetTabs()
        local customOrder = AetherChat.CustomTabs.GetTabOrder()
        local addedTabs = {}
        if customOrder then
            for _, cId in ipairs(customOrder) do
                local cTab = customTabs[cId]
                if cTab then
                    local cName = cTab.name or L('TAB_NEW_DEFAULT_NAME')
                    local cWidth = math.max(48, math.min(84, string.len(cName) * 8 + 24))
                    local cIcon = (AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabIcon and AetherChat.CustomTabs.GetTabIcon(cTab)) or '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
                    table.insert(tabsData, {
                        id = cId,
                        name = cName,
                        icon = cIcon,
                        width = cWidth,
                        isCustomTab = true,
                        tooltip = string.format(L('TT_TAB_CUSTOM'), cName),
                        unread = unreadCounts[cId] or 0,
                    })
                    addedTabs[cId] = true
                end
            end
        end
        for cId, cTab in pairs(customTabs) do
            if not addedTabs[cId] then
                local cName = cTab.name or L('TAB_NEW_DEFAULT_NAME')
                local cWidth = math.max(48, math.min(84, string.len(cName) * 8 + 24))
                local cIcon = (AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabIcon and AetherChat.CustomTabs.GetTabIcon(cTab)) or '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
                table.insert(tabsData, {
                    id = cId,
                    name = cName,
                    icon = cIcon,
                    width = cWidth,
                    isCustomTab = true,
                    tooltip = string.format(L('TT_TAB_CUSTOM'), cName),
                    unread = unreadCounts[cId] or 0,
                })
            end
        end
    end

    for _, contact in ipairs(knownWhispers) do
        local dLabel = "@" .. contact
        if string.len(dLabel) > 8 then
            dLabel = string.sub(dLabel, 1, 7) .. "…"
        end
        table.insert(tabsData, {
            id = 'dm:' .. contact,
            name = dLabel,
            contact = contact,
            icon = '/esoui/art/contacts/tabicon_friends_up.dds',
            width = 68,
            isWhisper = true,
            tooltip = string.format(L('TT_TAB_WHISPER'), contact),
            unread = unreadCounts['dm:' .. contact] or 0,
        })
    end

    for _, data in ipairs(tabsData) do
        tabIdx = tabIdx + 1
        local btn = GetOrCreateTab(tabIdx)
        btn:ClearAnchors()
        btn:SetAnchor(TOPLEFT, tabsStrip, TOPLEFT, curX, 0)
        btn:SetDimensions(data.width, 24)
        btn:SetHidden(false)

        curX = curX + data.width + 3

        local isSelected = (data.id == activeChannelKey) or (data.isSelected == true)

        btn.icon:SetTexture(data.icon)
        btn.icon:SetHidden(false)

        btn.label:SetText(data.name)
        btn.label:ClearAnchors()
        btn.label:SetAnchor(LEFT, btn.icon, RIGHT, 3, 0)
        if data.isWhisper then
            btn.label:SetAnchor(RIGHT, btn.closeBtn, LEFT, -2, 0)
        else
            btn.label:SetAnchor(RIGHT, btn, RIGHT, -4, 0)
        end

        if data.isWhisper then
            btn.closeBtn:SetHidden(false)
            btn.closeBtn:SetHandler('OnClicked', function()
                Messenger.CloseWhisperTab(data.id)
                Messenger.RefreshCompactTabs()
            end)
        else
            btn.closeBtn:SetHidden(true)
            btn.closeBtn:SetHandler('OnClicked', nil)
        end

        if isSelected then
            btn.selBg:SetHidden(false)
            local aR = (theme and theme.accentR) or 0.85
            local aG = (theme and theme.accentG) or 0.69
            local aB = (theme and theme.accentB) or 0.22
            btn.selBg:SetCenterColor(aR, aG, aB, 0.35)
            btn.selBg:SetEdgeColor(aR, aG, aB, 1.0)
            btn.label:SetColor(aR, aG, aB, 1.0)
            btn.icon:SetColor(1, 1, 1, 1)
        else
            btn.selBg:SetHidden(true)
            btn.bg:SetCenterColor(0.08, 0.08, 0.08, 0.45)
            btn.bg:SetEdgeColor(0.24, 0.24, 0.24, 0.6)
            btn.label:SetColor(0.75, 0.75, 0.75, 0.85)
            btn.icon:SetColor(0.75, 0.75, 0.75, 0.85)
        end

        local unread = data.unread or (unreadCounts[data.id] or 0)
        if unread > 0 then
            if btn.badge then btn.badge:SetHidden(false) end
            if btn.badgeCount then btn.badgeCount:SetText(tostring(unread)) end
        else
            if btn.badge then btn.badge:SetHidden(true) end
        end

        btn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(data.name, "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            if data.tooltip then
                InformationTooltip:AddLine(data.tooltip, "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end
        end)
        btn:SetHandler('OnMouseExit', function(self) ClearTooltip(InformationTooltip) end)

        if data.isGuilds then
            btn:SetHandler('OnMouseUp', function(self, button, upInside)
                if not upInside then return end
                ClearMenu()
                for i = 1, numGuilds do
                    local gId = GetGuildId(i)
                    if gId and gId > 0 then
                        local gName = GetGuildName(gId) or (L('CH_GUILD_PREFIX') .. ' ' .. i)
                        local uCount = unreadCounts['guild' .. i] or 0
                        local itemText = string.format("[%d] %s", i, gName)
                        if uCount > 0 then
                            itemText = itemText .. string.format(" |cF23F43(%d)|r", uCount)
                        end
                        local targetChannel = 'guild' .. i
                        AddCustomMenuItem(itemText, function()
                            Messenger.SelectChannel(targetChannel, true, true)
                            Messenger.RefreshCompactTabs()
                        end)
                    end
                end
                ShowMenu(self)
            end)
        elseif data.id == 'zone' then
            btn:SetHandler('OnMouseUp', function(self, button, upInside)
                if not upInside then return end
                if button == MOUSE_BUTTON_INDEX_RIGHT then
                    ClearMenu()
                    AddCustomMenuItem(L('MENU_ZONE_ALL'), function() Messenger.SetZoneLang('all') end)
                    AddCustomMenuItem(L('MENU_ZONE_FR'), function() Messenger.SetZoneLang('fr') end)
                    AddCustomMenuItem(L('MENU_ZONE_EN'), function() Messenger.SetZoneLang('en') end)
                    AddCustomMenuItem(L('MENU_ZONE_DE'), function() Messenger.SetZoneLang('de') end)
                    AddCustomMenuItem(L('MENU_ZONE_ES'), function() Messenger.SetZoneLang('es') end)
                    AddCustomMenuItem(L('MENU_ZONE_GLOBAL'), function() Messenger.SetZoneLang('global') end)
                    ShowMenu(self)
                else
                    Messenger.SelectChannel('zone', true, true)
                    Messenger.RefreshCompactTabs()
                end
            end)
        elseif data.id == 'loot' then
            btn:SetHandler('OnMouseUp', function(self, button, upInside)
                if not upInside then return end
                if button == MOUSE_BUTTON_INDEX_RIGHT then
                    local curFilter = Settings.Get('filterSetsOnly', false)
                    Settings.Set('filterSetsOnly', not curFilter)
                    Messenger.LoadMessages('loot')
                    local msg = not curFilter and L('CHAT_FILTER_SETS_ON') or L('CHAT_FILTER_SETS_OFF')
                    d(msg)
                else
                    Messenger.SelectChannel('loot', true, true)
                    Messenger.RefreshCompactTabs()
                end
            end)
        elseif data.isCustomTab then
            btn:SetHandler('OnMouseUp', function(self, button, upInside)
                if not upInside then return end
                if button == MOUSE_BUTTON_INDEX_RIGHT then
                    ClearMenu()
                    AddCustomMenuItem(L('TAB_MENU_EDIT'), function()
                        if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                            AetherChat.CustomTabs.OpenTabOptions(data.id)
                        end
                    end)
                    AddCustomMenuItem(L('TAB_MENU_DELETE'), function()
                        if AetherChat.CustomTabs and AetherChat.CustomTabs.DeleteTab then
                            AetherChat.CustomTabs.DeleteTab(data.id)
                        end
                    end)
                    AddCustomMenuItem(L('TAB_MENU_NEW'), function()
                        if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                            AetherChat.CustomTabs.OpenTabOptions(nil)
                        end
                    end)
                    ShowMenu(self)
                else
                    Messenger.SelectChannel(data.id, true, true)
                    Messenger.RefreshCompactTabs()
                end
            end)
        else
            btn:SetHandler('OnMouseUp', function(self, button, upInside)
                if not upInside then return end
                if button == MOUSE_BUTTON_INDEX_RIGHT then
                    ClearMenu()
                    AddCustomMenuItem(L('TAB_MENU_NEW'), function()
                        if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                            AetherChat.CustomTabs.OpenTabOptions(nil)
                        end
                    end)
                    ShowMenu(self)
                else
                    Messenger.SelectChannel(data.id, true, true)
                    Messenger.RefreshCompactTabs()
                end
            end)
        end
    end

    -- Dedicated [+] button to create new custom tabs
    tabIdx = tabIdx + 1
    local addBtn = GetOrCreateTab(tabIdx)
    addBtn:ClearAnchors()
    addBtn:SetAnchor(TOPLEFT, tabsStrip, TOPLEFT, curX, 0)
    addBtn:SetDimensions(22, 24)
    addBtn:SetHidden(false)
    addBtn.icon:SetHidden(true)
    addBtn.closeBtn:SetHidden(true)
    if addBtn.badge then addBtn.badge:SetHidden(true) end
    addBtn.selBg:SetHidden(true)
    addBtn.bg:SetCenterColor(0.10, 0.10, 0.10, 0.5)
    addBtn.bg:SetEdgeColor(0.35, 0.35, 0.35, 0.6)
    addBtn.label:ClearAnchors()
    addBtn.label:SetAnchor(CENTER, addBtn, CENTER, 0, 0)
    addBtn.label:SetText("+")
    addBtn.label:SetColor(0.9, 0.72, 0.35, 1)

    addBtn:SetHandler('OnMouseEnter', function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        InformationTooltip:AddLine(L('TAB_MENU_NEW'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
    end)
    addBtn:SetHandler('OnMouseExit', function(self) ClearTooltip(InformationTooltip) end)
    addBtn:SetHandler('OnMouseUp', function(self, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                AetherChat.CustomTabs.OpenTabOptions(nil)
            end
        end
    end)

    -- Left click on empty area of tabsStrip drags/moves window smoothly; Right click opens context menu
    tabsStrip:SetMouseEnabled(true)
    tabsStrip:SetHandler('OnMouseDown', function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and Messenger.window then
            Messenger.window:StartMoving()
        end
    end)
    tabsStrip:SetHandler('OnMouseUp', function(self, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT and Messenger.window then
            Messenger.window:StopMovingOrResizing()
            local left = Messenger.window:GetLeft()
            local top = Messenger.window:GetTop()
            if left and top then
                Messenger.window:ClearAnchors()
                Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                Settings.Set('compactPos', { x = left, y = top })
            end
        elseif upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()
            AddCustomMenuItem(L('TAB_MENU_NEW'), function()
                if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                    AetherChat.CustomTabs.OpenTabOptions(nil)
                end
            end)
            ShowMenu(self)
        end
    end)
end

function Messenger.ToggleInterfaceMode()
    local current = Settings.Get('interfaceMode', 'standard')
    local nextMode = (current == 'compact') and 'standard' or 'compact'
    Messenger.SetInterfaceMode(nextMode)
end

-- ============================================================================
-- Gamepad & Keyboard Rapid Tab Navigation & Chat Input Focus
-- ============================================================================

function Messenger.GetNavigableChannels()
    local channels = {}
    local mode = Settings.Get('interfaceMode', 'standard')

    if mode == 'compact' then
        -- Standard compact base channels
        table.insert(channels, 'zone')
        table.insert(channels, 'general')
        table.insert(channels, 'party')
        table.insert(channels, 'system')
        table.insert(channels, 'loot')

        -- Single Guild entry in compact cycle (points to current/last selected guild)
        local numGuilds = GetNumGuilds() or 0
        if numGuilds > 0 then
            local gChan = compactSelectedGuild or 'guild1'
            local gNum = tonumber(gChan:match('%d+')) or 1
            if gNum > numGuilds then gChan = 'guild1' end
            table.insert(channels, gChan)
        end

        -- Custom Tabs
        if AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabs then
            local customTabs = AetherChat.CustomTabs.GetTabs()
            local customOrder = AetherChat.CustomTabs.GetTabOrder()
            local added = {}
            if customOrder then
                for _, cId in ipairs(customOrder) do
                    if customTabs[cId] and not added[cId] then
                        table.insert(channels, cId)
                        added[cId] = true
                    end
                end
            end
            for cId, _ in pairs(customTabs) do
                if not added[cId] then
                    table.insert(channels, cId)
                    added[cId] = true
                end
            end
        end

        -- Active Whispers
        for _, contact in ipairs(knownWhispers or {}) do
            table.insert(channels, 'dm:' .. contact)
        end
    else
        local items = Messenger.BuildChannelItems()
        for _, itm in ipairs(items) do
            if not itm.isFolder then
                table.insert(channels, itm.id)
            end
        end
    end

    return channels
end

function Messenger.CycleTab(delta)
    if not Messenger.isOpen then
        Messenger.Show()
        return
    end

    local channels = Messenger.GetNavigableChannels()
    if not channels or #channels == 0 then return end

    local curIdx = 1
    for idx, cId in ipairs(channels) do
        if cId == activeChannelKey or (activeChannelKey and activeChannelKey:find('^guild') and cId:find('^guild')) then
            curIdx = idx
            break
        end
    end

    local newIdx = curIdx + delta
    if newIdx > #channels then
        newIdx = 1
    elseif newIdx < 1 then
        newIdx = #channels
    end

    local targetChannel = channels[newIdx]
    if targetChannel then
        local mode = Settings.Get('interfaceMode', 'standard')
        Messenger.SelectChannel(targetChannel, true, false)
        if mode == 'compact' then
            Messenger.RefreshCompactTabs()
        else
            Messenger.RefreshChannelList()
        end
        PlaySound(SOUNDS.CHAT_TAB_SWAPPED or SOUNDS.DEFAULT_CLICK)
    end
end

function Messenger.NextTab()
    Messenger.CycleTab(1)
end

function Messenger.PrevTab()
    Messenger.CycleTab(-1)
end

function Messenger.NextGuild()
    local numGuilds = GetNumGuilds() or 0
    if numGuilds <= 1 then return end

    local curIdx = 1
    if activeChannelKey and activeChannelKey:find('^guild') then
        curIdx = tonumber(activeChannelKey:sub(6)) or 1
    elseif compactSelectedGuild and compactSelectedGuild:find('^guild') then
        curIdx = tonumber(compactSelectedGuild:sub(6)) or 1
    end

    local nextIdx = (curIdx % numGuilds) + 1
    local targetChannel = 'guild' .. nextIdx
    compactSelectedGuild = targetChannel

    Messenger.SelectChannel(targetChannel, true, false)
    local mode = Settings.Get('interfaceMode', 'standard')
    if mode == 'compact' then
        Messenger.RefreshCompactTabs()
    else
        Messenger.RefreshChannelList()
    end
    PlaySound(SOUNDS.CHAT_TAB_SWAPPED or SOUNDS.DEFAULT_CLICK)
end

function Messenger.PrevGuild()
    local numGuilds = GetNumGuilds() or 0
    if numGuilds <= 1 then return end

    local curIdx = 1
    if activeChannelKey and activeChannelKey:find('^guild') then
        curIdx = tonumber(activeChannelKey:sub(6)) or 1
    elseif compactSelectedGuild and compactSelectedGuild:find('^guild') then
        curIdx = tonumber(compactSelectedGuild:sub(6)) or 1
    end

    local prevIdx = curIdx - 1
    if prevIdx < 1 then prevIdx = numGuilds end
    local targetChannel = 'guild' .. prevIdx
    compactSelectedGuild = targetChannel

    Messenger.SelectChannel(targetChannel, true, false)
    local mode = Settings.Get('interfaceMode', 'standard')
    if mode == 'compact' then
        Messenger.RefreshCompactTabs()
    else
        Messenger.RefreshChannelList()
    end
    PlaySound(SOUNDS.CHAT_TAB_SWAPPED or SOUNDS.DEFAULT_CLICK)
end

function Messenger.ReleaseChatFocus()
    local chatSys = (ZO_GetChatSystem and ZO_GetChatSystem()) or CHAT_SYSTEM
    if chatSys then
        chatSys.isEnteringText = false
        if chatSys.textEntry then
            chatSys.textEntry.isEnteringText = false
            if chatSys.textEntry.CloseTextEntry then
                chatSys.textEntry:CloseTextEntry(true)
            end
        end
        if chatSys.CloseTextEntry then
            chatSys:CloseTextEntry(true)
        end
    end

    if ZO_ChatWindowTextEntryEditBox then
        ZO_ChatWindowTextEntryEditBox:LoseFocus()
    end

    if SCENE_MANAGER and SCENE_MANAGER.IsInUIMode and SCENE_MANAGER:IsInUIMode() then
        if not (SCENE_MANAGER.IsLockedInUIMode and SCENE_MANAGER:IsLockedInUIMode()) then
            SCENE_MANAGER:SetInUIMode(false)
        end
    end

    if SetGameCameraUIMode and IsGameCameraUIModeActive and IsGameCameraUIModeActive() then
        SetGameCameraUIMode(false)
    end

    EVENT_MANAGER:UnregisterForUpdate('AetherChat_GamepadMoveWatcher')
end

function Messenger.FocusChatInput()
    if not Messenger.isOpen then
        Messenger.Show()
    end

    -- Toggle behavior: if chat entry is already active, close it and resume gameplay immediately!
    if ZO_ChatWindowTextEntryEditBox and ZO_ChatWindowTextEntryEditBox:HasFocus() then
        Messenger.ReleaseChatFocus()
        return
    end

    Messenger.DockNativeChatEntry()

    if ZO_ChatWindowTextEntry then
        ZO_ChatWindowTextEntry:SetHidden(false)
    end

    if ZO_ChatWindowTextEntryEditBox then
        ZO_ChatWindowTextEntryEditBox:TakeFocus()
    elseif CHAT_SYSTEM and CHAT_SYSTEM.StartTextEntry then
        CHAT_SYSTEM:StartTextEntry()
    end

    -- High-performance movement watcher: releases focus as soon as the player pushes the left stick or moves
    EVENT_MANAGER:UnregisterForUpdate('AetherChat_GamepadMoveWatcher')
    EVENT_MANAGER:RegisterForUpdate('AetherChat_GamepadMoveWatcher', 100, function()
        if not (ZO_ChatWindowTextEntryEditBox and ZO_ChatWindowTextEntryEditBox:HasFocus()) then
            EVENT_MANAGER:UnregisterForUpdate('AetherChat_GamepadMoveWatcher')
            return
        end

        if Settings.Get('gamepadCancelOnMove', true) then
            local isMoving = (IsPlayerMoving and IsPlayerMoving())
            if not isMoving and GetUnitVelocity then
                local vx, vy, vz = GetUnitVelocity('player')
                if vx and (vx*vx + vy*vy + vz*vz) > 0.001 then
                    isMoving = true
                end
            end
            if isMoving then
                Messenger.ReleaseChatFocus()
            end
        end
    end)
end

function Messenger.ApplyNativeGamepadChatHidden(hide)
    if hide == nil then
        hide = Settings.Get('gamepadUseKeyboardChat', true)
    end

    -- 1. Safety Cleanup: Ensure ESO's system notification screens are NEVER stuck on the HUD!
    if ZO_Notifications and not (SCENE_MANAGER and SCENE_MANAGER:IsShowing('notifications')) then
        ZO_Notifications:SetHidden(true)
    end
    if ZO_GamepadNotifications and not (SCENE_MANAGER and (SCENE_MANAGER:IsShowing('gamepad_notifications_root') or SCENE_MANAGER:IsShowing('notifications'))) then
        ZO_GamepadNotifications:SetHidden(true)
    end

    -- 2. Official ESO Gamepad Setting: Use Keyboard Chat
    -- When GAMEPAD_SETTING_USE_KEYBOARD_CHAT is "1", ESO natively directs chat to standard chat
    -- and completely disables the Gamepad HUD chat notification bubble.
    if GAMEPAD_SETTING_USE_KEYBOARD_CHAT and SetSetting then
        SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_USE_KEYBOARD_CHAT, hide and "1" or "0")
    end

    -- 3. Gamepad Chat System controls & fragments (isolated strictly to chat)
    if GAMEPAD_CHAT_SYSTEM then
        if GAMEPAD_CHAT_SYSTEM.control and GAMEPAD_CHAT_SYSTEM.control.SetHidden and hide then
            GAMEPAD_CHAT_SYSTEM.control:SetHidden(true)
        end
        if GAMEPAD_CHAT_SYSTEM.hudFragment then
            if hide then
                if HUD_SCENE and HUD_SCENE:HasFragment(GAMEPAD_CHAT_SYSTEM.hudFragment) then
                    HUD_SCENE:RemoveFragment(GAMEPAD_CHAT_SYSTEM.hudFragment)
                end
                if HUD_UI_SCENE and HUD_UI_SCENE:HasFragment(GAMEPAD_CHAT_SYSTEM.hudFragment) then
                    HUD_UI_SCENE:RemoveFragment(GAMEPAD_CHAT_SYSTEM.hudFragment)
                end
            else
                if HUD_SCENE and not HUD_SCENE:HasFragment(GAMEPAD_CHAT_SYSTEM.hudFragment) then
                    HUD_SCENE:AddFragment(GAMEPAD_CHAT_SYSTEM.hudFragment)
                end
            end
        end
        if GAMEPAD_CHAT_SYSTEM.minimizedFragment and hide then
            if HUD_SCENE and HUD_SCENE:HasFragment(GAMEPAD_CHAT_SYSTEM.minimizedFragment) then
                HUD_SCENE:RemoveFragment(GAMEPAD_CHAT_SYSTEM.minimizedFragment)
            end
            if HUD_UI_SCENE and HUD_UI_SCENE:HasFragment(GAMEPAD_CHAT_SYSTEM.minimizedFragment) then
                HUD_UI_SCENE:RemoveFragment(GAMEPAD_CHAT_SYSTEM.minimizedFragment)
            end
        end
    end

    if TEXT_CHAT_GAMEPAD and TEXT_CHAT_GAMEPAD.control and TEXT_CHAT_GAMEPAD.control.SetHidden and hide then
        TEXT_CHAT_GAMEPAD.control:SetHidden(true)
    end
end

function Messenger.SetInterfaceMode(mode, skipSaveCurrent)
    if not Messenger.window then return end
    local prevMode = Settings.Get('interfaceMode', 'standard')

    if not skipSaveCurrent and prevMode ~= mode then
        local curW, curH = Messenger.window:GetDimensions()
        local curL, curT = Messenger.window:GetLeft(), Messenger.window:GetTop()
        if curL and curT and curW and curH then
            if prevMode == 'compact' then
                Settings.Set('compactDimensions', { width = math.floor(curW + 0.5), height = math.floor(curH + 0.5) })
                Settings.Set('compactPos', { x = math.floor(curL + 0.5), y = math.floor(curT + 0.5) })
            else
                Settings.Set('windowDimensions', { width = math.floor(curW + 0.5), height = math.floor(curH + 0.5) })
                Settings.Set('windowPos', { x = math.floor(curL + 0.5), y = math.floor(curT + 0.5) })
            end
        end
    end

    Settings.Set('interfaceMode', mode)

    local scrollContainer = Messenger.window:GetNamedChild('ChannelsScroll')
    local sidebarBg = Messenger.window:GetNamedChild('SidebarBG')
    local vDivider = Messenger.window:GetNamedChild('VerticalDivider')
    local collapseBtn = Messenger.window:GetNamedChild('CollapseSidebarBtn')
    local topDiv = Messenger.window:GetNamedChild('TopDivider')
    local headerIcon = Messenger.window:GetNamedChild('HeaderIcon')
    local title = Messenger.window:GetNamedChild('Title')
    local searchBox = Messenger.window:GetNamedChild('SearchBox')
    local donateBtn = Messenger.window:GetNamedChild('DonateBtn')
    local mailBtn = Messenger.window:GetNamedChild('MailBtn')
    local friendsBtn = Messenger.window:GetNamedChild('FriendsBtn')
    local settingsBtn = Messenger.window:GetNamedChild('SettingsBtn')
    local closeBtn = Messenger.window:GetNamedChild('CloseBtn')
    local channelLabel = Messenger.window:GetNamedChild('ActiveChannelLabel')
    local midDiv = Messenger.window:GetNamedChild('MidDivider')
    local zoneLangBar = Messenger.window:GetNamedChild('ZoneLangBar')
    local setFilterBtn = Messenger.window:GetNamedChild('SetFilterBtn')
    local clearBtn = Messenger.window:GetNamedChild('ClearBtn')
    local messages = Messenger.window:GetNamedChild('Messages')
    local bottomDiv = Messenger.window:GetNamedChild('BottomDivider')
    local compactHeader = Messenger.compactHeader
    local stdModeBtn = Messenger.standardModeBtn

    if mode == 'compact' then
        if sidebarBg then sidebarBg:SetHidden(true) end
        if scrollContainer then scrollContainer:SetHidden(true) end
        if vDivider then vDivider:SetHidden(true) end
        if collapseBtn then collapseBtn:SetHidden(true) end
        if topDiv then topDiv:SetHidden(true) end
        if headerIcon then headerIcon:SetHidden(true) end
        if title then title:SetHidden(true) end
        if searchBox then searchBox:SetHidden(true) end
        if donateBtn then donateBtn:SetHidden(true) end
        if mailBtn then mailBtn:SetHidden(true) end
        if friendsBtn then friendsBtn:SetHidden(true) end
        if settingsBtn then settingsBtn:SetHidden(true) end
        if closeBtn then closeBtn:SetHidden(true) end
        if channelLabel then channelLabel:SetHidden(true) end
        if midDiv then midDiv:SetHidden(true) end
        if zoneLangBar then zoneLangBar:SetHidden(true) end
        if setFilterBtn then setFilterBtn:SetHidden(true) end
        if clearBtn then clearBtn:SetHidden(true) end
        if stdModeBtn then stdModeBtn:SetHidden(true) end

        if not compactHeader then
            Messenger.SetupCompactTabBar()
            compactHeader = Messenger.compactHeader
        end
        if compactHeader then compactHeader:SetHidden(false) end

        if messages then
            messages:ClearAnchors()
            messages:SetAnchor(TOPLEFT, Messenger.window, TOPLEFT, 8, 38)
            messages:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, -8, -38)
        end

        if bottomDiv then
            bottomDiv:ClearAnchors()
            bottomDiv:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 6, -34)
            bottomDiv:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, -6, -34)
            bottomDiv:SetHidden(false)
        end

        local cPos = Settings.Get('compactPos')
        if cPos and cPos.x and cPos.y then
            Messenger.window:ClearAnchors()
            Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cPos.x, cPos.y)
        else
            Messenger.window:ClearAnchors()
            Messenger.window:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 30, -100)
        end

        local cDims = Settings.Get('compactDimensions')
        if cDims and cDims.width and cDims.height then
            Messenger.window:SetDimensions(cDims.width, cDims.height)
        else
            Messenger.window:SetDimensions(450, 270)
        end

        Messenger.DockNativeChatEntry()
        Messenger.RefreshCompactTabs()

    else
        if compactHeader then compactHeader:SetHidden(true) end

        if sidebarBg then sidebarBg:SetHidden(false) end
        if scrollContainer then scrollContainer:SetHidden(false) end
        if vDivider then vDivider:SetHidden(false) end
        if collapseBtn then collapseBtn:SetHidden(false) end
        if topDiv then topDiv:SetHidden(false) end
        if headerIcon then headerIcon:SetHidden(false) end
        if title then title:SetHidden(false) end
        if searchBox then
            searchBox:ClearAnchors()
            if stdModeBtn then
                searchBox:SetAnchor(TOPRIGHT, stdModeBtn, TOPLEFT, -8, 0)
            else
                searchBox:SetAnchor(TOPRIGHT, Messenger.window, TOPRIGHT, -158, 10)
            end
            searchBox:SetDimensions(175, 24)
            searchBox:SetHidden(false)
        end
        if donateBtn then donateBtn:SetHidden(false) end
        if mailBtn then mailBtn:SetHidden(false) end
        if friendsBtn then friendsBtn:SetHidden(false) end
        if settingsBtn then settingsBtn:SetHidden(false) end
        if closeBtn then closeBtn:SetHidden(false) end
        if channelLabel then channelLabel:SetHidden(false) end
        if midDiv then midDiv:SetHidden(false) end
        if clearBtn then clearBtn:SetHidden(false) end
        if stdModeBtn then stdModeBtn:SetHidden(false) end

        local isCollapsed = Settings.Get('sidebarCollapsed', false)
        Messenger.SetSidebarCollapsed(isCollapsed)

        local winPos = Settings.Get('windowPos')
        if winPos and winPos.x and winPos.y then
            Messenger.window:ClearAnchors()
            Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, winPos.x, winPos.y)
        else
            Messenger.window:ClearAnchors()
            Messenger.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        end

        local winDims = Settings.Get('windowDimensions')
        if winDims and winDims.width and winDims.height then
            Messenger.window:SetDimensions(winDims.width, winDims.height)
        else
            Messenger.window:SetDimensions(940, 520)
        end

        Messenger.DockNativeChatEntry()
        Messenger.RefreshChannelList()
    end

    if activeChannelKey then
        Messenger.SelectChannel(activeChannelKey, true, false)
    end
end

function Messenger.OnFragmentShowing()
    Messenger.DockNativeChatEntry()

    if activeChannelKey then
        unreadCounts[activeChannelKey] = 0
        Messenger.UpdateTotalBadge()
    end

    Messenger.RefreshChannelList()
    Messenger.UpdateMailBadge()
    Messenger.UpdateFriendsBadge()
    Messenger.SelectChannel(activeChannelKey or 'zone', true, false)
    if ZO_ChatWindowTextEntryEditBox then
        ZO_ChatWindowTextEntryEditBox:LoseFocus()
    end
    if CHAT_SYSTEM and CHAT_SYSTEM.CloseTextEntry then
        CHAT_SYSTEM:CloseTextEntry(true)
    end
end

function Messenger.OnFragmentHidden()
    if CHAT_SYSTEM then
        CHAT_SYSTEM.isEnteringText = false
        if CHAT_SYSTEM.textEntry then
            CHAT_SYSTEM.textEntry.isEnteringText = false
            if CHAT_SYSTEM.textEntry.CloseTextEntry then
                CHAT_SYSTEM.textEntry:CloseTextEntry(true)
            end
        end
        if CHAT_SYSTEM.CloseTextEntry then
            CHAT_SYSTEM:CloseTextEntry(true)
        end
    end

    if ZO_ChatWindowTextEntryEditBox then
        ZO_ChatWindowTextEntryEditBox:LoseFocus()
    end

    -- Return text entry back to native chat immediately so old chat works flawlessly!
    Messenger.UndockNativeChatEntry()

    if PopupTooltip and not PopupTooltip:IsHidden() then
        ZO_PopupTooltip_Hide()
        PopupTooltip.lastLink = nil
    end

    if Messenger.donationWindow and not Messenger.donationWindow:IsHidden() then
        Messenger.donationWindow:SetHidden(true)
    end
end

function Messenger.Show()
    Messenger.isOpen = true
    if Messenger.fragment then
        Messenger.fragment:Refresh()
    else
        if Messenger.window then
            Messenger.window:SetHidden(false)
            Messenger.OnFragmentShowing()
        end
    end
end

function Messenger.Hide()
    Messenger.isOpen = false
    if Messenger.fragment then
        Messenger.fragment:Refresh()
    else
        if Messenger.window then
            Messenger.window:SetHidden(true)
            Messenger.OnFragmentHidden()
        end
    end
end

function Messenger.Toggle()
    if ZO_Notifications and not (SCENE_MANAGER and SCENE_MANAGER:IsShowing('notifications')) then
        ZO_Notifications:SetHidden(true)
    end
    if ZO_GamepadNotifications and not (SCENE_MANAGER and (SCENE_MANAGER:IsShowing('gamepad_notifications_root') or SCENE_MANAGER:IsShowing('notifications'))) then
        ZO_GamepadNotifications:SetHidden(true)
    end

    if Messenger.isOpen then
        Messenger.Hide()
    else
        Messenger.Show()
    end
end

function Messenger.LoadWhispersFromHistory()
    if not AetherChat.savedVars then return end
    AetherChat.savedVars.openWhispers = AetherChat.savedVars.openWhispers or {}

    -- Only restore whisper tabs that were explicitly kept open!
    for contact, isOpen in pairs(AetherChat.savedVars.openWhispers) do
        if isOpen and contact and contact ~= "" then
            Messenger.RegisterWhisperContact(contact)
        end
    end
end

function Messenger.RegisterWhisperContact(contact)
    if not contact or contact == '' then return end

    AetherChat.savedVars = AetherChat.savedVars or {}
    AetherChat.savedVars.openWhispers = AetherChat.savedVars.openWhispers or {}
    AetherChat.savedVars.openWhispers[contact] = true

    for i = #knownWhispers, 1, -1 do
        if knownWhispers[i] == contact then
            table.remove(knownWhispers, i)
        end
    end
    table.insert(knownWhispers, 1, contact)

    local channelId = 'dm:' .. contact
    local savedOrder = Settings.GetChannelOrder()
    if savedOrder and #savedOrder > 0 then
        for i = #savedOrder, 1, -1 do
            if savedOrder[i] == channelId then
                table.remove(savedOrder, i)
            end
        end
        table.insert(savedOrder, 1, channelId)
        Settings.SetChannelOrder(savedOrder)
    end
end

function Messenger.CloseWhisperTab(channelId)
    if not channelId or channelId:sub(1, 3) ~= 'dm:' then return end
    local contact = channelId:sub(4)

    -- Mark closed in saved variables so it NEVER reopens automatically on login/reload!
    if AetherChat.savedVars and AetherChat.savedVars.openWhispers then
        AetherChat.savedVars.openWhispers[contact] = nil
    end

    for i = #knownWhispers, 1, -1 do
        if knownWhispers[i] == contact then
            table.remove(knownWhispers, i)
        end
    end

    local savedOrder = Settings.GetChannelOrder()
    if savedOrder then
        for i = #savedOrder, 1, -1 do
            if savedOrder[i] == channelId then
                table.remove(savedOrder, i)
            end
        end
        Settings.SetChannelOrder(savedOrder)
    end

    unreadCounts[channelId] = 0
    Messenger.UpdateTotalBadge()

    if activeChannelKey == channelId then
        Messenger.SelectChannel('zone', true, false)
    else
        Messenger.RefreshChannelList()
    end
end

function Messenger.BuildChannelItems()
    local rawItems = {}
    local rawMap = {}

    -- 1. WHISPERS
    for _, contact in ipairs(knownWhispers) do
        local itm = {
            id = 'dm:' .. contact,
            name = contact,
            prefix = '/tell ' .. contact,
            icon = '/esoui/art/contacts/tabicon_friends_up.dds',
            isWhisper = true,
        }
        table.insert(rawItems, itm)
        rawMap[itm.id] = itm
    end

    -- 2. FIXED CHANNELS (Localized)
    local fixedChannels = GetFixedChannels()
    for _, ch in ipairs(fixedChannels) do
        table.insert(rawItems, ch)
        rawMap[ch.id] = ch
    end

    -- 3. COLLAPSIBLE GUILDS FOLDER (Localized)
    local numGuilds = GetNumGuilds() or 0
    if numGuilds > 0 then
        local folderPrefix = isGuildsExpanded and "[-] " or "[+] "
        local folderItem = {
            id = 'guilds_folder',
            name = folderPrefix .. L('CH_GUILDS_FOLDER') .. ' (' .. numGuilds .. ')',
            icon = '/esoui/art/tutorial/guild-tabicon_heraldry_up.dds',
            isFolder = true,
        }
        table.insert(rawItems, folderItem)
        rawMap[folderItem.id] = folderItem

        if isGuildsExpanded then
            for i = 1, numGuilds do
                local gId = GetGuildId(i)
                if gId and gId > 0 then
                    local gName = GetGuildName(gId) or (L('CH_GUILD_PREFIX') .. ' ' .. i)
                    local itm = {
                        id = 'guild' .. i,
                        name = "  " .. gName,
                        prefix = '/g' .. i,
                        icon = '/esoui/art/guild/tabicon_roster_up.dds',
                        isGuildChild = true,
                    }
                    table.insert(rawItems, itm)
                    rawMap[itm.id] = itm
                end
            end
        end
    end

    -- 3b. CUSTOM CHANNELS / TABS
    if AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabs then
        local customTabs = AetherChat.CustomTabs.GetTabs()
        local customOrder = AetherChat.CustomTabs.GetTabOrder()
        local addedTabs = {}
        if customOrder then
            for _, cId in ipairs(customOrder) do
                local cTab = customTabs[cId]
                if cTab then
                    local cIcon = (AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabIcon and AetherChat.CustomTabs.GetTabIcon(cTab)) or '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
                    local itm = {
                        id = cId,
                        name = cTab.name or L('TAB_NEW_DEFAULT_NAME'),
                        icon = cIcon,
                        isCustomTab = true,
                    }
                    table.insert(rawItems, itm)
                    rawMap[itm.id] = itm
                    addedTabs[cId] = true
                end
            end
        end
        for cId, cTab in pairs(customTabs) do
            if not addedTabs[cId] then
                local cIcon = (AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabIcon and AetherChat.CustomTabs.GetTabIcon(cTab)) or '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
                local itm = {
                    id = cId,
                    name = cTab.name or L('TAB_NEW_DEFAULT_NAME'),
                    icon = cIcon,
                    isCustomTab = true,
                }
                table.insert(rawItems, itm)
                rawMap[itm.id] = itm
            end
        end
    end

    -- 4. APPLY CUSTOM SAVED ORDER
    local savedOrder = Settings.GetChannelOrder()
    local orderedItems = {}
    local addedMap = {}

    if savedOrder and #savedOrder > 0 then
        for _, id in ipairs(savedOrder) do
            if rawMap[id] and not addedMap[id] and not rawMap[id].isGuildChild then
                table.insert(orderedItems, rawMap[id])
                addedMap[id] = true

                if id == 'guilds_folder' and isGuildsExpanded then
                    for i = 1, numGuilds do
                        local gId = 'guild' .. i
                        if rawMap[gId] and not addedMap[gId] then
                            table.insert(orderedItems, rawMap[gId])
                            addedMap[gId] = true
                        end
                    end
                end
            end
        end
    end

    for _, itm in ipairs(rawItems) do
        if not addedMap[itm.id] then
            table.insert(orderedItems, itm)
            addedMap[itm.id] = true
        end
    end

    currentItems = orderedItems
    return currentItems
end

function Messenger.SaveCurrentChannelOrder()
    local order = {}
    for _, itm in ipairs(currentItems) do
        if not itm.isGuildChild then
            table.insert(order, itm.id)
        end
    end
    Settings.SetChannelOrder(order)
end

function Messenger.RefreshChannelList()
    if not Messenger.window then return end

    if Settings.Get('interfaceMode', 'standard') == 'compact' then
        Messenger.RefreshCompactTabs()
        return
    end
    local scrollContainer = Messenger.window:GetNamedChild('ChannelsScroll')
    local scrollChild = scrollContainer and (scrollContainer:GetNamedChild('ScrollChild') or _G['AetherChat_MessengerWindowChannelsScrollScrollChild'])
    local container = scrollChild or scrollContainer
    if not container then return end

    for _, btn in pairs(channelButtons) do
        btn:SetHidden(true)
        btn:SetHandler('OnUpdate', nil)
    end

    local items = Messenger.BuildChannelItems()
    local offsetY = 0
    local theme = Theme.GetCurrentTheme()

    local isCollapsed = Settings.Get('sidebarCollapsed', false)
    local btnWidth = isCollapsed and 38 or 198
    local btnOffsetX = isCollapsed and 4 or 0
    local btnHeight = isCollapsed and 38 or 34
    local strideY = isCollapsed and 44 or 36
    local offsetY = 4

    for i, item in ipairs(items) do
        local btn = channelButtons[i]
        if not btn then
            btn = CreateControlFromVirtual('AetherChat_ChBtn_' .. i, container, 'AetherChat_ChannelBtnTemplate')
            channelButtons[i] = btn
        end

        btn:ClearAnchors()
        btn:SetAnchor(TOPLEFT, container, TOPLEFT, btnOffsetX, offsetY)
        btn:SetDimensions(btnWidth, btnHeight)
        btn:SetHidden(false)

        local isSelected = (item.id == activeChannelKey)

        local btnBG = btn:GetNamedChild('BG')
        if btnBG then
            btnBG:ClearAnchors()
            btnBG:SetAnchorFill()
            btnBG:SetHidden(false)
            if isCollapsed then
                btnBG:SetAlpha(1.0)
                btnBG:SetCenterColor(0.10, 0.10, 0.10, 0.85)
                btnBG:SetEdgeColor(0.24, 0.24, 0.24, 0.8)
            else
                btnBG:SetAlpha(0.25)
                btnBG:SetCenterColor(0.07, 0.07, 0.07, 0.25)
                btnBG:SetEdgeColor(0.23, 0.23, 0.23, 0.4)
            end
        end

        local nameLabel = btn:GetNamedChild('Name')
        if nameLabel then
            nameLabel:SetText(item.name)
            nameLabel:SetHidden(isCollapsed)
            if not isCollapsed then
                local currentFontSize = Settings.Get('chatFontSize', 16) or 16
                nameLabel:SetFont(string.format("$(CHAT_FONT)|%d|soft-shadow-thin", math.max(13, currentFontSize - 1)))
            end
        end

        local icon = btn:GetNamedChild('Icon')
        if icon then
            local iconTex = item.icon
            if iconTex and iconTex ~= "" then
                icon:SetTexture(iconTex)
                icon:SetHidden(false)
            else
                icon:SetHidden(true)
            end
            icon:ClearAnchors()
            if isCollapsed then
                icon:SetDimensions(24, 24)
                icon:SetAnchor(CENTER, btn, CENTER, 0, 0)
                if isSelected then
                    icon:SetColor(1, 1, 1, 1)
                else
                    icon:SetColor(0.85, 0.85, 0.85, 0.88)
                end
            else
                icon:SetDimensions(22, 22)
                icon:SetAnchor(LEFT, btn, LEFT, 8, 0)
                icon:SetColor(1, 1, 1, 1)
            end
        end

        local selectedBg = btn:GetNamedChild('SelectedBG')
        if selectedBg then
            selectedBg:ClearAnchors()
            selectedBg:SetAnchorFill()
            selectedBg:SetHidden(not isSelected)
            if isSelected then
                local aR = (theme and theme.accentR) or 0.85
                local aG = (theme and theme.accentG) or 0.69
                local aB = (theme and theme.accentB) or 0.22
                if isCollapsed then
                    selectedBg:SetCenterColor(aR, aG, aB, 0.35)
                    selectedBg:SetEdgeColor(aR, aG, aB, 1.0)
                    if btnBG then
                        btnBG:SetEdgeColor(aR, aG, aB, 1.0)
                    end
                else
                    selectedBg:SetCenterColor(aR, aG, aB, 0.45)
                    selectedBg:SetEdgeColor(aR, aG, aB, 1.0)
                end
            end
        end

        local dragGlow = btn:GetNamedChild('DragGlow')
        if dragGlow then
            local isBeingDragged = (dragState and dragState.itemId == item.id)
            dragGlow:SetHidden(not isBeingDragged)
            if isBeingDragged and theme and theme.accentR then
                dragGlow:SetCenterColor(theme.accentR, theme.accentG, theme.accentB, 0.6)
            end
        end

        local isWhisperTab = item.isWhisper or (item.id and item.id:sub(1, 3) == 'dm:')
        local closeBtn = btn:GetNamedChild('CloseBtn')
        if closeBtn then
            if isWhisperTab and not isCollapsed then
                closeBtn:SetHidden(false)
                closeBtn:SetHandler('OnClicked', function()
                    Messenger.CloseWhisperTab(item.id)
                end)
            else
                closeBtn:SetHidden(true)
            end
        end

        local badge = btn:GetNamedChild('Badge')
        local unread = unreadCounts[item.id] or 0

        if item.isFolder and item.id == 'guilds_folder' then
            local totalGuildUnread = 0
            for g = 1, 5 do
                totalGuildUnread = totalGuildUnread + (unreadCounts['guild' .. g] or 0)
            end
            unread = totalGuildUnread
        end

        if badge then
            badge:ClearAnchors()
            if isCollapsed then
                badge:SetAnchor(TOPRIGHT, btn, TOPRIGHT, 0, 0)
                if unread >= 10 then
                    badge:SetDimensions(22, 18)
                else
                    badge:SetDimensions(18, 18)
                end
            elseif isWhisperTab then
                badge:SetAnchor(RIGHT, btn, RIGHT, -26, 0)
                if unread >= 10 then
                    badge:SetDimensions(22, 18)
                else
                    badge:SetDimensions(18, 18)
                end
            else
                badge:SetAnchor(RIGHT, btn, RIGHT, -6, 0)
                if unread >= 10 then
                    badge:SetDimensions(22, 18)
                else
                    badge:SetDimensions(18, 18)
                end
            end

            badge:SetCenterColor(0.72, 0.08, 0.08, 1.0)
            badge:SetEdgeColor(0.90, 0.72, 0.35, 1.0)

            local count = badge:GetNamedChild('Count')
            if unread > 0 then
                badge:SetHidden(false)
                if count then
                    count:ClearAnchors()
                    count:SetAnchorFill()
                    count:SetText(unread > 99 and "99+" or tostring(unread))
                    count:SetFont("ZoFontGameSmall")
                    count:SetColor(1, 1, 1, 1)
                end
            else
                badge:SetHidden(true)
            end
        end

        -- Clean Tooltip on hover
        btn:SetHandler('OnMouseEnter', function(self)
            if isCollapsed and item.id ~= activeChannelKey then
                local bg = self:GetNamedChild('BG')
                if bg then
                    bg:SetCenterColor(0.16, 0.16, 0.16, 0.95)
                    bg:SetEdgeColor((theme and theme.accentR) or 0.85, (theme and theme.accentG) or 0.69, (theme and theme.accentB) or 0.22, 0.85)
                end
                local ic = self:GetNamedChild('Icon')
                if ic then ic:SetColor(1, 1, 1, 1) end
            end

            InitializeTooltip(InformationTooltip, self, RIGHT, 8, 0)
            InformationTooltip:AddLine("|cE5B558" .. item.name .. "|r", "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            if item.isGuildChild then
                InformationTooltip:AddLine("|c888888" .. L('CHANNEL_GUILD') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end
            if unread > 0 then
                InformationTooltip:AddLine("|cF23F43" .. L('TT_UNREAD_COUNT', unread) .. "|r", "ZoFontGameSmall", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            end
        end)
        btn:SetHandler('OnMouseExit', function(self)
            if isCollapsed and item.id ~= activeChannelKey then
                local bg = self:GetNamedChild('BG')
                if bg then
                    bg:SetCenterColor(0.10, 0.10, 0.10, 0.85)
                    bg:SetEdgeColor(0.24, 0.24, 0.24, 0.8)
                end
                local ic = self:GetNamedChild('Icon')
                if ic then ic:SetColor(0.85, 0.85, 0.85, 0.88) end
            end
            ClearTooltip(InformationTooltip)
        end)

        if item.isFolder then
            btn:SetHandler('OnMouseDown', nil)
            btn:SetHandler('OnUpdate', nil)
            btn:SetHandler('OnMouseUp', function(self, button, upInside)
                if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                    isGuildsExpanded = not isGuildsExpanded
                    Settings.Set('guildsExpanded', isGuildsExpanded)
                    Messenger.RefreshChannelList()
                end
            end)
        else
            btn:SetHandler('OnMouseDown', function(self, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    local _, curY = GetUIMousePosition()
                    dragState = {
                        isDown = true,
                        active = false,
                        startY = curY,
                        startIndex = i,
                        itemId = item.id,
                    }
                    local dg = self:GetNamedChild('DragGlow')
                    if dg then dg:SetHidden(false) end
                end
            end)

            btn:SetHandler('OnUpdate', function(self)
                if dragState and dragState.isDown and dragState.startIndex == i then
                    local _, curY = GetUIMousePosition()
                    local deltaY = curY - dragState.startY

                    if math.abs(deltaY) >= 28 then
                        local step = (deltaY > 0) and 1 or -1
                        local targetIdx = dragState.startIndex + step

                        if targetIdx >= 1 and targetIdx <= #currentItems then
                            local targetItem = currentItems[targetIdx]
                            if not item.isGuildChild and not (targetItem and targetItem.isGuildChild) then
                                local movingItem = table.remove(currentItems, dragState.startIndex)
                                table.insert(currentItems, targetIdx, movingItem)

                                dragState.startIndex = targetIdx
                                dragState.startY = curY
                                dragState.active = true

                                Messenger.SaveCurrentChannelOrder()
                                Messenger.RefreshChannelList()
                            end
                        end
                    end
                end
            end)

            btn:SetHandler('OnMouseUp', function(self, button, upInside)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    local wasActive = dragState and dragState.active
                    dragState = nil

                    local dg = self:GetNamedChild('DragGlow')
                    if dg then dg:SetHidden(true) end

                    if wasActive then
                        Messenger.SaveCurrentChannelOrder()
                        Messenger.RefreshChannelList()
                    elseif upInside then
                        Messenger.SelectChannel(item.id, true, false)
                    end
                elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                    ClearMenu()
                    if item.isCustomTab then
                        AddCustomMenuItem(L('TAB_MENU_EDIT'), function()
                            if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                                AetherChat.CustomTabs.OpenTabOptions(item.id)
                            end
                        end)
                        AddCustomMenuItem(L('TAB_MENU_DELETE'), function()
                            if AetherChat.CustomTabs and AetherChat.CustomTabs.DeleteTab then
                                AetherChat.CustomTabs.DeleteTab(item.id)
                            end
                        end)
                    end
                    AddCustomMenuItem(L('TAB_MENU_NEW'), function()
                        if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                            AetherChat.CustomTabs.OpenTabOptions(nil)
                        end
                    end)
                    ShowMenu(self)
                end
            end)
        end

        offsetY = offsetY + strideY
    end

    if scrollChild and scrollContainer then
        scrollChild:SetHeight(math.max(offsetY, scrollContainer:GetHeight()))
    end

    if scrollContainer then
        scrollContainer:SetHandler('OnMouseUp', function(self, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
                ClearMenu()
                AddCustomMenuItem(L('TAB_MENU_NEW'), function()
                    if AetherChat.CustomTabs and AetherChat.CustomTabs.OpenTabOptions then
                        AetherChat.CustomTabs.OpenTabOptions(nil)
                    end
                end)
                ShowMenu(self)
            end
        end)
    end
end

function Messenger.SelectChannel(channelKey, updateEditBox, takeFocus)
    if not Messenger.window or channelKey == 'guilds_folder' then return end

    activeChannelKey = channelKey or 'zone'
    unreadCounts[activeChannelKey] = 0
    Messenger.UpdateTotalBadge()

    -- When selecting a guild, ensure the folder is expanded so it is recognized
    if activeChannelKey:find('^guild%d') then
        isGuildsExpanded = true
        Settings.Set('guildsExpanded', true)
        compactSelectedGuild = activeChannelKey
    end

    local items = Messenger.BuildChannelItems()
    local currentItem = nil
    for _, it in ipairs(items) do
        if it.id == activeChannelKey then
            currentItem = it
            break
        end
    end

    -- Direct fallback for guild channels (especially in compact mode where sidebar is hidden)
    if not currentItem and activeChannelKey:find('^guild%d') then
        local gNum = tonumber(activeChannelKey:sub(6)) or 1
        local gId = GetGuildId(gNum)
        local gName = (gId and gId > 0 and GetGuildName(gId)) or (L('CH_GUILD_PREFIX') .. ' ' .. gNum)
        currentItem = {
            id = activeChannelKey,
            name = gName,
            prefix = '/g' .. gNum,
            icon = '/esoui/art/guild/tabicon_roster_up.dds',
            isGuildChild = true,
        }
    end

    -- Direct fallback for custom channels (especially in compact mode or after mode toggle)
    if not currentItem and activeChannelKey:find('^custom_') then
        local tabData = AetherChat.CustomTabs and AetherChat.CustomTabs.GetTab(activeChannelKey)
        if tabData then
            local cIcon = (AetherChat.CustomTabs and AetherChat.CustomTabs.GetTabIcon and AetherChat.CustomTabs.GetTabIcon(tabData)) or '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
            currentItem = {
                id = activeChannelKey,
                name = tabData.name or L('TAB_NEW_DEFAULT_NAME'),
                icon = cIcon,
                isCustomTab = true,
            }
        end
    end

    if not currentItem then
        activeChannelKey = 'zone'
        local fixed = GetFixedChannels()
        currentItem = fixed[2]
    end

    local title = Messenger.window:GetNamedChild('ActiveChannelLabel')
    if title then title:SetText(currentItem.name:gsub("^%s+", "")) end

    local mode = Settings.Get('interfaceMode', 'standard')

    -- Show/hide SetFilterBtn depending on whether active channel is 'loot'
    local setFilterBtn = Messenger.window:GetNamedChild('SetFilterBtn')
    if setFilterBtn then
        if mode == 'compact' then
            setFilterBtn:SetHidden(true)
        else
            setFilterBtn:SetHidden(activeChannelKey ~= 'loot')
            if activeChannelKey == 'loot' and Messenger.UpdateSetFilterUI then
                Messenger.UpdateSetFilterUI()
            end
        end
    end

    -- Show/hide ZoneLangBar depending on whether active channel is 'zone'
    local zoneLangBar = Messenger.window:GetNamedChild('ZoneLangBar')
    if zoneLangBar then
        if mode == 'compact' then
            zoneLangBar:SetHidden(true)
        else
            zoneLangBar:SetHidden(activeChannelKey ~= 'zone')
            if activeChannelKey == 'zone' and Messenger.UpdateZoneLangPills then
                Messenger.UpdateZoneLangPills()
            end
        end
    end

    if mode == 'compact' then
        Messenger.RefreshCompactTabs()
    else
        Messenger.RefreshChannelList()
    end
    Messenger.LoadMessages(activeChannelKey)

    Messenger.DockNativeChatEntry()

    if updateEditBox and CHAT_SYSTEM then
        local targetChannel = CHAT_CHANNEL_ZONE
        local targetContact = nil

        if currentItem.isWhisper and currentItem.id:sub(1, 3) == 'dm:' then
            targetChannel = CHAT_CHANNEL_WHISPER
            targetContact = currentItem.id:sub(4)
        elseif currentItem.id == 'loot' or currentItem.id == 'party' then
            targetChannel = CHAT_CHANNEL_PARTY
        elseif currentItem.id == 'zone' then
            if currentZoneLang == 'fr' then
                targetChannel = CHAT_CHANNEL_ZONE_LANGUAGE_2
            elseif currentZoneLang == 'en' then
                targetChannel = CHAT_CHANNEL_ZONE_LANGUAGE_1
            elseif currentZoneLang == 'de' then
                targetChannel = CHAT_CHANNEL_ZONE_LANGUAGE_3
            elseif currentZoneLang == 'es' then
                targetChannel = CHAT_CHANNEL_ZONE_LANGUAGE_6
            else
                targetChannel = CHAT_CHANNEL_ZONE
            end
        elseif currentItem.id == 'general' or currentItem.id == 'say' then
            targetChannel = CHAT_CHANNEL_SAY
        elseif currentItem.id:find('^guild') then
            local gIdx = tonumber(currentItem.id:sub(6)) or 1
            local guildChannels = {
                [1] = CHAT_CHANNEL_GUILD_1,
                [2] = CHAT_CHANNEL_GUILD_2,
                [3] = CHAT_CHANNEL_GUILD_3,
                [4] = CHAT_CHANNEL_GUILD_4,
                [5] = CHAT_CHANNEL_GUILD_5,
            }
            targetChannel = guildChannels[gIdx] or CHAT_CHANNEL_GUILD_1
        elseif currentItem.isCustomTab and activeChannelKey:find('^custom_') then
            local tabData = AetherChat.CustomTabs and AetherChat.CustomTabs.GetTab(activeChannelKey)
            if tabData and AetherChat.CustomTabs.GetPrimaryChatChannel then
                targetChannel, targetContact = AetherChat.CustomTabs.GetPrimaryChatChannel(tabData)
            else
                targetChannel = CHAT_CHANNEL_ZONE
            end
        elseif currentItem.id == 'system' then
            targetChannel = CHAT_CHANNEL_ZONE
        end

        if takeFocus then
            CHAT_SYSTEM:StartTextEntry(nil, targetChannel, targetContact)
            if ZO_ChatWindowTextEntryEditBox then
                ZO_ChatWindowTextEntryEditBox:TakeFocus()
            end
        else
            if CHAT_SYSTEM.SetChannel then
                CHAT_SYSTEM:SetChannel(targetChannel, targetContact)
            elseif CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.SetChannel then
                CHAT_SYSTEM.textEntry:SetChannel(targetChannel, targetContact)
            end
            if ZO_ChatWindowTextEntryEditBox then
                ZO_ChatWindowTextEntryEditBox:LoseFocus()
            end
        end
    end
end

function Messenger.GetActiveChannel()
    return activeChannelKey
end

function Messenger.LoadMessages(channelKey)
    if not Messenger.window then return end
    local buffer = Messenger.window:GetNamedChild('Messages')
    if not buffer then return end

    buffer:Clear()

    local messages = History.GetMessages(channelKey)
    local hasResults = false
    for _, msg in ipairs(messages) do
        -- Apply live search filter
        if Messenger.MessagePassesFilter(msg.author, msg.text) then
            hasResults = true
            Messenger.RenderMessageToBuffer(buffer, msg)
        end
    end

    -- Show "no results" hint if search active and nothing found
    if not hasResults and searchFilter ~= '' then
        buffer:AddMessage('|c888888' .. L('SEARCH_NO_RESULTS') .. '|r')
    end

    buffer:SetScrollPosition(0)
end

function Messenger.RenderMessageToBuffer(buffer, msg)
    if not msg then return end
    local mutedColor = (Theme and Theme.Hex and Theme.Hex.MUTED) or '888888'
    local timeTag = string.format('|c%s[%s]|r', mutedColor, msg.time or '00:00')

    -- Dedicated System Channel Message Rendering
    if activeChannelKey == 'system' or (msg.channel and msg.channel == 'system') then
        local rawText = msg.text or ""
        rawText = rawText:gsub("[\r\n]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if rawText == "" then return end

        local formattedText = FormatItemLinksInText(rawText)
        local systemTag = "|cE5B558[" .. L('CH_SYSTEM') .. "]|r"
        if msg.author and (msg.author:find("Annonce") or msg.author:find("Broadcast")) then
            systemTag = "|cFF5555[Annonce]|r"
        end

        buffer:AddMessage(string.format('%s %s %s', timeTag, systemTag, formattedText))
        return
    end

    if activeChannelKey == 'loot' or msg.author == '|cFFFF00Loot|r' or msg.author == '|cFFFF00Loot Log|r' then
        local lineText = msg.text
        local filterSetsOnly = Settings.Get('filterSetsOnly', false)

        -- If filtering for set items only, check if line contains a set piece
        if activeChannelKey == 'loot' and filterSetsOnly then
            local itemLink = lineText:match("(|H.-:item:.-|h.-|h)")
            local isSet = false
            if itemLink then
                local hasSet = GetItemLinkSetInfo(itemLink)
                local isSetPiece = IsItemLinkSetCollectionPiece and IsItemLinkSetCollectionPiece(itemLink)
                if hasSet or isSetPiece then
                    isSet = true
                end
            end
            if not isSet and (lineText:find("|cFFCC00!!!|r") or lineText:find("uncollected") or lineText:find("status_icon")) then
                isSet = true
            end

            if not isSet then
                return -- Skip non-set drop
            end
        end

        buffer:AddMessage(string.format('%s %s', timeTag, lineText))
        return
    end

    -- Strict Zone Multi-Language Filtering
    if activeChannelKey == 'zone' and currentZoneLang ~= 'all' then
        local targetLang = msg.zoneLang
        if not targetLang then
            local txt = msg.text or ""
            if txt:find("%[FR%]") then
                targetLang = 'fr'
            elseif txt:find("%[EN%]") then
                targetLang = 'en'
            elseif txt:find("%[DE%]") then
                targetLang = 'de'
            elseif txt:find("%[ES%]") then
                targetLang = 'es'
            elseif txt:find("%[Global%]") then
                targetLang = 'global'
            else
                targetLang = 'global' -- Legacy un-tagged zone messages treated as global
            end
        end

        if targetLang ~= currentZoneLang then
            return -- Strictly filter out messages from other zone channels!
        end
    end

    local authorName = msg.author or ""

    -- System announcements: Amis, Friends, Guilde, Guild status
    if authorName == 'Amis' or authorName == '|c57F287Amis|r' or authorName == 'Friends' or authorName == '|c57F287Friends|r'
       or authorName == 'Guilde' or authorName:find('^Guilde') or authorName == 'Guild' or authorName:find('^Guild') then
        buffer:AddMessage(string.format('%s %s', timeTag, msg.text))
        return
    end

    -- Guild Store Sales announcement
    if authorName == 'Boutique' or authorName:find('Boutique') or authorName == 'Guild Store' or authorName:find('Guild Store') or authorName:find('Store') then
        local formattedText = FormatItemLinksInText(msg.text)
        buffer:AddMessage(string.format('%s |cFFD700[%s]|r %s', timeTag, L('SALES_STORE_AUTHOR'), formattedText))
        return
    end

    local myAccount = GetDisplayName()
    local theme = Theme.GetCurrentTheme()
    local isMe = msg.isSelf or (myAccount and authorName == myAccount) or authorName == "@Moi" or authorName == "You" or authorName == "@Me" or authorName == "Vous"
    local authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_ZONE) or 'C5C29E'

    if isMe then
        authorName = (myAccount and myAccount ~= '') and myAccount or '@Moi'
        authorColor = (theme and (theme.selfHex or theme.accentHex)) or '38BDF8'
    else
        local ch = msg.originalChannel or msg.channel or activeChannelKey
        if ch and ch:find('^guild') then
            authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_GUILD) or '8CD17D'
        elseif ch and ch:find('^officer') then
            authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_OFFICER) or '23A55A'
        elseif ch == 'party' then
            authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_PARTY) or '80C0FF'
        elseif msg.isWhisper or (ch and ch:sub(1, 3) == 'dm:') then
            authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_WHISPER) or 'C084FC'
        elseif ch == 'say' or ch == 'general' then
            authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_SAY) or 'E5B558'
        elseif ch == 'yell' then
            authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_YELL) or 'FF5555'
        else
            authorColor = (Theme and Theme.Hex and Theme.Hex.OTHER_ZONE) or 'C5C29E'
        end
    end

    authorColor = tostring(authorColor or 'C5C29E')

    local linkedAuthor = authorName or 'Inconnu'
    if authorName and authorName:sub(1, 1) == '@' then
        linkedAuthor = ZO_LinkHandler_CreateDisplayNameLink(authorName)
    elseif authorName and authorName ~= '' then
        linkedAuthor = ZO_LinkHandler_CreateCharacterLink(authorName)
    end
    linkedAuthor = tostring(linkedAuthor or authorName or 'Inconnu')

    local authorTag = string.format('|c%s%s:|r', authorColor, linkedAuthor)

    local channelTag = ""
    if activeChannelKey and activeChannelKey:find('^custom_') then
        local srcChan = tostring(msg.originalChannel or msg.channel or 'zone')
        if srcChan:find('^guild(%d)') then
            local gNum = tonumber(srcChan:match('^guild(%d)'))
            local gId = gNum and GetGuildId(gNum)
            local gName = (gId and gId > 0 and GetGuildName(gId)) or ('G' .. tostring(gNum or 1))
            local gCol = (Theme and Theme.Hex and Theme.Hex.OTHER_GUILD) or '8CD17D'
            channelTag = string.format('|c%s[%s]|r ', gCol, tostring(gName))
        elseif srcChan:find('^officer(%d)') then
            local oNum = srcChan:match('^officer(%d)') or '1'
            local oCol = (Theme and Theme.Hex and Theme.Hex.OTHER_OFFICER) or '23A55A'
            channelTag = string.format('|c%s[Officiers %s]|r ', oCol, tostring(oNum))
        elseif srcChan == 'party' then
            local pCol = (Theme and Theme.Hex and Theme.Hex.OTHER_PARTY) or '80C0FF'
            channelTag = string.format('|c%s[%s]|r ', pCol, tostring(L('CH_PARTY') or 'Groupe'))
        elseif srcChan == 'say' or srcChan == 'general' then
            local sCol = (Theme and Theme.Hex and Theme.Hex.OTHER_SAY) or 'E5B558'
            channelTag = string.format('|c%s[%s]|r ', sCol, tostring(L('FILT_SAY') or 'Dire'))
        elseif srcChan == 'yell' then
            local yCol = (Theme and Theme.Hex and Theme.Hex.OTHER_YELL) or 'FF5555'
            channelTag = string.format('|c%s[%s]|r ', yCol, tostring(L('FILT_YELL') or 'Crier'))
        elseif srcChan:sub(1, 3) == 'dm:' or msg.isWhisper then
            local wCol = (Theme and Theme.Hex and Theme.Hex.OTHER_WHISPER) or 'C084FC'
            channelTag = string.format('|c%s[%s]|r ', wCol, tostring(L('CH_WHISPERS') or 'Chuchotement'))
        elseif srcChan == 'zone' then
            local zLabel = 'Zone'
            if msg.zoneLang == 'fr' or (msg.text and msg.text:find("%[FR%]")) then zLabel = 'Zone FR'
            elseif msg.zoneLang == 'en' or (msg.text and msg.text:find("%[EN%]")) then zLabel = 'Zone EN'
            elseif msg.zoneLang == 'de' or (msg.text and msg.text:find("%[DE%]")) then zLabel = 'Zone DE'
            elseif msg.zoneLang == 'es' or (msg.text and msg.text:find("%[ES%]")) then zLabel = 'Zone ES'
            end
            local zCol = (Theme and Theme.Hex and Theme.Hex.OTHER_ZONE) or 'C5C29E'
            channelTag = string.format('|c%s[%s]|r ', zCol, tostring(zLabel))
        end
    end

    local formattedText = FormatItemLinksInText(msg.text)
    local starTag = ""
    if AetherChat.ChatEngine and AetherChat.ChatEngine.ApplyKeywordHighlight then
        local highlighted, matched, hexColor = AetherChat.ChatEngine.ApplyKeywordHighlight(formattedText)
        if matched then
            formattedText = highlighted
            starTag = string.format('|c%s★|r ', hexColor or 'FFD700')
        end
    end

    buffer:AddMessage(string.format('%s%s %s%s %s', starTag, timeTag, channelTag, authorTag, formattedText))
end

function Messenger.RefreshActiveChannel()
    if activeChannelKey then
        Messenger.LoadMessages(activeChannelKey)
    end
end

function Messenger.OnMessageReceived(channelKey, author, text, isSelf, isWhisper, zoneLang, originalChannel)
    if isWhisper and channelKey:sub(1, 3) == 'dm:' then
        local contact = channelKey:sub(4)
        Messenger.RegisterWhisperContact(contact)
    end

    local isCurrentlyViewing = (Messenger.window and not Messenger.window:IsHidden()) and (activeChannelKey == channelKey)

    if not isCurrentlyViewing and not isSelf then
        if isWhisper or channelKey:find('^guild') or channelKey == 'party' or channelKey:find('^custom_') then
            unreadCounts[channelKey] = (unreadCounts[channelKey] or 0) + 1
            Messenger.UpdateTotalBadge()
        end
    end

    Messenger.RefreshChannelList()
    if Messenger.RefreshCompactTabs then
        Messenger.RefreshCompactTabs()
    end

    if isCurrentlyViewing and Messenger.window then
        local buffer = Messenger.window:GetNamedChild('Messages')
        if buffer then
            local timeStr = GetTimeString():sub(1, 5)
            Messenger.RenderMessageToBuffer(buffer, {
                author = author,
                text = text,
                time = timeStr,
                isSelf = isSelf,
                isWhisper = isWhisper,
                zoneLang = zoneLang,
                channel = originalChannel or channelKey,
                originalChannel = originalChannel or channelKey,
            })
            buffer:SetScrollPosition(0)
        end
    end
end

function Messenger.UpdateTotalBadge()
    local total = 0
    local showBadge = Settings.Get('showBadgeMessages', true)
    local notifyWhispers = Settings.Get('notifyWhispers', true)
    local notifyGuilds = Settings.Get('notifyGuilds', true)
    local notifyParty = Settings.Get('notifyParty', true)

    for key, count in pairs(unreadCounts) do
        if count > 0 then
            if notifyWhispers and key:sub(1, 3) == 'dm:' then
                total = total + count
            elseif notifyGuilds and key:find('^guild') then
                total = total + count
            elseif notifyParty and key == 'party' then
                total = total + count
            end
        end
    end

    if Messenger.minBar then
        local badge = Messenger.minBar:GetNamedChild('_Badge')
        if badge then
            local count = badge:GetNamedChild('Count')
            if showBadge and total > 0 then
                badge:SetHidden(false)
                if count then count:SetText(tostring(total)) end
            else
                badge:SetHidden(true)
            end
        end
    end
end

function Messenger.TestWhisper()
    Messenger.OnMessageReceived('zone', '@AlexQuiet', 'Bonjour à tous / Hello everyone!', true, false)
    Messenger.OnMessageReceived('dm:@TestUser', '@TestUser', 'Test whisper notification in AetherChat.', false, true)
end

-- ============================================================================
-- LIVE CHAT SEARCH (Real-time filter on current channel messages)
-- ============================================================================

local searchFilter = ''

function Messenger.SetupSearchBox()
    if not Messenger.window then return end
    local searchBox = Messenger.window:GetNamedChild('SearchBox')
    if not searchBox then
        searchBox = _G['AetherChat_MessengerWindowSearchBox']
    end
    if not searchBox then return end

    local editBox  = searchBox:GetNamedChild('Edit')
    if not editBox then
        editBox = _G['AetherChat_MessengerWindowSearchBoxEdit']
    end
    local clearBtn = searchBox:GetNamedChild('ClearBtn')
    if not clearBtn then
        clearBtn = _G['AetherChat_MessengerWindowSearchBoxClearBtn']
    end

    if not editBox then return end

    -- Set text color to white
    editBox:SetColor(1, 1, 1, 1)

    local icon = searchBox:GetNamedChild('Icon')
    if not icon then icon = _G['AetherChat_MessengerWindowSearchBoxIcon'] end

    -- Explicitly anchor editBox to the right of icon with generous spacing
    if editBox and icon then
        editBox:ClearAnchors()
        editBox:SetAnchor(LEFT, icon, RIGHT, 8, 0)
        if clearBtn then
            editBox:SetAnchor(RIGHT, clearBtn, LEFT, -4, 0)
        else
            editBox:SetAnchor(RIGHT, searchBox, RIGHT, -6, 0)
        end
        editBox:SetHeight(20)
    end

    -- Initialize default placeholder text cleanly
    if ZO_EditDefaultText_Initialize then
        ZO_EditDefaultText_Initialize(editBox, L('SEARCH_PLACEHOLDER'))
    end

    -- Focus handling
    editBox:SetHandler('OnMouseUp', function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:TakeFocus()
        end
    end)

    searchBox:SetHandler('OnMouseUp', function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            editBox:TakeFocus()
        end
    end)

    if icon then
        icon:SetMouseEnabled(true)
        icon:SetHandler('OnMouseUp', function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                editBox:TakeFocus()
            end
        end)
    end

    -- Text change handler: filter messages in real-time
    editBox:SetHandler('OnTextChanged', function(self)
        if ZO_EditDefaultText_OnTextChanged then
            ZO_EditDefaultText_OnTextChanged(self)
        end
        local query = self:GetText() or ''
        searchFilter = query:lower():match('^%s*(.-)%s*$') or ''
        if clearBtn then clearBtn:SetHidden(query == '') end
        if activeChannelKey then
            Messenger.LoadMessages(activeChannelKey)
        end
    end)

    -- Escape clears and releases focus (lets player go back to game)
    editBox:SetHandler('OnEscape', function(self)
        self:SetText('')
        searchFilter = ''
        if clearBtn then clearBtn:SetHidden(true) end
        self:LoseFocus()
        if activeChannelKey then
            Messenger.LoadMessages(activeChannelKey)
        end
    end)

    -- Enter releases focus
    editBox:SetHandler('OnEnter', function(self)
        self:LoseFocus()
    end)

    if clearBtn then
        clearBtn:SetHandler('OnClicked', function()
            editBox:SetText('')
            searchFilter = ''
            clearBtn:SetHidden(true)
            if activeChannelKey then
                Messenger.LoadMessages(activeChannelKey)
            end
            editBox:TakeFocus()
        end)
    end
end

-- Returns true if a message passes the current search filter
function Messenger.MessagePassesFilter(author, text)
    if searchFilter == '' then return true end
    local lowerAuthor = (author or ''):lower()
    local lowerText   = (text   or ''):lower()
    return lowerAuthor:find(searchFilter, 1, true) or lowerText:find(searchFilter, 1, true)
end

-- ============================================================================
-- COPY MODAL (Texte & Liens)
-- ============================================================================

function Messenger.SetupCopyModal()
    local modal = AetherChat_CopyModal
    if not modal then return end

    local closeBtn       = modal:GetNamedChild('CloseBtn')
    local bottomCloseBtn = modal:GetNamedChild('BottomCloseBtn')
    local editBox        = modal:GetNamedChild('BoxEdit')

    if closeBtn then
        closeBtn:SetHandler('OnClicked', function()
            modal:SetHidden(true)
        end)
    end
    if bottomCloseBtn then
        bottomCloseBtn:SetHandler('OnClicked', function()
            modal:SetHidden(true)
        end)
    end

    -- Update text on the description label to use localization
    local descLabel = modal:GetNamedChild('Desc')
    if descLabel then descLabel:SetText(L('MODAL_COPY_DESC')) end

    local titleLabel = modal:GetNamedChild('Title')
    if titleLabel then titleLabel:SetText('|cE5B558AetherChat|r — ' .. L('MODAL_COPY_TITLE')) end

    if bottomCloseBtn then bottomCloseBtn:SetText(L('MODAL_COPY_CLOSE')) end
end

-- Call this to open the copy modal with a specific content string
function Messenger.OpenCopyModal(content)
    local modal = AetherChat_CopyModal
    if not modal then return end

    local editBox = modal:GetNamedChild('BoxEdit')
    if editBox then
        editBox:SetText(content or '')
        -- Select all so the player just presses Ctrl+C immediately
        editBox:SelectAll()
    end

    modal:SetHidden(false)
end

-- ============================================================================
-- TYPOGRAPHY & CHAT FONT SIZE MANAGEMENT (FULL INTERFACE SCALING & CYRILLIC)
-- ============================================================================

function Messenger.ApplyChatFontSize(fontSize)
    local size = tonumber(fontSize) or 16
    if size < 12 then size = 12 end
    if size > 24 then size = 24 end

    if Messenger.window then
        -- 1. Main Messages TextBuffer with universal ESO font (supports Russian/Cyrillic & all unicode)
        local buffer = Messenger.window:GetNamedChild('Messages')
        if buffer then
            local fontStr = string.format("$(CHAT_FONT)|%d|soft-shadow-thin", size)
            buffer:SetFont(fontStr)
            if activeChannelKey then
                Messenger.LoadMessages(activeChannelKey)
            end
        end

        -- 2. Active Channel Header Title
        local activeTitle = Messenger.window:GetNamedChild('ActiveChannelLabel')
        if activeTitle then
            activeTitle:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", math.min(24, size + 3)))
        end

        -- 3. Top Header Title
        local winTitle = Messenger.window:GetNamedChild('Title')
        if winTitle then
            winTitle:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", math.min(22, size + 2)))
        end

        -- 4. Search Box Edit Field
        local searchEdit = Messenger.window:GetNamedChild('SearchBoxEdit')
        if searchEdit then
            searchEdit:SetFont(string.format("$(CHAT_FONT)|%d|soft-shadow-thin", math.max(12, size - 2)))
        end

        -- 5. Left Sidebar Channel Buttons
        for _, btn in pairs(channelButtons) do
            local nameLabel = btn:GetNamedChild('Name')
            if nameLabel then
                nameLabel:SetFont(string.format("$(CHAT_FONT)|%d|soft-shadow-thin", math.max(13, size - 1)))
            end
        end
    end
end

