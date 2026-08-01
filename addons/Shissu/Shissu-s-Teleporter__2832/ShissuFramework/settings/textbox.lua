-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/textbox.lua
-- Version:     v1.0.4
-- Last Update: 29.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local _control = {}
_control.name = "textbox"
_control.version = "1.0.4"

-- einzeilige Textbox
function _control.textbox(parent, textBoxData)
  local control = createBaseControl(parent, textBoxData, nil)
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

ShissuFramework_Settings.registerControl(_control.name, _control.textbox)
ShissuFramework["templates"][_control.name] = 1