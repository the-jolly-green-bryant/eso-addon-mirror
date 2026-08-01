-- Local instances of Global tables --
local PA = PersonalAssistant

-- =====================================================================================================================

local PARepairMenuDefaults = {
    name = table.concat({GetString(SI_PA_PROFILE), " ", 1}),

    -- ---------------------------------------------
    autoRepairEnabled = true,
    autoRepairInventoryEnabled = false,
	autoBuyRepairKitsEnabled = false,
    autoBuySoulGemsEnabled = false,
	autoBuySiegeItemsEnabled = false,

    -- ---------------------------------------------

    RepairEquipped = {
        repairWithGold = true,
        repairWithGoldDurabilityThreshold = 75,

        repairWithRepairKit = false,
        defaultRepairKit = DEFAULT_SOUL_GEM_CHOICE_GOLD,
		groupRepairKit = false,
        repairWithRepairKitThreshold = 10,
        lowRepairKitWarning = true,
        lowRepairKitThreshold = 10,
    },

    -- ---------------------------------------------

    RepairInventory = {
        repairWithGold = true,
        repairWithGoldDurabilityThreshold = 75,
    },

    -- ---------------------------------------------

    RechargeWeapons = {
        useSoulGems = false,
        defaultSoulGem = DEFAULT_SOUL_GEM_CHOICE_CROWN,
        lowSoulGemWarning = true,
        lowSoulGemThreshold = 10,
    },

    -- ---------------------------------------------	
	
	AutoBuyRepairKits = {
	    buyEquipmentRepairKits = false,
		buyEquipmentRepairKitsThreshold = 20,
		
	    buyCyrodiilRepairKits = false,
		buyCyrodiilRepairKitsThreshold = 20,
		buyCyrodiilRepairKitsPriority = "AP->GOLD",
		
	    buyBridgeAndMilegateRepairKits = false,
		buyBridgeAndMilegateRepairKitsThreshold = 20,
		buyBridgeAndMilegateRepairKitsPriority = "AP->GOLD",
	}, 
	
    -- ---------------------------------------------
	
	AutoBuySoulGems = {
        buyFullSoulGems = false,
		buyFullSoulGemsThreshold = 20,
		
        buyEmptySoulGems = false,
		buyEmptySoulGemsThreshold = 20,
		
		buyLockpicks = false,
		buyLockpicksThreshold = 20,
	},

    -- ---------------------------------------------
	
	AutoBuySiegeItems = {
		buyKeepRecallStone = false,
		buyKeepRecallStoneThreshold = 20,
		buyKeepRecallStonePriority = "AP",
		
		buyFlamingOil = false,
		buyFlamingOilThreshold = 20,
		buyFlamingOilPriority = "AP",
		
		buyForwardCamp = false,
		buyForwardCampThreshold = 20,
		buyForwardCampPriority = "AP",
		
		buyBallista = false,
		buyBallistaThreshold = 20,
		buyBallistaPriority = "AP",		
		
		buyFireBallista = false,
		buyFireBallistaThreshold = 20,
		buyFireBallistaPriority = "AP->GOLD",
		
		buyLightningBallista = false,
		buyLightningBallistaThreshold = 20,
		buyLightningBallistaPriority = "AP",

		buyMeatbagCatapult = false,
		buyMeatbagCatapultThreshold = 20,
		buyMeatbagCatapultPriority = "AP",		

		buyOilCatapult = false,
		buyOilCatapultThreshold = 20,
		buyOilCatapultPriority = "AP",

		buyScattershotCatapult = false,
		buyScattershotCatapultThreshold = 20,
		buyScattershotCatapultPriority = "AP",

		buyFirepotTrebuchet = false,
		buyFirepotTrebuchetThreshold = 20,
		buyFirepotTrebuchetPriority = "AP->GOLD",		

		buyIceballTrebuchet = false,
		buyIceballTrebuchetThreshold = 20,
		buyIceballTrebuchetPriority = "AP",
		
		buyStoneTrebuchet = false,
		buyStoneTrebuchetThreshold = 20,
		buyStoneTrebuchetPriority = "AP",	

		buyBatteringRam = false,
		buyBatteringRamThreshold = 20,
		buyBatteringRamPriority = "AP",

		buyTriPots = false,
		buyTriPotsThreshold = 20,
		buyTriPotsPriority = "AP",
    
		buySigilOfImperialRetreat = false,
		buySigilOfImperialRetreatThreshold = 20,
		buySigilOfImperialRetreatPriority = "AP",
	},


    -- ---------------------------------------------

    silentMode = false,
}

-- =====================================================================================================================
-- Export
PA.MenuDefaults = PA.MenuDefaults or {}
PA.MenuDefaults.PARepair = PARepairMenuDefaults