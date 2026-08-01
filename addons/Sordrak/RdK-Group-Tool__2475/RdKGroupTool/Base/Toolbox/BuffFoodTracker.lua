-- RdK Group Tool Buff Food Tracker
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.bft = RdKGToolTB.bft or {}
local RdKGToolBft = RdKGToolTB.bft
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.sound = RdKGToolUtil.sound or {}
local RdKGToolSound = RdKGToolUtil.sound
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts

RdKGToolBft.constants = RdKGToolBft.constants or {}
RdKGToolBft.constants.TLW_ALERT_MESSAGE = "RdKGTool.toolbox.bft.tlw"

RdKGToolBft.constants.ALERT_INTERVAL = 30000

RdKGToolBft.callbackName = RdKGTool.addonName .. "BuffFoodTracker"

RdKGToolBft.config = {}
RdKGToolBft.config.updateInterval = 100
RdKGToolBft.config.isClampedToScreen = true
RdKGToolBft.config.ratio = 6.0

RdKGToolBft.state = {}
RdKGToolBft.state.initialized = false
RdKGToolBft.state.foreground = true
RdKGToolBft.state.registredConsumers = false
RdKGToolBft.state.lastAlert = 0
RdKGToolBft.state.outOfLoadingScreen = false
RdKGToolBft.state.registredActiveConsumers = false
RdKGToolBft.state.activeLayerIndex = 1

RdKGToolBft.controls = {}

local wm = WINDOW_MANAGER

function RdKGToolBft.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolBft.callbackName, RdKGToolBft.OnProfileChanged)
	
	RdKGToolBft.state.sounds = RdKGToolSound.GetRestrictedSounds()
	
	RdKGToolBft.CreateUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolBft.SetBftPositionLocked)
	
	RdKGToolBft.state.initialized = true
	RdKGToolBft.InitializeControlSettings()
end

function RdKGToolBft.InitializeControlSettings()
	RdKGToolBft.SetEnabled(RdKGToolBft.bftVars.enabled)
	RdKGToolBft.SetControlVisibility()
	RdKGToolBft.SetPositionLocked(RdKGToolBft.bftVars.positionLocked)
	RdKGToolBft.AdjustColors()
	RdKGToolBft.AdjustSize()
end

function RdKGToolBft.SetTlwLocation()
	RdKGToolBft.controls.alertTLW:ClearAnchors()
	if RdKGToolBft.bftVars.location == nil then
		RdKGToolBft.controls.alertTLW:SetAnchor(CENTER, GuiRoot, CENTER, 450, -450)
	else
		RdKGToolBft.controls.alertTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolBft.bftVars.location.x, RdKGToolBft.bftVars.location.y)
	end
end

function RdKGToolBft.CreateUI()
	RdKGToolBft.controls.alertTLW = wm:CreateTopLevelWindow(RdKGToolBft.constants.TLW_ALERT_MESSAGE)
	
	RdKGToolBft.SetTlwLocation()
	
	RdKGToolBft.controls.alertTLW:SetClampedToScreen(RdKGToolBft.config.isClampedToScreen)
	RdKGToolBft.controls.alertTLW:SetHandler("OnMoveStop", RdKGToolBft.SaveWindowLocation)
	
	RdKGToolBft.controls.alertTLW.rootControl = wm:CreateControl(nil, RdKGToolBft.controls.alertTLW, CT_CONTROL)
	local rootControl = RdKGToolBft.controls.alertTLW.rootControl
	
	rootControl:SetAnchor(TOPLEFT, RdKGToolBft.controls.alertTLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	rootControl.alertLabel = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.alertLabel:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 3, 0)
	rootControl.alertLabel:SetWrapMode(ELLIPSIS)
	rootControl.alertLabel:SetText("")
	
end

function RdKGToolBft.AdjustSize()
	RdKGToolBft.controls.alertTLW:SetDimensions(RdKGToolBft.config.ratio * RdKGToolBft.bftVars.size, RdKGToolBft.bftVars.size)
	RdKGToolBft.controls.alertTLW.rootControl:SetDimensions(RdKGToolBft.config.ratio * RdKGToolBft.bftVars.size, RdKGToolBft.bftVars.size)
	RdKGToolBft.controls.alertTLW.rootControl.movableBackdrop:SetDimensions(RdKGToolBft.config.ratio * RdKGToolBft.bftVars.size, RdKGToolBft.bftVars.size)
	RdKGToolBft.controls.alertTLW.rootControl.alertLabel:SetFont(RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolBft.bftVars.size - 6, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK))
	RdKGToolBft.controls.alertTLW.rootControl.alertLabel:SetDimensions(RdKGToolBft.config.ratio * RdKGToolBft.bftVars.size - 3, RdKGToolBft.bftVars.size)
end

function RdKGToolBft.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.pvpOnly = true
	defaults.positionLocked = false
	defaults.size = 60
	defaults.color = {}
	defaults.color.r = 1
	defaults.color.g = 0
	defaults.color.b = 0
	defaults.soundEnabled = true
	defaults.selectedSound = "EnlightenedState_Lost"
	defaults.warningTimer = 600
	return defaults
end

function RdKGToolBft.SetEnabled(value)
	if RdKGToolBft.state.initialized == true and value ~= nil then
		RdKGToolBft.bftVars.enabled = value
		if value == true then
			if RdKGToolBft.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolBft.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolBft.OnPlayerActivated)
				EVENT_MANAGER:RegisterForEvent(RdKGToolBft.callbackName, EVENT_PLAYER_DEACTIVATED, RdKGToolBft.OnPlayerDeactivated)
				
			end
			RdKGToolBft.state.registredConsumers = true
		else
			if RdKGToolBft.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolBft.callbackName, EVENT_PLAYER_ACTIVATED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolBft.callbackName, EVENT_PLAYER_DEACTIVATED)
				
			end
			RdKGToolBft.state.registredConsumers = false
		end
		RdKGToolBft.OnPlayerActivated()
	end
end

function RdKGToolBft.SetControlVisibility()
	local enabled = RdKGToolBft.bftVars.enabled
	local pvpOnly = RdKGToolBft.bftVars.pvpOnly
	local setHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolBft.state.foreground == false then
			RdKGToolBft.controls.alertTLW:SetHidden(RdKGToolBft.state.activeLayerIndex > 2)
		else
			RdKGToolBft.controls.alertTLW:SetHidden(false)
		end
	else
		RdKGToolBft.controls.alertTLW:SetHidden(setHidden)
	end
end

function RdKGToolBft.SetPositionLocked(value)
	RdKGToolBft.bftVars.positionLocked = value
	RdKGToolBft.controls.alertTLW:SetMovable(not value)
	RdKGToolBft.controls.alertTLW:SetMouseEnabled(not value)
	if value == true then
		RdKGToolBft.controls.alertTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolBft.controls.alertTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolBft.controls.alertTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolBft.controls.alertTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolBft.AdjustColors()
	local rootControl = RdKGToolBft.controls.alertTLW.rootControl
	rootControl.alertLabel:SetColor(RdKGToolBft.bftVars.color.r, RdKGToolBft.bftVars.color.g, RdKGToolBft.bftVars.color.b)
end

function RdKGToolBft.PlaySound()
	if RdKGToolBft.bftVars.soundEnabled == true and RdKGToolBft.bftVars.enabled == true and (RdKGToolBft.bftVars.pvpOnly == false or (RdKGToolBft.bftVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if GetGameTimeMilliseconds() > RdKGToolBft.constants.ALERT_INTERVAL + RdKGToolBft.state.lastAlert and RdKGToolBft.state.outOfLoadingScreen == true then
			RdKGToolBft.state.lastAlert = GetGameTimeMilliseconds()
			RdKGToolSound.PlaySoundByName(RdKGToolBft.bftVars.selectedSound)
		end
	end
end
--callbacks
function RdKGToolBft.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolBft.bftVars = currentProfile.toolbox.bft
		RdKGToolBft.SetEnabled(RdKGToolBft.bftVars.enabled)
		if RdKGToolBft.state.initialized == true then
			RdKGToolBft.InitializeControlSettings()
			RdKGToolBft.SetTlwLocation()
		end
	end
end

function RdKGToolBft.SaveWindowLocation()
	if RdKGToolBft.bftVars.positionLocked == false then
		RdKGToolBft.bftVars.location = RdKGToolBft.bftVars.location or {}
		RdKGToolBft.bftVars.location.x = RdKGToolBft.controls.alertTLW:GetLeft()
		RdKGToolBft.bftVars.location.y = RdKGToolBft.controls.alertTLW:GetTop()
	end
end

function RdKGToolBft.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolBft.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolBft.state.foreground = false
	end
	--hack?
	RdKGToolBft.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolBft.SetControlVisibility()
end

function RdKGToolBft.OnPlayerActivated(eventCode, initial)
	RdKGToolBft.state.lastAlert = GetGameTimeMilliseconds()
	RdKGToolBft.state.outOfLoadingScreen = true
	if RdKGToolBft.bftVars.enabled == true and (RdKGToolBft.bftVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolBft.bftVars.pvpOnly == false) then
		--d("register")
		if RdKGToolBft.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolBft.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolBft.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolBft.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolBft.SetForegroundVisibility)
			
			EVENT_MANAGER:RegisterForUpdate(RdKGToolBft.callbackName, RdKGToolBft.config.updateInterval, RdKGToolBft.UiLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolBft.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolBft.config.updateInterval)
			
			RdKGToolBft.state.registredActiveConsumers = true
		end
	else
		--d("unregister")
		if RdKGToolBft.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolBft.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolBft.callbackName, EVENT_ACTION_LAYER_PUSHED)
			
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolBft.callbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolBft.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
				
			RdKGToolBft.state.registredActiveConsumers = false
		end
	end
	RdKGToolBft.SetControlVisibility()
end

function RdKGToolBft.OnPlayerDeactivated(eventCode)
	RdKGToolBft.state.outOfLoadingScreen = false
end

function RdKGToolBft.UiLoop()
	if RdKGToolBft.bftVars.enabled == true and (RdKGToolBft.bftVars.pvpOnly == false or (RdKGToolBft.bftVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		if players ~= nil then
			for i = 1, #players do
				if players[i].displayName == GetUnitDisplayName("player") and players[i].charName == GetUnitName("player") then
					local label = RdKGToolBft.controls.alertTLW.rootControl.alertLabel
					if players[i].buffs ~= nil and players[i].buffs.specialInformation ~= nil and players[i].buffs.specialInformation.foodDrink ~= nil and 
					   players[i].buffs.specialInformation.foodDrink.active == true and players[i].buffs.specialInformation.foodDrink.ending ~= nil then
						local left = players[i].buffs.specialInformation.foodDrink.ending - (GetGameTimeMilliseconds() / 1000)
						if left > RdKGToolBft.bftVars.warningTimer then
							label:SetText("")
						else
							local minutes = math.floor(left / 60)
							local seconds = math.floor(left - (minutes * 60))
							if seconds < 10 and seconds > 0 then
								seconds = string.format("0%d", seconds)
								left = string.format("%d:%s", minutes, seconds)
							elseif seconds == 0 then
								seconds = "00"
								left = string.format("%d:%s", minutes, seconds)
							else
								left = string.format("%d:%d", minutes, seconds)
							end
							label:SetText(string.format(RdKGToolBft.constants.BUFF_FOOD_STRING, left))
							--d(left)
							RdKGToolBft.PlaySound()
						end
					else
						label:SetText(string.format(RdKGToolBft.constants.BUFF_FOOD_STRING, "--:--"))
						RdKGToolBft.PlaySound()
					end
					break
				end
			end
		end
	end
end

--menu interactions
function RdKGToolBft.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.BFT_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.BFT_ENABLED,
					getFunc = RdKGToolBft.GetBftEnabled,
					setFunc = RdKGToolBft.SetBftEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.BFT_POSITION_FIXED,
					getFunc = RdKGToolBft.GetBftPositionLocked,
					setFunc = RdKGToolBft.SetBftPositionLocked
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.BFT_PVP_ONLY,
					getFunc = RdKGToolBft.GetBftPvpOnly,
					setFunc = RdKGToolBft.SetBftPvpOnly
				},
				[4] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.BFT_COLOR,
					getFunc = RdKGToolBft.GetBftColor,
					setFunc = RdKGToolBft.SetBftColor,
					width = "full"
				},
				[5] = {
					type = "slider",
					name = RdKGToolMenu.constants.BFT_SIZE,
					min = 20,
					max = 60,
					step = 1,
					getFunc = RdKGToolBft.GetBftSize,
					setFunc = RdKGToolBft.SetBftSize,
					width = "full",
					default = 60
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.BFT_SOUND_ENABLED,
					getFunc = RdKGToolBft.GetBftSoundEnabled,
					setFunc = RdKGToolBft.SetBftSoundEnabled
				},
				[7] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.BFT_SELECTED_SOUND,
					choices = RdKGToolBft.GetBftAvailableSounds(),
					getFunc = RdKGToolBft.GetBftSelectedSound,
					setFunc = RdKGToolBft.SetBftSelectedSound,
					width = "full"
				},
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.BFT_WARNING_TIMER,
					min = 1,
					max = 1800,
					step = 1,
					getFunc = RdKGToolBft.GetBftWarningTimer,
					setFunc = RdKGToolBft.SetBftWarningTimer,
					width = "full",
					default = 600
				},
			}
		},
	}
	return menu
end

function RdKGToolBft.GetBftEnabled()
	return RdKGToolBft.bftVars.enabled
end

function RdKGToolBft.SetBftEnabled(value)
	RdKGToolBft.SetEnabled(value)
end

function RdKGToolBft.GetBftPositionLocked()
	return RdKGToolBft.bftVars.positionLocked
end

function RdKGToolBft.SetBftPositionLocked(value)
	RdKGToolBft.SetPositionLocked(value)
end

function RdKGToolBft.GetBftPvpOnly()
	return RdKGToolBft.bftVars.pvpOnly
end

function RdKGToolBft.SetBftPvpOnly(value)
	RdKGToolBft.bftVars.pvpOnly = value
	RdKGToolBft.SetControlVisibility()
end

function RdKGToolBft.GetBftColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolBft.bftVars.color)
end

function RdKGToolBft.SetBftColor(r, g, b)
	RdKGToolBft.bftVars.color = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolBft.controls.alertTLW.rootControl.alertLabel:SetColor(r, g, b, 1)
end

function RdKGToolBft.GetBftSize()
	return RdKGToolBft.bftVars.size
end

function RdKGToolBft.SetBftSize(value)
	RdKGToolBft.bftVars.size = value
	RdKGToolBft.AdjustSize()
end

function RdKGToolBft.GetBftSoundEnabled()
	return RdKGToolBft.bftVars.soundEnabled
end

function RdKGToolBft.SetBftSoundEnabled(value)
	RdKGToolBft.bftVars.soundEnabled = value
end

function RdKGToolBft.GetBftAvailableSounds()
	local sounds = {}
	for i = 1, #RdKGToolBft.state.sounds do
		sounds[i] = RdKGToolBft.state.sounds[i].name
	end
	return sounds
end

function RdKGToolBft.GetBftSelectedSound()
	return RdKGToolBft.bftVars.selectedSound
end

function RdKGToolBft.SetBftSelectedSound(value)
	if value ~= nil then
		RdKGToolBft.bftVars.selectedSound = value
		RdKGToolSound.PlaySoundByName(value)
	end
end

function RdKGToolBft.GetBftWarningTimer()
	return RdKGToolBft.bftVars.warningTimer
end

function RdKGToolBft.SetBftWarningTimer(value)
	RdKGToolBft.bftVars.warningTimer = value
end