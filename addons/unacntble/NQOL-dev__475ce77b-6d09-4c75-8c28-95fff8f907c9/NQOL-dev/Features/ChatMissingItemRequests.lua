NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local ChatMissingItemRequests = {}

local CHAT_LINK_PATTERN = "|H.-|h.-|h"
local KEYBIND_MARKER = "nqolMissingItemRequest"
local hookInstalled = false
local hookAttempts = 0
local initialized = false

local function GetRequestableItemLink(chatFeature, value)
    if type(value) ~= "string" then
        return nil
    end

    local itemLink = string.match(value, CHAT_LINK_PATTERN)
    if itemLink
        and GetLinkType
        and GetLinkType(itemLink) == LINK_TYPE_ITEM
        and chatFeature.IsMissingItemLink(itemLink)
    then
        return itemLink
    end

    return nil
end

local function GetSelectedMessageText(targetData)
    if targetData and targetData.GetText then
        local text = targetData:GetText()
        if type(text) == "string" and text ~= "" then
            return text
        end
    end

    return targetData and targetData.text
end

local function DecorateRecipient(displayName)
    if type(displayName) ~= "string" or displayName == "" then
        return nil
    end

    if DecorateDisplayName and (not IsDecoratedDisplayName or not IsDecoratedDisplayName(displayName)) then
        return DecorateDisplayName(displayName)
    end

    return displayName
end

local function FindRecipientInMessage(message)
    if type(message) ~= "string" or message == "" then
        return nil
    end

    if GetLinkType and DISPLAY_NAME_LINK_TYPE and ZO_LinkHandler_ParseLinkData then
        for link in string.gmatch(message, CHAT_LINK_PATTERN) do
            if GetLinkType(link) == DISPLAY_NAME_LINK_TYPE then
                return DecorateRecipient(ZO_LinkHandler_ParseLinkData(link))
            end
        end
    end

    return DecorateRecipient(string.match(message, "%[@([^%]]+)%]"))
end

local function FindRequestableItemLink(chatFeature, message)
    for link in string.gmatch(message or "", CHAT_LINK_PATTERN) do
        local itemLink = GetRequestableItemLink(chatFeature, link)
        if itemLink then
            return itemLink
        end
    end

    return nil
end

local function GetRequestData(chatMenu)
    local chatFeature = NQOL.Features and NQOL.Features.Chat
    if not chatFeature
        or not chatFeature.GetAnnotateMissingItemsEnabled
        or not chatFeature.GetAnnotateMissingItemsEnabled()
        or not chatFeature.IsMissingItemLink
        or not chatMenu
        or not chatMenu.list
        or not chatMenu.list.GetTargetData
    then
        return nil
    end

    local targetData = chatMenu.list:GetTargetData()
    local entryData = targetData and targetData.data
    if not entryData then
        return nil
    end

    local messageText = GetSelectedMessageText(targetData)
    local recipient = DecorateRecipient(entryData.fromDisplayName) or FindRecipientInMessage(messageText)
    if not recipient then
        return nil
    end

    if chatFeature.IsOwnChatMessage and chatFeature.IsOwnChatMessage("", recipient) then
        return nil
    end

    if IsCommunicationRestricted and IsCommunicationRestricted() then
        if not CanCommunicateWith or not CanCommunicateWith(recipient) then
            return nil
        end
    end

    local itemLink
    local activeLinks = chatMenu.activeLinks
    if activeLinks and activeLinks.GetCurrentLink then
        local currentLinkData = activeLinks:GetCurrentLink()
        local currentLink = currentLinkData and currentLinkData.link
        local requestableItemLink = GetRequestableItemLink(chatFeature, currentLink)
        if requestableItemLink then
            itemLink = requestableItemLink
        end
    end

    if not itemLink then
        for _, linkData in ipairs(entryData.links or {}) do
            local link = type(linkData) == "table" and linkData.link or linkData
            local requestableItemLink = GetRequestableItemLink(chatFeature, link)
            if requestableItemLink then
                itemLink = requestableItemLink
                break
            end
        end
    end

    itemLink = itemLink
        or FindRequestableItemLink(chatFeature, entryData.rawMessageText)
        or FindRequestableItemLink(chatFeature, messageText)

    if not itemLink then
        return nil
    end

    return itemLink, recipient
end

local function InsertRequestText(textEdit, requestTemplate, itemLink)
    local formattedItemLink = itemLink
    if zo_strformat and SI_TOOLTIP_ITEM_NAME then
        formattedItemLink = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink)
    end

    textEdit:SetText("")

    local startIndex = 1
    while true do
        local markerIndex = string.find(requestTemplate, "$", startIndex, true)
        if not markerIndex then
            textEdit:InsertText(string.sub(requestTemplate, startIndex))
            return
        end

        textEdit:InsertText(string.sub(requestTemplate, startIndex, markerIndex - 1))
        textEdit:InsertText(formattedItemLink)
        startIndex = markerIndex + 1
    end
end

local function PrepareRequest(chatMenu)
    local itemLink, recipient = GetRequestData(chatMenu)
    if not itemLink then
        return
    end

    if not GAMEPAD_CHAT_SYSTEM
        or not GAMEPAD_CHAT_SYSTEM.SetChannel
        or not CHAT_CHANNEL_WHISPER
        or not chatMenu.textEdit
        or not chatMenu.textEdit.SetText
        or not chatMenu.textEdit.InsertText
        or not chatMenu.FocusTextInput
    then
        return
    end

    GAMEPAD_CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_WHISPER, recipient)
    local chatFeature = NQOL.Features and NQOL.Features.Chat
    local requestTemplate = chatFeature.GetAnnotateMissingItemsWhisperMessage
        and chatFeature.GetAnnotateMissingItemsWhisperMessage()
        or nil
    if type(requestTemplate) ~= "string" or requestTemplate == "" then
        requestTemplate = chatFeature.GetAnnotateMissingItemsWhisperMessageDefault()
    end

    InsertRequestText(chatMenu.textEdit, requestTemplate, itemLink)
    -- Console keyboards display ESO link markup as plain text, so leave the
    -- composed request in the in-game input where the link stays formatted.
    chatMenu:FocusTextInput()
end

local function AddChatMenuKeybind(chatMenu)
    local descriptor = chatMenu and chatMenu.chatEntryListKeybindDescriptor
    if type(descriptor) ~= "table" then
        return
    end

    for _, keybindDescriptor in ipairs(descriptor) do
        if keybindDescriptor[KEYBIND_MARKER] then
            return
        end
    end

    table.insert(descriptor, {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        keybind = "UI_SHORTCUT_LEFT_STICK",
        name = NQOL.L("features.chat.request_missing_item_keybind"),
        callback = function()
            PrepareRequest(chatMenu)
        end,
        visible = function()
            return GetRequestData(chatMenu) ~= nil
        end,
        [KEYBIND_MARKER] = true,
    })

    if chatMenu.chatEntryPanelFocalArea and chatMenu.chatEntryPanelFocalArea.SetKeybindDescriptor then
        chatMenu.chatEntryPanelFocalArea:SetKeybindDescriptor(descriptor)
    end
end

local function InstallChatMenuKeybindHook()
    if hookInstalled then
        return
    end

    if not ZO_ChatMenu_Gamepad
        or type(ZO_ChatMenu_Gamepad.InitializeFocusKeybinds) ~= "function"
        or type(SecurePostHook) ~= "function"
    then
        hookAttempts = hookAttempts + 1
        if hookAttempts < 10 and zo_callLater then
            zo_callLater(InstallChatMenuKeybindHook, 1000)
        end

        AddChatMenuKeybind(CHAT_MENU_GAMEPAD)
        return
    end

    SecurePostHook(ZO_ChatMenu_Gamepad, "InitializeFocusKeybinds", function(self)
        AddChatMenuKeybind(self)
    end)

    hookInstalled = true
    hookAttempts = 0
    AddChatMenuKeybind(CHAT_MENU_GAMEPAD)
end

function ChatMissingItemRequests.Initialize()
    if initialized then
        return
    end

    initialized = true
    InstallChatMenuKeybindHook()
end

NQOL.Features.ChatMissingItemRequests = ChatMissingItemRequests
