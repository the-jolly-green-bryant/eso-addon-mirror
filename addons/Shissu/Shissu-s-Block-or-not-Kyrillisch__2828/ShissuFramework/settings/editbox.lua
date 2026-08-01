-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/editbox.lua
-- Version:     v1.0.6
-- Last Update: 14.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local _control = {}
_control.name = "editbox"
_control.version = "1.0.6"

-- Textbox, um eine längere Variable, einen Text zu speichern, z.B. für die Willkommennachrichten vom SGT-Modul: ShissuWelcome, über mehrere Zeilen
function _control.editbox(parent, editboxData)
  local control = createBaseControl(parent, editboxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(editboxData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)
	
  control.container = CreateControl(nil, control, CT_CONTROL)
  control.container:SetDimensions(width / 2.1, 26)
	control.container:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
  
	control:SetMouseEnabled(true)
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	control.bg = CreateControlFromVirtual(nil, control.container, "ZO_EditBackdrop")
	control.bg:SetAnchorFill()
  
  control.editbox = CreateControlFromVirtual(nil, control.bg, "ZO_DefaultEditMultiLineForBackdrop")
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

ShissuFramework_Settings.registerControl(_control.name, _control.editbox)
ShissuFramework["templates"][_control.name] = 1