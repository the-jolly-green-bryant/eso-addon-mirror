RengarusStatusDisplay = {}
RengarusStatusDisplay.name = "RengarusStatusDisplay"
RengarusStatusDisplay.version="1"

local LAM2 = LibAddonMenu2 or false
local LUIE = LUIE or false

RengarusStatusDisplay.Default = {
	offsetX = 0,
	offsetY = -60,
	
	scale = 1,

	toggleStunned = true,
	toggleFlash = true,
	toggleStaggered = true,
	toggleRooted = true,
	toggleSilenced = true,
	toggleDodging = true,
	toggleBlocking = true,
	toggleSprinting = true,
	toggleTips = true,
	toggleForceSettings = true,
	
	stringStunned = "STUNNED",
	stringScared = "SCARED",
	stringCharmed = "CHARMED",
	stringUnbreakable = "UNBREAKABLE",
	stringStaggered = "STAGGERED",
	stringRooted = "ROOTED",
	stringSilenced = "SILENCED",
	stringDodging = "DODGING",
	stringBlocking = "BLOCKING",
	stringSprinting = "SPRINTING",
	stringVampireSprinting = "STEALTHED",
	
	colorStunnedR = 1,
	colorStunnedG = 0,
	colorStunnedB = 0,
	colorStunnedA = 1,
	
	colorStaggeredR = 0.5,
	colorStaggeredG = 0.5,
	colorStaggeredB = 0.5,
	colorStaggeredA = 1,
	
	colorRootedR = 1,
	colorRootedG = 1,
	colorRootedB = 0,
	colorRootedA = 1,
	
	colorSilencedR = 0.75,
	colorSilencedG = 0,
	colorSilencedB = 0.75,
	colorSilencedA = 1,

	colorDodgingR = 0,
	colorDodgingB = 1,
	colorDodgingG = 1,
	colorDodgingA = 1,
	
	colorBlockingR = 0.25,
	colorBlockingG = 0.5,
	colorBlockingB = 1,
	colorBlockingA = 1,

	colorSprintingR = 0,
	colorSprintingB = 0,
	colorSprintingG = 1,
	colorSprintingA = 1,
}

local isBreakable = false
local isStunned = false
local isScared = false
local isCharmed = false
local isStaggered = false
local isRootedTT = false
local isRootedID = false
local isSilenced = false
local isBlocking = false
local isDodging = false
local isSprinting = false
local isVampireSprinting = false

local durationStaggered = 0
local durationOffBalance = 0

local lastStunBreak = 0
local lastPowerValue = 0
local currentPowerValue = 0
local lastPowerDrain = GetFrameTimeSeconds()

-----------------
-- Identifiers --
-----------------

local function IsSilence(abilityId)
	--Icon
	if GetAbilityIcon(abilityId) == "/esoui/art/icons/ability_debuff_silence.dds" then
		return true
	end
	--Silence Effect
	if abilityId == 6289 then
		return true
	end
	--NPC Negate Magic
	if abilityId == 80735 then
		return true
	end
	--Negate Magic
	if abilityId == 27706 or abilityId == 28341 or abilityId == 28348 then
		return true
	end
end

local function IsRoot(abilityId)
	--LUI
	if LUIE ~= false and LuiData.Data.Effects.EffectOverride[abilityId] ~= nil and LuiData.Data.Effects.EffectOverride[abilityId].tooltip == LuiData.Data.Tooltips.Generic_Immobilize then
		return true
	end
	--Icon
	if GetAbilityIcon(abilityId) == "/esoui/art/icons/ability_debuff_root.dds" then
		if abilityId == 229191 then return false end --Lep Seclusa: Abyssal Reach
		return true
	end
	--Icon Talons
	if GetAbilityIcon(abilityId):match(".+010") == "esoui/art/icons/ability_dragonknight_010.dds" then
		return true
	end
	--Root Effect
	if abilityId == 1856 then
		return true
	end
end

local isIgnored = 
{
	--Hiding Spot
	[72712] = true, [75747] = true, [75860] = true, [126609] = true,
	--Enter the Endless
	[194570] = true, [194571] = true, [202141] = true, [202803] = true, [212065] = true,
	--Verse Select
	[203124] = true, [203125] = true, [210189] = true,
	--Vision Select
	[202995] = true, [203101] = true,
	--Side Content Transporter
	[211431] = true, [211433] = true, [211440] = true
}

---------------
-- Functions --
---------------

local function UpdateText()
	
	--if IsPlayerTryingToMove() and IsPlayerMoving() then
	--	isRootedTT = false
	--	isRootedID = false
	--	durationStaggered = 0
	--end

	if durationStaggered > GetFrameTimeSeconds() then
		isStaggered = true
	else
		isStaggered = false
	end

	if (isCharmed or isScared or isStunned) and RengarusStatusDisplay.savedVariables.toggleFlash then
		FlashHealthWarningStage(2,1000)
	end
	
	if RengarusStatusDisplay.savedVariables.toggleForceSettings and GetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP) ~= 2 then
		SetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP, 0, 2)
	end
	if RengarusStatusDisplay.savedVariables.toggleTips then
		ZO_ActiveCombatTips:SetHidden(true)
	else
		ZO_ActiveCombatTips:SetHidden(false)
	end

	if (isRootedTT or isRootedID) and isSilenced and RengarusStatusDisplay.savedVariables.toggleRooted and RengarusStatusDisplay.savedVariables.toggleSilenced then
		RengarusStatusDisplayTextUP:SetHidden(false)
		RengarusStatusDisplayTextUPLabel:SetColor(RengarusStatusDisplay.savedVariables.colorRootedR,RengarusStatusDisplay.savedVariables.colorRootedG,RengarusStatusDisplay.savedVariables.colorRootedB,RengarusStatusDisplay.savedVariables.colorRootedA)
		RengarusStatusDisplayTextUPLabel:SetText(RengarusStatusDisplay.savedVariables.stringRooted.." & "..RengarusStatusDisplay.savedVariables.stringSilenced)
	elseif (isRootedTT or isRootedID) and RengarusStatusDisplay.savedVariables.toggleRooted then
		RengarusStatusDisplayTextUP:SetHidden(false)
		RengarusStatusDisplayTextUPLabel:SetColor(RengarusStatusDisplay.savedVariables.colorRootedR,RengarusStatusDisplay.savedVariables.colorRootedG,RengarusStatusDisplay.savedVariables.colorRootedB,RengarusStatusDisplay.savedVariables.colorRootedA)
		RengarusStatusDisplayTextUPLabel:SetText(RengarusStatusDisplay.savedVariables.stringRooted)
	elseif isSilenced and RengarusStatusDisplay.savedVariables.toggleSilenced then
		RengarusStatusDisplayTextUP:SetHidden(false)
		RengarusStatusDisplayTextUPLabel:SetColor(RengarusStatusDisplay.savedVariables.colorSilencedR,RengarusStatusDisplay.savedVariables.colorSilencedG,RengarusStatusDisplay.savedVariables.colorSilencedB,RengarusStatusDisplay.savedVariables.colorSilencedA)
		RengarusStatusDisplayTextUPLabel:SetText(RengarusStatusDisplay.savedVariables.stringSilenced)
	else
		RengarusStatusDisplayTextUP:SetHidden(true)
	end
	
	if isCharmed and RengarusStatusDisplay.savedVariables.toggleStunned then
		if not isBreakable and GetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP) == 2 then
			RengarusStatusDisplayTextUP:SetHidden(false)
			RengarusStatusDisplayTextUPLabel:SetColor(RengarusStatusDisplay.savedVariables.colorStunnedR,RengarusStatusDisplay.savedVariables.colorStunnedG,RengarusStatusDisplay.savedVariables.colorStunnedB,RengarusStatusDisplay.savedVariables.colorStunnedA)
			RengarusStatusDisplayTextUPLabel:SetText(RengarusStatusDisplay.savedVariables.stringUnbreakable)
		end
		RengarusStatusDisplayTextDOWN:SetHidden(false)
		RengarusStatusDisplayTextDOWNLabel:SetColor(RengarusStatusDisplay.savedVariables.colorStunnedR,RengarusStatusDisplay.savedVariables.colorStunnedG,RengarusStatusDisplay.savedVariables.colorStunnedB,RengarusStatusDisplay.savedVariables.colorStunnedA)
		RengarusStatusDisplayTextDOWNLabel:SetText(RengarusStatusDisplay.savedVariables.stringCharmed)
	elseif isScared and RengarusStatusDisplay.savedVariables.toggleStunned then
		if not isBreakable and GetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP) == 2 then
			RengarusStatusDisplayTextUP:SetHidden(false)
			RengarusStatusDisplayTextUPLabel:SetColor(RengarusStatusDisplay.savedVariables.colorStunnedR,RengarusStatusDisplay.savedVariables.colorStunnedG,RengarusStatusDisplay.savedVariables.colorStunnedB,RengarusStatusDisplay.savedVariables.colorStunnedA)
			RengarusStatusDisplayTextUPLabel:SetText(RengarusStatusDisplay.savedVariables.stringUnbreakable)
		end
		RengarusStatusDisplayTextDOWN:SetHidden(false)
		RengarusStatusDisplayTextDOWNLabel:SetColor(RengarusStatusDisplay.savedVariables.colorStunnedR,RengarusStatusDisplay.savedVariables.colorStunnedG,RengarusStatusDisplay.savedVariables.colorStunnedB,RengarusStatusDisplay.savedVariables.colorStunnedA)
		RengarusStatusDisplayTextDOWNLabel:SetText(RengarusStatusDisplay.savedVariables.stringScared)
	elseif isStunned and RengarusStatusDisplay.savedVariables.toggleStunned then
		if not isBreakable and GetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP) == 2 then
			RengarusStatusDisplayTextUP:SetHidden(false)
			RengarusStatusDisplayTextUPLabel:SetColor(RengarusStatusDisplay.savedVariables.colorStunnedR,RengarusStatusDisplay.savedVariables.colorStunnedG,RengarusStatusDisplay.savedVariables.colorStunnedB,RengarusStatusDisplay.savedVariables.colorStunnedA)
			RengarusStatusDisplayTextUPLabel:SetText(RengarusStatusDisplay.savedVariables.stringUnbreakable)
		end
		RengarusStatusDisplayTextDOWN:SetHidden(false)
		RengarusStatusDisplayTextDOWNLabel:SetColor(RengarusStatusDisplay.savedVariables.colorStunnedR,RengarusStatusDisplay.savedVariables.colorStunnedG,RengarusStatusDisplay.savedVariables.colorStunnedB,RengarusStatusDisplay.savedVariables.colorStunnedA)
		RengarusStatusDisplayTextDOWNLabel:SetText(RengarusStatusDisplay.savedVariables.stringStunned)
	elseif isStaggered and RengarusStatusDisplay.savedVariables.toggleStaggered then
		RengarusStatusDisplayTextDOWN:SetHidden(false)
		RengarusStatusDisplayTextDOWNLabel:SetColor(RengarusStatusDisplay.savedVariables.colorStaggeredR,RengarusStatusDisplay.savedVariables.colorStaggeredG,RengarusStatusDisplay.savedVariables.colorStaggeredB,RengarusStatusDisplay.savedVariables.colorStaggeredA)
		RengarusStatusDisplayTextDOWNLabel:SetText(RengarusStatusDisplay.savedVariables.stringStaggered)
	elseif isDodging and RengarusStatusDisplay.savedVariables.toggleDodging then
		RengarusStatusDisplayTextDOWN:SetHidden(false)
		RengarusStatusDisplayTextDOWNLabel:SetColor(RengarusStatusDisplay.savedVariables.colorDodgingR,RengarusStatusDisplay.savedVariables.colorDodgingG,RengarusStatusDisplay.savedVariables.colorDodgingB,RengarusStatusDisplay.savedVariables.colorDodgingA)
		RengarusStatusDisplayTextDOWNLabel:SetText(RengarusStatusDisplay.savedVariables.stringDodging)
	elseif isBlocking and not isSprinting and RengarusStatusDisplay.savedVariables.toggleBlocking then
		RengarusStatusDisplayTextDOWN:SetHidden(false)
		RengarusStatusDisplayTextDOWNLabel:SetColor(RengarusStatusDisplay.savedVariables.colorBlockingR,RengarusStatusDisplay.savedVariables.colorBlockingG,RengarusStatusDisplay.savedVariables.colorBlockingB,RengarusStatusDisplay.savedVariables.colorBlockingA)
		RengarusStatusDisplayTextDOWNLabel:SetText(RengarusStatusDisplay.savedVariables.stringBlocking)
	elseif isSprinting and RengarusStatusDisplay.savedVariables.toggleSprinting then
		if isVampireSprinting then
			RengarusStatusDisplayTextUP:SetHidden(false)
			RengarusStatusDisplayTextUPLabel:SetColor(RengarusStatusDisplay.savedVariables.colorSprintingR,RengarusStatusDisplay.savedVariables.colorSprintingG,RengarusStatusDisplay.savedVariables.colorSprintingB,RengarusStatusDisplay.savedVariables.colorSprintingA)
			RengarusStatusDisplayTextUPLabel:SetText(RengarusStatusDisplay.savedVariables.stringVampireSprinting)
		end
		RengarusStatusDisplayTextDOWN:SetHidden(false)
		RengarusStatusDisplayTextDOWNLabel:SetColor(RengarusStatusDisplay.savedVariables.colorSprintingR,RengarusStatusDisplay.savedVariables.colorSprintingG,RengarusStatusDisplay.savedVariables.colorSprintingB,RengarusStatusDisplay.savedVariables.colorSprintingA)
		RengarusStatusDisplayTextDOWNLabel:SetText(RengarusStatusDisplay.savedVariables.stringSprinting)
	else
		RengarusStatusDisplayTextDOWN:SetHidden(true)
	end
end

local function DisplayTip(event, tipType)
	--d("display",tipType)
	if tipType == 18 then
		isBreakable = true
		if IsUnitPvPFlagged("player") and GetFrameTimeSeconds() - lastStunBreak > 0.1 then
			isStunned = true
		end
		UpdateText()
	end
	if tipType == 19 then 
		isRootedTT = true
		UpdateText()
	end
end

local function RemoveTip(event, tipType, result)
	--d("remove",tipType)
	if tipType == 18 then
		isBreakable = false
		isStunned = false
		isScared = false
		isCharmed = false
		UpdateText()
	end
	if tipType == 19 then
		isRootedTT = false
		UpdateText()
	end
end

local function OnStunnedStateChanged(eventCode, playerStunned)
	if IsUnitPvPFlagged("player") and IsUnitInCombat("player") then --Extra Check for PvP to capture weird edge cases.
		isStunned = playerStunned
		UpdateText()
	end
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if unitTag == "player" then
		if IsSilence(abilityId) then
			if changeType == 1 then
				isSilenced = true
			end
			if changeType == 2 then
				isSilenced = false
			end
			UpdateText()
		elseif IsRoot(abilityId) then
			if changeType == 1 then
				isRootedID = true
			end
			if changeType == 2 then
				isRootedID = false
			end
			UpdateText()
		elseif abilityId == 135226 then
			if changeType == 1 then
				isVampireSprinting = true
			end
			if changeType == 2 then
				isVampireSprinting = false
			end
		end
		if changeType == 1 and abilityId == 29721 then
			isDodging = true
			UpdateText()
			zo_callLater(function () isDodging = false end, 1000)
			zo_callLater(function () UpdateText() end, 1050)
		end
	end
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if targetName == GetRawUnitName("player") and targetType == 1 then
		if abilityId == 36010 then
			--lastMountUp = GetFrameTimeSeconds()
		elseif abilityId == 16565 and result == 2240 then
			lastStunBreak = GetFrameTimeSeconds()
			isStunned = false
			UpdateText()
		elseif sourceType ~= 1 and not isIgnored[abilityId] then -- and not IsUnitPvPFlagged("player")
			if result == ACTION_RESULT_STUNNED and GetAbilityDuration(abilityId) > 0 then
				--d("STUNNED",abilityName,abilityId,sourceName,sourceType)
				isStunned = true
				zo_callLater(function () isStunned = false end, GetAbilityDuration(abilityId))
				UpdateText()
				zo_callLater(function () UpdateText() end, GetAbilityDuration(abilityId) + 50)
			elseif result == ACTION_RESULT_FEARED and GetAbilityDuration(abilityId) > 0 then
				--d("FEARED",abilityName,abilityId,sourceName,sourceType)
				isScared = true
				zo_callLater(function () isScared = false end, GetAbilityDuration(abilityId))
				UpdateText()
				zo_callLater(function () UpdateText() end, GetAbilityDuration(abilityId) + 50)
			elseif result == ACTION_RESULT_CHARMED and GetAbilityDuration(abilityId) > 0 then
				--d("CHARMED",abilityName,abilityId,sourceName,sourceType)
				isCharmed = true
				zo_callLater(function () isCharmed = false end, GetAbilityDuration(abilityId))
				UpdateText()
				zo_callLater(function () UpdateText() end, GetAbilityDuration(abilityId) + 50)
			elseif result == ACTION_RESULT_STAGGERED and GetAbilityDuration(abilityId) > 0 then
				--d("STAGGERED",abilityName,abilityId,sourceName,sourceType)
				durationStaggered = math.max(durationStaggered,GetFrameTimeSeconds() + GetAbilityDuration(abilityId) / 1000)
				UpdateText()
				zo_callLater(function () UpdateText() end, GetAbilityDuration(abilityId) + 50)
			elseif result == ACTION_RESULT_OFFBALANCE and GetAbilityDuration(abilityId) > 0 then
				--d("OFFBALANCE",abilityName,abilityId,sourceName,sourceType)
				durationOffBalance = math.max(durationOffBalance,GetFrameTimeSeconds() + GetAbilityDuration(abilityId) / 1000)
				UpdateText()
				zo_callLater(function () UpdateText() end, GetAbilityDuration(abilityId) + 50)
			end
		elseif sourceType == 1 and abilityId == 16565 and result == 2240 then --Stunbreak
			local isBreakable = false
			local isStunned = false
			local isScared = false
			local isCharmed = false
		end
	end
end

local function CheckBlocking()
	if IsBlockActive() and (GetPlayerStat(STAT_STAMINA_REGEN_COMBAT) == 0 or GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT) == 0) then
		if isBlocking == false then
			isBlocking = true
			UpdateText()
		end
	else
		if isBlocking == true then
			isBlocking = false
			UpdateText()
		end
	end
end

local function CheckSprinting()
	if lastPowerDrain + 0.1 > GetFrameTimeSeconds() then
		isSprinting = true
		zo_callLater(function () CheckSprinting() end, 50)
	else
		isSprinting = false
	end
	UpdateText()
end

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if unitTag == "player" then
		if (powerIndex == 1 or powerIndex == 3 or powerIndex == 5) and (GetUnitStealthState("player") == 0 or isVampireSprinting) then
			lastPowerValue = currentPowerValue
			currentPowerValue = powerValue
			if (lastPowerValue - currentPowerValue) < 20 and (lastPowerValue - currentPowerValue) > 0 then
				lastPowerDrain = GetFrameTimeSeconds()
				if isSprinting == false then
					CheckSprinting()
				end
			end
		end
	end
end

local function UpdateAnchors()
	RengarusStatusDisplayTextUP:SetScale(RengarusStatusDisplay.savedVariables.scale)
	RengarusStatusDisplayTextUP:ClearAnchors()
	RengarusStatusDisplayTextUP:SetAnchor(CENTER, GuiRoot, CENTER, RengarusStatusDisplay.savedVariables.offsetX, (RengarusStatusDisplay.savedVariables.offsetY - (30 * RengarusStatusDisplay.savedVariables.scale)))
	RengarusStatusDisplayTextDOWN:SetScale(RengarusStatusDisplay.savedVariables.scale)
	RengarusStatusDisplayTextDOWN:ClearAnchors()
	RengarusStatusDisplayTextDOWN:SetAnchor(CENTER, GuiRoot, CENTER, RengarusStatusDisplay.savedVariables.offsetX, RengarusStatusDisplay.savedVariables.offsetY)
end

local function PreviewPosition()
	RengarusStatusDisplayTextUP:SetHidden(false)
	RengarusStatusDisplayTextUPLabel:SetColor(1,1,1,1)
	RengarusStatusDisplayTextUPLabel:SetText("TEST")
	RengarusStatusDisplayTextDOWN:SetHidden(false)
	RengarusStatusDisplayTextDOWNLabel:SetColor(1,1,1,1)
	RengarusStatusDisplayTextDOWNLabel:SetText("PREVIEW")
end

---------------------
-- Settings Window --
---------------------

local function CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Rengaru's Status Display",
		displayName = "Rengaru's Status Display",
		author = "Rengaru",
		version = RengarusStatusDisplay.version,
		registerForRefresh = true,
		registerForDefaults = true,
	} 
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("RengarusStatusDisplay_SettingsPanel", panelData)
	local controls = {}
	--Stunned
	controls[#controls + 1] = {
		type = "header",
		name = "Stunned & Scared",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Toggle:",
		tooltip = "Show when you are stunned or scared.\nTo properly show when a stun is unbreakable Active Combat Tips in the Combat Settings must be set to Always Show.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleStunned end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleStunned = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "colorpicker",
		name = "Color:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleStunned end,
		default = {r = RengarusStatusDisplay.Default.colorStunnedR,
				 g = RengarusStatusDisplay.Default.colorStunnedG,
				 b = RengarusStatusDisplay.Default.colorStunnedB,
				 a = RengarusStatusDisplay.Default.colorStunnedA},
		getFunc = function() return
					RengarusStatusDisplay.savedVariables.colorStunnedR,
					RengarusStatusDisplay.savedVariables.colorStunnedG,
					RengarusStatusDisplay.savedVariables.colorStunnedB,
					RengarusStatusDisplay.savedVariables.colorStunnedA
				end,
		setFunc = function(r,g,b,a)
					RengarusStatusDisplay.savedVariables.colorStunnedR = r
					RengarusStatusDisplay.savedVariables.colorStunnedG = g
					RengarusStatusDisplay.savedVariables.colorStunnedB = b
					RengarusStatusDisplay.savedVariables.colorStunnedA = a
				end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text Stunned:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleStunned end,
		default = RengarusStatusDisplay.Default.stringStunned,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringStunned end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringStunned = text end,
		isMultiline = false,
		width = "half",
	}
	--Unbreakable
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text Unbreakable:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleStunned end,
		default = RengarusStatusDisplay.Default.stringUnbreakable,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringUnbreakable end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringUnbreakable = text end,
		isMultiline = false,
		width = "half",
	}
	--Scared
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text Scared:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleStunned end,
		default = RengarusStatusDisplay.Default.stringScared,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringScared end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringScared = text end,
		isMultiline = false,
		width = "half",
	}
	--Charmed
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text Charmed:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleStunned end,
		default = RengarusStatusDisplay.Default.stringCharmed,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringCharmed end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringCharmed = text end,
		isMultiline = false,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Flash Screen",
		tooltip = "Flash the Screen when you get stunned or scared.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleFlash end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleFlash = newValue end,
		width = "half",
	}
	--Staggered
	controls[#controls + 1] = {
		type = "header",
		name = "Staggered",
	}	
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Toggle:",
		tooltip = "Show when you are staggered.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleStaggered end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleStaggered = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "colorpicker",
		name = "Color:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleStaggered end,
		default = {r = RengarusStatusDisplay.Default.colorStaggeredR,
				 g = RengarusStatusDisplay.Default.colorStaggeredG,
				 b = RengarusStatusDisplay.Default.colorStaggeredB,
				 a = RengarusStatusDisplay.Default.colorStaggeredA},
		getFunc = function() return
					RengarusStatusDisplay.savedVariables.colorStaggeredR,
					RengarusStatusDisplay.savedVariables.colorStaggeredG,
					RengarusStatusDisplay.savedVariables.colorStaggeredB,
					RengarusStatusDisplay.savedVariables.colorStaggeredA
				end,
		setFunc = function(r,g,b,a)
					RengarusStatusDisplay.savedVariables.colorStaggeredR = r
					RengarusStatusDisplay.savedVariables.colorStaggeredG = g
					RengarusStatusDisplay.savedVariables.colorStaggeredB = b
					RengarusStatusDisplay.savedVariables.colorStaggeredA = a
				end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleStaggered end,
		default = RengarusStatusDisplay.Default.stringStaggered,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringStaggered end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringStaggered = text end,
		isMultiline = false,
		width = "half",
	}
	--Rooted
	controls[#controls + 1] = {
		type = "header",
		name = "Rooted",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Toggle:",
		tooltip = "Show when you are rooted.\nActive Combat Tips in the Combat Settings must be set to Always Show.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleRooted end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleRooted = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "colorpicker",
		name = "Color:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleRooted end,
		default = {r = RengarusStatusDisplay.Default.colorRootedR,
				 g = RengarusStatusDisplay.Default.colorRootedG,
				 b = RengarusStatusDisplay.Default.colorRootedB,
				 a = RengarusStatusDisplay.Default.colorRootedA},
		getFunc = function() return
					RengarusStatusDisplay.savedVariables.colorRootedR,
					RengarusStatusDisplay.savedVariables.colorRootedG,
					RengarusStatusDisplay.savedVariables.colorRootedB,
					RengarusStatusDisplay.savedVariables.colorRootedA
				end,
		setFunc = function(r,g,b,a)
					RengarusStatusDisplay.savedVariables.colorRootedR = r
					RengarusStatusDisplay.savedVariables.colorRootedG = g
					RengarusStatusDisplay.savedVariables.colorRootedB = b
					RengarusStatusDisplay.savedVariables.colorRootedA = a
				end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleRooted end,
		default = RengarusStatusDisplay.Default.stringRooted,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringRooted end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringRooted = text end,
		isMultiline = false,
		width = "half",
	}
	--Silenced
	controls[#controls + 1] = {
		type = "header",
		name = "Silenced",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Toggle:",
		tooltip = "Show when you are silenced.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleSilenced end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleSilenced = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "colorpicker",
		name = "Color:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleSilenced end,
		default = {r = RengarusStatusDisplay.Default.colorSilencedR,
				 g = RengarusStatusDisplay.Default.colorSilencedG,
				 b = RengarusStatusDisplay.Default.colorSilencedB,
				 a = RengarusStatusDisplay.Default.colorSilencedA},
		getFunc = function() return
					RengarusStatusDisplay.savedVariables.colorSilencedR,
					RengarusStatusDisplay.savedVariables.colorSilencedG,
					RengarusStatusDisplay.savedVariables.colorSilencedB,
					RengarusStatusDisplay.savedVariables.colorSilencedA
				end,
		setFunc = function(r,g,b,a)
					RengarusStatusDisplay.savedVariables.colorSilencedR = r
					RengarusStatusDisplay.savedVariables.colorSilencedG = g
					RengarusStatusDisplay.savedVariables.colorSilencedB = b
					RengarusStatusDisplay.savedVariables.colorSilencedA = a
				end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleSilenced end,
		default = RengarusStatusDisplay.Default.stringSilenced,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringSilenced end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringSilenced = text end,
		isMultiline = false,
		width = "half",
	}
	--Dodging
	controls[#controls + 1] = {
		type = "header",
		name = "Dodging",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Toggle:",
		tooltip = "Show when you are dodging.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleDodging end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleDodging = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "colorpicker",
		name = "Color:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleDodging end,
		default = {r = RengarusStatusDisplay.Default.colorDodgingR,
				 g = RengarusStatusDisplay.Default.colorDodgingG,
				 b = RengarusStatusDisplay.Default.colorDodgingB,
				 a = RengarusStatusDisplay.Default.colorDodgingA},
		getFunc = function() return
					RengarusStatusDisplay.savedVariables.colorDodgingR,
					RengarusStatusDisplay.savedVariables.colorDodgingG,
					RengarusStatusDisplay.savedVariables.colorDodgingB,
					RengarusStatusDisplay.savedVariables.colorDodgingA
				end,
		setFunc = function(r,g,b,a)
					RengarusStatusDisplay.savedVariables.colorDodgingR = r
					RengarusStatusDisplay.savedVariables.colorDodgingG = g
					RengarusStatusDisplay.savedVariables.colorDodgingB = b
					RengarusStatusDisplay.savedVariables.colorDodgingA = a
				end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleDodging end,
		default = RengarusStatusDisplay.Default.stringDodging,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringDodging end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringDodging = text end,
		isMultiline = false,
		width = "half",
	}
	--Blocking
	controls[#controls + 1] = {
		type = "header",
		name = "Blocking",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Toggle:",
		tooltip = "Show when you are blocking.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleBlocking end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleBlocking = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "colorpicker",
		name = "Color:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleBlocking end,
		default = {r = RengarusStatusDisplay.Default.colorBlockingR,
				 g = RengarusStatusDisplay.Default.colorBlockingG,
				 b = RengarusStatusDisplay.Default.colorBlockingB,
				 a = RengarusStatusDisplay.Default.colorBlockingA},
		getFunc = function() return
					RengarusStatusDisplay.savedVariables.colorBlockingR,
					RengarusStatusDisplay.savedVariables.colorBlockingG,
					RengarusStatusDisplay.savedVariables.colorBlockingB,
					RengarusStatusDisplay.savedVariables.colorBlockingA
				end,
		setFunc = function(r,g,b,a)
					RengarusStatusDisplay.savedVariables.colorBlockingR = r
					RengarusStatusDisplay.savedVariables.colorBlockingG = g
					RengarusStatusDisplay.savedVariables.colorBlockingB = b
					RengarusStatusDisplay.savedVariables.colorBlockingA = a
				end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text:",
		default = RengarusStatusDisplay.Default.stringBlocking,
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleBlocking end,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringBlocking end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringBlocking = text end,
		isMultiline = false,
		width = "half",
	}
	--Sprinting
	controls[#controls + 1] = {
		type = "header",
		name = "Sprinting",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Toggle:",
		tooltip = "Show when you are sprinting.\nWIP: Please let me know about false positives.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleSprinting end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleSprinting = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "colorpicker",
		name = "Color:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleSprinting end,
		default = {r = RengarusStatusDisplay.Default.colorSprintingR,
				 g = RengarusStatusDisplay.Default.colorSprintingG,
				 b = RengarusStatusDisplay.Default.colorSprintingB,
				 a = RengarusStatusDisplay.Default.colorSprintingA},
		getFunc = function() return
					RengarusStatusDisplay.savedVariables.colorSprintingR,
					RengarusStatusDisplay.savedVariables.colorSprintingG,
					RengarusStatusDisplay.savedVariables.colorSprintingB,
					RengarusStatusDisplay.savedVariables.colorSprintingA
				end,
		setFunc = function(r,g,b,a)
					RengarusStatusDisplay.savedVariables.colorSprintingR = r
					RengarusStatusDisplay.savedVariables.colorSprintingG = g
					RengarusStatusDisplay.savedVariables.colorSprintingB = b
					RengarusStatusDisplay.savedVariables.colorSprintingA = a
				end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Text:",
		default = RengarusStatusDisplay.Default.stringSprinting,
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleSprinting end,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringSprinting end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringSprinting = text end,
		isMultiline = false,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "editbox",
		name = "Vampire Sprint:",
		disabled = function() return not RengarusStatusDisplay.savedVariables.toggleSprinting end,
		default = RengarusStatusDisplay.Default.stringVampireSprinting,
		getFunc = function() return RengarusStatusDisplay.savedVariables.stringVampireSprinting end,
		setFunc = function(text) RengarusStatusDisplay.savedVariables.stringVampireSprinting = text end,
		isMultiline = false,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "header",
		name = "Other",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Force Combat Tips On",
		tooltip = "Force the setting to track Active Combat Tips to \"Always Show\".\nActive Combat Tips are needed to track certain effects.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleForceSettings end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleForceSettings = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = "Suppress Combat Tips Display",
		tooltip = "Supresses Active Combat Tips from actually showing up on screen.\nActive Combat Tips are needed to track certain effects.",
		default = true,
		getFunc = function() return RengarusStatusDisplay.savedVariables.toggleTips end,
		setFunc = function(newValue) RengarusStatusDisplay.savedVariables.toggleTips = newValue end,
		width = "half",
	}
	controls[#controls + 1] = {
		type = "slider",
		name = "X Position",
		default = RengarusStatusDisplay.Default.offsetX,
		getFunc = function() return RengarusStatusDisplay.savedVariables.offsetX end,
		setFunc = function(value) RengarusStatusDisplay.savedVariables.offsetX = value UpdateAnchors() PreviewPosition() end,
		min = -GuiRoot:GetWidth()/2,
		max = GuiRoot:GetWidth()/2,
		step = 10,
		width = "half"
	}
	controls[#controls + 1] = {
		type = "slider",
		name = "Y Position",
		default = RengarusStatusDisplay.Default.offsetY,
		getFunc = function() return RengarusStatusDisplay.savedVariables.offsetY end,
		setFunc = function(value) RengarusStatusDisplay.savedVariables.offsetY = value UpdateAnchors() PreviewPosition() end,
		min = -GuiRoot:GetHeight()/2,
		max = GuiRoot:GetHeight()/2,
		step = 10,
		width = "half"
	}
	controls[#controls + 1] = {
		type = "slider",
		name = "Scale",
		default = RengarusStatusDisplay.Default.scale,
		getFunc = function() return RengarusStatusDisplay.savedVariables.scale end,
		setFunc = function(value) RengarusStatusDisplay.savedVariables.scale = value UpdateAnchors() PreviewPosition() end,
		min = 0.25,
		max = 5,
		step = 0.25,
		width = "half"
	}
	LAM2:RegisterOptionControls("RengarusStatusDisplay_SettingsPanel", controls)
end

-----------
-- Setup --
-----------

local function OnAddOnLoaded(event, addonName)
	if addonName == RengarusStatusDisplay.name then
		EVENT_MANAGER:UnregisterForEvent(RengarusStatusDisplay.name, EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP, DisplayTip)
		EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_REMOVE_ACTIVE_COMBAT_TIP, RemoveTip)
		EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_PLAYER_STUNNED_STATE_CHANGED, OnStunnedStateChanged)
		EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
		EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_COMBAT_EVENT, OnCombatEvent)
		EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_POWER_UPDATE, OnPowerUpdate)
		EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_ACTION_LAYER_POPPED, UpdateText)
		--ToDo: find a more resource efficient way to check for block status
		EVENT_MANAGER:RegisterForUpdate("RengarusStatusDisplayBlockUpdate", 10, function() CheckBlocking() end)
		RengarusStatusDisplay.savedVariables = ZO_SavedVars:NewAccountWide("RengarusStatusDisplay_SavedVars", RengarusStatusDisplay.version, nil, RengarusStatusDisplay.Default)
		if LAM2 ~= false then
			CreateSettingsWindow()
		end
		UpdateAnchors()
	end
end

EVENT_MANAGER:RegisterForEvent(RengarusStatusDisplay.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)