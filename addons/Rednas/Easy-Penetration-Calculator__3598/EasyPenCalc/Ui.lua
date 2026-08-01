EPC = EPC or {}
EPC.UI = EPC.UI or {}

----------------------------------------------------------
-- CHECKBOX / CHECKBUTTON
----------------------------------------------------------
function EPC.UI.CreateCheckbutton(data)
	assert(data, "No data parameters for the function")
	assert(data.name, "No data.name parameters for the function")
	assert(data.parent, "No data.parent parameters for the function")
	
	--Set defaults for data
	data.labelText = data.labelText or "Checkbox labelText"
	data.anchor = data.anchor or {}
	data.anchor.point = data.anchor.point or TOPLEFT
	data.anchor.relativePoint = data.anchor.relativePoint or BOTTOMLEFT
	data.anchor.relativeTo = data.anchor.relativeTo or data.parent
	data.anchor.offsetX = data.anchor.offsetX or 0
	data.anchor.offsetY = data.anchor.offsetY or 0
	
	
	--Create the control itself and set anchor
	local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_CheckbuttonContainer"..data.name, data.parent, "EPCCheckbuttonContainer")
	control:ClearAnchors()
	control:SetAnchor(data.anchor.point, data.anchor.relativeTo, data.anchor.relativePoint, data.anchor.offsetX, data.anchor.offsetY) 
	
	--Set Control MetaData
	control.label = control:GetNamedChild("CheckbuttonLabel")
	control.checkbutton = control:GetNamedChild("Checkbutton")
	control.checkbuttonText = control.checkbutton:GetNamedChild("Text")
	control.name = data.name
	
	--Do label stuff
	control.label:SetText(data.labelText)
	if data.tooltipText ~= nil then
		EPC.UI.SetTooltip(control.label, data.labelText, data.tooltipText)
	end
	
	--Create Form Field table
	EPC.FormField[data.name] = {}
	local FormField = EPC.FormField[data.name]
	FormField.value = data.default or false
	FormField.control = control
	function FormField:Refresh()
		EPC.UI.UpdateCheckbutton(control) 
	end
	
	--Do Checkbox stuff
	EPC.UI.UpdateCheckbutton(control)
	control.checkbutton:SetHandler("OnClicked", 
		function(self)
			local contr = {}
			contr = self:GetParent()
			
			EPC.FormField[contr.name].value = not EPC.FormField[contr.name].value
			
			EPC.UI.UpdateCheckbutton(contr)
			
			EPC.PEN.UpdateSummaryValues()
		end
	)
	
	return control
end

function EPC.UI.UpdateCheckbutton(control)
	local buttonColor, labelColor = {}
	buttonColor 		= EPC.FormField[control.name].value and EPC.GUI.Color.checkButtonActive or EPC.GUI.Color.checkButtonInactive -- select Correct Color
	labelColor 			= EPC.FormField[control.name].value and EPC.GUI.Color.white 			or EPC.GUI.Color.grey -- select Correct Color
	local buttonText 	= EPC.FormField[control.name].value and "Active" 						or "Inactive" -- select Correct text
	
	control.checkbuttonText:SetColor(EPC.Util.GetEsoRGBColorCodeFromArray(buttonColor)) -- update color
	control.label:SetColor(EPC.Util.GetEsoRGBColorCodeFromArray(labelColor)) -- update color
	control.checkbuttonText:SetText(buttonText)
end

function EPC.UI.UpdateCheckButtonHighlight(control, over)
	local currentColor = {}
	if over then
		currentColor = EPC.FormField[control.name].value and EPC.GUI.Color.checkButtonActiveHighlight or EPC.GUI.Color.checkButtonInactiveHighlight -- select Correct Color
	else 
		currentColor = EPC.FormField[control.name].value and EPC.GUI.Color.checkButtonActive or EPC.GUI.Color.checkButtonInactive -- select Correct Color
	end
	control.checkbuttonText:SetColor(EPC.Util.GetEsoRGBColorCodeFromArray(currentColor)) -- update color
end

----------------------------------------------------------
-- COMBOBOX / DROPDOWN
----------------------------------------------------------
function EPC.UI.CreateCombobox(data, options)
	assert(options, "No options parameters for the function")
	assert(data, "No data parameters for the function")
	assert(data.name, "No data.name parameters for the function")
	assert(data.parent, "No data.parent parameters for the function")

	--Set defaults for data
	data.labelText = data.labelText or "Checkbox labelText"
	data.anchor = data.anchor or {}
	data.anchor.point = data.anchor.point or TOPLEFT
	data.anchor.relativePoint = data.anchor.relativePoint or BOTTOMLEFT
	data.anchor.relativeTo = data.anchor.relativeTo or data.parent
	data.anchor.offsetX = data.anchor.offsetX or 0
	data.anchor.offsetY = data.anchor.offsetY or 0
	
	--Create the control itself and set anchor
	local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_ComboboxContainer"..data.name, data.parent, "EPCComboboxContainer")
	control:ClearAnchors()
	control:SetAnchor(data.anchor.point, data.anchor.relativeTo, data.anchor.relativePoint, data.anchor.offsetX, data.anchor.offsetY) 
	
	--Do label stuff
	control.label = control:GetNamedChild("ComboboxLabel")
	control.label:SetText(data.labelText)
	if data.tooltipText ~= nil then
		EPC.UI.SetTooltip(control.label, data.labelText, data.tooltipText)
	end
	
	--Do Combobox stuff
	control.controlCombobox = control:GetNamedChild("Combobox")
	local m_comboBox = control.controlCombobox.m_comboBox
    m_comboBox:SetSortsItems(false)
	
	--Create Form Field table
	EPC.FormField[data.name] = {}
	local FormField = EPC.FormField[data.name]
	FormField.value = data.default or false
	FormField.control = control
	function FormField:Refresh()
		local m_comboBox = self.control.controlCombobox.m_comboBox
		local m_sortedItems = m_comboBox.m_sortedItems
		local currentValue = self.value
		local item = {}
		for k, v in pairs(m_sortedItems) do
			if v.value == currentValue then
				item = v
				break
			end
		end
		m_comboBox:SelectItem(item, true)
		EPC.UI.UpdateCombobox(control, item.isInactive) 
	end
	
	--Fill combobox
	local function ItemSelectCallback(comboBox, itemName, item, selectionChanged)
		--Update Color of label
		EPC.UI.UpdateCombobox(control, item.isInactive)
		
		--Save new selection
        EPC.FormField[data.name].value = item.value
		EPC.PEN.UpdateSummaryValues()
    end
	
	local defaultIndex = 1
	for k,option in ipairs(options) do
		local itemData = option
		itemData.callback = ItemSelectCallback
		m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
		
		--Check if default value
		if option.value == EPC.FormField[data.name].value then
			defaultIndex = k
		end
	end
	
	-- select default item
    m_comboBox:SelectItem(options[defaultIndex], true)
	EPC.UI.UpdateCombobox(control, options[defaultIndex].isInactive)
	
	return control
end

function EPC.UI.UpdateCombobox(control, isInactive)
	local labelColor = {}
	local alpha = isInactive and 0.70 or 1
	local selectedItemText = control.controlCombobox:GetNamedChild("SelectedItemText")
	local bg = control.controlCombobox:GetNamedChild("BG")
	
	labelColor = isInactive and EPC.GUI.Color.grey or EPC.GUI.Color.white -- select Correct Color
	control.label:SetColor(EPC.Util.GetEsoRGBColorCodeFromArray(labelColor)) -- update color
	selectedItemText:SetColor(EPC.Util.GetEsoRGBColorCodeFromArray(labelColor)) -- update color
	bg:SetAlpha(alpha)
end

----------------------------------------------------------
-- OTHERS
----------------------------------------------------------
function EPC.UI.CreateSummaryLine(data)
	assert(data, "No data parameters for the function")
	assert(data.name, "No data.name parameters for the function")
	assert(data.parent, "No data.parent parameters for the function")
	
	data.labelText = data.labelText or "DefaultLabelText"
	data.labelNumber = data.labelNumber or "18.200"
	data.anchor = data.anchor or {}
	data.anchor.point = data.anchor.point or TOPLEFT
	data.anchor.relativePoint = data.anchor.relativePoint or BOTTOMLEFT
	data.anchor.relativeTo = data.anchor.relativeTo or data.parent
	data.anchor.offsetX = data.anchor.offsetX or 0
	data.anchor.offsetY = data.anchor.offsetY or 0
	
	local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_SummaryLine"..data.name, data.parent, "EPCSummaryTextRow")
	control:ClearAnchors()
	control:SetAnchor(data.anchor.point, data.anchor.relativeTo, data.anchor.relativePoint, data.anchor.offsetX, data.anchor.offsetY) 
	
	--Do label stuff
	control.numberLabel = control:GetNamedChild("Number")
	control.numberLabel:SetText(data.labelNumber)
	if data.numberColor ~= nil then
		control.numberLabel:SetColor(EPC.Util.GetEsoRGBColorCodeFromArray(data.numberColor))
	end
	
	control.label = control:GetNamedChild("Label")
	control.label:SetText(data.labelText)
	if data.tooltipText ~= nil then
		EPC.UI.SetTooltip(control.label, data.labelText, data.tooltipText)
	end
	
	return control
end

function EPC.UI.CreateWindowHeader(data)
	assert(data, "No data parameters for the function")
	assert(data.name, "No data.name parameters for the function")
	assert(data.parent, "No data.parent parameters for the function")
	
	data.labelText = data.labelText or "DefaultLabelText"
	data.anchor = data.anchor or {}
	data.anchor.point = data.anchor.point or TOPLEFT
	data.anchor.relativePoint = data.anchor.relativePoint or BOTTOMLEFT
	data.anchor.relativeTo = data.anchor.relativeTo or data.parent
	data.anchor.offsetX = data.anchor.offsetX or 0
	data.anchor.offsetY = data.anchor.offsetY or 0
	
	local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_WindowHeader"..data.name, data.parent, "EPCWindowHeader")
	control:ClearAnchors()
	control:SetAnchor(data.anchor.point, data.anchor.relativeTo, data.anchor.relativePoint, data.anchor.offsetX, data.anchor.offsetY) 
	control:SetText(data.labelText)
	
	return control	
end

function EPC.UI.CreateSummaryDivider(parent)
	local line  = CreateControlFromVirtual(nil, parent,  "ZO_HorizontalDivider")
	line:SetAnchor(TOPLEFT, parent, BOTTOMLEFT, -40, 2)
	line:SetAnchor(TOPRIGHT, parent, BOTTOMRIGHT, 40, 2)
	
	return line
end

----------------------------------------------------------
-- SHARED USE
----------------------------------------------------------
function EPC.UI.SetTooltip(control, title, text)
	local title = title or ""
	local text = text or ""

	control:SetMouseEnabled(true)
	control:SetHandler("OnMouseEnter", function()
		InitializeTooltip(EPC_Tooltip, control, TOP, -5)
		EPC_Tooltip:SetFont("EPCFontNormal")
		EPC_Tooltip:AddLine(title, "", ZO_NORMAL_TEXT:UnpackRGBA())
		EPC_Tooltip:AddLine(text)
	end)
	control:SetHandler("OnMouseExit", function()
		ClearTooltip(EPC_Tooltip)
	end)
end
