local MCI = {}
MCI.name = "MiatCastIcon"
MCI.version = 1.0
MCI.textVersion = "1.11"

-- local LAM2 = LibStub("LibAddonMenu-2.0")
local LAM2 = LibAddonMenu2

local MAIN_CONTROL = Miat_CastIcon_ChargeUp
local COOLDOWN_CONTROL = MAIN_CONTROL:GetNamedChild('Cooldown')
local ICON_CONTROL = MAIN_CONTROL:GetNamedChild('Icon')
local LEADINGEDGE_CONTROL = MAIN_CONTROL:GetNamedChild('LeadingEdge')
local GLOW_CONTROL = MAIN_CONTROL:GetNamedChild('Glow')
local HIGHLIGHT_CONTROL = MAIN_CONTROL:GetNamedChild('HeavyAttackHighlightIcon')
local LABEL_CONTROL = MAIN_CONTROL:GetNamedChild('Label')

local texturePath = "MiatCastIcon/textures/"

local PVP_BOW_HA_ICON = texturePath.."bow_3.dds"
local PVP_DW_HA_ICON = texturePath.."dw_3.dds"
local PVP_2H_HA_ICON = texturePath.."2h_3.dds"
local PVP_SB_HA_ICON = texturePath.."snb_3.dds"
local PVP_FLAME_HA_ICON = texturePath.."staff_3.dds"
local PVP_FROST_HA_ICON = texturePath.."staff_3.dds"
local PVP_SHOCK_HA_ICON = texturePath.."staff_chan_3.dds"
local PVP_RESTO_HA_ICON = texturePath.."staff_chan_3.dds"

local PVP_MAP_ICON = texturePath.."map1.dds"
local PVP_RETREAT_ICON = "/esoui/art/icons/rune_a.dds"

local PVP_RESURRECT_ICON = "esoui/art/tutorial/gamepad/gp_notificationicon_resurrect.dds"

local PVP_WALL_REPAIR_ICON = "/esoui/art/icons/crafting_heavy_armor_sp_names_001.dds"
local PVP_DOOR_REPAIR_ICON = "/esoui/art/icons/crafting_forester_weapon_component_005.dds"

local PVP_BOW_HA_COLOR = ZO_ColorDef:New(1,1,1,1)
local PVP_DW_HA_COLOR = ZO_ColorDef:New(1,1,1,1)
local PVP_2H_HA_COLOR = ZO_ColorDef:New(1,1,1,1)
local PVP_SB_HA_COLOR = ZO_ColorDef:New(1,1,1,1)
local PVP_FLAME_HA_COLOR = ZO_ColorDef:New(1,0.2,0.2,1)
local PVP_FROST_HA_COLOR = ZO_ColorDef:New(0.2,0.2,1,1)
local PVP_SHOCK_HA_COLOR = ZO_ColorDef:New(0,0.8,0.8,1)
local PVP_RESTO_HA_COLOR = ZO_ColorDef:New(0,0.8,0,1)

local PVP_TREBUCHET_ICON = "esoui/art/icons/ava_siege_weapon_005.dds"
local PVP_CATAPULT_ICON = "esoui/art/icons/ava_siege_ui_003.dds"
local PVP_BALLISTA_ICON = "esoui/art/icons/ava_siege_weapon_001.dds"

local PVP_MOUNT_ABILITYID = 37059

MCI.heavyAttackId={
	[16041] = PVP_2H_HA_ICON,
	[16691] = PVP_BOW_HA_ICON,
	[16420] = PVP_DW_HA_ICON,
	[15279] = PVP_SB_HA_ICON,
	[15383] = PVP_FLAME_HA_ICON,
	[16261] = PVP_FROST_HA_ICON,
	[18396] = PVP_SHOCK_HA_ICON,
	[16212] = PVP_RESTO_HA_ICON,
	[26770] = PVP_RESURRECT_ICON, -- resurrect
}

-- MCI.heavyIconColors={
	-- [16041] = PVP_2H_HA_COLOR,
	-- [16691] = PVP_BOW_HA_COLOR,
	-- [16420] = PVP_DW_HA_COLOR,
	-- [15279] = PVP_SB_HA_COLOR,
	-- [15383] = PVP_FLAME_HA_COLOR,
	-- [16261] = PVP_FROST_HA_COLOR,
	-- [18396] = PVP_SHOCK_HA_COLOR,
	-- [16212] = PVP_RESTO_HA_COLOR,
-- }

MCI.failedEvents = {
	[ACTION_RESULT_BAD_TARGET] = true,
	[ACTION_RESULT_CANT_SEE_TARGET] = true,
	[ACTION_RESULT_INTERRUPT] = true,
	[ACTION_RESULT_TARGET_NOT_IN_VIEW] = true,
	[ACTION_RESULT_TARGET_TOO_CLOSE] = true,
	[ACTION_RESULT_TARGET_OUT_OF_RANGE] = true,
	[ACTION_RESULT_DIED] = true,
	[ACTION_RESULT_DIED_XP] = true,
	[ACTION_RESULT_KILLING_BLOW] = true,
}

MCI.custom = {

	[6811] = PVP_MAP_ICON, -- worldmap
	[69293] = PVP_RETREAT_ICON, -- sigil of imperial retreat


	[22570] = "/esoui/art/icons/ava_siege_weapon_002.dds", -- oil

	[19040] = "/esoui/art/icons/ava_siege_ui_006.dds", -- ad camp
	[19041] = "esoui/art/icons/ava_siege_ui_007.dds", -- dc camp
	[19039] = "esoui/art/icons/ava_siege_ui_008.dds", -- ep camp

	[13853] = PVP_WALL_REPAIR_ICON,
	[16723] = PVP_DOOR_REPAIR_ICON,

	[39910] = PVP_TREBUCHET_ICON, -- treb

	[39909] = PVP_TREBUCHET_ICON, -- treb

	[39913] = PVP_TREBUCHET_ICON, -- treb
	[39914] = PVP_TREBUCHET_ICON, -- treb
	[39916] = PVP_TREBUCHET_ICON, -- treb

	[13663] = PVP_TREBUCHET_ICON, -- firepot treb
	[13664] = PVP_TREBUCHET_ICON, -- firepot treb
	[13665] = PVP_TREBUCHET_ICON, -- firepot treb


	[16754] = PVP_CATAPULT_ICON, -- oil cata
	[30610] = PVP_CATAPULT_ICON, -- oil cata
	[30614] = PVP_CATAPULT_ICON, -- oil cata


	[39911] = PVP_CATAPULT_ICON, -- scattershot cata
	[39915] = PVP_CATAPULT_ICON, -- scattershot cata
	[39918] = PVP_CATAPULT_ICON, -- scattershot cata

	[16755] = PVP_CATAPULT_ICON, -- meatbag cata
	[30609] = PVP_CATAPULT_ICON, -- meatbag cata
	[30613] = PVP_CATAPULT_ICON, -- meatbag cata


	[66435] = "esoui/art/icons/ava_siege_weapon_darkanchor_bluefireballista.dds", -- cf ballista
	[66387] = "esoui/art/icons/ava_siege_weapon_darkanchor_bluefiretrebuchet.dds", -- cf fire treb
	[66440] = "esoui/art/icons/ava_siege_weapon_darkanchor_bluestonetrebuchet.dds", -- cf stone treb

	[12256] = "esoui/art/icons/collectible_crafting_bag.dds", -- pack siege

	[15876] = "esoui/art/icons/ava_siege_weapon_004.dds", -- ram
	[16170] = "esoui/art/icons/ava_siege_weapon_004.dds", -- ram
	[16171] = "esoui/art/icons/ava_siege_weapon_004.dds", -- ram


	[16751] = PVP_BALLISTA_ICON, -- fire ballista
	[30607] = PVP_BALLISTA_ICON, -- fire ballista
	[30611] = PVP_BALLISTA_ICON, -- fire ballista

	[16752] = PVP_BALLISTA_ICON, -- lightning ballista
	[30608] = PVP_BALLISTA_ICON, -- lightning ballista
	[30612] = PVP_BALLISTA_ICON, -- lightning ballista

	[29671] = PVP_BALLISTA_ICON, -- ballista
	[29672] = PVP_BALLISTA_ICON, -- ballista
	[29673] = PVP_BALLISTA_ICON, -- ballista
}


function MCI:InsertAnimationType(animHandler, animType, control, animDuration, animDelay, animEasing, ...)
	if not animHandler then return end
	if animType==ANIMATION_SCALE then
		local animationScale, startScale, endScale = animHandler:InsertAnimation(ANIMATION_SCALE, control, animDelay), ...
		animationScale:SetScaleValues(startScale, endScale)
		animationScale:SetDuration(animDuration)
		animationScale:SetEasingFunction(animEasing)
	elseif animType==ANIMATION_ALPHA then
		local animationAlpha, startAlpha, endAlpha = animHandler:InsertAnimation(ANIMATION_ALPHA, control, animDelay), ...
		animationAlpha:SetAlphaValues(startAlpha, endAlpha)
		animationAlpha:SetDuration(animDuration)
		animationAlpha:SetEasingFunction(animEasing)
	elseif animType==ANIMATION_TRANSLATE then
		local animationTranslate, startX, startY, offsetX, offsetY = animHandler:InsertAnimation(ANIMATION_TRANSLATE, control, animDelay), ...
   	animationTranslate:SetTranslateOffsets(startX, startY, offsetX, offsetY)
		animationTranslate:SetDuration(animDuration)
		animationTranslate:SetEasingFunction(animEasing)
	elseif animType==ANIMATION_ROTATE3D then
		local animationRotate3D, startPitchRadians, startYawRadians, startRollRadians, endPitchRadians, endYawRadians, endRollRadians = animHandler:InsertAnimation(ANIMATION_ROTATE3D, control, animDelay), ...
		animationRotate3D:SetRotationValues(startPitchRadians, startYawRadians, startRollRadians, endPitchRadians, endYawRadians, endRollRadians)
		animationRotate3D:SetDuration(animDuration)
		animationRotate3D:SetEasingFunction(animEasing)
	end
end

function MCI.OnPlayerActivated()
	MCI.playerName = GetRawUnitName('player')
end

local function PlayPopUpAnimation(control)
	if LEADINGEDGE_CONTROL.animData then LEADINGEDGE_CONTROL.animData:Stop() end

	local timeline = ANIMATION_MANAGER:CreateTimeline()

	local targetScale = MCI.chargeUpScale*1.2

	local _, point, relativeTo, relativePoint, offsetX, offsetY = MAIN_CONTROL:GetAnchor()

	MAIN_CONTROL:ClearAnchors()
	MAIN_CONTROL:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)


	MCI:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100,   10, ZO_EaseInQuadratic, MCI.chargeUpScale, targetScale)
	MCI:InsertAnimationType(timeline, ANIMATION_SCALE, control, 150, 150, ZO_EaseOutQuadratic, targetScale, MCI.chargeUpScale)


    timeline:SetHandler('OnStop', function()
		control:SetScale(MCI.chargeUpScale)
		if COOLDOWN_CONTROL:GetTimeLeft()==0 then
			control:SetHidden(true)
		end
	end)

    timeline:PlayFromStart()
	if MAIN_CONTROL.isHA then
		HIGHLIGHT_CONTROL.animData:PingPong(0, 1, 750 * (1 / 3), 1)
	else
		GLOW_CONTROL.animData:PingPong(0, 1, 750 * (1 / 3), 1)
	end
	return timeline
end

local function PlayLeadingEdgeAnimation(control, hitValue)
	if LEADINGEDGE_CONTROL.animData then LEADINGEDGE_CONTROL.animData:Stop() end

	local timeline = ANIMATION_MANAGER:CreateTimeline()
	local _, offsetY = ICON_CONTROL:GetDimensions()

	control:ClearAnchors()
	control:SetAnchor(CENTER, ICON_CONTROL, BOTTOM, 0, 4)

	MCI:InsertAnimationType(timeline, ANIMATION_TRANSLATE, control, hitValue, 0, ZO_LinearEase, 0, 4, 0, -100)

    timeline:SetHandler('OnStop', function()
		control:SetHidden(true)
	end)



	control:SetHidden(false)
    timeline:PlayFromStart()
	return timeline
end

function MCI.OnCombat(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, combat_log, sourceUnitId, targetUnitId, abilityId)
	if sourceName == MCI.playerName and MCI.IsPopUpAnimationStopped() and ((result == 2245 and abilityId == 28549) or (result == 2240 and abilityId == 14890) or (MAIN_CONTROL.abilityId == abilityId and MCI.failedEvents[result])) then
		MCI.ResetMainControl()
	end

	if result == ACTION_RESULT_BEGIN and MCI.IsUnitPlayer(sourceName) then
		if MCI.IsDirtyHackActive() and GetSlotBoundId(2) == abilityId then
			MCI.dirtyHack = nil
			return
		end

		if MCI.dirtyHack then MCI.dirtyHack = nil end

		local abilityIcon

		if MCI.heavyAttackId[abilityId] then
			abilityIcon = MCI.heavyAttackId[abilityId]
			MAIN_CONTROL.isHA = true
			-- ICON_CONTROL:SetColor(MCI.heavyIconColors[abilityId]:UnpackRGBA())
			ICON_CONTROL:SetColor(1,1,1,1)
			HIGHLIGHT_CONTROL:SetTexture(abilityIcon)
			MCI.chargeUpScale = 0.6 * MCI.SV.scale

		elseif abilityId == PVP_MOUNT_ABILITYID then
			_,_,abilityIcon = GetCollectibleInfo(GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT))
			MAIN_CONTROL.isHA = true
			ICON_CONTROL:SetColor(1,1,1,1)
			HIGHLIGHT_CONTROL:SetTexture(abilityIcon)
			MCI.chargeUpScale = 0.6 * MCI.SV.scale
		elseif MCI.custom[abilityId] then
			abilityIcon = MCI.custom[abilityId]
			MAIN_CONTROL.isHA = true
			ICON_CONTROL:SetColor(1,1,1,1)
			HIGHLIGHT_CONTROL:SetTexture(abilityIcon)
			MCI.chargeUpScale = 0.6 * MCI.SV.scale
		else
			abilityIcon = GetAbilityIcon(abilityId)
			MAIN_CONTROL.isHA = false
			ICON_CONTROL:SetColor(1,1,1,1)
			MCI.chargeUpScale = 0.54 * MCI.SV.scale
		end

		-- LABEL_CONTROL:SetText(GetAbilityName(abilityId))

		MAIN_CONTROL:SetScale(MCI.chargeUpScale)

		local popUpPlaying = not MCI.IsPopUpAnimationStopped()

		ICON_CONTROL:SetTexture(abilityIcon)
		COOLDOWN_CONTROL:SetTexture(abilityIcon)
		COOLDOWN_CONTROL:ResetCooldown()

		if popUpPlaying then
			MCI.popUpAnim:Stop()
			HIGHLIGHT_CONTROL.animData:Stop()
			GLOW_CONTROL.animData:Stop()
			HIGHLIGHT_CONTROL:SetAlpha(0)
			GLOW_CONTROL:SetAlpha(0)
		end

		if LEADINGEDGE_CONTROL.animData then LEADINGEDGE_CONTROL.animData:Stop() end
		COOLDOWN_CONTROL:StartCooldown(hitValue, hitValue, CD_TYPE_VERTICAL_REVEAL, CD_TIME_TYPE_TIME_UNTIL, false)
		if not MAIN_CONTROL.isHA then
			LEADINGEDGE_CONTROL.animData = PlayLeadingEdgeAnimation(LEADINGEDGE_CONTROL, hitValue)
		end

		MAIN_CONTROL:SetHidden(false)
		MAIN_CONTROL.abilityId = abilityId
		MAIN_CONTROL.coolDownStartTime = GetFrameTimeMilliseconds()

		zo_callLater(function()
			if COOLDOWN_CONTROL:GetTimeLeft()==0 and MCI.IsPopUpAnimationStopped() then
				MAIN_CONTROL.abilityId = nil
				MCI.popUpAnim = PlayPopUpAnimation(MAIN_CONTROL)
			end
		end, hitValue+10)
	end
end

function MCI.OnWeaponPairChanged()
	if MCI.IsPopUpAnimationStopped() then
		MCI.ResetMainControl()
	end
end

function MCI.OnVibration(eventCode, param1, param2, param3, param4)
	zo_callLater(function() MCI.OnVibrationDelayed(eventCode, param1, param2, param3, param4) end, 75)
end

function MCI.OnVibrationDelayed(eventCode, param1, param2, param3, param4)
	if param1 == 250 and param2 == 0.25 and param3 == 0.25 then
		if MCI.IsPopUpAnimationStopped() and MAIN_CONTROL.abilityId and MAIN_CONTROL.abilityId == GetSlotBoundId(2) then
			MCI.ResetMainControl()
		end
	end
end

function MCI.IsPopUpAnimationStopped()
	return not (MCI.popUpAnim and MCI.popUpAnim:IsPlaying())
end

function MCI.ResetMainControl()
	COOLDOWN_CONTROL:ResetCooldown()
	MAIN_CONTROL:SetHidden(not MCI.SV.unlocked)
	MAIN_CONTROL.abilityId = nil
	MCI.dirtyHack = nil
end

function MCI.IsDirtyHackActive()
	return MCI.dirtyHack and MCI.dirtyHack[2] == 2
end

function MCI.IsUnitPlayer(unitName)
	if not unitName or unitName == "" then return false end
	if not MCI.playerName then MCI.playerName = GetRawUnitName('player') end
	return unitName == MCI.playerName  or unitName == MCI.playerName.."^Mx" or unitName == MCI.playerName.."^Fx"
end


function MCI.OnAbilityUsed(eventCode, slotNum)
	if slotNum ~= 2 then return end

	local currentTime=GetFrameTimeMilliseconds()
	local abilityId = GetSlotBoundId(slotNum)
	local isFrameShown = (not MAIN_CONTROL:IsHidden())
	local isSameSlot = MAIN_CONTROL.abilityId == abilityId

	if isFrameShown then
		if MCI.IsPopUpAnimationStopped() and isSameSlot then
			local elapsedTime = GetFrameTimeMilliseconds() - MAIN_CONTROL.coolDownStartTime
			local percent = elapsedTime/COOLDOWN_CONTROL:GetDuration()
			if percent>=0.95 then
				MAIN_CONTROL.abilityId	= nil
				MCI.popUpAnim = PlayPopUpAnimation(MAIN_CONTROL)
			else
				MCI.ResetMainControl()
			end
		end
	elseif MCI.dirtyHack and MCI.dirtyHack[2] == 1 and currentTime-MCI.dirtyHack[1]<400 then
		MCI.dirtyHack = {currentTime, 2}
	else
		MCI.dirtyHack = {currentTime, 1}
	end
end

function MiatCastIcon_SavePosition()
	local coordX, coordY=MAIN_CONTROL:GetCenter()
	MCI.SV.offsetX=coordX-(GuiRoot:GetWidth()/2)
	MCI.SV.offsetY=coordY-(GuiRoot:GetHeight()/2)
	MAIN_CONTROL:ClearAnchors()
	MAIN_CONTROL:SetAnchor(CENTER, GuiRoot, CENTER, MCI.SV.offsetX, MCI.SV.offsetY)
end

function MiatCastIcon_OnMouseWheel(control, delta)
	if not MCI.SV.unlocked then return end

	local scale = MCI.SV.scale + delta*0.01
	if scale <= 0 or scale >= 2 then return end

	MAIN_CONTROL:SetScale(scale*0.54)
	MCI.SV.scale = scale
end

function MCI.OnUpdate()
	if not MAIN_CONTROL.abilityId then return end
	if (MCI.custom[MAIN_CONTROL.abilityId] or MAIN_CONTROL.abilityId == PVP_MOUNT_ABILITYID) and IsPlayerMoving() then
		MCI.ResetMainControl()
	end
end

MCI.defaults = {
	unlocked = true,
	scale = 1.0,
	offsetX = 0,
	offsetY = 0,
}

function MCI.InitControls()
	MAIN_CONTROL:ClearAnchors()
	MAIN_CONTROL:SetAnchor(CENTER, GuiRoot, CENTER, MCI.SV.offsetX, MCI.SV.offsetY)
	MAIN_CONTROL:SetMovable(MCI.SV.unlocked)
	MAIN_CONTROL:SetMouseEnabled(MCI.SV.unlocked)
	MAIN_CONTROL:SetHidden(not MCI.SV.unlocked)
	if MCI.SV.unlocked then
		LABEL_CONTROL:SetText('Unlocked')
	else
		LABEL_CONTROL:SetText('')
	end
	MAIN_CONTROL:SetScale(MCI.SV.scale*0.54)
end

function MCI.InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Miat's CastIcon",
		displayName = "Miat's CastIcon",
		author = "Dorrino",
		version = MCI.textVersion,
		slashCommand = "/casticon",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function()
			MCI.SV.offsetX=0
			MCI.SV.offsetY=0
			MCI.SV.scale=1
			MCI.InitControls()
		end
	}

	local optionsPanel = LAM2:RegisterAddonPanel("CastIcon", panelData)

	local optionsData = {}


	table.insert(optionsData, {
		type = "header",
		name = "Main Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with CastIcon position",
		tooltip = "ON - icon can me moved on the screen by left clicking and dragging, OFF - icon is locked in place and can not be moved",
		default = MCI.defaults.unlocked,
		getFunc = function() return MCI.SV.unlocked end,
		setFunc = function(newValue) MCI.SV.unlocked = newValue MCI.InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Size of CastIcon",
		tooltip = "Default size is 100%",
		default = MCI.defaults.scale,
		min     = 10,
        max     = 300,
        step    = 1,
		getFunc = function() return tonumber(string.format("%.0f", 100*MCI.SV.scale)) end,
		setFunc = function(newValue) MCI.SV.scale = newValue/100 MCI.InitControls() end,
	})
	LAM2:RegisterOptionControls("CastIcon", optionsData)
end

function MCI.OnLoaded(eventCode, addonName)
	if addonName~=MCI.name then return end

	MCI.SV = ZO_SavedVars:NewAccountWide("MiatCastIconSettings", MCI.version, "Settings", MCI.defaults)

	-- MCI.SV.unlocked = false

	MCI.InitializeAddonMenu()

	MCI.InitControls()

	EVENT_MANAGER:UnregisterForEvent(MCI.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(MCI.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, MCI.OnWeaponPairChanged)
	EVENT_MANAGER:RegisterForEvent(MCI.name, EVENT_COMBAT_EVENT, MCI.OnCombat)
	EVENT_MANAGER:RegisterForEvent(MCI.name, EVENT_ACTION_SLOT_ABILITY_USED, MCI.OnAbilityUsed)
	EVENT_MANAGER:RegisterForEvent(MCI.name, EVENT_VIBRATION, MCI.OnVibration)
	EVENT_MANAGER:RegisterForEvent(MCI.name, EVENT_PLAYER_ACTIVATED, MCI.OnPlayerActivated)
	EVENT_MANAGER:RegisterForUpdate(MCI.name, 50, MCI.OnUpdate)
end

EVENT_MANAGER:RegisterForEvent(MCI.name, EVENT_ADD_ON_LOADED, MCI.OnLoaded)
