
local GPS = LibStub("LibGPS2")

Example = {}

local PATH = "Lib3D/example"

local light, frame, center

function Example.OnAddOnLoaded(_, addonName)
	if addonName ~= "Lib3D" then return end
	-- turn the top level control into a 3d control
	MageLight_TopLevel:Create3DRenderSpace()
	
	-- make sure the control is only shown, when the player can see the world
	-- i.e. the control is only shown during non-menu scenes
	local fragment = ZO_SimpleSceneFragment:New(MageLight_TopLevel)
	HUD_UI_SCENE:AddFragment(fragment)
	HUD_SCENE:AddFragment(fragment)
	LOOT_SCENE:AddFragment(fragment)
	
	-- register a callback, so we know when to start/stop displaying the mage light
	Lib3D:RegisterWorldChangeCallback("MageLight", function(identifier, zoneIndex, isValidZone, newZone)
		if not newZone then return end
		
		if isValidZone then
			Example.ShowMageLight()
		else
			Example.HideMageLight()
		end
	end)
	
	-- create the mage light
	-- we have one parent control (light) which we will move around the player
	-- and two child controls for the light's center and a periodically pulsing sphere
	light = WINDOW_MANAGER:CreateControl(nil, MageLight_TopLevel, CT_CONTROL)
	center = WINDOW_MANAGER:CreateControl(nil, light, CT_TEXTURE)
	frame = WINDOW_MANAGER:CreateControl(nil, light, CT_TEXTURE)
	
	-- make the control 3 dimensional
	light:Create3DRenderSpace()
	frame:Create3DRenderSpace()
	center:Create3DRenderSpace()
	
	-- set texture, size and enable the depth buffer so the mage light is hidden behind world objects
	center:SetTexture(PATH .. "/sphere.dds")
	center:Set3DLocalDimensions(0.5, 0.5)
	center:Set3DRenderSpaceUsesDepthBuffer(true)
	center:Set3DRenderSpaceOrigin(0,0,0.1)
	
	frame:SetTexture(PATH .. "/circle.dds")
	frame:Set3DLocalDimensions(0.5, 0.5)
	frame:Set3DRenderSpaceOrigin(0,0,0)
	frame:Set3DRenderSpaceUsesDepthBuffer(true)
	
end

function Example.ShowMageLight()
	light:SetHidden(false)
	frame:SetHidden(false)
	center:SetHidden(false)
	
	EVENT_MANAGER:UnregisterForUpdate("MageLight")
	-- perform the following every single frame
	EVENT_MANAGER:RegisterForUpdate("MageLight", 0, function(time)
		
		local x, y, z, forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ = Lib3D:GetCameraRenderSpace()
		
		-- align our mage light with the camera's render space so the light is always facing the camera
		light:Set3DRenderSpaceForward(forwardX, forwardY, forwardZ)
		light:Set3DRenderSpaceRight(rightX, rightY, rightZ)
		light:Set3DRenderSpaceUp(upX, upY, upZ)
		
		-- get the player position, so we can place the mage light nearby
		local worldX, worldY, worldZ = Lib3D:ComputePlayerRenderSpacePosition()
		if not worldX then return end
		-- this creates the circeling motion around the player
		local time = GetFrameTimeSeconds()
		worldX = worldX + math.sin(time)
		worldZ = worldZ + math.cos(time)
		worldY = worldY - 0.75 + 0.5 * math.sin(0.5 * time)
		MageLight_TopLevel:Set3DRenderSpaceOrigin(worldX, worldY, worldZ)
		
		-- add a pulsing animation
		center:SetAlpha(math.sin(2 * time) * 0.25 + 0.75)
		frame:Set3DLocalDimensions(time % 1, time % 1)
		frame:SetAlpha(1 - (time % 1))
		
	end)
end

function Example.HideMageLight()
	-- remove the on update handler and hide the mage light
	EVENT_MANAGER:UnregisterForUpdate("MageLight")
	light:SetHidden(true)
	frame:SetHidden(true)
	center:SetHidden(true)
end

EVENT_MANAGER:RegisterForEvent("MageLight", EVENT_ADD_ON_LOADED, Example.OnAddOnLoaded)
