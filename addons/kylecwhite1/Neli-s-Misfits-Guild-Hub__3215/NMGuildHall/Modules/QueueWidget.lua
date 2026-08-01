-- Queue Widget Module
-- Lightweight on-screen widget showing current campaign queue status.
-- Behaves similarly to ChatIcon: movable when unlocked, position persisted in SavedVars.

local Addon = NMGuildHall

local QueueWidget = {
    initialized = false,
    window = nil,        -- TopLevelWindow
    icon = nil,          -- CT_TEXTURE
    iconGlow = nil,      -- CT_TEXTURE (subtle pulse behind icon)
    title = nil,         -- CT_LABEL
    campaign = nil,      -- CT_LABEL
    position = nil,      -- CT_LABEL
    dragButton = nil,    -- CT_BUTTON overlay
    locked = true,
    active = false,
}

local function GetDb()
    return Addon and Addon.db or nil
end

function QueueWidget:Initialize()
    if self.initialized then
        return
    end
    self.initialized = true
    if Addon and Addon.Message then
        Addon.Message:For("QueueWidget"):Debug(GetString(NMGH_DEBUG_QUEUE_WIDGET_INIT))
    end
end

local function DefaultAnchor(win)
    -- Top-right, a bit below the top bar.
    win:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -260, 140)
end

function QueueWidget:Create()
    local db = GetDb()
    local win = self.window or WINDOW_MANAGER:GetControlByName("NMGuildHall_QueueWidget")
    local icon = self.icon or WINDOW_MANAGER:GetControlByName("NMGuildHall_QueueWidget_Icon")
    local iconGlow = self.iconGlow or WINDOW_MANAGER:GetControlByName("NMGuildHall_QueueWidget_IconGlow")
    local title = self.title or WINDOW_MANAGER:GetControlByName("NMGuildHall_QueueWidget_Title")
    local campaign = self.campaign or WINDOW_MANAGER:GetControlByName("NMGuildHall_QueueWidget_Campaign")
    local position = self.position or WINDOW_MANAGER:GetControlByName("NMGuildHall_QueueWidget_Position")
    local drag = self.dragButton or WINDOW_MANAGER:GetControlByName("NMGuildHall_QueueWidget_Drag")

    if not win then
        win = WINDOW_MANAGER:CreateTopLevelWindow("NMGuildHall_QueueWidget")
    end
    if not win then
        return
    end

    -- Square-ish layout (icon -> queue -> campaign -> pos)
    win:SetDimensions(200, 220)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetHidden(true)

    if db and db.queueWidgetX and db.queueWidgetY then
        win:ClearAnchors()
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.queueWidgetX, db.queueWidgetY)
    elseif (not win.GetNumAnchors) or win:GetNumAnchors() == 0 then
        DefaultAnchor(win)
    end

    if not icon or not iconGlow or not title or not campaign or not position or not drag then
        local bg = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_BG", win, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetCenterColor(0.02, 0.02, 0.02, 0.90)
        bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 2, 2, 1, 1)
        bg:SetEdgeColor(0.8, 0.2, 0.3, 0.95)
        bg:SetInsets(2, 2, -2, -2)

        -- Slightly more "crafted" look: subtle texture + accent bar.
        local texture = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Texture", win, CT_TEXTURE)
        texture:SetAnchorFill()
        texture:SetTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
        texture:SetColor(0.08, 0.08, 0.08, 0.55)

        local accent = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Accent", win, CT_TEXTURE)
        accent:SetHeight(5)
        accent:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
        accent:SetAnchor(TOPRIGHT, win, TOPRIGHT, 0, 0)
        accent:SetTexture("EsoUI/Art/Performance/StatusMeter_BG.dds")
        accent:SetColor(0.8, 0.2, 0.3, 0.95)

        iconGlow = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_IconGlow", win, CT_TEXTURE)
        iconGlow:SetTexture("EsoUI/Art/Miscellaneous/gradient_radial.dds")
        iconGlow:SetDimensions(70, 70)
        iconGlow:SetAnchor(TOP, win, TOP, 0, 8)
        iconGlow:SetColor(0.85, 0.25, 0.35, 0.10)

        icon = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Icon", win, CT_TEXTURE)
        icon:SetTexture("EsoUI/Art/Campaign/campaignbrowser_queued.dds")
        icon:SetDimensions(34, 34)
        icon:SetAnchor(TOP, win, TOP, 0, 14)
        icon:SetColor(1, 1, 1, 0.95)

        local divider1 = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Divider1", win, CT_TEXTURE)
        divider1:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
        divider1:SetDimensions(170, 8)
        divider1:SetAnchor(TOP, icon, BOTTOM, 0, 8)
        divider1:SetColor(1, 1, 1, 0.18)

        title = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Title", win, CT_LABEL)
        title:SetFont("ZoFontWinH3")
        title:SetAnchor(TOP, divider1, BOTTOM, 0, -2)
        title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        title:SetColor(1, 1, 1, 0.95)
        title:SetText(GetString(NMGH_QUEUE_WIDGET_TITLE))

        campaign = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Campaign", win, CT_LABEL)
        campaign:SetFont("ZoFontGameBold")
        campaign:SetAnchor(TOP, title, BOTTOM, 0, 6)
        campaign:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        campaign:SetColor(0.92, 0.92, 0.92, 0.95)
        campaign:SetText(GetString(NMGH_QUEUE_WIDGET_CAMPAIGN_UNKNOWN))

        local divider2 = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Divider2", win, CT_TEXTURE)
        divider2:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
        divider2:SetDimensions(170, 8)
        divider2:SetAnchor(TOP, campaign, BOTTOM, 0, 8)
        divider2:SetColor(1, 1, 1, 0.18)

        local posPlate = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_PosPlate", win, CT_BACKDROP)
        posPlate:SetDimensions(170, 52)
        posPlate:SetAnchor(TOP, divider2, BOTTOM, 0, 10)
        posPlate:SetCenterColor(0.04, 0.04, 0.04, 0.80)
        posPlate:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 2, 2, 1, 1)
        posPlate:SetEdgeColor(0.35, 0.18, 0.20, 0.75)
        posPlate:SetInsets(2, 2, -2, -2)

        position = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Position", win, CT_LABEL)
        position:SetFont("ZoFontWinH2")
        position:SetAnchor(CENTER, posPlate, CENTER, 0, 0)
        position:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        position:SetColor(1, 1, 1, 0.98)
        position:SetText(GetString(NMGH_QUEUE_WIDGET_POS_UNKNOWN))

        drag = WINDOW_MANAGER:CreateControl("NMGuildHall_QueueWidget_Drag", win, CT_BUTTON)
        drag:SetAnchorFill()
        drag:SetMouseEnabled(true)
    end

    local Constants = Addon and Addon.Constants
    local dragThreshold = (Constants and Constants.CHAT_ICON and Constants.CHAT_ICON.DRAG_THRESHOLD) or 4
    local mouseDownX, mouseDownY

    drag:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control)
        local tooltipText = GetString(NMGH_QUEUE_WIDGET_TOOLTIP)
        local currentDb = GetDb()
        if currentDb and currentDb.queueWidgetLocked == false then
            tooltipText = tooltipText .. "\n|cAAAAAA(Drag to move)|r"
        end
        SetTooltipText(InformationTooltip, tooltipText)
    end)

    drag:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    drag:SetHandler("OnMouseDown", function(_, button)
        local currentDb = GetDb()
        if button == MOUSE_BUTTON_INDEX_LEFT then
            mouseDownX, mouseDownY = GetUIMousePosition()
            if currentDb and currentDb.queueWidgetLocked == false then
                win:StartMoving()
            end
        end
    end)

    drag:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and mouseDownX then
            local mx, my = GetUIMousePosition()
            local isClick = math.abs(mx - mouseDownX) < dragThreshold and math.abs(my - mouseDownY) < dragThreshold
            mouseDownX, mouseDownY = nil, nil
            if isClick and Addon and Addon.UI then
                local function OpenCampaignTab()
                    if not (Addon and Addon.UI) then
                        return
                    end
                    if not Addon.UI.isShowing and Addon.UI.Show then
                        pcall(Addon.UI.Show, Addon.UI)
                    end
                    if Addon.UI.ShowTab then
                        pcall(Addon.UI.ShowTab, Addon.UI, "campaign")
                    end
                end

                if Addon.UI.EnsureReady then
                    Addon.UI:EnsureReady(function(ready)
                        if ready then
                            OpenCampaignTab()
                        end
                    end)
                else
                    OpenCampaignTab()
                end
            end
        end
    end)

    win:SetHandler("OnMoveStop", function(control)
        local currentDb = GetDb()
        if not currentDb then return end
        local x, y = control:GetLeft(), control:GetTop()
        currentDb.queueWidgetX = x
        currentDb.queueWidgetY = y
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end)

    win:SetDrawTier(DT_HIGH)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawLevel(2)

    self.window = win
    self.icon = icon
    self.iconGlow = iconGlow
    self.title = title
    self.campaign = campaign
    self.position = position
    self.dragButton = drag

    -- Apply saved settings
    if db then
        if db.queueWidgetScale then
            self:SetScale(db.queueWidgetScale)
        end
        self:SetLocked(db.queueWidgetLocked ~= false)
    else
        self:SetLocked(true)
    end

    self:Refresh()
    self:_UpdatePulseState()

    if Addon and Addon.Message then
        Addon.Message:For("QueueWidget"):Debug(GetString(NMGH_DEBUG_QUEUE_WIDGET_CREATED))
    end
end

function QueueWidget:SetLocked(locked)
    self.locked = locked == true
    if self.window then
        self.window:SetMovable(not self.locked)
    end
end

function QueueWidget:SetScale(scale)
    local s = tonumber(scale) or 1.0
    if s < 0.6 then s = 0.6 end
    if s > 1.8 then s = 1.8 end
    if self.window then
        self.window:SetScale(s)
    end
end

function QueueWidget:ResetPosition()
    if not self.window then return end
    self.window:ClearAnchors()
    DefaultAnchor(self.window)
    local db = GetDb()
    if db then
        db.queueWidgetX = nil
        db.queueWidgetY = nil
    end
end

function QueueWidget:SetActive(active)
    self.active = active == true
    self:Refresh()
    self:_UpdatePulseState()
end

function QueueWidget:SetText(text)
    -- Deprecated: kept for compatibility with earlier iterations.
    -- Widget now uses structured labels (title/campaign/position).
    if self.title then
        self.title:SetText(text or "")
    end
end

function QueueWidget:RefreshFromCampaign(campaign)
    local db = GetDb()
    if not (db and db.queueWidgetEnabled ~= false) then
        self:SetActive(false)
        return
    end

    local campaignId = campaign and campaign.currentQueueCampaignId or nil
    local pos = campaign and campaign.currentQueuePosition or nil

    if not campaignId then
        self:SetActive(false)
        return
    end

    local name = GetCampaignName and GetCampaignName(campaignId) or ""
    if name and name ~= "" then
        local fmt = GetString(NMGH_QUEUE_WIDGET_CAMPAIGN)
        if Addon and Addon.Message and Addon.Message._FormatPlain then
            fmt = Addon.Message:_FormatPlain(fmt, {name = name})
        else
            fmt = string.gsub(fmt, "{name}", name)
        end
        if self.campaign then
            self.campaign:SetText(fmt)
        end
    elseif self.campaign then
        self.campaign:SetText(GetString(NMGH_QUEUE_WIDGET_CAMPAIGN_UNKNOWN))
    end

    if self.position then
        if pos and pos > 0 then
            local fmt = GetString(NMGH_QUEUE_WIDGET_POS)
            if Addon and Addon.Message and Addon.Message._FormatPlain then
                fmt = Addon.Message:_FormatPlain(fmt, {pos = pos})
            else
                fmt = string.gsub(fmt, "{pos}", tostring(pos))
            end
            self.position:SetText(fmt)
        else
            self.position:SetText(GetString(NMGH_QUEUE_WIDGET_POS_UNKNOWN))
        end
    end

    self:SetActive(true)
end

function QueueWidget:Refresh()
    if not self.window then
        return
    end
    local db = GetDb()
    local enabled = db and (db.queueWidgetEnabled ~= false)
    local shouldShow = enabled and self.active == true
    self.window:SetHidden(not shouldShow)
end

function QueueWidget:_UpdatePulseState()
    if not EVENT_MANAGER then
        return
    end

    local name = ((Addon and Addon.name) or "NMGuildHall") .. "_QueueWidgetPulse"
    local running = self._pulseRunning == true
    local shouldRun = self.window ~= nil and self.window:IsHidden() == false and self.iconGlow ~= nil

    if shouldRun and not running then
        self._pulseStart = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
        EVENT_MANAGER:RegisterForUpdate(name, 50, function()
            if not (self.window and self.iconGlow) then
                EVENT_MANAGER:UnregisterForUpdate(name)
                self._pulseRunning = false
                return
            end
            if self.window:IsHidden() then
                EVENT_MANAGER:UnregisterForUpdate(name)
                self._pulseRunning = false
                return
            end
            local t = (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0) - (self._pulseStart or 0)
            local a = 0.10 + (math.sin(t * 2.2) * 0.06) -- subtle pulse only
            if a < 0.05 then a = 0.05 end
            self.iconGlow:SetColor(0.85, 0.25, 0.35, a)
        end)
        self._pulseRunning = true
    elseif (not shouldRun) and running then
        EVENT_MANAGER:UnregisterForUpdate(name)
        self._pulseRunning = false
    end
end

function QueueWidget:Cleanup()
    if self.window then
        if InformationTooltip then
            ClearTooltip(InformationTooltip)
        end
        if EVENT_MANAGER then
            local name = ((Addon and Addon.name) or "NMGuildHall") .. "_QueueWidgetPulse"
            EVENT_MANAGER:UnregisterForUpdate(name)
        end
        if self.dragButton then
            self.dragButton:SetHandler("OnMouseEnter", nil)
            self.dragButton:SetHandler("OnMouseExit", nil)
            self.dragButton:SetHandler("OnMouseDown", nil)
            self.dragButton:SetHandler("OnMouseUp", nil)
        end
        self.window:SetHandler("OnMoveStop", nil)
        self.window:SetHidden(true)
    end

    self.window = nil
    self.icon = nil
    self.iconGlow = nil
    self.title = nil
    self.campaign = nil
    self.position = nil
    self.dragButton = nil
    self.active = false
    self._pulseRunning = false
    self.initialized = false
end

NMGuildHall = NMGuildHall or {}
NMGuildHall.QueueWidget = QueueWidget

return QueueWidget
