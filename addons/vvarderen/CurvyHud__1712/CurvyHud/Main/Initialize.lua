--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/Main/Initialize.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

function CurvyHud:InitializeState()

	CurvyHud.state.initGone 	= ""
	CurvyHud.state.initGtow 	= ""
	CurvyHud.state.initGthree 	= ""
	CurvyHud.state.initGfour 	= ""
	CurvyHud.state.initGfive 	= ""
	CurvyHud.updateScaleReticle(false)	
	CurvyHud.state.inCombat 		= IsUnitInCombat("player")
	CurvyHud.state.mounted 			= IsMounted()
	CurvyHud.state.siege 			= IsPlayerControllingSiegeWeapon()
	CurvyHud.state.werewolf 		= CurvyHud:IsInWerewolfState()
	CurvyHud.state.inDungeon		= IsUnitInDungeon("player")	
	CurvyHud.state.playerDead 		= IsUnitDead("player")
	CurvyHud.state.inDisguise		= GetUnitDisguiseState("player")
	if (CurvyHud.state.inDisguise == 0) then
		CurvyHud.state.isDisguise 	= false
	else
		CurvyHud.state.isDisguise 	= true
	end
	CurvyHud.state.getStealthState	= GetUnitStealthState("player")
	if (CurvyHud.state.getStealthState == 0) then
		CurvyHud.state.stealthState = false
	else
		CurvyHud.state.stealthState = true
	end
	CurvyHud.state.bossHere 		= false	
	CurvyHud:InitializePlayerBars()
	CurvyHud:InitializeTargetBar()
	CurvyHud:InitializeVisualsEffect("player")
	CurvyHud:InitializeEffects("player")
	CurvyHud:ShowHud()
end

function CurvyHud:InitializeClepsydre()

	if (CurvyHud.config.clepsydre.show) then
		CurvyHud:UpdateClepsydre()
		CurvyHud.clepsydre.clockTime:SetHidden(false)
		CurvyHud.clepsydre.iconTime:SetHidden(false)
		CurvyHud.clepsydre.clockTimer:SetHidden(false)
	else
		CurvyHud.clepsydre.clockTime:SetHidden(true)
		CurvyHud.clepsydre.iconTime:SetHidden(true)
		CurvyHud.clepsydre.clockTimer:SetHidden(true)
	end
	CurvyHud.state.countButton 	= 3
	CurvyHud:UpdateChrono()
end

function CurvyHud:InitializeChrono()

	CurvyHud.state.chronoStart = "stop"
	CurvyHud.state.countButton = 2
	CurvyHud.state.bossHere = false
end

function CurvyHud:InitializeEffects(unitTag)

	local bar 			= CurvyHud.bars.targetBar
	-- Controle UnitTag
	if (unitTag == "player") then
		target 	= "player"
		bar 	= CurvyHud.bars.healthBar
		CurvyHud.playerEffects.majorResolve = false
		CurvyHud.playerEffects.majorWard = false
		CurvyHud.playerEffects.majorFracture = false
		CurvyHud.playerEffects.majorBreach = false
		CurvyHud.playerEffects.minorResolve = false
		CurvyHud.playerEffects.minorWard = false
		CurvyHud.playerEffects.minorFracture = false
		CurvyHud.playerEffects.minorBreach = false
		CurvyHud.playerEffects.isTaunted = false	
	else
		target	= "reticleover"
		bar 	= CurvyHud.bars.targetBar
		CurvyHud.targetEffects.majorResolve = false
		CurvyHud.targetEffects.majorWard = false
		CurvyHud.targetEffects.majorFracture = false
		CurvyHud.targetEffects.majorBreach = false
		CurvyHud.targetEffects.minorResolve = false
		CurvyHud.targetEffects.minorWard = false
		CurvyHud.targetEffects.minorFracture = false
		CurvyHud.targetEffects.minorBreach = false
		CurvyHud.targetEffects.isTaunted = false
	end
    local buffs 		= GetNumBuffs(target)
	local changeType	= EFFECT_RESULT_GAINED
	CurvyHud.taunt.icon:SetHidden(true)
	CurvyHud.taunt.timer:SetAlpha(0)	
	bar.majSpellResistDec:SetHidden(true)
	bar.majSpellResistInc:SetHidden(true)
	bar.majPhysResistInc:SetHidden(true)
	bar.majPhysResistDec:SetHidden(true)
	bar.minSpellResistDec:SetHidden(true)
	bar.minSpellResistInc:SetHidden(true)
	bar.minPhysResistInc:SetHidden(true)
	bar.minPhysResistDec:SetHidden(true)
	bar.majPhysResistDual:SetHidden(true)
	bar.minPhysResistDual:SetHidden(true)
	bar.majSpellResistDual:SetHidden(true)
	bar.minSpellResistDual:SetHidden(true)
	if (not CurvyHud.moveMode.enabled) then
		for i = 1, buffs do
			local _, timeStarted, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(target, i)
			if (target == "player") then
				CurvyHud:UpdatePlayerEffects(changeType, abilityId)
			elseif (target == "reticleover") then
				CurvyHud:UpdateTargetEffects(changeType, abilityId, timeStarted, timeEnding)
			end
		end
	end
end

function CurvyHud:InitializePlayerBars()

	for barName,  bar in pairs (CurvyHud.bars) do
		if (bar and barName ~= "targetBar") then
			local resource = {GetUnitPower("player", CurvyHud.barPowertypeMapping[barName])}
			local barCfg = CurvyHud.config[barName]
			if (barCfg.show or barCfg.showText) then
				if ((barName ~= "mountBar" or (barName == "mountBar" and CurvyHud.state.mounted)) and
					(barName ~= "siegeBar" or (barName == "siegeBar" and CurvyHud.state.siege)) and
					(barName ~= "werewolfBar" or (barName == "werewolfBar" and CurvyHud.state.werewolf)) 
				) then
					CurvyHud:UpdateBar(barName, resource[1], resource[3])
					CurvyHud:UpdateTextValues(barName, resource[1], resource[3])
					bar:SetHidden(not barCfg.show)
					bar.textContainer:SetHidden(not barCfg.showText)
				else
					bar:SetHidden(true)
					bar.textContainer:SetHidden(true)
				end
			else
				bar:SetHidden(true)
				bar.textContainer:SetHidden(true)
			end
		end
	end
	if (CurvyHud.state.playerDead) then
		CurvyHud:HideHudForDeathRecap(true)
	else
		CurvyHud:HideHudForDeathRecap(false)
	end
end

function CurvyHud:InitializeVisualsEffect(unitTag)

	local visuals = {GetAllUnitAttributeVisualizerEffectInfo(unitTag)}
	local stop = false
	local i = 1
	local updateFunc
	if (unitTag == "player") then
		updateFunc = function(...) CurvyHud:UpdatePlayerVisual(...) end
	elseif (unitTag == "reticleover") then
		updateFunc = function(...) CurvyHud:UpdateTargetVisual(...) end
	end
	while not stop do
		if (visuals[i] ~= nil) then
			updateFunc(true, visuals[i], visuals[i + 1], visuals[i + 2], visuals[i + 4], visuals[i + 5])
			-- We don't need visuals[i + 3]
			i = i + 6
		else
			stop = true
		end
	end	
end

function CurvyHud:IsInWerewolfState()

	local resource = {GetUnitPower("player", POWERTYPE_WEREWOLF)}
	if (resource[1] <= 0) then
		return false
	else
		return true
	end
end

function CurvyHud:InitializeMainVisuals()

	CurvyHud.visuals = {}
	CurvyHud.targetVisuals = {}
	CurvyHud.visuals.shield	= {}
	CurvyHud.visuals.shield.on = false
	CurvyHud.visuals.shield.value = 0
	CurvyHud.visuals.regen = {
		['healthBar']	= false, 
		['magickaBar']	= false, 
		['staminaBar']	= false, 
	}
	CurvyHud.visuals.degen = {
		['healthBar']	= false, 
		['magickaBar']	= false, 
		['staminaBar']	= false, 
	}
	CurvyHud.targetVisuals.shield	= {}
	CurvyHud.targetVisuals.shield.on = false
	CurvyHud.targetVisuals.shield.value = 0
	CurvyHud.targetVisuals.regen = false
	CurvyHud.targetVisuals.degen = false
end

-- Refresh GGframes by Agade
function CurvyHud.ReloadFrames()

	CurvyHud:BuildBarContainers()
	CurvyHud:InitializeState()
	CurvyHud:InitializePlayerBars()
	CurvyHud:InitializeEffects("player")
	CurvyHud:InitializeVisualsEffect("player")
	CurvyHud:InitializeTargetBar()
	CurvyHud:InitializeEffects("reticleover")
	CurvyHud:InitializeVisualsEffect("reticleover")
end

function CurvyHud:InitializeTargetBar()

	CurvyHud:InitializeVisualsEffect("reticleover")
	local isDead 	= IsUnitDead("reticleover")
	local reac		= GetUnitReaction("reticleover")
	local isPlayer	= IsUnitPlayer("reticleover")
	local isAttackabe	= IsUnitAttackable("reticleover")
	
	CurvyHud.targetVisuals.shield.on = false
	CurvyHud.targetVisuals.shield.value = 0
	CurvyHud.bars.targetBar.shield:SetHidden(true)
	CurvyHud.bars.targetBar.shield.textContainer.text:SetHidden(true)
	CurvyHud.targetVisuals.regen = false
	CurvyHud.bars.targetBar.regen:SetHidden(true)
	CurvyHud.bars.targetBar.regen.timeline:Stop()
	CurvyHud.targetVisuals.degen = false
	CurvyHud.bars.targetBar.degen:SetHidden(true)
	CurvyHud.bars.targetBar.degen.timeline:Stop()	
	CurvyHud:UpdateTargetInfos()
	
	if (not isDead) then
		local health = {GetUnitPower("reticleover",  POWERTYPE_HEALTH)}
		if (isPlayer or isAttackabe or reac == UNIT_REACTION_NEUTRAL) then

			if (health[3] >= 200) then
				if (CurvyHud.config.targetBar.show) then
					CurvyHud.bars.targetBar:SetHidden(not CurvyHud.config.targetBar.show)
					CurvyHud:UpdateBar("targetBar", health[1], health[3])	
				else
					CurvyHud.bars.targetBar:SetHidden(true)
				end
				if (CurvyHud.config.targetBar.showText) then
					CurvyHud.bars.targetBar.textContainer:SetHidden(false)
					CurvyHud:UpdateTextValues('targetBar', health[1], health[3])
				else
					CurvyHud.bars.targetBar.textContainer:SetHidden(true)
				end
				if (CurvyHud.config.targetVisuals.shield.showText) then
					CurvyHud.bars.targetBar.shield.textContainer:SetHidden(false)
					CurvyHud:UpdateTextValues("targetBar", health[1], health[3])
				else
					CurvyHud.bars.targetBar.shield.textContainer:SetHidden(true)
				end
			else
				CurvyHud.bars.targetBar:SetHidden(true)
				CurvyHud.bars.targetBar.textContainer:SetHidden(true)
				CurvyHud.bars.targetBar.shield.textContainer:SetHidden(true)
			end
		else
			CurvyHud.bars.targetBar:SetHidden(true)
			CurvyHud.bars.targetBar.textContainer:SetHidden(true)
			CurvyHud.bars.targetBar.shield.textContainer:SetHidden(true)
		end
		if(CurvyHud.config.targetNameplate.show) then
			if (health[3] >= 200) then
				CurvyHud.targetNameplate:SetHidden(false)	
			elseif (health[3] < 200 and CurvyHud.config.showCritters) then
				if (CurvyHud.state.inCombat) then
					CurvyHud.targetNameplate:SetHidden(true)
					CurvyHud.targetNameplate.level:SetHidden(true)
				else	
					CurvyHud.targetNameplate:SetHidden(false)
					CurvyHud.targetNameplate.level:SetHidden(true)
				end
			else
				CurvyHud.targetNameplate:SetHidden(true)
			end
		end	
	else
		CurvyHud.bars.targetBar:SetHidden(true)
		CurvyHud.bars.targetBar.textContainer:SetHidden(true)
		CurvyHud.bars.targetBar.shield.textContainer:SetHidden(true)		
		if (CurvyHud.config.showDead) then
			if (CurvyHud.state.inCombat) then
				CurvyHud.targetNameplate:SetHidden(true)
			else
				CurvyHud.targetNameplate:SetHidden(false)
			end
		else
			CurvyHud.targetNameplate:SetHidden(true)
		end
	end
	CurvyHud:InitializeVisualsEffect("reticleover")
	CurvyHud:InitializeEffects("reticleover")
end