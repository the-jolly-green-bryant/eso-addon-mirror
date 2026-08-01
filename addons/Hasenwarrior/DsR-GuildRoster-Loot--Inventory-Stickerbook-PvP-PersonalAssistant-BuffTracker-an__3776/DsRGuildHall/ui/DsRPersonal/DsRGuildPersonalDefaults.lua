-- Create namespace
DsRGuildPersonalDefaults = {}
local DsRGuildPersonalDefaults = DsRGuildPersonalDefaults  or {}

DsRGuildPersonalDefaults.name = "DsRGuildPersonalDefaults"

local function GetSetDef()
	return DsRGuildPersonalSettings["Default"][GetDisplayName()]
end

DsRGuildPersonalDefaults.GetSetDef = GetSetDef

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Generate Defaults for Account
function DsRGuildPersonalDefaults:Defaults()
    local General = {
        PersonalOnOff    = true,
        CurrencyOnOff 	 = true,
        BankingAvAOnOff  = false,
        AvAShoppingOnOff = true,
        JunkOnOff        = true,
        JunkSellOnOff    = true,
		JunkMarkManu	 = {},
        DeconstructOnOff = true,
        ConsumeOnOff     = true,
		AutoStack 		 = true,
		LastStackBags	 = 0,

        RepairOnOff      		= true,
        RepairChatOnOff      	= true,
		RepairstoreRepairMode   = DsRPersonal_REPAIR_ALL,
		RepairMode 				= DsRPersonal_REPAIR_ALWAYS,
		RepairThreshold 		= 30,
		RepairAnyKit 		    = false,
		RepairrechargeMode 		= DsRPersonal_REPAIR_ALWAYS,
		RepairrechargeThreshold = 50,
		RepairAnyGem 		    = false,
    }

	DsRGuildPersonal.ACCconfig  = ZO_SavedVars:NewAccountWide("DsRGuildPersonalSettings", 1, nil, General)

	local BankingCHAR = DsRGuildPersonalSettings["Default"]
	BankingCHAR[GetDisplayName()] = BankingCHAR[GetDisplayName()] or {}

    for k, v in pairs ( DsRGuildLoot.sV.characters ) do
		local nodeIndex = (#BankingCHAR[GetDisplayName()])
		nodeIndex 		= tostring(v)

		DsRGuildPersonalDefaults.GetSetDef()[nodeIndex] 									= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex] or {}
		DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"] 							= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"] or {}
		DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesSoulLock"] 	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesSoulLock"] or {}
		DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"] 	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"] or {}
		DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"] 						= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"] or {}
		DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"] 						= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"] or {}
		DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"] 						= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"] or {}

		BankingCHAR[GetDisplayName()][nodeIndex] = {
			["Banking"] = {
				Gold            	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["Gold"] or "10000",
				AP              	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["AP"] or "0",
				writvoucher     	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["writvoucher"] or "0",
				TelVar		    	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["TelVar"] or "0",
				SliderSoulgem   	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["SliderSoulgem"] or "200",
				SliderSoulgemEmpty 	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["SliderSoulgemEmpty"] or "200",
				SliderLockPick  	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["SliderLockPick"] or "200",
				SliderTool  	     = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["SliderTool"] or "200",
				DepoRecipeKnown		 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoRecipeKnown"],
				DepoRecipeUnknown	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoRecipeUnknown"],
				DepoRecipeAll   	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoRecipeAll"],
				DepoStileKnown		 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoStileKnown"],
				DepoStileUnknown	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoStileUnknown"],
				DepoBlueprintKnown	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoBlueprintKnown"],
				DepoBlueprintUnknown = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoBlueprintUnknown"],
				DepoScribingKnown	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoScribingKnown"],
				DepoScribingUnknown  = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoScribingUnknown"],
				DepoPvPMeride        = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoPvPMeride"],
				DepoPvPMarke         = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoPvPMarke"],
				DepoPvPBeweis        = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["DepoPvPBeweis"],

				BankingtypesSoulLock = {
					[ITEMTYPE_SOUL_GEM] 			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_SOUL_GEM] or false,
					[SPECIALIZED_ITEMTYPE_SOUL_GEM] = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesSoulLock"][SPECIALIZED_ITEMTYPE_SOUL_GEM] or false,
					[ITEMTYPE_LOCKPICK] 			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_LOCKPICK] or false,
					[ITEMTYPE_TOOL] 			    = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesSoulLock"][ITEMTYPE_TOOL] or false,
				},
				BankingtypesVoucher  = {
					[ITEMTYPE_MASTER_WRIT] 								= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] or 1,
					[SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP]  		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] or 1,
					[SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] 		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] or 1,
					[SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT]  		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] or 1,
					[SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] 		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] or 1,
					[SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] 	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] or 1,
				},
			},
			["BankingAvA"] = {
				depoKeepRecallStone		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoKeepRecallStone"] or 1,
				depoRepairKit	        = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoRepairKit"] or 1,
				depoFlamingOil			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoFlamingOil"] or 1,
				depoForwardCamp			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoForwardCamp"] or 1,
				depoBallista			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoBallista"] or 1,
				depoFireBallista		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoFireBallista"] or 1,
				depoLightningBallista	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoLightningBallista"] or 1,
				depoMeatbagCatapult		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoMeatbagCatapult"] or 1,
				depoOilCatapult			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoOilCatapult"] or 1,
				depoScattershotCatapult	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoScattershotCatapult"] or 1,
				depoFirepotTrebuchet	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoFirepotTrebuchet"] or 1,
				depoIceballTrebuchet	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoIceballTrebuchet"] or 1,
				depoStoneTrebuchet		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoStoneTrebuchet"] or 1,
				depoBatteringRam		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["BankingAvA"]["depoBatteringRam"] or 1,
            },
            ["SiegeMaster"] = {
				buyKeepRecallStone		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyKeepRecallStone"] or 0,
				buyRepairKit	        = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyRepairKit"] or 0,
				buyRepairKitGold        = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyRepairKitGold"] or 0,
				buyFlamingOil			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyFlamingOil"] or 0,
				buyForwardCamp			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyForwardCamp"] or 0,
				buyBallista			 	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyBallista"] or 0,
				buyFireBallista			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyFireBallista"] or 0,
				buyFireBallistaGold  	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyFireBallistaGold"] or 0,
				buyLightningBallista	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyLightningBallista"] or 0,
				buyMeatbagCatapult		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyMeatbagCatapult"] or 0,
				buyOilCatapult			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyOilCatapult"] or 0,
				buyScattershotCatapult	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyScattershotCatapult"] or 0,
				buyFirepotTrebuchet		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyFirepotTrebuchet"] or 0,
				buyFirepotTrebuchetGold	= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyFirepotTrebuchetGold"] or 0,
				buyIceballTrebuchet		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyIceballTrebuchet"] or 0,
				buyStoneTrebuchet		= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyStoneTrebuchet"] or 0,
				buyBatteringRam			= DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["SiegeMaster"]["buyBatteringRam"] or 0,
			},
            ["DeconJunk"] = {
				PlunderToJunk  	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["PlunderToJunk"],
				PleyToJunk  	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["PleyToJunk"],
				OrnateToJunk  	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["OrnateToJunk"],
				NoTraitToJunk  	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["NoTraitToJunk"],
				IndricateToDecon = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["IndricateToDecon"],
				DeconGlyphe		 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconGlyphe"] or DsR_Quality_NORMAL,
				DeconJewelry	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconJewelry"] or DsR_Quality_NORMAL,
				DeconArmor 		 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconArmor"] or DsR_Quality_NORMAL,
				DeconWeapon 	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconWeapon"] or DsR_Quality_NORMAL,
				DeconNoTrait 	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconNoTrait"],
				DeconSetItems 	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconSetItems"],
				DeconCrafted 	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconCrafted"],
				DeconReconstr 	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconReconstr"],
				DeconJunk    	 = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["DeconJunk"],

				ConsumeAutoEatTime = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["ConsumeAutoEatTime"] or "0",
				ConsumeAutoEatTyp  = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["ConsumeAutoEatTyp"],
				ConsumeAutoXPOnOff = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["ConsumeAutoXPOnOff"],
				ConsumeAutoAPOnOff = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["ConsumeAutoAPOnOff"],
				ConsumeAutoEatXP   = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["ConsumeAutoEatXP"],
				ConsumeAutoEatAP   = DsRGuildPersonalDefaults.GetSetDef()[nodeIndex]["DeconJunk"]["ConsumeAutoEatAP"],
            },
		}
	end
end