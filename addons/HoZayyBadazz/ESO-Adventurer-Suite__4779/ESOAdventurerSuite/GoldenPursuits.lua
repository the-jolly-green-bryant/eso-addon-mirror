-- ESO Adventurer Suite
-- Movable Golden Pursuits / Tamriel Tomes HUD tracker.

local EPC = ESOProgressionCoach
EPC.GoldenPursuits = EPC.GoldenPursuits or {}
local G = EPC.GoldenPursuits
local wm = WINDOW_MANAGER

local function getTrackerControl()
    if PROMOTIONAL_EVENT_TRACKER and PROMOTIONAL_EVENT_TRACKER.control then
        return PROMOTIONAL_EVENT_TRACKER.control
    end
    return ZO_PromotionalEventTracker_TL
end

function G:HasSavedPosition()
    return EPC.saved and tonumber(EPC.saved.goldenPursuitsLeft) and tonumber(EPC.saved.goldenPursuitsTop)
        and tonumber(EPC.saved.goldenPursuitsLeft) >= 0 and tonumber(EPC.saved.goldenPursuitsTop) >= 0
end

function G:ApplySavedPosition()
    local control = getTrackerControl()
    if not control or self.dragging or not self:HasSavedPosition() then return end
    local left = tonumber(EPC.saved.goldenPursuitsLeft)
    local top = tonumber(EPC.saved.goldenPursuitsTop)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function G:SavePosition()
    local control = getTrackerControl()
    if not control or not EPC.saved then return end
    local left = tonumber(control:GetLeft())
    local top = tonumber(control:GetTop())
    if left and top then
        EPC.saved.goldenPursuitsLeft = math.max(0, left)
        EPC.saved.goldenPursuitsTop = math.max(0, top)
    end
end

function G:ResetPosition()
    if not EPC.saved then return end
    EPC.saved.goldenPursuitsLeft = -1
    EPC.saved.goldenPursuitsTop = -1
    local control = getTrackerControl()
    if control and PROMOTIONAL_EVENT_TRACKER and PROMOTIONAL_EVENT_TRACKER.RefreshAnchors then
        pcall(PROMOTIONAL_EVENT_TRACKER.RefreshAnchors, PROMOTIONAL_EVENT_TRACKER)
    end
end

function G:BeginDrag(button)
    if not self.layoutMode then return end
    if MOUSE_BUTTON_INDEX_LEFT ~= nil and button ~= nil and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    local control = getTrackerControl()
    if not control or self.dragging then return end
    self.dragging = true
    if control.StartMoving then control:StartMoving() end
end

function G:EndDrag()
    local control = getTrackerControl()
    if not control then return end
    if control.StopMovingOrResizing then control:StopMovingOrResizing() end
    self.dragging = false
    self:SavePosition()
    self:ApplySavedPosition()
end

function G:CreateHandle()
    local control = getTrackerControl()
    if not control or self.handle then return control ~= nil end

    control:SetClampedToScreen(true)
    control:SetMovable(false)

    local handle = wm:CreateControl("EAS_GoldenPursuits_MoveHandle", control, CT_BACKDROP)
    handle:SetAnchorFill(control)
    handle:SetDrawLayer(DL_OVERLAY)
    handle:SetDrawLevel(1000)
    handle:SetMouseEnabled(false)
    handle:SetHidden(true)
    handle:SetCenterColor(0.08, 0.06, 0.02, 0.12)
    handle:SetEdgeTexture(nil, 1, 1, 2)
    handle:SetEdgeColor(0.92, 0.72, 0.25, 0.95)
    if handle.RegisterForDrag and MOUSE_BUTTON_INDEX_LEFT ~= nil then
        pcall(handle.RegisterForDrag, handle, MOUSE_BUTTON_INDEX_LEFT)
    end
    handle:SetHandler("OnMouseDown", function(_, button) self:BeginDrag(button) end)
    handle:SetHandler("OnDragStart", function(_, button) self:BeginDrag(button) end)
    handle:SetHandler("OnMouseUp", function() self:EndDrag() end)
    handle:SetHandler("OnDragStop", function() self:EndDrag() end)
    self.handle = handle
    return true
end

function G:SetLayoutMode(active)
    self.layoutMode = active == true
    local control = getTrackerControl()
    if not control then return end
    self:CreateHandle()
    control:SetMovable(self.layoutMode)
    control:SetMouseEnabled(self.layoutMode)
    if self.handle then
        self.handle:SetHidden(not self.layoutMode)
        self.handle:SetMouseEnabled(self.layoutMode)
    end
    if not self.layoutMode and self.dragging then self:EndDrag() end
    if not self.layoutMode then self:ApplySavedPosition() end
end

function G:Initialize()
    self.layoutMode = false
    self.dragging = false

    local function setup()
        if self:CreateHandle() then
            self:ApplySavedPosition()
            return true
        end
        return false
    end

    setup()

    if EVENT_MANAGER and EVENT_MANAGER.RegisterForEvent and EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(EPC.name .. "_GoldenPursuits", EVENT_PLAYER_ACTIVATED, function()
            setup()
            self:ApplySavedPosition()
        end)
    end

    -- ESO's tracker refreshes its native anchors whenever its content or platform
    -- style changes. Re-apply the user's saved position after those refreshes so
    -- Golden Pursuits/Tamriel Tomes stays exactly where the user placed it.
    if EVENT_MANAGER and EVENT_MANAGER.RegisterForUpdate then
        EVENT_MANAGER:RegisterForUpdate(EPC.name .. "_GoldenPursuitsAnchor", 250, function()
            if not self.dragging then
                setup()
                self:ApplySavedPosition()
            end
        end)
    end
end
