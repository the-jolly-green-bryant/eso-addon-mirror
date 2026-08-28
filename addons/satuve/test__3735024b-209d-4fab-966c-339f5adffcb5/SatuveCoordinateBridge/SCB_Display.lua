local SCB = SatuveCoordinateBridge

SCB.Display = SCB.Display or {}
local Display = SCB.Display

function Display:Create()
	if self.Window then return end
	local window = WINDOW_MANAGER:CreateTopLevelWindow("SatuveCoordinateBridgeGrid")
	window:SetMouseEnabled(false)
	window:SetMovable(false)
	window:SetClampedToScreen(true)
	window:SetDrawTier(DT_HIGH)
	if DL_OVERLAY then window:SetDrawLayer(DL_OVERLAY) end

	self.Cells = {}
	self.LastBits = {}
	for index = 1, SCB.Constants.BIT_COUNT do
		local cell = WINDOW_MANAGER:CreateControl("SatuveCoordinateBridgeBit" .. tostring(index), window, CT_BACKDROP)
		cell:SetCenterColor(0, 0, 0, 1)
		cell:SetEdgeColor(0, 0, 0, 1)
		cell:SetEdgeTexture("", 1, 1, 0)
		self.Cells[index] = cell
	end

	local debugText = WINDOW_MANAGER:CreateControl("SatuveCoordinateBridgeDebugText", window, CT_LABEL)
	debugText:SetDimensions(360, 220)
	debugText:SetFont("$(MEDIUM_FONT)|16|outline")
	debugText:SetColor(1, 1, 1, 1)
	debugText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	debugText:SetVerticalAlignment(TEXT_ALIGN_TOP)
	window.debugText = debugText

	self.Window = window
	self:ApplySettings()
end

function Display:ApplySettings()
	if not self.Window or not SCB.SV then return end
	local size = SCB.Clamp(SCB.SV.cellSize, 3, 12)
	SCB.SV.cellSize = size
	self.Window:ClearAnchors()
	self.Window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tonumber(SCB.SV.offsetX) or 20, tonumber(SCB.SV.offsetY) or 20)
	self.Window:SetDimensions(SCB.Constants.GRID_COLUMNS * size, SCB.Constants.GRID_ROWS * size)

	for index, cell in ipairs(self.Cells) do
		local zeroBased = index - 1
		local column = zeroBased % SCB.Constants.GRID_COLUMNS
		local row = math.floor(zeroBased / SCB.Constants.GRID_COLUMNS)
		cell:ClearAnchors()
		cell:SetAnchor(TOPLEFT, self.Window, TOPLEFT, column * size, row * size)
		cell:SetDimensions(size, size)
	end

	self.Window.debugText:ClearAnchors()
	self.Window.debugText:SetAnchor(TOPLEFT, self.Window, BOTTOMLEFT, 0, 8)
	self.Window.debugText:SetHidden(not SCB.SV.showDebugText)
	self.Window:SetHidden(not SCB.SV.enabled)
end

local function ValidText(value)
	return value and "VALID" or "INVALID"
end

function Display:Publish(frame)
	if not self.Window or not SCB.SV then return end
	self.Window:SetHidden(not SCB.SV.enabled)
	if not SCB.SV.enabled then return end

	for index = 1, SCB.Constants.BIT_COUNT do
		local bit = frame.bits[index] or 0
		if self.LastBits[index] ~= bit then
			self.LastBits[index] = bit
			local value = bit == 1 and 1 or 0
			self.Cells[index]:SetCenterColor(value, value, value, 1)
			self.Cells[index]:SetEdgeColor(value, value, value, 1)
		end
	end

	local debugText = self.Window.debugText
	debugText:SetHidden(not SCB.SV.showDebugText)
	if SCB.SV.showDebugText then
		debugText:SetText(string.format(
			"SatuveCoordinateBridge V2\n\nMap: %d\n\nX: %.6f\nY: %.6f\n\nMove: %.1f deg\nSpeed: %.2f m/s\n\nSeq: %d\n\nPosition: %s\nDirection: %s\nSpeed: %s\n\nCRC: %04X",
			frame.mapId,
			frame.x,
			frame.y,
			frame.direction / (math.pi * 2) * 360,
			frame.speed,
			frame.sequence,
			ValidText(frame.coordinatesValid),
			ValidText(frame.directionValid),
			ValidText(frame.speedValid),
			frame.crc
		))
	end
end

function Display:Initialize()
	self:Create()
end
