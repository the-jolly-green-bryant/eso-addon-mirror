--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/Main/Updates.lua 
    Original Author	:	Vvarderen
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

function CurvyHud:UpdateLowAttribs(barName, powerValue, powerEffectiveMax)

	local cfg 			= CurvyHud.config
	local trigger 		= cfg.lowAttributes.trigger
	local lowStats 		= CurvyHud.lowAttributes
	local actualValue 	= (math.ceil(powerValue * 100 / powerEffectiveMax))
	if (barName == "healthBar") then
		-- Health Alert
		if (actualValue >= trigger) then
			lowStats.health:SetHidden(true)
		elseif (actualValue < trigger) then 
			lowStats.health:SetHidden(false)
		end
	elseif (barName == "staminaBar") then
		-- Stamina Alert
		if (actualValue >= trigger) then
			lowStats.stamina:SetHidden(true)
		elseif (actualValue < trigger) then 
			lowStats.stamina:SetHidden(false)
		end
	elseif (barName == "magickaBar") then
		--Magicka Alert
		if (actualValue >= trigger) then
			lowStats.magicka:SetHidden(true)
		elseif (actualValue < trigger) then 
			lowStats.magicka:SetHidden(false)
		end
	end
end

function CurvyHud:UpdateBar(barName, currentValue, maxValue)

	local cfg		 	= CurvyHud.config
	local bar 			= CurvyHud.bars[barName]
	local barCfg		= bar.config
	local baseTCoords 	= bar.filler.baseTextureCoords
	local baseHeight 	= bar.filler.baseHeight
	local reac			= GetUnitReaction("reticleover")
	local tVisuals		= CurvyHud.targetVisuals
	local pVisuals		= CurvyHud.visuals
	local tBar			= "targetBar"
	local speed			= 1

	-- Calculating ratio,  new height and texture height
	local ratio 		= (math.ceil((currentValue / maxValue) * 100) / 100)
	local newHeight 	= (baseHeight * ratio)
	local newTCoordTop 	= (baseTCoords[4] - (ratio * (baseTCoords[4] - baseTCoords[3])))

	if ((barName == tBar) and (((currentValue < 0) or (currentValue > maxValue)) or ((newTCoordTop <= 0.007) or (newTCoordTop >= 0.993) or (newTCoordTop == nil)))) then
		zo_callLater(function ()	CurvyHud.ReloadFrames()	end,  100)
	end
	
	local shieldValue 	= (barName == tBar and tVisuals.shield.value or pVisuals.shield.value)
	local shieldOn	 	= (barName == tBar and tVisuals.shield.on or pVisuals.shield.on)
	local shieldCfg		= (barName == tBar and cfg.targetVisuals.shield or cfg.visuals.shield)
	local shieldNewHeight 		= 0
	local shieldRatio 			= 0
	local shieldNewTCoordBottom = 0
	local shieldNewTCoordTop 	= 0
	-- Calculating ratio,  new height and texture height for the shield bar
	if(((barName =="healthBar" or barName == tBar) and shieldCfg.show) and (shieldValue > 0)) then
		shieldRatio				=  (math.ceil((shieldValue / maxValue) * 100) / 100)
		shieldNewHeight 		= baseHeight * shieldRatio
		shieldNewTCoordBottom 	= baseTCoords[3] + (shieldRatio * (baseTCoords[4] - baseTCoords[3]))
		shieldNewTCoordTop 		= newTCoordTop - (shieldRatio * (baseTCoords[4] - baseTCoords[3]))
	else
		shieldNewHeight 		= 0
		shieldRatio 			= 0
		shieldNewTCoordBottom 	= 0
		shieldNewTCoordTop 		= 0		
	end
	-- Init filler speed
	if (barName == "healthBar") then
		speed = 165
	else
		if (newTarget) then
			speed = 1
		else
			speed = 165
		end
	end
	-- Anime bars
	bar:PlayBaseAnim(barName, newHeight, newTCoordTop, shieldNewHeight, shieldNewTCoordTop, shieldNewTCoordBottom)
	-- setting new colors
	-- Note : this is not part of the animation,  as I don"t want to add more calculation to it, 
	-- As a consequence,  colors will instantly goes to the "next" value,  so not that important
	local rBar = bar.config.colorLow[1] + bar.filler.rGap * ratio
	local gBar = bar.config.colorLow[2] + bar.filler.gGap * ratio
	local bBar = bar.config.colorLow[3] + bar.filler.bGap * ratio
	local aBar = bar.config.colorLow[4] + bar.filler.aGap * ratio
	
	local rAllyBar = cfg.differentiationBar.colorLow[1] + bar.filler.rAllyGap * ratio
	local gAllyBar = cfg.differentiationBar.colorLow[2] + bar.filler.gAllyGap * ratio
	local bAllyBar = cfg.differentiationBar.colorLow[3] + bar.filler.bAllyGap * ratio
	local aAllyBar = cfg.differentiationBar.colorLow[4] + bar.filler.aAllyGap * ratio
	
	local reacR, reacG, reacB = GetUnitReactionColor("reticleover")
	local isDiff			= GetUnitDifficulty("reticleover")
	local diffBarCFG		= cfg.differentiationBar
	-- changing colors
	if (barName == tBar) then
		-- if target is an friendly Player
		if (reac == UNIT_REACTION_PLAYER_ALLY and diffBarCFG.showNPCNeutral) then
			bar.filler:SetColor(rAllyBar, gAllyBar, bAllyBar, aAllyBar)
		elseif (reac == UNIT_REACTION_NEUTRAL and (isDiff == MONSTER_DIFFICULTY_NONE or isDiff == MONSTER_DIFFICULTY_EASY) and diffBarCFG.showNPCNeutral) then
			bar.filler:SetColor(reacR-0.1, reacG-0.1, reacB-0.1, aBar)
		else
			bar.filler:SetColor(rBar, gBar, bBar, aBar)
		end
	elseif (barName ~= tBar) then
		bar.filler:SetColor(rBar, gBar, bBar, aBar)
	end
 end

-- Update the text of the given bar with the new values
function CurvyHud:UpdateTextValues(barName, currentValue, maxValue)

	local cfg 			= CurvyHud.config
	local bar 			= CurvyHud.bars[barName]
	local barCfg		= bar.config
	local percentValue 	= 0
	
	if (CurvyHud.config.showDecimal) then
		if ((currentValue > 1 ) and (((currentValue / maxValue) * 100)) ~= 100) then
			percentValue 	= string.format("%.1f", ((currentValue / maxValue) * 100))
		elseif (currentValue == maxValue) then
			percentValue 	= 100
		elseif (currentValue < 1) then
			percentValue 	= 0
		end
	else
		percentValue 	= string.format("%d", (currentValue / maxValue) * 100)
	end
	local ratio 		= (math.ceil((currentValue / maxValue) * 100) / 100)
	local reac			= GetUnitReaction("reticleover")
	
	bar.textContainer.text:SetText(CurvyHud.FormatTextValues(bar.config.textFormat, currentValue, maxValue, percentValue))
	if(barName == "healthBar") then
		if(CurvyHud.visuals.shield.on and cfg.visuals.shield.showText) then
			bar.shield.textContainer.text:SetHidden(false)
			bar.shield.textContainer.text:SetText(CurvyHud.FormatTextValues(cfg.visuals.shield.textFormat, CurvyHud.visuals.shield.value))
		else
			bar.shield.textContainer.text:SetHidden(true)
		end
	elseif(barName =="targetBar") then
		if(CurvyHud.targetVisuals.shield.on and cfg.targetVisuals.shield.showText) then
			bar.shield.textContainer.text:SetHidden(false)
			bar.shield.textContainer.text:SetText(CurvyHud.FormatTextValues(cfg.targetVisuals.shield.textFormat, CurvyHud.targetVisuals.shield.value))
		else
			bar.shield.textContainer.text:SetHidden(true)
		end
	end

	local rBar = bar.config.colorLow[1] + bar.filler.rGap * ratio
	local gBar = bar.config.colorLow[2] + bar.filler.gGap * ratio
	local bBar = bar.config.colorLow[3] + bar.filler.bGap * ratio
	local aBar = bar.config.colorLow[4] + bar.filler.aGap * ratio
	
	local rAllyBar = cfg.differentiationBar.colorLow[1] + bar.filler.rAllyGap * ratio
	local gAllyBar = cfg.differentiationBar.colorLow[2] + bar.filler.gAllyGap * ratio
	local bAllyBar = cfg.differentiationBar.colorLow[3] + bar.filler.bAllyGap * ratio
	local aAllyBar = cfg.differentiationBar.colorLow[4] + bar.filler.aAllyGap * ratio

	local reacR, reacG, reacB = GetUnitReactionColor("reticleover")
	local isDiff			= GetUnitDifficulty("reticleover")
	local diffBarCFG		= cfg.differentiationBar
	local tBar				= "targetBar"	
	
	-- changing color of text
	if (barCfg.textColor == "default") then
		bar.textContainer.text:SetColor(unpack(CurvyHud.colorTable["white"]))
	elseif (barCfg.textColor == "attribute") then
		if (barName == tBar) then
			if (reac == UNIT_REACTION_PLAYER_ALLY and diffBarCFG.showNPCNeutral) then
				bar.textContainer.text:SetColor(rAllyBar, gAllyBar, bAllyBar, aAllyBar)
			elseif (reac == UNIT_REACTION_NEUTRAL and (isDiff == MONSTER_DIFFICULTY_NONE or isDiff == MONSTER_DIFFICULTY_EASY) and diffBarCFG.showNPCNeutral) then
				bar.textContainer.text:SetColor(reacR-0.1, reacG-0.1, reacB-0.1, aBar)
			else
				bar.textContainer.text:SetColor(rBar, gBar, bBar, aBar)
			end
		elseif (barName ~= tBar) then
			bar.textContainer.text:SetColor(rBar, gBar, bBar, aBar)
		end
	end	
end

function CurvyHud:UpdateTargetNameplate()

	local cfg 			= CurvyHud.config
	local nameplate 	= CurvyHud.targetNameplate
	local nameplateCfg 	= CurvyHud.config.targetNameplate
	local target		= "reticleover"
	
	if (cfg.targetNameplate.show) then
		CurvyHud.targetNameplate:SetHidden(false)
		if (CurvyHud.moveMode.enabled) then 
			target = "player" 
		else
			target = "reticleover" 
		end

		local accuntText= zo_strformat(SI_TOOLTIP_UNIT_NAME, GetUnitDisplayName(target))
		local nameText 	= zo_strformat(SI_TOOLTIP_UNIT_NAME, GetUnitName(target))
		local captText 	= zo_strformat(SI_TOOLTIP_UNIT_CAPTION, GetUnitCaption(target))
		local reac 		= GetUnitReaction(target)
		local isPlayer 	= IsUnitPlayer(target)
		local isDiff	= GetUnitDifficulty(target)
		local isDead 	= IsUnitDead(target)
		local allianceId= GetUnitAlliance(target)
		local reacR, reacG, reacB = GetUnitReactionColor(target)
		local guard 	=  IsUnitJusticeGuard("reticleover")
			
		if (CurvyHud.state.inCombat) then
			if (guard) then
				nameplate.name:SetColor(unpack(CurvyHud.colorTable["yellow"]))
			else
				nameplate.name:SetColor(reacR, reacG, reacB, 1)
			end
		else
			nameplate.name:SetColor(reacR, reacG, reacB, 1)
		end
		-- PLAYERS
		if (isPlayer) then
			-- Choice of name (Avatar name | Account name | Avatar + Account names | Account + Avatar names) 
			if (nameplateCfg.showTypeName == "name") then
				nameplate.name:SetText(nameText)
			elseif (nameplateCfg.showTypeName == "account") then
				nameplate.name:SetText(accuntText)
			elseif (nameplateCfg.showTypeName == "allone") then
				nameplate.name:SetText(nameText..accuntText)
			elseif (nameplateCfg.showTypeName == "alltwo") then
				nameplate.name:SetText(accuntText.." ~ "..nameText)
			end
			-- Level
			local levelText = GetUnitLevel(target)
			local champText = GetUnitChampionPoints(target) 
			if (levelText < 50) then
				nameplate.level:SetColor(unpack(CurvyHud.colorTable["grass"]))
				if (nameplateCfg.level) then
					nameplate.level:SetText(levelText)
				else
					nameplate.level:SetText("")
				end
			else
				if (champText < 160) then
					nameplate.level:SetColor(unpack(CurvyHud.colorTable["sky"]))
				elseif (champText < 780) then
					nameplate.level:SetColor(unpack(CurvyHud.colorTable["mauve"]))
				elseif (champText >= 780) then
					nameplate.level:SetColor(unpack(CurvyHud.colorTable["gold"]))
				end
				if (nameplateCfg.level) then
					nameplate.level:SetText(champText)
				else
					nameplate.level:SetText("")
				end
			end
			-- Race icon & level
			local raceZOInt 	= GetUnitRaceId(target) 
			local raceString 	= CurvyHud.raceIcons[raceZOInt]		
			local raceTexture	= CurvyHud.name.."/textures/icons/"..raceString..".dds"
			if (not nameplateCfg.level and not nameplateCfg.raceIcon) then
				nameplate.raceIcon:SetHidden(true)
				nameplate.level:SetHidden(true)
				nameplate.nolevel:SetHidden(true)
			elseif (nameplateCfg.level and nameplateCfg.raceIcon) then
				nameplate.raceIcon:SetHidden(false)
				nameplate.raceIcon:SetTexture(raceTexture)
				nameplate.level:SetHidden(false)
				nameplate.nolevel:SetHidden(true)
			elseif (not nameplateCfg.level and nameplateCfg.raceIcon) then
				nameplate.raceIcon:SetHidden(true)
				nameplate.nolevel:SetHidden(false)
				nameplate.nolevel:SetTexture(raceTexture)
				nameplate.level:SetHidden(true)
			elseif (nameplateCfg.level and not nameplateCfg.raceIcon) then
				nameplate.nolevel:SetHidden(true)
				nameplate.raceIcon:SetHidden(true)
				nameplate.level:SetHidden(false)
			end
			-- Class icon & Caption
			local classId 		= GetUnitClassId(target)
			local classString 	= CurvyHud.classIcons[classId]
			local classtexture	= CurvyHud.name.."/textures/icons/"..classString..".dds"
			local titleView = GetUnitTitle(target)
			if (titleView == "" or not nameplateCfg.caption) then
				nameplate.nocaption:SetHidden(not nameplateCfg.classIcon)
				nameplate.nocaption:SetTexture(classtexture)
				nameplate.classIcon:SetHidden(true)
				nameplate.caption:SetHidden(true)
			else
				nameplate.classIcon:SetHidden(not nameplateCfg.classIcon)
				nameplate.classIcon:SetTexture(classtexture)
				nameplate.nocaption:SetHidden(true)
				nameplate.caption:SetHidden(false)
			end
			-- Alliance icon
			local allianceString = CurvyHud.allianceIcons[allianceId]
			nameplate.allianceIcon:SetHidden(not nameplateCfg.allianceIcon)
			nameplate.allianceIcon:SetTexture(CurvyHud.name.."/textures/icons/"..allianceString..".dds")
			if (allianceId == 1) then
				nameplate.avaRankIcon:SetColor(unpack(CurvyHud.colorTable["yellow"]))
			elseif (allianceId == 2) then
				nameplate.avaRankIcon:SetColor(unpack(CurvyHud.colorTable["red"]))
			elseif (allianceId == 3) then
				nameplate.avaRankIcon:SetColor(unpack(CurvyHud.colorTable["blue"]))
			end
			-- Rank icon
			local rank = GetUnitAvARank(target)
			nameplate.avaRankIcon:SetHidden(not nameplateCfg.rankIcon)
			nameplate.avaRankIcon:SetTexture(GetAvARankIcon(rank))
			-- Set caption to title & hide monster difficulty indicator
			nameplate.caption:SetText(GetUnitTitle(target))
			nameplate.monsterDiff:SetHidden(true)
			-- Choice color of icons
			if (nameplateCfg.colorIcons == "default" ) then
				nameplate.classIcon:SetColor(unpack(CurvyHud.colorTable["white"]))
				nameplate.raceIcon:SetColor(unpack(CurvyHud.colorTable["white"]))
				nameplate.nocaption:SetColor(unpack(CurvyHud.colorTable["white"]))
				nameplate.nolevel:SetColor(unpack(CurvyHud.colorTable["white"]))
			elseif (nameplateCfg.colorIcons == "gold" ) then
				nameplate.classIcon:SetColor(unpack(CurvyHud.colorTable["gold"]))
				nameplate.raceIcon:SetColor(unpack(CurvyHud.colorTable["gold"]))
				nameplate.nocaption:SetColor(unpack(CurvyHud.colorTable["gold"]))
				nameplate.nolevel:SetColor(unpack(CurvyHud.colorTable["gold"]))
			elseif (nameplateCfg.colorIcons == "silver" ) then
				nameplate.classIcon:SetColor(unpack(CurvyHud.colorTable["silver"]))
				nameplate.raceIcon:SetColor(unpack(CurvyHud.colorTable["silver"]))
				nameplate.nocaption:SetColor(unpack(CurvyHud.colorTable["silver"]))
				nameplate.nolevel:SetColor(unpack(CurvyHud.colorTable["silver"]))
			elseif (nameplateCfg.colorIcons == "alliance" ) then
				if (allianceId == 1) then -- AD YELLOW
					nameplate.classIcon:SetColor(unpack(CurvyHud.colorTable["yellow"]))
					nameplate.raceIcon:SetColor(unpack(CurvyHud.colorTable["yellow"]))
					nameplate.nocaption:SetColor(unpack(CurvyHud.colorTable["yellow"]))
					nameplate.nolevel:SetColor(unpack(CurvyHud.colorTable["yellow"]))
				elseif (allianceId == 2) then -- EP yellow
					nameplate.classIcon:SetColor(unpack(CurvyHud.colorTable["red"]))
					nameplate.raceIcon:SetColor(unpack(CurvyHud.colorTable["red"]))
					nameplate.nocaption:SetColor(unpack(CurvyHud.colorTable["red"]))
					nameplate.nolevel:SetColor(unpack(CurvyHud.colorTable["red"]))
				elseif (allianceId == 3) then -- DC BLUE
					nameplate.classIcon:SetColor(unpack(CurvyHud.colorTable["blue"]))
					nameplate.raceIcon:SetColor(unpack(CurvyHud.colorTable["blue"]))
					nameplate.nocaption:SetColor(unpack(CurvyHud.colorTable["blue"]))
					nameplate.nolevel:SetColor(unpack(CurvyHud.colorTable["blue"]))
				end
			end
		end
		--for NPC
		if (not isPlayer) then
			nameplate.level:SetHidden(true)
			nameplate.name:SetText(nameText)
			nameplate.classIcon:SetHidden(true)
			nameplate.allianceIcon:SetHidden(true)
			nameplate.avaRankIcon:SetHidden(true)
			nameplate.raceIcon:SetHidden(true)
			nameplate.nocaption:SetHidden(true)
			nameplate.nolevel:SetHidden(true)
			-- set caoptin to job
			nameplate.caption:SetText(captText)
			nameplate.caption:SetHidden(false)
			-- also add monster difficulty indicator
			nameplate.monsterDiff:SetHidden(false)
			local iconCFG = CurvyHud.textures[cfg.iconBoss]
			--Boss Deadly
			if (isDiff == MONSTER_DIFFICULTY_DEADLY) then
				nameplate.monsterDiff:SetTexture(iconCFG.deadly)
				if (reac == UNIT_REACTION_NEUTRAL or reac == UNIT_REACTION_FRIENDLY or guard == true) then
					nameplate.monsterDiff:SetColor(unpack(nameplateCfg.colorGuard))
				else
					nameplate.monsterDiff:SetColor(unpack(CurvyHud.colorTable["red"]))
				end
			-- Boss Hard
			elseif (isDiff == MONSTER_DIFFICULTY_HARD) then
				nameplate.monsterDiff:SetTexture(iconCFG.hard)
				if (reac == UNIT_REACTION_NEUTRAL or reac == UNIT_REACTION_FRIENDLY) then
					nameplate.monsterDiff:SetColor(unpack(nameplateCfg.colorGuard))
				else
					nameplate.monsterDiff:SetColor(unpack(CurvyHud.colorTable["orange"]))
				end
			-- Boss Normal
			elseif (isDiff == MONSTER_DIFFICULTY_NORMAL) then
				nameplate.monsterDiff:SetTexture(iconCFG.normal)
				if (reac == UNIT_REACTION_NEUTRAL or reac == UNIT_REACTION_FRIENDLY) then
					nameplate.monsterDiff:SetColor(unpack(nameplateCfg.colorGuard))
				else
					nameplate.monsterDiff:SetColor(unpack(CurvyHud.colorTable["yellow"]))
				end
			else
				nameplate.monsterDiff:SetTexture(iconCFG.none)
			end
			if (reac ~= nil and isDead) then
				nameplate.monsterDiff:SetColor(unpack(CurvyHud.colorTable["grey"]))
			end
		end
	else
		CurvyHud.targetNameplate:SetHidden(true)
	end
end

function CurvyHud:UpdatePlayerVisual(visualOn, unitAttributeVisual, statType, powerType, value, maxValue)

	local barName 		= CurvyHud.statTypeBarMapping[statType]
	local health = {GetUnitPower("player", CurvyHud.barPowertypeMapping["healthBar"])}
	-- SHIELD
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING) then
		if ((CurvyHud.config.visuals.shield.show and CurvyHud.config.healthBar.show) or (CurvyHud.config.visuals.shield.showText and CurvyHud.config.healthBar.showText)) then
			if(visualOn and value > 0) then
				CurvyHud.visuals.shield.value = value
				CurvyHud.bars.healthBar.shield:SetHidden(false)
				CurvyHud.visuals.shield.on = true
			else
				CurvyHud.visuals.shield.value = 0
				CurvyHud.bars.healthBar.shield:SetHidden(true)
				CurvyHud.visuals.shield.on = false
			end
			if(CurvyHud.config.visuals.shield.show and CurvyHud.config.healthBar.show) then
				CurvyHud:UpdateBar("healthBar",  health[1], health[3])
			end
			if(CurvyHud.config.visuals.shield.showText and CurvyHud.config.healthBar.showText) then
				CurvyHud:UpdateTextValues("healthBar", health[1], health[3])
			end
			CurvyHud:FadePlayerBar("healthBar", health[1], health[3])
		end
	end
	-- REGEN
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER) then
		if (CurvyHud.config[barName].show and CurvyHud.config.visuals.regen.show) then
			local regenCtrl = CurvyHud.bars[barName].regen
			if (value ~= nil and maxValue ~= nil and visualOn) then
				CurvyHud.visuals.regen[barName] = true
				-- showing the regen control
				regenCtrl:SetHidden(false)
				-- playing the animation if it"s not already playing
				if(not regenCtrl.timeline:IsPlaying()) then
					regenCtrl.timeline:PlayFromStart()
				else
					regenCtrl.timeline:SetPlaybackLoopsRemaining(100000)
				end
			else
				CurvyHud.visuals.regen[barName] = false
				regenCtrl.timeline:SetPlaybackLoopsRemaining(0)
			end
		end
	end
	-- DEGEN
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER) then
		if (CurvyHud.config[barName].show and CurvyHud.config.visuals.regen.show) then
			local degenCtrl = CurvyHud.bars[barName].degen
			if (value ~= nil and maxValue ~= nil and visualOn) then
				CurvyHud.visuals.degen[barName] = true
				-- showing the degen control
				degenCtrl:SetHidden(false)
				-- playing the animation if it"s not already playing
				if(not degenCtrl.timeline:IsPlaying()) then
					degenCtrl.timeline:PlayFromStart()
				else
					degenCtrl.timeline:SetPlaybackLoopsRemaining(100000)
				end
			else
				CurvyHud.visuals.degen[barName] = false
				degenCtrl.timeline:SetPlaybackLoopsRemaining(0)
			end
		end
	end
end

-- Update textures of effects of the target reticle bar, player healthbar and taunt 
function CurvyHud:UpdatePlayerEffects(changeType, abilityId)

	local cfg 		= CurvyHud.config
	local bar 		= CurvyHud.bars.healthBar
	local ability 	= CurvyHud.visualsEffects[abilityId]
		
	--
	-- DECREASE
	--
	-- Decrease Major Magical resist
	if (ability == "MAJOR_BREACH" and cfg.visuals.majorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.majorBreach = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.majorBreach = false
		end
	elseif (ability == "MAJOR_BREACH" and not cfg.visuals.majorEffect.decShow) then
		CurvyHud.playerEffects.majorBreach = false
	end
	-- Decrease Major Physical resist
	if (ability == "MAJOR_FRACTURE" and cfg.visuals.majorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.majorFracture = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.majorFracture = false
		end
	elseif (ability == "MAJOR_FRACTURE" and not cfg.visuals.majorEffect.decShow) then
		CurvyHud.playerEffects.majorFracture = false
	end
	-- Glyphe of Weapon (Minor Effect)
	if (ability == "MINOR_ALL" and cfg.visuals.minorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.minorBreach		= true
			CurvyHud.playerEffects.minorFracture	= true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.minorBreach		= false
			CurvyHud.playerEffects.minorFracture	= false
		end
	elseif (ability == "MINOR_ALL" and not cfg.visuals.minorEffect.decShow) then
		CurvyHud.playerEffects.minorBreach		= false
		CurvyHud.playerEffects.minorFracture	= false		
	end
	-- Decrease Minor Magical resist
	if (ability == "MINOR_BREACH"  and cfg.visuals.minorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.minorBreach = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.minorBreach = false
		end
	elseif (ability == "MINOR_BREACH"  and not cfg.visuals.minorEffect.decShow) then
		CurvyHud.playerEffects.minorBreach = false
	end
	-- Decrease Minor Physical resist
	if (ability == "MINOR_FRACTURE" and cfg.visuals.minorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.minorFracture = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.minorFracture = false
		end
	elseif (ability == "MINOR_FRACTURE" and not cfg.visuals.minorEffect.decShow) then
		CurvyHud.playerEffects.minorFracture = false
	end
	
	--
	-- INCREASE
	--
	-- Increase Major Magical resist
	if (ability == "MAJOR_WARD" and cfg.visuals.majorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.majorWard = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.majorWard = false
		end
	elseif (ability == "MAJOR_WARD" and not cfg.visuals.majorEffect.incShow) then
		CurvyHud.playerEffects.majorWard = false
	end
	-- Increase Major Physical resist
	if (ability == "MAJOR_RESOLVE" and cfg.visuals.majorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.majorResolve = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.majorResolve = false
		end
	elseif (ability == "MAJOR_RESOLVE" and not cfg.visuals.majorEffect.incShow) then
		CurvyHud.playerEffects.majorResolve = false
	end
	-- Increase Minor Magical resist
	if (ability == "MINOR_WARD" and cfg.visuals.minorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.minorWard = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.minorWard = false
		end
	elseif (ability == "MINOR_WARD" and not cfg.visuals.minorEffect.incShow) then
		CurvyHud.playerEffects.minorWard = false
	end
	-- Increase Minor Physical resist
	if (ability == "MINOR_RESOLVE" and cfg.visuals.minorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.playerEffects.minorResolve = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.playerEffects.minorResolve = false
		end
	elseif (ability == "MINOR_RESOLVE" and cfg.visuals.minorEffect.incShow) then
		CurvyHud.playerEffects.minorResolve = false
	end
	--
	-- Apply good textures
	--
	-- Major Physical resist
	if (CurvyHud.playerEffects.majorFracture and CurvyHud.playerEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(true)
		bar.majPhysResistDec:SetHidden(true)
		if (cfg.visuals.antinomic.show) then
			bar.majPhysResistDual:SetHidden(false)
		end
	elseif (CurvyHud.playerEffects.majorFracture and not CurvyHud.playerEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(true)
		bar.majPhysResistDec:SetHidden(false)
		bar.majPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.majorFracture and CurvyHud.playerEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(false)
		bar.majPhysResistDec:SetHidden(true)
		bar.majPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.majorFracture and not CurvyHud.playerEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(true)
		bar.majPhysResistDec:SetHidden(true)
		bar.majPhysResistDual:SetHidden(true)
	end
		-- Major Magickal resist
	if (CurvyHud.playerEffects.majorBreach and CurvyHud.playerEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(true)
		bar.majSpellResistDec:SetHidden(true)
		if (cfg.visuals.antinomic.show) then
			bar.majSpellResistDual:SetHidden(false)
		end
	elseif (CurvyHud.playerEffects.majorBreach and not CurvyHud.playerEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(true)
		bar.majSpellResistDec:SetHidden(false)
		bar.majSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.majorBreach and CurvyHud.playerEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(false)
		bar.majSpellResistDec:SetHidden(true)
		bar.majSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.majorBreach and not CurvyHud.playerEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(true)
		bar.majSpellResistDec:SetHidden(true)
		bar.majSpellResistDual:SetHidden(true)
	end	
	-- Minor Physical resist
	if (CurvyHud.playerEffects.minorFracture and CurvyHud.playerEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(true)
		bar.minPhysResistDec:SetHidden(true)
		if (cfg.visuals.antinomic.show) then
			bar.minPhysResistDual:SetHidden(false)
		end
	elseif (CurvyHud.playerEffects.minorFracture and not CurvyHud.playerEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(true)
		bar.minPhysResistDec:SetHidden(false)
		bar.minPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.minorFracture and CurvyHud.playerEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(false)
		bar.minPhysResistDec:SetHidden(true)
		bar.minPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.minorFracture and not CurvyHud.playerEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(true)
		bar.minPhysResistDec:SetHidden(true)
		bar.minPhysResistDual:SetHidden(true)
	end
	-- Minor Magickal resist
	if (CurvyHud.playerEffects.minorBreach and CurvyHud.playerEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(true)
		bar.minSpellResistDec:SetHidden(true)
		if (cfg.visuals.antinomic.show) then
			bar.minSpellResistDual:SetHidden(false)
		end
	elseif (CurvyHud.playerEffects.minorBreach and not CurvyHud.playerEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(true)
		bar.minSpellResistDec:SetHidden(false)
		bar.minSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.minorBreach and CurvyHud.playerEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(false)
		bar.minSpellResistDec:SetHidden(true)
		bar.minSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.playerEffects.minorBreach and not CurvyHud.playerEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(true)
		bar.minSpellResistDec:SetHidden(true)
		bar.minSpellResistDual:SetHidden(true)
	end
end

-- Update textures of effects of the target reticle bar, player healthbar and taunt 
function CurvyHud:UpdateTargetEffects(changeType, abilityId, timeStarted, timeEnding)

	local cfg 		= CurvyHud.config
	local bar 		= CurvyHud.bars.targetBar
	local ability 	= CurvyHud.visualsEffects[abilityId]
	local taunt		= CurvyHud.taunt
	local isPlayer 	= IsUnitPlayer("reticleover")
	
	--
	-- DECREASE
	--
	-- Decrease Major Magical resist
	if (ability == "MAJOR_BREACH" and cfg.targetVisuals.majorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.majorBreach = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.majorBreach = false
		end
	elseif (ability == "MAJOR_BREACH" and not cfg.targetVisuals.majorEffect.decShow) then
		CurvyHud.targetEffects.majorBreach = false
	end
	-- Decrease Major Physical resist
	if (ability == "MAJOR_FRACTURE" and cfg.targetVisuals.majorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.majorFracture = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.majorFracture = false
		end
	elseif (ability == "MAJOR_FRACTURE" and not cfg.targetVisuals.majorEffect.decShow) then
		CurvyHud.targetEffects.majorFracture = false
	end
	-- Glyphe of Weapon (Minor Effect)
	if (ability == "MINOR_ALL" and cfg.targetVisuals.minorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.minorBreach		= true
			CurvyHud.targetEffects.minorFracture	= true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.minorBreach		= false
			CurvyHud.targetEffects.minorFracture	= false
		end
	elseif (ability == "MINOR_ALL" and not cfg.targetVisuals.minorEffect.decShow) then
		CurvyHud.targetEffects.minorBreach		= false
		CurvyHud.targetEffects.minorFracture	= false		
	end
	-- Decrease Minor Magical resist
	if (ability == "MINOR_BREACH" and cfg.targetVisuals.minorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.minorBreach = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.minorBreach = false
		end
	elseif (ability == "MINOR_BREACH" and not cfg.targetVisuals.minorEffect.decShow) then
		CurvyHud.targetEffects.minorBreach = false	
	end
	-- Decrease Minor Physical resist
	if (ability == "MINOR_FRACTURE" and cfg.targetVisuals.minorEffect.decShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.minorFracture = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.minorFracture = false
		end
	elseif (ability == "MINOR_FRACTURE" and not cfg.targetVisuals.minorEffect.decShow) then
		CurvyHud.targetEffects.minorFracture = false
	end
	
	--
	-- INCREASE
	--
	-- Increase Major Magical resist
	if (ability == "MAJOR_WARD" and cfg.targetVisuals.majorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.majorWard = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.majorWard = false
		end
	elseif (ability == "MAJOR_WARD" and cfg.targetVisuals.majorEffect.incShow) then
		CurvyHud.targetEffects.majorWard = false
	end
	-- Increase Major Physical resist
	if (ability == "MAJOR_RESOLVE" and cfg.targetVisuals.majorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.majorResolve = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.majorResolve = false
		end
	elseif (ability == "MAJOR_RESOLVE" and not cfg.targetVisuals.majorEffect.incShow) then
		CurvyHud.targetEffects.majorResolve = false
	end
	-- Increase Minor Magical resist
	if (ability == "MINOR_WARD" and cfg.targetVisuals.minorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.minorWard = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.minorWard = false
		end
	elseif (ability == "MINOR_WARD" and not cfg.targetVisuals.minorEffect.incShow) then
		CurvyHud.targetEffects.minorWard = false	
	end
	-- Increase Minor Physical resist
	if (ability == "MINOR_RESOLVE" and cfg.targetVisuals.minorEffect.incShow) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.minorResolve = true
		elseif (changeType == EFFECT_RESULT_FADED) then
			CurvyHud.targetEffects.minorResolve = false
		end
	elseif (ability == "MINOR_RESOLVE" and not cfg.targetVisuals.minorEffect.incShow) then
		CurvyHud.targetEffects.minorResolve = false
	end
	--
	-- TAUNT
	--
	if (ability == "TAUNT" and cfg.targetVisuals.taunt.show) then
		if (changeType == EFFECT_RESULT_GAINED) then
			CurvyHud.targetEffects.isTaunted = true
			CurvyHud:UpdateCountTaunt(timeStarted, timeEnding)
			CurvyHud.taunt.timer:SetAlpha(1)
		elseif (changeType == EFFECT_RESULT_FADED) then
		 	CurvyHud.targetEffects.isTaunted = false
			CurvyHud.taunt.timer:SetAlpha(0)
		end
	elseif (ability == "TAUNT" and not cfg.targetVisuals.taunt.show) then
		CurvyHud.targetEffects.isTaunted = false	
	end
	--
	-- Apply good textures
	--
	-- Major Physical resist
	if (CurvyHud.targetEffects.majorFracture and CurvyHud.targetEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(true)
		bar.majPhysResistDec:SetHidden(true)
		if (cfg.targetVisuals.antinomic.show) then
			bar.majPhysResistDual:SetHidden(false)
		end
	elseif (CurvyHud.targetEffects.majorFracture and not CurvyHud.targetEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(true)
		bar.majPhysResistDec:SetHidden(false)
		bar.majPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.majorFracture and CurvyHud.targetEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(false)
		bar.majPhysResistDec:SetHidden(true)
		bar.majPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.majorFracture and not CurvyHud.targetEffects.majorResolve) then
		bar.majPhysResistInc:SetHidden(true)
		bar.majPhysResistDec:SetHidden(true)
		bar.majPhysResistDual:SetHidden(true)
	end
		-- Major Magickal resist
	if (CurvyHud.targetEffects.majorBreach and CurvyHud.targetEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(true)
		bar.majSpellResistDec:SetHidden(true)
		if (cfg.targetVisuals.antinomic.show) then
			bar.majSpellResistDual:SetHidden(false)
		end
	elseif (CurvyHud.targetEffects.majorBreach and not CurvyHud.targetEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(true)
		bar.majSpellResistDec:SetHidden(false)
		bar.majSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.majorBreach and CurvyHud.targetEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(false)
		bar.majSpellResistDec:SetHidden(true)
		bar.majSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.majorBreach and not CurvyHud.targetEffects.majorWard) then
		bar.majSpellResistInc:SetHidden(true)
		bar.majSpellResistDec:SetHidden(true)
		bar.majSpellResistDual:SetHidden(true)
	end	
	-- Minor Physical resist
	if (CurvyHud.targetEffects.minorFracture and CurvyHud.targetEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(true)
		bar.minPhysResistDec:SetHidden(true)
		if (cfg.targetVisuals.antinomic.show) then
			bar.minPhysResistDual:SetHidden(false)
		end
	elseif (CurvyHud.targetEffects.minorFracture and not CurvyHud.targetEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(true)
		bar.minPhysResistDec:SetHidden(false)
		bar.minPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.minorFracture and CurvyHud.targetEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(false)
		bar.minPhysResistDec:SetHidden(true)
		bar.minPhysResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.minorFracture and not CurvyHud.targetEffects.minorResolve) then
		bar.minPhysResistInc:SetHidden(true)
		bar.minPhysResistDec:SetHidden(true)
		bar.minPhysResistDual:SetHidden(true)
	end
	-- Minor Magickal resist
	if (CurvyHud.targetEffects.minorBreach and CurvyHud.targetEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(true)
		bar.minSpellResistDec:SetHidden(true)
		if (cfg.targetVisuals.antinomic.show) then
			bar.minSpellResistDual:SetHidden(false)
		end
	elseif (CurvyHud.targetEffects.minorBreach and not CurvyHud.targetEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(true)
		bar.minSpellResistDec:SetHidden(false)
		bar.minSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.minorBreach and CurvyHud.targetEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(false)
		bar.minSpellResistDec:SetHidden(true)
		bar.minSpellResistDual:SetHidden(true)
	elseif (not CurvyHud.targetEffects.minorBreach and not CurvyHud.targetEffects.minorWard) then
		bar.minSpellResistInc:SetHidden(true)
		bar.minSpellResistDec:SetHidden(true)
		bar.minSpellResistDual:SetHidden(true)
	end
	-- Taunt
	if (CurvyHud.targetEffects.isTaunted and not (isPlayer)) then
		taunt.icon:SetHidden(false)
	elseif (CurvyHud.targetEffects.isTaunted and (isPlayer)) then
		taunt.icon:SetHidden(true)
	end
	if (not CurvyHud.targetEffects.isTaunted) then
		taunt.icon:SetHidden(true)
	end
end

function CurvyHud:UpdateTargetVisual(visualOn, unitAttributeVisual, statType, powerType, value, maxValue)

	local health = {GetUnitPower("reticleover", POWERTYPE_HEALTH)}
	-- SHIELD
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING) then
		if ((CurvyHud.config.targetVisuals.shield.show and CurvyHud.config.targetBar.show) or (CurvyHud.config.targetVisuals.shield.showText and CurvyHud.config.targetBar.showText)) then
			if(visualOn and value >= 0) then
				CurvyHud.targetVisuals.shield.value = value
				CurvyHud.bars.targetBar.shield:SetHidden(false)
				CurvyHud.targetVisuals.shield.on = true
			else
				CurvyHud.targetVisuals.shield.value = 0
				CurvyHud.bars.targetBar.shield:SetHidden(true)
				CurvyHud.targetVisuals.shield.on = false
			end
			if (CurvyHud.config.targetVisuals.shield.show and CurvyHud.config.targetBar.show) then
				CurvyHud:UpdateBar("targetBar",  health[1], health[3])
			end
			if (CurvyHud.config.targetVisuals.shield.showText and CurvyHud.config.targetBar.showText) then
				CurvyHud:UpdateTextValues("targetBar", health[1], health[3])
			end
			CurvyHud:FadeTargetBar()
		end
	end
	-- REGEN
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER and statType == STAT_HEALTH_REGEN_COMBAT) then
		if (CurvyHud.config.targetBar.show and CurvyHud.config.targetVisuals.regen.show) then
			local regenCtrl = CurvyHud.bars.targetBar.regen
			if (value ~= nil and maxValue ~= nil and visualOn) then
				CurvyHud.targetVisuals.regen = true
				-- showing the regen control
				regenCtrl:SetHidden(false)
				-- playing the animation if it"s not already playing
				if(not regenCtrl.timeline:IsPlaying()) then
					regenCtrl.timeline:PlayFromStart()
				else
					regenCtrl.timeline:SetPlaybackLoopsRemaining(100000)
				end
			else
				CurvyHud.targetVisuals.regen = false
				regenCtrl.timeline:SetPlaybackLoopsRemaining(0)
			end
		end
	end
	-- DEGEN
	if (unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER and statType == STAT_HEALTH_REGEN_COMBAT) then
		if (CurvyHud.config.targetBar.show and CurvyHud.config.targetVisuals.regen.show) then
			local degenCtrl = CurvyHud.bars.targetBar.degen
			if (value ~= nil and maxValue ~= nil and visualOn) then
				CurvyHud.targetVisuals.degen = true
				-- showing the degen control
				degenCtrl:SetHidden(false)
				
				-- playing the animation if it's not already playing
				if(not degenCtrl.timeline:IsPlaying()) then
					degenCtrl.timeline:PlayFromStart()
				else
					degenCtrl.timeline:SetPlaybackLoopsRemaining(100000)
				end
			else
				CurvyHud.targetVisuals.degen = false
				degenCtrl.timeline:SetPlaybackLoopsRemaining(0)
			end
		end
	end
end

function CurvyHud:UpadteSightColor()

	local color = "white"
	local hidden = true
	local alpha	= 1
	local inCombat		= IsUnitInCombat("player")
	local iSiNcombat	= IsUnitInCombat("reticleover")

	function showAlert()
		if (CurvyHud.config.reticleOption.inCombat and CurvyHud.config.reticleOption.textureConfig == "CurvyReticle") then
			CurvyHud.reticle.alert:SetHidden(hidden)
		else
			CurvyHud.reticle.alert:SetHidden(true)
		end
	end
	
	if (CurvyHud.config.reticleOption.textureConfig == "CurvyReticle") then
		hidden = false
		alpha = 0		
	else
		hidden = true
		alpha = 1
	end
	if (CurvyHud.state.getStealthState == 0) then
		CurvyHud.state.stealthState = false
	else
		CurvyHud.state.stealthState = true
	end
	if (CurvyHud.state.inDisguise == 0) then
		CurvyHud.state.isDisguise = false
	else
		CurvyHud.state.isDisguise = true
	end
	if (CurvyHud.state.isDisguise and not CurvyHud.state.stealthState) then
		if (inCombat) then
			-- in Combat, disguised or not!!
			if (CurvyHud.state.inDisguise == 0 or CurvyHud.state.inDisguise == 3) then
				color = "red"
			elseif (CurvyHud.state.inDisguise == 1) then
				if (iSiNcombat) then
					color = "DarkOrange"
				else
					color = "orange"
				end
			elseif (CurvyHud.state.inDisguise == 2) then
				color = "orange"
			end
		else
			-- Disguised
			if (CurvyHud.state.inDisguise == 1) then
				color = "green"
			-- Danger!!
			elseif (CurvyHud.state.inDisguise == 2) then
				color = "orange"
			end
			ZO_ReticleContainerReticle:SetAlpha(alpha)
			ZO_ReticleContainerReticle:SetHidden(not hidden)	
		end
		showAlert()
		CurvyHud.reticle.borders:SetHidden(true)
		ZO_ReticleContainerReticle:SetAlpha(0)
		ZO_ReticleContainerReticle:SetHidden(true)		
	elseif (CurvyHud.state.stealthState and not CurvyHud.state.isDisguise) then
		if (inCombat) then
			if (CurvyHud.state.getStealthState >= 1) then
				color = "red"
			end
		else
			if (CurvyHud.state.getStealthState == 1 or CurvyHud.state.getStealthState == 2) then
				color = "yellow"
			elseif (CurvyHud.state.getStealthState == 3 or CurvyHud.state.getStealthState == 4) then
				color = "green"
			-- Danger!!
			elseif (CurvyHud.state.getStealthState == 5 or CurvyHud.state.getStealthState == 6) then
				color = "orange"
			end
		end
		showAlert()
		CurvyHud.reticle.borders:SetHidden(true)		
		ZO_ReticleContainerReticle:SetAlpha(0)
		ZO_ReticleContainerReticle:SetHidden(true)
	elseif (not CurvyHud.state.stealthState and not CurvyHud.state.isDisguise) then
		if (inCombat) then
			if (CurvyHud.state.getStealthState == 0 or CurvyHud.state.inDisguise == 0) then
				CurvyHud.reticle.borders:SetHidden(hidden)
			else
				CurvyHud.reticle.borders:SetHidden(true)
			end
			color = "red"
			showAlert()
		else
			if (CurvyHud.state.getStealthState == 0 or CurvyHud.state.inDisguise == 0) then
				CurvyHud.reticle.borders:SetHidden(hidden)
			else
				CurvyHud.reticle.borders:SetHidden(true)
			end
			CurvyHud.reticle.alert:SetHidden(true)
		end
		ZO_ReticleContainerReticle:SetAlpha(alpha)
		ZO_ReticleContainerReticle:SetHidden(not hidden)
	end
	CurvyHud:ColorCompass(color)
	CurvyHud.reticle.center:SetHidden(hidden)
end

function CurvyHud:UpadteSightChatInformations()

	if (CurvyHud.config.covertChatIndic) then
		CurvyHud.state.inDisguise		= GetUnitDisguiseState("player")
		CurvyHud.state.getStealthState	= GetUnitStealthState("player")

		local inCombat		= IsUnitInCombat("player")
		local iSiNcombat	= IsUnitInCombat("reticleover")

		if (CurvyHud.state.isDisguise and not CurvyHud.state.stealthState) then
			if (inCombat) then
				if (CurvyHud.state.inDisguise == 1 and iSiNcombat) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseDangerOff)
				elseif (CurvyHud.state.inDisguise == 1) then
					return
				elseif (CurvyHud.state.inDisguise == 4) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseOff)
				elseif (CurvyHud.state.inDisguise == 2) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseDanger)
				end
			else
				if (CurvyHud.state.inDisguise == 1) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseOn)
				elseif (CurvyHud.state.inDisguise == 0) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseOn)				
				end
			end
		end
		if (CurvyHud.state.stealthState and not CurvyHud.state.isDisguise) then
			if (inCombat) then
				if (CurvyHud.state.getStealthState == 1) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseImpossible)
				end
			else
				if (CurvyHud.state.getStealthState == 1) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDiscovered)
				elseif (CurvyHud.state.getStealthState == 3) then
					CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseOn)
				end
			end
			if (CurvyHud.state.getStealthState == 5) then
				CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyDisguiseDanger)
			end
		end
	end
end

function CurvyHud:UpdateReticleColor(inColor)

	local color = "default"
	if (inColor) then
		color = "reac"
	else
		color = "default"
	end
	
	local health	= {GetUnitPower("reticleover",  POWERTYPE_HEALTH)}
	local isDead 	= IsUnitDead("reticleover")
	
	function self()
	
		CurvyHud:ReticleColor("default")	
	end
	
	if (isDead) then
		if (CurvyHud.config.showDead) then
			if (CurvyHud.state.inCombat) then
				self()
			else
				CurvyHud:ReticleColor(color)
			end
		else
			self()	
		end
	else
		if (health[3] < 200) then
			if (CurvyHud.config.showCritters) then
				if (CurvyHud.state.inCombat) then
					self()
				else
					CurvyHud:ReticleColor(color)
				end
			else
				self()	
			end
		else
			CurvyHud:ReticleColor(color)
		end
	end
end

function CurvyHud:UpdateTargetInfos()

	local timeStart	= GetSecondsSinceMidnight()
	
	function UpdateReticleInfomation()
	
		local exist		= DoesUnitExist("reticleover")
		local reac		= GetUnitReaction("reticleover")
		if (exist) then
			local secondsSinceMidnight    = GetSecondsSinceMidnight()
			local secondsPrimaris = secondsSinceMidnight - timeStart
			local minutes	= math.floor(secondsPrimaris / 60)
			local seconds	= secondsPrimaris - (minutes * 60)
			if (CurvyHud.config.reticleOption.color) then
				CurvyHud:UpdateReticleColor(true)
			else
				CurvyHud:UpdateReticleColor(false)
			end
			if (reac == UNIT_REACTION_NEUTRAL or reac == UNIT_REACTION_FRIENDLY) then
				if (seconds < 11) then
					zo_callLater(function ()	UpdateReticleInfomation()	end,  1000)
				end
			end			
		else
			CurvyHud:UpdateReticleColor(false)
		end
		CurvyHud:UpadteSightColor()
		CurvyHud:UpdateTargetNameplate()
	end
	UpdateReticleInfomation()
end

function CurvyHud.updateScaleReticle(boolean)

	local scalingStart 	= 1
	local scalingEnd	= 1
	if (boolean) then
		scalingStart 	= 1.1
		scalingEnd		= 0.85
	else
		scalingStart 	= 0.85
		scalingEnd	 	= 1.1
	end
	function scaleReticle(scalingStart, scalingEnd)
	
		local timeline = ANIMATION_MANAGER:CreateTimeline()
		local _, point, rTo, rPt, xOffset, yOffset = CurvyHud.reticle.borders:GetAnchor()
		local scale = timeline:InsertAnimation(ANIMATION_SCALE, CurvyHud.reticle.borders)
		scale:SetScaleValues(scalingStart, scalingEnd)
		scale:SetDuration(200)
		scale:SetEasingFunction(myEasing)

		timeline:SetHandler('OnStop', 
			function()
			CurvyHud.reticle.borders:ClearAnchors()
			CurvyHud.reticle.borders:SetAnchor(point, rTo, rPt, xOffset, yOffset)
			end
		)
		timeline:PlayFromStart()
	end
	scaleReticle(scalingStart, scalingEnd)
end

function CurvyHud:UpdateCountTaunt(timeStarted, timeEnding)

	CurvyHud.state.tauntCountDisplayStart	= timeStarted
	CurvyHud.state.tauntCountDisplayStop	= timeEnding
	function self()

		local gameTimeMilliseconds 	= GetGameTimeMilliseconds()
		local gameTime 				= (gameTimeMilliseconds / 1000)
		local countTime 			= math.floor(gameTime - CurvyHud.state.tauntCountDisplayStart)
		local timeDuracy 			= math.floor(CurvyHud.state.tauntCountDisplayStop - CurvyHud.state.tauntCountDisplayStart)
		CurvyHud.state.displayCountTaunt = (timeDuracy - countTime)
		if (CurvyHud.state.displayCountTaunt < 0) then
			CurvyHud.taunt.timer:SetAlpha(0)
		end
		function count()
		
			if (CurvyHud.state.displayCountTaunt >= 0) then
				zo_callLater(function ()	self()	end,  1000)
			end
		end
		count()
		CurvyHud.taunt.timer:SetText(CurvyHud.state.displayCountTaunt)
	end
	self()
end

function CurvyHud:UpdateClepsydre()

	local secondsSinceMidnight    = GetSecondsSinceMidnight()
	local hours		= math.floor(secondsSinceMidnight  / 3600)
	local minutes	= math.floor((secondsSinceMidnight  - (hours * 3600)) / 60)
	-- Minutes Formatted correction
	local newHours	= hours <= 9 and ("0"..hours) or hours
	-- Hours Formatted correction	
	local newMinutes 	= minutes <= 9 and ("0"..minutes) or minutes
	function countClepsydre()

		zo_callLater(function ()	CurvyHud:UpdateClepsydre()	end,  1000)
	end
	CurvyHud.clepsydre.clockTime:SetText(newHours.." : "..newMinutes) -- 16 : 17
	countClepsydre()
end

function CurvyHud:UpdateChrono()

	local cfg 	=	CurvyHud.config
	if (cfg.clepsydre.show) then	
		CurvyHud.state.countButton = CurvyHud.state.countButton + 1
		if (CurvyHud.state.countButton > 2) then
			CurvyHud.state.countButton = 0
		end
		local timeStart	= GetTimeStamp()
		CurvyHud.state.animIcon 	= 0
		CurvyHud.state.animChronoT 	= 0		
		-- Chrono settings
		function configChrono()
		
			if (cfg.clepsydre.show) then
				local newStartTime    = GetTimeStamp()
				local secondsPrimaris = newStartTime - timeStart
				local hours		= math.floor(secondsPrimaris / 3600)
				local minutes	= math.floor(secondsPrimaris / 60)
				local seconds	= secondsPrimaris - (minutes * 60)
				-- Seconds Formatted correction
				newSeconds = seconds <= 9 and ("0"..seconds) or seconds
				-- Minutes Formatted correction
				newMinutes = minutes <= 9 and ("0"..minutes) or minutes
				-- Hours Formatted correction
				newHours = hours <= 9 and ("0"..hours) or hours				
				-- update table
				CurvyHud.state.chronoSeconds	= newSeconds
				CurvyHud.state.chronoMinutes	= newMinutes
				CurvyHud.state.chronoHours		= newHours
				CurvyHud.state.animIcon = CurvyHud.state.animIcon + 1
				if (CurvyHud.state.animIcon >= 2) then
					CurvyHud.state.animIcon = 0
				end
				if (CurvyHud.state.animIcon == 1) then
					CurvyHud.clepsydre.iconTime:SetHidden(false)
				else
					CurvyHud.clepsydre.iconTime:SetHidden(true)
				end
				if (CurvyHud.state.chronoStart == "start") then
					CurvyHud.clepsydre.iconTime:SetColor(unpack(CurvyHud.colorTable["pureRed"]))
					function count()
						if (CurvyHud.config.clepsydre.show) then
							zo_callLater(function ()	configChrono()	end,  1000)
						end
					end
					count()
					CurvyHud.clepsydre.clockTimer:SetHidden(false)
					CurvyHud.clepsydre.clockTimer:SetText(CurvyHud.state.chronoHours.."|cFFFFFF : "..CurvyHud.state.chronoMinutes.." ' "..CurvyHud.state.chronoSeconds)
				end	
				if (CurvyHud.state.chronoStart == "pause") then
					CurvyHud.clepsydre.iconTime:SetColor(unpack(CurvyHud.colorTable["orange"]))		
					CurvyHud.clepsydre.iconTime:SetHidden(false)
					seconds = seconds - 1
					CurvyHud.clepsydre.clockTimer:SetHidden(false)
					if (cfg.clepsydre.chronoTurnSignal) then
						
						function AnimChronoModule()
							CurvyHud.state.animChrono = CurvyHud.state.animChrono + 1
							CurvyHud.state.animChronoT = CurvyHud.state.animChronoT + 1
							if (CurvyHud.state.animChrono >= 2) then
								CurvyHud.state.animChrono = 0
							end
							if (CurvyHud.state.animChrono == 1) then
								CurvyHud.clepsydre.clockTimer:SetHidden(false)
							else
								CurvyHud.clepsydre.clockTimer:SetHidden(true)
							end
							if (CurvyHud.state.animChronoT == 7) then 
								CurvyHud.clepsydre.iconTime:SetColor(unpack(CurvyHud.colorTable["pureYellow"]))
							end							
							function UpdateAnimChrono()
							
								if (CurvyHud.state.animChronoT <= 5) then
									zo_callLater(function () AnimChronoModule()	end,  1000)
								end
							end
						UpdateAnimChrono()
						end
						AnimChronoModule()
					end
					if (cfg.clepsydre.automaticChrono == "auto" or CurvyHud.config.clepsydre.automaticChrono == "sp") then
					
						function stopChrono()
				
							CurvyHud.state.chronoStart = "stop"
							CurvyHud.state.countButton = 0
							CurvyHud.state.animChronoT = 0
							configChrono()
						end
						if (CurvyHud.state.animChronoT == 7) then 
							stopChrono()
						end
					end
				end
				if (CurvyHud.state.chronoStart == "stop") then
					CurvyHud.clepsydre.iconTime:SetColor(unpack(CurvyHud.colorTable["white"]))
					CurvyHud.clepsydre.iconTime:SetHidden(false)
					CurvyHud.clepsydre.clockTimer:SetHidden(true)
					CurvyHud.state.animChronoT  = 0
					CurvyHud.state.countButton  = 0
					CurvyHud.state.animChrono	= 0
				end
			end
		end

		local L = CurvyHud:GetLoc()
		if (CurvyHud.state.countButton == 1) then
			CurvyHud.state.chronoStart = "start"
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.ClepsydreChronoStart)
		elseif (CurvyHud.state.countButton == 2) then
			CurvyHud.state.chronoStart = "pause"
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.ClepsydreChronoRAZ1)
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.ClepsydreChronoResult..CurvyHud.state.chronoHours.."|cFFFFFF : |cFF9500"..CurvyHud.state.chronoMinutes.."|cFFFFFF ' |cFF9500"..CurvyHud.state.chronoSeconds.."|cFFFFFF ''")
		elseif (CurvyHud.state.countButton == 0) then
			CurvyHud.state.chronoStart = "stop"
			CurvyHud:OnChatChronoMode()
		end
		configChrono()
	end
end

function CurvyHud:OnLinePlayers(guildId, displayName, newStatus)

    for i = 1, GetNumGuilds() do
		local gName = GetGuildName(guildId)
		function self(i, gName, guildId, displayName, newStatus)

			local cfg = CurvyHud.config
			if ((cfg.guildOne == true) and (i == 1)) then
				CurvyHud:goodGuild(i, gName, guildId, displayName, newStatus)
			elseif ((cfg.guildTow == true) and (i == 2)) then
				CurvyHud:goodGuild(i, gName, guildId, displayName, newStatus)
			elseif ((cfg.guildThree == true) and (i == 3)) then
				CurvyHud:goodGuild(i, gName, guildId, displayName, newStatus)
			elseif ((cfg.guildFour == true) and (i == 4)) then
				CurvyHud:goodGuild(i, gName, guildId, displayName, newStatus)
			elseif ((cfg.guildFive == true) and (i == 5)) then
				CurvyHud:goodGuild(i, gName, guildId, displayName, newStatus)
			end
		end
		self(i,gName,guildId, displayName, newStatus)
	end
end

function CurvyHud:goodGuild(i, gName, guildId, displayName, newStatus)

	local L 	= CurvyHud:GetLoc()
	local _, gAvatar	= GetGuildMemberCharacterInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, displayName))
	local formatedAvatarName	= zo_strformat(SI_TOOLTIP_UNIT_NAME, gAvatar)
	local accountGMate	= zo_strformat(SI_TOOLTIP_UNIT_NAME, displayName)
	local accountPlayer	= GetUnitDisplayName("player")
	local guildName	= gName
	if (GetGuildId(i) == guildId) then

		if ((displayName == accountPlayer) or (CurvyHud.state.friends == displayName)) then
			return	
		end

		local text = L.CurvyHudinfo..L.gMateArrival..accountGMate.."|cFFFFFF (|cFF9500"..formatedAvatarName.."|cFFFFFF)".." - |c3cc23e"..guildName		
		if (newStatus == 1) then
			CHAT_SYSTEM:AddMessage(text..L.gMateOnLine)
		elseif (newStatus == 2) then
			CHAT_SYSTEM:AddMessage(text..L.gMateABS)	
		elseif (newStatus == 3) then
			CHAT_SYSTEM:AddMessage(text..L.gMateNotDisturb)	
		elseif (newStatus == 4) then
			CHAT_SYSTEM:AddMessage(text..L.gMateOffLine)
		end
	end
end