Bankir = Bankir or {}
Bankir.Menu = Bankir.Menu or {}

function Bankir.createSettingsMenu(name, author, version)
	local BMBF = Bankir.MenuBuildFunctions
	local LAM = LibAddonMenu2
	
	Bankir.Menu.selectedBankIndex = 1
	Bankir.Menu.selectedBankId = Bankir.Data.bankBagIds[1]
	
	-- Register the Options panel with LAM
	local panelData =
	{
		type = "panel",
		name = name,
		author = author,
		version = version,
		registerForRefresh = true,
	}
	local addonPanel = LAM:RegisterAddonPanel("Bankir_Settings", panelData)
	
	local mainPanelTabsData = {
		{
			title = GetString(SI_CURRENCY_TYPE_NAME), -- "Currency"
			widgets = BMBF.makeCurrencyTab({
				CURT_MONEY,
				CURT_ALLIANCE_POINTS,
				CURT_TELVAR_STONES,
				CURT_WRIT_VOUCHERS,
			}),
		},
		{
			title = GetString(SI_ITEMFILTERTYPE4), -- "Materials"
		},
		{
			title = GetString(SI_ARMORY_EQUIPMENT_LABEL), -- "Equipment"
		},
		{
			title = GetString(SI_ITEMTYPEDISPLAYCATEGORY24), -- "Style Motifs"
			widgets = BMBF.makeWidgetsForTypes("specializedItemType", {
				SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK,
				SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER,
				SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE,
			}),
		},
		{
			title = GetString(SI_TRADINGHOUSECATEGORYHEADER3), -- "Consumables"
		},
		{
			title = GetString(SI_ITEMFILTERTYPE5), -- "Miscellanous"
		},
	}
	
	local craftingTabsData = {
		{
			title = GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_BLACKSMITHING),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_down.dds",
		},
		{
			title = GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_CLOTHIER),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_down.dds",
		},
		{
			title = GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_WOODWORKING),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_down.dds",
		},
		{
			title = GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_ENCHANTING),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_enchanting_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_ENCHANTING_RUNE_ASPECT,
				ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
				ITEMTYPE_ENCHANTING_RUNE_POTENCY,
				--ITEMTYPE_ENCHANTMENT_BOOSTER, -- what is it?
			}),
		},
		{
			title = GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_PROVISIONING),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_provisioning_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_provisioning_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_INGREDIENT,
				ITEMTYPE_FLAVORING,
				ITEMTYPE_SPICE,
			}),
		},
		{
			title = GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_ALCHEMY),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_alchemy_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_alchemy_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_REAGENT,
				ITEMTYPE_POTION_BASE,
				ITEMTYPE_POISON_BASE,
			}),
		},
		{
			title = GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_JEWELRYCRAFTING),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_down.dds",
		},
		{
			title = GetString(SI_SCRIBING_TITLE),
			iconNormal = "/esoui/art/crafting/scribing_tabicon_scribing_up.dds",
			iconPressed = "/esoui/art/crafting/scribing_tabicon_scribing_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_SCRIBING_INK,
				ITEMTYPE_CRAFTED_ABILITY_SCRIPT,
			}),
		},
		{
			title = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_FURNISHING),
			iconNormal = "/esoui/art/crafting/provisioner_indexicon_furnishings_up.dds",
			iconPressed = "/esoui/art/crafting/provisioner_indexicon_furnishings_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_FURNISHING_MATERIAL,
			}),
		},
		{
			title = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_TRAIT_ITEMS),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_itemtrait_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_itemtrait_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_WEAPON_TRAIT,
				ITEMTYPE_ARMOR_TRAIT,
				ITEMTYPE_JEWELRY_TRAIT,
				ITEMTYPE_JEWELRY_RAW_TRAIT,
			}),
		},
		{
			title = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_STYLE_MATERIALS),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_STYLE_MATERIAL,
				ITEMTYPE_RAW_MATERIAL,
			}),
		},
	}
	
	local blacksmithingTabsData = {
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_RAW_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_blacksmithing_rawmats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_blacksmithing_rawmats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_BLACKSMITHING_RAW_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_blacksmithing_mats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_blacksmithing_mats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_BLACKSMITHING_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_BOOSTER),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_blacksmithing_temper_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_blacksmithing_temper_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_BLACKSMITHING_BOOSTER }
			),
		},
	}
	
	local clothingTabsData = {
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_RAW_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_tailoring_rawmats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_tailoring_rawmats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_CLOTHIER_RAW_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_tailoring_mats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_tailoring_mats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_CLOTHIER_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_BOOSTER),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_tailoring_tannin_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_tailoring_tannin_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_CLOTHIER_BOOSTER }
			),
		},
	}
	
	local woodworkingTabsData = {
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_RAW_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_woodworking_rawmats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_woodworking_rawmats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_WOODWORKING_RAW_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_woodworking_mats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_woodworking_mats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_WOODWORKING_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_BOOSTER),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_woodworking_resin_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_woodworking_resin_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_WOODWORKING_BOOSTER }
			),
		},
	}
	
	local jewelrycraftingTabsData = {
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_rawmats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_rawmats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_MATERIAL),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_mats_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_mats_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_JEWELRYCRAFTING_MATERIAL }
			),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_BOOSTER),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_plating_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_plating_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType",
				{ ITEMTYPE_JEWELRYCRAFTING_BOOSTER }
			),
		},
	}
	
	local equipmentTabsData = {
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_LIGHT),
			iconNormal = "esoui/art/icons/progression_tabicon_armorlight_up.dds",
			iconPressed = "esoui/art/icons/progression_tabicon_armorlight_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_LIGHT,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_MEDIUM),
			iconNormal = "esoui/art/icons/progression_tabicon_armormedium_up.dds",
			iconPressed = "esoui/art/icons/progression_tabicon_armormedium_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_MEDIUM,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_HEAVY),
			iconNormal = "esoui/art/icons/progression_tabicon_armorheavy_up.dds",
			iconPressed = "esoui/art/icons/progression_tabicon_armorheavy_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_HEAVY,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_NECK),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_apparel_accessories_necklace_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_apparel_accessories_necklace_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_NECK,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_RING),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_apparel_accessories_ring_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_apparel_accessories_ring_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_RING,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_ONE_HANDED),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_weapons_1h_dagger_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_weapons_1h_dagger_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_ONE_HANDED,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_TWO_HANDED),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_weapons_2h_sword_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_weapons_2h_sword_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_TWO_HANDED,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_BOW),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_bow_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_bow_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_BOW,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_RESTO_STAFF),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_weapons_staff_lightning_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_weapons_staff_lightning_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_RESTO_STAFF,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_DESTRO_STAFF),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_weapons_staff_flame_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_weapons_staff_flame_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_DESTRO_STAFF,
			}),
		},
		{
			title = GetString("SI_EQUIPMENTFILTERTYPE", EQUIPMENT_FILTER_TYPE_SHIELD),
			iconNormal = "/esoui/art/inventory/inventory_tabicon_shield_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_shield_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Equipment" .. EQUIPMENT_FILTER_TYPE_SHIELD,
			}),
		},
	}
	
	local consumablesTabsData = {
		{
			title = GetString(SI_BUFFS_OPTIONS_SECTION_TITLE), -- "Buffs & Debuffs"
			iconNormal = "/esoui/art/inventory/inventory_tabicon_consumables_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_consumables_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_FOOD,
				ITEMTYPE_DRINK,
				ITEMTYPE_POTION,
				ITEMTYPE_POISON,
			}),
		},
		{
			title = GetString(SI_ITEMTYPEDISPLAYCATEGORY27), -- "Repair items"
			iconNormal = "/esoui/art/inventory/inventory_tabicon_repair_up.dds",
			iconPressed = "/esoui/art/inventory/inventory_tabicon_repair_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"RepairKit" .. 44879, -- Equipment repair kit
				ITEMTYPE_CROWN_REPAIR, -- Crown repair kit
				ITEMTYPE_GROUP_REPAIR, -- Group repair kit
				ITEMTYPE_SOUL_GEM,
			}),
		},
		{
			title = GetString(SI_CAMPAIGNRULESETTYPE1), -- "Cyrodiil"
			iconNormal = "/esoui/art/mainmenu/menubar_ava_up.dds",
			iconPressed = "/esoui/art/mainmenu/menubar_ava_down.dds",
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_AVA_REPAIR,
				ITEMTYPE_SIEGE,
			}),
		},
		{
			title = GetString(SI_MAP_INFO_MODE_LOCATIONS),
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_trophy_treasure_map_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_trophy_treasure_map_down.dds",
			widgets = BMBF.makeWidgetsForTypes("specializedItemType", {
				SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP,
				SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT,
				"Unopened" .. SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT,
			}),
		},
		{
			title = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES212), -- "Writs"
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_master_writ_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_master_writ_down.dds",
		},
		{
			title = GetString(SI_ITEMTYPEDISPLAYCATEGORY21), -- "Recipes"
			iconNormal = "/esoui/art/tradinghouse/tradinghouse_trophy_recipe_fragment_up.dds",
			iconPressed = "/esoui/art/tradinghouse/tradinghouse_trophy_recipe_fragment_down.dds",
			widgets = BMBF.makeWidgetsForTypes("specializedItemType", {
				SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD,
				SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK,
				SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
			}),
		},
		{
			title = GetString(SI_RECIPECRAFTINGSYSTEM6), -- "Blueprints"
			iconNormal = "/esoui/art/crafting/provisioner_indexicon_furnishings_up.dds",
			iconPressed = "/esoui/art/crafting/provisioner_indexicon_furnishings_down.dds",
			widgets = BMBF.makeWidgetsForTypes("specializedItemType", {
				SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
				SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
				SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,
				SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
				SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING,
				SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
				SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
			}),
		},
	}
	
	local masterWritsTabsData = {
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT),
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_MASTER_WRIT,
			}),
		},
		{
			title = zo_strformat(GetString(SI_ALCHEMY_UNKNOWN_RESULT), GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT)),
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				"Unopened" .. SPECIALIZED_ITEMTYPE_MASTER_WRIT,
			}),
		},
	}
	
	local miscTabsData = {
		{
			title = GetString(SI_GAMEPADITEMCATEGORY13), -- "Glyphs"
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_GLYPH_ARMOR,
				ITEMTYPE_GLYPH_WEAPON,
				ITEMTYPE_GLYPH_JEWELRY,
			}),
		},
		{
			title = GetString(SI_GAMEPADITEMCATEGORY31), -- "Trophy"
			widgets = BMBF.makeWidgetsForTypes("specializedItemType", {
				SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT,
				SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
				SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT,
				SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT,
				SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH,
				SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE,
			}),
		},
		{
			title = GetString(SI_SPECIALIZEDITEMTYPE850), -- "Container"
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_CONTAINER,
				ITEMTYPE_CONTAINER_CURRENCY,
			}),
		},
		{
			title = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING),
			widgets = BMBF.makeWidgetsForTypes("itemType", {
				ITEMTYPE_FURNISHING,
			}),
		},
		{
			title = GetString(SI_ITEMTYPE48), -- "Trash"
			widgets = BMBF.makeWidgetsForTypes("specializedItemType", {
				SPECIALIZED_ITEMTYPE_TREASURE,
				SPECIALIZED_ITEMTYPE_TROPHY_TOY,
				SPECIALIZED_ITEMTYPE_TRASH,
			}),
		},
		{
			title = GetString(SI_ITEMFILTERTYPE5), -- "Miscellanous"
			widgets = BMBF.makeWidgetsForTypes("specializedItemType", {
				SPECIALIZED_ITEMTYPE_CROWN_ITEM,
				SPECIALIZED_ITEMTYPE_LOCKPICK,
				SPECIALIZED_ITEMTYPE_LURE,
			}),
		},
	}
	
	local function onPanelCreated(panel)
		if (panel ~= addonPanel) then return end -- only proceed if this is our settings panel

		local mainPanel = _G["BankirMenuCustomPanel"]
		local panelWidth = addonPanel:GetWidth()
		mainPanel:SetWidth(panelWidth)
		
		local mainPanelTabs = Bankir.createTabs(mainPanel, "text", mainPanelTabsData)
		local craftingPanel = mainPanelTabs.panels[2]
		local craftingTabs = Bankir.createTabs(craftingPanel, "icon", craftingTabsData)
		local blacksmithingPanel = craftingTabs.panels[1]
		local blacksmithingTabs = Bankir.createTabs(blacksmithingPanel, "icon", blacksmithingTabsData)
		local clothingPanel = craftingTabs.panels[2]
		local clothingTabs = Bankir.createTabs(clothingPanel, "icon", clothingTabsData)
		local woodworkingPanel = craftingTabs.panels[3]
		local woodworkingTabs = Bankir.createTabs(woodworkingPanel, "icon", woodworkingTabsData)
		local jewelrycraftingPanel = craftingTabs.panels[7]
		local jewelrycraftingTabs = Bankir.createTabs(jewelrycraftingPanel, "icon", jewelrycraftingTabsData)
		local equipmentPanel = mainPanelTabs.panels[3]
		local equipmentTabs = Bankir.createTabs(equipmentPanel, "icon", equipmentTabsData)
		local consumablesPanel = mainPanelTabs.panels[5]
		local consumablesTabs = Bankir.createTabs(consumablesPanel, "icon", consumablesTabsData)
		local masterWritsPanel = consumablesTabs.panels[5]
		local masterWritsTabs = Bankir.createTabs(masterWritsPanel, "text", masterWritsTabsData)
		local miscPanel = mainPanelTabs.panels[6]
		local miscTabs = Bankir.createTabs(miscPanel, "text", miscTabsData)
		Bankir.createWidgets(mainPanel)
	end
	
	local optionsData = {
		BMBF.makeProfilesSubmenu(),
		{
			type = "checkbox",
			name = GetString(BANKIR_MENU_MOVE_LOCKED_ITEMS),
			tooltip = GetString(BANKIR_MENU_MOVE_LOCKED_ITEMS_DESC),
			getFunc = function()
				return Bankir.savedVars.moveLockedItems
			end,
			setFunc = function(value)
				Bankir.savedVars.moveLockedItems = value
			end,
		},
		{
			type = "checkbox",
			name = GetString(BANKIR_MENU_SHOW_DEPOSIT_NOT_ALLOWED_MESSAGE),
			tooltip = GetString(BANKIR_MENU_SHOW_DEPOSIT_NOT_ALLOWED_MESSAGE_DESC),
			getFunc = function()
				return Bankir.savedVars.showDepositNotAllowedMessage
			end,
			setFunc = function(value)
				Bankir.savedVars.showDepositNotAllowedMessage = value
			end,
		},
		BMBF.makeBankSelector(),
		BMBF.makeHeader(function() return Bankir.Data.bankBagNames[Bankir.Menu.selectedBankIndex] end),
		{
			type = "custom",
			reference = "BankirMenuCustomPanel",
		},
	}
	
	LAM:RegisterOptionControls("Bankir_Settings", optionsData)
	
	CALLBACK_MANAGER:RegisterCallback('LAM-PanelControlsCreated', onPanelCreated)
end
