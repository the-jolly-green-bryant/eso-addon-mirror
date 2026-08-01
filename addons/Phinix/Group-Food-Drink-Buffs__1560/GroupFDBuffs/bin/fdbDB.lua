local GroupFDB = _G['GroupFDB']

GroupFDB.fdbDB = {
--/script local _, _, abilityDescription = GetItemLinkOnUseAbilityInfo("|H1:item:"..tostring(71076)..":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h") d(abilityDescription)

-- Junk Food
[66551]		= {buffType = 1, itemID = 0},		-- Increase Max Health
[66568]		= {buffType = 1, itemID = 0},		-- Increase Max Magicka
[66576]		= {buffType = 1, itemID = 0},		-- Increase Max Stamina
[66125] 	= {buffType = 1, itemID = 0},		-- Increase Max Health (Unknown)

-- Junk Drink
[66586]		= {buffType = 2, itemID = 0},		-- Health Recovery
[66590]		= {buffType = 2, itemID = 0},		-- Magicka Recovery
[66594]		= {buffType = 2, itemID = 0},		-- Stamina Recovery
[66132] 	= {buffType = 2, itemID = 0},		-- Health Recovery (Alcoholic Drinks)
[66137]		= {buffType = 2, itemID = 0},		-- Magicka Recovery (Tea)
[66141] 	= {buffType = 2, itemID = 0},		-- Stamina Recovery (Tonics)
[66586] 	= {buffType = 2, itemID = 0},		-- Health Recovery (Unknown)
[66590] 	= {buffType = 2, itemID = 0},		-- Magicka Recovery (Unknown)
[66594] 	= {buffType = 2, itemID = 0},		-- Stamina Recovery (Unknown)
[84732] 	= {buffType = 2, itemID = 0},		-- Increase Health Regen (Unknown)
[84733] 	= {buffType = 2, itemID = 0},		-- Increase Health Regen (Unknown)
[85497] 	= {buffType = 2, itemID = 0},		-- All Primary Stat Recovery (Unknown)
[86560] 	= {buffType = 2, itemID = 0},		-- Stamina Recovery (Unknown)
[86674] 	= {buffType = 2, itemID = 0},		-- Stamina Recovery (Unknown)
[86678] 	= {buffType = 2, itemID = 0},		-- Health Recovery (Unknown)
[86747] 	= {buffType = 2, itemID = 0},		-- Health Recovery (Unknown)
[92433] 	= {buffType = 2, itemID = 0},		-- Health & Magicka Recovery (Unknown)
[92476] 	= {buffType = 2, itemID = 0},		-- Health & Stamina Recovery (Unknown)
[148633]	= {buffType = 2, itemID = 0},		-- Sparkling Mudcrab Apple Cider (Quest)

-- Standard Food
[61259]		= {buffType = 3, itemID = 0},		-- Increase Max Health (Meat Dishes)
[61260]		= {buffType = 3, itemID = 0},		-- Increase Max Magicka (Fruit Dishes)
[61261]		= {buffType = 3, itemID = 0},		-- Increase Max Stamina (Vegetable Dishes)
[61257]		= {buffType = 3, itemID = 0},		-- Increase Max Health & Magicka (Savouries)
[61255]		= {buffType = 3, itemID = 0},		-- Increase Max Health & Stamina (Ragout)
[61294]		= {buffType = 3, itemID = 0},		-- Increase Max Magicka & Stamina (Entremet)
[61218]		= {buffType = 3, itemID = 0},		-- Increase All Primary Stats (Gourmet)

-- Standard Drink
[61322]		= {buffType = 4, itemID = 0},		-- Health Recovery (Alcoholic Drinks)
[61325]		= {buffType = 4, itemID = 0},		-- Magicka Recovery (Tea)
[61328]		= {buffType = 4, itemID = 0},		-- Stamina Recovery (Tonics)
[61335]		= {buffType = 4, itemID = 0},		-- Health & Magicka Recovery (Liqueurs)
[61340]		= {buffType = 4, itemID = 0},		-- Health & Stamina Recovery (Tinctures)
[61345]		= {buffType = 4, itemID = 0},		-- Magicka & Stamina Recovery (Cordial Teas)
[61350]		= {buffType = 4, itemID = 0},		-- All Primary Stat Recovery (Distillates)

-- Festivals, Chapters, and DLC
[72816]		= {buffType = 5, itemID = 71056},	-- Red Frothgar (Orzorga's Red Frothgar)
[72819]		= {buffType = 5, itemID = 71057},	-- Tripe Trifle Pocket (Orzorga's Tripe Trifle Pocket)
[72822]		= {buffType = 5, itemID = 71058},	-- Blood Price Pie (Orzorga's Blood Price Pie)
[72824]		= {buffType = 5, itemID = 71059},	-- Smoked Bear Haunch, (Orzorga's Smoked Bear Haunch)
[86677]		= {buffType = 5, itemID = 112426},	-- Warning Fire (Bergama Warning Fire)
[84678]		= {buffType = 5, itemID = 87685},	-- Increase Max Magicka (Princess's Delight, Sweet Sanguine Apples)
[84681]		= {buffType = 5, itemID = 87686},	-- Pumpkin Snack Skewer (Crisp and Crunchy Pumpkin Snack Skewer)
[84700]		= {buffType = 5, itemID = 87687},	-- "Eyeballs" (Bowl of "Peeled Eyeballs")
[84704]		= {buffType = 5, itemID = 87690},	-- Witchmother's Party Punch (Witchmother's Party Punch)
[84709]		= {buffType = 5, itemID = 87691},	-- Crunchy Spider Skewer (Crunchy Spider Skewer)
[84720]		= {buffType = 5, itemID = 87695},	-- Eye Scream (Ghastly Eye Bowl)
[84725]		= {buffType = 5, itemID = 87696},	-- The Brains! (Frosted Brains)
[84731]		= {buffType = 5, itemID = 87697},	-- Witchmother's Potent Brew (Witchmother's Potent Brew)
[84735]		= {buffType = 5, itemID = 87699},	-- Purifying Bloody Mara (Purifying Bloody Mara)
[86559]		= {buffType = 5, itemID = 101879},	-- Fish Eye Rye (Hissmir Fish-Eye Rye)
[86673]		= {buffType = 5, itemID = 112475},	-- Lava Foot Soup & Saltrice (Lava Foot Soup-and-Saltrice)
[86746]		= {buffType = 5, itemID = 112433},	-- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
[86749]		= {buffType = 5, itemID = 112434},	-- Mud Ball (Jagga-Drenched "Mud Ball")
[86787]		= {buffType = 5, itemID = 112438},	-- Rajhin's Sugar Claws (Rajhin's Sugar Claws)
[86789]		= {buffType = 5, itemID = 112439},	-- Alcaire Festival Sword-Pie (Alcaire Festival Sword-Pie)
[86791]		= {buffType = 5, itemID = 112440},	-- Ice Bear Glow-Wine (Snow Bear Glow-Wine)
[89955]		= {buffType = 5, itemID = 120762},	-- Candied Jester's Coins (Candied Jester's Coins)
[89957]		= {buffType = 5, itemID = 120763},	-- Dubious Camoran Throne (Dubious Camoran Throne)
[89971]		= {buffType = 5, itemID = 120764},	-- Jewels of Misrule (Jewels of Misrule)
[100488]	= {buffType = 5, itemID = 133555},	-- Spring-Loaded Infusion (Spring-Loaded Infusion)
[100498]	= {buffType = 5, itemID = 133556},	-- Clockwork Citrus Filet (Clockwork Citrus Filet)
[100502]	= {buffType = 5, itemID = 133554},	-- Deregulated Mushroom Stew (Deregulated Mushroom Stew)
[107748]	= {buffType = 5, itemID = 139016},	-- Lure Allure (Artaeum Pickled Fish Bowl)
[107789]	= {buffType = 5, itemID = 139018},	-- Artaeum Takeaway Broth (Artaeum Takeaway Broth)
[127572]	= {buffType = 5, itemID = 153627},	-- Pack Leader's Bone Broth
[127596]	= {buffType = 5, itemID = 153629},	-- Bewitched Sugar Skulls
[127531]	= {buffType = 5, itemID = 153625},	-- Corrupting Bloody Mara (Corrupting Bloody Mara)

-- Cyrodilic Food & Drink
[72961]		= {buffType = 6, itemID = 0},		-- Max Stamina and Magicka (Cyrodilic Field Bar) 71076
[72956]		= {buffType = 6, itemID = 0},		-- Max Health and Stamina (Cyrodilic Field Tack) 71074
[72959]		= {buffType = 6, itemID = 0},		-- Max Health and Magicka (Cyrodilic Field Treat) 71075
[72965]		= {buffType = 6, itemID = 0},		-- Health and Stamina Recovery (Cyrodilic Field Brew) 71077
[72968]		= {buffType = 6, itemID = 0},		-- Health and Magicka Recovery (Cyrodilic Field Tea) 71078
[72971]		= {buffType = 6, itemID = 0},		-- Magicka and Stamina Recovery (Cyrodilic Field Tonic) 71079

-- Crown Food & Drink
[68411]		= {buffType = 7, itemID = 0},		-- Increase All Primary Stats (Crown Fortifying Meal)
[68416]		= {buffType = 7, itemID = 0},		-- All Primary Stat Recovery (Crown Refreshing Drink)

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

GroupFDB.AccountDefaults = {
	showGroup = true,
	showRaid = true,
	showActive = true,
	showJunk = true,
	showNone = false,
	groupMode = 1,
	raidMode = 1,
	groupSize = 16,
	raidSize = 16,
	gXO = 0,
	gYO = 0,
	rXO = 0,
	rYO = 0,
}
