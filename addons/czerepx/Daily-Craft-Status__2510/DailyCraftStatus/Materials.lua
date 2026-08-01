-- portions from Awesome Guild Store addon by sirinsidiator

local _addon = _G["DailyCraftStatus"]

_addon.DCS_TIERED_MATS = {
	[CRAFTING_TYPE_BLACKSMITHING] = {  
		808, -- Iron Ore
		5413, -- Iron Ingot
		5820, -- High Iron Ore
		4487, -- Steel Ingot
		23103, -- Orichalcum Ore
		23107, -- Orichalcum Ingot
		23104, -- Dwarven Ore
		6000, -- Dwarven Ingot
		23105, -- Ebony Ore
		6001, -- Ebony Ingot
		4482, -- Calcinium Ore
		46127, -- Calcinium Ingot
		23133, -- Galatite Ore
		46128, -- Galatite Ingot
		23134, -- Quicksilver Ore
		46129, -- Quicksilver Ingot
		23135, -- Voidstone Ore
		46130, -- Voidstone Ingot
		71198, -- Rubedite Ore
		64489 -- Rubedite Ingot
	},	

	[CRAFTING_TYPE_CLOTHIER] = {
		812, -- Raw Jute
		811, -- Jute
		793, -- Rawhide Scraps
		794, -- Rawhide
		4464, -- Raw Flax
		4463, -- Flax
		4448, -- Hide Scraps
		4447, -- Hide
		23129, -- Raw Cotton
		23125, -- Cotton
		23095, -- Leather Scraps
		23099, -- Leather
		23130, -- Raw Spidersilk
		23126, -- Spidersilk
		6020, -- Thick Leather Scraps
		23100, -- Thick Leather
		23131, -- Raw Ebonthread
		23127, -- Ebonthread
		23097, -- Fell Hide Scraps
		23101, -- Fell Hide
		33217, -- Raw Kreshweed
		46131, -- Kresh Fiber
		23142, -- Topgrain Hide Scraps
		46135, -- Topgrain Hide
		33218, -- Raw Ironweed
		46132, -- Ironthread
		23143, -- Iron Hide Scraps
		46136, -- Iron Hide
		33219, -- Raw Silverweed
		46133, -- Silverweave
		800, -- Superb Hide Scraps
		46137, -- Superb Hide
		33220, -- Raw Void Bloom
		46134, -- Void Cloth
		4478, -- Shadowhide Scraps
		46138, -- Shadowhide
		71200, -- Raw Ancestor Silk
		64504, -- Ancestor Silk
		71239, -- Rubedo Hide Scraps
		64506 -- Rubedo Leather
	},	

	[CRAFTING_TYPE_WOODWORKING] = {
		802, -- Rough Maple
		803, -- Sanded Maple
		521, -- Rough Oak
		533, -- Sanded Oak
		23117, -- Rough Beech
		23121, -- Sanded Beech
		23118, -- Rough Hickory
		23122, -- Sanded Hickory
		23119, -- Rough Yew
		23123, -- Sanded Yew
		818, -- Rough Birch
		46139, -- Sanded Birch
		4439, -- Rough Ash
		46140, -- Sanded Ash
		23137, -- Rough Mahogany
		46141, -- Sanded Mahogany
		23138, -- Rough Nightwood
		46142, -- Sanded Nightwood
		71199, -- Rough Ruby Ash
		64502 -- Sanded Ruby Ash
	},	

	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		135137, -- Pewter Dust
		135138, -- Pewter Ounce
		135139, -- Copper Dust
		135140, -- Copper Ounce
		135141, -- Silver Dust
		135142, -- Silver Ounce
		135143, -- Electrum Dust
		135144, -- Electrum Ounce
		135145, -- Platinum Dust
		135146 -- Platinum Ounce
	},

	[CRAFTING_TYPE_ALCHEMY] = {
		30148,  -- Blue Entoloma
		30149,  -- Stinkhorn
		30151,  -- Emetic Russula
		30152,  -- Violet Coprinus
		30153,  -- Namira's Rot
		30154,  -- White Cap
		30155,  -- Luminous Russula
		30156,  -- Imp Stool
		30157,  -- Blessed Thistle
		30158,  -- Lady's Smock
		30159,  -- Wormwood
		30160,  -- Bugloss
		30161,  -- Corn Flower
		30162,  -- Dragonthorn
		30163,  -- Mountain Flower
		30164,  -- Columbine
		30165,  -- Nirnroot
		30166,  -- Water Hyacinth
		77581,  -- Torchbug Thorax
		77583,  -- Beetle Scuttle
		77584,  -- Spider Egg
		77585,  -- Butterfly Wing
		77587,  -- Fleshfly Larva
		77589,  -- Scrib Jelly
		77590,  -- Nightshade
		77591,  -- Mudcrab Chitin
		139019, -- Powdered Mother of Pearl
		139020, -- Clam Gall
		150789, -- Dragon's Bile
		150731, -- Dragon's Blood
		150671, -- Dragon Rheum
		150672, -- Crimson Nirnroot
		150670,	-- Vile Coagulant
		150669, -- Chaurus Egg


		883, -- Natural Water
		75357, -- Grease
		1187, -- Clear Water
		75358, -- Ichor
		4570, -- Pristine Water
		75359, -- Slime
		23265, -- Cleansed Water
		75360, -- Gall
		23266, -- Filtered Water
		75361, -- Terebinthine
		23267, -- Purified Water
		75362, -- Pitch-Bile
		23268, -- Cloud Mist
		75363, -- Tarblack
		64500, -- Star Dew
		75364, -- Night-Oil
		64501, -- Lorkhan's Tears
		75365, -- Alkahest
	},	

	[CRAFTING_TYPE_ENCHANTING] = {
		45831, -- Oko
		45832, -- Makko
		45833, -- Deni
		45834, -- Okoma
		45835, -- Makkoma
		45836, -- Denima
		45837, -- Kuoko
		45838, -- Rakeipa
		45839, -- Dekeipa
		45840, -- Meip
		45841, -- Haoko
		45842, -- Deteri
		45843, -- Okori
		45846, -- Oru
		45847, -- Taderi
		45848, -- Makderi
		45849, -- Kaderi
		68342, -- Hakeijo
		166045, -- Indeko

		45817, -- Jode
		45855, -- Jora
		45818, -- Notade
		45856, -- Porade
		45819, -- Ode
		45857, -- Jera
		45820, -- Tade
		45806, -- Jejora
		45807, -- Odra
		45821, -- Jayde
		45808, -- Pojora
		45822, -- Edode
		45809, -- Edora
		45823, -- Pojode
		45810, -- Jaera
		45824, -- Rekude
		45811, -- Pora
		45825, -- Hade
		45812, -- Denara
		45826, -- Idode
		45813, -- Rera
		45827, -- Pode
		45814, -- Derado
		45828, -- Kedeko
		45815, -- Rekura
		45829, -- Rede
		45816, -- Kura
		45830, -- Kude
		64508, -- Jehade
		64509, -- Rejera
		68340, -- Itade
		68341, -- Repora
		
		45850, --Ta
		45851, --Jejota
		45852, --Denata
		45853, --Rekuta
		45854, --Kuta
	},	

}


_addon.DCS_WRIT_MATS = {
	[CRAFTING_TYPE_ALCHEMY] = {
		[0] = {},
		[1] = { 883, -- Natural Water
				30161,  -- Corn Flower
				30157,  -- Blessed Thistle
				30159,  -- Wormwood
				},
		[2] = { 4570, -- Pristine Water
				30161,  -- Corn Flower
				30157,  -- Blessed Thistle
				30160,  -- Bugloss
				},
		[3] = { 23265, -- Cleansed Water
				30159,  -- Wormwood
				30158,  -- Lady's Smock
				30163,  -- Mountain Flower
				},
		[4] = { 23266, -- Filtered Water
				30158,  -- Lady's Smock
				30162,  -- Dragonthorn
				},
		[5] = { 23267, -- Purified Water
				30159,  -- Wormwood
				30166,  -- Water Hyacinth
				},
		[6] = { 23268, -- Cloud Mist
				30165,  -- Nirnroot
				},
		[7] = { 23268, -- Cloud Mist
				30165,  -- Nirnroot
				},
		[8] = { 64501, -- Lorkhan's Tears
		        75365, -- Alkahest
				77591,  -- Mudcrab Chitin
				30165,  -- Nirnroot
				77590,  -- Nightshade
				30156,  -- Imp Stool
				77584,  -- Spider Egg
				30152,  -- Violet Coprinus
		        },
		
	},
	[CRAFTING_TYPE_ENCHANTING] = { 
		[0] = {	
				45850, --Ta
				45831, -- Oko
				45832, -- Makko
				45833, -- Deni
			},
		[1] = {	
				45817, -- Jode
				45855, -- Jora
			},
		[2] = {	
				45819, -- Ode
				45857, -- Jera
			},
		[3] = {	
				45807, -- Odra
				45821, -- Jayde
			},
		[4] = {
				45809, -- Edora
				45823, -- Pojode
			},
		[5] = {
				45811, -- Pora
				45825, -- Hade
			},
		[6] = {
				45826, -- Idode
				45813, -- Rera
			},
		[7] = {
				45814, -- Derado
			},
		[8] = {
				45828, -- Kedeko
				45815, -- Rekura
				45835, -- Makkoma
			},
		[9] = {
				45829, -- Rede
				45816, -- Kura
				45836, -- Denima
			},
		[10] = {
				64508, -- Jehade
				64509, -- Rejera
			},
	},
}
