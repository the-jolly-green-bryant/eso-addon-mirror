
local TileDisplay = {}
TrueExplor = TrueExplor or {}
TrueExplor.tileDisplay = TileDisplay

local TrueExplor = TrueExplor
local zo_floor = zo_floor
local PI = math.pi

function TileDisplay:Initialize(container, radius)
	self.total_units = TrueExplor.total_units
	self.parent = container:CreateControl(nil, CT_CONTROL)
	local composite = self.parent:CreateControl(nil, CT_TEXTURECOMPOSITE)
	composite:SetDrawLevel(2)
	composite:SetPixelRoundingEnabled(false)
	composite:SetTexture("EsoUI/Art/WorldMap/worldmap_map_background_512tile.dds")
	for y = 0, self.total_units - 1 do
		for x = 0, self.total_units - 1 do
			composite:AddSurface(
				x / self.total_units,
				(x+1) / self.total_units,
				y / self.total_units,
				(y+1) / self.total_units)
		end
	end
	self.composite = composite
	self.container = container
	self.hideAllControl = CreateControlFromVirtual(nil, container, "TE_MapTile")
	self.hideAllControl:SetHidden(true)
	self.controls = {}
	self.lastUnused = 0
	self.unusedControls = {}
	self.radius = radius
	
	self:SetContainer(container)
end

function TileDisplay:HideControl(x, y)
	local unit = x + y * self.total_units
	local control = self.controls[unit]
	if not control then return end
	
	local lastUnused = self.lastUnused + 1
	self.unusedControls[lastUnused] = control
	self.controls[unit] = nil
	control:SetHidden(true)
end

function TileDisplay:GetControl(x, y)
	local unit = x + y * self.total_units
	local control = self.controls[unit]
	if control then return control end
	
	if self.lastUnused > 0 then
		control = self.unusedControls[self.lastUnused]
		self.lastUnused = self.lastUnused - 1
	else
		control = CreateControlFromVirtual(nil, self.parent, "TE_MapTile")
		control:SetPixelRoundingEnabled(false)
	end
	control:SetTextureCoords(
		x / self.total_units,
		(x+1) / self.total_units,
		y / self.total_units,
		(y+1) / self.total_units)
	local container = self.container
	local width, height = self.hideAllControl:GetDimensions()
	local controlWidth = width / self.total_units
	local controlHeight = height / self.total_units
	control:SetAnchor(CENTER, container, TOPLEFT, x * controlWidth, y * controlHeight)
	control:SetDimensions(controlWidth, controlHeight)
	control:SetHidden(false)
	self.controls[unit] = control
	return control
end

function TileDisplay:SetDiscoveryData(discoveryData)
	self.discoveryData = discoveryData
	--self:Refresh()
end

function TileDisplay:SetRadius(radius)
	self.radius = radius
	--self:Refresh()
end

function TileDisplay:SetContainer(container, width, height)
	self.parent:SetParent(container)
	self.composite:SetAnchor(CENTER, container, TOPLEFT, 0, 0)
	self.hideAllControl:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
	self.container = container
	self:UpdateSize()
end

function TileDisplay:UpdateSize(width, height)
	local container = self.container
	if not (width and height) then
		width, height = container:GetDimensions()
	end
	local oldW, oldH = self.hideAllControl:GetDimensions()
	if oldW == width and oldH == height then return end
	
	self.hideAllControl:SetDimensions(width, height)
	local controlWidth = width / self.total_units
	local controlHeight = height / self.total_units
	local x, y
	for index, control in pairs(self.controls) do
		x = index % self.total_units
		y = zo_floor(index / self.total_units)
		control:SetAnchor(CENTER, container, TOPLEFT, x * controlWidth, y * controlHeight)
		control:SetDimensions(controlWidth, controlHeight)
	end
	local index = 0
	local yHeight
	local composite = self.composite
	for y = 0, self.total_units - 1 do
		yHeight = y * controlHeight
		for x = 0, TrueExplor.total_units - 1 do
			index = index + 1 --x + y * TrueExplor.total_units
			composite:SetInsets(index,
				x * controlWidth, x * controlWidth, yHeight, yHeight)
		end
	end
	composite:SetDimensions(controlWidth, controlHeight)
end

function TileDisplay:RemoveAllControls()
	local lastUnused = self.lastUnused
	for _, control in pairs(self.controls) do
		control:SetHidden(true)
		lastUnused = lastUnused + 1
		self.unusedControls[lastUnused] = control
	end
	self.lastUnused = lastUnused
	ZO_ClearTable(self.controls)
end

function TileDisplay:OnDiscoveryStatusChanged(unitX, unitY)
	local discoveryData = self.discoveryData
	if discoveryData:IsCompletelyDiscovered() then
		return
	end
	local index, anyDiscovered, allDiscovered, control
	local composite = self.composite
	local topRow = {}
	local currentRow = {}
	local radius = self.radius
	local discoveredColor = self.discoveredColor
	local undiscoveredColor = self.undiscoveredColor
	
	local startX = zo_max(0, unitX - self.radius)
	local endX = zo_min(self.total_units-1, unitX + self.radius + 1)
	
	if unitY - self.radius - 1 >= 0 then
		local y = unitY - self.radius - 1
		for x = startX - 1, endX do
			index = x + y * self.total_units
			topRow[x] = discoveryData:IsAnyDiscoveredInRadius(x, y, radius)
		end
	end
	
	for y = zo_max(0, unitY - self.radius), zo_min(self.total_units-1, unitY + self.radius + 1) do
		
		currentRow[startX - 1] = discoveryData:IsAnyDiscoveredInRadius(startX - 1, y, radius)
		for x = startX, endX do
			index = x + y * self.total_units
			currentRow[x] = discoveryData:IsAnyDiscoveredInRadius(x, y, radius)
			anyDiscovered = currentRow[x] or currentRow[x-1] or topRow[x] or topRow[x-1]
			allDiscovered = currentRow[x] and currentRow[x-1] and topRow[x] and topRow[x-1]
			if anyDiscovered and not allDiscovered then
				composite:SetSurfaceHidden(index + 1, true)
				control = self:GetControl(x, y)
				self:RefreshControlForDiscoveryStatus(control, currentRow[x], currentRow[x-1], topRow[x], topRow[x-1])
			else
				composite:SetSurfaceHidden(index + 1, false)
				self:HideControl(x, y)
				composite:SetColor(index + 1, unpack((allDiscovered and discoveredColor) or undiscoveredColor))
			end
		end
		topRow, currentRow = currentRow, topRow
	end
end

--[[
function TileDisplay:Refresh2()
	self:RemoveAllControls()
	if not self.discoveryData or self.discoveryData:IsCompletelyDiscovered() then 
		self:HideTiles()
		return
	end
	self.parent:SetHidden(false)
	local discoveredColor = self.discoveredColor
	local undiscoveredColor = self.undiscoveredColor
	local discoveryData = self.discoveryData
	local index, anyDiscovered, allDiscovered, control
	local composite = self.composite
	local topRow = {}
	local currentRow = {}
	local radius = self.radius
	local IsAnyDiscoveredInRadius = discoveryData.IsAnyDiscoveredInRadius
	for y = 0, self.total_units - 1 do
		for x = 0, self.total_units - 1 do
			index = x + y * self.total_units
			currentRow[x] = IsAnyDiscoveredInRadius(discoveryData, x, y, radius)
			anyDiscovered = currentRow[x] or currentRow[x-1] or topRow[x] or topRow[x-1]
			allDiscovered = currentRow[x] and currentRow[x-1] and topRow[x] and topRow[x-1]
			if anyDiscovered and not allDiscovered then
				composite:SetSurfaceHidden(index + 1, true)
				control = self:GetControl(x, y)
				self:RefreshControlForDiscoveryStatus(control, currentRow[x], currentRow[x-1], topRow[x], topRow[x-1])
			else
				composite:SetSurfaceHidden(index + 1, false)
				composite:SetColor(index + 1, unpack((allDiscovered and discoveredColor) or undiscoveredColor))
			end
		end
		topRow, currentRow = currentRow, topRow
	end
end]]--

function TileDisplay:Refresh()
	self:RemoveAllControls()
	if not self.discoveryData or self.discoveryData:IsCompletelyDiscovered() then 
		self:HideTiles()
		return
	end
	self.parent:SetHidden(false)
	local discoveredColor = self.discoveredColor
	local undiscoveredColor = self.undiscoveredColor
	local anyDiscovered, allDiscovered, control
	local composite = self.composite
	local index = 0
	local topRow = {}
	local currentRow = {}
	local total_units = self.total_units
	self:FillTableWithNumDiscoveriesInRow(topRow, -1)
	
	local currentRow = {}
	for y = 0, total_units - 1 do
		self:FillTableWithNumDiscoveriesInRow(currentRow, y)
		for x = 0, total_units - 1 do
			index = index + 1
			assert(currentRow[x]>=0)
			-- using boolean algebra: + is OR, * is AND
			-- we're asking if any of the 4 adjacent tiles has a discovery
			anyDiscovered = (currentRow[x] + currentRow[x-1] + topRow[x] + topRow[x-1]) ~= 0
			-- we're asking if all of the 4 adjacent tiles has a discovery
			allDiscovered = (currentRow[x] * currentRow[x-1] * topRow[x] * topRow[x-1]) ~= 0
			if anyDiscovered and not allDiscovered then
				composite:SetSurfaceHidden(index, true)
				control = self:GetControl(x, y)
				self:RefreshControlForDiscoveryStatus(control, 
					currentRow[x] ~= 0, currentRow[x-1] ~= 0, topRow[x] ~= 0, topRow[x-1] ~= 0)
			else
				composite:SetSurfaceHidden(index, false)
				composite:SetColor(index, unpack((allDiscovered and discoveredColor) or undiscoveredColor))
			end
		end
		topRow, currentRow = currentRow, topRow
	end
end

function TileDisplay:FillTableWithNumDiscoveriesInRow(tbl, y)
	local discoveryData = self.discoveryData
	local radius = self.radius
	if radius > 1 then
		radius = radius - 1
		local AnyDiscoveredInVerticalLine = discoveryData.AnyDiscoveredInVerticalLine
		tbl[-1] = 0
		for x = 0, radius-1 do
			tbl[-1] = tbl[-1] + AnyDiscoveredInVerticalLine(discoveryData, x, y, radius)
		end
		for x = 0, self.total_units - 1 do 
			tbl[x] = tbl[x-1] - AnyDiscoveredInVerticalLine(discoveryData, x-1-radius, y, radius) + AnyDiscoveredInVerticalLine(discoveryData, x+radius, y, radius)
		end
	else
		local IsAnyDiscoveredInRadius = discoveryData.IsAnyDiscoveredInRadius
		for x = -1, self.total_units - 1 do 
			tbl[x] = IsAnyDiscoveredInRadius(discoveryData, x, y, radius) and 1 or 0
		end
	end
end

function TileDisplay:RefreshControlForDiscoveryStatus(control, center, left, top, topleft)
	local discoveredColor = self.discoveredColor
	local hiddenColor = self.undiscoveredColor
	if (left and not top) or (top and not left) or (center and topleft) then
		control:SetTextureRotation(PI/2)
		control:SetVertexColors(VERTEX_POINTS_BOTTOMLEFT,--VERTEX_POINTS_BOTTOMRIGHT, --1, 0, 0, 1)
			unpack(center and discoveredColor or hiddenColor))
		-- color of the tile's neigbors for gradient effect
		control:SetVertexColors(VERTEX_POINTS_TOPLEFT,--VERTEX_POINTS_BOTTOMLEFT,
			unpack(left and discoveredColor or hiddenColor))
		control:SetVertexColors(VERTEX_POINTS_TOPRIGHT,--VERTEX_POINTS_TOPRIGHT,
			unpack(topleft and discoveredColor or hiddenColor))
		control:SetVertexColors(VERTEX_POINTS_BOTTOMRIGHT,--VERTEX_POINTS_TOPLEFT,
			unpack(top and discoveredColor or hiddenColor))
	else
		control:SetTextureRotation(0)
		control:SetVertexColors(VERTEX_POINTS_BOTTOMRIGHT, --1, 0, 0, 1)
			unpack(center and discoveredColor or hiddenColor))
		-- color of the tile's neigbors for gradient effect
		control:SetVertexColors(VERTEX_POINTS_BOTTOMLEFT,
			unpack(left and discoveredColor or hiddenColor))
		control:SetVertexColors(VERTEX_POINTS_TOPLEFT,
			unpack(topleft and discoveredColor or hiddenColor))
		control:SetVertexColors(VERTEX_POINTS_TOPRIGHT,
			unpack(top and discoveredColor or hiddenColor))
	end
end

function TileDisplay:SetColors(discoveredColor, undiscoveredColor)
	self.discoveredColor = discoveredColor
	self.undiscoveredColor = undiscoveredColor
	--self.hiddenColor:SetColor(unpack(undiscoveredColor))
	--self:Refresh()
end

-- set all tiles as hidden (so the entire map becomes visible)
function TileDisplay:HideTiles()
	self.parent:SetHidden(true)
	self.hideAllControl:SetHidden(true)
end
