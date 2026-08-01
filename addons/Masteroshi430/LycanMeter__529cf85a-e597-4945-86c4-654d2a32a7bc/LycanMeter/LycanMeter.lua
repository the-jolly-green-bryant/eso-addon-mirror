LycanMeter = {}
LycanMeter.name = "LycanMeter"


-- smooth meter transition
function LycanMeter.SetGradient()
    local angleGoal = LycanMeter.Meter.Circle.angle
    local newAngle = LycanMeter.Meter.Circle.angle
	if not LycanMeter.Meter.Circle.oldAngle then
	       
	elseif angleGoal > LycanMeter.Meter.Circle.oldAngle then
	       newAngle = LycanMeter.Meter.Circle.oldAngle + 0.01
	elseif angleGoal < LycanMeter.Meter.Circle.oldAngle then
		   newAngle = LycanMeter.Meter.Circle.oldAngle - 0.01
	end
	
	LycanMeter.Meter.Circle:SetRadialCooldownGradient(1, newAngle)
	LycanMeter.Meter.CircleTwo:SetRadialCooldownGradient(1, newAngle)
	LycanMeter.Meter.CircleThree:SetRadialCooldownGradient(1, newAngle)
	LycanMeter.Meter.CircleFour:SetRadialCooldownGradient(1, newAngle)
	LycanMeter.Meter.CircleFive:SetRadialCooldownGradient(1, newAngle)
	
    LycanMeter.Meter.Circle.oldAngle = newAngle
    if angleGoal ~= newAngle then
	   zo_callLater(function() LycanMeter.SetGradient() end, 100)
	end
end



-- smooth percent text transition
function LycanMeter.SetPercentText()
    local percentage = LycanMeter.Meter.Text.percentageGoal
	local newPercentage = percentage
	if not LycanMeter.Meter.Text.percentage then
	       LycanMeter.Meter.Text:SetText(percentage.."%")
	elseif percentage > LycanMeter.Meter.Text.percentage then
	       newPercentage = LycanMeter.Meter.Text.percentage + 1
		   LycanMeter.Meter.Text:SetText(newPercentage.."%")
	elseif percentage < LycanMeter.Meter.Text.percentage then
		   newPercentage = LycanMeter.Meter.Text.percentage - 1
		   LycanMeter.Meter.Text:SetText(newPercentage.."%")
	end
	
    LycanMeter.Meter.Text.percentage = newPercentage
    if LycanMeter.Meter.Text.percentage ~= percentage then
	   zo_callLater(function() LycanMeter.SetPercentText() end, 100)
	end
end

function LycanMeter.go() 
 if not IsPlayerActivated() then return end
 
 if IsInImperialCity() or GetBounty() > 0 or GetLocalPlayerDaedricArtifactId() ~= nil then
     doNotDisplay = true 
 end

 if IsPlayerInWerewolfForm() and SCENE_MANAGER:GetCurrentSceneName() == "hud" and not doNotDisplay then
 
      local current, max, effectiveMax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
      local percentage = math.floor(current/max*100)
	  local colour = ZO_ColorDef:New(255, 0, 0, 1)
	  local amount = percentage/100
	  colour = colour:Lerp(ZO_ColorDef:New(1, 1, 1, 1), amount)
	  
      -- top level window
      LycanMeter.Meter = LycanMeter.Meter or WINDOW_MANAGER:CreateTopLevelWindow(nil)
	  LycanMeter.Meter:SetDimensions(INFAMY_METER_WIDTH, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter:ClearAnchors()
	  LycanMeter.Meter:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
      LycanMeter.Meter:SetHidden(false)
	 
      -- meter circle bg
	  LycanMeter.Meter.CircleBg = LycanMeter.Meter.CircleBg or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_TEXTURE)
	  LycanMeter.Meter.CircleBg:SetTexture("esoui/art/hud/infamy_meter-back-grey_px_per.dds") 
	  LycanMeter.Meter.CircleBg:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter.CircleBg:ClearAnchors()
      LycanMeter.Meter.CircleBg:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, 15, 15)
      LycanMeter.Meter.CircleBg:SetHidden(false)

	  -- meter circle
	  LycanMeter.Meter.Circle = LycanMeter.Meter.Circle or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_COOLDOWN) 
	  LycanMeter.Meter.Circle:SetTexture("esoui/art/hud/infamy_meter-bounty_px_per.dds")
	  LycanMeter.Meter.Circle:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter.Circle:ClearAnchors()
      LycanMeter.Meter.Circle:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, 15, 15)
      LycanMeter.Meter.Circle:SetHidden(false)
	  LycanMeter.Meter.Circle:SetFillColor(colour:UnpackRGB())
	  local NO_LEADING_EDGE = false
	  LycanMeter.Meter.Circle.easeAnimation = LycanMeter.Meter.Circle.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
	  LycanMeter.Meter.Circle.startPercent = LycanMeter.Meter.Circle.endPercent or 100
	  LycanMeter.Meter.Circle.endPercent = percentage
      LycanMeter.Meter.Circle:StartFixedCooldown(LycanMeter.Meter.Circle.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
      LycanMeter.Meter.Circle.easeAnimation:PlayFromStart()
	  local MAX_ROTATION = math.pi * 2
	  local angle = math.floor(percentage*MAX_ROTATION)/100
	  LycanMeter.Meter.Circle.angle = angle

	  
	  -- meter circle two
	  LycanMeter.Meter.CircleTwo = LycanMeter.Meter.CircleTwo or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_COOLDOWN) 
	  LycanMeter.Meter.CircleTwo:SetTexture("esoui/art/hud/infamy_meter-bounty_px_per.dds")
	  LycanMeter.Meter.CircleTwo:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter.CircleTwo:ClearAnchors()
      LycanMeter.Meter.CircleTwo:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, 15, 15)
      LycanMeter.Meter.CircleTwo:SetHidden(false)
	  LycanMeter.Meter.CircleTwo:SetFillColor(colour:UnpackRGB())

	  LycanMeter.Meter.CircleTwo.easeAnimation = LycanMeter.Meter.CircleTwo.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
	  LycanMeter.Meter.CircleTwo.startPercent = LycanMeter.Meter.CircleTwo.endPercent or 100
	  LycanMeter.Meter.CircleTwo.endPercent = percentage
      LycanMeter.Meter.CircleTwo:StartFixedCooldown(LycanMeter.Meter.CircleTwo.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
      LycanMeter.Meter.CircleTwo.easeAnimation:PlayFromStart()

	  
	  -- meter circle three
	  LycanMeter.Meter.CircleThree = LycanMeter.Meter.CircleThree or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_COOLDOWN) 
	  LycanMeter.Meter.CircleThree:SetTexture("esoui/art/hud/infamy_meter-bounty_px_per.dds")
	  LycanMeter.Meter.CircleThree:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter.CircleThree:ClearAnchors()
      LycanMeter.Meter.CircleThree:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, 15, 15)
      LycanMeter.Meter.CircleThree:SetHidden(false)
	  LycanMeter.Meter.CircleThree:SetFillColor(colour:UnpackRGB())

	  LycanMeter.Meter.CircleThree.easeAnimation = LycanMeter.Meter.CircleThree.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
	  LycanMeter.Meter.CircleThree.startPercent = LycanMeter.Meter.CircleThree.endPercent or 100
	  LycanMeter.Meter.CircleThree.endPercent = percentage
      LycanMeter.Meter.CircleThree:StartFixedCooldown(LycanMeter.Meter.CircleThree.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
      LycanMeter.Meter.CircleThree.easeAnimation:PlayFromStart()

	  
	  -- meter circle four
	  LycanMeter.Meter.CircleFour = LycanMeter.Meter.CircleFour or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_COOLDOWN) 
	  LycanMeter.Meter.CircleFour:SetTexture("esoui/art/hud/infamy_meter-bounty_px_per.dds")
	  LycanMeter.Meter.CircleFour:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter.CircleFour:ClearAnchors()
      LycanMeter.Meter.CircleFour:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, 15, 15)
      LycanMeter.Meter.CircleFour:SetHidden(false)
	  LycanMeter.Meter.CircleFour:SetFillColor(colour:UnpackRGB())

	  LycanMeter.Meter.CircleFour.easeAnimation = LycanMeter.Meter.CircleFour.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
	  LycanMeter.Meter.CircleFour.startPercent = LycanMeter.Meter.CircleFour.endPercent or 100
	  LycanMeter.Meter.CircleFour.endPercent = percentage
      LycanMeter.Meter.CircleFour:StartFixedCooldown(LycanMeter.Meter.CircleFour.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
      LycanMeter.Meter.CircleFour.easeAnimation:PlayFromStart()

	  
	  -- meter circle five
	  LycanMeter.Meter.CircleFive = LycanMeter.Meter.CircleFive or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_COOLDOWN) 
	  LycanMeter.Meter.CircleFive:SetTexture("esoui/art/hud/infamy_meter-bounty_px_per.dds")
	  LycanMeter.Meter.CircleFive:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter.CircleFive:ClearAnchors()
      LycanMeter.Meter.CircleFive:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, 15, 15)
      LycanMeter.Meter.CircleFive:SetHidden(false)
	  LycanMeter.Meter.CircleFive:SetFillColor(colour:UnpackRGB())

	  LycanMeter.Meter.CircleFive.easeAnimation = LycanMeter.Meter.CircleFive.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
	  LycanMeter.Meter.CircleFive.startPercent = LycanMeter.Meter.CircleFive.endPercent or 100
	  LycanMeter.Meter.CircleFive.endPercent = percentage
      LycanMeter.Meter.CircleFive:StartFixedCooldown(LycanMeter.Meter.CircleFive.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
      LycanMeter.Meter.CircleFive.easeAnimation:PlayFromStart()

	  
	  LycanMeter.SetGradient()

	  
	  -- meter texture
	  LycanMeter.Meter.Texture = LycanMeter.Meter.Texture or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_TEXTURE)
	  LycanMeter.Meter.Texture:SetTexture("esoui/art/hud/infamy_meter-frame-generic.dds")
	  LycanMeter.Meter.Texture:SetDimensions(INFAMY_METER_WIDTH, INFAMY_METER_HEIGHT)
	  LycanMeter.Meter.Texture:ClearAnchors()
	  LycanMeter.Meter.Texture:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, 0, 0)
      LycanMeter.Meter.Texture:SetHidden(false)
	  
	  -- meter % text 
	  LycanMeter.Meter.Text = LycanMeter.Meter.Text or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_LABEL)
	  local path = "$(BOLD_FONT)"
      local size = 20
      local outline = "soft-shadow-thick"
      LycanMeter.Meter.Text:SetFont(path .. "|" .. size .. "|" ..  outline)
      LycanMeter.Meter.Text:SetColor(colour:UnpackRGB())
	  LycanMeter.Meter.Text:SetDimensions(50, 20)
	  LycanMeter.Meter.Text:ClearAnchors()
	  LycanMeter.Meter.Text:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, -125, -15)
      LycanMeter.Meter.Text:SetHidden(false)
	  LycanMeter.Meter.Text.percentageGoal = percentage 
	  LycanMeter.SetPercentText()
	  
	  -- meter icon
	  LycanMeter.Meter.Icon = LycanMeter.Meter.Icon or WINDOW_MANAGER:CreateControl(nil, LycanMeter.Meter, CT_TEXTURE)
	  LycanMeter.Meter.Icon:SetTexture("esoui/art/icons/store_werewolfbite_01.dds")
	  LycanMeter.Meter.Icon:SetDimensions(INFAMY_METER_HEIGHT/2, INFAMY_METER_HEIGHT/2)
	  LycanMeter.Meter.Icon:ClearAnchors()
	  LycanMeter.Meter.Icon:SetAnchor(BOTTOMRIGHT, LycanMeter.Meter, BOTTOMRIGHT, -17, -17) 
      LycanMeter.Meter.Icon:SetHidden(false)
	  

 else
	  if LycanMeter.Meter then
	      LycanMeter.Meter:SetHidden(true)
	  end
 end


end

EVENT_MANAGER:RegisterForEvent(LycanMeter.name, EVENT_WEREWOLF_STATE_CHANGED, LycanMeter.go)
EVENT_MANAGER:RegisterForEvent(LycanMeter.name, EVENT_POWER_UPDATE, function(_, unitTag, _, powerType) if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_WEREWOLF then LycanMeter.go() end end)


SecurePostHook(SCENE_MANAGER, "OnSceneStateChange", function(rowControl, rowData)
    LycanMeter.go() 
end)
