---------------------
-- Drawing the Window
---------------------

local wm = WINDOW_MANAGER
local chat_over = "/esoui/art/chatwindow/chat_notification_over.dds"
local chat_up = "/esoui/art/chatwindow/chat_notification_up.dds"
local chat_down = "/esoui/art/chatwindow/chat_notification_down.dds"
local decline_up = "ESOUI/art/buttons/decline_up.dds"
local decline_over = "ESOUI/art/buttons/decline_over.dds"
local accept_up = "ESOUI/art/buttons/accept_up.dds"
local accept_over = "ESOUI/art/buttons/accept_over.dds"
local disabled = "/esoui/art/buttons/checkbox_indeterminate.dds"
local edit_over = "ESOUI/art/buttons/edit_over.dds"
local edit_down = "ESOUI/art/buttons/edit_down.dds"
local edit_up = "ESOUI/art/buttons/edit_up.dds"

local scroll_texture = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
local edit_cancel_up = "ESOUI/art/buttons/edit_cancel_up.dds"
local edit_cancel_down = "ESOUI/art/buttons/edit_cancel_down.dds"
local edit_cancel_over = "ESOUI/art/buttons/edit_cancel_over.dds"
local radio_up = "/esoui/art/dye/dyes_toolicon_setfill_up.dds"
local radio_down = "/esoui/art/dye/dyes_toolicon_setfill_down.dds"
local radio_over = "/esoui/art/dye/dyes_toolicon_setfill_over.dds"
-- /esoui/art/menubar/menubar_mainmenu_up.dds
local char_up = "/esoui/art/charactercreate/charactercreate_faceicon_up.dds"
local char_down = "/esoui/art/charactercreate/charactercreate_faceicon_down.dds"
local char_over = "/esoui/art/charactercreate/charactercreate_faceicon_over.dds"
local quest_icon = "/esoui/art/compass/quest_icon_assisted.dds"
local quest_icon_over = "/esoui/art/compass/quest_icon_assisted.dds"

--local char_up = "/esoui/art/mainmenu/menubar_character_up.dds"
--local char_down = "/esoui/art/mainmenu/menubar_character_down.dds"
--local char_over = "/esoui/art/mainmenu/menubar_character_over.dds"
local settings_over = "/esoui/art/menubar/menubar_mainmenu_over.dds"
local icon_step_factor = 0.1
local min_icon_size = 20
local icon_width_factor = 18 -- divide window width by this factor to get maximum icon size
local skip_lines = 8
local font_color = { 1, 1, 1, 1 }
local line_center_color = { 0.6, 0.6, 0.5, 1 }
local line_edge_color = { 0, 0, 0, 0 }
local control_button_size = { 20, 20 }

local RUNE_BAG = 1
local RUNE_SLOT = 2
local RUNE_ICON = 3 
local RUNE_NAME = 4
local RUNE_COUNT = 5
local RUNE_QUALITY = 6
local RED_TEXT = ZO_ColorDef:New("FF0000")
local GREY = ZO_ColorDef:New("808080")
local WHITE = ZO_ColorDef:New("FFFFFF")
local GREEN = ZO_ColorDef:New("00FF00")
local DARK_RED = ZO_ColorDef:New("800000")
local LES = LibStub("LibEnchantingStation")

QE_Window = {
  controls = {
    [CRAFTING_TYPE_ENCHANTING] = {}
  }
}

function QE_Window:HideMainWindow(hide)
  if LES and not hide then
    if ENCHANTING.enchantingMode ~= nil then
      -- ENCHANTING:SetEnchantingMode(ENCHANTING_MODE_CREATION)
    end
    LES:HideSlotContainer()
  end
  if (self:dbg(1)) then self:debug("QE_Window:HideMainWindow " .. (hide and "HIDE" or "UNHIDE")) end
  QuickEnchanter.last_enchantment = nil
  if (not QuickEnchanter.savedVars.activated) then
    if (self:dbg(1)) then self:debug("QE_Window:HideMainWindow - deactivated -> hide") end
    hide = true
  end
  self:drawCraftStore() -- assure existence
--  if (self.top.close ~= nil) then
--    if (self:dbg(1)) then self:debug("QE_Window:HideMainWindow - close button " .. (hide and "HIDE" or "UNHIDE")) end
--    self.top.close:SetHidden(hide)
--  end
  QE_Window_Screen:SetHidden(hide)
  if (QE_Window.top) then
    if (self:dbg(1)) then self:debug("QE_Window:HideMainWindow QE_Window.top " .. (hide and "HIDE" or "UNHIDE")) end
    QE_Window.top:SetHidden(hide)
  else
    if (self:dbg(1)) then self:debug("QE_Window:HideMainWindow QE_Window.top wasn't defined") end
  end
  if (QE_Window.runes_display ~= nil and hide) then QE_Window.runes_display:SetHidden(hide) end
  if (not hide and QuickEnchanter.savedVars.start_with_char_level) then
    QE_Window:FixToPlayerLevel()
  end
  
  if (not (QE_Window_Screen:IsHidden() and QE_Window.top:IsHidden())) then
    QuickEnchanter:Refresh()
  else
    if (self:dbg(1)) then self:debug("QE_Window:HideMainWindow: Don't refresh hidden screen") end
  end
end

function QE_Window:ToggleWindow()
  if (self:dbg(1)) then self:debug("ToggleWindow " .. (QE_Window.top:IsHidden() and "to visible" or "to hidden")) end
  QE_Window:HideMainWindow(not QE_Window.top:IsHidden())
end

function QE_Window:drawCraftStore()
  if QE_Window_Screen == nil then
    if (self:dbg(1)) then self:debug("drawCraftStore") end
    QE_Window:drawMasterWindow()
    --QE_Window:drawGlyphs(nil, 1)
    QE_Window:drawDisplayButton()
  else
    if (self:dbg(1)) then self:debug("drawCraftStore (no action)") end
  end
end

function QE_Window:LanguageRefresh()
  self:SetTitleText(0)
  if (self.top ~= nil and self.top.destroy_label ~= nil) then
    self.top.destroy_label:SetText(QE_Language[QuickEnchanter.savedVars.language].destroy_label .. ":")
  end
end

function QE_Window:SetTitleText(num)
  if (self.title ~= nil) then
    local add = ""
    if (num ~= 0) then add = " " .. num end
    self.title:SetText(add .. " " .. QE_Language[QuickEnchanter.savedVars.language].glyphs)
  end
end

function QE_Window:dbg(level)
  return QuickEnchanter:dbg(level)
end

function QE_Window:debug(text)
  -- refer to main debug function
  QuickEnchanter:debug(text)
end

function QE_Window:CalculateWindowHeight()
  local line_height = QuickEnchanter.savedVars.line_height+QuickEnchanter.line_gap
  QuickEnchanter.savedVars.max_lines = 12 -- ja, das geht besser
  QuickEnchanter.current_lines = QuickEnchanter.savedVars.max_lines
  QuickEnchanter.current_height = QuickEnchanter.savedVars.max_lines * line_height + QuickEnchanter.y_offset_glyphs + skip_lines * QuickEnchanter.savedVars.line_height
  while (QuickEnchanter.current_height > QuickEnchanter.savedVars.max_height) do
    QuickEnchanter.current_height = QuickEnchanter.current_height - line_height
    QuickEnchanter.current_lines = QuickEnchanter.current_lines - 1
  end
  if (QE_Window_Screen ~= nil) then
    QE_Window_Screen:SetDimensions(QuickEnchanter.width, QuickEnchanter.current_height) -- TODO
  end
  if (self:dbg(1)) then self:debug("Line height " .. line_height .. " number of lines:" .. QuickEnchanter.current_lines .. " height: " .. QuickEnchanter.current_height) end
end

function QE_Window:StartEasy()
  -- assure radio buttons for start easy
  local previous = QuickEnchanter.savedVars.radio_buttons
  QuickEnchanter.savedVars.radio_buttons = true
  self:ToggleQualities(1)
  self:ToggleGlyphTypes(ITEMTYPE_GLYPH_WEAPON)
  QuickEnchanter.savedVars.radio_buttons = previous
end

function QE_Window:ToggleQualities(idx)
  if (QuickEnchanter.savedVars.radio_buttons) then
    if (self:dbg(2)) then self:debug("Radio Buttons for Quality with index " .. idx) end
    for k, _ in pairs(QuickEnchanter.savedVars.quality_selection) do
      local active = QuickEnchanter.savedVars.quality_selection[k] == 1
      if (self:dbg(2)) then self:debug("Toggle " .. k .. " is " .. (active and "ACTIVE" or "INACTIVE")) end
      if (active and k ~= idx or not active and k == idx) then
        if (self:dbg(2)) then self:debug("Toggle " .. k .. " with index " .. idx) end
        self:ToggleQuality(k)
      end
    end
  else
    self:ToggleQuality(idx)
  end
end

function QE_Window:ToggleQuality(idx)
  local btn = self.top.qualities[tonumber(idx)]
  if (btn ~= nil) then
    if (QuickEnchanter.savedVars.quality_selection[idx] == 0) then
      QuickEnchanter.savedVars.quality_selection[idx] = 1
      QE_Window:UpdateButton(idx, btn)
    elseif (QuickEnchanter.savedVars.quality_selection[idx] == 1) then
      QuickEnchanter.savedVars.quality_selection[idx] = 0
      QE_Window:UpdateButton(idx, btn)
    end
  end
end

function QE_Window:UpdateButton(idx, btn)
  if (QuickEnchanter.savedVars.quality_selection[idx] == 0) then
    btn:SetNormalTexture(decline_up)
    btn:SetMouseOverTexture(decline_over)
    if (btn.color) then
      btn.color:SetTexture(decline_up)
    end
  end
  if (QuickEnchanter.savedVars.quality_selection[idx] == 1) then
    btn:SetNormalTexture(accept_up)
    btn:SetMouseOverTexture(accept_over)
    if (btn.color) then
      btn.color:SetTexture(accept_up)
    end
  end
  if (btn:GetState() == BSTATE_DISABLED and btn.color) then
    btn.color:SetTexture(edit_cancel_up)
  end
end

function QE_Window:ToggleGlyphTypes(idx)
  if (QuickEnchanter.savedVars.radio_buttons) then
    if (self:dbg(2)) then self:debug("Radio Buttons for glyph types with index " .. idx) end
    for k, _ in pairs(self.top.glyph_types) do
      local active = QuickEnchanter.savedVars.enabled_types[k] == 1
      if (self:dbg(2)) then self:debug("Toggle " .. k .. " is " .. (active and "ACTIVE" or "INACTIVE")) end
      if (active and k ~= idx or not active and k == idx) then
        if (self:dbg(2)) then self:debug("Toggle " .. k .. " with index " .. idx) end
        self:ToggleGlyphType(k)
      end
    end
  else
    self:ToggleGlyphType(idx)
  end
end

function QE_Window:ToggleGlyphType(idx)
  local btn = self.top.glyph_types[tonumber(idx)]
  if (btn ~= nil) then
    if (QuickEnchanter.savedVars.enabled_types[idx] == nil) then QuickEnchanter.savedVars.enabled_types[idx] = 1 end
    if (QuickEnchanter.savedVars.enabled_types[idx] == 0) then
      QuickEnchanter.savedVars.enabled_types[idx] = 1
      QE_Window:UpdateGlyphButton(idx, btn)
    elseif (QuickEnchanter.savedVars.enabled_types[idx] == 1) then
      QuickEnchanter.savedVars.enabled_types[idx] = 0
      QE_Window:UpdateGlyphButton(idx, btn)
    end
  end
end

function QE_Window:UpdateGlyphButton(idx, btn)
  if (QuickEnchanter.savedVars.enabled_types[idx] == 0) then
    btn.color:SetHidden(false)
    btn:SetMouseOverTexture(QE_Settings.glyph_type_info[tonumber(idx)])
  end
  if (QuickEnchanter.savedVars.enabled_types[idx] == 1) then
    btn.color:SetHidden(true)
    btn:SetMouseOverTexture(decline_over)
  end
end

function QE_Window:ToggleEffectTypes(idx)
  if (QuickEnchanter.savedVars.radio_buttons) then
    if (self:dbg(2)) then self:debug("Radio Buttons for Effect types with index " .. idx) end
    for k, _ in pairs(self.top.effect_selection) do
      local active = QuickEnchanter.savedVars.enabled_effect_types[k] == 1
      if (self:dbg(2)) then self:debug("Effect toggle " .. k .. " is " .. (active and "ACTIVE" or "INACTIVE")) end
      if (active and k ~= idx or not active and k == idx) then
        if (self:dbg(2)) then self:debug("Effect toggle " .. k .. " with index " .. idx) end
        self:ToggleEffectType(k)
      end
    end
  else
    self:ToggleEffectType(idx)
  end
end

function QE_Window:ToggleEffectType(idx)
  local btn = self.top.effect_selection[tonumber(idx)]
  if (btn ~= nil) then
    if (QuickEnchanter.savedVars.enabled_effect_types[idx] == nil) then QuickEnchanter.savedVars.enabled_effect_types[idx] = 1 end
    if (QuickEnchanter.savedVars.enabled_effect_types[idx] == 0) then
      QuickEnchanter.savedVars.enabled_effect_types[idx] = 1
      QE_Window:UpdateEffectButton(idx, btn)
    elseif (QuickEnchanter.savedVars.enabled_effect_types[idx] == 1) then
      QuickEnchanter.savedVars.enabled_effect_types[idx] = 0
      QE_Window:UpdateEffectButton(idx, btn)
    end
  end
end

function QE_Window:UpdateEffectButton(idx, btn)
  if (QuickEnchanter.savedVars.enabled_effect_types[idx] == 0) then
    btn.color:SetHidden(false)
  end
  if (QuickEnchanter.savedVars.enabled_effect_types[idx] == 1) then
    btn.color:SetHidden(true)
  end
end

function QE_Window:ToggleRadioButtons(btn)
  if (QuickEnchanter.savedVars.radio_buttons == nil) then QuickEnchanter.savedVars.radio_buttons = false end
  if (not QuickEnchanter.savedVars.radio_buttons) then
    QuickEnchanter.savedVars.radio_buttons = true
  elseif (QuickEnchanter.savedVars.radio_buttons) then
    QuickEnchanter.savedVars.radio_buttons = false
  end
  if (self:dbg(1)) then self:debug("Toggle radio buttons " .. (QuickEnchanter.savedVars.radio_buttons and "ON" or "OFF")) end
  QE_Window:UpdateRadioButtons(btn)
end

function QE_Window:UpdateRadioButtons(btn)
  if (QuickEnchanter.savedVars.radio_buttons) then
    btn:SetNormalTexture(radio_down)
    btn.color:SetColor(GREEN:UnpackRGBA())
  else 
    btn:SetNormalTexture(radio_up)
    btn.color:SetColor(DARK_RED:UnpackRGBA())
  end
end

function QE_Window:ToggleShowUnavailableButton(btn)
  if (QuickEnchanter.savedVars.show_unavailable == nil) then QuickEnchanter.savedVars.show_unavailable = false end
  if (not QuickEnchanter.savedVars.show_unavailable) then
    QuickEnchanter.savedVars.show_unavailable = true
  elseif (QuickEnchanter.savedVars.show_unavailable) then
    QuickEnchanter.savedVars.show_unavailable = false
  end
  if (self:dbg(1)) then self:debug("Toggle show unavailable button " .. (QuickEnchanter.savedVars.show_unavailable and "ON" or "OFF")) end
  QE_Window:UpdateShowUnavailableButton(btn)
end

function QE_Window:UpdateShowUnavailableButton(btn)
  if (QuickEnchanter.savedVars.show_unavailable) then
    btn:SetNormalTexture(edit_cancel_down)
    btn.color:SetColor(GREEN:UnpackRGBA())
  else 
    btn:SetNormalTexture(edit_cancel_up)
    btn.color:SetColor(DARK_RED:UnpackRGBA())
  end
end

function QE_Window:ToggleUseMasterButton(btn)
  if (QuickEnchanter.savedVars.use_master == nil) then QuickEnchanter.savedVars.use_master = false end
  if (not QuickEnchanter.savedVars.use_master) then
    QuickEnchanter.savedVars.use_master = true
  elseif (QuickEnchanter.savedVars.use_master) then
    QuickEnchanter.savedVars.use_master = false
  end
  if (self:dbg(1)) then self:debug("Toggle use master button " .. (QuickEnchanter.savedVars.use_master and "ON" or "OFF")) end
  QE_Window:UpdateUseMasterButton(btn)
end

local function OnMouseUp_Glyph(self, button, upInside)
   if upInside then
      if button == 2 then
         ClearMenu()
         AddMenuItem(QE_Language[QuickEnchanter.savedVars.language].create_menuitem, function() QuickEnchanter:CraftEnchantment(self.QE_index, true) end)
         AddMenuItem(QE_Language[QuickEnchanter.savedVars.language].copy_to_chat_menuitem, function() QuickEnchanter:CopyToChat(QuickEnchanter.permutations[self.QE_index]) end)
         AddMenuItem(QE_Language[QuickEnchanter.savedVars.language].runes_menuitem, function() QuickEnchanter:CopyToChat(QuickEnchanter.permutations[self.QE_index], 2) end)
         AddMenuItem(QE_Language[QuickEnchanter.savedVars.language].missing_runes_menuitem, function() QuickEnchanter:CopyToChat(QuickEnchanter.permutations[self.QE_index], 2, true) end)
         ShowMenu(self)
      end
   end
end

function QE_Window:UpdateUseMasterButton(btn)
  if (QuickEnchanter.savedVars.use_master) then
    btn:SetNormalTexture(edit_down)
    btn.color:SetColor(GREEN:UnpackRGBA())
  else 
    btn:SetNormalTexture(edit_up)
    btn.color:SetColor(DARK_RED:UnpackRGBA())
  end
end

function QE_Window:ToggleClickToCreateButton(btn)
  if (QuickEnchanter.savedVars.click_to_create == nil) then QuickEnchanter.savedVars.click_to_create = false end
  if (not QuickEnchanter.savedVars.click_to_create) then
    QuickEnchanter.savedVars.click_to_create = true
  elseif (QuickEnchanter.savedVars.click_to_create) then
    QuickEnchanter.savedVars.click_to_create = false
  end
  if (self:dbg(1)) then self:debug("Toggle Click to create " .. (QuickEnchanter.savedVars.click_to_create and "ON" or "OFF")) end
  QE_Window:UpdateClickToCreateButton(btn)
end

function QE_Window:UpdateClickToCreateButton(btn)
  if (QuickEnchanter.savedVars.click_to_create) then
    btn:SetNormalTexture(edit_down)
    btn.color:SetColor(GREEN:UnpackRGBA())
  else 
    btn:SetNormalTexture(edit_up)
    btn.color:SetColor(DARK_RED:UnpackRGBA())
  end
end

function QE_Window:ToggleCopyToChatButton(btn)
  if (QuickEnchanter.savedVars.copy_to_chat == nil) then QuickEnchanter.savedVars.copy_to_chat = false end
  if (not QuickEnchanter.savedVars.copy_to_chat) then
    QuickEnchanter.savedVars.copy_to_chat = true
  elseif (QuickEnchanter.savedVars.copy_to_chat) then
    QuickEnchanter.savedVars.copy_to_chat = false
  end
  if (self:dbg(1)) then self:debug("Toggle Copy to chat " .. (QuickEnchanter.savedVars.copy_to_chat and "ON" or "OFF")) end
  QE_Window:UpdateCopyToChatButton(btn)
end

function QE_Window:UpdateCopyToChatButton(btn)
  if (QuickEnchanter.savedVars.copy_to_chat) then
    btn:SetNormalTexture(chat_down)
    btn.color:SetColor(GREEN:UnpackRGBA())
  else 
    btn:SetNormalTexture(chat_up)
    btn.color:SetColor(DARK_RED:UnpackRGBA())
  end
end

function QE_Window:FixToPlayerLevel()
  local which = "player"
  if (self.top ~= nil) then
    local level, vlevel = GetUnitLevel(which), GetUnitVeteranRank(which)
    local slider = self.top.level_slider
    local other_slider = self.top.vlevel_slider
    if (vlevel > 0) then
      slider = self.top.vlevel_slider
      other_slider = self.top.level_slider
      level = vlevel
    end
    if (slider ~= nil) then
      local min, max = slider:GetMinMax()
      -- fix max-level
      if (level > max) then
        slider:SetMinMax(0, level)
      end
      slider:SetValue(level)
      if (other_slider ~= nil) then
        other_slider:SetValue(0)
      end
    end
  end
end

function QE_Window:PageUp()
  local value = self.top.slider:GetValue() - QuickEnchanter.current_lines
  if (value < 1) then value = 1 end
  self.top.slider:SetValue(value)
end

function QE_Window:PageDown()
  local value = self.top.slider:GetValue() + QuickEnchanter.current_lines
  if (value > #QuickEnchanter.permutations) then value = #QuickEnchanter.permutations end
  self.top.slider:SetValue(value)
end

function QE_Window:RefreshWindowBackground()
  local width, height = self.top:GetDimensions()
  local width_add = 400
  width = width + width_add
  local height_add = 200
  height = height + height_add
  self.top.background:SetDimensions(width, height)
  self.top.background:ClearAnchors()
  self.top.background:SetAnchor(TOPLEFT, top, TOPLEFT, -width_add/2, -height_add/2)
end

function QE_Window:addGlyphSelection(anchor, type, tip, addstep)
  -- add glyph type selection
  local top = self.top
  local idx = tonumber(type)
  if (top ~= nil and top.glyph_types[idx] == nil) then
    top.glyph_types[idx] = wm:CreateControl(top:GetName() .. "glyphtype" .. idx, top, CT_BUTTON)
    top.glyph_types[idx]:SetState(BSTATE_NORMAL)
    top.glyph_types[idx]:SetHandler("OnClicked", function() 
      QE_Window:ToggleGlyphTypes(idx)
      QuickEnchanter:Refresh(true)
    end)
    
    top.glyph_types[idx]:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].glyph_types[tip]) end)
    top.glyph_types[idx]:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
    top.glyph_types[idx]:SetMouseOverTexture(accept_over)
    top.glyph_types[idx]:SetNormalTexture(QE_Settings.glyph_type_info[idx])
    top.glyph_types[idx]:SetNormalTexture(QE_Settings.glyph_type_info[tonumber(idx)])
    if (addstep) then
      top.glyph_types[idx]:SetAnchor(LEFT, anchor, RIGHT)
    else
      top.glyph_types[idx]:SetAnchor(TOPLEFT, anchor, TOPRIGHT, QuickEnchanter.savedVars.line_height * icon_step_factor)
    end
    top.glyph_types[idx].color = wm:CreateControl(top.glyph_types[idx]:GetName() .. "color", top, CT_TEXTURE)
    top.glyph_types[idx].color:SetDrawLayer(top.glyph_types[idx]:GetDrawLayer() + 1)
    top.glyph_types[idx].color:SetAnchor(CENTER, top.glyph_types[idx], CENTER)
    top.glyph_types[idx].color:SetColor(1, 1, 1, 0.5) -- greying out the field
    QE_Window:UpdateGlyphButton(idx, top.glyph_types[idx])
  end
  
  return top.glyph_types[idx]
end

function QE_Window:addPlusMinus(anchor, which)
  -- add glyph type selection
  local top = self.top
  if (top ~= nil) then
    if (top.effect_selection == nil) then top.effect_selection = {} end
    
    top.effect_selection[which] = wm:CreateControl(top:GetName() ..  "effect" .. which, top, CT_BUTTON)
    top.effect_selection[which]:SetState(BSTATE_NORMAL)
    top.effect_selection[which]:SetHandler("OnClicked", function() 
      QE_Window:ToggleEffectTypes(which)
      QuickEnchanter:Refresh(true)
    end)
    
    top.effect_selection[which]:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language][QE_Settings.effect_type_info[tonumber(which)].text]) end)
    top.effect_selection[which]:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
    top.effect_selection[which]:SetMouseOverTexture(QE_Settings.effect_type_info[tonumber(which)].over)
    top.effect_selection[which]:SetNormalTexture(QE_Settings.effect_type_info[tonumber(which)].up)

    top.effect_selection[which].color = wm:CreateControl(top.effect_selection[which]:GetName() .. "color", top, CT_TEXTURE)
    top.effect_selection[which].color:SetDrawLayer(top.effect_selection[which]:GetDrawLayer() + 1)
    top.effect_selection[which].color:SetAnchor(CENTER, top.effect_selection[which], CENTER)
    top.effect_selection[which].color:SetColor(1, 1, 1, 0.5) -- greying out the field
    QE_Window:UpdateEffectButton(which, top.effect_selection[which])
  end
  
  return top.effect_selection[which]
end

function QE_Window:ToggleClassicLook()
  if (QuickEnchanter.savedVars.classic_look) then
    self.top.background:SetHidden(true)
    self.top.backdrop:SetHidden(false)
  else
    self.top.background:SetHidden(false)
    self.top.backdrop:SetHidden(true)
  end
  self:RedrawGlyphs()
  self:SetTextures()
end

function QE_Window:SetTextures()
  if (self.top ~= nil and self.top.destroy_button_all ~= nil) then
    self.top.destroy_button_all:SetNormalTexture(QuickEnchanter.savedVars.classic_look and "/esoui/art/crafting/white_burst.dds" or "/esoui/art/crafting/blackcircle.dds")
  end
end

function QE_Window:FixTextLengthToMax(texts, line_height)
  local max = 0
  
  for _, v in pairs(texts) do
    local width = v:GetTextDimensions()
    if (self:dbg(2)) then self:debug(v:GetName() .. " has text width " .. width) end
    if (width > max) then max = width end
  end
  
  for _, v in pairs(texts) do
    v:SetDimensions(max, line_height)
  end
end

function QE_Window:HideLines(value)
  local top = self.top
  if (top) then
    value = value and true or false
    top.top_line:SetHidden(value)
    top.sep1_line:SetHidden(value)
    top.sep2_line:SetHidden(value)
    top.sep3_line:SetHidden(value)
    top.sep4_line:SetHidden(value)
  end
end

function QE_Window:ResizeOverlay(button)
  button.color:SetDimensions(button:GetDimensions())
  button.color:ClearAnchors()
  button.color:SetAnchor(CENTER, button, CENTER)
end

function QE_Window:StartCraftingStation()
  self.top:SetParent(QE_Window_Screen)
  self.top.close:SetHidden(true)
end

function QE_Window:EndCraftingStation()
  self.top:SetParent(QuickEnchanterControl)
  self.top.close:SetHidden(false)
end

function QE_Window:ResizeRefresh()
  local top = self.top
  if (top) then
    self:CalculateWindowHeight()
    local width = 540 -- QuickEnchanter.savedVars.window_width
    top:SetDimensions(width, QuickEnchanter.current_height)

--[[
    if (QuickEnchanter.savedVars.save_position and QuickEnchanter.savedVars.save_x_pos ~= nil and QuickEnchanter.savedVars.save_y_pos ~= nil) then
      top:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, QuickEnchanter.savedVars.save_x_pos, QuickEnchanter.savedVars.save_y_pos)
    else
      top:SetAnchor(CENTER, GuiRoot, CENTER, 0, -525 + QuickEnchanter.current_height/2)
    end
]]--

    QE_Window:RefreshWindowBackground()
    
    local icon_width = QuickEnchanter.savedVars.line_height
    local icon_height = QuickEnchanter.savedVars.line_height
    if (icon_width < min_icon_size) then
      icon_width = min_icon_size
      icon_height = min_icon_size
    end
    local max_icon_size = width/icon_width_factor
    if (icon_width > max_icon_size) then
      icon_width = max_icon_size
      icon_height = max_icon_size
    end
    if (self:dbg(1)) then self:debug("icon height " .. icon_height) end
    local line_height = QuickEnchanter.savedVars.line_height
    local height = QuickEnchanter.current_height
    
    -- fix lines
    local line_width = width * 0.9
    top.top_line:SetDimensions(line_width, 2)
    top.top_line:SetAnchor(TOP, top, TOP, -1, 1)
    
    self:FixTextLengthToMax({ top.level_selection_label, top.glyph_type_selection_label, top.quality_selection_label, top.options_label }, line_height)

    local upper_margin = 5
    
    top.glyph_type_selection_label:ClearAnchors()
    top.glyph_type_selection_label:SetAnchor(TOPLEFT, top, TOPLEFT, 0, upper_margin)
    
    local step = icon_width/2
    for k,v in pairs(top.glyph_types) do
      v:SetDimensions(icon_width, icon_height)
      v.color:SetDimensions(icon_width, icon_height)
      v:ClearAnchors()
      v:SetAnchor(TOPLEFT, top.glyph_type_selection_label, TOPRIGHT, step)
      step = step + icon_width
    end

    for k,v in pairs(top.effect_selection) do
      v:SetDimensions(icon_width, icon_height)
      v.color:SetDimensions(icon_width, icon_height)
      v:ClearAnchors()
      v:SetAnchor(TOPLEFT, top.glyph_type_selection_label, TOPRIGHT, step)
      step = step + icon_width  
    end
    
    local line_step = upper_margin + line_height
    
    top.sep1_line:SetDimensions(line_width, 1)
    top.sep1_line:SetAnchor(TOP, top, TOP, -1, line_step * 1.2)
        
    top.level_selection_label:ClearAnchors()
    top.level_selection_label:SetAnchor(TOPLEFT, top.glyph_type_selection_label, TOPLEFT, 0, icon_height * 1.7)
 
    top.char_level:SetDimensions(icon_width * 2, icon_height * 2)
    top.char_level:SetAnchor(LEFT, top.level_selection_label, RIGHT, 0, -icon_height * 0.2)
     
    top.quality_selection_label:ClearAnchors()
    top.quality_selection_label:SetAnchor(TOPLEFT, top.level_selection_label, TOPLEFT, 0, icon_height * 2)
    
    for i=1, #QE_Settings.qualities do
      top.qualities[i]:SetDimensions(icon_width, icon_height)
      top.qualities[i].color:SetDimensions(top.qualities[i]:GetDimensions())
      top.qualities[i]:ClearAnchors()
      top.qualities[i]:SetAnchor(TOPLEFT, top.quality_selection_label, TOPRIGHT, (i-0.5) * icon_width, -icon_height * 0.2)
    end
    
    line_step = line_step + 2.1 * line_height
    top.sep2_line:SetDimensions(line_width, 1)
    top.sep2_line:SetAnchor(TOP, top, TOP, -1, line_step)
    
    top.options_label:ClearAnchors()
    top.options_label:SetAnchor(TOPLEFT, top.quality_selection_label, TOPLEFT, 0, 1.5 * icon_height)

    line_step = line_step + 1.7 * icon_height
    top.sep3_line:SetDimensions(line_width, 1)
    top.sep3_line:SetAnchor(TOP, top, TOP, -1, line_step)

    line_step = line_step + 1.6 * icon_height
    top.sep4_line:SetDimensions(line_width, 2)
    top.sep4_line:SetAnchor(TOP, top, TOP, -1, line_step)
    
    top.close:SetDimensions(icon_width, icon_height)
    
    top.title:ClearAnchors()
    top.title:SetAnchor(TOP, top, TOP, 0, line_height * 7)
      
    -- pagination refresh
    top.page_up:SetDimensions(icon_width, icon_height)
    top.page_down:SetDimensions(icon_width, icon_height)
    
    -- slider
    top.slider:SetDimensions(30, height)
    top.slider:ClearAnchors()
    top.slider:SetAnchor(LEFT,top,RIGHT,0,0)

    local lwidth, lheight = top.destroy_label:GetTextDimensions()
    top.destroy_label:SetDimensions(lwidth, lheight)
    top.destroy_label:ClearAnchors()
    top.destroy_label:SetAnchor(TOPLEFT, top.options_label, TOPLEFT, width - lwidth - 4 * icon_width)
    
    --top.safety_check_label:SetDimensions(lwidth, lheight)
    
    -- resize icons
    top.click_to_create:SetDimensions(icon_width, icon_height)
    top.click_to_create:ClearAnchors()
    top.click_to_create:SetAnchor(TOPLEFT, top.options_label, TOPRIGHT, icon_width/2, -0.2 * icon_height)
    self:ResizeOverlay(top.click_to_create)
    
    top.copy_to_chat:SetDimensions(icon_width, icon_height)
    top.copy_to_chat:ClearAnchors()
    top.copy_to_chat:SetAnchor(TOPLEFT, top.click_to_create, TOPRIGHT, icon_width/4)
    self:ResizeOverlay(top.copy_to_chat)
          
    top.destroy_button_all:SetDimensions(icon_width, icon_height)
    top.destroy_button_bank:SetDimensions(icon_width, icon_height)
    top.destroy_button_bag:SetDimensions(icon_width, icon_height)
    
    top.radio_buttons:SetDimensions(icon_width, icon_height)
    top.radio_buttons:ClearAnchors()
    top.radio_buttons:SetAnchor(TOPLEFT, top.copy_to_chat, TOPRIGHT, icon_width/4)
    self:ResizeOverlay(top.radio_buttons)
        
    top.show_unavailable:SetDimensions(icon_width, icon_height)
    top.show_unavailable:ClearAnchors()
    top.show_unavailable:SetAnchor(TOPLEFT, top.radio_buttons, TOPRIGHT, icon_width/4)
    self:ResizeOverlay(top.show_unavailable)
    
    top.use_master:SetDimensions(icon_width, icon_height)
    top.use_master:ClearAnchors()
    top.use_master:SetAnchor(TOPLEFT, top.show_unavailable, TOPRIGHT, icon_width/4)
    self:ResizeOverlay(top.use_master)
    
    top.create_writ_glyph:SetDimensions(icon_width, icon_height)
    top.create_writ_glyph:ClearAnchors()
    top.create_writ_glyph:SetAnchor(TOPLEFT, top.use_master, TOPRIGHT, icon_width/4)
    top.create_writ_glyph.color:SetDimensions(icon_width, icon_height)

    top.creation_counter:SetAnchor(LEFT, top.options_label, LEFT, 5, icon_height * 1.5)
      
    QE_Window:RedrawGlyphs()
  end
end

function QE_Window:UpdateLevelFilter(self, value)
  if (QE_Window.top ~= nil) then
    QE_Window.top.level_slider.label:SetText(value)
    QuickEnchanter.chosen_level = value
    if (value > 0) then
      if (QE_Window.top.vlevel_slider) then
        QuickEnchanter.chosen_veteran_level = 0 -- reset the other level slider
        QE_Window.top.vlevel_slider:SetValue(0)
      end
    end
  end
end

function QE_Window:UpdateVeteranLevelFilter(self, value)
  if (QE_Window.top ~= nil) then
    QE_Window.top.vlevel_slider.label:SetText(value)
    QuickEnchanter.chosen_veteran_level = value
    if (value > 0) then
     if (QE_Window.top.level_slider) then
        QuickEnchanter.chosen_level = 0 -- reset the other level slider
        QE_Window.top.level_slider:SetValue(0)
      end     
    end
  end
end

function QE_Window:InitializeLevelSlider(slider, start_value, max_value, func, tip)
  slider:SetMouseEnabled(true)
  slider:SetThumbTexture(scroll_texture, scroll_texture, scroll_texture, 30, QuickEnchanter.savedVars.line_height, 0, 0, 1, 1)
  slider:SetMinMax(0, max_value)
  slider:SetValue(start_value)
  slider:SetValueStep(1)
  slider:SetDimensions(120, 20)
  slider:SetOrientation(ORIENTATION_HORIZONTAL)
  slider:SetHandler("OnValueChanged", func)
  slider:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, tip) end)
  slider:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  
  if (start_value ~= 0) then QuickEnchanter.calculated = nil end
  
  local icon_height = QuickEnchanter.savedVars.line_height
  local icon_width = icon_height

  slider.bg = wm:CreateControl(slider:GetName() .. "_level_slider_bg", slider, CT_BACKDROP)
  slider.bg:SetCenterColor(0, 0, 0)
  slider.bg:SetHidden(false)
  slider.bg:SetAnchor(TOPLEFT, slider, TOPLEFT, 0, 4)
  slider.bg:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4)
  slider.bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4)
  
  slider.backdrop = wm:CreateControlFromVirtual(slider:GetName() .. "Level_SliderBackdrop", slider, "ZO_DefaultBackdrop")
  slider.backdrop:SetHidden(false)
  
  slider.label = wm:CreateControl(slider:GetName().."_label", slider, CT_LABEL)
  slider.label:SetFont("ZoFontGameSmall")
  slider.label:SetColor(1,1,1,1)
  slider.label:SetDrawLayer(slider:GetDrawLayer()+2)
  slider.label:SetText(slider:GetValue())
  slider.label:SetDimensions(icon_width, icon_height)
  slider.label:SetAnchor(CENTER, slider, CENTER)

  slider.label_left = wm:CreateControl(slider:GetName().."_label_left", slider, CT_LABEL)
  slider.label_left:SetFont("ZoFontGameSmall")
  slider.label_left:SetColor(1,1,1,1)
  slider.label_left:SetDrawLayer(slider:GetDrawLayer()+2)
  slider.label_left:SetText(0)
  slider.label_left:SetDimensions(slider.label_left:GetTextDimensions())
  slider.label_left:SetDimensions(icon_width, icon_height)
  
  slider.label_right = wm:CreateControl(slider:GetName().."_label_right", slider, CT_LABEL)
  slider.label_right:SetFont("ZoFontGameSmall")
  slider.label_right:SetColor(unpack(font_color))
  slider.label_right:SetDrawLayer(slider:GetDrawLayer()+2)
  slider.label_right:SetText(max_value)
  slider.label_right:SetDimensions(icon_width, icon_height)
  slider.label_right:SetAnchor(LEFT, slider, RIGHT, 10)
end

function QE_Window:CreateLine(field)
  local top = self.top
  --top[field] = WINDOW_MANAGER:CreateControl(top:GetName() .. field, top, CT_BACKDROP)
  --top[field]:SetCenterColor(unpack(line_center_color))
  --top[field]:SetEdgeColor(unpack(line_edge_color))
  top[field] = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)" .. field, top, "ZO_WideHorizontalDivider")
end

function QE_Window:ToggleDestroyWindow()
  if (self.safety_check ~= nil) then
    self.safety_check:SetHidden(not self.safety_check:IsHidden())
  end
end

function QE_Window:ExtractCheck(which, btn)
  if (btn ~= nil and self.runes_display ~= nil) then
    self.runes_display:SetAnchor(CENTER, btn, CENTER)
  end
  
  if (QuickEnchanter.savedVars.safety_check) then
    self:ToggleDestroyWindow()
    if (self.safety_check ~= nil) then
      self.safety_check.which = which
      if (btn ~= nil) then
        self.safety_check:SetAnchor(CENTER, btn, CENTER)
      end
    end
  else
    QuickEnchanter:ResetExtractedRunes()
    QuickEnchanter:ExtractGlyphs(which)
  end
end

function QE_Window:SavePosition()
  QuickEnchanter.savedVars.save_x_pos = self.top:GetLeft()
  QuickEnchanter.savedVars.save_y_pos = self.top:GetTop()
  if (self:dbg(1)) then self:debug("save position " .. QuickEnchanter.savedVars.save_x_pos .. "," .. QuickEnchanter.savedVars.save_y_pos) end
end

function QE_Window:drawRunes(start_pos)
  if (self:dbg(1)) then self:debug("drawRunes") end
  local max_num = QE_Settings.max_num_runes_result
  local label_length = QE_Settings.rune_result_list_width
  local height = QuickEnchanter.savedVars.line_height
  if (self.runes_display.rune == nil) then self.runes_display.rune = {} end
  
  -- hide previously created result runes
  local pos = 1
  while (self.runes_display.rune[pos] ~= nil) do
    self.runes_display.rune[pos]:SetHidden(false)
    pos = pos + 1
  end
      
  if (QuickEnchanter.savedVars.display_result_runes and QuickEnchanter.extracted_runes ~= nil and QuickEnchanter.found_extracted_runes) then
    if (self:dbg(1)) then self:debug("found runes") end
    local found = 0
    local pos = 1
    
    for name, v in pairs(QuickEnchanter.extracted_runes) do
      if (pos >= start_pos and pos < start_pos + max_num) then
        -- either hide or create when necessary
        if (self.runes_display.rune[pos] == nil) then
          -- draw runes result for 
          if (self.runes_display.rune[pos] == nil) then
            self.runes_display.rune[pos] = wm:CreateControl(self.top:GetName() .. "rune" .. pos, self.runes_display, CT_BUTTON)
            self.runes_display.rune[pos]:SetHandler("OnMouseEnter", function (self) if (self.text) then ZO_Tooltips_ShowTextTooltip(self, RIGHT, self.text) end end)
            self.runes_display.rune[pos]:SetHandler("OnMouseExit", function (self) ZO_Tooltips_HideTextTooltip() end)
          end

          -- name of the rune
          self.runes_display.rune[pos].label = wm:CreateControl(self.runes_display.rune[pos]:GetName() .. "Label", self.runes_display.rune[pos], CT_LABEL)
          self.runes_display.rune[pos].label:SetFont("ZoFontGame")
          self.runes_display.rune[pos].label:SetVerticalAlignment(CENTER)
          self.runes_display.rune[pos].label:SetDimensions(label_length, height)
        else
          self.runes_display.rune[pos]:SetHidden(false) -- re-activate
        end

        -- anchor results
        self.runes_display.rune[pos]:SetDimensions(label_length, height)
        self.runes_display.rune[pos]:ClearAnchors()
        self.runes_display.rune[pos]:SetAnchor(TOPLEFT, self.runes_display, TOPLEFT, 5, 5 + (pos-start_pos+1) * height)
        self.runes_display.rune[pos].label:ClearAnchors()
        self.runes_display.rune[pos].label:SetAnchor(CENTER, self.runes_display.rune[pos], CENTER)
        
        -- fill in data           
        local icon, quality, count = unpack(v)
        name = name and name or ""
        icon = icon and zo_iconFormat(icon, QuickEnchanter.savedVars.tooltip_icon_size, QuickEnchanter.savedVars.tooltip_icon_size) or ""
        count = count and count or 0
        self.runes_display.rune[pos].label:SetText(string.format("%3d", count) .. " x " .. icon)
        self.runes_display.rune[pos].text = GetItemQualityColor(quality):Colorize(name)
               
        found = found + 1
      else
        if (self.runes_display.rune[pos] ~= nil) then self.runes_display.rune[pos]:SetHidden(true) end
      end
      pos = pos + 1
    end
    
    if (found > 0) then
      -- hide remaining runes
      self.runes_display:SetHidden(false)
      self.runes_display.slider:SetMinMax(1, found)
    end
  end
end

function QE_Window:MarkQuestGlyphAvailable()
  self:MarkQuestColor(0, 1, 0, 1)
end

function QE_Window:MarkQuestGlyphNotAvailable()
  self:MarkQuestColor(1, 0, 0, 1)
end

function QE_Window:MarkQuestGlyphAvailableRunesIncomplete()
  self:MarkQuestColor(1, 0.8, 0, 1)
end

function QE_Window:MarkQuestColor(r,g,b,a)
  if (self.top ~= nil and self.top.create_writ_glyph ~= nil and self.top.create_writ_glyph.color ~= nil) then
    self.top.create_writ_glyph.color:SetColor(r,g,b,a)
  end
end

function QE_Window:CreateButtonOverlay(button, texture)
  button.color = wm:CreateControl(button:GetName() .. "color", button, CT_TEXTURE)
  button.color:SetDrawLayer(button:GetDrawLayer() + 1)
  button.color:SetAnchor(CENTER, button, CENTER)
  button.color:SetTexture(texture)
  button.color:SetColor(DARK_RED:UnpackRGBA())
end

function QE_Window:InitializeMenu()
  ZO_CreateStringId("SI_QUICKENCHANTER", "Quick Enchanter")

  if LES then
    LES:Init()
    local tabData = {
      name = SI_QUICKENCHANTER,
      descriptor = QuickEnchanter.name, -- Must just be unique identifier. addon name is a good start
      disabled = "esoui/art/crafting/enchantment_tabicon_potency_disabled.dds",
      pressed = "esoui/art/crafting/enchantment_tabicon_potency_down.dds",
      highlight = "esoui/art/crafting/enchantment_tabicon_potency_over.dds",
      normal = "esoui/art/crafting/enchantment_tabicon_potency_up.dds",
      callback = function(tabData)
        LES:ShowRuneSlotContainer()
        QE_Window:HideMainWindow(false)
      end,
    }
    return LES:AddTab(tabData)
  end
end

function QE_Window:drawMasterWindow()
  if (self:dbg(1)) then self:debug("drawMasterWindow") end

  QE_Window_Screen = self:InitializeMenu() -- Diese Variable könnte auch an QuickEnchanter hängen, hat global zu sein

  local top = wm:CreateControl("Content", QE_Window_Screen, CT_CONTROL) -- wm:CreateTopLevelWindow("QE_Window_Screen")
  self.top = top
  top:ClearAnchors() -- Normalerweise AnchorsFill
  top:SetAnchor(TOPLEFT)
  --self.top:SetParent(QE_Window_Screen)
  self.top:SetParent(QuickEnchanterControl)
  
  -- create security check for destruction of glyphs
  local safety_check = wm:CreateTopLevelWindow("QE_Window_Screen_Safety")
  self.safety_check = safety_check
  safety_check:SetAnchor(CENTER, GuiRoot, CENTER)
  safety_check:SetDimensions(100, 80)
  safety_check:SetDrawLayer(top:GetDrawLayer()+1)
  safety_check.backdrop = wm:CreateControlFromVirtual("QE_Window_Screen_Safety_Backdrop", QE_Window_Screen_Safety, "ZO_DefaultBackdrop")
  safety_check:SetHidden(true)
  
  safety_check.label = wm:CreateControl(safety_check:GetName() .. "_label", safety_check, CT_LABEL)
  safety_check.label:SetText(QE_Language[QuickEnchanter.savedVars.language].destroy_label)
  safety_check.label:SetFont("ZoFontGame")
  safety_check.label:SetColor(unpack(font_color))
  safety_check.label:SetDimensions(safety_check.label:GetTextDimensions())
  safety_check.label:SetAnchor(TOP, safety_check, TOP, 0, 10)

  safety_check.yes = wm:CreateControl(safety_check:GetName() .. "_yes", safety_check, CT_BUTTON)
  safety_check.yes:SetHandler("OnClicked", function()
    QE_Window:ToggleDestroyWindow()
    if (safety_check.which ~= nil) then
      QuickEnchanter:ResetExtractedRunes()
      QuickEnchanter:ExtractGlyphs(safety_check.which)
    end
  end)
  safety_check.yes:SetNormalTexture(accept_up)
  safety_check.yes:SetMouseOverTexture(accept_over)
  safety_check.yes:SetState(BSTATE_NORMAL)
  safety_check.yes:SetAnchor(BOTTOMLEFT, safety_check, BOTTOMLEFT, 5)
  safety_check.yes:SetDimensions(unpack(control_button_size))

  safety_check.no = wm:CreateControl(safety_check:GetName() .. "_no", safety_check, CT_BUTTON)
  safety_check.no:SetHandler("OnClicked", function() 
    QE_Window:ToggleDestroyWindow()
    safety_check.which = nil
  end)
  safety_check.no:SetNormalTexture(decline_up)
  safety_check.no:SetMouseOverTexture(decline_over)
  safety_check.no:SetState(BSTATE_NORMAL)
  safety_check.no:SetAnchor(BOTTOMRIGHT, safety_check, BOTTOMRIGHT, -5)
  safety_check.no:SetDimensions(unpack(control_button_size))

  -- display result runes
  local runes_display = wm:CreateTopLevelWindow("QE_Window_Rune_Result")
  self.runes_display = runes_display
  runes_display:SetAnchor(CENTER, GuiRoot, CENTER)
  runes_display:SetDimensions(QE_Settings.rune_result_list_width, QE_Settings.rune_result_list_height)
  runes_display:SetDrawLayer(top:GetDrawLayer()+1)
  runes_display:SetHidden(true)
  runes_display.backdrop = wm:CreateControlFromVirtual("QE_Window_Rune_Result_Backdrop", QE_Window_Rune_Result, "ZO_DefaultBackdrop")

  runes_display.button = wm:CreateControl(runes_display:GetName().."_button", top, CT_BUTTON)
  runes_display.button:SetAnchor(CENTER, runes_display, CENTER)
  runes_display.button:SetDimensions(runes_display:GetDimensions())
  runes_display.button:SetHandler("OnMouseEnter", function(self)
    if (not QE_Window.runes_display:IsHidden()) then
      ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].display_result_runes_label_tip)
    end
    end)
  runes_display.button:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)  
  
  runes_display.label = wm:CreateControl(runes_display:GetName() .. "_label", runes_display, CT_LABEL)
  runes_display.label:SetFont("ZoFontGame")
  runes_display.label:SetColor(unpack(font_color))
  runes_display.label:SetDimensions(runes_display.label:GetTextDimensions())
  runes_display.label:SetAnchor(TOP, runes_display, TOP, 0, 20)

  runes_display.yes = wm:CreateControl(runes_display:GetName() .. "_yes", runes_display, CT_BUTTON)
  runes_display.yes:SetHandler("OnClicked", function() QE_Window.runes_display:SetHidden(true) end)
  runes_display.yes:SetNormalTexture(accept_up)
  runes_display.yes:SetMouseOverTexture(accept_over)
  runes_display.yes:SetState(BSTATE_NORMAL)
  runes_display.yes:SetAnchor(TOPRIGHT, runes_display, TOPRIGHT, 0)
  runes_display.yes:SetDimensions(unpack(control_button_size))
  
  -- put slider for result window
  runes_display.slider = wm:CreateControl(runes_display:GetName() .. "_Slider", runes_display, CT_SLIDER)
  runes_display.slider:SetMouseEnabled(true)
  local slider_width = 15
  runes_display.slider:SetDimensions(slider_width, QE_Settings.rune_result_list_height)
  runes_display.slider:SetThumbTexture(scroll_texture, scroll_texture, scroll_texture, slider_width, QE_Settings.rune_result_list_height, 0, 0, 1, 1)
  runes_display.slider:SetValueStep(1)
  runes_display.slider:SetValue(1)
  runes_display.slider:SetHandler("OnValueChanged", function (self, value, eventReason) QE_Window:drawRunes(value) end )
  runes_display.slider:SetHandler("OnMouseWheel", 
    function (self, delta)
      QE_Window.runes_display.slider:SetValue(QE_Window.runes_display.slider:GetValue() - delta)
    end )
  runes_display.slider:SetAnchor(LEFT, runes_display, RIGHT)
   
  -- go on with the rest
  self:CalculateWindowHeight()
  if (self:dbg(1)) then self:debug("drawMasterWindow: Window dimension is " .. QuickEnchanter.savedVars.window_width .. "x".. QuickEnchanter.current_height) end
  --top:SetDrawLayer(1)
  ----top:SetAnchor(CENTER,GuiRoot,CENTER,0, -525 + QuickEnchanter.current_height/2)
  top:SetMouseEnabled(true)
  --top:SetMovable(true)
  self:HideMainWindow(true)

  top:SetHandler("OnMouseWheel", function (self, delta) QE_Window.top.slider:SetValue(QE_Window.top.slider:GetValue() - delta) end )

--[[
  top:SetHandler("OnMoveStop", function ()
    if (QuickEnchanter.savedVars.save_position) then
      QE_Window:SavePosition()
    end
  end)
]]--

  top.qualities = {}

  -- create background
  top.background = wm:CreateControl(top:GetName() .. "Background", top, CT_TEXTURE)
  --top.background:SetDrawLayer(1)
  top.background:SetTexture("ESOUI\\art\\lorelibrary\\lorelibrary_note.dds") -- lorelibrary_note lorelibrary_paperbook lorelibrary_scroll skinbook
  top.backdrop = wm:CreateControl("QE_Window_Backdrop", QE_Window_Screen, CT_CONTROL) -- wm:CreateControlFromVirtual("QE_Window_Backdrop", QE_Window_Screen, "ZO_DefaultBackdrop")

  -- create lines
  self:CreateLine("top_line")
  self:CreateLine("sep1_line")
  self:CreateLine("sep2_line")
  self:CreateLine("sep3_line")
  self:CreateLine("sep4_line")
  
  self:HideLines(QuickEnchanter.savedVars.no_lines)
  
  self:ToggleClassicLook()
  
  -- Glyph Type selection
  top.glyph_type_selection_label = wm:CreateControl(top:GetName() .. "_glyph_type_selection_label", top, CT_LABEL)
  top.glyph_type_selection_label:SetText(QE_Language[QuickEnchanter.savedVars.language].glyph_type_selection_label .. ":")
  top.glyph_type_selection_label:SetFont("ZoFontGame")
  top.glyph_type_selection_label:SetColor(unpack(font_color))

  top.glyph_types = {}
  local ctrl = self:addGlyphSelection(top.glyph_type_selection_label, tonumber(ITEMTYPE_GLYPH_WEAPON), 1, 1.5 * QuickEnchanter.savedVars.line_height)
  ctrl = self:addGlyphSelection(ctrl, tonumber(ITEMTYPE_GLYPH_ARMOR), 2)
  ctrl = self:addGlyphSelection(ctrl, tonumber(ITEMTYPE_GLYPH_JEWELRY), 3)
  ctrl = self:addGlyphSelection(ctrl, 0, 4)
  
  -- effect selection
  ctrl = self:addPlusMinus(ctrl, 1)
  ctrl = self:addPlusMinus(ctrl, -1)
  
  -- level selection
  top.level_selection_label = wm:CreateControl(top:GetName() .. "_level_selection_label", top, CT_LABEL)
  top.level_selection_label:SetText(QE_Language[QuickEnchanter.savedVars.language].level .. ":")
  top.level_selection_label:SetFont("ZoFontGame")
  top.level_selection_label:SetColor(unpack(font_color))

  -- quality selection
  top.quality_selection_label = wm:CreateControl(top:GetName() .. "_quality_selection_label", top, CT_LABEL)
  top.quality_selection_label:SetText(QE_Language[QuickEnchanter.savedVars.language].quality .. ":")
  top.quality_selection_label:SetFont("ZoFontGame")
  top.quality_selection_label:SetColor(unpack(font_color))
  
  -- quality check-buttons
  for i=1, #QE_Settings.qualities do
    if (top.qualities[i] == nil) then
      top.qualities[i] = wm:CreateControl(top:GetName() .. QE_Settings.qualities[i], top, CT_BUTTON)
      top.qualities[i]:SetState(BSTATE_NORMAL)
      top.qualities[i]:SetHandler("OnClicked", function() 
          QE_Window:ToggleQualities(i)
          QuickEnchanter:Refresh(true)
        end)
      top.qualities[i]:SetNormalTexture(accept_up)
      top.qualities[i]:SetMouseOverTexture(accept_over)
      top.qualities[i]:SetDisabledTexture(disabled)
      top.qualities[i]:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, self.text) end)
      top.qualities[i]:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
      
      top.qualities[i].color = wm:CreateControl(top:GetName() .. QE_Settings.qualities[i] .. "color", top, CT_TEXTURE)
      top.qualities[i].color:SetDrawLayer(top.qualities[i]:GetDrawLayer() + 1)
      top.qualities[i].color:SetAnchor(CENTER, top.qualities[i], CENTER)
      
      QE_Window:UpdateButton(i, top.qualities[i])
    end
    local color = GetItemQualityColor(QE_Settings.qualities[i])
    top.qualities[i].color:SetColor(color:UnpackRGBA())
    top.qualities[i].text = QuickEnchanter:getColorized(QE_Language[QuickEnchanter.savedVars.language].qualities[i], color:ToHex())
  end

  -- options label
  top.options_label = wm:CreateControl(top:GetName() .. "_options_label", top, CT_LABEL)
  top.options_label:SetText(QE_Language[QuickEnchanter.savedVars.language].options .. ":")
  top.options_label:SetFont("ZoFontGame")
  top.options_label:SetColor(unpack(font_color))
    
  -- add closing button in top-right corner
  local ctrl = wm:CreateControl("QE_Window_CloseButton", top, CT_BUTTON)
  ctrl:SetAnchor(TOPRIGHT, top, TOPRIGHT, -4, 4)
  ctrl:SetState(BSTATE_NORMAL)
  ctrl:SetHandler("OnClicked", function() QE_Window:HideMainWindow(true) end)
  ctrl:SetNormalTexture(decline_up)
  ctrl:SetMouseOverTexture(decline_over)
  top.close = ctrl
  
  -- pagination
  if (top.page_up == nil) then
    top.page_up = wm:CreateControl(top:GetName() .. "pagination_up", top, CT_BUTTON)
    top.page_up:SetHandler("OnClicked", function() 
      QE_Window:PageUp()
      --QE_Window:RedrawGlyphs(QE_Window_Screen.slider:GetValue())
    end)
    top.page_up:SetNormalTexture("/esoui/art/actionbar/pagination_up_up.dds")
    top.page_up:SetMouseOverTexture("/esoui/art/actionbar/pagination_up_over.dds")
    top.page_up:SetState(BSTATE_NORMAL)
    top.page_up:SetAnchor(TOPRIGHT, top, TOPRIGHT, 0, 37) -- SetAnchor(TOPRIGHT, top.close, BOTTOMRIGHT)
  end
  
  if (top.page_down == nil) then
    top.page_down = wm:CreateControl(top:GetName() .. "pagination_down", top, CT_BUTTON)
    top.page_down:SetHandler("OnClicked", function() 
      QE_Window:PageDown()
      --QE_Window:RedrawGlyphs(QE_Window_Screen.slider:GetValue())
    end)
    top.page_down:SetNormalTexture("/esoui/art/actionbar/pagination_down_up.dds")
    top.page_down:SetMouseOverTexture("/esoui/art/actionbar/pagination_down_over.dds")
    top.page_down:SetState(BSTATE_NORMAL)
    top.page_down:SetAnchor(TOPRIGHT, top.page_up, BOTTOMRIGHT)
    local layer = top:GetDrawLayer()
    top.page_down:SetDrawLayer(layer + 2)
  end
  
  -- put a page slider
  top.slider = wm:CreateControl(QuickEnchanter.name .. "_Slider",top,CT_SLIDER)
  top.slider:SetMouseEnabled(true)
  top.slider:SetThumbTexture(scroll_texture,scroll_texture,scroll_texture,30,50,0,0,1,1)
  QuickEnchanter:getPermutations()
  top.slider:SetMinMax(1, #QuickEnchanter.permutations)
  top.slider:SetValueStep(1)
  top.slider:SetHandler("OnValueChanged", function(self,value,eventReason)
    if (not self.my_deactivate) then
      QE_Window:drawGlyphs(self, value)
    end
  end )
  
  -- add click to create
  top.click_to_create = wm:CreateControl(top:GetName() .. "click_to_create", top, CT_BUTTON)
  top.click_to_create:SetState(BSTATE_NORMAL)
  top.click_to_create:SetHandler("OnClicked", function()
    QE_Window:ToggleClickToCreateButton(top.click_to_create)
  end)
  top.click_to_create:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].click_to_create_label_tip) end)
  top.click_to_create:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  top.click_to_create:SetMouseOverTexture(edit_over)
  top.click_to_create:SetNormalTexture(edit_up)
  self:CreateButtonOverlay(top.click_to_create, edit_up)
  QE_Window:MarkQuestGlyphNotAvailable()
  QE_Window:UpdateClickToCreateButton(top.click_to_create)
  
  -- add copy to chat
  top.copy_to_chat = wm:CreateControl(top:GetName() .. "copy_to_chat", top, CT_BUTTON)
  top.copy_to_chat:SetState(BSTATE_NORMAL)
  top.copy_to_chat:SetHandler("OnClicked", function()
    QE_Window:ToggleCopyToChatButton(top.copy_to_chat)
  end)
  top.copy_to_chat:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].copy_to_chat_label_tip) end)
  top.copy_to_chat:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  top.copy_to_chat:SetMouseOverTexture(chat_over)
  top.copy_to_chat:SetNormalTexture(chat_up)
  top.copy_to_chat:SetAnchor(TOPLEFT, top.click_to_create, TOPRIGHT)
  self:CreateButtonOverlay(top.copy_to_chat, chat_up)
  QE_Window:UpdateCopyToChatButton(top.copy_to_chat)
  
  -- add radio-buttons selection
  top.radio_buttons = wm:CreateControl(top:GetName() .. "radio_buttons", top, CT_BUTTON)
  top.radio_buttons:SetState(BSTATE_NORMAL)
  top.radio_buttons:SetHandler("OnClicked", function()
    QE_Window:ToggleRadioButtons(top.radio_buttons)
  end)
  top.radio_buttons:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].radio_buttons_label_tip) end)
  top.radio_buttons:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  top.radio_buttons:SetMouseOverTexture(radio_over)
  top.radio_buttons:SetNormalTexture(radio_up)
  self:CreateButtonOverlay(top.radio_buttons, radio_up)
  QE_Window:UpdateRadioButtons(top.radio_buttons)

  -- show unavailable glyphs
  top.show_unavailable = wm:CreateControl(top:GetName() .. "_show_unavailable", top, CT_BUTTON)
  top.show_unavailable:SetState(BSTATE_NORMAL)
  top.show_unavailable:SetHandler("OnClicked", function()
    QE_Window:ToggleShowUnavailableButton(top.show_unavailable)
    QuickEnchanter:Refresh(true)
  end)
  top.show_unavailable:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].show_unavailable_label_tip) end)
  top.show_unavailable:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  top.show_unavailable:SetMouseOverTexture(edit_cancel_over)
  top.show_unavailable:SetNormalTexture(edit_cancel_up)
  self:CreateButtonOverlay(top.show_unavailable, edit_cancel_up)
  QE_Window:UpdateShowUnavailableButton(top.show_unavailable)

  -- use master list
  top.use_master = wm:CreateControl(top:GetName() .. "_use_master", top, CT_BUTTON)
  top.use_master:SetState(BSTATE_NORMAL)
  top.use_master:SetHandler("OnClicked", function()
    QE_Window:ToggleUseMasterButton(top.use_master)
    QuickEnchanter:Refresh(true)
  end)
  top.use_master:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].use_master_label_tip) end)
  top.use_master:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  top.use_master:SetMouseOverTexture(edit_over)
  top.use_master:SetNormalTexture(edit_up)
  self:CreateButtonOverlay(top.use_master, edit_up)
  QE_Window:UpdateUseMasterButton(top.use_master)
  
  -- enchanter writ
  top.create_writ_glyph = wm:CreateControl(top:GetName() .. "_create_writ_glyph", top, CT_BUTTON)
  top.create_writ_glyph:SetState(BSTATE_NORMAL)
  top.create_writ_glyph:SetHandler("OnClicked", function()
    QuickEnchanter:createWritGlyph()
  end)
  top.create_writ_glyph:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].create_writ_glyph_label_tip) end)
  top.create_writ_glyph:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  top.create_writ_glyph:SetMouseOverTexture(quest_icon_over)
  top.create_writ_glyph:SetNormalTexture(quest_icon)
  
  -- overlay for enchanter writ quest  
  top.create_writ_glyph.color = wm:CreateControl(top:GetName() .. top.create_writ_glyph:GetName() .. "color", top.create_writ_glyph, CT_TEXTURE)
  top.create_writ_glyph.color:SetDrawLayer(top.create_writ_glyph:GetDrawLayer() + 1)
  top.create_writ_glyph.color:SetAnchor(CENTER, top.create_writ_glyph, CENTER)
  top.create_writ_glyph.color:SetTexture(quest_icon)
  QE_Window:MarkQuestGlyphNotAvailable()
      
  -- add label for destroy
  top.destroy_label = wm:CreateControl(top:GetName() .. "_destroy_label", top, CT_LABEL)
  top.destroy_label:SetText(QE_Language[QuickEnchanter.savedVars.language].destroy_label .. ":")
  top.destroy_label:SetDrawLevel(top:GetDrawLevel())
  top.destroy_label:SetVerticalAlignment(BOTTOM)
  top.destroy_label:SetFont("ZoFontGame")
  top.destroy_label:SetColor(1,1,1,1)
  top.destroy_label:SetHidden(false)
  top.destroy_label:SetAnchor(LEFT, top.create_writ_glyph, RIGHT, 10, 0)
  
  -- add button for destroy bag
  top.destroy_button_bag = wm:CreateControl(top:GetName() .. "destroybuttonbag", top, CT_BUTTON)
  top.destroy_button_bag:SetNormalTexture("ESOUI/art/inventory/inventory_all_tabicon_active.dds")
  top.destroy_button_bag:SetState(BSTATE_NORMAL)
  top.destroy_button_bag:SetHandler("OnClicked",function()
    self:ExtractCheck(BAG_BACKPACK, top.destroy_button_bag)
  end)
  top.destroy_button_bag:SetHidden(false)
  top.destroy_button_bag:SetAnchor(LEFT, top.destroy_label, RIGHT, 0, 0)
  top.destroy_button_bag:SetHandler("OnMouseEnter",function(self) ZO_Tooltips_ShowTextTooltip(self,TOP,QE_Language[QuickEnchanter.savedVars.language].destroy_bag_tip) end)
  top.destroy_button_bag:SetHandler("OnMouseExit",function(self) ZO_Tooltips_HideTextTooltip() end)
  
  -- add button for destroy bank
  top.destroy_button_bank = wm:CreateControl(top:GetName() .. "destroybuttonbank", top, CT_BUTTON)
  top.destroy_button_bank:SetNormalTexture("/esoui/art/guild/guild_bankaccess.dds")
  top.destroy_button_bank:SetState(BSTATE_NORMAL)
  top.destroy_button_bank:SetHandler("OnClicked",function() self:ExtractCheck(BAG_BANK, top.destroy_button_bank) end)
  top.destroy_button_bank:SetHidden(false)
  top.destroy_button_bank:SetAnchor(LEFT, top.destroy_button_bag, RIGHT, 0, 0)
  top.destroy_button_bank:SetHandler("OnMouseEnter",function(self) ZO_Tooltips_ShowTextTooltip(self,TOP,QE_Language[QuickEnchanter.savedVars.language].destroy_bank_tip) end)
  top.destroy_button_bank:SetHandler("OnMouseExit",function(self) ZO_Tooltips_HideTextTooltip() end)  
  
  -- add button for destroy all
  top.destroy_button_all = wm:CreateControl(top:GetName() .. "destroybuttonall", top, CT_BUTTON)
  top.destroy_button_all:SetState(BSTATE_NORMAL)
  top.destroy_button_all:SetHandler("OnClicked",function() self:ExtractCheck(-1, top.destroy_button_all) end)
  top.destroy_button_all:SetHidden(false)
  top.destroy_button_all:SetAnchor(LEFT, top.destroy_button_bank, RIGHT, 0, 0)
  top.destroy_button_all:SetHandler("OnMouseEnter",function(self) ZO_Tooltips_ShowTextTooltip(self,TOP,QE_Language[QuickEnchanter.savedVars.language].destroy_all_tip) end)
  top.destroy_button_all:SetHandler("OnMouseExit",function(self) ZO_Tooltips_HideTextTooltip() end)
  
  -- add char button for selecting by char level
  top.char_level = wm:CreateControl(top:GetName() .. "char_level", top, CT_BUTTON)
  top.char_level:SetState(BSTATE_NORMAL)
  top.char_level:SetHandler("OnClicked",function()
    QE_Window:FixToPlayerLevel()
    QuickEnchanter:Refresh()
    end)
  top.char_level:SetNormalTexture(char_up)
  top.char_level:SetMouseOverTexture(char_over)
  top.char_level:SetHandler("OnMouseEnter",function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].char_level_tip) end)
  top.char_level:SetHandler("OnMouseExit",function(self) ZO_Tooltips_HideTextTooltip() end)
  
  -- add buttons for level selection
  top.level_slider = wm:CreateControl(top:GetName() .. "_level_slider", top, CT_SLIDER)
  self:InitializeLevelSlider(
    top.level_slider,
    QuickEnchanter.savedVars.last_level and QuickEnchanter.savedVars.last_level or (QuickEnchanter.chosen_level and QuickEnchanter.chosen_level or 0),
    QE_Settings.max_level,
    function(self, value, eventReason) 
     QE_Window:UpdateLevelFilter(self, value)
     QuickEnchanter.savedVars.last_level=value
     QuickEnchanter:Refresh(true)
     end,
    QE_Language[QuickEnchanter.savedVars.language].level
  )
  if (top.level_slider:GetValue() ~= 0) then
    QuickEnchanter.chosen_level=top.level_slider:GetValue()
  end
  
  -- anchor slider 
  top.level_slider:SetAnchor(LEFT, top.level_slider.label_left, RIGHT)
  top.level_slider.label_left:SetAnchor(LEFT, top.char_level, RIGHT)

  -- add buttons for veteran vlevel selection
  top.vlevel_slider = wm:CreateControl(top:GetName() .. "_vlevel_slider", top, CT_SLIDER)
  self:InitializeLevelSlider(
    top.vlevel_slider,
    QuickEnchanter.savedVars.last_veteran_level and QuickEnchanter.savedVars.last_veteran_level or (QuickEnchanter.chosen_veteran_level and QuickEnchanter.chosen_veteran_level or 0),
    QE_Settings.max_veteran_level,
    function(self,value,eventReason) 
     QE_Window:UpdateVeteranLevelFilter(self, value)
     QuickEnchanter.savedVars.last_veteran_level=value
     QuickEnchanter:Refresh(true)
     end,
     QE_Language[QuickEnchanter.savedVars.language].vlevel
    )
  if (top.vlevel_slider:GetValue() ~= 0) then
    QuickEnchanter.chosen_veteran_level=top.vlevel_slider:GetValue()
  end
    
  -- anchor slider
  top.vlevel_slider:SetAnchor(LEFT, top.vlevel_slider.label_left, RIGHT)
  top.vlevel_slider.label_left:SetAnchor(LEFT, top.level_slider.label_right, RIGHT, 5)

  self:SetTextures()
  
  -- add title label
  top.title = wm:CreateControl("QE_Window_TitleLabel",QE_Window_Screen,CT_LABEL)
  top.title:SetFont("ZoFontWinH3")
  top.title:SetColor(1,1,1,1)
  self.title = top.title
  self:SetTitleText(0)
  
  top.credits = wm:CreateControl("QE_Window_Credits", QE_Window_Screen, CT_LABEL)
  top.credits:SetFont("ZoFontGameSmall")
  top.credits:SetColor(1,1,1,1)
  top.credits:SetAnchor(BOTTOM, QE_Window_Screen, BOTTOM, 0, -5)
  top.credits:SetText("|cFFAA88" .. QuickEnchanter.name .. "|r ".. QE_Settings.version.." - |c4066FF@Criscal|r - " .. QE_Language[QuickEnchanter.savedVars.language].settings_tip)
  
  -- add button for settings
  top.settings = wm:CreateControl(top:GetName() .. "_settings", top, CT_BUTTON)
  top.settings:SetNormalTexture(settings_over)
  top.settings:SetState(BSTATE_NORMAL)
  top.settings:SetDimensions(20, 20)
  top.settings:SetHandler("OnClicked",function()
    QE_Settings:showSettings()
  end)
  top.settings:SetHidden(false)
  top.settings:SetAnchor(LEFT, top.credits, RIGHT, 0, 0)
  top.settings:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self,TOP,QE_Language[QuickEnchanter.savedVars.language].settings_tip) end)
  top.settings:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  
  -- add button for setting number of glyphs to be created
  top.creation_counter = wm:CreateControl(runes_display:GetName() .. "_creation_counter", top, CT_SLIDER)
  self:InitializeLevelSlider(
    top.creation_counter,
    0,
    100,
    function(self, value, eventReason) 
      QE_Window.top.creation_counter.label:SetText(value)
    end,
    QE_Language[QuickEnchanter.savedVars.language].glyph_amount_label_tip
  )
  top.creation_counter.label:SetText(1) -- show start value 1
  
  if (self.calculated == nil) then
    QuickEnchanter:Refresh()
  end
  self:ResizeRefresh()
end

function QE_Window:hideChatButton(set)
  if (self.chatbutton ~= nil) then
    self.chatbutton:SetHidden(set or QuickEnchanter.savedVars.hide_chat_button)
  end
end

function QE_Window:AnchorDisplayButton()
  if (self.chatbutton ~= nil) then
    self.chatbutton:SetAnchor(LEFT, ZO_ChatWindowNotifications, RIGHT, QuickEnchanter.savedVars.display_button_offset)
  end
end

function QE_Window:UpdateDisplayButton()
  if (self.chatbutton ~= nil) then
    if (not IsGameCameraUIModeActive()) then
      if (self.top ~= nil) then self:HideMainWindow(true) end
      if (self.runes_display ~= nil) then self.runes_display:SetHidden(true) end
      self.chatbutton:SetHidden(true)
    else
      self.chatbutton:SetHidden(false or QuickEnchanter.savedVars.hide_chat_button)
    end
  end
end

function QE_Window:drawDisplayButton()
  local ctrl = wm:CreateControl("QE_Window_DisplayButton",ZO_ChatWindowNotifications,CT_BUTTON)
  ctrl:SetDimensions(35,35)
  ctrl:SetDrawLayer(4)
  ctrl:SetHidden(QuickEnchanter.savedVars.hide_chat_button and true or false)
  ctrl.tooltipText = QuickEnchanter.name -- right target?
  ctrl.text = QuickEnchanter.name
  ctrl:SetNormalTexture("esoui/art/icons/servicemappins/servicepin_enchanting.dds")
  ctrl:SetMouseOverTexture("esoui/art/icons/servicemappins/servicepin_enchanting.dds")
  
  ctrl:SetHandler("OnClicked",function() QE_Window:HideMainWindow(not QE_Window_Screen:IsHidden()) end)
  ctrl:SetHandler("OnMouseEnter",function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].show_button_text) end)
  ctrl:SetHandler("OnMouseExit",function(self) ZO_Tooltips_HideTextTooltip() end)
  self.chatbutton = ctrl
  self:AnchorDisplayButton()
end

function QE_Window:ClearGlyphs()
  local id = CRAFTING_TYPE_ENCHANTING
  if (QE_Window.controls[id] ~= nil) then
    QuickEnchanter:getPermutations()
    -- unhide entries
    for i = 0, #QuickEnchanter.permutations do
      if (QE_Window.controls[id][i] ~= nil) then
        QE_Window.controls[id][i]:SetHidden(false)
        if (QE_Window.controls[id][i].label_click ~= nil) then
          QE_Window.controls[id][i].label_click:SetHidden(false)
        end
      end
    end
    local i = #QuickEnchanter.permutations
    i = i + 1
    -- hide superfluous entries
    while (QE_Window.controls[id][i] ~= nil) do
      QE_Window.controls[id][i]:SetHidden(true)
      if (QE_Window.controls[id][i].label_click ~= nil) then
        QE_Window.controls[id][i].label_click:SetHidden(true)
      end
      i = i + 1
    end
  end
end

function QE_Window:HideGlyphs()
  local ID = CRAFTING_TYPE_ENCHANTING
  local count = 0
  for _,v in pairs(QE_Window.controls[ID]) do
    if (not v:IsHidden()) then
      v:SetHidden(true)
      count = count + 1
    end
  end
  if (self:dbg(1)) then self:debug("Did hide " .. count .. " glyph results.") end
end

function QE_Window:CreateTooltip(ItemTooltip, control, entry)
  if (QuickEnchanter.savedVars.bottom_tooltips) then
     InitializeTooltip(ItemTooltip, QE_Window.top, TOP, 0, 0)
  elseif (QuickEnchanter.savedVars.center_tooltips) then
     InitializeTooltip(ItemTooltip, QE_Window.top, BOTTOMRIGHT, 0, 0)
  else
     InitializeTooltip(ItemTooltip, control, BOTTOMLEFT, 20, 375)
  end
  ItemTooltip:SetLink(entry.link)
  if (QuickEnchanter.savedVars.add_rune_to_tooltip) then
    ZO_Tooltip_AddDivider(ItemTooltip)
    local count_string = string.format("%3d", entry.count)
    if (entry.count == 0) then count_string = RED_TEXT:Colorize(count_string) end
    ItemTooltip:AddLine(count_string .. " " .. QE_Language[QuickEnchanter.savedVars.language].glyphs .. " - " .. QuickEnchanter:GetRuneDisplay(entry.id_p).. " " .. QuickEnchanter:GetRuneDisplay(entry.id_e) .. " " ..  QuickEnchanter:GetRuneDisplay(entry.id_a), "ZoFontGame", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, LEFT, false)
  end
  
  self:AddMMTooltip(ItemTooltip, entry.link)
end

function QE_Window:AddMMTooltip(ItemTooltip, link)
  if (QuickEnchanter.savedVars.add_mastermerchant) then
    if (self:dbg(1)) then self:debug("Preference for showing MasterMerchant Tooltip on.") end
    if (MasterMerchant ~= nil and MasterMerchant.addStatsAndGraph ~= nil) then
      if (self:dbg(1)) then self:debug("Found MasterMerchant - showing tooltip") end
      MasterMerchant:addStatsAndGraph(ItemTooltip, link)
    end
  end
end

function QE_Window:RemoveMMTooltip(ItemTooltip)
  if (QuickEnchanter.savedVars.add_mastermerchant and MasterMerchant and MasterMerchant.remStatsItemTooltip) then
    if (self:dbg(1)) then self:debug("Removing MM tooltip") end
    MasterMerchant:remStatsItemTooltip()
  end
end

function QE_Window:RememberPosition(start)
  local s=QuickEnchanter.savedVars
  if (start == nil and s.remember_position and s.last_top_glyph ~= nil) then
    for i=1,#QuickEnchanter.permutations do
      local entry=QuickEnchanter.permutations[i]
      if (s.last_top_glyph[1] == entry.id_p and s.last_top_glyph[2] == entry.id_e and s.last_top_glyph[3] == entry.id_a) then
        if (self:dbg(1)) then self:debug("Remember position " .. i) end
        if (self.top.slider ~= nil) then
          self.top.slider.my_deactivate=true
          self.top.slider:SetValue(i)
          self.top.slider.my_deactivate=false
        end
        return i
      end
    end
  end
  
  if (start == nil) then start=1 end
  
  return start
end

function QE_Window:multiCheck(count)
  if (self.top ~= nil and self.top.creation_counter ~= nil) then
    if (count < self.top.creation_counter:GetValue()) then
      self.top.creation_counter:SetValue(count)
    end
  end
  
  return true
end

function QE_Window:GetCraftCounter()
  return (self.top and self.top.creation_counter and self.top.creation_counter:GetValue()) or 0 
end

function QE_Window:fixGlyphCounter()
  if (self.top and self.top.creation_counter and self.top.creation_counter:GetValue() == 0) then
    self.top.creation_counter:SetValue(1)
  end
end

function QE_Window:DecreaseGlyphCounter()
  if (self.top and self.top.creation_counter and self.top.creation_counter:GetValue() > 0) then
    self.top.creation_counter:SetValue(self.top.creation_counter:GetValue() - 1)
  end
end

function QE_Window:drawGlyphs(slider, start)
  
  if (self:dbg(1)) then self:debug("drawGlyphs with start " .. (start and start or "nil")) end
  -- Label it
  local xpos = 10
  local ypos = skip_lines * QuickEnchanter.savedVars.line_height
  -- match the label size with values below
  local label_length = QuickEnchanter.savedVars.window_width - QuickEnchanter.savedVars.line_height - 6 * QuickEnchanter.font_size - xpos
  
  local x_size, y_size = QE_Window_Screen:GetDimensions()
  if (self:dbg(1)) then self:debug("drawGlyph: Window is " .. x_size .. "," .. y_size .. " label length is " .. label_length) end
  
  self:HideGlyphs()
  
  QuickEnchanter:getPermutations()
  self:SetTitleText(#QuickEnchanter.permutations)
  if (slider ~= nil) then
    slider.my_deactivate=true
    slider:SetMinMax(1, #QuickEnchanter.permutations)
    slider.my_deactivate=nil
  end
  
  local s=QuickEnchanter.savedVars
  
  start=self:RememberPosition(start)

  local retval = 1
  
  local ID = CRAFTING_TYPE_ENCHANTING -- TODO: remove
  
  local max = start + QuickEnchanter.current_lines - 1
  if (max > #QuickEnchanter.permutations) then max = #QuickEnchanter.permutations end
  
  if (#QuickEnchanter.permutations == 0) then return end

  local top = self.top
  local anchor = top.glyph_type_selection_label
  
  local start_entry = QuickEnchanter.permutations[start]
  if (start_entry ~= nil) then
    s.last_top_glyph={start_entry.id_p, start_entry.id_e, start_entry.id_a}
  end
  
  for i = start, max do
    if (QuickEnchanter.permutations[i] == nil) then
      d("invalid index " .. i .. " with max " .. max)
      return
    end
    local name
    if (QuickEnchanter.permutations[i].name ~= nil) then
      name = QuickEnchanter:NormalizeName(QuickEnchanter.permutations[i].name)
    else
      name = QE_Language[QuickEnchanter.savedVars.language].unknown
    end
    
    local entry = QuickEnchanter.permutations[i]
    local icon = entry.icon
    local y = (i-start) * (QuickEnchanter.savedVars.line_height+QuickEnchanter.line_gap) + ypos
    if (self:dbg(3)) then self:debug("Y-Pos for glyph " .. i .. " is " .. y) end
    
    -- main control per row
    if (QE_Window.controls[ID][i] == nil) then
      local control_name = "QE_Window_ColumnHeader_"..ID..i
      QE_Window.controls[ID][i] = wm:CreateControl(control_name,self.top,CT_BUTTON)
      QE_Window.controls[ID][i]:SetHandler("OnMouseExit",function (self) ZO_Tooltips_HideTextTooltip() end)
      QE_Window.controls[ID][i]:SetHandler("OnClicked",function(...) QuickEnchanter:CraftEnchantment(i) end)
      QE_Window.controls[ID][i]:SetMouseOverTexture("esoui/art/icons/servicemappins/servicepin_enchanting.dds")
      QE_Window.controls[ID][i].QE_index = i
    end
    
    QE_Window.controls[ID][i]:SetDimensions(QuickEnchanter.savedVars.line_height,QuickEnchanter.savedVars.line_height)
    QE_Window.controls[ID][i]:SetHidden(false)
    QE_Window.controls[ID][i]:SetHandler("OnMouseUp", OnMouseUp_Glyph)
    
    -- add icon
    QE_Window.controls[ID][i]:SetNormalTexture(icon)
    QE_Window.controls[ID][i]:ClearAnchors()
    QE_Window.controls[ID][i]:SetAnchor(TOPLEFT, anchor, TOPLEFT, xpos, y)
    QE_Window.controls[ID][i].text = "|cFFFFFF"..name.."|r\n"..QE_Language[QuickEnchanter.savedVars.language].column
    QE_Window.controls[ID][i]:SetText(name)
    QE_Window.controls[ID][i]:SetHandler("OnMouseEnter", function (self) if (entry.link ~= nil and string.len(entry.link) > 0) then QE_Window:CreateTooltip(ItemTooltip, QE_Window.controls[ID][i], entry) end
    end)
    QE_Window.controls[ID][i]:SetHandler("OnMouseExit",function (self)
      QE_Window:RemoveMMTooltip(ItemTooltip)
      ClearTooltip(ItemTooltip)
    end)
    
    -- add count
    if (QE_Window.controls[ID][i].count == nil) then
      QE_Window.controls[ID][i].count = wm:CreateControl(QE_Window.controls[ID][i]:GetName() .. "count", QE_Window.controls[ID][i], CT_LABEL)
      QE_Window.controls[ID][i].count:SetFont("ZoFontGame")
      QE_Window.controls[ID][i].count:SetHidden(false)
    end
    local count = entry.count and entry.count or "?"
    if (count == 0) then count = RED_TEXT:Colorize(count) end
    QE_Window.controls[ID][i].count:SetText(count)
    -- align the glyph amounts
    local size_mult = 1
    if (entry.count ~= nil) then
      if (entry.count > 9) then size_mult = 2 end
      if (entry.count > 99) then size_mult = 3 end
    end
    QE_Window.controls[ID][i].count:SetDimensions(QuickEnchanter.savedVars.line_height/3*size_mult, QuickEnchanter.savedVars.line_height/3)
    QE_Window.controls[ID][i].count:ClearAnchors()
    QE_Window.controls[ID][i].count:SetAnchor(RIGHT, QE_Window.controls[ID][i], RIGHT)
    
    -- add check mark for marked glyphs
    if (QE_Window.controls[ID][i].check == nil) then
      QE_Window.controls[ID][i].check = wm:CreateControl(QE_Window.controls[ID][i]:GetName() .. "check", QE_Window.controls[ID][i], CT_BUTTON)
      QE_Window.controls[ID][i].check:SetNormalTexture(QE_Settings.checked_texture)
      QE_Window.controls[ID][i].check:SetHandler("OnMouseEnter",function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, QE_Language[QuickEnchanter.savedVars.language].favourite_tip) end)
      QE_Window.controls[ID][i].check:SetHandler("OnMouseExit",function(self) ZO_Tooltips_HideTextTooltip() end)
      QE_Window.controls[ID][i].check:SetMouseEnabled(true)
      QE_Window.controls[ID][i].check:SetHandler("OnClicked", function(...) 
        QuickEnchanter:ToggleMarkGlyph(i)
        if (QuickEnchanter.savedVars.sort_marked) then
          QuickEnchanter:Refresh(true)
        else
          QuickEnchanter:SetMarking(QE_Window.controls[ID][i].check, i)
        end
        end)
    end
    QE_Window.controls[ID][i].check:SetDimensions(QuickEnchanter.savedVars.line_height, QuickEnchanter.savedVars.line_height)
    QE_Window.controls[ID][i].check:ClearAnchors()   
    QE_Window.controls[ID][i].check:SetAnchor(RIGHT, QE_Window.controls[ID][i], LEFT, 1.8 * QuickEnchanter.savedVars.line_height)
    if (entry.is_marked) then
      QE_Window.controls[ID][i].check:SetAlpha(1)
    else
      QE_Window.controls[ID][i].check:SetAlpha(QuickEnchanter.savedVars.classic_look and 0.3 or 0.5)
    end

    -- name of the glyph
    if (QE_Window.controls[ID][i].label == nil) then
      QE_Window.controls[ID][i].label = wm:CreateControl(QE_Window.controls[ID][i]:GetName() .. "Label", QE_Window.controls[ID][i], CT_LABEL)
      QE_Window.controls[ID][i].label.QE_index = i
      QE_Window.controls[ID][i].label:SetFont("ZoFontGame")
      QE_Window.controls[ID][i].label:SetHidden(false)
    end
    QE_Window.controls[ID][i].label:SetVerticalAlignment(CENTER)
    QE_Window.controls[ID][i].label:SetDimensions(label_length, QuickEnchanter.savedVars.line_height)
    QE_Window.controls[ID][i].label:ClearAnchors()
    QE_Window.controls[ID][i].label:SetAnchor(RIGHT, QE_Window.controls[ID][i], RIGHT, label_length + 20)
    
    -- make clickable too
    if (QE_Window.controls[ID][i].label_click == nil) then
      local control_name = "QE_Window_ColumnHeader_"..ID..i.."click"
      QE_Window.controls[ID][i].label_click = wm:CreateControl(control_name, QE_Window_Screen, CT_BUTTON)
      QE_Window.controls[ID][i].label_click:SetHandler("OnMouseExit",function (self) ZO_Tooltips_HideTextTooltip() end)
      QE_Window.controls[ID][i].label_click:SetHandler("OnClicked",function(...) QuickEnchanter:CraftEnchantment(i) end)
      QE_Window.controls[ID][i].label_click.QE_index = i
      QE_Window.controls[ID][i].label_click:SetHandler("OnMouseUp", OnMouseUp_Glyph)
    end
    
    QE_Window.controls[ID][i].label_click:ClearAnchors()
    QE_Window.controls[ID][i].label_click:SetAnchor(LEFT, QE_Window.controls[ID][i].label, LEFT)
    QE_Window.controls[ID][i].label_click:SetHandler("OnMouseEnter",function (self) if (entry.link ~= nil and string.len(entry.link) > 0) then QE_Window:CreateTooltip(ItemTooltip, QE_Window.controls[ID][i], entry) end end)
    QE_Window.controls[ID][i].label_click:SetHandler("OnMouseExit",function (self) ClearTooltip(ItemTooltip) end)
    QE_Window.controls[ID][i].label_click:SetHidden(false)
    
    local colorcode
    if (QuickEnchanter.permutations[i] ~= nil and QuickEnchanter.permutations[i].quality ~= nil) then
      colorcode = GetItemQualityColor(entry.quality):ToHex()
    end
    local format_name = "%-" .. 60 .. "s"
    -- debugging
    -- name = name .. " " .. entry.enchantment_type .. " " .. entry.info.quality .. " " .. entry.info.minlevel .. " " .. entry.icon
    -- try some fixing
    if (entry.glyph_level == "") then QuickEnchanter:fixLevel(entry) end
    
    local level = string.format("%-7s", entry.glyph_level)
    local display_name = QuickEnchanter:getColorized(string.format(format_name, name), colorcode)
    QE_Window.controls[ID][i].label:SetText(level .. " " .. display_name)
    local text_width = QE_Window.controls[ID][i].label:GetTextDimensions()
    QE_Window.controls[ID][i].label_click:SetDimensions(text_width, QuickEnchanter.savedVars.line_height)
  end
  
  return retval
  
end

function QE_Window:RedrawGlyphs(start)
  if (self:dbg(1)) then self:debug("RedrawGlyphs") end
  if (QE_Window_Screen ~= nil) then
    --QuickEnchanter:resetPermutations()
    QE_Window:ClearGlyphs()
    QE_Window:CalculateWindowHeight()
    QE_Window_Screen:SetDimensions(QuickEnchanter.savedVars.window_width, QuickEnchanter.current_height) -- TODO
    if (QE_Window.top.slider) then
      QE_Window.top.slider:SetDimensions(30, QuickEnchanter.current_height)
    end
    QE_Window:drawGlyphs(self.top and self.top.slider or nil, start)
  end
end
