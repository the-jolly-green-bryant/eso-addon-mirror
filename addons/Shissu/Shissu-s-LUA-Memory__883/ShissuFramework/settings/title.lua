-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/title.lua
-- Version:     v1.0.1
-- Last Update: 29.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local _control = {}
_control.name = "title"
_control.version = "1.0.1"

-- Überschriften
function _control.title(parent, titleData)
	local control = createBaseControl(parent, titleData, nil)
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

ShissuFramework_Settings.registerControl(_control.name, _control.title)
ShissuFramework["templates"][_control.name] = 1