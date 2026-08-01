local windowId = 1
local DEFAULT_WIDTH = 800
local DEFAULT_HEIGHT = 367
local AUI_LOAD_WINDOW_HEADER_TEXT_COLOR = "#b8b594"

local AUI_OpenDataDialog = ZO_Object:Subclass()
function AUI_OpenDataDialog:New(_name, _parent, _headerText)
	local manager = ZO_Object.New(self)

	manager.window = CreateControlFromVirtual(_name, _parent, "AUI_LoadWindow")
	manager.listBox = AUI.CreateListBox(_name .. "_ListBox" .. windowId, manager.window, true, true)
	manager.name = _name
	manager.parent = _parent
	manager.headerText = _headerText

    manager:Initialize()	

    return manager								
end

function AUI_OpenDataDialog:Show()
	self.window:SetHidden(false)
end

function AUI_OpenDataDialog:Close()
	self.window:SetHidden(true)
end

function AUI_OpenDataDialog:SetLoadButtonCallback(_self, _callback)
	self.loadButtonCallback = _callback
end

function AUI_OpenDataDialog:LoadSelectedData()
	local selectedRowControl = self.listBox:GetSelectedRowControl()
	
	if selectedRowControl and self.loadButtonCallback then
		self.loadButtonCallback(selectedRowControl)	
	end
end

function AUI_OpenDataDialog:Initialize()
	self.window:ClearAnchors()
	self.window:SetAnchor(CENTER, self.parent, CENTER, 0, 0)
	self.window:SetParent(GuiRoot)
	self.window:SetMovable(true)
			
	self.listBox:ClearAnchors()
	self.listBox:SetAnchor(TOP, self.window, TOP, 0, 40)
	self.listBox:EnableMouseHover()
	self.listBox:EnableMouseSelection()
	self.listBox:AllowManualDeselect(true)
	
	local closeButtonControl = GetControl(self.window, "_CloseButton")
	
	closeButtonControl:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
	closeButtonControl:SetPressedTexture("ESOUI/art/buttons/decline_down.dds")
	closeButtonControl:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")
	closeButtonControl:SetHandler("OnClicked", function() self:Close() end)		

	self:SetDimensions(DEFAULT_WIDTH, DEFAULT_HEIGHT)
	
	local headerTextControl = GetControl(self.window, "_HeaderText")
	headerTextControl:SetColor(AUI.Color.ConvertHexToRGBA(AUI_LOAD_WINDOW_HEADER_TEXT_COLOR, 1):UnpackRGBA())
	headerTextControl:SetText(self.headerText)	

	local openDataButtonControl = GetControl(self.window, "_OpenDataButton")
	openDataButtonControl:SetHandler("OnClicked", function() self:LoadSelectedData() end)	
	
	local openDataButtonTextControl = GetControl(self.window, "_OpenDataButton_Text")
	
	openDataButtonTextControl:SetFont("$(MEDIUM_FONT)|" ..  18 .. "|" .. "outline")	
	openDataButtonTextControl:SetText(AUI.L10n.GetString("load"))
	openDataButtonTextControl:SetColor(AUI.Color.ConvertHexToRGBA(AUI_LOAD_WINDOW_HEADER_TEXT_COLOR, 1):UnpackRGBA())	
end

function AUI_OpenDataDialog:SetDimensions(width, height)
	self.width = width
	self.height = height

	self.window:SetDimensions(width, height)
	self.listBox:SetDimensions(width, height - 94)		
end

function AUI.CreateOpenDataDialog(_name, _parent, _headerText)	
	local openDataDialog = AUI_OpenDataDialog:New(_name, _parent, _headerText)
	openDataDialog.window.SetItemList = function(...) openDataDialog.listBox.SetItemList(...) end
	openDataDialog.window.Show = function(...) openDataDialog:Show(...) end
	openDataDialog.window.Refresh = function(...) openDataDialog.listBox.Refresh(...) end
	openDataDialog.window.SetColumnList = function(...) openDataDialog.listBox.SetColumnList(...) end
	openDataDialog.window.Close = function(...) openDataDialog:Close(...) end
	openDataDialog.window.SetRowMouseDoubleClickCallback = function(...) openDataDialog.listBox.SetRowMouseDoubleClickCallback(...) end
	openDataDialog.window.SetSortKey = function(...) openDataDialog.listBox.SetSortKey(...) end
	openDataDialog.window.SetRowMouseUpCallback = function(...) openDataDialog.listBox.SetRowMouseUpCallback(...) end
	openDataDialog.window.SetLoadButtonCallback = function(...) openDataDialog:SetLoadButtonCallback(...) end

	windowId = windowId + 1
	
	return openDataDialog.window
end