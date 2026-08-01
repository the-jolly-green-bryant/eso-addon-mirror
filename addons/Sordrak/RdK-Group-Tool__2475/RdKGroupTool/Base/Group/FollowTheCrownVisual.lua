-- RdK Group Tool Follow The Crown Visual
-- By @s0rdrak (PC / EU)

--local lib3d = LibStub("Lib3D2")
local lib3d = Lib3D

RdKGTool.group.ftcv = RdKGTool.group.ftcv or {}
local RdKGToolFtcv = RdKGTool.group.ftcv
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.ui = RdKGToolUtil.ui or {}
local RdKGToolUI = RdKGToolUtil.ui
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group
RdKGToolFtcv.constants = RdKGToolFtcv.constants or {}
RdKGToolFtcv.constants.modes = {}
RdKGToolFtcv.constants.modes.RETICLE = 1
RdKGToolFtcv.constants.modes.FIXED = 2
RdKGToolFtcv.constants.MODES = {}
RdKGToolFtcv.constants.color_modes = {}
RdKGToolFtcv.constants.color_modes.DISTANCE = 1
RdKGToolFtcv.constants.color_modes.ORIENTATION = 2
RdKGToolFtcv.constants.COLOR_MODES = {}
RdKGToolFtcv.constants.TLW_RETICLE_NAME = "RdKGTool.group.ftcv.RETICLE_TLW"
RdKGToolFtcv.constants.RETICLE_NAME = "RdKGTool.group.ftcv.RETICLE"
RdKGToolFtcv.constants.TLW_FIXED_NAME = "RdKGTool.group.ftcv.FIXED_TLW"
RdKGToolFtcv.constants.FIXED_NAME = "RdKGTool.group.ftcv.FIXED"

local wm = WINDOW_MANAGER
RdKGToolFtcv.controls = {}

RdKGToolFtcv.callbackName = RdKGTool.addonName .. "FollowTheCrownVisual"

RdKGToolFtcv.config = RdKGToolFtcv.config or {}
RdKGToolFtcv.config.isClampedToScreen = true
RdKGToolFtcv.config.updateInterval = 10
RdKGToolFtcv.config.minDis = 0
RdKGToolFtcv.config.maxDis = 10

RdKGToolFtcv.textures = {}
RdKGToolFtcv.textures[1] = {}
RdKGToolFtcv.textures[1].dds = "RdKGroupTool/Art/FTCV/pfeil8.dds"
RdKGToolFtcv.textures[2] = {}
RdKGToolFtcv.textures[2].dds = "RdKGroupTool/Art/FTCV/pfeil1.dds"
RdKGToolFtcv.textures[3] = {}
RdKGToolFtcv.textures[3].dds = "RdKGroupTool/Art/FTCV/pfeil2.dds"
RdKGToolFtcv.textures[4] = {}
RdKGToolFtcv.textures[4].dds = "RdKGroupTool/Art/FTCV/pfeil3.dds"
RdKGToolFtcv.textures[5] = {}
RdKGToolFtcv.textures[5].dds = "RdKGroupTool/Art/FTCV/pfeil4.dds"
RdKGToolFtcv.textures[6] = {}
RdKGToolFtcv.textures[6].dds = "RdKGroupTool/Art/FTCV/pfeil5.dds"
RdKGToolFtcv.textures[7] = {}
RdKGToolFtcv.textures[7].dds = "RdKGroupTool/Art/FTCV/pfeil6.dds"
RdKGToolFtcv.textures[8] = {}
RdKGToolFtcv.textures[8].dds = "RdKGroupTool/Art/FTCV/pfeil7.dds"

RdKGToolFtcv.state = {}
RdKGToolFtcv.state.foreground = true
RdKGToolFtcv.state.initialized = false
RdKGToolFtcv.state.registeredConsumer = false
RdKGToolFtcv.state.activeLayerIndex = 1
RdKGToolFtcv.state.registredActiveConsumers = false

function RdKGToolFtcv.Initialize()
	--vars
	RdKGTool.profile.AddProfileChangeListener(RdKGToolFtcv.callbackName, RdKGToolFtcv.OnProfileChanged)
	RdKGToolFtcv.constants.MODES[RdKGToolFtcv.constants.modes.RETICLE] = RdKGTool.menu.constants.FTCV_MODE_RETICLE
	RdKGToolFtcv.constants.MODES[RdKGToolFtcv.constants.modes.FIXED] = RdKGTool.menu.constants.FTCV_MODE_FIXED
	
	
	RdKGToolFtcv.constants.COLOR_MODES[RdKGToolFtcv.constants.color_modes.DISTANCE] = RdKGTool.menu.constants.FTCV_COLOR_MODE_DISTANCE
	RdKGToolFtcv.constants.COLOR_MODES[RdKGToolFtcv.constants.color_modes.ORIENTATION] = RdKGTool.menu.constants.FTCV_COLOR_MODE_ORIENTATION
	--ui
	local size = RdKGToolFtcv.ftcvVars.size.close

	--reticle
	
	RdKGToolFtcv.controls.TLW_Reticle = wm:CreateTopLevelWindow(RdKGToolFtcv.constants.TLW_RETICLE_NAME)
	
	RdKGToolFtcv.controls.TLW_Reticle:SetDimensions(size, size)
	RdKGToolFtcv.controls.TLW_Reticle:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		
	RdKGToolFtcv.controls.TLW_Reticle:SetClampedToScreen(RdKGToolFtcv.config.isClampedToScreen)
	RdKGToolFtcv.controls.TLW_Reticle:SetDrawLayer(0)
	RdKGToolFtcv.controls.TLW_Reticle:SetDrawLevel(0)
	
	RdKGToolFtcv.controls.reticle = wm:CreateControl(RdKGToolFtcv.constants.RETICLE_NAME, RdKGToolFtcv.controls.TLW_Reticle, CT_TEXTURE)
	
	RdKGToolFtcv.controls.reticle:SetAnchor(TOPLEFT, RdKGToolFtcv.controls.TLW_Reticle, TOPLEFT, 0, 0)
	RdKGToolFtcv.controls.reticle:SetColor(1, 1, 1, 1)

	RdKGToolFtcv.controls.reticle:SetDimensions(size, size)
	
	
	
	--fixed
	RdKGToolFtcv.controls.TLW_Fixed = wm:CreateTopLevelWindow(RdKGToolFtcv.constants.TLW_FIXED_NAME)
	
	RdKGToolFtcv.controls.TLW_Fixed:SetDimensions(size, size)
	RdKGToolFtcv.controls.TLW_Fixed:SetAnchor(CENTER, GuiRoot, CENTER, 0, RdKGToolFtcv.ftcvVars.fixedPosition)
		
	RdKGToolFtcv.controls.TLW_Fixed:SetClampedToScreen(RdKGToolFtcv.config.isClampedToScreen)
	RdKGToolFtcv.controls.TLW_Fixed:SetDrawLayer(0)
	RdKGToolFtcv.controls.TLW_Fixed:SetDrawLevel(0)
	
	RdKGToolFtcv.controls.fixed = wm:CreateControl(RdKGToolFtcv.constants.FIXED_NAME, RdKGToolFtcv.controls.TLW_Fixed, CT_TEXTURE)
	
	RdKGToolFtcv.controls.fixed:SetAnchor(TOPLEFT, RdKGToolFtcv.controls.TLW_Fixed, TOPLEFT, 0, 0)
	RdKGToolFtcv.controls.fixed:SetColor(1, 1, 1, 1)
	
	RdKGToolFtcv.controls.fixed:SetDimensions(size, size)
	
	
		
	--EVENT_MANAGER:RegisterForEvent(RdKGToolFtcv.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolFtcv.SetVisible)
	--EVENT_MANAGER:RegisterForEvent(RdKGToolFtcv.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolFtcv.SetVisible)
	
	--config
	RdKGToolFtcv.controls.TLW_Reticle:SetHidden(true)
	RdKGToolFtcv.controls.TLW_Fixed:SetHidden(true)

	
	RdKGToolFtcv.UpdateTextures()

	RdKGToolFtcv.state.initialized = true
	RdKGToolFtcv.SetEnabled(RdKGToolFtcv.ftcvVars.enabled)
end

function RdKGToolFtcv.GetDefaults()
	local defaults = {}
	defaults.mode = RdKGToolFtcv.constants.modes.RETICLE
	defaults.colorMode = RdKGToolFtcv.constants.color_modes.DISTANCE
	defaults.colors = {}
	defaults.colors.front = {}
	defaults.colors.front.r = 0
	defaults.colors.front.g = 1
	defaults.colors.front.b = 0
	defaults.colors.side = {}
	defaults.colors.side.r = 1
	defaults.colors.side.g = 0.5
	defaults.colors.side.b = 0
	defaults.colors.back = {}
	defaults.colors.back.r = 1
	defaults.colors.back.g = 0
	defaults.colors.back.b = 0
	defaults.enabled = true
	defaults.pvponly = false
	defaults.opacity = {}
	defaults.opacity.close = 50
	defaults.opacity.far = 100
	defaults.size = {}
	defaults.size.close = 30
	defaults.size.far = 75
	defaults.distance = 25
	defaults.position = 65
	defaults.maxDistance = 10
	defaults.minDistance = 3
	defaults.selectedTexture = 1
	return defaults
end

function RdKGToolFtcv.SetEnabled(value)
	if RdKGToolFtcv.state.initialized == true then
		RdKGToolFtcv.ftcvVars.enabled = value
		if RdKGToolFtcv.state.foreground == true then
			if RdKGToolFtcv.ftcvVars.mode == RdKGToolFtcv.constants.modes.RETICLE then
				RdKGToolFtcv.controls.TLW_Reticle:SetHidden(not RdKGToolFtcv.ftcvVars.enabled)
			elseif RdKGToolFtcv.ftcvVars.mode == RdKGToolFtcv.constants.modes.FIXED then
				RdKGToolFtcv.controls.TLW_Fixed:SetHidden(not RdKGToolFtcv.ftcvVars.enabled)
			end
		end
		
		if value == true then
			if RdKGToolFtcv.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolFtcv.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolFtcv.OnPlayerActivated)
				
			end
			RdKGToolFtcv.state.registredConsumers = true
		else
			if RdKGToolFtcv.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolFtcv.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolFtcv.state.registredConsumers = false
		end
		RdKGToolFtcv.OnPlayerActivated()
		
	end
end

function RdKGToolFtcv.GetTextureString()
	return RdKGToolFtcv.textures[RdKGToolFtcv.ftcvVars.selectedTexture].dds
end

function RdKGToolFtcv.UpdateTextures()
	local texture = RdKGToolFtcv.GetTextureString()
	--d(texture)
	RdKGToolFtcv.controls.reticle:SetTexture(texture)
	RdKGToolFtcv.controls.fixed:SetTexture(texture)
end

function RdKGToolFtcv.GetDistanceColorTone(r1, r2, distance)
	local d = RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance
	local color = r1
	
	local delta = r2 - r1
	
	if delta > 0 then
		color = r1 + delta * ((distance - RdKGToolFtcv.ftcvVars.minDistance) / d)
	elseif delta < 0 then
		color = r2 - delta * (d - (distance - RdKGToolFtcv.ftcvVars.minDistance)) / d
	end
	return color
end

--callbacks
function RdKGToolFtcv.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		--RdKGToolFtcv.SetEnabled(false)
		RdKGToolFtcv.ftcvVars = currentProfile.group.ftcv
		RdKGToolFtcv.SetEnabled(RdKGToolFtcv.ftcvVars.enabled)
		if RdKGToolFtcv.state.initialized == true then
			RdKGToolFtcv.UpdateTextures()
			RdKGToolFtcv.SetFtcvPosition(RdKGToolFtcv.ftcvVars.position)
		end
	end
end

function RdKGToolFtcv.OnPlayerActivated(eventCode, initial)
	if RdKGToolFtcv.ftcvVars.enabled == true and (RdKGToolFtcv.ftcvVars.pvponly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolFtcv.ftcvVars.pvponly == false) then
		if RdKGToolFtcv.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolFtcv.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolFtcv.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolFtcv.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolFtcv.SetForegroundVisibility)
			RdKGToolGroup.AddFeature(RdKGToolFtcv.callbackName, RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE, RdKGToolFtcv.config.updateInterval)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolFtcv.callbackName, RdKGToolFtcv.config.updateInterval, RdKGToolFtcv.OnUpdate)
			RdKGToolFtcv.state.registredActiveConsumers = true
		end
	else
		if RdKGToolFtcv.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolFtcv.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolFtcv.callbackName, EVENT_ACTION_LAYER_PUSHED)
			RdKGToolGroup.RemoveFeature(RdKGToolFtcv.callbackName, RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolFtcv.callbackName)
			RdKGToolFtcv.state.registredActiveConsumers = false
		end
	end
	RdKGToolFtcv.SetControlVisibility()
end

function RdKGToolFtcv.SetControlVisibility()
	local enabled = RdKGToolFtcv.ftcvVars.enabled
	local pvpOnly = RdKGToolFtcv.ftcvVars.pvpOnly
	local setOverviewHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setOverviewHidden = false
		end
	end
	if setOverviewHidden == false then
		if RdKGToolFtcv.state.foreground == false then
			if RdKGToolFtcv.ftcvVars.mode == RdKGToolFtcv.constants.modes.RETICLE then
				RdKGToolFtcv.controls.TLW_Reticle:SetHidden(RdKGToolFtcv.state.activeLayerIndex > 2)
			else
				RdKGToolFtcv.controls.TLW_Fixed:SetHidden(RdKGToolFtcv.state.activeLayerIndex > 2)
			end
		else
			if RdKGToolFtcv.ftcvVars.mode == RdKGToolFtcv.constants.modes.RETICLE then
				RdKGToolFtcv.controls.TLW_Reticle:SetHidden(false)
			else
				RdKGToolFtcv.controls.TLW_Fixed:SetHidden(false)
			end
		end
	else
		RdKGToolFtcv.controls.TLW_Reticle:SetHidden(setOverviewHidden)
		RdKGToolFtcv.controls.TLW_Fixed:SetHidden(setOverviewHidden)
	end
end

function RdKGToolFtcv.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolFtcv.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolFtcv.state.foreground = false
	end
	--hack?
	RdKGToolFtcv.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolFtcv.SetControlVisibility()
end

function RdKGToolFtcv.OnUpdate()
	
	--d(pvpZone)
	--d("dafuq")
	if RdKGToolFtcv.ftcvVars.enabled == true and IsUnitGrouped("player") and RdKGToolGroup.IsPlayerGroupLeader() == false then
		--d("unit isn't lead and addon enabled")
		local pvpZone = RdKGToolUtil.IsInPvPArea()
		if RdKGToolFtcv.ftcvVars.pvponly == true and pvpZone == true or RdKGToolFtcv.ftcvVars.pvponly == false then
			

			if lib3d:IsValidZone() then
				--Rotate

				local distance = RdKGToolGroup.GetLeaderDistance()
				local rotation = RdKGToolGroup.GetLeaderRotation()
				--d("FTCV: " .. rotation)
				if distance ~= nil and rotation ~= nil then
					
					RdKGToolFtcv.controls.reticle:SetTextureRotation(rotation)
					RdKGToolFtcv.controls.fixed:SetTextureRotation(rotation)
					--Scale
					local size = RdKGToolFtcv.ftcvVars.size.far
					if RdKGToolFtcv.ftcvVars.size.close > RdKGToolFtcv.ftcvVars.size.far then
						size = RdKGToolFtcv.ftcvVars.size.close
					end
					if RdKGToolFtcv.ftcvVars.size.close < RdKGToolFtcv.ftcvVars.size.far then
						--size = RdKGToolFtcv.ftcvVars.size.close + ((RdKGToolFtcv.ftcvVars.size.far - RdKGToolFtcv.ftcvVars.size.close) / (RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance)) * distance
						size = RdKGToolFtcv.ftcvVars.size.far - (RdKGToolFtcv.ftcvVars.size.far - RdKGToolFtcv.ftcvVars.size.close) * ((RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance) - (distance - RdKGToolFtcv.ftcvVars.minDistance))/(RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance)
						--d(size)
						if size > RdKGToolFtcv.ftcvVars.size.far then
							size = RdKGToolFtcv.ftcvVars.size.far
						elseif size < RdKGToolFtcv.ftcvVars.size.close then
							size = RdKGToolFtcv.ftcvVars.size.close
						end
					end
					size = size * 2
					
					RdKGToolFtcv.controls.TLW_Reticle:SetDimensions(size,size)
					RdKGToolFtcv.controls.TLW_Fixed:SetDimensions(size,size)
					RdKGToolFtcv.controls.reticle:SetDimensions(size,size)
					RdKGToolFtcv.controls.fixed:SetDimensions(size,size)
					
					
					
					--Reposition (Reticle Only)
					
					if RdKGToolFtcv.ftcvVars.mode == RdKGToolFtcv.constants.modes.RETICLE then
						local position = RdKGToolFtcv.ftcvVars.position
						if position < 0 then
							position = -position
						end
						
						local reticleDistance = position + size / 2
						local distanceX = math.sin(math.pi + rotation) * reticleDistance
						local distanceY = math.cos(math.pi + rotation) * reticleDistance
						
						RdKGToolFtcv.controls.TLW_Reticle:ClearAnchors()
						RdKGToolFtcv.controls.TLW_Reticle:SetAnchor(CENTER, GuiRoot, CENTER, distanceX, distanceY)
					end
					--d(rotation)
					
					
					
					
					--opacity
					local opacity = RdKGToolFtcv.ftcvVars.opacity.far
					if RdKGToolFtcv.ftcvVars.opacity.close > RdKGToolFtcv.ftcvVars.opacity.far then
						opacity = RdKGToolFtcv.ftcvVars.opacity.close
					end
					if RdKGToolFtcv.ftcvVars.opacity.close < RdKGToolFtcv.ftcvVars.opacity.far then
						--opacity = (RdKGToolFtcv.ftcvVars.opacity.close + ((RdKGToolFtcv.ftcvVars.opacity.far - RdKGToolFtcv.ftcvVars.opacity.close) / (RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance))* distance) / 100
						opacity = (RdKGToolFtcv.ftcvVars.opacity.far - (RdKGToolFtcv.ftcvVars.opacity.far - RdKGToolFtcv.ftcvVars.opacity.close) * ((RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance) - (distance - RdKGToolFtcv.ftcvVars.minDistance))/(RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance)) / 100
						--d(opacity)
						if opacity > RdKGToolFtcv.ftcvVars.opacity.far / 100 then
							opacity = RdKGToolFtcv.ftcvVars.opacity.far / 100
						elseif opacity < RdKGToolFtcv.ftcvVars.opacity.close / 100 then
							opacity = RdKGToolFtcv.ftcvVars.opacity.close / 100
						end
					end
					
					--RdKGToolFtcv.controls.reticle:SetAlpha(opacity)
					--RdKGToolFtcv.controls.fixed:SetAlpha(opacity)
					
					--Color
					if RdKGToolFtcv.ftcvVars.colorMode == RdKGToolFtcv.constants.color_modes.ORIENTATION then
						local color1 = nil
						local color2 = nil
						local minRotation = nil
						local maxRotation = nil
						if rotation >= math.pi and rotation <= math.pi * 1.5 then
							color1 = RdKGToolFtcv.ftcvVars.colors.back
							color2 = RdKGToolFtcv.ftcvVars.colors.side
							minRotation = math.pi
							maxRotation = math.pi * 1.5
						elseif rotation > math.pi * 1.5 and rotation <= math.pi * 2 then
							color1 = RdKGToolFtcv.ftcvVars.colors.side
							color2 = RdKGToolFtcv.ftcvVars.colors.front
							minRotation = math.pi * 1.5
							maxRotation = math.pi * 2
						elseif rotation > math.pi * 2 and rotation <= math.pi * 2.5 then
							color1 = RdKGToolFtcv.ftcvVars.colors.front
							color2 = RdKGToolFtcv.ftcvVars.colors.side
							minRotation = math.pi * 2
							maxRotation = math.pi * 2.5
						else
							color1 = RdKGToolFtcv.ftcvVars.colors.side
							color2 = RdKGToolFtcv.ftcvVars.colors.back
							minRotation = math.pi * 2.5
							maxRotation = math.pi * 3
						end

						local colorR = color1.r + (color2.r - color1.r) / (maxRotation - minRotation) * (rotation - minRotation)
						local colorG = color1.g + (color2.g - color1.g) / (maxRotation - minRotation) * (rotation - minRotation)
						local colorB = color1.b + (color2.b - color1.b) / (maxRotation - minRotation) * (rotation - minRotation)
						
						--d(colorR.. " ".. colorG.. " ".. colorB)
						RdKGToolFtcv.controls.reticle:SetColor(colorR, colorG, colorB, opacity)
						RdKGToolFtcv.controls.fixed:SetColor(colorR, colorG, colorB, opacity)
					elseif RdKGToolFtcv.ftcvVars.colorMode == RdKGToolFtcv.constants.color_modes.DISTANCE then
						local d = RdKGToolFtcv.ftcvVars.maxDistance - RdKGToolFtcv.ftcvVars.minDistance
						local colorR = RdKGToolFtcv.GetDistanceColorTone(RdKGToolFtcv.ftcvVars.colors.front.r, RdKGToolFtcv.ftcvVars.colors.back.r, distance)
						local colorG = RdKGToolFtcv.GetDistanceColorTone(RdKGToolFtcv.ftcvVars.colors.front.g, RdKGToolFtcv.ftcvVars.colors.back.g, distance)
						local colorB = RdKGToolFtcv.GetDistanceColorTone(RdKGToolFtcv.ftcvVars.colors.front.b, RdKGToolFtcv.ftcvVars.colors.back.b, distance)

						--d(colorR " " .. " ".. colorG.. " ".. colorB)
						RdKGToolFtcv.controls.reticle:SetColor(colorR, colorG, colorB, opacity)
						RdKGToolFtcv.controls.fixed:SetColor(colorR, colorG, colorB, opacity)

					end
					--d(RdKGToolFtcv.state.foreground)
					--foreground always == false?
					if RdKGToolFtcv.state.foreground == true then
						if RdKGToolFtcv.ftcvVars.mode == RdKGToolFtcv.constants.modes.RETICLE then
							RdKGToolFtcv.controls.TLW_Reticle:SetHidden(false)
						else
							RdKGToolFtcv.controls.TLW_Fixed:SetHidden(false)
						end
					end
					
				end
				return
			end
		end
	end
	
	RdKGToolFtcv.controls.TLW_Reticle:SetHidden(true)
	RdKGToolFtcv.controls.TLW_Fixed:SetHidden(true)
end


--menu interaction
function RdKGToolFtcv.GetMenu()
	local menu = {
	[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.FTCV_HEADER,
			--width = "full",
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCV_ENABLED,
					getFunc = RdKGToolFtcv.GetFtcvEnabled,
					setFunc = RdKGToolFtcv.SetFtcvEnabled,
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCV_PVP_ONLY,
					getFunc = RdKGToolFtcv.GetFtcvPvpOnly,
					setFunc = RdKGToolFtcv.SetFtcvPvpOnly
				},
				[3] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.FTCV_MODE,
					choices = RdKGToolFtcv.GetFtcvAvailableModes(),
					getFunc = RdKGToolFtcv.GetFtcvSelectedMode,
					setFunc = RdKGToolFtcv.SetFtcvSelectedMode,
					width = "full"
				},
				[4] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.FTCV_COLOR_MODE,
					choices = RdKGToolFtcv.GetFtcvAvailableColorModes(),
					getFunc = RdKGToolFtcv.GetFtcvSelectedColorMode,
					setFunc = RdKGToolFtcv.SetFtcvSelectedColorMode,
					width = "full"
				},
				[5] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.FTCV_TEXTURES,
					choices = RdKGToolFtcv.GetFtcvAvailableTextures(),
					getFunc = RdKGToolFtcv.GetFtcvSelectedTexture,
					setFunc = RdKGToolFtcv.SetFtcvSelectedTexture,
					width = "full"
				},
				[6] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.FTCV_COLOR_FRONT,
					getFunc = RdKGToolFtcv.GetFtcvFrontColor,
					setFunc = RdKGToolFtcv.SetFtcvFrontColor,
					width = "full"
				},
				[7] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.FTCV_COLOR_SIDE,
					getFunc = RdKGToolFtcv.GetFtcvSideColor,
					setFunc = RdKGToolFtcv.SetFtcvSidetColor,
					width = "full"
				},
				[8] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.FTCV_COLOR_BACK,
					getFunc = RdKGToolFtcv.GetFtcvBackColor,
					setFunc = RdKGToolFtcv.SetFtcvBackColor,
					width = "full"
				},
				[9] =
				{
					type = "slider",
					name = RdKGToolMenu.constants.FTCV_OPACITY_CLOSE,
					min = 1,
					max = 100,
					step = 1,
					getFunc = RdKGToolFtcv.GetFtcvOpacityClose,
					setFunc = RdKGToolFtcv.SetFtcvOpacityClose,
					width = "full",
					default = 50
				},
				[10] =
				{
					type = "slider",
					name = RdKGToolMenu.constants.FTCV_OPACITY_FAR,
					min = 1,
					max = 100,
					step = 1,
					getFunc = RdKGToolFtcv.GetFtcvOpacityFar,
					setFunc = RdKGToolFtcv.SetFtcvOpacityFar,
					width = "full",
					default = 100
				},
				[11] =
				{
					type = "slider",
					name = RdKGToolMenu.constants.FTCV_SIZE_CLOSE,
					min = 1,
					max = 100,
					step = 1,
					getFunc = RdKGToolFtcv.GetFtcvSizeClose,
					setFunc = RdKGToolFtcv.SetFtcvSizeClose,
					width = "full",
					default = 50
				},
				[12] =
				{
					type = "slider",
					name = RdKGToolMenu.constants.FTCV_SIZE_FAR,
					min = 1,
					max = 100,
					step = 1,
					getFunc = RdKGToolFtcv.GetFtcvSizeFar,
					setFunc = RdKGToolFtcv.SetFtcvSizeFar,
					width = "full",
					default = 100
				},
				[13] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCV_POSITION,
					min = -250,
					max = 250,
					step = 1,
					getFunc = RdKGToolFtcv.GetFtcvPosition,
					setFunc = RdKGToolFtcv.SetFtcvPosition,
					width = "full",
					default = 65
				},
				[14] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCV_MAX_DISTANCE,
					min = 0,
					max = 25,
					step = 1,
					getFunc = RdKGToolFtcv.GetFtcvMaxDistance,
					setFunc = RdKGToolFtcv.SetFtcvMaxDistance,
					width = "full",
					default = 8
				},
				[15] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCV_MIN_DISTANCE ,
					min = 0,
					max = 5,
					step = 1,
					getFunc = RdKGToolFtcv.GetFtcvMinDistance,
					setFunc = RdKGToolFtcv.SetFtcvMinDistance,
					width = "full",
					default = 3
				}
			}
		}
	}
	return menu
end

function RdKGToolFtcv.GetFtcvEnabled()
	return RdKGToolFtcv.ftcvVars.enabled
end

function RdKGToolFtcv.SetFtcvEnabled(value)
	RdKGToolFtcv.SetEnabled(value)
end


function RdKGToolFtcv.GetFtcvSelectedMode()
	return RdKGToolFtcv.constants.MODES[RdKGToolFtcv.ftcvVars.mode]
end

function RdKGToolFtcv.SetFtcvSelectedMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolFtcv.constants.MODES do
			if RdKGToolFtcv.constants.MODES[i] == value then
				RdKGToolFtcv.ftcvVars.mode = i
				break
			end
		end
	end
end

function RdKGToolFtcv.GetFtcvAvailableModes()
	return {
		RdKGToolFtcv.constants.MODES[RdKGToolFtcv.constants.modes.RETICLE], 
		RdKGToolFtcv.constants.MODES[RdKGToolFtcv.constants.modes.FIXED]
	}
end

function RdKGToolFtcv.GetFtcvSelectedColorMode()
	return RdKGToolFtcv.constants.COLOR_MODES[RdKGToolFtcv.ftcvVars.colorMode]
end

function RdKGToolFtcv.SetFtcvSelectedColorMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolFtcv.constants.COLOR_MODES do
			if RdKGToolFtcv.constants.COLOR_MODES[i] == value then
				RdKGToolFtcv.ftcvVars.colorMode = i
				break
			end
		end
	end
end

function RdKGToolFtcv.GetFtcvAvailableColorModes()
	return {
		RdKGToolFtcv.constants.COLOR_MODES[RdKGToolFtcv.constants.color_modes.DISTANCE], 
		RdKGToolFtcv.constants.COLOR_MODES[RdKGToolFtcv.constants.color_modes.ORIENTATION]
	}
end

function RdKGToolFtcv.GetFtcvFrontColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolFtcv.ftcvVars.colors.front)
end

function RdKGToolFtcv.SetFtcvFrontColor(r, g, b)
	RdKGToolFtcv.ftcvVars.colors.front = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolFtcv.GetFtcvSideColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolFtcv.ftcvVars.colors.side)
end

function RdKGToolFtcv.SetFtcvSidetColor(r, g, b)
	RdKGToolFtcv.ftcvVars.colors.side = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolFtcv.GetFtcvBackColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolFtcv.ftcvVars.colors.back)
end

function RdKGToolFtcv.SetFtcvBackColor(r, g, b)
	RdKGToolFtcv.ftcvVars.colors.back = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolFtcv.GetFtcvSizeClose()
	return RdKGToolFtcv.ftcvVars.size.close
end

function RdKGToolFtcv.SetFtcvSizeClose(value)
	RdKGToolFtcv.ftcvVars.size.close = value
end

function RdKGToolFtcv.GetFtcvSizeFar()
	return RdKGToolFtcv.ftcvVars.size.far
end

function RdKGToolFtcv.SetFtcvSizeFar(value)
	RdKGToolFtcv.ftcvVars.size.far = value
end

function RdKGToolFtcv.GetFtcvOpacityClose()
	return RdKGToolFtcv.ftcvVars.opacity.close
end

function RdKGToolFtcv.SetFtcvOpacityClose(value)
	RdKGToolFtcv.ftcvVars.opacity.close = value
end

function RdKGToolFtcv.GetFtcvOpacityFar()
	return RdKGToolFtcv.ftcvVars.opacity.far
end

function RdKGToolFtcv.SetFtcvOpacityFar(value)
	RdKGToolFtcv.ftcvVars.opacity.far = value
end

function RdKGToolFtcv.GetFtcvPvpOnly()
	return RdKGToolFtcv.ftcvVars.pvponly
end

function RdKGToolFtcv.SetFtcvPvpOnly(value)
	RdKGToolFtcv.ftcvVars.pvponly = value
	RdKGToolFtcv.SetEnabled(RdKGToolFtcv.ftcvVars.enabled)
end

function RdKGToolFtcv.GetFtcvPosition()
	return RdKGToolFtcv.ftcvVars.position
end

function RdKGToolFtcv.SetFtcvPosition(value)
	if value ~= nil then
		RdKGToolFtcv.ftcvVars.position = value
		RdKGToolFtcv.controls.TLW_Fixed:ClearAnchors()
		RdKGToolFtcv.controls.TLW_Fixed:SetAnchor(CENTER, GuiRoot, CENTER, 0, value)
	end
end

function RdKGToolFtcv.GetFtcvMaxDistance()
	return RdKGToolFtcv.ftcvVars.maxDistance
end

function RdKGToolFtcv.SetFtcvMaxDistance(value)
	RdKGToolFtcv.ftcvVars.maxDistance = value
end

function RdKGToolFtcv.GetFtcvMinDistance()
	return RdKGToolFtcv.ftcvVars.minDistance
end

function RdKGToolFtcv.SetFtcvMinDistance(value)
	RdKGToolFtcv.ftcvVars.minDistance = value
end

function RdKGToolFtcv.GetFtcvAvailableTextures()
	local textures = {}
	for i = 1, #RdKGToolFtcv.textures do
		table.insert(textures, RdKGToolFtcv.textures[i].name)
	end
	return textures
end

function RdKGToolFtcv.GetFtcvSelectedTexture()
	return RdKGToolFtcv.textures[RdKGToolFtcv.ftcvVars.selectedTexture].name
end

function RdKGToolFtcv.SetFtcvSelectedTexture(value)
	if value ~= nil then
		for i = 1, #RdKGToolFtcv.textures do
			if RdKGToolFtcv.textures[i].name == value then
				RdKGToolFtcv.ftcvVars.selectedTexture = i
				
				break
			end
		end
		RdKGToolFtcv.UpdateTextures()
	end
end