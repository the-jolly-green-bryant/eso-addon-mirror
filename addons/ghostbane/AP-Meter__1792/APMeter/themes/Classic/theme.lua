local APM = APMeter
local Theme = ZO_Object:Subclass()

Theme.name = 'Classic'
Theme.template = 'APMeter_Theme_Classic'
Theme.containerWidth = 255
Theme.containerHeight = 90

local GO_Mode = GetUnitAvARank('player') == 50

local function SetRankIcon(self, rank)

    if not rank then
        rank = GetUnitAvARank('player')
    end

    if rank == 50 then
        self.ctx_Perc:SetText('|t34:34:' .. GetAvARankIcon(rank):gsub('%rankicon', 'rankicon64') .. '|t')
        self.ctx_PercSmall:SetText('|t25:25:' .. GetAvARankIcon(rank):gsub('%rankicon', 'rankicon64') .. '|t')
        self.ctx_Perc_Symbol:SetHidden(true)
        self.ctx_PercSmall_Symbol:SetHidden(true)
        self.ctx_Perc:ClearAnchors()
        self.ctx_Perc:SetAnchor(LEFT, self.ctx_LabelContainer, LEFT, -148, 0)
        self.ctx_PercSmall:SetAnchor(RIGHT, self.ctx_GoalPerc, RIGHT, 7, 26)
        
    end
end

local timeElapsed = 1

local function format_int(number)

    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

    -- reverse the int-string and append a comma to all blocks of 3 digits
    int = int:reverse():gsub("(%d%d%d)", "%1,")

    -- reverse the int-string back remove an optional comma and put the 
    -- optional minus and fractional part back
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

local function parseAPH()

    if APM.session.timeElapsed > 0 then
        timeElapsed = (timeElapsed + GetGameTimeMilliseconds() - APM.session.startTime) / 1000
        local APH_value = math.floor(1 * (3600 / timeElapsed * APM.session.total))

        APMeterContainer_SelectedThemeClassicApH:SetText('ApH: |c00a313 '..format_int(APH_value))
    else
        APMeterContainer_SelectedThemeClassicApH:SetText('ApH: |c00a313 -')
    end

end

local function StartAPHTimer()

    EVENT_MANAGER:RegisterForUpdate('APM_Classic_APH', 500, parseAPH)

end

local function StopAPHTimer()

    EVENT_MANAGER:UnregisterForUpdate('APM_Classic_APH')

end

function Theme:New(...)
    local theme = ZO_Object.New(self)
    theme:Initialize(...)
    return theme
end

function Theme:Initialize( container, containerLabel, previewMode )
    
    self.previewMode = previewMode
    self.ctx_Container = CreateControlFromVirtual(containerLabel, container, Theme.template)
    
    if self.previewMode then
        self.ctx_Container:SetAnchor(CENTER, container, CENTER, 0, 0)
    else
        self.ctx_Container:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    end

    self.ctx_GreenBar = GetControl(self.ctx_Container, 'ClassicBarFill')
    self.ctx_BlueBar = GetControl(self.ctx_Container, 'ClassicBarTargetFill')
    self.ctx_Perc = GetControl(self.ctx_Container, 'ClassicMultiplierContainerWholePart')
    self.ctx_LabelContainer = GetControl(self.ctx_Container, 'ClassicMultiplierContainer')
    self.ctx_Perc_Symbol = GetControl(self.ctx_Container, 'ClassicMultiplierContainerFractionalPart')
    self.ctx_PercSmall = GetControl(self.ctx_Container, 'ClassicMultiplierContainerTargetGlobalValue')
    self.ctx_PercSmall_Symbol = GetControl(self.ctx_Container, 'ClassicMultiplierContainerFractionalTargetGlobalPart')
    self.ctx_GoalPerc = GetControl(self.ctx_Container, 'ClassicMultiplierContainerTargetValue')
    self.ctx_GoalPerc_Symbol = GetControl(self.ctx_Container, 'ClassicMultiplierContainerFractionalTargetPart')
    self.ctx_Total = GetControl(self.ctx_Container, 'ClassicDisplay')
    self.ctx_Range = GetControl(self.ctx_Container, 'ClassicZone')
    self.ctx_ApH = GetControl(self.ctx_Container, 'ClassicApH')

    -- -- Animations
    self.ctx_GreenBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual('APMeter_Classic_EasingGreen')
    self.ctx_GreenBar.easeAnimation._previewMode = self.previewMode
    self.ctx_GreenBar.lastValue = 0
    self.ctx_BlueBar.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual('APMeter_Classic_EasingBlue')
    self.ctx_BlueBar.easeAnimation._previewMode = self.previewMode
    self.ctx_BlueBar.lastValue = 0
    self:ToggleGoalUI()

    SetRankIcon(self, rank)

    self.ctx_ApH:SetHidden(not APM.db.settings.themes['Classic'].aph)

    if APM.db.settings.themes['Classic'].aph then
        StartAPHTimer()
    end

    if GO_Mode then
        zo_callLater(function()
            self.ctx_GreenBar.startPercent = 0
            self.ctx_GreenBar.endPercent = 1
            self.ctx_GreenBar.easeAnimation:PlayFromStart()
        end, 900)
    end

end
-- 'ApH: |c00a313 -'

local currencyDisplayOptions = {
    showTooltips = true,
    customTooltip = SI_CURRENCYTYPE2,
    isGamepad = false,
    font = "ZoFontGameLargeBold",
    iconSide = LEFT
}

function Theme:SetValue( value )
    ZO_CurrencyControl_SetSimpleCurrency(self.ctx_Total, CURT_ALLIANCE_POINTS, value, currencyDisplayOptions, CURRENCY_SHOW_ALL)
end

function Theme:ToggleGoalUI(force)

    if APM.db.goal.active or force then
        self.ctx_BlueBar:SetHidden(false)
        self.ctx_GoalPerc:SetHidden(false)
        self.ctx_GoalPerc_Symbol:SetHidden(false)
        self.ctx_PercSmall:SetHidden(false)
        self.ctx_Perc:SetHidden(true)

        if not GO_Mode then
            self.ctx_Perc_Symbol:SetHidden(true)
            self.ctx_PercSmall_Symbol:SetHidden(false)
        end
    else
        self.ctx_BlueBar:SetHidden(true)
        self.ctx_GoalPerc:SetHidden(true)
        self.ctx_GoalPerc_Symbol:SetHidden(true)
        self.ctx_PercSmall:SetHidden(true)
        self.ctx_Perc:SetHidden(false)

        if not GO_Mode then
            self.ctx_PercSmall_Symbol:SetHidden(true)
            self.ctx_Perc_Symbol:SetHidden(false)
        end
    end

end

function Theme:RankChange() end

function Theme:SetProgress( value )

    if GO_Mode then return end

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
    self.ctx_Range:SetText(label)
end

function Theme:AnimationCallback(name, progress)

    if not progress then return false end

    if name == 'GreenBarUpdate' and self.ctx_GreenBar.startPercent then

        local fillPercentage = zo_min((progress * (self.ctx_GreenBar.endPercent - self.ctx_GreenBar.startPercent)) + self.ctx_GreenBar.startPercent, 1)
        self.ctx_GreenBar:StartFixedCooldown(fillPercentage, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
        if not GO_Mode then
            self.ctx_Perc:SetText(math.floor(self.ctx_GreenBar.endPercent*100))
            self.ctx_PercSmall:SetText(math.floor(self.ctx_GreenBar.endPercent*100))
        end

    elseif name == 'GreenBarComplete' and self.ctx_GreenBar.startPercent then

        if not GO_Mode then
            self.ctx_Perc:SetText(math.floor(self.ctx_GreenBar.endPercent*100))
            self.ctx_PercSmall:SetText(math.floor(self.ctx_GreenBar.endPercent*100))
        end

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
        zo_callLater(function() self:ToggleGoalUI(true) self:SetGoalProgress(42) end, 1800)
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

    local settings = APM.db.settings.themes['Classic']
    local context = self

    return {
        [1] = {
            type = "checkbox",
            name = "Enable ApH timer?",
            tooltip = "Displays Alliance Points per Hour",
            getFunc = function()
                return settings.aph
            end,
            setFunc = function(value)
                if APMeterPreviewContainer_SelectedTheme_ClassicClassicApH then
                    APMeterPreviewContainer_SelectedTheme_ClassicClassicApH:SetHidden(not value)
                end
                if APMeterContainer_SelectedThemeClassicApH then
                    APMeterContainer_SelectedThemeClassicApH:SetHidden(not value)
                    StartAPHTimer()
                else
                    StopAPHTimer()
                end
                settings.aph = value
            end,
            default = false
        }
    }
end

APM.Theme.Register(Theme)