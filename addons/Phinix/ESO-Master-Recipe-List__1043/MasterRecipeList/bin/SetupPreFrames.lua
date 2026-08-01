local ESOMRL = _G['ESOMRL']
local L = ESOMRL.DB.Strings


ESOMRL.DB.IconStrings = {
	[1]='|t16:16:/MasterRecipeList/bin/textures/known.dds|t ',
	[2]='|t16:16:/MasterRecipeList/bin/textures/knownt.dds|t ',
	[3]='|t16:16:/MasterRecipeList/bin/textures/unknown.dds|t ',
	[4]='|t16:16:/MasterRecipeList/bin/textures/unknownt.dds|t ',
	[5]='|t16:16:/MasterRecipeList/bin/textures/writ.dds|t ',
	[6]='|t16:16:/MasterRecipeList/bin/textures/writt.dds|t ',
}

ESOMRL.DB.QualityColors = {
	[1]= "ffffff",
	[2]= "00ff00",
	[3]= "3a92ff",
	[4]= "a02ef7",
	[5]= "eeca2a",
}

ESOMRL.DB.StationIcons = {
	[1] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t',
	[2] = '  |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t',
	[3] = '  |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[4] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t',
	[5] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[6] = '  |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[7] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[8] = ' |t16:16:/MasterRecipeList/bin/textures/tracking.dds|t',[9] = ' |t16:16:/MasterRecipeList/bin/textures/trackings.dds|t',
}

ESOMRL.DB.StatIcons = {
	[1] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t',
	[2] = '  |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t',
	[3] = '  |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[4] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t',
	[5] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[6] = '  |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[7] = '  |t16:16:/MasterRecipeList/bin/textures/stat_hstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_mstar.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_sstar.dds|t',
	[8] = '  |t16:16:/MasterRecipeList/bin/textures/stat_h.dds|t',
	[9] = '  |t16:16:/MasterRecipeList/bin/textures/stat_m.dds|t',
	[10] = '  |t16:16:/MasterRecipeList/bin/textures/stat_s.dds|t',
	[11] = '  |t16:16:/MasterRecipeList/bin/textures/stat_h.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_m.dds|t',
	[12] = '  |t16:16:/MasterRecipeList/bin/textures/stat_h.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_s.dds|t',
	[13] = '  |t16:16:/MasterRecipeList/bin/textures/stat_m.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_s.dds|t',
	[14] = '  |t16:16:/MasterRecipeList/bin/textures/stat_h.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_m.dds|t |t16:16:/MasterRecipeList/bin/textures/stat_s.dds|t',
}

ESOMRL.DB.StationControls = {
	[1] = {c = nil},
	[2] = {c = nil},
	[3] = {c = nil},
	[4] = {c = nil},
	[5] = {c = nil},
	[6] = {c = nil},
	[7] = {c = nil},
	[8] = {c = nil},
	[9] = {c = nil},
	[10] = {c = nil},
	[11] = {c = nil},
	[12] = {c = nil},
	[13] = {c = nil},
	[14] = {c = nil},
	[15] = {c = nil},
	[16] = {c = nil},
	[17] = {c = nil},
	[18] = {c = nil},
	[19] = {c = nil},
	[20] = {c = nil},
	[21] = {c = nil},
	[22] = {c = nil},
	[23] = {c = nil},
	[24] = {c = nil},
	[25] = {c = nil},
	[26] = {c = nil},
	[27] = {c = nil},
	[28] = {c = nil},
	[29] = {c = nil},
	[30] = {c = nil},
}

ESOMRL.DB.ProvisionerTabs = {
	[1] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 1,
}

ESOMRL.DB.StationData = {
	[CRAFTING_TYPE_BLACKSMITHING] = 	{ tab = 6, nav = 107},
	[CRAFTING_TYPE_CLOTHIER] = 			{ tab = 6, nav = 112},
	[CRAFTING_TYPE_ENCHANTING] = 		{ tab = 3, nav = 117},
	[CRAFTING_TYPE_ALCHEMY] = 			{ tab = 2, nav = 102},
	[CRAFTING_TYPE_PROVISIONING] = 		{ tab = 3, nav = 122},
	[CRAFTING_TYPE_WOODWORKING] = 		{ tab = 6, nav = 127},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = 	{ tab = 6, nav = 132},
}

ESOMRL.DB.StatOptions = {
	[1] = '/MasterRecipeList/bin/textures/opt_stars.dds',
	[2] = '/MasterRecipeList/bin/textures/opt_circles.dds',
}

ESOMRL.DB.StatOptionTooltips = {
	[1] = L.ESOMRL_ICONTT1,
	[2] = L.ESOMRL_ICONTT2,
}

ESOMRL.DB.FurnitureNav = {
	[1] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameAlchemy1T1', c2 = 'ESOMRL_MainFrameFurnitureFrameAlchemy1T2'},
	[2] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameAlchemy2T1', c2 = 'ESOMRL_MainFrameFurnitureFrameAlchemy2T2'},
	[3] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameAlchemy3T1', c2 = 'ESOMRL_MainFrameFurnitureFrameAlchemy3T2'},
	[4] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameAlchemy4T1', c2 = 'ESOMRL_MainFrameFurnitureFrameAlchemy4T2'},
	[5] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameAlchemy5T1', c2 = 'ESOMRL_MainFrameFurnitureFrameAlchemy5T2'},
	[6] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith1T1', c2 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith1T2'},
	[7] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith2T1', c2 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith2T2'},
	[8] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith3T1', c2 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith3T2'},
	[9] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith4T1', c2 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith4T2'},
	[10] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith5T1', c2 = 'ESOMRL_MainFrameFurnitureFrameBlacksmith5T2'},
	[11] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameClothing1T1', c2 = 'ESOMRL_MainFrameFurnitureFrameClothing1T2'},
	[12] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameClothing2T1', c2 = 'ESOMRL_MainFrameFurnitureFrameClothing2T2'},
	[13] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameClothing3T1', c2 = 'ESOMRL_MainFrameFurnitureFrameClothing3T2'},
	[14] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameClothing4T1', c2 = 'ESOMRL_MainFrameFurnitureFrameClothing4T2'},
	[15] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameClothing5T1', c2 = 'ESOMRL_MainFrameFurnitureFrameClothing5T2'},
	[16] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameEnchant1T1', c2 = 'ESOMRL_MainFrameFurnitureFrameEnchant1T2'},
	[17] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameEnchant2T1', c2 = 'ESOMRL_MainFrameFurnitureFrameEnchant2T2'},
	[18] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameEnchant3T1', c2 = 'ESOMRL_MainFrameFurnitureFrameEnchant3T2'},
	[19] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameEnchant4T1', c2 = 'ESOMRL_MainFrameFurnitureFrameEnchant4T2'},
	[20] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameEnchant5T1', c2 = 'ESOMRL_MainFrameFurnitureFrameEnchant5T2'},
	[21] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameProvisioning1T1', c2 = 'ESOMRL_MainFrameFurnitureFrameProvisioning1T2'},
	[22] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameProvisioning2T1', c2 = 'ESOMRL_MainFrameFurnitureFrameProvisioning2T2'},
	[23] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameProvisioning3T1', c2 = 'ESOMRL_MainFrameFurnitureFrameProvisioning3T2'},
	[24] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameProvisioning4T1', c2 = 'ESOMRL_MainFrameFurnitureFrameProvisioning4T2'},
	[25] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameProvisioning5T1', c2 = 'ESOMRL_MainFrameFurnitureFrameProvisioning5T2'},
	[26] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameWoodworking1T1', c2 = 'ESOMRL_MainFrameFurnitureFrameWoodworking1T2'},
	[27] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameWoodworking2T1', c2 = 'ESOMRL_MainFrameFurnitureFrameWoodworking2T2'},
    [28] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameWoodworking3T1', c2 = 'ESOMRL_MainFrameFurnitureFrameWoodworking3T2'},
	[29] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameWoodworking4T1', c2 = 'ESOMRL_MainFrameFurnitureFrameWoodworking4T2'},
	[30] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameWoodworking5T1', c2 = 'ESOMRL_MainFrameFurnitureFrameWoodworking5T2'},
	[31] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameJewelry1T1', c2 = 'ESOMRL_MainFrameFurnitureFrameJewelry1T2'},
	[32] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameJewelry2T1', c2 = 'ESOMRL_MainFrameFurnitureFrameJewelry2T2'},
	[33] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameJewelry3T1', c2 = 'ESOMRL_MainFrameFurnitureFrameJewelry3T2'},
	[34] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameJewelry4T1', c2 = 'ESOMRL_MainFrameFurnitureFrameJewelry4T2'},
	[35] = {active = false, c1 = 'ESOMRL_MainFrameFurnitureFrameJewelry5T1', c2 = 'ESOMRL_MainFrameFurnitureFrameJewelry5T2'},
}

ESOMRL.DB.ProvisioningPsijic = { --Psijic Recipes: 
[64223] = true,			-- Psijic Ambrosia
[115029] = true,		-- Mythic Aetherial Ambrosia
[120077] = true,		-- Aetherial Ambrosia
[139012] = true,		-- Artaeum Pickled Fish Bowl
[139017] = true,		-- Artaeum Takeaway Broth
}

ESOMRL.DB.ProvisioningOrsinium = { --Orsinium Recipes
[71060] = true,			-- Orzorga's Red Frothgar
[71061] = true,			-- Orzorga's Tripe Trifle Pocket
[71062] = true,			-- Orzorga's Blood Price Pie
[71063] = true,			-- Orzorga's Smoked Bear Haunch
}

ESOMRL.DB.ProvisioningWitchesFestival = { --Witches Festival Recipes
[87682] = true,			-- Sweet Sanguine Apples
[87683] = true,			-- Crisp and Crunchy Pumpkin Snack Skewer
[87689] = true,			-- Crunchy Spider Skewer
[87693] = true,			-- Frosted Brains
[87692] = true,			-- Ghastly Eye-Bowl
[87684] = true,			-- Bowl of "Peeled Eyeballs"
[87694] = true,			-- Witchmother's Potent Brew
[87688] = true,			-- Witchmother's Party Punch
[87698] = true,			-- Double Bloody Mara
[153624] = true,		-- Disastrously Bloody Mara
[153626] = true,		-- Pack Leader's Bone Broth
[153628] = true,		-- Bewitched Sugar Skulls
}

ESOMRL.DB.ProvisioningNewLifeFestival = { --New Life Festival Recipes
[96961] = true,			-- Alcaire Festival Sword-Pie
[96963] = true,			-- Old Aldmeri Orphan Gruel
[96962] = true,			-- Rajhin's Sugar Claws
[96964] = true,			-- Jagga-Drenched "Mud Ball"
[96967] = true,			-- Lava Foot Soup-and-Saltrice
[96960] = true,			-- Snow Bear Glow-Wine
[96965] = true,			-- Betnikh Twice-Spiked Ale
[96966] = true,			-- Bergama Warning Fire
[96968] = true,			-- Hissmir Fish-Eye Rye
}

ESOMRL.DB.ProvisioningJesterFestival = { --Jester Festival Recipes
[120767] = true,		-- Princess' Delight
[120768] = true,		-- Candied Jester's Coins
[120769] = true,		-- Dubious Camoran Throne
[120770] = true,		-- Jewels of Misrule
}

ESOMRL.DB.ProvisioningClockworkCity = { --Clockwork City Recipes
[133551] = true,		-- Deregulated Mushroom Stew
[133552] = true,		-- Spring-Loaded Infusion
[133553] = true,		-- Clockwork Citrus Filet
}

ESOMRL.DB.SkillTypes = {
	[1] = "Blacksmithing",
	[2] = "Clothing",
	[3] = "Enchanting",
	[4] = "Alchemy",
	[5] = "Provisioning",
	[6] = "Woodworking",
	[7] = "Jewelry Crafting",
}

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end
