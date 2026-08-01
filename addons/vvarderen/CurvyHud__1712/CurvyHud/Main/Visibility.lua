--[[----------------------------------------------------------
    CurvyHud
    ----------------------------------------------------------
	Localization 	: 	/Main/Visibility.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

function CurvyHud:ToggleDefaultPlayerFrameHide()

	ZO_PlayerAttributeHealth:SetHidden(CurvyHud.config.healthBar.show)
	ZO_PlayerAttributeStamina:SetHidden(CurvyHud.config.staminaBar.show)
	ZO_PlayerAttributeMagicka:SetHidden(CurvyHud.config.magickaBar.show)
	ZO_PlayerAttributeMountStamina:SetHidden(CurvyHud.config.mountBar.show)
	ZO_PlayerAttributeWerewolf:SetHidden(CurvyHud.config.werewolfBar.show)
	ZO_PlayerAttributeSiegeHealth:SetHidden(CurvyHud.config.siegeBar.show)
end

function CurvyHud:ToggleCombatCompass()
	
	ZO_CompassContainer:SetHidden(not CurvyHud.config.compass.show)
	ZO_CompassAreaOverrideLabel:SetHidden(not CurvyHud.config.compass.show)

	ZO_BossBarHealthBarLeft:SetHidden(not CurvyHud.config.compass.boss)
	ZO_BossBarHealthBarRight:SetHidden(not CurvyHud.config.compass.boss)
	ZO_BossBarHealthBarLeftGloss:SetHidden(not CurvyHud.config.compass.boss)
	ZO_BossBarHealthBarRightGloss:SetHidden(not CurvyHud.config.compass.boss)
	ZO_BossBarHealthText:SetHidden(not CurvyHud.config.compass.boss)

	ZO_CompassFrameLeft:SetHidden(CurvyHud.config.compass.notexture)
	ZO_CompassFrameCenter:SetHidden(CurvyHud.config.compass.notexture)
	ZO_CompassFrameRight:SetHidden(CurvyHud.config.compass.notexture)
	ZO_BossBarBracketLeft:SetHidden(CurvyHud.config.compass.notexture)
	ZO_BossBarBracketRight:SetHidden(CurvyHud.config.compass.notexture)

	ZO_CompassCenterOverPinLabel:SetHidden(not CurvyHud.config.compass.show)
end

function CurvyHud:ToggleReticleOption()
	
	-- Label to Hidden/discovered on reticle
	ZO_ReticleContainerStealthIconStealthText:SetHidden(CurvyHud.config.reticleOption.hidden)
	-- Label when the player id hidden and stealth loot
	ZO_LootStealthIconStealthText:SetHidden(CurvyHud.config.reticleOption.hidden)
	-- Label when the player id hidden and stealth chest
	ZO_LockpickPanelStealthIconStealthText:SetHidden(CurvyHud.config.reticleOption.hidden)
end

function CurvyHud:ToggleDefaultTargetFrame()

	CurvyHud.targetNameplate:SetHidden(not CurvyHud.config.targetNameplate.show)
	ZO_TargetUnitFramereticleover:SetHidden(CurvyHud.config.targetBar.show)
end

function CurvyHud:ZoCombatTips()

	ZO_ActiveCombatTipsTipIcon:SetHidden(CurvyHud.config.combatTips.zoShow)
	ZO_ActiveCombatTipsTipTipText:SetHidden(CurvyHud.config.combatTips.zoShow)
end

-- Original mode by GetBackYouPansy named "PL Combat Indicator" (thanks to him)
function CurvyHud:ColorCompass(color)

	CurvyHud.reticle.alert:SetColor(unpack(CurvyHud.colorTable[color]))
	if (CurvyHud.config.compass.inCombat) then
		color = color
	else
		color = "white"
	end
	ZO_CompassFrameLeft:SetColor(unpack(CurvyHud.colorTable[color]))
	ZO_CompassFrameCenter:SetColor(unpack(CurvyHud.colorTable[color]))
	ZO_CompassFrameRight:SetColor(unpack(CurvyHud.colorTable[color]))

	for i = 1, _G["ZO_CompassContainer"]:GetNumChildren() do
	local areaTexture = _G["ZO_CompassAreaTexture" .. i]
		if areaTexture then
			areaTexture.left:SetColor(unpack(CurvyHud.colorTable[color]))
			areaTexture.center:SetColor(unpack(CurvyHud.colorTable[color]))
			areaTexture.right:SetColor(unpack(CurvyHud.colorTable[color]))
		end
	end
	
	local sat	= 0
	local alpha	= 0
	if (CurvyHud.config.compass.colorVisibility) then
		sat 	= -0.7
		aplha 	= 0.4
	else
		sat		= 0
		alpha	= 0
	end
	ZO_CompassFrameCenter:SetDesaturation(sat)
	ZO_CompassFrameLeft:SetDesaturation(sat)
	ZO_CompassFrameRight:SetDesaturation(sat)
	ZO_CompassFrameCenterBottomMungeOverlay:SetAlpha(alpha)    
	ZO_CompassFrameCenterTopMungeOverlay:SetAlpha(alpha)
end

function CurvyHud:FadePlayerBar(barName, value, maxValue)

	local bar  	= CurvyHud.bars[barName]
	local alpha = 0
	if (CurvyHud.state.inCombat) then
		alpha 	= CurvyHud.config.combatAlpha 
	else
		if (value == nil or maxValue == nil) then
			local attribute =  {GetUnitPower("player", CurvyHud.barPowertypeMapping[barName])}
			value 		= attribute[1]
			maxValue 	= attribute[3]
		end		
		if (value < maxValue or (barName == "healthBar" and CurvyHud.visuals.shield.on)) then
			alpha = CurvyHud.config.attributeUsedAlpha
		else
			alpha = CurvyHud.config.oocAlpha
		end
	end
	bar:SetAlpha(alpha)
	bar.textContainer:SetAlpha(alpha)
	bar.regen:SetGradientColors(ORIENTATION_VERTICAL,
		1,1,1,0,
		1,1,1,alpha
	)
	bar.degen:SetGradientColors(ORIENTATION_VERTICAL,
		1,1,1,0,
		1,1,1,alpha
	)
end

function CurvyHud:ReticleColor(color)

	local reacR, reacG, reacB = GetUnitReactionColor("reticleover")
	local guard =  IsUnitJusticeGuard("reticleover")
	function isGuard()
		if (CurvyHud.config.reticleOption.textureConfig == "default") then
			ZO_ReticleContainerReticle:SetColor(unpack(CurvyHud.config.targetNameplate.colorGuard))
			CurvyHud.reticle.center:SetHidden(true)
		elseif (CurvyHud.config.reticleOption.textureConfig == "CurvyReticle") then
			CurvyHud.reticle.center:SetColor(unpack(CurvyHud.config.targetNameplate.colorGuard))
			CurvyHud.reticle.borders:SetColor(unpack(CurvyHud.config.targetNameplate.colorGuard))
		end
	end
	if (color == "reac") then
		if (guard) then
			isGuard()
		else
			if (CurvyHud.config.reticleOption.textureConfig == "default") then
				ZO_ReticleContainerReticle:SetColor(reacR, reacG, reacB, 1)
				CurvyHud.reticle.center:SetHidden(true)
			elseif (CurvyHud.config.reticleOption.textureConfig == "CurvyReticle") then
				CurvyHud.reticle.center:SetColor(reacR, reacG, reacB, 1)
				CurvyHud.reticle.borders:SetColor(reacR, reacG, reacB, 1)
			end
		end		
	else
		if (CurvyHud.config.reticleOption.textureConfig == "default") then
			ZO_ReticleContainerReticle:SetColor(unpack(CurvyHud.colorTable["whiteReticle"]))
		elseif (CurvyHud.config.reticleOption.textureConfig == "CurvyReticle") then
			CurvyHud.reticle.center:SetColor(unpack(CurvyHud.colorTable["whiteReticle"]))
			CurvyHud.reticle.borders:SetColor(unpack(CurvyHud.colorTable["whiteReticle"]))
		end
	end	
end

function CurvyHud:FadeTargetBar()

	local alpha 	= 1
	local reac 		= GetUnitReaction("reticleover")
	local checkExist= DoesUnitExist("reticleover")
	local isPlayer	= IsUnitPlayer("reticleover")
	local inCombat	= IsUnitInCombat("reticleover")
	if (checkExist) then
		if (not CurvyHud.state.inCombat) then
			if (inCombat) then
				if (reac == UNIT_REACTION_NEUTRAL or reac == UNIT_REACTION_HOSTILE) then
					alpha = CurvyHud.config.targetinCombatAlpha
				elseif (reac == UNIT_REACTION_PLAYER_ALLY) then
					alpha = CurvyHud.config.targetinCombatAlpha
				else
				alpha = CurvyHud.config.oocAlpha
				end
			else
				if (reac == UNIT_REACTION_NEUTRAL or reac == UNIT_REACTION_HOSTILE or reac == UNIT_REACTION_PLAYER_ALLY) then
					alpha = CurvyHud.config.targetOocAlpha
				else
				alpha = CurvyHud.config.oocAlpha
				end
			end	
		else
			alpha = CurvyHud.config.combatAlpha
		end
	else
		alpha = 0
	end
	CurvyHud.bars.targetBar:SetAlpha(alpha)
	CurvyHud.bars.targetBar.textContainer:SetAlpha(alpha)
	CurvyHud.bars.targetBar.shield.textContainer:SetAlpha(alpha)
	CurvyHud.bars.targetBar.regen:SetGradientColors(ORIENTATION_VERTICAL, 
		1, 1, 1, 0, 
		1, 1, 1, alpha
	)
	CurvyHud.bars.targetBar.degen:SetGradientColors(ORIENTATION_VERTICAL, 
		1, 1, 1, 0, 
		1, 1, 1, alpha
	)
end

-- Show HUD and fades all controls to their appropriate opacity 
function CurvyHud:ShowHud()

	local cfg 		= CurvyHud.config
	local tips 		= CurvyHud.combatTips
	local lowAtt 	= CurvyHud.lowAttributes
	local pBar		= CurvyHud.bars.healthBar
	local tBar		= CurvyHud.bars.targetBar
	if (CurvyHud.moveMode.enabled) then
		for barName, bar in pairs(CurvyHud.bars) do
			bar:SetHidden(not bar.config.show)
			bar.textContainer:SetHidden(not bar.config.showText)
			bar:SetAlpha(1)
			bar.textContainer:SetAlpha(1)
		end
		tBar.shield.textContainer:SetHidden(false)
		tBar.shield.textContainer:SetAlpha(1)
		CurvyHud.targetNameplate:SetHidden(not cfg.targetNameplate.show)
		CurvyHud.targetNameplate.level:SetHidden(not cfg.targetNameplate.level)
		lowAtt.health:SetHidden(not cfg.lowAttributes.show)
		lowAtt.stamina:SetHidden(not cfg.lowAttributes.show)
		lowAtt.magicka:SetHidden(not cfg.lowAttributes.show)
		CurvyHud.interactionPrompt.text:SetHidden(false)
		CurvyHud.playerinteractionPrompt.text:SetHidden(false)
		tips.block:SetHidden(not cfg.combatTips.show)
		tips.exploit:SetHidden(not cfg.combatTips.show)
		tips.interrupt:SetHidden(not cfg.combatTips.show)
		tips.dodge:SetHidden(not cfg.combatTips.show)
		-- Init factices values and conditions of shields
		if (cfg.effects.showdemobars) then
			if (cfg.visuals.shield.show or cfg.visuals.shield.showText) then
				CurvyHud.visuals.shield.on = true
				CurvyHud.visuals.shield.value = 4560
			else
				CurvyHud.visuals.shield.on = false
				CurvyHud.visuals.shield.value = 0
			end
			if (cfg.targetVisuals.shield.show or cfg.targetVisuals.shield.showText) then
				CurvyHud.targetVisuals.shield.on = true
				CurvyHud.targetVisuals.shield.value = 4560
			else
				CurvyHud.targetVisuals.shield.on = false	
				CurvyHud.targetVisuals.shield.value = 0
			end
			-- Simulate alterated bars
			health = {GetUnitPower("player",  POWERTYPE_HEALTH)}
			CurvyHud:UpdateTextValues("targetBar", math.ceil(health[1] * 0.5), health[3])
			CurvyHud:UpdateTextValues("healthBar", math.ceil(health[1] * 0.5), health[3])
			CurvyHud:UpdateBar("targetBar", math.ceil(health[1] * 0.5), health[3])
			CurvyHud:UpdateBar("healthBar", math.ceil(health[1] * 0.5), health[3])
			-- Active new effects on the bars
			CurvyHud:BuildBar("healthBar")
			CurvyHud:BuildBar("targetBar")	
		else
			CurvyHud.targetVisuals.shield.on = false	
			CurvyHud.targetVisuals.shield.value = 0	
			CurvyHud.visuals.shield.on = false
			CurvyHud.visuals.shield.value = 0	
			health = {GetUnitPower("player",  POWERTYPE_HEALTH)}
			CurvyHud:UpdateTextValues("targetBar", health[1], health[3])
			CurvyHud:UpdateTextValues("healthBar", health[1], health[3])
			CurvyHud:UpdateBar("targetBar", health[1], health[3])
			CurvyHud:UpdateBar("healthBar", health[1], health[3])
		end
		-- Show Increase Major Physical resist
		pBar.majPhysResistInc:SetHidden(not cfg.effects.showMajPhysResistInc)
		tBar.majPhysResistInc:SetHidden(not cfg.effects.showMajPhysResistInc)
		-- Show Increase Major Speel resist		
		tBar.majSpellResistInc:SetHidden(not cfg.effects.showMajSpellResistInc)
		pBar.majSpellResistInc:SetHidden(not cfg.effects.showMajSpellResistInc)			
		-- Show Decrease Major Physical resist
		tBar.majPhysResistDec:SetHidden(not cfg.effects.showMajPhysResistDec)
		pBar.majPhysResistDec:SetHidden(not cfg.effects.showMajPhysResistDec)
		-- Show Decreaser Major speel resist
		pBar.majSpellResistDec:SetHidden(not cfg.effects.showMajSpellResistDec)	
		tBar.majSpellResistDec:SetHidden(not cfg.effects.showMajSpellResistDec)	
		-- Show Increase Minor Physical resist
		pBar.minPhysResistInc:SetHidden(not cfg.effects.showMinPhysResistInc)
		tBar.minPhysResistInc:SetHidden(not cfg.effects.showMinPhysResistInc)
		-- Show Increase Minor Speel resist		
		tBar.minSpellResistInc:SetHidden(not cfg.effects.showMinSpellResistInc)
		pBar.minSpellResistInc:SetHidden(not cfg.effects.showMinSpellResistInc)		
		-- Show Decrease Minor Physical resist
		tBar.minPhysResistDec:SetHidden(not cfg.effects.showMinPhysResistDec)
		pBar.minPhysResistDec:SetHidden(not cfg.effects.showMinPhysResistDec)
		-- Show Decreaser Minor speel resist
		pBar.minSpellResistDec:SetHidden(not cfg.effects.showMinSpellResistDec)	
		tBar.minSpellResistDec:SetHidden(not cfg.effects.showMinSpellResistDec)	
		-- Show Major Antinmoc Physical
		tBar.majPhysResistDual:SetHidden(not cfg.effects.showMajPhysResistDual)
		pBar.majPhysResistDual:SetHidden(not cfg.effects.showMajPhysResistDual)
		-- Show Minor Antinomic Physical
		pBar.minPhysResistDual:SetHidden(not cfg.effects.showMinPhysResistDual)	
		tBar.minPhysResistDual:SetHidden(not cfg.effects.showMinPhysResistDual)	
		-- Show Major Antinmoc Speel
		tBar.majSpellResistDual:SetHidden(not cfg.effects.showMajSpellResistDual)
		pBar.majSpellResistDual:SetHidden(not cfg.effects.showMajSpellResistDual)
		-- Show Minor Antinomic Speel
		pBar.minSpellResistDual:SetHidden(not cfg.effects.showMinSpellResistDual)	
		tBar.minSpellResistDual:SetHidden(not cfg.effects.showMinSpellResistDual)	
		if (CurvyHud.config.reticleOption.textureConfig == "CurvyReticle") then
			hiddenOne 	= false
			hiddenTwo 	= true
			alphaOne	= 0
		else
			hiddenOne 	= true
			hiddenTwo 	= false
			alphaOne	= 1	
		end
		CurvyHud.reticle.center:SetHidden(hiddenOne)
		CurvyHud.reticle.borders:SetHidden(hiddenOne)
		ZO_ReticleContainerReticle:SetAlpha(alphaOne)
		ZO_ReticleContainerReticle:SetHidden(hiddenTwo)
		CurvyHud.taunt.icon:SetHidden(not cfg.targetVisuals.taunt.show)
		CurvyHud.taunt.timer:SetAlpha(0)		
		if  (CurvyHud.config.reticleOption.color) then
			colorOne = "green"
		else
			colorOne = "whiteReticle"
		end
		CurvyHud.reticle.center:SetColor(unpack(CurvyHud.colorTable[colorOne]))
		CurvyHud.reticle.borders:SetColor(unpack(CurvyHud.colorTable[colorOne]))
		ZO_ReticleContainerReticle:SetColor(unpack(CurvyHud.colorTable[colorOne]))
		if (CurvyHud.config.reticleOption.inCombat) then
			CurvyHud.reticle.alert:SetColor(unpack(CurvyHud.colorTable["green"]))
			CurvyHud.reticle.alert:SetHidden(false)
		else
			CurvyHud.reticle.alert:SetHidden(true)
		end
		-- Show factice HUD
		CurvyHud:HideHud(false)
	else
		-- Init states and effects
		CurvyHud:InitializeMainVisuals()
		-- hidde other element
		CurvyHud.interactionPrompt.text:SetHidden(true)
		CurvyHud.playerinteractionPrompt.text:SetHidden(true)
		tips.block:SetHidden(true)
		tips.exploit:SetHidden(true)
		tips.interrupt:SetHidden(true)
		tips.dodge:SetHidden(true)
		lowAtt.health:SetHidden(true)
		lowAtt.stamina:SetHidden(true)
		lowAtt.magicka:SetHidden(true)
		-- taunt 
		CurvyHud.taunt.icon:SetHidden(true)
		CurvyHud.taunt.timer:SetAlpha(0)		
		CurvyHud.state.mounted 			= IsMounted()
		if (CurvyHud.state.mounted) then
			CurvyHud.bars.mountBar:SetHidden(not CurvyHud.config.mountBar.show)
			CurvyHud.bars.mountBar.textContainer:SetHidden(not CurvyHud.config.mountBar.showText)
		else
			CurvyHud.bars.mountBar:SetHidden(true)
			CurvyHud.bars.mountBar.textContainer:SetHidden(true)
		end
		CurvyHud:UpadteSightColor()
		CurvyHud.OnReticleTarget(131118)
		CurvyHud:InitializePlayerBars()
		-- 'normal' mode,  we just fade all the player bars to appropriate opacity, 
		for barName, bar in pairs (CurvyHud.bars) do
			if(barName ~= "targetBar") then -- target bar is taken care of elsewhere
				CurvyHud:FadePlayerBar(barName)
			else
				CurvyHud:FadeTargetBar()
			end
		end
	end	
end

-- Toggle HUD visibility
function CurvyHud:HideHud(hide)

	CurvyHud.topControl:SetHidden(hide)
	if (hide) then
		CurvyHud.reticle:SetHidden(true)
		ZO_ReticleContainerReticle:SetHidden(true)			
		ZO_ReticleContainerReticle:SetAlpha(0)
	else
		if (CurvyHud.config.reticleOption.textureConfig == "CurvyReticle") then
			hidden 	= false
			alpha	= 0
		else
			hidden 	= true
			alpha	= 1	
		end
	CurvyHud.reticle:SetHidden(hidden)
	ZO_ReticleContainerReticle:SetHidden(not hidden)
	ZO_ReticleContainerReticle:SetAlpha(alpha)
	CurvyHud:UpdateTargetInfos()
	end
end

function CurvyHud:HideHudForDeathRecap(hide)

	if (hide) then
		EVENT_MANAGER:RegisterForUpdate('deathRecap',  100,  
			function()
			CurvyHud.OnReticleHidden(0, (not ZO_DeathRecap:IsHidden()) or IsReticleHidden())
				for barName, bar in pairs(CurvyHud.bars) do
					if (bar and barName ~= 'targetBar') then
						bar:SetHidden(true)
						bar.textContainer:SetHidden(true)
					end
				end
				CurvyHud:ToggleDefaultTargetFrame()
			CurvyHud.lowAttributes:SetHidden(true)
			CurvyHud.combatTips:SetHidden(true)
			end
		)	
	else
		EVENT_MANAGER:UnregisterForUpdate('deathRecap')
	end
end