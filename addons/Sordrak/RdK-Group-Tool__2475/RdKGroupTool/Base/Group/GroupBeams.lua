-- RdK Group Tool Group Beams
-- By @s0rdrak (PC / EU)

--local lib3D = LibStub("Lib3D2")
local lib3D = Lib3D

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGToolGroup.gb = RdKGToolGroup.gb or {}
local RdKGToolGBeam = RdKGToolGroup.gb
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.moving3DObjects = RdKGToolUtil.moving3DObjects  or {}
local RdKGToolM3DO = RdKGToolUtil.moving3DObjects
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGToolUtil.beams = RdKGToolUtil.beams
local RdKGToolBeams = RdKGToolUtil.beams

RdKGToolGBeam.callbackName = RdKGTool.addonName .. "GroupBeam"

RdKGToolGBeam.constants = {}

RdKGToolGBeam.controls = {}
RdKGToolGBeam.controls.beams = {}

RdKGToolGBeam.config = {}
RdKGToolGBeam.config.updateInterval = 10
RdKGToolGBeam.config.distanceUpdateInterval = 100
RdKGToolGBeam.config.maxDistance = 200

RdKGToolGBeam.state = {}
RdKGToolGBeam.state.initialized = false
RdKGToolGBeam.state.registredConsumers = false
RdKGToolGBeam.state.registredActivationConsumers = false

local wm = GetWindowManager()

function RdKGToolGBeam.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolGBeam.callbackName, RdKGToolGBeam.OnProfileChanged)
	RdKGToolGBeam.CreateBeams()
	RdKGToolGBeam.state.initialized = true
	RdKGToolGBeam.AdjustTextures()
	RdKGToolGBeam.SetEnabled(RdKGToolGBeam.gbVars.enabled)
end

function RdKGToolGBeam.CreateBeams()
	for i = 1, 10 do
		table.insert(RdKGToolGBeam.controls.beams, RdKGToolGBeam.CreateBeam())
	end
end

function RdKGToolGBeam.CreateBeam()
	local beam = wm:CreateControl(nil, RdKGToolM3DO.GetDefaultTopLevelWindow(), CT_TEXTURE)
	beam:Create3DRenderSpace()
	beam:Set3DLocalDimensions(RdKGToolGBeam.gbVars.size, 256)
	beam:SetDrawLevel(3)
	beam:SetTexture(RdKGToolBeams.GetBeamByBeamId(RdKGToolGBeam.gbVars.texture).texture)
	beam:Set3DRenderSpaceUsesDepthBuffer(true)
	beam:SetHidden(true)
	beam.registeredTexture = false
	return beam
end

function RdKGToolGBeam.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.pvpOnly = true
	defaults.size = 0.5
	defaults.hideWhenDead = true
	defaults.texture = RdKGToolBeams.constants.beams.BEAM_1
	defaults.roles = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID].color.r = 0.05490196078431372549019607843137
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID].color.g = 0.77254901960784313725490196078431
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID].color.b = 0.09019607843137254901960784313725
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE].color.r = 0.87450980392156862745098039215686
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE].color.g = 0.94117647058823529411764705882353
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE].color.b = 0.05882352941176470588235294117647
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL].color.r = 0.6
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL].color.g = 0.85098039215686274509803921568627
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL].color.b = 0.91764705882352941176470588235294
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD].color.r = 0.53333333333333333333333333333333
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD].color.g = 0
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD].color.b = 0.08235294117647058823529411764706
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY].color.r = 0.70980392156862745098039215686275
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY].color.g = 0.90196078431372549019607843137255
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY].color.b = 0.11372549019607843137254901960784
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC].color.r = 1
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC].color.g = 0.78823529411764705882352941176471
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC].color.b = 0.05490196078431372549019607843137
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT].color.r = 0.44705882352941176470588235294118
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT].color.g = 0.61176470588235294117647058823529
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT].color.b = 0.61176470588235294117647058823529
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER].enabled = false
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER].color.r = 0.71764705882352941176470588235294
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER].color.g = 0.58823529411764705882352941176471
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER].color.b = 0.34117647058823529411764705882353
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER].color.a = 0.5
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT] = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT].enabled = true
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT].color = {}
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT].color.r = 0.38039215686274509803921568627451
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT].color.g = 0.22352941176470588235294117647059
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT].color.b = 0.83529411764705882352941176470588
	defaults.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT].color.a = 0.5
	return defaults
end

function RdKGToolGBeam.SetEnabled(value)
	if RdKGToolGBeam.state.initialized == true and value ~= nil then
		RdKGToolGBeam.gbVars.enabled = value
		if value == true then
			if RdKGToolGBeam.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolGBeam.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolGBeam.OnPlayerActivated)
			end
			RdKGToolGBeam.state.registredConsumers = true
		else
			if RdKGToolGBeam.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolGBeam.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolGBeam.state.registredConsumers = false
		end
		RdKGToolGBeam.OnPlayerActivated()
	end
end

function RdKGToolGBeam.AdjustSize()
	local beam = RdKGToolBeams.GetBeamByBeamId(RdKGToolGBeam.gbVars.texture)
	for i = 1, #RdKGToolGBeam.controls.beams do
		if beam.ignoreSize == false then
			RdKGToolGBeam.controls.beams[i]:Set3DLocalDimensions(RdKGToolGBeam.gbVars.size, beam.height)
		else
			RdKGToolGBeam.controls.beams[i]:Set3DLocalDimensions(beam.width, beam.height)
		end
	end
end

function RdKGToolGBeam.AdjustTextures()
	local beam = RdKGToolBeams.GetBeamByBeamId(RdKGToolGBeam.gbVars.texture)
	for i = 1, #RdKGToolGBeam.controls.beams do
		RdKGToolGBeam.controls.beams[i]:SetTexture(beam.texture)
		RdKGToolGBeam.controls.beams[i]:Set3DRenderSpaceUsesDepthBuffer(beam.usesDepthBuffer)
	end
	RdKGToolGBeam.AdjustSize()
end

function RdKGToolGBeam.GetRoleBeamInformation(role)
	local color = nil
	local enabled = false
	if RdKGToolGBeam.gbVars.roles[role] ~= nil then
		if RdKGToolGBeam.gbVars.roles[role].enabled ~= nil then
			enabled = RdKGToolGBeam.gbVars.roles[role].enabled
		end
		if RdKGToolGBeam.gbVars.roles[role].color ~= nil then
			color = RdKGToolGBeam.gbVars.roles[role].color
		end
	end
	return enabled, color
end

function RdKGToolGBeam.GetEnabled()
	return (RdKGToolGBeam.gbVars.enabled == true and (RdKGToolGBeam.gbVars.pvpOnly == false or (RdKGToolGBeam.gbVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)))
end

--callbacks
function RdKGToolGBeam.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolGBeam.gbVars = currentProfile.group.gb
		if RdKGToolGBeam.state.initialized == true then
			RdKGToolGBeam.AdjustTextures()
		end
		RdKGToolGBeam.SetEnabled(RdKGToolGBeam.gbVars.enabled)
	end
end

function RdKGToolGBeam.OnPlayerActivated(eventCode, initial)
	if RdKGToolGBeam.gbVars.enabled == true and (RdKGToolGBeam.gbVars.pvpOnly == false or (RdKGToolGBeam.gbVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolGBeam.state.registredActivationConsumers == false then
			EVENT_MANAGER:RegisterForUpdate(RdKGToolGBeam.callbackName, RdKGToolGBeam.config.updateInterval, RdKGToolGBeam.UiLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolGBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES, RdKGToolGBeam.config.updateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolGBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE, RdKGToolGBeam.config.distanceUpdateInterval)
			RdKGToolGBeam.state.registredActivationConsumers = true
		end
	else
		if RdKGToolGBeam.state.registredActivationConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolGBeam.callbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolGBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolGBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE)
			RdKGToolGBeam.state.registredActivationConsumers = false
		end
		--Hide if neccessary
		for i = 1, #RdKGToolGBeam.controls.beams do
			if RdKGToolGBeam.controls.beams[i].registeredTexture == true then
				RdKGToolM3DO.UnregisterTextureControl(RdKGToolGBeam.controls.beams[i])
				RdKGToolGBeam.controls.beams[i].registeredTexture = false
			end
			RdKGToolGBeam.controls.beams[i]:SetHidden(true)
		end
	end
end

function RdKGToolGBeam.UiLoop()
	--d("ui loop")
	if RdKGToolGBeam.gbVars.enabled == true and (RdKGToolGBeam.gbVars.pvpOnly == false or (RdKGToolGBeam.gbVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		--d("ui loop enabled")
		local beamIndex = 1
		local players = RdKGToolUtilGroup.GetGroupInformation()
		if players ~= nil then
			if #players > #RdKGToolGBeam.controls.beams then
				local amount = #players - #RdKGToolGBeam.controls.beams
				for i = 1, amount do
					local beam = RdKGToolGBeam.CreateBeam()
					table.insert(RdKGToolGBeam.controls.beams, beam)
					RdKGToolGBeam.AdjustTextures()
					--RdKGToolM3DO.RegisterTextureControl(beam)
				end
			end
			--local _, height, _ = lib3D:GetCameraRenderSpacePosition()
			local heading = GetPlayerCameraHeading()
			if heading > math.pi then 
				heading = heading - 2 * math.pi
			end
			for i = 1, #players do
				local player = players[i]
				local role = player.role
				--d(role)
				if role ~= nil and player.isOnline == true and player.isPlayer == false and player.isLeader == false then
					local enabled, color = RdKGToolGBeam.GetRoleBeamInformation(role)
					--d("here we go")
					
					if enabled == true and player.distances.fromPlayer ~= nil and RdKGToolGBeam.config.maxDistance >= player.distances.fromPlayer and (RdKGToolGBeam.gbVars.hideWhenDead == false or (RdKGToolGBeam.gbVars.hideWhenDead == true and player.isDead == false)) then
						local coordinates = player.coordinates
						local beam = RdKGToolGBeam.controls.beams[beamIndex]
						local beamTemplate = RdKGToolBeams.GetBeamByBeamId(RdKGToolGBeam.gbVars.texture)
						beam:SetColor(color.r, color.g, color.b)
						--beam:Set3DRenderSpaceOrigin(coordinates.x, coordinates.height , coordinates.y)
						beam:Set3DRenderSpaceOrigin(coordinates.worldX, coordinates.worldHeight + beamTemplate.heightOffset, coordinates.worldY)
						beam:Set3DRenderSpaceOrientation(0, heading, 0)
						beam:SetHidden(false)
						if beam.registeredTexture == false then
							RdKGToolM3DO.RegisterTextureControl(beam)
							beam.registeredTexture = true
						end
						beam.coordinates = coordinates --layer test 
						beamIndex = beamIndex + 1
						--d("done")
					end
				end
			end
			
		end
		for i = beamIndex, #RdKGToolGBeam.controls.beams do
			RdKGToolGBeam.controls.beams[i]:SetHidden(true)
			if RdKGToolGBeam.controls.beams[i].registeredTexture == true then
				RdKGToolM3DO.UnregisterTextureControl(RdKGToolGBeam.controls.beams[i])
				RdKGToolGBeam.controls.beams[i].registeredTexture = false
			end
		end
	else
		for i = 1, #RdKGToolGBeam.controls.beams do
			RdKGToolGBeam.controls.beams[i]:SetHidden(true)
			if RdKGToolGBeam.controls.beams[i].registeredTexture == true then
				RdKGToolM3DO.UnregisterTextureControl(RdKGToolGBeam.controls.beams[i])
				RdKGToolGBeam.controls.beams[i].registeredTexture = false
			end
		end
	end
end

--menu interaction
function RdKGToolGBeam.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.GB_HEADER,
			controls = {
				[1] = {
					type = "description",
					text = RdKGToolMenu.constants.GB_DESCRIPTION
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ENABLED,
					getFunc = RdKGToolGBeam.GetGbEnabled,
					setFunc = RdKGToolGBeam.SetGbEnabled
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_PVP_ONLY,
					getFunc = RdKGToolGBeam.GetGbPvpOnly,
					setFunc = RdKGToolGBeam.SetGbPvpOnly
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_HIDE_WHEN_DEAD,
					getFunc = RdKGToolGBeam.GetGbHideWhenDead,
					setFunc = RdKGToolGBeam.SetGbHideWhenDead
				},
				[5] = {
					type = "slider",
					name = RdKGToolMenu.constants.GB_SIZE,
					min = 1,
					max = 8,
					step = 1,
					getFunc = RdKGToolGBeam.GetGbSize,
					setFunc = RdKGToolGBeam.SetGbSize,
					width = "full",
					default = 4
				},
				[6] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.GB_SELECTED_BEAM,
					choices = RdKGToolGBeam.GetGbBeams(),
					getFunc = RdKGToolGBeam.GetGbSelectedBeam,
					setFunc = RdKGToolGBeam.SetGbSelectedBeam
				},
				[7] = {
					type = "divider",
					width = "full"
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_RAPID_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_RAPID) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_RAPID, value) end,
					width = "full"
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_RAPID_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_RAPID) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_RAPID, r, g, b, a) end,
					width = "full"
				},
				[10] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_PURGE_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_PURGE) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_PURGE, value) end,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_PURGE_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_PURGE) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_PURGE, r, g, b, a) end,
					width = "full"
				},
				[12] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_HEAL_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_HEAL) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_HEAL, value) end,
					width = "full"
				},
				[13] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_HEAL_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_HEAL) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_HEAL, r, g, b, a) end,
					width = "full"
				},
				[14] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_DD_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_DD) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_DD, value) end,
					width = "full"
				},
				[15] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_DD_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_DD) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_DD, r, g, b, a) end,
					width = "full"
				},
				[16] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_SYNERGY_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY, value) end,
					width = "full"
				},
				[17] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_SYNERGY_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY, r, g, b, a) end,
					width = "full"
				},
				[18] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_CC_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_CC) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_CC, value) end,
					width = "full"
				},
				[19] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_CC_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_CC) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_CC, r, g, b, a) end,
					width = "full"
				},
				[20] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_SUPPORT_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT, value) end,
					width = "full"
				},
				[21] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_SUPPORT_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT, r, g, b, a) end,
					width = "full"
				},
				[22] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_PLACEHOLDER_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER, value) end,
					width = "full"
				},
				[23] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_PLACEHOLDER_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER, r, g, b, a) end,
					width = "full"
				},
				[24] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.GB_ROLE_APPLICANT_ENABLED,
					getFunc = function() return RdKGToolGBeam.GetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT) end,
					setFunc = function(value) RdKGToolGBeam.SetGbRoleEnabled(RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT, value) end,
					width = "full"
				},
				[25] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.GB_ROLE_APPLICANT_COLOR,
					getFunc = function() return RdKGToolGBeam.GetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT) end,
					setFunc = function(r, g, b, a) RdKGToolGBeam.SetGbRoleColor(RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT, r, g, b, a) end,
					width = "full"
				}
			}
		}
	}
	return menu
end


function RdKGToolGBeam.GetGbEnabled()
	return RdKGToolGBeam.gbVars.enabled
end

function RdKGToolGBeam.SetGbEnabled(value)
	RdKGToolGBeam.SetEnabled(value)
end

function RdKGToolGBeam.GetGbPvpOnly()
	return RdKGToolGBeam.gbVars.pvpOnly
end

function RdKGToolGBeam.SetGbPvpOnly(value)
	RdKGToolGBeam.gbVars.pvpOnly = value
	RdKGToolGBeam.SetEnabled(RdKGToolGBeam.gbVars.enabled)
end

function RdKGToolGBeam.GetGbSize()
	return RdKGToolMath.FloatingPointToValue(RdKGToolGBeam.gbVars.size, 8)
end

function RdKGToolGBeam.SetGbSize(value)
	if value ~= nil and value >= 1 and value <= 8 then
		RdKGToolGBeam.gbVars.size = RdKGToolMath.ValueToFloatingPoint(value, 8)
		RdKGToolGBeam.AdjustSize()
	end
end

function RdKGToolGBeam.GetGbHideWhenDead()
	return RdKGToolGBeam.gbVars.hideWhenDead
end

function RdKGToolGBeam.SetGbHideWhenDead(value)
	RdKGToolGBeam.gbVars.hideWhenDead = value
end

function RdKGToolGBeam.GetGbBeams()
	return RdKGToolBeams.GetBeamNames()
end

function RdKGToolGBeam.GetGbSelectedBeam()
	return RdKGToolBeams.GetBeamByBeamId(RdKGToolGBeam.gbVars.texture).name
end

function RdKGToolGBeam.SetGbSelectedBeam(value)
	if value ~= nil then
		RdKGToolGBeam.gbVars.texture = RdKGToolBeams.GetBeamIdByName(value)
		RdKGToolGBeam.AdjustTextures()
	end
end

function RdKGToolGBeam.GetGbRoleEnabled(role)
	return RdKGToolGBeam.gbVars.roles[role].enabled
end

function RdKGToolGBeam.SetGbRoleEnabled(role, value)
	RdKGToolGBeam.gbVars.roles[role].enabled = value
end

function RdKGToolGBeam.GetGbRoleColor(role)
	return RdKGToolMenu.GetRGBAColor(RdKGToolGBeam.gbVars.roles[role].color)
end

function RdKGToolGBeam.SetGbRoleColor(role, r, g, b, a)
	RdKGToolGBeam.gbVars.roles[role].color = RdKGToolMenu.GetColorFromRGB(r, g, b, a)
end

