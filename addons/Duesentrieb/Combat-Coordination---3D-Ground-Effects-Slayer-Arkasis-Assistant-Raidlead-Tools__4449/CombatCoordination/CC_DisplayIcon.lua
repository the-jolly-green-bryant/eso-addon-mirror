local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayIcon",
    Parent = nil,
    Label = nil,
    Background = nil,
    Timeline = nil,
    ScaleUp = nil,
    ScaleDown = nil,
    isAnimationActive = false,
    currentTrigger = nil,

    Default = {
        offsetX = 200,
        offsetY = 200,
        animationMs = 250,
        width = 60,
        height = 60,
        borderThickness = 5,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CREATE UI ELEMENTS
----------------------------------------------------------------------------------------------------
function Module:Create()
    if self.Parent then return end

    self.Parent = WINDOW_MANAGER:CreateTopLevelWindow("CC_DisplayIcon_Parent")
    self.Parent:SetDimensions(self.SV.width, self.SV.height)
    self.Parent:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.Parent:SetClampedToScreen(true)
    self.Parent:SetMouseEnabled(true)
    self.Parent:SetMovable(false)
    self.Parent:SetDrawTier(DT_HIGH)
    self.Parent:SetDrawLayer(DL_OVERLAY)
    self.Parent:SetHidden(true)

    self.Background = WINDOW_MANAGER:CreateControl("CC_DisplayIcon_Background", self.Parent, CT_BACKDROP)
    self.Background:SetAnchorFill()
    self.Background:SetCenterColor(1, 0, 0, 1)
    self.Background:SetEdgeColor(0.5, 0, 0, 1)
    self.Background:SetEdgeTexture("", 1, 1, 2)

    self.Icon = WINDOW_MANAGER:CreateControl("CC_DisplayIcon_Icon", self.Parent, CT_TEXTURE)
    self.Icon:SetAnchor(CENTER, self.Parent, CENTER)
    local innerSize = math.max(1, self.SV.width - (self.SV.borderThickness * 2))
    self.Icon:SetDimensions(innerSize, innerSize)
    self.Icon:SetTexture("")

    self.Label = WINDOW_MANAGER:CreateControl("CC_DisplayIcon_Label", self.Parent, CT_LABEL)
    self.Label:SetAnchor(CENTER, self.Parent, CENTER, 0, 0)
    self.Label:SetFont("$(BOLD_FONT)|".. (self.SV.height * 0.75) .. "|thick-outline")
    self.Label:SetColor(1, 0, 0, 1)
    self.Label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.Label:SetText("X")
end

----------------------------------------------------------------------------------------------------
-- ENABLE MODULE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    if not self.Parent then self:Create() end
end

----------------------------------------------------------------------------------------------------
-- DISABLE MODULE
----------------------------------------------------------------------------------------------------
function Module:CustomDisable()
    if self.Parent then
        self.Parent:SetHidden(true)
    end
end

----------------------------------------------------------------------------------------------------
-- ANIMATION GROW
----------------------------------------------------------------------------------------------------
function Module:PlayAnimationGrow()
    if not self.Timeline then
        self.Timeline = ANIMATION_MANAGER:CreateTimeline()
        self.Animation = self.Timeline:InsertAnimation(ANIMATION_SCALE, self.Parent, 0)
    end

    if self.Timeline:IsPlaying() then self.Timeline:Stop() end

    self.Timeline:SetHandler('OnStop', nil)
    self.Parent:SetHidden(false)

    local durationGrow = self.SV.animationMs
    local currentScale = self.Parent:GetScale()

    self.Animation:SetScaleValues(currentScale, 1.0)
    self.Animation:SetDuration(durationGrow)
    self.Animation:SetEasingFunction(ZO_EaseOutQuadratic)
    self.Timeline:PlayFromStart()
end

----------------------------------------------------------------------------------------------------
-- ANIMATION SHRINK
----------------------------------------------------------------------------------------------------
function Module:PlayAnimationShrink()
    if not self.Timeline then return end
    if self.Timeline:IsPlaying() then self.Timeline:Stop() end

    local durationShrink = self.SV.animationMs
    local currentScale = self.Parent:GetScale()

    self.Animation:SetScaleValues(currentScale, 0.0)
    self.Animation:SetDuration(durationShrink)
    self.Animation:SetEasingFunction(ZO_EaseInQuadratic)

    self.Timeline:SetHandler('OnStop', function()
        if self.Parent:GetScale() < 0.1 then
            self.Parent:SetHidden(true)
        end
    end)
    self.Timeline:PlayFromStart()
end

----------------------------------------------------------------------------------------------------
-- TRIGGER ANIMATION
----------------------------------------------------------------------------------------------------
function Module:TriggerAnimation(abilityId, isUnregister)
    if not self.Parent then return end
    if not abilityId then return end

    if isUnregister then
        self.Background:SetCenterColor(0, 1, 0, 1)
        self.Background:SetEdgeColor(0, 0.5, 0, 1)
        self.Label:SetText("")
    else
        self.Background:SetCenterColor(1, 0, 0, 1)
        self.Background:SetEdgeColor(0.5, 0, 0, 1)
        self.Label:SetText("X")
    end

    self.Icon:SetTexture(GetAbilityIcon(abilityId))
    self:PlayAnimationGrow()

    self.currentTrigger = (self.currentTrigger or 0) + 1
    local trigger = self.currentTrigger

    zo_callLater(function()
        if self.currentTrigger == trigger then
            self:PlayAnimationShrink()
        end
    end, math.max(0, 1000 - self.SV.animationMs))
end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)