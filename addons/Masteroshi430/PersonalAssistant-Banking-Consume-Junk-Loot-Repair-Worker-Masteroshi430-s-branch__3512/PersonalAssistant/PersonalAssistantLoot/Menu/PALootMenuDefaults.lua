-- Local instances of Global tables --
local PA = PersonalAssistant

-- =====================================================================================================================

local PALootMenuDefaults = {
    name = table.concat({GetString(SI_PA_PROFILE), " ", 1}),

    -- ---------------------------------------------
    AutoLoot = {
	  autoLootEnabled = false,
	},
	
    LootEvents = {
        lootEventsEnabled = true,

        LootRecipes = {
            unknownRecipeMsg = true,
        },

        LootStyles = {
            unknownMotifMsg = true,
            unknownStylePageMsg = true,
			unknownScribingScriptMsg = true,
			autoLearnMotif = false,
			autoLearnRecipe = false,
			autoLearnFurnishingPlan = false,
			autoLearnStylePage = false,
			autoLearnScribingScript = false,
			autoLearnScribingGrimoire = false,
			autoMarkAsJunkRecipes = false,
			autoMarkAsJunkScribingScript = false,
			autoMarkAsJunkScribingGrimoire = false,
        },

        LootApparelWeapons = {
            unknownTraitMsg = true,
            uncollectedSetMsg = true,
			autoBind = false,
        },

        LootCompanionItems = {
            qualityThreshold = ITEM_FUNCTIONAL_QUALITY_ARTIFACT,
        },
        Fishing = {
            AutoFillet = false,
        },
        Collectibles = {
            AutoCombine = false,
        },
    },

    ItemIcons = {
        itemIconsEnabled = true,

        Recipes = {
            showKnownIcon = false,
            showUnknownIcon = true,
        },

        Motifs = {
            showKnownIcon = false,
            showUnknownIcon = true,
        },
		
        Scribing = {
            showKnownIcon = false,
            showUnknownIcon = true,
        },

        StylePageContainers = {
            showKnownIcon = false,
            showUnknownIcon = true,
        },

        ApparelWeapons = {
            showKnownIcon = false,
            showUnknownIcon = true,
        },

        iconTooltipShown = true,
        iconSizeList = 16,
        iconSizeGrid = 16,
        iconXOffsetList = 0,
        iconYOffsetList = 0,
        iconXOffsetGrid = 2,
        iconYOffsetGrid = -2,

        SetCollection = {
            showUncollectedIcon = true,
            iconSizeList = 16,
            iconSizeGrid = 16,
            iconXOffsetList = 20,
            iconYOffsetList = 0,
            iconXOffsetGrid = -2,
            iconYOffsetGrid = -2,
        },

        CompanionItems = {
            showCompanionItemIcon = true,
            iconSizeList = 16,
            iconSizeGrid = 16,
            iconXOffsetList = 0,
            iconYOffsetList = 0,
            iconXOffsetGrid = 2,
            iconYOffsetGrid = -2,
        },
    },

    InventorySpace = {
        lowInventorySpaceWarning = true,
        lowInventorySpaceThreshold = 10,
    },

    silentMode = false,
}

-- =====================================================================================================================
-- Export
PA.MenuDefaults = PA.MenuDefaults or {}
PA.MenuDefaults.PALoot = PALootMenuDefaults