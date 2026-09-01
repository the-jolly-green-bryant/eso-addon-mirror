MARK = MARK or {}
PreviewMarker = {}

-- PERFORMANCE: Localize globals used in the 50ms hot loop
local EM = EVENT_MANAGER
local getPlayerPos = GetUnitRawWorldPosition
local isAltDown = IsAltKeyDown
local isBlockActive = IsBlockActive
local isCapsLockOn = IsCapsLockOn
local m_sqrt = math.sqrt

function PreviewMarker.new(self, texture, dontplace, parent)
	local _, worldX, worldY, worldZ = getPlayerPos("player")
    local newmarker = {
		id = LibAkaUtils.uuid(),
		x = worldX,
		y = worldY,
		z = worldZ,
		texture = texture,
		icon = nil,
		dontplace = dontplace,
		parent = parent,
		distance = 0,
        -- PERFORMANCE FIX: Cache a single vector object to prevent creating 
        -- a new table every 50ms in the update loop.
        camVector = Vector:new(0, 0, 0) 
	}
    setmetatable(newmarker, self)
    self.__index = self
	newmarker:checkDistance()
	newmarker:bind()
    return newmarker
end

function PreviewMarker.show(self)
	if self.parent ~= nil then 
		self.parent:hide()
	end
    
    -- PERFORMANCE FIX: Do not destroy and recreate the OSI icon 20 times a second 
    -- if the position hasn't actually changed.
    if self.icon ~= nil and self.lastX == self.x and self.lastY == self.y and self.lastZ == self.z then
        return
    end

	if self.icon ~= nil then 
		self:hide()
	end
    
	if MARK.isPlacingAllowed(self.x, self.y, self.z) then
		self.icon = OSI.CreatePositionIcon(self.x, self.y, self.z, LibEmote.GetEmoteByIndex(self.texture).textures[1], 100, MARK.iconColor)
		if self.icon.myLabel ~= nil then
			self.icon.myLabel:SetText("")
		end
        
        -- Cache the last rendered position
        self.lastX = self.x
        self.lastY = self.y
        self.lastZ = self.z
	end
end

function PreviewMarker.hide(self)
	if self.icon == nil then return end
	OSI.DiscardPositionIcon(self.icon)
	self.icon = nil
    self.lastX = nil
    self.lastY = nil
    self.lastZ = nil
end

function PreviewMarker.checkDistance(self, camVector)
	if camVector == nil then
		local cx, cy, cz = LibAkaUtils.getCameraPositionWithOSI()
        self.camVector.x = cx
        self.camVector.y = cy
        self.camVector.z = cz
		camVector = self.camVector
	end
    
    -- PERFORMANCE FIX: Removed pcall from this hot path.
    if self.x and self.y and self.z then
	    self.distance = LibAkaUtils.getDistanceSquaredUnsafe(camVector.x, camVector.y, camVector.z, self.x, self.y, self.z)
    else
        self.distance = 0
    end
end

function PreviewMarker.bind(self)
	MarkerUIPlacement:SetHidden(false)
	EM:UnregisterForUpdate(MARK.name .. "3DPlace")
	EM:RegisterForUpdate(MARK.name .. "3DPlace", 50, function()
		self:update()
	end)
end

function PreviewMarker.update(self)
	if isAltDown() then
		self:unbind()
		return
	end
	if isBlockActive() then
		self:unbind()
		self:place()
		return
	end

	local cx, cy, cz = LibAkaUtils.getCameraPositionWithOSI()
    
    -- PERFORMANCE FIX: Reuse the cached vector object instead of creating a new one
    local camVector = self.camVector
    camVector.x = cx
    camVector.y = cy
    camVector.z = cz
    
	local pitch = LibAkaUtils.getCameraPitchWithOSI()
	local yaw = LibAkaUtils.getCameraYaw()
    
    local isCaps = isCapsLockOn()
    local distanceStr = ""

	if isCaps then
		local distance = m_sqrt(self.distance)
		local vector = LibAkaUtils.rotationsToPointInDistance(camVector, yaw, pitch, distance)
		self.x = vector.x
		self.y = vector.y
		self.z = vector.z
		self:show()
        
        -- PERFORMANCE FIX: Only update UI text if the formatted string actually changes
        distanceStr = LibAkaUtils.formatDistance(distance)
        if self.lastMode ~= "Spherical" or self.lastDistStr ~= distanceStr then
		    MarkerUIPlacementLabel:SetText("Mode: Spherical\n(Press CAPSLOCK to change mode)\nDistance: " .. distanceStr .. "\n>>BLOCK to place the Marker.<<\nPress ALT to cancel.")
            self.lastMode = "Spherical"
            self.lastDistStr = distanceStr
        end
	else
		local _, _, worldY, _ = getPlayerPos("player")
		local vector = LibAkaUtils.viewPointToTargetPointSameHeight(worldY, camVector, yaw, pitch)
		self.x = vector.x
		self.y = vector.y
		self.z = vector.z
		self:checkDistance(camVector)
		self:show()
        
		local distance = m_sqrt(self.distance)
        
        -- PERFORMANCE FIX: Only update UI text if the formatted string actually changes
        distanceStr = LibAkaUtils.formatDistance(distance)
        if self.lastMode ~= "Planar" or self.lastDistStr ~= distanceStr then
		    MarkerUIPlacementLabel:SetText("Mode: Planar\n(Press CAPSLOCK to change mode)\nDistance: " .. distanceStr .. "\n>>BLOCK to place the Marker.<<\nPress ALT to cancel.")
            self.lastMode = "Planar"
            self.lastDistStr = distanceStr
        end
	end
end

function PreviewMarker.unbind(self)
	EM:UnregisterForUpdate(MARK.name .. "3DPlace")
	MarkerUIPlacement:SetHidden(true)
	self:hide()
end

function PreviewMarker.place(self)
	if self.dontplace == nil then
		MARK.placeMarkerInProfile(self.x, self.y, self.z, nil, self.texture)
	else
		self.dontplace()
	end
end