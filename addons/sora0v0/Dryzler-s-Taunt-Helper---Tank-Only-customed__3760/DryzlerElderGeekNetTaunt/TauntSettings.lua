local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(...)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(...)
end

local LAM2 = LibAddonMenu2

local Obj = {
  initialized = false,
  Addon = nil,
}

function Obj:initialize()
  if self.initialized then return end
  
  self.Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]
              
  local optionsPanelConfig  = {
    type = "panel",
    name = "Dryzler's Taunt Helper",
    displayName = "|c3f95ffDryzler's|r |cEFEBBETaunt Helper|r",
    author = "|cEFEBBEdryzler.elder-geek.net|r",
    website = "https://dryzler.elder-geek.net/",
    version = self.Addon.versionString,
    slashCommand = "/drytaunt",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsPanel = LAM2:RegisterAddonPanel(self.Addon.name, optionsPanelConfig)
  
  local optionsPanelControls = {}
    
  table.insert(optionsPanelControls, {
      type = "header",
      name = GetString(SI_DEG_SI_SETTINGS_THIS_CHAR),      
  })        
    
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_TAUNT_OPTS_ACTIVATED),
      default = function() return true end,
      getFunc = function()
        return self.Addon.savedVariablesCharacter.helperActivated 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesCharacter.helperActivated = newValue
        if not newValue then
          self.Addon:hideHelper()
        end        
      end,
  })
  
  table.insert(optionsPanelControls, {
      type = "header",
      name = GetString(SI_DEG_SI_SETTINGS_ACCOUNTWIDE),      
  })  
  
  table.insert(optionsPanelControls, {
    type = "slider",
    name = GetString(SI_DEG_TAUNT_OPTS_ALPHA).." (%)",
    min = 0,
    max = 100,
    step = 1,
    getFunc = function()
      return self.Addon.savedVariablesAccount.frameAlpha 
    end,
    setFunc = function(newValue) 
      self.Addon.savedVariablesAccount.frameAlpha = newValue
    end,
    width = "full",
    default = function() return 50 end,
    disabled = function() return false end,
  })
  
  table.insert(optionsPanelControls, {
    type = "colorpicker",
    name = GetString(SI_DEG_TAUNT_OPTS_COLOR),
    getFunc = function() return unpack(self.Addon.savedVariablesAccount.frameColor) end,
    setFunc = function(r,g,b,a) self.Addon.savedVariablesAccount.frameColor={r,g,b} end,
    width = "full",
    disabled = function() return false end,
    default = function() return {r=255/255,g=0,b=0} end,   
  })  
  
  table.insert(optionsPanelControls, {
    type = "slider",
    name = GetString(SI_DEG_TAUNT_OPTS_SCALE).." (%)",
    min = 0,
    max = 1000,
    step = 1,
    getFunc = function()
      return self.Addon.savedVariablesAccount.frameSize 
    end,
    setFunc = function(newValue) 
      self.Addon.savedVariablesAccount.frameSize = newValue
    end,
    width = "full",
    default = function() return 100 end,
    disabled = function() return false end,
  })
  
     
  LAM2:RegisterOptionControls(self.Addon.name, optionsPanelControls)
  
  self.initialized = true
end

_G[_G["DEG_CURRENT_ADDON"].ADDON_NAME.."Settings"] = Obj