-- ============================================================================
-- AKsAttributeBars - Chat Customization Module
-- ============================================================================
-- Handles chat box positioning and resizing

local AKB = AKsAttributeBars

-- Create chat namespace
AKB.Chat = AKB.Chat or {}

-- Store original chat container properties
local originalChatProperties = {
    x = nil,
    y = nil,
    width = nil,
    height = nil,
    captured = false
}

-- Function to capture original chat container position and size
function AKB.Chat.CaptureOriginalProperties()
    if originalChatProperties.captured then
        return
    end
    
    local chatContainer = AKB.Chat.FindGamepadChatContainer()
    
    if chatContainer then
        local positionCaptured = false
        local sizeCaptured = false
        
        -- Try to get current position and size
        if chatContainer.GetLeft and chatContainer.GetTop then
            local x, y = chatContainer:GetLeft(), chatContainer:GetTop()
            if x and y then
                originalChatProperties.x = x
                originalChatProperties.y = y
                positionCaptured = true
            end
        end
        
        if chatContainer.GetWidth and chatContainer.GetHeight then
            local w, h = chatContainer:GetWidth(), chatContainer:GetHeight()
            if w and h then
                originalChatProperties.width = w
                originalChatProperties.height = h
                sizeCaptured = true
            end
        end
        
        -- Only mark as captured if we got at least some data
        if positionCaptured or sizeCaptured then
            originalChatProperties.captured = true
        end
    end
end

-- Find the gamepad chat container using multiple methods
function AKB.Chat.FindGamepadChatContainer()
    -- Try multiple possible gamepad chat container references
    local possibleContainers = {
        function() return ZO_GamepadChatSystem and ZO_GamepadChatSystem.control end,
        function() return ZO_GamepadChat end,
        function() return ZO_ChatContainer_Gamepad end,
        function() return ZO_GamepadChatContainer end,
        function() return GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.control end,
        function() return GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.container end,
        function() return CHAT_SYSTEM and CHAT_SYSTEM.gamepadContainer end,
        function() return CHAT_SYSTEM and CHAT_SYSTEM.containers and CHAT_SYSTEM.containers.gamepad end,
        function() return IsInGamepadPreferredMode and IsInGamepadPreferredMode() and CHAT_SYSTEM and CHAT_SYSTEM.control end
    }
    
    for _, getContainer in ipairs(possibleContainers) do
        local container = getContainer()
        if container then
            return container
        end
    end
    
    -- Try searching for gamepad chat window by name
    if WINDOW_MANAGER then
        local possibleNames = {
            "ZO_GamepadChatWindow",
            "ZO_ChatWindow_Gamepad", 
            "ZO_GamepadChat",
            "GamepadChatWindow",
            "ChatWindow_Gamepad"
        }
        
        for _, name in ipairs(possibleNames) do
            if _G[name] then
                return _G[name]
            end
        end
    end
    
    return nil
end

-- Function to apply chat box positioning and sizing
function AKB.Chat.ApplyChatBoxCustomization()
    local settings = AKB.Settings.GetAll()
    if not settings.enableChatBoxCustomization then
        return
    end
    
    -- Capture original properties first
    AKB.Chat.CaptureOriginalProperties()
    
    local chatContainer = AKB.Chat.FindGamepadChatContainer()
    if not chatContainer then
        return
    end
    
    -- Apply positioning if enabled
    if settings.chatBoxXPosition ~= 0 or settings.chatBoxYPosition ~= 0 then
        if chatContainer.ClearAnchors and chatContainer.SetAnchor then
            chatContainer:ClearAnchors()
            -- Ensure we have valid numbers for math operations
            local baseX = originalChatProperties.x or 50
            local baseY = originalChatProperties.y or 50
            local offsetX = settings.chatBoxXPosition or 0
            local offsetY = settings.chatBoxYPosition or 0
            
            local newX = baseX + offsetX
            local newY = baseY - offsetY  -- Inverted: positive moves UP
            chatContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, newX, newY)
        end
    end
    
    -- Apply sizing if enabled
    if settings.chatBoxWidth ~= 0 or settings.chatBoxHeight ~= 0 then
        if chatContainer.SetDimensions then
            -- Ensure we have valid numbers for math operations
            local baseWidth = originalChatProperties.width or 400
            local baseHeight = originalChatProperties.height or 200
            local widthOffset = settings.chatBoxWidth or 0
            local heightOffset = settings.chatBoxHeight or 0
            
            local newWidth = baseWidth + widthOffset
            local newHeight = baseHeight + heightOffset
            
            -- Ensure minimum sizes
            newWidth = math.max(newWidth, 200)
            newHeight = math.max(newHeight, 100)
            
            chatContainer:SetDimensions(newWidth, newHeight)
        end
    end
end

-- Function to reset chat box to original position and size
function AKB.Chat.ResetToOriginal()
    if not originalChatProperties.captured then
        AKB.Chat.CaptureOriginalProperties()
        if not originalChatProperties.captured then
            return
        end
    end
    
    local chatContainer = AKB.Chat.FindGamepadChatContainer()
    if not chatContainer then
        return
    end
    
    -- Reset position
    if chatContainer.ClearAnchors and chatContainer.SetAnchor then
        chatContainer:ClearAnchors()
        local resetX = originalChatProperties.x or 50
        local resetY = originalChatProperties.y or 50
        chatContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, resetX, resetY)
    end
    
    -- Reset size
    if chatContainer.SetDimensions then
        local resetWidth = originalChatProperties.width or 400
        local resetHeight = originalChatProperties.height or 200
        chatContainer:SetDimensions(resetWidth, resetHeight)
    end
end
