WishList = WishList or {}
local WL = WishList

WL.checkItemTypes = {
    [ITEMTYPE_WEAPON] = true,
	[ITEMTYPE_ARMOR]  = true,
}

WL.ItemTypes = {
	[ITEMTYPE_WEAPON] = GetString(SI_EQUIPSLOTVISUALCATEGORY1), --Weapon
	[ITEMTYPE_ARMOR]  = GetString(SI_EQUIPSLOTVISUALCATEGORY2), --Armor
}
WL.ItemTypeTextures = {
	[ITEMTYPE_WEAPON] = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds", --Weapon
	[ITEMTYPE_ARMOR]  = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds", --Armor
}

WL.ArmorTypes = {
	[0] = GetString(SI_EQUIPSLOTVISUALCATEGORY3), --Accessory
	[1] = GetString(SI_ARMORTYPE1), --Light
	[2] = GetString(SI_ARMORTYPE2), --Medium
	[3] = GetString(SI_ARMORTYPE3), --Heavy
}
WL.ArmorTypeTextures = {
	[0] = "WishList/assets/apparel/clothing_up.dds", 				--Accessory
	[1] = "esoui/art/icons/progression_tabicon_armorlight_up.dds", 	--Light
	[2] = "esoui/art/icons/progression_tabicon_armormedium_up.dds", --Medium
	[3] = "esoui/art/icons/progression_tabicon_armorheavy_up.dds", 	--Heavy
}

WL.WeaponTypes = {
	--TODO: Is translated with "Do not translate" ??? -> Change to fixed text "None"  instead?
	[0] = GetString(SI_WEAPONTYPE0), --None
	[1] = GetString(SI_WEAPONTYPE1), --Axe
	[2] = GetString(SI_WEAPONTYPE2), --Hammer
	[3] = GetString(SI_WEAPONTYPE3), --Sword
	[4] = "2hd " .. GetString(SI_WEAPONTYPE4), --2h Sword
	[5] = "2hd " .. GetString(SI_WEAPONTYPE5), --2h Axe
	[6] = "2hd " .. GetString(SI_WEAPONTYPE6), --2h Hammer
	--TODO: Is translated with "Do not translate" ??? -> Change to fixed text "Prop"  instead?
	[7] = GetString(SI_WEAPONTYPE7), --Prop  ???
	[8] = GetString(SI_WEAPONTYPE8), --Bow
	[9] = GetString(SI_WEAPONTYPE9), --Restoration Staff
	[10] = GetString(SI_WEAPONTYPE10), --Rune
	[11] = GetString(SI_WEAPONTYPE11), --Dagger
	[12] = GetString(SI_WEAPONTYPE12), --Fire Staff
	[13] = GetString(SI_WEAPONTYPE13), --Frost Staff
	[14] = GetString(SI_WEAPONTYPE14), --Shield
	[15] = GetString(SI_WEAPONTYPE15), --Lightning Staff
}
WL.WeaponTypeTextures = {
	[0] = "", --None
	[1] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Axe_up.dds", --Axe
	[2] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Mace_up.dds", --Hammer
	[3] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Sword_up.dds", --Sword
	[4] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_2h_Sword_up.dds", --2h Sword
	[5] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_2h_Axe_up.dds", --2h Axe
	[6] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_2h_Mace_up.dds", --2h Hammer
	--TODO: Is translated with "Do not translate" ??? -> Change to fixed text "Prop"  instead?
	[7] = "", --Prop  ???
	[8] = "WishList/assets/weapons/bow_up.dds", --Bow
	[9] = "WishList/assets/weapons/healing_up.dds", --Restoration Staff
	[10] = "esoui/art/icons/rune_a.dds", --Rune
	[11] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Dagger_up.dds", --Dagger
	[12] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Flame_up.dds", --Fire Staff
	[13] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Frost_up.dds", --Frost Staff
	[14] = "WishList/assets/weapons/shiedl_up.dds", --Shield
	[15] = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Lightning_up.dds", --Lightning Staff
}

WL.TraitTypes = {
	[ITEM_TRAIT_TYPE_NONE] = GetString(SI_ITEMTRAITTYPE0), --None
    [ITEM_TRAIT_TYPE_WEAPON_POWERED] = GetString(SI_ITEMTRAITTYPE1), --Powered
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = GetString(SI_ITEMTRAITTYPE2), --Charged
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = GetString(SI_ITEMTRAITTYPE3), --Precise
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = GetString(SI_ITEMTRAITTYPE4), --Infused
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = GetString(SI_ITEMTRAITTYPE5), --Defending
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = GetString(SI_ITEMTRAITTYPE6), --Training
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = GetString(SI_ITEMTRAITTYPE7), --Sharpened
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = GetString(SI_ITEMTRAITTYPE8), --Decisive
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = GetString(SI_ITEMTRAITTYPE9), --Intricate weapon
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE] = GetString(SI_ITEMTRAITTYPE10), --Ornate weapon

    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = GetString(SI_ITEMTRAITTYPE11), --Sturdy
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = GetString(SI_ITEMTRAITTYPE12), --Impenetrable
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = GetString(SI_ITEMTRAITTYPE13), --Reinforced
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = GetString(SI_ITEMTRAITTYPE14), --Well-fitted
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = GetString(SI_ITEMTRAITTYPE15), --Training
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = GetString(SI_ITEMTRAITTYPE16), --Infused
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = GetString(SI_ITEMTRAITTYPE17), --Prosperous
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = GetString(SI_ITEMTRAITTYPE18), --Divines
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE] = GetString(SI_ITEMTRAITTYPE19), --Ornate armor
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = GetString(SI_ITEMTRAITTYPE20), --Intricate armor

	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = GetString(SI_ITEMTRAITTYPE21), --Healthy
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = GetString(SI_ITEMTRAITTYPE22), --Arcane
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = GetString(SI_ITEMTRAITTYPE23), --Robust
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = GetString(SI_ITEMTRAITTYPE24), --Ornate

	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = GetString(SI_ITEMTRAITTYPE25), --Nirnhoned armor
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = GetString(SI_ITEMTRAITTYPE26), --Nirnhoned weapon

	[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = GetString(SI_ITEMTRAITTYPE27), --Intricate jewelry
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = GetString(SI_ITEMTRAITTYPE28), --Swift
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = GetString(SI_ITEMTRAITTYPE29), --Harmony
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = GetString(SI_ITEMTRAITTYPE30), --Triune
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = GetString(SI_ITEMTRAITTYPE31), --Bloodthirsty
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = GetString(SI_ITEMTRAITTYPE32), --Protective
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = GetString(SI_ITEMTRAITTYPE33), --Infused
	--Entry for "Special traits"
	[WISHLIST_TRAIT_TYPE_SPECIAL] = GetString(WISHLIST_ITEMTRAITTYPE_SPECIAL), --the special traits entry
	[WISHLIST_TRAIT_TYPE_ALL] = GetString(WISHLIST_DIALOG_ADD_ANY_TRAIT) --Any/All traits of current chosen item
}

WL.traitTextures = {
    --belebend: esoui/art/icons/crafting_jewelry_base_garnet_r3.dds
    --Verstärkt: esoui/art/icons/crafting_enchantment_base_sardonyx_r2.dds
    --Armor
    [ITEM_TRAIT_TYPE_NONE]					= "",
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE]			= "esoui/art/inventory/inventory_trait_ornate_icon.dds",
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]		= "esoui/art/inventory/inventory_trait_intricate_icon.dds",
    [ITEM_TRAIT_TYPE_ARMOR_DIVINES]			= "esoui/art/icons/crafting_accessory_sp_names_001.dds",
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]	= "esoui/art/icons/crafting_jewelry_base_diamond_r3.dds",
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED]			= "esoui/art/icons/crafting_enchantment_baxe_bloodstone_r2.dds",
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]		= "EsoUI/art/icons/crafting_potent_nirncrux_dust.dds",
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]		= "esoui/art/icons/crafting_jewelry_base_garnet_r3.dds",
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= "esoui/art/icons/crafting_enchantment_base_sardonyx_r2.dds",
    [ITEM_TRAIT_TYPE_ARMOR_STURDY]			= "esoui/art/icons/crafting_runecrafter_plug_component_002.dds",
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING]		= "esoui/art/icons/crafting_jewelry_base_emerald_r2.dds",
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= "esoui/art/icons/crafting_accessory_sp_names_002.dds",
    --Jewelry
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]		= "esoui/art/inventory/inventory_trait_ornate_icon.dds",
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]		= "esoui/art/inventory/inventory_trait_intricate_icon.dds",
    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]		= "esoui/art/icons/jewelrycrafting_trait_refined_cobalt.dds",
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]		= "esoui/art/icons/jewelrycrafting_trait_refined_antimony.dds",
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]		= "esoui/art/icons/jewelrycrafting_trait_refined_zinc.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY]	= "esoui/art/icons/crafting_enchantment_baxe_bloodstone_r1.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY]		= "esoui/art/icons/crafting_metals_tin.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED]		= "esoui/art/icons/crafting_enchantment_base_jade_r1.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]	= "esoui/art/icons/crafting_runecrafter_armor_component_006.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT]			= "esoui/art/icons/crafting_outfitter_plug_component_002.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]		= "esoui/art/icons/jewelrycrafting_trait_refined_dawnprism.dds",
    --Weapons
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE]			= "esoui/art/inventory/inventory_trait_ornate_icon.dds",
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE]		= "esoui/art/inventory/inventory_trait_intricate_icon.dds",
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED]		= "esoui/art/icons/crafting_jewelry_base_amethyst_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]		= "esoui/art/icons/crafting_smith_potion__sp_names_003.dds",
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]		= "esoui/art/icons/crafting_jewelry_base_turquoise_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED]		= "esoui/art/icons/crafting_enchantment_base_jade_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]		= "esoui/art/icons/crafting_potent_nirncrux_dust.dds",
    [ITEM_TRAIT_TYPE_WEAPON_POWERED]		= "esoui/art/icons/crafting_runecrafter_potion_008.dds",
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]		= "esoui/art/icons/crafting_jewelry_base_ruby_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]		= "esoui/art/icons/crafting_enchantment_base_fire_opal_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= "esoui/art/icons/crafting_runecrafter_armor_component_004.dds",
	[WISHLIST_TRAIT_TYPE_SPECIAL]			= "esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds", --Special
	[WISHLIST_TRAIT_TYPE_ALL]				= "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds" --All traits!
}

WL.SlotTypes = {
	[0] = GetString(SI_COLLECTIBLECATEGORYTYPE0), --Invalid
	[1] = GetString(SI_EQUIPTYPE1), --Head
	[2] = GetString(SI_EQUIPTYPE2), --Neck
	[3] = GetString(SI_EQUIPTYPE3), --Chest
	[4] = GetString(SI_EQUIPTYPE4), --Shoulders
	[5] = GetString(SI_EQUIPTYPE5), --One hand
	[6] = GetString(SI_EQUIPTYPE6), --Two Hand
	[7] = GetString(SI_EQUIPTYPE7), --Off Hand
	[8] = GetString(SI_EQUIPTYPE8), --Waist
	[9] = GetString(SI_EQUIPTYPE9), --Legs
	[10] = GetString(SI_EQUIPTYPE10), --Feet
	[11] = GetString(SI_EQUIPTYPE11), --Costume
	[12] = GetString(SI_EQUIPTYPE12), --Ring
	[13] = GetString(SI_EQUIPTYPE13), --Hand
	[14] = GetString(SI_EQUIPTYPE14), --Main Hand
	[15] = GetString(SI_EQUIPTYPE15), --Poison
}
WL.SlotTextures = {
	[0] = "", --Invalid
	[1] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_HEAD), --Head
	[2] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_NECK), --Neck
	[3] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_CHEST), --Chest
	[4] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_SHOULDERS), --Shoulders
	[5] = "/esoui/art/icons/progression_tabicon_1handed_up.dds", --One hand
	[6] = "/esoui/art/icons/progression_tabicon_2handed_up.dds", --Two Hand
	[7] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_OFF_HAND), --Off Hand
	[8] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_WAIST), --Waist
	[9] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_LEGS), --Legs
	[10] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_FEET), --Feet
	[11] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_COSTUME), --Costume
	[12] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_RING1), --Ring
	[13] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_HAND), --Hand
	[14] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_MAIN_HAND), --Main Hand
	[15] = ZO_Character_GetEmptyEquipSlotTexture(EQUIP_SLOT_POISON), --Poison
}

WL.quality = {
	[WISHLIST_QUALITY_ALL]					= GetString(WISHLIST_ITEM_QUALITY_ALL), 					--Any quality
	[WISHLIST_QUALITY_TRASH] 				= GetString(SI_ITEMQUALITY0), 								--Trash
	[WISHLIST_QUALITY_NORMAL] 				= GetString(SI_ITEMQUALITY1), 								--Normal (white)
	[WISHLIST_QUALITY_MAGIC] 				= GetString(SI_ITEMQUALITY2), 								--Magic (green)
	[WISHLIST_QUALITY_ARCANE] 				= GetString(SI_ITEMQUALITY3), 								--Arcane (blue)
	[WISHLIST_QUALITY_ARTIFACT] 			= GetString(SI_ITEMQUALITY4), 								--Artifact (purple)
	[WISHLIST_QUALITY_LEGENDARY]			= GetString(SI_ITEMQUALITY5), 								--Legendary (golden)
	[WISHLIST_QUALITY_MAGIC_OR_ARCANE] 		= GetString(WISHLIST_ITEM_QUALITY_MAGIC_OR_ARCANE), 		--Magic or arcane
	[WISHLIST_QUALITY_ARCANE_OR_ARTIFACT]	= GetString(WISHLIST_ITEM_QUALITY_ARCANE_OR_ARTIFACT), 		--Arcane or artifact
	[WISHLIST_QUALITY_ARTIFACT_OR_LEGENDARY]= GetString(WISHLIST_ITEM_QUALITY_ARTIFACT_OR_LEGENDARY), 	--Artifact or legendary
	[WISHLIST_QUALITY_MAGIC_TO_LEGENDARY]	= GetString(WISHLIST_ITEM_QUALITY_MAGIC_TO_LEGENDARY), 		--Magic to legendary
	[WISHLIST_QUALITY_ARCANE_TO_LEGENDARY]	= GetString(WISHLIST_ITEM_QUALITY_ARCANE_TO_LEGENDARY), 	--Arcane to legendary
}

WL.addDialogButtonTextures = {
	--Vertical buttons at the left side of the dialog
	[WISHLIST_ADD_TYPE_WHOLE_SET]                           = "esoui/art/chatwindow/chat_addtab_%s.dds",
	[WISHLIST_ADD_TYPE_BY_ITEMTYPE]                         = "esoui/art/charactercreate/rotate_right_%s.dds",
	[WISHLIST_ADD_TYPE_BY_ITEMTYPE_AND_ARMOR_WEAPON_TYPE]   = "esoui/art/characterwindow/gearslot_quickslot.dds",
	--Horizontal buttons next to "slot"
	[WISHLIST_ADD_ONE_HANDED_WEAPONS] 						= "esoui/art/icons/progression_tabicon_1handed_%s.dds",
	[WISHLIST_ADD_TWO_HANDED_WEAPONS] 						= "esoui/art/icons/progression_tabicon_2handed_%s.dds",
	[WISHLIST_ADD_BODY_PARTS_ARMOR] 						= "esoui/art/crafting/smithing_tabicon_armorset_%s.dds",
	[WISHLIST_ADD_MONSTER_SET_PARTS_ARMOR] 					= "esoui/art/icons/gear_undauntedspider_head_a.dds",
}