local lib = GearOverview

-- Full sets
local Galenwe = { name = "Aegis of Galenwe", id = 388 }
local GalenwePerf = { name = "Perfected Aegis of Galenwe", id = 392 }
local Yolna = { name = "Claw of Yolnahkriin", id = 446 }
local YolnaPerf = { name = "Perfected Claw of Yolnahkriin", id = 451 }
local Crimson = { name = "Crimson Oath's Rive", id = 602 }
local DragonDefile = { name = "Dragon's Defilement", id = 457 }
local EC = { name = "Elemental Catalyst", id = 516 }
local FrozenWatcher = { name = "Frozen Watcher", id = 433 }
local Gossamer = { name = "Gossamer", id = 261 }
local Hollowfang = { name = "Hollowfang Thirst", id = 452 }
local JO = { name = "Jorvuld's Guidance", id = 346 }
local Lucent = { name = "Lucent Echos", id = 768 }
local LucentPerf = { name = "Perfected Lucent Echos", id = 771 }
local MasterArchitect = { name = "Master Architect", id = 332 }
local PearlescentWard = { name = "Pearlescent Ward", id = 648 }
local PearlescentWardPerf = { name = "Perfected Pearlescent Ward", id = 651 }
local Pillagers = { name = "Pillager's Profit", id = 649 }
local PillagersPerf = { name = "Perfected Pillager's Profit", id = 650 }
local Potentates = { name = "Blessing of the Potentates", id = 128 }
local PowerfulAssault = { name = "Powerful Assault", id = 180 }
local Alkosh = { name = "Roar of Alkosh", id = 232 }
local RO = { name = "Roaring Opportunist", id = 496 }
local ROPerf = { name = "Perfected Roaring Opportunist", id = 497 }
local Sax = { name = "Saxhleel Champion", id = 585 }
local SaxPerf = { name = "Perfected Saxhleel Champion", id = 589 }
local SPC = { name = "Spell Power Cure", id = 185 }
local StoneTalker = { name = "Stone-Talker's Oath", id = 588 }
local StoneTalkerPerf = { name = "Perfected Stone-Talker's Oath", id = 592 }
local Olorime = { name = "Vestment of Olorime", id = 391 }
local OlorimePerf = { name = "Perfected Vestment of Olorime", id = 395 }
local Worms = { name = "The Worm's Raiment", id = 124 }
local TT = { name = "Turning Tide", id = 622 }
local WarMachine = { name = "War Machine", id = 331 }
local MK = { name = "Way of Martial Knowledge", id = 147 }
local Zen = { name = "Z'en's Redress", id = 455 }
local Xoryn = { name = "Xoryn's Masterpiece", id = 769 }
local XorynPerf = { name = "Perfected Xoryn's Masterpiece", id = 770 }

-- Arena Sword and Board
local SB_Masters = { name = "Puncturing Remedy", id = 314 } -- Dragonstar Arena
local SB_MastersPerf = { name = "Perfected Puncturing Remedy", id = 529 }
local SB_Maelstrom = { name = "Rampaging Slash", id = 370 } -- Maelstrom Arena
local SB_MaelstromPerf = { name = "Perfected Rampaging Slash", id = 523 }
local SB_VoidBash = { name = "Void Bash", id = 558 } -- Vateshran Hollows
local SB_VoidBashPerf = { name = "Perfected Void Bash", id = 564 }

-- Arena Restoration Staff
local RESTO_ForceOverFlow = { name = "Force Overflow", id = 562 } -- Vateshran Hollows
local RESTO_ForceOverFlowPerf = { name = "Perfected Force Overflow", id = 568 }
local RESTO_GrandRejuv = { name = "Grand Rejuvenation", id = 318 } -- Dragonstar Arena
local RESTO_GrandRejuvPerf = { name = "Perfected Grand Rejuvenation", id = 533 }
local RESTO_BRP = { name = "Mender's Ward", id = 416 } --  Blackrose Prison
local RESTO_BRPPerf = { name = "Perfected Mender's Ward", id = 428 }
local RESTO_PreciseRegen = { name = "Precise Regeneration", id = 374 } -- Maelstrom Arena
local RESTO_PreciseRegenPerf = { name = "Perfected Precise Regeneration", id = 527 }
local RESTO_TimelessBlessing = { name = "Timeless Blessing", id = 368 } --  Asylum Sanctorium
local RESTO_TimelessBlessingPerf = { name = "Perfected Timeless Blessing", id = 362 }
local DESTRO_Crushing = {name = "Crushing Wall", id = 373}
local DESTRO_CrushingPerf = {name = "Perfected Crushing Wall", id = 526}

-- Monster
local Archdruid = { name = "Archdruid Devyric", id = 666 }
local Naz = { name = "Nazaray (Monster Helm)", id = 633 }
local Tremor = { name = "Tremorscale", id = 276 }
local Encratis = { name = "Encratis's Behemoth (Monster Helm)", id = 577 }
local Earthgore = { name = "Earthgore", id = 341 }
local Rkugamz = { name = "Sentinel of Rkugamz", id = 268 }
local EngineGuardian = { name = "Engine Guardian", id = 166 }
local Stonekeeper = { name = "Stonekeeper", id = 432 }
local TrollKing = { name = "The Troll King", id = 278 }
local Symphony = { name = "Symphony of Blades", id = 436 }
local LordWarden = { name = "Lord Warden", id = 164 }
local Thurvokun = { name = "Thurvokun", id = 349 }
local Bloodspawn = { name = "Bloodspawn", id = 163 }
local LadyThorn = { name = "Lady Thorn", id = 535 }
local Nightflame = { name = "Nightflame", id = 167 }
local TheBlind = { name = "The Blind", id = 738 }
local Ozezan = { name = "Ozezan the Inferno", id = 687 }

-- Mythic
local Spaulder = { name = "Spaulder of Ruin", id = 627 }
local Pearls = { name = "Pearls of Ehlnofey", id = 576 }
local WildHunt = { name = "Ring of the Wild Hunt", id = 503 }
local DeathDealersFete = { name = "Death Dealer's Fete", id = 596 }
local TonalConstancy = { name = "Torc of Tonal Constancy", id = 505 }

-- PRESETS
lib.presets = {
	{
		name = "Tank Recommended",
		displayWeapons = "WEAPONS_TANK",
		sets = {
			-- Full sets
			Sax, SaxPerf, Crimson, TT, PowerfulAssault, PearlescentWard, PearlescentWardPerf, Lucent, LucentPerf,
			-- Monster
			Archdruid, Earthgore, Encratis, EngineGuardian, LadyThorn, Naz, Tremor, SB_VoidBash, SB_VoidBashPerf,
			-- Arena
			SB_Masters, SB_MastersPerf, SB_Maelstrom, SB_MaelstromPerf,
			-- Mythic
			Spaulder,
		},
	},
	{
		name = "Tank Extensive",
		displayWeapons = "WEAPONS_TANK",
		sets = {
			-- Full sets
			Yolna, YolnaPerf, Sax, SaxPerf, Crimson, TT, PowerfulAssault, Worms, EC, PearlescentWard, PearlescentWardPerf,
			Galenwe, GalenwePerf, DragonDefile, Alkosh, FrozenWatcher, WarMachine, MasterArchitect, Olorime, OlorimePerf,
			Lucent, LucentPerf,
			-- Monster
			Encratis, Naz, Earthgore, Rkugamz, Tremor, EngineGuardian, Stonekeeper, TrollKing, Symphony,
			LordWarden, Thurvokun, Bloodspawn, LadyThorn, Archdruid,
			-- Arena
			SB_Masters, SB_MastersPerf, SB_Maelstrom, SB_MaelstromPerf, SB_VoidBash, SB_VoidBashPerf,
			-- Mythic
			Spaulder, Pearls, WildHunt, DeathDealersFete, TonalConstancy,
		},
	},
	{
		name = "Healer Recommended",
		displayWeapons = "WEAPONS_HEALER",
		sets = {
			-- Full sets
			Hollowfang, JO, RO, ROPerf, MasterArchitect, Olorime, OlorimePerf, PowerfulAssault, Sax, SaxPerf,
			Pillagers, PillagersPerf, SPC, StoneTalker, StoneTalkerPerf, MK,
			-- Monster
			Symphony, TrollKing, Rkugamz, Naz, Earthgore, Nightflame, Ozezan,
			-- Arena
			RESTO_GrandRejuv, RESTO_GrandRejuvPerf, RESTO_BRP, RESTO_BRPPerf, RESTO_PreciseRegen, RESTO_PreciseRegenPerf,
			-- Mythic
			Spaulder, Pearls,
		},
	},
	{
		name = "Healer Extensive",
		displayWeapons = "WEAPONS_HEALER",
		sets = {
			-- Full sets
			Gossamer, Hollowfang, JO, RO, ROPerf, MasterArchitect, Olorime, OlorimePerf, PowerfulAssault, Sax, SaxPerf,
			Pillagers, PillagersPerf, SPC, StoneTalker, StoneTalkerPerf, MK, Worms, Zen,
			-- Monster
			Symphony, TrollKing, Rkugamz, Encratis, Naz, Earthgore, Nightflame, Ozezan,
			-- Arena
			RESTO_GrandRejuv, RESTO_GrandRejuvPerf, RESTO_ForceOverFlow, RESTO_ForceOverFlowPerf,
			RESTO_PreciseRegen, RESTO_PreciseRegenPerf, RESTO_TimelessBlessing, RESTO_TimelessBlessingPerf,
			RESTO_BRP, RESTO_BRPPerf,
			-- Mythic
			Spaulder, Pearls,
		},
	},
}

local roseTankSets = {
	name = "Tank",
	displayWeapons = "WEAPONS_TANK",
	sets = {
		Sax, SaxPerf, PowerfulAssault, PearlescentWard, PearlescentWardPerf, Lucent, LucentPerf, TT,
		-- Monster
		Archdruid, Naz, Tremor,
		-- Mythic
		Spaulder,
	},
}

local roseHealerSets = {
	name = "Healer",
	displayWeapons = "WEAPONS_HEALER",
	sets = {
		SPC, Pillagers, PillagersPerf, PowerfulAssault, MK, RO, ROPerf, JO, MasterArchitect, Xoryn, XorynPerf, Potentates,
		-- Arena
		RESTO_GrandRejuv, RESTO_GrandRejuvPerf,
		-- Monster
		Symphony, Naz, Ozezan, TheBlind, Archdruid,
		-- Mythic
		Spaulder, Pearls
	},
}

local roseSupportDDSets = {
	name = "Support DD",
	displayWeapons = "WEAPONS_DD",
	sets = {
		Zen,
        WarMachine,
        Alkosh
	}
}

lib.guildPresets = {}

-- Autumn Rose
lib.guildPresets[553666] = {
	roseTankSets,
	roseHealerSets,
	roseSupportDDSets,
}

-- Spring Rose
lib.guildPresets[496448] = {
	roseTankSets,
	roseHealerSets,
	roseSupportDDSets,
}

-- Winter Rose
lib.guildPresets[422980] = {
	roseTankSets,
	roseHealerSets,
	roseSupportDDSets,
}

-- Summer Rose
lib.guildPresets[569338] = {
	roseTankSets,
	roseHealerSets,
	roseSupportDDSets,
}

-- Midnight Rose
lib.guildPresets[586676] = {
	roseTankSets,
	roseHealerSets,
	roseSupportDDSets,
}
