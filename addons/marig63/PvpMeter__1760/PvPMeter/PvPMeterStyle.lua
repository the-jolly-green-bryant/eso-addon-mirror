TELVAR_METER_WIDTH = 256
TELVAR_METER_HEIGHT = 128
TELVAR_METER_KEYBOARD_BAR_OFFSET_X = 14
TELVAR_METER_KEYBOARD_BAR_OFFSET_Y = 18
TELVAR_METER_GAMEPAD_BAR_OFFSET_X = -9
TELVAR_METER_GAMEPAD_BAR_OFFSET_Y = 15

local HUDTelvarMeter = ZO_Object:Subclass()

function HUDTelvarMeter:New(...)

    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object

end

function HUDTelvarMeter:Initialize(control)

    -- Initialize state
    self.hiddenReasons = ZO_HiddenReasons:New()
    self.telvarStoneThreshold = GetTelvarStoneMultiplierThresholdIndex()
    
    -- Set up controls
    self.alertBorder = HUDTelvarAlertBorder
    self.telvarDisplayControl = control:GetNamedChild("TelvarDisplay")
    self.meterTelvarMultiplierControl = control:GetNamedChild("Multiplier")
    self.meterFrameControl = control:GetNamedChild("Frame")
    self.meterBarControl = control:GetNamedChild("Bar")
    self.meterOverlayControl = control:GetNamedChild("Overlay")
    self.meterBarFill = self.meterBarControl:GetNamedChild("Fill")
    self.meterBarHighlight = self.meterBarControl:GetNamedChild("Highlight")
    self.multiplierContainer = control:GetNamedChild("MultiplierContainer")
    self.multiplierLabel = self.multiplierContainer:GetNamedChild("MultiplierLabel")
    self.multiplierWholePart = self.multiplierContainer:GetNamedChild("WholePart")
    self.multiplierFractionalPart = self.multiplierContainer:GetNamedChild("FractionalPart")
    self.control = control

    -- Set up platform styles
    self.keyboardStyle = 
    { 
        template = "HUDTelvarMeter_KeyboardTemplate" ,
        currencyOptions = 
        {
            showTooltips = true,
            customTooltip = SI_CURRENCYTYPE3,
            isGamepad = false,
            font = "ZoFontGameLargeBold",
            iconSide = RIGHT,
        },
    }
    self.gamepadStyle = 
    { 
        template = "HUDTelvarMeter_KeyboardTemplate",
        currencyOptions = 
        {
            showTooltips = true,
			customTooltip = SI_CURRENCYTYPE3,
            isGamepad = false,
            font = "ZoFontGameLargeBold",
            iconSide = RIGHT,
        },
    }
    ZO_PlatformStyle:New(function(...) self:UpdatePlatformStyle(...) end, self.keyboardStyle, self.gamepadStyle)

    -- Initialize alert border animation
    self.alertBorder.pulseAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDTelvarAlertBorderAnimation", self.alertBorder)

    -- Initialize overlay animation
    self.meterOverlayControl.fadeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDTelvarMeterOverlayFade", self.meterOverlayControl)

    -- Initialize label animation
    self.multiplierContainer.bounceAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDTelvarMeterMultiplierBounce", self.multiplierContainer)

    -- Initialize bar states and animations
    self.meterBarControl.easeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HUDTelvarMeterEasing")
    self.meterBarControl.startPercent = 0
    self.meterBarControl.endPercent = 0

    -- Initialize edge animation

    -- Register for events
    control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
        if DoesCurrentZoneHaveTelvarStoneBehavior() then
            TriggerTutorial(TUTORIAL_TRIGGER_TELVAR_ZONE_ENTERED)
            self:SetHiddenForReason("disabledInZone", false)
        else
            self:SetHiddenForReason("disabledInZone", false)
        end
    end)
    -- Do our initial update
    self:SetBarValue(self.meterBarControl.startPercent)
    self:OnTelvarStonesUpdated()

end

function HUDTelvarMeter:SetHiddenForReason(reason, hidden)

    self.hiddenReasons:SetHiddenForReason(reason, hidden)
    self.control:SetHidden(self.hiddenReasons:IsHidden())

end

function HUDTelvarMeter:OnTelvarStonesUpdated()

	newTelvarStones = 80
	oldTelvarStones = 10
	
	self:UpdateMeterBar()

end

function HUDTelvarMeter:UpdateMeterBar()

    self.meterBarControl.easeAnimation:PlayFromStart() 

end

function HUDTelvarMeter:AnimateMeter(progress)

    local fillPercentage = zo_min((progress * (self.meterBarControl.endPercent - self.meterBarControl.startPercent)) + self.meterBarControl.startPercent, 1)
    self:SetBarValue(fillPercentage)

end

function HUDTelvarMeter:SetBarValue(percentFilled)

    self.meterBarFill:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE) -- CD_TIME_TYPE_TIME_REMAINING causes clockwise scroll
    self.meterBarHighlight:StartFixedCooldown(percentFilled, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)

end

function HUDTelvarMeter:UpdatePlatformStyle(styleTable)

    ApplyTemplateToControl(self.control, styleTable.template)
    ZO_CurrencyControl_SetSimpleCurrency(self.telvarDisplayControl, CURT_TELVAR_STONES, GetCarriedCurrencyAmount(CURT_TELVAR_STONES), styleTable.currencyOptions, CURRENCY_SHOW_ALL) 

    local isMaxThreshold = IsMaxTelvarStoneMultiplierThreshold(self.telvarStoneThreshold)
    self.meterBarControl:SetHidden(isMaxThreshold)
    self.meterOverlayControl:SetAlpha(isMaxThreshold and 1 or 0)

end

function HUDTelvarMeter:CalculateMeterFillPercentage()

    if IsMaxTelvarStoneMultiplierThreshold(self.telvarStoneThreshold) then
        return 1
    elseif self.telvarStoneThreshold then -- Protect against self.telvarStoneThreshold being nil.
        local currentThresholdAmount = GetTelvarStoneThresholdAmount(self.telvarStoneThreshold)
        local nextThresholdAmount = GetTelvarStoneThresholdAmount(self.telvarStoneThreshold + 1)
        local result = (GetCarriedCurrencyAmount(CURT_TELVAR_STONES) - currentThresholdAmount) / (nextThresholdAmount - currentThresholdAmount)
        return zo_max(result, 0)    
    else
        return 0
    end

end


function HUDTelvarMeter_Initialize(control)

    TELVAR_METER = HUDTelvarMeter:New(control)

end

function HUDTelvarMeter_update(startP,endP)

    if TELVAR_METER then
	
		TELVAR_METER.meterBarControl.startPercent = startP
		TELVAR_METER.meterBarControl.endPercent = endP
	
        TELVAR_METER:OnTelvarStonesUpdated()
    end

end

function HUDTelvarMeter_color(r,g,b)

	if TELVAR_METER then
		TELVAR_METER.meterBarFill:SetFillColor(r,g,b)
		TELVAR_METER.meterBarHighlight:SetFillColor(r,g,b)
		TELVAR_METER.meterOverlayControl:SetColor(r,g,b,0)
	end

end

function HUDTelvarMeter_moveBar(x,y)

	if TELVAR_METER then
		TELVAR_METER.meterBarControl:ClearAnchors()
		TELVAR_METER.meterOverlayControl:ClearAnchors()
		
		TELVAR_METER.meterBarControl:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,18+x,18+y)
		TELVAR_METER.meterOverlayControl:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,24+x,18+y)
	end

end

function HUDTelvarMeter_colorAlert(r,g,b)

	if TELVAR_METER then
		local truck = HUDTelvarAlertBorder:GetNamedChild("Overlay")
		truck:SetEdgeColor(r,g,b)
	end

end

function HUDTelvarMeter_restore(top,left)

	if TELVAR_METER then
		TELVAR_METER.control:ClearAnchors()
		TELVAR_METER.control:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT, left, top)
	end

end

function HUDTelvarMeter_show()

	if(PvpMeter.savedVariables.showBeautifulMeter)then
		if TELVAR_METER then
			TELVAR_METER:SetHiddenForReason("disabledInZone", false)
		end
	end
end

function HUDTelvarMeter_hide()

	if TELVAR_METER then
		TELVAR_METER:SetHiddenForReason("disabledInZone", true)
	end

end

function HUDTelvarMeter_alpha(alpha)

	if TELVAR_METER then
		TELVAR_METER.meterBarControl:SetAlpha(alpha)
	end

end

function HUDTelvarMeter_first()

	if TELVAR_METER then
		TELVAR_METER.meterBarControl:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,TELVAR_METER_KEYBOARD_BAR_OFFSET_X,18)
	end

end

function HUDTelvarMeter_sec()

	if TELVAR_METER then
		TELVAR_METER.meterBarControl:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,TELVAR_METER_KEYBOARD_BAR_OFFSET_X,-72)
	end

end

function HUDTelvarMeter_getLeft()

	if TELVAR_METER then
		return TELVAR_METER.control:GetLeft()
	end

end

function HUDTelvarMeter_getTop()
	
	if TELVAR_METER then
		return TELVAR_METER.control:GetTop()
	end

end

function HUDTelvarMeter_UpdateMeterToAnimationProgress(progress)

    if TELVAR_METER then
        TELVAR_METER:AnimateMeter(progress)
    end

end

function HUDTelvarMeter_gamepad(option,left)

	if TELVAR_METER then
		
		if(option) then
		
			TELVAR_METER.meterBarControl:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,80,18)
		else
			TELVAR_METER.meterBarControl:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,18,18)
		end
	end
	
end


function HUDTelvarMeter_Anim()
	
	if TELVAR_METER then
		if(PvpMeter.savedVariables.showBeautifulMeter)then
			TELVAR_METER.meterOverlayControl.fadeAnimation:PlayFromStart()
		end
		if(PvpMeter.savedVariables.alertBorder)then
			TELVAR_METER.alertBorder.pulseAnimation:PlayFromStart()
		end
	end
	
end
