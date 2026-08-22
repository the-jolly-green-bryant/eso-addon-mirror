NQOL = NQOL or {}

local Chat = {}

local PREFIX_COLOR = "7fd7ff"
local function ToText(value)
    if value == nil then
        return ""
    end

    return tostring(value)
end

local function AddToGamepadHud(message)
    if not GAMEPAD_CHAT_SYSTEM
        or not GAMEPAD_CHAT_SYSTEM.primaryContainer
        or not GAMEPAD_CHAT_SYSTEM.primaryContainer.currentBuffer
        or not GAMEPAD_CHAT_SYSTEM.primaryContainer.AddMessageToWindow
    then
        return
    end

    local container = GAMEPAD_CHAT_SYSTEM.primaryContainer
    local window = container.currentBuffer:GetParent()
    if not window then
        return
    end

    local category = CHAT_CATEGORY_SYSTEM or 0
    if IsChatContainerTabCategoryEnabled and window.tab and window.tab.index and IsChatContainerTabCategoryEnabled(container.id, window.tab.index, category) then
        return
    end

    container:AddMessageToWindow(window, message, 1, 1, 1, category)

    if container.windowContainer and container.windowContainer.SetHidden then
        container.windowContainer:SetHidden(false)
    end

    if GAMEPAD_CHAT_SYSTEM.StartVisibilityTimer then
        GAMEPAD_CHAT_SYSTEM:StartVisibilityTimer()
    end
end

local function ApplyTimestampMode(message)
    if NQOL.Features and NQOL.Features.Chat and NQOL.Features.Chat.ApplyTimestampMode then
        return NQOL.Features.Chat.ApplyTimestampMode(message)
    end

    return message
end

function Chat.Format(message, featureName)
    local prefix = "|c" .. PREFIX_COLOR .. "NQOL|r"

    if featureName and featureName ~= "" then
        prefix = prefix .. " [" .. ToText(featureName) .. "]"
    end

    return prefix .. ": " .. ToText(message)
end

function Chat.FormatTag(featureName)
    local tag = "|c" .. PREFIX_COLOR .. "NQOL|r"

    if featureName and featureName ~= "" then
        tag = tag .. " [" .. ToText(featureName) .. "]"
    end

    return tag
end

function Chat.Message(message, featureName)
    local formattedMessage = Chat.Format(ToText(message), featureName)
    formattedMessage = ApplyTimestampMode(formattedMessage)

    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(formattedMessage)
        AddToGamepadHud(formattedMessage)
    elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(formattedMessage)
        AddToGamepadHud(formattedMessage)
    elseif d then
        d(formattedMessage)
    end
end

NQOL.Chat = Chat
