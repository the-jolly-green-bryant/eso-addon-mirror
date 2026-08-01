CheckEnchantmentSettings = ZO_Object:Subclass()

local settings
local WM = WINDOW_MANAGER

function CheckEnchantmentSettings:New()
  local obj = ZO_Object.New(self)
  obj:Initialize()

  return obj
end

function CheckEnchantmentSettings:Initialize()
  local defaults = {
  xoffset = 80, -- used 80 to not clash with the 100 of Research Assistant
  xoffset_eq = 20,
  yoffset = 0,
  yoffset_eq = -16,
  xdim = 16,
  ydim = 16, 
  alpha = 1 
  }

  settings = ZO_SavedVars:New("CheckEnchantmentSettings", 1, nil, defaults)
  self:CreateOptionsMenu()
end

function CheckEnchantmentSettings:CreateOptionsMenu()
  local panel = WM:CreatecontrolPanel("CheckEnchantmentSettingsPanel", "Check Enchantment Settings")
  WM:AddHeader(panel, "CE_Settings_header", "Check Enchantment")
end
