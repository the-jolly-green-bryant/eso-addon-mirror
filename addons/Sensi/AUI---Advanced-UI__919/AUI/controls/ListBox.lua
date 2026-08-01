local AUI_COLUMN_DEFAULT_COLOR = "#b8b594"
local AUI_COLUMN_DEFAULT_COLOR_HOVER = "#b27900"
local AUI_COLUMN_DEFAULT_FONT_SIZE = 20
local AUI_ROW_DEFAULT_FONT_SIZE = 16
local AUI_ROW_COLOR_DEFAULT = "#ffffff"
local AUI_ROW_COLOR_HOVER_DEFAULT = "#005298"
local AUI_ROW_COLOR_PRESSED_DEFAULT = "#c7c7c7"
local AUI_COLUMN_FONT_DEFAULT = ("$(BOLD_FONT)|" .. AUI_COLUMN_DEFAULT_FONT_SIZE .. "|" .. "outline")
local AUI_ROW_FONT_DEFAULT = ("$(MEDIUM_FONT)|" .. AUI_ROW_DEFAULT_FONT_SIZE .. "|" .. "outline")
local AUI_SORT_ARROW_UP = "EsoUI/Art/Miscellaneous/list_sortUp.dds"
local AUI_SORT_ARROW_DOWN = "EsoUI/Art/Miscellaneous/list_sortDown.dds"
local AUI_ROW_BG_COLOR_DEFAULT = ""
local AUI_ROW_BG_COLOR_SELECTED_DEFAULT = "AUI/images/other/listbox_selected.dds"
local AUI_ROW_BG_COLOR_HOVER_DEFAULT = "AUI/images/other/listbox_hover.dds"
local AUI_ROW_BG_COLOR_PRESSED_DEFAULT = "AUI/images/other/listbox_pressed.dds"
local AUI_COLUMN_DEFAULT_HEIGHT = 38

local ListBox = ZO_Object:Subclass()
function ListBox:New(_name, _parent, _useMouseEvents, _showBorder)
	local manager = ZO_Object.New(self)

	manager.itemList = {}
	manager.rowList = {}	
	manager.ListBoxControl = CreateControlFromVirtual(_name, _parent, "AUI_ListBox")
	manager.name = _name
	manager.parent = _parent
	manager.currentSortKey = 1
	manager.currentSortOrder = ZO_SORT_ORDER_DOWN
	manager.rowHeight = 30
	manager.columnCount = 0
	manager.rowCount = 0
	manager.visibleRowCount = 0
	manager.width = 0
	manager.height = 0
	manager.borderSize = 2
	manager.padding = 4
	manager.firstRowTop = 4
	manager.contentTop = 4
	manager.columnHeaderHeight = AUI_COLUMN_DEFAULT_HEIGHT
	manager.scrollBarWidth = 16
	manager.scrollBarPaddingTop = 16
	manager.scrollBarPaddingBottom = 16
	manager.rowDistance = 2
	manager.showMouseHoverEffect = false
	manager.showRowSelectedHoverEffect = false
	manager.activeRows = {}
	manager.useMouseEvents = _useMouseEvents
	manager.currentCellsWidth = 0
	manager.lastCreatedColumn = nil
	manager.columnpool = nil
	manager.scrollContentHeight = 0
	manager.showBorder = _showBorder
	manager.allowManualDeselect = false
	manager.totalInnerHeight = 0
	
    manager:Initialize()
	
    return manager	
end

function ListBox:SetSortOrder(_self, _sortOrder)
	self.currentSortOrder = _sortOrder
end

function ListBox:SetSortKey(_self, _sortKey)
	self.currentSortKey = _sortKey
end

function ListBox:SetRowHeight(_self, _value)
	self.rowHeight = _value
end

function ListBox:EnableMouseHover()
	self.showMouseHoverEffect = true
end

function ListBox:EnableMouseSelection()
	self.showRowSelectedHoverEffect = true
end

function ListBox:GetRowCount()
	return self.rowCount
end

function ListBox:GetRowHeight()
	return self.rowHeight
end

function ListBox:GetScrollContentHeight()
	return (self.totalInnerHeight + self.columnHeaderHeight + self.contentTop) + (self.padding * 2) + (self.rowDistance * self.rowCount) + (self.borderSize * 2) - self.firstRowTop + 1000
end

function ListBox:GetVisibleRowCount()
	return self.visibleRowCount
end

function ListBox:SetColumnText(_self, _columnIndex, _text)
	if self.columnpool then
		local columnControl = self.columnpool:GetExistingObject(_columnIndex)
		if columnControl then
			local textContainer = GetControl(columnControl, "TextContainer")
			local labelControl = GetControl(textContainer, "Label")
			labelControl:SetText(_text)
		end
	end
end

function ListBox:UpdateArrow(arrowTexture)
	if self.currentSortOrder == ZO_SORT_ORDER_UP then
		arrowTexture:SetTexture(AUI_SORT_ARROW_UP)
	else
		arrowTexture:SetTexture(AUI_SORT_ARROW_DOWN)
	end
end

function ListBox:ScrollToRow(_rowIndex)
    -- Clamp the row index to be within valid range
    if _rowIndex < 0 then
        _rowIndex = 0
    elseif _rowIndex > (self.rowCount - self.visibleRowCount) then
        _rowIndex = self.rowCount - self.visibleRowCount
    end

    -- Calculate the vertical offset to scroll to the desired row
    local offsetY = 0
    for i = 0, _rowIndex - 1 do
        local rowControl = self.rowList[i]
        offsetY = offsetY + rowControl:GetHeight() + self.rowDistance
    end

    -- Update the content control position to simulate scrolling
    self.contentControl:ClearAnchors()
    self.contentControl:SetAnchor(TOPLEFT, self.scrollControl, TOPLEFT, 0, -offsetY)

    -- Update the current row index in the scroll control's data
    self.scrollControl.data.currentRowIndex = _rowIndex
end

function ListBox:Scroll(_delta)
    if self.visibleRowCount > 0 and self.visibleRowCount < self.rowCount then
        -- Calculate the new row index based on the delta
        local newRowIndex = self.scrollControl.data.currentRowIndex - _delta

        -- Clamp the new row index to be within valid range
        if newRowIndex < 0 then
            newRowIndex = 0
        elseif newRowIndex > (self.rowCount - self.visibleRowCount) then
            newRowIndex = self.rowCount - self.visibleRowCount
        end

        -- Update the scroll bar position and scroll to the new row
        self.scrollBarControl:SetValue(newRowIndex)
        self:ScrollToRow(newRowIndex)
    end
end

function ListBox:RefreshVisible()
    local scrollMax = 0
    local rowSpace = self.rowHeight + self.rowDistance

    self.visibleHeight = self.height - self.columnHeaderHeight - self.contentTop - (self.borderSize * 2) - (self.padding * 2)
    self.visibleRowCount = math.floor(self.visibleHeight / rowSpace)

    if self.visibleRowCount > 0 and self.visibleRowCount < self.rowCount then
        self.scrollBarControl:SetHidden(false)
        scrollMax = self.rowCount - self.visibleRowCount
    else
        self.scrollBarControl:SetHidden(true)
    end    

    self.scrollBarControl:SetMinMax(0, scrollMax)
    self.scrollBarControl:SetValue(0)
end

function ListBox:Refresh()
	self:Clear()
    self:Sort()
	
	local rowIndex = 0
	
	local lastRowControl = nil
	for rowKey, rowData in ipairs(self.itemList) do
		local rowControl = self:CreateRow(rowIndex, rowData)		

		rowControl:ClearAnchors()
		if lastRowControl then
			rowControl:SetAnchor(TOPLEFT, lastRowControl, BOTTOMLEFT, 0, self.rowDistance)
		else					
			rowControl:SetAnchor(TOPLEFT, self.contentControl, TOPLEFT, 0, 0)
		end
		
		lastRowControl = rowControl
		
		rowIndex = rowIndex + 1
	end	

	self:RefreshVisible()
	self:ScrollToStart()	
end

function ListBox:Initialize()
    self.container = GetControl(self.ListBoxControl, "Container")
    self.scrollControl = GetControl(self.container, "Scroll")
    self.scrollControl.data = { currentRowIndex = 0 }
    self.contentControl = GetControl(self.scrollControl, "Content")
    self.scrollBarControl = GetControl(self.ListBoxControl, "ScrollBar")
    self.columnHeader = GetControl(self.container, "ColumnHeader")
    self.borderControl = GetControl(self.ListBoxControl, "_Border")
    self.columnLine = GetControl(self.columnHeader, "ColumnLine")

    local scrollBarUp = GetControl(self.scrollBarControl, "Up")
    local scrollBarDown = GetControl(self.scrollBarControl, "Down")

    scrollBarUp:SetHandler("OnClicked",
    function(_eventCode, _button, _ctrl, _alt, _shift)
        self:Scroll(1)
    end)

    scrollBarDown:SetHandler("OnMouseDown",
    function(_eventCode, _button, _ctrl, _alt, _shift)
        self:Scroll(-1)
    end)

    self.scrollControl:SetHandler("OnMouseWheel",
    function(_control, _delta)
        self:Scroll(_delta)
    end)

    self.ListBoxControl:SetParent(self.parent)
    self.borderControl:SetEdgeTexture(nil, 2, 2, self.borderSize)

    if not self.showBorder then
        self.borderControl:SetHidden(true)
    else
        self.borderControl:SetHidden(false)
    end

    self.columnpool = ZO_ObjectPool:New(function(objectPool) return ZO_ObjectPool_CreateNamedControl(self.name .. "Column", "AUI_ListBox_Column", objectPool, self.columnHeader) end, ZO_ObjectPool_DefaultResetControl)
    self.rowPool = ZO_ObjectPool:New(function(objectPool) return ZO_ObjectPool_CreateNamedControl(self.name .. "Row", "AUI_ListBox_Row", objectPool, self.contentControl) end, ZO_ObjectPool_DefaultResetControl)
end

function ListBox:CreateColumn(columnKey, columnData)
	local columnControl, key = self.columnpool:AcquireObject()

	if columnControl then
		if not columnData.Width then
			columnData.Width = 0
		end
		
		if not columnData.Height then
			columnData.Height = 0
		end	
		
		local textContainer = GetControl(columnControl, "TextContainer")
		local labelControl = GetControl(textContainer, "Label")
		local textColor = AUI.Color.ConvertHexToRGBA(AUI_COLUMN_DEFAULT_COLOR)
		local arrowTexture = nil
		local textAlign = TEXT_ALIGN_LEFT
		
		local horizontalTextAlign = TEXT_ALIGN_LEFT
		local verticalTextAlign = TEXT_ALIGN_CENTER
		
		if columnData.HorizontalTextAlign then
			horizontalTextAlign = columnData.HorizontalTextAlign
		end		
		
		if columnData.VerticalTextAlign then
			verticalTextAlign = columnData.VerticalTextAlign
		end	
		
		if columnData.Font then
			labelControl:SetFont(columnData.Font)
		else
			labelControl:SetFont(AUI_COLUMN_FONT_DEFAULT)
		end
		
		labelControl:SetText(columnData.Text)
		labelControl:SetHorizontalAlignment(horizontalTextAlign)
		labelControl:SetVerticalAlignment(verticalTextAlign)
		labelControl:SetColor(textColor:UnpackRGBA())
				
		columnControl:SetMouseEnabled(columnData.AllowSort)						
		
		if columnData.AllowSort then
			columnData.arrowTexture = GetControl(textContainer, "SortArrow")
			columnData.arrowTexture:SetHidden(false)
			
			self:UpdateArrow(columnData.arrowTexture)

			columnControl:SetHandler("OnMouseUp", 
			function(_eventCode, _button, _ctrl, _alt, _shift)
				if self.currentSortOrder == ZO_SORT_ORDER_DOWN then
					self.currentSortOrder = ZO_SORT_ORDER_UP
				else
					self.currentSortOrder = ZO_SORT_ORDER_DOWN
				end

				self:UpdateArrow(columnData.arrowTexture)
				
				self.currentSortKey = columnKey
				
				self:Refresh()
			end)			
		end		
		
		columnControl:SetHandler("OnMouseEnter", 
		function(_eventCode, _button, _ctrl, _alt, _shift) 
			local textHoverColor = AUI.Color.ConvertHexToRGBA(AUI_COLUMN_DEFAULT_COLOR_HOVER)
			labelControl:SetColor(textHoverColor:UnpackRGBA())
		end)
		
		columnControl:SetHandler("OnMouseExit", 
		function(_eventCode, _button, _ctrl, _alt, _shift) 
			labelControl:SetColor(textColor:UnpackRGBA())
		end)		

		columnData.CurrentWidth = self:GetCalculatedItemWidth(columnData.Width)
		columnData.CurrentHeight = self.columnHeaderHeight
		
		columnControl:ClearAnchors()

		if self.lastCreatedColumn then			
			columnControl:SetAnchor(TOPLEFT, self.lastCreatedColumn, TOPRIGHT, 0, 0)
		else
			columnControl:SetAnchor(TOPLEFT, self.columnHeader)
		end			
		
		self.lastCreatedColumn = columnControl				
		
		columnControl:SetDimensions(columnData.CurrentWidth, columnData.CurrentHeight)

		if columnData.arrowTexture then
			textContainer:SetDimensions(columnData.CurrentWidth - 16, columnData.CurrentHeight)
		
			labelControl:SetText(columnData.Text)
		
			columnData.arrowTexture:ClearAnchors()			
			columnData.arrowTexture:SetAnchor(LEFT, columnControl, RIGHT, -26)
		else
			textContainer:SetDimensions(columnData.CurrentWidth, columnData.CurrentHeight)
		end
		
		columnControl:SetHidden(false)				
	end	
end

function ListBox:ScrollToStart()
	self.contentControl:ClearAnchors()
	self.contentControl:SetAnchor(TOPLEFT, self.scrollControl, TOPLEFT, 0, 0)		
end

function ListBox:GetCalculatedItemWidth(width)
	local newWidth = 0

	if type(width) == "number" then
		newWidth = width	
	elseif type(width) == "string" then
		if width == "Height" then
			newWidth = self.rowHeight
		elseif not AUI.String.IsEmpty(width) then 
			local convertedWidth = string.gsub(width, "%%", "")
			convertedWidth = tonumber(convertedWidth)		
			newWidth = (((self.scrollControlWidth / 100) * convertedWidth))		
		end
	end

	newWidth = newWidth - ((self.padding + self.borderSize) / self.columnCount) * 2

	return newWidth
end

function ListBox:SetDimensions(_self, width, height)
	self.width = width
	self.height = height

	self.ListBoxControl:SetWidth(self.width)
	self.ListBoxControl:SetHeight(self.height)	
	
	self.scrollControlWidth = self.width - self.scrollBarWidth - (self.padding + self.borderSize * 2)
	self.scrollControlHeight = self.height - self.columnHeaderHeight - self.contentTop - (self.borderSize * 2) - (self.padding * 2)	
		
	self.columnHeader:ClearAnchors()
	self.columnHeader:SetAnchor(TOPLEFT, self.ListBoxControl, TOPLEFT, self.padding + self.borderSize, self.padding + self.borderSize)	
	self.columnHeader:SetDimensions(self.scrollControlWidth, self.columnHeaderHeight)		
		
	self.scrollControl:ClearAnchors()
	self.scrollControl:SetAnchor(TOPLEFT, self.ListBoxControl, TOPLEFT, self.padding + self.borderSize, self.columnHeaderHeight + self.padding + self.borderSize + self.firstRowTop)	
	self.scrollControl:SetDimensions(self.scrollControlWidth, self.scrollControlHeight - self.firstRowTop + 1)
	
	self.scrollBarControl:ClearAnchors()
	self.scrollBarControl:SetAnchor(TOPLEFT, self.scrollControl, TOPRIGHT, 0, self.contentTop + self.scrollBarPaddingTop)
	self.scrollBarControl:SetDimensions(self.scrollBarWidth, self.scrollControlHeight - self.firstRowTop - (self.scrollBarPaddingBottom * 2))		
	
	self.contentControl:ClearAnchors()
	self.contentControl:SetAnchor(TOPLEFT, self.scrollControl, TOPLEFT, 0, 0)
	self.contentControl:SetDimensions(self.scrollControlWidth, 0)
	
	self.columnLine:ClearAnchors()
	self.columnLine:SetAnchor(BOTTOMLEFT, self.columnHeader, nil, self.scrollBarWidth  + 4, 0)
	self.columnLine:SetAnchor(BOTTOMRIGHT, self.columnHeader, nil, -4, 0)
end

function ListBox:Sort()
    if(self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		table.sort(self.itemList, 
		function(listEntry1, listEntry2) 
			if listEntry1 and listEntry2 then
				local data1 = listEntry1[self.currentSortKey]
				local data2 = listEntry2[self.currentSortKey]
				
				if data1.SortType and data2.SortType then				
					local value1 = 0
					local value2 = 0
				
					if data1.SortType == "string" then
						value1 = zo_strlower(data1.SortValue)
					elseif data1.SortType == "number" or data1.SortType == "count" then
						value1 = tonumber(data1.SortValue)			
					end
													
					if data2.SortType == "string" then
						value2 = zo_strlower(data2.SortValue)
					elseif data2.SortType == "number" or data1.SortType == "count" then
						value2 = tonumber(data2.SortValue)				
					end			

					if self.currentSortOrder then
						return value1 < value2
					end
				
					return value1 > value2
				else
					return false
				end
			end
		end)
    end
end



function ListBox:CreateCell(rowControl, cellData)
	local rowControlName = rowControl:GetName()

	local cellControl, cellKey = rowControl.cellPool:AcquireObject()
	cellControl.cellIndex = cellKey
	cellControl.cellData = cellData
	
	if not cellControl.inner then
		if cellData.ControlType == "texture" then
			cellControl.inner = CreateControlFromVirtual(cellControl:GetName() .. "_Inner", cellControl, "AUI_ListBox_CellTexture")
		elseif cellData.ControlType == "icon" then
			cellControl.inner = CreateControlFromVirtual(cellControl:GetName() .. "_Inner", cellControl, "AUI_ListBox_CellIcon")			
		elseif cellData.ControlType == "button" then
			cellControl.inner = CreateControlFromVirtual(cellControl:GetName() .. "_Inner", cellControl, "AUI_ListBox_CellButton")
		else
			cellControl.inner = CreateControlFromVirtual(cellControl:GetName() .. "_Inner", cellControl, "AUI_ListBox_CellLabel")
		end
	end		
		
	local width = 0
	local height = 0	
		
	if cellControl and cellControl.inner then	
		local columnData = self.columnList[cellKey]
		local controlType = cellControl.inner:GetType()
				
		local opacity = 1
	
		local horizontalTextAlign = TEXT_ALIGN_LEFT
		local verticalTextAlign = TEXT_ALIGN_CENTER
		
		if cellData.HorizontalTextAlign then
			horizontalTextAlign = cellData.HorizontalTextAlign
		end		
		
		if cellData.VerticalTextAlign then
			verticalTextAlign = cellData.VerticalTextAlign
		end			
		
		if cellData.Opacity then
			opacity = cellData.Opacity
		end		

		width = columnData.CurrentWidth
		height = self.rowHeight	

		if controlType == CT_LABEL then
			if cellData.TextWrap then
				cellControl.inner:SetDimensions(width, 0)
			else
				cellControl.inner:SetDimensions(width, height)
			end
		
			if cellData.Font then
				cellControl.inner:SetFont(cellData.Font)
			else
				cellControl.inner:SetFont(AUI_ROW_FONT_DEFAULT)
			end
					
			if cellData.Color then
				cellControl.inner:SetColor(cellData.Color:UnpackRGBA())
			else
				cellControl.inner:SetColor(AUI.Color.ConvertHexToRGBA(AUI_ROW_COLOR_DEFAULT, 1):UnpackRGBA())
			end	

			cellControl.inner:SetVerticalAlignment(verticalTextAlign) 
			cellControl.inner:SetHorizontalAlignment(horizontalTextAlign)		
		
			if cellData.ControlType == "count" then		
				cellControl.inner:SetText(rowControl.rowKey .. ".")
			else
				cellControl.inner:SetText(cellData.Value)
			end	
			
			local textHeight = cellControl.inner:GetTextHeight()			
			if textHeight > height then			
				height = textHeight
			end
			
			cellControl:SetDimensions(width, height)
		elseif controlType == CT_TEXTURE then
			if cellData.ControlType == "icon" then
				local textureControl = GetControl(cellControl.inner, "_Texture")
				
				if textureControl then
					textureControl:SetTexture(cellData.TextureFile)
				end
			else
				if cellData.TextureFile and not AUI.String.IsEmpty(cellData.TextureFile) then
					cellControl.inner:SetTexture(cellData.TextureFile)
					cellControl.inner:SetHidden(false)
				else
					cellControl.inner:SetHidden(true)
				end
			end

			if cellData.TextureWidth then			
				if cellData.TextureWidth == "Height" then
					width = self.rowHeight
				else
					width = cellData.TextureWidth		
				end
			end
			
			if cellData.TextureHeight then			
				if cellData.TextureHeight == "Height" then
					height = newWidth
				else
					height = cellData.TextureHeight		
				end
			end		

			cellControl:SetDimensions(width, height)
			cellControl.inner:SetDimensions(width, height)			
		elseif controlType == CT_BUTTON then
			if cellData.TextWrap then
				cellControl.inner:SetDimensions(width, 0)
			else
				cellControl.inner:SetDimensions(width, height)
			end		

			if cellData.NormalTexture then
				cellControl.inner:SetNormalTexture(cellData.NormalTexture)
			end	
	
			if cellData.PressedTexture then
				cellControl.inner:SetPressedTexture(cellData.PressedTexture)
			end
			
			if cellData.MouseOverTexture then
				cellControl.inner:SetMouseOverTexture(cellData.MouseOverTexture)
			end

			cellControl.inner:SetText(cellData.Value)																						

			if cellData.Font then																																													
				cellControl.inner:SetFont(cellData.Font)
			else
				cellControl.inner:SetFont(AUI_ROW_FONT_DEFAULT)
			end		
			
			cellControl.inner:SetHorizontalAlignment(textAlign)	
			cellControl:SetDimensions(width, height)
		end			
		
		local offsetX = 0
		local offsetY = 0
		
		if cellData.OffsetX then
			offsetX = cellData.OffsetX
		end	
		if cellData.OffsetX then
			offsetY = cellData.OffsetY
		end		

		cellControl.inner:ClearAnchors()
		cellControl.inner:SetAnchor(LEFT, cellControl, LEFT, offsetX, offsetY)	
		
		cellControl:ClearAnchors()
		if rowControl.lastCellControl then
			cellControl:SetAnchor(TOPLEFT, rowControl.lastCellControl, TOPRIGHT, 0, 0)
		else
			cellControl:SetAnchor(TOPLEFT, rowControl, TOPLEFT)
		end		

		if self.useMouseEvents then
			cellControl:SetHandler("OnMouseEnter", 
			function(_eventCode, _button)
				if not rowControl.selected then
					if cellData.ControlType == "button" then
						cellControl.isMouseOverButton = true
					elseif self.showMouseHoverEffect then				
						self:SetHoverEffect(rowControl)
					end
				end
			end)		
			
			cellControl:SetHandler("OnMouseExit", 
			function(_eventCode, _button)
				if self.showMouseHoverEffect and not rowControl.selected then
					self:RemoveHoverEffect(rowControl)
				end
				
				if cellData.ControlType == "button" then
					cellControl.isMouseOverButton = false
				end
			end)

			cellControl:SetHandler("OnClicked", 
			function(_eventCode, _button, _ctrl, _alt, _shift)
				if self.showRowSelectedHoverEffect and cellData.ControlType ~= "button" then
					self:SelectRow(rowControl, true)
				end		

				self:OnRowMouseUp(_eventCode, _button, _ctrl, _alt, _shift, rowControl, cellControl)
			end)			
			
			cellControl:SetHandler("OnMouseDoubleClick",
			function(_eventCode, _button, _ctrl, _alt, _shift)
				self:OnRowDoubleClick(_eventCode, _button, _ctrl, _alt, _shift, rowControl, cellControl)
			end)			
				
			if cellData.OnClick then
				cellControl.inner:SetHandler("OnClicked",
				function(_eventCode, _button, _ctrl, _alt, _shift)
					cellData.OnClick(_eventCode, _button, _ctrl, _alt, _shift, rowControl, cellControl)
				end)				
			end

			cellControl:SetMouseEnabled(true)	
		end

		cellControl:SetAlpha(opacity)
		cellControl:SetHidden(false)

		rowControl.cellList[cellKey] = cellControl		
		rowControl.lastCellControl = cellControl
	end	
	
	return height
end

function ListBox:CreateRow(rowIndex, rowData)
	local rowControl, key = self.rowPool:AcquireObject()
	rowControl.lastCellControl = nil
	rowControl.rowKey = key
	rowControl.cellList = {}
	
	if not rowControl.cellPool then
		local factoryFunction = function(objectPool) return ZO_ObjectPool_CreateNamedControl(rowControl:GetName() .. "Cell", "AUI_ListBox_Row", objectPool, rowControl) end
		rowControl.cellPool = ZO_ObjectPool:New(factoryFunction, ZO_ObjectPool_DefaultResetControl)	
		rowControl.cellPool:ReleaseAllObjects()
	end
	
	local rowHeight = self.rowHeight
	
	for _, cellData in ipairs(rowData) do
		local cellHeight = self:CreateCell(rowControl, cellData)
		
		if cellData.TextWrap and cellHeight > rowHeight	then
			rowHeight = cellHeight
		end
		
		self.totalInnerHeight = self.totalInnerHeight + rowHeight
	end
	
	if self.useMouseEvents then
		rowControl:SetHandler("OnMouseEnter", 
		function(_eventCode, _button)
			if not rowControl.selected then
				self:SetHoverEffect(rowControl, 1)
			end
		end)		
		
		rowControl:SetHandler("OnMouseExit", 
		function(_eventCode, _button)
			if not rowControl.selected then
				self:RemoveHoverEffect(rowControl)
			end
		end)

		rowControl:SetHandler("OnClicked", 
		function(_eventCode, _button, _ctrl, _alt, _shift)
			if _button == 1 or _button == 2 then
				self:SelectRow(rowControl, true)
			end
			self:OnRowMouseUp(_eventCode, _button, _ctrl, _alt, _shift, rowControl)
		end)		
		
		rowControl:SetHandler("OnMouseDoubleClick", 
		function(_eventCode, _button, _ctrl, _alt, _shift)
			self:OnRowDoubleClick(_eventCode, _button, _ctrl, _alt, _shift, rowControl)
		end)
		
		rowControl:SetMouseEnabled(true)
	end
		
	rowControl:SetParent(self.contentControl)
	rowControl:SetDimensions(self.scrollControlWidth, rowHeight)
	rowControl:SetHidden(false)	
	
	self.activeRows[key] = rowControl
	self.rowList[rowIndex] = rowControl
	
	self.rowCount = self.rowCount + 1
	
	return rowControl
end

function ListBox:Clear()
	for rowKey, _ in pairs(self.activeRows) do		
		self:RemoveHoverEffect(self.activeRows[rowKey])	
		self.activeRows[rowKey].cellPool:ReleaseAllObjects() 
		self.activeRows[rowKey].cellList = {}												
	end
	
	self.rowPool:ReleaseAllObjects()	
	self.activeRows = {}	
	self.rowCount = 0
	
	if self.selectedRowControl then
		self.selectedRowControl.selected = false
	end
	
	self.selectedRowControl = nil
end

function ListBox:SelectRowByIndex(_self, _index, _useCallback)
	local rowIndex = 0
	for key, rowControl in ipairs(self.activeRows) do
		if rowIndex == _index then
			self:SelectRow(rowControl, _useCallback)
			
			return	
		end
	 
		rowIndex = rowIndex + 1
	end
end

function ListBox:AllowManualDeselect(_self, _allow)
	self.allowManualDeselect = _allow
end

function ListBox:SelectRow(_rowControl, _useCallback)
	if not _rowControl then
		return
	end

	if self.selectedRowControl then
		if self.selectedRowControl.rowKey ~= _rowControl.rowKey then
			self.selectedRowControl:SetNormalTexture(self.selectedRowControl.NormalTexture)
			self.selectedRowControl.selected = false
		
			self.selectedRowControl = _rowControl
			self.selectedRowControl.selected = true			
			self.selectedRowControl:SetNormalTexture(AUI_ROW_BG_COLOR_SELECTED_DEFAULT)
			
			if _useCallback and self.selectedRowCallback then			
				self.selectedRowCallback(nil, nil, nil, nil, nil, _rowControl, nil)
			end				
		elseif self.allowManualDeselect == true then
			self.selectedRowControl:SetNormalTexture(self.selectedRowControl.NormalTexture)		
			self.selectedRowControl.selected = false
			self.selectedRowControl = nil
			
			if _useCallback and self.deselectedRowCallback then			
				self.deselectedRowCallback(nil, nil, nil, nil, nil, _rowControl, nil)
			end				
		end
	else
		self.selectedRowControl = _rowControl
		self.selectedRowControl.selected = true
		self.selectedRowControl:SetNormalTexture(AUI_ROW_BG_COLOR_SELECTED_DEFAULT)
		
		if _useCallback and self.selectedRowCallback then			
			self.selectedRowCallback(nil, nil, nil, nil, nil, _rowControl, nil)
		end			
	end
end

function ListBox:SetHoverEffect(_rowControl)
	if _rowControl.HoverTexture then
		_rowControl:SetNormalTexture(_rowControl.HoverTexture)
	else
		_rowControl:SetNormalTexture(AUI_ROW_BG_COLOR_HOVER_DEFAULT)
	end
end

function ListBox:RemoveHoverEffect(_rowControl)
	if _rowControl.NormalTexture then
		_rowControl:SetNormalTexture(_rowControl.NormalTexture)
	else
		_rowControl:SetNormalTexture(AUI_ROW_BG_COLOR_DEFAULT)
	end
end

function ListBox:OnRowMouseUp(_eventCode, _button, _ctrl, _alt, _shift, _rowControl, _cellControl)
	if self.mouseUpCallback then
		self.mouseUpCallback(_eventCode, _button, _ctrl, _alt, _shift, _rowControl, _cellControl)
	end
end

function ListBox:OnRowDoubleClick(_eventCode, _button, _ctrl, _alt, _shift, _rowControl, _cellControl)
	if self.mouseDoubleClickCallback and not _cellControl.isMouseOverButton then
		self.mouseDoubleClickCallback(_eventCode, _button, _ctrl, _alt, _shift, _rowControl, _cellControl)
	end
end

function ListBox:SetRowMouseDoubleClickCallback(_self, _callback)
	self.mouseDoubleClickCallback = _callback
end

function ListBox:SetRowMouseUpCallback(_self, _callback)
	self.mouseUpCallback = _callback
end

function ListBox:SetSelectedRowCallback(_self, _callback)
	self.selectedRowCallback = _callback
end

function ListBox:SetDeselectedRowCallback(_self, _callback)
	self.deselectedRowCallback = _callback
end

function ListBox:GetSelectedRowControl(_self)
	if self.selectedRowControl then
		return self.selectedRowControl
	end
	
	return nil
end

function ListBox:SetColumnList(_self, _list)
	self.columnList = _list

	self.columnpool:ReleaseAllObjects()	
	self.lastCreatedColumn = nil
	
	if self.columnList then
		self.columnCount = AUI.Table.GetLength(self.columnList)

		for columnKey, columnData in ipairs(self.columnList) do
			self:CreateColumn(columnKey, columnData)
		end	
	end
end

function ListBox:SetItemList(_self, _list)
	self.itemList = _list
end

function AUI.CreateListBox(_name, _parent, _useMouseEvents, _showBorder)	
	local listBoxClass = ListBox:New(_name, _parent, _useMouseEvents, _showBorder)
		
	listBoxClass.ListBoxControl.SetItemList = function(...) listBoxClass:SetItemList(...) end
	listBoxClass.ListBoxControl.SetColumnList = function(...) listBoxClass:SetColumnList(...) end
	listBoxClass.ListBoxControl.Refresh = function() listBoxClass:Refresh() end
	listBoxClass.ListBoxControl.RefreshVisible = function() listBoxClass:RefreshVisible() end
	listBoxClass.ListBoxControl.SetSortKey = function(...) listBoxClass:SetSortKey(...) end
	listBoxClass.ListBoxControl.SetSortOrder = function(...) listBoxClass:SetSortOrder(...) end
	listBoxClass.ListBoxControl.SetDimensions = function(...) listBoxClass:SetDimensions(...) end
	listBoxClass.ListBoxControl.SetColumnText = function(...) listBoxClass:SetColumnText(...) end
	listBoxClass.ListBoxControl.SetRowHeight = function(...) listBoxClass:SetRowHeight(...) end
	listBoxClass.ListBoxControl.SetRowMouseDoubleClickCallback = function(...) listBoxClass:SetRowMouseDoubleClickCallback(...) end
	listBoxClass.ListBoxControl.SetRowMouseUpCallback = function(...) listBoxClass:SetRowMouseUpCallback(...) end
	listBoxClass.ListBoxControl.SetSelectedRowCallback = function(...) listBoxClass:SetSelectedRowCallback(...) end
	listBoxClass.ListBoxControl.SetDeselectedRowCallback = function(...) listBoxClass:SetDeselectedRowCallback(...) end
	listBoxClass.ListBoxControl.GetSelectedRowControl = function(...) return listBoxClass:GetSelectedRowControl(...) end
	listBoxClass.ListBoxControl.EnableMouseHover = function(...) return listBoxClass:EnableMouseHover(...) end
	listBoxClass.ListBoxControl.EnableMouseSelection = function(...) return listBoxClass:EnableMouseSelection(...) end
	listBoxClass.ListBoxControl.GetScrollContentHeight = function(...) return listBoxClass:GetScrollContentHeight(...) end	
	listBoxClass.ListBoxControl.GetVisibleRowCount = function(...) return listBoxClass:GetVisibleRowCount(...) end
	listBoxClass.ListBoxControl.GetRowHeight = function(...) return listBoxClass:GetRowHeight(...) end
	listBoxClass.ListBoxControl.GetRowCount = function(...) return listBoxClass:GetRowCount(...) end
	listBoxClass.ListBoxControl.SelectRowByIndex = function(...) return listBoxClass:SelectRowByIndex(...) end
	listBoxClass.ListBoxControl.AllowManualDeselect = function(...) return listBoxClass:AllowManualDeselect(...) end

	listBoxClass.ListBoxControl:SetDrawTier(DT_HIGH)
	
	return listBoxClass.ListBoxControl
end