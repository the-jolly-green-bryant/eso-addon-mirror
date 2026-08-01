-- RdK Group Tool Enhancements
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.enhancements = RdKGToolTB.enhancements or {}
local RdKGToolEnhance = RdKGToolTB.enhancements
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolEnhance.callbackName = RdKGTool.addonName .. "Enhancements"
RdKGToolEnhance.questTrackerCallbackName = RdKGTool.addonName .. "EnhancementsQuestTracker"
RdKGToolEnhance.compassCallbackName = RdKGTool.addonName .. "EnhancementsCompass"
RdKGToolEnhance.alertsCallbackName = RdKGTool.addonName .. "EnhancementsAlerts"
RdKGToolEnhance.respawnTimerCallbackName = RdKGTool.addonName .. "EnhancementsRespawnTimer"
RdKGToolEnhance.respawnTimerUpdateLoopName = RdKGTool.addonName .. "EnhancementsRespawnTimerLoop"

RdKGToolEnhance.constants = {}
RdKGToolEnhance.constants.TOPRIGHT = 1
RdKGToolEnhance.constants.BOTTOMRIGHT = 2
RdKGToolEnhance.constants.TOPLEFT = 3
RdKGToolEnhance.constants.BOTTOMLEFT = 4
RdKGToolEnhance.constants.positionNames = {}
RdKGToolEnhance.constants.PREFIX = "Enhancements"

RdKGToolEnhance.state = {}
RdKGToolEnhance.state.initialized = false
RdKGToolEnhance.state.initCodeRun = false
RdKGToolEnhance.state.questTracker = {}
RdKGToolEnhance.state.compass = {}
RdKGToolEnhance.state.compass.registeredConsumers = false
RdKGToolEnhance.state.alerts = {}
RdKGToolEnhance.state.alerts.allignment = TEXT_ALIGN_RIGHT
RdKGToolEnhance.state.respawnTimer = {}
RdKGToolEnhance.state.respawnTimer.hookedTimer = false
RdKGToolEnhance.state.respawnTimerText = ""
RdKGToolEnhance.state.refreshRate = 100
RdKGToolEnhance.state.origFunc = nil
RdKGToolEnhance.state.failedAlertHooks = 0 

function RdKGToolEnhance.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolEnhance.callbackName, RdKGToolEnhance.OnProfileChanged)
		
	--RdKGToolEnhance.OnInitialize()
	EVENT_MANAGER:RegisterForEvent(RdKGToolEnhance.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolEnhance.OnInitialize)
	EVENT_MANAGER:RegisterForEvent(RdKGToolEnhance.questTrackerCallbackName, EVENT_PLAYER_ACTIVATED, RdKGToolEnhance.OnQuestTrackerPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(RdKGToolEnhance.compassCallbackName, EVENT_PLAYER_ACTIVATED, RdKGToolEnhance.OnCompassPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(RdKGToolEnhance.respawnTimerCallbackName, EVENT_PLAYER_ACTIVATED, RdKGToolEnhance.OnRespawnTimerPlayerActivated)
	
	RdKGToolEnhance.state.initialized = true
	RdKGToolEnhance.InitializeEnhancements()
end

function RdKGToolEnhance.InitializeEnhancements()
	RdKGToolEnhance.OnQuestTrackerPlayerActivated()
	RdKGToolEnhance.OnRespawnTimerPlayerActivated()
end


function RdKGToolEnhance.GetDefaults()
	local defaults = {}
	defaults.questTracker = {}
	defaults.questTracker.disabled = true
	defaults.questTracker.pvpOnly = true
	defaults.compass = {}
	defaults.compass.tweaksEnabled = false
	defaults.compass.pvpOnly = true
	defaults.compass.hidden = false
	defaults.compass.width = 672
	defaults.alerts = {}
	defaults.alerts.tweaksEnabled = false
	defaults.alerts.pvpOnly = true
	defaults.alerts.hidden = false
	defaults.alerts.position = RdKGToolEnhance.constants.TOPRIGHT
	defaults.alerts.color = {}
	defaults.alerts.color.r = 1
	defaults.alerts.color.g = 1
	defaults.alerts.color.b = 1
	defaults.respawnTimer = {}
	defaults.respawnTimer.enabled = true
	return defaults
end

function RdKGToolEnhance.HookAlerts()
	if ALERT_MESSAGES ~= nil and ALERT_MESSAGES.alerts ~= nil then
		RdKGToolUtil.ParameterPreHook(RdKGToolEnhance.alertsCallbackName, ALERT_MESSAGES.alerts, "SetupItem", RdKGToolEnhance.HookedZOSetupItemFunction)
	else
		RdKGToolEnhance.state.failedAlertHooks = RdKGToolEnhance.state.failedAlertHooks + 1
		if RdKGToolEnhance.state.failedAlertHooks <= 5 then
			zo_callLater(RdKGToolEnhance.HookAlerts, 1000)
		end
	end
end

function RdKGToolEnhance.AdjustAlerts()
	local anchor = TOPRIGHT
	local pushDirection = FCB_PUSH_DIRECTION_DOWN
	local hidden = false
	local color = {r = 1, g = 1, b = 1, a = 1}
	if RdKGToolEnhance.eVars.alerts.tweaksEnabled == true and (RdKGToolEnhance.eVars.alerts.pvpOnly == false or (RdKGToolEnhance.eVars.alerts.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolEnhance.eVars.alerts.position == RdKGToolEnhance.constants.TOPRIGHT then
			RdKGToolEnhance.state.alerts.allignment = TEXT_ALIGN_RIGHT
			anchor = TOPRIGHT
			pushDirection = FCB_PUSH_DIRECTION_DOWN
		elseif RdKGToolEnhance.eVars.alerts.position == RdKGToolEnhance.constants.BOTTOMRIGHT then
			RdKGToolEnhance.state.alerts.allignment = TEXT_ALIGN_RIGHT
			anchor = BOTTOMRIGHT
			pushDirection = -1
		elseif RdKGToolEnhance.eVars.alerts.position == RdKGToolEnhance.constants.TOPLEFT then
			RdKGToolEnhance.state.alerts.allignment = TEXT_ALIGN_LEFT
			anchor = TOPLEFT
			pushDirection = FCB_PUSH_DIRECTION_DOWN
		elseif RdKGToolEnhance.eVars.alerts.position == RdKGToolEnhance.constants.BOTTOMLEFT then
			RdKGToolEnhance.state.alerts.allignment = TEXT_ALIGN_LEFT
			anchor = BOTTOMLEFT
			pushDirection = -1
		end
		if RdKGToolEnhance.eVars.alerts.hidden == true then
			hidden = true
		end
		RdKGToolEnhance.state.alerts.color = RdKGToolEnhance.eVars.alerts.color
	else
		RdKGToolEnhance.state.alerts.allignment = TEXT_ALIGN_RIGHT
		RdKGToolEnhance.state.alerts.color = color
	end
	
	
	ZO_AlertTextNotification:SetHidden(hidden)
	if ALERT_MESSAGES ~= nil and ALERT_MESSAGES.alerts ~= nil then
		local fadingControlBuffer = ALERT_MESSAGES.alerts
		if fadingControlBuffer.anchor ~= nil and fadingControlBuffer.anchor.data ~= nil then
			fadingControlBuffer.anchor.data[1] = anchor
		end
		if fadingControlBuffer.SetPushDirection ~= nil and type(fadingControlBuffer.SetPushDirection) == "function" then
			fadingControlBuffer:SetPushDirection(pushDirection)
		end
	end
	
	
	--ALERT_MESSAGES.alerts.anchor.data[1]= BOTTOMRIGHT
	--ZO_AlertTextNotification:GetChild().fadingControlBuffer.anchor.data[1] = anchor
	
	--ALERT_MESSAGES.alerts:SetPushDirection(-1)
	--ZO_AlertTextNotification:GetChild().fadingControlBuffer:SetPushDirection(pushDirection)

end

function RdKGToolEnhance.HookedZOSetupItemFunction(control, hasHeader, item, templateName, setupFn, pools, parent, offsetY, isHeader)
	RdKGToolChat.SendChatMessage("ALERT_MESSAGES:SetupItem:Outer Hook", RdKGToolEnhance.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
	local hookedFn = function(ctrl, data)
		item.color.r = RdKGToolEnhance.state.alerts.color.r
		item.color.g = RdKGToolEnhance.state.alerts.color.g
		item.color.b = RdKGToolEnhance.state.alerts.color.b
		ctrl:SetHorizontalAlignment(RdKGToolEnhance.state.alerts.allignment)
		RdKGToolChat.SendChatMessage("ALERT_MESSAGES:SetupItem:Inner Hook", RdKGToolEnhance.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
		return setupFn(ctrl, data)
	end
	return control, hasHeader, item, templateName, hookedFn, pools, parent, offsetY, isHeader
end

function RdKGToolEnhance.RespawnTimerHook(--[[currentTime]])
	--d("hooked")
	if IsInCyrodiil() == true and RdKGToolEnhance.eVars.respawnTimer.enabled == true then
		local respawnTime = GetNextForwardCampRespawnTime()
		--currentTime = currentTime * 1000
		local seconds = (respawnTime - GetGameTimeMilliseconds()) / 1000
		if seconds < 0 then
			respawnTime = "-"
		else
			respawnTime = ZO_FormatTimeAsDecimalWhenBelowThreshold(seconds)
		end
		

		if IsInGamepadPreferredMode() then
			local data =
			{
				data1HeaderText = SI_MAP_FORWARD_CAMP_RESPAWN_COOLDOWN,
				data1Text = respawnTime
			}
			GAMEPAD_GENERIC_FOOTER:Refresh(data)
		else
			ZO_WorldMapRespawnTimerValue:SetText(respawnTime)
			
			ZO_WorldMapRespawnTimer:SetHidden(false)
		end
	else
		ZO_WorldMapRespawnTimer:SetHidden(true)
	end
	--[[replace above with ZO_WorldMapRespawnTimer:SetHidden(false) ? -gamepad?]]
end

--callbacks
function RdKGToolEnhance.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolEnhance.eVars = currentProfile.toolbox.enhancements
		RdKGToolEnhance.InitializeEnhancements()
		if RdKGToolEnhance.state.initialized == true then
			RdKGToolEnhance.OnCompassPlayerActivated()
			RdKGToolEnhance.AdjustAlerts()
		end
	end
end

function RdKGToolEnhance.OnQuestTrackerPlayerActivated()
	if RdKGToolEnhance.eVars.questTracker.disabled == true and (RdKGToolEnhance.eVars.questTracker.pvpOnly == false or (RdKGToolEnhance.eVars.questTracker.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if ZO_FocusedQuestTrackerPanel ~= nil then
			ZO_FocusedQuestTrackerPanel:SetHidden(true)
		end
	else
		if ZO_FocusedQuestTrackerPanel ~= nil then
			ZO_FocusedQuestTrackerPanel:SetHidden(false)
		end
	end
	
end

function RdKGToolEnhance.OnCompassPlayerActivated()
	if RdKGToolEnhance.state.initCodeRun == false then
		RdKGToolEnhance.OnInitialize()
	end
	if RdKGToolEnhance.eVars.compass.tweaksEnabled == true and (RdKGToolEnhance.eVars.compass.pvpOnly == false or (RdKGToolEnhance.eVars.compass.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		COMPASS_FRAME.control:SetHidden(RdKGToolEnhance.eVars.compass.hidden)
		COMPASS.control:GetNamedChild("Container"):SetHidden(RdKGToolEnhance.eVars.compass.hidden)
		COMPASS.centerOverPinLabel:SetText("")
		for index, item in pairs({"Left", "Center", "Right"}) do
			local control = COMPASS_FRAME.control:GetNamedChild(item)
			if control then 
				control:SetHidden(RdKGToolEnhance.eVars.compass.hidden) 
			end
		end
		local cWidth, cHeight = COMPASS_FRAME.control:GetDimensions()
		zo_callLater(function()
			COMPASS_FRAME.control:SetDimensions(RdKGToolEnhance.eVars.compass.width, cHeight)
		end, 10)
	else
		COMPASS_FRAME.control:SetHidden(false)
		COMPASS.control:GetNamedChild("Container"):SetHidden(false)
		for index, item in pairs({"Left", "Center", "Right"}) do
			local control = COMPASS_FRAME.control:GetNamedChild(item)
			if control then 
				control:SetHidden(false) 
			end
		end
		zo_callLater(function()
			COMPASS_FRAME.control:SetDimensions(RdKGToolEnhance.state.compass.width, RdKGToolEnhance.state.compass.height)
		end, 10)
	end
end

function RdKGToolEnhance.OnRespawnTimerPlayerActivated()
	--d("respawn activated")
	if IsInCyrodiil() == true and RdKGToolEnhance.eVars.respawnTimer.enabled == true then
		if RdKGToolEnhance.state.respawnTimer.hookedTimer == false then
			--d("hooking")
			RdKGToolEnhance.state.respawnTimerText = ZO_WorldMapRespawnTimerStat:GetText()
			RdKGToolEnhance.state.origFunc = ZO_WorldMap_RefreshRespawnTimer
			ZO_WorldMap_RefreshRespawnTimer = function(currentTime) end
			ZO_WorldMapRespawnTimerStat:SetText(RdKGToolEnhance.constants.CAMP_RESPAWN)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolEnhance.respawnTimerUpdateLoopName, RdKGToolEnhance.state.refreshRate, RdKGToolEnhance.RespawnTimerHook)
			--RdKGToolUtil.PostHook(RdKGToolEnhance.respawnTimerCallbackName, nil, "ZO_WorldMap_RefreshRespawnTimer", RdKGToolEnhance.RespawnTimerHook)
			RdKGToolEnhance.state.respawnTimer.hookedTimer = true
			
		end
	else
		if RdKGToolEnhance.state.respawnTimer.hookedTimer == true then
			--d("removing hook")
			ZO_WorldMapRespawnTimerStat:SetText(RdKGToolEnhance.state.respawnTimerText)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolEnhance.respawnTimerUpdateLoopName)
			ZO_WorldMap_RefreshRespawnTimer = RdKGToolEnhance.state.origFunc
			--RdKGToolUtil.RemovePostHook(RdKGToolEnhance.respawnTimerCallbackName)
			RdKGToolEnhance.state.respawnTimer.hookedTimer = false
			ZO_WorldMapRespawnTimer:SetHidden(true)
		end
	end
end

function RdKGToolEnhance.OnInitialize()
	RdKGToolEnhance.state.compass.width, RdKGToolEnhance.state.compass.height = COMPASS_FRAME.control:GetDimensions()
	RdKGToolEnhance.HookAlerts()
	RdKGToolEnhance.AdjustAlerts()
	EVENT_MANAGER:UnregisterForEvent(RdKGToolEnhance.callbackName, EVENT_PLAYER_ACTIVATED)
	RdKGToolEnhance.state.initCodeRun = true
end

--menu interactions
function RdKGToolEnhance.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.ENHANCE_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_QUEST_TRACKER_ENABLED,
					getFunc = RdKGToolEnhance.GetEnhanceQuestTrackerDisabled,
					setFunc = RdKGToolEnhance.SetEnhanceQuestTrackerDisabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_QUEST_TRACKER_PVP_ONLY,
					getFunc = RdKGToolEnhance.GetEnhanceQuestTrackerPvpOnly,
					setFunc = RdKGToolEnhance.SetEnhanceQuestTrackerPvpOnly
				},
				[3] = {
					type = "divider",
					width = "full"
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_COMPASS_TWEAKS_ENABLED,
					getFunc = RdKGToolEnhance.GetEnhanceCompassTweaksEnabled,
					setFunc = RdKGToolEnhance.SetEnhanceCompassTweaksEnabled
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_COMPASS_PVP_ONLY,
					getFunc = RdKGToolEnhance.GetEnhanceCompassPvpOnly,
					setFunc = RdKGToolEnhance.SetEnhanceCompassPvpOnly
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_COMPASS_HIDDEN,
					getFunc = RdKGToolEnhance.GetEnhanceCompassHidden,
					setFunc = RdKGToolEnhance.SetEnhanceCompassHidden
				},
				[7] = {
					type = "slider",
					name = RdKGToolMenu.constants.ENHANCE_COMPASS_WIDTH,
					min = 10,
					max = 1800,
					step = 1,
					getFunc = RdKGToolEnhance.GetEnhanceCompassWidth,
					setFunc = RdKGToolEnhance.SetEnhanceCompassWidth,
					width = "full",
					default = 672
				},
				[8] = {
					type = "divider",
					width = "full"
				},
				[9] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_ALERTS_TWEAKS_ENABLED,
					getFunc = RdKGToolEnhance.GetEnhanceAlertsTweaksEnabled,
					setFunc = RdKGToolEnhance.SetEnhanceAlertsTweaksEnabled
				},
				[10] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_ALERTS_PVP_ONLY,
					getFunc = RdKGToolEnhance.GetEnhanceAlertsPvpOnly,
					setFunc = RdKGToolEnhance.SetEnhanceAlertsPvpOnly
				},
				[11] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_ALERTS_HIDDEN,
					getFunc = RdKGToolEnhance.GetEnhanceAlertsHidden,
					setFunc = RdKGToolEnhance.SetEnhanceAlertsHidden
				},
				[12] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.ENHANCE_ALERTS_POSITION,
					choices = RdKGToolEnhance.GetEnhanceAlertsPositionValues(),
					choicesValues = RdKGToolEnhance.GetEnhanceAlertsPositionValueChoises(),
					getFunc = RdKGToolEnhance.GetEnhanceAlertsSelectedPosition,
					setFunc = RdKGToolEnhance.SetEnhanceAlertsSelectedPosition
				},
				[13] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.ENHANCE_ALERTS_COLOR,
					getFunc = RdKGToolEnhance.GetEnhanceAlertsColor,
					setFunc = RdKGToolEnhance.SetEnhanceAlertsColor,
					width = "full"
				},
				[14] = {
					type = "divider",
					width = "full"
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ENHANCE_RESPAWN_TIMER_ENABLED,
					getFunc = RdKGToolEnhance.GetEnhanceRespawnTimerEnabled,
					setFunc = RdKGToolEnhance.SetEnhanceRespawnTimerEnabled
				}
			}
		}
	}
	return menu
end

function RdKGToolEnhance.GetEnhanceQuestTrackerDisabled()
	return RdKGToolEnhance.eVars.questTracker.disabled
end

function RdKGToolEnhance.SetEnhanceQuestTrackerDisabled(value)
	RdKGToolEnhance.eVars.questTracker.disabled = value
	RdKGToolEnhance.OnQuestTrackerPlayerActivated()
end

function RdKGToolEnhance.GetEnhanceQuestTrackerPvpOnly()
	return RdKGToolEnhance.eVars.questTracker.pvpOnly
end

function RdKGToolEnhance.SetEnhanceQuestTrackerPvpOnly(value)
	RdKGToolEnhance.eVars.questTracker.pvpOnly = value
	RdKGToolEnhance.OnQuestTrackerPlayerActivated()
end

function RdKGToolEnhance.GetEnhanceCompassTweaksEnabled()
	return RdKGToolEnhance.eVars.compass.tweaksEnabled
end

function RdKGToolEnhance.SetEnhanceCompassTweaksEnabled(value)
	RdKGToolEnhance.eVars.compass.tweaksEnabled = value
	RdKGToolEnhance.OnCompassPlayerActivated()
end

function RdKGToolEnhance.GetEnhanceCompassPvpOnly()
	return RdKGToolEnhance.eVars.compass.pvpOnly
end

function RdKGToolEnhance.SetEnhanceCompassPvpOnly(value)
	RdKGToolEnhance.eVars.compass.pvpOnly = value
	RdKGToolEnhance.OnCompassPlayerActivated()
end

function RdKGToolEnhance.GetEnhanceCompassHidden()
	return RdKGToolEnhance.eVars.compass.hidden
end

function RdKGToolEnhance.SetEnhanceCompassHidden(value)
	RdKGToolEnhance.eVars.compass.hidden = value
	RdKGToolEnhance.OnCompassPlayerActivated()
end

function RdKGToolEnhance.GetEnhanceCompassWidth()
	return RdKGToolEnhance.eVars.compass.width
end

function RdKGToolEnhance.SetEnhanceCompassWidth(value)
	RdKGToolEnhance.eVars.compass.width = value
	RdKGToolEnhance.OnCompassPlayerActivated()
end

function RdKGToolEnhance.GetEnhanceAlertsTweaksEnabled()
	return RdKGToolEnhance.eVars.alerts.tweaksEnabled
end

function RdKGToolEnhance.SetEnhanceAlertsTweaksEnabled(value)
	RdKGToolEnhance.eVars.alerts.tweaksEnabled = value
	RdKGToolEnhance.AdjustAlerts()
end

function RdKGToolEnhance.GetEnhanceAlertsPvpOnly()
	return RdKGToolEnhance.eVars.alerts.pvpOnly
end

function RdKGToolEnhance.SetEnhanceAlertsPvpOnly(value)
	RdKGToolEnhance.eVars.alerts.pvpOnly = value
	RdKGToolEnhance.AdjustAlerts()
end

function RdKGToolEnhance.GetEnhanceAlertsHidden()
	return RdKGToolEnhance.eVars.alerts.hidden
end

function RdKGToolEnhance.SetEnhanceAlertsHidden(value)
	RdKGToolEnhance.eVars.alerts.hidden = value
	RdKGToolEnhance.AdjustAlerts()
end

function RdKGToolEnhance.GetEnhanceAlertsPositionValues()
	local values = {}
	RdKGToolEnhance.constants.positionNames = RdKGToolEnhance.constants.positionNames or {}
	values[1] = RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.TOPRIGHT]
	values[2] = RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.BOTTOMRIGHT]
	values[3] = RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.TOPLEFT]
	values[4] = RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.BOTTOMLEFT]
	return values
end

function RdKGToolEnhance.GetEnhanceAlertsPositionValueChoises()
	local choices = {}
	choices[1] = RdKGToolEnhance.constants.TOPRIGHT
	choices[2] = RdKGToolEnhance.constants.BOTTOMRIGHT
	choices[3] = RdKGToolEnhance.constants.TOPLEFT
	choices[4] = RdKGToolEnhance.constants.BOTTOMLEFT
	return choices
end

function RdKGToolEnhance.GetEnhanceAlertsSelectedPosition()
	return RdKGToolEnhance.eVars.alerts.position
end

function RdKGToolEnhance.SetEnhanceAlertsSelectedPosition(value)
	RdKGToolEnhance.eVars.alerts.position = value
	RdKGToolEnhance.AdjustAlerts()
end

function RdKGToolEnhance.GetEnhanceAlertsColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolEnhance.eVars.alerts.color)
end

function RdKGToolEnhance.SetEnhanceAlertsColor(r, g, b)
	RdKGToolEnhance.eVars.alerts.color = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolEnhance.AdjustAlerts()
end

function RdKGToolEnhance.GetEnhanceRespawnTimerEnabled()
	return RdKGToolEnhance.eVars.respawnTimer.enabled
end

function RdKGToolEnhance.SetEnhanceRespawnTimerEnabled(value)
	RdKGToolEnhance.eVars.respawnTimer.enabled = value
	RdKGToolEnhance.OnRespawnTimerPlayerActivated()
end