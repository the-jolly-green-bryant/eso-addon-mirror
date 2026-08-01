TankSettings = {
  version = "1.1",
  defaults = { show_untaunted_mobs = true },
  save_version = 1,
  initialized = false,
}

local panelData = {
  type = "panel",
  name = "Tank",
  displayName = "Tank",
  author = "|cFFC300@amuridee|r, Criscal",
  version = TankSettings.version,
  slashCommand = "/ts",  --(optional) will register a keybind to open to this panel
  registerForRefresh = true,  --boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
  registerForDefaults = true, --boolean (optional) (will set all options controls back to default values)
}

local optionsTable = {
  [1] = {
    name = "Tank Settings",
    type = "header",
    width = "full", --or "half" (optional)
  },
  [2] = {
    name = "Show untaunted",
    type = "checkbox",
    getFunc = function() return Tank.savedVars.show_untaunted_mobs end,
    setFunc = function(value)
      Tank.savedVars.show_untaunted_mobs = value
      end,
    default = TankSettings.defaults.show_untaunted_mobs
  }
}

function TankSettings:initializeOptions(event, name)
  self.LAM2 = LibAddonMenu2
  self.panel = self.LAM2:RegisterAddonPanel("TankControlPanel", panelData)
  self.LAM2:RegisterOptionControls("TankControlPanel", optionsTable)
end