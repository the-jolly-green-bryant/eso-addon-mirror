-- RdK Group Tool 3D Moving Objects
-- By @s0rdrak (PC / EU)

--local lib3D = LibStub("Lib3D2")
local lib3D = Lib3D
local libGPS = LibGPS2

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem
RdKGToolUtil.moving3DObjects = RdKGToolUtil.moving3DObjects  or {}
local RdKGToolM3DO = RdKGToolUtil.moving3DObjects


RdKGToolM3DO.callbackName = RdKGTool.addonName .. "UtilM3DO"
RdKGToolM3DO.drawLayerCallbackName = RdKGTool.addonName .. "UtilM3DODrawLayerUpdate"

RdKGToolM3DO.constants = RdKGToolM3DO.constants or {}
RdKGToolM3DO.constants.updateIntervals = {}
RdKGToolM3DO.constants.updateIntervals.AWAY = 1
RdKGToolM3DO.constants.updateIntervals.CLOSE = 2
RdKGToolM3DO.constants.updateIntervals.CRITICAL = 3
RdKGToolM3DO.constants.MEASUREMENT_CONTROL = RdKGToolM3DO.callbackName .. "MeasurementControl"
RdKGToolM3DO.constants.CAMERA_CONTROL = RdKGToolM3DO.callbackName .. "CameraControl"
RdKGToolM3DO.constants.PREFIX = "M3DO"

RdKGToolM3DO.config = {}
RdKGToolM3DO.config.updateIntervals = {}
RdKGToolM3DO.config.updateIntervals[RdKGToolM3DO.constants.updateIntervals.AWAY] = 1500
RdKGToolM3DO.config.updateIntervals[RdKGToolM3DO.constants.updateIntervals.CLOSE] = 100
RdKGToolM3DO.config.updateIntervals[RdKGToolM3DO.constants.updateIntervals.CRITICAL] = 0
RdKGToolM3DO.config.drawLayerUpdateInterval = 10
RdKGToolM3DO.config.lowestDrawLayer = 3

RdKGToolM3DO.state = {}
RdKGToolM3DO.state.initialized = false
RdKGToolM3DO.state.registeredControls = {}
RdKGToolM3DO.state.updateRegistered = false
RdKGToolM3DO.state.measurementControl = nil
RdKGToolM3DO.state.cameraControl = nil
RdKGToolM3DO.state.currentUpdateInterval = nil
RdKGToolM3DO.state.registeredTextureControls = {}

local wm = GetWindowManager()
local measurementControl = nil
local cameraControl = nil

function RdKGToolM3DO.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolM3DO.callbackName, RdKGToolM3DO.OnProfileChanged)
	EVENT_MANAGER:RegisterForEvent(RdKGToolM3DO.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolM3DO.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(RdKGToolM3DO.callbackName, EVENT_PLAYER_DEACTIVATED, RdKGToolM3DO.OnPlayerDeactivated)
	RdKGToolM3DO.state.measurementControl = wm:CreateTopLevelWindow(RdKGToolM3DO.constants.MEASUREMENT_CONTROL)
	RdKGToolM3DO.state.measurementControl:Create3DRenderSpace()
	measurementControl = RdKGToolM3DO.state.measurementControl
	measurementControl:SetDrawTier(0)
	measurementControl:SetDrawLayer(0)
	measurementControl:SetDrawLevel(0)
	RdKGToolM3DO.state.cameraControl = wm:CreateTopLevelWindow(RdKGToolM3DO.constants.CAMERA_CONTROL)
	RdKGToolM3DO.state.cameraControl:Create3DRenderSpace()
	cameraControl = RdKGToolM3DO.state.cameraControl
	RdKGToolM3DO.state.initialized = true
	lib3D:RegisterWorldChangeCallback(RdKGToolM3DO.callbackName, RdKGToolM3DO.OnWorldMove)
end

function RdKGToolM3DO.GetDefaults()
	local defaults = {}

	return defaults
end

function RdKGToolM3DO.ContainsControl(control, container)
	local containsControl = false
	local index = 0
	for i = 1, #container do
		if container[i] == control then
			containsControl = true
			index = i
			break
		end
	end
	return containsControl, index
end

function RdKGToolM3DO.RegisterControl(control)
	if control ~= nil then
		if RdKGToolM3DO.ContainsControl(control, RdKGToolM3DO.state.registeredControls) == false then
			table.insert(RdKGToolM3DO.state.registeredControls, control)
		end
		if RdKGToolM3DO.state.updateRegistered == false then
			RdKGToolM3DO.state.currentUpdateInterval = RdKGToolM3DO.GetUpdateIntervalFromDistance()
			EVENT_MANAGER:RegisterForUpdate(RdKGToolM3DO.callbackName, RdKGToolM3DO.config.updateIntervals[RdKGToolM3DO.state.currentUpdateInterval], RdKGToolM3DO.OnUpdate)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolM3DO.drawLayerCallbackName, RdKGToolM3DO.config.drawLayerUpdateInterval, RdKGToolM3DO.DrawLayerUpdateLoop)
			RdKGToolM3DO.state.updateRegistered = true
		end
	end
end

function RdKGToolM3DO.UnregisterControl(control)
	if control ~= nil then
		local containsItem, index = RdKGToolM3DO.ContainsControl(control, RdKGToolM3DO.state.registeredControls)
		if containsItem == true then
			table.remove(RdKGToolM3DO.state.registeredControls, index)
			if #RdKGToolM3DO.state.registeredControls == 0 and #RdKGToolM3DO.state.registeredTextureControls == 0 and RdKGToolM3DO.state.updateRegistered == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolM3DO.callbackName)
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolM3DO.drawLayerCallbackName)
				RdKGToolM3DO.state.updateRegistered = false
			end
		end
	end
end

function RdKGToolM3DO.RegisterTextureControl(control)
	--d("register texture control")
	if control ~= nil and control.GetType ~= nil and type(control.GetType) == "function" and control:GetType() == CT_TEXTURE then
		local found, _ = RdKGToolM3DO.ContainsControl(control, RdKGToolM3DO.state.registeredTextureControls)
		if found == false then
			table.insert(RdKGToolM3DO.state.registeredTextureControls, control)
			control:SetParent(measurementControl)
			control.origDrawLevel = control:GetDrawLevel()
			if RdKGToolM3DO.state.updateRegistered == false then
				RdKGToolM3DO.state.currentUpdateInterval = RdKGToolM3DO.GetUpdateIntervalFromDistance()
				EVENT_MANAGER:RegisterForUpdate(RdKGToolM3DO.callbackName, RdKGToolM3DO.config.updateIntervals[RdKGToolM3DO.state.currentUpdateInterval], RdKGToolM3DO.OnUpdate)
				EVENT_MANAGER:RegisterForUpdate(RdKGToolM3DO.drawLayerCallbackName, RdKGToolM3DO.config.drawLayerUpdateInterval, RdKGToolM3DO.DrawLayerUpdateLoop)
				RdKGToolM3DO.state.updateRegistered = true
			end
		end
	end
end

function RdKGToolM3DO.UnregisterTextureControl(control)
	--d("unregister texture control")
	if control ~= nil and control.GetType ~= nil and type(control.GetType) == "function" and control:GetType() == CT_TEXTURE then
		local found, index = RdKGToolM3DO.ContainsControl(control, RdKGToolM3DO.state.registeredTextureControls)
		if found == true then
			RdKGToolM3DO.state.registeredTextureControls[index]:SetDrawLevel(RdKGToolM3DO.state.registeredTextureControls[index].origDrawLevel)
			table.remove(RdKGToolM3DO.state.registeredTextureControls, index)
			if #RdKGToolM3DO.state.registeredControls == 0 and #RdKGToolM3DO.state.registeredTextureControls == 0 and RdKGToolM3DO.state.updateRegistered == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolM3DO.callbackName)
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolM3DO.drawLayerCallbackName)
				RdKGToolM3DO.state.updateRegistered = false
			end
		end
	end
end

function RdKGToolM3DO.GetUpdateIntervalFromDistance()
	local x, y = GetMapPlayerPosition("player")
	x, y = libGPS:LocalToGlobal(x, y)
	local updateInterval = RdKGToolM3DO.constants.updateIntervals.AWAY
	if x ~= nil and x ~= 0 and lib3D:IsValidZone() then
		local originX, originY = lib3D:GetCurrentWorldOriginAsGlobal()
		local factor, _ = lib3D:GetGlobalToWorldFactor(GetZoneId(GetUnitZoneIndex("player")))
		if factor ~= nil then
			x = (originX - x) * factor
			y = (originX - y) * factor
			local distance = x * x + y * y
			if distance >= 902500 then --[[950*950]]
				updateInterval = RdKGToolM3DO.constants.updateIntervals.CRITICAL
			elseif distance >= 902500 then
				updateInterval = RdKGToolM3DO.constants.updateIntervals.CLOSE
			end
		else
			RdKGToolChat.SendChatMessage("GetUpdateIntervalFromDistance: Factor = nil", RdKGToolM3DO.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
		end
	end
	return updateInterval
end

function RdKGToolM3DO.OnWorldMove()
	--d("OnWorldMove")
	--[[
	local x, z = lib3D:GlobalToWorld(lib3D:GetCurrentWorldOriginAsGlobal())
	measurementControl:Set3DRenderSpaceOrigin(x, 0, z)
	]]
	RdKGToolM3DO.UpdateAll()
end

function RdKGToolM3DO.UpdateAll()
	local x, y = lib3D:GlobalToWorld(lib3D:GetCurrentWorldOriginAsGlobal())
	for i = 1, #RdKGToolM3DO.state.registeredControls do
		RdKGToolM3DO.state.registeredControls[i]:Set3DRenderSpaceOrigin(x, 0, y)
	end
	measurementControl:Set3DRenderSpaceOrigin(x, 0, y)
end

function RdKGToolM3DO.GetDefaultTopLevelWindow()
	return measurementControl
end

function RdKGToolM3DO.CalculateDistances()
	Set3DRenderSpaceToCurrentCamera(RdKGToolM3DO.constants.CAMERA_CONTROL)
	local x, height, y = cameraControl:Get3DRenderSpaceOrigin()
	for i = 1, #RdKGToolM3DO.state.registeredTextureControls do
		local coordinates = RdKGToolM3DO.state.registeredTextureControls[i].coordinates
		if coordinates ~= nil and coordinates.x ~= nil and coordinates.y ~= nil then
			local distanceX = x - coordinates.x
			local distanceY = y - coordinates.y
			RdKGToolM3DO.state.registeredTextureControls[i].distance = math.sqrt((distanceX * distanceX) + (distanceY * distanceY))
		else
			RdKGToolM3DO.state.registeredTextureControls[i].distance = 10000
		end
	end
end

function RdKGToolM3DO.SortTextureDistance(a, b)
	if a.distance < b.distance then
		return true
	else
		return false
	end
end

--callbacks
function RdKGToolM3DO.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolM3DO.m3doVars = currentProfile.util.moving3DObjects
	end
end

function RdKGToolM3DO.OnUpdate()
	local x, _, y = measurementControl:Get3DRenderSpaceOrigin()
	if x ~= 0 and y ~= 0 then
		x, y = lib3D:GlobalToWorld(lib3D:GetCurrentWorldOriginAsGlobal())
		--d(x) d(y)
		for i = 1, #RdKGToolM3DO.state.registeredControls do
			--d(RdKGToolM3DO.state.registeredControls[i]:Get3DRenderSpaceOrigin())
			RdKGToolM3DO.state.registeredControls[i]:Set3DRenderSpaceOrigin(x, 0, y)
		end
		measurementControl:Set3DRenderSpaceOrigin(x, 0, y)
		--d(RdKGToolM3DO.state.registeredControls[1]:Get3DRenderSpaceOrigin())
	end
	local updateInterval = RdKGToolM3DO.GetUpdateIntervalFromDistance()
	if updateInterval ~= RdKGToolM3DO.state.currentUpdateInterval then
		RdKGToolM3DO.state.currentUpdateInterval = updateInterval
		EVENT_MANAGER:UnregisterForUpdate(RdKGToolM3DO.callbackName)
		EVENT_MANAGER:RegisterForUpdate(RdKGToolM3DO.callbackName, RdKGToolM3DO.config.updateIntervals[updateInterval], RdKGToolM3DO.OnUpdate)
	end
end


function RdKGToolM3DO.DrawLayerUpdateLoop()
	RdKGToolM3DO.CalculateDistances()
	table.sort(RdKGToolM3DO.state.registeredTextureControls, RdKGToolM3DO.SortTextureDistance)
	local controls = #RdKGToolM3DO.state.registeredTextureControls
	for i = 1, #RdKGToolM3DO.state.registeredTextureControls do
		RdKGToolM3DO.state.registeredTextureControls[i]:SetDrawLevel(RdKGToolM3DO.config.lowestDrawLayer + controls - i)
	end
end

function RdKGToolM3DO.OnPlayerActivated()
	if #RdKGToolM3DO.state.registeredControls >= 1 or #RdKGToolM3DO.state.registeredTextureControls >= 1 then
		EVENT_MANAGER:RegisterForUpdate(RdKGToolM3DO.callbackName, RdKGToolM3DO.config.updateIntervals[RdKGToolM3DO.constants.updateIntervals.AWAY], RdKGToolM3DO.OnUpdate)
		RdKGToolM3DO.state.currentUpdateInterval = RdKGToolM3DO.constants.updateIntervals.AWAY
		RdKGToolM3DO.state.updateRegistered = true
		--RdKGToolM3DO.UpdateAll()
	end
end

function RdKGToolM3DO.OnPlayerDeactivated()
	if RdKGToolM3DO.state.updateRegistered == true then
		EVENT_MANAGER:UnregisterForUpdate(RdKGToolM3DO.callbackName)
		RdKGToolM3DO.state.updateRegistered = false
	end
end