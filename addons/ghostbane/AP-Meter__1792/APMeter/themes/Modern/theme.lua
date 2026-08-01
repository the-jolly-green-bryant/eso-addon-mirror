local APM = APMeter
local Theme = ZO_Object:Subclass()

Theme.name = 'Modern'
Theme.template = 'APMeter_Theme_Modern'
Theme.containerWidth = 248
Theme.containerHeight = 112

local GO_Mode = false

local function SetRankIcon(self, rank)

    if not rank then
        rank = GetUnitAvARank('player')
    end

    self.ctx_RankIcon:SetTexture(GetAvARankIcon(rank):gsub('%rankicon', 'rankicon64'))

    if rank >= 47 then
        self.ctx_RankIcon:SetDimensions(40, 40)
    else
        self.ctx_RankIcon:SetDimensions(46, 46)
    end

    if rank == 50 then
        GO_Mode = true
        self.ctx_Perc:SetHidden(true)
        self.ctx_RankIcon:ClearAnchors()
        self.ctx_RankIcon:SetAnchor(CENTER, self.ctx_Gauge, CENTER, 0, -2)
    end
end

function Theme:New(...)
    local theme = ZO_Object.New(self)
    theme:Initialize(...)
    return theme
end

function Theme:Initialize( container, containerLabel, previewMode )

    self.previewMode = previewMode
    self.ctx_Container = CreateControlFromVirtual(containerLabel, container, Theme.template)
    self.ctx_Container:SetAnchor(CENTER, container, CENTER, 0, 0)

    self.ctx_Gauge = GetControl(self.ctx_Container, 'Gauge')
    self.ctx_GreenBar = GetControl(self.ctx_Container, 'GaugeGreenBar')
    self.ctx_BlueBar = GetControl(self.ctx_Container, 'GaugeBlueBar')
    self.ctx_Perc = GetControl(self.ctx_Container, 'GaugePerc')
    self.ctx_GoalPerc = GetControl(self.ctx_Container, 'GaugeGoalPerc')
    self.ctx_Glow = GetControl(self.ctx_Container, 'Glow')
    self.ctx_RankIcon = GetControl(self.ctx_Container, 'GaugeRankIcon')
    self.ctx_Total = GetControl(self.ctx_Container, 'SideSpaceValue')
    self.ctx_Range = GetControl(self.ctx_Container, 'SideSpaceRange')
    self.ctx_RangeLabel = GetControl(self.ctx_Container, 'SideSpaceRangeLabel')

    if self.previewMode then
        GetControl(self.ctx_Container, 'SideSpacePanelButton'):SetMouseEnabled(false)
    end

    self:SetSize()

    -- Animations
    self.ctx_GreenBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual('APMeter_Modern_EasingGreen')
    self.ctx_GreenBar.easeAnimation._previewMode = self.previewMode
    self.ctx_GreenBar.lastValue = 0
    self.ctx_BlueBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual('APMeter_Modern_EasingBlue')
    self.ctx_BlueBar.easeAnimation._previewMode = self.previewMode
    self.ctx_BlueBar.lastValue = 0
    self.ctx_Glow.glowInAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual('APMeter_Modern_RangeGlowIn', self.ctx_Glow)
    self.ctx_Glow.glowOutAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual('APMeter_Modern_RangeGlowOut', self.ctx_Glow)

    self.ctx_Range.alphaAnimation = ZO_AlphaAnimation:New(self.ctx_Range)
    self.ctx_Range.alphaAnimation:SetMinMaxAlpha(0, 0.9)

    SetRankIcon(self)
    self:ToggleGoalUI()
end

local currencyDisplayOptions = {
    showTooltips = false,
    useShortFormat = false,
    font = "$(GAMEPAD_MEDIUM_FONT)|28|soft-shadow-thin",
    iconSide = RIGHT,
    iconSize = 20,
}

function Theme:SetSize()

    local sizeType = APM.db.settings.themes['Modern'].size

    if sizeType == 'small' then
        self.ctx_Container:SetScale(0.8)
        self.ctx_RangeLabel:SetFont("$(CHAT_FONT)|16")
        GetControl(self.ctx_Container, 'SideSpacePanelButton'):SetFont('$(GAMEPAD_MEDIUM_FONT)|17')
    else
        self.ctx_Container:SetScale(1)
        self.ctx_RangeLabel:SetFont("$(CHAT_FONT)|12|soft-shadow-thin")
        GetControl(self.ctx_Container, 'SideSpacePanelButton'):SetFont('$(GAMEPAD_MEDIUM_FONT)|16|soft-shadow-thick')
    end

end

function Theme:SetValue( value )
    ZO_CurrencyControl_SetSimpleCurrency(self.ctx_Total, CURT_ALLIANCE_POINTS, value, currencyDisplayOptions, CURRENCY_SHOW_ALL)
end

function Theme:ToggleGoalUI(force)

    if APM.db.goal.active or force then
        self.ctx_Perc:SetFont('$(GAMEPAD_BOLD_FONT)|34|soft-shadow-thick')
        self.ctx_Perc:ClearAnchors()
        self.ctx_BlueBar:SetHidden(false)
        self.ctx_Perc:SetAnchor(CENTER, self.ctx_Gauge, CENTER, -4, 0)
        self.ctx_GoalPerc:SetHidden(false)

        if GO_Mode then
            self.ctx_RankIcon:ClearAnchors()
            self.ctx_RankIcon:SetWidth(44)
            self.ctx_RankIcon:SetHeight(44)
            self.ctx_RankIcon:SetAnchor(CENTER, self.ctx_Gauge, CENTER, 0, -12)
        end
    else
        self.ctx_Perc:SetFont('$(GAMEPAD_BOLD_FONT)|40|soft-shadow-thick')
        self.ctx_Perc:ClearAnchors()
        self.ctx_BlueBar:SetHidden(true)
        self.ctx_Perc:SetAnchor(CENTER, self.ctx_Gauge, CENTER, -4, 6)
        self.ctx_GoalPerc:SetHidden(true)

        if GO_Mode then
            self.ctx_RankIcon:ClearAnchors()
            self.ctx_RankIcon:SetWidth(44)
            self.ctx_RankIcon:SetHeight(44)
            self.ctx_RankIcon:SetAnchor(CENTER, self.ctx_Gauge, CENTER, 0, -3)
        end
    end

end

function Theme:RankChange()
    SetRankIcon(self)
end

function Theme:SetProgress( value )

    local toValue = zo_min(value/100, 1.0)

    self.ctx_GreenBar:SetHidden(toValue == 0)
    
    self.ctx_GreenBar.startPercent = zo_min(self.ctx_GreenBar.lastValue, 1.0)
    self.ctx_GreenBar.endPercent = toValue
    self.ctx_GreenBar.easeAnimation:PlayFromStart()
    self.ctx_GreenBar.lastValue = toValue
end

function Theme:SetGoalProgress( value )

    local toValue = zo_min(value/100, 1.0)

    self.ctx_BlueBar:SetHidden(toValue == 0)

    self.ctx_BlueBar.startPercent = zo_min(self.ctx_BlueBar.lastValue, 1.0)
    self.ctx_BlueBar.endPercent = toValue
    self.ctx_BlueBar.easeAnimation:PlayFromStart()
    self.ctx_BlueBar.lastValue = toValue
end

function Theme:SetTickRange(label)

    local previousLabel = self.ctx_RangeLabel:GetText()

    if label ~= ' ' and previousLabel == ' ' then
        self.ctx_Glow.glowInAnimation:PlayFromStart()
        self.ctx_Range.alphaAnimation:FadeIn(0, 300)
    elseif label == ' ' and previousLabel ~= ' ' then
        self.ctx_Glow.glowOutAnimation:PlayFromStart()
        self.ctx_Range.alphaAnimation:FadeOut(0, 300)
    end

    self.ctx_RangeLabel:SetText(label)
end

function Theme:AnimationCallback(name, progress)

    if name == 'GreenBarUpdate' and self.ctx_GreenBar.startPercent then

        local fillPercentage = zo_min((progress * (self.ctx_GreenBar.endPercent - self.ctx_GreenBar.startPercent)) + self.ctx_GreenBar.startPercent, 1)
        self.ctx_GreenBar:StartFixedCooldown(fillPercentage, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
        self.ctx_Perc:SetText(math.floor(fillPercentage*100))

    elseif name == 'GreenBarComplete' and self.ctx_GreenBar.startPercent then

        self.ctx_Perc:SetText(math.floor(self.ctx_GreenBar.endPercent*100))

    elseif name == 'BlueBarUpdate' and self.ctx_BlueBar.startPercent then

        local fillPercentage = zo_min((progress * (self.ctx_BlueBar.endPercent - self.ctx_BlueBar.startPercent)) + self.ctx_BlueBar.startPercent, 1)
        self.ctx_BlueBar:StartFixedCooldown(fillPercentage, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
        self.ctx_GoalPerc:SetText(math.floor(fillPercentage*100))
    
    elseif name == 'BlueBarComplete' and self.ctx_BlueBar.startPercent then
        self.ctx_GoalPerc:SetText(math.floor(self.ctx_BlueBar.endPercent*100))
    end

end

function Theme:StartPreview()
    self:SetValue(696969)
    zo_callLater(function()
        self:SetProgress(69)
        zo_callLater(function() self:SetTickRange('Keep Range') end, 900)
        zo_callLater(function() self:ToggleGoalUI(true) self:SetGoalProgress(42) end, 1300)
    end,800)
end

function Theme:ResetPreview()
    self:SetValue(0)
    self:SetTickRange(' ')
    self:ToggleGoalUI(false)
    self.ctx_GreenBar:SetHidden(true)
    self.ctx_BlueBar:SetHidden(true)
    self.ctx_GreenBar.lastValue = 0
    self.ctx_BlueBar.lastValue = 0
    self:SetProgress(0)
    self:SetGoalProgress(0)
end

function Theme:GetSettings()
    return {
        -- [1] = {
        --     type = "description",
        --     title = "Options coming soon",
        --     text = [[Anything you may want here, feel free to leave a comment or send a mail]]
        -- }
        [1] = {
            type = "dropdown",
            name = "Set size of the Modern meter",
            choices = {'Large', 'Small'},
            choicesValues = {'large', 'small'},
            getFunc = function()
                return APM.db.settings.themes['Modern'].size
            end,
            setFunc = function(value)
                APM.db.settings.themes['Modern'].size = value
                APM.Theme.Preview:SetSize(value)

                if APM.Theme.Selected().name == 'Modern' then
                    APM.Theme.Selected():SetSize(value)
                end
            end,
            width = "full",	--or "half" (optional)
            default = 'large',
        }
    }
end

APM.Theme.Register(Theme)