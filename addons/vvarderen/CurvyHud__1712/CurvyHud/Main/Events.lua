--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/Main/Events.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

function CurvyHud:RegisteringEvents()

	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_RETICLE_TARGET_CHANGED			, CurvyHud.OnReticleTarget)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_RETICLE_HIDDEN_UPDATE				, CurvyHud.OnReticleHidden)
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_STEALTH_STATE_CHANGED 			, CurvyHud.OnStealthStateChanged)	
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_POWER_UPDATE						, CurvyHud.OnPowerUpdated)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED		, CurvyHud.OnVisualChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED		, CurvyHud.OnVisualChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED		, CurvyHud.OnVisualChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_EFFECT_CHANGED 					, CurvyHud.OnEffectChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_PLAYER_COMBAT_STATE				, CurvyHud.OnCombatStateChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_DISGUISE_STATE_CHANGED			, CurvyHud.OnDisguiseStateChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_DISPLAY_ACTIVE_COMBAT_TIP			, CurvyHud.OnCombatTips)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_MOUNTED_STATE_CHANGED				, CurvyHud.OnMountedStateChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_WEREWOLF_STATE_CHANGED			, CurvyHud.OnWerewolfStateChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_BEGIN_SIEGE_CONTROL				, CurvyHud.OnSiegeStateChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_END_SIEGE_CONTROL					, CurvyHud.OnSiegeStateChanged)	
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_PLAYER_DEAD						, CurvyHud.OnPlayerDead)
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_ACTIVE_WEAPON_PAIR_CHANGED		, CurvyHud.OnWeaponBarSwitched)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_PLAYER_ALIVE						, CurvyHud.OnPlayerAlive)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_PLAYER_ACTIVATED					, CurvyHud.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_FRIEND_PLAYER_STATUS_CHANGED		, CurvyHud.OnFriendsChanged)	
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, CurvyHud.OnGuildmateChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_UNIT_DEATH_STATE_CHANGED			, CurvyHud.OnTargetDead)
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_ZONE_CHANGED 						, CurvyHud.OnZoneChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_BOSSES_CHANGED 					, CurvyHud.OnBossChanged)
	EVENT_MANAGER:RegisterForEvent('CurvyHud',	EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE	, CurvyHud.OnActivityComplete)
end

function CurvyHud.OnReticleTarget(event)

	CurvyHud:ToggleDefaultTargetFrame()
	if (DoesUnitExist("reticleover")) then
		CurvyHud:InitializeTargetBar()
		CurvyHud.updateScaleReticle(true)		
	else
		CurvyHud.bars.targetBar:SetHidden(true)
		CurvyHud.bars.targetBar.textContainer:SetHidden(true)
		CurvyHud.bars.targetBar.shield.textContainer:SetHidden(true)
		CurvyHud.targetNameplate:SetHidden(true)
		CurvyHud.taunt.icon:SetHidden(true)
		CurvyHud.taunt.timer:SetAlpha(0)		
		CurvyHud:UpdateTargetInfos()
		CurvyHud.updateScaleReticle(false)
	end
	CurvyHud:FadeTargetBar()
end

function CurvyHud.OnReticleHidden(event, hidden)

	CurvyHud:HideHud(hidden)
end

function CurvyHud.OnWeaponBarSwitched(event, activeWeaponPair, locked)

	local num = activeWeaponPair
	function CreateReticleRotate(angle)
	
		local timeline = ANIMATION_MANAGER:CreateTimeline()
		local _, point, rTo, rPt, xOffset, yOffset = CurvyHud.reticle.borders:GetAnchor()
		local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, CurvyHud.reticle.borders)
		rotate:SetStartRotation(0)
		rotate:SetEndRotation(angle)
		rotate:SetDuration(200)

		timeline:SetHandler('OnStop', 
			function()
			rotate:SetStartRotation(0)
			CurvyHud.reticle.borders:SetAnchor(point, rTo, rPt, xOffset, yOffset)
			end
		)
		timeline:PlayFromStart()
	end
	local reversing 	= (180 * (math.pi/180))
	if (num == 1) then
		CreateReticleRotate(reversing)
	else
		CreateReticleRotate(-reversing)
	end
end

function CurvyHud.OnStealthStateChanged(event, unitTag, stealthState)

	if (unitTag == "player") then
		CurvyHud.state.getStealthState	= stealthState
		local curvyStealth
		if (stealthState <= 1) then
			CurvyHud.state.stealthState = false
		elseif (stealthState >= 2) then
			CurvyHud.state.stealthState = true
		end
	CurvyHud:UpadteSightColor()
	CurvyHud:UpadteSightChatInformations()
	end
end

function CurvyHud.OnEffectChanged(event, changeType, _, _, unitTag, timeStarted, timeEnding, _, _, _, _, _, _, unitName, _, abilityId, _)

	local target
	if (unitTag == "player") then
		target = "player"
	elseif (unitTag ~= "player") then
		target = "reticleover"
	end
	local nameReticle 	= GetUnitName(target)
	local nameUnitTag	= zo_strformat(SI_TOOLTIP_UNIT_NAME, unitName)
	if (nameUnitTag ~= nameReticle) then
		return
	end
	if (unitTag == "player") then
		CurvyHud:UpdatePlayerEffects(changeType, abilityId)
	else
		CurvyHud:UpdateTargetEffects(changeType, abilityId, timeStarted, timeEnding)
	end
end

function CurvyHud.OnPowerUpdated(event, unitTag, _, powerType, powerValue, _, powerEffectiveMax)
	
	local barName 	= CurvyHud.powerTypeBarMapping[powerType]
	local bar 		= CurvyHud.bars[barName]
	local isPlayer	= IsUnitPlayer("reticleover")
	local reac		= GetUnitReaction("reticleover")
	-- PLAYER 
	if (unitTag == "player") then
		if (CurvyHud.config.lowAttributes.show) then
			CurvyHud:UpdateLowAttribs(barName, powerValue, powerEffectiveMax)
		end
		if (bar) then
			if (bar.config.show) then
				CurvyHud:UpdateBar(barName, powerValue, powerEffectiveMax)
				if (barName == "werewolfBar" and CurvyHud.state.werewolf and powerValue <= 0) then
					CurvyHud.OnWerewolfStateChanged(nil, false)
				end
			end 
			if (bar.config.showText) then 
				CurvyHud:UpdateTextValues(barName, powerValue, powerEffectiveMax)
			end	
			if (not CurvyHud.state.inCombat)then
				CurvyHud:FadePlayerBar(barName, powerValue, powerEffectiveMax)
			end
		end
	end
	-- TARGET
	local reac		= GetUnitReaction("reticleover")
	local isPlayer	= IsUnitPlayer("reticleover")
	local isAttackabe	= IsUnitAttackable("reticleover")	
	if (unitTag == "reticleover" and powerType == POWERTYPE_HEALTH) then
		if (isPlayer or isAttackabe or reac == UNIT_REACTION_NEUTRAL) then
			if (CurvyHud.config.targetBar.show) then
				CurvyHud:UpdateBar("targetBar", powerValue, powerEffectiveMax)
			else
				return
			end
			if (CurvyHud.config.targetBar.showText) then
				CurvyHud:UpdateTextValues("targetBar", powerValue, powerEffectiveMax)
			else
				return
			end
		end
	end
	-- SIEGE WEAPONRY
	if (unitTag == 'controlledsiege' and powerType == POWERTYPE_HEALTH) then
		if (CurvyHud.config.siegeBar.show) then
			CurvyHud:UpdateBar("siegeBar", powerValue, powerEffectiveMax)
		end
		if(CurvyHud.bars.siegeBar.config.showText)then 
			CurvyHud:UpdateTextValues("siegeBar", powerValue, powerEffectiveMax)
		end
	end
end

function CurvyHud.OnVisualChanged(event, unitTag, unitAttributeVisual, statType, attributeType, powerType, val1, val2, val3, val4)

	local value
	local maxValue 
	local oldValue
	local oldMaxValue 
	local visualOn 	= false
	if (event == EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED) then
		value 		= val1
		maxValue	= val2
		visualOn 	= true
	elseif (event == EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED) then
		value	 	= val2
		maxValue	= val4
		oldValue	= val1
		oldMaxValue	= val3
		visualOn = true
	elseif (event == EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED) then
		value 		= val1
		maxValue	= val2
		visualOn 	= false
	end
	if (unitTag == "player") then
		CurvyHud:UpdatePlayerVisual(visualOn, unitAttributeVisual, statType, powerType, value, maxValue)
	elseif (unitTag == "reticleover") then
		CurvyHud:UpdateTargetVisual(visualOn, unitAttributeVisual, statType, powerType, value, maxValue)
	end
end

function CurvyHud.OnDisguiseStateChanged(event, unitTag, disguiseState)

	if (unitTag == "player") then
	CurvyHud.state.inDisguise	= disguiseState
		-- not disguise
		if (disguiseState == 0 or disguiseState == 4) then
			CurvyHud.state.isDisguise = false
		-- disguise
		elseif (disguiseState >= 1 or disguiseState <= 3) then
			CurvyHud.state.isDisguise = true
		end
	CurvyHud:UpadteSightColor()
	CurvyHud:UpadteSightChatInformations()
	end
end

function CurvyHud.OnCombatStateChanged(event, inCombat)

	CurvyHud.state.inDisguiseOnCombat		= GetUnitDisguiseState("player")
	CurvyHud.state.getStealthStateOnCombat	= GetUnitStealthState("player")
	CurvyHud.state.inCombat = inCombat
	if (CurvyHud.config.combatChatIndic) then
		local L = CurvyHud:GetLoc()
		if (inCombat) then
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyCombatOn)
		else
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo..L.CurvyCombatOff)
		end
	end
	
	function CurvyHud:PatchEventMounted()
	
		if (CurvyHud.state.mounted) then
			function countMounted ()
		
				zo_callLater(function ()	CurvyHud:PatchEventMounted()	end,  0500)
			end
			countMounted()
		else
			CurvyHud:ShowHud()
		end
	end
	
	if (inCombat) then
		if (CurvyHud.config.clepsydre.automaticChrono == "auto") then
			CurvyHud:ChonoAutoMode(CurvyHud.config.clepsydre.automaticChrono)
		end
		CurvyHud:PatchEventMounted()
	else
		CurvyHud:ShowHud()
	end
	CurvyHud:UpdateTargetInfos()
	CurvyHud:UpadteSightChatInformations()
end

function CurvyHud.OnCombatTips(event, tipId)

	if (CurvyHud.config.combatTips.show) then
		if (tipId == 1) then
			CurvyHud.combatTips.block:SetHidden(false)
			zo_callLater(function ()	CurvyHud.combatTips.block:SetHidden(true)	end,  2500)
		elseif (tipId == 2) then
			CurvyHud.combatTips.exploit:SetHidden(false)
			zo_callLater(function ()	CurvyHud.combatTips.exploit:SetHidden(true)	end,  2500)
		elseif (tipId == 3) then
			CurvyHud.combatTips.interrupt:SetHidden(false)
			zo_callLater(function ()	CurvyHud.combatTips.interrupt:SetHidden(true)	end,  2500)
		elseif (tipId == 4) then
			CurvyHud.combatTips.dodge:SetHidden(false)
			zo_callLater(function ()	CurvyHud.combatTips.dodge:SetHidden(true)	end,  2500)
		end
	end
end

function CurvyHud.OnMountedStateChanged(event, mounted)
	
	CurvyHud.state.mounted = mounted
	if (CurvyHud.state.mounted) then
		CurvyHud.bars.mountBar:SetHidden(not CurvyHud.config.mountBar.show)
		CurvyHud.bars.mountBar.textContainer:SetHidden(not CurvyHud.config.mountBar.showText)
	else
		CurvyHud.bars.mountBar:SetHidden(true)
		CurvyHud.bars.mountBar.textContainer:SetHidden(true)
	end
end

function CurvyHud.OnWerewolfStateChanged(event, werewolf)
	
	CurvyHud.state.werewolf = werewolf
	if (CurvyHud.state.werewolf) then
		CurvyHud.bars.werewolfBar:SetHidden(not CurvyHud.config.werewolfBar.show)
		CurvyHud.bars.werewolfBar.textContainer:SetHidden(not CurvyHud.config.werewolfBar.showText)
	else
		CurvyHud.bars.werewolfBar:SetHidden(true)
		CurvyHud.bars.werewolfBar.textContainer:SetHidden(true)
	end
end

function CurvyHud.OnSiegeStateChanged(event)
	
	CurvyHud.state.siege = IsPlayerControllingSiegeWeapon()
	if(CurvyHud.state.siege) then
		CurvyHud.bars.siegeBar:SetHidden(not CurvyHud.config.siegeBar.show)
		CurvyHud.bars.siegeBar.textContainer:SetHidden(not CurvyHud.config.siegeBar.showText)
	else
		CurvyHud.bars.siegeBar:SetHidden(true)
		CurvyHud.bars.siegeBar.textContainer:SetHidden(true)
	end
end

function CurvyHud.OnPlayerDead(event)
	
	local cfg 			= CurvyHud.config	
	CurvyHud.state.playerDead = true
	CurvyHud:HideHudForDeathRecap(true)
	CurvyHud.state.playerDeadCount = CurvyHud.state.playerDeadCount + 1 
	if (cfg.troll) then
		CurvyHud:DeadInformation()
	end
end

function CurvyHud.OnPlayerAlive(event)

	CurvyHud.state.playerDead = false
	CurvyHud.ReloadFrames()
	CurvyHud:HideHudForDeathRecap(false)
	CurvyHud.OnReticleHidden(0, IsReticleHidden())
end

function CurvyHud.OnTargetDead(event, isDead)

	CurvyHud:InitializeTargetBar()
	CurvyHud:UpdateReticleColor(false)
end

function CurvyHud.OnZoneChanged(event, _, _, _, _, _)

	CurvyHud.state.inDungeon = IsUnitInDungeon("player")
	CurvyHud.location.onZoneChanged = GetUnitZoneIndex("player")
	if (CurvyHud.state.inDungeon and CurvyHud.location.onZoneChanged ~= CurvyHud.location.init) then
		CurvyHud:DungeonInformationChat()
	end
end

function CurvyHud.OnFriendsChanged(event, displayName, _, newStatus )

	local friendsChanged = 0
	local cfg 	= CurvyHud.config		
	if ((event) and (cfg.guildmatesChatIndic == true)) then
		CurvyHud.state.friends = displayName
	end
end

function CurvyHud.OnGuildmateChanged(event, guildId, displayName, _, newStatus)

	local cfg 	= CurvyHud.config		
	if (cfg.guildmatesChatIndic == true and event) then
		CurvyHud:OnLinePlayers(guildId, displayName, newStatus)
	end
end

function CurvyHud.OnBossChanged(event)

	local existOne 		= DoesUnitExist("boss1")
	local existTow 		= DoesUnitExist("boss2")
	local existThree 	= DoesUnitExist("boss3")
	local existFour 	= DoesUnitExist("boss4")
	local existFive 	= DoesUnitExist("boss5")
	local existSix 		= DoesUnitExist("boss6")
	if (existOne or existTow or existThree or existFour or existFive or existSix) then
		CurvyHud.state.bossHere = true
		local iSiNcombat	= IsUnitInCombat(boss)
	else
		CurvyHud.state.bossHere = false
	end
end

function CurvyHud.OnActivityComplete(event)

	if (CurvyHud.config.clepsydre.automaticChrono == "sp" and CurvyHud.state.chronoStart == "start") then
		CurvyHud.state.chronoStart = "pause"
		CurvyHud.state.countButton = 1
		CurvyHud:UpdateChrono()
	else
		CurvyHud:InitializeChrono()
	end
end