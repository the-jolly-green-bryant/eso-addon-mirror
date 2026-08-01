--------------------------------------------------
-- ShibUI Chat Window Module
--------------------------------------------------
local SUI = SUI
local sv

SUI.ChatWindow = SUI.ChatWindow or {}
local ChatWindow = SUI.ChatWindow

local Log = function(...) SUI.Debug:Log("Chat Window", ...) end

-- Chat Window Size Controls
function ChatWindow:SetSize()
    if sv and ZO_ChatWindow then
        ZO_ChatWindow:SetDimensions(sv.chatWidth, sv.chatHeight)
    end
end

-- Chat Window Position Controls
function ChatWindow:SetPosition()
    if sv and ZO_ChatWindow then
        ZO_ChatWindow:ClearAnchors()

        local horizAnchor = (sv.chatSide == "Left") and LEFT or RIGHT
        local vertAnchor = (sv.chatAnchor == "Top") and TOP or BOTTOM
        
        -- Always add padding to prevent chat from touching screen edges
        local xOffset = 0
        local yOffset = 0
        
        if sv.chatAnchor == "Bottom" then
            yOffset = -82  -- Bottom padding (matches ESO default to avoid UI overlap)
        elseif sv.chatAnchor == "Top" then
            yOffset = 50   -- Top padding for better visibility and header clearance
        end

        ZO_ChatWindow:SetAnchor(vertAnchor + horizAnchor, GuiRoot, vertAnchor + horizAnchor, xOffset, yOffset)
    end
end

-- Set default chat channel without opening chat input
local function SetDefaultChatChannel()
    if sv and sv.chatDefaultChannel and CHAT_ROUTER then
        -- Set the default channel without opening the chat input
        local chatSystem = ZO_GetChatSystem()
        if chatSystem then
            chatSystem:SetChannel(sv.chatDefaultChannel)
        end
    end
end

-- Prevent ESO from overriding our chat window settings
local function PreventChatSystemOverride()
    if ZO_ChatWindow and ZO_ChatWindow.container then
        local container = ZO_ChatWindow.container
        
        -- Hook into the SaveSettings function to prevent ESO from saving position/size
        if container.SaveSettings then
            local originalSaveSettings = container.SaveSettings
            container.SaveSettings = function(self)
                -- Call original but then immediately reapply our settings
                originalSaveSettings(self)
                zo_callLater(function()
                    ChatWindow:SetSize()
                    ChatWindow:SetPosition()
                end, 50)
            end
        end
        
        -- Hook into OnMoveStop to reapply position when user manually moves the window
        if container.OnMoveStop then
            local originalOnMoveStop = container.OnMoveStop
            container.OnMoveStop = function(self)
                originalOnMoveStop(self)
                zo_callLater(function()
                    ChatWindow:SetPosition()
                end, 50)
            end
        end
        
        -- Hook into OnResizeStop to reapply size when user manually resizes the window
        if container.OnResizeStop then
            local originalOnResizeStop = container.OnResizeStop
            container.OnResizeStop = function(self)
                originalOnResizeStop(self)
                zo_callLater(function()
                    ChatWindow:SetSize()
                end, 50)
            end
        end
    end
end

--------------------------------------------------
function ChatWindow:Initialize()
    sv = SUI.SavedVars.saved
    
    -- Register the event handler after sv is initialized
    -- Apply settings and set default channel once when player is activated
    local hasAppliedSettings = false
    local function OnPlayerActivated()
        if not hasAppliedSettings then
            -- Wait a brief moment for the chat system to fully initialize
            zo_callLater(function()
                -- Apply chat window settings
                self:SetSize()
                self:SetPosition()
                
                -- Set default chat channel
                SetDefaultChatChannel()
                
                -- Prevent ESO's chat system from overriding our settings
                PreventChatSystemOverride()
                
                Log("Chat window settings applied")
            end, 100)
            
            hasAppliedSettings = true
        end
    end
    
    EVENT_MANAGER:RegisterForEvent("ShibUI_ChatWindow", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    
    Log("Initialized")
end