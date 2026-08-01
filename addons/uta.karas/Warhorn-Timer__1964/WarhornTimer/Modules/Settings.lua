function WarhornTimer:SettingsBuildMenu()
  local addonPanel = {
    type                = 'panel',
    name                = self.name,
    displayName         = ZO_ColorDef:New('3366cc'):Colorize(self.name),
    author              = self.author,
    version             = self.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }

  local optionControls = {
    {
      type    = 'header',
      name    = ZO_ColorDef:New('6699ff'):Colorize('Bar Settings'),
    },
    {
      type    = 'checkbox',
      name    = 'Lock',
      getFunc = function() return self.settings.locked end,
      setFunc = function()
        self.settings.locked = not self.settings.locked
        self:WindowApplySettings()
      end
    },
    {
      type    = 'checkbox',
      name    = 'Always Show',
      getFunc = function() return self.settings.alwaysShow end,
      setFunc = function()
        self.settings.alwaysShow = not self.settings.alwaysShow
        self:WindowApplySettings()
      end
    },
    {
      type    = 'slider',
      name    = 'Interval of refreshing bar (ms)',
      min     = 100,
      max     = 1000,
      step    = 100,
      getFunc = function() return self.settings.updateSpeed end,
      setFunc = function(number)
        self.settings.updateSpeed = number
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'header',
      name    = ZO_ColorDef:New('6699ff'):Colorize('Display Settings'),
    },
    {
      type    = 'slider',
      name    = 'Width',
      min     = 0,
      max     = 500,
      step    = 5,
      getFunc = function() return self.settings.width end,
      setFunc = function(number)
        self.settings.width = number
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'slider',
      name    = 'Height',
      min     = 0,
      max     = 200,
      step    = 5,
      getFunc = function() return self.settings.height end,
      setFunc = function(number)
        self.settings.height = number
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'slider',
      name    = 'Text Size',
      min     = 10,
      max     = 100,
      step    = 2,
      getFunc = function() return self.settings.textSize end,
      setFunc = function(number)
        self.settings.textSize = number
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'checkbox',
      name    = 'Reverse Bar Direction',
      getFunc = function() return self.settings.reverse end,
      setFunc = function()
        self.settings.reverse = not self.settings.reverse
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'colorpicker',
      name    = 'Bar Color Left',
      getFunc = function() return self.settings.colorBar[1], self.settings.colorBar[2], self.settings.colorBar[3], self.settings.colorBar[4] end,
      setFunc = function(r,g,b,a)
        self.settings.colorBar[1] = r
        self.settings.colorBar[2] = g
        self.settings.colorBar[3] = b
        self.settings.colorBar[4] = a
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'colorpicker',
      name    = 'Bar Color Right',
      getFunc = function() return self.settings.colorBar[5], self.settings.colorBar[6], self.settings.colorBar[7], self.settings.colorBar[8] end,
      setFunc = function(r,g,b,a)
        self.settings.colorBar[5] = r
        self.settings.colorBar[6] = g
        self.settings.colorBar[7] = b
        self.settings.colorBar[8] = a
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'colorpicker',
      name    = 'Bar Color Edge',
      getFunc = function() return unpack(self.settings.colorEdge) end,
      setFunc = function(r,g,b,a)
        self.settings.colorEdge = {r,g,b,a}
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'colorpicker',
      name    = 'Bar Color Background',
      getFunc = function() return unpack(self.settings.colorBackground) end,
      setFunc = function(r,g,b,a)
        self.settings.colorBackground = {r,g,b,a}
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'colorpicker',
      name    = 'Text Color',
      getFunc = function() return unpack(self.settings.colorLabel) end,
      setFunc = function(r,g,b,a)
        self.settings.colorLabel = {r,g,b,a}
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'checkbox',
      name    = 'Show Icon',
      getFunc = function() return self.settings.showIcon end,
      setFunc = function()
        self.settings.showIcon = not self.settings.showIcon
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'slider',
      name    = 'Icon Size',
      min     = 10,
      max     = 100,
      step    = 2,
      getFunc = function() return self.settings.iconSize end,
      setFunc = function(number)
        self.settings.iconSize = number
        self:WindowApplySettings()
      end,
    },
    {
      type    = 'colorpicker',
      name    = 'Icon Color',
      getFunc = function() return unpack(self.settings.iconColor) end,
      setFunc = function(r,g,b,a)
        self.settings.iconColor = {r,g,b,a}
        self:WindowApplySettings()
      end,
    },
  }

  LibAddonMenu2:RegisterAddonPanel('WarhornTimerPanel', addonPanel)
  LibAddonMenu2:RegisterOptionControls('WarhornTimerPanel', optionControls)
end

function WarhornTimer:SettingsLoad()
  local defaultSettings = {
    offset          = {x=200, y=200},
    locked          = false,
    alwaysShow      = true,
    updateSpeed     = 100,
    width           = 200,
    height          = 30,
    textSize        = 20,
    reverse         = false,
    colorBar        = {1,0,0,1,0,1,0,1},
    colorEdge       = {0,0,0,1},
    colorBackground = {0.2,0.2,0.2,0.4},
    colorLabel      = {1,1,1,1},
    showIcon        = true,
    iconSize        = 30,
    iconColor       = {1,1,1,1},
    iconTexture     = '/esoui/art/icons/ability_ava_003.dds',
  }

  self.settings = ZO_SavedVars:NewAccountWide('WarhornTimerSavedVariables', 1, nil, defaultSettings, nil, '$InstallationWide')
end
