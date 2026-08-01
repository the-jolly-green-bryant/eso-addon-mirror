-- RdK Group Tool I See Dead People
-- By @s0rdrak (PC / EU)

--local lib3D = LibStub("Lib3D2")
local lib3D = Lib3D

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGToolGroup.isdp = RdKGToolGroup.isdp or {}
local RdKGToolIsdp = RdKGToolGroup.isdp
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.moving3DObjects = RdKGToolUtil.moving3DObjects  or {}
local RdKGToolM3DO = RdKGToolUtil.moving3DObjects
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGToolUtil.beams = RdKGToolUtil.beams
local RdKGToolBeams = RdKGToolUtil.beams

RdKGToolIsdp.callbackName = RdKGTool.addonName .. "ISeeDeadPeople"

RdKGToolIsdp.constants = {}

RdKGToolIsdp.controls = {}
RdKGToolIsdp.controls.beams = {}

RdKGToolIsdp.config = {}
RdKGToolIsdp.config.updateInterval = 10
RdKGToolIsdp.config.distanceUpdateInterval = 100
RdKGToolIsdp.config.deadStateUpdateInterval = 10
RdKGToolIsdp.config.maxDistance = 200

RdKGToolIsdp.state = {}
RdKGToolIsdp.state.initialized = false
RdKGToolIsdp.state.registredConsumers = false
RdKGToolIsdp.state.registredActivationConsumers = false
RdKGToolIsdp.state.beams = {}

local wm = GetWindowManager()

function RdKGToolIsdp.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolIsdp.callbackName, RdKGToolIsdp.OnProfileChanged)
	RdKGToolIsdp.InitializeTextures()
	RdKGToolIsdp.CreateBeams()
	RdKGToolIsdp.state.initialized = true
	RdKGToolIsdp.SetEnabled(RdKGToolIsdp.isdpVars.enabled)
end

function RdKGToolIsdp.CreateBeams()
	for i = 1, 10 do
		table.insert(RdKGToolIsdp.controls.beams, RdKGToolIsdp.CreateBeam())
	end
end

function RdKGToolIsdp.CreateBeam()
	local beamConfig = RdKGToolIsdp.state.beams[RdKGToolIsdp.isdpVars.texture]
	local beam = wm:CreateControl(nil, RdKGToolM3DO.GetDefaultTopLevelWindow(), CT_TEXTURE)
	beam:Create3DRenderSpace()
	if beamConfig.ignoreSize == true then
		beam:Set3DLocalDimensions(beamConfig.width, beamConfig.height)
	else
		beam:Set3DLocalDimensions(RdKGToolIsdp.isdpVars.size, beamConfig.height)
	end
	beam:SetDrawLevel(3)
	beam:SetTexture(beamConfig.texture)
	beam:Set3DRenderSpaceUsesDepthBuffer(beamConfig.usesDepthBuffer)
	beam:SetHidden(true)
	beam.registeredTexture = false
	return beam
end

function RdKGToolIsdp.InitializeTextures()
	local commonBeams = RdKGToolBeams.GetBeams()
	for i = 1, #commonBeams do
		RdKGToolIsdp.state.beams[i] = {}
		RdKGToolIsdp.state.beams[i].texture = commonBeams[i].texture
		RdKGToolIsdp.state.beams[i].name = commonBeams[i].name
		RdKGToolIsdp.state.beams[i].usesDepthBuffer = commonBeams[i].usesDepthBuffer
		RdKGToolIsdp.state.beams[i].ignoreSize = commonBeams[i].ignoreSize
		RdKGToolIsdp.state.beams[i].height = commonBeams[i].height
		RdKGToolIsdp.state.beams[i].width = commonBeams[i].width
		RdKGToolIsdp.state.beams[i].heightOffset = commonBeams[i].heightOffset
	end
	RdKGToolIsdp.state.beams[#commonBeams - 2].heightOffset = 2
	RdKGToolIsdp.state.beams[#commonBeams - 3].heightOffset = 2
	RdKGToolIsdp.state.beams[#commonBeams - 4].heightOffset = 2
	RdKGToolIsdp.state.beams[#commonBeams - 5].heightOffset = 2
	
	local index = #commonBeams + 1
	RdKGToolIsdp.state.beams[index] = {}
	RdKGToolIsdp.state.beams[index].texture = "EsoUI/Art/icons/poi/poi_groupboss_complete.dds"
	RdKGToolIsdp.state.beams[index].name = RdKGToolIsdp.constants.BEAM_SKULL_USING_BUFFER
	RdKGToolIsdp.state.beams[index].usesDepthBuffer = true
	RdKGToolIsdp.state.beams[index].ignoreSize = true
	RdKGToolIsdp.state.beams[index].height = 1
	RdKGToolIsdp.state.beams[index].width = 1
	RdKGToolIsdp.state.beams[index].heightOffset = 2
	index = index + 1
	RdKGToolIsdp.state.beams[index] = {}
	RdKGToolIsdp.state.beams[index].texture = "EsoUI/Art/icons/poi/poi_groupboss_complete.dds"
	RdKGToolIsdp.state.beams[index].name = RdKGToolIsdp.constants.BEAM_SKULL_NOT_USING_BUFFER
	RdKGToolIsdp.state.beams[index].usesDepthBuffer = false
	RdKGToolIsdp.state.beams[index].ignoreSize = true
	RdKGToolIsdp.state.beams[index].height = 1
	RdKGToolIsdp.state.beams[index].width = 1
	RdKGToolIsdp.state.beams[index].heightOffset = 2
end

function RdKGToolIsdp.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.pvpOnly = true
	defaults.size = 0.125
	defaults.texture = RdKGToolBeams.constants.beams.BEAM_1
	defaults.colors = {}
	defaults.colors.dead = {}
	defaults.colors.dead.r = 1
	defaults.colors.dead.g = 0
	defaults.colors.dead.b = 0
	defaults.colors.dead.a = 0.75
	defaults.colors.beingRessurected = {}
	defaults.colors.beingRessurected.r = 0.86274509803921568627450980392157
	defaults.colors.beingRessurected.g = 0.65882352941176470588235294117647
	defaults.colors.beingRessurected.b = 0.18039215686274509803921568627451
	defaults.colors.beingRessurected.a = 0.75
	defaults.colors.ressurected = {}
	defaults.colors.ressurected.r = 0.16862745098039215686274509803922
	defaults.colors.ressurected.g = 0.91372549019607843137254901960784
	defaults.colors.ressurected.b = 0.12941176470588235294117647058824
	defaults.colors.ressurected.a = 0.75
	return defaults
end

function RdKGToolIsdp.SetEnabled(value)
	if RdKGToolIsdp.state.initialized == true and value ~= nil then
		RdKGToolIsdp.isdpVars.enabled = value
		if value == true then
			if RdKGToolIsdp.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolIsdp.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolIsdp.OnPlayerActivated)
			end
			RdKGToolIsdp.state.registredConsumers = true
		else
			if RdKGToolIsdp.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolIsdp.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolIsdp.state.registredConsumers = false
		end
		RdKGToolIsdp.OnPlayerActivated()
	end
end

function RdKGToolIsdp.AdjustSize()
	local beamConfig = RdKGToolIsdp.state.beams[RdKGToolIsdp.isdpVars.texture]
	for i = 1, #RdKGToolIsdp.controls.beams do
		if beamConfig.ignoreSize == true then
			RdKGToolIsdp.controls.beams[i]:Set3DLocalDimensions(beamConfig.width, beamConfig.height)
		else
			RdKGToolIsdp.controls.beams[i]:Set3DLocalDimensions(RdKGToolIsdp.isdpVars.size, beamConfig.height)
		end
	end
end

function RdKGToolIsdp.AdjustTextures()
	local beamConfig = RdKGToolIsdp.state.beams[RdKGToolIsdp.isdpVars.texture]
	for i = 1, #RdKGToolIsdp.controls.beams do
		RdKGToolIsdp.controls.beams[i]:SetTexture(beamConfig.texture)
		RdKGToolIsdp.controls.beams[i]:Set3DRenderSpaceUsesDepthBuffer(beamConfig.usesDepthBuffer)
	end
end

function RdKGToolIsdp.GetBeamColor(isDead, isResurrected, isBeingResurrected)
	local color = nil
	if isBeingResurrected == true and isDead == true then
		color = RdKGToolIsdp.isdpVars.colors.beingRessurected
	elseif isResurrected == true and isDead == true then
		color = RdKGToolIsdp.isdpVars.colors.ressurected
	elseif isDead == true then
		color = RdKGToolIsdp.isdpVars.colors.dead
	end
	return color
end

--callbacks
function RdKGToolIsdp.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolIsdp.isdpVars = currentProfile.group.isdp
		if RdKGToolIsdp.state.initialized == true then
			RdKGToolIsdp.AdjustTextures()
			RdKGToolIsdp.AdjustSize()
		end
		RdKGToolIsdp.SetEnabled(RdKGToolIsdp.isdpVars.enabled)
	end
end

function RdKGToolIsdp.OnPlayerActivated(eventCode, initial)
	if RdKGToolIsdp.isdpVars.enabled == true and (RdKGToolIsdp.isdpVars.pvpOnly == false or (RdKGToolIsdp.isdpVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolIsdp.state.registredActivationConsumers == false then
			EVENT_MANAGER:RegisterForUpdate(RdKGToolIsdp.callbackName, RdKGToolIsdp.config.updateInterval, RdKGToolIsdp.UiLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolIsdp.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES, RdKGToolIsdp.config.updateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolIsdp.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE, RdKGToolIsdp.config.distanceUpdateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolIsdp.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_DEAD_STATE, RdKGToolIsdp.config.deadStateUpdateInterval)
			RdKGToolIsdp.state.registredActivationConsumers = true
		end
	else
		if RdKGToolIsdp.state.registredActivationConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolIsdp.callbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolIsdp.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolIsdp.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolIsdp.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_DEAD_STATE)
			RdKGToolIsdp.state.registredActivationConsumers = false
		end
		--Hide if neccessary
		for i = 1, #RdKGToolIsdp.controls.beams do
			if RdKGToolIsdp.controls.beams[i].registeredTexture == true then
				RdKGToolM3DO.UnregisterTextureControl(RdKGToolIsdp.controls.beams[i])
				RdKGToolIsdp.controls.beams[i].registeredTexture = false
			end
			RdKGToolIsdp.controls.beams[i]:SetHidden(true)
		end
	end
end

function RdKGToolIsdp.UiLoop()
	if RdKGToolIsdp.isdpVars.enabled == true and (RdKGToolIsdp.isdpVars.pvpOnly == false or (RdKGToolIsdp.isdpVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		local beamIndex = 1
		local players = RdKGToolUtilGroup.GetGroupInformation()
		if players ~= nil then
			if #players > #RdKGToolIsdp.controls.beams then
				local amount = #players - #RdKGToolIsdp.controls.beams
				for i = 1, amount do
					local beam = RdKGToolIsdp.CreateBeam()
					table.insert(RdKGToolIsdp.controls.beams, beam)
					--RdKGToolM3DO.RegisterTextureControl(beam)
				end
			end
			--local _, height, _ = lib3D:GetCameraRenderSpacePosition()
			local heading = GetPlayerCameraHeading()
			if heading > math.pi then 
				heading = heading - 2 * math.pi
			end
			local beamConfig = RdKGToolIsdp.state.beams[RdKGToolIsdp.isdpVars.texture]
			for i = 1, #players do
				local player = players[i]
				if player.isOnline == true and player.isPlayer == false and player.isLeader == false and player.distances ~= nil and player.distances.fromPlayer ~= nil and RdKGToolIsdp.config.maxDistance >= player.distances.fromPlayer then
					local color = RdKGToolIsdp.GetBeamColor(player.isDead, player.isResurrected, player.isBeingResurrected)
					if color ~= nil then
						local coordinates = player.coordinates
						local beam = RdKGToolIsdp.controls.beams[beamIndex]
						beam:SetColor(color.r, color.g, color.b)
						--beam:Set3DRenderSpaceOrigin(coordinates.x, coordinates.height + beamConfig.heightOffset, coordinates.y)
						beam:Set3DRenderSpaceOrigin(coordinates.worldX, coordinates.worldHeight + beamConfig.heightOffset, coordinates.worldY)
						beam:Set3DRenderSpaceOrientation(0, heading, 0)
						beam:SetHidden(false)
						if beam.registeredTexture == false then
							RdKGToolM3DO.RegisterTextureControl(beam)
							beam.registeredTexture = true
						end
						beam.coordinates = coordinates --layer test
						beamIndex = beamIndex + 1
					end
				end
			end	
		end
		for i = beamIndex, #RdKGToolIsdp.controls.beams do
			RdKGToolIsdp.controls.beams[i]:SetHidden(true)
			if RdKGToolIsdp.controls.beams[i].registeredTexture == true then
				RdKGToolM3DO.UnregisterTextureControl(RdKGToolIsdp.controls.beams[i])
				RdKGToolIsdp.controls.beams[i].registeredTexture = false
			end
		end
	else
		for i = 1, #RdKGToolIsdp.controls.beams do
			RdKGToolIsdp.controls.beams[i]:SetHidden(true)
			if RdKGToolIsdp.controls.beams[i].registeredTexture == true then
				RdKGToolM3DO.UnregisterTextureControl(RdKGToolIsdp.controls.beams[i])
				RdKGToolIsdp.controls.beams[i].registeredTexture = false
			end
		end
	end
end

--menu interaction
function RdKGToolIsdp.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.ISDP_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ISDP_ENABLED,
					getFunc = RdKGToolIsdp.GetIsdpEnabled,
					setFunc = RdKGToolIsdp.SetIsdpEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ISDP_PVP_ONLY,
					getFunc = RdKGToolIsdp.GetIsdpPvpOnly,
					setFunc = RdKGToolIsdp.SetIsdpPvpOnly
				},
				[3] = {
					type = "slider",
					name = RdKGToolMenu.constants.ISDP_SIZE,
					min = 1,
					max = 16,
					step = 1,
					getFunc = RdKGToolIsdp.GetIsdpSize,
					setFunc = RdKGToolIsdp.SetIsdpSize,
					width = "full",
					default = 2
				},
				[4] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.ISDP_SELECTED_BEAM,
					choices = RdKGToolIsdp.GetIsdpBeams(),
					getFunc = RdKGToolIsdp.GetIsdpSelectedBeam,
					setFunc = RdKGToolIsdp.SetIsdpSelectedBeam
				},
				[5] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.ISDP_COLOR_DEAD,
					getFunc = RdKGToolIsdp.GetIsdpColorDead,
					setFunc = RdKGToolIsdp.SetIsdpColorDead,
					width = "full"
				},
				[6] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.ISDP_COLOR_BEING_RESURRECTED,
					getFunc = RdKGToolIsdp.GetIsdpColorBeingResurrected,
					setFunc = RdKGToolIsdp.SetIsdpColorBeingResurrected,
					width = "full"
				},
				[7] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.ISDP_COLOR_RESURRECTED,
					getFunc = RdKGToolIsdp.GetIsdpColorResurrected,
					setFunc = RdKGToolIsdp.SetIsdpColorResurrected,
					width = "full"
				},
			}
		},		
	}
	return menu
end

function RdKGToolIsdp.GetIsdpEnabled()
	return RdKGToolIsdp.isdpVars.enabled
end

function RdKGToolIsdp.SetIsdpEnabled(value)
	RdKGToolIsdp.SetEnabled(value)
end

function RdKGToolIsdp.GetIsdpPvpOnly()
	return RdKGToolIsdp.isdpVars.pvpOnly
end

function RdKGToolIsdp.SetIsdpPvpOnly(value)
	RdKGToolIsdp.isdpVars.pvpOnly = value
	RdKGToolIsdp.SetEnabled(RdKGToolIsdp.isdpVars.enabled)
end

function RdKGToolIsdp.GetIsdpSize()
	return RdKGToolMath.FloatingPointToValue(RdKGToolIsdp.isdpVars.size, 16)
end

function RdKGToolIsdp.SetIsdpSize(value)
	if value ~= nil and value >= 1 and value <= 16 then
		RdKGToolIsdp.isdpVars.size = RdKGToolMath.ValueToFloatingPoint(value, 16)
		RdKGToolIsdp.AdjustSize()
	end
end

function RdKGToolIsdp.GetIsdpBeams()
	local names = {}
	for i = 1, #RdKGToolIsdp.state.beams do
		table.insert(names, RdKGToolIsdp.state.beams[i].name)
	end
	return names
end

function RdKGToolIsdp.GetIsdpSelectedBeam()
	return RdKGToolIsdp.state.beams[RdKGToolIsdp.isdpVars.texture].name
end

function RdKGToolIsdp.SetIsdpSelectedBeam(value)
	if value ~= nil then
		for i = 1, #RdKGToolIsdp.state.beams do
			if RdKGToolIsdp.state.beams[i].name == value then
				RdKGToolIsdp.isdpVars.texture = i
				RdKGToolIsdp.AdjustTextures()
				RdKGToolIsdp.AdjustSize()
				return
			end
		end
	end
end

function RdKGToolIsdp.GetIsdpColorDead()
	return RdKGToolMenu.GetRGBAColor(RdKGToolIsdp.isdpVars.colors.dead)
end

function RdKGToolIsdp.SetIsdpColorDead(r, g, b, a)
	RdKGToolIsdp.isdpVars.colors.dead = RdKGToolMenu.GetColorFromRGB(r, g, b, a)
end

function RdKGToolIsdp.GetIsdpColorBeingResurrected()
	return RdKGToolMenu.GetRGBAColor(RdKGToolIsdp.isdpVars.colors.beingRessurected)
end

function RdKGToolIsdp.SetIsdpColorBeingResurrected(r, g, b, a)
	RdKGToolIsdp.isdpVars.colors.beingRessurected = RdKGToolMenu.GetColorFromRGB(r, g, b, a)
end

function RdKGToolIsdp.GetIsdpColorResurrected()
	return RdKGToolMenu.GetRGBAColor(RdKGToolIsdp.isdpVars.colors.ressurected)
end

function RdKGToolIsdp.SetIsdpColorResurrected(r, g, b, a)
	RdKGToolIsdp.isdpVars.colors.ressurected = RdKGToolMenu.GetColorFromRGB(r, g, b, a)
end
