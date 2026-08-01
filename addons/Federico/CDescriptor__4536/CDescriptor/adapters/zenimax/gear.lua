-- Item quality, armor type, and weapon type enums are mapped to readable strings
-- here (adapter layer) since the ESO global constants are only available at runtime.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local GetEquippedItemInfo       = GetEquippedItemInfo
local GetItemLink               = GetItemLink
local GetItemLinkName           = GetItemLinkName
local GetItemLinkDisplayQuality = GetItemLinkDisplayQuality
local GetItemLinkTraitInfo      = GetItemLinkTraitInfo
local GetItemLinkEnchantInfo    = GetItemLinkEnchantInfo
local GetItemLinkSetInfo        = GetItemLinkSetInfo
local GetItemLinkArmorType      = GetItemLinkArmorType
local GetItemLinkWeaponType     = GetItemLinkWeaponType

local M = {}

-- Populated lazily after ESO globals are available
local QUALITY_NAMES
local ARMOR_TYPE_NAMES
local WEAPON_TYPE_NAMES

local function init_maps()
  if QUALITY_NAMES then return end
  QUALITY_NAMES = {
    [ITEM_DISPLAY_QUALITY_TRASH]          = "trash",
    [ITEM_DISPLAY_QUALITY_NORMAL]         = "white",
    [ITEM_DISPLAY_QUALITY_ARCANE]         = "green",
    [ITEM_DISPLAY_QUALITY_MAGIC]          = "blue",
    [ITEM_DISPLAY_QUALITY_ARTIFACT]       = "purple",
    [ITEM_DISPLAY_QUALITY_LEGENDARY]      = "gold",
    [ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE]= "mythic",
  }
  ARMOR_TYPE_NAMES = {
    [ARMORTYPE_NONE]   = nil,
    [ARMORTYPE_LIGHT]  = "Light",
    [ARMORTYPE_MEDIUM] = "Medium",
    [ARMORTYPE_HEAVY]  = "Heavy",
  }
  WEAPON_TYPE_NAMES = {
    [WEAPONTYPE_NONE]              = nil,
    [WEAPONTYPE_SWORD]             = "Sword",
    [WEAPONTYPE_AXE]               = "Axe",
    [WEAPONTYPE_HAMMER]            = "Hammer",
    [WEAPONTYPE_DAGGER]            = "Dagger",
    [WEAPONTYPE_TWO_HANDED_SWORD]  = "Two-Handed Sword",
    [WEAPONTYPE_TWO_HANDED_AXE]    = "Two-Handed Axe",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Two-Handed Hammer",
    [WEAPONTYPE_BOW]               = "Bow",
    [WEAPONTYPE_HEALING_STAFF]     = "Restoration Staff",
    [WEAPONTYPE_FIRE_STAFF]        = "Inferno Staff",
    [WEAPONTYPE_FROST_STAFF]       = "Ice Staff",
    [WEAPONTYPE_LIGHTNING_STAFF]   = "Lightning Staff",
    [WEAPONTYPE_SHIELD]            = "Shield",
    [WEAPONTYPE_RUNE]              = "Rune",
  }
end

local function get_item_data(equip_slot)
  local _, has_item = GetEquippedItemInfo(equip_slot)
  if not has_item then return nil end

  local link = GetItemLink(BAG_WORN, equip_slot, LINK_STYLE_BRACKETS)
  if not link or link == "" then return nil end

  init_maps()

  local name          = GetItemLinkName(link)
  local quality_enum  = GetItemLinkDisplayQuality(link)
  local trait_type, trait_desc = GetItemLinkTraitInfo(link)
  local _, enchant_name, enchant_desc = GetItemLinkEnchantInfo(link)
  local has_set, set_name   = GetItemLinkSetInfo(link, true)
  local armor_type    = GetItemLinkArmorType(link)
  local weapon_type   = GetItemLinkWeaponType(link)

  return {
    name         = name,
    quality      = QUALITY_NAMES[quality_enum] or tostring(quality_enum),
    trait        = trait_desc or "",
    enchant      = enchant_name or "",
    enchant_desc = enchant_desc or "",
    set_name     = has_set and set_name or nil,
    armor_type   = ARMOR_TYPE_NAMES[armor_type],
    weapon_type  = WEAPON_TYPE_NAMES[weapon_type],
  }
end

function M.get_equipped()
  return {
    bar_1_weapon = get_item_data(EQUIP_SLOT_MAIN_HAND),
    bar_1_offhand = get_item_data(EQUIP_SLOT_OFF_HAND),
    bar_2_weapon  = get_item_data(EQUIP_SLOT_BACKUP_MAIN),
    bar_2_offhand = get_item_data(EQUIP_SLOT_BACKUP_OFF),
    head          = get_item_data(EQUIP_SLOT_HEAD),
    shoulder      = get_item_data(EQUIP_SLOT_SHOULDERS),
    chest         = get_item_data(EQUIP_SLOT_CHEST),
    gloves        = get_item_data(EQUIP_SLOT_HAND),
    waist         = get_item_data(EQUIP_SLOT_WAIST),
    legs          = get_item_data(EQUIP_SLOT_LEGS),
    boots         = get_item_data(EQUIP_SLOT_FEET),
    neck          = get_item_data(EQUIP_SLOT_NECK),
    ring_1        = get_item_data(EQUIP_SLOT_RING1),
    ring_2        = get_item_data(EQUIP_SLOT_RING2),
  }
end

CDescriptor.Adapters.Gear = M
