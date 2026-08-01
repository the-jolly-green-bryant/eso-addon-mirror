-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/checkbox.lua
-- Version:     v1.2.12
-- Last Update: 04.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local _control = {}
_control.name = "checkbox"
_control.version = "1.2.12"

function _control.createFlatCheckbox(control, checkboxData, guildName)
  local checkbox = {}
  checkbox = CreateControl(nil, control, CT_TEXTURE)
	checkbox:SetTexture("ShissuFramework/textures/checkbox1.dds")
	checkbox:SetDimensions(20, 20)
	checkbox:SetDrawLayer(DL_FOREGROUND)
  checkbox:SetMouseEnabled(true)
  checkbox.isChecked = false

  if (guildName ~= nil) then
    if (checkboxData.saveVar ~= nil) then
      if (checkboxData.saveVar[guildName] == true) then
        checkbox.isChecked = true
        checkbox:SetTexture("ShissuFramework/textures/checkbox3.dds")
      end
    end 
  elseif (checkboxData.getFunc ~= nil) then
		if (checkboxData.getFunc == true) then
			checkbox.isChecked = true
			checkbox:SetTexture("ShissuFramework/textures/checkbox3.dds")
		end
	end 
  
  checkbox.toogleFunction = function()
		if checkbox.isChecked == false then
			checkbox.isChecked = true
			checkbox:SetTexture("ShissuFramework/textures/checkbox3.dds")
		else
			checkbox.isChecked = false
			checkbox:SetTexture("ShissuFramework/textures/checkbox1.dds")
		end
  end
  
  checkbox:SetHandler("OnMouseEnter", function(self)
		ZO_Tooltips_ShowTextTooltip(checkbox, TOPRIGHT, "|ceeeeee".. (guildName or checkboxData.tooltip))

		if (self.isChecked == false) then
			self:SetTexture("ShissuFramework/textures/checkbox2.dds")
		else
			self:SetTexture("ShissuFramework/textures/checkbox4.dds")
		end
	end)

	checkbox:SetHandler("OnMouseExit", function(self)
		ZO_Tooltips_HideTextTooltip()

		if (self.isChecked == false) then
			self:SetTexture("ShissuFramework/textures/checkbox1.dds")
		else
			self:SetTexture("ShissuFramework/textures/checkbox3.dds")
		end
	end)

	checkbox:SetHandler("OnMouseUp", function(self, btn, upInside)
		if (self.isChecked == false) then
			self:SetTexture("ShissuFramework/textures/checkbox3.dds")
			self.isChecked = true
		else
			self:SetTexture("ShissuFramework/textures/checkbox1.dds")
			self.isChecked = false
    end

    if (guildName ~= nil) then
      if (checkboxData.saveVar ~= nil) then
        if checkboxData.saveVar[guildName] == nil then
          checkboxData.saveVar[guildName] = {}
        end 

        checkboxData.saveVar[guildName] = self.isChecked
      end 
    elseif (checkboxData["setFunc"] ~= nil) then
      checkboxData.setFunc(self.isChecked, self.isChecked)
    end 
	end)

  return checkbox
end

function _control.checkbox(parent, checkboxData)
	local control = createBaseControl(parent, checkboxData, nil)
  local width = control:GetWidth()
  control:SetDimensions(width, 30)

  control.label = CreateControl(nil, control, CT_LABEL)
  control.label:SetFont("ZoFontGame")
  control.label:SetText(checkboxData.name)
	control.label:SetWidth(width-100)
  control.label:SetAnchor(TOPLEFT)
  
	if (checkboxData.tooltip == nil) then
    checkboxData.tooltip = checkboxData.name  
	end
	
  control.checkbox = _control.createFlatCheckbox(control, checkboxData)
	control.checkbox:SetAnchor(TOPRIGHT, control.label, TOPRIGHT)

	return control
end

function _control.guildcheckbox(parent, checkboxData)
  local control = createBaseControl(parent, checkboxData, nil)
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
    local gId = GetGuildId(guildId)
    local guildName = GetGuildName(gId)

    -- Überschriften
    control.guildLabel[guildId] = CreateControl(nil, control, CT_LABEL)
    control.guildLabel[guildId]:SetFont("ZoFontGame")
    control.guildLabel[guildId]:SetText(guildName)
    control.guildLabel[guildId]:SetWidth(100)
    control.guildLabel[guildId]:SetHeight(30)   
    control.guildLabel[guildId]:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(checkbox, TOPRIGHT, "|ceeeeee".. guildName) end)
	  control.guildLabel[guildId]:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)

    -- Je nachdem ob, es die erste Gilde ist oder nicht, den Anchor anders setzen
    if (guildId == 1) then
      control.guildLabel[guildId]:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 30)   
    else
      control.guildLabel[guildId]:SetAnchor(TOPRIGHT, control.guildLabel[guildId-1], TOPRIGHT, 120, 0)   
    end        
    
    -- Flat-Checkbox
    control.checkbox[guildId] = _control.createFlatCheckbox(control, checkboxData, guildName)
    control.checkbox[guildId]:SetAnchor(TOPLEFT, control.guildLabel[guildId], TOPLEFT, 35, 30)
  end
    
	return control
end

ShissuFramework_Settings.registerControl(_control.name, _control.checkbox)
ShissuFramework_Settings.registerControl("guildCheckbox", _control.guildcheckbox)
ShissuFramework["templates"][_control.name] = 1