-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/slider.lua
-- Version:     v1.0.3
-- Last Update: 29.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local _control = {}
_control.name = "slider"
_control.version = "1.0.3"

-- Beschreibungen, Infotexte, ...
function _control.slider(parent, sliderData)
  local control = createBaseControl(parent, sliderData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(sliderData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)
	
  control.slider = CreateControl(nil, control, CT_SLIDER)
  control.slider:SetDimensions(190, 14)
  control.slider:SetMinMax(sliderData.minimum, sliderData.maximum)
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

	control.slider:SetValueStep(sliderData.steps)
	control.slider:SetHandler("OnValueChanged", function(self, value, eventReason)
		if eventReason == EVENT_REASON_SOFTWARE then return end
		self:SetValue(value)
		control.valueText:SetText("|c82FA58" .. value .. "|r")	
  end)

  if sliderData.tooltip == nil then
    sliderData.tooltip = sliderData.name
  end
    
  if sliderData.tooltip then 
    control.slider:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(control.slider, TOPRIGHT, sliderData.tooltip)
    end)
    
    control.slider:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
    end)   
  end
  
  if sliderData.getFunc then
    control.valueText:SetText(sliderData.getFunc)
    control.slider:SetValue(sliderData.getFunc)
  end
  
  if sliderData.setFunc then
	  control.slider:SetHandler("OnSliderReleased", function(self, value)
      sliderData.setFunc(value)
    end)  
  end
   
	return control
end

ShissuFramework_Settings.registerControl(_control.name, _control.slider)
ShissuFramework["templates"][_control.name] = 1