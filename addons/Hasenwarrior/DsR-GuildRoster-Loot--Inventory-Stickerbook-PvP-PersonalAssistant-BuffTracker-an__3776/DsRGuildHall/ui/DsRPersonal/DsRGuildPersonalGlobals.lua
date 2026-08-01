DsRGuildPersonalGlobals = {}

DsRPersonal_MOVE_IGNORE   = GetString(DsRGuildPersonal_GeneralNothing)
DsRPersonal_MOVE_DEPOSIT  = "|cFAA0A0" .. GetString(DsRGuildPersonal_GeneralDepoBank)
DsRPersonal_MOVE_WITHDRAW = "|c35fc38" .. GetString(DsRGuildPersonal_GeneralWithBank)

DsRPersonal_REPAIR_ALL     = GetString(DsRGuildPersonal_RepairGlobalsAll)
DsRPersonal_REPAIR_WORN    = GetString(DsRGuildPersonal_RepairGlobalsWorn)
DsRPersonal_REPAIR_NONE    = GetString(DsRGuildPersonal_RepairGlobalsNone)
DsRPersonal_REPAIR_ALWAYS  = GetString(DsRGuildPersonal_RepairGlobalAlways)
DsRPersonal_REPAIR_RAIDING = GetString(DsRGuildPersonal_RepairGlobalRaiding)
DsRPersonal_REPAIR_NEVER   = GetString(DsRGuildPersonal_RepairGlobalNever)

DsRGuildPersonalGlobals.SiegeWeapons = {}
DsRGuildPersonalGlobals.SiegeWeapons[ALLIANCE_ALDMERI_DOMINION] =
	{
		[1]  = { settingName = "KeepRecallStone",       itemId = 141731,    gold = false,   AP = 20000,},
		[2]  = { settingName = "RepairKit",             itemId = 204483,    gold = 90,      AP = 250,},
        [3]  = { settingName = "BatteringRam",          itemId = 27136,     gold = false,   AP = 1800,},
		[4]  = { settingName = "ForwardCamp",           itemId = 29533,     gold = false,   AP = 20000,}, 
		[5]  = { settingName = "FlamingOil",            itemId = 30359,     gold = false,   AP = 800,}, 
		[6]  = { settingName = "Ballista",              itemId = 36567,     gold = false,   AP = 1800,}, 
		[7]  = { settingName = "FireBallista",          itemId = 27970,     gold = 750,     AP = 1200,}, 
		[8]  = { settingName = "LightningBallista",     itemId = 27973,     gold = false,   AP = 1200,},
		[9]  = { settingName = "MeatbagCatapult",       itemId = 27964,     gold = false,   AP = 1200,},		
		[10] = { settingName = "OilCatapult",           itemId = 27967,     gold = false,   AP = 1200,},		
		[11] = { settingName = "ScattershotCatapult",   itemId = 44770,     gold = false,   AP = 1200,},			
		[12] = { settingName = "FirepotTrebuchet",      itemId = 27105,     gold = 750,     AP = 1800,},		
		[13] = { settingName = "IceballTrebuchet",      itemId = 44768,     gold = false,   AP = 1800,},			
		[14] = { settingName = "StoneTrebuchet",        itemId = 44769,     gold = false,   AP = 1800,},		
	} 
DsRGuildPersonalGlobals.SiegeWeapons[ALLIANCE_DAGGERFALL_COVENANT] =
    {
        [1]  = { settingName = "KeepRecallStone",       itemId = 141731,    gold = false,   AP = 20000,},
        [2]  = { settingName = "RepairKit",             itemId = 204483,    gold = 90,      AP = 250,},
		[3]  = { settingName = "BatteringRam",          itemId = 27835,     gold = false,   AP = 1800,},
        [4]  = { settingName = "ForwardCamp",           itemId = 29535,     gold = false,   AP = 20000,},
		[5]  = { settingName = "FlamingOil",            itemId = 30359,     gold = false,   AP = 800,}, 
		[6]  = { settingName = "Ballista",              itemId = 36569,     gold = false,   AP = 1800,}, 
		[7]  = { settingName = "FireBallista",          itemId = 27972,     gold = 750,     AP = 1200,}, 
		[8]  = { settingName = "LightningBallista",     itemId = 27975,     gold = false,   AP = 1200,},
		[9]  = { settingName = "MeatbagCatapult",       itemId = 27966,     gold = false,   AP = 1200,},		
		[10] = { settingName = "OilCatapult",           itemId = 27969,     gold = false,   AP = 1200,},		
		[11] = { settingName = "ScattershotCatapult",   itemId = 44773,     gold = false,   AP = 1200,},			
		[12] = { settingName = "FirepotTrebuchet",      itemId = 27115,     gold = 750,     AP = 1800,},		
		[13] = { settingName = "IceballTrebuchet",      itemId = 44771,     gold = false,   AP = 1800,},			
		[14] = { settingName = "StoneTrebuchet",        itemId = 44772,     gold = false,   AP = 1800,},		
	} 
DsRGuildPersonalGlobals.SiegeWeapons[ALLIANCE_EBONHEART_PACT] =
	{
		[1]  = { settingName = "KeepRecallStone",       itemId = 141731,    gold = false,   AP = 20000,},
		[2]  = { settingName = "RepairKit",             itemId = 204483,    gold = 90,      AP = 250,},
		[3]  = { settingName = "BatteringRam",          itemId = 27850,     gold = false,   AP = 1800,},
        [4]  = { settingName = "ForwardCamp",           itemId = 29534,     gold = false,   AP = 20000,},
		[5]  = { settingName = "FlamingOil",            itemId = 30359,     gold = false,   AP = 800,}, 
		[6]  = { settingName = "Ballista",              itemId = 36568,     gold = false,   AP = 1800,}, 
		[7]  = { settingName = "FireBallista",          itemId = 27971,     gold = 750,     AP = 1200,}, 
		[8]  = { settingName = "LightningBallista",     itemId = 27974,     gold = false,   AP = 1200,},
		[9]  = { settingName = "MeatbagCatapult",       itemId = 27965,     gold = false,   AP = 1200,},		
		[10] = { settingName = "OilCatapult",           itemId = 27968,     gold = false,   AP = 1200,},		
		[11] = { settingName = "ScattershotCatapult",   itemId = 44777,     gold = false,   AP = 1200,},			
		[12] = { settingName = "FirepotTrebuchet",      itemId = 27114,     gold = 750,     AP = 1800,},		
		[13] = { settingName = "IceballTrebuchet",      itemId = 44775,     gold = false,   AP = 1800,},			
		[14] = { settingName = "StoneTrebuchet",        itemId = 44776,     gold = false,   AP = 1800,},		
	} 

