---------------------------------------------------------------------------------------------------------
-- S E T T I N G S
---------------------------------------------------------------------------------------------------------
function PXWritStatusAddon:CreateSettingsWindow()
  d('PXWS -- CreateSettingsWindow() -- ' .. self.savedVariables.fontColor.r)
  local LAM2 = LibStub("LibAddonMenu-2.0")
  local panelData =
  {
    type                = "panel",
    name                = self.Name,
    displayName         = GetString(PXWS_SETTINGS_DISPLAY_NAME),
    author              = GetString(PXWS_SETTINGS_AUTHOR),
    version             = self.Version,
    registerForRefresh  = true,
    registerForDefaults = true
  }

  local cntrlOptionsPanel = LAM2:RegisterAddonPanel(self.Name, panelData)

  local optionsData =
  {
    {
      type = "description",
      text = GetString(PXWS_SETTINGS_HEADER_TEXT),
    },

    ---------------------
    -- Window Settings --
    ---------------------
    {
      type = "submenu",
      name = GetString(PXWS_SETTINGS_WINDOW_SETTINGS),
      controls =
      {
        {
          type = "colorpicker",
          name = GetString(PXWS_SETTINGS_FONT_COLOR),
          tooltip = GetString(PXWS_SETTINGS_FONT_COLOR_TOOLTIP),
          getFunc = function() return self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.g end,
          setFunc = function(r,g,b,a) self.savedVariables.fontColor = { ["r"] = r, ["g"] = g, ["b"] = b }; PXWritStatusAddon:UpdateWritStatus() end,
          default = { r = 1, g = 1, b = 1 },
        },
        {
          type = "slider",
          name = GetString(PXWS_SETTINGS_FONT_SCALE),
          min = 0, max = 3, step = 0.1,
          getFunc = function() return self.savedVariables.fontScale end,
          setFunc = function(value) self.savedVariables.fontScale = value; PXWritStatusAddon:UpdateWritStatus() end,
          disabled = function() return false end,
          width = "full",
          default = 1,
        },
        {
          type = "slider",
          name = GetString(PXWS_SETTINGS_BACKGROUND_TRANSPARENCY),
          min = 0, max = 1, step = 0.1,
          getFunc = function() return self.savedVariables.transparency end,
          setFunc = function(value) self.savedVariables.transparency = value; PXWritStatusAddon:UpdateWritStatus() end,
          width = "full",
          default = 0,
        },
      }
    },
  }

  LAM2:RegisterOptionControls(self.Name, optionsData)
end

function PXWritStatusAddon:CheckDefaultSettingsAreApplied()
  if (self.savedVariables.allWritsDoneNotified == nil) then
    self.savedVariables.allWritsDoneNotified = self.DefaultSettings.allWritsDoneNotified
  end
  if (self.savedVariables.debug == nil) then
    self.savedVariables.debug = self.DefaultSettings.debug;
  end
  if (self.savedVariables.left == nil) then
    self.savedVariables.left = self.DefaultSettings.left
  end
  if (self.savedVariables.top == nil) then
    self.savedVariables.top = self.DefaultSettings.top
  end
  if (self.savedVariables.fontColor == nil) then
    self.savedVariables.fontColor = self.DefaultSettings.fontColor
  end
  if (self.savedVariables.fontScale == nil) then
    self.savedVariables.fontScale = self.DefaultSettings.fontScale
  end
  if (self.savedVariables.transparency == nil) then
    self.savedVariables.transparency = self.DefaultSettings.transparency
  end
  if (self.savedVariables.showing == nil) then
    self.savedVariables.showing = self.DefaultSettings.showing
  end
  if (self.savedVariables.showWritStatus == nil) then
    self.savedVariables.showWritStatus = self.DefaultSettings.showWritStatus
  end
  if (self.savedVariables.showWritStatusCondensed == nil) then
    self.savedVariables.showWritStatusCondensed = self.DefaultSettings.showWritStatusCondensed
  end
end