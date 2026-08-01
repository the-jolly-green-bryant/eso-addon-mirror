local RF = RipFilter or {}
local LAM2 = LibAddonMenu2

function RF:InitialiseAddoMenu()
  local panelData = {
          type = "panel",
          name = "RipFilter",
          displayName = "RipFilter",
          author = "kadeer",
          slashCommand = "/ripmenu",
          registerForRefresh = true,
          registerForDefaults = true
  }

  LAM2:RegisterAddonPanel("RipFilterAddonOptions", panelData)

  local optionsData = {}

  table.insert(optionsData, {
    type = "header",
    name = "Usage:", -- or string id or function returning a string
    width = "full", --or "half" (optional)
  })

  table.insert(optionsData, {
    type = "description",
    --title = "Shortcuts",
    text = "/rip\n/ripr\n/ripd\n/ripmenu\n/ripreset\n/riprecap\n\n(Keybindings available for all of the above)\n",
    width = "half",
  })

  table.insert(optionsData, {
    type = "description",
    --title = "Shortcuts",
    text = "Killing Blow Count\nResurrection Count\nDeath Count\nShortcut to this Menu\nResets All Counts\nToggle Recap\n\n",
    width = "half",
  })

  table.insert(optionsData, {
    type = "header",
    name = "Options", -- or string id or function returning a string
    width = "full", --or "half" (optional)
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Enabled",
    default = self.defaults.enabled,
    getFunc = function() return self.SV.enabled end,
    setFunc = function(value) self.SV.enabled=value if value then RF:Initialise() else RF:DeInitialise() end end,
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Rip Filter Tab",
    default = self.defaults.ripFeed,
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return self.SV.ripFeed end,
    setFunc = function(value) self.SV.ripFeed=value if value then RF:InitialiseRipFeed() else RF:DeinitialiseRipFeed() end end,
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "vTrial AutoReset Counts",
    default = self.defaults.trialStartReset,
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return self.SV.trialStartReset end,
    setFunc = function(value) self.SV.trialStartReset=value end,
  })

  table.insert(optionsData, {
    type = "colorpicker",
    name = "Player (primary colour)",
    default = RF:ConvertHexToRGBAPacked(self.defaults.gColourA),
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return RF:ConvertHexToRGBA(self.SV.gColourA) end,
    setFunc = function(r,g,b) self.SV.gColourA = RF:ConvertRGBToHex(r, g, b) end,
  })

  table.insert(optionsData, {
    type = "colorpicker",
    name = "Player (secondary colour)",
    default = RF:ConvertHexToRGBAPacked(self.defaults.gColourB),
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return RF:ConvertHexToRGBA(self.SV.gColourB) end,
    setFunc = function(r,g,b) self.SV.gColourB = RF:ConvertRGBToHex(r, g, b) end,
  })

  table.insert(optionsData, {
    type = "colorpicker",
    name = "Group (primary colour)",
    default = RF:ConvertHexToRGBAPacked(self.defaults.ngColourA),
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return RF:ConvertHexToRGBA(self.SV.ngColourA) end,
    setFunc = function(r,g,b) self.SV.ngColourA = RF:ConvertRGBToHex(r, g, b) end,
  })

  table.insert(optionsData, {
    type = "colorpicker",
    name = "Group (secondary colour)",
    default = RF:ConvertHexToRGBAPacked(self.defaults.ngColourB),
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return RF:ConvertHexToRGBA(self.SV.ngColourB) end,
    setFunc = function(r,g,b) self.SV.ngColourB = RF:ConvertRGBToHex(r, g, b) end,
  })

  table.insert(optionsData, {
    type = "header",
    name = "Recaps",
    width = "full",
  })

  table.insert(optionsData, {
    type = "checkbox",
    name = "Merge Attacks",
    default = self.defaults.recapMergeAttacks,
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return self.SV.recapMergeAttacks end,
    setFunc = function(value) self.SV.recapMergeAttacks=value end,
  })

  table.insert(optionsData, {
    type = "slider",
    name = "Max Attacks", -- or string id or function returning a string
    default = self.defaults.recapMaxAttacks,
    disabled = function() return not self.SV.enabled end,
    getFunc = function() return self.SV.recapMaxAttacks end,
    setFunc = function(value) self.SV.recapMaxAttacks = value end,
    min = 1,
    max = 50,
    step = 1, --(optional)
    clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
    decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
    autoSelect = true, -- boolean, automatically select everything in the text input field when it gains focus (optional)
    --inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
    tooltip = "Specify the maximum number of attacks to store per recap. Merged attacks are counted as 1 if they appear sequentially.", -- or string id or function returning a string (optional)
    width = "full", --or "half" (optional)
    --warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
    requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
  })

  table.insert(optionsData, {
    type = "header",
    name = "Resets", -- or string id or function returning a string
    width = "full", --or "half" (optional)
  })

  table.insert(optionsData, {
    type = "button",
    name = "Reset Killing Blows",
    func = function() RF:Reset("Killing Blows") end,
    width = "half",
  })

  table.insert(optionsData, {
    type = "button",
    name = "Reset Resurrections",
    func = function() RF:Reset("Resurrections") end,
    width = "half",
  })

  table.insert(optionsData, {
    type = "button",
    name = "Reset Deaths",
    func = function() RF:Reset("Deaths") end,
    width = "half",
  })

  table.insert(optionsData, {
    type = "button",
    name = "Reset All",
    func = function() RF:Reset("RipFilter has been reset")  end,
    width = "half",
  })

  table.insert(optionsData, {
    type = "divider"
  })

  LAM2:RegisterOptionControls("RipFilterAddonOptions", optionsData)
end