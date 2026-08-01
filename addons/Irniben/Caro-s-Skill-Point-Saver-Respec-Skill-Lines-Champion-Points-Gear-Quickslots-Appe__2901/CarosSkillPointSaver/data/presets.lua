-- This file contains all presets found in the addon. The numbers for the presets have no meaning, but have to be in consecutive order and have to be unambiguous. 
-- The name doesn't have to contain the source and the role as they appear in separate columns.
-- The roles are numbered: 1 = DD (unspecific), 2 = Tank, (3 = undefined), 4 = Heal, 5 = Magicka DD, 6 = Stamina DD, 7 = Not role-specific
-- Disciplines: 1 = Craft, 2 = Warfare, 3 = Fitness
-- BasestatsToFill: Skills in this category will be filled with remaining points in the end
-- Slotted: The four skills that should be slotted if available.
-- switch = number If this field is present, a message will be displayed promting to switch to a specific skill.
-- situational = {} If this list contains entries, the user will get a message with recommended situational skills.
-- aoe, penetration, crit, aoe, offBalance, offBalanceUp: can be used to give recommendations for certain scenarios

-- check for values too high or invalid after updates:
-- /script for i,v in pairs(CSPS.CPPresets) do if v.preset then local anything = false for j, w in pairs(v.preset) do local entry = CSPS.cp.table[w[1]] if entry then  local maxV = entry.maxValue if maxV < w[2] then d(w[1]..maxV) anything = true end else d(w[1]) anything = true end end if anything then d("Preset: "..i) end end end

-- /script for i, v in pairs(CSPS.CPPresets[17].preset) do if GetChampionSkillType(v[1]) > 0 then d(v[1]..GetChampionSkillName(v[1])) end end 

local GS = GetString
local directDamage = GS(SI_CHATCHANNELCATEGORIES51)
local dot = GS(SI_CHATCHANNELCATEGORIES52)
local weaponspelldamage = string.format("%s/%s", GS(SI_DERIVEDSTATS25), GS(SI_DERIVEDSTATS35))
local aoe = GS(CSPS_AOE)
local crit = GS(CSPS_CRIT)
local offBalance = GS(CSPS_OffBalance)
local singleTarget = GS(CSPS_SingleTarget)
		
CSPS.CPPresets = {
	[1] = {
		name = "Tank", 			-- Warfare
		website = "thetankclub.com",
		updated = {11, 08, 2025},
		points = "(dynamic)",
		discipline = 2,
		role = 2,
		source = "The Tank Club",
		preset = {
			{6,10}, {20,10}, {14,20}, 
			{15,13}, {16,10}, {15,20}, 
			{16,20}, {136,50}, {265,25}, {134,25}, {133,25}, 
			{159,50}, {265,50}, {99,20}, {134,50}, 
			{6,20}, {10,10}, {17,20}, {10,20}, {108,10}, {108,20}, 
			{17,40}, {18,20}, {18,40}, {11,10}, {11,20}, 
			{133,50}, {22,30}, {21,30}, {20,20}, {28,50}, 
			{24,50}, {260,50}, {160,50}, {263,50}, {26,50}			
		},
		 
		slotted = {136,265,134,159}, 
	},
	[2] = {
		name = "Tank",			-- Fitness
		website = "thetankclub.com",
		updated = {11, 08, 2025},
		points = "(dynamic)",
		discipline = 3,
		role = 2,
		source = "The Tank Club",
		preset = {	
			{2,20}, {34,20}, {35,10}, 
			{2,30}, {35,20}, {34,30}, {35,30}, 
			{39,10}, {44,3}, {267,30}, {2,40}, 
			{267,50}, {34,40}, {37,30}, {128,10}, 
			{35,40}, {128,20}, {43,30}, {44,6}, 
			{2,50}, {34,50}, {35,50}, {53,10}, 
			{113,20}, {42,8}, {42,16}, {38,20}, 
			{270,40}, {270,50}, {40,30}, {45,10}, 
			{58,25}, {58,50}, {39,20}, {53,50}, 
			{273,50}, {52,50}, {51,50}, {63,50}, 
			{266,50}, {46,50}, {49,50}, {271,50}					
		},
		slotted = {2,34,35,267},
	},

	[7] = {
		name = "Mag DD",  -- Fitness
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		updated = {11, 08, 2025},
		points = "(dynamic)",
		discipline = 3,
		role = 5,
		source = "Skinny Cheeks",
		preset = {
			{2,50}, {35,50}, {34,50}, {38,10}, {42,8}, {113,20}, {63,10}, {46,50}, {58,25}, {56,50}, -- fixed part
			{37,30}, {128,20}, {38,20}, {42,16}, {39,20}, {43,30}, {44,3}, {40,30}, {50,20}, {58,50}, -- passives to fill
			{51,50}, {270,50}, {53,50}, {273,50}, {47,50}, {266,50}, {52,50}, {48,50} -- additional slottables
		},
		slotted = {2,35,34,46},
	},
	
	
	
	[8] = {
		name = "Stam DD",  -- Fitness
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		updated = {11, 08, 2025},
		points = "(dynamic)",
		discipline = 3,
		role = 6,
		source = "Skinny Cheeks",
		preset = {
			{2,50}, {35,50}, {34,50}, {38,10}, {42,8}, {113,20}, {63,10}, {46,50}, {58,25}, {56,50}, -- fixed part
			{37,30}, {128,20}, {38,20}, {42,16}, {39,20}, {43,30}, {44,3}, {40,30}, {50,20}, {58,50}, -- passives to fill
			{51,50}, {270,50}, {53,50}, {273,50}, {48,50}, {266,50}, {52,50}, {47,50}, -- additional slottables
		},
		slotted = {2,35,34,46},
	},
	
	[15] = {
		name = "Healer",
		website = "healers-haven.com",
		updated = {11, 08, 2025},
		points = "(dynamic)",
		source = "Duncan88 / Healers Haven",
		role = 4,
		discipline = 3,
		preset = {
			{2,50}, {34,50}, {38,10}, {42,8}, {270,50}, 
			{113,20}, {39,10}, {43,30}, {37,30}, {128,20}, {51,50}, 
			{42,16}, {44,6}, {53,50}, {38,20}, {45,10}, {58,50}, 
			{39,20}, {40,30}, {50,20}, {45,30}, {273,50}, {52,50}, 
			{35,50}, {56,50}
		},
		slotted = {2,34,270,51},
	},
	[16] = {
		name = "Healer",
		website = "healers-haven.com",
		updated = {11, 08, 2025},
		points = "(dynamic)",
		source = "Duncan88 / Healers Haven",
		role = 4,
		discipline = 2,
		preset = {
			{99,20}, {108,20}, {20,10}, {14,20}, {24,50}, {28,50}, {263,50}, {262,50}, 
			{11,20}, {16,20}, {15,20}, {10,10}, {17,40}, {21,30}, {20,20}, {6,20}, 
			{10,20}, {18,40}, {22,30}, {9,50}, {26,50}, {4,50}, {12,50}
		},
		slotted = {24,28,263,262},
	},
	[17] = {
		name = "Farming",
		addInfo = GS(CSPS_CPPDescr_JoaTFarming),
		updated = {03, 21, 2025},
		points = "(dynamic)",
		source = "@Orejana",
		role = 7,
		discipline = 1,
		preset = {
			{68, 10}, {76, 25}, {84, 50}, {83, 50}, {78, 75},
			{81, 50}, {91, 25}, {79, 50}, {75, 10}, {85, 30},
			{74, 50}, {1, 50}, {66, 50}, {279,25}, {77, 25}, {70, 50},
			{75, 50}, {71, 50}, {69, 50}, {279,50}, {90, 25}, {68, 30},
			{86,50}, {88, 50}, {89, 25}, {65, 50}, {67, 40},
			{80, 75}, {92, 50}, {87, 30}, {82, 75}, {72, 45}
		},
		slotted = {66, 78, 88, 89},
	},
	[18] = {
		name = "Fishing",
		addInfo = GS(CSPS_CPPDescr_JoaTFishing),
		updated = {03, 21, 2025},
		points = "(dynamic)",
		source = "@Orejana",
		role = 7,
		discipline = 1,
		preset = {
			{69, 10}, {70, 15}, {75, 10}, {79, 50}, {78, 15},
			{81, 10}, {91, 25}, {88, 50}, {89, 25}, {85, 30},
			{66, 50}, {81, 50}, {78, 75}, {70, 50}, {69, 50},
			{74, 50}, {71, 50}, {1, 50}, {83, 50}, {84, 50},
			{90, 25}, {76, 25}, {68, 30}, {77, 25}, {75, 50},
			{86,50}, {65, 50}, {279,50}, {87,30}, {67, 40}, {80, 75}, {92, 50}, {82,75}, {72,45}
		},
		slotted = {66, 88, 89, 78},
	},
	[19] = {
		name = "Thieving",
		addInfo = GS(CSPS_CPPDescr_JoaTThieving),
		updated = {03, 21, 2025},
		points = "(dynamic)",
		source = "@Orejana",
		role = 7,
		discipline = 1,
		preset = {
			{68, 30}, {76, 25}, {77, 25}, {80, 75}, {90, 25},
			{67, 40}, {84, 50}, {65, 50}, {66, 50}, {74, 50},
			{71, 50}, {78, 15}, {81, 10}, {91, 25}, {79, 50},
			{81, 50}, {78, 75}, {75, 10}, {85, 30}, {70, 50},
			{1, 50}, {69, 50}, {83, 50}, {75, 50}, {86,50}, {87, 30}, {279, 50},
			{89, 25}, {88, 50}, {92, 50},{82,75},{72,45}
		},
		slotted = {76, 80, 84, 65},
	},
	[20] = {
		name = "Combat focus",
		addInfo = GS(CSPS_CPPDescr_CombatFocus),
		updated = {03, 21, 2025},
		points = "(dynamic)",
		source = "@Irniben",
		role = 7,
		discipline = 1,
		preset = {
			{66,20}, {69,10}, {70,15}, {75,10}, {85,10}, 
			{86,50}, {85,20}, {66,50}, {69,20}, {75,50}, {69,50}, 
			{85,30}, {279,25}, {79,50}, {70,45}, {74,50}, {71,20}, {70, 50}, {279,50},
			{71,50}, {68,30}, {67,40}, {87,30}, {1,50}, {78,15}, 
			{81,10}, {91,25}, {92,50}, {78,75}, {81,50}, {65,50}, 
			{82,75}, {83,50}, {76,25}, {77,25}, {90,25}, {84,50}, {89,25}, {80,75}, {72,45}, {88,50},
		},
		slotted = {66, 92, 65, 82},
	},
	[21] = {
		name = "Crafter/Harvester",
		updated = {03, 21, 2025},
		points = "(dynamic)",
		source = "@Irniben",
		role = 7,
		discipline = 1,
		preset = {
			{74,10}, {71,10}, {72,15}, {83,50}, {78,15}, 
			{81,50}, {78,30}, {70,15}, {75,10}, {85,30}, 
			{66,50}, {78,45}, {74,30}, {79,50}, {74,50}, 
			{91,25}, {78,75}, {70, 50}, {69,50}, {279, 50}, {75,50}, 
			{86,50}, {68,30}, {67,40}, {1,50}, {92,50}, 
			{76,25}, {84,50}, {76,25}, {77,25}, {65,50}, 
			{82,75}, {71,50}, {72,45}, {80,75}, {87,30}, {88,50}, {89,25}, {90,25},
		},
		slotted = {66, 78, 92, 65},
	},
	[22] = {
		name = "Crafter (leveling)",
		updated = {03, 21, 2025},
		points = "(dynamic)",
		source = "@Irniben",
		role = 7,
		discipline = 1,
		preset = {
			{74,10}, {71,10}, {72,45}, {66,50}, {83,50}, {279,50},
			{78,15}, {81,50}, {74,30}, {78,30}, {70,15}, 
			{75,10}, {85,30}, {78,45}, {79,50}, {74,50}, 
			{91,25}, {78,75}, {70, 50}, {69,50}, {75,50}, 
			{86,50}, {68,30}, {67,40}, {1,50}, {92,50}, {71,50}, {90,25}, 
			{76,25}, {84,50}, {76,25}, {77,25}, {65,50}, {87,30},
			{82,75},{80,75},{88,50},{89,25},
		},
		slotted = {66, 78, 92, 65},
	},
	[23] = {
		name = "Allrounder",
		updated = {03, 21, 2025},
		points = "(dynamic)",
		source = "@Irniben",
		role = 7,
		discipline = 1,
		preset = {
			{66,20}, {69,10}, {70,15}, {75,10}, {85,10}, 
			{79,50}, {85,20}, {66,50}, {69,20}, {74,20}, 
			{85,30}, {74,50}, {78,15}, {81,10}, {91,25}, 
			{70,45}, {69,50}, {71,20}, {86,50}, {70, 50}, 
			{75,50}, {71,50}, {279,50}, {68,30}, {67,40}, {87,30},
			{1,50}, {92,50}, {78,75}, {81,50}, {83,50}, {65,50}, {90,25}, {77,25},
			{76,25}, {77,25}, {84,50}, {89,25}, {82,75}, {80,75}, {88,50}, {72,45},
		},
		slotted = {66, 78, 65, 92},
	},
--45 moved to old, 46 is next
	[46] = { 
		name = string.format("Balanced, %s", aoe), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 5,--mag dd
		discipline = 2,	--warfare
		preset = {
			{99,10},{20,10},{14,20},{11,10},{10,10},
			{264,50},{23,50},{8,50},{277,50}, -- slot: masteratarms, biting aura, wrathful strikes, exploiter
			{10,20},{11,20},{17,40},{21,30},{18,40},{22,30},{99,20},{15,20},{16,20},
			{6,20},{20,20},{108,20},
			{25,50}, --deadly aim
			{30,50}, --direct damage heals
			{12,50}, --fighting fitness (critical healing/damage)
			{4,50}, --untamed aggression (weapon/spell damage)
			{31,50}, --backstabber
			{27,50}, --thaumaturge (dot)
			{276,50} --force of nature (offensive penetration)
		},
		slotted = {264,23,8,277},
	},
	[47] = {
		name = string.format("Full DPS, %s", aoe), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 5,	--mag dd
		discipline = 2,	--warfare
		preset = {
			{11,10},{10,10},
			{264,50},{23,50},{8,50},{277,50},-- slot: masteratarms, biting aura, wrathful strikes, explorer
			{10,20},{11,20},{17,40},{21,30},{18,40},{22,30},{99,20},{20,10},{14,20},{15,20},{16,20},
			{25,50}, 
			{6,20},
			{12,50},{4,50}, {31,50}, {27,50}, {276,50}, {30,50}, 
			{20,20},{108,20},
		},
		slotted = {264,23,8,277},
	},
	[48] = { -- like 46 but 23 swapped for 25
		name = string.format("Balanced, %s", singleTarget), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 5,--mag dd
		discipline = 2,	--warfare
		preset = {
			{99,10},{20,10},{14,20},{11,10},{10,10},
			{264,50},{25,50},{8,50},{277,50}, -- slot: masteratarms, deadly aim, wrathful strikes, exploiter
			{10,20},{11,20},{17,40},{21,30},{18,40},{22,30},{99,20},{15,20},{16,20},
			{6,20},{20,20},{108,20},
			{23,50}, {30,50}, {12,50}, {4,50}, {31,50},{27,50}, {276,50} 
		},
		slotted = {264,25,8,277},
	},
	[49] = { -- like 49 but 23 swapped for 25
		name = string.format("Full DPS, %s", singleTarget), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 5,	--mag dd
		discipline = 2,	--warfare
		preset = {
			{11,10},{10,10},
			{264,50},{25,50},{8,50},{277,50},-- slot: masteratarms, deadly aim, wrathful strikes, explorer
			{10,20},{11,20},{17,40},{21,30},{18,40},{22,30},{99,20},{20,10},{14,20},{15,20},{16,20},
			{23,50}, {6,20},
			{12,50}, {4,50}, {31,50}, {27,50}, {276,50}, {30,50}, 
			{20,20},{108,20},
		},
		slotted = {264,25,8,277},
	},
	
	[50] = { 
		name = string.format("Balanced, %s", aoe), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 6, --stam dd
		discipline = 2,	--warfare
		preset = {
			{6,10},{20,10},{14,20},{11,10},{10,10},
			{264,50},{23,50},{8,50},{277,50}, -- slot: masteratarms, biting aura, wrathful strikes, exploiter
			{10,20},{11,20},{18,40},{22,30},{17,40},{21,30},{6,20},{15,20},{16,20},
			{99,20},{20,20},{108,20},
			{25,50}, --deadly aim
			{30,50}, --direct damage heals
			{12,50}, --fighting fitness (critical healing/damage)
			{4,50}, --untamed aggression (weapon/spell damage)
			{31,50}, --backstabber
			{27,50}, --thaumaturge (dot)
			{276,50} --force of nature (offensive penetration)
		},
		slotted = {264,23,8,277},
	},
	[51] = {
		name = string.format("Full DPS, %s", aoe), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 6, --stam dd
		discipline = 2,	--warfare
		preset = {
			{11,10},{10,10},
			{264,50},{23,50},{8,50},{277,50},-- slot: masteratarms, biting aura, wrathful strikes, explorer
			{10,20},{11,20},{18,40},{22,30},{17,40},{21,30},{6,20},{20,10},{14,20},{15,20},{16,20},
			{25,50}, 
			{99,20},
			{12,50},{4,50}, {31,50}, {27,50}, {276,50},
			{20,20},{108,20}, 
			{30,50}, 
		},
		slotted = {264,23,8,277},
	},
	[52] = {
		name = string.format("Balanced, %s", singleTarget), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 6, --stam dd
		discipline = 2,	--warfare
		preset = {
			{6,10},{20,10},{14,20},{11,10},{10,10},
			{264,50},{25,50},{8,50},{277,50}, -- slot: masteratarms, deadly aim, wrathful strikes, exploiter
			{10,20},{11,20},{18,40},{22,30},{17,40},{21,30},{6,20},{15,20},{16,20},
			{99,20},{20,20},{108,20},
			{23,50}, {30,50}, {12,50}, {4,50}, {31,50},{27,50}, {276,50} 
		},
		slotted = {264,25,8,277},
	},
	[53] = { 
		name = string.format("Full DPS, %s", singleTarget), 
		updated = {11, 08, 2025},
		points = "(dynamic)",
		website = "www.youtube.com/c/SkinnyCheeksGaming/",
		source = "Skinny Cheeks",
		role = 6, --stam dd
		discipline = 2,	--warfare
		preset = {
			{11,10},{10,10},
			{264,50},{25,50},{8,50},{277,50},-- slot: masteratarms, deadly aim, wrathful strikes, explorer
			{10,20},{11,20},{18,40},{22,30},{17,40},{21,30},{6,20},{20,10},{14,20},{15,20},{16,20},
			{23,50}, 
			{99,20}, 
			{12,50}, {4,50}, {31,50}, {27,50}, {276,50}, 
			{20,20},{108,20},
			{30,50}, 
		},
		slotted = {264,25,8,277},
	},
}
