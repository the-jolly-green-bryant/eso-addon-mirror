local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayIcon",
    Parent = nil,
    Label = nil,
    Background = nil,

    TimelineScale = nil,
    AnimScale = nil,

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
-- CREATE
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
-- CUSTOM ENABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    if not self.Parent then self:Create() end
end

----------------------------------------------------------------------------------------------------
-- CUSTOM DISABLE
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
    if not self.TimelineScale then
        self.TimelineScale = ANIMATION_MANAGER:CreateTimeline()
        self.AnimScale = self.TimelineScale:InsertAnimation(ANIMATION_SCALE, self.Parent, 0)
    end

    if self.TimelineScale:IsPlaying() then self.TimelineScale:Stop() end

    self.TimelineScale:SetHandler('OnStop', nil)
    self.Parent:SetHidden(false)

    local durationGrow = self.SV.animationMs
    local currentScale = self.Parent:GetScale()

    self.AnimScale:SetScaleValues(currentScale, 1.0)
    self.AnimScale:SetDuration(durationGrow)
    self.AnimScale:SetEasingFunction(ZO_EaseOutQuadratic)
    self.TimelineScale:PlayFromStart()
end

----------------------------------------------------------------------------------------------------
-- ANIMATION SHRINK
----------------------------------------------------------------------------------------------------
function Module:PlayAnimationShrink()
    if not self.TimelineScale then return end
    if self.TimelineScale:IsPlaying() then self.TimelineScale:Stop() end

    local durationShrink = self.SV.animationMs
    local currentScale = self.Parent:GetScale()

    self.AnimScale:SetScaleValues(currentScale, 0.0)
    self.AnimScale:SetDuration(durationShrink)
    self.AnimScale:SetEasingFunction(ZO_EaseInQuadratic)

    self.TimelineScale:SetHandler('OnStop', function()
        if self.Parent:GetScale() < 0.1 then
            self.Parent:SetHidden(true)
        end
    end)
    self.TimelineScale:PlayFromStart()
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