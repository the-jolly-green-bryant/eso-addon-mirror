local LCA = LibCombatAlerts


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local COLUMN_SPACING = 16
local SUBCELL_SPACING = -8

local DEFAULT_POSITION = {
	left = 400,
	top = 300,
}

local DEFAULT_OPTIONS = {
	ownerId = nil,
	rowLabels = { },
	alignFirstColumn = true,
	scale = 1,
	pollingInterval = 100,
	pollingFunction = nil,
	initFunction = nil,
}


--------------------------------------------------------------------------------
-- LCA_StatusPanel
--------------------------------------------------------------------------------

local LCA_StatusPanel = LCA.BaseControlObject:Subclass()
LCA.StatusPanel = LCA_StatusPanel

local nextOwnerId = 1 -- Yes, we do want this to be shared across instances

-- Preserve GuiRoot to guard against redefinition
local GuiRoot = GuiRoot


--------------------------------------------------------------------------------
-- Public interface
--------------------------------------------------------------------------------

function LCA_StatusPanel:New( )
	local obj = LCA.BaseControlObject.New(self, "LCA_StatusPanel")

	obj.ownerId = nil
	obj.polling = false
	obj.alignFirstColumn = false

	-- Initialize
	obj.control = WINDOW_MANAGER:CreateControlFromVirtual(obj.ID, GuiRoot, "LCA_MoveableControl")
	obj.fragment = ZO_SimpleSceneFragment:New(obj.control)
	obj.rows = { }

	-- Positioning
	obj.positioner = LCA.MoveableControl:New(obj.control)

	return obj
end

function LCA_StatusPanel:SetRepositionCallback( fn )
	self.positioner:RegisterCallback(self.ID, LCA.EVENT_CONTROL_MOVE_STOP, fn)
end

function LCA_StatusPanel:SetPosition( pos )
	self.positioner:UpdatePosition(pos or DEFAULT_POSITION)
end

function LCA_StatusPanel:SetPositionSnap( ... )
	self.positioner:SetSnap(...)
end

function LCA_StatusPanel:ToggleLock( ... )
	self.positioner:ToggleLock(...)
end

function LCA_StatusPanel:GetLeftTopPosition( )
	return self.positioner:GetLeftTopPosition()
end

function LCA_StatusPanel:ToggleGamepadMove( ... )
	return self.positioner:ToggleGamepadMove(...)
end

function LCA_StatusPanel:GetDefaultPosition( )
	return ZO_ShallowTableCopy(DEFAULT_POSITION)
end

function LCA_StatusPanel:Enable( options )
	-- If the panel is already enabled, new options should be processed only if the new owner is different than the current owner
	if (self.ownerId and options and options.ownerId == self.ownerId) then
		return self.ownerId
	end

	options = LCA.PopulateOptions(options, DEFAULT_OPTIONS)

	-- Owner information
	self.ownerId = options.ownerId
	if (type(self.ownerId) ~= "number" and type(self.ownerId) ~= "string") then
		self.ownerId = nextOwnerId
		nextOwnerId = nextOwnerId + 1
	end

	-- Scaling
	self.control:SetScale(options.scale)

	-- Reset memory width
	self.memWidth = nil
	self.control:SetDimensionConstraints(0, 0, 0, 0)

	-- Initialize rows
	self:Reset()
	if (type(options.rowLabels) == "table") then
		for i, label in ipairs(options.rowLabels) do
			self:ModifyCell(i, 1, { text = label })
		end
	elseif (type(options.rowLabels) == "string") then
		self:ModifyCell(1, 1, { text = options.rowLabels })
	end

	-- Additional initialization
	if (options.initFunction) then
		options.initFunction()
	end

	-- Align the first column
	self.alignFirstColumn = options.alignFirstColumn
	if (self.alignFirstColumn) then
		self:AlignFirstColumn()
	end

	-- Polling
	if (options.pollingFunction) then
		if (self.polling) then
			EVENT_MANAGER:UnregisterForUpdate(self.ID)
		end
		self.polling = true
		EVENT_MANAGER:RegisterForUpdate(self.ID, options.pollingInterval, options.pollingFunction)
		options.pollingFunction()
	end

	-- Show
	self:SetPosition(options.pos)
	LCA.ToggleUIFragment(self.fragment, true)
	self.memWidth = 0

	return self.ownerId
end

function LCA_StatusPanel:Disable( )
	if (self.ownerId) then
		self.ownerId = nil

		if (self.polling) then
			self.polling = false
			EVENT_MANAGER:UnregisterForUpdate(self.ID)
		end

		-- Hide
		LCA.ToggleUIFragment(self.fragment, false)
	end
end

function LCA_StatusPanel:GetOwnerId( )
	return self.ownerId
end

function LCA_StatusPanel:SetRowColor( r, color )
	if (self.ownerId and type(color) == "number") then
		local row = self:GetRow(r)
		if (row) then
			for _, cell in ipairs(row.cells) do
				self:UpdateControl(cell, nil, color)
			end
		end
	end
end

function LCA_StatusPanel:SetRowAlpha( r, alpha )
	if (self.ownerId) then
		local row = self:GetRow(r)
		if (row) then
			self:UpdateControl(row.control, nil, nil, nil, nil, nil, alpha)
		end
	end
end

function LCA_StatusPanel:SetRowHidden( r, hidden )
	if (self.ownerId) then
		local row = self:GetRow(r)
		if (row) then
			self:UpdateControl(row.control, nil, nil, nil, nil, nil, nil, hidden == true, nil, nil, true)
		end
		self:UpdateMemoryWidth()
	end
end

function LCA_StatusPanel:ModifyCell( r, c, params )
	if (self.ownerId and type(params) == "table" and self:GetCell(r, c)) then
		if (c == 0) then
			-- These fields are not supported for the sub-cell
			params.alignment = nil
			params.width = nil
			params.minWidth = nil
		end
		if (c <= 2 and params.text == "") then
			-- The first two cells and the sub-cell should never be fully blank
			params.text = " "
		end
		self:UpdateControl(self:GetCell(r, c), params.text, params.color, params.alignment, params.width, params.minWidth, params.alpha, params.hide == true, r, c)
		if (not params.hide) then
			self:SetRowHidden(r, false)
		end
	end
end

function LCA_StatusPanel:ToggleAdditionalScene( sceneName, enable )
	local scene = SCENE_MANAGER:GetScene(sceneName)
	if (scene and enable) then
		scene:AddFragment(self.fragment)
	elseif (scene and not enable) then
		scene:RemoveFragment(self.fragment)
	end
end


--------------------------------------------------------------------------------
-- Private functions; do not call these externally
--------------------------------------------------------------------------------

function LCA_StatusPanel:GetRow( r )
	if (type(r) == "number" and r > 0) then
		local rows = self.rows
		if (#rows < r) then
			for i = #rows + 1, r do
				local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Row" .. i, self.control, "LCA_StatusPanel_Row")
				if (i == 1) then
					control:SetAnchor(TOPLEFT)
				else
					control:SetAnchor(TOPLEFT, rows[i - 1].control, BOTTOMLEFT)
				end
				rows[i] = { control = control, cells = { control:GetNamedChild("Cell1") } }
			end
		end
		return rows[r]
	else
		return nil
	end
end

function LCA_StatusPanel:GetCell( r, c )
	local row = self:GetRow(r)

	if (row and type(c) == "number" and c >= 0) then
		-- If requesting the sub-cell, then ensure that cell 2 exists
		local getSubCell = false
		if (c == 0) then
			c = 2
			getSubCell = true
		end

		local cells = row.cells
		if (#cells < c) then
			for i = #cells + 1, c do
				local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Cell" .. i, row.control, "LCA_StatusPanel_Cell")
				control:SetAnchor(TOPLEFT, cells[i - 1], TOPRIGHT, COLUMN_SPACING, 0)
				cells[i] = control
			end
		end

		if (not getSubCell) then
			-- Normal cell
			return cells[c]
		else
			-- Sub cell
			if (not row.subCell) then
				local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)SubCell", row.control, "LCA_StatusPanel_SubCell")
				control:SetAnchor(TOPLEFT, cells[2], BOTTOMLEFT, 0, SUBCELL_SPACING)
				row.subCell = control
			end
			return row.subCell
		end
	else
		return nil
	end
end

function LCA_StatusPanel:AlignFirstColumn( includeRow )
	local cells = { }
	local maxWidth = 0

	for i, row in ipairs(self.rows) do
		local cell = row.cells[1]
		if (i == includeRow or (not row.control:IsControlHidden() and not cell:IsControlHidden())) then
			table.insert(cells, cell)
			local width = cell:GetStringWidth(cell:GetText())
			if (maxWidth < width) then
				maxWidth = width
			end
		end
	end

	maxWidth = maxWidth / GetUIGlobalScale()

	for _, cell in ipairs(cells) do
		self:UpdateControl(cell, nil, nil, nil, maxWidth)
	end
end

function LCA_StatusPanel:UpdateMemoryWidth( )
	if (self.memWidth and not self.positioner:GetPosition().left) then
		local width = self.control:GetWidth()
		if (self.memWidth < width) then
			self.memWidth = width
			self.control:SetDimensionConstraints(self.memWidth, 0, 0, 0)
		end
	end
end

function LCA_StatusPanel:UpdateControl( control, text, color, alignment, width, minWidth, alpha, hidden, r, c, checkAlign )
	if (text and text ~= control.lcaCurrentText) then
		control.lcaCurrentText = text
		control:SetText(text)
		if (c == 1 and self.alignFirstColumn) then
			self:AlignFirstColumn(r)
		end
	end

	if (color and color ~= control.lcaCurrentColor) then
		control.lcaCurrentColor = color
		control:SetColor(LCA.UnpackRGBA(color))
	end

	if (alignment and alignment ~= control.lcaCurrentAlignment) then
		control.lcaCurrentAlignment = alignment
		control:SetHorizontalAlignment(alignment)
	end

	if (type(width) == "string") then
		width = control:GetStringWidth(width) / GetUIGlobalScale()
	end
	if (width and width ~= control.lcaCurrentWidth) then
		control.lcaCurrentWidth = width
		if (width == 0) then width = nil end
		control:SetWidth(width)
	end

	if (type(minWidth) == "string") then
		minWidth = control:GetStringWidth(minWidth) / GetUIGlobalScale()
	end
	if (minWidth and minWidth ~= control.lcaCurrentMinWidth) then
		control.lcaCurrentMinWidth = minWidth
		control:SetDimensionConstraints(minWidth, 0, 0, 0)
	end

	if (alpha and alpha ~= control.lcaCurrentAlpha) then
		control.lcaCurrentAlpha = alpha
		control:SetAlpha(alpha)
	end

	if (hidden ~= nil and hidden ~= control.lcaCurrentHidden) then
		control.lcaCurrentHidden = hidden
		control:SetHidden(hidden)
		if (checkAlign and hidden == false and self.alignFirstColumn) then
			self:AlignFirstColumn()
		end
	end

	self:UpdateMemoryWidth()
end

function LCA_StatusPanel:Reset( )
	self.alignFirstColumn = false
	for _, row in ipairs(self.rows) do
		for i, cell in ipairs(row.cells) do
			self:UpdateControl(cell, "", 0xFFFFFFFF, (i == 1) and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 0, 1, i > 1)
		end
		if (row.subCell) then
			self:UpdateControl(row.subCell, "", 0xFFFFFFFF, nil, nil, nil, 1, true)
		end
		self:UpdateControl(row.control, nil, nil, nil, nil, nil, 1, true)
	end
end
