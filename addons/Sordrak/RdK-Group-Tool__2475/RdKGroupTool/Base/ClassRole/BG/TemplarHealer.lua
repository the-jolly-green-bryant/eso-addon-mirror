-- RdK Group Tool Class Role
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.classRole = RdKGTool.classRole or {}
local RdKGToolCR = RdKGTool.classRole
RdKGToolCR.bg = RdKGToolCR.bg or {}
local RdKGToolBG = RdKGToolCR.bg
RdKGToolBG.tpHeal = RdKGToolBG.tpHeal or {}
local RdKGToolTH = RdKGToolBG.tpHeal
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGTool.ui = RdKGTool.ui or {}
local RdKGToolUI = RdKGTool.ui
RdKGToolUI.buffs = RdKGToolUI.buffs or {}
local RdKGToolBuffs = RdKGToolUI.buffs



RdKGToolTH.constants = RdKGToolTH.constants or {}
RdKGToolTH.constants.TLW = "RdKGTool.classRole.bg.tpHeal.tlw"
RdKGToolTH.constants.BUFF_TYPES = {}
RdKGToolTH.constants.BUFF_TYPES.DAMAGE = 1
RdKGToolTH.constants.BUFF_TYPES.HEALING = 2
RdKGToolTH.constants.BUFF_TYPES.RECOVERY = 3
RdKGToolTH.constants.COOLDOWN_TYPES = {}
RdKGToolTH.constants.COOLDOWN_TYPES.NONE = 1
RdKGToolTH.constants.COOLDOWN_TYPES.PROC = 2

RdKGToolTH.callbackName = RdKGTool.addonName .. "BGTemplarHealer"

RdKGToolTH.config = {}
RdKGToolTH.config.updateInterval = 100
RdKGToolTH.config.isClampedToScreen = false
RdKGToolTH.config.width = 150

RdKGToolTH.config.buffs = {}
RdKGToolTH.config.buffs[1] = {}
RdKGToolTH.config.buffs[1].texture = "/esoui/art/icons/ability_buff_major_sorcery.dds"
RdKGToolTH.config.buffs[1].ids = {}
RdKGToolTH.config.buffs[1].ids[1] = 92503
RdKGToolTH.config.buffs[1].name = "majorSorcery"
RdKGToolTH.config.buffs[1].buffType = RdKGToolTH.constants.BUFF_TYPES.DAMAGE
RdKGToolTH.config.buffs[1].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.buffs[2] = {}
RdKGToolTH.config.buffs[2].texture = "/esoui/art/icons/ability_buff_minor_sorcery.dds"
RdKGToolTH.config.buffs[2].ids = {}
RdKGToolTH.config.buffs[2].ids[1] = 62800
RdKGToolTH.config.buffs[2].name = "minorSorcery"
RdKGToolTH.config.buffs[2].buffType = RdKGToolTH.constants.BUFF_TYPES.DAMAGE
RdKGToolTH.config.buffs[2].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.buffs[3] = {}
RdKGToolTH.config.buffs[3].texture = "/esoui/art/icons/ability_mage_045.dds" -- courage
RdKGToolTH.config.buffs[3].ids = {}
RdKGToolTH.config.buffs[3].ids[1] = 109994
RdKGToolTH.config.buffs[3].name = "majorCourage"
RdKGToolTH.config.buffs[3].buffType = RdKGToolTH.constants.BUFF_TYPES.DAMAGE
RdKGToolTH.config.buffs[3].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.buffs[4] = {}
RdKGToolTH.config.buffs[4].texture = "/esoui/art/icons/ava_artifact_006.dds" -- weapon glyph
RdKGToolTH.config.buffs[4].ids = {}
RdKGToolTH.config.buffs[4].ids[1] = 21230
RdKGToolTH.config.buffs[4].name = "weaponGlyph"
RdKGToolTH.config.buffs[4].buffType = RdKGToolTH.constants.BUFF_TYPES.DAMAGE
RdKGToolTH.config.buffs[4].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.PROC
RdKGToolTH.config.buffs[4].cooldown = {}
RdKGToolTH.config.buffs[4].cooldown.lastProc = 0
RdKGToolTH.config.buffs[4].cooldown.duration = 10
RdKGToolTH.config.buffs[5] = {}
RdKGToolTH.config.buffs[5].texture = "/esoui/art/icons/ability_weapon_028.dds" -- continous attack
RdKGToolTH.config.buffs[5].ids = {}
RdKGToolTH.config.buffs[5].ids[1] = 45617
RdKGToolTH.config.buffs[5].name = "continousAttack"
RdKGToolTH.config.buffs[5].buffType = RdKGToolTH.constants.BUFF_TYPES.DAMAGE
RdKGToolTH.config.buffs[5].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.buffs[6] = {}
RdKGToolTH.config.buffs[6].texture = "/esoui/art/icons/ability_buff_major_mending.dds"
RdKGToolTH.config.buffs[6].ids = {}
RdKGToolTH.config.buffs[6].ids[1] = 77922
RdKGToolTH.config.buffs[6].name = "majorMending"
RdKGToolTH.config.buffs[6].buffType = RdKGToolTH.constants.BUFF_TYPES.HEALING
RdKGToolTH.config.buffs[6].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.buffs[7] = {}
RdKGToolTH.config.buffs[7].texture = "/esoui/art/icons/ability_buff_minor_mending.dds"
RdKGToolTH.config.buffs[7].ids = {}
RdKGToolTH.config.buffs[7].ids[1] = 77082
RdKGToolTH.config.buffs[7].ids[2] = 31759
RdKGToolTH.config.buffs[7].name = "minorMending"
RdKGToolTH.config.buffs[7].buffType = RdKGToolTH.constants.BUFF_TYPES.HEALING
RdKGToolTH.config.buffs[7].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.buffs[8] = {}
RdKGToolTH.config.buffs[8].texture = "/esoui/art/icons/ability_templar_channeled_focus.dds"
RdKGToolTH.config.buffs[8].ids = {}
RdKGToolTH.config.buffs[8].ids[1] = 37009
RdKGToolTH.config.buffs[8].name = "channeledFocus"
RdKGToolTH.config.buffs[8].buffType = RdKGToolTH.constants.BUFF_TYPES.RECOVERY
RdKGToolTH.config.buffs[8].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.buffs[9] = {}
RdKGToolTH.config.buffs[9].texture = "/esoui/art/icons/ability_mage_045.dds" -- lich
RdKGToolTH.config.buffs[9].ids = {}
RdKGToolTH.config.buffs[9].ids[1] = 57164
RdKGToolTH.config.buffs[9].name = "lich"
RdKGToolTH.config.buffs[9].buffType = RdKGToolTH.constants.BUFF_TYPES.RECOVERY
RdKGToolTH.config.buffs[9].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.PROC
RdKGToolTH.config.buffs[9].cooldown = {}
RdKGToolTH.config.buffs[9].cooldown.lastProc = 0
RdKGToolTH.config.buffs[9].cooldown.duration = 60
RdKGToolTH.config.buffs[10] = {}
RdKGToolTH.config.buffs[10].texture = "/esoui/art/icons/ability_buff_major_intellect.dds"
RdKGToolTH.config.buffs[10].ids = {}
RdKGToolTH.config.buffs[10].ids[1] = 45224
RdKGToolTH.config.buffs[10].name = "majorIntellect"
RdKGToolTH.config.buffs[10].buffType = RdKGToolTH.constants.BUFF_TYPES.RECOVERY
RdKGToolTH.config.buffs[10].cdType = RdKGToolTH.constants.COOLDOWN_TYPES.NONE
RdKGToolTH.config.height = #RdKGToolTH.config.buffs * 20

RdKGToolTH.state = {}
RdKGToolTH.state.initialized = false
RdKGToolTH.state.foreground = true
RdKGToolTH.state.registredConsumers = false
RdKGToolTH.state.registredActiveConsumers = false
RdKGToolTH.state.activeLayerIndex = 1

RdKGToolTH.controls = {}

local wm = WINDOW_MANAGER
local buffControls = nil

function RdKGToolTH.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolTH.callbackName, RdKGToolTH.OnProfileChanged)
	
	RdKGToolTH.CreateUI()
	
	buffControls = RdKGToolTH.controls.TLW.rootControl.buffs
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolTH.SetCrBgTpHealPositionLocked)
	
	RdKGToolTH.state.initialized = true
	RdKGToolTH.AdjustColors()
	RdKGToolTH.SetEnabled(RdKGToolTH.tpVars.enabled)
end

function RdKGToolTH.SetTlwLocation()
	if RdKGToolTH.tpVars.location == nil then
		RdKGToolTH.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, -200, -125)
	else
		RdKGToolTH.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolTH.tpVars.location.x, RdKGToolTH.tpVars.location.y)
	end
end

function RdKGToolTH.CreateUI()
	RdKGToolTH.controls.TLW = wm:CreateTopLevelWindow(RdKGToolTH.constants.TLW)
	
	RdKGToolTH.SetTlwLocation()
	
	
	RdKGToolTH.controls.TLW:SetClampedToScreen(RdKGToolTH.config.isClampedToScreen)
	RdKGToolTH.controls.TLW:SetHandler("OnMoveStop", RdKGToolTH.SaveWindowLocation)
	RdKGToolTH.controls.TLW:SetDimensions(RdKGToolTH.config.width, RdKGToolTH.config.height)
	
	RdKGToolTH.controls.TLW.rootControl = wm:CreateControl(nil, RdKGToolTH.controls.TLW, CT_CONTROL)
	
	local rootControl = RdKGToolTH.controls.TLW.rootControl
	
	rootControl:SetDimensions(RdKGToolTH.config.width, RdKGToolTH.config.height)
	rootControl:SetAnchor(TOPLEFT, RdKGToolTH.controls.TLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(RdKGToolTH.config.width, RdKGToolTH.config.height)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	rootControl.buffs = {}
	for i = 1, 10 do
		rootControl.buffs[i] = RdKGToolBuffs.CreateBuffControl(rootControl, 0, (i - 1) * 20)
		rootControl.buffs[i].texture:SetTexture(RdKGToolTH.config.buffs[i].texture)
	end
	
end

function RdKGToolTH.GetDefaults()
	local defaults = {}
	
	return defaults
end

function RdKGToolTH.GetCharDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.pvpOnly = true
	defaults.positionLocked = false
	defaults.damageColor = {}
	defaults.damageColor.r = 0.9
	defaults.damageColor.g = 0.2
	defaults.damageColor.b = 0.2
	defaults.healingColor = {}
	defaults.healingColor.r = 0.2
	defaults.healingColor.g = 0.9
	defaults.healingColor.b = 0.2
	defaults.recoveryColor = {}
	defaults.recoveryColor.r = 0.2
	defaults.recoveryColor.g = 0.2
	defaults.recoveryColor.b = 0.9
	defaults.damageLabelColor = {}
	defaults.damageLabelColor.r = 1
	defaults.damageLabelColor.g = 1
	defaults.damageLabelColor.b = 1
	defaults.healingLabelColor = {}
	defaults.healingLabelColor.r = 1
	defaults.healingLabelColor.g = 1
	defaults.healingLabelColor.b = 1
	defaults.recoveryLabelColor = {}
	defaults.recoveryLabelColor.r = 1
	defaults.recoveryLabelColor.g = 1
	defaults.recoveryLabelColor.b = 1
	defaults.cooldownLabelColor = {}
	defaults.cooldownLabelColor.r = 1
	defaults.cooldownLabelColor.g = 0.1
	defaults.cooldownLabelColor.b = 0.1
	return defaults
end

function RdKGToolTH.SetEnabled(value)
	if RdKGToolTH.state.initialized == true and value ~= nil then
		RdKGToolTH.tpVars.enabled = value
		if value == true then
			if RdKGToolTH.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolTH.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolTH.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolTH.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolTH.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolTH.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolTH.OnPlayerActivated)
			end
			RdKGToolTH.state.registredConsumers = true
		else
			if RdKGToolTH.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolTH.callbackName, EVENT_ACTION_LAYER_POPPED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolTH.callbackName, EVENT_ACTION_LAYER_PUSHED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolTH.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolTH.state.registredConsumers = false
		end
		RdKGToolTH.SetControlVisibility()
		RdKGToolTH.OnPlayerActivated()
	end
end

function RdKGToolTH.GetBuffColors(buffType)
	local color = RdKGToolTH.tpVars.damageColor
	local textColor = RdKGToolTH.tpVars.damageLabelColor
	if buffType == RdKGToolTH.constants.BUFF_TYPES.HEALING then
		color = RdKGToolTH.tpVars.healingColor
		textColor = RdKGToolTH.tpVars.healingLabelColor
	elseif buffType == RdKGToolTH.constants.BUFF_TYPES.RECOVERY then
		color = RdKGToolTH.tpVars.recoveryColor
		textColor = RdKGToolTH.tpVars.recoveryLabelColor
	end
	return color, textColor
end

function RdKGToolTH.AdjustColors()
	for i = 1, #buffControls do
		local color, textColor = RdKGToolTH.GetBuffColors(RdKGToolTH.config.buffs[i].buffType)

		buffControls[i].progress:SetColor(color.r, color.g, color.b ,0.7)
		buffControls[i].timeLabel:SetColor(textColor.r, textColor.g, textColor.b ,1.0)
	end
end

function RdKGToolTH.SetPositionLocked(value)
	RdKGToolTH.tpVars.positionLocked = value
	RdKGToolTH.controls.TLW:SetMovable(not value)
	RdKGToolTH.controls.TLW:SetMouseEnabled(not value)
	
	if value == true then
		RdKGToolTH.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolTH.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolTH.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolTH.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
	--RdKGToolTH.SetControlVisibility()
end

function RdKGToolTH.SetControlVisibility()
	local enabled = RdKGToolTH.tpVars.enabled
	local pvpOnly = RdKGToolTH.tpVars.pvpOnly
	local setHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolTH.state.foreground == false then
			RdKGToolTH.controls.TLW:SetHidden(RdKGToolTH.state.activeLayerIndex > 2)
		else
			RdKGToolTH.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolTH.controls.TLW:SetHidden(setHidden)
	end
end

function RdKGToolTH.AdjustProgress(buff, control, currentTime)
	local timer = 0
	local percent = 0
	if buff ~= nil then
		buff.remaining = buff.ending - (currentTime / 1000)
		if buff.remaining < 0 then
			buff.remaining = 0
		end
		timer = buff.remaining
		--d(timer)
		
		
		if buff.started == buff.ending and buff.started == 0 then
			percent = 100
		else
			if buff.remaining > 0 then
				percent = 100 / (buff.ending - buff.started) * buff.remaining
			end
		end
		
	end
	control.timeLabel:SetText(string.format("%.1f", timer))
	control.progress:SetValue(percent)
end

function RdKGToolTH.CreateCharVars()
		local charVars = RdKGTool.profile.GetCharacterVars()
		charVars.crBgTp = charVars.crBgTp or {}
		RdKGToolTH.tpVars = charVars.crBgTp
		
		local defaults = RdKGToolTH.GetCharDefaults()
		
		RdKGTool.PopulateWithDefaults(RdKGToolTH.tpVars, defaults)
		
end

--callbacks
function RdKGToolTH.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		--RdKGToolTH.tpVars = currentProfile.classRole.bg.tpHeal
		RdKGToolTH.CreateCharVars()

		if RdKGToolTH.state.initialized == true then
			RdKGToolTH.SetControlVisibility()
			RdKGToolTH.AdjustColors()
			RdKGToolTH.SetPositionLocked(RdKGToolTH.tpVars.positionLocked)
			RdKGToolTH.SetTlwLocation()
		end
		RdKGToolTH.SetEnabled(RdKGToolTH.tpVars.enabled)
		
	end
end

function RdKGToolTH.SaveWindowLocation()
	if RdKGToolTH.tpVars.positionLocked == false then
		RdKGToolTH.tpVars.location = RdKGToolTH.tpVars.location or {}
		RdKGToolTH.tpVars.location.x = RdKGToolTH.controls.TLW:GetLeft()
		RdKGToolTH.tpVars.location.y = RdKGToolTH.controls.TLW:GetTop()
	end
end

function RdKGToolTH.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolTH.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolTH.state.foreground = false
	end
	--hack?
	RdKGToolTH.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolTH.SetControlVisibility()
end

function RdKGToolTH.OnPlayerActivated(eventCode, initial)
	if RdKGToolTH.tpVars.enabled == true and (RdKGToolTH.tpVars.pvpOnly == false or (RdKGToolTH.tpVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolTH.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForUpdate(RdKGToolTH.callbackName, RdKGToolTH.config.updateInterval, RdKGToolTH.UiLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolTH.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolTH.config.updateInterval)
			RdKGToolUtilGroup.SetCrBgTpHealBuffs(RdKGToolTH.config.buffs)
			
			RdKGToolTH.state.registredActiveConsumers = true
		end
	else
		if RdKGToolTH.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolTH.callbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolTH.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
			RdKGToolUtilGroup.SetCrBgTpHealBuffs(nil)
			
			RdKGToolTH.state.registredActiveConsumers = false
		end
	end
	RdKGToolTH.SetControlVisibility()
end

function RdKGToolTH.UiLoop()
	--d("loop")
	if RdKGToolTH.tpVars.pvpOnly == false or (RdKGToolTH.tpVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea()) then
		--d("inner loop")
		local buffs = RdKGToolUtilGroup.GetUnitFromRawCharName(GetRawUnitName("player")).buffs
		if buffs ~= nil and buffs.specialInformation ~= nil and buffs.specialInformation.crBgTpHealBuffs ~= nil then
			buffs = RdKGToolUtilGroup.GetUnitFromRawCharName(GetRawUnitName("player")).buffs.specialInformation.crBgTpHealBuffs
			local confBuffs = RdKGToolTH.config.buffs
			local currentTime = GetGameTimeMilliseconds()
			--d(buffs)
			for i = 1, #confBuffs do
				RdKGToolTH.AdjustProgress(buffs[confBuffs[i].name], buffControls[i], currentTime)
				if confBuffs[i].cdType == RdKGToolTH.constants.COOLDOWN_TYPES.PROC then
					local buff = buffs[confBuffs[i].name]
					local _, labelColor = RdKGToolTH.GetBuffColors(confBuffs[i].buffType)
					if buff == nil then
						if confBuffs[i].cooldown.lastProc > 0 then
							local timeSinceProc = currentTime / 1000 - confBuffs[i].cooldown.lastProc
							local timer = confBuffs[i].cooldown.duration - timeSinceProc
							if timer < 0 then
								timer = 0
							end
							if timer > 0 then
								labelColor = RdKGToolTH.tpVars.cooldownLabelColor
							end
							buffControls[i].timeLabel:SetColor(labelColor.r, labelColor.g, labelColor.b ,1.0)
							buffControls[i].timeLabel:SetText(string.format("%.1f", timer))
						end
					else
						
						confBuffs[i].cooldown.lastProc = buff.started
						buffControls[i].timeLabel:SetColor(labelColor.r, labelColor.g, labelColor.b ,1.0)
					end
				end
			end
		end
	end
end


--menu interaction
function RdKGToolTH.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.CRBG_TPHEAL_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_ENABLED,
					getFunc = RdKGToolTH.GetCrBgTpHealEnabled,
					setFunc = RdKGToolTH.SetCrBgTpHealEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_PVP_ONLY,
					getFunc = RdKGToolTH.GetCrBgTpHealPvpOnly,
					setFunc = RdKGToolTH.SetCrBgTpHealPvpOnly
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_POSITION_FIXED,
					getFunc = RdKGToolTH.GetCrBgTpHealPositionLocked,
					setFunc = RdKGToolTH.SetCrBgTpHealPositionLocked
				},
				[4] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_DAMAGE,
					getFunc = RdKGToolTH.GetCrBgTpHealColorProgressDamage,
					setFunc = RdKGToolTH.SetCrBgTpHealColorProgressDamage,
					width = "full"
				},
				[5] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_DAMAGE,
					getFunc = RdKGToolTH.GetCrBgTpHealColorLabelDamage,
					setFunc = RdKGToolTH.SetCrBgTpHealColorLabelDamage,
					width = "full"
				},
				[6] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_HEALING,
					getFunc = RdKGToolTH.GetCrBgTpHealColorProgressHealing,
					setFunc = RdKGToolTH.SetCrBgTpHealColorProgressHealing,
					width = "full"
				},
				[7] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_HEALING,
					getFunc = RdKGToolTH.GetCrBgTpHealColorLabelHealing,
					setFunc = RdKGToolTH.SetCrBgTpHealColorLabelHealing,
					width = "full"
				},
				[8] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_RECOVERY,
					getFunc = RdKGToolTH.GetCrBgTpHealColorProgressRecovery,
					setFunc = RdKGToolTH.SetCrBgTpHealColorProgressRecovery,
					width = "full"
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_RECOVERY,
					getFunc = RdKGToolTH.GetCrBgTpHealColorLabelRecovery,
					setFunc = RdKGToolTH.SetCrBgTpHealColorLabelRecovery,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_COOLDOWN,
					getFunc = RdKGToolTH.GetCrBgTpHealColorLabelCooldown,
					setFunc = RdKGToolTH.SetCrBgTpHealColorLabelCooldown,
					width = "full"
				},
			}
		},
	}
	return menu
end

function RdKGToolTH.GetCrBgTpHealEnabled()
	return RdKGToolTH.tpVars.enabled
end

function RdKGToolTH.SetCrBgTpHealEnabled(value)
	RdKGToolTH.SetEnabled(value)
end

function RdKGToolTH.GetCrBgTpHealPositionLocked()
	return RdKGToolTH.tpVars.positionLocked
end

function RdKGToolTH.SetCrBgTpHealPositionLocked(value)
	RdKGToolTH.SetPositionLocked(value)
end

function RdKGToolTH.GetCrBgTpHealPvpOnly()
	return RdKGToolTH.tpVars.pvpOnly
end

function RdKGToolTH.SetCrBgTpHealPvpOnly(value)
	RdKGToolTH.tpVars.pvpOnly = value
	RdKGToolTH.SetEnabled(RdKGToolTH.tpVars.enabled)
end

function RdKGToolTH.GetCrBgTpHealColorProgressDamage()
	return RdKGToolMenu.GetRGBColor(RdKGToolTH.tpVars.damageColor)
end

function RdKGToolTH.SetCrBgTpHealColorProgressDamage(r, g, b)
	RdKGToolTH.tpVars.damageColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolTH.AdjustColors()
end

function RdKGToolTH.GetCrBgTpHealColorProgressRecovery()
	return RdKGToolMenu.GetRGBColor(RdKGToolTH.tpVars.recoveryColor)
end

function RdKGToolTH.SetCrBgTpHealColorProgressRecovery(r, g, b)
	RdKGToolTH.tpVars.recoveryColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolTH.AdjustColors()
end

function RdKGToolTH.GetCrBgTpHealColorProgressHealing()
	return RdKGToolMenu.GetRGBColor(RdKGToolTH.tpVars.healingColor)
end

function RdKGToolTH.SetCrBgTpHealColorProgressHealing(r, g, b)
	RdKGToolTH.tpVars.healingColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolTH.AdjustColors()
end

function RdKGToolTH.GetCrBgTpHealColorLabelDamage()
	return RdKGToolMenu.GetRGBColor(RdKGToolTH.tpVars.damageLabelColor)
end

function RdKGToolTH.SetCrBgTpHealColorLabelDamage(r, g, b)
	RdKGToolTH.tpVars.damageLabelColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolTH.AdjustColors()
end

function RdKGToolTH.GetCrBgTpHealColorLabelRecovery()
	return RdKGToolMenu.GetRGBColor(RdKGToolTH.tpVars.recoveryLabelColor)
end

function RdKGToolTH.SetCrBgTpHealColorLabelRecovery(r, g, b)
	RdKGToolTH.tpVars.recoveryLabelColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolTH.AdjustColors()
end

function RdKGToolTH.GetCrBgTpHealColorLabelHealing()
	return RdKGToolMenu.GetRGBColor(RdKGToolTH.tpVars.healingLabelColor)
end

function RdKGToolTH.SetCrBgTpHealColorLabelHealing(r, g, b)
	RdKGToolTH.tpVars.healingLabelColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolTH.AdjustColors()
end

function RdKGToolTH.GetCrBgTpHealColorLabelCooldown()
	return RdKGToolMenu.GetRGBColor(RdKGToolTH.tpVars.cooldownLabelColor)
end

function RdKGToolTH.SetCrBgTpHealColorLabelCooldown(r, g, b)
	RdKGToolTH.tpVars.cooldownLabelColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolTH.AdjustColors()
end