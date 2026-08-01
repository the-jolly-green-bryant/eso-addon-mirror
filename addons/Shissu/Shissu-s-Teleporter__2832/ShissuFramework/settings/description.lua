-- Shissu Framework: Settings control
-- ----------------------------------
-- 
-- Filename:    settings/description.lua
-- Version:     v1.0.1
-- Last Update: 28.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local createBaseControl = ShissuFramework["functions"]["settings"].createBaseControl
local _control = {}
_control.name = "description"
_control.version = "1.0.1"

-- Beschreibungen, Infotexte, ...
function _control.description(parent, descriptionData)
  if (descriptionData.alternateName ~= nil) then
    parent = descriptionData.alternateName
  end

	local control = createBaseControl(parent, descriptionData, nil)
	local width = control:GetWidth()
	control:SetResizeToFitDescendents(true)
  control:SetDimensionConstraints(width, 26, width, 26 * 4)

	control.desc = CreateControl(nil, control, CT_LABEL)
	control.desc:SetVerticalAlignment(TEXT_ALIGN_TOP)
	control.desc:SetFont("ZoFontGame")
	control.desc:SetText(descriptionData.text)
	control.desc:SetWidth(width)
	control.desc:SetAnchor(TOPLEFT)

	return control
end

ShissuFramework_Settings.registerControl(_control.name, _control.description)
ShissuFramework["templates"][_control.name] = 1