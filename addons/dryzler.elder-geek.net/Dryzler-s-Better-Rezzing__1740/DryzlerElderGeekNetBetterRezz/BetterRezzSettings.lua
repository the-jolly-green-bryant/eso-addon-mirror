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
    name = "Dryzler's Better Rezzing",
    displayName = "|c3f95ffDryzler's|r |cEFEBBEBetter Rezzing|r",
    author = "|cEFEBBEDryzler|r",
    website = "https://dryzler.com/",
    version = self.Addon.versionString,
    slashCommand = "/dryrez",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsPanel = LAM2:RegisterAddonPanel(self.Addon.name, optionsPanelConfig)
  
  local optionsPanelControls = {}

  table.insert(optionsPanelControls, {
      type = "slider",
      name = GetString(SI_DEG_REZZ_OPTS_SCALE_LEVEL),
      min = 50,
      max = 3000,
      step = 1,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.frameScale 
      end,
      setFunc = function(newValue) 
        self.Addon.savedVariablesAccount.settings.frameScale = newValue
        DryzlersBetterRezzFrameStatics:repaintAllFrames()
      end,
      width = "full",
      default = function()
        return 150
      end,
      disabled = function() 
        return false
      end,
  })  
     
  table.insert(optionsPanelControls, {
    type = "colorpicker",
    name = GetString(SI_DEG_REZZ_OPTS_COLOR_HEALER),
    getFunc = function() return unpack(self.Addon.savedVariablesAccount.settings.colorHealer) end,
    setFunc = function(r,g,b,a) 
      self.Addon.savedVariablesAccount.settings.colorHealer={r,g,b} 
      DryzlersBetterRezzFrameStatics:repaintAllFrames()  
    end,
    width = "full",
    disabled = function() return false end,
    default = function() return {r=51/255,g=204/255,b=51/255} end,   
  })  
  
  table.insert(optionsPanelControls, {
    type = "colorpicker",
    name = GetString(SI_DEG_REZZ_OPTS_COLOR_TANK),
    getFunc = function() return unpack(self.Addon.savedVariablesAccount.settings.colorTank) end,
    setFunc = function(r,g,b,a) 
      self.Addon.savedVariablesAccount.settings.colorTank={r,g,b} 
      DryzlersBetterRezzFrameStatics:repaintAllFrames()
    end,
    width = "full",
    disabled = function() return false end,
    default = function() return {r=255/255,g=153/255,b=51/255} end,   
  })  
  
  table.insert(optionsPanelControls, {
      type = "dropdown",
      name = GetString(SI_DEG_REZZ_OPTS_ICON),
      choices = {"soulgem", "arrowSmithing", "arrowCharacterCreate", "arrowChatOverflow"},
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.icon 
      end,
      setFunc = function(newValue) 
        self.Addon.savedVariablesAccount.settings.icon = newValue
        DryzlersBetterRezzFrameStatics.texture = self.Addon.savedVariablesAccount.settings.icon
        DryzlersBetterRezzFrameStatics:repaintAllFrames()
      end,
      default = function()
        return "arrowChatOverflow"
      end,
      width = "full",
      disabled = function() 
        return false
      end,
  })  
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_REZZ_OPTS_ACTIVE_HEALER),
      default = function()
        return true
      end,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.activeHealer 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.activeHealer = newValue
      end,
  })  
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_REZZ_OPTS_ACTIVE_TANK),
      default = function()
        return true
      end,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.activeTank 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.activeTank = newValue
      end,
  })
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_REZZ_OPTS_ACTIVE_DD),
      default = function()
        return true
      end,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.activeDD 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.activeDD = newValue
      end,
  })    

  LAM2:RegisterOptionControls(self.Addon.name, optionsPanelControls)
    
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
    if panel == optionsPanel then
      DryzlersBetterRezzFrameStatics:showSettingsFrameHelper()
    else 
      DryzlersBetterRezzFrameStatics:hideSettingsFrameHelper()
    end  
  end)
  
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
      DryzlersBetterRezzFrameStatics:hideSettingsFrameHelper()  
  end)
  
--  CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", function(panel)    
--    d("LAM-RefreshPanel")
--    if panel == optionsPanel then
--      DryzlersBetterRezzFrameStatics:showSettingsFrameHelper()
--    else 
--      DryzlersBetterRezzFrameStatics:hideSettingsFrameHelper()
--    end
--  end)
    
  ZO_PreHook(LAMAddonSettingsWindow, "SetHidden", function(hidden)
    if hidden then
      DryzlersBetterRezzFrameStatics:hideSettingsFrameHelper()
    else
      if LAM2.currentAddonPanel == optionsPanel then
        DryzlersBetterRezzFrameStatics:showSettingsFrameHelper()
      else
        DryzlersBetterRezzFrameStatics:hideSettingsFrameHelper()
      end
    end
  end)
  
  self.initialized = true
end

_G[_G["DEG_CURRENT_ADDON"].ADDON_NAME.."Settings"] = Obj