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
    name = "Dryzler's Reticle",
    displayName = "|c3f95ffDryzler's|r |cEFEBBEReticle|r",
    author = "|cEFEBBEDryzler|r",
    website = "https://dryzler.com/",
    version = self.Addon.versionString,
    slashCommand = "/dryreticle",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsPanel = LAM2:RegisterAddonPanel(self.Addon.name, optionsPanelConfig)
  
  local optionsPanelControls = {}
    
  table.insert(optionsPanelControls, {
      type = "header",
      name = GetString(SI_DEG_SI_SETTINGS_ACCOUNTWIDE),
  })
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_RETICLE_OPTS_MODE_CIRCLE_HEADER),
      default = function()
        return self.Addon.defaults.modes.circle
      end,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.modes.circle 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.modes.circle = newValue
        self.Addon:activateReticles()
        self.Addon:updateReticles()
      end,
  })
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_RETICLE_OPTS_MODE_SQUARE_HEADER),
      default = function()
        return self.Addon.defaults.modes.square
      end,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.modes.square 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.modes.square = newValue
        self.Addon:activateReticles()
        self.Addon:updateReticles()
      end,
  })  
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_RETICLE_OPTS_MODE_DOT_HEADER),
      default = function()
        return self.Addon.defaults.modes.dot
      end,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.modes.dot 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.modes.dot = newValue
        self.Addon:activateReticles()
        self.Addon:updateReticles()
      end,
  })    
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_RETICLE_OPTS_MODE_RULE_HEADER),
      default = function()
        return self.Addon.defaults.modes.rule
      end,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.modes.rule 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.modes.rule = newValue
        self.Addon:activateReticles()
        self.Addon:updateReticles()
      end,
  })
  
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_DEG_RETICLE_OPTS_MODE_CIRCLE_HEADER),
    controls = {{
        type = "slider",
        name = GetString(SI_DEG_SI_SETTINGS_SCALE).. " (%)",
        min = 0,
        max = 1000,
        step = 1,
        default = function()
          return self.Addon.defaults.circle.scale
        end,
        getFunc = function()
          return self.Addon.savedVariablesAccount.settings.circle.scale 
        end,
        setFunc = function(newValue)
          self.Addon.savedVariablesAccount.settings.circle.scale = newValue
          self.Addon:activateReticles()
          self.Addon:updateReticles()
        end,
        width = "full",},
        {
            type = "checkbox",
            name = GetString(SI_DEG_RETICLE_OPTS_HRULE),
            default = function()
              return self.Addon.defaults.circle.hrule
            end,
            getFunc = function()
              return self.Addon.savedVariablesAccount.settings.circle.hrule 
            end,
            setFunc = function(newValue)
              self.Addon.savedVariablesAccount.settings.circle.hrule = newValue
              self.Addon:activateReticles()
              self.Addon:updateReticles()
            end,
        },
      {
              type = "slider",
              name = GetString(SI_DEG_RETICLE_OPTS_HRULE).." "..GetString(SI_DEG_SI_SETTINGS_OPACITY).. " (%)",
              min = 0,
              max = 100,
              step = 1,
              default = function()
                return self.Addon.defaults.circle.hruleAlpha
              end,
              getFunc = function()
                return self.Addon.savedVariablesAccount.settings.circle.hruleAlpha 
              end,
              setFunc = function(newValue)
                self.Addon.savedVariablesAccount.settings.circle.hruleAlpha = newValue
                self.Addon:activateReticles()
                self.Addon:updateReticles()
              end,
              width = "full",},        
        {
            type = "checkbox",
            name = GetString(SI_DEG_RETICLE_OPTS_VRULE),
            default = function()
              return self.Addon.defaults.circle.vrule
            end,
            getFunc = function()
              return self.Addon.savedVariablesAccount.settings.circle.vrule 
            end,
            setFunc = function(newValue)
              self.Addon.savedVariablesAccount.settings.circle.vrule = newValue
              self.Addon:activateReticles()
              self.Addon:updateReticles()
            end,
        },      
        {
            type = "slider",
            name = GetString(SI_DEG_RETICLE_OPTS_VRULE).." "..GetString(SI_DEG_SI_SETTINGS_OPACITY).. " (%)",
            min = 0,
            max = 100,
            step = 1,
            default = function()
              return self.Addon.defaults.circle.vruleAlpha
            end,
            getFunc = function()
              return self.Addon.savedVariablesAccount.settings.circle.vruleAlpha 
            end,
            setFunc = function(newValue)
              self.Addon.savedVariablesAccount.settings.circle.vruleAlpha = newValue
              self.Addon:activateReticles()
              self.Addon:updateReticles()
            end,
        width = "full",},                    
    },
  })  
    
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_DEG_RETICLE_OPTS_MODE_SQUARE_HEADER),
    controls = {{
        type = "slider",
        name = GetString(SI_DEG_SI_SETTINGS_SCALE).. " (%)",
        min = 0,
        max = 1000,
        step = 1,
        default = function()
          return self.Addon.defaults.square.scale
        end,
        getFunc = function()
          return self.Addon.savedVariablesAccount.settings.square.scale 
        end,
        setFunc = function(newValue)
          self.Addon.savedVariablesAccount.settings.square.scale = newValue
          self.Addon:activateReticles()
          self.Addon:updateReticles()
        end,
        width = "full",},
      {
            type = "checkbox",
            name = GetString(SI_DEG_RETICLE_OPTS_ROTATE),
            default = function()
              return self.Addon.defaults.square.rotate
            end,
            getFunc = function()
              return self.Addon.savedVariablesAccount.settings.square.rotate
            end,
            setFunc = function(newValue)
              self.Addon.savedVariablesAccount.settings.square.rotate = newValue
              self.Addon:activateReticles()
              self.Addon:updateReticles()
            end,
        }        
    },
  })  
  
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_DEG_RETICLE_OPTS_MODE_RULE_HEADER),
    controls = {
      {
            type = "checkbox",
            name = GetString(SI_DEG_RETICLE_OPTS_ROTATE),
            default = function()
              return self.Addon.defaults.rule.rotate
            end,
            getFunc = function()
              return self.Addon.savedVariablesAccount.settings.rule.rotate
            end,
            setFunc = function(newValue)
              self.Addon.savedVariablesAccount.settings.rule.rotate = newValue
              self.Addon:activateReticles()
              self.Addon:updateReticles()
            end,
        }        
    },
  })   
       

  LAM2:RegisterOptionControls(self.Addon.name, optionsPanelControls)
  
  self.initialized = true
end

_G[_G["DEG_CURRENT_ADDON"].ADDON_NAME.."Settings"] = Obj