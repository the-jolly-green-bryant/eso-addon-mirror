CombatCrosshair = {
	name = "CombatCrosshair",
	title = "|cFF0000Combat|r Crosshair",
	version = "1.5",
	slashCommand = "/cc",

	defaults = {
		fade = true,
		hit = true,
	},	
}

local function OnAddOnLoaded(event, addonName)
	if addonName ~= CombatCrosshair.name then return end
	
	CombatCrosshair.vars = ZO_SavedVars:NewAccountWide("CombatCrosshairSavedVariables", 1, nil, CombatCrosshair.defaults, nil, "$InstallationWide")
	
	SLASH_COMMANDS[CombatCrosshair.slashCommand] = CombatCrosshair.SlashCommandHandler
	
	EVENT_MANAGER:UnregisterForEvent(CombatCrosshair.name, EVENT_ADD_ON_LOADED)
	
	RETICLE.control:UnregisterForEvent(EVENT_IMPACTFUL_HIT)
	
	EVENT_MANAGER:RegisterForEvent(CombatCrosshair.name, EVENT_PLAYER_COMBAT_STATE, CombatCrosshair.CombatState)
	EVENT_MANAGER:RegisterForEvent(CombatCrosshair.name, EVENT_IMPACTFUL_HIT, CombatCrosshair.PlayImpactfulHitAnim)
	
	CombatCrosshair.CombatFadeAnim()
	CombatCrosshair.ImpactfulHitAnim()
end

function CombatCrosshair.SlashCommandHandler(command)
	command = string.lower(command)

	if (command == "fade") then
		CombatCrosshair.vars.fade = not CombatCrosshair.vars.fade
		CHAT_ROUTER:AddSystemMessage(string.format(
			"[%s] Fade Animation: %s", CombatCrosshair.title, 
			GetString(CombatCrosshair.vars.fade and SI_CHECK_BUTTON_ON or SI_CHECK_BUTTON_OFF)
		))
	elseif (command == "hit") then
		CombatCrosshair.vars.hit = not CombatCrosshair.vars.hit
		CHAT_ROUTER:AddSystemMessage(string.format(
			"[%s] Hit Animation: %s", CombatCrosshair.title, 
			GetString(CombatCrosshair.vars.hit and SI_CHECK_BUTTON_ON or SI_CHECK_BUTTON_OFF)
		))
	else
		CHAT_ROUTER:AddSystemMessage((string.format("[%s]", CombatCrosshair.title)))
		CHAT_ROUTER:AddSystemMessage("/cc fade – Toggles Combat fade animation")
		CHAT_ROUTER:AddSystemMessage("/cc hit – Toggles Impactful hit animation")
	end
end

function CombatCrosshair.ReticleInCombat(inCombat)
	local function SetReticleColor(color)
		ZO_ReticleContainerReticle:SetColor(unpack(color))
		ZO_ReticleContainerReticle.animation0:SetEndColor(unpack(color))
		ZO_ReticleContainerReticle.animation1:SetEndColor(unpack(color))
		ZO_ReticleContainerStealthIconStealthEye:SetColor(unpack(color))
	end
	
	if inCombat then
		SetReticleColor({1,0,0,1})
	else
		SetReticleColor({1,1,1,1})
	end
end

function CombatCrosshair.CombatState(event, inCombat)
	CombatCrosshair.inCombat = inCombat
	CombatCrosshair.PlayCombatFadeAnim()
	CombatCrosshair.ReticleInCombat(inCombat)
end

function CombatCrosshair.ImpactfulHitAnim()
	local texture0 = ZO_ReticleContainerReticle
	local animation0, timeline0 = CreateSimpleAnimation(ANIMATION_COLOR, texture0, 0)
	animation0:SetEndColor(1,0,0,1)
	animation0:SetStartColor(1,1,1,0.6)
	animation0:SetEasingFunction(ZO_EaseOutQuadratic)
	animation0:SetDuration(700)
	timeline0:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
	texture0.timeline0 = timeline0
	texture0.animation0 = animation0
end

function CombatCrosshair.CombatFadeAnim()
	local texture1 = ZO_ReticleContainerReticle
	local animation1, timeline1 = CreateSimpleAnimation(ANIMATION_COLOR, texture1, 0)
	animation1:SetEndColor(1,0,0,1)
	animation1:SetStartColor(1,1,0,0.8)
	animation1:SetEasingFunction(ZO_EaseOutQuadratic)
	animation1:SetDuration(1000)
	timeline1:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
	texture1.timeline1 = timeline1
	texture1.animation1 = animation1
end

function CombatCrosshair.PlayImpactfulHitAnim()
	if CombatCrosshair.vars.hit then 
		ZO_ReticleContainerReticle.timeline0:PlayFromStart()
	end
end

function CombatCrosshair.PlayCombatFadeAnim()
	if CombatCrosshair.vars.fade then 
		ZO_ReticleContainerReticle.timeline1:PlayFromStart()
	end
end

EVENT_MANAGER:RegisterForEvent(CombatCrosshair.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)