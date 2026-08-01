-- Default values for saved vars
AutobankerGuildBank = AutobankerGuildBank or {}

-- Create a local shortcut for the global table
local ABGB = AutobankerGuildBank

-- Default values for saved vars
ABGB.DefaultSettings = {
	autoMode = false,
	useGlobalSettings = true,
	-- Notifications
	notifications = {
		deposit = true,
		amount = true,
	},
	editProfileId = "default",
	-- The New Profile Table
	guildProfiles = {
		["default"] = {
			enabled = false,
			typesToDeposit = {
				[ITEMTYPE_POTION_BASE] = false,
				[ITEMTYPE_POISON_BASE] = false,
				[ITEMTYPE_INGREDIENT] = false,
				[ITEMTYPE_STYLE_MATERIAL] = false,
				[ITEMTYPE_FOOD] = false,
				[ITEMTYPE_DRINK] = false,
				[ITEMTYPE_TREASURE] = false,
				[ITEMTYPE_LOCKPICK] = false,
				[ITEMTYPE_FURNISHING_MATERIAL] = false,
				[ITEMTYPE_MASTER_WRIT] = false,
				[ITEMTYPE_POTION] = false,
				[ITEMTYPE_POISON] = false,
				[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = false,
				[ITEMTYPE_FURNISHING] = false,
				[ITEMTYPE_SIEGE] = false,
				[ITEMTYPE_AVA_REPAIR] = false,
				[ITEMTYPE_BLACKSMITHING_MATERIAL] = false,
				[ITEMTYPE_CLOTHIER_MATERIAL] = false,
				[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = false,
				[ITEMTYPE_WOODWORKING_MATERIAL] = false,
				[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = false,
				[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = false,
				[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = false,
				[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = false,
				[ITEMTYPE_BLACKSMITHING_BOOSTER] = false,
				[ITEMTYPE_CLOTHIER_BOOSTER] = false,
				[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = false,
				[ITEMTYPE_WOODWORKING_BOOSTER] = false,
				[ITEMTYPE_ARMOR_TRAIT] = false,
				[ITEMTYPE_JEWELRY_TRAIT] = false,
				[ITEMTYPE_WEAPON_TRAIT] = false,
				[ITEMTYPE_REAGENT] = false,
				[ITEMTYPE_ENCHANTING_RUNE_ASPECT] = false,
				[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = false,
				[ITEMTYPE_ENCHANTING_RUNE_POTENCY] = false,
				[ITEMTYPE_SCRIBING_INK] = false,

			},
			-- Specific Ids
			itemIdsToDeposit = {
				-- Unknown Writs
				[217917] = false, -- BlackSmithing
				[217918] = false, -- Clothier
				[217923] = false, -- Jewelry
				[217919] = false, -- Woodworking
				[217922] = false, -- Alchemy
				[217920] = false, -- Enchanting
				[217921] = false, -- Provisioning
				-- Unknown Surveys
				[219849] = false, -- Blacksmith
				[219850] = false, -- Clothier
				[219854] = false, -- Jewelry
				[219851] = false, -- Woodworker
				[219853] = false, -- Alchemist
				[219852] = false, -- Enchanter
				-- Unknown Treasure Maps
				[224681] = false, -- Unopened Treasure Map
			},
			shouldDepositTreasureMap = false,
			shouldDepositResearchable = false,
			shouldDepositRecipeFragment = false,
			shouldDepositRuneboxFragment = false,
			shouldDepositMotifBook = false,
			shouldDepositMotifChapter = false,
			shouldDepositStylePage = false,
			shouldDepositFurnishingRecipe = false,
			shouldDepositProvisioningRecipe = false,
			depositFilledSoulGems = false,
			depositEmptySoulGems = false,
			depositRepairKits = false,
			-- Toggles depositing all intricate types
			shouldDepositIntricate = false,
			-- Specific categories for intricate
			intricateType = {
				[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = false,
				[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = false,
				[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = false,
			},
			-- Currencies
			CURRENCY_DATA =
			{
				[CURT_MONEY] =
				{
					depositAmount = 5000,
					deposit = false,
					slider = { max = 1000000, step = 1000 },
				},
			},
		}
	}
}
