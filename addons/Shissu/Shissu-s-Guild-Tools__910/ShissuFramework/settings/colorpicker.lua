-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/colorpicker.lua
-- Version:     v1.1.0
-- Last Update: 17.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local registerForUpdate = ShissuFramework["functions"]["settings"].registerForUpdate

local _control = {}
_control.name = "colorpicker"
_control.version = "1.1.0"

local function UpdateValue(control)
  if (control.index) then
    local color = shissuColor["c" .. control.index]
    
    control.saved = {color[1], color[2], color[3]}
    control.thumb:SetColor(color[1], color[2], color[3])
  end
end

-- Farbauswahl
function _control.colorpicker(parent, colorData)
  local control = createBaseControl(parent, colorData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.UpdateValue = UpdateValue
  control.index = colorData.index
  control.saved = colorData.getFunc
  control.updateAllowed = colorData.updateAllowed

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(colorData.name)
  control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)

  control.backdrop = CreateControl(nil, control, CT_BACKDROP)
  control.backdrop:SetDimensions(40, 40)
  control.backdrop:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
  control.backdrop:SetCenterColor( 0.2, 0.2, 0.2, 0.66 )
  control.backdrop:SetEdgeColor( 0.2, 0.2, 0.2, 0.4 )
  control.backdrop:SetEdgeTexture("",1 ,1 ,2 )
  control.backdrop:SetPixelRoundingEnabled(true) 
  control.backdrop:SetExcludeFromResizeToFitExtents(true) 

  control.thumb = CreateControl(nil, control, CT_TEXTURE)
  control.thumb:SetAnchor(TOPRIGHT, control.label, TOPRIGHT, -2, 2)
  control.thumb:SetDimensions(36, 36)
  control.thumb:SetMouseEnabled(true)
  control.thumb:SetColor(1, 1, 1)

  -- Gespeicherte Daten
  if (control.saved) then 
    local color = control.saved
    control.thumb:SetColor(color[1], color[2], color[3])
  end
 
  -- Ändern + Speichern
  local function ColorPickerCallback(r, g, b)
    control.thumb:SetColor(r, g, b)
    colorData.getFunc = {r, g, b}
    control.saved = {r, g, b}
  
    if (colorData.setFunc) then
      colorData.setFunc(r, g, b)
    end
  end

  control.thumb:SetHandler("OnMouseUp", function(self, btn, upInside)
    if self.isDisabled then return end

    local color = control.saved or {1,1,1}

    if upInside then  
      COLOR_PICKER:Show(ColorPickerCallback, color[1], color[2], color[3])
    end
  end)

  if (control.updateAllowed) then registerForUpdate(control) end

  return control
end

ShissuFramework_Settings.registerControl(_control.name, _control.colorpicker)
ShissuFramework["templates"][_control.name] = 1