-- Libraries
local LAM = LibAddonMenu2

InventoryUpkeep = {}

--variables
	local defaults = {
		enabled ={
			alchemy =false,
			blacksmithing =false,
			clothing =false,
			enchanting =false,
			provisioning =false,
			woodworking =false,
			jewelry =false,
			furnishing =false,
			misc = false,
			notifications = false
		},
		minQuality ={
			alchemy =1,
			blacksmithing =1,
			clothing =1,
			enchanting =1,
			provisioning =1,
			woodworking =1,
			jewelry =1
		},
		keepTraits ={
			alchemy =true,
			blacksmithing =true,
			clothing =true,
			enchanting =true,
			provisioning =true,
			woodworking =true,
			jewelry =true
		},
		keepIntricate ={
			alchemy =true,
			blacksmithing =true,
			clothing =true,
			enchanting =true,
			provisioning =true,
			woodworking =true,
			jewelry =true
		},
		keepOrnate ={
			alchemy =true,
			blacksmithing =true,
			clothing =true,
			enchanting =true,
			provisioning =true,
			woodworking =true,
			jewelry =true
		},
		keepMaterial ={
			alchemy =true,
			blacksmithing =true,
			clothing =true,
			enchanting =true,
			provisioning =true,
			woodworking =true,
			jewelry =true,
			furnishing =true
		},
		keepRawMaterial ={
			alchemy =true,
			blacksmithing =true,
			clothing =true,
			enchanting =true,
			provisioning =true,
			woodworking =true,
			jewelry =true
		},
		keepBooster ={
			alchemy =true,
			blacksmithing =true,
			clothing =true,
			enchanting =true,
			provisioning =true,
			woodworking =true,
			jewelry =true
		},
		keepRawBooster ={
			alchemy =true,
			blacksmithing =true,
			clothing =true,
			enchanting =true,
			provisioning =true,
			woodworking =true,
			jewelry =true
		},
		mailEnabled = {
			alchemy =false,
			blacksmithing =false,
			clothing =false,
			enchanting =false,
			furnishing =false,
			jewelry =false,
			provisioning =false,
			woodworking =false
		},
		mailSubject = {
			alchemy ="Alchemist Delivery",
			blacksmithing ="Blacksmith Delivery",
			clothing ="Clothier Delivery",
			enchanting ="Enchanter Delivery",
			furnishing ="Furnisher Delivery",
			jewelry ="Jeweler Delivery",
			provisioning ="Provisioner Delivery",
			woodworking ="Woodworker Delivery"
		},
		mailTo = {
			alchemy ="",
			blacksmithing ="",
			clothing ="",
			enchanting ="",
			furnishing ="",
			jewelry ="",
			provisioning ="",
			woodworking =""
		},
		keepWeaponGlyphs = true,
		keepJewelryGlyphs = true,
		keepArmorGlyphs = true,
		keepRunes = true,
		keepLures = true,
		keepTrophies = true,
		keepMotifs = true,
		keepRecipes = true,
		keepFood = true,
		keepDrink = true,
		keepTrash = true,
		keepStyles = true,
		keepWeaponTraitStones = true,
		keepArmorTraitStones = true,
		keepJewelryTraitStones = true,
		keepBoosterStones = true,
		keepFurnishing = true
	}
	local item_qualities = {
		 [1] = "White",
		 [2] = "Green",
		 [3] = "Blue",
		 [4] = "Purple",
		 [5] = "Yellow"
	 }
	local SavedVariables
	local emptyItemSlots = {}
	local lootEventEnable = true
	local itemsToCheck = {}
	local currentItem = 0
	local procLock = 0
	local mailingInProgress = 0
	local lootItem_buffer = {}
--functions

local BufferTable = {}
local function BufferReached(key, buffer)
	if key == nil then return end
	if BufferTable[key] == nil then BufferTable[key] = {} end
	BufferTable[key].buffer = buffer or 3
	BufferTable[key].now = GetFrameTimeSeconds()
	if BufferTable[key].last == nil then BufferTable[key].last = BufferTable[key].now end
	BufferTable[key].diff = BufferTable[key].now - BufferTable[key].last
	BufferTable[key].eval = BufferTable[key].diff >= BufferTable[key].buffer
	if BufferTable[key].eval then BufferTable[key].last = BufferTable[key].now end
	return BufferTable[key].eval
end

local function checkItemType(itemLinkType,itemLinkWeaponType,itemLinkArmorType,enable)
	if(enable) then
		if(itemLinkType == ITEMTYPE_ADDITIVE) then d("InventoryUpkeep:ItemType:Additive") end
		if(itemLinkType == ITEMTYPE_POTION_BASE or itemLinkType == ITEMTYPE_POISON_BASE) then d("InventoryUpkeep:ItemType:Alchemy Base") end
		if(itemLinkType == ITEMTYPE_ARMOR) then d("InventoryUpkeep:ItemType:Armor") end
		if(itemLinkType == ITEMTYPE_ARMOR_BOOSTER) then d("InventoryUpkeep:ItemType:Armor booster") end
		if(itemLinkType == ITEMTYPE_ARMOR_TRAIT) then d("InventoryUpkeep:ItemType:Armor Trait") end
		if(itemLinkType == ITEMTYPE_AVA_REPAIR) then d("InventoryUpkeep:ItemType:AVA Repair") end
		if(itemLinkType == ITEMTYPE_BLACKSMITHING_BOOSTER) then d("InventoryUpkeep:ItemType:Blacksmithing Booster") end
		if(itemLinkType == ITEMTYPE_BLACKSMITHING_MATERIAL) then d("InventoryUpkeep:ItemType:Blacksmithing Material") end
		if(itemLinkType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL) then d("InventoryUpkeep:ItemType:Blacksmithing Raw Material") end
		if(itemLinkType == ITEMTYPE_CLOTHIER_BOOSTER) then d("InventoryUpkeep:ItemType:Clothier Booster") end
		if(itemLinkType == ITEMTYPE_CLOTHIER_MATERIAL) then d("InventoryUpkeep:ItemType:Clothier Material") end
		if(itemLinkType == ITEMTYPE_CLOTHIER_RAW_MATERIAL) then d("InventoryUpkeep:ItemType:Clothier Raw Material") end
		if(itemLinkType == ITEMTYPE_COLLECTIBLE) then d("InventoryUpkeep:ItemType:Collectible") end
		if(itemLinkType == ITEMTYPE_CONTAINER) then d("InventoryUpkeep:ItemType:Container") end
		if(itemLinkType == ITEMTYPE_COSTUME) then d("InventoryUpkeep:ItemType:Costumer") end
		if(itemLinkType == ITEMTYPE_DEPRECIATED) then d("InventoryUpkeep:ItemType:Depreciated") end
		if(itemLinkType == ITEMTYPE_DISGUISE) then d("InventoryUpkeep:ItemType:Disguise") end
		if(itemLinkType == ITEMTYPE_DRINK) then d("InventoryUpkeep:ItemType:Drink") end
		if(itemLinkType == ITEMTYPE_DYE_STAMP) then d("InventoryUpkeep:ItemType:Dye Stamp") end
		if(itemLinkType == ITEMTYPE_ENCHANTING_RUNE_ASPECT) then d("InventoryUpkeep:ItemType:Enchanting Rune Aspect") end
		if(itemLinkType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE) then d("InventoryUpkeep:ItemType:Enchanting Rune Essence") end
		if(itemLinkType == ITEMTYPE_ENCHANTING_RUNE_POTENCY) then d("InventoryUpkeep:ItemType:Enchanting Rune Potency") end
		if(itemLinkType == ITEMTYPE_ENCHANTMENT_BOOSTER) then d("InventoryUpkeep:ItemType:Enchantment Booster") end
		if(itemLinkType == ITEMTYPE_FISH) then d("InventoryUpkeep:ItemType:Fish") end
		if(itemLinkType == ITEMTYPE_FLAVORING) then d("InventoryUpkeep:ItemType:Flavoring") end
		if(itemLinkType == ITEMTYPE_FOOD) then d("InventoryUpkeep:ItemType:Food") end
		if(itemLinkType == ITEMTYPE_FURNISHING) then d("InventoryUpkeep:ItemType:Furnishing") end
		if(itemLinkType == ITEMTYPE_FURNISHING_MATERIAL) then d("InventoryUpkeep:ItemType:Furnishing Material") end
		if(itemLinkType == ITEMTYPE_GLYPH_ARMOR) then d("InventoryUpkeep:ItemType:Glyph Armor") end
		if(itemLinkType == ITEMTYPE_GLYPH_JEWELRY) then d("InventoryUpkeep:ItemType:Glyph Jewelry") end
		if(itemLinkType == ITEMTYPE_GLYPH_WEAPON) then d("InventoryUpkeep:ItemType:Glyph Weapon") end
		if(itemLinkType == ITEMTYPE_INGREDIENT) then d("InventoryUpkeep:ItemType:Ingredient") end
		if(itemLinkType == ITEMTYPE_ITERATION_BEGIN) then d("InventoryUpkeep:ItemType:Iteration Begin") end
		if(itemLinkType == ITEMTYPE_ITERATION_END) then d("InventoryUpkeep:ItemType:Iteration End") end
		if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER) then d("InventoryUpkeep:ItemType:Jewelry Crafting Booster") end
		if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL) then d("InventoryUpkeep:ItemType:Jewelry Crafting Material") end
		if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER) then d("InventoryUpkeep:ItemType:Jewelry Crafting Raw Booster") end
		if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL) then d("InventoryUpkeep:ItemType:Jewelry Crafting Raw Material") end
		if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_RAW_TRAIT) then d("InventoryUpkeep:ItemType:Jewelry Crafting Raw Trait") end
		if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_TRAIT) then d("InventoryUpkeep:ItemType:Jewelry Crafting Trait") end
		if(itemLinkType == ITEMTYPE_LOCKPICK) then d("InventoryUpkeep:ItemType:Lockpick") end
		if(itemLinkType == ITEMTYPE_LURE) then d("InventoryUpkeep:ItemType:Lure") end
		if(itemLinkType == ITEMTYPE_MASTER_WRIT) then d("InventoryUpkeep:ItemType:Master Writ") end
		if(itemLinkType == ITEMTYPE_MAX_VALUE) then d("InventoryUpkeep:ItemType:Max Value") end
		if(itemLinkType == ITEMTYPE_MIN_VALUE) then d("InventoryUpkeep:ItemType:Min Value") end
		if(itemLinkType == ITEMTYPE_MOUNT) then d("InventoryUpkeep:ItemType:Mount") end
		if(itemLinkType == ITEMTYPE_NONE) then d("InventoryUpkeep:ItemType:None") end
		if(itemLinkType == ITEMTYPE_PLUG) then d("InventoryUpkeep:ItemType:Plug") end
		if(itemLinkType == ITEMTYPE_POISON) then d("InventoryUpkeep:ItemType:Poison") end
		if(itemLinkType == ITEMTYPE_POISON_BASE) then d("InventoryUpkeep:ItemType:Poison Base") end
		if(itemLinkType == ITEMTYPE_POTION) then d("InventoryUpkeep:ItemType:Potion") end
		if(itemLinkType == ITEMTYPE_RACIAL_STYLE_MOTIF) then d("InventoryUpkeep:ItemType:Racial Style Motif") end
		if(itemLinkType == ITEMTYPE_RAW_MATERIAL) then d("InventoryUpkeep:ItemType:Raw Material") end
		if(itemLinkType == ITEMTYPE_REAGENT) then d("InventoryUpkeep:ItemType:Reagent") end
		if(itemLinkType == ITEMTYPE_RECIPE) then d("InventoryUpkeep:ItemType:Recipe") end
		if(itemLinkType == ITEMTYPE_SCROLL) then d("InventoryUpkeep:ItemType:Scroll") end
		if(itemLinkType == ITEMTYPE_SIEGE) then d("InventoryUpkeep:ItemType:Siege") end
		if(itemLinkType == ITEMTYPE_SOUL_GEM) then d("InventoryUpkeep:ItemType:Soul Gem") end
		if(itemLinkType == ITEMTYPE_SPELLCRAFTING_TABLET) then d("InventoryUpkeep:ItemType:Spellcrafting Tablet") end
		if(itemLinkType == ITEMTYPE_SPICE) then d("InventoryUpkeep:ItemType:Spice") end
		if(itemLinkType == ITEMTYPE_STYLE_MATERIAL) then d("InventoryUpkeep:ItemType:Material") end
		if(itemLinkType == ITEMTYPE_TABARD) then d("InventoryUpkeep:ItemType:Tabard") end
		if(itemLinkType == ITEMTYPE_TOOL) then d("InventoryUpkeep:ItemType:Tool") end
		if(itemLinkType == ITEMTYPE_TRASH) then d("InventoryUpkeep:ItemType:Trash") end
		if(itemLinkType == ITEMTYPE_TREASURE) then d("InventoryUpkeep:ItemType:Treasure") end
		if(itemLinkType == ITEMTYPE_TROPHY) then d("InventoryUpkeep:ItemType:Trophy") end
		if(itemLinkType == ITEMTYPE_WEAPON) then d("InventoryUpkeep:ItemType:Weapon") end
		if(itemLinkType == ITEMTYPE_WEAPON_BOOSTER) then d("InventoryUpkeep:ItemType:Weapon Booster") end
		if(itemLinkType == ITEMTYPE_WEAPON_TRAIT) then d("InventoryUpkeep:ItemType:Weapon Trait") end
		if(itemLinkType == ITEMTYPE_WOODWORKING_BOOSTER) then d("InventoryUpkeep:ItemType:Woodworking Booster") end
		if(itemLinkType == ITEMTYPE_WOODWORKING_MATERIAL) then d("InventoryUpkeep:ItemType:Woodworking Material") end
		if(itemLinkType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) then d("InventoryUpkeep:ItemType:Woodworking Raw Material") end
	
		if(itemLinkWeaponType == WEAPONTYPE_AXE) then d("InventoryUpkeep:WeaponType:Axe") end
		if(itemLinkWeaponType == WEAPONTYPE_BOW) then d("InventoryUpkeep:WeaponType:Bow") end
		if(itemLinkWeaponType == WEAPONTYPE_DAGGER) then d("InventoryUpkeep:WeaponType:Dagger") end
		if(itemLinkWeaponType == WEAPONTYPE_FIRE_STAFF) then d("InventoryUpkeep:WeaponType:Fire Staff") end
		if(itemLinkWeaponType == WEAPONTYPE_FROST_STAFF) then d("InventoryUpkeep:WeaponType:Frost Staff") end
		if(itemLinkWeaponType == WEAPONTYPE_HAMMER) then d("InventoryUpkeep:WeaponType:Hammer") end
		if(itemLinkWeaponType == WEAPONTYPE_HEALING_STAFF) then d("InventoryUpkeep:WeaponType:Healing Staff") end
		if(itemLinkWeaponType == WEAPONTYPE_LIGHTNING_STAFF) then d("InventoryUpkeep:WeaponType:Lightning Staff") end
		if(itemLinkWeaponType == WEAPONTYPE_NONE) then d("InventoryUpkeep:WeaponType:None") end
		if(itemLinkWeaponType == WEAPONTYPE_RUNE) then d("InventoryUpkeep:WeaponType:Rune") end
		if(itemLinkWeaponType == WEAPONTYPE_SHIELD) then d("InventoryUpkeep:WeaponType:Shield") end
		if(itemLinkWeaponType == WEAPONTYPE_SWORD) then d("InventoryUpkeep:WeaponType:Sword") end
		if(itemLinkWeaponType == WEAPONTYPE_TWO_HANDED_AXE) then d("InventoryUpkeep:WeaponType:Two Handed Axe") end
		if(itemLinkWeaponType == WEAPONTYPE_TWO_HANDED_HAMMER) then d("InventoryUpkeep:WeaponType:Two Handed Hammer") end
		if(itemLinkWeaponType == WEAPONTYPE_TWO_HANDED_SWORD) then d("InventoryUpkeep:WeaponType:Two Handed Sword") end
		
		if(itemLinkArmorType == ARMORTYPE_HEAVY) then d("InventoryUpkeep:ArmorType:Heavy") end
		if(itemLinkArmorType == ARMORTYPE_MEDIUM) then d("InventoryUpkeep:ArmorType:Medium") end
		if(itemLinkArmorType == ARMORTYPE_LIGHT) then d("InventoryUpkeep:ArmorType:Light") end 
	end
		
		if(itemLinkWeaponType == WEAPONTYPE_AXE) then return true end
		if(itemLinkWeaponType == WEAPONTYPE_BOW) then return false end
		if(itemLinkWeaponType == WEAPONTYPE_DAGGER) then return true end
		if(itemLinkWeaponType == WEAPONTYPE_FIRE_STAFF) then return false end
		if(itemLinkWeaponType == WEAPONTYPE_FROST_STAFF) then return false end
		if(itemLinkWeaponType == WEAPONTYPE_HAMMER) then return true end
		if(itemLinkWeaponType == WEAPONTYPE_HEALING_STAFF) then return false end
		if(itemLinkWeaponType == WEAPONTYPE_LIGHTNING_STAFF) then return false end
		--if(itemLinkWeaponType == WEAPONTYPE_NONE) then return end
		--if(itemLinkWeaponType == WEAPONTYPE_RUNE) then return end
		if(itemLinkWeaponType == WEAPONTYPE_SHIELD) then return false end
		if(itemLinkWeaponType == WEAPONTYPE_SWORD) then return true end
		if(itemLinkWeaponType == WEAPONTYPE_TWO_HANDED_AXE) then return true end
		if(itemLinkWeaponType == WEAPONTYPE_TWO_HANDED_HAMMER) then return true end
		if(itemLinkWeaponType == WEAPONTYPE_TWO_HANDED_SWORD) then return true end
end

local function processItem(i)
				local destroyItem = 0
				local itemLink = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT)
				--populate itemlink information
				local itemLinkType = GetItemLinkItemType(itemLink)
				local itemLinkName = GetItemLinkName(itemLink)
				local itemLinkQuality = GetItemLinkQuality(itemLink)
				local itemLinkStyle = GetItemLinkItemStyle(itemLink)
				local itemLinkWeaponType = GetItemWeaponType(BAG_BACKPACK,i)
				local itemLinkArmorType = GetItemArmorType(BAG_BACKPACK,i)
				local itemLinkStyle = GetItemLinkItemStyle(itemLink)
				local itemLinkBound = IsItemLinkBound(itemLink)
				local itemLinkTraitType,itemLinkTraitText = GetItemLinkTraitInfo(itemLink)
				local itemLinkEquipType = GetItemLinkEquipType(itemLink)
				local WeaponIsSmith = checkItemType(itemLinkType,itemLinkWeaponType,itemLinkArmorType,false)
				--process misc items
				if(SavedVariables.enabled.misc) then
					if(not SavedVariables.keepLures and itemLinkType == ITEMTYPE_LURE) then
						destroyItem = 1
					end
					if(not SavedVariables.keepTrophies and itemLinkType == ITEMTYPE_TROPHY) then
						destroyItem = 1
					end
					if(not SavedVariables.keepMotifs and itemLinkType == ITEMTYPE_COLLECTIBLE) then
						destroyItem = 1
					end
					if(not SavedVariables.keepFood and itemLinkType == ITEMTYPE_FOOD) then
						destroyItem = 1
					end
					if(not SavedVariables.keepDrink and itemLinkType == ITEMTYPE_DRINK) then
						destroyItem = 1
					end
					if(not SavedVariables.keepTrash and itemLinkType == ITEMTYPE_TRASH) then
						destroyItem = 1
					end
					if(not SavedVariables.keepStyles and itemLinkType == ITEMTYPE_STYLE_MATERIAL) then
						destroyItem = 1
					end
					if(not SavedVariables.keepWeaponTraitStones and itemLinkType == ITEMTYPE_WEAPON_TRAIT) then
						destroyItem = 1
					end
					if(not SavedVariables.keepArmorTraitStones and itemLinkType == ITEMTYPE_ARMOR_TRAIT) then
						destroyItem = 1
					end
					if(not SavedVariables.keepJewelryTraitStones and itemLinkType == ITEMTYPE_JEWELRY_TRAIT) then
						destroyItem = 1
					end
				end
				--process weapons
				if(itemLinkType == ITEMTYPE_WEAPON) then
					if(not WeaponIsSmith and SavedVariables.enabled.woodworking) then
						if(itemLinkQuality == ITEM_QUALITY_TRASH) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_NORMAL and SavedVariables.minQuality.woodworking > 1) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_MAGIC and SavedVariables.minQuality.woodworking > 2) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARCANE and SavedVariables.minQuality.woodworking > 3) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARTIFACT and SavedVariables.minQuality.woodworking > 4) then
							destroyItem = 1 end
						--if the weapon has a feature we want to keep, override the quality filter
						if(itemLinkTraitType ~= ITEM_TRAIT_TYPE_NONE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_WEAPON_ORNATE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_WEAPON_INTRICATE and SavedVariables.keepTraits.woodworking) then
							destroyItem = 0 end
						if(itemLinkTraitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE and SavedVariables.keepIntricate.woodworking) then
							destroyItem = 0 end
					end
					if(WeaponIsSmith and SavedVariables.enabled.blacksmithing) then
						if(itemLinkQuality == ITEM_QUALITY_TRASH) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_NORMAL and SavedVariables.minQuality.blacksmithing > 1) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_MAGIC and SavedVariables.minQuality.blacksmithing > 2) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARCANE and SavedVariables.minQuality.blacksmithing > 3) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARTIFACT and SavedVariables.minQuality.blacksmithing > 4) then
							destroyItem = 1 end
						--if the weapon has a feature we want to keep, override the quality filter
						if(itemLinkTraitType ~= ITEM_TRAIT_TYPE_NONE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_WEAPON_ORNATE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_WEAPON_INTRICATE and SavedVariables.keepTraits.blacksmithing) then
							destroyItem = 0 end
						if(itemLinkTraitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE and SavedVariables.keepIntricate.blacksmithing) then
							destroyItem = 0 end
					end
				end
				--process armors
				if(itemLinkType == ITEMTYPE_ARMOR) then
					if(itemLinkArmorType == ARMORTYPE_HEAVY and SavedVariables.enabled.blacksmithing) then
						if(itemLinkQuality == ITEM_QUALITY_TRASH) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_NORMAL and SavedVariables.minQuality.blacksmithing > 1) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_MAGIC and SavedVariables.minQuality.blacksmithing > 2) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARCANE and SavedVariables.minQuality.blacksmithing > 3) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARTIFACT and SavedVariables.minQuality.blacksmithing > 4) then
							destroyItem = 1 end
						--if the armor has a feature we want to keep, override the quality filter
						if(itemLinkTraitType ~= ITEM_TRAIT_TYPE_NONE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_ARMOR_INTRICATE and SavedVariables.keepTraits.blacksmithing) then
							destroyItem = 0 end
						if(itemLinkTraitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE and SavedVariables.keepIntricate.blacksmithing) then
							destroyItem = 0 end
					end
					if(itemLinkArmorType == ARMORTYPE_MEDIUM or itemLinkArmorType == ARMORTYPE_LIGHT and SavedVariables.enabled.clothing) then
						if(itemLinkQuality == ITEM_QUALITY_TRASH) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_NORMAL and SavedVariables.minQuality.clothing > 1) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_MAGIC and SavedVariables.minQuality.clothing > 2) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARCANE and SavedVariables.minQuality.clothing > 3) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARTIFACT and SavedVariables.minQuality.clothing > 4) then
							destroyItem = 1 end
						--if the armor has a feature we want to keep, override the quality filter
						if(itemLinkTraitType ~= ITEM_TRAIT_TYPE_NONE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_ARMOR_INTRICATE and SavedVariables.keepTraits.clothing) then
							destroyItem = 0 end
						if(itemLinkTraitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE and SavedVariables.keepIntricate.clothing) then
							destroyItem = 0 end
					end
				end
				--process jewelry
				if(SavedVariables.enabled.jewelry) then
					if(itemLinkEquipType == EQUIP_TYPE_RING or itemLinkEquipType == EQUIP_TYPE_NECK) then
						if(itemLinkQuality == ITEM_QUALITY_TRASH) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_NORMAL and SavedVariables.minQuality.jewelry > 1) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_MAGIC and SavedVariables.minQuality.jewelry > 2) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARCANE and SavedVariables.minQuality.jewelry > 3) then
							destroyItem = 1 end
						if(itemLinkQuality == ITEM_QUALITY_ARTIFACT and SavedVariables.minQuality.jewelry > 4) then
							destroyItem = 1 end
						--if the jewelry has a feature we want to keep, override the quality filter
						if(itemLinkTraitType ~= ITEM_TRAIT_TYPE_NONE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE and itemLinkTraitType ~= ITEM_TRAIT_TYPE_ARMOR_INTRICATE and SavedVariables.keepTraits.jewelry) then
							destroyItem = 0 end
						if(itemLinkTraitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE and SavedVariables.keepIntricate.jewelry) then
							destroyItem = 0 end
					end
				end
				--process blacksmith material and raw material and booster
				if(SavedVariables.enabled.blacksmithing) then
					if(itemLinkType == ITEMTYPE_BLACKSMITHING_MATERIAL and not SavedVariables.keepMaterial.blacksmithing) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL and not SavedVariables.keepMaterial.blacksmithing) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_BLACKSMITHING_BOOSTER and not SavedVariables.keepBooster.blacksmithing) then
						destroyItem = 1 end
				end
				--process clothier material and raw material
				if(SavedVariables.enabled.clothing) then
					if(itemLinkType == ITEMTYPE_CLOTHIER_MATERIAL and not SavedVariables.keepMaterial.clothing) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_CLOTHIER_RAW_MATERIAL and not SavedVariables.keepRawMaterial.clothing) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_CLOTHIER_BOOSTER and not SavedVariables.keepBooster.clothier) then
						destroyItem = 1 end
				end
				--process woodworking material and raw material
				if(SavedVariables.enabled.woodworking) then
					if(itemLinkType == ITEMTYPE_WOODWORKING_MATERIAL and not SavedVariables.keepMaterial.woodworking) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_WOODWORKING_RAW_MATERIAL and not SavedVariables.keepRawMaterial.woodworking) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_WOODWORKING_BOOSTER and not SavedVariables.keepBooster.woodworking) then
						destroyItem = 1 end
				end
				--process jewelry material and raw material
				if(SavedVariables.enabled.jewelry) then
					if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL and not SavedVariables.keepMaterial.jewelry) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL and not SavedVariables.keepRawMaterial.jewelry) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER and not SavedVariables.keepBooster.jewelry) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER and not SavedVariables.keepRawBooster.Jewelry) then
						destroyItem = 1 end
				end
				--process enchanting
				if(SavedVariables.enabled.enchanting) then
					if((itemLinkType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemLinkType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemLinkType == ITEMTYPE_ENCHANTING_RUNE_POTENCY) and not SavedVariables.keepRunes) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_GLYPH_ARMOR and not SavedVariables.keepArmorGlyphs) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_GLYPH_WEAPON and not SavedVariables.keepWeaponGlyphs) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_GLYPH_JEWELRY and not SavedVariables.keepJewelryGlyphs) then
						destroyItem = 1 end
				end
				--process provisioning
				if(SavedVariables.enabled.provisioning) then
					--removed until i figure out how to separate prov recipeis from other types (such as furnishing)
					--if(itemLinkType == ITEMTYPE_RECIPE and not SavedVariables.keepRecipes) then
						--destroyItem = 1 end
					if((itemLinkType == ITEMTYPE_FLAVORING or itemLinkType == ITEMTYPE_INGREDIENT or itemLinkType == ITEMTYPE_SPICE) and not SavedVariables.keepMaterial.provisioning) then
						destroyItem = 1 end
				end
				--process alchemy
				if(SavedVariables.enabled.alchemy) then
					if((itemLinkType == ITEMTYPE_ADDITIVE or itemLinkType == ITEMTYPE_POTION_BASE or itemLinkType == ITEMTYPE_POISON_BASE or itemLinkType == ITEMTYPE_REAGENT) and not SavedVariables.keepMaterial.alchemy) then
						destroyItem = 1 
					end
				end
				--process furnishing
				if(SavedVariables.enabled.furnishing) then
					if(itemLinkType == ITEMTYPE_FURNISHING_MATERIAL and not SavedVariables.keepMaterial.furnishing) then
						destroyItem = 1 end
					if(itemLinkType == ITEMTYPE_FURNISHING and not SavedVariables.keepFurnishing) then
						destroyItem = 1 end
				end
				if(destroyItem == 1) then
					if(SavedVariables.enabled.notifications) then d("InventoryUpkeep:Destroyed: "..itemLink)
					DestroyItem(BAG_BACKPACK,i) end
					destroyItem = 0
				end
end
function InventoryUpkeep:Initialize()
	self.name = "InventoryUpkeep"
	self.version = "1.7.0.0"
	self.author = "manyrabidrats"
    SavedVariables = ZO_SavedVars:New("InventoryUpkeepSavedVariables",1,nil,defaults)
    self.CreateSettingsMenu()
	EVENT_MANAGER:UnregisterForEvent(InventoryUpkeep.name, EVENT_ADD_ON_LOADED, InventoryUpkeep.OnAddOnLoaded)
	EVENT_MANAGER:RegisterForEvent("InventoryUpkeep_InventoryLootUpdate", EVENT_LOOT_RECEIVED , self.OnLootEvent)
	EVENT_MANAGER:RegisterForEvent("InventoryUpkeep_MailSendSuccessUpdate", EVENT_MAIL_SEND_SUCCESS, self.OnSendMailEvent)
end



function InventoryUpkeep.OnLootEvent(eventId,receivedBy,itemName,quantity,itemSound,lootType,self,isPickpocketLoot,questitemicon,itemId,isStolen)
	local bagsize
	local curslot
	local lootItemLink
	local cur_itemName
	lootItem_buffer[#lootItem_buffer+1] = itemName
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	
	while(table.getn(lootItem_buffer) > 0) do
		cur_itemName = table.remove(lootItem_buffer,1)
		while(curslot <= bagsize) do
			lootItemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
			if(cur_itemName == lootItemLink)then 
				processItem(curslot)
			end
			curslot = curslot+1
		end
	end
end



local function SendIUMail(itemsToSend,subject,recipeint)
	local nItems = table.getn(itemsToSend)
	local curRecipient = recipeint
	local curSubject = subject
	local curBody = ""
	local curAttachmentSlot = 1
	local curBagId = BAG_BACKPACK
	local curSlotIndex = 0
	
	if(curRecipient == "") then
		d("InventoryUpkeep:No recipient found")
	end
	
	ClearQueuedMail()
	--RequestOpenMailbox()
	--CloseMailbox()
	--CanQueueItemAttachment(curBagId,curSlotIndex,curAttachmentSlot)
	--RemoveQueuedItemAttachment(curAttachmentSlot)
	--QueueItemAttachment(curBagId,curSlotIndex,curAttachmentSlot)
	--SendMail(curRecipient,curSubject,curBody)
	
	RequestOpenMailbox()
	--attach items to mail
	while(curAttachmentSlot <= nItems) do
		curSlotIndex = table.remove(itemsToSend)
		if(CanQueueItemAttachment(curBagId,curSlotIndex,curAttachmentSlot) == true) then
			QueueItemAttachment(curBagId,curSlotIndex,curAttachmentSlot)
		end
		curAttachmentSlot = curAttachmentSlot+1
	end
	--fill in to and subject lines
	d("InventoryUpkeep:Sending mail to "..curRecipient)
	SendMail(curRecipient,curSubject,curBody)
	
	
end



local function SendBlacksmith()
	d("InventoryUpkeep:SendBlacksmith")
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		--local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		
		if(itemLinkType == ITEMTYPE_WEAPON)then
			local itemLinkWeaponType = GetItemWeaponType(BAG_BACKPACK,curslot)
			local itemLinkArmorType = GetItemArmorType(BAG_BACKPACK,curslot)
			local WeaponIsSmith = checkItemType(itemLinkType,itemLinkWeaponType,itemLinkArmorType,false)	
			if(WeaponIsSmith) then
				--add to itemsToSend if it is attachable
				if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
					table.insert(itemsToSend,curslot)
				end
			end
		end
		if(itemLinkType == ITEMTYPE_ARMOR)then
			local itemLinkArmorType = GetItemArmorType(BAG_BACKPACK,curslot)
			if(itemLinkArmorType == ARMORTYPE_HEAVY) then
				--add to itemsToSend if it is attachable
				if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
					table.insert(itemsToSend,curslot)
				end
			end
		end
		if(itemLinkType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemLinkType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or itemLinkType == ITEMTYPE_BLACKSMITHING_BOOSTER) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 1
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.blacksmithing,SavedVariables.mailTo.blacksmithing)
			return
		end
		curslot = curslot+1
	end
end
local function SendClothing()
	d("InventoryUpkeep:SendClothing")
	
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		--local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		if(itemLinkType == ITEMTYPE_ARMOR)then
			local itemLinkArmorType = GetItemArmorType(BAG_BACKPACK,curslot)
			if(itemLinkArmorType == ARMORTYPE_MEDIUM or itemLinkArmorType == ARMORTYPE_LIGHT) then
				--add to itemsToSend if it is attachable
				if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
					table.insert(itemsToSend,curslot)
				end
			end
		end
		if(itemLinkType == ITEMTYPE_CLOTHIER_MATERIAL or itemLinkType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or itemLinkType == ITEMTYPE_CLOTHIER_BOOSTER) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 2
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.clothing,SavedVariables.mailTo.clothing)
			return
		end
		curslot = curslot+1
	end
end
local function SendWoodworking()
	d("InventoryUpkeep:SendWoodworking")
	
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		--local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		
		if(itemLinkType == ITEMTYPE_WEAPON)then
			local itemLinkWeaponType = GetItemWeaponType(BAG_BACKPACK,curslot)
			local WeaponIsSmith = checkItemType(itemLinkType,itemLinkWeaponType,itemLinkArmorType,false)	
			if(not WeaponIsSmith) then
				--add to itemsToSend if it is attachable
				if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
					table.insert(itemsToSend,curslot)
				end
			end
		end
		if(itemLinkType == ITEMTYPE_WOODWORKING_MATERIAL or itemLinkType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or itemLinkType == ITEMTYPE_WOODWORKING_BOOSTER) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 3
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.woodworking,SavedVariables.mailTo.woodworking)
			return
		end
		curslot = curslot+1
	end
end
local function SendJewelry()
	d("InventoryUpkeep:SendJewelry")
	
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		
		if(itemLinkEquipType == EQUIP_TYPE_RING or itemLinkEquipType == EQUIP_TYPE_NECK) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end	
		end
		if(itemLinkType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or
			itemLinkType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or 
			itemLinkType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or 
			itemLinkType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 4
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.jewelry,SavedVariables.mailTo.jewelry)
			return
		end
		curslot = curslot+1
	end
end
local function SendEnchanting()
	d("InventoryUpkeep:SendEnchanting")
	
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		--local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		if(itemLinkType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or 
			itemLinkType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or 
			itemLinkType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or 
			itemLinkType == ITEMTYPE_GLYPH_ARMOR or 
			itemLinkType == ITEMTYPE_GLYPH_WEAPON or 
			itemLinkType == ITEMTYPE_GLYPH_JEWELRY) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 5
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.enchanting,SavedVariables.mailTo.enchanting)
			return
		end
		curslot = curslot+1
	end
end
local function SendAlchemy()
	d("InventoryUpkeep:SendAlchemy")
	
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		--local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		
		if(itemLinkType == ITEMTYPE_ADDITIVE or itemLinkType == ITEMTYPE_POTION_BASE or itemLinkType == ITEMTYPE_POISON_BASE or itemLinkType == ITEMTYPE_REAGENT) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end 
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 6
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.alchemy,SavedVariables.mailTo.alchemy)
			return
		end
		curslot = curslot+1
	end
end
local function SendProvisioning()
	d("InventoryUpkeep:SendProvisioning")
	
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		--local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		
		if(--itemLinkType == ITEMTYPE_RECIPE or -- disabled until recipe type can be determined
			itemLinkType == ITEMTYPE_FLAVORING or 
			itemLinkType == ITEMTYPE_INGREDIENT or 
			itemLinkType == ITEMTYPE_SPICE) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 7
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.provisioning,SavedVariables.mailTo.provisioning)
			return
		end
		curslot = curslot+1
	end
end
local function SendFurnishing()
	d("InventoryUpkeep:SendFurnishing")
	
	--if(mailingInProgress ~= 0) then
	--	return
	--end
	
	local bagsize
	local curslot
	local itemLink
	local itemsToSend = {}
	
	bagsize = GetBagSize(BAG_BACKPACK)
	curslot = 1
	while(curslot <= bagsize) do
		itemLink = GetItemLink(BAG_BACKPACK, curslot, LINK_STYLE_DEFAULT)
		local itemLinkType = GetItemLinkItemType(itemLink)
		local itemLinkName = GetItemLinkName(itemLink)
		--local itemLinkEquipType = GetItemLinkEquipType(itemLink)
		
		if(itemLinkType == ITEMTYPE_FURNISHING_MATERIAL or 
		itemLinkType == ITEMTYPE_FURNISHING) then
			--add to itemsToSend if it is attachable
			if(CanQueueItemAttachment(BAG_BACKPACK,curslot,1) == true) then
				table.insert(itemsToSend,curslot)
			end
		end
		if((table.getn(itemsToSend) == 6) or (curslot == bagsize and table.getn(itemsToSend) > 0)) then
			if(curslot < bagsize) then
				mailingInProgress = 8
			end
			SendIUMail(itemsToSend,SavedVariables.mailSubject.furnishing,SavedVariables.mailTo.furnishing)
			return
		end
		curslot = curslot+1
	end
end



function InventoryUpkeep.OnReceiveMailEvent(eventCode)
	if not BufferReached("InventoryUpkeepupdatebuffer", 1) then return; end
	--ReturnTheMail()
end
function InventoryUpkeep.OnSendMailEvent(eventCode)
	if not BufferReached("InventoryUpkeepupdatebuffer", 1) then return; end
	if(mailingInProgress > 0) then
		d("InventoryUpkeep:Sent mail successfully")
	end
	
	--need to put some kind of delay here, 1 or 2 seconds at least.
	
	if(mailingInProgress == 1) then
		mailingInProgress = 0
		CloseMailbox()
		SendBlacksmith()
	end
	if(mailingInProgress == 2) then
		mailingInProgress = 0
		CloseMailbox()
		SendClothing()
	end
	if(mailingInProgress == 3) then
		mailingInProgress = 0
		CloseMailbox()
		SendWoodworking()
	end
	if(mailingInProgress == 4) then
		mailingInProgress = 0
		CloseMailbox()
		SendJewelry()
	end
	if(mailingInProgress == 5) then
		mailingInProgress = 0
		CloseMailbox()
		SendEnchanting()
	end
	if(mailingInProgress == 6) then
		mailingInProgress = 0
		CloseMailbox()
		SendAlchemy()
	end
	if(mailingInProgress == 7) then
		mailingInProgress = 0
		CloseMailbox()
		SendProvisioning()
	end
	if(mailingInProgress == 8) then
		mailingInProgress = 0
		CloseMailbox()
		SendFurnishing()
	end
	if(mailingInProgress == 100) then
		mailingInProgress = 0
		CloseMailbox()
		--ReturnTheMail()
	end
end

function InventoryUpkeep.CreateSettingsMenu()
	
   local panelData = {
		  type = "panel",
		  name = "InventoryUpkeep",
		  displayName = "|cFFFFB0InventoryUpkeep|r",
		  author = InventoryUpkeep.author,
		  version = InventoryUpkeep.version,
		  slashcommand = "/iUpkeep",
		  registerForRefresh = true,
		  registerForDefaults = true
   }
   LAM:RegisterAddonPanel("InventoryUpkeep", panelData)
   
   local optionsTable = {
	 {
		type = "checkbox",
		name = "Enable notifications",
		tooltip = "Verbose activity information",
		getFunc = function () return SavedVariables.enabled.notifications end,
		setFunc = function (var) 
			SavedVariables.enabled.notifications = var
			return var 
			end,
		default = defaults.enabled.notifications,
	 },
	 {
		 type = "header",
		 name = "Blacksmithing",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.enabled.blacksmithing = var
			return var 
			end,
		default = defaults.enabled.blacksmithing,
	 },
	 {
		 type = "dropdown",
		 name = "Minimum quality to keep",
		 tooltip = "Select minimum quality to keep",
		 choices = item_qualities,
		 disabled = function() return not SavedVariables.enabled.blacksmithing end,
		 getFunc = function() return item_qualities[SavedVariables.minQuality.blacksmithing] end, 
		 setFunc = function(var)
			if(var == "White") then
				 SavedVariables.minQuality.blacksmithing = 1 end
			if(var == "Green") then
				 SavedVariables.minQuality.blacksmithing = 2 end
			if(var == "Blue") then
				SavedVariables.minQuality.blacksmithing = 3 end
			if(var == "Purple") then
				SavedVariables.minQuality.blacksmithing = 4 end
			if(var == "Yellow") then
				 SavedVariables.minQuality.blacksmithing = 5 end
			return item_qualities[SavedVariables.minQuality.blacksmithing]
		 end,
		 default = item_qualities[defaults.minQuality.blacksmithing],
	 },
	 {
		type = "checkbox",
		name = "Keep intricate",
		tooltip = "Keep items with the intricate property",
		disabled = function() return not SavedVariables.enabled.blacksmithing end,
		getFunc = function () return SavedVariables.keepIntricate.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.keepIntricate.blacksmithing = var
			return var 
			end,
		default = defaults.keepIntricate.blacksmithing,
	 },
	 {
		type = "checkbox",
		name = "Keep ornate",
		tooltip = "Keep items with the ornate property",
		disabled = function() return not SavedVariables.enabled.blacksmithing end,
		getFunc = function () return SavedVariables.keepOrnate.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.keepOrnate.blacksmithing = var
			return var 
			end,
		default = defaults.keepOrnate.blacksmithing,
	 },
	 {
		type = "checkbox",
		name = "Keep traits",
		tooltip = "Keep items with traits",
		disabled = function() return not SavedVariables.enabled.blacksmithing end,
		getFunc = function () return SavedVariables.keepTraits.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.keepTraits.blacksmithing = var
			return var 
			end,
		default = defaults.keepTraits.blacksmithing,
	 }, 
	 {
		type = "checkbox",
		name = "Keep booster stones",
		tooltip = "Keep booster materials",
		disabled = function() return not SavedVariables.enabled.blacksmithing end,
		getFunc = function () return SavedVariables.keepBooster.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.keepBooster.blacksmithing = var
			return var 
			end,
		default = defaults.keepBooster.blacksmithing,
	 },
	 {
		type = "checkbox",
		name = "Keep materials",
		tooltip = "Keep crafting materials",
		disabled = function() return not SavedVariables.enabled.blacksmithing end,
		getFunc = function () return SavedVariables.keepMaterial.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.keepMaterial.blacksmithing = var
			return var 
			end,
		default = defaults.keepMaterial.blacksmithing,
	 },
	 {
		type = "checkbox",
		name = "Keep raw materials",
		tooltip = "Keep raw crafting materials",
		disabled = function() return not SavedVariables.enabled.blacksmithing end,
		getFunc = function () return SavedVariables.keepRawMaterial.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.keepRawMaterial.blacksmithing = var
			return var 
			end,
		default = defaults.keepRawMaterial.blacksmithing,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendBlacksmith,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.mailSubject.blacksmithing = var
			return var 
			end,
		default = defaults.mailSubject.blacksmithing,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.blacksmithing end,
		setFunc = function (var) 
			SavedVariables.mailTo.blacksmithing = var
			return var 
			end,
		default = defaults.mailTo.blacksmithing,
	 },
	 {
		 type = "header",
		 name = "Clothing",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.clothing end,
		setFunc = function (var) 
			SavedVariables.enabled.clothing = var
			return var 
			end,
		default = defaults.enabled.clothing,
	 },
	 {
		 type = "dropdown",
		 name = "Minimum quality to keep",
		 tooltip = "Select minimum quality to keep",
		 choices = item_qualities,
		 disabled = function() return not SavedVariables.enabled.clothing end,
		 getFunc = function() return item_qualities[SavedVariables.minQuality.clothing] end, 
		 setFunc = function(var)
			if(var == "White") then
				 SavedVariables.minQuality.clothing = 1 end
			if(var == "Green") then
				 SavedVariables.minQuality.clothing = 2 end
			if(var == "Blue") then
				SavedVariables.minQuality.clothing = 3 end
			if(var == "Purple") then
				SavedVariables.minQuality.clothing = 4 end
			if(var == "Yellow") then
				 SavedVariables.minQuality.clothing = 5 end
			return item_qualities[SavedVariables.minQuality.clothing]
		 end,
		 default = item_qualities[defaults.minQuality.clothing],
	 },
	 {
		type = "checkbox",
		name = "Keep intricate",
		tooltip = "Keep items with the intricate property",
		disabled = function() return not SavedVariables.enabled.clothing end,
		getFunc = function () return SavedVariables.keepIntricate.clothing end,
		setFunc = function (var) 
			SavedVariables.keepIntricate.clothing = var
			return var 
			end,
		default = defaults.keepIntricate.clothing,
	 },
	 {
		type = "checkbox",
		name = "Keep ornate",
		tooltip = "Keep items with the ornate property",
		disabled = function() return not SavedVariables.enabled.clothing end,
		getFunc = function () return SavedVariables.keepOrnate.clothing end,
		setFunc = function (var) 
			SavedVariables.keepOrnate.clothing = var
			return var 
			end,
		default = defaults.keepOrnate.clothing,
	 },
	 {
		type = "checkbox",
		name = "Keep traits",
		tooltip = "Keep items with traits",
		disabled = function() return not SavedVariables.enabled.clothing end,
		getFunc = function () return SavedVariables.keepTraits.clothing end,
		setFunc = function (var) 
			SavedVariables.keepTraits.clothing = var
			return var 
			end,
		default = defaults.keepTraits.clothing,
	 },
	 {
		type = "checkbox",
		name = "Keep booster stones",
		tooltip = "Keep booster materials",
		disabled = function() return not SavedVariables.enabled.clothing end,
		getFunc = function () return SavedVariables.keepBooster.clothing end,
		setFunc = function (var) 
			SavedVariables.keepBooster.clothing = var
			return var 
			end,
		default = defaults.keepBooster.clothing,
	 }, 
	 {
		type = "checkbox",
		name = "Keep materials",
		tooltip = "Keep crafting materials",
		disabled = function() return not SavedVariables.enabled.clothing end,
		getFunc = function () return SavedVariables.keepMaterial.clothing end,
		setFunc = function (var) 
			SavedVariables.keepMaterial.clothing = var
			return var 
			end,
		default = defaults.keepMaterial.clothing,
	 },
	 {
		type = "checkbox",
		name = "Keep raw materials",
		tooltip = "Keep raw crafting materials",
		disabled = function() return not SavedVariables.enabled.clothing end,
		getFunc = function () return SavedVariables.keepRawMaterial.clothing end,
		setFunc = function (var) 
			SavedVariables.keepRawMaterial.clothing = var
			return var 
			end,
		default = defaults.keepRawMaterial.clothing,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendClothing,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.clothing end,
		setFunc = function (var) 
			SavedVariables.mailSubject.clothing = var
			return var 
			end,
		default = defaults.mailSubject.clothing,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.clothing end,
		setFunc = function (var) 
			SavedVariables.mailTo.clothing = var
			return var 
			end,
		default = defaults.mailTo.clothing,
	 },
	 {
		 type = "header",
		 name = "Woodworking",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.woodworking end,
		setFunc = function (var) 
			SavedVariables.enabled.woodworking = var
			return var 
			end,
		default = defaults.enabled.woodworking,
	 },
	 {
		 type = "dropdown",
		 name = "Minimum quality to keep",
		 tooltip = "Select minimum quality to keep",
		 choices = item_qualities,
		 disabled = function() return not SavedVariables.enabled.woodworking end,
		 getFunc = function() return item_qualities[SavedVariables.minQuality.woodworking] end, 
		 setFunc = function(var)
			if(var == "White") then
				 SavedVariables.minQuality.woodworking = 1 end
			if(var == "Green") then
				 SavedVariables.minQuality.woodworking = 2 end
			if(var == "Blue") then
				SavedVariables.minQuality.woodworking = 3 end
			if(var == "Purple") then
				SavedVariables.minQuality.woodworking = 4 end
			if(var == "Yellow") then
				 SavedVariables.minQuality.woodworking = 5 end
			return item_qualities[SavedVariables.minQuality.woodworking]
		 end,
		 default = item_qualities[defaults.minQuality.woodworking],
	 },
	 {
		type = "checkbox",
		name = "Keep intricate",
		tooltip = "Keep items with the intricate property",
		disabled = function() return not SavedVariables.enabled.woodworking end,
		getFunc = function () return SavedVariables.keepIntricate.woodworking end,
		setFunc = function (var) 
			SavedVariables.keepIntricate.woodworking = var
			return var 
			end,
		default = defaults.keepIntricate.woodworking,
	 },
	 {
		type = "checkbox",
		name = "Keep ornate",
		tooltip = "Keep items with the ornate property",
		disabled = function() return not SavedVariables.enabled.woodworking end,
		getFunc = function () return SavedVariables.keepOrnate.woodworking end,
		setFunc = function (var) 
			SavedVariables.keepOrnate.woodworking = var
			return var 
			end,
		default = defaults.keepOrnate.woodworking,
	 },
	 {
		type = "checkbox",
		name = "Keep traits",
		tooltip = "Keep items with traits",
		disabled = function() return not SavedVariables.enabled.woodworking end,
		getFunc = function () return SavedVariables.keepTraits.woodworking end,
		setFunc = function (var) 
			SavedVariables.keepTraits.woodworking = var
			return var 
			end,
		default = defaults.keepTraits.woodworking,
	 },
	 {
		type = "checkbox",
		name = "Keep booster stones",
		tooltip = "Keep booster materials",
		disabled = function() return not SavedVariables.enabled.woodworking end,
		getFunc = function () return SavedVariables.keepBooster.woodworking end,
		setFunc = function (var) 
			SavedVariables.keepBooster.woodworking = var
			return var 
			end,
		default = defaults.keepBooster.woodworking,
	 }, 
	 {
		type = "checkbox",
		name = "Keep materials",
		tooltip = "Keep crafting materials",
		disabled = function() return not SavedVariables.enabled.woodworking end,
		getFunc = function () return SavedVariables.keepMaterial.woodworking end,
		setFunc = function (var) 
			SavedVariables.keepMaterial.woodworking = var
			return var 
			end,
		default = defaults.keepMaterial.woodworking,
	 },
	 {
		type = "checkbox",
		name = "Keep raw materials",
		tooltip = "Keep raw crafting materials",
		disabled = function() return not SavedVariables.enabled.woodworking end,
		getFunc = function () return SavedVariables.keepRawMaterial.woodworking end,
		setFunc = function (var) 
			SavedVariables.keepRawMaterial.woodworking = var
			return var 
			end,
		default = defaults.keepRawMaterial.woodworking,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendWoodworking,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.woodworking end,
		setFunc = function (var) 
			SavedVariables.mailSubject.woodworking = var
			return var 
			end,
		default = defaults.mailSubject.woodworking,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.woodworking end,
		setFunc = function (var) 
			SavedVariables.mailTo.woodworking = var
			return var 
			end,
		default = defaults.mailTo.woodworking,
	 },
	 {
		 type = "header",
		 name = "Jewelry",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.jewelry end,
		setFunc = function (var) 
			SavedVariables.enabled.jewelry = var
			return var 
			end,
		default = defaults.enabled.jewelry,
	 },
	 {
		 type = "dropdown",
		 name = "Minimum quality to keep",
		 tooltip = "Select minimum quality to keep",
		 choices = item_qualities,
		 disabled = function() return not SavedVariables.enabled.jewelry end,
		 getFunc = function() return item_qualities[SavedVariables.minQuality.jewelry] end, 
		 setFunc = function(var)
			if(var == "White") then
				 SavedVariables.minQuality.jewelry = 1 end
			if(var == "Green") then
				 SavedVariables.minQuality.jewelry = 2 end
			if(var == "Blue") then
				SavedVariables.minQuality.jewelry = 3 end
			if(var == "Purple") then
				SavedVariables.minQuality.jewelry = 4 end
			if(var == "Yellow") then
				 SavedVariables.minQuality.jewelry = 5 end
			return item_qualities[SavedVariables.minQuality.jewelry]
		 end,
		 default = item_qualities[defaults.minQuality.jewelry],
	 },
	 {
		type = "checkbox",
		name = "Keep intricate",
		tooltip = "Keep items with the intricate property",
		disabled = function() return not SavedVariables.enabled.jewelry end,
		getFunc = function () return SavedVariables.keepIntricate.jewelry end,
		setFunc = function (var) 
			SavedVariables.keepIntricate.jewelry = var
			return var 
			end,
		default = defaults.keepIntricate.jewelry,
	 },
	 {
		type = "checkbox",
		name = "Keep ornate",
		tooltip = "Keep items with the ornate property",
		disabled = function() return not SavedVariables.enabled.jewelry end,
		getFunc = function () return SavedVariables.keepOrnate.jewelry end,
		setFunc = function (var) 
			SavedVariables.keepOrnate.jewelry = var
			return var 
			end,
		default = defaults.keepOrnate.jewelry,
	 },
	 {
		type = "checkbox",
		name = "Keep traits",
		tooltip = "Keep items with traits",
		disabled = function() return not SavedVariables.enabled.jewelry end,
		getFunc = function () return SavedVariables.keepTraits.jewelry end,
		setFunc = function (var) 
			SavedVariables.keepTraits.jewelry = var
			return var 
			end,
		default = defaults.keepTraits.jewelry,
	 },
	 {
		type = "checkbox",
		name = "Keep booster stones",
		tooltip = "Keep booster materials",
		disabled = function() return not SavedVariables.enabled.jewelry end,
		getFunc = function () return SavedVariables.keepBooster.jewelry end,
		setFunc = function (var) 
			SavedVariables.keepBooster.jewelry = var
			return var 
			end,
		default = defaults.keepBooster.jewelry,
	 }, 
	 {
		type = "checkbox",
		name = "Keep raw booster stones",
		tooltip = "Keep raw booster materials",
		disabled = function() return not SavedVariables.enabled.jewelry end,
		getFunc = function () return SavedVariables.keepRawBooster.jewelry end,
		setFunc = function (var) 
			SavedVariables.keepRawBooster.jewelry = var
			return var 
			end,
		default = defaults.keepRawBooster.jewelry,
	 }, 
	 {
		type = "checkbox",
		name = "Keep materials",
		tooltip = "Keep crafting materials",
		disabled = function() return not SavedVariables.enabled.jewelry end,
		getFunc = function () return SavedVariables.keepMaterial.jewelry end,
		setFunc = function (var) 
			SavedVariables.keepMaterial.jewelry = var
			return var 
			end,
		default = defaults.keepMaterial.jewelry,
	 },
	 {
		type = "checkbox",
		name = "Keep raw materials",
		tooltip = "Keep raw crafting materials",
		disabled = function() return not SavedVariables.enabled.jewelry end,
		getFunc = function () return SavedVariables.keepRawMaterial.jewelry end,
		setFunc = function (var) 
			SavedVariables.keepRawMaterial.jewelry = var
			return var 
			end,
		default = defaults.keepRawMaterial.jewelry,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendJewelry,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.jewelry end,
		setFunc = function (var) 
			SavedVariables.mailSubject.jewelry = var
			return var 
			end,
		default = defaults.mailSubject.jewelry,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.jewelry end,
		setFunc = function (var) 
			SavedVariables.mailTo.jewelry = var
			return var 
			end,
		default = defaults.mailTo.jewelry,
	 },
	 {
		 type = "header",
		 name = "Enchanting",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.enchanting end,
		setFunc = function (var) 
			SavedVariables.enabled.enchanting = var
			return var 
			end,
		default = defaults.enabled.enchanting,
	 },
	 {
		type = "checkbox",
		name = "Keep Runes",
		tooltip = "Enable to keep runes",
		disabled = function() return not SavedVariables.enabled.enchanting end,
		getFunc = function () return SavedVariables.keepRunes end,
		setFunc = function (var) 
			SavedVariables.keepRunes = var
			return var 
			end,
		default = defaults.keepRunes,
	 },
	 {
		type = "checkbox",
		name = "Keep armor glyphs",
		tooltip = "Keep glyphs for armor",
		disabled = function() return not SavedVariables.enabled.enchanting end,
		getFunc = function () return SavedVariables.keepArmorGlyphs end,
		setFunc = function (var) 
			SavedVariables.keepArmorGlyphs = var
			return var 
			end,
		default = defaults.keepArmorGlyphs,
	 }, 
	 {
		type = "checkbox",
		name = "Keep weapon glyphs",
		tooltip = "Keep glyphs for weapons",
		disabled = function() return not SavedVariables.enabled.enchanting end,
		getFunc = function () return SavedVariables.keepWeaponGlyphs end,
		setFunc = function (var) 
			SavedVariables.keepWeaponGlyphs = var
			return var 
			end,
		default = defaults.keepWeaponGlyphs,
	 },
	 {
		type = "checkbox",
		name = "Keep jewelry glyphs",
		tooltip = "Keep glyphs for jewelry",
		disabled = function() return not SavedVariables.enabled.enchanting end,
		getFunc = function () return SavedVariables.keepJewelryGlyphs end,
		setFunc = function (var) 
			SavedVariables.keepJewelryGlyphs = var
			return var 
			end,
		default = defaults.keepJewelryGlyphs,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendEnchanting,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.enchanting end,
		setFunc = function (var) 
			SavedVariables.mailSubject.enchanting = var
			return var 
			end,
		default = defaults.mailSubject.enchanting,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.enchanting end,
		setFunc = function (var) 
			SavedVariables.mailTo.enchanting = var
			return var 
			end,
		default = defaults.mailTo.enchanting,
	 },
	 {
		 type = "header",
		 name = "Provisioning",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.provisioning end,
		setFunc = function (var) 
			SavedVariables.enabled.provisioning = var
			return var 
			end,
		default = defaults.enabled.provisioning,
	 },
	 --{
	--	type = "checkbox",
	--	name = "Keep recipes",
	--	tooltip = "Keep recipes to learn",
	--	disabled = function() return not SavedVariables.enabled.provisioning end,
	--	getFunc = function () return SavedVariables.keepRecipes end,
	--	setFunc = function (var) 
	--		SavedVariables.keepRecipes = var
	--		return var 
	--		end,
	--	default = defaults.keepRecipes,
	--},
	 {
		type = "checkbox",
		name = "Keep materials",
		tooltip = "Keep crafting materials",
		disabled = function() return not SavedVariables.enabled.provisioning end,
		getFunc = function () return SavedVariables.keepMaterial.provisioning end,
		setFunc = function (var) 
			SavedVariables.keepMaterial.provisioning = var
			return var 
			end,
		default = defaults.keepMaterial.provisioning,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendProvisioning,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.provisioning end,
		setFunc = function (var) 
			SavedVariables.mailSubject.provisioning = var
			return var 
			end,
		default = defaults.mailSubject.provisioning,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.provisioning end,
		setFunc = function (var) 
			SavedVariables.mailTo.provisioning = var
			return var 
			end,
		default = defaults.mailTo.provisioning,
	 },
     {
		 type = "header",
		 name = "Alchemy",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.alchemy end,
		setFunc = function (var) 
			SavedVariables.enabled.alchemy = var
			return var 
			end,
		default = defaults.enabled.alchemy,
	 },
	 {
		type = "checkbox",
		name = "Keep materials",
		tooltip = "Keep crafting materials",
		disabled = function() return not SavedVariables.enabled.alchemy end,
		getFunc = function () return SavedVariables.keepMaterial.alchemy end,
		setFunc = function (var) 
			SavedVariables.keepMaterial.alchemy = var
			return var 
			end,
		default = defaults.keepMaterial.alchemy,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendAlchemy,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.alchemy end,
		setFunc = function (var) 
			SavedVariables.mailSubject.alchemy = var
			return var 
			end,
		default = defaults.mailSubject.alchemy,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.alchemy end,
		setFunc = function (var) 
			SavedVariables.mailTo.alchemy = var
			return var 
			end,
		default = defaults.mailTo.alchemy,
	 },
     {
		 type = "header",
		 name = "Furnishing",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.furnishing end,
		setFunc = function (var) 
			SavedVariables.enabled.furnishing = var
			return var 
			end,
		default = defaults.enabled.furnishing,
	 },
	 {
		type = "checkbox",
		name = "Keep furnishing",
		tooltip = "Keep furnishing items",
		disabled = function() return not SavedVariables.enabled.furnishing end,
		getFunc = function () return SavedVariables.keepFurnishing end,
		setFunc = function (var) 
			SavedVariables.keepFurnishing = var
			return var 
			end,
		default = defaults.keepFurnishing,
	 },
	 {
		type = "checkbox",
		name = "Keep materials",
		tooltip = "Keep crafting materials",
		disabled = function() return not SavedVariables.enabled.furnishing end,
		getFunc = function () return SavedVariables.keepMaterial.furnishing end,
		setFunc = function (var) 
			SavedVariables.keepMaterial.furnishing = var
			return var 
			end,
		default = defaults.keepMaterial.furnishing,
	 },
	 {
		type = "button",
		name = "Run auto-mail",
		tooltip = "Send all items blacksmith related to Recipient specified below",
		func = SendFurnishing,
		width = "full",
		isDangerous = true
	 },
	 {
		type = "editbox",
		name = "Subject",
		tooltip = "What should go in the Subject line of the mail",
		getFunc = function () return SavedVariables.mailSubject.furnishing end,
		setFunc = function (var) 
			SavedVariables.mailSubject.furnishing = var
			return var 
			end,
		default = defaults.mailSubject.furnishing,
	 },
	 {
		type = "editbox",
		name = "Recipient",
		tooltip = "Who should receive items of this catagory",
		getFunc = function () return SavedVariables.mailTo.furnishing end,
		setFunc = function (var) 
			SavedVariables.mailTo.furnishing = var
			return var 
			end,
		default = defaults.mailTo.furnishing,
	 },
	 {
		 type = "header",
		 name = "Misc",
	 },
	 {
		type = "checkbox",
		name = "Enable catagory",
		tooltip = "Enable this section's filter and mail",
		getFunc = function () return SavedVariables.enabled.misc end,
		setFunc = function (var) 
			SavedVariables.enabled.misc = var
			return var 
			end,
		default = defaults.enabled.misc,
	 },
	 {
		type = "checkbox",
		name = "Keep lures",
		tooltip = "Keep fishing lures",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepLures end,
		setFunc = function (var) 
			SavedVariables.keepLures = var
			return var 
			end,
		default = defaults.keepLures,
	 },
	 {
		type = "checkbox",
		name = "Keep trophies",
		tooltip = "Keep collectable trophies",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepTrophies end,
		setFunc = function (var) 
			SavedVariables.keepTrophies = var
			return var 
			end,
		default = defaults.keepTrophies,
	 },
	 {
		type = "checkbox",
		name = "Keep motifs",
		tooltip = "Keep crafting motifs for different styles",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepMotifs end,
		setFunc = function (var) 
			SavedVariables.keepMotifs = var
			return var 
			end,
		default = defaults.keepMotifs,
	 },
	 {
		type = "checkbox",
		name = "Keep Style Material",
		tooltip = "Keep Racial Style Material for crafting",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepStyles end,
		setFunc = function (var) 
			SavedVariables.keepStyles = var
			return var 
			end,
		default = defaults.keepStyles,
	 },
	 {
		type = "checkbox",
		name = "Keep Weapon Trait Stones",
		tooltip = "Keep Weapon Trait stones for crafting",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepWeaponTraitStones end,
		setFunc = function (var) 
			SavedVariables.keepWeaponTraitStones = var
			return var 
			end,
		default = defaults.keepWeaponTraitStones,
	 },
	 {
		type = "checkbox",
		name = "Keep Armor Trait Stones",
		tooltip = "Keep Armor Trait stones for crafting",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepArmorTraitStones end,
		setFunc = function (var) 
			SavedVariables.keepArmorTraitStones = var
			return var 
			end,
		default = defaults.keepArmorTraitStones,
	 },
	 {
		type = "checkbox",
		name = "Keep Jewelry Trait Stones",
		tooltip = "Keep Jewelry Trait stones for crafting",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepJewelryTraitStones end,
		setFunc = function (var) 
			SavedVariables.keepJewelryTraitStones = var
			return var 
			end,
		default = defaults.keepJewelryTraitStones,
	 },
	 {
		type = "checkbox",
		name = "Keep food",
		tooltip = "NomNomNom",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepFood end,
		setFunc = function (var) 
			SavedVariables.keepFood = var
			return var 
			end,
		default = defaults.keepFood,
	 },
	 {
		type = "checkbox",
		name = "Keep beverages",
		tooltip = "GlugGlugGlug",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepDrink end,
		setFunc = function (var) 
			SavedVariables.keepDrink = var
			return var 
			end,
		default = defaults.keepDrink,
	 },
	 {
		type = "checkbox",
		name = "Keep trash",
		tooltip = "One man's trash is another man's treasure",
		disabled = function() return not SavedVariables.enabled.misc end,
		getFunc = function () return SavedVariables.keepTrash end,
		setFunc = function (var) 
			SavedVariables.keepTrash = var
			return var 
			end,
		default = defaults.keepTrash,
	 },
   }
   
   LAM:RegisterOptionControls("InventoryUpkeep", optionsTable)
 end


 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function InventoryUpkeep.OnAddOnLoaded(eventCode, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  
   if (addonName == "InventoryUpkeep") then
		InventoryUpkeep:Initialize()
   end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent("InventoryUpkeep", EVENT_ADD_ON_LOADED, InventoryUpkeep.OnAddOnLoaded)