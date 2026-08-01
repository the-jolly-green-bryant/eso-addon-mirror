local LAM2 = LibAddonMenu2

local panelData = {
 type = "panel",
 name = CC.displayName,
 author = CC.author,
 version = CC.version,
}

local optionsData = {
  [1] = {
      type = "description",
      text = "Cosmetic Cupboard allows you store and load cosmetic profiles.",
      width = "full",
  },
  [2] = {
      type = "checkbox",
      name = "Display Icon",
      tooltip = "Should the Cosmetic Cuboard icon appear on the main screen.",
      getFunc = function() return CC.data:GetIconEnabled() end,
      setFunc = function(value) CC:SetIconHidden(value) end,
      width = "half",
  },
}

local addonPanel

function CC:CreateAddonMenu()
  addonPanel = LAM2:RegisterAddonPanel("CosmeticCupboardOptions", panelData)
  LAM2:RegisterOptionControls("CosmeticCupboardOptions", optionsData)
end

--- Opens the settings page
function CC.ShowSettings()
	LAM2:OpenToPanel(addonPanel)
end
