local BlindRun = {}
local br = BlindRun

br.name = "BlindRun"

local ylookup = {}
local min = zo_min
local round = zo_round
local controlPool = ZO_ControlPool:New("BlindRunTemplate", BlindRunToplevel)
local redraw
local createStuff

local maxRenderDistance = 7

SLASH_COMMANDS['/setblindrenderdistance'] = function(x)
	if tonumber(x) then
		maxRenderDistance = tonumber(x)
		controlPool:ReleaseAllObjects()
		createStuff()
		redraw()
	end
end


local currentGridX = 0
local currentGridZ = 0


local function getYLoop()
	local zone, x,y,z = GetUnitRawWorldPosition('player')
	local gridX = round(x/250)*250
	local gridZ = round(z/250)*250

	if ylookup[gridX] then
		if ylookup[gridX][gridZ] then
			ylookup[gridX][gridZ] = min(ylookup[gridX][gridZ], y)
		else
			ylookup[gridX][gridZ] = y
		end
	else
		ylookup[gridX] = {
			[gridZ]=y
		}
	end
	
	if (gridX ~= currentGridX) or (gridZ ~= currentGridZ) then
		-- grid spot changed
		currentGridX = gridX
		currentGridZ = gridZ
		redraw()
	end


end


local controlLookup = {}

local ceil = zo_ceil

redraw = function()
	local minX = currentGridX-250*ceil(maxRenderDistance/2)
	local minZ = currentGridZ-250*ceil(maxRenderDistance/2)
	
	for i = 1, maxRenderDistance do
		local cx = minX+i*250
		for j = 1, maxRenderDistance do
			local cz = minZ+j*250
			if ylookup[cx] then
				local cy = ylookup[cx][cz]
				if cy then
					local x,y,z = WorldPositionToGuiRender3DPosition(cx, cy, cz)
					controlLookup[i][j]:SetTransformOffset(x,y,z)
					controlLookup[i][j]:SetHidden(false)
				else
					controlLookup[i][j]:SetHidden(true)
				end
			end
		end
	end
end



local neghalfpi = -math.pi/2

createStuff = function()
	for i = 1, maxRenderDistance do
		for j = 1, maxRenderDistance do
			local control, key = controlPool:AcquireObject()
			control:SetHidden(true)
			control:SetSpace(SPACE_WORLD)
			control:SetAnchor(CENTER,GuiRoot,CENTER)
			control:SetScale(1/100*0.25) -- 25cm
			control:SetTransformRotation(neghalfpi, 0, 0)
			control:SetTransformNormalizedOriginPoint(0.5,0.5)
			control.key = key
			if controlLookup[i] then
				controlLookup[i][j] = control
			else
				controlLookup[i] = {[j] = control}
			end
		end
	end
end


local groupMemberControlPool = ZO_ControlPool:New("BlindRunGroupMemberTemplate", BlindRunToplevel)

local groupLookup = {}

local function createGroupStuff()
	for i = 1, 12 do
		local control, key = groupMemberControlPool:AcquireObject()
		control:SetHidden(true)
		control:SetSpace(SPACE_WORLD)
		control:SetAnchor(CENTER,GuiRoot,CENTER)
		control:SetScale(1/100*2) -- 2m tall
		control:SetTransformNormalizedOriginPoint(0.5,0.5)
		control.key = key
		control.unitTag = string.format("group%d",i)
		control.nameplate = control:GetNamedChild("Text")
		groupLookup[control.unitTag] = control
	end
end


local negdoublepi = - 2 * math.pi

local function updateGroupPosition()
	local heading = GetPlayerCameraHeading()
	-- if heading > math.pi then 
	-- 	heading = heading + negdoublepi
	-- end
	for i,control in pairs(groupLookup) do
		local name = GetUnitDisplayName(i)
		if name and name ~= "" then
			local zone, cx, cy, cz = GetUnitRawWorldPosition(i)
			local x,y,z = WorldPositionToGuiRender3DPosition(cx, cy+100, cz)
			control:SetTransformOffset(x,y,z)
			control:SetTransformRotation(0, heading, 0)
			if not AreUnitsEqual(i, 'player') then
				control.nameplate:SetText(name)
			else
				control.nameplate:SetText("")
			end
			control:SetHidden(false)
		else
			control:SetHidden(true)
		end
	end


	--self:Set3DRenderSpaceOrientation(0, heading, 0)
end



local function hideEverythingCreatedByTheAddonWhileShowingEverythingCreatedByZos()
	for i = 1, maxRenderDistance do
		for j = 1, maxRenderDistance do
			if controlLookup[i] and controlLookup[i][j] then
				controlLookup[i][j]:SetHidden(true)
			end
		end
	end


end

local function hideGroupMembersCreatedByTheAddonWhileShowingThemCreatedByZos()
	for i,v in pairs(groupLookup) do
		v:SetHidden(true)
	end
end


local shouldDrawMembers = true
local currentlyDrawing = false
local function toggleDrawingMembers()
	if shouldDrawMembers then
		shouldDrawMembers = false
		EVENT_MANAGER:UnregisterForUpdate("BlindRunGroupLoop")
		hideGroupMembersCreatedByTheAddonWhileShowingThemCreatedByZos()
		d("You will no longer see stick figures where people are located.")
	else
		shouldDrawMembers = true
		if not currentlyDrawing then
			EVENT_MANAGER:RegisterForUpdate("BlindRunGroupLoop", 0, updateGroupPosition)
		end
		d("You will now see stick figures where people are located.")
	end
end

SLASH_COMMANDS['/togglestickvision'] = toggleDrawingMembers



function br.startRun()
	SetShouldRenderWorld(false)

	if #controlLookup == 0 then
		createStuff()
	end
	redraw()
	EVENT_MANAGER:RegisterForUpdate("BlindRunLoop", 100, getYLoop)

	if #groupLookup == 0 then
		createGroupStuff()
	end
	if shouldDrawMembers then
		EVENT_MANAGER:RegisterForUpdate("BlindRunGroupLoop", 0, updateGroupPosition)
		currentlyDrawing = true
	end

end

SLASH_COMMANDS['/goblind'] = br.startRun

function br.stopRun()
	currentlyDrawing = false
	SetShouldRenderWorld(true)
	EVENT_MANAGER:UnregisterForUpdate("BlindRunLoop")
	EVENT_MANAGER:UnregisterForUpdate("BlindRunGroupLoop")
	hideEverythingCreatedByTheAddonWhileShowingEverythingCreatedByZos()
	hideGroupMembersCreatedByTheAddonWhileShowingThemCreatedByZos()
end

SLASH_COMMANDS['/cureblindness'] = br.stopRun
