-- DisputeReticle.lua
if MSI == nil then MSI = MSI or {} end
local MSI = _G['MSI']

local function PlayImpactfulHitAnim()
	if MSI.SVars.redReticleHit then
		ZO_ReticleContainerReticle.timeline1:PlayFromStart()
	end
end

local function PlayReticleFadeAnim()
	if MSI.SVars.redReticleFade then
		ZO_ReticleContainerReticle.timeline2:PlayFromStart()
	end
end

local function DisputeReticleState(eventCode, inRedState)
if not MSI.SVars.IsDisputeReticle then return end
	inRedState = inRedState or false
	PlayReticleFadeAnim()
	
	local function SetReticleColor(color)
		ZO_ReticleContainerReticle:SetColor(unpack(color))
		ZO_ReticleContainerReticle.animation1:SetEndColor(unpack(color))
		ZO_ReticleContainerReticle.animation2:SetEndColor(unpack(color))
		ZO_ReticleContainerStealthIconStealthEye:SetColor(unpack(color))
	end
	if not (inRedState == true) then
		SetReticleColor({1,1,1,1})
	else
		SetReticleColor({1,0,0,1})
	end
end

local function ImpactfulHitAnim()
	local texture1 = ZO_ReticleContainerReticle
	local animation1, timeline1 = CreateSimpleAnimation(ANIMATION_COLOR, texture1, 0)
	animation1:SetEndColor(1,0,0,1)
	animation1:SetStartColor(1,1,1,0.3)
	animation1:SetEasingFunction(ZO_EaseOutQuadratic)
	animation1:SetDuration(321)
	timeline1:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
	texture1.timeline1 = timeline1
	texture1.animation1 = animation1
end

local function ReticleFadeAnim()
	local texture2 = ZO_ReticleContainerReticle
	local animation2, timeline2 = CreateSimpleAnimation(ANIMATION_COLOR, texture2, 0)
	animation2:SetEndColor(1,0,0,1)
	animation2:SetStartColor(1,1,0,0.4)
	animation2:SetEasingFunction(ZO_EaseOutQuadratic)
	animation2:SetDuration(789)
	timeline2:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
	texture2.timeline2 = timeline2
	texture2.animation2 = animation2
end

--*****************--
-- Dispute Reticle
function MSI.InitModDisputeReticle()
	local function UnRegModuleEvents()
		RETICLE.control:UnregisterForEvent(EVENT_IMPACTFUL_HIT)
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."DisputeReticleState", EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."ImpactHitAnimation", EVENT_IMPACTFUL_HIT)
	end
	local function RegModuleEvents()
		UnRegModuleEvents()
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."DisputeReticleState", EVENT_PLAYER_COMBAT_STATE, DisputeReticleState)
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."ImpactHitAnimation", EVENT_IMPACTFUL_HIT, PlayImpactfulHitAnim)
	end
	if MSI.SVars.IsDisputeReticle and MSI.SVars.IsMSIActive then
		RegModuleEvents()
		ReticleFadeAnim()
		ImpactfulHitAnim()
		--MSI.Print("d", "Modul enabled!! DisputeReticle Event registered")
	elseif not MSI.SVars.IsDisputeReticle or not MSI.SVars.IsMSIActive then
		UnRegModuleEvents()
		--MSI.Print("d", "Modul disabled!! DisputeReticle Event unregistered")
	else
		UnRegModuleEvents()
		--MSI.Print("d", "MSI |c8B0000not|r Active!! DisputeReticle Event unregistered")
	end
end
--eof