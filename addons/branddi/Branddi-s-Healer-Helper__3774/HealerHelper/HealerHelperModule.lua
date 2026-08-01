--[[
-- beta modules for testing
HealerHelper.hashes	= {
	-- BETA Testers
	[3345028076]   = { true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  },
	[2401453394]   = { true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,   },
	[471943172]    = { true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,   },

	[0]            = { true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  },
	-- MODULE             1,     2,     3,     4,     5,     6,     7,     8,     9,    10,    11,    12,    13,    14,    15,    16,    17,    18,    19,    20,    21,    22,    23,    24,    25,    26,    27,    28,    29,    30,    31,    32,    33,    34,    35,    36,    37,    38,    39,    40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
}

HealerHelper.MODULE_ARCHDRUID = 1
HealerHelper.MODULE_COMBAT_PRAYER_BUFF = 2
HealerHelper.MODULE_COMBAT_PRAYER_BURST = 3
HealerHelper.MODULE_ECHOING_VIGOR = 4
HealerHelper.MODULE_FUNNEL_HEALTH = 5
HealerHelper.MODULE_GEAR_SETS = 6
HealerHelper.MODULE_HEAVY_ATTACK = 7
HealerHelper.MODULE_MAJOR_RESOLVE = 8
HealerHelper.MODULE_MINOR_PROPHECY_SAVAGERY = 9
HealerHelper.MODULE_MINOR_VULNERABILITY = 10
HealerHelper.MODULE_OLORIME = 11
HealerHelper.MODULE_PILLAGERS = 12
HealerHelper.MODULE_PEARLS = 13
HealerHelper.MODULE_POWERFUL_ASSAULT = 14
HealerHelper.MODULE_PURGE = 15
HealerHelper.MODULE_RADIATING_REGEN = 16
HealerHelper.MODULE_RESISTANT_FLESH = 17
HealerHelper.MODULE_ROARING_OPPORTUNIST = 18
HealerHelper.MODULE_SPAULDER = 19
HealerHelper.MODULE_TWILIGHT_MATRIARCH = 20
HealerHelper.MODULE_ULTIMATE_GENERATION = 21
HealerHelper.MODULE_WARD_ALLY = 22
HealerHelper.MODULE_POTION = 23
HealerHelper.MODULE_SELFISH_WARD = 24
HealerHelper.MODULE_HUD = 25
HealerHelper.MODULE_SKILL_BLOCKING = 26
HealerHelper.MODULE_MINOR_SORCERY_BRUTALITY = 27
HealerHelper.MODULE_MINOR_TOUGHNESS = 28


function HealerHelper.isModuleOn(module)
	if module == nil then
		d("isModuleOn is nil")
	end
	return HealerHelper.modules[module]
end

--]]