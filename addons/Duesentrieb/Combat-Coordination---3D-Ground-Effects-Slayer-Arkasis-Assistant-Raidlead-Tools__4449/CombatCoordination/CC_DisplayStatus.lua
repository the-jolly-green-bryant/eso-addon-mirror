local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayStatus",
    Parent = nil,
    Label = nil,
    Icon = nil,
    Background = nil,
    Timeline = nil,
    ScaleUp = nil,
    ScaleDown = nil,
    isAnimationActive = false,

    Default = {
        offsetX = nil,
        offsetY = nil,
        width = 30,
        height = 30,

        animationMs = 500,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CREATE UI ELEMENTS
----------------------------------------------------------------------------------------------------
function Module:Create()
    if self.Parent then return end

    if not self.SV.offsetX or not self.SV.offsetY then
        self.SV.offsetX = (GuiRoot:GetWidth() - self.SV.width) / 2
        self.SV.offsetY = (GuiRoot:GetHeight() - self.SV.height) / 2
    end

    local function HandleMouseUp(control, button, upInside, ctrl, alt, shift, command)
        if button == MOUSE_BUTTON_INDEX_LEFT and upInside then

            local deltaX = math.abs(self.SV.offsetX - self.Parent:GetLeft())
            local deltaY = math.abs(self.SV.offsetY - self.Parent:GetTop())

            if math.max(deltaX, deltaY) <= 1 then
                self:PlayAnimation(1.5)

                local isOpening = not CC.DisplayPanel.SV.isVisible

                if not CC.DisplayPanel.SV.isVisible then
                    CC.DisplayPanel:Toggle()
                end
                -- if isOpening then
                --     CC.Broadcast:SendPingRequest(true)
                -- end
            end
        end
    end

    self.Parent = WINDOW_MANAGER:CreateTopLevelWindow("CC_DisplayStatus_Parent")
    self.Parent:SetDimensions(self.SV.width, self.SV.height)
    self.Parent:SetScale(CC.DisplayPanel.SV.panelScale)
    self.Parent:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.offsetX or 0, self.SV.offsetY or 0)
    self.Parent:SetClampedToScreen(true)
    self.Parent:SetMouseEnabled(true)
    self.Parent:SetMovable(true)
    self.Parent:SetHidden(false)
    self.Parent:SetDrawTier(DT_HIGH)
    self.Parent:SetHandler("OnMoveStop", function() self:OnMoveStop() end)
    self.Parent:SetHandler("OnMouseUp", HandleMouseUp)

    self.Label = WINDOW_MANAGER:CreateControl("CC_DisplayStatus_Label", self.Parent, CT_LABEL)
    self.Label:SetAnchor(CENTER, self.Parent, CENTER, 0, 0)
    self.Label:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
    self.Label:SetColor(1, 1, 0, 1)
    self.Label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.Label:SetText("CC")

    self.Background = WINDOW_MANAGER:CreateControl("CC_DisplayStatus_Background", self.Parent, CT_BACKDROP)
    self.Background:SetAnchorFill()
    self.Background:SetPixelRoundingEnabled(true)
    self.Background:SetCenterColor(0, 0, 0, 0.75)
    self.Background:SetEdgeColor(0.5, 0.5, 0, 1)
    self.Background:SetEdgeTexture("", 1, 1, 2)

    -- THX ExoY FOR TEACHING ME THIS
    local Fragment = ZO_HUDFadeSceneFragment:New(self.Parent)
    HUD_SCENE:AddFragment(Fragment)
    HUD_UI_SCENE:AddFragment(Fragment)
end

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    if not self.Parent then
        self:Create()
    end
    if self.Parent then
        self.Parent:SetHidden(false)
    end
end

function Module:CustomDisable()
    if self.Parent then
        self.Parent:SetHidden(true)
    end
end

----------------------------------------------------------------------------------------------------
-- ON MOVE STOP
----------------------------------------------------------------------------------------------------
function Module:OnMoveStop()
    zo_callLater(function()
        if not self.Parent then return end
        self.SV.offsetX = self.Parent:GetLeft()
        self.SV.offsetY = self.Parent:GetTop()

        self.Parent:ClearAnchors()
        self.Parent:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.offsetX, self.SV.offsetY)
    end, 100)
end

----------------------------------------------------------------------------------------------------
-- ANIMATION
----------------------------------------------------------------------------------------------------
function Module:PlayAnimation(endScale)
    if not self.Parent then return end

    local animationMs = self.SV.animationMs
    local durationGrow =  math.floor(animationMs / 3)
    local durationShrink = animationMs - durationGrow
    endScale = math.max(1, endScale or 1.5)

    -- CREATE TIMELINE AND ANIMATION IF NOT YET CREATE
    if not self.Timeline then
        self.Timeline = ANIMATION_MANAGER:CreateTimeline()

        self.ScaleUp = self.Timeline:InsertAnimation(ANIMATION_SCALE, self.Label, 0)
        self.ScaleUp:SetEasingFunction(ZO_LinearEase) -- ZO_EaseInQuadratic)

        self.ScaleDown = self.Timeline:InsertAnimation(ANIMATION_SCALE, self.Label, 0)
        self.ScaleDown:SetEasingFunction(ZO_LinearEase) -- ZO_EaseOutQuadratic)

        -- RESET ON STOP
        self.Timeline:SetHandler('OnStop', function()
            self.Label:SetScale(1.0)
        end)
    end

    if self.Timeline:IsPlaying() then
        self.Timeline:Stop()
    end

    -- SET NEW VALS
    self.ScaleUp:SetScaleValues(1.0, endScale)
    self.ScaleUp:SetDuration(durationGrow)

    self.ScaleDown:SetScaleValues(endScale, 1.0)
    self.ScaleDown:SetDuration(durationShrink)
    self.Timeline:SetAnimationOffset(self.ScaleDown, durationGrow)

    self.Timeline:PlayFromStart()
end

----------------------------------------------------------------------------------------------------
-- UPDATE UI
----------------------------------------------------------------------------------------------------
function Module:Update()
    if not self.Parent then return end

    local count = 0
    local hasPlayer = false
    local playerName = GetUnitDisplayName("player")

    for displayName, _ in pairs(CC.UserData or {}) do -- DESYNC NIL ERROR ON USERDATA.. THANKS ZOS. THAT SHOULD NOT BE POSSIBLE BUT WELL.. IT WAS.
        if displayName == playerName then hasPlayer = true end
        count = count + 1
    end
    if not hasPlayer then count = count + 1 end

    local expectedSize = math.max(1, GetGroupSize())
    if count >= expectedSize then
        self.Label:SetColor(0, 1, 0, 1)
        self.Background:SetEdgeColor(0, 0.5, 0, 1)
    else
        self.Label:SetColor(1, 1, 0, 1)
        self.Background:SetEdgeColor(0.5, 0.5, 0, 1)
    end

    self.Label:SetText(tostring(count))
end

----------------------------------------------------------------------------------------------------
-- RESET POSITION
----------------------------------------------------------------------------------------------------
function Module:ResetPosition()
    self.SV.offsetX = (GuiRoot:GetWidth() - self.SV.width) / 2
    self.SV.offsetY = (GuiRoot:GetHeight() - self.SV.height) / 2

    if self.Parent then
        self.Parent:ClearAnchors()
        self.Parent:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.offsetX, self.SV.offsetY)
    end
end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)