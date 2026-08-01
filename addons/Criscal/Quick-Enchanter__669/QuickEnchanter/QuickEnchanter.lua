local addon_name = "QuickEnchanter"

-- use for finding right enchanting rank: GetNonCombatBonus(NON_COMBAT_BONUS_ENCHANTING_LEVEL)

local wm = WINDOW_MANAGER
local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack
local SIGNED_INT_MAX = 2^32 / 2 - 1
local INT_MAX = 2^32
local POTENCY_LEVEL_STRING = 1 -- potency_level_information
local POTENCY_MIN_LEVEL = 2
local POTENCY_MAX_LEVEL = 3
local POTENCY_MIN_VLEVEL = 4
local POTENCY_MAX_VLEVEL = 5
local POTENCY_EFFECT = 6 -- -1 negate, 0 nothing special, +1 positive effect
local POTENCY_LEVEL_ICON = 7

local RUNE_ICON = 1 
local RUNE_NAME = 2
local RUNE_COUNT = 3
local RUNE_QUALITY = 4
local RUNE_LINK = 5
local RUNE_ID = 6
local RUNE_STACKS = 7

local RUNE_STACK_BAG = 1
local RUNE_STACK_SLOT = 2
local RUNE_STACK_AMOUNT = 3

local save_version=1

local RED_TEXT = ZO_ColorDef:New("FF0000")

-- Icons
local IS_ENCHANTABLE_ITEM_TEXTURE = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchant can be put on, but is just not available
local HAS_AVAILABLE_ENCHANTMENT = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchantment can be put on, but is just not available
local HAS_AVAILABLE_ENCHANTMENT_BANK = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchantment from the bank can be used 
local HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchantment from the guild bank can be used 
local IS_SUITABLE_ENCHANTMENT_TEXTURE = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- This enchantment can be used

local TRAIT_HAS_AVAILABLE_ENCHANTMENT = 1
local TRAIT_IS_ENCHANTABLE = 2
local TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK = 3
local TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK = 4

local controlsToWatch = {}
local ownedTraits = {}

-- store our information on equipment slots
-- The key to the table is the key to the slot id in the global _G variables e.g. _G["EQUIP_SLOT_HEAD"]
-- The value is a table. eng is for English - in case I want to add other translations to the script
-- Control is the graphical control ID
local slots = {
  ["EQUIP_SLOT_HEAD"] = { eng = "head" , control = "ZO_CharacterEquipmentSlotsHead"},
  ["EQUIP_SLOT_CHEST"] = { eng = "chest", control = "ZO_CharacterEquipmentSlotsChest" },
  ["EQUIP_SLOT_HEAD"] = { eng = "head" , control = "ZO_CharacterEquipmentSlotsHead"},
  ["EQUIP_SLOT_CHEST"] = { eng = "chest", control = "ZO_CharacterEquipmentSlotsChest" },
  ["EQUIP_SLOT_SHOULDERS"] = { eng = "shoulders", control = "ZO_CharacterEquipmentSlotsShoulder" },
  ["EQUIP_SLOT_FEET"] = { eng = "feet", control = "ZO_CharacterEquipmentSlotsFoot" },
  ["EQUIP_SLOT_HAND"] = { eng = "hand", control = "ZO_CharacterEquipmentSlotsGlove" },
  ["EQUIP_SLOT_LEGS"] = { eng = "legs", control = "ZO_CharacterEquipmentSlotsLeg" },
  ["EQUIP_SLOT_WAIST"] = { eng = "waist", control = "ZO_CharacterEquipmentSlotsBelt" },
  ["EQUIP_SLOT_RING1"] = { eng = "left ring", control = "ZO_CharacterEquipmentSlotsRing1" },
  ["EQUIP_SLOT_RING2"] = { eng = "right ring", control = "ZO_CharacterEquipmentSlotsRing2" },
  ["EQUIP_SLOT_NECK"] = { eng = "neck", control = "ZO_CharacterEquipmentSlotsNeck" },
  ["EQUIP_SLOT_COSTUME"] = { eng = "costume", control = "ZO_CharacterEquipmentSlotsCostume" },
  ["EQUIP_SLOT_MAIN_HAND"] = { eng = "main-hand", control = "ZO_CharacterEquipmentSlotsMainHand" },
  ["EQUIP_SLOT_OFF_HAND"] = { eng = "off-hand", control = "ZO_CharacterEquipmentSlotsOffHand" },
  ["EQUIP_SLOT_BACKUP_MAIN"] = { eng = "backup main-hand", control = "ZO_CharacterEquipmentSlotsBackupMain" },
  ["EQUIP_SLOT_BACKUP_OFF"] = { eng = "backup off-hand", control = "ZO_CharacterEquipmentSlotsBackupOff" }
}

QuickEnchanter = {
	command = "/cqe",
	name = addon_name,
	svName = "QuickEnchanter_SavedVariables",
	svDefaults = {},
	do_you_really_wanna = false,
	crafting = {},
	current_crafting = nil,
	debug_level = 0,
	-- default values
	tooltip_icon_size = 25,
	max_lines = 20,
	line_gap = 2,
	y_offset_glyphs = 20,
	width = 450,
	childname = "QE_Indicator",
	font_size = 6, -- guessing here - no function known for determining the font size in a generic way
	-- Unfortunately, there doesn't seem to be any generic information on the level of the resulting glyph
	potency_level_information = {
    ["Jora"]   = { "1-10 ",     1,  10, nil, nil,  1, [[QuickEnchanter/media/1to10.dds]] },
    ["Jode"]   = { "1-10 ",     1,  10, nil, nil, -1, [[QuickEnchanter/media/1to10.dds]] },
    ["Porade"] = { "5-15 ",     5,  15, nil, nil,  1, [[QuickEnchanter/media/5to15.dds]] },
    ["Notade"] = { "5-15 ",     5,  15, nil, nil, -1, [[QuickEnchanter/media/5to15.dds]] },
    ["Jera"]   = { "10-20",     10,  20, nil, nil,  1, [[QuickEnchanter/media/10to20.dds]] },
    ["Ode"]    = { "10-20",     10,  20, nil, nil, -1, [[QuickEnchanter/media/10to20.dds]] },
    ["Jejora"] = { "15-25",     15,  25, nil, nil,  1, [[QuickEnchanter/media/15to25.dds]] },
    ["Tade"]   = { "15-25",     15,  25, nil, nil, -1, [[QuickEnchanter/media/15to25.dds]] },
    ["Odra"]   = { "20-30",     20,  30, nil, nil,  1, [[QuickEnchanter/media/20to30.dds]] },
    ["Jayde"]  = { "20-30",     20,  30, nil, nil, -1, [[QuickEnchanter/media/20to30.dds]] },
    ["Pojora"] = { "25-35",     25,  35, nil, nil,  1, [[QuickEnchanter/media/25to35.dds]] },
    ["Edode"]  = { "25-35",     25,  35, nil, nil, -1, [[QuickEnchanter/media/25to35.dds]] },
    ["Edora"]  = { "30-40",     30,  40, nil, nil,  1, [[QuickEnchanter/media/30to40.dds]] }, -- to be checked
    ["Pojode"] = { "30-40",     30,  40, nil, nil, -1, [[QuickEnchanter/media/30to40.dds]] },
    ["Jaera"]  = { "35-45",     35,  45, nil, nil,  1, [[QuickEnchanter/media/35to45.dds]] },
    ["Rekude"] = { "35-45",     35,  45, nil, nil,  1, [[QuickEnchanter/media/35to45.dds]] },
    ["Pora"]   = { "40-50",     40,  50, nil, nil,  1, [[QuickEnchanter/media/40to50.dds]] },
    ["Hade"]   = { "40-50",     40,  50, nil, nil, -1, [[QuickEnchanter/media/40to50.dds]] },
    ["Denara"] = { "VR1-3",     nil, nil,  1,   3,  1, [[QuickEnchanter/media/v1to3.dds]] },
    ["Idode"]  = { "VR1-3",     nil, nil,  1,   3, -1, [[QuickEnchanter/media/v1to3.dds]] },
    ["Rera"]   = { "VR3-5",     nil, nil,  3,   5,  1, [[QuickEnchanter/media/v3to5.dds]] },
    ["Pode"]   = { "VR3-5",     nil, nil,  3,   5, -1, [[QuickEnchanter/media/v3to5.dds]] },
    ["Derado"] = { "VR5-7",     nil, nil,  5,   7,  1, [[QuickEnchanter/media/v5to7.dds]] },
    ["Kedeko"] = { "VR5-7",     nil, nil,  5,   7, -1, [[QuickEnchanter/media/v5to7.dds]] },
    ["Rekura"] = { "VR7-9",     nil, nil,  7,   9,  1, [[QuickEnchanter/media/v7to9.dds]] },
    ["Rede"]   = { "VR7-9",     nil, nil,  7,   9, -1, [[QuickEnchanter/media/v7to9.dds]] },
    ["Kura"]   = { "VR10-VR14", nil, nil, 10, 14,  1, [[QuickEnchanter/media/v10to14.dds]] },
    ["Kude"]   = { "VR10-VR14", nil, nil, 10, 14, -1, [[QuickEnchanter/media/v10to14.dds]] },
    ["Rejera"] = { "VR15",      nil, nil, 15, 15,   1, [[QuickEnchanter/media/v15.dds]] },
    ["Jehade"] = { "VR15",      nil, nil, 15, 15,  -1, [[QuickEnchanter/media/v15.dds]] },
    ["Repora"] = { "VR16",      nil, nil, 16, 16,   1, [[QuickEnchanter/media/v16.dds]] },
    ["Itade"]  = { "VR16",      nil, nil, 16, 16,  -1, [[QuickEnchanter/media/v16.dds]] },    
  },
}

local QuickEnchanter = QuickEnchanter

--function QuickEnchanter:CleanName(name)
--  return string.gsub(name, "%^.", "") -- remove trailing ^ pattern
--end

function QuickEnchanter:dbg(level)
  return self.savedVars ~= nil and self.savedVars.debug_level ~= nil and self.savedVars.debug_level >= level and not (QuickEnchanter.selected_bug_level_only ~= nil and self.debug_level ~= level)
end

function QuickEnchanter:debug(text)
  d(text)
end

function QuickEnchanter:NormalizeName(name)
  return zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
end

function QuickEnchanter:GetResultList(bagId, slotIndex)

	local info = QuickEnchanter:MyGetItemInfo(bagId, slotIndex)
	
	if (info ~= nil) then
		local type = GetItemType(bagId, slotIndex)
		if (self:dbg(2)) then self:debug("item-type of item is " .. type) end
		if (self:isRune(type)) then
      return info and self.rune_to_glyph_info and self.rune_to_glyph_info[info.id]
		end
	end

	return nil
end

-- there should be some shorter list to check for with id
function QuickEnchanter:ItemInBag(bag, id)
	local slots = GetBagSize(bag)
	
	for slot = 0, slots do
		if (self:GetItemId(bag, slot) == id) then return true end
	end
	
	return false
end

function QuickEnchanter:ItemAvailable(id)
	if (self:ItemInBag(BAG_BACKPACK, id)) then return true end
	if (self:ItemInBag(BAG_BANK, id)) then return true end
	if (HasCraftBagAccess() and self:ItemInBag(BAG_VIRTUAL, id)) then return true end
	
	return false
end

function QuickEnchanter:getColorized(string, color)
    if (color == nil or color == "") then if (self:dbg(1)) then self:debug("Return plain color string:'" .. string .."'") end return string end
    
    if (self:dbg(2)) then self:debug("Get colorized string:'" .. color ..string .. "'") end
    return "|c" .. color .. string .. "|r"
end

function QuickEnchanter:isRuneOfType(type, bag, slot)
  if (bag ~= nil and slot ~= nil and bag >= 0 and slot >= 0) then
    local info = self:MyGetItemInfo(bag, slot)
    if (info ~= nil and info.itemType ~= nil) then
      return info.itemType == type
    end
  end
  
  return false
end

function QuickEnchanter:isRune(type)
	return type == ITEMTYPE_ENCHANTING_RUNE_POTENCY or type == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or type == ITEMTYPE_ENCHANTING_RUNE_ASPECT
end

function QuickEnchanter:isGlyph(type)
  return type == ITEMTYPE_GLYPH_ARMOR or type == ITEMTYPE_GLYPH_JEWELRY or type == ITEMTYPE_GLYPH_WEAPON
end

function QuickEnchanter:getColor(type, subtype)
	-- colorize results for runes
	if (self:dbg(2)) then self:debug("Use type:" .. (type and type or "-") .. " and extra " .. (subtype and subtype or "-")) end
	if (self:isRune(type)) then
		if (subtype == ENCHANTING_RUNE_ASPECT) then
			if (self:dbg(2)) then self:debug("return ASPECT") end
			return "FFAF50"
		elseif (subtype == ENCHANTING_RUNE_ESSENCE) then
			if (self:dbg(2)) then self:debug("return ESSENCE") end
			return "F5F5DC"
		elseif (subtype == ENCHANTING_RUNE_POTENCY) then
			if (self:dbg(2)) then self:debug("return POTENCY") end
			return "0000FF"
		end
	end
	
	return nil
end

function QuickEnchanter:getGlyphInfo()
  return self.savedVars.glyph_info
end

function QuickEnchanter:addRuneToolTip(runes, rune)
  local info = runes[rune]
  local text = ""
  if (info ~= nil) then
    if (info[RUNE_ICON] ~= nil) then
      text = text .. zo_iconFormat(info[RUNE_ICON], self.savedVars.tooltip_icon_size, self.savedVars.tooltip_icon_size)
    end
    local available = self:ItemAvailable(rune)
    local color = (info[RUNE_QUALITY] and available) and GetItemQualityColor(info[RUNE_QUALITY]) or RED_TEXT
    text = ", " .. text .. color:Colorize(self:NormalizeName(info[RUNE_NAME]))
  end
  
  return text
end

-- add text for rune tooltip per rune - except for the given rune
function QuickEnchanter:addRuneToolTipInfo(glyph, rune)
  local text = ""
  local s = self:getLists()
  if (self:dbg(2)) then self:debug("glyph " .. glyph.name .. " rune " .. rune .. " " .. glyph.id_a .. " " .. glyph.id_p .. " " .. glyph.id_e) end
  --if (rune ~= glyph.id_a) then text = text .. self:addRuneToolTip(s.aspect_runes, glyph.id_a) end -- don't need to show aspect runes
  if (rune ~= glyph.id_p) then text = text .. self:addRuneToolTip(s.potency_runes, glyph.id_p) end
  if (rune ~= glyph.id_e) then text = text .. self:addRuneToolTip(s.essence_runes, glyph.id_e) end
  
  return text
end

function QuickEnchanter:OnUpdateTooltip(item)
  if not self.savedVars.activated or not item or not item.dataEntry or not item.dataEntry.data or self.selectedItem == item then
    return
  end

  self.selectedItem = item -- prevent redo
  
  local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
  local font = "ZoFontGame"
  
  local bagId = item.dataEntry.data.bagId
  local slotIndex = item.dataEntry.data.slotIndex
  
  local id = self:GetItemId(bagId, slotIndex)
  local rune = id and self:GetRuneInfo(id) or nil
  local potency_level = rune and QuickEnchanter.potency_level_information[rune[RUNE_NAME]] or nil
      
  if (self.savedVars.show_potency_level_tooltip) then
    -- we got a potency rune and put the level in its information
    if (potency_level ~= nil and potency_level[POTENCY_LEVEL_STRING] ~= nil) then
      ZO_Tooltip_AddDivider(ItemTooltip)
      ItemTooltip:AddLine(potency_level[POTENCY_LEVEL_STRING], font, r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end
  end
  
  if (not QuickEnchanter.savedVars.activate_tooltips) then return end
  
  local stackCount = item.dataEntry.data.stackCount or item.dataEntry.data.stack
  if not stackCount then 
    return
  end

  local result_info = self:GetResultList(bagId, slotIndex)
  local s = self:getGlyphInfo()
  
  if ((s == nil or result_info == nil) and not self:IsMarkedRune(id) and not self:IsQuestRune(id)) then
    return
  end
   
  if (self:dbg(1)) then self:debug("Got result_info for rune " .. id .. (result_info ~= nil and "YES" or "NO")) end
  ZO_Tooltip_AddDivider(ItemTooltip)
  ItemTooltip:AddLine("", "ZoFontHeader2")

  if (result_info ~= nil and s ~= nil and not (potency_level and self.savedVars.show_potency_level_tooltip)) then
    -- we can't sort tables with strings as keys directly - hooray ...
    local keys = {}
    for k,_ in pairs(result_info) do
      local v = s[k]
      if (v ~= nil and v.potency_info ~= nil) then
        keys[#keys+1] = k
      else
        --d(k .. " missing minlevel")
      end
    end
    
    table.sort(keys, QuickEnchanter:getSortFunction(s))

    local max_name = 0
    local max_input_name = 0

    -- get formatting information
    for k,_ in pairs(result_info) do
      local single = s[k]
      if (single ~= nil) then
        local name = single.name
        if (#name > max_name) then max_name = #name end
      end
    end

    --local format_name = "%-" .. max_name .. "s"
    local format_name = "%s"

    local quality_found
    
    for k, value in pairs(keys) do
      local v = s[value]
      -- we only need simple quality for tooltips
      if (v ~= nil and v.quality ~= nil and (not quality_found or v.quality == quality_found)) then
        quality_found = v.quality
        local colorcode = ""
        if (v.quality ~= nil) then
          colorcode = GetItemQualityColor(v.quality):ToHex()
          if (self:dbg(1)) then self:debug("Using quality color code:'" .. colorcode .. "'") end
        end

        local name = v.name
        local display_name = self:getColorized(string.format(format_name, name), colorcode)
        if (self:dbg(1)) then self:debug("put out '" .. name .. "' - length " .. #name .. " not normalized:'" .. v.name .. " length:" .. #v.name .. "' - format string:'" .. format_name .. "' display length:" .. #display_name) end
        local text = (v.icon and zo_iconFormat(v.icon, self.savedVars.tooltip_icon_size, self.savedVars.tooltip_icon_size) or "") .. display_name
        text = text .. " ("
        if (v.potency_info ~= nil and v.potency_info[POTENCY_LEVEL_STRING] ~= nil) then
          text = text .. v.potency_info[POTENCY_LEVEL_STRING]
        else
          text = text .. "--"
        end

        text = text .. self:addRuneToolTipInfo(v, id)
        text = text .. ")"
        ItemTooltip:AddLine(text, font, r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
      end
    end
  end
  
  if (self:IsMarkedRune(id)) then
    ItemTooltip:AddLine(QE_Language[QuickEnchanter.savedVars.language].marked_rune_text, font, r, g, b, LEFT, MODYIFY_TEXT_TYPE_NONE, LEFT, false)
  end
  if (self:IsQuestRune(id)) then
    ItemTooltip:AddLine(QE_Language[QuickEnchanter.savedVars.language].quest_rune_text, font, r, g, b, LEFT, MODYIFY_TEXT_TYPE_NONE, LEFT, false)
  end
end

function QuickEnchanter:StartCraftingStation(event, crafting_type)
  if (crafting_type == CRAFTING_TYPE_ENCHANTING) then
    if (not self.savedVars.disable_auto_open) then
      if (self:dbg(1)) then self:debug("Draw Window") end
      QE_Window:StartCraftingStation()
      QE_Window:HideMainWindow(false) -- TODO
    end
    local LES = LibStub("LibEnchantingStation")
    LES:SelectTab(addon_name)
    self.is_at_crafting_station = crafting_type
    self.last_enchantment = nil
  end
end

function QuickEnchanter:ResetCraftingStation()
    if (self:dbg(1)) then self:debug("Hide window") end
    QE_Window:HideMainWindow(true)
    QE_Window:EndCraftingStation()
    self.is_at_crafting_station = nil
    self.last_enchantment = nil
end

function QuickEnchanter:EndCraftingStation(event, crafting_type)
  --if (crafting_type == CRAFTING_TYPE_ENCHANTING) then -- there is no type given anymore by UI
  if (self.is_at_crafting_station) then
    self:ResetCraftingStation()
  end
end

function QuickEnchanter:ProvideTranslations()
  local potency_level_information = self.potency_level_information
  potency_level_information["Kudé"] = potency_level_information["Kude"]
  potency_level_information["Kédéko"] = potency_level_information["Kedeko"]
  potency_level_information["Réra"] = potency_level_information["Rera"]
  potency_level_information["Dérado"] = potency_level_information["Derado"]
  potency_level_information["Rekudé"] = potency_level_information["Rekude"]
  potency_level_information["Dénara"] = potency_level_information["Denara"]
end

function QuickEnchanter:assureSettings(tabula_rasa)
  if (self:dbg(1)) then self:debug("assureSettings") end
  --local tabula_rasa = 1
  if (tabula_rasa ~= nil) then
    d("Tabula rasa")
    self.savedVars = ZO_SavedVars:NewAccountWide(self.svName, save_version+1, nil, self.svDefaults, nil)
    self.savedVars = ZO_SavedVars:NewAccountWide(self.svName, save_version, nil, self.svDefaults, nil)
  end
  
  local s = self.savedVars
    
  if (s.debug_level == nil) then s.debug_level = 0 end
  if (s.tooltip_icon_size == nil) then s.tooltip_icon_size = self.tooltip_icon_size end
  if (s.line_height == nil) then s.line_height = QE_Settings.line_height_default end
  if (s.max_lines == nil) then s.max_lines = self.max_lines end
  if (s.language == nil) then QE_Settings:SetLanguage(nil) end
  if (s.window_width == nil) then s.window_width = QE_Settings.width_default end
  if (s.disable_inventory_update == nil) then s.disable_inventory_update = QE_Settings.disable_inventory_update_default end
  if (s.quality_selection == nil) then s.quality_selection = {} end
  for i=1,#QE_Settings.qualities do
    if (s.quality_selection[i] == nil) then s.quality_selection[i] = 1 end
  end
  if (s.enabled_types == nil) then s.enabled_types = {} end
  for k,v in pairs(QE_Settings.glyph_type_info) do
    if (s.enabled_types[k] == nil) then s.enabled_types[k] = 1 end
  end
  s.retry_delay = QE_Settings.retry_delay
  if (s.copy_amount == nil) then s.copy_amount = 0 end
  if (s.radio_buttons == nil) then s.radio_buttons = true end
  if (s.start_easy == nil) then s.start_easy = true end
  if (s.safety_check == nil) then s.safety_check = true end
  if (s.max_height == nil) then s.max_height = QE_Settings.max_height_default end
  if (s.add_rune_to_tooltip == nil) then s.add_rune_to_tooltip = true end
  if (s.center_tooltips == nil) then s.center_tooltips = true end
  if (s.display_button_offset == nil) then s.display_button_offset = QE_Settings.display_button_offset_default end
  if (s.display_result_runes == nil) then s.display_result_runes = QE_Settings.display_result_runes_default end
  if (s.glyph_info == nil) then s.glyph_info = {} end
  if (s.potency_runes == nil) then s.potency_runes = {} end
  if (s.essence_runes == nil) then s.essence_runes = {} end
  if (s.aspect_runes == nil) then s.aspect_runes = {} end
  if (s.quest_update == nil) then s.quest_update = true end
  if (s.classic_look == nil) then s.classic_look = true end
  if (s.enabled_effect_types == nil) then
    s.enabled_effect_types = {}
    s.enabled_effect_types[tonumber(1)] = 1
    s.enabled_effect_types[tonumber(-1)] = 1
  end
  if (s.activated == nil) then s.activated = true end
  if (s.show_potency_level_tooltip == nil) then s.show_potency_level_tooltip = true end
  if (s.show_potency_level == nil) then s.show_potency_level = QE_Settings.show_potency_level_default end
  if (s.indicator_x_position == nil) then s.indicator_x_position = QE_Settings.indicator_x_position_default end
  if (s.suppress_rune_voicing == nil) then suppress_rune_voicing = QE_Settings.suppress_rune_voicing_default end
  if (s.add_mastermerchant == nil) then add_mastermerchant = QE_Settings.add_mastermerchant end
end

-- used to change values between different code versions
function QuickEnchanter:TransferSettings()
  local s = self.savedVars
  -- change size
  if (not s.version_0_28) then
    d("Set settings for version 0.28.0")
    s.line_height = 30
    s.max_height = 800
    s.version_0_28 = true
  end
end

function QuickEnchanter:InventoryUpdateCheck()
  if (not self.savedVars.disable_inventory_update) then
    QuickEnchanter.recalculated = nil
    local next = GetTimeStamp()
    if (next ~= self.last_update) then
      self:RuneUpdateCheck()
      self:Refresh()
    end
    self.last_update = next
  end
end

function QuickEnchanter:fixNames()
  if (self.savedVars ~= nil and self.savedVars.glyph_info ~= nil) then
    for k,v in pairs(self.savedVars.glyph_info) do
      v.name = self:NormalizeName(v.name)
    end
  end
end

function QuickEnchanter:QuestUpdate()
  if (self:dbg(1)) then self:debug("QuestUpdate") end
  if (QuickEnchanter.savedVars.quest_update) then
    local found = self:getWritGlyph()
    if (not self.quest_check and found) then
      self:CheckItems()
      self.quest_check = true
    elseif (self.quest_check == true and found == nil) then
      self:CheckItems()
      self.quest_check = false
    end
  end
end

function QuickEnchanter:toggle()
  if (QuickEnchanter.savedVars.activated) then
    QuickEnchanter.savedVars.activated = false
    self:register(false)
  else
    QuickEnchanter.savedVars.activated = true
    self:register(true, true)
  end
end

function QuickEnchanter:register(apply, force_recalc)
 
  self.calculated = nil -- always trigger a re-calculation at next opportunity
  if (self:dbg(1)) then self:debug("register " .. (apply and "ON" or "OFF")) end
  local func = apply and function(...) EVENT_MANAGER:RegisterForEvent(...) end or function(...) EVENT_MANAGER:UnregisterForEvent(...) end
  
  func(self.name, EVENT_CRAFT_STARTED, function (event, which)
    if (which == CRAFTING_TYPE_ENCHANTING) then
      self:initCrafting(event, which)
    end
  end)
  func(self.name, EVENT_CRAFT_COMPLETED, function (event, which)
    if (which == CRAFTING_TYPE_ENCHANTING) then
      self:finishCrafting(event, which)
      self:resetCrafting(which)
      self.calculated = nil -- force recalculation
      if (self.last_enchantment ~= nil) then
        self:updateStackInfos(self.last_enchantment)
        if (QE_Window:GetCraftCounter() > 0) then
          self:CraftEnchantmentImpl(self.last_enchantment)
        else
          QE_Window:fixGlyphCounter()
          self.last_enchantment = nil
          local LES = LibStub("LibEnchantingStation")
          LES:SelectTab(addon_name) -- get back
        end
      elseif (self.has_extracted ~= nil and self.has_extracted > 0) then
        self.has_extracted = self.has_extracted - 1
        if (self.has_extracted == 0) then
          local LES = LibStub("LibEnchantingStation")
          LES:SelectTab(addon_name) -- get back
        end
      end
    end
  end)
  func(self.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, function(...) QE_Window:UpdateDisplayButton(...) end)
  func(self.name, EVENT_CRAFTING_STATION_INTERACT, function (...) self:StartCraftingStation(...) end )
  func(self.name, EVENT_END_CRAFTING_STATION_INTERACT, function (...) self:EndCraftingStation(...) end )
  -- throttle single updates by time-stamp
  func(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (...) self:InventoryUpdateCheck(...) end ) 
  func(self.name, EVENT_INVENTORY_FULL_UPDATE, function (...) self:InventoryUpdateCheck() end )
  --func(self.name, EVENT_MOUNTS_FULL_UPDATE, function (...) self:InventoryUpdateCheck(true) end ) -- event after inventory change for mount change

  -- used for displaying marked runes
  func(self.name, EVENT_ACTION_LAYER_PUSHED, function (...) QuickEnchanter:ALPush(...) end)
  func(self.name, EVENT_OPEN_STORE, function (...) QuickEnchanter:StoreOrBankOpen(...) end)
  func(self.name, EVENT_OPEN_BANK, function (...) QuickEnchanter:StoreOrBankOpen(...) end)
  func(self.name, EVENT_CLOSE_STORE, function (...) QuickEnchanter:StoreOrBankClosed(...) end)
  func(self.name, EVENT_CLOSE_BANK, function (...) QuickEnchanter:StoreOrBankClosed(...) end)

  -- keep writ information updated
  func(self.name, EVENT_QUEST_ADDED, function(...) QuickEnchanter:QuestUpdate() end)
  func(self.name, EVENT_QUEST_REMOVED, function(...) QuickEnchanter:QuestUpdate() end)
  --func(self.name, EVENT_QUEST_ADVANCED, function(...) QuickEnchanter:QuestUpdate() end)
  --func(self.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, function(...) QuickEnchanter:QuestUpdate() end)

  -- TODO: find way to properly deregister the hooks
  if (apply) then
    ZO_PreHookHandler(ItemTooltip, "OnUpdate", function() self:OnUpdateTooltip(moc()) end)
    ZO_PreHookHandler(ItemTooltip, "OnHide", function() self:OnHideTooltip() end)
  end
  
  if (apply) then
    self:fixNames() -- get the pesky ^ out
    self:getWritGlyph() -- set quest runes
    if (self.savedVars.activate_tooltips or force_recalc) then
      self:createPermutations(self.savedVars.activate_tooltips) -- initialise values and if tooltips are on, check all types
    end
  end
  
  if (not apply) then
    if (QE_Window.top) then
      QE_Window.top:SetHidden(true)
    end
  end
  
  self:CheckItems()
end

function QuickEnchanter:InitializeItems(eventCode, addOnName)
  if (addOnName ~= addon_name) then return end
  if (self:dbg(1)) then self:debug("InitializeItems") end
  SLASH_COMMANDS[self.command] = function (...) self:cmdQuickEnchanter(...) end
           
  self.savedVars = ZO_SavedVars:NewAccountWide(self.svName, save_version, nil, self.svDefaults, nil)
  QE_Settings:initializeLookup()
  self:assureSettings()
  self:TransferSettings()
  self:ProvideTranslations()
  
  if (self.savedVars.activated) then
    self:register(true)
  end

  QE_Window:drawCraftStore()
  
  if (QuickEnchanter.savedVars.start_easy) then
    QE_Window:StartEasy()
  end
  
  QE_Settings:initializeOptions()
  
  QuickEnchanter:getWritGlyph()
  
  ZO_CreateStringId("SI_BINDING_NAME_SHOW_QUICKENCHANTER", QE_Language[self.savedVars.language].show_button_text)
  ZO_CreateStringId("SI_BINDING_NAME_QE_MARK_GLYPH", QE_Language[self.savedVars.language].show_mark_button_text)
  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_QUICKENCHANTER", QE_Language[self.savedVars.language].show_toggle_button_text)
  
  self:ResetCraftingStation()
  EVENT_MANAGER:UnregisterForEvent(QuickEnchanter.name, EVENT_ADD_ON_LOADED)
end

function QuickEnchanter:OnHideTooltip()
  self.selectedItem = nil
end
  
function QuickEnchanter:printCrafting(which)
	if (self.savedVars[which] ~= nil and self.savedVars[which].results ~= nil) then
        for k,v in pairs(self.savedVars[which].results) do
          if (self:dbg(1)) then self:debug("Input item: " .. v.name .. " (" .. k .. ") " .. v.link) end
          if (v.results ~= nil) then
            for rk, rv in pairs(v.results) do
              if (self:dbg(1)) then self:debug("Target item:" .. rk .. " " .. rv.num .. " times") end
            end
          end
		end
	end
end

function QuickEnchanter:erase_single(which)
	if (self.savedVars[which] ~= nil) then
		if (self.savedVars[which] ~= nil and self.savedVars[which].results ~= nil) then
			d("Resetting result values for " .. which)
			self.savedVars[which].results = nil
		end
	end
end

function QuickEnchanter:erase(which)
	if (which ~= nil) then
		self:erase_single(which)
	else 
		for i=1,10 do
			self:erase_single(i) -- TODO: better choice of range
		end
	end
end

function QuickEnchanter:checker()
	  d("If you really want to erase that data, enter the command again.")
	  self.do_you_really_wanna = true
end

function QuickEnchanter:isEnchanterWrit(questName)
  if (self:dbg(1)) then self:debug("Compare '" .. QE_Language[QuickEnchanter.savedVars.language].quest_name .. "' with '" .. questName .. "'") end
  return QE_Language[QuickEnchanter.savedVars.language].quest_name == questName
end

 -- thank you for adding a non-breaking space in the french client ... NOT - even trimming the usual way messes things up
function QuickEnchanter:fixStupidFrenchClient(lower)
  while (string.len(lower) > 2 and (string.byte(lower, -1) == 160 or string.byte(lower, -1) == 32 or string.byte(lower, -1) == 194)) do
    lower=string.sub(lower, 1, #lower - 1)
  end
  
  return lower
end

-- very slow function
function QuickEnchanter:findGlyph(name)
  local lower=name:lower()
  if (name == nil or string.find(lower, "glyph") == nil) then
    return nil
  end
 
  lower=self:fixStupidFrenchClient(lower)
  if (self:dbg(1)) then self:debug("Search glyph with name '" .. lower .. "'(" .. string.len(lower) .. ")'" .. string.byte(lower, -1) .. "''" .. string.char(string.byte(lower, -1)).. "'") end
  local glyph_info=QuickEnchanter.savedVars.glyph_info
  if (glyph_info ~= nil) then
    for k,v in pairs(glyph_info) do
      -- all items seem to have normal quality for normal
      if (v.quality == ITEM_QUALITY_NORMAL) then
        --if (self:dbg(2)) then self:debug("compare '" .. lower .. "' with '" .. v.name:lower() .. "'(" .. string.len(v.name:lower()) ..")") end
        if (lower == v.name:lower()) then
          return v
        end
      end
    end
  end
  
  return nil
end

-- get condition from quest
function QuickEnchanter:getGlyphName(condition)
  local text=string.gsub(condition, QE_Language[QuickEnchanter.savedVars.language].quest_glyph_prefix .. "%s*(.*)%s*" .. QE_Language[QuickEnchanter.savedVars.language].quest_glyph_postfix .. ".*", "%1")
  if (self:dbg(1)) then self:debug("Extracted glyph name:'" .. text .. "' with condition '" .. condition .. "'") end
  return text
end

function QuickEnchanter:cutChar(text, char)
  local pos = string.find(text, char)
  if (pos ~= nil) then
    local tmp=string.sub(text, 1, pos-1)
    return tmp
  end
  
  return text
end

function QuickEnchanter:getRuneName(condition, which)
  local lang=QE_Language[QuickEnchanter.savedVars.language]
  local prefix=which and (which == 2 and lang.quest_rune_prefix2 or lang.quest_rune_prefix3) or lang.quest_rune_prefix
  local text=string.gsub(condition, prefix .."%s*(.-)%s*", "%1") -- LUA pattern matching sucks
  -- -> have to cut the stupid way
  text = self:cutChar(text, " ")
  text = self:cutChar(text, "-")
  text = self:cutChar(text, ":")

  text=self:fixStupidFrenchClient(text)
  if (self:dbg(1)) then self:debug("Extracted rune name:'".. text.."'") end
  return text
end

function QuickEnchanter:getWritGlyph()
  local retvalue
  
  self.quest_runes = {}
  
  QE_Window:MarkQuestGlyphNotAvailable()
  
  -- QUEST_TYPE_CRAFTING is getting bugged elsewhere - fix to 4
  local type_crafting = 4
  for qIndex=1, GetNumJournalQuests() do
    local questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType = GetJournalQuestInfo(qIndex)
    if (self:dbg(1)) then self:debug("Quest " .. questName .. " of type " .. questType .. " required type is " .. type_crafting .. " completed:" .. (completed and "YES" or "NO")) end
    if (questType == type_crafting and self:isEnchanterWrit(questName) and not completed) then
      if (self:dbg(1)) then self:debug(questName .. " '" .. backgroundText .. "' '" .. activeStepText .. "' type " .. activeStepType .. " '" .. activeStepTrackerOverrideText .. " completed:" .. (completed and "YES" or "NO") .. " tracked " .. (tracked and "YES" or "NO") .. " pushed " .. (pushed and "YES" or "NO")) end
      local stepIndex=1
      local numConditions = GetJournalQuestNumConditions(qIndex, stepIndex)
      if (numConditions > 0) then
        for conditionIndex=1,numConditions do
          local conditionText, current, max, isFailCondition, isComplete, isCreditShared = GetJournalQuestConditionInfo(qIndex, stepIndex, conditionIndex)
          if (conditionText ~= nil and conditionText ~= "" and not isComplete) then
            local glyph_name = self:getGlyphName(conditionText)
            if (self:dbg(1)) then self:debug(questName .. " conditionText:" .. conditionText .. " current " .. current .. " max " .. max .. " name:'" .. glyph_name .. "'") end
            local glyph = self:findGlyph(glyph_name)
            if (glyph ~= nil) then
              QE_Window:MarkQuestGlyphAvailableRunesIncomplete()
              retvalue = glyph
              self.quest_runes[glyph.id_a] = true
              self.quest_runes[glyph.id_e] = true
              self.quest_runes[glyph.id_p] = true
              -- check, whether we have the runes
              local s = self:getLists()
              local potency = s.potency_runes[glyph.id_p]
              if (potency ~= nil and potency[RUNE_COUNT] ~= nil and type(potency[RUNE_COUNT]) == "number" and potency[RUNE_COUNT] > 0) then
                local aspect = s.aspect_runes[glyph.id_a]
                if (aspect ~= nil and aspect[RUNE_COUNT] ~= nil and aspect[RUNE_COUNT] > 0) then
                  local essence = s.essence_runes[glyph.id_e]
                  if (essence ~= nil and essence[RUNE_COUNT] ~= nil and essence[RUNE_COUNT] > 0) then
                    QE_Window:MarkQuestGlyphAvailable()
                  end
                end
              end
            else
              local rune = self:getRuneName(conditionText)
              local id = self:findRune(rune)
              if (id == nil and QE_Language[QuickEnchanter.savedVars.language].quest_rune_prefix2) then -- fallback
                rune = self:getRuneName(conditionText, 2)
                id = self:findRune(rune)
              end
              if (id == nil and QE_Language[QuickEnchanter.savedVars.language].quest_rune_prefix3) then -- another fallback
                rune = self:getRuneName(conditionText, 3)
                id = self:findRune(rune)
              end
              if (id ~= nil) then
                if (self:dbg(1)) then self:debug("Mark rune " .. rune .. " with id " .. id .. " as quest rune achievement.") end
                self.quest_runes[id] = true
              end
            end
          end
        end
      end
    end
  end
  
  return retvalue
end

function QuickEnchanter:createWritGlyph()
  local glyph = self:getWritGlyph()
  if (glyph ~= nil) then
    self:CraftEnchantmentImpl(glyph)
  else
    d("Information for writ glyph not found.")
  end
end

-- Command display start
function QuickEnchanter:cmdQuickEnchanter(text, test)
  local check = self.do_you_really_wanna
  self.do_you_really_wanna = false

  if (text == "en") then
    self:printCrafting(CRAFTING_TYPE_ENCHANTING)
  elseif (text == "initen") then
  	self:InitGlobalInput(CRAFTING_TYPE_ENCHANTING)  
  elseif (text == "reseten") then
    if (check) then
	  self:erase(CRAFTING_TYPE_ENCHANTING)
    else
      self:checker()
	end
  elseif (text == "cleanvar") then
  	self:cleanResults()
  elseif (text == "resetall") then
    if (check) then
      self:erase()
    else
      self:checker()
    end
  elseif (text == "test") then
--    local slots = GetBagSize(BAG_BACKPACK)
--    for slot = 0, slots do
--      if (self:IsProtected(BAG_BACKPACK, slot)) then
--        d(GetItemName(BAG_BACKPACK, slot) .. " is protected.")
--      end
--    end
  else
    d("Running " .. addon_name .. " version " .. QE_Settings.version .. ".")
  end
  d("level " .. GetUnitLevel("player"))
  d("vlevel " .. GetUnitVeteranRank("player"))
end
-- Command display end

function QuickEnchanter:resetCrafting(which)
  if (self.crafting[which] == nil) then
    self.crafting[which] = {}
  end
  self.crafting[which].input = {}
  self.current_crafting = nil
end

function QuickEnchanter:initCrafting(event, which)
  self:resetCrafting(which)
  self.current_crafting = which
  self.crafting[which].input = self:getInputList()
end

-- attempt at getting useful information out of a link
function QuickEnchanter:MyGetItemInfo(bag, slot)
  local retval
  
  if (bag ~= BAG_BACKPACK and bag ~= BAG_BANK and bag ~= BAG_VIRTUAL) then return retval end
    
  local link = GetItemLink(bag, slot)
  
  retval = self:MyGetItemInfoFromLink(link)
  
  if (retval ~= nil) then
  
    local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(bag, slot)
    retval.icon = icon
    retval.stack = stack
    retval.sellPrice = sellPrice
    retval.meetsUsageRequirement = meetsUsageRequirement
    retval.locked = locked
    retval.equipType = equipType
    retval.itemStyle = itemStyle
    retval.quality = quality
    if (retval.quality == nil) then retval.quality = ITEM_QUALITY_NORMAL end
    if (self:dbg(2)) then self:debug("GetItemInfo " .. (name and name or "-") .. ": equipType:" .. (equipType and equipType or "-") .. " Style:" .. (itemStyle and itemStyle or "-") .. " quality:" .. (quality and quality or "-")) end
        
    local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(bag, slot)
    retval.usedInCraftingType = usedInCraftingType
    retval.itemType = itemType
    retval.extraInfo1 = extraInfo1 -- type of enchantment in case of enchantments
    retval.extraInfo2 = extraInfo2 -- requirements level
    retval.extraInfo3 = extraInfo3
        
    retval.rank = GetItemLinkRequiredCraftingSkillRank(link)
    if (self:dbg(2)) then self:debug("GetItemCraftingInfo name:" .. (name and name  or "-") .. " id:" .. (id and id or "-") .. " type:" .. (itemType and itemType or "-") .. " ench1:" .. (ench1 and ench1 or "-") .. " ench2:" .. (ench2 and ench2 or "-") .. " enchantment: " .. (enchantment and enchantment or "-") .. " itemtype:" .. (itemType and itemType or "-") .. " 1:" .. (extraInfo1 and extraInfo1 or "-") .. " 2:" .. (extraInfo2 and extraInfo2 or "-") .. " 3:" .. (extraInfo3 and extraInfo3 or "-")) end
       
  end
  
  return retval
  
end

function QuickEnchanter:MyGetItemInfoFromLink(link)

    local retval
    
    if (link ~= nil) then
    retval = {}
    local name,col,typID,id,qual,levelreq,enchantment,ench1,ench2,un1,un2,un3,un4,un5,un6,un7,un8,un9,style,un10,bound,charge,un11 = ZO_LinkHandler_ParseLink(link)
        retval.name = self:NormalizeName(name)
        retval.id = id
        retval.typeID = typID -- like "item"
        retval.link = link
        retval.quality = qual
        retval.minlevel = tonumber(levelreq)
        retval.enchantment = enchantment -- used enchantment on item
        retval.charge = charge -- charge for enchantments
        retval.style = style -- number for style like Dunmer, Nord etc.
        retval.bound = bound -- 1 = bound to account
        if (self:dbg(2)) then self:debug("ParseLink " .. (name and name or "-") .. "ench1: " .. (ench1 and ench1 or "-") .. " ench2:" .. (ench2 and ench2 or "-") .. " un1:" .. (un1 and un1 or "-") .. " un2:" .. (un2 and un2 or "-") .. " un3: " .. (un3 and un3 or "-") .. " un4:" .. (un4 and un4 or "") .. " un5:" .. (un5 and un5 or "") .. " un6:" .. (un6 or un6 or "-") .. " un7:" .. (un7 and un7 or "-") .. " un8:" .. (un8 and un8 or "-") .. " un9:" .. (un9 and un9 or "-") .. " un10:".. (un10 and un10 or "-") .. " un11:" .. (un11 and un11 or "-")) end
        
  end

  return retval
end

-- there should be a generic function provided by ZO?!
function QuickEnchanter:GetItemId(bag, slot)
  local info = self:MyGetItemInfo(bag, slot)
  
  if (info ~= nil) then return info.id end
  
  return nil
end

function QuickEnchanter:getInfoByNameBag(bag_id, name)
  local slot = ZO_GetNextBagSlotIndex(bagId, nil)
  while slot do
    local iname = GetItemName(bag_id, slot)
    if (iname ~= nil) then
      if (iname == name) then
        return self:MyGetItemInfo(bag_id, slot)
      end
    end
    slot = ZO_GetNextBagSlotIndex(bagId, slot)
  end

  return nil
end

-- try to match by name in lack of a better function - instance id doesn't seem reliable
-- TODO: requires BAG_VIRTUAL check as well?
function QuickEnchanter:getInfoByName(name)
  local retval = self:getInfoByName(BAG_BACKPACK)
  if (HasCraftBagAccess() and retval == nil) then
    return self:getInfoByName(BAG_VIRTUAL)
	end

	return nil
end

function QuickEnchanter:cleanResults()
	if (self.savedVars[CRAFTING_TYPE_ENCHANTING] ~= nil) then
		for k,v in pairs(self.self.savedVars[CRAFTING_TYPE_ENCHANTING].results) do
			if (v.results ~= nil) then
				for k2,v2 in pairs(v.results) do
					if (v2.minlevel == nil) then
						v.results[k2] = nil -- reset
					end
				end
			end
		end
	end
end

function QuickEnchanter:ResetExtractedRunes()
  if (self:dbg(1)) then self:debug("Reset extracted runes") end
  self.extracted_runes = {}
  self.found_extracted_runes = false
  self.has_extracted = 0
end

function QuickEnchanter:finishCrafting(event, which)

  if (which == CRAFTING_TYPE_ENCHANTING) then
    self:RuneUpdateCheck()
    self:Refresh()
  end
  
  local result_runes = {}
  
	for n = 1, GetNumLastCraftingResultItemsAndPenalty() do
		if (self:dbg(1)) then self:debug("Result number:" .. n) end
		local name, icon, stack, sellPrice, meetsUsageRequirement, equipType, itemType, itemStyle, quality, soundCategory, itemInstanceId = GetLastCraftingResultItemInfo(n)
		if (name ~= nil and self:isRune(itemType)) then
		  if (self.extracted_runes == nil) then self.extracted_runes = {} end
		  if (self.extracted_runes[name] ~= nil) then
		    self.extracted_runes[name][3] = self.extracted_runes[name][3] + 1
		  else
		    self.extracted_runes[name] = { icon, quality, 1 }
		  end
		  self.found_extracted_runes = true
			if (self:dbg(1)) then self:debug("name:" .. name .. " icon: " .. icon .. " eq-type:" .. equipType .. " item-type:" .. itemType .. " instance id:" .. itemInstanceId) end
		end
	end
end

function QuickEnchanter:InitGlobalInput(which)
	if (self:dbg(1)) then self:debug("Init global input information " .. which) end
	if (self.savedVars.input == nil) then self.savedVars.input = {} end

	if (self.savedVars[which].results ~= nil) then
	    for id_rune, value_rune in pairs(self.savedVars[which].results) do
	    	for id_result, value_result in pairs(value_rune.results) do
	    		if (value_result.input ~= nil) then
					for id_result_rune, value_result_rune in pairs(value_result.input) do
						self.savedVars.input[value_result_rune.id] = value_result_rune
						if (self:dbg(1)) then self:debug("Transfer to global input information:" .. value_result_rune.id .. " " .. self.savedVars.input[id_result].name) end
					end
				end
	    	end
	    end
	end

	-- TODO: remove superfluous information
end

-- Function is for returning a table with the input items
function QuickEnchanter:getInputList()

	local retval = {}

	if (self.current_crafting ~= nil) then
		if (self.current_crafting == CRAFTING_TYPE_ENCHANTING) then
			for k,v in pairs(ENCHANTING.runeSlots) do
				local bag = v.bagId
				local slot = v.slotIndex
				if (bag ~= nil and slot ~= nil) then
					local info = self:MyGetItemInfo(bag, slot)
					if (info ~= nil) then
						retval[k] = {}
						retval[k].name       = info.name
						retval[k].link       = info.link
						retval[k].id         = info.id
						retval[k].itemType   = info.itemType
						retval[k].extraInfo1 = info.extraInfo1
						retval[k].extraInfo2 = info.extraInfo2
						retval[k].extraInfo3 = info.extraInfo3
						retval[k].icon       = info.icon
					end
				end
			end
		end
	end

	return retval
end

function QuickEnchanter:resetSingleRune(rune, count)
  rune[RUNE_STACKS] = nil
  rune[RUNE_COUNT] = count ~= nil and count or 0
end

function QuickEnchanter:resetSingleRuneSet(runes, count)
  for k,v in pairs(runes) do
    self:resetSingleRune(v, count)
  end
end

function QuickEnchanter:findRuneIdinSet(set, name)
  if (set ~= nil and name ~= nil) then
    for k,v in pairs(set) do
      if (v[RUNE_NAME] == name) then
        if (self:dbg(1)) then self:debug("Found rune " .. name .. " with id " .. k) end
        return k
      end
    end
  end
  
  return nil
end

function QuickEnchanter:findRune(name)
  local s = self:getLists()
  local id = self:findRuneIdinSet(s.potency_runes, name)
  if (id ~= nil) then return id end
  id = self:findRuneIdinSet(s.essence_runes, name)
  if (id ~= nil) then return id end
  id =self:findRuneIdinSet(s.aspect_runes, name)
  
  return id
end

function QuickEnchanter:resetRuneCount()
  local s = self:getLists()
  self:resetSingleRuneSet(s.potency_runes)
  self:resetSingleRuneSet(s.essence_runes)
  self:resetSingleRuneSet(s.aspect_runes, -1)
end

function QuickEnchanter:validRune(rune)
  return rune[RUNE_STACKS] ~= nil
end

function QuickEnchanter:getBagInfo(rune)
  if (rune ~= nil and type(rune) == "table" and rune[RUNE_STACKS] ~= nil) then
    return { rune[RUNE_STACKS][1][RUNE_STACK_BAG], rune[RUNE_STACKS][1][RUNE_STACK_SLOT] }
  end
  
  return nil
end

function QuickEnchanter:updateStackInfos(glyph)
  self:updateStackInfo(glyph.rune_p)
  self:updateStackInfo(glyph.rune_e)
  self:updateStackInfo(glyph.rune_a)
end

-- only need to update the first entry each
function QuickEnchanter:updateStackInfo(rune)
  if (rune ~= nil) then
    local stack = rune[RUNE_STACKS]
    if (stack ~= nil) then
      local entry = stack[1]
      if (entry ~= nil) then
        local info = self:MyGetItemInfo(entry[RUNE_STACK_BAG], entry[RUNE_STACK_SLOT])
        if (info ~= nil and info.stack ~= nil and info.stack > 0 and info.id == rune[RUNE_ID]) then
          entry[RUNE_STACK_AMOUNT] = info.stack
        else
          table.remove(stack, 1)
        end
      end
    end
  end
end

function QuickEnchanter:insertRune(runes, bag, slot, info)
  local i = runes[info.id]
  if (i == nil) then
    runes[info.id] = { info.icon, info.name, info.stack, info.quality, info.link, info.id }
    i = runes[info.id]
  else
    -- update
    if (info.icon ~= nil) then i[RUNE_ICON] = info.icon end
    if (info.name ~= nil) then i[RUNE_NAME] = info.name end
    if (info.quality ~= nil) then i[RUNE_QUALITY] = info.quality end
    if (info.link ~= nil) then i[RUNE_LINK] = info.link end
    if (info.id ~= nil) then i[RUNE_ID] = info.id end
    if (i[RUNE_COUNT] < 0) then
      i[RUNE_COUNT] = 0
    end
    i[RUNE_COUNT] = i[RUNE_COUNT] + info.stack
  end
  
  if (bag >= 0 and slot >= 0 and info.stack > 0) then
    if (i[RUNE_STACKS] == nil) then i[RUNE_STACKS] = {} end
    local stack = i[RUNE_STACKS]
    if (table.getn(stack) > 0 and info.bag == BAG_BACKPACK) then
      table.insert(stack, 1, { bag, slot, info.stack }) -- push to front
    else
      table.insert(stack, { bag, slot, info.stack })
    end
  end
end

-- get runes sorted by type - each entry in the tables are bag, slot
function QuickEnchanter:getRunes(bag, aspect_level, aspect_quality_found)

  local s = self:getLists()
  local aspect_runes = s.aspect_runes
  local essence_runes = s.essence_runes
  local potency_runes = s.potency_runes
  
  local slot = ZO_GetNextBagSlotIndex(bag, nil)
  
  while slot do
    local info = self:MyGetItemInfo(bag, slot)
    if (info ~= nil) then
      local subtype = info.extraInfo1
      if (info.itemType ~= nil and subtype ~= nil) then
        if (self:isRune(info.itemType)) then
          -- avoid duplicate entries and avoid to put combinations that can't be realized
          if (info.id ~= nil and info.meetsUsageRequirement) then
              if (subtype == ENCHANTING_RUNE_ASPECT) then
                aspect_quality_found[info.quality] = true
                repeat
                  if (self.savedVars.best_quality) then
                    if (#aspect_runes > 0) then
                      if (info.minlevel ~= nil and info.minlevel > aspect_level) then
                        for k,v in pairs(aspect_runes) do
                          self:resetSingleRune(v, -1)
                        end
                      else
                        break
                      end
                    end
                    aspect_level = info.minlevel
                  end
                  if (self.savedVars.quality_selection[QE_Settings.quality_lookup[info.quality]] ~= 1) then break end
                  self:insertRune(aspect_runes, bag, slot, info)
                until true -- hack for continue
              elseif (subtype == ENCHANTING_RUNE_ESSENCE) then
                self:insertRune(essence_runes, bag, slot, info)
              elseif (subtype == ENCHANTING_RUNE_POTENCY) then
                self:insertRune(potency_runes, bag, slot, info)
            end
          end
        end
      end
    end
    slot = ZO_GetNextBagSlotIndex(bag, slot)
  end

  return aspect_level
end

-- we are not interested in stack amounts here
function QuickEnchanter:CountRunesBag(bag)
  local slots = GetBagSize(bag)
  
  local count = 0
  for slot = 0, slots do
    local info = self:MyGetItemInfo(bag, slot)
    if (info ~= nil and self:isRune(info.itemType)) then
      count = count + 1
    end
  end
  
  return count
end

function QuickEnchanter:CountRunes()
  local val = self:CountRunesBag(BAG_BACKPACK)
  val = val + self:CountRunesBag(BAG_BANK)
  if (HasCraftBagAccess()) then val = val + self:CountRunesBag(BAG_VIRTUAL)end
  
  return val
end

function QuickEnchanter:resetPermutations()
  self.num_runes = nil
end

function QuickEnchanter:Refresh(force)
  if (self.calculated == nil or force) then
    if (QE_Window_Screen ~= nil and not (QE_Window_Screen:IsHidden() and QE_Window.top:IsHidden())) then
      if (self:dbg(1)) then self:debug("Refresh window") end
      self.permutations = self:createPermutations()
      QE_Window:RedrawGlyphs()
      self.calculated = true
    else
      if (self:dbg(1)) then self:debug("No refresh - QE_Window_Screen either doesn't exist or is hidden.") end
    end
  end
end

function QuickEnchanter:RuneUpdateCheck()
  if (self:dbg(1)) then self:debug("RuneUpdate") end
  
  -- only check for runes, if no calculation has been triggered yet
  if (self.calculated) then 
    local num_runes = self:CountRunes()
    if (self.num_runes == nil or num_runes ~= self.num_runes) then
      self.calculated = nil
      self.num_runes = num_runes
    end
  end
end

function QuickEnchanter:getPermutations()
  if (self:dbg(1)) then self:debug("getPermutations") end

  self:RuneUpdateCheck()
  
  if (self.permutations == nil) then
    self.permutations = {}
    self.num_runes = 0
  end
  
  return self.permutations
end

function QuickEnchanter:getLists()
  return self.use_master and QE_Master or self.savedVars
end

function QuickEnchanter:fixLevel(entry)
  local potency_info = self:getPotencyLevelInformation(entry.id_p)
  if (potency_info ~= nil) then
    entry.glyph_level = potency_info[POTENCY_LEVEL_STRING]
    if (entry.glyph_level == nil) then
      entry.glyph_level = ""
    end
  end
end

function QuickEnchanter:getPotencyLevelInformation(id)
  local s = self:getLists()
  local potency_rune = s.potency_runes[id]
  if (potency_rune ~= nil) then
    local potency_name = self:NormalizeName(potency_rune[RUNE_NAME])
    if (potency_name ~= nil) then
      return self.potency_level_information[potency_name]
    end
  end
  
  return nil
end

-- returns sort function over glyph results
function QuickEnchanter:getSortFunction(tmp_permutations)
  return function (a_p, b_p)
      -- sorting by level, type, quality
      local a = tmp_permutations[a_p]
      local b = tmp_permutations[b_p]

      if (QuickEnchanter.savedVars.sort_marked) then
        if (a.is_marked) then
          if (not b.is_marked) then
            return true
          end
        elseif (b.is_marked) then
          return false
        end
      end
      
      local a_has_level = (a.info ~= nil and a.info.minlevel ~= nil)
      local b_has_level = (b.info ~= nil and b.info.minlevel ~= nil)
      
      if (a_has_level) then
        if (b_has_level) then
          if (a.info.minlevel ~= b.info.minlevel) then
            return a.info.minlevel > b.info.minlevel
          end
        else
          return true
        end
      elseif (b_has_level) then
        return false
      end
   
      -- quality for veteran level?
      local a_has_quality = (a.info ~= nil and a.info.quality ~= nil)
      local b_has_quality = (b.info ~= nil and b.info.quality ~= nil)
      
      if (a_has_quality) then
        if (b_has_quality) then
          if (a.info.quality ~= b.info.quality) then
            return a.info.quality > b.info.quality
          end
        else
          return true
        end
      elseif (b_has_quality) then
        return false
      end
         
      if (a.enchantment_type ~= b.enchantment_type) then return a.enchantment_type < b.enchantment_type end
      
      if (a.quality ~= nil) then
        if (b.quality == nil) then return true end
        if (a.quality ~= b.quality) then return a.quality > b.quality end
      elseif (b.quality ~= nil) then
        return false
      end
      
      return a.name < b.name
    end
end

function QuickEnchanter:createPermutations(filter_off)

  if (self:dbg(1)) then self:debug("Create permutations") end

  local s = self:getLists()
  local potency_runes = s.potency_runes
  local aspect_runes = s.aspect_runes
  local essence_runes = s.essence_runes

  self:resetRuneCount()

  local quality_found = {}
  local aspect_level = self:getRunes(BAG_BACKPACK, 0, quality_found)
  self:getRunes(BAG_BANK, aspect_level, quality_found)
  if (HasCraftBagAccess()) then self:getRunes(BAG_VIRTUAL, aspect_level, quality_found) end
  
  self:getWritGlyph()
  
  -- fix buttons for quality
  if (QE_Window.top ~= nil and QE_Window.top.qualities ~= nil) then
    for i=1, #QE_Settings.qualities do
      if (QE_Window.top.qualities[i] ~= nil) then
        if (quality_found[QE_Settings.qualities[i]]) then
          if (self:dbg(2)) then self:debug("Enable quality selection " .. i) end
          QE_Window.top.qualities[i]:SetState(BSTATE_NORMAL)
        else
          QE_Window.top.qualities[i]:SetState(BSTATE_DISABLED)
          if (self:dbg(2)) then self:debug("Disable quality selection " .. i) end
        end
        QE_Window:UpdateButton(i, QE_Window.top.qualities[i])
      end
    end
  end
  
  local tmp_permutations = {}
  local num = 0

  for keyp, value_p in pairs(potency_runes) do
    local potency_name = self:NormalizeName(value_p[RUNE_NAME])
    if (self:dbg(3)) then self:debug("potency name " .. potency_name) end
    -- no better way to extract resulting glyph value?
    local level = ""
    local min_level
    local max_level
    local min_vlevel
    local max_vlevel
    local effect_type
    local potency_info
    if (potency_name ~= nil) then
      potency_info = QuickEnchanter.potency_level_information[potency_name]
      if (potency_info ~= nil) then
        level = potency_info[POTENCY_LEVEL_STRING]
        if (level == nil) then
          level = ""
        end
        min_level = potency_info[POTENCY_MIN_LEVEL]
        max_level = potency_info[POTENCY_MAX_LEVEL]
        min_vlevel = potency_info[POTENCY_MIN_VLEVEL]
        max_vlevel = potency_info[POTENCY_MAX_VLEVEL]
        effect_type = potency_info[POTENCY_EFFECT]
        --if (self:dbg(1)) then self:debug("potency rune " .. potency_name .. " level '" .. level .. "' min:" .. min_level .. ", max-level:" .. max_level) end
      end
    end

    repeat

      if (not filter_off) then
        -- level filtering
        local clevel = QuickEnchanter.chosen_level
        if (clevel ~= nil and clevel > 0) then
          if (min_level == nil or max_level == nil or clevel < min_level or clevel > max_level) then
            break
          end
        end
        clevel = QuickEnchanter.chosen_veteran_level
        if (clevel ~= nil and clevel > 0) then
          if (min_vlevel == nil or clevel < min_vlevel or max_vlevel ~= nil and max_vlevel < clevel) then
            break
          end
        end

        -- effect type filtering
        if (effect_type ~= nil and effect_type ~= 0) then
          if (effect_type < 0 and QuickEnchanter.savedVars.enabled_effect_types[tonumber(-1)] == 0) then break end
          if (effect_type > 0 and QuickEnchanter.savedVars.enabled_effect_types[tonumber(1)] == 0) then break end
        end
      end

      for keya, value_a in pairs(aspect_runes) do
        for keye, value_e in pairs(essence_runes) do
          local valid_entry = self:validRune(value_p) and self:validRune(value_e) and self:validRune(value_a)
          local tmp = {}
          if (valid_entry) then
            local bag_a = self:getBagInfo(value_a)
            local bag_p = self:getBagInfo(value_p)
            local bag_e = self:getBagInfo(value_e)
            local bag_info = { bag_p[1], bag_p[2], bag_e[1], bag_e[2], bag_a[1], bag_a[2] }
            local name, icon, stack, sellPrice, meetsUsageRequirement, quality = GetEnchantingResultingItemInfo(unpack(bag_info))
            tmp.name = self:NormalizeName(name)
            if (tmp.name == nil) then tmp.name = "" end
            tmp.icon = icon
            tmp.potency_info = potency_info
            tmp.glyph_level = level
            if (self:dbg(3)) then self:debug("Icon for " .. tmp.name .. ":'" .. tmp.icon .. "' level:" .. tmp.glyph_level) end

            tmp.quality = quality
            if (tmp.quality == nil) then tmp.quality = ITEM_QUALITY_NORMAL end

            tmp.link = GetEnchantingResultingItemLink(unpack(bag_info))
            tmp.info = self:MyGetItemInfoFromLink(tmp.link)
            
            tmp.enchantment_type = GetItemLinkItemType(tmp.link)
            
            tmp.id_a = keya
            tmp.id_e = keye
            tmp.id_p = keyp
            
            -- determine maximum number of glyphs that can be created
            local count = 0
            local count_p = potency_runes[tmp.id_p][RUNE_COUNT]
            local count_e = essence_runes[tmp.id_e][RUNE_COUNT]
            local count_a = aspect_runes[tmp.id_a][RUNE_COUNT]
            if (count_a ~= nil and count_e ~= nil and count_p ~= nil) then
              if (self:dbg(2)) then self:debug("Counts are " .. count_a .. " aspect " .. count_e .. " essence and " .. count_p .. " potency runes for " .. tmp.name) end
              count = count_a
              if (count_e < count) then count = count_e end
              if (count_p < count) then count = count_p end
            end
            tmp.count = count
            local tmp_key = tmp.id_p .. "_" .. tmp.id_e .. "_" .. tmp.id_a
            s.glyph_info[tmp_key] = tmp
            -- create rune to glyph lookup on the fly
            if (self.rune_to_glyph_info == nil) then self.rune_to_glyph_info = {} end
              -- only store for potency and essence
            if (self.rune_to_glyph_info[tmp.id_e] == nil) then self.rune_to_glyph_info[tmp.id_e] = {} end
            self.rune_to_glyph_info[tmp.id_e][tmp_key] = true
            if (self.rune_to_glyph_info[tmp.id_p] == nil) then self.rune_to_glyph_info[tmp.id_p] = {} end
            self.rune_to_glyph_info[tmp.id_p][tmp_key] = true
            if (self:dbg(2)) then self:debug("Store key '" .. tmp_key .. "' for rune " .. tmp.id_p) end
          elseif (self.savedVars.show_unavailable) then
            tmp = s.glyph_info[keyp .. "_" .. keye .. "_" .. keya]
            if (tmp ~= nil) then tmp.count = 0 end
          end

          if (tmp ~= nil) then
            tmp.rune_a = nil
            tmp.rune_p = nil
            tmp.rune_e = nil
            
            if ((value_a[RUNE_COUNT] > -1 or (self.savedVars.show_unavailable and QuickEnchanter.savedVars.quality_selection ~= nil and QuickEnchanter.savedVars.quality_selection[QE_Settings.quality_lookup[value_a[RUNE_QUALITY]]] == 1))) then
              tmp.rune_a = value_a
              tmp.rune_p = value_p
              tmp.rune_e = value_e
              if (QuickEnchanter.savedVars.enabled_types[tmp.enchantment_type] == 1) then
                tmp.is_marked = self:IsMarked(tmp) -- has to be after setting ids
                table.insert(tmp_permutations, tmp)
              end

              num = num + 1
            end
          end
        end
      end
    until true -- hack for lack of continue
  end

  -- we can't sort tables with strings as keys directly - hooray ...
  local keys = {}
  for k,_ in pairs(tmp_permutations) do
    keys[#keys+1] = k
  end
  
  table.sort(keys, self:getSortFunction(tmp_permutations))
  
  -- copy the sorted output
  local permutations = {}
  
  for i = 1, #keys do
    table.insert(permutations, tmp_permutations[keys[i]])
  end
  
  if (self:dbg(1)) then self:debug("Created " .. #permutations .. " glyph entries.") end
  --d(num .. " rune combinations known with existing runes.")
  return permutations

end

function QuickEnchanter:GetItemId(bag, slot)
  local link = GetItemLink(bag, slot)
  if (link ~= nil) then
    return select(4, ZO_LinkHandler_ParseLink(link))
  end
  
  return nil
end

function QuickEnchanter:IsMarked(info)
  local saved = QuickEnchanter.savedVars
  return info ~= nil and info.id_p ~= nil and info.id_e ~= nil and saved.marked_glyphs ~= nil and saved.marked_glyphs[info.id_p] ~= nil and saved.marked_glyphs[info.id_p][info.id_e]
end

function QuickEnchanter:IsMarkedRune(id)
  local runes  = QuickEnchanter.savedVars.marked_runes
  return runes ~= nil and runes[id] ~= nil
end

function QuickEnchanter:IsQuestRune(id)
  local runes = QuickEnchanter.quest_runes
  return runes ~= nil and runes[id] ~= nil
end

function QuickEnchanter:RuneMarking(id, add)
  local saved = QuickEnchanter.savedVars
  if (saved.marked_runes == nil) then saved.marked_runes = {} end

  if (add) then
    if (saved.marked_runes[id] == nil) then
      saved.marked_runes[id] = 1
    else
      saved.marked_runes[id] = saved.marked_runes[id] + 1
    end
  else
    if (saved.marked_runes[id]) then
      saved.marked_runes[id] = saved.marked_runes[id] - 1
      if (saved.marked_runes[id] <= 0) then
        saved.marked_runes[id] = nil
      end
    end
  end
end

-- takes index id
function QuickEnchanter:ToggleMarkGlyph(id)
  local permutations = self:getPermutations()
  if (permutations ~= nil) then
    local i = permutations[id]
    if (i ~= nil and i.id_p ~= nil and i.id_e ~= nil) then
      local saved = QuickEnchanter.savedVars
      if (saved.marked_glyphs == nil) then saved.marked_glyphs = {} end
      if (saved.marked_glyphs[i.id_p] == nil) then saved.marked_glyphs[i.id_p] = {} end
      
      if (saved.marked_glyphs[i.id_p][i.id_e] ~= nil) then
        saved.marked_glyphs[i.id_p][i.id_e] = nil
        self:RuneMarking(i.id_p, false)
        self:RuneMarking(i.id_e, false)
      else
        saved.marked_glyphs[i.id_p][i.id_e] = true
        self:RuneMarking(i.id_p, true)
        self:RuneMarking(i.id_e, true)
      end
    else
        d("WARNING: potency and essence runes were not properly defined.")
    end
  end
end

function QuickEnchanter:CountGlyphs(bag)
  local slots = GetBagSize(bag)
  local count = 0
  
  for slot = 0, slots do
    local type = GetItemType(bag, slot)
    if (self:isGlyph(type)) then
    end
  end
  
  return count
end

function QuickEnchanter:IsProtected(bag, slot)
  local id = GetItemInstanceId(bag, slot)
  local retval = self.savedVars.FCO_just_marked and FCOIsMarked ~= nil and FCOIsMarked(id, 1)
  if (retval) then return true end
  retval = FCOIsFiltered and FCOIsFiltered(id, -1, 9)
  if (retval) then return true end
  return ItemSaver_IsItemSaved ~= nil and ItemSaver_IsItemSaved(bag, slot)
end

function QuickEnchanter:ExtractGlyphs(bag, attempt)
  if (self:dbg(1)) then self:debug("ExtractGlyphs " .. bag) end
  if (self.is_at_crafting_station == nil) then
    if (self:dbg(1)) then self:debug("Bail out because of not being at the crafting station.") end
    return
  end
  
  if (bag < 0) then
    if (bag ~= BAG_BACKPACK) then
      self:ExtractGlyphs(BAG_BACKPACK)
    end
    if (bag ~= BAG_BANK) then
      self:ExtractGlyphs(BAG_BANK)
    end
    return
  end
  
  local slots = GetBagSize(bag)
  
  attempt = attempt and attempt + 1 or 1
  if (self.current_crafting ~= nil) then
    if (self:dbg(1)) then self:debug("Currently crafting - return later - attempt " .. attempt) end
    zo_callLater(function() QuickEnchanter:ExtractGlyphs(bag, attempt) end, QuickEnchanter.savedVars.retry_delay)
    return
  end
  
  if (self:dbg(1)) then self:debug("attempt " .. attempt .. " out of " .. QE_Settings.max_attempts) end
  if (attempt > QE_Settings.max_attempts) then
    QE_Window:drawRunes(1)
    return
  end -- safety
  
  for slot = 0, slots do
    local type = GetItemType(bag, slot)
    if (self:isGlyph(type) and not self:IsProtected(bag, slot)) then
      if (self:ExtractItem(bag, slot)) then
        attempt = 0
      end
      if (self:dbg(1)) then self:debug("set up call-back for " .. bag) end
      zo_callLater(function() QuickEnchanter:ExtractGlyphs(bag, attempt) end, QuickEnchanter.savedVars.retry_delay)
      return
    end
  end
  
  QE_Window:drawRunes(1)
end

-- clear after extract
function QuickEnchanter:ExtractItem(bag, slot)
  if (self:dbg(1)) then self:debug("ExtractItem " .. bag .. "," .. slot .. " " .. GetItemName(bag, slot)) end
  --ENCHANTING:SetExtractionSlotItem(bag, slot)
  if (self.is_at_crafting_station and self.current_crafting == nil) then
    local mode = ENCHANTING:GetEnchantingMode()
    ENCHANTING:SetEnchantingMode(ENCHANTING_MODE_EXTRACTION)
    ZO_MenuBar_SelectDescriptor(ZO_EnchantingTopLevelModeMenuBar, ENCHANTING_MODE_EXTRACTION)
    ENCHANTING:AddItemToCraft(bag, slot)
    self.has_extracted = self.has_extracted + 1
    ExtractEnchantingItem(bag, slot)
    return true
  else
    if (self:dbg(1)) then self:debug("bailing out because of either not at the station or currently crafting") end
  end
  
  return false
end

function QuickEnchanter:GetRuneDisplay(id)
  local info = self:GetRuneInfo(id)
  if (info ~= nil) then
    local icon = zo_iconFormat(info[RUNE_ICON], QuickEnchanter.savedVars.tooltip_icon_size, QuickEnchanter.savedVars.tooltip_icon_size)
    icon = icon and icon or ""
    local name = info[RUNE_NAME] and info[RUNE_NAME] or ""
    local count = (info[RUNE_COUNT] and info[RUNE_COUNT] or 0)
    if (count == nil or count < 0) then count = 0 end
    local count_string = string.format("%3d", count)
    if (count == 0) then count_string = RED_TEXT:Colorize(count_string) end
    return icon .. string.format("%-10s", GetItemQualityColor(info[RUNE_QUALITY]):Colorize(name) .. ":" .. count_string) .. " "
  end
  
  return ""
end

function QuickEnchanter:GetRuneInfo(id)
  local s = self:getLists()
  local info = s.potency_runes[id]
  if (info == nil) then info = s.essence_runes[id] end
  if (info == nil) then info = s.aspect_runes[id] end
  
  return info
end

function QuickEnchanter:GetRuneLink(id)
  local info = self:GetRuneInfo(id)
  if (info ~= nil) then
    return info[RUNE_LINK]
  end
  return ""
end

function QuickEnchanter:CopyToChat(i, which, amounts)
  if (CHAT_SYSTEM) then
    if (which == nil) then which = 1 end -- default is showing glyphs
    local amount = (QuickEnchanter.savedVars.copy_amount == 1 or amounts) and (i.count .. "x") or ""
    local text = ""
    if (which == 1) then -- glyphs
      text = amount .. "[" .. i.link .. "]"
    elseif (which == 2) then -- runes
      if (amounts) then
       local i_p = self:GetRuneInfo(i.id_p)
       local i_e = self:GetRuneInfo(i.id_e)
       local i_a = self:GetRuneInfo(i.id_a)
       if (i_p ~= nil and i_p[RUNE_COUNT] <= 0) then text = text .. "[" .. self:GetRuneLink(i.id_p) .. "]" end
       if (i_e ~= nil and i_e[RUNE_COUNT] <= 0) then text = text .. "[" .. self:GetRuneLink(i.id_e) .. "]" end
       if (i_a ~= nil and i_a[RUNE_COUNT] <= 0) then text = text .. "[" .. self:GetRuneLink(i.id_a) .. "]" end
      else
        text = "[" .. self:GetRuneLink(i.id_p) .. "]" .. "[" .. self:GetRuneLink(i.id_e) .. "]" .. "[" .. self:GetRuneLink(i.id_a) .. "]"
      end
    end
    if (CHAT_SYSTEM.textEntry ~= nil and CHAT_SYSTEM.textEntry.GetText ~= nil and CHAT_SYSTEM.textEntry:GetText() ~= "" and CHAT_SYSTEM.textEntry.SetText ~= nil) then
      CHAT_SYSTEM.textEntry:SetText(CHAT_SYSTEM.textEntry:GetText() .. text)
    else
      CHAT_SYSTEM:StartTextEntry(text)
    end
  end
end

function QuickEnchanter:CraftEnchantmentImpl(i)
  if (i ~= nil) then

    if (QuickEnchanter.savedVars.copy_to_chat) then
      self:CopyToChat(i)
      return
    end
    
    local bag_p = self:getBagInfo(i.rune_p)
    local bag_e = self:getBagInfo(i.rune_e)
    local bag_a = self:getBagInfo(i.rune_a)
    
    local has_potency = bag_p ~= nil and self:isRuneOfType(ITEMTYPE_ENCHANTING_RUNE_POTENCY, bag_p[1], bag_p[2])
    local has_essence = bag_e ~= nil and self:isRuneOfType(ITEMTYPE_ENCHANTING_RUNE_ESSENCE, bag_e[1], bag_e[2])
    local has_aspect = bag_a ~= nil and self:isRuneOfType(ITEMTYPE_ENCHANTING_RUNE_ASPECT, bag_a[1], bag_a[2])

    QE_Window:multiCheck(i.count) -- fix slider
    
    if (has_potency) then ENCHANTING:SetRuneSlotItem(3, unpack(self:getBagInfo(i.rune_p))) end
    if (has_essence) then ENCHANTING:SetRuneSlotItem(2, unpack(self:getBagInfo(i.rune_e))) end
    if (has_aspect) then ENCHANTING:SetRuneSlotItem(1, unpack(self:getBagInfo(i.rune_a))) end
    
    if (has_potency and has_essence and has_aspect and (self.savedVars.click_to_create) and self.is_at_crafting_station and self.current_crafting == nil) then
      if (self:dbg(1)) then self:debug("Crafting glyph") end
      QE_Window:DecreaseGlyphCounter()
      ENCHANTING:SetEnchantingMode(ENCHANTING_MODE_CREATION)
      ZO_MenuBar_SelectDescriptor(ZO_EnchantingTopLevelModeMenuBar, ENCHANTING_MODE_CREATION)
      --if (CRAFTING_RESULTS ~= nil) then CRAFTING_RESULTS:SetTooltipAnimationSounds("") end
      self.last_enchantment = i
      --local tmp = ZO_Enchanting_IsInCreationMode
      --ZO_Enchanting_IsInCreationMode = function (...) return false end
      if (self.savedVars.suppress_rune_voicing) then
        ENCHANTING:SetEnchantingMode(ENCHANTING_MODE_EXTRACTON) -- kick sound with this hack
        local bag_info = { bag_p[1], bag_p[2], bag_e[1], bag_e[2], bag_a[1], bag_a[2] }
        CraftEnchantingItem(unpack(bag_info))
      else
        ENCHANTING:Create()
      end
      --ZO_Enchanting_IsInCreationMode = tmp
    end
  end
end
  
-- input is permutation from createPermutations
function QuickEnchanter:CraftEnchantment(id, rightaway)
  if (self:dbg(1)) then self:debug("CraftEnchantment with id " .. id) end
  local permutations = self:getPermutations()
  local i = permutations[id]

  self:CraftEnchantmentImpl(i)
end

-------------------------------
-- Mark runes in inventory
-------------------------------

function QuickEnchanter:SetMarking(indicatorControl, id)
  local permutations = self:getPermutations()
  if (permutations ~= nil) then
    local entry = permutations[id]
    if (entry ~= nil) then
      if (self:IsMarked(entry)) then
        indicatorControl:SetAlpha(1)
      else
        indicatorControl:SetAlpha(QuickEnchanter.savedVars.classic_look and 0.3 or 0.5)
      end
    end
  end
end

-- check implicitly, whether items in equipment can be enchanted with glyphs in the guild-bank
function QuickEnchanter:UpdateEnchantmentForEq(ebag, eslot)
  for k,v in pairs(slots) do
    local slot = _G[k]
    self:CheckSingleItem(BAG_WORN, slot, ebag, eslot)
  end
end

-- check implicitly, whether items in given bag can be enchanted with glyphs in the guild-bank
function QuickEnchanter:UpdateEnchantmentForBag(bag, ebag, eslot)
  local slots = GetBagSize(bag)
  if (slots ~= nil) then
    for s = 0, slots do
      self:CheckSingleItem(bag, s, ebag, eslot)
    end
  end
end

function QuickEnchanter:AddEnchantmentIndicatorToSlot(control, bag, slot)
  
  local indicatorControl = control:GetNamedChild(self.childname)
  if (not indicatorControl) then
    indicatorControl = self:CreateIndicatorControl(control, self.childname)
  end

  self:SetPosition(control, indicatorControl)

  local id = self:GetItemId(bag, slot)

  -- over-ride marking with quest information
  if (id ~= nil and self:IsQuestRune(id)) then
    indicatorControl:SetTexture(QE_Settings.quest_rune_texture)
    indicatorControl:SetColor(0, 1, 0, 1)
    indicatorControl:SetHidden(false)
  -- marked rune?
  elseif (id ~= nil and self:IsMarkedRune(id)) then
    indicatorControl:SetTexture(QE_Settings.marked_rune_texture)
    indicatorControl:SetColor(0, 1, 0, 1)
    indicatorControl:SetHidden(false)
  -- indicators - can item be marked?
  elseif (self.savedVars.enchantment_check) then
    local traitKey = self:CheckIsItemEnchantable(bag, slot)

    if (bag == BAG_WORN) then if (self:dbg(2)) then self:debug("Item " .. GetItemName(bag, slot) .. " got trait " .. (traitKey and traitKey or "nil")) end end

    if (traitKey) then
      indicatorControl:SetHidden(false)
      if (bag == BAG_WORN) then if (self:dbg(2)) then self:debug("Item " .. GetItemName(bag, slot) .. " gets shown") end end
      if (traitKey == TRAIT_HAS_AVAILABLE_ENCHANTMENT) then
        indicatorControl:SetTexture(HAS_AVAILABLE_ENCHANTMENT)
        indicatorControl:SetColor(0, 1, 0, 1)
      elseif (traitKey == TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK) then
        indicatorControl:SetTexture(HAS_AVAILABLE_ENCHANTMENT_BANK)
        indicatorControl:SetColor(1, 0.8, 0, 1)
      elseif (traitKey == TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK) then
        indicatorControl:SetTexture(HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK)
        indicatorControl:SetColor(0, 0, 1, 1)
      else
        indicatorControl:SetTexture(IS_ENCHANTABLE_ITEM_TEXTURE)
        indicatorControl:SetColor(1, 0.5, 0.2, 1)
      end
      indicatorControl:SetHidden(false)
    else
      if (bag == BAG_WORN) then if (self:dbg(2)) then self:debug("Item " .. GetItemName(bag, slot) .. " gets hidden") end end
      indicatorControl:SetHidden(true)
    end

    local instance = GetItemInstanceId(bag, slot)
    -- we only see a small window of the guild bank- special treatment therefore
    if (bag == BAG_GUILDBANK and IsItemEnchantment(bag, slot)) then
      if (self.suitable_enchantments == nil or self.suitable_enchantments[instance] == nil) then
        self:EnchantmentRegistration(bag, slot, self.guild_bank_enchantments)
        self:UpdateEnchantmentForEq(bag, slot)
        self:UpdateEnchantmentForBag(BAG_BACKPACK, bag, slot)
      end
    end

    -- check for marking usable glyphs
    if (IsItemEnchantment(bag, slot) and self.suitable_enchantments and self.suitable_enchantments[instance] ~= nil) then
      if (self.suitable_enchantments[instance][BAG_WORN] ~= nil or self.suitable_enchantments[instance][BAG_BACKPACK] ~= nil) then
        if (self:dbg(3)) then self:debug("Show inventory " .. bag .. "," .. slot) end
        indicatorControl:SetTexture(IS_SUITABLE_ENCHANTMENT_TEXTURE)
        indicatorControl:SetColor(0, 1, 0, 1)
        indicatorControl:SetHidden(false)
      elseif (self.suitable_enchantments[instance][BAG_BANK] ~= nil and bag == BAG_BANK) then
        if (self:dbg(3)) then self:debug("Show bank " .. bag .. "," .. slot) end
        indicatorControl:SetTexture(IS_SUITABLE_ENCHANTMENT_TEXTURE)
        indicatorControl:SetColor(1, 0.8, 0, 1)
        indicatorControl:SetHidden(false)
      elseif (self.suitable_enchantments[instance][BAG_GUILDBANK] ~= nil and bag == BAG_GUILDBANK) then
        if (self:dbg(3)) then self:debug("Show guild bank " .. bag .. "," .. slot) end
        indicatorControl:SetTexture(IS_SUITABLE_ENCHANTMENT_TEXTURE)
        indicatorControl:SetColor(0, 0, 1, 1)
        indicatorControl:SetHidden(false)
      else
        if (self:dbg(3)) then self:debug("Hide " .. bag .. "," .. slot) end
        indicatorControl:SetHidden(true)
      end
    end
  else
    indicatorControl:SetHidden(true)
  end
  
  local pname = self.childname .. "potency"
  local potency_indicator = control:GetNamedChild(pname)
  if (control:GetWidth() >= QE_Settings.x_threshold and QuickEnchanter.savedVars.show_potency_level) then
    -- show level e.g. "1-10"
    local potency_level_information = self:getPotencyLevelInformation(id)
    if (potency_level_information ~= nil) then
      local potency_indicator = control:GetNamedChild(pname)
      if (not potency_indicator) then
        potency_indicator = self:CreateIndicatorControl(control, pname)
      end
      self:SetPosition(control, potency_indicator, (indicatorControl and indicatorControl:GetWidth() or 20) + 5)
      potency_indicator:SetTexture(potency_level_information[POTENCY_LEVEL_ICON])
      -- make it even taller
      local factor = 1.5
      potency_indicator:SetWidth(potency_indicator:GetWidth() * factor)
      potency_indicator:SetHeight(potency_indicator:GetHeight() * factor)
      potency_indicator:SetColor(1, 1, 1, 1)
      potency_indicator:SetHidden(false)
    elseif (potency_indicator ~= nil) then
      potency_indicator:SetHidden(true)
    end
  elseif (potency_indicator ~= nil) then
    potency_indicator:SetHidden(true)
  end
end

function QuickEnchanter:AddEnchantmentIndicatorToControl(control)
  local bagId = control.dataEntry.data.bagId
  local slotIndex = control.dataEntry.data.slotIndex
  self:AddEnchantmentIndicatorToSlot(control, bagId, slotIndex)
end

function QuickEnchanter:AddEnchantmentIndicators(control)
  for _, v in pairs(control.activeControls) do
    self:AddEnchantmentIndicatorToControl(v)
  end
end

function QuickEnchanter:CheckNow(control)
  if (not control.isGrid and not control:IsHidden()) then
    self:AddEnchantmentIndicators(control)
  end
end

local function min(x,y)
  return x < y and x or y
end

-- fix the positions to the parent window
function QuickEnchanter:SetPosition(parent, control, x_offset)
  local xdim = min(QuickEnchanter.savedVars.line_height, parent:GetWidth())
  local ydim = min(QuickEnchanter.savedVars.line_height, parent:GetWidth())

  -- make it even smaller
  if (parent:GetWidth() < QE_Settings.x_threshold) then
    xdim = min(QE_Settings.xdim, xdim)
    ydim = min(QE_Settings.ydim, ydim)
  end
  
  control:SetDimensions(xdim, ydim)

  local x = min(self.savedVars.indicator_x_position, parent:GetWidth())
  local y = min(QE_Settings.y_offset_mark, parent:GetHeight())

  local anchor = CENTER
  -- we have a small icon here
  if (x < QE_Settings.x_threshold) then -- adapt here, if it doesn't work with InventoryGridView
    anchor = TOPRIGHT
    x = 0
  end

  control:ClearAnchors()
  control:SetAnchor(anchor, parent, anchor, x + (x_offset or 0), y)
end

function QuickEnchanter:CreateIndicatorControl(parent, name)
  local control = wm:CreateControl(parent:GetName() .. name, parent, CT_TEXTURE)
  control:SetDrawLayer(parent:GetDrawLayer()+1)
  self:SetPosition(parent, control)
  control:SetAlpha(0.3)
  control:SetHidden(true)

  return control
end

local bufferTime = 200 -- ms - TODO: make configurable
local elapsedTime = 0
local stopUpdateWait = 500 -- TODO: make configurable
local elapsedStopUpdateWait = 0
local shouldStopUpdate = false
local isScanning = false

function QuickEnchanter:AreAllHidden()
  return BANK and BANK:IsHidden() and BACKPACK and BACKPACK:IsHidden() and GUILD_BANK and GUILD_BANK:IsHidden()
end

function QuickEnchanter:ALPush()
  QuickEnchanterControl:SetHandler("OnUpdate", function (...) self:OnUpdate(...) end)
end

function QuickEnchanter:StoreOrBankOpen()
  QuickEnchanterControl:SetHandler("OnUpdate", function (...) self:OnUpdate(...) end)
  self.isStoreOrBankOpen = true
end

function QuickEnchanter:StoreOrBankClosed( ... )
  self.isStoreOrBankOpen = false
end

function QuickEnchanter:CheckItems()
  if (self.savedVars.enchantment_check) then
    self:UpdateEnchantments()
    self:CheckEQ()
  end
  self:CheckNow(BACKPACK)
  self:CheckNow(BANK)
  self:CheckNow(GUILD_BANK)
end

function QuickEnchanter:OnUpdate()
  elapsedTime = elapsedTime + GetFrameDeltaTimeMilliseconds()
  if (isScanning or elapsedTime < bufferTime) then return end
  elapsedTime = 0

  if (self:AreAllHidden() and not self.isStoreOrBankOpen) then
    shouldStopUpdate = true
    elapsedStopUpdateWait = elapsedStopUpdateWait + GetFrameDeltaTimeMilliseconds()
    if(elapsedStopUpdateWait >= stopUpdateWait) then
      QuickEnchanterControl:SetHandler("OnUpdate", nil)
      elapsedStopUpdateWait = 0
    end
    return
  end

  if(shouldStopUpdate) then
    shouldStopUpdate = false
    elapsedStopUpdateWait = 0
  end
  
  self:CheckItems()
end

-- ----------------------------------------------------------
-- Set inventory markers here
-- ----------------------------------------------------------

function QuickEnchanter:CheckSingleItem(bag, slot, ebag, eslot)
    
  if (ebag == BAG_GUILDBANK and bag == BAG_BACKPACK and self:dbg(3)) then self:debug("Check item "..GetItemName(bag, slot) .. " with " .. GetItemName(ebag, eslot)) end
  
  if (CanItemTakeEnchantment(bag, slot, ebag, eslot)) then
    if (self.savedVars.show_glyphs) then
      if (self.suitable_enchantments == nil) then self.suitable_enchantments = {} end
      local instance = GetItemInstanceId(ebag, eslot)
      if (self.suitable_enchantments[instance] == nil) then self.suitable_enchantments[instance] = {} end
      if (ebag == BAG_GUILDBANK) then if (self:dbg(2)) then self:debug("Mark item " .. GetItemName(ebag, eslot) .. " as used.") end end
      self.suitable_enchantments[instance][bag] = 1 -- this enchantment can be used
      if (self:dbg(2)) then self:debug("Return true for " .. GetItemName(bag, slot) .. " using " .. GetItemName(ebag, eslot)) end
    end
    return true
  end
  
  return false
end

function QuickEnchanter:findEnchantingItem(enchantment_bag, bag, slot)
  local r = nil

  local enchantment_list = nil
  if (enchantment_bag == BAG_BACKPACK) then enchantment_list = self.enchantments end
  if (enchantment_bag == BAG_BANK) then enchantment_list = self.bank_enchantments end
  if (enchantment_bag == BAG_GUILDBANK) then enchantment_list = self.guild_bank_enchantments end
  if (enchantment_list == nil) then return end

  for k,v in pairs(enchantment_list) do
    local ebag = v[2]
    local eslot = v[3]
    local tmp = self:CheckSingleItem(bag, slot, ebag, eslot)
    if (tmp) then
      r = true
    end
  end

  if (self:dbg(2)) then self:debug("Return " .. (r and  "true" or "false") .. " for " .. GetItemName(bag, slot) .. " enchantment in bag " .. enchantment_bag) end

  return r
end

function QuickEnchanter:CheckIsItemEnchantable(bag, slot, liste)
  if (IsItemEnchantable (bag, slot)) then
    if (bag == BAG_WORN) then if (self:dbg(2)) then self:debug("Item " .. GetItemName(bag, slot) .. " is enchantable.") end end
    local liste_inventory =  self:findEnchantingItem(BAG_BACKPACK, bag, slot)
    local liste_bank =       self:findEnchantingItem(BAG_BANK, bag, slot)
    local liste_guild_bank = self:findEnchantingItem(BAG_GUILDBANK, bag, slot)
    
    --return liste_inventory and TRAIT_HAS_AVAILABLE_ENCHANTMENT or (liste_bank and TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK or (liste_guild_bank and TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK or TRAIT_IS_ENCHANTABLE))
    if (liste_inventory == true) then
      if (self:dbg(2)) then self:debug(bag .. "," .. slot .. " " .. GetItemName(bag, slot) .. " has available enchantment.") end
      return TRAIT_HAS_AVAILABLE_ENCHANTMENT
    elseif (liste_bank == true) then
      if (self:dbg(2)) then self:debug(bag .. "," .. slot .. " " ..  GetItemName(bag, slot) .. " has available enchantment in bank.") end
      return TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK
    elseif (liste_guild_bank == true) then
      if (self:dbg(2)) then self:debug(bag .. "," .. slot .. " " ..  GetItemName(bag, slot) .. " has available enchantment in guild bank.") end
      return TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK
    else
      if (self:dbg(2)) then self:debug(bag .. "," .. slot .. " " ..  GetItemName(bag, slot) .. " is enchantable.") end
      return TRAIT_IS_ENCHANTABLE
    end
  end
 
  return nil
end

function QuickEnchanter:CheckEQ()
  for k,v in pairs(slots) do
    local parent = _G[v.control]
    local slot = _G[k]
    if (parent ~= nil) then 
      --if (parent.activeControls and #parent.activeControls > 0 and not parent.IsHidden()) then
      self:AddEnchantmentIndicatorToSlot(parent, 0, slot)
      --end
    end
  end
end

-- register a single enchantment item
function QuickEnchanter:EnchantmentRegistration(bag, s, enchantment_list)
  if (self:dbg(2)) then self:debug("EnchantmentRegistration check " .. bag .. "," .. s .. GetItemLink(bag, LINK_STYLE_BRACKET) .. " is an enchantment.") end
  if (IsItemEnchantment(bag, s)) then
    if (self:dbg(2)) then self:debug("Item " .. bag .. "," .. s .. GetItemLink(bag, LINK_STYLE_BRACKET) .. " is an enchantment.") end
    if (bag == BAG_GUILDBANK) then if (self:dbg(3)) then self:debug("register enchantment item " .. bag .. "," .. s .. " " .. GetItemName(bag, s)) end end
    -- create look-up table for glyphs that are getting used
    local instance = GetItemInstanceId(bag, s)
    if (instance ~= nil) then
      if (self.suitable_enchantments == nil) then self.suitable_enchantments = {} end
      if (self.suitable_enchantments[instance] == nil) then self.suitable_enchantments[instance] = {} end
      local name = self:NormalizeName(GetItemLink(bag, s, LINK_STYLE_BRACKET))
      
      if name ~= nil then
          if (enchantment_list == nil) then enchantment_list = {} end
        enchantment_list[instance] = { name, bag, s }
      else
        if (self:dbg(2)) then self:debug("Couldn't register enchantment, because of missing name:" .. bag .. "," .. s) end
      end
    else
      if (self:dbg(2)) then self:debug("Couldn't register enchantment (missing instance):" .. bag .. "," .. s) end
    end
  end
end

-- collect all available enchantments
function QuickEnchanter:UpdateEnchantmentsPerBag(bag, enchantment_list)
  if (self:dbg(2)) then self:debug("Update enchantments for bag " .. bag) end
  local slots = GetBagSize(bag)
  if (slots ~= nil) then
    for s = 0, slots do
      self:EnchantmentRegistration(bag, s, enchantment_list)
    end
  end
end

-- create a list of enchantments
function QuickEnchanter:UpdateEnchantments()
  self.enchantments = {}
  self:UpdateEnchantmentsPerBag(BAG_BACKPACK, self.enchantments)
  self.bank_enchantments = {}
  self:UpdateEnchantmentsPerBag(BAG_BANK, self.bank_enchantments)
  -- Guild Bank is separately managed
end

-------------------------------
-- Register add-on
-------------------------------
EVENT_MANAGER:RegisterForEvent(QuickEnchanter.name, EVENT_ADD_ON_LOADED , function (...)  QuickEnchanter:InitializeItems(...) end)