-- Shissu Framework: Interface control
-- -----------------------------------
-- 
-- Filename:    interface/coloredbutton.lua
-- Version:     v2.0.2
-- Last Update: 17.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _control = {}
_control.name = "coloredButton"
_control.version = "2.0.2"

local RGBtoHex = ShissuFramework["functions"]["datatypes"].RGBtoHex
local _L = ShissuFramework["func"]._L("ShissuFramework")

local function anyColor(name, parent, pos, color)
  local control = CreateControl(name, parent, CT_TEXTURE) 
  control:SetAnchor(TOPLEFT, parent, TOPLEFT, pos[1],pos[2])
  control:SetMouseEnabled(true)
  control:SetDimensions(10, 20)
  control:SetColor(color[1]/255,color[2]/255,color[3]/255,1)
  control:SetDrawLevel(100)
  
  return control
end

local function colorPicker(control, editbox)
  control:SetHandler("OnMouseUp", function()        
    local cache = editbox:GetText()

    local function ColorPickerCallback(r, g, b)
      local htmlString = RGBtoHex({r, g, b})
      editbox:SetText(cache .. htmlString .. _L("TEXT") .. "|r")
    end

    COLOR_PICKER:Show(ColorPickerCallback, r, g, b)   
  end)
end

function _control.coloredButton(controlName, parent, colorNumber, XY, buttonLabel, editbox)
  if ( XY == nil ) then XY = {40, 0} end
  
  local color = { 1, 1, 1 }

  if ( colorNumber ~= nil and shissuColor ~= nil ) then
    color = shissuColor["c" .. colorNumber]
  end 
  
  local control = CreateControl(buttonLabel .. controlName, parent, CT_TEXTURE)  
  control:SetAnchor(TOPRIGHT, parent, TOPRIGHT, XY[1], XY[2])
  control:SetDimensions(30, 20)
  control:SetMouseEnabled(true)
  control:SetColor(color[1] or 1, color[2]or 1, color[3]or 1, color[4]or 1)
  control:SetDrawLevel(100)
  
  control.backdrop = CreateControl(buttonLabel .. controlName .. "BACKDROP", parent, CT_BACKDROP)
  control.backdrop:SetDimensions(34, 24)
  control.backdrop:SetAnchor(TOPRIGHT, parent, TOPRIGHT, XY[1]+2, XY[2]-2)
  control.backdrop:SetCenterColor( 0.2, 0.2, 0.2, 0.66 )
  control.backdrop:SetEdgeColor( 0.2, 0.2, 0.2, 0.4 )
  control.backdrop:SetEdgeTexture("",1 ,1 ,2 )
  control.backdrop:SetPixelRoundingEnabled(true) 
  control.backdrop:SetExcludeFromResizeToFitExtents(true) 

  if (controlName == "ANY" ) then
    control.anyRed = anyColor(buttonLabel .. controlName .. "Red", control, {0, 0}, {243,114,117})
    control.anyBlue = anyColor(buttonLabel .. controlName .. "Blue", control, {10,0}, {111, 168, 238})
    control.anyGreen = anyColor(buttonLabel .. controlName .. "Green", control, {20,0}, {160,250,107})

    colorPicker(control.anyRed, editbox)
    colorPicker(control.anyBlue, editbox)
    colorPicker(control.anyGreen, editbox)
  end
   
  control:SetHandler("OnMouseUp", function(_, btn)
    local cache = editbox:GetText()
    local color =  string.gsub(control:GetName(), buttonLabel, "")   

    local r = shissuColor["c" .. color][1]
    local g = shissuColor["c" .. color][2]
    local b = shissuColor["c" .. color][3]

    -- Linksklick; Einfügen des Farbcodes
    if (btn == 1) then
      if (color == "W") then            
        color = "|ceeeeee"
      else
        if (shissuColor == nil) then 
          color = "|ceeeeee" 
        end

        color = RGBtoHex({shissuColor["c" .. color][1], shissuColor["c" .. color][2], shissuColor["c" .. color][3]})
      end
        
      editbox:SetText(cache .. color .. _L("TEXT") .. "|r")        
    -- Rechtsklick: Ändern des Farbcodes + Einfügen
    elseif (btn == 2 and color ~= "W") then
      local function ColorPickerCallback(r, g, b)
        local htmlString = RGBtoHex({r, g, b})

        control:SetColor(r, g, b, 1)
        shissuColor["c" .. color] = {r, g, b, a or 1}
        editbox:SetText(cache .. htmlString .. _L("TEXT") .. "|r")
      end

      COLOR_PICKER:Show(ColorPickerCallback, r, g, b)   
    end
  end)
  
  return control
end

ShissuFramework["interface"].registerControl(_control.name, _control.coloredButton)
ShissuFramework["templates"][_control.name] = 1