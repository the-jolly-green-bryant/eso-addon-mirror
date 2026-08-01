local FC = FontChanger or {}
local LAM2 = LibAddonMenu2

function FC:InitialiseAddonMenu()
  local panelData = {
    type = "panel",
    name = "FontChanger",
    displayName = "Font Changer",
    author = "Ferrety",
    slashCommand = "/fc",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsData = {}
	
  table.insert(optionsData, {
    type = "dropdown",
    name = "Menu/UI Font Scale",
    choices = FC.FONT_SCALING_CHOICES,
    choicesValues = FC.FONT_SCALING_VALUES,
    getFunc = function() return self.SV.menu_font_scale end,
    setFunc = function(menu_font_scale) self.SV.menu_font_scale=menu_font_scale self:SetUIFonts() end,
    default = function() self:SetUIFonts() return self.defaults.default_menu_font_scale end,
	warning = "Reload UI Required.",
    scrollable = true,
  })
  
  table.insert(optionsData, {
    type = "dropdown",
    name = "Menu/UI Bold Font Scale",
    choices = FC.FONT_SCALING_CHOICES,
    choicesValues = FC.FONT_SCALING_VALUES,
    getFunc = function() return self.SV.menu_bold_font_scale end,
    setFunc = function(menu_bold_font_scale) self.SV.menu_bold_font_scale=menu_bold_font_scale self:SetUIFonts() end,
    default = function() self:SetUIFonts() return self.defaults.default_menu_bold_font_scale end,
    warning = "Reload UI Required.",
    scrollable = true,
  })
  
  table.insert(optionsData, {
    type = "dropdown",
    name = "Scripture/Book Font Scale",
    choices = FC.FONT_SCALING_CHOICES,
    choicesValues = FC.FONT_SCALING_VALUES,
    getFunc = function() return self.SV.book_font_scale end,
    setFunc = function(book_font_scale) self.SV.book_font_scale=book_font_scale self:SetUIFonts() end,
    default = function() self:SetUIFonts() return self.defaults.default_book_font_scale end,
    warning = "Reload UI Required.",
    scrollable = true,
  })

  table.insert(optionsData, {
    type = "dropdown",
    name = "Nameplate Font Size",
    choices = FC.FONTSIZE_CHOICES,
    choicesValues = FC.FONTSIZE_VALUES,
    getFunc = function() return self.SV.nameplate_size end,
    setFunc = function(nameplate_size) self.SV.nameplate_size=nameplate_size self:SetWorldFonts() end,
    default = function() self:SetWorldFonts() return self.defaults.default_nameplate_size end,
    scrollable = true,
  })
  
    table.insert(optionsData, {
    type = "dropdown",
    name = "SCT Font Size",
    choices = FC.FONTSIZE_CHOICES,
    choicesValues = FC.FONTSIZE_VALUES,
    getFunc = function() return self.SV.sct_size end,
    setFunc = function(sct_size) self.SV.sct_size=sct_size self:SetWorldFonts() end,
    default = function() self:SetWorldFonts() return self.defaults.default_sct_size end,
    scrollable = true,
  })

  LAM2:RegisterAddonPanel("FontChangerAddonOptions", panelData)
  LAM2:RegisterOptionControls("FontChangerAddonOptions", optionsData)
end