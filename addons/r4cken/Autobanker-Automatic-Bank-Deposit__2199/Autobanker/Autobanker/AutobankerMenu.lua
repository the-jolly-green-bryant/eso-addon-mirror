--[[
-------------------------------------------------------------------------------
-- Autobanker, made by r4cken + updated by Muffins714
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at :
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

This AddOn has taken inspiration and small snippets from Dustman by Ayantir, Garkin & iFedix
]]

-- Make sure AB is declared before use

if AB == nil then AB = {} end
AB.SavedVars = AB.SavedVars or {}
AB.GlobalSavedVars = AB.GlobalSavedVars or {}

local function GetSettings()
	if AB.SavedVars.useGlobalSettings then
		return AB.GlobalSavedVars
	else
		return AB.SavedVars
	end
end


AB.GetSettings = GetSettings

--addon menu
function AB.CreateSettingsMenu(defaults)
	-- Load settings->addons menu
	local menu = LibAddonMenu2

	local function GetCurrencyNameAndIcon(currencyType)
		return zo_strformat("<<T:1>>", ZO_Currency_FormatPlatform(currencyType, nil, ZO_CURRENCY_FORMAT_PLURAL_NAME_ICON))
	end

	local function ClampLowestToZero(value)
		return value < 0 and 0 or value
	end

	-- Create the panel for the addons menu
	local panel = {
		type = "panel",
		name = AB.name,
		displayName = ZO_HIGHLIGHT_TEXT:Colorize(AB.name),
		author = AB.author,
		version = "" .. AB.version,
		slashCommand = "/autobanker",
		website = AB.website,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	menu:RegisterAddonPanel("Auto_banker", panel)

	-- Make all submenues
	--
	local currencySubmenu = {}
	for currencyType, _ in ipairs(defaults.CURRENCY_DATA) do
		local curr = GetSettings().CURRENCY_DATA[currencyType]
		if (curr.slider ~= nil) then -- TODO: Implement the other currencies, this hack allows us to have empty tables when doing ipairs
			table.insert(currencySubmenu, {
				type = "divider",
				width = "full",
				height = 5,
				alpha = 0.5,
			})
			table.insert(currencySubmenu, {
				type = "slider",
				name = GetCurrencyNameAndIcon(currencyType),
				min = 0,
				max = curr.slider.max,
				step = curr.slider.step,
				inputLocation = "right",
				tooltip = GetString(AB_SLIDER_TOOLTIP),
				decimals = 0,
				getFunc = function() return curr.minimum end,
				setFunc = function(value) curr.minimum = ClampLowestToZero(value) end,
				default = defaults.CURRENCY_DATA[currencyType].minimum,
				disabled = function() return not curr.deposit end,
			})
			table.insert(currencySubmenu, {
				type = "checkbox",
				name = SI_BANK_DEPOSIT,
				getFunc = function() return curr.deposit end,
				setFunc = function(value) curr.deposit = value end,
				default = defaults.CURRENCY_DATA[currencyType].deposit,
			})
		end
	end

	local traitSubmenu = {}
	table.insert(traitSubmenu, {
		type = "checkbox",
		name = GetString(SI_ITEMTRAITTYPE27),
		getFunc = function() return GetSettings().shouldDepositIntricate end,
		setFunc = function(value) GetSettings().shouldDepositIntricate = value end,
		default = defaults.shouldDepositIntricate,
	})

	table.insert(traitSubmenu, {
		type = "checkbox",
		name = zo_strformat("<<1>> <<2>>", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE),
			GetString(SI_ITEM_FORMAT_STR_ARMOR)),
		getFunc = function() return GetSettings().intricateType[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] end,
		setFunc = function(value) GetSettings().intricateType[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = value end,
		disabled = function() return not GetSettings().shouldDepositIntricate end,
		default = defaults.intricateType[ITEM_TRAIT_TYPE_ARMOR_INTRICATE],
	})

	table.insert(traitSubmenu, {
		type = "checkbox",
		name = zo_strformat("<<1>> <<2>>", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INTRICATE),
			GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON)),
		getFunc = function() return GetSettings().intricateType[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] end,
		setFunc = function(value) GetSettings().intricateType[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = value end,
		disabled = function() return not GetSettings().shouldDepositIntricate end,
		default = defaults.intricateType[ITEM_TRAIT_TYPE_WEAPON_INTRICATE],
	})

	table.insert(traitSubmenu, {
		type = "checkbox",
		name = zo_strformat("<<1>> <<2>>", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_INTRICATE),
			GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY)),
		getFunc = function() return GetSettings().intricateType[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] end,
		setFunc = function(value) GetSettings().intricateType[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = value end,
		disabled = function() return not GetSettings().shouldDepositIntricate end,
		default = defaults.intricateType[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE],
	})


	local researchSubmenu = {}
	table.insert(researchSubmenu, {
		type = "checkbox",
		name = GetString(AB_RESEARCHABLE),
		getFunc = function() return GetSettings().shouldDepositResearchable end,
		setFunc = function(value) GetSettings().shouldDepositResearchable = value end,
		default = defaults.shouldDepositResearchable,
	})

	local mapsSubmenu = {
		{
			type = "checkbox",
			name = GetString(AB_TREASURE_MAP),
			tooltip = GetString(AB_TREASURE_MAP_TOOLTIP),
			getFunc = function()
				local ids = { 224681 }
				for _, id in ipairs(ids) do
					if not GetSettings().itemIdsToDeposit[id] then return false end
				end
				return true
			end,
			setFunc = function(value)
				local ids = { 224681 }
				for _, id in ipairs(ids) do
					GetSettings().itemIdsToDeposit[id] = value
				end
			end,
			default = false,
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP),
			getFunc = function() return GetSettings().shouldDepositTreasureMap end,
			setFunc = function(value)
				GetSettings().shouldDepositTreasureMap = value
			end,
			default = defaults.shouldDepositTreasureMap,
		},
		{
			type = "checkbox",
			name = GetString(AB_SURVEYS),
			tooltip = GetString(AB_SURVEYS_TOOLTIP),
			getFunc = function()
				local ids = { 219849, 219850, 219851, 219852, 219853, 219854 }
				for _, id in ipairs(ids) do
					if not GetSettings().itemIdsToDeposit[id] then return false end
				end
				return true
			end,
			setFunc = function(value)
				local ids = { 219849, 219850, 219851, 219852, 219853, 219854 }
				for _, id in ipairs(ids) do
					GetSettings().itemIdsToDeposit[id] = value
				end
			end,
			default = false,
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT),
			getFunc = function() return GetSettings().shouldDepositSurveyReport end,
			setFunc = function(value)
				GetSettings().shouldDepositSurveyReport = value
			end,
			default = defaults.shouldDepositSurveyReport,
		},
	}

	local masterWritSubmenu = {
		{
			type = "checkbox",
			name = GetString(AB_WRITS),
			tooltip = GetString(AB_WRITS_TOOLTIP),
			getFunc = function()
				local ids = { 217917, 217918, 217923, 217919, 217922, 217920, 217921 }
				for _, id in ipairs(ids) do
					if not GetSettings().itemIdsToDeposit[id] then return false end
				end
				return true
			end,
			setFunc = function(value)
				local ids = { 217917, 217918, 217923, 217919, 217922, 217920, 217921 }
				for _, id in ipairs(ids) do
					GetSettings().itemIdsToDeposit[id] = value
				end
			end,
			default = false,
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_MASTER_WRIT),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_MASTER_WRIT] end,
			setFunc = function(value) GetSettings().typesToDeposit[ITEMTYPE_MASTER_WRIT] = value end,
			default = defaults.typesToDeposit[ITEMTYPE_MASTER_WRIT],
		},
	}

	local craftingMaterialSubmenu = {
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ASPECT] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ASPECT] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ASPECT],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ESSENCE],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_POTENCY] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_POTENCY] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_POTENCY],
		},
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(AB_MATERIALS_NAME),
			tooltip = GetString(AB_MATDES),
			getFunc = function()
				return GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_MATERIAL]
					and GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_MATERIAL]
					and GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_MATERIAL]
					and GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_MATERIAL]
			end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_MATERIAL] = value
				GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_MATERIAL] = value
				GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = value
				GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_MATERIAL] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_BLACKSMITHING_MATERIAL]
				and defaults.typesToDeposit[ITEMTYPE_CLOTHIER_MATERIAL]
				and defaults.typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_MATERIAL]
				and defaults.typesToDeposit[ITEMTYPE_WOODWORKING_MATERIAL],
		},
		{
			type = "checkbox",
			name = GetString(AB_RAWMATERIALS_NAME),
			tooltip = GetString(AB_MATDES),
			getFunc = function()
				return GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL]
					and GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_RAW_MATERIAL]
					and GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL]
					and GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_RAW_MATERIAL]
			end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = value
				GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = value
				GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = value
				GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL]
				and defaults.typesToDeposit[ITEMTYPE_CLOTHIER_RAW_MATERIAL]
				and defaults.typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL]
				and defaults.typesToDeposit[ITEMTYPE_WOODWORKING_RAW_MATERIAL],
		},
		{
			type = "checkbox",
			name = GetString(AB_TRAITMATERIALS_NAME),
			tooltip = GetString(AB_TRAITDES),
			getFunc = function()
				return GetSettings().typesToDeposit[ITEMTYPE_ARMOR_TRAIT]
					and GetSettings().typesToDeposit[ITEMTYPE_JEWELRY_TRAIT]
					and GetSettings().typesToDeposit[ITEMTYPE_WEAPON_TRAIT]
			end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_ARMOR_TRAIT] = value
				GetSettings().typesToDeposit[ITEMTYPE_JEWELRY_TRAIT] = value
				GetSettings().typesToDeposit[ITEMTYPE_WEAPON_TRAIT] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_ARMOR_TRAIT]
				and defaults.typesToDeposit[ITEMTYPE_JEWELRY_TRAIT]
				and defaults.typesToDeposit[ITEMTYPE_WEAPON_TRAIT],
		},
		{
			type = "checkbox",
			name = GetString(AB_UPGRADEMATERIALS_NAME),
			tooltip = GetString(AB_UPMATDES),
			getFunc = function()
				return GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_BOOSTER]
					and GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_BOOSTER]
					and GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_BOOSTER]
					and GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_BOOSTER]
			end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_BOOSTER] = value
				GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_BOOSTER] = value
				GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = value
				GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_BOOSTER] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_BLACKSMITHING_BOOSTER]
				and defaults.typesToDeposit[ITEMTYPE_CLOTHIER_BOOSTER]
				and defaults.typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_BOOSTER]
				and defaults.typesToDeposit[ITEMTYPE_WOODWORKING_BOOSTER],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_STYLE_MATERIAL),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_STYLE_MATERIAL] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_STYLE_MATERIAL] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_STYLE_MATERIAL],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING_MATERIAL),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_FURNISHING_MATERIAL] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_FURNISHING_MATERIAL] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_FURNISHING_MATERIAL],
		},
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_POTION_BASE),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_POTION_BASE] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_POTION_BASE] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_POTION_BASE],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_POISON_BASE),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_POISON_BASE] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_POISON_BASE] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_POISON_BASE],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_REAGENT),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_REAGENT] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_REAGENT] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_REAGENT],
		},
		{
			type = "checkbox",
			name = GetString(AB_INGREDIENT_NAME),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_INGREDIENT] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_INGREDIENT] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_INGREDIENT],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_SCRIBING_INK),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_SCRIBING_INK] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_SCRIBING_INK] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_SCRIBING_INK],
		},
	}

	local consumableSubmenu = {
		{
			type = "checkbox",
			name = GetString(AB_SGF), -- Filled Soul Gems
			getFunc = function() return GetSettings().depositFilledSoulGems end,
			setFunc = function(value)
				GetSettings().depositFilledSoulGems = value
			end,
			width = "half",
			default = defaults.depositFilledSoulGems,
		},
		{
			type = "checkbox",
			name = GetString(AB_SGE), -- Empty Soul Gems
			getFunc = function() return GetSettings().depositEmptySoulGems end,
			setFunc = function(value)
				GetSettings().depositEmptySoulGems = value
			end,
			width = "half",
			default = defaults.depositEmptySoulGems,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_FOOD),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_FOOD] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_FOOD] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_FOOD],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_DRINK),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_DRINK] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_DRINK] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_DRINK],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_POTION),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_POTION] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_POTION] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_POTION],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_POISON),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_POISON] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_POISON] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_POISON],
		},
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(AB_RECIPE_F),
			getFunc = function() return GetSettings().shouldDepositFurnishingRecipe end,
			setFunc = function(value)
				GetSettings().shouldDepositFurnishingRecipe = value
			end,
			width = "half",
			default = defaults.shouldDepositFurnishingRecipe,
		},
		{
			type = "checkbox",
			name = GetString(AB_RECIPE_P),
			getFunc = function() return GetSettings().shouldDepositProvisioningRecipe end,
			setFunc = function(value)
				GetSettings().shouldDepositProvisioningRecipe = value
			end,
			width = "half",
			default = defaults.shouldDepositProvisioningRecipe,
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_CRAFTED_ABILITY_SCRIPT],
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK),
			getFunc = function() return GetSettings().shouldDepositMotifBook end,
			setFunc = function(value)
				GetSettings().shouldDepositMotifBook = value
			end,
			default = defaults.shouldDepositMotifBook,
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER),
			getFunc = function() return GetSettings().shouldDepositMotifChapter end,
			setFunc = function(value)
				GetSettings().shouldDepositMotifChapter = value
			end,
			default = defaults.shouldDepositMotifChapter,
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE),
			tooltip = GetString(AB_STYLE_PAGE),
			getFunc = function() return GetSettings().shouldDepositStylePage end,
			setFunc = function(value)
				GetSettings().shouldDepositStylePage = value
			end,
			default = defaults.shouldDepositStylePage,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0.5,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_CROWN_ITEM),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_CROWN_ITEM] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_CROWN_ITEM] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_CROWN_ITEM],
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT),
			getFunc = function() return GetSettings().shouldDepositRecipeFragment end,
			setFunc = function(value)
				GetSettings().shouldDepositRecipeFragment = value
			end,
			default = defaults.shouldDepositRecipeFragment,
		},
		{
			type = "checkbox",
			name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT),
			getFunc = function() return GetSettings().shouldDepositRuneboxFragment end,
			setFunc = function(value)
				GetSettings().shouldDepositRuneboxFragment = value
			end,
			default = defaults.shouldDepositRuneboxFragment,
		},
		{
			type = "checkbox",
			name = GetString(AB_REPAIR_KITS),
			tooltip = GetString(AB_RK_TOOLTIP),
			getFunc = function()
				return AB.GetSettings().depositRepairKits
			end,
			setFunc = function(value)
				AB.GetSettings().depositRepairKits = value
			end,
			--		width = "half",
			default = defaults.depositRepairKits,
		},
	}

	local furnishingSubmenu = {
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_FURNISHING] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_FURNISHING] = value
			end,
			--		width = "half",
			default = defaults.typesToDeposit[ITEMTYPE_FURNISHING],
		},
	}

	local miscSubmenu = {
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_TREASURE] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_TREASURE] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_TREASURE],
		},
		{
			type = "checkbox",
			name = GetString(AB_TOOLS_NAME),
			getFunc = function()
				return GetSettings().typesToDeposit[ITEMTYPE_SIEGE]
					and GetSettings().typesToDeposit[ITEMTYPE_AVA_REPAIR]
					and GetSettings().typesToDeposit[ITEMTYPE_RECALL_STONE]
			end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_SIEGE] = value
				GetSettings().typesToDeposit[ITEMTYPE_AVA_REPAIR] = value
				GetSettings().typesToDeposit[ITEMTYPE_RECALL_STONE] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_SIEGE]
				and defaults.typesToDeposit[ITEMTYPE_AVA_REPAIR]
				and defaults.typesToDeposit[ITEMTYPE_RECALL_STONE],
		},
		{
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", ITEMTYPE_LOCKPICK),
			getFunc = function() return GetSettings().typesToDeposit[ITEMTYPE_LOCKPICK] end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_LOCKPICK] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_LOCKPICK],
		},
		{
			type = "checkbox",
			name = GetString(SI_ITEMTYPEDISPLAYCATEGORY30), -- Glyphs 03/31
			--	tooltip = GetString(AB_MATDES),
			getFunc = function()
				return GetSettings().typesToDeposit[ITEMTYPE_GLYPH_ARMOR]
					and GetSettings().typesToDeposit[ITEMTYPE_GLYPH_JEWELRY]
					and GetSettings().typesToDeposit[ITEMTYPE_GLYPH_WEAPON]
			end,
			setFunc = function(value)
				GetSettings().typesToDeposit[ITEMTYPE_GLYPH_ARMOR] = value
				GetSettings().typesToDeposit[ITEMTYPE_GLYPH_JEWELRY] = value
				GetSettings().typesToDeposit[ITEMTYPE_GLYPH_WEAPON] = value
			end,
			default = defaults.typesToDeposit[ITEMTYPE_GLYPH_ARMOR]
				and defaults.typesToDeposit[ITEMTYPE_GLYPH_JEWELRY]
				and defaults.typesToDeposit[ITEMTYPE_GLYPH_WEAPON],
		},
	}

	-- Autobanker entries & submenus in the addon settings panel
	local options = {
		{
			-- General Settings
			type = "header",
			name = zo_strformat("<<1>> <<2>>", GetString(SI_AUDIO_OPTIONS_GENERAL), GetString(SI_GAME_MENU_SETTINGS)),
		},
		{
			type    = "checkbox",
			name    = GetString(AB_GLOBAL),
			tooltip = GetString(AB_GLOBAL_TOOLTIP),
			warning = GetString(AB_WARNING),
			getFunc = function()
				return AB.SavedVars.useGlobalSettings
			end,
			setFunc = function(state)
				AB.SavedVars.useGlobalSettings = state
				if state then
					AB.SavedVars = AB.GlobalSavedVars
				else
					AB.SavedVars = ZO_SavedVars:NewCharacterIdSettings("AutobankerSavedVars", 5, nil, defaults)
				end
				SCENE_MANAGER:ShowBaseScene()
				zo_callLater(function() ReloadUI() end, 2000)
			end,
			width   = "half",
			default = defaults.useGlobalSettings,
		},
		{
			type = "checkbox",
			name = GetString(AB_MANUAL_OVERRIDE),
			getFunc = function() return GetSettings().automaticTransfers end,
			setFunc = function(value)
				GetSettings().automaticTransfers = value
				AB.ToggleManualOverride()
			end,
			tooltip = GetString(AB_MANUAL_OVERRIDE_TOOLTIP),
			width = "half",
			default = defaults.useManualActivation,
		},
		{
			-- Notifications Settings
			type = "header",
			name = GetString(SI_MAIN_MENU_NOTIFICATIONS),
		},
		{
			type = "checkbox",
			name = GetString(AB_NOTIFICATION_DEPOSIT),
			tooltip = GetString(AB_NOTIFICATION_TOOLTIP),
			getFunc = function() return GetSettings().notifications.deposit end,
			setFunc = function(value)
				GetSettings().notifications.deposit = value
			end,
			width = "half",
			default = defaults.notifications.deposit,
		},
		{
			type = "checkbox",
			name = GetString(AB_NOTIFICATION_AMOUNT),
			tooltip = GetString(AB_NOTIFICATION_TOOLTIP),
			getFunc = function() return GetSettings().notifications.amount end,
			setFunc = function(value)
				GetSettings().notifications.amount = value
			end,
			width = "half",
			default = defaults.notifications.amount,
		},
		{
			type = "submenu",
			name = GetString(SI_INVENTORY_MODE_CURRENCY),
			controls = currencySubmenu,
		},
		-- Autobanker Banking settings
		{
			-- Trait Items
			type = "submenu",
			name = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_TRAIT_ITEMS),
			controls = traitSubmenu,
		},
		{
			-- Research
			type = "submenu",
			name = GetString(SI_ITEMTRAITINFORMATION3),
			controls = researchSubmenu,
		},
		{
			-- Maps
			type = "submenu",
			name = GetString(AB_MAPS),
			controls = mapsSubmenu,
		},
		{
			-- Writs
			type = "submenu",
			name = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES212),
			controls = masterWritSubmenu,
		},
		{
			-- Materials
			type = "submenu",
			name = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CRAFTING),
			controls = craftingMaterialSubmenu,
		},
		{
			-- Consumable
			type = "submenu",
			-- Consumable
			name = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CONSUMABLE),
			controls = consumableSubmenu,
		},
		{
			-- Furnishings
			type = "submenu",
			-- Furnishings
			name = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_FURNISHING),
			controls = furnishingSubmenu,
		},
		{
			-- Miscellaneous
			type = "submenu",
			name = GetString(SI_PLAYER_MENU_MISC),
			controls = miscSubmenu,
		},
		--[[
		{
			-- Notifications
			type = "header",
			name = GetString(SI_MAIN_MENU_NOTIFICATIONS),
		},
		
		{
			type = "checkbox",
			name = GetString(AB_NOTIFICATION_DEPOSIT),
			getFunc = function() return GetSettings().notifications.deposit end,
			setFunc = function(value)
				GetSettings().notifications.deposit = value
			end,
			default = defaults.notifications.deposit,
		},
		{
			type = "checkbox",
			name = GetString(AB_NOTIFICATION_AMOUNT),
			getFunc = function() return GetSettings().notifications.amount end,
			setFunc = function(value)
				GetSettings().notifications.amount = value
			end,
			default = defaults.notifications.amount,
		},
		]]
	}
	menu:RegisterOptionControls("Auto_banker", options)
end
