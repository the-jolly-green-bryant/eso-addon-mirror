-- RdK Group Tool Follow The Crown Beam
-- By @s0rdrak (PC / EU)

--local lib3D = LibStub("Lib3D2")

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGToolGroup.ftcb = RdKGToolGroup.ftcb or {}
local RdKGToolBeam = RdKGToolGroup.ftcb
RdKGToolUtil.moving3DObjects = RdKGToolUtil.moving3DObjects  or {}
local RdKGToolM3DO = RdKGToolUtil.moving3DObjects
RdKGToolUtil.beams = RdKGToolUtil.beams
local RdKGToolBeams = RdKGToolUtil.beams

RdKGToolBeam.callbackName = RdKGTool.addonName .. "FollowTheCrownBeam"

RdKGToolBeam.constants = {}

RdKGToolBeam.controls = {}

RdKGToolBeam.config = {}
RdKGToolBeam.config.updateInterval = 10
RdKGToolBeam.config.distanceUpdateInterval = 100
RdKGToolBeam.config.maxDistance = 200

RdKGToolBeam.state = {}
RdKGToolBeam.state.initialized = false
RdKGToolBeam.state.registredConsumers = false
RdKGToolBeam.state.registredActivationConsumers = false
RdKGToolBeam.state.controlCallbackRegistered = false
RdKGToolBeam.state.textureRegistered = false

local wm = GetWindowManager()

function RdKGToolBeam.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolBeam.callbackName, RdKGToolBeam.OnProfileChanged)
	RdKGToolBeam.controls.beam = wm:CreateControl(nil, RdKGToolM3DO.GetDefaultTopLevelWindow(), CT_TEXTURE)
	RdKGToolBeam.controls.beam:Create3DRenderSpace()
	RdKGToolBeam.controls.beam:Set3DLocalDimensions(1, 256)
	RdKGToolBeam.controls.beam:SetDrawLevel(3)
	RdKGToolBeam.controls.beam:SetHidden(true)
	RdKGToolBeam.controls.beam:Set3DRenderSpaceUsesDepthBuffer(true)
	RdKGToolBeam.state.initialized = true
	RdKGToolBeam.AdjustTexture()
	RdKGToolBeam.AdjustColor()
	RdKGToolBeam.SetEnabled(RdKGToolBeam.ftcbVars.enabled)
	--RdKGToolM3DO.RegisterTextureControl(RdKGToolBeam.controls.beam)
end

function RdKGToolBeam.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.pvpOnly = true
	defaults.selectedTexture = RdKGToolBeams.constants.beams.BEAM_1
	defaults.color = {}
	defaults.color.r = 0
	defaults.color.g = 0.5
	defaults.color.b = 1
	defaults.color.a = 0.75
	return defaults
end

function RdKGToolBeam.SetEnabled(value)
	--d("SetEnabled")
	if RdKGToolBeam.state.initialized == true and value ~= nil then
		--d("dafuq")
		RdKGToolBeam.ftcbVars.enabled = value
		if value == true then
			if RdKGToolBeam.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolBeam.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolBeam.OnPlayerActivated)
			end
			RdKGToolBeam.state.registredConsumers = true
		else
			if RdKGToolBeam.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolBeam.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolBeam.state.registredConsumers = false
		end
		RdKGToolBeam.OnPlayerActivated()
	end
end

function RdKGToolBeam.AdjustColor()
	RdKGToolBeam.controls.beam:SetColor(RdKGToolBeam.ftcbVars.color.r, RdKGToolBeam.ftcbVars.color.g, RdKGToolBeam.ftcbVars.color.b, RdKGToolBeam.ftcbVars.color.a)
end

function RdKGToolBeam.AdjustTexture()
	local beam = RdKGToolBeams.GetBeamByBeamId(RdKGToolBeam.ftcbVars.selectedTexture)
	RdKGToolBeam.controls.beam:SetTexture(beam.texture)
	RdKGToolBeam.controls.beam:Set3DLocalDimensions(beam.width, beam.height)
	RdKGToolBeam.controls.beam:Set3DRenderSpaceUsesDepthBuffer(beam.usesDepthBuffer)
end

--callbacks
function RdKGToolBeam.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolBeam.ftcbVars = currentProfile.group.ftcb
		if RdKGToolBeam.state.initialized == true then
			RdKGToolBeam.AdjustColor()
			RdKGToolBeam.AdjustTexture()
		end
		RdKGToolBeam.SetEnabled(RdKGToolBeam.ftcbVars.enabled)
	end
end

function RdKGToolBeam.OnPlayerActivated(eventCode, initial)
	--d("player activated")
	if RdKGToolBeam.ftcbVars.enabled == true and (RdKGToolBeam.ftcbVars.pvpOnly == false or (RdKGToolBeam.ftcbVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolBeam.state.registredActivationConsumers == false then
			--d("enabled")
			EVENT_MANAGER:RegisterForUpdate(RdKGToolBeam.callbackName, RdKGToolBeam.config.updateInterval, RdKGToolBeam.UiLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES, RdKGToolBeam.config.updateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_LEADER_DISTANCE, RdKGToolBeam.config.distanceUpdateInterval)
			--lib3D:RegisterWorldChangeCallback(RdKGToolBeam.callbackName, RdKGToolBeam.OnWorldMove)
			--RdKGToolBeam.OnWorldMove()
			RdKGToolBeam.state.registredActivationConsumers = true
		end
		--RdKGToolM3DO.RegisterTextureControl(RdKGToolBeam.controls.beam)
	else
		if RdKGToolBeam.state.registredActivationConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolBeam.callbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolBeam.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_LEADER_DISTANCE)
			--lib3D:UnregisterWorldChangeCallback(RdKGToolBeam.callbackName)
			RdKGToolBeam.state.registredActivationConsumers = false
		end
		RdKGToolBeam.controls.beam:SetHidden(true)
		if RdKGToolBeam.state.textureRegistered == true then
			RdKGToolBeam.state.textureRegistered = false
			RdKGToolM3DO.UnregisterTextureControl(RdKGToolBeam.controls.beam)
		end
	end
end

--[[
function RdKGToolBeam.OnWorldMove()
	--d("OnWorldMove")
	local x, z = lib3D:GlobalToWorld(lib3D:GetWorldOriginAsGlobal())
	RdKGToolBeam.controls.beam:Set3DRenderSpaceOrigin(x, 0, z)
end

function RdKGToolBeam.RenderSpaceUpdate()
	local x, y, z = RdKGToolBeam.controls.beam:Get3DRenderSpaceOrigin()
	if x ~= 0 and z ~= 0 then
		--d("changed location")
		local x, z = lib3D:GlobalToWorld(lib3D:GetWorldOriginAsGlobal())
		RdKGToolBeam.controls.beam:Set3DRenderSpaceOrigin(x, 0, z)
	end
end
]]

function RdKGToolBeam.UiLoop()
	local drawBeam = false
	--d("loop")
	if RdKGToolBeam.ftcbVars.enabled == true and (RdKGToolBeam.ftcbVars.pvpOnly == false or (RdKGToolBeam.ftcbVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		if players ~= nil then
			local leaderDistance = RdKGToolUtilGroup.GetLeaderDistance()
			if leaderDistance ~= nil and leaderDistance < RdKGToolBeam.config.maxDistance then
				
				local leader = nil
				local zoneIndex = nil
				for i = 1, #players do
					if players[i].isLeader == true then
						leader = players[i]
						zoneIndex = GetUnitZoneIndex(players[i].unitTag)
						break
					end
				end
				--d(leader)
				if leader ~= nil then
					if leader.isPlayer == false and leader.coordinates ~= nil and zoneIndex ~= nil and zoneIndex == GetUnitZoneIndex("player") then
						--d("yes, draw a beam")
						drawBeam = true
						local beam = RdKGToolBeams.GetBeamByBeamId(RdKGToolBeam.ftcbVars.selectedTexture)
						--local _, height, _ = lib3D:GetCameraRenderSpacePosition()
						--d("code path reached")
						--d("Position: " .. leader.coordinates.x .. ", " .. height .. ", " .. leader.coordinates.y)
						--RdKGToolBeam.controls.beam:Set3DRenderSpaceOrigin(leader.coordinates.x, leader.coordinates.height , leader.coordinates.y)
						--if GetUnitZoneIndex(leader.unitTag) == 373 or GetUnitZoneIndex(leader.unitTag) == 346 then
							--wtf IC / Sewers?
							--[[
							d("---")
							d("IC")
							d(leader.coordinates.worldX)
							d(leader.coordinates.worldHeight)
							d(leader.coordinates.worldY)
							
							TestOffset = TestOffset or 0
							
							local x, y, z = GetMapPlayerPosition(leader.unitTag)
							local worldX, worldZ = Lib3D:LocalToWorld(x, y)
							local _, height, _ = Lib3D:GetCameraRenderSpacePosition()
							d("-Camera")
							d(worldX)
							d(height)
							d(worldZ)
							if worldX ~= nil and worldZ ~= nil then
								worldX, _, worldZ = WorldPositionToGuiRender3DPosition(worldX * 100, 0, worldZ*100)
							end
							d("-RenderSpace Camera")
							d(worldX)
							d(height)
							d(worldZ)
							d("-Raw")
							local _, x, y, z = GetUnitRawWorldPosition(leader.unitTag)
							d(x)
							d(y)
							d(z)
							d("-Raw - Render Position")
							x, y, z = WorldPositionToGuiRender3DPosition(x , y + TestOffset, z)
							d(x)
							d(y)
							d(z)
							x, y, z = WorldPositionToGuiRender3DPosition( x, y, z )
							--RdKGToolBeam.controls.beam:Set3DRenderSpaceOrigin(leader.coordinates.worldX / 100, (leader.coordinates.worldHeight + beam.heightOffset) / 100, leader.coordinates.worldY / 100)
							RdKGToolBeam.controls.beam:Set3DRenderSpaceOrigin(x / 100, y / 100, z / 100)
							RdKGToolBeam.controls.beam:Set3DRenderSpaceUsesDepthBuffer(false)
							]]
						--else
							--d("Not IC")
							RdKGToolBeam.controls.beam:Set3DRenderSpaceOrigin(leader.coordinates.worldX, leader.coordinates.worldHeight + beam.heightOffset, leader.coordinates.worldY)
						--end
						local heading = GetPlayerCameraHeading()
						if heading > math.pi then 
							heading = heading - 2 * math.pi
						end
						RdKGToolBeam.controls.beam:Set3DRenderSpaceOrientation(0, heading, 0)
						RdKGToolBeam.controls.beam.coordinates = leader.coordinates --layer test
					end
				end
			end
		end
	end
	--draw beam
	if drawBeam == true then
		RdKGToolBeam.controls.beam:SetHidden(false)
		if RdKGToolBeam.state.textureRegistered == false then
			RdKGToolBeam.state.textureRegistered = true
			RdKGToolM3DO.RegisterTextureControl(RdKGToolBeam.controls.beam)
		end
		--[[
		if RdKGToolBeam.state.controlCallbackRegistered == false then
			EVENT_MANAGER:RegisterForUpdate(RdKGToolBeam.controlCallbackName, 0, RdKGToolBeam.RenderSpaceUpdate)
			RdKGToolBeam.state.controlCallbackRegistered = true
		end
		]]
		--d("all good")
	else
		RdKGToolBeam.controls.beam:SetHidden(true)
		if RdKGToolBeam.state.textureRegistered == true then
			RdKGToolBeam.state.textureRegistered = false
			RdKGToolM3DO.UnregisterTextureControl(RdKGToolBeam.controls.beam)
		end
		--[[
		if RdKGToolBeam.state.controlCallbackRegistered == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolBeam.controlCallbackName)
			RdKGToolBeam.state.controlCallbackRegistered = false
		end
		]]
	end
end

--menu interaction
function RdKGToolBeam.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.FTCB_HEADER,
			--width = "full",
			controls = {
				[1] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.FTCB_WARNING,
					width = "full"
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCB_ENABLED,
					getFunc = RdKGToolBeam.GetFtcbEnabled,
					setFunc = RdKGToolBeam.SetFtcbEnabled,
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCB_PVP_ONLY,
					getFunc = RdKGToolBeam.GetFtcbPvpOnly,
					setFunc = RdKGToolBeam.SetFtcbPvpOnly,
				},
				[4] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.FTCB_SELECTED_BEAM,
					choices = RdKGToolBeam.GetFtcbBeams(),
					getFunc = RdKGToolBeam.GetFtcbSelectedBeam,
					setFunc = RdKGToolBeam.SetFtcbSelectedBeam,
					width = "full"
				},
				[5] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.FTCB_COLOR,
					getFunc = RdKGToolBeam.GetFtcbColor,
					setFunc = RdKGToolBeam.SetFtcbColor,
					width = "full"
				}
			}
		}
	}
	return menu
end

function RdKGToolBeam.GetFtcbEnabled()
	return RdKGToolBeam.ftcbVars.enabled
end

function RdKGToolBeam.SetFtcbEnabled(value)
	RdKGToolBeam.SetEnabled(value)
end

function RdKGToolBeam.GetFtcbPvpOnly()
	return RdKGToolBeam.ftcbVars.pvpOnly
end

function RdKGToolBeam.SetFtcbPvpOnly(value)
	RdKGToolBeam.ftcbVars.pvpOnly = value
	RdKGToolBeam.SetEnabled(RdKGToolBeam.ftcbVars.enabled)
end

function RdKGToolBeam.GetFtcbBeams()
	return RdKGToolBeams.GetBeamNames()
end

function RdKGToolBeam.GetFtcbSelectedBeam()
	return RdKGToolBeams.GetBeamByBeamId(RdKGToolBeam.ftcbVars.selectedTexture).name
end

function RdKGToolBeam.SetFtcbSelectedBeam(value)
	if value ~= nil then
		RdKGToolBeam.ftcbVars.selectedTexture = RdKGToolBeams.GetBeamIdByName(value)
		RdKGToolBeam.AdjustTexture()
	end
end

function RdKGToolBeam.GetFtcbColor()
	return RdKGToolMenu.GetRGBAColor(RdKGToolBeam.ftcbVars.color)
end

function RdKGToolBeam.SetFtcbColor(r, g, b, a)
	RdKGToolBeam.ftcbVars.color = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolBeam.AdjustColor()
end
