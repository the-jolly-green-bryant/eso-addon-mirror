MARK = MARK or {}
Marker = {}

local SHARED_MARKER = "(%d+)/([^/]+)/(%d+)/(%d+)/(%d+)/(%d+)/(%d+)"

-- PERFORMANCE: Localize global functions heavily used in this class
local t_tonumber = tonumber
local t_tostring = tostring
local t_type = type
local s_gmatch = string.gmatch
local s_match = string.match

function Marker.new(self, data)
	if data == nil then
		data = {
			id = LibAkaUtils.uuid(),
			x = 0,
			y = 0,
			z = 0,
			texture = 0,
			size = 0,
			requirement = nil,
		}
	end
    local newmarker = {
		data = data,
		reqFunc = nil
	}
	newmarker.icon = nil
	newmarker.icons = nil
    setmetatable(newmarker, self)
    self.__index = self
	newmarker:loadFunc()
    return newmarker
end

function Marker.loadFunc(self)
	if self.data.requirement ~= nil and self.data.requirement ~= "" then
		-- PERFORMANCE FIX: zo_loadstring natively returns `nil, err` if it fails.
		-- Using pcall here was expensive and entirely redundant.
		local func, err = zo_loadstring(self.data.requirement)
		if type(func) == "function" then
			self.reqFunc = func
		else
			self.reqFunc = nil
		end
	else
		self.reqFunc = nil
	end
end

function Marker.show(self, sizeChange, circle)
	local size = self.data.size or MARK.fallbackSize
	if self.type == 1 then
		size = sizeChange or 100
	end
	
	if self.icon ~= nil then 
		if (self.icon.data or {}).size ~= size then self:hide() end
		if self:isIconActive() == true then return end
		self:hide()
	end
	
	if self.icons ~= nil then 
		if self:isIconActive() == true then return end
		self:hide()
	end
	
	local texStr = t_tostring(self.data.texture)
	if texStr == "15071" or circle == true then
		self:circleMarker()
		return
	end
	
	if texStr ~= "15071" then
		if MARK.isPlacingAllowed(self.data.x, self.data.y, self.data.z, self.data.id) then
			MARK.setPlacingPosition(self.data.x, self.data.y, self.data.z, self.data.id)
			
			local tex = LibEmote.GetEmoteByIndex(self.data.texture):getTexture()
			local actualSize = size * ((MARK.savedVars.iconsizemultiplier or 100) / 100)
			
			self.icon = OSI.CreatePositionIcon(self.data.x, self.data.y, self.data.z, tex, actualSize, MARK.iconColor)
			if self.icon.myLabel ~= nil then
				self.icon.myLabel:SetText("")
			end
		end
	end
end

function Marker.fromString(self, str, onlyText)
	local profile = MARK.loadedProfile
	if profile == nil then return "No Profile selected" end
	local marker
	local match = s_match(str, SHARED_MARKER)
	
	if match ~= nil then
		for zone, id, x, y, z, s, t in s_gmatch(str, SHARED_MARKER) do
			zone = t_tonumber(zone)
			id = t_tostring(id)
			x = t_tonumber(x)
			y = t_tonumber(y)
			z = t_tonumber(z)
			s = t_tonumber(s)
			t = t_tonumber(t)
			
			if zone and id and x and y and z and s and t then
				if profile.data.zone ~= zone then
					return "This Marker is for a different zone"
				end
				local existingId = MARK.getPlacedMarkerAt(x, y, z)
				marker = {
					id = existingId or id,
					x = x,
					y = y,
					z = z,
					texture = t_tostring(t),
					size = s
				}
			end
		end
	else
		-- Note: pcall is left here since decode libraries might throw hard errors on bad input, 
		-- and this is only executed manually on chat interactions (not a hot-path).
		local decoded = {}
		if pcall(function() decoded = LibBase64.decode(str) end) then
			if pcall(function() decoded = LibJson.decode(decoded) end) then
				local zone = t_tonumber(decoded.zone or 0)
				if zone == nil or zone ~= profile.data.zone then
					return "This Marker is for a different zone"
				end
				decoded.icon = nil
				decoded.icons = nil
				local existingId = MARK.getPlacedMarkerAt(decoded.x, decoded.y, decoded.z)
				decoded.id = existingId or decoded.id
				marker = decoded
			end
		end
	end
	
	if marker ~= nil then
		if onlyText == true then
			return "Zone: " .. profile.data.zone .. ", x: " .. marker.x .. ", y: " .. marker.y .. ", z: " .. marker.z
		end
		profile:setMarker(marker)
		profile:dataUpdate()
		profile:load()
		return "Marker placed"
	else
		return "This is not a valid Marker"
	end
end

function Marker.toString(self, zone)
	-- PERFORMANCE FIX: Shallow copy is much faster than full recursive deep copy.
	local data = {}
	for k, v in pairs(self.data) do
		data[k] = v
	end
	
	data.zone = zone
	data.requirement = nil
	local out = LibJson.encode(data)
	out = LibBase64.encode(out)
	return MARK.messagePrefix .. t_tostring(out)
end

function Marker.isIconActive(self)
	if self.icon == nil and self.icons == nil then return end
	
	if self.data.texture == MARK.circlePath or self.icons ~= nil then
		-- PERFORMANCE FIX: Replaced pairs with numeric for-loop. Array iteration is faster.
		for i = 1, #self.icons do
			if self.icons[i].use == false then return false end
		end
		return true
	else
		return self.icon.use
	end
end

function Marker.hide(self)
	if self.icon == nil and self.icons == nil then return end
	if self.icons ~= nil then
		self:removeCircleMarker()
	end
	if self.icon ~= nil then
		OSI.DiscardPositionIcon(self.icon)
		MARK.setPlacingPosition(self.data.x, self.data.y, self.data.z, nil)
	end
	self:unmark()
	self.icon = nil
	self.icons = nil
end

function Marker.edit(self, data)
	self:hide()
	if data.x ~= nil then self.data.x = data.x end
	if data.y ~= nil then self.data.y = data.y end
	if data.z ~= nil then self.data.z = data.z end
	if data.size ~= nil then self.data.size = data.size end
	if data.texture ~= nil then self.data.texture = data.texture end
	if data.requirement ~= nil then 
		self.data.requirement = data.requirement
		self:loadFunc()
	end
	self:unmark()
end

function Marker.createGroundControl(self)
	local control, key = MARK.controlPool:AcquireObject()
	control:SetHidden(false)
	control:SetSpace(SPACE_WORLD)
	control:SetAnchor(CENTER,GuiRoot,CENTER)
	control:SetScale(1/100)
	control.bgLayer = control:GetNamedChild("Background")
	control:SetTransformNormalizedOriginPoint(0.5,0.5)

	control:SetTransformScale(self.data.size/50)
	control:SetTransformRotation(math.pi/2, 0, 0)
	local x,y,z = WorldPositionToGuiRender3DPosition(self.data.x, self.data.y, self.data.z)
	control:SetTransformOffset(x,y,z)

	local icon = {}

	icon.control = control
	icon.key = key
	icon.type = "GC"
	icon.control.bgLayer:SetHidden(false)

	local texture = LibEmote.GetEmoteByIndex(self.data.texture)
	if texture.reference ~= "" then
		texture = LibEmote.GetEmoteByIndex(texture.reference)
	end

	icon.control.bgLayer:SetTexture(texture:getTexture())
	local width = 100*(icon.control.bgLayer:GetTextureFileDimensions() or 1)
	icon.control.bgLayer:SetScale(width)
	icon.control.bgLayer:SetTransformScale(1/width)

	self.icons = icon
	return icon
end

function Marker.removeGroundControl(self)
	if self.icons == nil then return end
	if self.icons.type ~= "GC" then return end
	self.icons.control:SetHidden(true)
	self.icons.control.bgLayer:SetHidden(true)
	MARK.controlPool:ReleaseObject(self.icons.key)
	self.icons = nil
end

function Marker.circleMarker(self)
	if true then
		return self:createGroundControl()
	end
	--[[local size = self.data.size
	local circle = LibAkaUtils.getCircleCoordinates(self.data.x, self.data.y, self.data.z, size, 50)
	local circleSize = 100 * ((MARK.savedVars.iconsizemultiplier or 100) / 100)
	self.icons = {}
	
	-- PERFORMANCE FIX: Hoist static lookups out of the loop
	local id = self.data.id
	local tex = LibEmote.GetEmoteByIndex(MARK.circlePath).textures[1]
	local color = MARK.iconColor
	
	-- PERFORMANCE FIX: Replaced table.foreachi (which creates an anonymous closure every frame)
	-- with a highly optimized numeric for-loop.
	for i = 1, #circle do
		local v = circle[i]
		if MARK.isPlacingAllowed(v.x, v.y, v.z, id) then
			MARK.setPlacingPosition(v.x, v.y, v.z, id)
			local icon = OSI.CreatePositionIcon(v.x, v.y, v.z, tex, circleSize, color)
			if icon.myLabel ~= nil then
				icon.myLabel:SetText("")
			end
			self.icons[#self.icons + 1] = icon
		end
	end--]]
end

function Marker.removeCircleMarker(self)
	if true then
		return self:removeGroundControl()
	end--[[



	if not self.icons then return end
	
	-- PERFORMANCE FIX: Replaced table.foreachi to stop memory/closure leaks.
	for i = 1, #self.icons do
		local v = self.icons[i]
		OSI.DiscardPositionIcon(v)
		MARK.setPlacingPosition(v.x, v.y, v.z, nil)
	end
	self.icons = nil--]]
end

function Marker.checkDistance(self, worldX, worldY, worldZ, radius)
	if self.temp ~= nil then return end
	
	-- PERFORMANCE FIX: Removed pcall entirely from this HOT PATH.
	-- `getDistanceSquaredUnsafe` expects numbers. We ensure data.x/y/z exist to prevent crashes.
	if not self.data.x or not self.data.y or not self.data.z then
		self:hide()
		return
	end
	
	local distance = LibAkaUtils.getDistanceSquaredUnsafe(worldX, worldY, worldZ, self.data.x, self.data.y, self.data.z)
	self.distance = distance
	
	if t_type(self.reqFunc) == "function" then
		if self.reqFunc() == false then
			self:hide()
			return 
		end
	end
	
    if distance < radius then
		self:show()
	else
		self:hide()
	end
end

function Marker.toggle(self)
	if self.temp ~= nil then 
		self:unmark()
	else
		self:mark()
	end
end

function Marker.isMarked(self)
	return self.temp ~= nil
end

function Marker.mark(self)
	if self:isMarked() == true then return end
	self:show()
	self.temp = OSI.CreatePositionIcon(self.data.x, self.data.y + 100, self.data.z, "OdySupportIcons/icons/green_arrow.dds", 100, MARK.iconColor)
end

function Marker.unmark(self)
	if self:isMarked() == false then return end
	OSI.DiscardPositionIcon(self.temp)
	self.temp = nil
end

function Marker.getData(self)
	-- PERFORMANCE FIX: Shallow copy is enough for flat tables
	local data = {}
	for k, v in pairs(self.data) do
		data[k] = v
	end
    return data
end