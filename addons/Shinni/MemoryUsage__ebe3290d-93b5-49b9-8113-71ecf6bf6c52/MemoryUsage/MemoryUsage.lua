
MemoryUsage = {}

function MemoryUsage.NextMeasurement()
	local self = MemoryUsage
	
	self.measurements.current = (self.measurements.current-1) % (self.numSegments + 1)
	self.measurements[self.measurements.current] = GetTotalUserAddOnMemoryPoolUsageMB()
	self:UpdateControls()
	--d(self.measurements.current)
end

function MemoryUsage:UpdateControls()
	local current = self.measurements.current
	local numSegments = self.numSegments
	local measurements = self.measurements
	for i, line in pairs(self.segments) do
		local index = (current + i - 1) % (numSegments + 1)
		line:SetAnchor(TOPLEFT, MemoryUsageWindow, BOTTOMRIGHT, -(i-1) * self.width, -measurements[index] * 2)
		line:SetAnchor(BOTTOMRIGHT, MemoryUsageWindow, BOTTOMRIGHT, -i * self.width, -measurements[(index+1)% (numSegments + 1)] * 2)
	end
	self.currentUsage:SetText(string.format("%.2f MB", GetTotalUserAddOnMemoryPoolUsageMB()))
end

function MemoryUsage:Initialize()
	self.segments = {}
	self.measurements = {current = 1}
	self.numSegments = 100
	self.width = MemoryUsageWindow:GetWidth() / self.numSegments
	MemoryUsageWindow:SetMouseEnabled(true)
	MemoryUsageWindow:SetMovable(true)
	
	for i = 1, self.numSegments do
		self.measurements[i] = 0
		
		local line = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LINE)
		line:SetColor(1,0,0)
		line:SetThickness(2)
		--line:SetHidden(true)
		line:SetPixelRoundingEnabled(false)
		self.segments[i] = line
		line:SetDrawLevel(2)
	end
	
	local numVertical = 10
	for i = 1, numVertical do
		local line = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LINE)
		local height = MemoryUsageWindow:GetHeight() / numVertical * i
		line:SetAnchor(TOPLEFT, MemoryUsageWindow, TOPLEFT, 0, height)
		line:SetAnchor(BOTTOMRIGHT, MemoryUsageWindow, TOPRIGHT, 0, height)
		line:SetDrawLevel(1)
		line:SetThickness(1)
		local label = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LABEL)
		label:SetAnchor(LEFT, line, RIGHT, 8, 0)
		label:SetText(tostring((numVertical - i) * 10))
		label:SetFont("ZoFontGamepad22")
	end
	
	local label = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LABEL)
	label:SetAnchor(LEFT, MemoryUsageWindow, TOPRIGHT, 8, 0)
	label:SetText("MB")
	label:SetFont("ZoFontGamepad22")
	
	label = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LABEL)
	label:SetAnchor(BOTTOMRIGHT, MemoryUsageWindow, TOPRIGHT, 0, -8)
	label:SetText("sec")
	label:SetFont("ZoFontGamepad22")
	
	label = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LABEL)
	label:SetAnchor(LEFT, self.segments[1], RIGHT, 40, 0)
	label:SetFont("ZoFontGamepad22")
	self.currentUsage = label
	
	local numHorizontal = 6
	for i = 1, numHorizontal-1 do
		local line = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LINE)
		local width = MemoryUsageWindow:GetWidth() / numHorizontal * i
		line:SetAnchor(BOTTOMRIGHT, MemoryUsageWindow, BOTTOMLEFT, width, 0)
		line:SetAnchor(TOPLEFT, MemoryUsageWindow, TOPLEFT, width, 0)
		line:SetDrawLevel(1)
		line:SetThickness(1)
		local label = WINDOW_MANAGER:CreateControl(nil, MemoryUsageWindow, CT_LABEL)
		label:SetAnchor(BOTTOM, line, TOP, 0, -8)
		label:SetText(tostring((numHorizontal - i) * 10))
		label:SetFont("ZoFontGamepad22")
	end
	
	local timeOnDisplayInMs = 60 * 1000 -- 60seconds
	local delayInMs = timeOnDisplayInMs / self.numSegments
	EVENT_MANAGER:RegisterForUpdate("MemoryUsage", delayInMs, MemoryUsage.NextMeasurement)
end

local function OnAddonLoaded(_, addonName)
	if addonName ~= "MemoryUsage" then return end
	
	MemoryUsage:Initialize()
end

EVENT_MANAGER:RegisterForEvent("MemoryUsage", EVENT_ADD_ON_LOADED, OnAddonLoaded)