local addon = BureauOfPrivateDispatches
local CONFIG = addon.config

local type = type

local function SanitizeCoordinate(value, fallback)
	if type(value) ~= "number" or value ~= value then
		return fallback
	end

	if value > CONFIG.MAX_ABSOLUTE_OFFSET or value < -CONFIG.MAX_ABSOLUTE_OFFSET then
		return fallback
	end

	return value
end

function addon:GetDefaultPosition()
	local left = 0
	if GuiRoot ~= nil and type(GuiRoot.GetWidth) == "function" then
		left = GuiRoot:GetWidth() - CONFIG.PANEL_WIDTH - CONFIG.DEFAULT_INSET_RIGHT
	end

	if left < 0 then
		left = 0
	end

	return left, CONFIG.DEFAULT_TOP
end

function addon:ClampPositionToScreen(left, top)
	if GuiRoot == nil or type(GuiRoot.GetWidth) ~= "function" then
		return left, top
	end

	local screenWidth = GuiRoot:GetWidth()
	local screenHeight = GuiRoot:GetHeight()
	local margin = CONFIG.MIN_ONSCREEN_MARGIN
	local maximumLeft = screenWidth - margin
	local maximumTop = screenHeight - margin

	if left > maximumLeft then
		left = maximumLeft
	end
	if left < CONFIG.PANEL_WIDTH * -1 + margin then
		left = CONFIG.PANEL_WIDTH * -1 + margin
	end

	if top > maximumTop then
		top = maximumTop
	end
	if top < 0 then
		top = 0
	end

	return left, top
end

local LEGACY_HORIZONTAL_FACTOR =
{
	[TOPLEFT] = 0.0, [BOTTOMLEFT] = 0.0,
	[LEFT] = 0.0,
	[TOP] = 0.5, [BOTTOM] = 0.5, [CENTER] = 0.5,
	[TOPRIGHT] = 1.0, [BOTTOMRIGHT] = 1.0, [RIGHT] = 1.0,
}

local LEGACY_VERTICAL_FACTOR =
{
	[TOPLEFT] = 0.0, [TOP] = 0.0, [TOPRIGHT] = 0.0,
	[LEFT] = 0.5, [CENTER] = 0.5, [RIGHT] = 0.5,
	[BOTTOMLEFT] = 1.0, [BOTTOM] = 1.0, [BOTTOMRIGHT] = 1.0,
}

function addon:ConvertLegacyPosition(position)
	if GuiRoot == nil or type(GuiRoot.GetWidth) ~= "function" then
		return nil, nil
	end

	local point = position.point
	local relativePoint = position.relativePoint
	local offsetX = position.offsetX
	local offsetY = position.offsetY

	if type(offsetX) ~= "number" or type(offsetY) ~= "number" then
		return nil, nil
	end

	local relativeHorizontal = LEGACY_HORIZONTAL_FACTOR[relativePoint]
	local relativeVertical = LEGACY_VERTICAL_FACTOR[relativePoint]
	local selfHorizontal = LEGACY_HORIZONTAL_FACTOR[point]
	local selfVertical = LEGACY_VERTICAL_FACTOR[point]

	if relativeHorizontal == nil or selfHorizontal == nil
		or relativeVertical == nil or selfVertical == nil then
		return nil, nil
	end

	local anchorX = GuiRoot:GetWidth() * relativeHorizontal + offsetX
	local anchorY = GuiRoot:GetHeight() * relativeVertical + offsetY
	local left = anchorX - CONFIG.PANEL_WIDTH * selfHorizontal
	local top = anchorY - CONFIG.HEADER_HEIGHT * selfVertical

	return left, top
end

function addon:SanitizePosition()
	local defaultLeft, defaultTop = self:GetDefaultPosition()
	local existing = self.savedVariables.position
	local position = {}
	if type(existing) == "table" then
		position.left = existing.left
		position.top = existing.top
		position.point = existing.point
		position.relativePoint = existing.relativePoint
		position.offsetX = existing.offsetX
		position.offsetY = existing.offsetY
	end
	self.savedVariables.position = position

	local pendingLegacy = false
	if position.left == nil and position.point ~= nil then
		local convertedLeft, convertedTop = self:ConvertLegacyPosition(position)
		if convertedLeft ~= nil and convertedTop ~= nil then
			position.left = convertedLeft
			position.top = convertedTop
			position.point = nil
			position.relativePoint = nil
			position.offsetX = nil
			position.offsetY = nil
		else
			pendingLegacy = true
		end
	elseif position.point ~= nil then
		position.point = nil
		position.relativePoint = nil
		position.offsetX = nil
		position.offsetY = nil
	end

	if not pendingLegacy then
		position.left = SanitizeCoordinate(position.left, defaultLeft)
		position.top = SanitizeCoordinate(position.top, defaultTop)
	end

	return position
end

function addon:ApplySavedPosition()
	if not self.root then
		return
	end

	local position = self:SanitizePosition()
	local left = position.left
	local top = position.top
	if left == nil or top == nil then
		left, top = self:GetDefaultPosition()
	end
	left, top = self:ClampPositionToScreen(left, top)

	self.root:ClearAnchors()
	self.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

	if position.point == nil then
		position.left = left
		position.top = top
	end
end

function addon:SavePosition()
	if not self.root then
		return
	end

	local left = self.root:GetLeft()
	local top = self.root:GetTop()
	local position = self:SanitizePosition()
	local sanitizedLeft = SanitizeCoordinate(left, position.left)
	local sanitizedTop = SanitizeCoordinate(top, position.top)

	sanitizedLeft, sanitizedTop = self:ClampPositionToScreen(sanitizedLeft, sanitizedTop)
	position.left = sanitizedLeft
	position.top = sanitizedTop

	self.root:ClearAnchors()
	self.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sanitizedLeft, sanitizedTop)
end

function addon:ResetPosition()
	if not self.root then
		return
	end

	local defaultLeft, defaultTop = self:GetDefaultPosition()
	local position = self:SanitizePosition()
	position.left = defaultLeft
	position.top = defaultTop

	self:ApplySavedPosition()
	self:RefreshNotifications()
	self:SavePosition()
end