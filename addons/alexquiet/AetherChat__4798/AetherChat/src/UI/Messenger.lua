-- ============================================================================
-- AetherChat : Messenger UI Controller (Edge Resizing, Full Chat Area & L10n)
-- ============================================================================
AetherChat = AetherChat or {}
AetherChat.Messenger = {}

local Messenger = AetherChat.Messenger
local Theme = AetherChat.Theme
local History = AetherChat.History
local Settings = AetherChat.Settings

local channelButtons = {}
local activeChannelKey = 'zone'
local knownWhispers = {}
local unreadCounts = {}
local hideHooksInitialized = false
local currentItems = {}
local dragState = nil
local isGuildsExpanded = false

-- Dynamic Edge Resizing state
local resizeState = nil
local MIN_WIDTH = 560
local MIN_HEIGHT = 320
local MAX_WIDTH = 1920
local MAX_HEIGHT = 1200

local function L(key, ...)
    return AetherChat.L(key, ...)
end

local function GetFixedChannels()
    return {
        { id = 'loot',  name = L('CH_LOOT'),  prefix = '/p',    icon = '/esoui/art/inventory/inventory_tabicon_misc_up.dds' },
        { id = 'zone',  name = L('CH_ZONE'),  prefix = '/zone', icon = '/esoui/art/chatwindow/chat_notification_echo.dds' },
        { id = 'say',   name = L('CH_SAY'),   prefix = '/say',  icon = '/esoui/art/chatwindow/chat_notification_echo.dds' },
        { id = 'party', name = L('CH_PARTY'), prefix = '/party',icon = '/esoui/art/compass/groupleader.dds' },
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
    Messenger.floatingIcon = AetherChat_FloatingIcon
    Messenger.window = AetherChat_MessengerWindow
    Messenger.donationWindow = AetherChat_DonationWindow

    if not Messenger.floatingIcon or not Messenger.window then return end

    isGuildsExpanded = Settings.Get('guildsExpanded', false)

    -- 1. Floating HUD Pure Notification Indicator
    local iconPos = Settings.Get('floatingIconPos')
    if iconPos and iconPos.x and iconPos.y then
        Messenger.floatingIcon:ClearAnchors()
        Messenger.floatingIcon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, iconPos.x, iconPos.y)
    end

    Messenger.floatingIcon:SetHandler('OnMoveStop', function(self)
        local pos = { x = self:GetLeft(), y = self:GetTop() }
        Settings.Set('floatingIconPos', pos)
    end)

    Messenger.floatingIcon:SetHandler('OnMouseEnter', function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        InformationTooltip:AddLine("|cE5B558" .. L('TT_FLOATING_ICON') .. "|r", "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
    end)

    Messenger.floatingIcon:SetHandler('OnMouseExit', function(self)
        ClearTooltip(InformationTooltip)
    end)

    Messenger.floatingIcon:SetHandler('OnMouseUp', nil)

    -- 2. Messenger Window Position & Saved Dimensions
    local winPos = Settings.Get('windowPos')
    if winPos and winPos.x and winPos.y then
        Messenger.window:ClearAnchors()
        Messenger.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, winPos.x, winPos.y)
    end

    local winDims = Settings.Get('windowDimensions')
    if winDims and winDims.width and winDims.height then
        Messenger.window:SetDimensions(winDims.width, winDims.height)
    else
        Messenger.window:SetDimensions(940, 520)
    end

    Messenger.window:SetHandler('OnMoveStop', function(self)
        local pos = { x = self:GetLeft(), y = self:GetTop() }
        Settings.Set('windowPos', pos)
    end)

    -- Setup Edge Resizing with Visual Glow Affordance
    Messenger.SetupEdgeResizing()

    -- Close Button
    local closeBtn = Messenger.window:GetNamedChild('CloseBtn')
    if closeBtn then
        closeBtn:SetHandler('OnClicked', function()
            Messenger.Toggle()
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

    -- Friends List Quick Button (Online Friends Only + 1-Click Whisper)
    local friendsBtn = Messenger.window:GetNamedChild('FriendsBtn')
    if friendsBtn then
        friendsBtn:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
            InformationTooltip:AddLine(L('TT_FRIENDS_BTN'), "ZoFontGameBold", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
            InformationTooltip:AddLine("|c888888" .. L('TT_FRIENDS_BTN_SUB') .. "|r", "ZoFontGameSmall", 0.8, 0.8, 0.8, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
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
            if Messenger.window and not Messenger.window:IsHidden() then
                Messenger.Toggle()
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

    -- Global mouse up for drag-and-drop channel order and edge resizing finalization
    EVENT_MANAGER:RegisterForEvent('AetherChat_GlobalMouseUp', EVENT_GLOBAL_MOUSE_UP, function()
        if dragState then
            dragState = nil
            Messenger.SaveCurrentChannelOrder()
            Messenger.RefreshChannelList()
        end
        if resizeState then
            Messenger.FinalizeResize()
        end
    end)

    Messenger.LoadWhispersFromHistory()
    Messenger.RefreshChannelList()
    Messenger.UpdateMailBadge()

    Theme.ApplyTheme(Settings.Get('activeTheme', 'skyrim_nordic'))

    Messenger.SetupHideHooks()
    if Settings.Get('hideOfficialChat', false) then
        Messenger.SetHideOfficialChat(true)
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

                if mode == 'right' then
                    local newWidth = math.max(MIN_WIDTH, math.min(MAX_WIDTH, resizeState.startWidth + deltaX))
                    Messenger.window:SetDimensions(newWidth, resizeState.startHeight)
                elseif mode == 'bottom' then
                    local newHeight = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, resizeState.startHeight + deltaY))
                    Messenger.window:SetDimensions(resizeState.startWidth, newHeight)
                elseif mode == 'top' then
                    local newHeight = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, resizeState.startHeight - deltaY))
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
    HookEdge('ResizeRight', 'right', "Étirer la largeur (Bord droit)", "Maintenez le clic gauche et glissez horizontalement pour ajuster la largeur")

    -- Hook Top Edge (Height Upwards)
    HookEdge('ResizeTop', 'top', "Étirer la hauteur (Bord supérieur)", "Maintenez le clic gauche et glissez verticalement vers le haut pour ajuster la hauteur")

    -- Hook Bottom Edge (Height Downwards)
    HookEdge('ResizeBottom', 'bottom', "Étirer la hauteur (Bord inférieur)", "Maintenez le clic gauche et glissez verticalement vers le bas pour ajuster la hauteur")
end

function Messenger.FinalizeResize()
    if not resizeState then return end

    if resizeState.glowControl then
        resizeState.glowControl:SetHidden(true)
    end
    resizeState = nil

    local finalW, finalH = Messenger.window:GetDimensions()
    local finalPos = { x = Messenger.window:GetLeft(), y = Messenger.window:GetTop() }

    Settings.Set('windowDimensions', { width = finalW, height = finalH })
    Settings.Set('windowPos', finalPos)
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
    SetGameCameraUIMode(true)
end

function Messenger.DockNativeChatEntry()
    if not ZO_ChatWindowTextEntry or not Messenger.window then return end

    ZO_ChatWindowTextEntry:SetParent(Messenger.window)
    ZO_ChatWindowTextEntry:ClearAnchors()
    ZO_ChatWindowTextEntry:SetAnchor(BOTTOMLEFT, Messenger.window, BOTTOMLEFT, 230, -8)
    ZO_ChatWindowTextEntry:SetAnchor(BOTTOMRIGHT, Messenger.window, BOTTOMRIGHT, -10, -8)
    ZO_ChatWindowTextEntry:SetMovable(false)
    ZO_ChatWindowTextEntry:SetHidden(Messenger.window:IsHidden())
end

function Messenger.UpdateMailBadge()
    if not Messenger.window then return end
    local mailBtn = Messenger.window:GetNamedChild('MailBtn')
    if not mailBtn then return end

    local badge = mailBtn:GetNamedChild('Badge')
    if not badge then return end

    local numUnread = GetNumUnreadMail() or 0
    if numUnread > 0 then
        badge:SetHidden(false)
        local countLabel = badge:GetNamedChild('Count')
        if countLabel then
            countLabel:SetText(tostring(numUnread))
        end
    else
        badge:SetHidden(true)
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

function Messenger.Toggle()
    if not Messenger.window then return end
    local isHidden = Messenger.window:IsHidden()
    Messenger.window:SetHidden(not isHidden)

    if ZO_ChatWindowTextEntry then
        ZO_ChatWindowTextEntry:SetHidden(not isHidden)
    end

    if not isHidden then
        SetGameCameraUIMode(false)
        if PopupTooltip and not PopupTooltip:IsHidden() then
            ZO_PopupTooltip_Hide()
            PopupTooltip.lastLink = nil
        end
        if Messenger.donationWindow and not Messenger.donationWindow:IsHidden() then
            Messenger.donationWindow:SetHidden(true)
        end
        if ZO_ChatWindowTextEntryEditBox then
            ZO_ChatWindowTextEntryEditBox:LoseFocus()
        end
    else
        SetGameCameraUIMode(true)
        Messenger.DockNativeChatEntry()

        if activeChannelKey then
            unreadCounts[activeChannelKey] = 0
            Messenger.UpdateTotalBadge()
        end

        Messenger.RefreshChannelList()
        Messenger.UpdateMailBadge()
        Messenger.SelectChannel(activeChannelKey or 'zone', true, false)
        if ZO_ChatWindowTextEntryEditBox then
            ZO_ChatWindowTextEntryEditBox:LoseFocus()
        end
    end
end

function Messenger.LoadWhispersFromHistory()
    if not AetherChat.savedVars or not AetherChat.savedVars.history then return end
    for key, _ in pairs(AetherChat.savedVars.history) do
        if key:sub(1, 3) == 'dm:' then
            local contact = key:sub(4)
            Messenger.RegisterWhisperContact(contact)
        end
    end
end

function Messenger.RegisterWhisperContact(contact)
    if not contact or contact == '' then return end

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
            icon = '/esoui/art/guild/tabicon_roster_up.dds',
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
    local container = Messenger.window:GetNamedChild('ChannelsList')
    if not container then return end

    for _, btn in pairs(channelButtons) do
        btn:SetHidden(true)
        btn:SetHandler('OnUpdate', nil)
    end

    local items = Messenger.BuildChannelItems()
    local offsetY = 0
    local theme = Theme.GetCurrentTheme()

    for i, item in ipairs(items) do
        local btn = channelButtons[i]
        if not btn then
            btn = CreateControlFromVirtual('AetherChat_ChBtn_' .. i, container, 'AetherChat_ChannelBtnTemplate')
            channelButtons[i] = btn
        end

        btn:ClearAnchors()
        btn:SetAnchor(TOPLEFT, container, TOPLEFT, 0, offsetY)
        btn:SetHidden(false)

        local nameLabel = btn:GetNamedChild('Name')
        if nameLabel then
            nameLabel:SetText(item.name)
        end

        local icon = btn:GetNamedChild('Icon')
        if icon and item.icon then
            icon:SetTexture(item.icon)
            icon:SetHidden(false)
        end

        local selectedBg = btn:GetNamedChild('SelectedBG')
        if selectedBg then
            selectedBg:SetHidden(item.id ~= activeChannelKey)
            if theme and theme.accentR then
                selectedBg:SetCenterColor(theme.accentR, theme.accentG, theme.accentB, 0.45)
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
            if isWhisperTab then
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
            if isWhisperTab then
                badge:SetAnchor(RIGHT, btn, RIGHT, -28, 0)
            else
                badge:SetAnchor(RIGHT, btn, RIGHT, -6, 0)
            end

            local count = badge:GetNamedChild('Count')
            if unread > 0 then
                badge:SetHidden(false)
                if count then count:SetText(tostring(unread)) end
            else
                badge:SetHidden(true)
            end
        end

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
                end
            end)
        end

        offsetY = offsetY + 36
    end
end

function Messenger.SelectChannel(channelKey, updateEditBox, takeFocus)
    if not Messenger.window or channelKey == 'guilds_folder' then return end

    activeChannelKey = channelKey or 'zone'
    unreadCounts[activeChannelKey] = 0
    Messenger.UpdateTotalBadge()

    local items = Messenger.BuildChannelItems()
    local currentItem = nil
    for _, it in ipairs(items) do
        if it.id == activeChannelKey then
            currentItem = it
            break
        end
    end

    if not currentItem then
        activeChannelKey = 'zone'
        local fixed = GetFixedChannels()
        currentItem = fixed[2]
    end

    local title = Messenger.window:GetNamedChild('ActiveChannelLabel')
    if title then title:SetText(currentItem.name:gsub("^%s+", "")) end

    Messenger.RefreshChannelList()
    Messenger.LoadMessages(activeChannelKey)

    Messenger.DockNativeChatEntry()

    if updateEditBox and CHAT_SYSTEM then
        if currentItem.isWhisper and currentItem.id:sub(1, 3) == 'dm:' then
            local contact = currentItem.id:sub(4)
            CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, contact)
        elseif currentItem.id == 'loot' or currentItem.id == 'party' then
            CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_PARTY)
        elseif currentItem.id == 'zone' then
            CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_ZONE)
        elseif currentItem.id == 'say' then
            CHAT_SYSTEM:StartTextEntry(nil, CHAT_CHANNEL_SAY)
        elseif currentItem.id:find('^guild') then
            local gIdx = tonumber(currentItem.id:sub(6)) or 1
            local guildChannels = {
                [1] = CHAT_CHANNEL_GUILD_1,
                [2] = CHAT_CHANNEL_GUILD_2,
                [3] = CHAT_CHANNEL_GUILD_3,
                [4] = CHAT_CHANNEL_GUILD_4,
                [5] = CHAT_CHANNEL_GUILD_5,
            }
            CHAT_SYSTEM:StartTextEntry(nil, guildChannels[gIdx] or CHAT_CHANNEL_GUILD_1)
        else
            CHAT_SYSTEM:StartTextEntry(currentItem.prefix .. ' ')
        end

        if ZO_ChatWindowTextEntryEditBox then
            if takeFocus then
                ZO_ChatWindowTextEntryEditBox:TakeFocus()
            else
                ZO_ChatWindowTextEntryEditBox:LoseFocus()
            end
        end
    end
end

function Messenger.LoadMessages(channelKey)
    if not Messenger.window then return end
    local buffer = Messenger.window:GetNamedChild('Messages')
    if not buffer then return end

    buffer:Clear()

    local messages = History.GetMessages(channelKey)
    for _, msg in ipairs(messages) do
        Messenger.RenderMessageToBuffer(buffer, msg)
    end

    buffer:SetScrollPosition(0)
end

function Messenger.RenderMessageToBuffer(buffer, msg)
    local timeTag = string.format('|c%s[%s]|r', Theme.Hex.MUTED, msg.time)

    if activeChannelKey == 'loot' or msg.author == '|cFFFF00Loot|r' then
        local lineText = msg.text
        if not lineText:find("|cFFFF00Loot:|r") and not lineText:find("Loot:") then
            local itemLink = lineText:match("(|H.-:item:.-|h.-|h)")
            if itemLink then
                local isSelf = msg.isSelf or (msg.author == "@Moi") or (msg.author == GetDisplayName())
                local looter = isSelf and GetDisplayName() or msg.author
                lineText = AetherChat.FormatLootLogLine(itemLink, 1, looter, isSelf)
            end
        end

        buffer:AddMessage(string.format('%s %s', timeTag, lineText))
        return
    end

    local myAccount = GetDisplayName()
    local authorName = msg.author
    local theme = Theme.GetCurrentTheme()
    local authorColor = Theme.Hex.OTHER_ZONE

    local isMe = msg.isSelf or (myAccount and authorName == myAccount) or authorName == "@Moi" or authorName == "You"

    if isMe then
        authorName = (myAccount and myAccount ~= '') and myAccount or '@Moi'
        authorColor = (theme and (theme.selfHex or theme.accentHex)) or '38BDF8'
    else
        if activeChannelKey:find('^guild') or (msg.channel and msg.channel:find('^guild')) then
            authorColor = Theme.Hex.OTHER_GUILD
        elseif activeChannelKey == 'party' or (msg.channel == 'party') then
            authorColor = Theme.Hex.OTHER_PARTY
        elseif msg.isWhisper or activeChannelKey:sub(1, 3) == 'dm:' then
            authorColor = Theme.Hex.OTHER_WHISPER
        else
            authorColor = Theme.Hex.OTHER_ZONE
        end
    end

    local linkedAuthor = authorName
    if authorName:sub(1, 1) == '@' then
        linkedAuthor = ZO_LinkHandler_CreateDisplayNameLink(authorName)
    else
        linkedAuthor = ZO_LinkHandler_CreateCharacterLink(authorName)
    end

    local authorTag = string.format('|c%s%s:|r', authorColor, linkedAuthor)
    local formattedText = FormatItemLinksInText(msg.text)

    buffer:AddMessage(string.format('%s %s %s', timeTag, authorTag, formattedText))
end

function Messenger.OnMessageReceived(channelKey, author, text, isSelf, isWhisper)
    if isWhisper and channelKey:sub(1, 3) == 'dm:' then
        local contact = channelKey:sub(4)
        Messenger.RegisterWhisperContact(contact)
    end

    local isCurrentlyViewing = (Messenger.window and not Messenger.window:IsHidden()) and (activeChannelKey == channelKey)

    if not isCurrentlyViewing and not isSelf then
        if isWhisper or channelKey:find('^guild') or channelKey == 'party' then
            unreadCounts[channelKey] = (unreadCounts[channelKey] or 0) + 1
            Messenger.UpdateTotalBadge()
        end
    end

    Messenger.RefreshChannelList()

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
            })
            buffer:SetScrollPosition(0)
        end
    end
end

function Messenger.UpdateTotalBadge()
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

    if Messenger.floatingIcon then
        local badge = Messenger.floatingIcon:GetNamedChild('_Badge')
        if badge then
            local count = badge:GetNamedChild('Count')
            if total > 0 then
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
