-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/combobox.lua
-- Version:     v2.0.0
-- Last Update: 14.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local _control = {}
_control.name = "combobox"
_control.version = "2.0.0"

-- Auswahlbox
function _control.combobox(parent, dropdownData)
	local control = createBaseControl(parent, dropdownData, nil)
	local width = control:GetWidth()
	control:SetDimensions(width, 30)
  
  control.label = CreateControl(dropdownData.reference or nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(dropdownData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)

	control.combobox = CreateControlFromVirtual(dropdownData.name, control, "ZO_ComboBox")
	control.combobox:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
	control.combobox:SetDimensions(170, 30)
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

  if (dropdownData.dynamic) then
    local height = 30
    control.add = CreateControl(nil, control, CT_TEXTURE)
    control.add:SetTexture("ShissuFramework/textures/button_plus1.dds")
    control.add:SetAnchor(TOPRIGHT, control.combobox, RIGHT, height, -18)
    control.add:SetDimensions(32, 32)
    control.add:SetDrawLayer(DL_FOREGROUND)
    control.add:SetExcludeFromResizeToFitExtents(true)
    control.add:SetMouseEnabled(true)
    
    control.delete = CreateControl(nil, control, CT_TEXTURE)
    control.delete:SetTexture("ShissuFramework/textures/button_minus1.dds")
    control.delete:SetAnchor(TOPRIGHT, control.add, RIGHT, height, -15)
    control.delete:SetDimensions(32, 32)
    control.delete:SetDrawLayer(DL_FOREGROUND)
    control.delete:SetExcludeFromResizeToFitExtents(true)
    control.delete:SetMouseEnabled(true)

    control.save = CreateControl(nil, control, CT_TEXTURE)
    control.save:SetTexture("ShissuFramework/textures/button_sgt.dds")
    control.save:SetAnchor(TOPRIGHT, control.delete, RIGHT, height, -15)
    control.save:SetDimensions(32, 32)
    control.save:SetDrawLayer(DL_FOREGROUND)
    control.save:SetExcludeFromResizeToFitExtents(true)
    control.save:SetMouseEnabled(true)

    control.container = CreateControl(nil, control, CT_CONTROL)
    control.container:SetDimensions(170, height)
    control.container:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)
    control.container:SetHeight(height)
    control.container:SetHidden(true)

    local width = control.container:GetWidth()
    
    control.bg = CreateControlFromVirtual(nil, control.container, "ZO_EditBackdrop")
	  control.bg:SetAnchorFill()
  
    control.textbox = CreateControlFromVirtual(nil, control.bg, "ZO_DefaultEditForBackdrop")
	  control.textbox:SetMaxInputChars(3000)
    control.textbox:SetDimensionConstraints(width, height, width, 500)
    control.textbox:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(control) end)
    control.textbox:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(control) end)	  
    control.textbox:SetHandler("OnEscape", function(self) 
      self:LoseFocus() 

      control.combobox:SetHidden(false)
      control.container:SetHidden(true)
    end)

    local _L = ShissuFramework["func"]._L("ShissuFramework")
    local white = "|ceeeeee"
    
    control.add:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(control.add, TOPRIGHT, white .. _L("ADD")) end)
    control.delete:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(control.add, TOPRIGHT, white .. _L("DELETE")) end)
    control.save:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(control.add, TOPRIGHT, white .. _L("SAVE")) end)

    control.add:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)	  
    control.delete:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)	  
    control.save:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)	  

    control.add:SetHandler("OnMouseUp", function(self, btn, upInside)
      control.combobox:SetHidden(true)
      control.container:SetHidden(false)
    end)

    control.delete:SetHandler("OnMouseUp", function(self, btn, upInside)
      control.combobox:SetHidden(false)
      control.container:SetHidden(true)

      local count = #(control.combobox.dropdown["m_sortedItems"])
      local selected = control.combobox.dropdown["m_selectedItemText"]:GetText()

      for i=1, count do
        if (control.combobox.dropdown["m_sortedItems"][i]["name"] == selected) then
          control.combobox.dropdown["m_sortedItems"][i] = {}
        end
      end

      control.combobox.dropdown["m_selectedItemText"]:SetText("")

      if (dropdownData.deleteFunc) then
        dropdownData.deleteFunc(selected)
      end
    end)

    control.save:SetHandler("OnMouseUp", function(self, btn, upInside)
      control.combobox:SetHidden(false)
      control.container:SetHidden(true)

      control.combobox.dropdown:AddItem(control.combobox.dropdown:CreateItemEntry(control.textbox:GetText(), dropdownData.setFunc))
      control.combobox.dropdown:SetSelectedItem(control.textbox:GetText())
    end)

  end

	return control
end                                   

ShissuFramework_Settings.registerControl(_control.name, _control.combobox)
ShissuFramework["templates"][_control.name] = 1