--------------------------------------------------------------------------------------
-- Title: |cedf762LootManager|r 1.4													--
-- Author: |cef9a2ccOOLsp0T|r														--
-- Description: A full adjustable Loot Manager which destroys filtered out items.	--
-- APIVersion: 100028																--
-- Version: 1.6																		--
-- AddOnVersion: 1																	--
-- SavedVariables: LootManagerConfig												--
-- OptionalDependsOn: LibAddonMenu-2.0												--
--------------------------------------------------------------------------------------

				--- Create Namespace ---
local LootManager = {}
				--- Object Strings ---
LootManager.Name = "LootManager"
LootManager.ManagerDebugMark = "— |cef9a2cLootMgr|r: "
InventoryFullTag = LootManager.ManagerDebugMark.."|cdc1f1fYour Inventory is full!|r"
StatusTag = {
	[true] = " — |c33ff00Activated|r —",
	[false] = " — |cdc1f1fDeactivated|r —",
}

					--- Player Combat State ---
LootManager.isPlayerInCombat = false
					--- Loot State Variables ---
LootManager.isLooting = false
LootManager.isLastItem = false
LootManager.isCrime = false
					--- Loot Item Variables ---
LootManager.RecentLootItemLink = nil
LootManager.RecentInventoryItemLink = nil
LootManager.RecentLootGUID = nil
LootManager.RecentInvGUID = nil
LootManager.RecentStackSize = nil
LootManager.RecentBagID = nil
LootManager.RecentSlotID = nil
LootManager.RecentNewSlotID = nil

local defaults = {
	GeneralSettings = {
		AddonVersion = "|c46c6f51.6|r",
		Debug = "Actions",
		ManagerEnabled = true,
		LootStolen = true,
		ShowEmpty = true,
		Wait_MS = 100,
	},
	GeneralFilterSettings = {
		LootValue = 0,
		LootOrnate = true,
		LootSoulGems = true,
		LootLockpicks = true,
		LootHealthPotions = true,
		LootStaminaPotions = true,
		LootMagickaPotions = true,
		LootWeaponGlyphs = 1,
		LootArmorGlyphs = 1,
		LootJewelryGlyphs = 1,
		LootPoisons = true,
		LootQuality = 1,
		LootStyleMaterial = true,
		LootStyleRawMaterial = true,
		MaterialFilter = true,
		WeaponFilter = true,
		ArmorFilter = true,
		JewelryFilter = true,
		RecipeFilter = "Every",
	},
	MaterialFilterSettings = {
		LootAlchemy = true,
		LootClothing = true,
		LootSmithing = true,
		LootWood = true,
		LootRunes = true,
		LootCooking = true,
		LootFurnish = true,
		LootJewelry = true,
	},
	WeaponFilterSettings = {
		Dagger = 1,
		OHSword = 1,
		OHHammer = 1,
		OHAxe = 1,
		THSword = 1,
		THHammer = 1,
		THAxe = 1,
		ResearchSmithWeaponTraits = false,
		MetalWeaponIntricate = true,
		Shield = 1,
		Bow = 1,
		FireStaff = 1,
		FrostStaff = 1,
		LightningStaff = 1,
		HealingStaff = 1,
		ResearchWoodWeaponTraits = false,
		WoodenWeaponIntricate = true,
	},
	ArmorFilterSettings = {
		JewelryArmor = 1,
		LightArmor = 1,
		MediumArmor = 1,
		ResearchJewelryTrait = false,
		ResearchClothArmorTrait = false,
		JewelryArmorIntricate = true,
		ClothArmorIntricate = true,
		HeavyArmor = 1,
		ResearchSmithArmorTrait = false,
		SmithArmorIntricate = true,
	},
}
				--- Panel Menu Disable Conditions ---
function LootManager.MenuCondition(funcID)
	local condition = false
	if Config.GeneralSettings.ManagerEnabled then
		if funcID == 0 and not Config.GeneralFilterSettings.MaterialFilter then condition = true end
		if funcID == 1 and not Config.GeneralFilterSettings.WeaponFilter then condition = true end
		if funcID == 2 and not Config.GeneralFilterSettings.ArmorFilter then condition = true end
	else 
		condition = true
	end
	return condition
end
									--- Initiate Addon ---
function LootManager.Init(event, addonName)
	if addonName ~= LootManager.Name then return end
	EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_PLAYER_ACTIVATED, LootManager_ActivateManager)
						--- Init Menu Panel ---
	LootManager.ConfigPanel()
						--- Hook Reticle ---
	HookReticleTake()
end	
										--- Control Panel ---
function LootManager.ConfigPanel()
	LAM = LibAddonMenu2
								--- Check for Update & Declare User Variables ---
	Config = ZO_SavedVars:New("LootManagerConfig", 1, nil, defaults)
	
	if defaults.GeneralSettings.AddonVersion ~= Config.GeneralSettings.AddonVersion then
		d(LootManager.ManagerDebugMark.."|c46c6f5Old Saved Variables of |cef9a2ccOOLsp0T's|r Loot Manager |c46c6f5was detected!|r")
		Config = ZO_SavedVars:New("LootManagerConfig", 2, nil, defaults)
		d(LootManager.ManagerDebugMark.."|c46c6f5Saved Variables was renewed! Please reconfigurate the Addon!|r")
	end
				--- Build Menu ---
	local panelData = {
		type = "panel",
		name = "cOOLsp0t's Loot Manager",
		displayName = "|cffff00— cOOLsp0t's |cef9a2cLoot Manager |cffff00—|r",
		author = "|cef9a2ccOOLsp0T|r",
		version = Config.GeneralSettings.AddonVersion,
		website = "https://www.esoui.com/downloads/info2433-cOOLsp0tsLootManager.html",
		feedback = "https://www.esoui.com/downloads/info2433-cOOLsp0tsLootManager.html#comments",
		donation = "https://www.esoui.com/downloads/info2433-cOOLsp0tsLootManager.html#donate",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local optionsTable = {
		[1] = {
			type = "divider",
			height = 10,
			alpha = 1.0,
			width = "full",
		},
		[2] = {
			type = "checkbox",
			name = "Enable Loot Manager",
			getFunc = function() return Config.GeneralSettings.ManagerEnabled end,
			setFunc = function(value) Config.GeneralSettings.ManagerEnabled = value LootManager_ActivateManager() end,
			width = "full",
		},
		[3] = {
			type = "checkbox",
			name = "Activate Thief Mode",
			tooltip = "When Thief Mode is deactivated will Loot Manager prevent you from stealing & lockpicking! Also will all reticle information about stealing & lockpicking be hide.",
			getFunc = function() return Config.GeneralSettings.LootStolen end,
			setFunc = function(value) Config.GeneralSettings.LootStolen = value end,
			disabled = function() return not Config.GeneralSettings.ManagerEnabled end,
			width = "full",
		},
		[4] = {
			type = "checkbox",
			name = "Show Empty Container",
			tooltip = "Loot Manager can hide the reticle info on empty barrels & crates",
			getFunc = function() return Config.GeneralSettings.ShowEmpty end,
			setFunc = function(value) Config.GeneralSettings.ShowEmpty = value end,
			disabled = function() return not Config.GeneralSettings.ManagerEnabled end,
			width = "full",
		},
		[5] = {
			type = "dropdown",
			name = "Info Output",
			tooltip = "Set the Log Output Mode",
			choices = {"Silent", "Actions"},
			getFunc = function() return Config.GeneralSettings.Debug end,
			setFunc = function(value) Config.GeneralSettings.Debug = value end,
			disabled = function() return not Config.GeneralSettings.ManagerEnabled end,
			width = "full",
		},
		[6] = {
			type = "divider",
			height = 10,
			alpha = 1.0,
			width = "full",
		},
--		[6] = {
--			type = "description",
--			title = nil,
--			text = "        — Troubleshooting —————————————— Milliseconds —",
--			width = "full",
--		},
--		[7] = {
--			type = "slider",
--			name = "Update Interval per Milliseconds",
--			tooltip = "If your Computer has low Framerates raise this Value",
--			min = 80,
--			max = 2000,
--			getFunc = function() return Config.GeneralSettings.Wait_MS end,
--			setFunc = function(value) Config.GeneralSettings.Wait_MS = value end,
--			width = "full",
--			warning = "Its on your won Responsibility to set the value below the standard of 100ms!",
--		},
		[7] = {
			type = "submenu",
			name = "General Filter Settings",
			icon = "/esoui/art/icons/housing_bre_con_moneybag001.dds",
			disabled = function() return not Config.GeneralSettings.ManagerEnabled end,
			controls = {
				[1] = {
					type = "description",
					title = nil,
					text = "        ———————— General Filter Management ————————",
					width = "full",
				},
				[2] = {
					type = "checkbox",
					name = "Enable Material Filter",
					tooltip = "De/Activates the Material Filter",
					getFunc = function() return Config.GeneralFilterSettings.MaterialFilter end,
					setFunc = function(value) Config.GeneralFilterSettings.MaterialFilter = value end,
					width = "full",
				},
				[3] = {
					type = "checkbox",
					name = "Enable Weapon Filter",
					tooltip = "De/Activates the Weapon Filter",
					getFunc = function() return Config.GeneralFilterSettings.WeaponFilter end,
					setFunc = function(value) Config.GeneralFilterSettings.WeaponFilter = value d("test") end,
					width = "full",
				},
				[4] = {
					type = "checkbox",
					name = "Enable Armor Filter",
					tooltip = "De/Activates the Armor Filter",
					getFunc = function() return Config.GeneralFilterSettings.ArmorFilter end,
					setFunc = function(value) Config.GeneralFilterSettings.ArmorFilter = value end,
					width = "full",
				},
				[5] = {
					type = "description",
					title = nil,
					text = "        ————————  Clutter Filter Management  ————————",
					width = "full",
				},
				[6] = {
					type = "slider",
					name = "Common Loot Quality",
					icon = "/esoui/art/crafting/smithing_tabicon_improve_up.dds",
					tooltip = "Set Quality Treshhold for looting Common Items. Value 6 will stop loot Common Items",
					min = 0,
					max = 6,
					getFunc = function() return Config.GeneralFilterSettings.LootQuality end,
					setFunc = function(value) Config.GeneralFilterSettings.LootQuality = value end,
					width = "full",
				},
				[7] = {
					type = "slider",
					name = "Common Loot Value",
					tooltip = "Sets the common Loot value filter depth",
					min = 0,
					max = 5000,
					getFunc = function() return Config.GeneralFilterSettings.LootValue end,
					setFunc = function(value) Config.GeneralFilterSettings.LootValue = value end,
					width = "full",
				},
				[8] = {
					type = "checkbox",
					name = "Loot Ornate Items",
					tooltip = "De/Activates Loot Manager for Ornate Items",
					getFunc = function() return Config.GeneralFilterSettings.LootOrnate end,
					setFunc = function(value) Config.GeneralFilterSettings.LootOrnate = value end,
					width = "full",
				},
				[9] = {
					type = "checkbox",
					name = "Loot Soul Gems",
					tooltip = "De/Activates Loot Manager for Soul Gems",
					getFunc = function() return Config.GeneralFilterSettings.LootSoulGems end,
					setFunc = function(value) Config.GeneralFilterSettings.LootSoulGems = value end,
					width = "full",
				},
				[10] = {
					type = "checkbox",
					name = "Loot Lockpicks",
					tooltip = "De/Activates Loot Manager for Lockpicks",
					getFunc = function() return Config.GeneralFilterSettings.LootLockpicks end,
					setFunc = function(value) Config.GeneralFilterSettings.LootLockpicks = value end,
					width = "full",
				},
				[11] = {
					type = "checkbox",
					name = "Loot Refined Style Material",
					tooltip = "De/Activates Loot Manager for Refined Style Material",
					getFunc = function() return Config.GeneralFilterSettings.LootStyleMaterial end,
					setFunc = function(value) Config.GeneralFilterSettings.LootStyleMaterial = value end,
					width = "full",
				},
				[12] = {
					type = "checkbox",
					name = "Loot Raw Style Material",
					tooltip = "De/Activates Loot Manager for Raw Style Material",
					getFunc = function() return Config.GeneralFilterSettings.LootStyleRawMaterial end,
					setFunc = function(value) Config.GeneralFilterSettings.LootStyleRawMaterial = value end,
					width = "full",
				},
				[13] = {
					type = "checkbox",
					name = "Loot Poisons",
					tooltip = "De/Activates Loot Manager for Poisons",
					getFunc = function() return Config.GeneralFilterSettings.LootPoisons end,
					setFunc = function(value) Config.GeneralFilterSettings.LootPoisons = value end,
					width = "full",
				},
				[14] = {
					type = "description",
					title = nil,
					text = "        ————————  Potion Filter Management  ————————",
					width = "full",
				},
				[15] = {
					type = "checkbox",
					name = "Loot Health Potions",
					tooltip = "De/Activates Loot Manager for Health Potions",
					getFunc = function() return Config.GeneralFilterSettings.LootHealthPotions end,
					setFunc = function(value) Config.GeneralFilterSettings.LootHealthPotions = value end,
					width = "full",
				},
				[16] = {
					type = "checkbox",
					name = "Loot Stamina Potions",
					tooltip = "De/Activates Loot Manager for Stamina Potions",
					getFunc = function() return Config.GeneralFilterSettings.LootStaminaPotions end,
					setFunc = function(value) Config.GeneralFilterSettings.LootStaminaPotions = value end,
					width = "full",
				},
				[17] = {
					type = "checkbox",
					name = "Loot Magicka Potions",
					tooltip = "De/Activates Loot Manager for Magicka Potions",
					getFunc = function() return Config.GeneralFilterSettings.LootMagickaPotions end,
					setFunc = function(value) Config.GeneralFilterSettings.LootMagickaPotions = value end,
					width = "full",
				},
				[18] = {
					type = "description",
					title = nil,
					text = "        ————————  Glyph Filter Management  ————————",
					width = "full",
				},
				[19] = {
					type = "slider",
					name = "Loot Weapon Glyphs",
					tooltip = "Set Quality Treshhold for looting Weapon Glyphs. Value 6 will stop loot Weapon Glyphs",
					min = 0,
					max = 6,
					getFunc = function() return Config.GeneralFilterSettings.LootWeaponGlyphs end,
					setFunc = function(value) Config.GeneralFilterSettings.LootWeaponGlyphs = value end,
					width = "full",
				},
				[20] = {
					type = "slider",
					name = "Loot Armor Glyphs",
					tooltip = "Set Quality Treshhold for looting Armor Glyphs. Value 6 will stop loot Armor Glyphs",
					min = 0,
					max = 6,
					getFunc = function() return Config.GeneralFilterSettings.LootArmorGlyphs end,
					setFunc = function(value) Config.GeneralFilterSettings.LootArmorGlyphs = value end,
					width = "full",
				},
				[21] = {
					type = "slider",
					name = "Loot Jewelry Glyphs",
					tooltip = "Set Quality Treshhold for looting Jewelry Glyphs. Value 6 will stop loot Jewelry Glyphs",
					min = 0,
					max = 6,
					getFunc = function() return Config.GeneralFilterSettings.LootJewelryGlyphs end,
					setFunc = function(value) Config.GeneralFilterSettings.LootJewelryGlyphs = value end,
					width = "full",
				},
				
			},
		},
		[8] = {
			type = "submenu",
			name = "Material Filter Settings",
			icon = "/esoui/art/icons/achievements_indexicon_crafting_up.dds",
			disabled = function() return LootManager.MenuCondition(0) end,
			controls = {
				[1] = {
					type = "divider",
					height = 10,
					alpha = 1.0,
					width = "full",
				},
				[2] = {
					type = "checkbox",
					name = "Loot Alchemy Materials",
					tooltip = "De/Activates Loot Manager for Alchemy Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootAlchemy end,
					setFunc = function(value) Config.MaterialFilterSettings.LootAlchemy = value end,
					width = "full",
				},
				[3] = {
					type = "checkbox",
					name = "Loot Clothing Materials",
					tooltip = "De/Activates Loot Manager for Clothing Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootClothing end,
					setFunc = function(value) Config.MaterialFilterSettings.LootClothing = value end,
					width = "full",
				},
				[4] = {
					type = "checkbox",
					name = "Loot Smithing Materials",
					tooltip = "De/Activates Loot Manager for Smithing Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootSmithing end,
					setFunc = function(value) Config.MaterialFilterSettings.LootSmithing = value end,
					width = "full",
				},
				[5] = {
					type = "checkbox",
					name = "Loot Jewelry Materials",
					tooltip = "De/Activates Loot Manager for Jewelry Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootJewelry end,
					setFunc = function(value) Config.MaterialFilterSettings.LootJewelry = value end,
					width = "full",
				},
				[6] = {
					type = "checkbox",
					name = "Loot Woodcrafting Materials",
					tooltip = "De/Activates Loot Manager for Woodcraft Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootWood end,
					setFunc = function(value) Config.MaterialFilterSettings.LootWood = value end,
					width = "full",
				},
				[7] = {
					type = "checkbox",
					name = "Loot Enchantment Materials",
					tooltip = "De/Activates Loot Manager for Enchantment Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootRunes end,
					setFunc = function(value) Config.MaterialFilterSettings.LootRunes = value end,
					width = "full",
				},
				[8] = {
					type = "checkbox",
					name = "Loot Cooking Materials",
					tooltip = "De/Activates Loot Manager for cooking Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootCooking end,
					setFunc = function(value) Config.MaterialFilterSettings.LootCooking = value end,
					width = "full",
				},
				[9] = {
					type = "checkbox",
					name = "Loot Furnishing Materials",
					tooltip = "De/Activates Loot Manager for cooking Materials",
					getFunc = function() return Config.MaterialFilterSettings.LootFurnish end,
					setFunc = function(value) Config.MaterialFilterSettings.LootFurnish = value end,
					width = "full",
				},
			},
		},
		[9] = {
			type = "submenu",
			name = "Weapon Filter Settings",
			icon = "/esoui/art/inventory/inventory_tabicon_weapons_up.dds",
			disabled = function() return LootManager.MenuCondition(1) end,
			controls = {
				[1] = {
					type = "description",
					title = nil,
					text = "        —————— Intricate & Researchable Weapon Filter ——————",
					width = "full",
				},
				[2] = {
					type = "checkbox",
					name = "Loot Smithed Intricate Weapons",
					tooltip = "De/Activates Loot Manager for Smithed Intricate Weapons",
					getFunc = function() return Config.WeaponFilterSettings.MetalWeaponIntricate end,
					setFunc = function(value) Config.WeaponFilterSettings.MetalWeaponIntricate = value end,
					width = "full",
				},
				[3] = {
					type = "checkbox",
					name = "Loot Researchable Smithed Weapons",
					tooltip = "De/Activates Loot Manager for Researchable Smithed Weapons",
					getFunc = function() return Config.WeaponFilterSettings.ResearchSmithWeaponTraits end,
					setFunc = function(value) Config.WeaponFilterSettings.ResearchSmithWeaponTraits = value end,
					width = "full",
				},
				[4] = {
					type = "checkbox",
					name = "Loot Wooden Intricate Weapons",
					tooltip = "De/Activates Loot Manager for Wooden Intricate Weapons",
					getFunc = function() return Config.WeaponFilterSettings.WoodenWeaponIntricate end,
					setFunc = function(value) Config.WeaponFilterSettings.WoodenWeaponIntricate = value end,
					width = "full",
				},
				[5] = {
					type = "checkbox",
					name = "Loot Researchable Wooden Weapon",
					tooltip = "De/Activates Loot Manager for Researchable Wooden Weapon",
					getFunc = function() return Config.WeaponFilterSettings.ResearchWoodWeaponTraits end,
					setFunc = function(value) Config.WeaponFilterSettings.ResearchWoodWeaponTraits = value end,
					width = "full",
				},
				[6] = {
					type = "description",
					title = nil,
					text = "        — One-Handed Weapons ————————————— Quality —",
					width = "full",
				},
				[7] = {
					type = "slider",
					name = "Loot Daggers",
					tooltip = "Set Quality Treshhold for looting Daggers. Value 6 will stop loot Daggers",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.Dagger end,
					setFunc = function(value) Config.WeaponFilterSettings.Dagger = value end,
					width = "full",
				},
				[8] = {
					type = "slider",
					name = "Loot One-Hand Swords",
					tooltip = "Set Quality Treshhold for looting One-Hand Swords. Value 6 will stop loot One-Hand Swords",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.OHSword end,
					setFunc = function(value) Config.WeaponFilterSettings.OHSword = value end,
					width = "full",
				},
				[9] = {
					type = "slider",
					name = "Loot One-Hand Mace",
					tooltip = "Set Quality Treshhold for looting One-Hand Maces. Value 6 will stop loot One-Hand Maces",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.OHHammer end,
					setFunc = function(value) Config.WeaponFilterSettings.OHHammer = value end,
					width = "full",
				},
				[10] = {
					type = "slider",
					name = "Loot One-Hand Axe",
					tooltip = "Set Quality Treshhold for looting One-Hand Axes. Value 6 will stop loot One-Hand Axes",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.OHAxe end,
					setFunc = function(value) Config.WeaponFilterSettings.OHAxe = value end,
					width = "full",
				},
				[11] = {
					type = "slider",
					name = "Loot Shield",
					tooltip = "Set Quality Treshhold for looting Shields. Value 6 will stop loot Shields",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.Shield end,
					setFunc = function(value) Config.WeaponFilterSettings.Shield = value end,
					width = "full",
				},
				[12] = {
					type = "description",
					title = nil,
					text = "        — Two-Handed Weapons ————————————— Quality —",
					width = "full",
				},
				[13] = {
					type = "slider",
					name = "Loot Two-Hand Swords",
					tooltip = "Set Quality Treshhold for looting Two-Hand Swords. Value 6 will stop loot Two-Hand Swords",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.THSword end,
					setFunc = function(value) Config.WeaponFilterSettings.THSword = value end,
					width = "full",
				},
				[14] = {
					type = "slider",
					name = "Loot Two-Hand Mace",
					tooltip = "Set Quality Treshhold for looting Two-Hand Maces. Value 6 will stop loot Two-Hand Maces",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.THHammer end,
					setFunc = function(value) Config.WeaponFilterSettings.THHammer = value end,
					width = "full",
				},
				[15] = {
					type = "slider",
					name = "Loot Two-Hand Axe",
					tooltip = "Set Quality Treshhold for looting Two-Hand Axes. Value 6 will stop loot Two-Hand Axes",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.THAxe end,
					setFunc = function(value) Config.WeaponFilterSettings.THAxe = value end,
					width = "full",
				},
				[16] = {
					type = "slider",
					name = "Loot Bow",
					tooltip = "Set Quality Treshhold for looting Bows. Value 6 will stop loot Bows",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.Bow end,
					setFunc = function(value) Config.WeaponFilterSettings.Bow = value end,
					width = "full",
				},
				[17] = {
					type = "slider",
					name = "Loot Firestaff",
					tooltip = "Set Quality Treshhold for Firestaffs. Value 6 will stop loot Firestaffs",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.FireStaff end,
					setFunc = function(value) Config.WeaponFilterSettings.FireStaff = value end,
					width = "full",
				},
				[18] = {
					type = "slider",
					name = "Loot Icestaff",
					tooltip = "Set Quality Treshhold for Icestaffs. Value 6 will stop loot Icestaffs",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.FrostStaff end,
					setFunc = function(value) Config.WeaponFilterSettings.FrostStaff = value end,
					width = "full",
				},
				[19] = {
					type = "slider",
					name = "Loot Shockstaff",
					tooltip = "Set Quality Treshhold for Lightningstaffs. Value 6 will stop loot Lightningstaffs",
					min = 0,
					max = 6,
					getFunc = function() return Config.WeaponFilterSettings.LightningStaff end,
					setFunc = function(value) Config.WeaponFilterSettings.LightningStaff = value end,
					width = "full",
				},
			},
		},
		[10] = {
			type = "submenu",
			name = "Armor Filter Settings",
			icon = "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
			disabled = function() return LootManager.MenuCondition(2) end,
			controls = {
				[1] = {
					type = "description",
					title = nil,
					text = "        —————— Intricate & Researchable Armor Filter ——————",
					width = "full",
				},
				[2] = {
					type = "checkbox",
					name = "Loot Smithed Intricate Armor",
					tooltip = "De/Activates Loot Manager for Smithed Intricate Armors",
					getFunc = function() return Config.ArmorFilterSettings.SmithArmorIntricate end,
					setFunc = function(value) Config.ArmorFilterSettings.SmithArmorIntricate = value end,
					width = "full",
				},
				[3] = {
					type = "checkbox",
					name = "Loot Researchable Smithed Armor",
					tooltip = "De/Activates Loot Manager for Researchable Smithed Armor",
					getFunc = function() return Config.ArmorFilterSettings.ResearchSmithArmorTrait end,
					setFunc = function(value) Config.ArmorFilterSettings.ResearchSmithArmorTrait = value end,
					width = "full",
				},
				[4] = {
					type = "checkbox",
					name = "Loot Clothing Intricate Armor",
					tooltip = "De/Activates Loot Manager for Clothing Intricate Armors",
					getFunc = function() return Config.ArmorFilterSettings.ClothArmorIntricate end,
					setFunc = function(value) Config.ArmorFilterSettings.ClothArmorIntricate = value end,
					width = "full",
				},
				[5] = {
					type = "checkbox",
					name = "Loot Researchable Clothing Armor",
					tooltip = "De/Activates Loot Manager for Researchable Clothing Armor",
					getFunc = function() return Config.ArmorFilterSettings.ResearchClothArmorTrait end,
					setFunc = function(value) Config.ArmorFilterSettings.ResearchClothArmorTrait = value end,
					width = "full",
				},
				[6] = {
					type = "checkbox",
					name = "Loot Intricate Jewelry",
					tooltip = "De/Activates Loot Manager for Intricate Jewelry",
					getFunc = function() return Config.ArmorFilterSettings.JewelryArmorIntricate end,
					setFunc = function(value) Config.ArmorFilterSettings.JewelryArmorIntricate = value end,
					width = "full",
				},
				[7] = {
					type = "checkbox",
					name = "Loot Researchable Jewelry",
					tooltip = "De/Activates Loot Manager for Researchable Jewelry",
					getFunc = function() return Config.ArmorFilterSettings.ResearchJewelryArmorTrait end,
					setFunc = function(value) Config.ArmorFilterSettings.ResearchJewelryArmorTrait = value end,
					width = "full",
				},
				[8] = {
					type = "description",
					title = nil,
					text = "        — Armortype —————————————————— Quality —",
					width = "full",
				},
				[9] = {
					type = "slider",
					name = "Loot Light Armor",
					tooltip = "Set Quality Treshhold for looting Light Armor. Value 6 will stop loot Light Armor",
					min = 0,
					max = 6,
					getFunc = function() return Config.ArmorFilterSettings.LightArmor end,
					setFunc = function(value) Config.ArmorFilterSettings.LightArmor = value end,
					width = "full",
				},
				[10] = {
					type = "slider",
					name = "Loot Medium Armor",
					tooltip = "Set Quality Treshhold for looting Medium Armor. Value 6 will stop loot Medium Armor",
					min = 0,
					max = 6,
					getFunc = function() return Config.ArmorFilterSettings.MediumArmor end,
					setFunc = function(value) Config.ArmorFilterSettings.MediumArmor = value end,
					width = "full",
				},
				[11] = {
					type = "slider",
					name = "Loot Heavy Armor",
					tooltip = "Set Quality Treshhold for looting Heavy Armor. Value 6 will stop loot Heavy Armor",
					min = 0,
					max = 6,
					getFunc = function() return Config.ArmorFilterSettings.HeavyArmor end,
					setFunc = function(value) Config.ArmorFilterSettings.HeavyArmor = value end,
					width = "full",
				},
				[12] = {
					type = "slider",
					name = "Loot Jewelry",
					tooltip = "Set Quality Treshhold for looting Jewelry. Value 6 will stop loot Jewelry",
					min = 0,
					max = 6,
					getFunc = function() return Config.ArmorFilterSettings.JewelryArmor end,
					setFunc = function(value) Config.ArmorFilterSettings.JewelryArmor = value end,
					width = "full",
				},
			},
		},
		[11] = {
			type = "divider",
			height = 10,
			alpha = 1.0,
			width = "full",
		},
		[12] = {
			type = "submenu",
			name = "Recommended Addons",
			icon = "/esoui/art/tutorial/tabicon_friends_up.dds",
			controls = {
				[1] = {
					type = "divider",
					height = 2,
					alpha = 1.0,
					width = "full",
				},
				[2] = {
					type = "description",
					title = nil,
					text = "Here are a few Addons from ESOUI.COM which I can recommend to use with cOOLsp0t's Loot Manager.",
					width = "full",
				},
				[3] = {
					type = "divider",
					height = 10,
					alpha = 1.0,
					width = "full",
				},
				[4] = {
					type = "button",
					name = "|cffff00P|cffffffersonal |cffff00A|cffffffssistant|r",
					tooltip = "Personal Assistant by Klingo, NTak is a great addition & can help to safe a lot of time",
					func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info381-PersonalAssistantBankingJunkLootRepair.html") end,
					width = "half",
				},
				[5] = {
					type = "button",
					name = "|cececb6HarvestMap|r",
					tooltip = "HarvestMap by Shinni shows lootmarks on your map & in the World",
					func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info57-HarvestMap.html") end,
					width = "half",
				},
				[6] = {
					type = "button",
					name = "|cffffffLootdrop Continued|r",
					tooltip = "Lootdrop by Ayantir & Pawkette displays your loot in an animated lootbar",
					func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info35-LootdropContinuedAllinOne.html") end,
					width = "half",
				},
				[7] = {
					type = "button",
					name = "|cffffffMaster Merchant|r",
					tooltip = "Master Merchant by Philgo68 helps to find lootworthy items for sell",
					func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info928-MasterMerchant.html") end,
					width = "half",
				},
				[8] = {
					type = "button",
					name = "|cececb6pChat|r",
					tooltip = "pChat by DesertDwellers, Ayantir & Puddy extends the chatwindow on functionality & will help to see when CLM destroys items",
					func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info417-RAETIAInfoHub.html") end,
					width = "half",
				},
				[9] = {
					type = "button",
					name = "|c4454ddRAETIA|r |cffffffInfohub|r",
					tooltip = "Raetia Infohub by Kraeius & P5ych3 shows your bag-, bank- & serveral other information in your HUD",
					func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info417-RAETIAInfoHub.html") end,
					width = "half",
				},
				[10] = {
					type = "divider",
					height = 10,
					alpha = 1.0,
					width = "full",
				},
			},
		},
	}
	clmpanel = LAM:RegisterAddonPanel("LootManager", panelData)
	LAM:RegisterOptionControls("LootManager", optionsTable)
end
						---	 Open Option Panel Function for Keybinding & Slashcommand ---
function LootManager_OpenPanel()
	LAM:OpenToPanel(clmpanel)
end

						--- Activate Manager NO RELOADUI NEEDED! ---
function LootManager_ActivateManager(funcID)
	
	if funcID == 1 then Config.GeneralSettings.ManagerEnabled = not Config.GeneralSettings.ManagerEnabled end
	
	if (GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)) == "1" then
		Config.GeneralSettings.ManagerEnabled = false
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, "0")
		d("— |cef9a2ccOOLsp0T's|r Loot Manager |c46c6f5has deactivated the ESO Auto Loot Function!|r")
	end
	
	local isActivated = StatusTag[Config.GeneralSettings.ManagerEnabled]
	d("— |cef9a2ccOOLsp0T's|r Loot Manager "..Config.GeneralSettings.AddonVersion..isActivated)	
	
	if Config.GeneralSettings.ManagerEnabled then

						--- Register Functions to Events ---
		EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_LOOT_UPDATED, LootManager.LootInit)
		LootManager.Debugger(20)
						--- Register Player States to Events ---
		EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_PLAYER_COMBAT_STATE, function(_,inCombat) LootManager.isPlayerInCombat = inCombat end)
	
	else
		LootManager_ActivateThiefMode(0)
		LootManager.ShowEmpty = false
						--- Unregister Functions to Events ---
		EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_LOOT_UPDATED)
		LootManager.Debugger(21)
						--- Unregister Player States to Events ---
		EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_PLAYER_COMBAT_STATE)
		
	end
	if funcID == 0 then
		EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_PLAYER_ACTIVATED)
		LootManager_ActivateThiefMode()
	end
end
						--- Activate Thief Mode NO RELOADUI NEEDED! ---
function LootManager_ActivateThiefMode(funcID)
	if (funcID == "" or funcID == nil) and not Config.GeneralSettings.ManagerEnabled then
		LootManager.Debugger(12)
	else
		if funcID == 0 then
			Config.GeneralSettings.LootStolen = false
		else
			Config.GeneralSettings.LootStolen = not Config.GeneralSettings.LootStolen
		end
		
		if Config.GeneralSettings.ManagerEnabled and Config.GeneralSettings.LootStolen then status = true else status = false end
		
		local isActivated = StatusTag[status]
		LootManager.Debugger(11,_,_,_,_,_,_,_,_,isActivated)
	end
	if status then
						--- Unregister Lockpick Prevention ---
		EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_BEGIN_LOCKPICK)
		LootManager.Debugger(29)
		
	else
						--- Register Lockpick Prevention ---
		EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_BEGIN_LOCKPICK, LootManager.PreventLockpick)
		LootManager.Debugger(28)
	end
end

						---	Modified reticle hook from No, Thank You!
function HookReticleTake()
	local function DisableReticleTake_Hook(interactionPossible)
	local hide = false
		if interactionPossible and Config.GeneralSettings.ManagerEnabled then
			local action,text,isEmpty,isOwned,addinfo,_,_,crime = GetGameCameraInteractableActionInfo()
			if text ~= '' and text ~= nil then
				if isOwned or crime then isCrime = true else isCrime = false end
				LootManager.isCrime = isCrime
				if addinfo == 2 and isEmpty then emptyCrate = true else emptyCrate = false end
				if emptyCrate and isCrime then emptyStolen = true else emptyStolen = false end
				if (not Config.GeneralSettings.LootStolen and (isCrime and not emptyCrate)) then hide = true end
				if (not Config.GeneralSettings.ShowEmpty and (emptyCrate or emptyStolen)) then hide = true end
			end
		end
	return hide
	end	
	ZO_PreHook(RETICLE, "TryHandlingInteraction", DisableReticleTake_Hook)
end

function LootManager.PreventLockpick()
	if not Config.GeneralSettings.LootStolen and LootManager.isCrime then
		LootManager.Debugger(7)
		EndInteraction(20)
	end
end
						--- Slash Command Handler ---
SLASH_COMMANDS["/clm"] = function(param)
	local options = {}
	local searchResult = { string.match(param,"^(%S*)%s*(.-)$") }
	if param == nil or param == "" then
		LootManager.HelpMessage()
		return
	else
		for i,v in pairs(searchResult) do
			options[i] = string.lower(v)
		end
	end
	if options[1] == "help" then LootManager.HelpMessage() end
	if options[1] == "menu" then LootManager_OpenPanel() end
	if options[1] == "clm" then LootManager_ActivateManager(1) end
	if options[1] == "thief" then LootManager_ActivateThiefMode() end
	if options[1] == "empty" then
		Config.GeneralSettings.ShowEmpty = not Config.GeneralSettings.ShowEmpty
		local isActivated = StatusTag[Config.GeneralSettings.ShowEmpty]
		LootManager.Debugger(13,_,_,_,_,_,_,_,_,isActivated)
	end
	if options[1] == "debug" then
		if options[2] == "0" or options[2] == "silent" then Config.GeneralSettings.Debug = "Silent" end
		if options[2] == "1" or options[2] == "actions" then Config.GeneralSettings.Debug = "Actions" end
		if options[2] == "2" or options[2] == "debug" then Config.GeneralSettings.Debug = "Debug" end
		if options[2] == nil or options[2] == "" then
			d(LootManager.ManagerDebugMark.."|c46c6f5CLM Debug Mode|r is |c46c6f5"..Config.GeneralSettings.Debug.."|r")
		else
			d(LootManager.ManagerDebugMark.."|c46c6f5CLM Debug Mode|r was set to |c46c6f5"..Config.GeneralSettings.Debug.."|r")
		end
	end
	if options[1] == "update" then
		if options[2] ~= nil and options[2] ~= "" then
			options[2] = tonumber(options[2])
			if options[2] >= 80 and options[2] <= 2000 then
				local reventIntervall = Config.GeneralSettings.Wait_MS
				Config.GeneralSettings.Wait_MS = options[2]
				d(LootManager.ManagerDebugMark.."|c46c6f5CLM Update Intervall per MS|r was set from |c46c6f5"..reventIntervall.."|r to |c46c6f5"..Config.GeneralSettings.Wait_MS.."|r")
			else
				d(LootManager.ManagerDebugMark.."|cdc1f1fInvalid Parameter!|r Number must be in Range |c46c6f580|r - |c46c6f52000|r")
			end
		else
			d(LootManager.ManagerDebugMark.."|c46c6f5CLM Update Intervall per MS|r is |c46c6f5"..Config.GeneralSettings.Wait_MS.."|r")
		end
	end
end

function LootManager.HelpMessage()
	local CLM_IsActivated = StatusTag[Config.GeneralSettings.ManagerEnabled]
	
	local ThiefModeStatus = false
	if Config.GeneralSettings.ManagerEnabled and Config.GeneralSettings.LootStolen then ThiefModeStatus = true end
	local ThiefMode_IsActivated = StatusTag[ThiefModeStatus]
	
	d("—————————— |cef9a2ccOOLsp0T's|r Loot Manager "..Config.GeneralSettings.AddonVersion.." —————————")
	d("————————————— |c46c6f5 Command List|r ————————————")
	d(LootManager.ManagerDebugMark.."Type '|c46c6f5/clm|r' or '|c46c6f5/clm help|r' to open this Help Message!")
	d(LootManager.ManagerDebugMark.."Type '|c46c6f5/clm menu|r' to open the Options Menu!")
	d(LootManager.ManagerDebugMark.."Type '|c46c6f5/clm clm|r' to de/activate cOOLsp0t's Loot Manager!")
	d(LootManager.ManagerDebugMark.."Type '|c46c6f5/clm thief|r' to de/activate the CLM Thief Mode!")
	d(LootManager.ManagerDebugMark.."Type '|c46c6f5/clm empty|r' to de/activate the CLM Show Empty Container!")
	d("——————————— |c46c6f5 Debug Command List|r ———————————")
	d(LootManager.ManagerDebugMark.."Type '|c46c6f5/clm debug NR|r' — NR: 0 = Silent, 1 = Actions, 2 = Debug")
	d(LootManager.ManagerDebugMark.."Type '|c46c6f5/clm update VALUE|r' — VALUE = 80 - 2000")
	d("————————————————————————————————")
end

						--- Loot Currencies ---
function LootManager.LootAllCurrencies()
	local currencies = {
		[1] = "Gold",
		[2] = "Alliance Points",
		[3] = "Telvar Stones",
		[4] = "Writ Vouchers",
	}
	for i, currency in ipairs(currencies) do
		local amount = GetLootCurrency(i)
		if amount == nil then amount = 0 end
		if amount ~= 0 then
			LootManager.Debugger(6,_,_,_,_,_,_,currency,amount)
			LootCurrency(i)
		end
	end
	local stolengold = GetLootCurrency(1)
	if Config.GeneralSettings.LootStolen and (LootManager.isCrime and stolengold ~= 0) then
		LootMoney()
		LootManager.Debugger(10,_,_,_,_,_,_,_,stolengold,_)
	end
	if not Config.GeneralSettings.LootStolen and (LootManager.isCrime and stolengold ~= 0) then
		LootManager.Debugger(8)
		EndLooting()
	end
end
						--- Looting ---					
function LootManager.LootInit()

	if LootManager.isLooting == false then
		LootManager.isLooting = true
		EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_LOOT_CLOSED, function() LootManager.StopLooting() end)
		LootManager.Debugger(26)	
	end
				--- When Player is in Combat, close loot window! ---
	if LootManager.isPlayerInCombat == true then EndLooting() return end
	
	lootID,_,_,LootManager.RecentStackSize = GetLootItemInfo()	
	LootManager.LootAllCurrencies()
								--- Check if there is an Itemstack avaibled to loot ---
	if lootID ~= 0 then
								--- Check if inventory is full ---
		local bagsizeleft = GetNumBagFreeSlots(BAG_BACKPACK)
		if bagsizeleft ~= 0 then
			
			local lootstack = GetNumLootItems()
			if lootstack == 1 then LootManager.isLastItem = true else LootManager.isLastItem = false end
			
			local lootitem,stolen = LootManager.ItemFilter(nil,nil)
			if not Config.GeneralSettings.LootStolen and stolen then EndLooting() LootManager.Debugger(9) end 
			LootManager.Debugger(0,lootstack,lootitem)

			if lootitem == false then
										--- Unregister, because call will not come from next item ---
				EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_LOOT_UPDATED)
				LootManager.Debugger(21)
														--- Register for fetching data of incoming itemstack ---
				EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) LootManager.CheckForEquip(...) end)
				LootManager.Debugger(22)
										--- Get Item Link and extract Loot GUID ---
				local itemlink = GetLootItemLink(lootID) -- first fetch try
				if itemlink == nil or itemlink == "" then itemlink = GetLootItemLink(lootID) end -- second fetch try
												--- if second fetch try fails, reset ---
				if itemlink == nil or itemlink == "" then
					EndLooting()
					LootManager.Debugger(30)
					return
				end -- error
				local lootguid = LootManager.ItemLinkDescrambler(itemlink) --- extract GUID
				if LootManager.RecentLootItemLink ~= itemlink then LootManager.RecentLootItemLink = itemlink end --- Set Recent Loot Itemlink
				if LootManager.RecentLootGUID ~= lootguid then LootManager.RecentLootGUID = lootguid end --- Set Recent Loot ItemGUID
			else
				if LootManager.isLastItem == false then
					EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_LOOT_UPDATED, LootManager.LootInit)
					LootManager.Debugger(20)
				end
			end
			LootItemById(lootID)
		else
			d(InventoryFullTag)
			EndLooting()
		end
	end
end


function LootManager.CheckForEquip(_,bagID,slotID,isNewItem,_,_,stackCountChanged)

	EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	LootManager.Debugger(23)

	local isEquip = false
	
	if LootManager.RecentBagID ~= bagID then LootManager.RecentBagID = bagID end
	if LootManager.RecentSlotID ~= slotID then LootManager.RecentSlotID = slotID end
	local isItemInSlot = HasItemInSlot(bagID,slotID)
	
					--- Get Inventory ItemLink, extract GUID & set GUID as Global ---
	local itemlink = GetItemLink(bagID,slotID) --- first try
	if itemlink == nil or itemlink == "" then itemlink = LootManager.RecentLootItemLink end --- Set Loot ItemLink to Inventory ItemLink
							--- if second fetch try fails, reset ---
	if itemlink == nil or itemlink == "" then
		EndLooting()
		LootManager.Debugger(30)
		return
	end --- error
	if LootManager.RecentInventoryItemLink ~= itemlink then LootManager.RecentInventoryItemLink = itemlink end
	local invguid = LootManager.ItemLinkDescrambler(itemlink) --- descramble Link
	if LootManager.RecentInvGUID ~= invguid then LootManager.RecentInvGUID = invguid end --- proof GUID, if wrong, take recent LootGUID
	
					--- Get sure to have the right item selected! ---
	if LootManager.RecentLootGUID == LootManager.RecentInvGUID and isItemInSlot == true then
	
		local stacksize_inslot = GetSlotStackSize(bagID,slotID)
		local itemtype = GetItemType(bagID,slotID)
		
		if itemtype == ITEMTYPE_ARMOR or itemtype == ITEMTYPE_WEAPON then isEquip = true end
		if LootManager.RecentStackSize ~= stackCountChanged then stackCountChanged = LootManager.RecentStackSize end
		
					--- If the existing slot stack size = looting stack size then destroy it
					--- faster as making a new item stack.
		if stacksize_inslot == stackCountChanged or isEquip == true then
			
			DestroyItem(bagID,slotID)
			LootManager.Debugger(3,_,_,_,_,_,itemlink,_,_)
			
			if LootManager.isLastItem == false then
				LootManager.LootChainForward()
			end
		else
			local bagsizeleft = GetNumBagFreeSlots(BAG_BACKPACK)
			if bagsizeleft ~= 0 then
				LootManager.Debugger(4)
				LootManager.CreateItemStack(bagID,slotID,stackCountChanged)
			else
				EndLooting()
				d(InventoryFullTag)
			end
		end
	else
		EndLooting()
		LootManager.Debugger(30)
	end
end

function LootManager.CreateItemStack(bagID,slotID,stackCountChanged)
	
	if bagID ~= LootManager.RecentBagID then bagID = LootManager.RecentBagID end
	if slotID ~= LootManager.RecentSlotID then slotID = LootManager.RecentSlotID end
	
		--- Get Inventory ItemLink and compare with Global Inventory GUID ---
	local itemlink = GetItemLink(bagID,slotID) --- first try
	if itemlink == nil or itemlink == "" then itemlink = LootManager.RecentInventoryItemLink end --- if ItemLink is not valid, then Set Inventory ItemLink to itemlink
	if itemlink == nil or itemlink == "" then itemlink = LootManager.RecentLootItemLink end --- if ItemLink is not valid, then Set Loot ItemLink to itemlink
	if itemlink == nil or itemlink == "" then
		EndLooting()
		LootManager.Debugger(30)
		return
	end --- error
	
	local actinvguid = LootManager.ItemLinkDescrambler(itemlink)
	
	local isItemInSlot = HasItemInSlot(bagID,slotID)
	local newslotID = FindFirstEmptySlotInBag(BAG_BACKPACK)
	if LootManager.RecentNewSlotID ~= newslotID then LootManager.RecentNewSlotID = newslotID end
	
	if stackCountChanged ~= LootManager.RecentStackSize then stackCountChanged = LootManager.RecentStackSize end
	
	if LootManager.RecentInvGUID == actinvguid and isItemInSlot == true then

		EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) LootManager.CheckDestroy(...) end)
		LootManager.Debugger(24)
	
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem",bagID,slotID,bagID,newslotID,stackCountChanged)
		else
			RequestMoveItem(bagID,slotID,bagID,newslotID,stackCountChanged)
		end
		LootManager.Debugger(1,_,_,stackCountChanged,slotID,newslotID,itemlink)
	else
		EndLooting()
		LootManager.Debugger(30)
	end
end

function LootManager.CheckDestroy(_,bagID,slotID,_,_,_,stackCountChanged)

	EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	LootManager.Debugger(25)
	
	if bagID ~= LootManager.RecentBagID then bagID = LootManager.RecentBagID end
	if slotID ~= LootManager.RecentNewSlotID then slotID = LootManager.RecentNewSlotID end
	
	local itemlink = GetItemLink(bagID,slotID) --- first try
	if itemlink == nil or itemlink == "" then itemlink = LootManager.RecentInventoryItemLink end --- if ItemLink is not valid, then Set Inventory ItemLink to itemlink
	if itemlink == nil or itemlink == "" then itemlink = LootManager.RecentLootItemLink end --- if ItemLink is not valid, then Set Loot ItemLink to itemlink
	if itemlink == nil or itemlink == "" then
		EndLooting()
		LootManager.Debugger(30)
		return
	end --- error
	local actinvguid = LootManager.ItemLinkDescrambler(itemlink)
	
	local isItemInSlot = HasItemInSlot(bagID,slotID)
	local stacksize_inslot = GetSlotStackSize(bagID,slotID)
	
	if LootManager.RecentStackSize ~= stackCountChanged then stackCountChanged = LootManager.RecentStackSize end
	
	if LootManager.RecentInvGUID == actinvguid and stacksize_inslot == stackCountChanged and isItemInSlot == true then

		DestroyItem(bagID,slotID)
		LootManager.Debugger(2,_,_,stackCountChanged,slotID,_,itemlink)
		
		if LootManager.isLastItem == false then
			LootManager.LootChainForward()
		end	
	else
		EndLooting()
		LootManager.Debugger(30)
	end
end

					--- If Lootwindow is getten closed, reset looting global var for next Loot action ---
function LootManager.StopLooting()
	LootManager.isLooting = false
	EVENT_MANAGER:UnregisterForEvent(LootManager.Name, EVENT_LOOT_CLOSED)
	LootManager.Debugger(27)
	EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_LOOT_UPDATED, LootManager.LootInit)
	LootManager.Debugger(20)
end

					--- Loot Chain Forward with stacks per Lootchain dependet time management ---
function LootManager.LootChainForward()
	EVENT_MANAGER:RegisterForUpdate("loopforward", Config.GeneralSettings.Wait_MS, function() LootManager.LootInit() EVENT_MANAGER:UnregisterForUpdate("loopforward") end)
	LootManager.Debugger(5)
end

function LootManager.ItemLinkDescrambler(itemlink)

	local arg = {}
	local pointerpos1 = 0
	local pointerpos2 = 0
	local itemlink = itemlink
	
	for i = 1, 22, 1 do
		
		--		d(pointerpos1.." & "..pointerpos2)
		if pointerpos1 == 0 then
			_,pointerpos1 = string.find(itemlink,":")
			pointerpos1 = pointerpos1 + 1
		else
			_,pointerpos1 = string.find(itemlink,":",pointerpos1)
			pointerpos1 = pointerpos2 + 2
		end
		
		_,pointerpos2 = string.find(itemlink,":",pointerpos1)
		
		if pointerpos2 == nil then
			_,pointerpos2 = string.find(itemlink,"|",2)
		end
			pointerpos2 = pointerpos2 - 1
		
		arg[i] = string.sub(itemlink,pointerpos1,pointerpos2)
	end
	
	local LINKTYPE = arg[1]
	local GUID = tonumber(arg[2])
	local REQPLAYERLEVEL = arg[3]
	local ITEMEFFECT = arg[4]
	local ITEMBUFF = arg[5]
	local ITEMBUFFVAL = arg[6]
	local ITEMSTYLE = arg[17]
	local CRAFTED = arg[18]
	local ISBOUND = arg[19]
	local ISSTOLEN = arg[20]
	local DURABILITY = arg[21]
	local POTIONEFFECTS = tonumber(arg[22])
	local hexPOTIONEFFECTS = string.format("%x", POTIONEFFECTS)
	
	return GUID,REQPLAYERLEVEL,ITEMEFFECT,ITEMBUFF,ITEMBUFFVAL,ITEMSTYLE,CRAFTED,ISBOUND,ISSTOLEN,DURABILITY,hexPOTIONEFFECTS
end

function LootManager.ItemFilter(bagID,slotID)	
	local COMMONITEMLOOTFILTER = {
		[48] = true, --- Trash
		[56] = true, --- Treasure
		[5] = true, --- Trophy
		[4] = true, --- Food
		[12] = true, --- Drink
		[9] = true, --- Tool
		[59] = true, --- Dye Stamp
		[14] = true, --- Disguise
		[13] = true, --- Costume
		[0] = true, --- None
		[3] = true, --- Plug
		[6] = true, --- Siege
		[49] = true, --- Spellcrafting Table
		[50] = true, --- Mount
		[47] = true, --- Ava Repair
	}
	
	local SOULGEMLOOTFILTER = {
		[19] = true, --- Soul Gem
	}
	
	local POISONLOOTFILTER = {
		[30] = true, -- Poison
	}
	
	local LOCKPICKLOOTFILTER = {
		[22] = true, --- Lockpick
	}
	
	local ALCHEMYLOOTFILTER = {
		[33] = true, --- Potion Base
		[31] = true, --- Reagent
		[58] = true, --- Poison Base
	}
	
	local WOODCRAFTINGLOOTFILTER = {
		[37] = true, --- Woodworking Raw Material
		[38] = true, --- Woodworking Material
		[42] = true, --- Woodworking Booster
		[46] = true, --- Weapon Trait
	}
	
	local BLACKSMITHINGLOOTFILTER = {
		[35] = true, --- Blacksmith Raw Material
		[36] = true, --- Blacksmith Material
		[41] = true, --- Blacksmith Booster
		[46] = true, --- Weapon Trait
		[45] = true, --- Armor Trait
	}
	
	local JEWELRYLOOTFILTER = {
		[65] = true, --- Jewelry Booster
		[64] = true, --- Jewelry Material
		[67] = true, --- Jewelry Raw Booster
		[63] = true, --- Jewelry Raw Material
	}
	
	local CLOTHIERLOOTFILTER = {
		[39] = true, --- Clothier Raw Material
		[40] = true, --- Clothier Material
		[43] = true, --- Clothier Booster
		[45] = true, --- Armor Trait
	}
	
	local RUNELOOTFILTER = {
		[52] = true, --- Aspect Rune
		[53] = true, --- Essence Rune
		[51] = true, --- Potency Rune
		[25] = true, --- Enchanting Booster
	}
	
	local COOKINGLOOTFILTER = {
		[28] = true, --- Flavoring
		[10] = true, --- Ingredient
		[54] = true, --- Fish
		[16] = true, --- Lure
		[27] = true, --- Spice
	}
	
	local FURNISHINGLOOTFILTER = {
		[61] = true, --- Furnishing
		[62] = true, --- Furnishing Material
	}
	
	local METALWEAPONFILTER = {
		[11] = true, --- Dagger
		[3] = true, --- One-Hand Sword
		[2] = true, --- One-Hand Hammer
		[1] = true, --- One-Hand Axe
		[4] = true, --- Two-Hand Sword
		[6] = true, --- Two-Hand Hammer
		[5] = true, --- Two-Hand Axe
	}
	
	local WOODENWEAPONFILTER = {
		[8] = true, --- Bow
		[12] = true, --- Firestaff
		[13] = true, --- Froststaff
		[15] = true, --- Lightningstaff
		[9] = true, --- Healingstaff
		[14] = true, --- Shield
	}
	
	local METALARMORFILTER = {
		[3] = true, --- Heavy
	}
	
	local CLOTHARMORFILTER = {
		[1] = true, --- Light
		[2] = true, --- Medium
	}
	
	local JEWELRYFILTER = {
		[0] = true, --- None
	}
	
	local WEAPONTRAITLOOTFILTER = {
		[0] = true, --- None
		[2] = true, --- Charged
		[8] = true, --- Decisive
		[5] = true, --- Defending
		[4] = true, --- Infused
		[26] = true, --- Nirnhorned
		[1] = true, --- Powered
		[3] = true, --- Precise
		[7] = true, --- Sharpened
		[9] = true, --- Intricate
		[10] = true, --- Ornate
	}
	
	local ARMORTRAITLOOTFILTER = {
		[0] = true, --- None
		[18] = true, --- Divine
		[13] = true, --- Reinforced
		[12] = true, --- Impenetrable
		[16] = true, --- Infused
		[25] = true, --- Nirnhorned
		[17] = true, --- Prosperous
		[15] = true, --- Training
		[11] = true, --- Sturdy
		[14] = true, --- Well Fitted
		[20] = true, --- Intricate
		[2] = true, --- Ornate
	}
	
	local itemlink = "ItemLink"
	local itemtype = "ItemType"
	local itemtype2 = "Weapon&Armor ItemType"
	local itemtrait = "ItemTrait"
	local itemfiltertype = "InvItemFilterType"
	local itemID,name,icon,amount,quality,value,isQuest,stolen = "Iteminfo"
	
	if bagID == nil or slotID == nil then
		itemID,name,icon,amount,quality,value,isQuest,stolen = GetLootItemInfo()
		itemlink = GetLootItemLink(itemID)
		itemtype = GetItemLinkItemType(itemlink)
		itemtrait = GetItemLinkTraitType(itemlink)
	else
		itemID = GetItemId(bagID,slotID)
		itemlink = GetItemLink(bagID,slotID)
		itemtype = GetItemType(bagID,slotID)
		itemtrait = GetItemTrait(bagID,slotID)
		stolen = IsItemStolen(bagID,slotID)
		name = GetItemName(bagID,slotID)
		quality = GetItemQuality(bagID,slotID)
		value = GetItemLinkValue(itemlink)
	end
	
	local lootitem = false
	local canberesearched = CanItemLinkBeTraitResearched(itemlink)
	
							--- Apply Crafting Filters ---
	local usecommonitemlootfilter = COMMONITEMLOOTFILTER[itemtype] or false
	local usealchemylootfilter = ALCHEMYLOOTFILTER[itemtype] or false
	local usewoodcraftinglootfilter = WOODCRAFTINGLOOTFILTER[itemtype] or false
	local useblacksmithlootfilter = BLACKSMITHINGLOOTFILTER[itemtype] or false
	local usejewelrylootfilter = JEWELRYLOOTFILTER[itemtype] or false
	local useclothierlootfilter = CLOTHIERLOOTFILTER[itemtype] or false
	local userunelootfilter = RUNELOOTFILTER[itemtype] or false
	local usecookinglootfilter = COOKINGLOOTFILTER[itemtype] or false
	local usefurnishinglootfilter = FURNISHINGLOOTFILTER[itemtype] or false
	
	local usepoisonlootfilter = POISONLOOTFILTER[itemtype] or false
							--- Apply Weapon & Armor Filter ---
	local useweapontraitlootfilter = WEAPONTRAITLOOTFILTER[itemtrait] or false
	local usearmortraitlootfilter = ARMORTRAITLOOTFILTER[itemtrait] or false
							--- Apply Clutter Filter ---
							
	local uselockpicklootfilter = LOCKPICKLOOTFILTER[itemtype] or false
	local usesoulgemlootfilter = SOULGEMLOOTFILTER[itemtype] or false
	
						--- User Common Item Filter ---
	if Config.GeneralFilterSettings.LootQuality <= quality and usecommonitemlootfilter == true then lootitem = true end
	if Config.GeneralFilterSettings.LootValue <= value and usecommonitemlootfilter == true then lootitem = true end
	
						--- User General Clutter Filter ---
	if Config.GeneralFilterSettings.LootLockpicks == true and uselockpicklootfilter == true then lootitem = true end
	if Config.GeneralFilterSettings.LootGlyphs == true and useglyphlootfilter == true then lootitem = true end
	if Config.GeneralFilterSettings.LootSoulGems == true and usesoulgemlootfilter == true then lootitem = true end
	if Config.GeneralFilterSettings.LootPoisons == true and usepoisonlootfilter == true then lootitem = true end
	
	if itemtype == ITEMTYPE_POTION then
							---- ITEMLINK DESCRAMBLER ----
		local GUID = LootManager.ItemLinkDescrambler(itemlink)
		if Config.GeneralFilterSettings.LootHealthPotions == true and GUID == 27036 then lootitem = true end
		if Config.GeneralFilterSettings.LootMagickaPotions == true and GUID == 27037 then lootitem = true end
		if Config.GeneralFilterSettings.LootStaminaPotions == true and GUID == 27038 then lootitem = true end
	end
	
	if Config.GeneralFilterSettings.LootArmorGlyphs <= quality and itemtype == ITEMTYPE_GLYPH_ARMOR then lootitem = true end
	if Config.GeneralFilterSettings.LootWeaponGlyphs <= quality and itemtype == ITEMTYPE_GLYPH_WEAPON then lootitem = true end
	if Config.GeneralFilterSettings.LootJewelryGlyphs <= quality and itemtype == ITEMTYPE_GLYPH_JEWELRY then lootitem = true end
	
						---- User Recipe Filter ---
	if itemtype == ITEMTYPE_RECIPE then
		local isknown = IsItemLinkRecipeKnown(itemlink)
		if Config.GeneralFilterSettings.RecipeFilter == "Not Known" and isknown == false then lootitem = true end
		if Config.GeneralFilterSettings.RecipeFilter == "Every" then lootitem = true end
	end
	
	if itemtype == ITEMTYPE_CONTAINER then lootitem = true end
	if itemtype == ITEMTYPE_COLLECTIBLE then lootitem = true end
--	if itemtype == ITEMTYPE_CROWN_ITEM or ITEMTYPE_CROWN_REPAIR then lootitem = true end
	if itemtype == ITEMTYPE_RACIAL_STYLE_MOTIF then lootitem = true end
	if itemtype == ITEMTYPE_MASTER_WRIT then lootitem = true end
	if itemtype == ITEMTYPE_STYLE_MATERIAL and Config.GeneralFilterSettings.LootStyleMaterial then lootitem = true end
	if itemtype == ITEMTYPE_RAW_MATERIAL and Config.GeneralFilterSettings.LootStyleRawMaterial then lootitem = true end
	

						---- User Weapon Filter ----
	if Config.GeneralFilterSettings.WeaponFilter == true then
		if itemtype == ITEMTYPE_WEAPON then
						------- LootWindow or Bag? --------
			if bagID == nil or slotID == nil then
				itemtype2 = GetItemLinkWeaponType(itemlink)
			else
				itemtype2 = GetItemWeaponType(bagID,slotID)
			end
						-----------------------------------
						
			local usemetalweaponfilter = METALWEAPONFILTER[itemtype2] or false
			local usewoodweaponfilter = WOODENWEAPONFILTER[itemtype2] or false			
			
			if itemtype2 == WEAPONTYPE_DAGGER and Config.WeaponFilterSettings.Dagger <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_SWORD and Config.WeaponFilterSettings.OHSword <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_AXE and Config.WeaponFilterSettings.OHAxe <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_HAMMER and Config.WeaponFilterSettings.OHHammer <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_SHIELD and Config.WeaponFilterSettings.Shield <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_TWO_HANDED_SWORD and Config.WeaponFilterSettings.THSword <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_TWO_HANDED_HAMMER and  Config.WeaponFilterSettings.THHammer <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_TWO_HANDED_AXE and Config.WeaponFilterSettings.THAxe <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_BOW and Config.WeaponFilterSettings.Bow <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_FIRESTAFF and Config.WeaponFilterSettings.FireStaff <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_FROSTSTAFF and Config.WeaponFilterSettings.FrostStaff <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_LIGHTNINGSTAFF and Config.WeaponFilterSettings.LightningStaff <= quality then lootitem = true end
			if itemtype2 == WEAPONTYPE_HEALINGSTAFF and Config.WeaponFilterSettings.HealingStaff <= quality then lootitem = true end
			
			if canberesearched == true then
				if Config.WeaponFilterSettings.ResearchSmithWeaponTraits == true and usemetalweaponfilter == true then lootitem = true end
				if Config.WeaponFilterSettings.ResearchWoodWeaponTraits == true and usewoodweaponfilter == true then lootitem = true end
			end
		
			if itemtrait == ITEM_TRAIT_TYPE_WEAPON_ORNATE and Config.GeneralFilterSettings.LootOrnate == true then lootitem = true end
		
			if itemtrait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE then
				if Config.WeaponFilterSettings.MetalWeaponIntricate == true and usemetalweaponfilter == true then lootitem = true end
				if Config.WeaponFilterSettings.WoodenWeaponIntricate == true and usewoodweaponfilter == true then lootitem = true end
			end
		end
	end							
							---- User Armor Filter ----
	if Config.GeneralFilterSettings.ArmorFilter == true then
		if itemtype == ITEMTYPE_ARMOR then
						------- LootWindow or Bag? --------
			if bagID == nil or slotID == nil then
				itemtype2 = GetItemLinkArmorType(itemlink)
			else
				itemtype2 = GetItemArmorType(bagID,slotID)
			end
						-----------------------------------
			
			local useclotharmorfilter = CLOTHARMORFILTER[itemtype2] or false
			local usemetalarmorfilter = METALARMORFILTER[itemtype2] or false
			local usejewelryarmorfilter = JEWELRYFILTER[itemtype2] or false
			
			if itemtype2 == ARMORTYPE_LIGHT and Config.ArmorFilterSettings.LightArmor <= quality then lootitem = true end
			if itemtype2 == ARMORTYPE_MEDIUM and Config.ArmorFilterSettings.MediumArmor <= quality then lootitem = true end
			if itemtype2 == ARMORTYPE_HEAVY and Config.ArmorFilterSettings.HeavyArmor <= quality then lootitem = true end
			
			if itemtype2 == ARMORTYPE_NONE and Config.ArmorFilterSettings.JewelryArmor <= quality then lootitem = true end
			
			if canberesearched == true then
				if Config.ArmorFilterSettings.ResearchClothArmorTrait == true and useclotharmorfilter == true then lootitem = true end
				if Config.ArmorFilterSettings.ResearchSmithArmorTrait == true and usemetalarmorfilter == true then lootitem = true end
				if Config.ArmorFilterSettings.ResearchJewelryArmorTrait == true and usejewelryarmorfilter == true then lootitem = true end
			end
			if itemtrait == ITEM_TRAIT_TYPE_ARMOR_ORNATE and Config.GeneralFilterSettings.LootOrnate == true then lootitem = true end
		
			if itemtrait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE then
				if Config.ArmorFilterSettings.SmithArmorIntricate == true and usemetalarmorfilter == true then lootitem = true end
				if Config.ArmorFilterSettings.ClothArmorIntricate == true and useclotharmorfilter == true then lootitem = true end
				if Config.ArmorFilterSettings.JewelryArmorIntricate == true and usejewelryarmorfilter == true then lootitem = true end
			end
		end
	end
						--- User Material Filter ---
	if Config.GeneralFilterSettings.MaterialFilter == true then
		if Config.MaterialFilterSettings.LootCooking == true and usecookinglootfilter == true then lootitem = true end
		if Config.MaterialFilterSettings.LootAlchemy == true and usealchemylootfilter == true then lootitem = true end
		if Config.MaterialFilterSettings.LootClothing == true and useclothierlootfilter == true then lootitem = true end
		if Config.MaterialFilterSettings.LootSmithing == true and useblacksmithlootfilter == true then lootitem = true end
		if Config.MaterialFilterSettings.LootJewelry == true and usejewelrylootfilter == true then lootitem = true end
		if Config.MaterialFilterSettings.LootWood == true and usewoodcraftinglootfilter == true then lootitem = true end
		if Config.MaterialFilterSettings.LootRunes == true and userunelootfilter == true then lootitem = true end
		if Config.MaterialFilterSettings.LootFurnish == true and usefurnishinglootfilter == true then lootitem = true end
	end
	

								--- User Stolen Item Filter ---
	if not Config.GeneralSettings.LootStolen and stolen then lootitem = false end
						------------ Loot Every Questitem ------------
	if isQuest == true then lootitem = true end
								-------------------------------
	return lootitem,stolen
end

function LootManager.LootItemIdentifier()
	local itemtype = "None"
	local itemtype2 = "None"
	local itemtypename = "None"
	local itemtype2name = "None"
	local itemtrait = "None"
	local itemtraitname = "None"
	
	local ITEMTYPENAMES = {
		[1] = "Weapon",
		[2] = "Armor",
		[11] = "Additive",
		[22] = "Lockpick",
		[28] = "Flavoring",
		[10] = "Ingredient",
		[54] = "Fish",
		[16] = "Lure",
		[27] = "Spice",
		[48] = "Trash",
		[56] = "Treasure",
		[5] = "Trophy",
		[4] = "Food",
		[12] = "Drink",
		[9] = "Tool",
		[59] = "Dye Stamp",
		[14] = "Disguise",
		[13] = "Costume",
		[32] = "Deprecated",
		[0] = "None",
		[3] = "Plug",
		[6] = "Siege",
		[29] = "Recipe",
		[49] = "Spellcrafting Table",
		[50] = "Mount",
		[18] = "Container",
		[47] = "Ava Repair",
		[35] = "Blacksmith Raw Material",
		[36] = "Blacksmith Material",
		[41] = "Blacksmith Booster",
		[52] = "Aspect Rune",
		[53] = "Essence Rune",
		[51] = "Potency Rune",
		[25] = "Enchanting Booster",
		[39] = "Clothier Raw Material",
		[40] = "Clothier Material",
		[43] = "Clothier Booster",
		[37] = "Woodworking Raw Material",
		[38] = "Woodworking Material",
		[42] = "Woodworking Booster",
		[46] = "Weapon Trait",
		[45] = "Armor Trait",
		[61] = "Furnishing",
		[62] = "Furnishing Material",
		[65] = "Jewelry Booster",
		[64] = "Jewelry Material",
		[67] = "Jewelry Raw Booster",
		[63] = "Jewelry Raw Material",
		[7] = "Potion",
		[33] = "Potion Base",
		[31] = "Reagent",
		[30] = "Poison",
		[58] = "Poison Base",
		[19] = "Soul Gem",
		[21] = "Armor Glyph",
		[26] = "Jewelry Glyph",
		[20] = "Weapon Glyph",
		[44] = "Style Material",
		[8] = "Racial Style Motif",
		[17] = "Raw Material",
	}
	
	local WEAPONTYPENAMES = {
		[0] = "None",
		[11] = "Dagger",
		[3] = "One-Hand Sword",
		[2] = "One-Hand Hammer",
		[1] = "One-Hand Axe",
		[14] = "Shield",
		[4] = "Two-Hand Sword",
		[6] = "Two-Hand Hammer",
		[5] = "Two-Hand Axe",
		[8] = "Bow",
		[12] = "Firestaff",
		[13] = "Froststaff",
		[15] = "Lightningstaff",
		[9] = "Healingstaff",
	}
	
	local ARMORTYPENAMES = {
		[0] = "None",
		[1] = "Light",
		[2] = "Medium",
		[3] = "Heavy",
	}
	
	local WEAPONTRAITNAMES = {
		[0] = "None",
		[2] = "Charged",
		[8] = "Decisive",
		[5] = "Defending",
		[4] = "Infused",
		[26] = "Nirnhorned",
		[1] = "Powered",
		[3] = "Precise",
		[7] = "Sharpened",
		[9] = "Intricate",
		[10] = "Ornate",
	}
	
	local ARMORTRAITNAMES = {
		[0] = "None",
		[18] = "Divine",
		[13] = "Reinforced",
		[12] = "Impenetrable",
		[16] = "Infused",
		[25] = "Nirnhorned",
		[17] = "Prosperous",
		[15] = "Training",
		[11] = "Sturdy",
		[14] = "Well Fitted",
		[20] = "Intricate",
		[2] = "Ornate",
	}
	
	local JEWELRYTRAITNAMES = {
		[22] = "Arcane",
		[31] = "Bloodthirsty",
		[29] = "Harmony",
		[21] = "Healthy",
		[33] = "Infused",
		[27] = "Intricate",
		[24] = "Ornate",
		[32] = "Protective",
		[23] = "Robust",
		[28] = "Swift",
		[30] = "Triune",	
	}
	
	local itemID,name,icon,amount,quality,value,isQuest,stolen = GetLootItemInfo()
	local itemlink = GetLootItemLink(itemID)
	local itemtype = GetItemLinkItemType(itemlink)
	local itemtrait = GetItemLinkTraitType(itemlink)
	local itemtypename = ITEMTYPENAMES[itemtype]
		if itemtype == ITEMTYPE_WEAPON or itemtype == ITEMTYPE_WEAPON_TRAIT then
			itemtype2 = GetItemLinkWeaponType(itemlink)
			itemtype2name = WEAPONTYPENAMES[itemtype2]
			itemtraitname = WEAPONTRAITNAMES[itemtrait]
		end
		if itemtype == ITEMTYPE_ARMOR or itemtype == ITEMTYPE_ARMOR_TRAIT then
			itemtype2 = GetItemLinkArmorType(itemlink)
			itemtype2name = ARMORTYPENAMES[itemtype2]
			itemtraitname = ARMORTRAITNAMES[itemtrait]
		end
		if itemtraitname == nil then
			itemtraitname = "None"
			itemtrait = 0
		end
	
	return itemID,name,icon,amount,quality,value,isQuest,stolen,itemtype,itemtypename,itemtype2,itemtype2name,itemtrait,itemtraitname
end	

function LootManager.Debugger(funcID,itemnumber,lootitem,stackCountChanged,slotID,newslotID,lootname,currency,amount,isActivated)
	
	local messagespacer = "|cef9a2c——————————————————————————|r"
	
	if Config.GeneralSettings.Debug == "Debug" then
										--- SysChat Register & Unregister Output ---
		if funcID == 20 then d(LootManager.ManagerDebugMark.."REG >>> LootInit() >>> LOOT_UPDATED") end
		if funcID == 21 then d(LootManager.ManagerDebugMark.."UNREG <<< LootInit() <<< LOOT_UPDATED") end
		if funcID == 22 then d(LootManager.ManagerDebugMark.."REG >>> CheckForEquip() >>> INVENTORY_SINGLE_SLOT_UPDATE") end
		if funcID == 23 then d(LootManager.ManagerDebugMark.."UNREG <<< CheckForEquip() <<< INVENTORY_SINGLE_SLOT_UPDATE") end
		if funcID == 24 then d(LootManager.ManagerDebugMark.."REG >>> CheckDestroy() >>> INVENTORY_SINGLE_SLOT_UPDATE") end
		if funcID == 25 then d(LootManager.ManagerDebugMark.."UNREG <<< CheckDestroy() <<< INVENTORY_SINGLE_SLOT_UPDATE") end
		if funcID == 26 then d(LootManager.ManagerDebugMark.."REG >>> StopLooting() >>> EVENT_LOOT_CLOSED") end
		if funcID == 27 then d(LootManager.ManagerDebugMark.."UNREG <<< StopLooting() <<< EVENT_LOOT_CLOSED") end
		if funcID == 28 then d(LootManager.ManagerDebugMark.."Reg >>> PreventLockpick() >>> BEGIN_LOCKPICK") end
		if funcID == 29 then d(LootManager.ManagerDebugMark.."Unreg <<< PreventLockpick() <<< BEGIN_LOCKPICK") end
										--- SysChat Failsafe Debug Output ---
		if funcID == 30 then d(LootManager.ManagerDebugMark.."|cdc1f1fFRAME ERROR: Raise the Update Interval in Loot Manager Option Menu|r") end
		
										--- SysChat ItemInfo Output ---
		if funcID == 0 then
			itemID,name,icon,amount,quality,value,isQuest,stolen,itemtype,itemtypename,itemtype2,itemtype2name,itemtrait,itemtraitname = LootManager.LootItemIdentifier()
			
			name = zo_strformat("<<1>>", name)
			
			d(LootManager.ManagerDebugMark.."ID: |c46c6f5"..itemID.."|r")
			d(LootManager.ManagerDebugMark.."Name: |c46c6f5"..name.."|r")
			d(LootManager.ManagerDebugMark.."Amount: |c46c6f5"..amount.."|r")
			d(LootManager.ManagerDebugMark.."Quality: |c46c6f5"..quality.."|r")
			d(LootManager.ManagerDebugMark.."Gold: |c46c6f5"..value.."|r")
			d(LootManager.ManagerDebugMark.."Quest: |c46c6f5"..tostring(isQuest).."|r")
			d(LootManager.ManagerDebugMark.."Stolen: |c46c6f5"..tostring(stolen).."|r")
			d(LootManager.ManagerDebugMark.."ItemType: |c46c6f5".. itemtype.." |cffff00- |c46c6f5"..itemtypename.."|r")
			if itemtypename == "Armor" then d(LootManager.ManagerDebugMark.."ArmorType: |c46c6f5"..itemtype2.." |cffff00- |c46c6f5"..itemtype2name.."|r") end
			if itemtypename == "Weapon" then d(LootManager.ManagerDebugMark.."WeaponType: |c46c6f5"..itemtype2.." |cffff00- |c46c6f5"..itemtype2name.."|r") end
			d(LootManager.ManagerDebugMark.."Trait: |c46c6f5"..itemtrait.." |cffff00- |c46c6f5"..itemtraitname.."|r")
			if lootitem == true then d(LootManager.ManagerDebugMark.."Loot this: |c33ff00"..tostring(lootitem).."|r") d(messagespacer) else d(LootManager.ManagerDebugMark.."Loot this: |cdc1f1f"..tostring(lootitem).."|r") d(messagespacer) end
		end
										--- Stack & Destroy Debug Output ---
		if funcID == 1 then d(LootManager.ManagerDebugMark.."Create Stack: |c46c6f5"..stackCountChanged.."|r × "..lootname.." from |c46c6f5"..slotID.."|r to |c46c6f5"..newslotID.."|r") end
		if funcID == 2 then d(LootManager.ManagerDebugMark.."|c46c6f5"..stackCountChanged.."|r × "..lootname.." in Slot: |c46c6f5"..slotID.."|r was destroyed!") end
		if funcID == 4 then d(LootManager.ManagerDebugMark.."No Equip or allready existing Itemstack identical with looted Item was found!") d(LootManager.ManagerDebugMark.."Create new ItemStack from current Item!")end
		if funcID == 5 then d(LootManager.ManagerDebugMark.."LootChain Forward!") end
	end
	if Config.GeneralSettings.Debug ~= "Silent" then
		if funcID == 3 then d(LootManager.ManagerDebugMark.."|c46c6f51|r × "..lootname.." destroyed!") end
		if funcID == 6 then d(LootManager.ManagerDebugMark.."|c46c6f5"..amount.."|r "..currency.." looted!") end
		if funcID == 7 then d(LootManager.ManagerDebugMark.."|cdc1f1fForbidden |c46c6f5Lockpick prevented!|r") end
		if funcID == 8 then d(LootManager.ManagerDebugMark.."|cdc1f1fForbidden |c46c6f5Gold Stealing prevented!|r") end
		if funcID == 9 then d(LootManager.ManagerDebugMark.."|cdc1f1fForbidden |c46c6f5Stealing prevented!|r") end
		if funcID == 10 then d(LootManager.ManagerDebugMark.."You have |c46c6f5"..amount.."|r Gold stolen!") end
		if funcID == 11 then d(LootManager.ManagerDebugMark.."Thief Mode is "..isActivated) end
		if funcID == 12 then d(LootManager.ManagerDebugMark.."|cdc1f1fEnable |cef9a2ccOOLsp0t's|r Loot Manager |cdc1f1fbefore you try to activate the Thief Mode!|r") end
		if funcID == 13 then d(LootManager.ManagerDebugMark.."Show Empty: "..isActivated) end
	end
	if Config.GeneralSettings.Debug == "Actions" then
		if funcID == 2 then d(LootManager.ManagerDebugMark.."|c46c6f5"..stackCountChanged.."|r × |c46c6f5"..lootname.."|r was destroyed!") end
	end
end
				--- Register when this Addon loaded ---
EVENT_MANAGER:RegisterForEvent(LootManager.Name, EVENT_ADD_ON_LOADED, LootManager.Init)