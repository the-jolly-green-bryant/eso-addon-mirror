-- LycanStatus.lua
if MSI == nil then MSI = MSI or {} end
local MSI = _G['MSI']

--*************--
-- Lycan State
local function SetGradient()
	local angleGoal = LycanStatus.Circle.angle
	local newAngle = LycanStatus.Circle.angle
	if not LycanStatus.Circle.oldAngle then

	elseif angleGoal > LycanStatus.Circle.oldAngle then
			newAngle = LycanStatus.Circle.oldAngle + 0.01
	elseif angleGoal < LycanStatus.Circle.oldAngle then
			newAngle = LycanStatus.Circle.oldAngle - 0.01
	end

	LycanStatus.Circle:SetRadialCooldownGradient(1, newAngle)
	LycanStatus.CircleTwo:SetRadialCooldownGradient(1, newAngle)
	LycanStatus.CircleThree:SetRadialCooldownGradient(1, newAngle)
	LycanStatus.CircleFour:SetRadialCooldownGradient(1, newAngle)
	LycanStatus.CircleFive:SetRadialCooldownGradient(1, newAngle)

	LycanStatus.Circle.oldAngle = newAngle
	if angleGoal ~= newAngle then
		zo_callLater(function() SetGradient() end, 100)
	end
end

-- smooth percent text transition
local function SetPercentText()
	local percentage = LycanStatus.Text.percentageGoal
	local newPercentage = percentage
	if not LycanStatus.Text.percentage then
			LycanStatus.Text:SetText(percentage.."%")
	elseif percentage > LycanStatus.Text.percentage then
			newPercentage = LycanStatus.Text.percentage + 1
			LycanStatus.Text:SetText(newPercentage.."%")
	elseif percentage < LycanStatus.Text.percentage then
			newPercentage = LycanStatus.Text.percentage - 1
			LycanStatus.Text:SetText(newPercentage.."%")
	end

	LycanStatus.Text.percentage = newPercentage
	if LycanStatus.Text.percentage ~= percentage then
		zo_callLater(function() SetPercentText() end, 100)
	end
end

local function ShowLycanStatus()
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
		LycanStatus = LycanStatus or WINDOW_MANAGER:CreateTopLevelWindow(nil)
		LycanStatus:SetDimensions(INFAMY_METER_WIDTH, INFAMY_METER_HEIGHT)
		LycanStatus:ClearAnchors()
		LycanStatus:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
		LycanStatus:SetHidden(false)

		-- meter circle bg
		LycanStatus.CircleBg = LycanStatus.CircleBg or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_TEXTURE)
		LycanStatus.CircleBg:SetTexture([[EsoUI/Art/Hud/infamy_meter-back-grey_px_per.dds]]) 
		LycanStatus.CircleBg:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
		LycanStatus.CircleBg:ClearAnchors()
		LycanStatus.CircleBg:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, 15, 15)
		LycanStatus.CircleBg:SetHidden(false)

		-- meter circle
		LycanStatus.Circle = LycanStatus.Circle or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_COOLDOWN) 
		LycanStatus.Circle:SetTexture([[EsoUI/Art/Hud/infamy_meter-bounty_px_per.dds]])
		LycanStatus.Circle:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
		LycanStatus.Circle:ClearAnchors()
		LycanStatus.Circle:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, 15, 15)
		LycanStatus.Circle:SetHidden(false)
		LycanStatus.Circle:SetFillColor(colour:UnpackRGB())
		local NO_LEADING_EDGE = false
		LycanStatus.Circle.easeAnimation = LycanStatus.Circle.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
		LycanStatus.Circle.startPercent = LycanStatus.Circle.endPercent or 100
		LycanStatus.Circle.endPercent = percentage
		LycanStatus.Circle:StartFixedCooldown(LycanStatus.Circle.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
		LycanStatus.Circle.easeAnimation:PlayFromStart()
		local MAX_ROTATION = math.pi * 2
		local angle = math.floor(percentage*MAX_ROTATION)/100
		LycanStatus.Circle.angle = angle


		-- meter circle two
		LycanStatus.CircleTwo = LycanStatus.CircleTwo or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_COOLDOWN) 
		LycanStatus.CircleTwo:SetTexture([[EsoUI/Art/Hud/infamy_meter-bounty_px_per.dds]])
		LycanStatus.CircleTwo:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
		LycanStatus.CircleTwo:ClearAnchors()
		LycanStatus.CircleTwo:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, 15, 15)
		LycanStatus.CircleTwo:SetHidden(false)
		LycanStatus.CircleTwo:SetFillColor(colour:UnpackRGB())

		LycanStatus.CircleTwo.easeAnimation = LycanStatus.CircleTwo.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
		LycanStatus.CircleTwo.startPercent = LycanStatus.CircleTwo.endPercent or 100
		LycanStatus.CircleTwo.endPercent = percentage
		LycanStatus.CircleTwo:StartFixedCooldown(LycanStatus.CircleTwo.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
		LycanStatus.CircleTwo.easeAnimation:PlayFromStart()


		-- meter circle three
		LycanStatus.CircleThree = LycanStatus.CircleThree or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_COOLDOWN) 
		LycanStatus.CircleThree:SetTexture([[EsoUI/Art/Hud/infamy_meter-bounty_px_per.dds]])
		LycanStatus.CircleThree:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
		LycanStatus.CircleThree:ClearAnchors()
		LycanStatus.CircleThree:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, 15, 15)
		LycanStatus.CircleThree:SetHidden(false)
		LycanStatus.CircleThree:SetFillColor(colour:UnpackRGB())

		LycanStatus.CircleThree.easeAnimation = LycanStatus.CircleThree.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
		LycanStatus.CircleThree.startPercent = LycanStatus.CircleThree.endPercent or 100
		LycanStatus.CircleThree.endPercent = percentage
		LycanStatus.CircleThree:StartFixedCooldown(LycanStatus.CircleThree.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
		LycanStatus.CircleThree.easeAnimation:PlayFromStart()


		-- meter circle four
		LycanStatus.CircleFour = LycanStatus.CircleFour or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_COOLDOWN) 
		LycanStatus.CircleFour:SetTexture([[EsoUI/Art/Hud/infamy_meter-bounty_px_per.dds]])
		LycanStatus.CircleFour:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
		LycanStatus.CircleFour:ClearAnchors()
		LycanStatus.CircleFour:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, 15, 15)
		LycanStatus.CircleFour:SetHidden(false)
		LycanStatus.CircleFour:SetFillColor(colour:UnpackRGB())

		LycanStatus.CircleFour.easeAnimation = LycanStatus.CircleFour.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
		LycanStatus.CircleFour.startPercent = LycanStatus.CircleFour.endPercent or 100
		LycanStatus.CircleFour.endPercent = percentage
		LycanStatus.CircleFour:StartFixedCooldown(LycanStatus.CircleFour.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
		LycanStatus.CircleFour.easeAnimation:PlayFromStart()


		-- meter circle five
		LycanStatus.CircleFive = LycanStatus.CircleFive or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_COOLDOWN) 
		LycanStatus.CircleFive:SetTexture([[EsoUI/Art/Hud/infamy_meter-bounty_px_per.dds]])
		LycanStatus.CircleFive:SetDimensions(INFAMY_METER_HEIGHT, INFAMY_METER_HEIGHT)
		LycanStatus.CircleFive:ClearAnchors()
		LycanStatus.CircleFive:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, 15, 15)
		LycanStatus.CircleFive:SetHidden(false)
		LycanStatus.CircleFive:SetFillColor(colour:UnpackRGB())

		LycanStatus.CircleFive.easeAnimation = LycanStatus.CircleFive.easeAnimation or ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_HUDInfamyMeterEasing")
		LycanStatus.CircleFive.startPercent = LycanStatus.CircleFive.endPercent or 100
		LycanStatus.CircleFive.endPercent = percentage
		LycanStatus.CircleFive:StartFixedCooldown(LycanStatus.CircleFive.startPercent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
		LycanStatus.CircleFive.easeAnimation:PlayFromStart()

		SetGradient()

		-- meter texture
		LycanStatus.Texture = LycanStatus.Texture or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_TEXTURE)
		LycanStatus.Texture:SetTexture([[EsoUI/Art/Hud/infamy_meter-frame-generic.dds]])
		LycanStatus.Texture:SetDimensions(INFAMY_METER_WIDTH, INFAMY_METER_HEIGHT)
		LycanStatus.Texture:ClearAnchors()
		LycanStatus.Texture:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, 0, 0)
		LycanStatus.Texture:SetHidden(false)

		-- meter % text 
		LycanStatus.Text = LycanStatus.Text or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_LABEL)
		local path = "$(BOLD_FONT)"
		local size = 20
		local outline = "soft-shadow-thick"
		LycanStatus.Text:SetFont(path .. "|" .. size .. "|" ..  outline)
		LycanStatus.Text:SetColor(colour:UnpackRGB())
		LycanStatus.Text:SetDimensions(50, 20)
		LycanStatus.Text:ClearAnchors()
		LycanStatus.Text:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, -125, -15)
		LycanStatus.Text:SetHidden(false)
		LycanStatus.Text.percentageGoal = percentage 
		SetPercentText()

		-- meter icon
		LycanStatus.Icon = LycanStatus.Icon or WINDOW_MANAGER:CreateControl(nil, LycanStatus, CT_TEXTURE)
		LycanStatus.Icon:SetTexture([[EsoUI/Art/Icons/store_werewolfbite_01.dds]])
		LycanStatus.Icon:SetDimensions(INFAMY_METER_HEIGHT/2, INFAMY_METER_HEIGHT/2)
		LycanStatus.Icon:ClearAnchors()
		LycanStatus.Icon:SetAnchor(BOTTOMRIGHT, LycanStatus, BOTTOMRIGHT, -17, -17) 
		LycanStatus.Icon:SetHidden(false)
	else
		if LycanStatus then
			LycanStatus:SetHidden(true)
		end
	end
end

--**************--
-- lycan Status
function MSI.InitModLycanStatus()
	local function UnRegModuleEvents()
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."ShowLycanStatus", EVENT_WEREWOLF_STATE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."PowerUpdate", EVENT_POWER_UPDATE)
	end
	local function RegModuleEvents()
		UnRegModuleEvents()
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."ShowLycanStatus", EVENT_WEREWOLF_STATE_CHANGED, ShowLycanStatus)
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."PowerUpdate", EVENT_POWER_UPDATE, function(_, unitTag, _, powerType) if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_WEREWOLF then ShowLycanAdvertisement() end end)
	end
	if MSI.SVars.IsLycanStatus and MSI.SVars.IsMSIActive then
		RegModuleEvents()
		--MSI.Print("d", "Modul enabled!! LycanStatus Event registered")
	elseif not MSI.SVars.IsLycanStatus or not MSI.SVars.IsMSIActive then
		UnRegModuleEvents()
		--MSI.Print("d", "Modul disabled!! LycanStatus Event unregistered")
	else
		UnRegModuleEvents()
		--MSI.Print("d", "MSI |c8B0000not|r Active!! LycanStatus Event unregistered")
	end
end
--eof