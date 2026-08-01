local NP = NamePlater or {}
local LAM2 = LibAddonMenu2


function NP:DefaultEverything()
  self:SetFont(self.defaults.font, self.defaults.style, self.defaults.size)
end

function NP:InitialiseAddonMenu()
  local panelData = {
    type = "panel",
    name = "NamePlater",
    displayName = "NamePlater",
    author = "kadeer",
    slashCommand = "/npmenu",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsData = {}


  table.insert(optionsData, {
    type = "checkbox",
    name = "Enabled",
    default = self.defaults.enabled,
    getFunc = function() return self.SV.enabled end,
    setFunc = function(value) self.SV.enabled=value NP:SetupEvents(value) end,
  })

  table.insert(optionsData, {
    type = "dropdown",
    name = "Font",
    choices = NP.FONT_CHOICES,
    choicesValues = NP.FONT_VALUES,
    getFunc = function() return self.SV.font end,
    setFunc = function(font) self.SV.font=font self:SetFont(self.SV.font, self.SV.style, self.SV.size) end,
    default = function() self:DefaultEverything() return self.defaults.font end,
    disabled = function() return not self.SV.enabled end,
  })

  table.insert(optionsData, {
    type = "dropdown",
    name = "Style",
    choices = NP.FONTSTYLE_CHOICES,
    choicesValues = NP.FONTSTYLE_VALUES,
    getFunc = function() return self.SV.style end,
    setFunc = function(style) self.SV.style=style self:SetFont(self.SV.font, self.SV.style, self.SV.size) end,
    default = function() self:DefaultEverything() return self.defaults.style end,
    disabled = function() return not self.SV.enabled end,
  })

  table.insert(optionsData, {
    type = "dropdown",
    name = "Size",
    choices = NP.FONTSIZE_CHOICES,
    choicesValues = NP.FONTSIZE_VALUES,
    getFunc = function() return self.SV.size end,
    setFunc = function(size) self.SV.size=size self:SetFont(self.SV.font, self.SV.style, self.SV.size) end,
    default = function() self:DefaultEverything() return self.defaults.size end,
    disabled = function() return not self.SV.enabled end,
    scrollable = true,
  })

  LAM2:RegisterAddonPanel("NamePlaterAddonOptions", panelData)
  LAM2:RegisterOptionControls("NamePlaterAddonOptions", optionsData)
end


