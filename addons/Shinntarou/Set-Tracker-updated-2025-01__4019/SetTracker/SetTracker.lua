SetTrack = SetTrack or {}
local ST = SetTrack

ST.VersionMajor = 3
ST.VersionMinor = 2
ST.VersionBuild = 0
ST.VersionData = 0
ST.VersionInventory = 5
ST.Version = ST.VersionMajor .. "." .. ST.VersionMinor
if ST.VersionBuild then ST.Version = ST.Version .. "." .. ST.VersionBuild end

local LIBMW = LibMsgWin
local LAM = LibAddonMenu2

local ST_name = "SetTracker"
local ST_SaveDataName = "ST_SavedVariables"
local ST_regName = "SetTrack"
local ST_initialised = false
local bHoldingsDirty = true
local bGuildBankReady = false
local tBagHoldings = {}
local tSetHoldings = {}
local tGeodeHoldings = {}
local tUndKeyHoldings = {}
local tLinkHoldingsOthers = {}
local tLinkHoldingsCurrent = {}
local tLabelControls = {}
local currentCharId = ""
local currentCharST_Id = ""
local currentCharName = ""
local currentBankST_id = nil
local currentHouseST_id = nil
local currentWornST_id =  nil
local currentWornName = nil
local currentAcountName = ""
local stSaveData = nil
local stSaveLocal = nil
local stSaveGlobal = nil
local msgWin = nil
local msgWinCloseButton = nil
local slotUpdatePending = false
local isHouse = false

local BANK_ID = "BANK_ID"
local HOUSE_ID = "HOUSE_ID"
local BANK_NAME = GetString(SI_SETTRK_BANK_NAME)
local HOUSE_NAME = GetString(SI_SETTRK_HOUSE_NAME)

local WORN_SUFFIX = GetString(SI_SETTRK_WORN_SUFFIX)
local WORN_SUFFIX_ID = "-WORN"
local BAG_NAME_BACKPACK = GetString(SI_SETTRK_BAG_NAME_BACKPACK)
local BAG_NAME_BUYBACK = GetString(SI_SETTRK_BAG_NAME_BUYBACK)
local BAG_NAME_GUILDBANK = GetString(SI_SETTRK_BAG_NAME_GUILDBANK)
local BAG_NAME_VIRTUAL = GetString(SI_SETTRK_BAG_NAME_VIRTUAL)
local BAG_NAME_WORN = GetString(SI_SETTRK_BAG_NAME_WORN)
local ACROSS_ALL_ACOUNTS = "AcrossAllAcounts"

local INVENTORY_TYPE_NORMAL = 1
local INVENTORY_TYPE_DECON = 2
local INVENTORY_TYPE_TRADER = 3

local SETTRK_TT_ICON = "SETTRK_TT_ICON"
local SETTRK_TT_ICON_POP = "SETTRK_TT_ICON_POP"
local SETTRK_TT_ICON_IB = "SETTRK_TT_ICON_IB"

local TRACK_INDEX_CRAFTED = 100
local TRACK_INDEX_GEODE = 200
local TRACK_INDEX_INVALID = -1

local SLOT_UPDATE_DELAY = 2500
local SLOT_UPDATE_EQUIP_DELAY = 100

local tLabelText = {
	Track			= GetString(SI_SETTRK_LBL_TRACK),
	Forget			= GetString(SI_SETTRK_LBL_NOTRACK),
	ShowHold		= GetString(SI_SETTRK_LBL_SHOWHOLD),
	ShowCharBound	= GetString(SI_SETTRK_LBL_SHOWCHARBOUND),
	ShowFreeSpace	= GetString(SI_SETTRK_LBL_SHOWFREESPACE),
	EditNotes		= GetString(SI_SETTRK_LBL_EDIT_NOTES),
	ShowNotes		= GetString(SI_SETTRK_LBL_SHOW_NOTES),
	SubMenuName		= GetString(SI_SETTRK_LBL_SUBMENU),
	BlockSeparator	= "------------------",
}

local bagList = {}
--local bagListMax = nil

local ST_NO_TRAIT = 999

local traitColourIDs = {
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES]			= ITEM_TRAIT_TYPE_ARMOR_DIVINES,
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]	= ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED]			= ITEM_TRAIT_TYPE_ARMOR_INFUSED,
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE]		= ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]		= ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE]			= ITEM_TRAIT_TYPE_ARMOR_ORNATE,
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]		= ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
	[ITEM_TRAIT_TYPE_ARMOR_STURDY]			= ITEM_TRAIT_TYPE_ARMOR_STURDY,
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING]		= ITEM_TRAIT_TYPE_ARMOR_TRAINING,
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE]		= ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]		= ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE]		= ITEM_TRAIT_TYPE_JEWELRY_ORNATE,
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST]		= ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
	[ITEM_TRAIT_TYPE_NONE]					= ITEM_TRAIT_TYPE_SPECIAL_STAT,
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED]		= ITEM_TRAIT_TYPE_WEAPON_CHARGED,
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE]		= ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING]		= ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED]		= ITEM_TRAIT_TYPE_ARMOR_INFUSED,
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE]		= ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]		= ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE]			= ITEM_TRAIT_TYPE_ARMOR_ORNATE,
	[ITEM_TRAIT_TYPE_WEAPON_POWERED]		= ITEM_TRAIT_TYPE_WEAPON_POWERED,
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE]		= ITEM_TRAIT_TYPE_WEAPON_PRECISE,
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED]		= ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= ITEM_TRAIT_TYPE_ARMOR_TRAINING,
	[ST_NO_TRAIT] 							= ST_NO_TRAIT,
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] 	= ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] 		= ITEM_TRAIT_TYPE_JEWELRY_HARMONY ,
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] 		= ITEM_TRAIT_TYPE_ARMOR_INFUSED,
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] 	= ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] 		= ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] 		= ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
}

local traitNames = {
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES]			= GetString(SI_SETTRK_TRAIT_DIVINES),
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]	= GetString(SI_SETTRK_TRAIT_IMPEN),
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED]			= GetString(SI_SETTRK_TRAIT_INFUSED),
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE]		= GetString(SI_SETTRK_TRAIT_INTRICATE),
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]		= GetString(SI_SETTRK_TRAIT_NIRN),
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE]			= GetString(SI_SETTRK_TRAIT_ORNATE),
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]		= GetString(SI_SETTRK_TRAIT_PROSP),
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= GetString(SI_SETTRK_TRAIT_REINF),
	[ITEM_TRAIT_TYPE_ARMOR_STURDY]			= GetString(SI_SETTRK_TRAIT_STURDY),
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING]		= GetString(SI_SETTRK_TRAIT_TRAIN),
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= GetString(SI_SETTRK_TRAIT_FITTED),
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE]		= GetString(SI_SETTRK_TRAIT_ARCANE),
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]		= GetString(SI_SETTRK_TRAIT_HEALTHY),
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE]		= GetString(SI_SETTRK_TRAIT_ORNATE),
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST]		= GetString(SI_SETTRK_TRAIT_ROBUST),
	[ITEM_TRAIT_TYPE_NONE]					= GetString(SI_SETTRK_TRAIT_SPECIAL),
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED]		= GetString(SI_SETTRK_TRAIT_CHARGED),
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE]		= GetString(SI_SETTRK_TRAIT_DECISIVE),
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING]		= GetString(SI_SETTRK_TRAIT_DEFEND),
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED]		= GetString(SI_SETTRK_TRAIT_INFUSED),
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE]		= GetString(SI_SETTRK_TRAIT_INTRICATE),
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]		= GetString(SI_SETTRK_TRAIT_NIRN),
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE]			= GetString(SI_SETTRK_TRAIT_ORNATE),
	[ITEM_TRAIT_TYPE_WEAPON_POWERED]		= GetString(SI_SETTRK_TRAIT_POWERED),
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE]		= GetString(SI_SETTRK_TRAIT_PRECISE),
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED]		= GetString(SI_SETTRK_TRAIT_SHARP),
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= GetString(SI_SETTRK_TRAIT_TRAIN),
	[ST_NO_TRAIT] 							= GetString(SI_SETTRK_TRAIT_NONE),
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] 	= GetString(SI_SETTRK_TRAIT_BLOODTHIRSTY),
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] 		= GetString(SI_SETTRK_TRAIT_HARMONY),
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] 		= GetString(SI_SETTRK_TRAIT_INFUSED),
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] 	= GetString(SI_SETTRK_TRAIT_PROTECTIVE),
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] 		= GetString(SI_SETTRK_TRAIT_SWIFT),
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] 		= GetString(SI_SETTRK_TRAIT_TRIUNE),
}

local traitTextures = {
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES]			= "EsoUI/Art/Progression/progression_indexIcon_race_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]	= "EsoUI/Art/Guild/tabIcon_heraldry_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED]			= "EsoUI/Art/Progression/progression_tabIcon_combatSkills_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE]		= "EsoUI/Art/Progression/progression_indexIcon_guilds_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]		= "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE]			= "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]		= "EsoUI/Art/Progression/progression_indexIcon_world_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= "EsoUI/Art/Crafting/smithing_tabIcon_armorset_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_STURDY]			= "EsoUI/Art/Campaign/campaignBrowser_indexIcon_hardcore_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING]		= "EsoUI/Art/Guild/tabIcon_ranks_up.dds",
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= "EsoUI/Art/Campaign/campaign_tabIcon_summary_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE]		= "EsoUI/Art/Campaign/campaignBrowser_indexIcon_specialEvents_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]		= "EsoUI/Art/Crafting/provisioner_indexIcon_beer_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE]		= "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST]		= "EsoUI/Art/Repair/inventory_tabIcon_repair_up.dds",
	[ITEM_TRAIT_TYPE_NONE]					= "",
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED]		= "EsoUI/Art/Campaign/overview_indexIcon_bonus_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE]		= "EsoUI/Art/Inventory/inventory_tabicon_misc_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING]		= "EsoUI/Art/Guild/tabIcon_heraldry_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED]		= "EsoUI/Art/Progression/progression_tabIcon_combatskills_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE]		= "EsoUI/Art/Progression/progression_indexIcon_guilds_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]		= "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE]			= "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_POWERED]		= "EsoUI/Art/Crafting/smithing_tabIcon_weaponset_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE]		= "EsoUI/Art/Campaign/overview_indexIcon_scoring_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED]		= "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_up.dds",
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= "EsoUI/Art/Guild/tabIcon_ranks_up.dds",
	[ST_NO_TRAIT] 							= "",
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] 	= "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] 		= "EsoUI/Art/Inventory/inventory_tabicon_misc_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] 		= "EsoUI/Art/Progression/progression_tabIcon_combatSkills_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] 	= "EsoUI/Art/Crafting/smithing_tabIcon_armorset_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] 		= "EsoUI/Art/Campaign/campaignBrowser_indexIcon_hardcore_up.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] 		= "EsoUI/Art/Campaign/campaign_tabIcon_summary_up.dds",
}

local armourPieceTexturesHvy = {
	[EQUIP_TYPE_CHEST]						= "esoui/art/icons/gear_nord_heavy_chest_a.dds",
	[EQUIP_TYPE_FEET]						= "esoui/art/icons/gear_nord_heavy_feet_a.dds",
	[EQUIP_TYPE_HAND]						= "esoui/art/icons/gear_nord_heavy_hands_a.dds",
	[EQUIP_TYPE_HEAD]						= "esoui/art/icons/gear_nord_heavy_head_b.dds",
	[EQUIP_TYPE_LEGS]						= "esoui/art/icons/gear_nord_heavy_legs_a.dds",
	[EQUIP_TYPE_SHOULDERS]					= "esoui/art/icons/gear_nord_heavy_shoulders_a.dds",
	[EQUIP_TYPE_WAIST]						= "esoui/art/icons/gear_nord_heavy_waist_a.dds",
}

local armourPieceTexturesMed = {
	[EQUIP_TYPE_CHEST]						= "esoui/art/icons/gear_nord_medium_chest_a.dds",
	[EQUIP_TYPE_FEET]						= "esoui/art/icons/gear_nord_medium_feet_a.dds",
	[EQUIP_TYPE_HAND]						= "esoui/art/icons/gear_nord_medium_hands_a.dds",
	[EQUIP_TYPE_HEAD]						= "esoui/art/icons/gear_nord_medium_head_b.dds",
	[EQUIP_TYPE_LEGS]						= "esoui/art/icons/gear_nord_medium_legs_a.dds",
	[EQUIP_TYPE_SHOULDERS]					= "esoui/art/icons/gear_nord_medium_shoulders_a.dds",
	[EQUIP_TYPE_WAIST]						= "esoui/art/icons/gear_nord_medium_waist_a.dds",
}

local armourPieceTexturesLgt = {
	[EQUIP_TYPE_CHEST]						= "esoui/art/icons/gear_nord_light_robe_a.dds",
	[EQUIP_TYPE_FEET]						= "esoui/art/icons/gear_nord_light_feet_a.dds",
	[EQUIP_TYPE_HAND]						= "esoui/art/icons/gear_nord_light_hands_a.dds",
	[EQUIP_TYPE_HEAD]						= "esoui/art/icons/gear_nord_light_head_b.dds",
	[EQUIP_TYPE_LEGS]						= "esoui/art/icons/gear_nord_light_legs_a.dds",
	[EQUIP_TYPE_SHOULDERS]					= "esoui/art/icons/gear_nord_light_shoulders_a.dds",
	[EQUIP_TYPE_WAIST]						= "esoui/art/icons/gear_nord_light_waist_a.dds",
}

local jewelleryTextures = {
	[EQUIP_TYPE_NECK]						= "esoui/art/icons/gear_nord_neck_a.dds",
	[EQUIP_TYPE_RING]						= "esoui/art/icons/gear_nord_ring_a.dds",
}

local weaponTypeTextures = {	
	[WEAPONTYPE_AXE]						= "esoui/art/icons/gear_nord_1haxe_a.dds",
	[WEAPONTYPE_BOW]						= "esoui/art/icons/gear_nord_bow_a.dds",
	[WEAPONTYPE_DAGGER]						= "esoui/art/icons/gear_nord_dagger_a.dds",
	[WEAPONTYPE_FIRE_STAFF]					= "esoui/art/icons/gear_nord_staff_a.dds",
	[WEAPONTYPE_FROST_STAFF]				= "esoui/art/icons/gear_nord_staff_a.dds",
	[WEAPONTYPE_HAMMER]						= "esoui/art/icons/gear_nord_1hhammer_a.dds",
	[WEAPONTYPE_HEALING_STAFF]				= "esoui/art/icons/gear_nord_staff_a.dds",
	[WEAPONTYPE_LIGHTNING_STAFF]			= "esoui/art/icons/gear_nord_staff_a.dds",
	[WEAPONTYPE_SHIELD]						= "esoui/art/icons/gear_nord_shield_a.dds",
	[WEAPONTYPE_SWORD]						= "esoui/art/icons/gear_nord_1hsword_a.dds",
	[WEAPONTYPE_TWO_HANDED_AXE]				= "esoui/art/icons/gear_nord_2haxe_a.dds",
	[WEAPONTYPE_TWO_HANDED_HAMMER]			= "esoui/art/icons/gear_nord_2hhammer_a.dds",
	[WEAPONTYPE_TWO_HANDED_SWORD]			= "esoui/art/icons/gear_nord_2hsword_a.dds",
}

local armourPieceNamesHvy = {
	[EQUIP_TYPE_CHEST]						= GetString(SI_SETTRK_HVY_CHEST),
	[EQUIP_TYPE_FEET]						= GetString(SI_SETTRK_HVY_FEET),
	[EQUIP_TYPE_HAND]						= GetString(SI_SETTRK_HVY_HAND),
	[EQUIP_TYPE_HEAD]						= GetString(SI_SETTRK_HVY_HEAD),
	[EQUIP_TYPE_LEGS]						= GetString(SI_SETTRK_HVY_LEGS),
	[EQUIP_TYPE_SHOULDERS]					= GetString(SI_SETTRK_HVY_SHOULDERS),
	[EQUIP_TYPE_WAIST]						= GetString(SI_SETTRK_HVY_WAIST),
}

local armourPieceNamesMed = {
	[EQUIP_TYPE_CHEST]						= GetString(SI_SETTRK_MED_CHEST),
	[EQUIP_TYPE_FEET]						= GetString(SI_SETTRK_MED_FEET),
	[EQUIP_TYPE_HAND]						= GetString(SI_SETTRK_MED_HAND),
	[EQUIP_TYPE_HEAD]						= GetString(SI_SETTRK_MED_HEAD),
	[EQUIP_TYPE_LEGS]						= GetString(SI_SETTRK_MED_LEGS),
	[EQUIP_TYPE_SHOULDERS]					= GetString(SI_SETTRK_MED_SHOULDERS),
	[EQUIP_TYPE_WAIST]						= GetString(SI_SETTRK_MED_WAIST),
}

local armourPieceNamesLgt = {
	[EQUIP_TYPE_CHEST]						= GetString(SI_SETTRK_LGT_CHEST),
	[EQUIP_TYPE_FEET]						= GetString(SI_SETTRK_LGT_FEET),
	[EQUIP_TYPE_HAND]						= GetString(SI_SETTRK_LGT_HAND),
	[EQUIP_TYPE_HEAD]						= GetString(SI_SETTRK_LGT_HEAD),
	[EQUIP_TYPE_LEGS]						= GetString(SI_SETTRK_LGT_LEGS),
	[EQUIP_TYPE_SHOULDERS]					= GetString(SI_SETTRK_LGT_SHOULDERS),
	[EQUIP_TYPE_WAIST]						= GetString(SI_SETTRK_LGT_WAIST),
}

local weaponTypeNames = {	
	[WEAPONTYPE_AXE]						= GetString(SI_SETTRK_WEAP_AXE),
	[WEAPONTYPE_BOW]						= GetString(SI_SETTRK_WEAP_BOW),
	[WEAPONTYPE_DAGGER]						= GetString(SI_SETTRK_WEAP_DAGGER),
	[WEAPONTYPE_FIRE_STAFF]					= GetString(SI_SETTRK_WEAP_FIRE_STAFF),
	[WEAPONTYPE_FROST_STAFF]				= GetString(SI_SETTRK_WEAP_FROST_STAFF),
	[WEAPONTYPE_HAMMER]						= GetString(SI_SETTRK_WEAP_HAMMER),
	[WEAPONTYPE_HEALING_STAFF]				= GetString(SI_SETTRK_WEAP_HEAL_STAFF),
	[WEAPONTYPE_LIGHTNING_STAFF]			= GetString(SI_SETTRK_WEAP_LIGHT_STAFF),
	[WEAPONTYPE_NONE]						= GetString(SI_SETTRK_WEAP_NONE),
	[WEAPONTYPE_RUNE]						= GetString(SI_SETTRK_WEAP_RUNE),
	[WEAPONTYPE_SHIELD]						= GetString(SI_SETTRK_WEAP_SHIELD),
	[WEAPONTYPE_SWORD]						= GetString(SI_SETTRK_WEAP_SWORD),
	[WEAPONTYPE_TWO_HANDED_AXE]				= GetString(SI_SETTRK_WEAP_TWO_H_AXE),
	[WEAPONTYPE_TWO_HANDED_HAMMER]			= GetString(SI_SETTRK_WEAP_TWO_H_HAM),
	[WEAPONTYPE_TWO_HANDED_SWORD]			= GetString(SI_SETTRK_WEAP_TWO_H_SWORD),
}

-------------------------------------------------------------------------------------------------
--  Colours  --
-------------------------------------------------------------------------------------------------
local colourYellow 		= "FFFF00"
local colourLightYellow	= "7F7F00"
local colourRed 		= "FF0000"
local colourGreen 		= "00FF00"
local colourLightGreen	= "58A0D8"
local colourLightBrown	= "A0605A"
local colourBlue		= "0000FF"
local colourLightBlue	= "448FFF"
local colourMauve		= "8888FF"
local colourWhite 		= "FFFFFF"
local colourOffWhite 	= "A0A0A0"
local colourMagenta		= "FF00FF"
local colourCyan		= "00FFFF"
local colourLightCyan	= "00AAAA"
local colourNORMAL		= "FFFFFF"
local colourMAGIC		= "00FF00"
local colourARCANE		= colourLightBlue
local colourARTIFACT	= "A000FF"
local colourLEGENDARY	= "C0B000"

local ST_defaultsLocal = {
	LastLogin		= nil,
}

local maxTrackNum		= 4
local maxCustTrackNum	= 14
local ST_defaults = {
	DataVersion			= 0,
	InventoryVersion	= 0,
	LastUpdate			= nil,
	TrackedSets			= {},
	Inventories			= {},
	CharIdFromName		= {},
	CharNameFromId		= {},
	CharAccountFromId	= {},
	DebugLevel			= 0,
	HoldingWinAlpha		= 0,
	AcrossAccounts		= true,
	UseCustomMenu		= false,
	ShowHoldingsOnMain	= false,
	ShowNotesOnMain		= false,
	EnableItemBrow		= true,
	EnableListPrfx		= true,
	IconOffsetBackpack	= 100,
	CustomTextures		= false,
	HoldingsToChat		= false,
	UseLevelInHoldings	= false,
	UseLinkInHoldings	= false,
	TrackCrafted		= true,
	TrackGuildBanks		= false,
	TrackCharBound		= false,
	TrackFreeSpace		= false,
	LimitFreeAcc		= true,
	ForceESO_Plus		= false,
	ToolTipInfo			= true,
	ColourDefault		= colourWhite,
	ColourCrafted		= colourMauve,
	ColourHoldings		= colourLightBrown,
	TraitColours		= nil,
	TrackColours		= {
		[0]				= colourGreen,
		[1]				= colourMagenta,
		[2]				= colourCyan,
		[3]				= colourLightCyan,
		[4]				= colourLightGreen,
		[5]				= colourOffWhite,
		[6]				= colourOffWhite,
		[7] 			= colourOffWhite,
		[8]				= colourOffWhite,
		[9]				= colourOffWhite,
		[10]			= colourOffWhite,
		[11]			= colourOffWhite,
		[12]			= colourOffWhite,
		[13]			= colourOffWhite,
		[14]			= colourOffWhite,
	},
	TrackNames		= {
		[0]				= GetString(SI_SETTRK_MISC_SELLDEC),
		[1] 			= GetString(SI_SETTRK_MISC_COLLECT),
		[2] 			= "",
		[3] 			= "",
		[4] 			= "",
		[5] 			= "",
		[6] 			= "",
		[7] 			= "",
		[8] 			= "",
		[9] 			= "",
		[10]			= "",
		[11]			= "",
		[12]			= "",
		[13]			= "",
		[14]			= "",
	},
	TrackTextures = {
		[0]				= "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_up.dds",
		[1]				= "EsoUI/Art/WorldMap/map_ava_tabicon_foodfarm_up.dds",
		[2]				= "EsoUI/Art/WorldMap/map_ava_tabicon_keepsummary_up.dds",
		[3]				= "EsoUI/Art/WorldMap/map_ava_tabicon_oremine_up.dds",
		[4]				= "EsoUI/Art/WorldMap/map_ava_tabicon_resourcedefense_up.dds",
		[5]				= "EsoUI/Art/WorldMap/map_ava_tabicon_woodmill_up.dds",
		[6]				= "EsoUI/Art/WorldMap/map_indexicon_filters_up.dds",
		[7]				= "EsoUI/Art/WorldMap/map_indexicon_key_up.dds",
		[8]				= "EsoUI/Art/WorldMap/map_indexicon_locations_up.dds",
		[9]				= "EsoUI/Art/WorldMap/map_indexicon_quests_up.dds",
		[10]			= "EsoUI/Art/repair/inventory_tabicon_repair_up.dds",
		[11]			= "EsoUI/Art/quest/quest_untrack_up.ddsquest\quest_untrack_up.dds",
		[12]			= "EsoUI/Art/quest/quest_showonmap_up.dds",
		[13]			= "EsoUI/Art/quest/quest_assist_up.dds",
		[14]			= "EsoUI/Art/quest/quest_abandon_up.dds",
		[TRACK_INDEX_CRAFTED]			= "EsoUI/Art/quest/quest_showonmap_up.dds",
	},
}

local function isDebug(_Level)
	return (stSaveData.DebugLevel >= _Level)
end

local function dbg(_Level, _Msg)
	if isDebug(_Level) then d(_Msg) end
end

--Removes any nil elements from a table
local function cleanTable(tTable)

	local function getNextNilIndex(_tTable)
		for i=1, #_tTable, 1 do
			if not _tTable[i] then return i end
		end
		return nil
	end
	
	local index = getNextNilIndex(tTable)
	while index do
		table.remove(tTable, index)
		index = getNextNilIndex(tTable)
	end

end

local function cleanGuildInventory()

	for i=1, 5, 1 do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		
		stSaveData.Inventories[guildName] = nil
	end

end
	

local function convertRGBToHex(r, g, b)
	return string.format("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

local function convertHexToRGBA(colourString)
	local r=tonumber(string.sub(colourString, 1, 2), 16) or 255
	local g=tonumber(string.sub(colourString, 3, 4), 16) or 255
	local b=tonumber(string.sub(colourString, 5, 6), 16) or 255
	return r/255, g/255, b/255, 1
end

local function colourText(_Colour, _Text)

	if not _Colour then
		if _Text then
			return _Text
		else
			return "colourText - both nil"
		end
	end

	if not _Text then
		if _Colour then
			return _Colour .. " nil _Text"
		else
			return "colourText - both nil"
		end
	end

	return "|c" .. _Colour .. _Text .. "|r"

end

local function getQualityColour(_ItemQual)

	if _ItemQual == ITEM_QUALITY_ARCANE then
		return colourARCANE
	elseif _ItemQual == ITEM_QUALITY_ARTIFACT then
		return colourARTIFACT
	elseif _ItemQual == ITEM_QUALITY_LEGENDARY then
		return colourLEGENDARY
	elseif _ItemQual == ITEM_QUALITY_MAGIC then
		return colourMAGIC
	elseif _ItemQual == ITEM_QUALITY_NORMAL then
		return colourNORMAL
	elseif _ItemQual == ITEM_QUALITY_TRASH then
		return colourWhite
	end

end

local function getWindowSaveData(__win, _varName)

	local winName = __win:GetName()

	if not stSaveData.WindowData then stSaveData.WindowData = {} end
	if not stSaveData.WindowData[winName] then stSaveData.WindowData[winName] = {} end

	if _varName then
		return stSaveData.WindowData[winName][_varName]
	else
		return stSaveData.WindowData[winName]
	end

end

local function isIGV_Loaded()
--Support for InventoryGridView by Randactyl and ingeniousclown.

	if InventoryGridView then
		return true
	else
		return false
	end

end

local function isIGV_Active(bStartupCheck)
--Support for InventoryGridView by Randactyl and ingeniousclown.

	if not InventoryGridView then return false end

	local IGV = InventoryGridView
    local IGVId = IGV.currentIGVId
	return IGV.settings.IsGrid(IGVId)

end

local function checkHouse()

	local currentZoneHouseId = GetCurrentZoneHouseId()
	if (currentZoneHouseId ~= 0) then
		isHouse = true
	else
		isHouse = false
	end

end

local function isHouseStorage(__BagId)

	if(__BagId == BAG_HOUSE_BANK_ONE)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_TWO)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_THREE)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_FOUR)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_FIVE)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_SIX)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_SEVEN)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_EIGHT)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_NINE)then
		return true
	elseif(__BagId == BAG_HOUSE_BANK_TEN)then
		return true
	else
		return false
	end

end

function SetTrackerSaveWinPosAndSize(_win)

	local winData = getWindowSaveData(_win)

	winData.WinLeft = _win:GetLeft()
	winData.WinTop = _win:GetTop()
	winData.WinWidth = _win:GetWidth()
	winData.WinHeight = _win:GetHeight()

 end

local function setWinPosAndSize(_win, _bPositionOnly, _leftOffset, _topOffset, _width, _height)

	local winData = getWindowSaveData(_win)

 	local winLeft = winData.WinLeft
	local winTop = winData.WinTop
	local winWidth = winData.WinWidth
	local winHeight = winData.WinHeight

	if not winLeft then winLeft = 100 end
	if not winTop then winTop = 60 end
	if not winWidth then winWidth = 200 end
	if not winHeight then winHeight = 140 end

	if _leftOffset then winLeft = _leftOffset end
	if _topOffset then winTop = _topOffset end
	
	if _bPositionOnly then
		winWidth = _win:GetWidth()
		winHeight = _win:GetHeight()
	end

	if _width then winWidth = _width end
	if _height then winHeight = _height end

	_win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, winLeft, winTop)
	_win:SetDimensions(winWidth, winHeight)

	_win:SetMovable(true) 
	_win:SetMouseEnabled(true)

end

local function toggleWindow(_win)

	if _win then
		if _win:IsControlHidden() then
--			setWinPosAndSize(_win)
			_win:SetHidden(false)
		else
			_win:SetHidden(true)
		end
	end

end

local function getFormattedItemLink(_BagIdOrLink, _iSlotId)

	if _iSlotId then
		return zo_strformat("<<t:1>>", GetItemLink(_BagIdOrLink,_iSlotId))
	end

	return zo_strformat("<<t:1>>", _BagIdOrLink)

end

function ST.GetMaxTrackStates()

	if stSaveData.UseCustomMenu then 
		return maxCustTrackNum
	else
		return maxTrackNum
	end

end

local function getTrackType(_SetName)
	
	local iIndex = TRACK_INDEX_INVALID
	local sNotes = ""
	
	for setName, tData in pairs(stSaveData.TrackedSets) do
		if setName == _SetName then
			iIndex = tData.State
			sNotes = tData.Notes
			break
		end
	end

	if not iIndex then iIndex = TRACK_INDEX_INVALID end
	if not sNotes then sNotes = "" end
	
	return iIndex, sNotes

end

local function isJewellery(_equipType)

	if _equipType == EQUIP_TYPE_NECK then
		return true
	elseif _equipType == EQUIP_TYPE_RING then
		return true
	else
		return false
	end
	
end

local function getLinkInfo(_lLink)

	local sName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(_lLink))
	local sTexture = GetItemLinkInfo(_lLink)
	local bIsSetItem, sSetName, nNumBonuses, nNumEquipped, nMaxEquipped = GetItemLinkSetInfo(_lLink, false)
	local bIsCrafted = IsItemLinkCrafted(_lLink) 
	local iItemType = GetItemLinkItemType(_lLink)
	local iEquipType = GetItemLinkEquipType(_lLink)
	local iQual = GetItemLinkQuality(_lLink)
	local iLevel = GetItemLinkRequiredLevel(_lLink)
	local iCP = GetItemLinkRequiredChampionPoints(_lLink)
	local trackType = 0
	local sItemTypeName = nil
	local iSubType 	= 0
	local iSubTypeName 	= ""
	local itemCat = 0
	local itemCatTexture = ""
	local itemCatName = ""
	local itemCatLong = ""

	if iLevel == 50 then
		iLevel = "CP" .. iCP
	end
	
	if iItemType == ITEMTYPE_ARMOR then
		sItemTypeName = GetString(SI_SETTRK_NAME_ARMOUR)
		iSubType = GetItemLinkArmorType(_lLink)
		itemCat = iEquipType
		if isJewellery(iEquipType) then
			if iEquipType == EQUIP_TYPE_NECK then
				itemCatName = GetString(SI_SETTRK_EQUIP_NECK)
			elseif iEquipType == EQUIP_TYPE_RING then
				itemCatName = GetString(SI_SETTRK_EQUIP_RING)
			else
				itemCatName = "UNKNOWN"
			end
			itemCatLong = itemCatName
			itemCatTexture = jewelleryTextures[iEquipType]
		else
			if iSubType == ARMORTYPE_HEAVY then
				itemCatLong = armourPieceNamesHvy[iEquipType]
				itemCatTexture = armourPieceTexturesHvy[iEquipType]
			elseif iSubType == ARMORTYPE_MEDIUM then
				itemCatLong = armourPieceNamesMed[iEquipType]
				itemCatTexture = armourPieceTexturesMed[iEquipType]
			elseif iSubType == ARMORTYPE_LIGHT then
				itemCatLong = armourPieceNamesLgt[iEquipType]
				itemCatTexture = armourPieceTexturesLgt[iEquipType]
			else
				itemCatLong = "UNKNOWN"
				itemCatTexture = ""
			end	
		end
	elseif iItemType == ITEMTYPE_WEAPON then
		sItemTypeName = GetString(SI_SETTRK_NAME_WEAPON)
		iSubType = iEquipType
		itemCat = GetItemLinkWeaponType(_lLink)
		itemCatName = weaponTypeNames[itemCat]
		itemCatLong = itemCatName
		itemCatTexture = weaponTypeTextures[itemCat]
	end

	local traitType, traitDescription, traitSubtype, traitSubtypeName, traitSubtypeDescription = GetItemLinkTraitInfo(_lLink)

	local isGeode = (sName == "Uncracked Transmutation Geode" or sName == "Transmutation Geode")
	local isUndauntedKey = (sName == "Undaunted Key")
	
	local tItemInfo = {
		["LINK"]				= _lLink,
		["TEXTURE"]				= sTexture,
		["NAME"]				= sName,
		["QUALITY"]				= iQual,
		["LEVEL"]				= iLevel,
		["SETITEM"]				= bIsSetItem,
		["SETNAME"]				= zo_strformat(SI_TOOLTIP_ITEM_NAME, sSetName),
		["CRAFTED"]				= bIsCrafted,
		["ITEMTYPE"]			= sItemTypeName,
		["SUBTYPE"]				= iSubType,
		["EQUIPTYPE"]			= iEquipType,
		["EQUIPCAT"]			= itemCat,
		["EQUIPCATTEXTURE"]		= itemCatTexture,
		["EQUIPCATNAME"]		= itemCatName,
		["EQUIPCATLONG"]		= itemCatLong,
		["TRAIT"]				= traitType,
		["TRAITNAME"]			= traitNames[traitType],
		["TRAITDESC"]			= traitDescription,
		["TRAITSUBTYPE"]		= traitSubtype,
		["TRAITSUBTYPENAME"]	= traitSubtypeName,
		["TRAITSUBTYPEDESC"]	= traitSubtypeDescription,
		["ISGEODE"]				= isGeode,
		["ISUNDAUNTEDKEY"]		= isUndauntedKey,
	}

	return tItemInfo

-- Green, single ["LINK"] = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:132102|h|h",
-- Gold 4-25 ["LINK"] = "|H0:item:134618:124:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",

end

local function GetInfo(_BagIdOrLink, _iSlotId)

	local lLink = getFormattedItemLink(_BagIdOrLink, _iSlotId)

	return getLinkInfo(lLink)

end

local function getLinkHoldings(_Link)

	local sTemp = nil
	local sTemp2 = nil
	local sReturn = ""
	
	if tLinkHoldingsCurrent[_Link] then
		for sBagName, nQty in pairs(tLinkHoldingsCurrent[_Link]) do
			local sHold = sBagName .. "(" .. nQty .. ")"
			if sTemp then
				sTemp = sTemp .. ", " .. sHold
			else
				sTemp = sHold
			end
		end
	end

	if tLinkHoldingsOthers[_Link] then
		for sBagName, nQty in pairs(tLinkHoldingsOthers[_Link]) do
			local sHold = sBagName .. "(" .. nQty .. ")"
			if sTemp2 then
				sTemp2 = sTemp2 .. ", " .. sHold
			else
				sTemp2 = sHold
			end
		end
	end

	if sTemp then
		if sTemp2 then
			sReturn = sTemp .. ", " .. sTemp2
		else
			sReturn = sTemp
		end
	else
		if sTemp2 then
			sReturn = sTemp2
		end
	end

	return sReturn
	
end

local function getTrackStateInfo(_trackIndex)

	local sColour = stSaveData.ColourDefault
	local sTrackName = ""
	local sTrackTexture = ""

	if _trackIndex == TRACK_INDEX_CRAFTED then
		sColour = stSaveData.ColourCrafted
		sTrackName = GetString(SI_SETTRK_NAME_CRAFTED)
		if stSaveData.CustomTextures then
			sTrackTexture = stSaveData.TrackTextures[TRACK_INDEX_CRAFTED]
		else
			sTrackTexture = ST_defaults.TrackTextures[TRACK_INDEX_CRAFTED]
		end
	else
		sColour = stSaveData.TrackColours[_trackIndex]
		sTrackName = stSaveData.TrackNames[_trackIndex]
		if stSaveData.CustomTextures then
			sTrackTexture = stSaveData.TrackTextures[_trackIndex]
		else
			sTrackTexture = ST_defaults.TrackTextures[0]
		end
		if not sTrackName or sTrackName == "" then sTrackName = GetString(SI_SETTRK_PREFIX_TRACKSTATE) .. _trackIndex end
	end

	if not sTrackTexture then sTrackTexture = "" end

	return sColour, sTrackName, sTrackTexture

end

local function getTrackedInfo(__itemInfo)

	local sColour = stSaveData.ColourDefault
	local sTrackName = ""
	local sTrackTexture = ""
	local sTrackNotes = ""
	local iTrackIndex = TRACK_INDEX_INVALID

	if __itemInfo then
		if __itemInfo.SETITEM then
			local sSetName = __itemInfo.SETNAME
			iTrackIndex, sTrackNotes = getTrackType(sSetName)
			if __itemInfo["CRAFTED"] then
				iTrackIndex = TRACK_INDEX_CRAFTED
			end
		elseif __itemInfo.ISGEODE then
			iTrackIndex = TRACK_INDEX_GEODE
		end
	end

	if iTrackIndex ~= TRACK_INDEX_INVALID then
		if iTrackIndex == TRACK_INDEX_GEODE then
			sColour = getQualityColour(__itemInfo.QUALITY)
			sTrackName = __itemInfo.NAME
			sTrackTexture = ""
		else
			sColour, sTrackName, sTrackTexture = getTrackStateInfo(iTrackIndex)
		end
	end

	return sColour, sTrackName, sTrackTexture, iTrackIndex, sTrackNotes

end

function ST.GetTrackStateInfo(_trackIndex)
--Returns SetTracker data for the specified track index
--sTrackColour	- the user configured colour for the set ("RRGGBB")
--sTrackName	- the user configured tracking name for the set
--sTrackTexture	- the texture used for the track state icon
	return getTrackStateInfo(_trackIndex)
end

function ST.GetTrackingInfo(bagId, slotIndex)
--Returns SetTracker data for the specified bag item
--iTrackIndex	- track state index 0 - 14,  -1 means the set is not tracked and 100 means the set is crafted
--sTrackName	- the user configured tracking name for the set
--sTrackColour	- the user configured colour for the set ("RRGGBB")
--sTrackNotes	- the user notes saved for the set

	local tInfo = GetInfo(bagId, slotIndex)
	local sTrackColour, sTrackName, sTrackTexture, iTrackIndex, sTrackNotes = getTrackedInfo(tInfo)

	return iTrackIndex, sTrackName, sTrackColour, sTrackNotes

end

local function getSetNotes(_setName)
	local setNotes = nil
	if _setName and stSaveData.TrackedSets[_setName] then setNotes = stSaveData.TrackedSets[_setName].Notes end
	if not setNotes then setNotes = "" end
	return setNotes
end

local function hideSetNotes()
	SetTrackerNotesTT:SetHidden(true)
end

local function showSetNotes(__control, _itemInfo, _leftOffset)

	if _itemInfo then
		local setName = _itemInfo.SETNAME
		if setName then
			local setNotes = getSetNotes(setName)
			if setNotes and setNotes ~= "" then
				local sColour = getTrackedInfo(_itemInfo)
				local sTitle = colourText(sColour, setName)
				local winName = nil
				
				if __control then
					winName = "SetTrackerNotesTT"
				else
					winName = "SetTrackerNotesWin"
				end
				local winCtrl = _G[winName]
				local titleCtrl = _G[winName .. "_Title"]
				local notesCtrl = _G[winName .. "_Notes"]
				titleCtrl:SetText(sTitle)
				notesCtrl:SetText(setNotes)
				winCtrl:SetDrawTier(DT_HIGH)
				if __control then
					local leftOffset = 40
					if _leftOffset then leftOffset = _leftOffset end
					winCtrl:SetDimensions(300, 200)
					winCtrl:SetAnchor(TOPLEFT, __control, TOPLEFT, leftOffset, 4)
				else
					setWinPosAndSize(winCtrl, true)
				end
				winCtrl:SetHidden(false)
			end
		end
	end

end

local function onRowControlMouseExit(_control)
	hideSetNotes()
end

local function onRowControlMouseEnter(_control)
	showSetNotes(_control, _control.ItemInfo)
end

local function updateLabelControl(_label, _ItemInfo, _InvenType)

	local bShowIcon = false

	if _ItemInfo then
		if _ItemInfo.SETITEM then
			if _ItemInfo.CRAFTED then
				bShowIcon = stSaveData.TrackCrafted
			else
				bShowIcon = true
			end
		end
	end

	if bShowIcon then
		_label.ItemInfo = _ItemInfo
		_label.InventoryType = _InvenType
		local sColour, sTrackName, sTrackTexture = getTrackedInfo(_ItemInfo)
		if sTrackName == "" then
			_label:SetHidden(true)
		else
			local r, g, b, a = convertHexToRGBA(sColour)
			local leftOffset = stSaveData.IconOffsetBackpack
			local topOffset = 17
			--if isIGV_Loaded() then leftOffset = 95 end
			--if _InvenType == INVENTORY_TYPE_DECON then
				--leftOffset = 0
				--if isIGV_Loaded() then leftOffset = 0 end
			--elseif _InvenType == INVENTORY_TYPE_TRADER then
			if _InvenType == INVENTORY_TYPE_TRADER then
				--leftOffset = 40
				topOffset = 8
				--if isIGV_Loaded() then leftOffset = 40 end
			end
			
			_label:SetHandler("OnMouseEnter", function(self) onRowControlMouseEnter(self) end)
			_label:SetHandler("OnMouseExit", function(self) onRowControlMouseExit(self) end)
			_label:SetMouseEnabled(true)
			_label:SetDimensions(20, 20)
			_label:SetTexture(sTrackTexture)
			_label:SetColor(r, g, b, a)
			_label:SetDrawTier(DT_HIGH)

			if isIGV_Active() then
				_label:SetAnchor(TOPLEFT, _label:GetParent(), TOPLEFT, 20, 0)
			else
				_label:SetAnchor(TOPLEFT, _label:GetParent(), TOPLEFT, leftOffset, topOffset)
			end

			_label:SetHidden(false)
		end
	else
		_label.ItemInfo = nil
		_label.InventoryType = nil
		_label:SetHidden(true)
	end

end

local function updateAllLabelControls(_ItemInfo)

	for sName, cLabel in pairs(tLabelControls) do
		if cLabel.ItemInfo then
			if cLabel.ItemInfo.SETNAME == _ItemInfo.SETNAME then
				updateLabelControl(cLabel, cLabel.ItemInfo, cLabel.InventoryType)
			end
		end
	end

end

local function checkTrackedSet(_SetName)
	if not stSaveData.TrackedSets[_SetName] then stSaveData.TrackedSets[_SetName] = {} end
end

local function setLinkMarkState(_itemLink, nState, _ibag, _iindex)


	local tItemInfo = getLinkInfo(_itemLink)
	if tItemInfo["CRAFTED"] then return end

	if tItemInfo["SETITEM"] then
		local sSetName = tItemInfo["SETNAME"]
		checkTrackedSet(sSetName)

		--Save the current set tracker state to be able to find the current FCOIS marker icon
		local currentSetTrackerState = stSaveData.TrackedSets[sSetName].State

		stSaveData.TrackedSets[sSetName].State = nState

		--Update the marker icon for the tracked sets within FCOItemSaver
	    --and update the inventory afterwards so the updated marker icon will be shown/hidden
		if _ibag and _iindex and FCOIS and FCOIS.updateSetTrackerMarker then
			--Show or hide the marker icon=
			local doShow = (nState ~= -1 and nState ~= 100 and nState ~= nil)
	        doShow = doShow or false
			--FCOIS.updateSetTrackerMarker(bagId, slotIndex, currentSetTrackerState, doShow, doUpdateInv)
		    -->returns true if any item was marked/demarked
		    FCOIS.updateSetTrackerMarker(_ibag, _iindex, currentSetTrackerState, doShow, true)
	    end

		stSaveData.LastUpdate = GetTimeStamp()
		updateAllLabelControls(tItemInfo)
	end

end  

local function doToggleLinkMarkState(_itemLink)

	local tItemInfo = getLinkInfo(_itemLink)
	if tItemInfo["CRAFTED"] then return end
	
	if tItemInfo["SETITEM"] then
		local sSetName = tItemInfo["SETNAME"]
		local iTrackIndex = getTrackType(sSetName)
		checkTrackedSet(sSetName)
		if iTrackIndex == ST.GetMaxTrackStates() then
			stSaveData.TrackedSets[sSetName].State = nil
		else
			stSaveData.TrackedSets[sSetName].State = iTrackIndex + 1
		end
		stSaveData.LastUpdate = GetTimeStamp()
		updateAllLabelControls(tItemInfo)
	end

end

local function saveFreeSlots()

	if (not stSaveData.FreeSlots) then stSaveData.FreeSlots = {} end
	if (not stSaveData.FreeSlots[currentAcountName]) then stSaveData.FreeSlots[currentAcountName] = {} end
	local holdingName = stSaveData.CharNameFromId[currentCharST_Id]
	if holdingName then
		stSaveData.FreeSlots[currentAcountName][holdingName] = GetNumBagFreeSlots(BAG_BACKPACK)
	end

end


local function getBagST_Id(_BagId)

	local bagST_Id = nil
	
	if(_BagId == BAG_BANK or _BagId == BAG_SUBSCRIBER_BANK)then
		bagST_Id = currentBankST_id
	elseif(isHouseStorage(_BagId))then
		bagST_Id = currentHouseST_id
	elseif(_BagId == BAG_BACKPACK)then
		bagST_Id = currentCharST_Id
	elseif(_BagId == BAG_WORN)then
		bagST_Id = currentWornST_id
	end

	return bagST_Id

end

local function getBagNameFromBagId(___BagId)

	local bagName = "UNKNOWNBAG"
	
	if(___BagId == BAG_BANK or ___BagId == BAG_SUBSCRIBER_BANK)then
		bagName = BANK_NAME
	elseif(isHouseStorage(_BagId))then
		bagName = HOUSE_NAME
	elseif(___BagId == BAG_BACKPACK)then
		bagName = BAG_NAME_BACKPACK
	elseif(___BagId == BAG_WORN)then
		bagName = BAG_NAME_WORN
	elseif(___BagId == BAG_BUYBACK)then
		bagName = BAG_NAME_BUYBACK
	elseif(___BagId == BAG_VIRTUAL)then
		bagName = BAG_NAME_VIRTUAL
	end

	return bagName
	
end

local function gatherOneLinkHolding(__tLinkHoldings, __sbagST_Id, _Link, _Qty)

	local tItemInfo = getLinkInfo(_Link)
	if not tItemInfo then d("bad link") return end
	local setName = tItemInfo["SETNAME"]
	local equipType = tItemInfo["EQUIPCATLONG"]

	if (setName and equipType) or tItemInfo["ISGEODE"] then
		local sBagName = stSaveData.CharNameFromId[__sbagST_Id]
		if not __tLinkHoldings[_Link] then __tLinkHoldings[_Link] = {} end
		__tLinkHoldings[_Link][sBagName] = _Qty
	else
		if setName then
			if isDebug(4) then d("nil equipType: " .. setName) end
		else
			if isDebug(4) then d("nil setName: " .. itemLink) end
		end
	end
	
end

local function clearBagHoldings()
	tBagHoldings = {}
end

local function getBagItem(__BagId, __SlotId)

	if tBagHoldings[__BagId] then
		if tBagHoldings[__BagId][__SlotId] then
			return tBagHoldings[__BagId][__SlotId]
		else
			return nil
		end
	else
		return nil
	end

end

local function putBagItem(__BagId, __SlotId, __ItemLink)

	if not tBagHoldings[__BagId] then tBagHoldings[__BagId] = {} end
	tBagHoldings[__BagId][__SlotId] = __ItemLink

end

local function removeBagItem(_BagST_Id, _BagId, _SlotId, _lLink, _IsSetItem)

	putBagItem(_BagId, _SlotId, nil)
	
	if tLinkHoldingsCurrent[_lLink] then
		local sBagName = stSaveData.CharNameFromId[_BagST_Id]
		if tLinkHoldingsCurrent[_lLink][sBagName] then
			if tLinkHoldingsCurrent[_lLink][sBagName] > 1 then
				tLinkHoldingsCurrent[_lLink][sBagName] = tLinkHoldingsCurrent[_lLink][sBagName] - 1
			else
				tLinkHoldingsCurrent[_lLink][sBagName] = nil
			end
		end
	end
	
	if _IsSetItem then
		if stSaveData.Inventories[_BagST_Id] then 
			if stSaveData.Inventories[_BagST_Id][_lLink] then 
				local nTemp = stSaveData.Inventories[_BagST_Id][_lLink]
				nTemp = nTemp - 1
				if nTemp == 0 then nTemp = nil end
				stSaveData.Inventories[_BagST_Id][_lLink] = nTemp
			end
		end
	end
	
end

local function evalSingleItem(__BagST_Id, __BagId, _tItemInfo, _Qty)

	if _tItemInfo then
		local itemLink = _tItemInfo.LINK
		if itemLink then
			if _tItemInfo["SETITEM"] or _tItemInfo["CRAFTED"] or _tItemInfo["ISGEODE"]  or _tItemInfo["ISUNDAUNTEDKEY"] then
				if not stSaveData.Inventories[__BagST_Id] then stSaveData.Inventories[__BagST_Id] = {} end
				local tLinks = stSaveData.Inventories[__BagST_Id]
				if not tLinks[itemLink] then tLinks[itemLink] = 0 end
				tLinks[itemLink] = tLinks[itemLink] + _Qty
				if __BagId ~= BAG_GUILDBANK then
					gatherOneLinkHolding(tLinkHoldingsCurrent, __BagST_Id, itemLink, tLinks[itemLink])
				end
			end
		end
	end

end

local function evalBagItem(__BagST_Id, __BagId, __SlotId)

	local tItemInfo = GetInfo(__BagId, __SlotId)
	if tItemInfo and tItemInfo.LINK and tItemInfo.LINK ~= "" then
		local stackSz, maxStack = GetSlotStackSize(__BagId, __SlotId)
		putBagItem(__BagId, __SlotId, tItemInfo.LINK)
		evalSingleItem(__BagST_Id, __BagId, tItemInfo, stackSz)
	end

end

local function gatherOneBag(_bagST_Id, _bagId)

	local nBagItems = GetBagSize and GetBagSize(_bagId)
	for slotNum=0, nBagItems, 1 do
		evalBagItem(_bagST_Id, _bagId, slotNum)
	end

end

local function gatherInventory()

	clearBagHoldings()
	if (isHouse) then
		stSaveData.Inventories[currentHouseST_id] = {}
	end
	
	for idx, bagId in ipairs(bagList) do
		local bagST_Id = getBagST_Id(bagId)
		if bagST_Id then
			if bagId ~= BAG_SUBSCRIBER_BANK and bagST_Id ~= currentHouseST_id then
				stSaveData.Inventories[bagST_Id] = {}
			end
			if (bagST_Id == currentHouseST_id) then
				if (isHouse) then
					gatherOneBag(bagST_Id, bagId)
				end
			else
				gatherOneBag(bagST_Id, bagId)
			end
		end
	end

	saveFreeSlots()

end

local function gatherSingleLinkHoldings(_tLinkHoldings, _tLinks, _sbagST_Id)

	for lLink, nQty in pairs(_tLinks) do
		gatherOneLinkHolding(_tLinkHoldings, _sbagST_Id, lLink, nQty)
	end

end

local function gatherLinkHoldingsOthers()

	tLinkHoldingsOthers = {}

	for bagST_Id, tLinks in pairs(stSaveData.Inventories) do
		if bagST_Id ~= currentCharST_Id and bagST_Id ~= currentWornST_id and bagST_Id ~= currentBankST_id and bagST_Id ~= currentHouseST_id then
			gatherSingleLinkHoldings(tLinkHoldingsOthers, tLinks, bagST_Id)
		end
	end

end

local function gatherSingleHoldings(_tInventory)

	local holdCol = stSaveData.ColourHoldings
	local tTemp = {}
	local tTempGeode = {}

	for bagST_Id, tLinks in pairs(_tInventory) do
		for lLink, nQty in pairs(tLinks) do
			local tItemInfo = getLinkInfo(lLink)
			local setName = tItemInfo["SETNAME"]
			local equipType = tItemInfo["EQUIPCATLONG"]
			local equipTexture = tItemInfo["EQUIPCATTEXTURE"]
			local traitId = tItemInfo["TRAIT"]
			local qualColour = getQualityColour(tItemInfo["QUALITY"])
			local holdingName = stSaveData.CharNameFromId[bagST_Id]
			local holdingAcc = stSaveData.CharAccountFromId[bagST_Id]
			local equipTypeText = equipType
			local equipLevel = "(" .. tItemInfo["LEVEL"] .. ")"

			if stSaveData.UseLinkInHoldings then
				equipTypeText = lLink
			else
				equipTypeText = colourText(qualColour, equipTypeText)
			end
			if stSaveData.UseLevelInHoldings then
				equipTypeText = equipTypeText .. colourText(holdCol, equipLevel)
			end

			if tItemInfo["ISGEODE"] then
				if not tTempGeode[lLink] then tTempGeode[lLink] = {} end
				if not tTempGeode[lLink][holdingAcc] then tTempGeode[lLink][holdingAcc] = {} end
				tTempGeode[lLink][holdingAcc][holdingName] = nQty
			elseif tItemInfo["ISUNDAUNTEDKEY"] then
				if (not tUndKeyHoldings[bagST_Id]) then tUndKeyHoldings[bagST_Id] = 0 end
				tUndKeyHoldings[bagST_Id] = tUndKeyHoldings[bagST_Id] + nQty
			elseif setName and equipType then
				if not traitId then
					traitId = ST_NO_TRAIT
				end
				if not tTemp[holdingName] then
					tTemp[holdingName] = {}
				end
				if not tTemp[holdingName][setName] then
					tTemp[holdingName][setName] = {}
				end
				if not tTemp[holdingName][setName][equipTypeText] then
					tTemp[holdingName][setName][equipTypeText] = {}
				end
				if not tTemp[holdingName][setName][equipTypeText][traitId] then
					tTemp[holdingName][setName][equipTypeText][traitId] = {}
					tTemp[holdingName][setName][equipTypeText][traitId].Qty = 0
					tTemp[holdingName][setName][equipTypeText][traitId].Texture = equipTexture
				end
				tTemp[holdingName][setName][equipTypeText][traitId].Qty = tTemp[holdingName][setName][equipTypeText][traitId].Qty + nQty
				tTemp[holdingName][setName][equipTypeText][traitId].Link = lLink
			else
				if setName then
					dbg(1, "nil equipType: " .. setName)
				else
					dbg(1, "nil setName: " .. itemLink)
				end
			end
		end
	end

	for bagName, tSets in pairs(tTemp) do
		for setName, tItems in pairs(tSets) do
			for itemText, tTraits in pairs(tItems) do
				for traitId, tEquip in pairs(tTraits) do
					local nQty = tEquip.Qty
					local sHolding = bagName .. "(" .. nQty .. ")"
					local sTexture = tEquip.Texture

					if not tSetHoldings[setName] then tSetHoldings[setName] = {} end
					if not tSetHoldings[setName][itemText] then tSetHoldings[setName][itemText] = {} end
					if not tSetHoldings[setName][itemText][traitId] then tSetHoldings[setName][itemText][traitId] = {} end

					if tSetHoldings[setName][itemText][traitId]["HOLDINGS"] then
						tSetHoldings[setName][itemText][traitId]["HOLDINGS"] = tSetHoldings[setName][itemText][traitId]["HOLDINGS"] .. ", " .. sHolding
						tSetHoldings[setName][itemText][traitId]["COUNT"] = tSetHoldings[setName][itemText][traitId]["COUNT"] + nQty
						tSetHoldings[setName][itemText][traitId]["LINK"] = tEquip.Link
					else
						tSetHoldings[setName][itemText][traitId]["HOLDINGS"] = sHolding
						tSetHoldings[setName][itemText][traitId]["COUNT"] = nQty
						tSetHoldings[setName][itemText][traitId]["TEXTURE"] = sTexture
						tSetHoldings[setName][itemText][traitId]["LINK"] = tEquip.Link
					end
				end
			end
		end
	end
	tTemp = {}

	for lLink, tAccounts in pairs(tTempGeode) do
		for accName, tHolders in pairs(tAccounts) do
			if accName == currentAcountName then
				tTemp = {}
				for holderName, nQty in pairs(tHolders) do
					local holderQty = holderName .. "(" .. nQty .. ")"
					table.insert(tTemp, holderQty)
				end
				table.sort(tTemp)
				for i, sHolding in ipairs(tTemp) do
					if not tGeodeHoldings[lLink] then
						tGeodeHoldings[lLink] = sHolding
					else
						tGeodeHoldings[lLink] = tGeodeHoldings[lLink] .. ", " .. sHolding
					end
				end
				
			end
		end
	end
	tTempGeode = {}

end

local function saveItemData(bag, index)
	local tItemInfo = GetInfo(bag, index)
	if not (stSaveLocal.SavedItemData) then
		stSaveLocal.SavedItemData = {}
	end
	table.insert(stSaveLocal.SavedItemData, tItemInfo)
	d("Item data saved")
	return 	
end  

local function gatherAllHoldings()

	if bHoldingsDirty then
		tSetHoldings = {}
		tGeodeHoldings = {}
		tUndKeyHoldings = {}

--		ST_ProcessCurrentData()
		gatherSingleHoldings(stSaveData.Inventories)

		bHoldingsDirty = false
	else
		dbg(2, "Holdings clean - no rebuild needed")
	end
	
end

local function sendHoldingsMsg(_Msg)
	if stSaveData.HoldingsToChat then
		d(_Msg)
	else
		msgWin:AddText(_Msg)
	end
end

local function compareSetHoldings(a, b)

	local itemType = {
		["ITEM_TYPE_WEAPON"]		= 1,
		["ITEM_TYPE_ARMOR"]			= 2,
		["ITEM_TYPE_JEWELRY"]		= 3,
		["ITEM_TYPE_UNKNOWN"]		= 99,
	}

	local itemPieceWeapon = {
		["ITEM_PIECE_AXE"]			= 1,
		["ITEM_PIECE_MACE"]			= 2,
		["ITEM_PIECE_SWORD"]		= 3,
		["ITEM_PIECE_BATTLEAXE"]	= 4,
		["ITEM_PIECE_MAUL"]			= 5,
		["ITEM_PIECE_GREATSWORD"]	= 6,
		["ITEM_PIECE_DAGGER"]		= 7,
		["ITEM_PIECE_SHIELD"]		= 8,
		["ITEM_PIECE_BOW"]			= 9,
		["ITEM_PIECE_INFERNO"]		= 10,
		["ITEM_PIECE_ICE"]			= 11,
		["ITEM_PIECE_LIGHTNING"]	= 12,
		["ITEM_PIECE_RESTO"]		= 13,
		["ITEM_PIECE_UNKNOWN"]		= 99,
	}

	local itemPieceArmor = {
		["ITEM_PIECE_HEAD"]			= 1,
		["ITEM_PIECE_SHOULDERS"]	= 2,
		["ITEM_PIECE_CHEST"]		= 3,
		["ITEM_PIECE_LEGS"]			= 4,
		["ITEM_PIECE_HANDS"]		= 5,
		["ITEM_PIECE_WAIST"]		= 6,
		["ITEM_PIECE_FEET"]			= 7,
		["ITEM_PIECE_UNKNOWN"]		= 99,
	}

	local itemPieceJewelry = {
		["ITEM_PIECE_NECK"]			= 1,
		["ITEM_PIECE_RING"]			= 2,
		["ITEM_PIECE_UNKNOWN"]		= 99,
	}

	local itemArmorWeight = {
		["ITEM_WEIGHT_LIGHT"]		= 1,
		["ITEM_WEIGHT_MEDIUM"]		= 2,
		["ITEM_WEIGHT_HEAVY"]		= 3,
		["ITEM_WEIGHT_UNKNOWN"]		= 99,
	}

	local function getItemType(item)
		if		item["EQUIPTYPE"] == EQUIP_TYPE_ONE_HAND or
				item["EQUIPTYPE"] == EQUIP_TYPE_TWO_HAND or
				item["EQUIPTYPE"] == EQUIP_TYPE_OFF_HAND then
					return itemType["ITEM_TYPE_WEAPON"]
		elseif	item["EQUIPTYPE"] == EQUIP_TYPE_CHEST or 
				item["EQUIPTYPE"] == EQUIP_TYPE_FEET or 
				item["EQUIPTYPE"] == EQUIP_TYPE_HAND or 
				item["EQUIPTYPE"] == EQUIP_TYPE_HEAD or 
				item["EQUIPTYPE"] == EQUIP_TYPE_LEGS or 
				item["EQUIPTYPE"] == EQUIP_TYPE_SHOULDERS or 
				item["EQUIPTYPE"] == EQUIP_TYPE_WAIST then
					return itemType["ITEM_TYPE_ARMOR"]
		elseif	item["EQUIPTYPE"] == EQUIP_TYPE_NECK or
				item["EQUIPTYPE"] == EQUIP_TYPE_RING then
					return itemType["ITEM_TYPE_JEWELRY"]
		else
					return itemType["ITEM_TYPE_UNKNOWN"]
		end
	end

	local function getItemPieceWeapon(item)
		if item["EQUIPCAT"] == WEAPONTYPE_AXE then
			return itemPieceWeapon["ITEM_PIECE_AXE"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_HAMMER then
			return itemPieceWeapon["ITEM_PIECE_MACE"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_SWORD then
			return itemPieceWeapon["ITEM_PIECE_SWORD"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_TWO_HANDED_AXE then
			return itemPieceWeapon["ITEM_PIECE_BATTLEAXE"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_TWO_HANDED_HAMMER then
			return itemPieceWeapon["ITEM_PIECE_MAUL"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_TWO_HANDED_SWORD then
			return itemPieceWeapon["ITEM_PIECE_GREATSWORD"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_DAGGER then
			return itemPieceWeapon["ITEM_PIECE_DAGGER"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_SHIELD then
			return itemPieceWeapon["ITEM_PIECE_SHIELD"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_BOW then
			return itemPieceWeapon["ITEM_PIECE_BOW"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_FIRE_STAFF then
			return itemPieceWeapon["ITEM_PIECE_INFERNO"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_FROST_STAFF then
			return itemPieceWeapon["ITEM_PIECE_ICE"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_LIGHTNING_STAFF then
			return itemPieceWeapon["ITEM_PIECE_LIGHTNING"]
		elseif item["EQUIPCAT"] == WEAPONTYPE_HEALING_STAFF then
			return itemPieceWeapon["ITEM_PIECE_RESTO"]
		else
			return itemPieceWeapon["ITEM_PIECE_UNKNOWN"]
		end
	end

	local function getItemPieceArmor(item)
		if item["EQUIPTYPE"] == EQUIP_TYPE_HEAD then
			return itemPieceArmor["ITEM_PIECE_HEAD"]
		elseif item["EQUIPTYPE"] == EQUIP_TYPE_SHOULDERS then
			return itemPieceArmor["ITEM_PIECE_SHOULDERS"]
		elseif item["EQUIPTYPE"] == EQUIP_TYPE_CHEST then
			return itemPieceArmor["ITEM_PIECE_CHEST"]
		elseif item["EQUIPTYPE"] == EQUIP_TYPE_LEGS then
			return itemPieceArmor["ITEM_PIECE_LEGS"]
		elseif item["EQUIPTYPE"] == EQUIP_TYPE_HAND then
			return itemPieceArmor["ITEM_PIECE_HANDS"]
		elseif item["EQUIPTYPE"] == EQUIP_TYPE_WAIST then
			return itemPieceArmor["ITEM_PIECE_WAIST"]
		elseif item["EQUIPTYPE"] == EQUIP_TYPE_FEET then
			return itemPieceArmor["ITEM_PIECE_FEET"]
		else
			return itemPieceArmor["ITEM_PIECE_UNKNOWN"]
		end
	end

	local function getItemPieceJewelry(item)
		if item["EQUIPTYPE"] == EQUIP_TYPE_NECK then
			return itemPieceJewelry["ITEM_PIECE_NECK"]
		elseif item["EQUIPTYPE"] == EQUIP_TYPE_RING then
			return itemPieceJewelry["ITEM_PIECE_RING"]
		else
			return itemPieceJewelry["ITEM_PIECE_UNKNOWN"]
		end
	end

	local function getItemArmorWeight(item)
		if item["SUBTYPE"] == ARMORTYPE_LIGHT then
			return itemArmorWeight["ITEM_WEIGHT_LIGHT"]
		elseif item["SUBTYPE"] == ARMORTYPE_MEDIUM then
			return itemArmorWeight["ITEM_WEIGHT_MEDIUM"]
		elseif item["SUBTYPE"] == ARMORTYPE_HEAVY then
			return itemArmorWeight["ITEM_WEIGHT_HEAVY"]
		else
			return itemArmorWeight["ITEM_WEIGHT_UNKNOWN"]
		end
	end

	local itemA = getLinkInfo(a["LINK"])
	local itemB = getLinkInfo(b["LINK"])

	local itemAType = getItemType(itemA)
	local itemBType = getItemType(itemB)

	if itemAType == itemBType then
		if itemAType == itemType["ITEM_TYPE_WEAPON"] then
			local itemAPiece = getItemPieceWeapon(itemA)
			local itemBPiece = getItemPieceWeapon(itemB)

			if itemAPiece == itemBPiece then
				local itemATrait = itemA["TRAIT"]
				local itemBTrait = itemB["TRAIT"]

				if itemATrait == itemBTrait then
					local itemALevel = string.match(itemA["LEVEL"], "%d+")
					local itemBLevel = string.match(itemB["LEVEL"], "%d+")

					if itemALevel == itemBLevel then
						local itemAQual = itemA["QUALITY"]
						local itemBQual = itemB["QUALITY"]

						return itemAQual > itemBQual
					else
						return itemALevel > itemBLevel
					end
				else
					return itemATrait < itemBTrait
				end
			else
				return itemAPiece < itemBPiece
			end
		elseif itemAType == itemType["ITEM_TYPE_ARMOR"] then
			local itemAPiece = getItemPieceArmor(itemA)
			local itemBPiece = getItemPieceArmor(itemB)

			if itemAPiece == itemBPiece then
				local itemAWeight = getItemArmorWeight(itemA)
				local itemBWeight = getItemArmorWeight(itemB)

				if itemAWeight == itemBWeight then
					local itemATrait = itemA["TRAIT"]
					local itemBTrait = itemB["TRAIT"]

					if itemATrait == itemBTrait then
						local itemALevel = string.match(itemA["LEVEL"], "%d+")
						local itemBLevel = string.match(itemB["LEVEL"], "%d+")

						if itemALevel == itemBLevel then
							local itemAQual = itemA["QUALITY"]
							local itemBQual = itemB["QUALITY"]

							return itemAQual > itemBQual
						else
							return itemALevel > itemBLevel
						end
					else
						return itemATrait < itemBTrait
					end
				else
					return itemAWeight < itemBWeight
				end
			else
				return itemAPiece < itemBPiece
			end
		elseif itemAType == itemType["ITEM_TYPE_JEWELRY"] then
			local itemAPiece = getItemPieceJewelry(itemA)
			local itemBPiece = getItemPieceJewelry(itemB)

			if itemAPiece == itemBPiece then
				local itemATrait = itemA["TRAIT"]
				local itemBTrait = itemB["TRAIT"]

				if itemATrait == itemBTrait then
					local itemALevel = string.match(itemA["LEVEL"], "%d+")
					local itemBLevel = string.match(itemB["LEVEL"], "%d+")

					if itemALevel == itemBLevel then
						local itemAQual = itemA["QUALITY"]
						local itemBQual = itemB["QUALITY"]

						return itemAQual > itemBQual
					else
						return itemALevel > itemBLevel
					end
				else
					return itemATrait < itemBTrait
				end
			else
				return itemAPiece < itemBPiece
			end
		end
	else
		return itemAType < itemBType
	end

end

local function doShowHoldings(_itemInfo)

	local holdCol = stSaveData.ColourHoldings

	if _itemInfo then
		local sSetName = _itemInfo["SETNAME"]
		if sSetName then
			local sColour, sTrackName, sTrackTexture = getTrackedInfo(_itemInfo)

			gatherAllHoldings()
			
			if tSetHoldings[sSetName] then
				local tTemp = {}

				local labelText = sSetName
--				if sTrackTexture then labelText = zo_iconTextFormat(sTrackTexture, 20, 20, sSetName) end

				sendHoldingsMsg(colourText(holdCol, GetString(SI_SETTRK_PREFIX_HOLDING)) .. colourText(sColour, labelText))
				for itemText, tTraits in pairs(tSetHoldings[sSetName]) do
					for traitId, tHoldings in pairs(tTraits) do
						local traitName = traitNames[traitId]
						local traitTexture = traitTextures[traitId]
						local traitColour = stSaveData.TraitColours[traitColourIDs[traitId]]
						local equipTexture = tHoldings["TEXTURE"]
						local sHoldings = tHoldings["HOLDINGS"]
						local tTmp = {}
						tTmp["TEXT"] = zo_iconTextFormat(equipTexture, 20, 20, itemText) .. colourText(holdCol, ", ")
						tTmp["TEXT"] = tTmp["TEXT"] .. zo_iconTextFormat(traitTexture, 20, 20, colourText(traitColour, traitName))
						tTmp["TEXT"] = tTmp["TEXT"] .. colourText(holdCol, ": ") .. colourText(holdCol, sHoldings)
						tTmp["LINK"] = tHoldings["LINK"]
						table.insert(tTemp, tTmp)
					end
				end
				table.sort(tTemp, compareSetHoldings)

				for i, sHoldings in pairs(tTemp) do
					sendHoldingsMsg(sHoldings["TEXT"])
				end
			else
				sendHoldingsMsg(colourText(holdCol, GetString(SI_SETTRK_PREFIX_NOHOLDINGS)) .. colourText(sColour, sSetName))
			end
			sendHoldingsMsg(tLabelText.BlockSeparator)
		end

		if not stSaveData.HoldingsToChat then msgWin:SetHidden(false) end
	end

end

local function showUndKeyHoldings()

	local holdCol = stSaveData.ColourHoldings
	
	local tTemp = {}
	for bagST_Id, nQty in pairs(tUndKeyHoldings) do
		local charName = stSaveData.CharNameFromId[bagST_Id]
		local accName = stSaveData.CharAccountFromId[bagST_Id]
--		local undKeyDisp = accName .. "." .. charName .. "(" .. nQty .. ")"
		local undKeyDisp = charName .. "(" .. nQty .. ")"
		if accName == currentAcountName then
			table.insert(tTemp, undKeyDisp)
		end
	end
	table.sort(tTemp)
	
	sendHoldingsMsg(colourText(colourWhite, GetString(SI_SETTRK_MISC_DISP_UNDKEY)))
	local sHolders = ""
	for i, freeDisp in ipairs(tTemp) do
		if sHolders == "" then
			sHolders = freeDisp
		else
			sHolders = sHolders .. ", " .. freeDisp
		end
	end
	local tTemp = nil

	local holdDisp = "|H0:item:55448:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h" .. "  " .. sHolders
	sendHoldingsMsg(colourText(holdCol, holdDisp))
	
	sendHoldingsMsg(tLabelText.BlockSeparator)

end

local function showGeodeHoldings()

	local holdCol = stSaveData.ColourHoldings
	local bGotSome = false
	
	gatherAllHoldings()

	sendHoldingsMsg(colourText(colourWhite, GetString(SI_SETTRK_MISC_DISP_GEODES)))
	for lLink, sHolders in pairs(tGeodeHoldings) do
		local geodeHolders = lLink .. "  " .. colourText(holdCol, sHolders)
		sendHoldingsMsg(geodeHolders)
		bGotSome = true
	end

	if (not bGotSome) then
		sendHoldingsMsg(GetString(SI_SETTRK_MISC_NO_GEODES))
	end
	sendHoldingsMsg(tLabelText.BlockSeparator)

end

function SetTrackerShowCharBoundHoldings()

	if (not stSaveData.TrackCharBound) then return end

	showGeodeHoldings()
	showUndKeyHoldings()

	if not stSaveData.HoldingsToChat then msgWin:SetHidden(false) end

end

function SetTrackerShowFreeSpace()

	if (not stSaveData.TrackFreeSpace) then return end

	local function getSlotsDisplay(_accountName, _holdingName, _freeSlots)

		if (stSaveData.LimitFreeAcc) then
			return _holdingName .. "(" .. _freeSlots .. ")"
		else
--			return _accountName .. "." .. _holdingName .. "(" .. _freeSlots .. ")"
			return _holdingName .. _accountName .. "(" .. _freeSlots .. ")"
		end

	end

	local holdCol = stSaveData.ColourHoldings
	
	gatherAllHoldings()

	sendHoldingsMsg(colourText(colourWhite, GetString(SI_SETTRK_MISC_DISP_FREESLOTS)))

	if (stSaveData.LimitFreeAcc) then
		local tTemp = {}
		for accName, tFreeSlotData in pairs(stSaveData.FreeSlots) do
			if ((not stSaveData.LimitFreeAcc) or accName == currentAcountName) then
				for holdName, nFreeSlots in pairs(tFreeSlotData) do
					local freeDisp = getSlotsDisplay(accName, holdName, nFreeSlots)
					table.insert(tTemp, freeDisp)
				end
			end
		end
		table.sort(tTemp)

		for i, freeDisp in ipairs(tTemp) do
			sendHoldingsMsg(colourText(holdCol, freeDisp))
		end
		local tTemp = nil
	else

	end

	sendHoldingsMsg(tLabelText.BlockSeparator)

	if not stSaveData.HoldingsToChat then msgWin:SetHidden(false) end

end  

local function showBagItemHoldings(bag, index)
	local tItemInfo = GetInfo(bag, index)
	doShowHoldings(tItemInfo)
	return 	
end  

local function showLinkHoldings(_itemLink)
	local tItemInfo = getLinkInfo(_itemLink)
	doShowHoldings(tItemInfo)
end  

local function checkMenu(_TrackNum, _TrackType)

	if _TrackNum == TRACK_INDEX_INVALID then
		return (_TrackType ~= TRACK_INDEX_INVALID)
	else
		if _TrackNum == _TrackType then
			return false
		else
			if stSaveData.TrackNames[_TrackNum] then
				if stSaveData.TrackNames[_TrackNum] == "" then
					return false
				else
					return true
				end
			else
				return false
			end
		end
	end

end

local function getMenuText(_trackType)

	local sColour = stSaveData.TrackColours[_trackType]
	local sTrackName = stSaveData.TrackNames[_trackType]

	return tLabelText.Track .. " " .. colourText(sColour, sTrackName)

end

local function displayLinkText(_lLink)

	local sTemp = _lLink:gsub("|H0:", "")
	sTemp = sTemp:gsub("|h|h", "")
	d("(" .. sTemp .. ")")

end

local function getSubMenuItems(_tkTyp, _IsCrafted, _itemInfo, _includeShowHoldings, _includeShowNotes, _ibag, _iindex)

	local tTemp = {}
	local tEntry = nil
	local lLink = _itemInfo.LINK
	
	if not _IsCrafted then
		for i=0, ST.GetMaxTrackStates(), 1 do
			tEntry = {label = getMenuText(i), callback = function() setLinkMarkState(lLink, i, _ibag, _iindex) end,}
			if checkMenu(i, _tkTyp) then table.insert(tTemp, tEntry) end
		end
		if checkMenu(TRACK_INDEX_INVALID, _tkTyp) then
			tEntry = {label = tLabelText.Forget, callback = function() setLinkMarkState(lLink, nil, _ibag, _iindex) end,}
			table.insert(tTemp, tEntry)
		end
	end

	tEntry = {label = tLabelText.EditNotes, callback = function() SetTrackerOpenNotes(lLink) end,}
	table.insert(tTemp, tEntry)

	if _includeShowNotes then
		tEntry = {label = tLabelText.ShowNotes, callback = function(self) showSetNotes(nil, _itemInfo) end,}
		table.insert(tTemp, tEntry)
	end

	if _includeShowHoldings then
		tEntry = {label = tLabelText.ShowHold, callback = function(self) showLinkHoldings(lLink) end,}
		table.insert(tTemp, tEntry)
	end

	if isDebug(3) then
		tEntry = {label = "Display Link Text", callback = function(self) displayLinkText(lLink) end,}
		table.insert(tTemp, tEntry)
	end

	return tTemp

end

local function addShowFreeSpaceMenuItem(_bag, _index)
	if (stSaveData.TrackFreeSpace) then
		AddCustomMenuItem(tLabelText.ShowFreeSpace, function() SetTrackerShowFreeSpace() end, MENU_ADD_OPTION_LABEL)
	end
end

local function addShowCharBoundMenuItem(_bag, _index)
	if (stSaveData.TrackCharBound) then
		AddCustomMenuItem(tLabelText.ShowCharBound, function() SetTrackerShowCharBoundHoldings() end, MENU_ADD_OPTION_LABEL)
	end
end

local function addShowHoldingsMenuItem(_bag, _index)
	AddCustomMenuItem(tLabelText.ShowHold, function() showBagItemHoldings(_bag, _index) end, MENU_ADD_OPTION_LABEL)
end

local function addShowNotesMenuItem(_itemInfo, _setNotes)
	if _setNotes and _setNotes ~= "" then
		AddCustomMenuItem(tLabelText.ShowNotes, function() showSetNotes(nil, _itemInfo) end, MENU_ADD_OPTION_LABEL)
	end
end

local function addEditNotesMenuItem(_lLink)
	AddCustomMenuItem(tLabelText.EditNotes, function() SetTrackerOpenNotes(_lLink) end, MENU_ADD_OPTION_LABEL)
end

local function addSaveItemDataMenuItem(_bag, _index)
	AddCustomMenuItem("Save Item Data", function() saveItemData(_bag, _index) end, MENU_ADD_OPTION_LABEL)
end

local function AddContextMenuOption(inventorySlot)

	local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
	local tItemInfo = GetInfo(bag, index)

	if tItemInfo then
		if isDebug(4) then
			addSaveItemDataMenuItem(bag, index)
		end

		if (tItemInfo["SETITEM"]) then
			local bIsCrafted = tItemInfo["CRAFTED"]
			if bIsCrafted and (not stSaveData.TrackCrafted) then return end
			local sSetName = tItemInfo["SETNAME"]
			local lLink = tItemInfo["LINK"]
			local tkTyp = getTrackType(sSetName)
			local bUseSubMenu = stSaveData.UseCustomMenu
			local bShowHoldOnMain = stSaveData.ShowHoldingsOnMain
			local bShowNotesOnMain = stSaveData.ShowNotesOnMain

			if bUseSubMenu then
				local tSubMenuEntries = getSubMenuItems(tkTyp, bIsCrafted, tItemInfo, (not bShowHoldOnMain), (not bShowNotesOnMain), bag, index)
				AddCustomSubMenuItem(tLabelText.SubMenuName, tSubMenuEntries)
				if bShowHoldOnMain then
					addShowHoldingsMenuItem(bag, index)
				end
				if bShowNotesOnMain then
					addShowNotesMenuItem(tItemInfo, getSetNotes(sSetName))
				end
			else
				if not bIsCrafted then
					for i=0, ST.GetMaxTrackStates(), 1 do
						if checkMenu(i, tkTyp) then AddCustomMenuItem(getMenuText(i), function() setLinkMarkState(lLink, i, bag, index) end, MENU_ADD_OPTION_LABEL) end
					end
					if checkMenu(TRACK_INDEX_INVALID, tkTyp) then AddCustomMenuItem(tLabelText.Forget, function() setLinkMarkState(lLink, nil, bag, index) end, MENU_ADD_OPTION_LABEL) end
				end
				addShowHoldingsMenuItem(bag, index)
				addEditNotesMenuItem(lLink)
				addShowNotesMenuItem(tItemInfo, getSetNotes(sSetName))
			end
		else
			addShowCharBoundMenuItem(bag, index)
			addShowFreeSpaceMenuItem(bag, index)
		end
	end

	ShowMenu(self)
	
end

local function AddContextMenuOptionSoon(inventorySlot)

	if inventorySlot:GetOwningWindow() == ZO_TradingHouse then return end
	if ZO_PlayerInventoryBackpack:IsHidden() and ZO_PlayerBankBackpack:IsHidden() and ZO_HouseBankBackpack:IsHidden() and ZO_GuildBankBackpack:IsHidden() then
		if ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack:IsHidden() then
			if ZO_SmithingTopLevelImprovementPanelInventoryBackpack:IsHidden() then
				return
			end
		end
	end
	--If FCOItemSaver doesn't want to show the context menu because all marker items were removed
	--via SHIFT+right mouse button click, the context menu mustn't be built here.
	--This preventer variable will be reset in FCOIS directly after the markers were removed and
	--the context menu will be opened normally if you just use the right click mouse button (without SHIFT).
	if FCOIS and FCOIS.preventerVars and FCOIS.preventerVars.dontShowInvContextMenu then return false end

	--zo_callLater(function() AddContextMenuOption(inventorySlot) end, 50)
	AddContextMenuOption(inventorySlot)

end

local function processAllData()

	checkHouse()

	gatherInventory()
--	gatherAllHoldings()
	gatherLinkHoldingsOthers()

end

function ST_ProcessCurrentData()

	dbg(3,"Rescan started " .. GetGameTimeMilliseconds())

	gatherInventory()

	dbg(3, "Rescan finished " .. GetGameTimeMilliseconds())

end


function SetTrack.OnUpdate()
end

local function onSlotUpdate(_eventCode, _iBagId, _iSlotId, _bNewItem, _itemSoundCategory, _UpdateReason)

	if _iBagId == BAG_VIRTUAL then return end

	if _UpdateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE then return end
	if _UpdateReason == INVENTORY_UPDATE_REASON_DYE_CHANGE then return end
	if _UpdateReason == INVENTORY_UPDATE_REASON_ITEM_CHARGE then return end
	if _UpdateReason == INVENTORY_UPDATE_REASON_PLAYER_LOCKED then return end

	local function getDebugMsg(__NewItem, __IsDestroyed, __BagId, __SetItem)
		local sTempMsg = ""
		local bagName = getBagNameFromBagId(__BagId)
		if __NewItem then
			if __SetItem then
				sTempMsg = "New set item in " .. bagName
			else
				sTempMsg = "New item in " .. bagName
			end
		else
			if __IsDestroyed then
				if __SetItem then
					sTempMsg = bagName .. " set item destroyed"
				else
					sTempMsg = bagName .. " item destroyed"
				end
			else
				if __SetItem then
					sTempMsg = bagName .. " set item updated"
				else
					sTempMsg = bagName .. " item updated"
				end
			end
		end
		return "Slot update - " .. sTempMsg
	end
	
	dbg(4, "SlotUpdate event code: " .. _eventCode .. ", " .. _iBagId .. ", " .. _iSlotId)
	local bIsSetItem = false
	local lItemLink = nil
	local bIsDestroyed = false

	local bagST_Id = getBagST_Id(_iBagId)
	if not bagST_Id then dbg(4, "onSlotUpdate() - bad bagST_Id") return end

	local tItemInfo = GetInfo(_iBagId, _iSlotId)
	if not tItemInfo then dbg(4, "onSlotUpdate() - bad tItemInfo") return end
	local lOldLink = getBagItem(_iBagId, _iSlotId)

	if tItemInfo.NAME == "" then
		bIsDestroyed = true
		if lOldLink then
			local tOldInfo = getLinkInfo(lOldLink)
			if tOldInfo then
				if tOldInfo.NAME then
					bIsSetItem = tOldInfo.SETITEM
					lItemLink = tOldInfo.LINK
				end
			end
		end
	else
		bIsSetItem = (tItemInfo.SETITEM or tItemInfo.ISGEODE or tItemInfo.ISUNDAUNTEDKEY)
		lItemLink = tItemInfo.LINK

		if lOldLink and lItemLink ~= lOldLink then
			removeBagItem(bagST_Id, _iBagId, _iSlotId, lOldLink, bIsSetItem)
		end
	end

	if bIsSetItem then
		if bIsDestroyed then
			removeBagItem(bagST_Id, _iBagId, _iSlotId, lItemLink, bIsSetItem)
			bHoldingsDirty = true
		else
			if (lOldLink and lItemLink ~= lOldLink) or (not lOldLink) then
				evalBagItem(bagST_Id, _iBagId, _iSlotId)
				bHoldingsDirty = true
			end
		end
		dbg(2, getDebugMsg(_bNewItem, bIsDestroyed, _iBagId, true))
	else
		if bIsDestroyed then
			removeBagItem(bagST_Id, _iBagId, _iSlotId, lItemLink, bIsSetItem)
		end
		dbg(4, getDebugMsg(_bNewItem, bIsDestroyed, _iBagId, false))
	end

	saveFreeSlots()

end

function SetTrackerSaveNotes(notesWin)

	local sNotes = SetTrackerNotesEdit_Notes:GetText()
	SetTrackerNotesEdit:SetHidden(true)
	local setName = SetTrackerNotesEdit.SetName
	if setName then
		checkTrackedSet(setName)
		stSaveData.TrackedSets[setName].Notes = sNotes
	end
	
end

function SetTrackerOpenNotes(_lLink)

	if _lLink then
		local itemInfo = getLinkInfo(_lLink)
		if itemInfo and itemInfo.SETITEM then
			local setName = itemInfo.SETNAME
			local setNotes = ""
			if stSaveData.TrackedSets[setName] then setNotes = stSaveData.TrackedSets[setName].Notes end
			local sColour = getTrackedInfo(itemInfo)
			SetTrackerNotesEdit.SetName = setName
			SetTrackerNotesEdit_WindowTitle:SetText(colourText(sColour,setName))
			SetTrackerNotesEdit_Notes:SetText(setNotes)
			setWinPosAndSize(SetTrackerNotesEdit, true)
			SetTrackerNotesEdit:SetHidden(false)
		end
	end
	
end

local function doToggleDisplay()

	toggleWindow(msgWin)

end

local function showContextMenu(_lLink)

	local tItemInfo = getLinkInfo(_lLink)
	if tItemInfo then
		local bIsCrafted = tItemInfo["CRAFTED"]
		local tkTyp = getTrackType(tItemInfo["SETNAME"])

		if bIsCrafted and (not stSaveData.TrackCrafted) then return end

		local tSubMenuEntries = getSubMenuItems(tkTyp, bIsCrafted, tItemInfo, true, true)
		ClearMenu()
		AddCustomSubMenuItem(tLabelText.SubMenuName, tSubMenuEntries)
		ShowMenu()	
	else
		dbg(1, "Context Menu - bad item link")
	end

end

local function setTrackerItemBrowserMouseUp(__control, __button)

	if __button == 1 then
		ItemBrowser.AddToChat(__control.data.itemLink);
	elseif __button == 2 then
		showContextMenu(__control.data.itemLink)
	end

end

function SetTrackerToggleDisplay()
	doToggleDisplay()
end

local function STlist()

	msgWin:AddText(colourText(colourOffWhite,"Tracked Sets"))

	table.sort(stSaveData.TrackedSets)
	for setName, tData in pairs(stSaveData.TrackedSets) do
		local nTrackType = tData.State
		local sColour = stSaveData.TrackColours[nTrackType]
		msgWin:AddText(colourText(sColour, "    " .. setName))
	end

	msgWin:AddText(colourText(colourOffWhite,tLabelText.BlockSeparator))
	
	msgWin:SetHidden(false)

end

local function onTooltipMouseUp(_toolTipControl, __button)

	if __button == 2 then
		if _toolTipControl.SetTrackerItemLink then
			showLinkHoldings(_toolTipControl.SetTrackerItemLink)
--			showContextMenu(_toolTipControl.SetTrackerItemLink)
		end
	end
	
end

local function onTooltipIconMouseExit(_toolTipIcon)
	hideSetNotes()
end

local function onTooltipIconMouseEnter(_toolTipIcon)

	local itemInfo = _toolTipIcon.ItemInfo
	if not itemInfo then return end
	showSetNotes(_toolTipIcon, itemInfo, -400)
	
end

local function createTooltipIcon(_tooltip, iconName)

	local ttIcon = WINDOW_MANAGER:CreateControl(iconName, _tooltip, CT_TEXTURE)
	ttIcon:SetHandler("OnMouseEnter", function(self) onTooltipIconMouseEnter(self) end)
	ttIcon:SetHandler("OnMouseExit", function(self) onTooltipIconMouseExit(self) end)

end

local function getControlChild(control, childName)

	for i=1, control:GetNumChildren(), 1 do
		local child = control:GetChild(i)
		if child and child:GetName() == childName then return child end
	end

	return nil
	
end

local function setTooltipIcon(_tooltip, _lLink)

	local ttIcon = getControlChild(_tooltip, SETTRK_TT_ICON_POP)
	if not ttIcon then return end	--If we can't find the icon we need to bail

	ttIcon:SetHidden(true)
	if _lLink then
		local itemInfo = getLinkInfo(_lLink)
		if itemInfo then
			if itemInfo.SETITEM then
				if itemInfo.CRAFTED and (not stSaveData.TrackCrafted) then return end
				local sColour, sTrackName, sTrackTexture, iTrackIndex, sTrackNotes = getTrackedInfo(itemInfo)
				if iTrackIndex == TRACK_INDEX_INVALID then return end --no icon for un-tracked sets
				local leftOffset = 90
				local topOffset = 4
				local r, g, b, a = convertHexToRGBA(sColour)
				ttIcon.ItemInfo = itemInfo
				ttIcon:SetDimensions(40, 40)
				ttIcon:SetTexture(sTrackTexture)
				ttIcon:SetColor(r, g, b, a)
				ttIcon:SetDrawTier(DT_HIGH)
				ttIcon:SetMouseEnabled(true)
				ttIcon:SetAnchor(TOPLEFT, ttIcon:GetParent(), TOPLEFT, leftOffset, topOffset)

				ttIcon:SetHidden(false)
			end
		end
	end

end

local function AddTooltipText(tooltip, itemLink)

	if itemLink then
		local tItemInfo = getLinkInfo(itemLink)
		if not tItemInfo then return end
		local bIsSetItem =  tItemInfo["SETITEM"]
		local sSetName = tItemInfo["SETNAME"]
		local bIsCrafted = tItemInfo.CRAFTED

		if bIsSetItem then
			if bIsCrafted and (not stSaveData.TrackCrafted) then return end
			tooltip.SetTrackerItemLink = itemLink
			setTooltipIcon(tooltip, itemLink)
			local sColour, sTrackName, sTrackTexture = getTrackedInfo(tItemInfo)
			tooltip:AddVerticalPadding(8)
			local sTrackText = GetString(SI_SETTRK_PREFIX_TRKSTATE) .. sTrackName
			if sTrackName == "" then sTrackText = GetString(SI_SETTRK_MISC_NOTTRACKED) end
			if bIsCrafted then sTrackText = GetString(SI_SETTRK_NAME_CRAFTED) end
			tooltip:AddLine(colourText(sColour, sTrackText), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

			if stSaveData.ToolTipInfo then
				local sLinkPrfx = GetString(SI_SETTRK_PREFIX_THISITEMHOLD)
				local sLinkTemp = getLinkHoldings(itemLink)
				if sLinkTemp == "" then
					sLinkTemp = GetString(SI_SETTRK_MISC_NOHOLDTHISITEM) 
				else
					sLinkTemp = sLinkPrfx .. sLinkTemp
				end
				tooltip:AddLine(colourText(sColour, sLinkTemp), "", 1, 1, 1, 
																					CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

				tooltip:AddLine(colourText(sColour, "Level: " .. tItemInfo["LEVEL"]), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
		else
			setTooltipIcon(tooltip)
		end
	end

end

local function ReturnWornItemLink(_equipSlot)
	return getFormattedItemLink(BAG_WORN, _equipSlot)
end

local function ReturnItemLink(itemLink)
	return itemLink
end

local function TooltipHook(tooltipControl, method, linkFunc, equipped)

	local origMethod = tooltipControl[method]

	tooltipControl:SetHandler("OnMouseUp", function(self, _button)
		onTooltipMouseUp(self, _button)
	end)

	tooltipControl[method] = function(self, ...)
		origMethod(self, ...)
		AddTooltipText(self, linkFunc(...))
	end

end

local function setItemBrowIntegration(_enable)

--support for ItemBrowser by @code65536
	if _enable then
		if ItemBrowser then
			if ItemBrowserTooltip then
				TooltipHook(ItemBrowserTooltip, "SetLink", ReturnItemLink)
			end
			ItemBrowserRow_OnMouseUp = function(control, button) setTrackerItemBrowserMouseUp(control, button) end
		end
	end

end

local function HookBagTips()

	TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
	TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
	TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)

	TooltipHook(ItemTooltip, "SetWornItem", ReturnWornItemLink)
	
	createTooltipIcon(PopupTooltip, SETTRK_TT_ICON_POP)
	TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)

end

local function updateRowControl(__RowCtrl, _ItemInfo, _inventoryType)

    local label = tLabelControls[__RowCtrl:GetName()]
    if not label then
        label = WINDOW_MANAGER:CreateControl(__RowCtrl:GetName() .. "SETTRK", __RowCtrl, CT_TEXTURE)
        tLabelControls[__RowCtrl:GetName()] = label
    end

	updateLabelControl(label, _ItemInfo, _inventoryType)

end

local function updateInventoryRow(_RowControl, _linkFunction, _inventoryType)

	local bagId = _RowControl.dataEntry.data.bagId
	local slotIndex = _RowControl.dataEntry.data.slotIndex
	local itemLink = bagId and _linkFunction(bagId, slotIndex) or _linkFunction(slotIndex)
	local tItemInfo = getLinkInfo(itemLink)
	if tItemInfo then
		if tItemInfo.SETITEM then
			updateRowControl(_RowControl, tItemInfo, _inventoryType)
		else
			updateRowControl(_RowControl)
		end
	else
		updateRowControl(_RowControl)
	end

end

--Guild trader hook function
local function hookTradingList()

	EVENT_MANAGER:UnregisterForEvent(ST_regName, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)

	local hookedFunction = TRADING_HOUSE.searchResultsList.dataTypes[1].setupCallback
	if hookedFunction then
		TRADING_HOUSE.searchResultsList.dataTypes[1].setupCallback = function(...)
			local row, data = ...
			hookedFunction(...)
			updateInventoryRow(row, GetTradingHouseSearchResultItemLink, INVENTORY_TYPE_TRADER)
		end
	end

end

local inventoryLists = {
    [0] = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listView,
    [1] = PLAYER_INVENTORY.inventories[INVENTORY_BANK].listView,
	[2] = PLAYER_INVENTORY.inventories[INVENTORY_GUILD_BANK].listView,
    [3] = PLAYER_INVENTORY.inventories[INVENTORY_HOUSE_BANK].listView,
}

local function hookInventoryLists()

	if not stSaveData.EnableListPrfx then return end

	--inventories hooks
    for i, inventoryList in pairs(inventoryLists) do
        if inventoryList and inventoryList.dataTypes and inventoryList.dataTypes[1] then
			local existingCallbackFunction = inventoryList.dataTypes[1].setupCallback
			inventoryList.dataTypes[1].setupCallback = function(rowControl, slot)
				existingCallbackFunction(rowControl, slot)
				updateInventoryRow(rowControl, GetItemLink, INVENTORY_TYPE_NORMAL)
			end
		end
    end

	--craft station deconstruction hook
	local deconList = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
	local existingCallbackFunction = deconList.dataTypes[1].setupCallback
	deconList.dataTypes[1].setupCallback = function(rowControl, slot)
		existingCallbackFunction(rowControl, slot)
		updateInventoryRow(rowControl, GetItemLink, INVENTORY_TYPE_DECON)
	end

	-- universal deconstruction (decon NPC) hook
	local deconList = ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack
	local existingCallbackFunction = deconList.dataTypes[1].setupCallback
	deconList.dataTypes[1].setupCallback = function(rowControl, slot)
		existingCallbackFunction(rowControl, slot)
		updateInventoryRow(rowControl, GetItemLink, INVENTORY_TYPE_DECON)
	end

	--Guild trader callback
	EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, hookTradingList)

end

local function onPlayerActivated()

	dbg(2, "Player activated")

	checkHouse()
	if (isHouse) then
		--Rescan if in a player house
		--This is because the API only populates the house storage tables when the player is actually in a house
		ST_ProcessCurrentData()
		bHoldingsDirty = true
	end

--[[
	d(GetGameTimeMilliseconds() .. " Player activated")
	if (currentZoneHouseId ~= 0) then
		d("Is House")
	else
		d("Is NOT House")
	end
--]]

end

local function createSettingsMenu()

	local function convertHexToRGBA_Packed(colourString)
		local r, g, b, a = convertHexToRGBA(colourString)
		return {r = r, g = g, b = b, a = a}
	end

	local function getOptionTrackColour(_TrkState)
		local	tColour = {
		type = "colorpicker",
			name = GetString(SI_SETTRK_SETTINGS_TRKSTATE) .. _TrkState .. GetString(SI_SETTRK_SETTINGS_TRKCOL),
			getFunc = function() return convertHexToRGBA(stSaveData.TrackColours[_TrkState]) end,
			setFunc = function(r, g, b)
				stSaveData.TrackColours[_TrkState] = convertRGBToHex(r, g, b)
				bHoldingsDirty = true
				stSaveData.LastUpdate = GetTimeStamp()
			end,
			default = convertHexToRGBA_Packed(colourOffWhite),
		}
		if _TrkState > maxTrackNum then tColour.disabled = function() return not stSaveData.UseCustomMenu end end
		return tColour
	end

	local function getOptionTraitColour(_TraitColourId)
		local	tColour = {
		type = "colorpicker",
			name = traitNames[_TraitColourId],
			getFunc = function() return convertHexToRGBA(stSaveData.TraitColours[_TraitColourId]) end,
			setFunc = function(r, g, b)
				stSaveData.TraitColours[_TraitColourId] = convertRGBToHex(r, g, b)
				bHoldingsDirty = true
				stSaveData.LastUpdate = GetTimeStamp()
			end,
			default = convertHexToRGBA_Packed(colourOffWhite),
		}
		return tColour
	end

	local function getOptionOtherColour(_Name, _settingName, _default, _disabledSettingName)
		local tempDefault = _default
		if not tempDefault then tempDefault = ST_defaults[_settingName] end
		local	tColour = {
		type = "colorpicker",
			name = _Name,
			getFunc = function() return convertHexToRGBA(stSaveData[_settingName]) end,
			setFunc = function(r, g, b) stSaveData[_settingName] = convertRGBToHex(r, g, b) bHoldingsDirty = true end,
			default = convertHexToRGBA_Packed(tempDefault),
		}
		if _disabledSettingName then tColour.disabled = function() return not stSaveData[_disabledSettingName] end end
		return tColour
	end

	local function getOptionTrkName(_TrkState)
		local	tName = {
			type = "editbox",
			name = GetString(SI_SETTRK_SETTINGS_TRKSTATE) .. _TrkState .. GetString(SI_SETTRK_SETTINGS_TRKNAME),
			getFunc = function() return stSaveData.TrackNames[_TrkState] end,
			setFunc = function(text)
				stSaveData.TrackNames[_TrkState] = text
				stSaveData.LastUpdate = GetTimeStamp()
			end,
			isMultiline = false,
			default = "",
		}
		if _TrkState > maxTrackNum then tName.disabled = function() return not stSaveData.UseCustomMenu end end
		return tName
	end

	local function getOptionTrkTexture(_TrkState)
		local	tTexture = {
			type = "editbox",
			name = GetString(SI_SETTRK_SETTINGS_TRKSTATE) .. _TrkState .. GetString(SI_SETTRK_SETTINGS_TRKTEXT),
			getFunc = function() return stSaveData.TrackTextures[_TrkState] end,
			setFunc = function(text)
				stSaveData.TrackTextures[_TrkState] = text
				stSaveData.LastUpdate = GetTimeStamp()
			end,
			isMultiline = false,
			default = ST_defaults.TrackTextures[i],
		}
		if _TrkState > maxTrackNum then
			tTexture.disabled = function() return not (stSaveData.CustomTextures and stSaveData.UseCustomMenu and stSaveData.EnableListPrfx) end
		else
			tTexture.disabled = function() return not (stSaveData.CustomTextures and stSaveData.EnableListPrfx) end
		end
		return tTexture
	end

	local function getOptionDivider()
		local tDivider = {
			type = "texture",
			image = "EsoUI/Art/Miscellaneous/horizontaldivider.dds",
			imageWidth = 510,
			imageHeight = 4,
		}
		return tDivider
	end

	local function getOptionCheckbox(_Name, _settingName, _default, _tooltip, _warning, _disabledSettingName)
		local tempDefault = _default
		if not tempDefault then tempDefault = ST_defaults[_settingName] end
		local tCb = {
			type = "checkbox",
			name = _Name,
			tooltip = _tooltip,
			getFunc = function() return stSaveData[_settingName] end,
			setFunc = function(state)
				stSaveData[_settingName] = state
			end,
			warning = _warning,
			default = tempDefault,
		}
		if _disabledSettingName then tCb.disabled = function() return not stSaveData[_disabledSettingName] end end
		return tCb
	end

	local function getOptionSlider(_Name, _settingName, _min, _max, _step, _default, _tooltip, _warning, _setCallback)
		local tempDefault = _default
		if not tempDefault then tempDefault = ST_defaults[_settingName] end
		local tSlider = {
			type = "slider",
			name = _Name,
			tooltip = _tooltip,
			min = _min,
			max = _max,
			step = _step,
			getFunc = function() return stSaveData[_settingName] end,
			setFunc = function(val) stSaveData[_settingName] = val  if _setCallback then _setCallback() end end,
			warning = _warning,
			default = tempDefault,
		}
		return tSlider
	end

	local function getOptionItemBrow()
		if not ItemBrowser then return nil end
		local tItembrow = {
			 type = "checkbox",
			 name = GetString(SI_SETTRK_SETTINGS_NAME2),
			 tooltip = GetString(SI_SETTRK_SETTINGS_TT2),
			 getFunc = function() return stSaveData.EnableItemBrow end,
			 setFunc = function(state)
					stSaveData.EnableItemBrow = state
					setItemBrowIntegration(state)
					ReloadUI("ingame")
				end,
			 warning = colourText(colourRed, GetString(SI_SETTRK_SETTINGS_WARN1)),
			 default = ST_defaults.EnableItemBrow,
		}
--		if not ItemBrowser then tItembrow.disabled = true end
		return tItembrow
	end

	local function getOptionSubMenu(_Name)
		local tSubMenu = {
			type = "submenu",
			name = _Name,
			controls = {},
			disabled = false,
		}
		return tSubMenu
	end

	local panelData = {
		type = "panel",
		name = ST_name,
		displayName = ST_name .. GetString(SI_SETTRK_SETTINGS_PNLNAME),
		author = "@Elephant42, updated by @q.bit, @Shinntarou",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel(ST_name, panelData)

	local optionsTable = {
		{
			type = "checkbox",
			name = GetString(SI_SETTRK_SETTINGS_NAME15),
			tooltip = GetString(SI_SETTRK_SETTINGS_TT15),
			getFunc = function() return stSaveGlobal.AcrossAccounts end,
			setFunc = function(state)
				stSaveGlobal.AcrossAccounts = state
				ReloadUI("ingame")
			end,
			warning = colourText(colourRed, GetString(SI_SETTRK_SETTINGS_WARN1)),
			default = ST_defaults.AcrossAccounts,
		},
		{
			type = "checkbox",
			name = GetString(SI_SETTRK_SETTINGS_NAME3),
			tooltip = GetString(SI_SETTRK_SETTINGS_TT3),
			getFunc = function() return stSaveData.EnableListPrfx end,
			setFunc = function(state)
				stSaveData.EnableListPrfx = state
				ReloadUI("ingame")
			end,
			warning = colourText(colourRed, GetString(SI_SETTRK_SETTINGS_WARN1)),
			default = ST_defaults.EnableListPrfx,
		},
		getOptionSlider(SI_SETTRK_SETTINGS_NAME18, "IconOffsetBackpack", 0, 140, 1, nil, SI_SETTRK_SETTINGS_TT18, nil, nil),

		getOptionItemBrow(),

		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME1), "UseCustomMenu", nil, GetString(SI_SETTRK_SETTINGS_TT1)),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME12), "ShowHoldingsOnMain", nil, GetString(SI_SETTRK_SETTINGS_TT12), nil, "UseCustomMenu"),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME14), "ShowNotesOnMain", nil, GetString(SI_SETTRK_SETTINGS_TT14), nil, "UseCustomMenu"),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME4), "HoldingsToChat", nil, GetString(SI_SETTRK_SETTINGS_TT4)),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME9), "CustomTextures", nil, GetString(SI_SETTRK_SETTINGS_TT9)),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME13), "TrackCrafted", nil, GetString(SI_SETTRK_SETTINGS_TT13)),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME19), "ToolTipInfo", nil, GetString(SI_SETTRK_SETTINGS_TT19)),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME21), "TrackCharBound", nil, GetString(SI_SETTRK_SETTINGS_TT21)),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME22), "TrackFreeSpace", nil, GetString(SI_SETTRK_SETTINGS_TT22)),
		getOptionCheckbox(GetString(SI_SETTRK_SETTINGS_NAME23), "LimitFreeAcc", nil, GetString(SI_SETTRK_SETTINGS_TT23), nil, "TrackFreeSpace"),

		{
			type = "checkbox",
			name = GetString(SI_SETTRK_SETTINGS_NAME17),
			tooltip = "",
			getFunc = function() return stSaveData.TrackGuildBanks end,
			setFunc = function(state)
				stSaveData.TrackGuildBanks = state
				if state == false then
					cleanGuildInventory()
				end
				ReloadUI("ingame")
			end,
			warning = colourText(colourRed, GetString(SI_SETTRK_SETTINGS_WARN1)),
			default = ST_defaults.TrackGuildBanks,
		},
		{
			type = "checkbox",
			name = GetString(SI_SETTRK_SETTINGS_NAME11),
			tooltip = GetString(SI_SETTRK_SETTINGS_TT11),
			getFunc = function() return stSaveData.UseLinkInHoldings end,
			setFunc = function(state)
				stSaveData.UseLinkInHoldings = state
				bHoldingsDirty = true
			end,
			default = ST_defaults.UseLinkInHoldings,
		},
		{
			type = "checkbox",
			name = GetString(SI_SETTRK_SETTINGS_NAME10),
			tooltip = GetString(SI_SETTRK_SETTINGS_TT10),
			getFunc = function() return stSaveData.UseLevelInHoldings end,
			setFunc = function(state)
				stSaveData.UseLevelInHoldings = state
				bHoldingsDirty = true
			end,
			default = ST_defaults.UseLevelInHoldings,
		},
		{
			type = "checkbox",
			name = GetString(SI_SETTRK_SETTINGS_NAME20),
			tooltip = GetString(SI_SETTRK_SETTINGS_TT20),
			getFunc = function() return stSaveData.ForceESO_Plus end,
			setFunc = function(state)
				stSaveData.ForceESO_Plus = state
				ReloadUI("ingame")
			end,
			warning = colourText(colourRed, GetString(SI_SETTRK_SETTINGS_WARN1)),
			default = ST_defaults.ForceESO_Plus,
		},

--		getOptionSlider(GetString(SI_SETTRK_SETTINGS_NAME16), "HoldingWinAlpha", 0, 1, 0.1, nil, nil, nil,
--										function() msgWin:SetAlpha(stSaveData.HoldingWinAlpha) setWinPosAndSize(msgWin) end),

		getOptionOtherColour(GetString(SI_SETTRK_SETTINGS_NAME5), "ColourHoldings"),
		getOptionOtherColour(GetString(SI_SETTRK_SETTINGS_NAME6), "ColourCrafted", nil, "TrackCrafted"),
		getOptionOtherColour(GetString(SI_SETTRK_SETTINGS_NAME7), "ColourDefault"),

		getOptionDivider(),
		getOptionSlider(GetString(SI_SETTRK_SETTINGS_NAME8), "DebugLevel", 0, 4, 1, nil, ""),
	}

	local tSubTrait = getOptionSubMenu(GetString(SI_SETTRK_SETTINGS_SUBMNU1))
	local tTemp = {}
	for iTraitColourId, sTraitColour in pairs(stSaveData.TraitColours) do
		if traitNames[iTraitColourId] then
			tTemp[traitNames[iTraitColourId]] = iTraitColourId
		end
	end
	table.sort(tTemp)
	for sTraitName, iTraitColourId in pairs(tTemp) do
		table.insert(tSubTrait.controls, getOptionTraitColour(iTraitColourId))
	end
	table.insert(optionsTable, tSubTrait)

	local tSubTrk = getOptionSubMenu(GetString(SI_SETTRK_SETTINGS_SUBMNU2))
	local nMaxTrk = ST.GetMaxTrackStates()
	local tDivider = getOptionDivider()

	for i=0, maxCustTrackNum, 1 do
		local tColour =  getOptionTrackColour(i)
		local tName =  getOptionTrkName(i)
		local tTexture = getOptionTrkTexture(i)
		table.insert(tSubTrk.controls, tColour)
		table.insert(tSubTrk.controls, tName)
		table.insert(tSubTrk.controls, tTexture)
		if i < maxCustTrackNum then table.insert(tSubTrk.controls, tDivider) end
	end
	table.insert(optionsTable, tSubTrk)

	cleanTable(optionsTable)
	
	LAM:RegisterOptionControls(ST_name, optionsTable)

end

local function guildBankReady()

	SelectGuildBank(GetSelectedGuildBankId())
	local guildName = GetGuildName(GetSelectedGuildBankId()) 
	local bagST_Id = guildName
	stSaveData.Inventories[bagST_Id] = {}
	for i=1, #ZO_GuildBankBackpack.data do
		local slotIndex = ZO_GuildBankBackpack.data[i].data.slotIndex
		local tItemInfo = GetInfo(BAG_GUILDBANK, slotIndex)
		evalSingleItem(bagST_Id, BAG_GUILDBANK, tItemInfo, 1)
	end
	
	bGuildBankReady = false

end

local function guildBankAddRemove()
	guildBankReady()
end

local function guildBankDelayReady()

	if bGuildBankReady then return end
	
	bGuildBankReady = true
	zo_callLater(function() guildBankReady() end, 1500)

end

local function guildBankClosed()
	processAllData()
end

local function initCallbacks()

	--ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)
	local LCM = LibCustomMenu
	LCM:RegisterContextMenu(AddContextMenuOptionSoon, LCM.CATEGORY_LATE)

	HookBagTips()
	hookInventoryLists()

	EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onSlotUpdate)

	SLASH_COMMANDS["/stlist"] = STlist
	SLASH_COMMANDS["/st"] = doToggleDisplay

	EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_PLAYER_ACTIVATED, onPlayerActivated)

---[[
	if stSaveData.TrackGuildBanks then
		EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_GUILD_BANK_ITEMS_READY, guildBankDelayReady)
		EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_GUILD_BANK_ITEM_ADDED, guildBankAddRemove)
		EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_GUILD_BANK_ITEM_REMOVED, guildBankAddRemove)
		EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_CLOSE_GUILD_BANK, guildBankClosed)
	end
--]]

end

local function initWindows()
	
	local winName = "ST_OutputWindow"
	
	local winLabel =  ST_name .. " Version " .. ST.Version
	msgWin = LIBMW:CreateMsgWindow(winName, winLabel)
	msgWin:SetHidden(true)
	----- CLOSE BUTTON -----
	msgWinCloseButton = WINDOW_MANAGER:CreateControl(winName.."Close", msgWin, CT_BUTTON)
	msgWinCloseButton:SetDimensions(40,40)
	msgWinCloseButton:SetAnchor(TOPRIGHT, tlw, TOPRIGHT,0,0)

	msgWinCloseButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
	msgWinCloseButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
	msgWinCloseButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
	msgWinCloseButton:SetDisabledTexture("EsoUI/Art/Buttons/closebutton_disabled.dds")

--	msgWin:SetAlpha(stSaveData.HoldingWinAlpha)

	msgWinCloseButton:SetHandler("OnClicked",function(self, but)
		msgWin:SetHidden(true)
	end)
--[[
	msgWin:SetHandler("OnMouseEnter", function()
		msgWin:SetAlpha(0.5)
--		msgWin:SetAlpha(stSaveData.HoldingWinAlpha)
	end)
	msgWin:SetHandler("OnMouseExit", function()
		msgWin:SetAlpha(stSaveData.HoldingWinAlpha)
	end)
--]]
	msgWin:SetHandler("OnMoveStart", function()
--		msgWin:SetAlpha(0.5)
	end)
	msgWin:SetHandler("OnMoveStop", function()
		SetTrackerSaveWinPosAndSize(msgWin)
	end)
	msgWin:SetHandler("OnResizeStart", function()
--		msgWin:SetAlpha(0.5)
	end)
	msgWin:SetHandler("OnResizeStop", function()
		SetTrackerSaveWinPosAndSize(msgWin)
	end)

	local winWidth = getWindowSaveData(msgWin, "WinWidth")
	if (winWidth) and winWidth > 0 then
		setWinPosAndSize(msgWin)
	end

	SetTrackerNotesEdit:SetHidden(true)
	SetTrackerNotesTT:SetHidden(true)

end

local function resetTraitColours()

	stSaveData.TraitColours = {}
	for traitId, traitColourId in pairs(traitColourIDs) do
		stSaveData.TraitColours[traitColourId] = colourLightYellow
	end

end

local function checkTraitColours()

	for traitId, traitColourId in pairs(traitColourIDs) do
		if not stSaveData.TraitColours[traitColourId] then
			stSaveData.TraitColours[traitColourId] = colourLightYellow
		end
	end

end

local function initSaveData()

	if stSaveData.TraitColours then
		checkTraitColours()
	else
		resetTraitColours()
	end

	stSaveLocal.LastLogin = GetTimeStamp()

end

local function initCharacterData(_RawSaveData)
 
	local currentCharId = GetCurrentCharacterId()

	for charNum=1, GetNumCharacters(), 1 do
		local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo(charNum)
		if charId == currentCharId then
			currentCharName = zo_strformat("<<1>>", name)
			break
		end
	end

	for accName, tAccData in pairs(_RawSaveData["Default"]) do
		for charName, tCharVars in pairs(tAccData) do
			if charName == currentCharName then
				currentAcountName = accName
				break
			end
		end
	end

	for charNum=1, GetNumCharacters(), 1 do
		local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo(charNum)
		local charName = zo_strformat("<<1>>", name)
		local charST_Id = charId .. currentAcountName
		local wornName = charName .. WORN_SUFFIX
		local wornST_Id = charST_Id .. WORN_SUFFIX_ID

		if charId == currentCharId then
			currentCharST_Id = charST_Id
			currentWornST_id = wornST_Id
			currentWornName = wornName
		end

		stSaveData.CharIdFromName[charName] = charST_Id
		stSaveData.CharNameFromId[charST_Id] = charName
		stSaveData.CharAccountFromId[charST_Id] = currentAcountName

		stSaveData.CharIdFromName[wornName] = wornST_Id
		stSaveData.CharNameFromId[wornST_Id] = wornName
	end

	for i=1, 5, 1 do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId) 
		stSaveData.CharIdFromName[guildName] = guildName
		stSaveData.CharNameFromId[guildName] = guildName
	end

	local currentBankName = nil
	local currentHouseName = nil

	currentBankST_id = BANK_ID .. currentAcountName
	currentBankName = BANK_NAME .. currentAcountName
	currentHouseST_id = HOUSE_ID .. currentAcountName
	currentHouseName = HOUSE_NAME .. currentAcountName

	stSaveData.CharIdFromName[currentBankName] = currentBankST_id
	stSaveData.CharNameFromId[currentBankST_id] = currentBankName
	stSaveData.CharIdFromName[currentHouseName] = currentHouseST_id
	stSaveData.CharNameFromId[currentHouseST_id] = currentHouseName

end


local function Initialise(eventCode, addOnName)

	if (ST_name ~= addOnName) then return end
	EVENT_MANAGER:UnregisterForEvent(ST_regName, EVENT_ADD_ON_LOADED)

	stSaveLocal = ZO_SavedVars:New(ST_SaveDataName, 1, nil, ST_defaultsLocal)
	stSaveGlobal = ZO_SavedVars:NewAccountWide(ST_SaveDataName, 1, nil, ST_defaults, nil, ACROSS_ALL_ACOUNTS)
	if stSaveGlobal.AcrossAccounts then
		stSaveData = stSaveGlobal
	else
		stSaveData = ZO_SavedVars:NewAccountWide(ST_SaveDataName, 1, nil, ST_defaults)
	end

	if IsESOPlusSubscriber() or stSaveData.ForceESO_Plus then
		bagList = {BAG_WORN, BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK, BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TWO, BAG_HOUSE_BANK_THREE, BAG_HOUSE_BANK_FOUR, BAG_HOUSE_BANK_FIVE, BAG_HOUSE_BANK_SIX, BAG_HOUSE_BANK_SEVEN, BAG_HOUSE_BANK_EIGHT, BAG_HOUSE_BANK_NINE, BAG_HOUSE_BANK_TEN}
	else
		bagList = {BAG_WORN, BAG_BACKPACK, BAG_BANK, BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TWO, BAG_HOUSE_BANK_THREE, BAG_HOUSE_BANK_FOUR, BAG_HOUSE_BANK_FIVE, BAG_HOUSE_BANK_SIX, BAG_HOUSE_BANK_SEVEN, BAG_HOUSE_BANK_EIGHT, BAG_HOUSE_BANK_NINE, BAG_HOUSE_BANK_TEN}
	end

	initCharacterData(_G[ST_SaveDataName]) --This call MUST be made before any others to properly initialise character and account names

	initSaveData(_G[ST_SaveDataName])

	-- Register our keybind names
	ZO_CreateStringId("SI_BINDING_NAME_ST_TOGGLE_DISPLAY", GetString(SI_SETTRK_SLASHCMD))
	ZO_CreateStringId("SI_BINDING_NAME_ST_SHOW_FREESPACE", tLabelText.ShowFreeSpace)
	ZO_CreateStringId("SI_BINDING_NAME_ST_SHOW_CHARBOUND", tLabelText.ShowCharBound)

	SLASH_COMMANDS["/stcb"] = SetTrackerShowCharBoundHoldings
	SLASH_COMMANDS["/stfs"] = SetTrackerShowFreeSpace
	
	initCallbacks()

	initWindows()

	processAllData()

	createSettingsMenu()

	setItemBrowIntegration(stSaveData.EnableItemBrow)

	dbg(1, "SetTracker initialised - " .. currentCharName .. currentAcountName)


	ST_initialised = true

end

EVENT_MANAGER:RegisterForEvent(ST_regName, EVENT_ADD_ON_LOADED, Initialise)

-- EOF
