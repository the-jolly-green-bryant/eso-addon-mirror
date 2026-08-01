-- ZOS Objects
local ZO = {
  sm = SCENE_MANAGER,
  cm = CALLBACK_MANAGER,
}

local modulList = {}
local optionsMap = {}
local optionsCreated = {}                                     

local ShissuCreateControl = {}
local _settings = {}
local callbackRegistered = false

shissuModulMenu = {}

ShissuFramework_Settings = {}

-- CONTROLS
ShissuCreateControl.scrollCount = ShissuCreateControl.scrollCount or 1

local function RefreshPanel(control)
	local panel = control.panel or control
	local panelControls = panel.controlsToRefresh

	for i = 1, #panelControls do
		local updateControl = panelControls[i]
		if  updateControl ~= control then
			if updateControl.UpdateValue then
				updateControl:UpdateValue()
			end
			if updateControl.UpdateDisabled then
				updateControl:UpdateDisabled()
			end
		end
	end
end

function _settings.CreateModulList(name, parent)
	local modulList = CreateControlFromVirtual(name, parent, "ZO_ScrollList")

	local function modulListRow_OnMouseDown(control, button)
		if button == 1 then
			local data = ZO_ScrollList_GetData(control)
			ZO_ScrollList_SelectData(modulList, data, control)
		end
  end

	local function modulListRow_OnMouseEnter(control)
		ZO_ScrollList_MouseEnter(modulList, control)
	end

	local function modulListRow_OnMouseExit(control)
		ZO_ScrollList_MouseExit(modulList, control)
	end

	local function modulListRow_Select(previouslySelectedData, selectedData, reselectingDuringRebuild)
		if not reselectingDuringRebuild then
			if previouslySelectedData then
				previouslySelectedData.panel:SetHidden(true)
			end
			if selectedData then
				selectedData.panel:SetHidden(false)
			end
		end
	end

	local function modulListRow_Setup(control, data)
  	control:SetText(data.name)
		control:SetSelected(not data.panel:IsHidden())
	end
  
	ZO_ScrollList_AddDataType(modulList, 1, "ZO_SelectableLabel", 28, modulListRow_Setup)
	ZO_ScrollList_EnableHighlight(modulList, "ZO_ThinListHighlight")
	ZO_ScrollList_EnableSelection(modulList, "ZO_ThinListHighlight", modulListRow_Select)

	local modulDataType = ZO_ScrollList_GetDataTypeTable(modulList, 1)
	local modulListRow_CreateRaw = modulDataType.pool.m_Factory

	local function addonListRow_Create(pool)
		local control = modulListRow_CreateRaw(pool)
		control:SetHandler("OnMouseDown", modulListRow_OnMouseDown)
		control:SetHeight(28)
		control:SetFont("ZoFontHeader")
		control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		return control
	end

	modulDataType.pool.m_Factory = addonListRow_Create

	return modulList
end

local function UpdateValue(control)
	control.header:SetText(control.data.name)
end

-- EINZELNE ELEMENTE
-- Einstellungen: Standard Panel je AddOn
function ShissuCreateControl.panel(parent, panelData, controlName)
	local control = CreateControl(controlName, parent, CT_CONTROL)

	control.label = CreateControlFromVirtual(nil, control, "ZO_Options_SectionTitleLabel")
	local label = control.label
	label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 4)
	label:SetText(panelData.displayName or panelData.name)

  control.info = CreateControl(nil, control, CT_LABEL)
	local info = control.info
	info:SetFont("$(CHAT_FONT)|14|soft-shadow-thin")
	info:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, -2)
	info:SetText(string.format("Version: %s  -  %s: %s", panelData.version, GetString(SI_ADDON_MANAGER_AUTHOR), "|c82FA58@Shissu [EU-SERVER]"))

  control.feedback = CreateControlFromVirtual(nil, control, "ZO_DefaultButton")  
  control.feedback:SetWidth(200)
  control.feedback:SetText("|t36:36:EsoUI/Art/notifications/notification_cs.dds|tFeedback")
  control.feedback:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, -40 )
  control.feedback:SetHandler("OnClicked", function()
	  local function PrepareMail()
      MAIL_SEND.to:SetText("@Shissu")
      MAIL_SEND.subject:SetText(panelData.displayName .. " - Donation")
      MAIL_SEND.body:SetText("")
      MAIL_SEND:SetMoneyAttachmentMode()
      MAIL_SEND:AttachMoney(0, 1000)
    end

    MAIL_SEND:ClearFields()

    if (MAIL_SEND:IsHidden()) then
			MAIN_MENU_KEYBOARD:ShowScene("mailSend")
    	SCENE_MANAGER:CallWhen("mailSend", SCENE_SHOWN, PrepareMail)
    else
    	PrepareMail()
    end
  end)

	control.container = CreateControlFromVirtual("ShissuAddonPanelContainer"..ShissuCreateControl.scrollCount, control, "ZO_ScrollContainer")
	ShissuCreateControl.scrollCount = ShissuCreateControl.scrollCount + 1
	local container = control.container
	container:SetAnchor(TOPLEFT, control.info or label, BOTTOMLEFT, 0, 20)
	container:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -3, -3)
	control.scroll = GetControl(control.container, "ScrollChild")
	control.scroll:SetResizeToFitPadding(0, 20)

	control.data = panelData
	control.controlsToRefresh = {}

	return control
end

-- Standardelement 
function _settings.CreateBaseControl(parent, controlData, controlName)
	local control = CreateControl(controlName or controlData.reference, parent.scroll or parent, CT_CONTROL)

	control.panel = parent.panel or parent
	control.data = controlData

	control:SetWidth(control.panel:GetWidth() - 60)
	return control
end

-- Farbauswahl
function ShissuCreateControl.colorpicker(parent, colorData)
  local control = _settings.CreateBaseControl(parent, colorData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(colorData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)

  control.thumb = CreateControl(nil, control, CT_TEXTURE)
  control.thumb:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
  control.thumb:SetDimensions(36, 36)
  control.thumb:SetMouseEnabled(true)
  
  local function ColorPickerCallback(r, g, b, a)
    control.thumb:SetColor(r, g, b, a or 1)

    --d(r .. " - " .. g.. " - ".. b)

    if colorData.setFunc then
      colorData.setFunc(r, g, b, a or 1)
    end
  end
  
  if colorData.getFunc then
    local r, g, b, a = colorData.getFunc
    control.thumb:SetColor(colorData.getFunc[1], colorData.getFunc[2], colorData.getFunc[3], colorData.getFunc[4])
	end    

  control.thumb:SetHandler("OnMouseUp", function(self, btn, upInside)
    if self.isDisabled then return end

    if upInside then
      COLOR_PICKER:Show(ColorPickerCallback, r, g, b, a, colorData.name)
    end
  end)

	return control
end

-- �berschrift
function ShissuCreateControl.title(parent, titleData)
	local control = _settings.CreateBaseControl(parent, titleData, nil)
	local width = control:GetWidth()
	control:SetDimensions(width, 30)

	control.divider = CreateControlFromVirtual(nil, control, "ZO_Options_Divider")
	control.divider:SetWidth(width)
	control.divider:SetAnchor(TOPLEFT)

	control.header = CreateControlFromVirtual(nil, control, "ZO_Options_SectionTitleLabel")
	control.header:SetAnchor(TOPLEFT, control.divider, BOTTOMLEFT)
	control.header:SetAnchor(BOTTOMRIGHT)
	control.header:SetText(titleData.name)
  
	return control
end

-- DropDown Men�
function ShissuCreateControl.combobox(parent, dropdownData)
	local control = _settings.CreateBaseControl(parent, dropdownData, nil)
	local width = control:GetWidth()
	control:SetDimensions(width, 30)
  
  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(dropdownData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)

	control.combobox = CreateControlFromVirtual(dropdownData.name, control, "ZO_ComboBox")
	control.combobox:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
	control.combobox:SetDimensions(150, 30)
  control.combobox.dropdown = ZO_ComboBox_ObjectFromContainer(control.combobox)
  
  for i = 1, #dropdownData.items do
    control.combobox.dropdown:AddItem(control.combobox.dropdown:CreateItemEntry(dropdownData.items[i], dropdownData.setFunc))
  end

  if dropdownData.tooltip then 
    control.combobox:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(control.combobox, TOPRIGHT, dropdownData.tooltip)
    end)
    
    control.combobox:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)   
  end
 
  if dropdownData.getFunc then  
    control.combobox.dropdown:SetSelectedItem(dropdownData.getFunc)
  end 

	return control
end                                   


-- Checkbox AN/AUS
function ShissuCreateControl.checkbox(parent, checkboxData)
  local control = _settings.CreateBaseControl(parent, checkboxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(checkboxData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)
	
  control.checkbox = CreateControlFromVirtual(nil, control, "ZO_CheckButton")
  control.checkbox:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
  control.checkbox:SetDimensions(20, 20)
  
  if checkboxData.tooltip == nil then
    checkboxData.tooltip = checkboxData.name  
  end
    
  if checkboxData.tooltip then 
    control.checkbox:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(control.checkbox, TOPRIGHT, checkboxData.tooltip)
    end)
    
    control.checkbox:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)   
  end

  if checkboxData.getFunc then
    ZO_CheckButton_SetChecked(control.checkbox)
  end 
  
  if checkboxData.setFunc then
    ZO_CheckButton_SetToggleFunction(control.checkbox, checkboxData.setFunc)
  end
  
	return control
end

function ShissuCreateControl.sliderEditbox(parent, checkboxData)
  local control = _settings.CreateBaseControl(parent, checkboxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(checkboxData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)
	
  control.slider = CreateControl(nil, control, CT_SLIDER)
  control.slider:SetDimensions(190, 14)
  control.slider:SetMinMax(checkboxData.minimum, checkboxData.maximum)
  control.slider:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
 
  control.slider:SetMouseEnabled(true)
	control.slider:SetOrientation(ORIENTATION_HORIZONTAL)
  control.slider:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 8, 16) 
  control.slider:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(control) end)
	control.slider:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseExit(control) end)

	control.bg = CreateControl(nil, control.slider, CT_BACKDROP)
	control.bg:SetCenterColor(0, 0, 0)
	control.bg:SetAnchor(TOPLEFT, control.slider, TOPLEFT, 0, 4)
	control.bg:SetAnchor(BOTTOMRIGHT, control.slider, BOTTOMRIGHT, 0, -4)
	control.bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 8)

	control.container = CreateControl(nil, control.slider, CT_CONTROL)
  control.container:SetDimensions(80, 26)
	control.container:SetAnchor(TOPRIGHT, control.slider, TOPRIGHT, 105, -5)

	control.containerbg = CreateControlFromVirtual(nil, control.container, "ZO_EditBackdrop")
	control.containerbg:SetAnchorFill()
  
  control.valueText = CreateControlFromVirtual(nil, control.containerbg, "ZO_DefaultEditForBackdrop")--"ZO_DefaultEditForBackdrop")
	control.valueText:SetMaxInputChars(7)
	control.valueText:SetText("0")

	control.valueText:SetHandler("OnTextChanged", function()
		local value = tonumber(control.valueText:GetText())

		if (value ~= nil) then
  		if (value > checkboxData.maximum) then
				control.slider:SetValue(checkboxData.maximum)
			elseif ( value <= checkboxData.minimum) then
				control.slider:SetValue(checkboxData.minimum)
			else 
				control.slider:SetValue(tonumber(control.valueText:GetText()))
			end
		else
			control.valueText:SetText(control.slider:GetValue())	
		end

		checkboxData.setFunc(value)
	end)  

	control.slider:SetValueStep(checkboxData.steps)
	control.slider:SetHandler("OnValueChanged", function(self, value, eventReason)
			if eventReason == EVENT_REASON_SOFTWARE then return end
			self:SetValue(value)
			control.valueText:SetText(value)	
  end)

  if checkboxData.tooltip == nil then
    checkboxData.tooltip = checkboxData.name
  end
    
  if checkboxData.tooltip then 
    control.slider:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(control.slider, TOPRIGHT, checkboxData.tooltip)
    end)
    
    control.slider:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)   
  end
  
  if checkboxData.getFunc then
    control.valueText:SetText(checkboxData.getFunc)
    control.slider:SetValue(checkboxData.getFunc)
  end
  
  if checkboxData.setFunc then
    control.slider:SetHandler("OnSliderReleased", function(self, value)
      checkboxData.setFunc(value)
    end)  
  end
   
	return control
end

-- Textbox
function ShissuCreateControl.editbox(parent, editboxData)
  local control = _settings.CreateBaseControl(parent, editboxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(editboxData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)
	
  control.container = CreateControl(nil, control, CT_CONTROL)
  control.container:SetDimensions(width / 3, 26)
	control.container:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
  
	control:SetMouseEnabled(true)
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	control.bg = CreateControlFromVirtual(nil, control.container, "ZO_EditBackdrop")
	control.bg:SetAnchorFill()
  
  control.editbox = CreateControlFromVirtual(nil, control.bg, "ZO_DefaultEditMultiLineForBackdrop")--"ZO_DefaultEditForBackdrop")
	control.editbox:SetMaxInputChars(3000)
  control.editbox:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(control) end)
	
  control.editbox:SetHandler("OnEscape", function(self) self:LoseFocus() end)
  control.editbox:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(control) end)	
  
	local width = control.container:GetWidth()
	local height = 100
  local value = control.editbox:GetText()
  
  control.container:SetHeight(height)
	control.editbox:SetDimensionConstraints(width, height, width, 500)
  control:SetHeight(height)

  if editboxData.getFunc then
    control.editbox:SetText(editboxData.getFunc)
  end 
  
  if editboxData.setFunc then   
    control.editbox:SetHandler("OnTextChanged", function()
      editboxData.setFunc(control.editbox:GetText())
    end)  
  end

	return control
end

-- Guild Checkbox Settings
function ShissuCreateControl.guildCheckbox(parent, checkboxData)
  local control = _settings.CreateBaseControl(parent, checkboxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 90)

  if (checkboxData.name) then
    control.label = CreateControl(nil, control, CT_LABEL)
    control.label:SetFont("ZoFontGame")
    control.label:SetText(checkboxData.name)
  	control.label:SetWidth(width-100)
    control.label:SetAnchor(TOPLEFT)
  end

  local numGuild = GetNumGuilds()
  control.guildLabel = {}
  control.checkbox = {}
  
  for guildId = 1, numGuild do
    guildId = GetGuildId(guildId)
    local guildName = GetGuildName(guildId)

    control.guildLabel[guildId] = CreateControl(nil, control, CT_LABEL)
    control.guildLabel[guildId]:SetFont("ZoFontGame")
    control.guildLabel[guildId]:SetText(guildName)
    control.guildLabel[guildId]:SetWidth(100)
    control.guildLabel[guildId]:SetHeight(30)
    
    if (guildId == 1) then
      control.guildLabel[guildId]:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 30)   
    else
      control.guildLabel[guildId]:SetAnchor(TOPRIGHT, control.guildLabel[guildId-1], TOPRIGHT, 120, 0)   
    end        
    
    control.checkbox[guildId] = CreateControlFromVirtual(nil, control, "ZO_CheckButton")
    control.checkbox[guildId]:SetAnchor(TOPLEFT, control.guildLabel[guildId], TOPLEFT, 35, 30)
    control.checkbox[guildId]:SetDimensions(20, 20)
    
    control.checkbox[guildId]:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(control.checkbox[guildId], TOPRIGHT, guildName)
    end)
    
    control.checkbox[guildId]:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end) 
    
    if checkboxData.saveVar then 
      if checkboxData.saveVar[guildName] == true then   
        ZO_CheckButton_SetChecked(control.checkbox[guildId])
      end
      
      ZO_CheckButton_SetToggleFunction(control.checkbox[guildId], function(_, value) 
        checkboxData.saveVar[guildName] = value
          
        if (checkboxData.setFunc) then
          checkboxData.setFunc(value, guildName)  
        end
      end)
    end       
  end
  
	return control
end  

-- Textbox Klein
function ShissuCreateControl.textbox(parent, textBoxData)
  local control = _settings.CreateBaseControl(parent, textBoxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(textBoxData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)

  control.container = CreateControl(nil, control, CT_CONTROL)
  control.container:SetDimensions(width / 3, 26)
	control.container:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
  
	control:SetMouseEnabled(true)
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	control.bg = CreateControlFromVirtual(nil, control.container, "ZO_EditBackdrop")
	control.bg:SetAnchorFill()
  
  control.textbox = CreateControlFromVirtual(nil, control.bg, "ZO_DefaultEditForBackdrop")--"ZO_DefaultEditForBackdrop")
	control.textbox:SetMaxInputChars(3000)
  control.textbox:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(control) end)

  control.textbox:SetHandler("OnEscape", function(self) self:LoseFocus() end)
  control.textbox:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(control) end)	

  if textBoxData.tooltip then 
    control.textbox:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(control.textbox, TOPRIGHT, textBoxData.tooltip)
    end)
    
    control.textbox:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)   
  end
  
	local width = control.container:GetWidth()
	local height = 30
  local value = control.textbox:GetText()

  control.container:SetHeight(height)
	control.textbox:SetDimensionConstraints(width, height, width, 500)
  control:SetHeight(height)

  if textBoxData.getFunc then
    control.textbox:SetText(textBoxData.getFunc)
  end 

  if textBoxData.setFunc then   
    control.textbox:SetHandler("OnTextChanged", function() 
      textBoxData.setFunc(control.textbox:GetText(), textBoxData.name)
    end)  
  end

	return control
end

function ShissuCreateControl.slider(parent, checkboxData)
  local control = _settings.CreateBaseControl(parent, checkboxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(checkboxData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)
	
  control.slider = CreateControl(nil, control, CT_SLIDER)
  control.slider:SetDimensions(190, 14)
  control.slider:SetMinMax(checkboxData.minimum, checkboxData.maximum)
  control.slider:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
 
  control.slider:SetMouseEnabled(true)
	control.slider:SetOrientation(ORIENTATION_HORIZONTAL)
  control.slider:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 8, 16) 
  control.slider:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(control) end)
	control.slider:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseExit(control) end)

	control.bg = CreateControl(nil, control.slider, CT_BACKDROP)
	control.bg:SetCenterColor(0, 0, 0)
	control.bg:SetAnchor(TOPLEFT, control.slider, TOPLEFT, 0, 4)
	control.bg:SetAnchor(BOTTOMRIGHT, control.slider, BOTTOMRIGHT, 0, -4)
	control.bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 8)

	control.valueText = CreateControl(nil, control.slider, CT_LABEL)
	control.valueText:SetFont("ZoFontGame")
	control.valueText:SetAnchor(TOPRIGHT, control.slider, TOPRIGHT, 40, -5 )
	control.valueText:SetText("0")

	control.slider:SetValueStep(checkboxData.steps)
	control.slider:SetHandler("OnValueChanged", function(self, value, eventReason)
			if eventReason == EVENT_REASON_SOFTWARE then return end
			self:SetValue(value)
			control.valueText:SetText("|c82FA58" .. value .. "|r")	
  end)

  if checkboxData.tooltip == nil then
    checkboxData.tooltip = checkboxData.name
  end
    
  if checkboxData.tooltip then 
    control.slider:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(control.slider, TOPRIGHT, checkboxData.tooltip)
    end)
    
    control.slider:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)   
  end

  
  if checkboxData.getFunc then
    control.valueText:SetText(checkboxData.getFunc)
    control.slider:SetValue(checkboxData.getFunc)
  end
  
  if checkboxData.setFunc then
    control.slider:SetHandler("OnSliderReleased", function(self, value)
      checkboxData.setFunc(value)
    end)  
  end
   
	return control
end

-- Beschreibung, Infotext
function ShissuCreateControl.description(parent, descriptionData)
	local control = _settings.CreateBaseControl(parent, descriptionData, nil)
	local width = control:GetWidth()
	control:SetResizeToFitDescendents(true)
  control:SetDimensionConstraints(width, 26, width, 26 * 4)

	control.desc = CreateControl(nil, control, CT_LABEL)
	control.desc:SetVerticalAlignment(TEXT_ALIGN_TOP)
	control.desc:SetFont("ZoFontGame")
	control.desc:SetText(descriptionData.text)
	control.desc:SetWidth(width)
  control.desc:SetAnchor(TOPLEFT)
	
	--control.UpdateValue = UpdateValue

	return control
end
         
function _settings.CreateOptionsControls(panel)
	local modulId = panel:GetName()
	local optionsTable = optionsMap[modulId]

	if optionsTable then
		local function CreateAndAnchorWidget(parent, widgetData, offsetX, offsetY, anchorTarget, wasHalf)
			local widget
			local status, err = pcall(function() widget = ShissuCreateControl[widgetData.type](parent, widgetData) end)
			if not status then
				return err or true, offsetY, anchorTarget, wasHalf
			else
				if not anchorTarget then 
					widget:SetAnchor(TOPLEFT)
					anchorTarget = widget
				else
					widget:SetAnchor(TOPLEFT, anchorTarget, BOTTOMLEFT, 0, 15 + offsetY)
					offsetY = 0
					anchorTarget = widget
				end
				return false, offsetY, anchorTarget
			end
		end

		local THROTTLE_TIMEOUT, THROTTLE_COUNT = 10, 20
		local fifo = {}
		local anchorOffset, lastAddedControl, wasHalf
		local CreateWidgetsInPanel, err

		local function PrepareForNextPanel()
			anchorOffset, lastAddedControl, wasHalf = 0, nil, false
		end

		local function SetupCreationCalls(parent, widgetDataTable)
			fifo[#fifo + 1] = PrepareForNextPanel
			local count = #widgetDataTable
			for i = 1, count, THROTTLE_COUNT do
				fifo[#fifo + 1] = function()
          local startIndex = i
          local endIndex = zo_min(i + THROTTLE_COUNT - 1, count)
          
          for i=startIndex,endIndex do
            local widgetData = widgetDataTable[i]
				  
            if widgetData then
              local widgetType = widgetData.type
					    local offsetX = 0

					    err, anchorOffset, lastAddedControl, wasHalf = CreateAndAnchorWidget(parent, widgetData, offsetX, anchorOffset, lastAddedControl, wasHalf)
				    end
			    end           
				end
			end
		end

		local function DoCreateSettings()
			if #fifo > 0 then
				local nextCall = table.remove(fifo, 1)
				nextCall()
				if(nextCall == PrepareForNextPanel) then
					DoCreateSettings()
				else
					zo_callLater(DoCreateSettings, THROTTLE_TIMEOUT)
				end
			else
				optionsCreated[modulId] = true
				ZO.cm:FireCallbacks("SHISSU-PanelControlsCreated", panel)
			end
		end

    SetupCreationCalls(panel, optionsTable)
		DoCreateSettings()
	end
end           

function _settings.ToggleAddonPanels(panel)
	local currentlySelected = shissuModulMenu.currentAddonPanel
  
	if currentlySelected and currentlySelected ~= panel then
		currentlySelected:SetHidden(true)
	end
  
	shissuModulMenu.currentAddonPanel = panel

	ZO_ScrollList_RefreshVisible(shissuModulMenu.addonList)

	if not optionsCreated[panel:GetName()] then
		_settings.CreateOptionsControls(panel)
	end

	ZO.cm:FireCallbacks("Shissu-RefreshPanel", panel)
end


-- Shissu's top-level Einstellungen / Fenster
function _settings.CreateAddonSettingsWindow()
  local tlw = CreateTopLevelWindow("ShissuAddonSettingsWindow")
	tlw:SetHidden(true)
	tlw:SetDimensions(1010, 914) -- same height as ZO_OptionsWindow

	ZO_ReanchorControlForLeftSidePanel(tlw)

	local bgLeft = CreateControl("$(parent)BackgroundLeft", tlw, CT_TEXTURE)
	bgLeft:SetTexture("EsoUI/Art/Miscellaneous/rightpanel_bg_right.dds")
	bgLeft:SetDimensions(1000, 1000)
	bgLeft:SetAnchor(TOPLEFT, nil, TOPLEFT, 40, 60)
	bgLeft:SetDrawLayer(DL_BACKGROUND)
	bgLeft:SetExcludeFromResizeToFitExtents(true)

	local title = CreateControl("$(parent)Title", tlw, CT_LABEL)
	title:SetAnchor(TOPLEFT, nil, TOPLEFT, 65, 80)
	title:SetFont("ZoFontWinH1")
	title:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)

	local divider = CreateControlFromVirtual("$(parent)Divider", tlw, "ZO_Options_Divider")
	divider:SetAnchor(TOPLEFT, nil, TOPLEFT, 65, 120)
  divider:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 65, 120)  
  divider:SetColor(0.2705882490, 0.5725490451, 1, 1)
                                                    
	local addonList = _settings.CreateModulList("$(parent)AddonList", tlw)
	addonList:SetAnchor(TOPLEFT, nil, TOPLEFT, 65, 140)
	addonList:SetDimensions(285, 665)

	shissuModulMenu.addonList = addonList
  
	local panelContainer = CreateControl("$(parent)PanelContainer", tlw, CT_CONTROL)
	panelContainer:SetAnchor(TOPLEFT, nil, TOPLEFT, 365, 120)
	panelContainer:SetDimensions(645, 675)

	return tlw
end


local hasInitialize = false

function _settings.CheckInitialize(modulId)
  if not hasInitialize then
    hasInitialize = true
  end
end

function _settings.PopulateAddonList(addonList, filter)
	local entryList = ZO_ScrollList_GetDataList(addonList)
	local numEntries = 0
	local selectedData = nil

	ZO_ScrollList_Clear(addonList)

	for i, data in ipairs(modulList) do
		if not filter or filter(data) then
			local dataEntry = ZO_ScrollList_CreateDataEntry(1, data)
			numEntries = numEntries + 1
			data.sortIndex = numEntries
			entryList[numEntries] = dataEntry

			if selectedData == nil or data.panel == shissuModulMenu.currentAddonPanel then
				selectedData = data
			end
		else
			data.sortIndex = nil
		end
	end

	ZO_ScrollList_Commit(addonList)

	if selectedData then
		if selectedData.panel == shissuModulMenu.currentAddonPanel then
			ZO_ScrollList_SelectData(addonList, selectedData, nil, RESELECTING_DURING_REBUILD)
		else
			ZO_ScrollList_SelectData(addonList, selectedData, nil)
		end
	end
end

function _settings.CreateAddonSettingsMenuEntry()
	local panelData = {
		id = KEYBOARD_OPTIONS.currentPanelId,
		name = "|c82FA58Shissu|ceeeeee's AddOns",
	}

	KEYBOARD_OPTIONS.currentPanelId = panelData.id + 1
	KEYBOARD_OPTIONS.panelNames[panelData.id] = panelData.name

	shissuModulMenu.panelId = panelData.id

  function panelData.callback()
    ZO.sm:AddFragment(_settings.GetModulSettingsFragment())
		KEYBOARD_OPTIONS:ChangePanels(shissuModulMenu.panelId)

		local title = ShissuAddonSettingsWindow:GetNamedChild("Title")
		title:SetText(panelData.name)
	   
    table.sort(modulList, function(a, b) return a.name < b.name end)
		_settings.PopulateAddonList(shissuModulMenu.addonList)
  end

	function panelData.unselectedCallback()
    ZO.sm:RemoveFragment(_settings.GetModulSettingsFragment())
    
    if SetCameraOptionsPreviewModeEnabled then 
      SetCameraOptionsPreviewModeEnabled(false)
    end
	end

	ZO_GameMenu_AddSettingPanel(panelData)
end

function _settings.GetModulSettingsFragment()
	assert(hasInitialize)
	if not ShissuAddonSettingsFragment then
		local window = _settings.CreateAddonSettingsWindow()
		ShissuAddonSettingsFragment = ZO_FadeSceneFragment:New(window, true, 100)
		_settings.CreateAddonSettingsMenuEntry()
	end
  
	return ShissuAddonSettingsFragment
end

local function GetModulPanelContainer()
	local fragment = _settings.GetModulSettingsFragment()
	local window = fragment:GetControl()
	return window:GetNamedChild("PanelContainer")
end


-- GLOBALE AUFRUFFUNKTIONEN
-- Einstellungen | Standardpanel pro AddOn /& Modul anlegen
function ShissuFramework_Settings.RegisterAddonPanel(modulId, panelData, optionsTable)
	_settings.CheckInitialize(modulId)
  
	local container = GetModulPanelContainer()
	local panel = ShissuCreateControl.panel(container, panelData, modulId)
	panel:SetHidden(true)
	panel:SetAnchorFill(container)
	panel:SetHandler("OnShow", _settings.ToggleAddonPanels)

	local modulData = {
		panel = panel,
		name = "|ceeeeee" .. panelData.name .. "|r",
	}

	table.insert(modulList, modulData)
  
  optionsMap[modulId] = optionsTable
end