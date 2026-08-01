QE_Settings = {
  language_default = "en",
  language_options = { "Auto", "English", "Deutsch", "Français" },
  debug_levels = { 0, 1, 2, 3, 4 },
  width_default = 550,
  line_height_default = 30,
  disable_inventory_update_default = false,
  version = "0.44.0",
  checked_texture = "esoui/art/buttons/accept_up.dds",
  marked_rune_texture = "esoui/art/icons/servicemappins/servicepin_enchanting.dds",
  quest_rune_texture = "/esoui/art/compass/quest_icon_assisted.dds",
  x_offset_mark = 80, -- used 80 to not clash with the 100 of Research Assistant
  y_offset_mark = 0,
  x_threshold = 60, -- adapt this to a slightly higher values, if InventoryGridView has the check-marks in the middle
  qualities = { ITEM_QUALITY_NORMAL, ITEM_QUALITY_MAGIC, ITEM_QUALITY_ARCANE, ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_LEGENDARY },
  quality_lookup = {},
  glyph_type_info = {},
  effect_type_info = {},
  max_attempts = 10,
  retry_delay = 100,
  max_level = 50,
  max_veteran_level = 16,
  max_height_default = 800,
  display_button_offset_default = 50,
  display_result_runes_default = true,
  max_num_runes_result = 3,
  rune_result_list_height = 120,
  rune_result_list_width = 80,
  start_with_char_level_default = false,
  bottom_tooltips_default = false,
  remember_position_default = true,
  quest_update_default = true,
  show_potency_level_tooltip_default = true,
  show_potency_level_default = true,
  xoffset_eq = 20,
  yoffset = 0,
  yoffset_eq = -16,
  xdim = 16,
  ydim = 16, 
  xdim_grid = 20,
  ydim_grid = 20,
  alpha = 1,
  enchantment_check_default = false,
  indicator_x_position_default = 130,
  suppress_rune_voicing_default = false,
  add_mastermerchant = true,
}


local plus_up = "ESOUI/art/buttons/plus_up.dds"
local plus_over = "ESOUI/art/buttons/plus_over.dds"
local plus_down = "ESOUI/art/buttons/plus_down.dds"

local minus_up = "ESOUI/art/buttons/minus_up.dds"
local minus_over = "ESOUI/art/buttons/minus_over.dds"
local minus_down = "ESOUI/art/buttons/minus_down.dds"

local panelData = {
  type = "panel",
  name = "QuickEnchanter",
  displayName = "Quick Enchanter",
  author = "@Criscal",
  version = QE_Settings.version,
  slashCommand = "/qep",  --(optional) will register a keybind to open to this panel
  registerForRefresh = true,  --boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
  registerForDefaults = true, --boolean (optional) (will set all options controls back to default values)
}

local optionsTable = {
  [1] = {
    type = "header",
    width = "full", --or "half" (optional)
  },
  [2] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.best_quality end,
    setFunc = function(value)
      QuickEnchanter.savedVars.best_quality = value
      QE_Window:RedrawGlyphs()
      end,
    default = false
  },
  [3] = {
    type = "slider",
    min = 5,
    max = 40,
    step = 1,
    getFunc = function() return QuickEnchanter.savedVars.tooltip_icon_size end,
    setFunc = function(value) QuickEnchanter.savedVars.tooltip_icon_size = value end,
    default = QuickEnchanter.tooltip_icon_size
  },
  [4] = {
    type = "slider",
    min = 5,
    max = 40,
    step = 1,
    getFunc = function() return QuickEnchanter.savedVars.line_height end,
    setFunc = function(value)
      QuickEnchanter.savedVars.line_height = value
      QE_Window:ResizeRefresh()
      end,
    default = QE_Settings.line_height_default
  },
  [5] = {
    type = "slider",
    min = 5,
    max = 40,
    step = 1,
    getFunc = function() return QuickEnchanter.savedVars.max_lines end,
    setFunc = function(value)
      QuickEnchanter.savedVars.max_lines = value
      QE_Window:RedrawGlyphs()
      end,
    default = QuickEnchanter.max_lines
  },
  [6] = { -- change the language
    type = "dropdown",
    choices = QE_Settings.language_options,
    getFunc = function() return QE_Settings:GetLanguage() end,
    setFunc = function(value)
      QE_Settings:SetLanguage(value)
      QE_Settings:FixTexts()
      QE_Window:LanguageRefresh()
      QE_Window:RedrawGlyphs()
      end,
    default = "Auto"
  },
  [7] = { -- debugging
    type = "dropdown",
    choices = QE_Settings.debug_levels,
    getFunc = function() return QuickEnchanter.savedVars.debug_level end,
    setFunc = function(value) QuickEnchanter.savedVars.debug_level = value end,
    default = 0
  },
  [8] = {
    type = "slider",
    min = 550,
    max = 800,
    step = 1,
    getFunc = function() return QuickEnchanter.savedVars.window_width end,
    setFunc = function(value)
      QuickEnchanter.savedVars.window_width = value
      QE_Window:ResizeRefresh()
    end,
    default = QE_Settings.width_default
  },
  [9] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.disable_inventory_update end,
    setFunc = function(value) QuickEnchanter.savedVars.disable_inventory_update = value end,
    default = false
  },
  [10] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.selected_bug_level_only end,
    setFunc = function(value) QuickEnchanter.selected_bug_level_only = value end,
    default = false
  },
  [11] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.activate_tooltips end,
    setFunc = function(value) QuickEnchanter.savedVars.activate_tooltips = value end,
    default = false
  },
  [12] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.sort_marked end,
    setFunc = function(value)
      QuickEnchanter.savedVars.sort_marked = value
      QE_Window:RedrawGlyphs()
      end,
    default = false
  },
  [13] = {
    type = "checkbox",
    getFunc = function() return false end,
    setFunc = function(value)
      if (value) then
        QuickEnchanter:assureSettings(1)
        QE_Window:RedrawGlyphs()
      end
      end,
    default = false
  },
  [14] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.hide_chat_button end,
    setFunc = function(value) QuickEnchanter.savedVars.hide_chat_button = value
        QE_Window:hideChatButton(value)
      end,
    default = false
  },
  [15] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.classic_look end,
    setFunc = function(value) QuickEnchanter.savedVars.classic_look = value
        QE_Window:ToggleClassicLook(value)
      end,
    default = true
  },
  [16] = {
    type = "slider",
    min = 100,
    max = 2000,
    step = 50,
    getFunc = function() return QuickEnchanter.savedVars.retry_delay end,
    setFunc = function(value) QuickEnchanter.savedVars.retry_delay = value end,
    default = QE_Settings.retry_delay
  },
  [17] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.radio_buttons end,
    setFunc = function(value) QuickEnchanter.savedVars.radio_buttons = value end,
    default = true
  },
  [18] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.start_easy end,
    setFunc = function(value) QuickEnchanter.savedVars.start_easy = value end,
    default = true
  },
  [19] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.no_lines end,
    setFunc = function(value)
      QuickEnchanter.savedVars.no_lines = value
      QE_Window:HideLines(value)
    end,
    default = false
  },
  [20] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.safety_check end,
    setFunc = function(value)
      QuickEnchanter.savedVars.safety_check = value
    end,
    default = true
  },
  [21] = {
    type = "slider",
    min = 450,
    max = 850,
    step = 1,
    getFunc = function() return QuickEnchanter.savedVars.max_height end,
    setFunc = function(value)
      QuickEnchanter.savedVars.max_height = value
      QE_Window:ResizeRefresh()
    end,
    default = QE_Settings.max_height_default
  },
  [22] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.save_position end,
    setFunc = function(value)
      QuickEnchanter.savedVars.save_position = value
      if (not QuickEnchanter.savedVars.save_position) then
        QuickEnchanter.savedVars.save_x_pos = 0
        QuickEnchanter.savedVars.save_y_pos = 0
      end
    end,
    default = false
  },
  [23] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.disable_auto_open end,
    setFunc = function(value)
      QuickEnchanter.savedVars.disable_auto_open = value
    end,
    default = false
  },
  [24] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.add_rune_to_tooltip end,
    setFunc = function(value)
      QuickEnchanter.savedVars.add_rune_to_tooltip = value
    end,
    default = true
  },
  [25] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.center_tooltips end,
    setFunc = function(value)
      QuickEnchanter.savedVars.center_tooltips = value
    end,
    default = true
  },
  [26] = {
    type = "slider",
    min = 20,
    max = 150,
    step = 1,
    getFunc = function() return QuickEnchanter.savedVars.display_button_offset end,
    setFunc = function(value)
      QuickEnchanter.savedVars.display_button_offset = value
      QE_Window:AnchorDisplayButton()
    end,
    default = QE_Settings.display_button_offset_default
  },
  [27] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.FCO_just_marked end,
    setFunc = function(value)
      QuickEnchanter.savedVars.FCO_just_marked = value
    end,
    default = true
  },
  [28] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.display_result_runes end,
    setFunc = function(value)
      QuickEnchanter.savedVars.display_result_runes = value
    end,
    default = QE_Settings.display_result_runes_default,
  },
  [29] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.start_with_char_level end,
    setFunc = function(value)
      QuickEnchanter.savedVars.start_with_char_level = value
    end,
    default = QE_Settings.start_with_char_level_default,
  },
  [30] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.bottom_tooltips end,
    setFunc = function(value)
      QuickEnchanter.savedVars.bottom_tooltips = value
    end,
    default = QE_Settings.bottom_tooltips_default,
  },
  [31] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.remember_position end,
    setFunc = function(value)
      QuickEnchanter.savedVars.remember_position = value
    end,
    default = QE_Settings.remember_position_default,
  },
  [32] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.quest_update end,
    setFunc = function(value)
      QuickEnchanter.savedVars.quest_update = value
    end,
    default = QE_Settings.quest_update_default,
  },
  [33] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.show_potency_level_tooltip end,
    setFunc = function(value)
      QuickEnchanter.savedVars.show_potency_level_tooltip = value
    end,
    default = QE_Settings.show_potency_level_tooltip_default,
  },
  [34] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.enchantment_check end,
    setFunc = function(value)
      QuickEnchanter.savedVars.enchantment_check = value
    end,
    default = QE_Settings.enchantment_check_default,
  },
  [35] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.show_potency_level end,
    setFunc = function(value)
      QuickEnchanter.savedVars.show_potency_level = value
    end,
    default = QE_Settings.show_potency_level_default,
  },
  [36] = {
    type = "slider",
    min = 0,
    max = 150,
    step = 1,
    getFunc = function() return QuickEnchanter.savedVars.indicator_x_position end,
    setFunc = function(value) QuickEnchanter.savedVars.indicator_x_position = value end,
    default = QE_Settings.indicator_x_position_default
  },
  [37] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.suppress_rune_voicing end,
    setFunc = function(value)
      QuickEnchanter.savedVars.suppress_rune_voicing = value
    end,
    default = QE_Settings.suppress_rune_voicing_default,
  },
  [38] = {
    type = "checkbox",
    getFunc = function() return QuickEnchanter.savedVars.add_mastermerchant end,
    setFunc = function(value)
      QuickEnchanter.savedVars.add_mastermerchant = value
    end,
    default = QE_Settings.add_mastermerchant,
  },  
}

function QE_Settings:FixTexts()
  local op = optionsTable
  
  op[1].name = QE_Language[QuickEnchanter.savedVars.language].header_settings
  
  op[2].name = QE_Language[QuickEnchanter.savedVars.language].best_quality
  
  op[3].name = QE_Language[QuickEnchanter.savedVars.language].tooltip_icon_size_label
  
  op[4].name = QE_Language[QuickEnchanter.savedVars.language].line_height_label
  
  op[5].name = QE_Language[QuickEnchanter.savedVars.language].max_lines_label
  
  op[6].name = QE_Language[QuickEnchanter.savedVars.language].language_label
  op[6].tooltip = QE_Language[QuickEnchanter.savedVars.language].language_label_tip
  
  op[7].name = QE_Language[QuickEnchanter.savedVars.language].debug_level_label
  op[7].tooltip = QE_Language[QuickEnchanter.savedVars.language].debug_level_label_tip
  
  op[8].name = QE_Language[QuickEnchanter.savedVars.language].width_label
  
  op[9].name = QE_Language[QuickEnchanter.savedVars.language].disable_inventory_update_default_label
  op[9].tooltip = QE_Language[QuickEnchanter.savedVars.language].disable_inventory_update_default_label_tip
  
  op[10].name = QE_Language[QuickEnchanter.savedVars.language].selected_bug_level_only_label
  
  op[11].name = QE_Language[QuickEnchanter.savedVars.language].activate_tooltips_label
  op[11].tooltip = QE_Language[QuickEnchanter.savedVars.language].activate_tooltips_label_tip
  
  op[12].name = QE_Language[QuickEnchanter.savedVars.language].sort_marked_label
  op[12].tooltip = QE_Language[QuickEnchanter.savedVars.language].sort_marked_label_tip
  
  op[13].name = QE_Language[QuickEnchanter.savedVars.language].erase_label
  
  op[14].name = QE_Language[QuickEnchanter.savedVars.language].hide_chat_button_label
  
  op[15].name = QE_Language[QuickEnchanter.savedVars.language].classic_look_label
  op[15].tooltip = QE_Language[QuickEnchanter.savedVars.language].classic_look_label_tip
  
  op[16].name = QE_Language[QuickEnchanter.savedVars.language].retry_delay_label
  op[16].tooltip = QE_Language[QuickEnchanter.savedVars.language].retry_delay_label_tip
  
  op[17].name = QE_Language[QuickEnchanter.savedVars.language].radio_buttons_label
  op[17].tooltip = QE_Language[QuickEnchanter.savedVars.language].radio_buttons_label_tip
  
  op[18].name = QE_Language[QuickEnchanter.savedVars.language].start_easy_label
  op[18].tooltip = QE_Language[QuickEnchanter.savedVars.language].start_easy_label_tip
  
  op[19].name = QE_Language[QuickEnchanter.savedVars.language].no_lines_label
  op[19].tooltip = QE_Language[QuickEnchanter.savedVars.language].no_lines_label_tip
  
  op[20].name = QE_Language[QuickEnchanter.savedVars.language].safety_check_label
  op[20].tooltip = QE_Language[QuickEnchanter.savedVars.language].safety_check_label_tip
  
  op[21].name = QE_Language[QuickEnchanter.savedVars.language].max_height_label
  op[21].tooltip = QE_Language[QuickEnchanter.savedVars.language].max_height_label_tip
  
  op[22].name = QE_Language[QuickEnchanter.savedVars.language].save_position_label
  op[22].tooltip = QE_Language[QuickEnchanter.savedVars.language].save_position_label_tip

  op[23].name = QE_Language[QuickEnchanter.savedVars.language].disable_auto_open_label
  op[23].tooltip = QE_Language[QuickEnchanter.savedVars.language].disable_auto_open_label_tip

  op[24].name = QE_Language[QuickEnchanter.savedVars.language].add_rune_to_tooltip_label
  op[24].tooltip = QE_Language[QuickEnchanter.savedVars.language].add_rune_to_tooltip_tip

  op[25].name = QE_Language[QuickEnchanter.savedVars.language].center_tooltips_label
  op[25].tooltip = QE_Language[QuickEnchanter.savedVars.language].center_tooltips_label_tip
  
  op[26].name = QE_Language[QuickEnchanter.savedVars.language].display_button_offset_label
  op[26].tooltip = QE_Language[QuickEnchanter.savedVars.language].display_button_offset_label_tip

  op[27].name = QE_Language[QuickEnchanter.savedVars.language].FCO_just_marked_label
  op[27].tooltip = QE_Language[QuickEnchanter.savedVars.language].FCO_just_marked_label_tip
  
  op[28].name = QE_Language[QuickEnchanter.savedVars.language].display_result_runes_label
  op[28].tooltip = QE_Language[QuickEnchanter.savedVars.language].display_result_runes_label_tip

  op[29].name = QE_Language[QuickEnchanter.savedVars.language].start_with_char_level_label
  
  op[30].name = QE_Language[QuickEnchanter.savedVars.language].bottom_tooltips_label
  
  op[31].name = QE_Language[QuickEnchanter.savedVars.language].remember_position_label
  op[31].tooltip = QE_Language[QuickEnchanter.savedVars.language].remember_position_label_tip

  op[32].name = QE_Language[QuickEnchanter.savedVars.language].quest_update_label
  op[32].tooltip = QE_Language[QuickEnchanter.savedVars.language].quest_update_label_tip
  
  op[33].name = QE_Language[QuickEnchanter.savedVars.language].show_potency_level_tooltip_label
  
  op[34].name = QE_Language[QuickEnchanter.savedVars.language].enchantment_check_label
  op[34].tooltip = QE_Language[QuickEnchanter.savedVars.language].enchantment_check_label_tip
  
  op[35].name = QE_Language[QuickEnchanter.savedVars.language].show_potency_level_label
  op[35].tooltip = QE_Language[QuickEnchanter.savedVars.language].show_potency_level_label_tip
  
  op[36].name = QE_Language[QuickEnchanter.savedVars.language].indicator_x_position_label
  op[36].tooltip = QE_Language[QuickEnchanter.savedVars.language].indicator_x_position_label_tip
  
  op[37].name = QE_Language[QuickEnchanter.savedVars.language].suppress_rune_voicing_label
  op[37].tooltip = QE_Language[QuickEnchanter.savedVars.language].suppress_rune_voicing_label_tip
  
  op[38].name = QE_Language[QuickEnchanter.savedVars.language].add_mastermerchant_label
  op[38].tooltip = QE_Language[QuickEnchanter.savedVars.language].add_mastermerchant_label_tip
end

function QE_Settings:initializeOptions()
  self:FixTexts()
  self.LAM2 = LibStub("LibAddonMenu-2.0")
  self.panel = self.LAM2:RegisterAddonPanel("QuickEnchanterControlPanel", panelData)
  self.LAM2:RegisterOptionControls("QuickEnchanterControlPanel", optionsTable)
end

function QE_Settings:showSettings()
  if (self.panel ~= nil) then
    self.LAM2:OpenToPanel(self.panel)
  end
end

function QE_Settings:initializeLookup()
  for i = 1, #self.qualities do
    self.quality_lookup[self.qualities[i]] = i
  end
  self.glyph_type_info[tonumber(ITEMTYPE_GLYPH_ARMOR)] = "/esoui/art/icons/enchantment_armor_healthboost.dds"
  self.glyph_type_info[tonumber(ITEMTYPE_GLYPH_JEWELRY)] = "/esoui/art/icons/enchantment_jewelry_increaseweapondamage.dds"
  self.glyph_type_info[tonumber(ITEMTYPE_GLYPH_WEAPON)] = "/esoui/art/icons/enchantment_weapon_poisonessence.dds"
  self.glyph_type_info[0] = "/esoui/art/icons/icon_missing.dds"
  
  self.effect_type_info[tonumber(1)] = {}
  local icons = self.effect_type_info[tonumber(1)]
  icons.over = plus_over
  icons.down = plus_down
  icons.up = plus_up
  icons.text="effect_type_tip_positive"
  
  self.effect_type_info[tonumber(-1)] = {}
  icons = self.effect_type_info[tonumber(-1)]
  icons.over = minus_over
  icons.down = minus_down
  icons.up = minus_up
  icons.text="effect_type_tip_negative"
end

function QE_Settings:GetLanguage()
  local lang = QuickEnchanter.savedVars.language
  
  if (lang == QE_Settings:GetSystemLanguage()) then return "Auto"
  elseif (lang == "en") then return "English"
  elseif (lang == "de") then return "Deutsch"
  elseif (lang == "fr") then return "Français"
  else return "Auto"
  end
end

function QE_Settings:dbg(level)
  return QuickEnchanter:dbg(level)
end

function QE_Settings:debug(text)
  QuickEnchanter:debug(text)
end

function QE_Settings:GetSystemLanguage()
  return GetCVar("language.2")
end

function QE_Settings:SetLanguage(lang)
  local system = self:GetSystemLanguage()
  if (lang == nil or lang == "" or lang == "Auto") then
    QuickEnchanter.savedVars.language = system
  elseif (lang == "English") then
    QuickEnchanter.savedVars.language = "en"
  elseif (lang == "Deutsch") then
    QuickEnchanter.savedVars.language = "de"
  elseif (lang == "Français") then
    QuickEnchanter.savedVars.language = "fr"
  else
    QuickEnchanter.savedVars.language = language_default -- fall-back
  end
    if (self:dbg(1)) then self:debug("Set language to " .. QuickEnchanter.savedVars.language .. " system is " .. system) end
end
