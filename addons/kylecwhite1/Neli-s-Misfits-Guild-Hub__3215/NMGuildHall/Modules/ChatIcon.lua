-- Chat Icon Module
-- Handles the chat window icon for opening the NMGuildHall UI
-- Dependencies: UI module (for Toggle functionality)

local ChatIcon = {
    initialized = false,
    window = nil,   -- the TopLevelWindow (used for movement/positioning)
    button = nil -- the CT_BUTTON child (used for visuals and mouse events)
}

-- Initialize the chat icon module
function ChatIcon:Initialize()
    if self.initialized then
        return
    end
    self.initialized = true
    if NMGuildHall and NMGuildHall.Message then
        NMGuildHall.Message:For("ChatIcon"):Debug(GetString(NMGH_DEBUG_CHATICON_INIT))
    end
end

-- Create and initialize the chat icon
function ChatIcon:Create()
    -- Parent to GuiRoot via TopLevelWindow so the icon is never hidden
    -- when ZO_ChatWindow collapses. ZO_ChatWindow is used as an anchor
    -- reference only.
    local win = self.window or WINDOW_MANAGER:GetControlByName("NMGuildHall1")
    local btn = self.button or WINDOW_MANAGER:GetControlByName("NMGuildHall1_Btn")
    local defaultSize = (NMGuildHall and NMGuildHall.Constants and NMGuildHall.Constants.CHAT_ICON and NMGuildHall.Constants.CHAT_ICON.DEFAULT_SIZE) or 36

    if not win then
        win = WINDOW_MANAGER:CreateTopLevelWindow("NMGuildHall1")
    end
    if not win then
        return
    end

    win:SetDimensions(defaultSize, defaultSize)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)  -- window must accept mouse for dragging

    -- Restore saved position, or default to top-right of the chat window
    if NMGuildHall and NMGuildHall.db and NMGuildHall.db.chatIconX and NMGuildHall.db.chatIconY then
        win:ClearAnchors()
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NMGuildHall.db.chatIconX, NMGuildHall.db.chatIconY)
    elseif (not win.GetNumAnchors) or win:GetNumAnchors() == 0 then
        win:ClearAnchors()
        win:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -60, 9)
    end

    -- CT_BUTTON handles all visual states (normal / hover / pressed).
    -- It MUST have mouse enabled so ESO drives its hover/pressed textures.
    -- We still route drag logic through the parent window.
    if not btn then
        btn = WINDOW_MANAGER:CreateControl("NMGuildHall1_Btn", win, CT_BUTTON)
    end
    if not btn then
        return
    end
    btn:SetAnchorFill()
    btn:SetMouseEnabled(true)

    -- Tooltip on the button
    btn:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control)
        local tooltipText = GetString(NMGH_GUILD_HUB)
        if NMGuildHall.db and not NMGuildHall.db.chatIconLocked then
            tooltipText = tooltipText .. "\n|cAAAAAA(Drag to move)|r"
        end
        SetTooltipText(InformationTooltip, tooltipText)
    end)

    btn:SetHandler("OnMouseExit", function(_)
        ClearTooltip(InformationTooltip)
    end)

    -- Click vs drag: track mouse position on down; only fire Toggle if the
    -- mouse didn't move more than the drag threshold before releasing.
    local Constants = NMGuildHall and NMGuildHall.Constants
    local dragThreshold = (Constants and Constants.CHAT_ICON and Constants.CHAT_ICON.DRAG_THRESHOLD) or 4
    local mouseDownX, mouseDownY

    btn:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            mouseDownX, mouseDownY = GetUIMousePosition()
            if not self.locked then
                -- Start dragging the parent window from the button only when unlocked.
                win:StartMoving()
            end
        end
    end)

    btn:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and mouseDownX then
            local mx, my = GetUIMousePosition()
            if math.abs(mx - mouseDownX) < dragThreshold and
               math.abs(my - mouseDownY) < dragThreshold then
                if NMGuildHall.UI and NMGuildHall.UI.EnsureReady then
                    NMGuildHall.UI:EnsureReady(function(ready)
                        if ready and NMGuildHall.UI and NMGuildHall.UI.Toggle then
                            NMGuildHall.UI:Toggle()
                        end
                    end)
                elseif NMGuildHall.UI and NMGuildHall.UI.Toggle then
                    NMGuildHall.UI:Toggle()
                end
            end
            mouseDownX, mouseDownY = nil, nil
        end
    end)

    -- Save absolute position after drag and re-anchor to GuiRoot so it
    -- persists correctly across sessions.
    win:SetHandler("OnMoveStop", function(control)
        if NMGuildHall and NMGuildHall.db then
            local x, y = control:GetLeft(), control:GetTop()
            NMGuildHall.db.chatIconX = x
            NMGuildHall.db.chatIconY = y
            control:ClearAnchors()
            control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        end
    end)

    -- Render above the chat window
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawLevel(1)

    -- Hide when chat window closes, but only if using the default position.
    -- If the user has dragged it somewhere custom, leave it visible always.
    local function OnChatVisibilityChanged()
        if not NMGuildHall or not NMGuildHall.db then return end
        local hasCustomPos = NMGuildHall.db.chatIconX and NMGuildHall.db.chatIconY
        local shouldShow = NMGuildHall.db.showChatIcon ~= false
        local chatHidden = false
        if ZO_ChatWindow and type(ZO_ChatWindow.IsHidden) == "function" then
            chatHidden = ZO_ChatWindow:IsHidden()
        end
        if hasCustomPos then
            -- Custom position: always visible (user chose to put it there)
            win:SetHidden(not shouldShow)
        else
            -- Default position: follow the chat window's visibility
            win:SetHidden(not shouldShow or chatHidden)
        end
    end

    -- Hook CHAT_SYSTEM's Minimize/Maximize functions directly.
    -- These fire BEFORE the slide animation begins, so the icon hides
    -- immediately rather than riding along with the chat window.
    if not self._chatVisibilityHooksInstalled then
        local canHookChat =
            ZO_PreHook and
            CHAT_SYSTEM and
            type(CHAT_SYSTEM.Minimize) == "function" and
            type(CHAT_SYSTEM.Maximize) == "function"

        if canHookChat then
            ZO_PreHook(CHAT_SYSTEM, "Minimize", function()
                if not (NMGuildHall and NMGuildHall.db and self.window) then return end
                local hasCustomPos = NMGuildHall.db.chatIconX and NMGuildHall.db.chatIconY
                if not hasCustomPos then
                    self.window:SetHidden(true)
                end
            end)
            ZO_PreHook(CHAT_SYSTEM, "Maximize", function()
                if not (NMGuildHall and NMGuildHall.db and self.window) then return end
                if NMGuildHall.db.showChatIcon ~= false then
                    self.window:SetHidden(false)
                end
            end)
            self._chatVisibilityHooksInstalled = true
        end
    end
    self.onChatVisibilityChanged = OnChatVisibilityChanged

    self.window = win
    self.button = btn

    -- Apply saved settings
    if NMGuildHall and NMGuildHall.db then
        self:SetTexture(NMGuildHall.db.monochromeIcon or false)
        self:SetVisible(NMGuildHall.db.showChatIcon ~= false)
        if NMGuildHall.db.chatIconSize then
            self:SetSize(NMGuildHall.db.chatIconSize)
        end
        self:SetLocked(NMGuildHall.db.chatIconLocked or false)
    end

    if NMGuildHall and NMGuildHall.Message then
        NMGuildHall.Message:For("ChatIcon"):Debug(GetString(NMGH_DEBUG_CHATICON_CREATED))
    end
end

-- Set chat icon locked state
function ChatIcon:SetLocked(locked)
    if not self.window then return end
    self.window:SetMovable(not locked)
    self.locked = locked
end

-- Reset chat icon position back to default (top-right of chat window)
function ChatIcon:ResetPosition()
    if not self.window then return end
    self.window:ClearAnchors()
    self.window:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -60, 9)
    if NMGuildHall and NMGuildHall.db then
        NMGuildHall.db.chatIconX = nil
        NMGuildHall.db.chatIconY = nil
    end
end

-- Show or hide the chat icon
function ChatIcon:SetVisible(show)
    if not self.window then return end
    if self.onChatVisibilityChanged then
        self.onChatVisibilityChanged()
    else
        local shouldShow = show and (NMGuildHall.db.showChatIcon ~= false)
        self.window:SetHidden(not shouldShow)
    end
end

-- Set chat icon texture (normal or monochrome), respects icon style setting
function ChatIcon:SetTexture(monochrome)
    if not self.button then return end

    local style = (NMGuildHall and NMGuildHall.db and NMGuildHall.db.chatIconStyle) or "new"
    local sets  = NMGuildHall and NMGuildHall.Constants
                  and NMGuildHall.Constants.CHAT_ICON
                  and NMGuildHall.Constants.CHAT_ICON.SETS
    local textures = (sets and sets[style]) or {
        NORMAL         = "NMGuildHall/Icons/new/misfit_logo.dds",
        NORMAL_PRESSED = "NMGuildHall/Icons/new/misfit_logo_pressed.dds",
        NORMAL_OVER    = "NMGuildHall/Icons/new/misfit_logo_hover.dds",
        MONO           = "NMGuildHall/Icons/new/mono_misfit_logo.dds",
        MONO_PRESSED   = "NMGuildHall/Icons/new/mono_misfit_logo_pressed.dds",
        MONO_OVER      = "NMGuildHall/Icons/new/mono_misfit_logo_hover.dds",
    }

    self.button:SetNormalTexture(monochrome   and textures.MONO         or textures.NORMAL)
    self.button:SetPressedTexture(monochrome  and textures.MONO_PRESSED or textures.NORMAL_PRESSED)
    self.button:SetMouseOverTexture(monochrome and textures.MONO_OVER   or textures.NORMAL_OVER)
end

-- Set chat icon size
function ChatIcon:SetSize(size)
    if not self.window then return end
    self.window:SetDimensions(size, size)
end

-- Cleanup function for chat icon
function ChatIcon:Cleanup()
    if self.window then
        if InformationTooltip then
            ClearTooltip(InformationTooltip)
        end
        if self.button then
            self.button:SetHandler("OnMouseDown", nil)
            self.button:SetHandler("OnMouseUp", nil)
            self.button:SetHandler("OnMouseEnter", nil)
            self.button:SetHandler("OnMouseExit", nil)
        end
        self.window:SetHandler("OnMoveStop", nil)
        self.window:SetHidden(true)
        self.window    = nil
        self.button = nil
        self.onChatVisibilityChanged = nil
    end
    self.locked = nil
    self.initialized = false
    if NMGuildHall and NMGuildHall.Message then
        NMGuildHall.Message:For("ChatIcon"):Debug(GetString(NMGH_DEBUG_CLEANUP_DONE))
    end
end

-- Export chat icon module
NMGuildHall = NMGuildHall or {}
NMGuildHall.ChatIcon = ChatIcon

return ChatIcon
